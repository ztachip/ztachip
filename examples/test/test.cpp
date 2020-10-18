#define _XOPEN_SOURCE 700
#include <stdlib.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <assert.h>
#include <sys/mman.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "../../software/target/base/bitmap.h"
#include "../../software/target/base/tensor.h"
#include "../../software/target/apps/nn/tf.h"
#include "../../software/target/apps/color/kernels/color.h"
#include "../../software/target/apps/resize/kernels/resize.h"
#include "../../software/target/apps/resize/resize.h"
#include "../../software/target/apps/color/color.h"
#include "../../software/target/apps/canny/canny.h"
#include "../../software/target/apps/gaussian/gaussian.h"
#include "../../software/target/apps/harris/harris.h"
#include "../../software/target/apps/of/of.h"
#include "../../software/target/apps/equalize/equalize.h"

// Test most features against test vectors.
// This is a good test to run first to make sure ztachip is running fine. 

#define MAX_PICT_DIM 1024
#define MAX(a,b) (((a)>(b))?(a):(b))
#define MIN(a,b) (((a)<(b))?(a):(b))
#define ARRAY_ELE(p,dx,dy,x,y,elesize,offset)  ((p)[(y)*(dx)*(elesize)+(x)*(elesize)+(offset)])
#define HISTOGRAM_W 256
#define HISTOGRAM_H 256
#define HISTOGRAM_CHANNEL 3


int cast_error(const char *errString) {
   printf("\r\n%s\r\n",errString);
   assert(0);
   return 0;
}

static int test_histogram()
{
   uint8_t *input;
   int src_w, src_h;
   uint8_t pict_in[HISTOGRAM_W*HISTOGRAM_H*HISTOGRAM_CHANNEL];
   uint8_t pict_out[HISTOGRAM_W*HISTOGRAM_H*HISTOGRAM_CHANNEL];
   FILE *fp;
   int dst_w,dst_h;
   int nchannels;
   int r,c;
   TENSOR inputTensor,outputTensor;
   ZtaStatus rc;
   Graph graph;
   GraphNodeEqualize graphNode;
   uint8_t *output2;

   nchannels=HISTOGRAM_CHANNEL;

   fp = fopen("data/histogram_in.bin", "rb");
   assert(fp);
   fread(pict_in, 1, HISTOGRAM_W * HISTOGRAM_H * nchannels, fp);
   fclose(fp);

   fp = fopen("data/histogram_out.bin", "rb");
   assert(fp);
   fread(pict_out, 1, HISTOGRAM_W * HISTOGRAM_H * nchannels, fp);
   fclose(fp);

   printf("HISTOGRAM TEST\n");

   dst_w = HISTOGRAM_W;
   dst_h = HISTOGRAM_H;
   src_w = dst_w;
   src_h = dst_h;

   std::vector<int> inputDim={nchannels,src_h,src_w};
   inputTensor.Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,inputDim);
   input=(uint8_t *)inputTensor.GetBuf();
   memcpy(input,pict_in,inputTensor.GetBufLen());

   rc=graphNode.Create(&inputTensor,&outputTensor);
   assert(rc==ZtaStatusOk);
   graph.Add(&graphNode);
   rc=graph.Verify();
   assert(rc==ZtaStatusOk);
   graph.Schedule();
   while(graph.Wait(0) != ZtaStatusOk);
   graph.Schedule();
   while(graph.Wait(0) != ZtaStatusOk);

   output2=(uint8_t *)outputTensor.GetBuf();

   for (r = 0; r < (nchannels*dst_h); r++) {
      for (c = 0; c < dst_w; c++) {
         if (output2[r*dst_w + c] != pict_out[r*dst_w + c]) {
            if (ABS(output2[r*dst_w + c] - pict_out[r*dst_w + c]) >= 10) {
               printf("\r\n FAIL 1 r=%d c=%d original=%d got=%d expect=%d \r\n", r, c,
                        (int)input[(r)*src_w + (c)],
                        (int)output2[r*dst_w + c], pict_out[r*dst_w + c]);
               exit(0);
            }
         }
      }
   }
   printf("HISTOGRAM OK\n");
   return 0;
}

#define SCALE 9
static uint8_t bgr2mono(uint8_t b,uint8_t g,uint8_t r)
{
   int32_t _mono;
   int round=(1<<(SCALE-1));

   _mono= ((int32_t)r)*154+((int32_t)g)*302+((int32_t)b)*56;

   _mono=((_mono+round)>>SCALE);
   if(_mono < 0)
      _mono=0;
   else if(_mono > 255)
      _mono=255;
   return (uint8_t)_mono;
}

