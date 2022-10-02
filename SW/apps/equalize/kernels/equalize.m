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
#include "equalize.h"
#include "equalize.h"
#include "equalize.p.img"

// Perform histogram equalization

typedef struct {
   uint32_t input;
   uint32_t output;
   uint32_t output2;
   int nchannels;
   uint32_t equalize;
   int w;
   int h;
   struct {
      int channel;
      int extra_zero[2];
   } ws;
} Request;

extern void mycallback(int);

static void equalize(void *_p,int pid) {
   Request *req=(Request *)_p;
   int x,y;
   int step,step_x,step_y;
   int dx,dy;
   uint32_t input,output2,p;
   int i,j,count,extra_zero;
   int np,nt;
   int len;
   int src_w,src_h;

   input=req->input+req->w*req->h*req->ws.channel;
   output2=req->output2+req->w*req->h*req->ws.channel;
   np=NUM_PCORE;
   nt=NUM_THREAD_PER_CORE;
   step_x = kHistogramInSize*nt;
   step_y = np;
   dx=req->w;
   dy=req->h;
   src_w=req->w;
   src_h=req->h;

   dx=dx*dy;
   dy=1;
   src_w=src_w*src_h;
   src_h=1;
   step_x=step_x*step_y;
   step_y=1;

   // Split the job in the X direction
   if(pid==0) {
      dx=dx/2;
      src_w=src_w/2;
   } else {
      input=input+dx/2;
      output2=output2+dx/2;
      dx=dx-dx/2;
      src_w=src_w-src_w/2;
   }

   count=1000/kHistogramInSize;

   i=0;
   j=0;
   > EXE_LOCKSTEP(equalize::init,np,nt);
   ztaTaskYield();

   for(y=0;y < dy;y+=step_y) {
      for(x=0;x < dx;x += step_x) {
         >CAST(UINT8)PCORE(np)[:].equalize::in[0:kHistogramInSize*nt-1] <= CAST(UINT8)MEM(input,src_w)[x:x+step_x-1];

         if(req->equalize) {
            >CAST(UINT8)MEM(output2,src_w)[x:x+step_x-1] <= PROC(0) <= CAST(UINT8)SYNC PCORE(np)[:].equalize::in[0:kHistogramInSize*nt-1];
         } else {
            >CAST(UINT8)MEM(output2,src_w)[x:x+step_x-1] <= CAST(UINT8)SYNC PCORE(np)[:].equalize::in[0:kHistogramInSize*nt-1];
         }

         > EXE_LOCKSTEP(equalize::exe,np,nt);

         ztaTaskYield();

         i++;
         j+=(step_x*step_y);
         if(i >= count) {
            > EXE_LOCKSTEP(equalize::accumulate,np,nt);
            ztaTaskYield();
            i=0;
         }
      }
   }

   > EXE_LOCKSTEP(equalize::accumulate,np,nt);

   ztaTaskYield();

   > equalize::done.count <= INT16(nt);

   // Summarize results among the threads...
   > EXE_LOCKSTEP(equalize::done,np,kHistogramBinSize);
   ztaTaskYield();

   // Save results to SCRATCH...
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=(pid==0)?0:len*2*2;
   >CAST(INT16)SCRATCH(p,len)[0:len-1] <= CAST(INT16)PCORE(np)[0:np-1].equalize::histogram_lo[0:kHistogramBinSize-1][:];
   p += len*2;
   >CAST(INT16)SCRATCH(p,len)[0:len-1] <= CAST(INT16)PCORE(np)[0:np-1].equalize::histogram_hi[0:kHistogramBinSize-1][:];

   req->ws.extra_zero[pid]=j-dx*dy;
}

// Aggregate the results from all the cores from both process 1 & 2

static void equalize_final(Request *req) {
   uint32_t p;
   int np,len,extra_zero;

   np=NUM_PCORE;
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=0;
   >PCORE(np)[0].equalize::histogram_lo[0:kHistogramBinSize*np-1][:] <= CAST(INT16)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].equalize::histogram_hi[0:kHistogramBinSize*np-1][:] <= CAST(INT16)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].equalize::histogram_lo[kHistogramBinSize*np:kHistogramBinSize*2*np-1][:] <= CAST(INT16)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].equalize::histogram_hi[kHistogramBinSize*np:kHistogramBinSize*2*np-1][:] <= CAST(INT16)SCRATCH(p,len)[0:len-1];

   if((2*np) > NUM_THREAD_PER_CORE)
      ztaAbort(0);

   > equalize::done.count <= INT16(2*np);
   > EXE_LOCKSTEP(equalize::done,1,kHistogramBinSize);

   extra_zero=req->ws.extra_zero[0]+req->ws.extra_zero[1];

   >CAST(INT16)PCORE(np)[0].equalize::histogram_hi[kHistogramBinSize][:] <= INT16(extra_zero/1000);
   >CAST(INT16)PCORE(np)[0].equalize::histogram_lo[kHistogramBinSize][:] <= INT16(extra_zero%1000);

   > EXE_LOCKSTEP(equalize::adjust_extra_zero,1,1);

   p=req->output+req->ws.channel*(kHistogramBinSize*VECTOR_WIDTH)*2*2;
   > CAST(INT16)MEM(p,kHistogramBinSize*VECTOR_WIDTH)[:] <= CAST(INT16)PCORE(np)[0].equalize::histogram_hi[0:kHistogramBinSize-1][:];
   p+=kHistogramBinSize*VECTOR_WIDTH*2;
   > CAST(INT16)MEM(p,kHistogramBinSize*VECTOR_WIDTH)[:] <= CAST(INT16)PCORE(np)[0].equalize::histogram_lo[0:kHistogramBinSize-1][:];
}

// Process request from host to do equalization/histogram

void kernel_equalize_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _output2,
   int _nchannels,
   unsigned int _equalize,
   int _w,
   int _h
   ) 
{
   Request req;
   int i;
   
   ztaInitPcore(zta_pcore_img);
   ztaInitStream(_equalize);
      
   req.input=_input;
   req.output=_output;
   req.output2=_output2;
   req.nchannels=_nchannels;
   req.equalize=_equalize;
   req.w=_w;
   req.h=_h;
   
   for(i=0;i < req.nchannels;i++) {
      req.ws.channel=i;
      ztaDualHartExecute(equalize,&req);
      equalize_final(&req);
   }
   ztaJobDone(_req_id);
}

