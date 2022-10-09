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
#include "../../../base/ztalib.h"
#include "harris.h"
#include "harris.p.img"

// Perform harris-corner algorithm
// Refer to https://en.wikipedia.org/wiki/Harris_Corner_Detector


typedef struct {
   uint32_t input;
   uint32_t x_gradient;
   uint32_t y_gradient;
   uint32_t score;
   uint32_t output;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   int dst_w;
   int dst_h;
} Request;

// Find gradient in X and Y direction

static void harris_phase_0(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h,pad;
   int inputLen;
   uint32_t input,x_gradient,y_gradient;
   int x,y,cnt;
   int x_off,y_off;
   int ksz=3;

   x_off=req->x_off;
   y_off=req->y_off;
   pad=(ksz/2);
   dx2=NUM_PCORE*TILE_DX_DIM;
   dx=NUM_PCORE*TILE_DX_DIM-pad;
   dy=TILE_DY_DIM*VECTOR_WIDTH;
   dxcnt=(req->w+dx-1)/dx;
   dycnt=(req->h+dy-1)/dy;
   h=(req->h+TILE_DY_DIM-1)/TILE_DY_DIM;

   if(pid==0) {
      from=0;
      to=(dycnt<=1)?dycnt:dycnt/2;
   } else {
      if(dycnt <= 1)
         return;
      from=dycnt/2;
      to=dycnt;
   }

   // Load the convolution kernel...
   > EXE_LOCKSTEP(harris::init,NUM_PCORE);
   ztaTaskYield();

   inputLen=req->src_w*req->src_h;
   input=req->input;
   inputLen-=y_off*req->src_w;
   input+=y_off*req->src_w;
   input-=req->src_w*pad;
   inputLen+=req->src_w*pad;
   x_gradient=req->x_gradient;
   y_gradient=req->y_gradient;

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;

         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >DTYPE(UINT8)PCORE(NUM_PCORE)[0].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >DTYPE(UINT8)PCORE(NUM_PCORE)[cnt-1].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >DTYPE(INT8)PCORE(NUM_PCORE)[0].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT8(0);
         }

         // Copy input to PCORE array...
         >CONCURRENT DTYPE(UINT8) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >DTYPE(UINT8)MEM(input,inputLen(h,TILE_DY_DIM+,req->src_w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx+x_off:x*dx+dx2+x_off-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
         >DTYPE(UINT8)PCORE(NUM_PCORE)[0:cnt-2].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >DTYPE(UINT8)LATEST PCORE(NUM_PCORE)[1:cnt-1].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >DTYPE(UINT8)PCORE(NUM_PCORE)[1:cnt-1].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >DTYPE(UINT8)PCORE(NUM_PCORE)[0:cnt-2].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         if(y==0) {
            >DTYPE(INT8)PCORE(NUM_PCORE)[*].harris::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT8(0);
         }

         > EXE_LOCKSTEP(harris::calc_gradient,NUM_PCORE);

         ztaTaskYield();

         // Copy result tiles back to memory
         >DTYPE(INT16)MEM(x_gradient,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >CONCURRENT FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) DTYPE(INT16)PCORE(NUM_PCORE)[II].harris::x_gradient(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];

         >DTYPE(INT16)MEM(y_gradient,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >CONCURRENT FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) DTYPE(INT16)PCORE(NUM_PCORE)[II].harris::y_gradient(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
	  }
   }
}

// Calculate HARRIS score