static int test_copy()
{
   ZTA_SHARED_MEM input_share;
   ZTA_SHARED_MEM output_share;
   uint8_t *input,*output;
   int src_w,src_h;
   int ii;
   uint8_t *split_result,*interleave_result;
   struct timespec requestStart,requestEnd;
   int timeDuration;
   int minTimeDuration=0x7FFFFFFF;
   int maxTimeDuration=0;
   int srcfmt,dstfmt;
   int srcorder,dstorder;
   int dst_w,dst_h;
   int dst_x,dst_y;
   int x_off,y_off;
   int clip_w,clip_h;
   int r,c;
   int crop;
   uint8_t blue,green,red;
   TENSOR inputTensor,outputTensor;
   TensorSemantic srcColorSpace,dstColorSpace;
   TensorFormat destFormat;
   Graph graph;

   printf("COPY TEST\n");

   input_share=ztahostAllocSharedMem(4*MAX_PICT_DIM*MAX_PICT_DIM);
   output_share=ztahostAllocSharedMem(4*MAX_PICT_DIM*MAX_PICT_DIM);
   input=(uint8_t *)ZTA_SHARED_MEM_P(input_share);
   output=(uint8_t *)ZTA_SHARED_MEM_P(output_share);
   split_result=(uint8_t *)malloc(MAX_PICT_DIM*MAX_PICT_DIM*3);
   interleave_result=(uint8_t *)malloc(MAX_PICT_DIM*MAX_PICT_DIM*3);

   for(src_w=16,src_h=16;src_w < 130;src_w+=2,src_h+=2) {
   for(crop=0;crop <= 8;crop++) {
      clip_w = src_w-crop;
      clip_h = src_h-crop;

      x_off=(src_w-clip_w)/2;
      y_off=(src_h-clip_h)/2;

      dst_x=0;
      dst_y=0;
      dst_w=clip_w;
      dst_h=clip_h;
   
      for(ii=0;ii < 16;ii++) {
         switch(ii) {
            case 0:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtInterleave;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorBGR;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticBGR;
               destFormat=TensorFormatInterleaved;
               break;
            case 1:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtSplit;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorBGR;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticBGR;
               destFormat=TensorFormatSplit;
               break;
            case 2:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtInterleave;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorBGR;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticBGR;
               destFormat=TensorFormatInterleaved;
               break;
            case 3:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtSplit;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorBGR;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticBGR;
               destFormat=TensorFormatSplit;
               break;
            case 4:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtSingle;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticMonochromeSingleChannel;
               destFormat=TensorFormatSplit;
               break;
            case 5:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtSingle;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticMonochromeSingleChannel;
               destFormat=TensorFormatSplit;
               break;
            case 6:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtSingle;
               srcorder=kChannelColorRGB;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticRGB;
               dstColorSpace=TensorSemanticMonochromeSingleChannel;
               destFormat=TensorFormatSplit;
               break;
            case 7:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtSingle;
               srcorder=kChannelColorRGB;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticRGB;
               dstColorSpace=TensorSemanticMonochromeSingleChannel;
               destFormat=TensorFormatSplit;
               break;
            case 8:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtInterleave;
               srcorder=kChannelColorRGB;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticRGB;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatInterleaved;
               break;
            case 9:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtSplit;
               srcorder=kChannelColorRGB;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticRGB;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatSplit;
               break;
            case 10:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtSplit;
               srcorder=kChannelColorRGB;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticRGB;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatSplit;
               break;
            case 11:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtInterleave;
               srcorder=kChannelColorRGB;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticRGB;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatInterleaved;
               break;
            case 12:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtInterleave;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatInterleaved;
               break;
            case 13:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtSplit;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatSplit;
               break;
            case 14:
               srcfmt=kChannelFmtInterleave;
               dstfmt=kChannelFmtSplit;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatSplit;
               break;
            default:
               srcfmt=kChannelFmtSplit;
               dstfmt=kChannelFmtInterleave;
               srcorder=kChannelColorBGR;
               dstorder=kChannelColorMono;
               srcColorSpace=TensorSemanticBGR;
               dstColorSpace=TensorSemanticMonochrome;
               destFormat=TensorFormatInterleaved;
               break;

         }

         for(r=0;r < src_h;r++) {
            for(c=0;c < src_w;c++) {
               split_result[(r*src_w+c)]=(uint8_t)(r*100+c);
               split_result[(r*src_w+c)+src_w*src_h]=(uint8_t)(r*100+c+1);
               split_result[(r*src_w+c)+2*src_w*src_h]=(uint8_t)(r*100+c+2);

               interleave_result[3*(r*src_w+c)+0]=(uint8_t)(r*100+c);
               interleave_result[3*(r*src_w+c)+1]=(uint8_t)(r*100+c+1);
               interleave_result[3*(r*src_w+c)+2]=(uint8_t)(r*100+c+2);      
            }
         }
         if(srcfmt==kChannelFmtInterleave)
            memcpy(input,interleave_result,src_w*src_h*3);
         else
            memcpy(input,split_result,src_w*src_h*3);

         ZtaStatus rc;
         std::vector<int> dim={3,src_w,src_h};
         inputTensor.Create(TensorDataTypeUint8,
                            (srcfmt==kChannelFmtInterleave)?TensorFormatInterleaved:TensorFormatSplit,
                             srcColorSpace,
                             dim);
         if(srcfmt==kChannelFmtInterleave)
            memcpy(inputTensor.GetBuf(),interleave_result,src_w*src_h*3);
         else
             memcpy(inputTensor.GetBuf(),split_result,src_w*src_h*3);
         GraphNodeColorAndReshape node;
         rc=node.Create(&inputTensor,&outputTensor,dstColorSpace,destFormat,x_off,y_off,clip_w,clip_h,dst_x,dst_y,dst_w,dst_h);
         assert(rc==ZtaStatusOk);
         graph.Clear();
         graph.Add(&node);
         rc=graph.Verify();
         assert(rc==ZtaStatusOk);
         graph.Schedule();
         while(graph.Wait(0) != ZtaStatusOk);

         clock_gettime(CLOCK_REALTIME, &requestStart);
         output=(uint8_t *)outputTensor.GetBuf();
         clock_gettime(CLOCK_REALTIME, &requestEnd);
         timeDuration = (requestEnd.tv_sec - requestStart.tv_sec) * 1000000 +
                        +(requestEnd.tv_nsec - requestStart.tv_nsec) / 1000;
         minTimeDuration=MIN(minTimeDuration,timeDuration);
         maxTimeDuration=MAX(maxTimeDuration,timeDuration);

         if(dstorder!=kChannelColorMono && dstfmt==kChannelFmtSplit) {
            for(r=0;r < clip_h;r++) {
               for(c=0;c < clip_w;c++) {
                  if(output[r*clip_w+c] != (uint8_t)((r+y_off)*100+(c+x_off))) {
                     printf("FAIL 1 r=%d c=%d \n",r,c);
                     exit(0);
                  }
                  if(output[clip_w*clip_h*1+r*clip_w+c] != (uint8_t)((r+y_off)*100+(c+x_off)+1)) {
                     printf("FAIL 2 r=%d c=%d \n",r,c);
                     exit(0);
                  }
                  if(output[clip_w*clip_h*2+r*clip_w+c] != (uint8_t)((r+y_off)*100+(c+x_off)+2)) {
                     printf("FAIL 3 r=%d c=%d \n",r,c);
                     exit(0);
                  }
               }
            }
	 } else if(dstorder!=kChannelColorMono && dstfmt==kChannelFmtInterleave) {
            for(r=0;r < clip_h;r++) {
               for(c=0;c < clip_w;c++) {
                  if(output[3*(r*clip_w+c)+0] != (uint8_t)((r+y_off)*100+(c+x_off))) {
                     printf("FAIL 4 r=%d c=%d \n",r,c);
                     exit(0);
                  }
                  if(output[3*(r*clip_w+c)+1] != (uint8_t)((r+y_off)*100+(c+x_off)+1)) {
                     printf("FAIL 5 r=%d c=%d \n",r,c);
                     exit(0);
                  }
                  if(output[3*(r*clip_w+c)+2] != (uint8_t)((r+y_off)*100+(c+x_off)+2)) {
                     printf("FAIL 6 r=%d c=%d \n",r,c);
                     exit(0);
                  }
               }
            }
	 } else {
            // Check for monochrome result....
            for(r=0;r < clip_h;r++) {
               for(c=0;c < clip_w;c++) {
                  uint8_t mono;
                  if(srcorder==kChannelColorBGR) {
                     blue=(uint8_t)((r+y_off)*100+(c+x_off));
                     green=(uint8_t)((r+y_off)*100+(c+x_off)+1);
                     red=(uint8_t)((r+y_off)*100+(c+x_off)+2);
                  } else {
                     red=(uint8_t)((r+y_off)*100+(c+x_off));
                     green=(uint8_t)((r+y_off)*100+(c+x_off)+1);
                     blue=(uint8_t)((r+y_off)*100+(c+x_off)+2);
                  }
                  mono=bgr2mono(blue,green,red);
                  if(dstfmt==kChannelFmtInterleave) {
                     if(output[3*(r*clip_w+c)+0] != mono || output[3*(r*clip_w+c)+1] != mono || output[3*(r*clip_w+c)+2] != mono) {
                        printf("FAIL 4 r=%d c=%d \n",r,c);
                        exit(0);
                     }
		  } else if(dstfmt==kChannelFmtSplit) {
                     if(output[(r*clip_w+c)] != mono || 
                        output[(r*clip_w+c)+clip_w*clip_h] != mono || 
                        output[(r*clip_w+c)+clip_w*clip_h*2] != mono) {
                        printf("FAIL 4 r=%d c=%d \n",r,c);
                        exit(0);
                     }
                  } else {
                     if(output[(r*clip_w+c)] != bgr2mono(blue,green,red)) {
                        printf("FAIL 4 r=%d c=%d \n",r,c);
                        exit(0);
                     }
                  } 
               }
            }
         }
      }
   }
   }
   free(interleave_result);
   free(split_result);
   ztahostFreeSharedMem(input_share);
   ztahostFreeSharedMem(output_share);
   printf("COPY OK\n");
   return 0;
}

