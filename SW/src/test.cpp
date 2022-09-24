//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include "soc.h"
#include "../base/zta.h"
#include "../base/util.h"
#include "../apps/color/color.h"
#include "../apps/color/kernels/color.h"
#include "../apps/of/of.h"
#include "../apps/of/kernels/of.h"
#include "../apps/canny/canny.h"
#include "../apps/canny/kernels/canny.h"
#include "../apps/harris/harris.h"
#include "../apps/harris/kernels/harris.h"
#include "../apps/resize/resize.h"
#include "../apps/resize/kernels/resize.h"
#include "../apps/gaussian/gaussian.h"
#include "../apps/equalize/equalize.h"
#include "../apps/nn/tf.h"

// This is the test suite for ztachip
// Various vision and AI functions are tested and verified against test vectors

#define MAX_PICT_DIM 1024

#define MAX(a,b) (((a)>(b))?(a):(b))

#define MIN(a,b) (((a)<(b))?(a):(b))

#define ARRAY_ELE(p,dx,dy,x,y,elesize,offset)  ((p)[(y)*(dx)*(elesize)+(x)*(elesize)+(offset)])


// Show progress of the test using LED

static void led() {
   static int count=0;
   count++;
   LedSetState(1<<(count&0x3));
}

// Convert BGR to MONO color

static uint8_t bgr2mono(uint8_t b,uint8_t g,uint8_t r)
{
   int scale=9;
   int32_t _mono;
   int round;

   round=(1<<(scale-1));
   _mono= ((int32_t)r)*154+((int32_t)g)*302+((int32_t)b)*56;
   _mono=((_mono+round)>>scale);
   if(_mono < 0)
      _mono=0;
   else if(_mono > 255)
      _mono=255;
   return (uint8_t)_mono;
}

// Test color conversion

