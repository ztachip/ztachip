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
#include "../../../base/util.h"
#include "../../../base/ztalib.h"
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
   int fmt=UINT8;
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

   >DTYPE(INT16)PCORE(np)[*].THREAD[:].resize_box::filter <= DTYPE(INT16)MEM(req->filter[0])[0:BOX_RESIZE_MAX_FILTER*NUM_THREAD_PER_CORE-1];
   >DTYPE(UINT8)PCORE(np)[*].THREAD[:].resize_box::init.filteri <= DTYPE(UINT8)MEM(req->filteri[0])[0:NUM_THREAD_PER_CORE-1];

   >EXE_LOCKSTEP(resize_box::init,np);

   ztaTaskYield();

   // Resize horizontally first

   for(ch=0;ch < req->nchannel;ch++) {
      // Scan for each channel...
      for(src_y=from,dst_y=dst_start;src_y < to;src_y+=src_dy,dst_y+=dst_dy) {
         for(src_x=0,dst_x=0;src_x < src_w;src_x+=src_dx,dst_x+=dst_dx) {
            
            // Copy input image to pcore memory space...

            > DTYPE(fmt) CONCURRENT FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::inbuf(BOX_RESIZE_MAX_INBUF/8,8,VECTOR_WIDTH)[0:src_dx2/8-1][:][J] <= DTYPE(fmt)MEM(req->input,req->nchannel,src_h,src_w)[ch][src_y:src_y+src_dy-1][src_x:src_x+src_dx2-1];

            > EXE_LOCKSTEP(kfunc[req->filterLen[0]-1],np);

            ztaTaskYield();

            // Copy results back to DDR

            > DTYPE(fmt) MEM(req->temp,req->nchannel,dst_h,dst_w)[ch][dst_y:dst_y+dst_dy-1][dst_x:dst_x+dst_dx-1] <= REMAP(0) DTYPE(fmt) CONCURRENT FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::outbuf(BOX_RESIZE_MAX_OUTBUF/8,8,VECTOR_WIDTH)[0:dst_dx/8-1][:][J];         
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
   int fmt=UINT8;
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
   
   >DTYPE(INT16)PCORE(np)[*].THREAD[:].resize_box::filter <= DTYPE(INT16)MEM(req->filter[1])[0:BOX_RESIZE_MAX_FILTER*NUM_THREAD_PER_CORE-1];
   >DTYPE(UINT8)PCORE(np)[*].THREAD[:].resize_box::init.filteri <= DTYPE(UINT8)MEM(req->filteri[1])[0:NUM_THREAD_PER_CORE-1];

   >EXE_LOCKSTEP(resize_box::init,np);

   ztaTaskYield();

   // Resize horizontally first
   for(ch=0;ch < req->nchannel;ch++) {
      // Scan for each channel...
      for(src_x=from,dst_x=dst_start;src_x < to;src_x+=src_dx,dst_x+=dst_dx) {
       
         for(src_y=0,dst_y=0;src_y < src_h;src_y+=src_dy,dst_y+=dst_dy) {
            
            // Copy input image to pcore memory space...

            > DTYPE(fmt) FOR(K=0:src_dy2-1) FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::inbuf[K][J] <= DTYPE(fmt) MEM(req->temp,req->nchannel,src_h,src_w)[ch][src_y:src_y+src_dy2-1][src_x:src_x+src_dx-1];
            
            > EXE_LOCKSTEP(kfunc[req->filterLen[1]-1],np);

            ztaTaskYield();

            // Copy results back to DDR

            > DTYPE(fmt)MEM(req->output,req->nchannel,dst_h,dst_w)[ch][dst_y:dst_y+dst_dy2-1][dst_x:dst_x+dst_dx-1] <= REMAP(1) DTYPE(fmt) FOR(K=0:dst_dy2-1) FOR(I=0:np-1) FOR(J=0:VECTOR_WIDTH-1) PCORE(np)[I].resize_box::outbuf[K][J];
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
   
   ztaInitPcore(zta_pcore_img);
   ztaInitStream(_spu);
        
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

   ztaDualHartExecute(box_resize_horizontal,&req);
      
   // Then resize vertically

   ztaDualHartExecute(box_resize_vertical,&req);
           
   ztaJobDone(_req_id);
}