static int test_yuyv_to_bgr()
{
   uint8_t *output;
   int src_w,src_h;
   int ii,size;
   char fname[256];
   FILE *fp;
   uint8_t *buf;
   struct timespec requestStart,requestEnd;
   int timeDuration;
   int minTimeDuration=0x7FFFFFFF;
   int maxTimeDuration=0;
   int fmt;
   int order;
   int dst_w,dst_h;
   int x_off,y_off;
   int r,c;
   int crop;
   ZtaStatus rc;
   TENSOR inputTensor,outputTensor;
   GraphNodeColorAndReshape graphNode;
   Graph graph;

   printf("YUYV_TO_BGR TEST\n");

   buf=(uint8_t *)malloc(MAX_PICT_DIM*MAX_PICT_DIM*3);

   for(src_w=16,src_h=16;src_w < 130;src_w+=2,src_h+=2) {
      if(src_w==128) {
         src_w=640;
         src_h=480;
      }
      for(crop=0;crop <= 8;crop+=2) {
         dst_w = src_w-crop;
         dst_h = src_h-crop;

         x_off=(src_w-dst_w)/2;
         x_off=(x_off/2)*2;
         y_off=(src_h-dst_h)/2;
         y_off=(y_off/2)*2;

         for(ii=0;ii < 4;ii++) {
            switch(ii) {
               case 0:
                  fmt=kChannelFmtSplit;order=kChannelColorRGB;
                  break;
               case 1:
                  fmt=kChannelFmtSplit;order=kChannelColorBGR;
                  break;
               case 2:
                  fmt=kChannelFmtInterleave;order=kChannelColorRGB;
                  break;
               default:
                  fmt=kChannelFmtInterleave;order=kChannelColorBGR;
                  break;
            }

            // Read input image...

            std::vector<int> dim={1,src_h,src_w};
            rc=inputTensor.Create(TensorDataTypeUint16,TensorFormatSplit,TensorSemanticYUYV,dim);
            assert(rc==ZtaStatusOk);

            sprintf(fname,"data/color_conversion_%d_%d_in.bin",src_w,src_h);
            fp=fopen(fname,"rb");
            assert(fp);
            size=fread(inputTensor.GetBuf(),1,src_w*src_h*2,fp);
            assert(size==(src_w*src_h*2));
            fclose(fp);

            rc=graphNode.Create(
                    &inputTensor,
                    &outputTensor,
                    (order==kChannelColorRGB)?TensorSemanticRGB:TensorSemanticBGR,
                    (fmt==kChannelFmtSplit)?TensorFormatSplit:TensorFormatInterleaved,
                    x_off,
                    y_off,
                    dst_w,
                    dst_h);
            assert(rc==ZtaStatusOk);

            clock_gettime(CLOCK_REALTIME, &requestStart);

            graph.Clear();
            graph.Add(&graphNode);
            rc=graph.Verify();
            assert(rc==ZtaStatusOk);
            graph.Schedule();
            while(graph.Wait(0) != ZtaStatusOk);
            output=(uint8_t *)outputTensor.GetBuf();

            clock_gettime(CLOCK_REALTIME, &requestEnd);
            timeDuration = (requestEnd.tv_sec - requestStart.tv_sec) * 1000000 +
                          +(requestEnd.tv_nsec - requestStart.tv_nsec) / 1000;
            minTimeDuration=MIN(minTimeDuration,timeDuration);
            maxTimeDuration=MAX(maxTimeDuration,timeDuration);

            // Check against result
            sprintf(fname, "data/color_conversion_%s_%s_%d_%d_out.bin",
                   (order==kChannelColorBGR)?"bgr":"rgb",
                   (fmt==kChannelFmtInterleave)?"interleave":"split",
                   src_w,src_h);
            fp = fopen(fname, "rb");
            assert(fp);
            size=fread(buf, 1, src_w*src_h*3, fp);
            assert(size==(src_w*src_h*3));
            fclose(fp);

            if (fmt == kChannelFmtSplit) {
               uint8_t *p1, *p2;
               int ch;
               for (ch = 0, p1 = buf, p2 = output; ch < 3; ch++, p1 += src_w*src_h, p2 += dst_w*dst_h) {
                  for (r = 0; r < dst_h; r++) {
                     for (c = 0; c < dst_w; c++) {
                        if (ARRAY_ELE(p1, src_w, src_h, c + x_off, r + y_off, 1,0) != ARRAY_ELE(p2, dst_w, dst_h, c, r, 1,0)) {
                           printf("\r\n [r=%d c=%d] ", r, c);
                           printf("  **** MISMATCH **** ");
                           exit(0);
                        }
                     }
                  }
               }
	    } else {
               for (r = 0; r < dst_h; r++) {
                  for (c = 0; c < dst_w; c++) {
                     if (ARRAY_ELE(buf, src_w, src_h, c + x_off, r + y_off, 3, 0) != ARRAY_ELE(output, dst_w, dst_h, c, r, 3, 0) ||
                         ARRAY_ELE(buf, src_w, src_h, c + x_off, r + y_off, 3, 1) != ARRAY_ELE(output, dst_w, dst_h, c, r, 3, 1) ||
                         ARRAY_ELE(buf, src_w, src_h, c + x_off, r + y_off, 3, 2) != ARRAY_ELE(output, dst_w, dst_h, c, r, 3, 2)) {
                        printf("\r\n [r=%d c=%d]  ", r, c);
                        printf("  **** MISMATCH **** ");
                        exit(0);
                     }
                  }
               }
            }
         }
      }
   }
   free(buf);
   printf("YUYV_TO_BGR OK\n");
   return 0;
}