int test_color()
{
   ZTA_SHARED_MEM input_share;
   ZTA_SHARED_MEM output_share;
   uint8_t *input,*output;
   int src_w,src_h;
   int ii;
   uint8_t *split_result,*interleave_result;
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

   input_share=ztaAllocSharedMem(4*MAX_PICT_DIM*MAX_PICT_DIM);
   output_share=ztaAllocSharedMem(4*MAX_PICT_DIM*MAX_PICT_DIM);
   input=(uint8_t *)ZTA_SHARED_MEM_VIRTUAL(input_share);
   output=(uint8_t *)ZTA_SHARED_MEM_VIRTUAL(output_share);
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
         FLUSH_DATA_CACHE();
         assert(rc==ZtaStatusOk);
         graph.Prepare();
         graph.RunUntilCompletion();
         FLUSH_DATA_CACHE();

         led();

         output=(uint8_t *)outputTensor.GetBuf();

         if(dstorder!=kChannelColorMono && dstfmt==kChannelFmtSplit) {
            for(r=0;r < clip_h;r++) {
               for(c=0;c < clip_w;c++) {
                  if(output[r*clip_w+c] != (uint8_t)((r+y_off)*100+(c+x_off))) {
                     exit(0);
                  }
                  if(output[clip_w*clip_h*1+r*clip_w+c] != (uint8_t)((r+y_off)*100+(c+x_off)+1)) {
                     exit(0);
                  }
                  if(output[clip_w*clip_h*2+r*clip_w+c] != (uint8_t)((r+y_off)*100+(c+x_off)+2)) {
                     exit(0);
                  }
               }
            }
         } else if(dstorder!=kChannelColorMono && dstfmt==kChannelFmtInterleave) {
            for(r=0;r < clip_h;r++) {
               for(c=0;c < clip_w;c++) {
                  if(output[3*(r*clip_w+c)+0] != (uint8_t)((r+y_off)*100+(c+x_off))) {
                     exit(0);
                  }
                  if(output[3*(r*clip_w+c)+1] != (uint8_t)((r+y_off)*100+(c+x_off)+1)) {
                     exit(0);
                  }
                  if(output[3*(r*clip_w+c)+2] != (uint8_t)((r+y_off)*100+(c+x_off)+2)) {
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
                        exit(0);
                     }
                  } else if(dstfmt==kChannelFmtSplit) {
                     if(output[(r*clip_w+c)] != mono ||
                        output[(r*clip_w+c)+clip_w*clip_h] != mono ||
                        output[(r*clip_w+c)+clip_w*clip_h*2] != mono) {
                        exit(0);
                     }
                  } else {
                     if(output[(r*clip_w+c)] != bgr2mono(blue,green,red)) {
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
   ztaFreeSharedMem(input_share);
   ztaFreeSharedMem(output_share);
   return 0;
}

// Test optical flow

int test_of() {
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
      sprintf(fname,"optical_flow_%d_in",j+1);
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
   FLUSH_DATA_CACHE();
   graph.Prepare();
   graph.RunUntilCompletion();
   FLUSH_DATA_CACHE();

   memcpy(inputCurr.GetBuf(),input[0].GetBuf(),inputCurr.GetBufLen());
   FLUSH_DATA_CACHE();
   graph.Prepare();
   graph.RunUntilCompletion();
   FLUSH_DATA_CACHE();

   x_gradient_p=(int16_t *)x_gradient.GetBuf();
   y_gradient_p=(int16_t *)y_gradient.GetBuf();
   t_gradient_p=(int16_t *)t_gradient.GetBuf();
   x_vect_p=(int16_t *)x_vect.GetBuf();
   y_vect_p=(int16_t *)y_vect.GetBuf();
   display_p=(uint8_t *)display.GetBuf();

   // Verify X-gradient
   sprintf(fname,"optical_flow_Ix.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);

   if(memcmp(buf,x_gradient_p,w*h*sizeof(int16_t))!=0) {
      exit(0);
   }

   // Verify Y-gradient
   sprintf(fname,"optical_flow_Iy.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);

   if(memcmp(buf,y_gradient_p,w*h*sizeof(int16_t))!=0) {
      exit(0);
   }

   // Verify T-gradient
   sprintf(fname,"optical_flow_It.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);

   if(memcmp(buf,t_gradient_p,w*h*sizeof(int16_t))!=0) {
      exit(0);
   }

   // Verify x_vect
   sprintf(fname,"optical_flow_vx.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);
   if(memcmp(buf,x_vect_p,w*h*sizeof(int16_t))!=0) {
      exit(0);
   }

   // Verify y_vect
   sprintf(fname,"optical_flow_vy.bin");
   fp = fopen(fname, "rb");
   assert(fp);
   fread(buf, 1, w*h*sizeof(int16_t), fp);
   fclose(fp);
   if(memcmp(buf,y_vect_p,w*h*sizeof(int16_t))!=0) {
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
           exit(0);
        }
        if(x_mag < 0)
           v=-x_mag;
        else
           v=0;
        if(v>255)
           v=255;
        if(v != rgb[1]) {
           exit(0);
        }
        if(y_mag < 0)
           v=-y_mag;
        else
           v=y_mag;
        if(v>255)
           v=255;
        if(v != rgb[2]) {
           exit(0);
        }
     }
   }
   free(buf);
   return 0;
}

// test color space conversion

int test_yuyv_to_bgr() {
   uint8_t *output;
   int src_w,src_h;
   int ii,size;
   char fname[256];
   FILE *fp;
   uint8_t *buf;
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

   buf=(uint8_t *)malloc(MAX_PICT_DIM*MAX_PICT_DIM*3);

   for(src_w=100,src_h=100;src_w <= 100;src_w+=2,src_h+=2) {
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

            sprintf(fname,"color_conversion_%d_%d_in.bin",src_w,src_h);
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

            graph.Clear();
            graph.Add(&graphNode);
            rc=graph.Verify();
            assert(rc==ZtaStatusOk);
            FLUSH_DATA_CACHE();
            graph.Prepare();
            graph.RunUntilCompletion();
            FLUSH_DATA_CACHE();

            output=(uint8_t *)outputTensor.GetBuf();

            // Check against result
            sprintf(fname, "color_conversion_%s_%s_%d_%d_out.bin",
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
                        exit(0);
                     }
                  }
               }
            }
         }
      }
   }
   free(buf);
   return 0;
}

// Test edge detection

int test_canny()
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
   GraphNodeCanny graphNode;
   TENSOR inputTensor,outputTensor;
   ZtaStatus rc;
   Graph graph;

   w=200;
   h=200;

   for(x_off=0,y_off=0;x_off <= 0;x_off++,y_off++) {
      src_w=w+2*x_off;
      src_h=h+2*y_off;

      // Read input image...
      sprintf(fname,"canny_%d_in.bin",w);
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

      rc=graphNode.Create(&inputTensor,&outputTensor);
      assert(rc==ZtaStatusOk);

      graph.Clear();
      graph.Add(&graphNode);
      rc=graph.Verify();
      assert(rc==ZtaStatusOk);
      FLUSH_DATA_CACHE();
      graph.Prepare();
      graph.RunUntilCompletion();
      FLUSH_DATA_CACHE();

      output=(uint8_t *)outputTensor.GetBuf();

      buf=(uint8_t *)malloc(w*h);
      sprintf(fname,"canny_%d_out.bin",w);
      fp = fopen(fname, "rb");
      assert(fp);
      fread(buf, 1, w*h, fp);
      fclose(fp);
      if(memcmp(buf,output,w*h) != 0) {
         exit(0);
      }
      free(buf);
   }
   return 0;
}

