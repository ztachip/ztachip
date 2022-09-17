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

#include <stdbool.h>
#include "../../../base/ztam.h"
#include "../../main/kernels/main.h"
#include "resize.h"
#include "resize.p.img"

// Perform image resize using bicubic interpolation

#define PAD_VALUE 0
#define TILE_DIM_P  (TILE_DIM+TILE_PAD)

extern void mycallback(int);

typedef struct {
   uint32_t input;
   uint32_t output;
   int nchannel;
   uint32_t spu;
   int scale;
   int w;
   int h;
   int x_off;
   int y_off;
   int src_w;
   int src_h;
   int dst_w;
   int dst_h;
   struct {
      uint32_t init;
      uint32_t init2;
      uint32_t scratch;
      int *scale0;
      int *scale1;
      int *scale2;
      int loopstep;
   } ws;
} Request;

// Image resize using bicubic interpolation

static void resize(void *_p,int pid) {
   Request *req=(Request *)_p;
   int dx,dy2,dy1;
   int dxcnt,dycnt;
   int i,cnt;
   int nt;
   uint32_t output;
   uint32_t input;
   int inputLen,inputLen2;
   int ch;
   int h,x,y;
   int remain,left,from,to;
   int dst_num_tiles;
   int dst_w,dst_h;

   // Input pixel position (For every output X/Y pixel position)
   static int pixel_4[4]={1,3,5,7};
   static int pixel_5[5]={1,2,4,5,7};
   static int pixel_6[6]={0,2,3,4,6,7};
   static int pixel_7[7]={0,1,2,4,5,6,7};
	     
   // Scaling factors (For every output pixel X/Y position
      
   static int scale0_4[4]={64,64,64,64};
   static int scale1_4[4]={32,32,32,32};
   static int scale2_4[4]={16,16,16,16};

   static int scale0_5[5]={12,89,38,115,64};
   static int scale1_5[5]={1,62,11,103,32};
   static int scale2_5[5]={0,43,3,93,16};

   static int scale0_6[6]={106,21,64,106,21,64};
   static int scale1_6[6]={88,3,32,88,3,32};
   static int scale2_6[6]={74,0,16,74,0,16};

   static int scale0_7[7]={82,100,118,9,27,45,64};
   static int scale1_7[7]={52,79,110,0,5,16,32};
   static int scale2_7[7]={34,62,102,0,1,5,16};
   
   if(pid==0) {
      int loopcnt;
      int *pixel;
      int v;
      ztaInitStream(req->spu,1);

      switch(req->scale) {
         case 4: 
            req->ws.scale0=scale0_4;
            req->ws.scale1=scale1_4;
            req->ws.scale2=scale2_4;
            pixel=pixel_4;
            break;
         case 5: 
            req->ws.scale0=scale0_5;
            req->ws.scale1=scale1_5;
            req->ws.scale2=scale2_5;
            pixel=pixel_5;
            break;
         case 6: 
            req->ws.scale0=scale0_6;
            req->ws.scale1=scale1_6;
            req->ws.scale2=scale2_6;
            pixel=pixel_6;
            break;
         case 7: 
            req->ws.scale0=scale0_7;
            req->ws.scale1=scale1_7;
            req->ws.scale2=scale2_7;
            pixel=pixel_7;
            break;
         default:
            pixel=0;
            ztamAssert("Invalid resize scale");
      }
      loopcnt=((req->scale*req->scale)+NUM_THREAD_PER_CORE-1)/NUM_THREAD_PER_CORE;
      for(req->ws.loopstep=NUM_MIN_THREAD_FOR_MAX_EFFICIENCY;
          req->ws.loopstep <= NUM_THREAD_PER_CORE;
          req->ws.loopstep++) {
         if((((req->scale*req->scale)+req->ws.loopstep-1)/req->ws.loopstep) <= loopcnt)
            break;
      }
      req->ws.scratch=0;
      req->ws.init=req->ws.scratch;
      for(y=0,i=0;y < req->scale;y++) {
         for(x=0;x < req->scale;x++) {
            v=(pixel[x])|(pixel[y]<<3);
            >(int)SCRATCH(req->ws.init)[i] <= INT(v);
            i++;
         }
      }

      req->ws.scratch+=TILE_DIM*TILE_DIM*2;
      req->ws.init2=req->ws.scratch;
      for(y=0,i=0;y < req->scale;y++) {
         for(x=0;x < req->scale;x++) {
            v=x|(y<<3);
            >(int)SCRATCH(req->ws.init2)[i] <= INT(v);
            i++;
         }
      }
      req->ws.scratch+=TILE_DIM*TILE_DIM*2;
   }
   
   dx=NUM_PCORE*TILE_DIM;
   dy1=TILE_DIM*VECTOR_WIDTH;
   dy2=req->scale*VECTOR_WIDTH;
   dxcnt=(req->w+dx-1)/dx;
   dycnt=(req->h+dy1-1)/dy1;
   h=(req->h+VECTOR_WIDTH-1)/VECTOR_WIDTH;
   dst_num_tiles=(req->dst_w+req->scale-1)/req->scale;

   for(i=0;i < req->scale;i++) {
      >PCORE(NUM_PCORE)[*].resize::fract0[i] <= SHORT(req->ws.scale0[i]);
      >PCORE(NUM_PCORE)[*].resize::fract1[i] <= SHORT(req->ws.scale1[i]);
      >PCORE(NUM_PCORE)[*].resize::fract2[i] <= SHORT(req->ws.scale2[i]);
   }

   if(pid==0) {
      from=0;
      to=(dycnt<=1)?dycnt:dycnt/2;
   } else {
      if(dycnt <= 1)
         return;
      from=dycnt/2;
      to=dycnt;
   }
   for(ch=0;ch < req->nchannel;ch++) {
      inputLen=req->src_w*req->src_h;
      inputLen2=inputLen-req->src_w*req->y_off;
      input=req->input+ch*inputLen+req->src_w*req->y_off;
      output=req->output+ch*(req->dst_w*req->dst_h);
      for(y=from;y < to;y++) {
         for(x=dxcnt-1;x >= 0;x--) {
            // Copy input tiles to PCORE array memory
            if(x==dxcnt-1) {
               remain=req->w-x*dx;
               cnt=(remain+TILE_DIM-1)/TILE_DIM;
            } else {
               cnt=NUM_PCORE;
               // Copy the right most gap from the beginning of last interation
               >(ushort)PCORE(NUM_PCORE)[NUM_PCORE-1].resize::inbuf(TILE_DIM+TILE_PAD,TILE_DIM+TILE_PAD,VECTOR_WIDTH)[0:TILE_DIM+TILE_PAD-1][TILE_DIM:TILE_DIM+TILE_PAD-1][:] <=
               >(ushort)PCORE(NUM_PCORE)[0].resize::inbuf(TILE_DIM+TILE_PAD,TILE_DIM+TILE_PAD,VECTOR_WIDTH)[0:TILE_DIM+TILE_PAD-1][0:TILE_PAD-1][:];
            }
            // Copy tiles from memory to PCORE
            left=(req->h-y*dy1);
            // Calculate how many threads required for these tiles...
            remain=(left+TILE_DIM-1)/TILE_DIM; // How many vector elements used
            if(remain > VECTOR_WIDTH)
               remain=VECTOR_WIDTH;
            >SCATTER(req->ws.scratch) FOR(K=0:remain-1) FOR(I=0:TILE_DIM+TILE_PAD-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DIM-1) PCORE(NUM_PCORE)[II].resize::inbuf(TILE_DIM+TILE_PAD,TILE_DIM+TILE_PAD,VECTOR_WIDTH)[I][J][K] <= 
            >(ushort)MEM(input,inputLen2(h,VECTOR_WIDTH+,req->src_w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+remain-1][0:TILE_DIM+TILE_PAD-1][x*dx+req->x_off:x*dx+dx+req->x_off-1];
            >FLUSH;
            if(x==dxcnt-1) {
               int ii;
               ii=(req->w-x*dx-(cnt-1)*TILE_DIM);
               // This is the right most gap of the image. Set it to zero...
               if(ii <= (TILE_DIM+TILE_PAD-1)) {
                  >(ushort)PCORE(NUM_PCORE)[cnt-1].resize::inbuf(TILE_DIM+TILE_PAD,TILE_DIM+TILE_PAD,VECTOR_WIDTH)[0:TILE_DIM+TILE_PAD-1][ii:TILE_DIM+TILE_PAD-1][:] <= SHORT(PAD_VALUE);
               }
            }

            // Copy the gap from adjacent tile.
            if(cnt >= 2) {
               >(ushort)PCORE(NUM_PCORE)[0:cnt-2].resize::inbuf(TILE_DIM+TILE_PAD,TILE_DIM+TILE_PAD,VECTOR_WIDTH)[0:TILE_DIM+TILE_PAD-1][TILE_DIM:TILE_DIM+TILE_PAD-1][:] <=
               >(ushort)PCORE(NUM_PCORE)[1:cnt-1].resize::inbuf(TILE_DIM+TILE_PAD,TILE_DIM+TILE_PAD,VECTOR_WIDTH)[0:TILE_DIM+TILE_PAD-1][0:TILE_PAD-1][:];
            }
            for(i=0;i < req->scale*req->scale;i+=req->ws.loopstep) {
               nt=req->scale*req->scale-i;
               if(nt > req->ws.loopstep)
                  nt=req->ws.loopstep;
               > (int)PCORE(NUM_PCORE)[*][0:nt-1].resize::init._pixel <= (int)SCRATCH(req->ws.init)[i:i+nt-1];
               > (int)PCORE(NUM_PCORE)[*][0:nt-1].resize::init._pixel2 <= (int)SCRATCH(req->ws.init2)[i:i+nt-1];
               > EXE_LOCKSTEP(resize::init,NUM_PCORE,nt);
               > EXE_LOCKSTEP(resize::exe,NUM_PCORE,nt);
               ztamTaskYield();
            }

            // Copy result tiles back to memory
            >(ushort)MEM(output,req->dst_h,req->dst_w(dst_num_tiles,req->scale))[y*dy2:y*dy2+req->scale*VECTOR_WIDTH-1][x*NUM_PCORE:x*NUM_PCORE+NUM_PCORE-1][0:TILE_DIM-1] <= PROC(0) <=
            >SCATTER(req->ws.scratch) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:req->scale-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DIM-1) (ushort) PCORE(NUM_PCORE)[II].resize::outbuf(TILE_DIM,TILE_DIM,VECTOR_WIDTH)[I][J][K];
         }
      }
   }

   // Fill in the rest of output tensors with zero.
   dst_w=(((req->w+7)/8)*req->scale);
   dst_h=(((req->h+7)/8)*req->scale);

   for(ch=0;ch < req->nchannel;ch++) {
      output=req->output+ch*(req->dst_w*req->dst_h);
      if(dst_w <= (req->dst_w-1)) {
         >(ushort)MEM(output,req->dst_h,req->dst_w)[0:dst_h-1][dst_w:req->dst_w-1] <= SHORT(PAD_VALUE);
      }
      if(dst_h <= (req->dst_h-1)) {
         >(ushort)MEM(output,req->dst_h,req->dst_w)[dst_h:req->dst_h-1][0:req->dst_w-1] <= SHORT(PAD_VALUE);
      }
   }
}