#define NCHANNEL 3

#define SIGMA 0.84089642
#define PI 3.14159265


static int test_gaussian() {
   uint8_t *buf;
   FILE *fp;
   int i;
   int ch,w,h,dst_w,dst_h;
   int src_w,src_h;
   int size;
   char fname[100];
   uint8_t *input,*output,*p;
   struct timespec requestStart,requestEnd;
   int timeDuration;
   int minTimeDuration=0x7FFFFFFF;
   int maxTimeDuration=0;
   int x_off=0;
   int y_off=0;
   TENSOR inputTensor,outputTensor;
   GraphNodeGaussian graphNode;
   ZtaStatus rc;
   Graph graph;

   printf("GAUSSIAN TEST\n");

   buf=(uint8_t *)malloc(MAX_PICT_DIM*MAX_PICT_DIM*3);

   for(x_off=0;x_off <= 0;x_off++) {
      y_off=x_off;
      for(w=200;w <= 232;w++) {
         h=w;
         src_w=w+2*x_off;
         src_h=h+2*y_off;
         dst_w=w;
         dst_h=h;

         std::vector<int> dim={3,src_h,src_w};
         inputTensor.Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim);
         input=(uint8_t *)inputTensor.GetBuf();

         // Read input image...
         sprintf(fname,"data/gaussian_%d_in.bin",w);
         fp=fopen(fname,"rb");
         assert(fp);
         memset(input,0,src_w*src_h*3);

         for(ch=0;ch<3;ch++) {
            p=input+src_w*src_h*ch+(src_w*y_off)+x_off;
            for(i=0;i < h;i++) {
               fread(p,1,w,fp);
               p+=src_w;
            }
         }
         fclose(fp);

         clock_gettime(CLOCK_REALTIME, &requestStart);

         graphNode.Create(&inputTensor,&outputTensor);

         graph.Clear();
         graph.Add(&graphNode);
         rc=graph.Verify();
         assert(rc==ZtaStatusOk);
         graph.Schedule();
         while(graph.Wait(0) != ZtaStatusOk);

         output=(uint8_t *)outputTensor.GetBuf();

         clock_gettime(CLOCK_REALTIME, &requestEnd);
         timeDuration = (requestEnd.tv_sec - requestStart.tv_sec) * 1000000 +
                        +(requestEnd.tv_nsec - requestStart.tv_nsec) / 1000;
         minTimeDuration=MIN(minTimeDuration,timeDuration);
         maxTimeDuration=MAX(maxTimeDuration,timeDuration);

         // Check against result
         sprintf(fname, "data/gaussian_%d_out.bin",w);
         fp = fopen(fname, "rb");
         assert(fp);
         size=fread(buf, 1, dst_w*dst_w*3, fp);
         assert(size==(dst_w*dst_w*3));

         for(i=0;i < (dst_w*dst_h*3);i++) {
            if(buf[i] != output[i]) {
               printf("MISMATCH i=%d [got=%02X expect=%02X*****\n",i,(int)output[i],(int)buf[i]);
               exit(0);
            }
         }
         fclose(fp);
      }
   }
   free(buf);
   printf("GAUSSIAN OK\n");
   return 0;
}