// Test harris-corner point-of-interest

int test_harris() {
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
   TENSOR inputTensor,outputTensor;
   GraphNodeHarris graphNode;
   Graph graph;
   ZtaStatus rc;

   w=200;
   h=200;

   for(x_off=0,y_off=0;x_off <= 0;x_off++,y_off++) {
      src_w=w+2*x_off;
      src_h=h+2*y_off;

      // Read input image...
      sprintf(fname,"harris_corner_%d_in.bin",w);
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

      rc=graphNode.Create(&inputTensor,&outputTensor);
      assert(rc==ZtaStatusOk);
      graph.Clear();
      graph.Add(&graphNode);
      rc=graph.Verify();
      assert(rc==ZtaStatusOk);
      FLUSH_DATA_CACHE();
      graph.Prepare();
      graph.RunUntilCompletion();
      FLUSH_DATA_CACHE();

      output=(int16_t *)outputTensor.GetBuf();

      buf=(uint8_t *)malloc(w*h*sizeof(int16_t));

      sprintf(fname,"harris_after_suppression.bin");
      fp = fopen(fname, "rb");
      assert(fp);
      fread(buf, 1, w*h*sizeof(int16_t), fp);
      fclose(fp);

      if(memcmp(buf,output,w*h*sizeof(int16_t))!=0) {
         exit(0);
      }
      free(buf);
   }
   return 0;
}

// Test image resize

static void resize(const char *fname_in,int w,int h,const char *fname_out,int dst_w,int dst_h)
{
   GraphNodeResize graph;
   Graph g;
   TENSOR input,output;
   TENSOR outputRef;
   std::vector<int> dim={3,h,w};
   ZtaStatus rc;

   input.CreateWithBitmap(fname_in);

   rc=graph.Create(&input,&output,dst_w,dst_h);
   assert(rc==ZtaStatusOk);
   g.Clear();
   g.Add(&graph);
   rc=g.Verify();
   assert(rc==ZtaStatusOk);
   FLUSH_DATA_CACHE();
   g.Prepare();
   g.RunUntilCompletion();
   FLUSH_DATA_CACHE();
   {
   char fname[100];
   uint8_t *vector=(uint8_t *)malloc(dst_w*dst_h*3);
   memset(vector,0,dst_w*dst_h*3);
   sprintf(fname,"%s",fname_out);
   outputRef.CreateWithBitmap(fname);
   if(memcmp(outputRef.GetBuf(),output.GetBuf(),dst_w*dst_h*3) != 0)
   {
      exit(0);
   }
   free(vector);
   }
}

// Test for different image resize