static void harris_phase_1(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h2,pad;
   int x_gradientLen;
   uint32_t x_gradient;
   int y_gradientLen;
   uint32_t y_gradient;
   int x,y,cnt;
   int w,h;
   int ksz=3;

   pad=(ksz/2);
   w=req->w;
   h=req->h;
   dx2=NUM_PCORE*TILE_DX_DIM;
   dx=NUM_PCORE*TILE_DX_DIM-pad;
   dy=TILE_DY_DIM*VECTOR_WIDTH;
   dxcnt=(w+dx-1)/dx;
   dycnt=(h+dy-1)/dy;
   h2=(h+TILE_DY_DIM-1)/TILE_DY_DIM;
   if(pid==0) {
      from=0;
      to=(dycnt<=1)?dycnt:dycnt/2;
   } else {
      if(dycnt <= 1)
         return;
      from=dycnt/2;
      to=dycnt;
   }

   // Load the convolution kernel...
   > EXE_LOCKSTEP(harris1::init,NUM_PCORE);
   ztaTaskYield();

   x_gradientLen=w*h*sizeof(int16_t);
   x_gradient=req->x_gradient;
   x_gradient-=w*pad*sizeof(int16_t);
   x_gradientLen+=w*pad*sizeof(int16_t);

   y_gradientLen=w*h*sizeof(int16_t);
   y_gradient=req->y_gradient;
   y_gradient-=w*pad*sizeof(int16_t);
   y_gradientLen+=w*pad*sizeof(int16_t);

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;

         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >DTYPE(INT16)PCORE(NUM_PCORE)[0].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >DTYPE(INT16)PCORE(NUM_PCORE)[cnt-1].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
            >DTYPE(INT16)PCORE(NUM_PCORE)[0].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >DTYPE(INT16)PCORE(NUM_PCORE)[cnt-1].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >DTYPE(INT16)PCORE(NUM_PCORE)[0].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT16(0);
            >DTYPE(INT16)PCORE(NUM_PCORE)[0].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT16(0);
         }

         // Copy input to PCORE array...
         >CONCURRENT FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) DTYPE(INT16) PCORE(NUM_PCORE)[II].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >DTYPE(INT16)MEM(x_gradient,x_gradientLen(h2,TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         >CONCURRENT FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) DTYPE(INT16) PCORE(NUM_PCORE)[II].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >DTYPE(INT16)MEM(y_gradient,y_gradientLen(h2,TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
         >DTYPE(INT16)PCORE(NUM_PCORE)[0:cnt-2].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >DTYPE(INT16)LATEST PCORE(NUM_PCORE)[1:cnt-1].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >DTYPE(INT16)PCORE(NUM_PCORE)[1:cnt-1].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >DTYPE(INT16)PCORE(NUM_PCORE)[0:cnt-2].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         // Copy left margin from right tiles to the immediate left tiles...
         >DTYPE(INT16)PCORE(NUM_PCORE)[0:cnt-2].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >DTYPE(INT16)PCORE(NUM_PCORE)[1:cnt-1].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >DTYPE(INT16)PCORE(NUM_PCORE)[1:cnt-1].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >DTYPE(INT16)PCORE(NUM_PCORE)[0:cnt-2].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         if(y==0) {
            >DTYPE(INT16)PCORE(NUM_PCORE)[*].harris1::x_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT16(0);
            >DTYPE(INT16)PCORE(NUM_PCORE)[*].harris1::y_gradient(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT16(0);
         }

         > EXE_LOCKSTEP(harris1::calc,NUM_PCORE);

         ztaTaskYield();

         // Copy result tiles back to memory
         >DTYPE(INT16)MEM(req->score,h,w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >CONCURRENT FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) DTYPE(INT16)PCORE(NUM_PCORE)[II].harris1::score(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
      }
   }
}

// Local non-max suppression

static void harris_phase_2(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h2,pad;
   int scoreLen;
   uint32_t score;
   int x,y,cnt;
   int w,h;
   int ksz=3;

   pad=(ksz/2);
   w=req->w;
   h=req->h;
   dx2=NUM_PCORE*TILE_DX_DIM;
   dx=NUM_PCORE*TILE_DX_DIM-pad;
   dy=TILE_DY_DIM*VECTOR_WIDTH;
   dxcnt=(w+dx-1)/dx;
   dycnt=(h+dy-1)/dy;
   h2=(h+TILE_DY_DIM-1)/TILE_DY_DIM;
   if(pid==0) {
      from=0;
      to=(dycnt<=1)?dycnt:dycnt/2;
   } else {
      if(dycnt <= 1)
         return;
      from=dycnt/2;
      to=dycnt;
   }

   // Load the convolution kernel...
   > EXE_LOCKSTEP(harris2::init,NUM_PCORE);
   ztaTaskYield();

   scoreLen=w*h*sizeof(int16_t);
   score=req->score;
   score-=w*pad*sizeof(int16_t);
   scoreLen+=w*pad*sizeof(int16_t);

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;

         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >DTYPE(INT16)PCORE(NUM_PCORE)[0].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >DTYPE(INT16)PCORE(NUM_PCORE)[cnt-1].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >DTYPE(INT16)PCORE(NUM_PCORE)[0].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT16(0);
         }

         // Copy input to PCORE array...
         >CONCURRENT FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) DTYPE(INT16) PCORE(NUM_PCORE)[II].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >DTYPE(INT16)MEM(score,scoreLen(h2,TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
         >DTYPE(INT16)PCORE(NUM_PCORE)[0:cnt-2].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >DTYPE(INT16)LATEST PCORE(NUM_PCORE)[1:cnt-1].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >DTYPE(INT16)PCORE(NUM_PCORE)[1:cnt-1].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >DTYPE(INT16)PCORE(NUM_PCORE)[0:cnt-2].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         if(y==0) {
            >DTYPE(INT16)PCORE(NUM_PCORE)[*].harris2::score(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT16(0);
         }

         > EXE_LOCKSTEP(harris2::calc,NUM_PCORE);

         ztaTaskYield();

         // Copy result tiles back to memory
         >DTYPE(INT16)MEM(req->output,h,w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >CONCURRENT FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) DTYPE(INT16)PCORE(NUM_PCORE)[II].harris2::output(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
      }
   }
}

// Process request from host to do harris-corner feature extraction
void kernel_harris_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _x_gradient,
   unsigned int _y_gradient,
   unsigned int _score,
   unsigned int _output,
   int _w,
   int _h,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_w,
   int _dst_h)
{
   Request req;

   ztaInitPcore(zta_pcore_img);
   
   req.input=_input;
   req.x_gradient=_x_gradient;
   req.y_gradient=_y_gradient;
   req.score=_score;
   req.output=_output;
   req.w=_w;
   req.h=_h;
   req.src_w=_src_w;
   req.src_h=_src_h;
   req.x_off=_x_off;
   req.y_off=_y_off;
   req.dst_w=_dst_w;
   req.dst_h=_dst_h;
   
   ztaDualHartExecute(harris_phase_0,&req);
      
   ztaDualHartExecute(harris_phase_1,&req);
      
   ztaDualHartExecute(harris_phase_2,&req);
      
   ztaJobDone(_req_id);
}