static int test_canny()
{
   char fname[200];
   FILE *fp;
   int w,h;
   int i;
   int src_w,src_h;
   int x_off,y_off;
   uint8_t *input,*output;
   uint8_t *buf;
   uint8_t *p;
   struct timespec requestStart,requestEnd;
   int timeDuration;
   int minTimeDuration=0x7FFFFFFF;
   int maxTimeDuration=0;
   GraphNodeCanny graphNode;
   TENSOR inputTensor,outputTensor;
   ZtaStatus rc;
   Graph graph;

   w=200;
   h=200;

   printf("CANNY TEST\n");
   for(x_off=0,y_off=0;x_off <= 0;x_off++,y_off++) {
      src_w=w+2*x_off;
      src_h=h+2*y_off;

      // Read input image...
      sprintf(fname,"data/canny_%d_in.bin",w);
      fp=fopen(fname,"rb");
      assert(fp);

      std::vector<int> input_dim={1,src_w,src_h};
      inputTensor.Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticMonochromeSingleChannel,input_dim);
      input=(uint8_t *)inputTensor.GetBuf();

      memset(input,0,src_w*src_h);
      p=input+(src_w*y_off)+x_off;
      for(i=0;i < h;i++) {
         fread(p,1,w,fp);
         p+=src_w;
      }
      fclose(fp);

      clock_gettime(CLOCK_REALTIME, &requestStart);

      rc=graphNode.Create(&inputTensor,&outputTensor);
      assert(rc==ZtaStatusOk);

      graph.Clear();
      graph.Add(&graphNode);
      rc=graph.Verify();
      assert(rc==ZtaStatusOk);
      graph.Schedule();
      while(graph.Wait(0) != ZtaStatusOk);

      output=(uint8_t *)outputTensor.GetBuf();

      clock_gettime(CLOCK_REALTIME, &requestEnd);
      timeDuration = (requestEnd.tv_sec - requestStart.tv_sec) * 1000000 +
                     +(requestEnd.tv_nsec - requestStart.tv_nsec) / 1000;
      minTimeDuration=MIN(minTimeDuration,timeDuration);
      maxTimeDuration=MAX(maxTimeDuration,timeDuration);

      buf=(uint8_t *)malloc(w*h);
      sprintf(fname,"data/canny_%d_out.bin",w);
      fp = fopen(fname, "rb");
      assert(fp);
      fread(buf, 1, w*h, fp);
      fclose(fp);
      if(memcmp(buf,output,w*h) != 0) {
         printf("MISMATCH\n");
         exit(0);
      }
      free(buf);
   }
   printf("CANNY OK\n");
   return 0;
}