int test_resize() {
   resize("resize.bmp",960,540,"resize_800_400.bmp",800,400);
   resize("resize.bmp",960,540,"resize_768_300.bmp",768,300);
   resize("resize.bmp",960,540,"resize_660_256.bmp",660,256);
   resize("resize.bmp",960,540,"resize_560_200.bmp",560,200);
   resize("resize.bmp",960,540,"resize_400_180.bmp",400,180);
   resize("resize.bmp",960,540,"resize_320_172.bmp",320,172);
   resize("resize.bmp",960,540,"resize_248_140.bmp",248,140);
   return 0;
}

// Test gaussian blurring

int test_gaussian() {
   uint8_t *buf;
   FILE *fp;
   int i;
   int ch,w,h,dst_w,dst_h;
   int src_w,src_h;
   int size;
   char fname[100];
   uint8_t *input,*output,*p;
   int x_off=0;
   int y_off=0;
   TENSOR inputTensor,outputTensor;
   GraphNodeGaussian graphNode;
   ZtaStatus rc;
   Graph graph;

   buf=(uint8_t *)malloc(MAX_PICT_DIM*MAX_PICT_DIM*3);

   for(x_off=0;x_off <= 0;x_off++) {
      y_off=x_off;
      for(w=200;w <= 200;w++) {
         h=w;
         src_w=w+2*x_off;
         src_h=h+2*y_off;
         dst_w=w;
         dst_h=h;

         std::vector<int> dim={3,src_h,src_w};
         inputTensor.Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim);
         input=(uint8_t *)inputTensor.GetBuf();

         // Read input image...
         sprintf(fname,"gaussian_%d_in.bin",w);
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

         graphNode.Create(&inputTensor,&outputTensor);

         graph.Clear();
         graph.Add(&graphNode);
         rc=graph.Verify();
         assert(rc==ZtaStatusOk);
         FLUSH_DATA_CACHE();
         graph.Prepare();
         graph.RunUntilCompletion();
         FLUSH_DATA_CACHE();

         output=(uint8_t *)outputTensor.GetBuf();

         // Check against result
         sprintf(fname, "gaussian_%d_out.bin",w);
         fp = fopen(fname, "rb");
         assert(fp);
         size=fread(buf, 1, dst_w*dst_w*3, fp);
         assert(size==(dst_w*dst_w*3));

         for(i=0;i < (dst_w*dst_h*3);i++) {
            if(buf[i] != output[i]) {
               exit(0);
            }
         }
         fclose(fp);
      }
   }
   free(buf);
   return 0;
}

// Test histogram

#define HISTOGRAM_W        256
#define HISTOGRAM_H        256
#define HISTOGRAM_CHANNEL  3

int test_histogram()
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

   fp = fopen("histogram_in.bin", "rb");
   assert(fp);
   fread(pict_in, 1, HISTOGRAM_W * HISTOGRAM_H * nchannels, fp);
   fclose(fp);

   fp = fopen("histogram_out.bin", "rb");
   assert(fp);
   fread(pict_out, 1, HISTOGRAM_W * HISTOGRAM_H * nchannels, fp);
   fclose(fp);

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
   FLUSH_DATA_CACHE();
   graph.Prepare();
   graph.RunUntilCompletion();
   FLUSH_DATA_CACHE();
   graph.Prepare();
   graph.RunUntilCompletion();
   FLUSH_DATA_CACHE();

   output2=(uint8_t *)outputTensor.GetBuf();

   for (r = 0; r < (nchannels*dst_h); r++) {
      for (c = 0; c < dst_w; c++) {
         if (output2[r*dst_w + c] != pict_out[r*dst_w + c]) {
            if (ABS(output2[r*dst_w + c] - pict_out[r*dst_w + c]) >= 10) {
               exit(0);
            }
         }
      }
   }
   return 0;
}

// Test mobinet AI model