// Process cubic intepolation image resize request from host

#if 0
void do_resize(int queue) {
   Request req;
   req.input=ztamMsgqReadPointer(queue);
   req.output=ztamMsgqReadPointer(queue);
   req.nchannel=ztamMsgqReadInt(queue);
   req.spu=ztamMsgqReadPointer(queue);
   req.scale=ztamMsgqReadInt(queue);
   req.w=ztamMsgqReadInt(queue);
   req.h=ztamMsgqReadInt(queue);
   req.src_w=ztamMsgqReadInt(queue);
   req.src_h=ztamMsgqReadInt(queue);
   req.x_off=ztamMsgqReadInt(queue);
   req.y_off=ztamMsgqReadInt(queue);
   req.dst_w=ztamMsgqReadInt(queue);
   req.dst_h=ztamMsgqReadInt(queue);
   ztamTaskSpawn(resize,&req,1);
   resize(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
}
#endif

typedef struct 
{
   uint32_t input;
   uint32_t output;
   uint32_t temp;
   uint32_t filter[2];
   uint32_t filteri[2];
   int filterLen[2];
   uint32_t spu;
   int nchannel;
   int src_w;
   int src_h;
   int dst_w;
   int dst_h;
   int scale_x;
   int scale_y;
} RequestBoxResize;

// Box resizing horizontally

void box_resize_horizontal(void *_p,int pid) {
   RequestBoxResize *req=(RequestBoxResize *)_p;
   int ch;
   int np;
   int from,to;
   int src_x,src_y,dst_x,dst_y;
   int src_dx,src_dy,dst_dx,dst_dy;
   int fmt=DP_DATA_TYPE_UINT8;
   int src_dx2;
   int src_w,src_h,dst_w,dst_h;
   uint32_t dst_start;
   uint32_t kfunc[BOX_RESIZE_MAX_FILTER]={0,0,$resize_box::exe3,$resize_box::exe4,$resize_box::exe5,
                                          $resize_box::exe6,$resize_box::exe7,$resize_box::exe8};
   np=NUM_PCORE;

   // Resize width wise first

   src_dx=req->scale_x;
   src_dx2=ROUND(src_dx,VECTOR_WIDTH);
   src_dy=VECTOR_WIDTH*NUM_PCORE;
   dst_dx=NUM_THREAD_PER_CORE;
   dst_dy=VECTOR_WIDTH*NUM_PCORE;
   src_w=req->src_w;
   src_h=req->src_h;
   dst_w=req->dst_w;
   dst_h=req->src_h;

   if(pid==0) {
      ztaInitStream(req->spu,2);
   }

   // Split the work between 2 processes...

   if(pid==0) {
      from=0;
      to=(src_h/2);
      to=ROUND(to,src_dy);
      dst_start=0;
   } else {
      from=(src_h/2);
      from=ROUND(from,src_dy);
      to=src_h;
      dst_start=(from/src_dy)*dst_dy;
   }

   >(int)PCORE(np)[*].THREAD[:].resize_box::filter <= (int)MEM(req->filter[0])[0:BOX_RESIZE_MAX_FILTER*NUM_THREAD_PER_CORE-1];
   >(ushort)PCORE(np)[*].THREAD[:].resize_box::init.filteri <= (ushort)MEM(req->filteri[0])[0:NUM_THREAD_PER_CORE-1];

   >EXE_LOCKSTEP(resize_box::init,np);

   ztamTaskYield();

   // Resize horizontally first

   for(ch=0;ch < req->nchannel;ch++) {
      // Scan for each channel...
      for(src_y=from,dst_y=dst_start;src_y < to;src_y+=src_dy,dst_y+=dst_dy) {
         for(src_x=0,dst_x=0;src_x < src_w;src_x+=src_dx,dst_x+=dst_dx) {
            
            // Copy input image to pcore memory space...

            > (fmt) SCATTER(0) FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::inbuf(BOX_RESIZE_MAX_INBUF/8,8,VECTOR_WIDTH)[0:src_dx2/8-1][:][J] <= (fmt)MEM(req->input,req->nchannel,src_h,src_w)[ch][src_y:src_y+src_dy-1][src_x:src_x+src_dx2-1];

            > EXE_LOCKSTEP(kfunc[req->filterLen[0]-1],np);

            ztamTaskYield();

            // Copy results back to DDR

            > (fmt) MEM(req->temp,req->nchannel,dst_h,dst_w)[ch][dst_y:dst_y+dst_dy-1][dst_x:dst_x+dst_dx-1] <= PROC(0) <= (fmt) SCATTER(0) FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::outbuf(BOX_RESIZE_MAX_OUTBUF/8,8,VECTOR_WIDTH)[0:dst_dx/8-1][:][J];         
         }
      }
   }
}

// Box resizing vertically...

void box_resize_vertical(void *_p,int pid) {
   RequestBoxResize *req=(RequestBoxResize *)_p;
   int ch;
   int np;
   int from,to;
   int src_x,src_y,dst_x,dst_y;
   int src_dx,src_dy,dst_dx,dst_dy;
   int fmt=DP_DATA_TYPE_UINT8;
   int src_dy2,dst_dy2;
   int src_w,src_h,dst_w,dst_h;
   uint32_t dst_start;
   uint32_t kfunc[BOX_RESIZE_MAX_FILTER]={0,0,$resize_box::exe3,$resize_box::exe4,$resize_box::exe5,
                                          $resize_box::exe6,$resize_box::exe7,$resize_box::exe8};
   np=NUM_PCORE;

   // Resize vertically

   src_dy=req->scale_y;
   src_dy2=ROUND(src_dy,VECTOR_WIDTH);
   src_dx=VECTOR_WIDTH*NUM_PCORE;
   dst_dy=NUM_THREAD_PER_CORE;
   dst_dy2=ROUND(dst_dy,VECTOR_WIDTH);
   dst_dx=VECTOR_WIDTH*NUM_PCORE;
   src_w=req->dst_w;
   src_h=req->src_h;
   dst_w=src_w;
   dst_h=req->dst_h;

   // Split the work between 2 processes

   if(pid==0) {
      from=0;
      to=(src_w/2);
      to=ROUND(to,src_dx);
      dst_start=0;
   } else {
      from=(src_w/2);
      from=ROUND(from,src_dx);
      to=src_w;
      dst_start=(from/src_dx)*dst_dx;
   }
   
   >(int)PCORE(np)[*].THREAD[:].resize_box::filter <= (int)MEM(req->filter[1])[0:BOX_RESIZE_MAX_FILTER*NUM_THREAD_PER_CORE-1];
   >(ushort)PCORE(np)[*].THREAD[:].resize_box::init.filteri <= (ushort)MEM(req->filteri[1])[0:NUM_THREAD_PER_CORE-1];

   >EXE_LOCKSTEP(resize_box::init,np);

   ztamTaskYield();

   // Resize horizontally first
   for(ch=0;ch < req->nchannel;ch++) {
      // Scan for each channel...
      for(src_x=from,dst_x=dst_start;src_x < to;src_x+=src_dx,dst_x+=dst_dx) {
       
         for(src_y=0,dst_y=0;src_y < src_h;src_y+=src_dy,dst_y+=dst_dy) {
            
            // Copy input image to pcore memory space...

            > (fmt) FOR(K=0:src_dy2-1) FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::inbuf[K][J] <= (fmt) MEM(req->temp,req->nchannel,src_h,src_w)[ch][src_y:src_y+src_dy2-1][src_x:src_x+src_dx-1];
            
            > EXE_LOCKSTEP(kfunc[req->filterLen[1]-1],np);

            ztamTaskYield();

            // Copy results back to DDR

            > (fmt)MEM(req->output,req->nchannel,dst_h,dst_w)[ch][dst_y:dst_y+dst_dy2-1][dst_x:dst_x+dst_dx-1] <= PROC(1) <= (fmt) FOR(K=0:dst_dy2-1) FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::outbuf[K][J];
         }
      }
   }
}

// Process image box resize request from host

void kernel_resize_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _temp,
   unsigned int _filter_0,
   unsigned int _filter_1,
   unsigned int _filteri_0,
   unsigned int _filteri_1,
   int _filterLen_0,
   int _filterLen_1,
   unsigned int _spu,
   int _nchannel,
   int _src_w,
   int _src_h,
   int _dst_w,
   int _dst_h,
   int _scale_x,
   int _scale_y
) 
{
   RequestBoxResize req;
   
   ztaInitPcore(IMG_C,sizeof(IMG_C),IMG_P,sizeof(IMG_P));
   
   req.input=_input;
   req.output=_output;
   req.temp=_temp;
   req.filter[0]=_filter_0;
   req.filter[1]=_filter_1;
   req.filteri[0]=_filteri_0;
   req.filteri[1]=_filteri_1;
   req.filterLen[0]=_filterLen_0;
   req.filterLen[1]=_filterLen_1;
   req.spu=_spu;
   req.nchannel=_nchannel;
   req.src_w=_src_w;
   req.src_h=_src_h;
   req.dst_w=_dst_w;
   req.dst_h=_dst_h;
   req.scale_x=_scale_x;
   req.scale_y=_scale_y;

   // Resize horizontally 

   ztamTaskSpawn(box_resize_horizontal,&req,1);
   box_resize_horizontal(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
      
   // Then resize vertically

   ztamTaskSpawn(box_resize_vertical,&req,1);
   box_resize_vertical(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();     
  >CALLBACK(0,_req_id);
}