static int test_harris() {
   char fname[200];
   FILE *fp;
   int w,h;
   int i;
   int src_w,src_h;
   int x_off,y_off;
   uint8_t *input;
   int16_t *output;
   uint8_t *buf;
   uint8_t *p;
   struct timespec requestStart,requestEnd;
   int timeDuration;
   int minTimeDuration=0x7FFFFFFF;
   int maxTimeDuration=0;
   TENSOR inputTensor,outputTensor;
   GraphNodeHarris graphNode;
   Graph graph;
   ZtaStatus rc;

   printf("HARRIS_CORNER TEST\n");

   w=200;
   h=200;

   for(x_off=0,y_off=0;x_off <= 0;x_off++,y_off++) {
      src_w=w+2*x_off;
      src_h=h+2*y_off;

      // Read input image...
      sprintf(fname,"data/harris_corner_%d_in.bin",w);
      fp=fopen(fname,"rb");
      assert(fp);

      std::vector<int> dim={1,src_h,src_w};
      inputTensor.Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticMonochromeSingleChannel,dim);
      input=(uint8_t *)inputTensor.GetBuf();

      memset(input,0,src_w*src_h);
      p=input+(src_w*y_off)+x_off;
      for(i=0;i < h;i++) {
         fread(p,1,w,fp);
         p+=src_w;
      }
      fclose(fp);

      clock_gettime(CLOCK_REALTIME, &requestStart);

      rc=graphNode.Create(&inputTensor,&outputTensor);
      assert(rc==ZtaStatusOk);
      graph.Clear();
      graph.Add(&graphNode);
      rc=graph.Verify();
      assert(rc==ZtaStatusOk);
      graph.Schedule();
      while(graph.Wait(0) != ZtaStatusOk);

      output=(int16_t *)outputTensor.GetBuf();
      clock_gettime(CLOCK_REALTIME, &requestEnd);
      timeDuration = (requestEnd.tv_sec - requestStart.tv_sec) * 1000000 +
         +(requestEnd.tv_nsec - requestStart.tv_nsec) / 1000;
      minTimeDuration=MIN(minTimeDuration,timeDuration);
      maxTimeDuration=MAX(maxTimeDuration,timeDuration);

      buf=(uint8_t *)malloc(w*h*sizeof(int16_t));

      sprintf(fname,"data/harris_after_suppression.bin");
      fp = fopen(fname, "rb");
      assert(fp);
      fread(buf, 1, w*h*sizeof(int16_t), fp);
      fclose(fp);

      if(memcmp(buf,output,w*h*sizeof(int16_t))!=0) {
         printf("\r\nHARRIS CORNER MISMATCH \r\n");
         exit(0);
      }
      free(buf);
   }
   printf("HARRIS OK\n");
   return 0;
}