void test_mobinet()
{
   TENSOR input;
   TENSOR output;
   Graph graph;
   ZtaStatus rc;
   TfliteNn TF2;

   rc=input.CreateWithBitmap("classifier_input.bmp");
   assert(rc==ZtaStatusOk);
   TF2.Create("mobilenet_v2_1_0_224_quant.tflite",&input,1,&output);
   graph.Add(&TF2);
   graph.Verify();

   FLUSH_DATA_CACHE();
   graph.Prepare();
   graph.RunUntilCompletion();
   FLUSH_DATA_CACHE();
   {
   size_t size=output.GetBufLen();
   uint8_t *p=(uint8_t *)malloc(size);
   FILE *fp=fopen("classifier.bin","rb");
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
//      printf("   %d %f\n",top5[i],(float)probability[top5[i]]/255.0);
   }
   fclose(fp);
   free(p);
   }

   TF2.Unload();
}

// Test SSD-Mobinet AI model

void test_mobinet_ssd()
{
   TENSOR input;
   TENSOR output[4];
   Graph graph;
   TfliteNn TF1;

   input.CreateWithBitmap("ssd_input.bmp");
   TF1.Create("detect.tflite",&input,4,&output[0],&output[1],&output[2],&output[3]);
   TF1.LabelLoad("labelmap.txt");
   graph.Add(&TF1);
   graph.Verify();

   FLUSH_DATA_CACHE();
   graph.Prepare();
   graph.RunUntilCompletion();
   FLUSH_DATA_CACHE();

   // Check result
   {
   uint8_t *p;
   FILE *fp;
   size_t size;
   uint8_t *boxes=(uint8_t *)ZTA_SHARED_MEM_VIRTUAL(TF1.BufferGetInterleave(TF1.m_operators[TF1.m_operators.size()-1]->m_def.input[0]));
   uint8_t *classes=(uint8_t *)ZTA_SHARED_MEM_VIRTUAL(TF1.BufferGetInterleave(TF1.m_operators[TF1.m_operators.size()-1]->m_def.input[1]));

   fp=fopen("detect_boxes.bin","rb");
   fseek(fp, 0L, SEEK_END);
   size = ftell(fp);
   p=(uint8_t *)malloc(size);
   fseek(fp, 0L, SEEK_SET);
   if(fread(p,1,size,fp) != size) {
      assert(0);
   }
   if(memcmp(p,boxes,size) != 0) {
      assert(0);
   }
   fclose(fp);
   free(p);

   fp=fopen("detect_classes.bin","rb");
   fseek(fp, 0L, SEEK_END);
   size = ftell(fp);
   p=(uint8_t *)malloc(size);
   fseek(fp, 0L, SEEK_SET);
   if(fread(p,1,size,fp) != size) {
      assert(0);
   }
   if(memcmp(p,classes,size) != 0) {
      assert(0);
   }
   fclose(fp);
   free(p);

#if 0
   { 
   float *box_p;
   float *classes_p;
   float *probability_p;
   float *numDetect_p;
   int xmin,ymin,xmax,ymax,classIdx;
   char *className;
   int numDetect;

   box_p=(float *)output[0].GetBuf();
   classes_p=(float *)output[1].GetBuf();
   probability_p=(float *)output[2].GetBuf();
   numDetect_p=(float *)output[3].GetBuf();

   numDetect=(int)numDetect_p[0];
   for(int i=0;i < (int)numDetect_p[0];i++) {
//      printf("   xmin=%f ymin=%f xmax=%f ymax=%f score=%f class=%d \n",
//      box_p[4*i+1],box_p[4*i+0],box_p[4*i+3],box_p[4*i+2],probability_p[i],(int)classes_p[i]);
      xmin=box_p[4*i+1]*300;
      ymin=box_p[4*i+0]*300;
      xmax=box_p[4*i+3]*300;
      ymax=box_p[4*i+2]*300;
      classIdx=(int)classes_p[i];
      className=(char *)TF1.LabelGet(classIdx);
   }
   }
#endif
   }
   TF1.Unload();
}

// ztachip test suite...

int test()
{
   test_mobinet_ssd();
   test_mobinet();
   test_histogram();
   test_gaussian();
   test_resize();
   test_harris();
   test_canny();
   test_yuyv_to_bgr();
   test_of();
   test_color();
   return 0;
}

