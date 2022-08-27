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

#include "../../../base/ztam.h"
#include "../../main/kernels/main.h"
#include "canny.h"
#include "canny.p.img"


// Perform canny edge detection algorithm
// Refer to https://en.wikipedia.org/wiki/Canny_edge_detector

extern void mycallback(int);

typedef struct {
   uint32_t input;
   uint32_t magnitude;
   uint32_t phase;
   uint32_t maxima;
   uint32_t output;
   int threshold_lo;
   int threshold_hi;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   int dst_w;
   int dst_h;
} Request;

// Find gradient magnitude and phase for every pixel

static void canny_phase_0(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h,pad;
   int inputLen;
   uint32_t input,magnitude,phase;
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
   > EXE_LOCKSTEP(canny::init,NUM_PCORE);
   ztamTaskYield();
   inputLen=req->src_w*req->src_h;
   input=req->input;
   inputLen-=y_off*req->src_w;
   input+=y_off*req->src_w;
   input-=req->src_w*pad;
   inputLen+=req->src_w*pad;
   magnitude=req->magnitude;
   phase=req->phase;

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;
         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >(ushort)PCORE(NUM_PCORE)[0].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(ushort)PCORE(NUM_PCORE)[cnt-1].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >(ushort)PCORE(NUM_PCORE)[0].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= SHORT(0);
         }
         
         >FLUSH;
         
         // Copy input to PCORE array...
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(ushort)MEM(input,inputLen(h,TILE_DY_DIM+,req->src_w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx+x_off:x*dx+dx2+x_off-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
         >(ushort)PCORE(NUM_PCORE)[0:cnt-2].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >(ushort)SYNC PCORE(NUM_PCORE)[1:cnt-1].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >(ushort)PCORE(NUM_PCORE)[1:cnt-1].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(ushort) SYNC PCORE(NUM_PCORE)[0:cnt-2].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         >FLUSH;
         
         if(y==0) {
            >PCORE(NUM_PCORE)[*].canny::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= SHORT(0);
         }

         > EXE_LOCKSTEP(canny::calc_gradient,NUM_PCORE);

         ztamTaskYield();

         // Copy result tiles back to memory
         >(int)MEM(magnitude,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (int)PCORE(NUM_PCORE)[II].canny::magnitude(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];

         >(ushort)MEM(phase,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (ushort) PCORE(NUM_PCORE)[II].canny::phase(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
	   }
   }
}

// Perform local maxima suppression

static void canny_phase_1(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h2,pad;
   int magnitudeLen;
   uint32_t magnitude;
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
   > EXE_LOCKSTEP(canny1::init,NUM_PCORE);
   ztamTaskYield();

   magnitudeLen=w*h*sizeof(int16_t);
   magnitude=req->magnitude;
   magnitude-=w*pad*sizeof(int16_t);
   magnitudeLen+=w*pad*sizeof(int16_t);

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;

         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >(int)PCORE(NUM_PCORE)[0].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(int)PCORE(NUM_PCORE)[cnt-1].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >(int)PCORE(NUM_PCORE)[0].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT(0);
         }
         >FLUSH;
         // Copy input to PCORE array...
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) (int) PCORE(NUM_PCORE)[II].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(int)MEM(magnitude,magnitudeLen(h2,TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (short)PCORE(NUM_PCORE)[II].canny1::phase(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K] <= 
         >(short)MEM(req->phase,h2,TILE_DY_DIM,w)[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM-1][x*dx:x*dx+dx2-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
         >(int)PCORE(NUM_PCORE)[0:cnt-2].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >(int)SYNC PCORE(NUM_PCORE)[1:cnt-1].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >(int)PCORE(NUM_PCORE)[1:cnt-1].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(int)SYNC PCORE(NUM_PCORE)[0:cnt-2].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         >FLUSH;
         
         if(y==0) {
            >(int)PCORE(NUM_PCORE)[*].canny1::magnitude(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT(0);
         }

         > EXE_LOCKSTEP(canny1::calc_maxima,NUM_PCORE);

         ztamTaskYield();

         // Copy result tiles back to memory
         >(int)MEM(req->maxima,h,w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (int)PCORE(NUM_PCORE)[II].canny1::maxima(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
      }
   }
}

// Perform edge detection threshold hysterisis

static void canny_phase_2(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h2,pad;
   int maximaLen;
   uint32_t maxima;
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

   >(int)PCORE(NUM_PCORE)[*].canny2::threshold_lo <= INT(req->threshold_lo); 
   >(int)PCORE(NUM_PCORE)[*].canny2::threshold_hi <= INT(req->threshold_hi); 

   // Load the convolution kernel...
   > EXE_LOCKSTEP(canny2::init,NUM_PCORE);
   ztamTaskYield();

   maximaLen=w*h*sizeof(int16_t);
   maxima=req->maxima;
   maxima-=w*pad*sizeof(int16_t);
   maximaLen+=w*pad*sizeof(int16_t);

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;

         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >(int)PCORE(NUM_PCORE)[0].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(int)PCORE(NUM_PCORE)[cnt-1].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >(int)PCORE(NUM_PCORE)[0].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT(0);
         }
         >FLUSH;
         // Copy input to PCORE array...
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) (int) PCORE(NUM_PCORE)[II].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(int)MEM(maxima,maximaLen(h2,TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
         >(int)PCORE(NUM_PCORE)[0:cnt-2].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >(int)SYNC PCORE(NUM_PCORE)[1:cnt-1].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >(int)PCORE(NUM_PCORE)[1:cnt-1].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(int)SYNC PCORE(NUM_PCORE)[0:cnt-2].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         >FLUSH;
         
         if(y==0) {
            >(int)PCORE(NUM_PCORE)[*].canny2::maxima(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT(0);
         }

         > EXE_LOCKSTEP(canny2::threshold_hysteris,NUM_PCORE);

         ztamTaskYield();

         // Copy result tiles back to memory
         >(ushort)MEM(req->output,h,w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (ushort)PCORE(NUM_PCORE)[II].canny2::output(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
      }
   }
}

void kernel_canny_exe(
   unsigned int req_id,
   unsigned int _input,
   unsigned int _magnitude,
   unsigned int _phase,
   unsigned int _maxima,
   unsigned int _output,
   int _threshold_lo,
   int _threshold_hi,
   int _w,
   int _h,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_w,
   int _dst_h

) {
   Request req;

   KERNEL_INIT;
   req.input=_input;
   req.magnitude=_magnitude;
   req.phase=_phase;
   req.maxima=_maxima;
   req.output=_output;
   req.threshold_lo=_threshold_lo;
   req.threshold_hi=_threshold_hi;
   req.w=_w;
   req.h=_h;
   req.src_w=_src_w;
   req.src_h=_src_h;
   req.x_off=_x_off;
   req.y_off=_y_off;
   req.dst_w=_dst_w;
   req.dst_h=_dst_h;

   ztamTaskSpawn(canny_phase_0,&req,1);
   canny_phase_0(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   ztamTaskSpawn(canny_phase_1,&req,1);
   canny_phase_1(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   ztamTaskSpawn(canny_phase_2,&req,1);
   canny_phase_2(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   >CALLBACK(0,req_id);
}