static int test_of() {
   char fname[200];
   FILE *fp;
   int w,h;
   int i,j;
   int src_w,src_h;
   TENSOR input[2];
   TENSOR inputCurr;
   TENSOR x_gradient;
   TENSOR y_gradient;
   TENSOR t_gradient;
   TENSOR x_vect;
   TENSOR y_vect;
   TENSOR display;
   uint8_t *input_p[2];
   int16_t *x_gradient_p;
   int16_t *y_gradient_p;
   int16_t *t_gradient_p;
   int16_t *x_vect_p;
   int16_t *y_vect_p;
   uint8_t *display_p;
   uint8_t *buf;
   uint8_t *p;
   GraphNodeOpticalFlow graphNode;
   Graph graph;
   ZtaStatus rc;

   printf("OPTICAL FLOW TEST\n");

   buf=(uint8_t *)malloc(MAX_PICT_DIM*MAX_PICT_DIM*sizeof(int16_t));

   w=640;
   h=480;

   src_w=w;
   src_h=h;

   // Load the 2 images


   std::vector<int> dim={1,src_h,src_w};
   input[0].Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticMonochromeSingleChannel,dim);
   input[1].Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticMonochromeSingleChannel,dim);
   inputCurr.Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticMonochromeSingleChannel,dim);
   input_p[0]=(uint8_t *)input[0].GetBuf();
   input_p[1]=(uint8_t *)input[1].GetBuf();

   for(j=0;j < 2;j++) {
      sprintf(fname,"data/optical_flow_%d_in.bin",j+1);
      fp=fopen(fname,"rb");
      assert(fp);
      memset(input_p[j],0,src_w*src_h);
      p=input_p[j];
      for(i=0;i < h;i++) {
         fread(p,1,w,fp);
         p+=src_w;
      }
      fclose(fp);
   }

   rc=graphNode.Create(&inputCurr,&x_gradient,&y_gradient,&t_gradient,&x_vect,&y_vect,&display);
   assert(rc==ZtaStatusOk);
   graph.Clear();
   graph.Add(&graphNode);
   rc=graph.Verify();
   assert(rc==ZtaStatusOk);


   memcpy(inputCurr.GetBuf(),input[1].GetBuf(),inputCurr.GetBufLen());
   graph.Schedule();
   while(graph.Wait(0) != ZtaStatusOk);
   memcpy(inputCurr.GetBuf(),input[0].GetBuf(),inputCurr.GetBufLen());
   graph.Schedule();
   while(graph.Wait(0) != ZtaStatusOk);


   x_gradient_p=(int16_t *)x_gradient.GetBuf();
   y_gradient_p=(int16_t *)y_gradient.GetBuf();
   t_gradient_p=(int16_t *)t_gradient.GetBuf();
   x_vect_p=(int16_t *)x_vect.GetBuf();
   y_vect_p=(int16_t *)y_vect.GetBuf();
   display_p=(uint8_t *)display.GetBuf();


   // Verify X-gradient
   sprintf(fname,"data/optical_flow_Ix.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);

   if(memcmp(buf,x_gradient_p,w*h*sizeof(int16_t))!=0) {
      printf("IX mismatch\n");
      exit(0);
   }

   // Verify Y-gradient
   sprintf(fname,"data/optical_flow_Iy.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);

   if(memcmp(buf,y_gradient_p,w*h*sizeof(int16_t))!=0) {
      printf("IY mismatch\n");
      exit(0);
   }

   // Verify T-gradient
   sprintf(fname,"data/optical_flow_It.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);

   if(memcmp(buf,t_gradient_p,w*h*sizeof(int16_t))!=0) {
      printf("It mismatch\n");
      exit(0);
   }

   // Verify x_vect
   sprintf(fname,"data/optical_flow_vx.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);
   if(memcmp(buf,x_vect_p,w*h*sizeof(int16_t))!=0) {
      printf("VX mismatch\n");
      exit(0);
   }

   // Verify y_vect
   sprintf(fname,"data/optical_flow_vy.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);
   if(memcmp(buf,y_vect_p,w*h*sizeof(int16_t))!=0) {
      printf("VY mismatch\n");
      exit(0);
   }


   // Verify magnitude vector
   int x_mag,y_mag;
   int v;
   uint8_t rgb[3];
   for(int r=0;r<src_h;r++) {
     for(int c=0;c < src_w;c++) {
        x_mag=x_vect_p[r*src_w+c];
        y_mag=y_vect_p[r*src_w+c];
        rgb[0]=display_p[r*src_w+c];
        rgb[1]=display_p[r*src_w+c+src_w*src_h];
        rgb[2]=display_p[r*src_w+c+2*src_w*src_h];
        if(x_mag > 0)
           v=x_mag;
        else
           v=0;
        if(v>255)
           v=255;
        if(v != rgb[0]) {
           printf("MISMATCH \n");
           exit(0);
        }        
        if(x_mag < 0)
           v=-x_mag;
        else
           v=0;
        if(v>255)
           v=255;
        if(v != rgb[1]) {
           printf("MISMATCH \n");
           exit(0);
        }        
        if(y_mag < 0)
           v=-y_mag;
        else
           v=y_mag;
        if(v>255)
           v=255;
        if(v != rgb[2]) {
           printf("MISMATCH \n");
           exit(0);
        }        
     }
   }
   printf("OPTICAL FLOW OK\n");
   free(buf);
   return 0;
}

static TfliteNn TF2;

static void test_mobinet_ssd()
{ 
   struct timespec tic,toc;
   int timeDuration;
   TENSOR input;
   TENSOR output[4];
   Graph graph;
   TfliteNn TF1;
   float *box_p;
   float *classes_p;
   float *probability_p;
   float *numDetect_p;

   printf("MOBINET_SSD TEST\n");

   BitmapRead("data/ssd_input.bmp",&input);
   TF1.Create("../models/detect.tflite",&input,4,&output[0],&output[1],&output[2],&output[3]);
   graph.Add(&TF1);
   graph.Verify();
   clock_gettime(CLOCK_REALTIME,&tic);
   graph.Schedule();
   while(graph.Wait(0) != ZtaStatusOk);
   clock_gettime(CLOCK_REALTIME,&toc);

   timeDuration = (toc.tv_sec - tic.tv_sec) * 1000000 +
      +(toc.tv_nsec - tic.tv_nsec) / 1000;
   printf("   TimeElapsed(usec)=%d\n",timeDuration);

   // Check result
   {
   uint8_t *p;
   FILE *fp;
   size_t size;
   uint8_t *boxes=(uint8_t *)ZTA_SHARED_MEM_P(TF1.BufferGetInterleave(TF1.m_operators[TF1.m_operators.size()-1]->m_def.input[0]));
   uint8_t *classes=(uint8_t *)ZTA_SHARED_MEM_P(TF1.BufferGetInterleave(TF1.m_operators[TF1.m_operators.size()-1]->m_def.input[1]));
   size=ZTA_SHARED_MEM_LEN(TF1.BufferGetInterleave(TF1.m_operators[TF1.m_operators.size()-1]->m_def.input[0]));
   p=(uint8_t *)malloc(size);
   fp=fopen("data/detect_boxes.bin","rb");
   if(fread(p,1,size,fp) != size) {
      assert(0);
   }
   if(memcmp(p,boxes,size) != 0) {
      assert(0);
   }
   fclose(fp);
   free(p);
   size=ZTA_SHARED_MEM_LEN(TF1.BufferGetInterleave(TF1.m_operators[TF1.m_operators.size()-1]->m_def.input[1]));
   p=(uint8_t *)malloc(size);
   fp=fopen("data/detect_classes.bin","rb");
   if(fread(p,1,size,fp) != size) {
      assert(0);
   }
   if(memcmp(p,classes,size) != 0) {
      assert(0);
   }
   fclose(fp);
   free(p);

   box_p=(float *)output[0].GetBuf();
   classes_p=(float *)output[1].GetBuf();
   probability_p=(float *)output[2].GetBuf();
   numDetect_p=(float *)output[3].GetBuf();

   for(int i=0;i < (int)numDetect_p[0];i++) {
      printf("   xmin=%f ymin=%f xmax=%f ymax=%f score=%f class=%d \n",
      box_p[4*i+1],box_p[4*i+0],box_p[4*i+3],box_p[4*i+2],probability_p[i],(int)classes_p[i]);
   }   
   printf("MOBINET_SSD OK\n");
   }
   TF1.Unload();
}

static void test_mobinet()
{
   struct timespec tic,toc;
   int timeDuration;
   TENSOR input;
   TENSOR output;
   Graph graph;
   ZtaStatus rc;

   printf("MOBINET TEST\n");
   rc=BitmapRead("data/classifier_input.bmp",&input);
   assert(rc==ZtaStatusOk);
   TF2.Create("../models/mobilenet_v2_1.0_224_quant.tflite",&input,1,&output);
   graph.Add(&TF2);
   graph.Verify();
   clock_gettime(CLOCK_REALTIME,&tic);
   graph.Schedule();
   while(graph.Wait(0) != ZtaStatusOk);
   clock_gettime(CLOCK_REALTIME,&toc);

   timeDuration = (toc.tv_sec - tic.tv_sec) * 1000000 +
      +(toc.tv_nsec - tic.tv_nsec) / 1000;
   printf("   TimeElapsed(usec)=%d\n",timeDuration);

   {
   size_t size=output.GetBufLen();
   uint8_t *p=(uint8_t *)malloc(size);
   FILE *fp=fopen("data/classifier.bin","rb");
   assert(fp);
   if(fread(p,1,size,fp) != size) {
      assert(0);
   }
   if(memcmp(p,output.GetBuf(),size) != 0) {
      assert(0);
   }
   int top5[5];
   uint8_t *probability=(uint8_t *)output.GetBuf();
   NeuralNet::GetTop5(probability,output.GetBufLen(),top5);
   for(int i=0;i < 5;i++)
   {
      printf("   %d %f\n",top5[i],(float)probability[top5[i]]/255.0);
   }

   printf("MOBINET OK\n");
   fclose(fp);
   free(p);
   }
   TF2.Unload();
}

static void resize(const char *fname_in,int w,int h,const char *fname_out,int dst_w,int dst_h)
{
   GraphNodeResize graph;
   Graph g;
   TENSOR input,output;
   TENSOR outputRef;
   std::vector<int> dim={3,h,w};
   ZtaStatus rc;

   BitmapRead(fname_in,&input);

   rc=graph.Create(&input,&output,dst_w,dst_h);
   assert(rc==ZtaStatusOk);
   g.Clear();
   g.Add(&graph);
   rc=g.Verify();
   assert(rc==ZtaStatusOk);
   g.Schedule();
   while(g.Wait(0) != ZtaStatusOk);
   {
   char fname[100];
   uint8_t *vector=(uint8_t *)malloc(dst_w*dst_h*3);
   memset(vector,0,dst_w*dst_h*3);
   sprintf(fname,"%s",fname_out);
   BitmapRead(fname,&outputRef);
   if(memcmp(outputRef.GetBuf(),output.GetBuf(),dst_w*dst_h*3) != 0)
   {
      printf("MISMATCH \n");
      exit(0);
   }
   free(vector);
   }
}

static int test_resize() {
   printf("RESIZE TEST\n");
   resize("data/resize.bmp",960,540,"data/resize_800_400.bmp",800,400);
   resize("data/resize.bmp",960,540,"data/resize_768_300.bmp",768,300);
   resize("data/resize.bmp",960,540,"data/resize_660_256.bmp",660,256);
   resize("data/resize.bmp",960,540,"data/resize_560_200.bmp",560,200);
   resize("data/resize.bmp",960,540,"data/resize_400_180.bmp",400,180);
   resize("data/resize.bmp",960,540,"data/resize_320_172.bmp",320,172);
   resize("data/resize.bmp",960,540,"data/resize_248_140.bmp",248,140);
   printf("RESIZE OK\n");
   return 0;
}

int main()
{
   int loopCount=0;
   system("echo 2 > /proc/cpu/alignment");
   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   for(;;) {
      printf("*************** TEST COUNT=%d ********\n",loopCount);
      printf("totalSharedMem=%d\n",ztahostGetTotalAllocSharedMem());
      system("free");
      printf("*************************************\n");
      test_mobinet_ssd();
      test_mobinet();
      test_gaussian();
      test_of();
      test_copy();
      test_histogram();
      test_resize();
      test_yuyv_to_bgr();
      test_canny();
      test_harris();
      loopCount++;
   }
   return 0;
}
