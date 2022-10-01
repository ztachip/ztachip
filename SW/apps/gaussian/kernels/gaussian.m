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

#include "../../../base/ztalib.h"
#include "gaussian.h"
#include "gaussian.p.img"
#include "gaussian.h"

// Kernel to perform gaussian blurring 
// Refer to https://en.wikipedia.org/wiki/Gaussian_blur

extern void mycallback(int);

typedef struct {
   uint32_t input;
   uint32_t output;
   uint32_t kernel;
   int nchannel;
   int ksz;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   int dst_w;
   int dst_h;
} Request;

static void iconv(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h,pad;
   int ch,inputLen;
   uint32_t input,output;
   int x,y,cnt;
   int x_off,y_off;

   x_off=req->x_off;
   y_off=req->y_off;
   pad=(req->ksz/2);
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
   >CAST(int)PCORE(NUM_PCORE)[*][:].iconv::init._ksz <= INT(req->ksz);

   > EXE_LOCKSTEP(iconv::init,NUM_PCORE);
   ztaTaskYield();

   >CAST(int)PCORE(NUM_PCORE)[*].iconv::k[0:req->ksz-1][0:req->ksz-1] <= CAST(int)MEM(req->kernel)[0:req->ksz*req->ksz-1];

   for(ch=0;ch < req->nchannel;ch++) {
      inputLen=req->src_w*req->src_h;
      input=req->input+inputLen*ch;
      inputLen-=y_off*req->src_w;
      input+=y_off*req->src_w;
      input-=req->src_w*pad;
      inputLen+=req->src_w*pad;
      output=req->output+ch*(req->dst_w*req->dst_h);
      for(y=from;y < to;y++) {
         for(x=0;x < dxcnt;x++) {
            cnt=NUM_PCORE;
            // Copy the left-pad from left most tiles edges from memory.
            if(x>0) {
               >CAST(ushort)PCORE(NUM_PCORE)[0].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
               >CAST(ushort)PCORE(NUM_PCORE)[cnt-1].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
            } else {
               // There is nothing at the left. So set it to zero...
               >CAST(ushort)PCORE(NUM_PCORE)[0].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= SHORT(0);
            }

            // Copy input to PCORE array...
            >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
            >CAST(ushort)MEM(input,inputLen(h,TILE_DY_DIM+,req->src_w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx+x_off:x*dx+dx2+x_off-1];

            // Copy the gap from adjacent tile.

            // Copy left margin from right tiles to the immediate left tiles...
            >CAST(ushort)PCORE(NUM_PCORE)[0:cnt-2].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
            >CAST(ushort) SYNC PCORE(NUM_PCORE)[1:cnt-1].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

            // Copy right margin from left tiles to the immediate right tiles...
            >CAST(ushort)PCORE(NUM_PCORE)[1:cnt-1].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
            >CAST(ushort)PCORE(NUM_PCORE)[0:cnt-2].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

            if(y==0) {
               >PCORE(NUM_PCORE)[*].iconv::inbuf(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= SHORT(0);
            }
            > EXE_LOCKSTEP(iconv::exe_7x7,NUM_PCORE);

            ztaTaskYield();

            // Copy result tiles back to memory
            >CAST(ushort)MEM(output,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
            >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) CAST(ushort) PCORE(NUM_PCORE)[II].iconv::outbuf(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
         }
      }
   }
}

// Process request from host to do gaussian filtering

void kernel_gaussian_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _kernel,
   int _nchannel,
   int _ksz,
   int _w,
   int _h,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_w,
   int _dst_h
)
{
   Request req;
   
   ztaInitPcore(zta_pcore_img);
   
   req.input=_input;
   req.output=_output;
   req.kernel=_kernel;
   req.nchannel=_nchannel;
   req.ksz=_ksz;
   req.w=_w;
   req.h=_h;
   req.src_w=_src_w;
   req.src_h=_src_h;
   req.x_off=_x_off;
   req.y_off=_y_off;
   req.dst_w=_dst_w;
   req.dst_h=_dst_h;
   
   ztaDualHartExecute(iconv,&req);

   ztaJobDone(_req_id);
}
