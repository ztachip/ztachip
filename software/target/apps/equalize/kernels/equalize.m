#include "../../../base/ztam.h"
#include "equalize.h"

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
   uint32_t input,output,output2,p;
   int i,j,count,extra_zero;
   int np,nt;
   int len;
   int src_w,src_h;

   input=req->input+req->w*req->h*req->ws.channel;
   output=req->output+req->ws.channel*(kHistogramBinSize*VECTOR_WIDTH)*2*2;
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
   ztamTaskYield();

   for(y=0;y < dy;y+=step_y) {
      for(x=0;x < dx;x += step_x) {
         >(ushort)PCORE(np)[:].equalize::in[0:kHistogramInSize*nt-1] <= (ushort)MEM(input,src_w)[x:x+step_x-1];

         > EXE_LOCKSTEP(equalize::exe,np,nt);

         ztamTaskYield();

         i++;
         j+=(step_x*step_y);
         if(i >= count) {
            > EXE_LOCKSTEP(equalize::accumulate,np,nt);
            ztamTaskYield();
            i=0;
         }
         if(req->equalize) {
            >(ushort)MEM(output2,src_w)[x:x+step_x-1] <= PROC(0) <= (ushort)PCORE(np)[:].equalize::in[0:kHistogramInSize*nt-1];
         } else {
            >(ushort)MEM(output2,src_w)[x:x+step_x-1] <= (ushort)PCORE(np)[:].equalize::in[0:kHistogramInSize*nt-1];
         }
      }
   }

   > EXE_LOCKSTEP(equalize::accumulate,np,nt);

   ztamTaskYield();

   > equalize::done.count <= INT(nt);

   // Summarize results among the threads...
   > EXE_LOCKSTEP(equalize::done,np,kHistogramBinSize);
   ztamTaskYield();

   // Save results to SCRATCH...
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=(pid==0)?0:len*2*2;
   >(int)SCRATCH(p,len)[0:len-1] <= (int)PCORE(np)[0:np-1].equalize::histogram_lo[0:kHistogramBinSize-1][:];
   p += len*2;
   >(int)SCRATCH(p,len)[0:len-1] <= (int)PCORE(np)[0:np-1].equalize::histogram_hi[0:kHistogramBinSize-1][:];

   req->ws.extra_zero[pid]=j-dx*dy;
}

// Aggregate the results from all the cores from both process 1 & 2

static void equalize_final(Request *req) {
   uint32_t p;
   int np,len,extra_zero;

   np=NUM_PCORE;
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=0;
   >PCORE(np)[0].equalize::histogram_lo[0:kHistogramBinSize*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].equalize::histogram_hi[0:kHistogramBinSize*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].equalize::histogram_lo[kHistogramBinSize*np:kHistogramBinSize*2*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].equalize::histogram_hi[kHistogramBinSize*np:kHistogramBinSize*2*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];

   if((2*np) > NUM_THREAD_PER_CORE)
      ztamAssert("Histogram FAIL");

   > equalize::done.count <= INT(2*np);
   > EXE_LOCKSTEP(equalize::done,1,kHistogramBinSize);

   extra_zero=req->ws.extra_zero[0]+req->ws.extra_zero[1];

   >(int)PCORE(np)[0].equalize::histogram_hi[kHistogramBinSize][:] <= INT(extra_zero/1000);
   >(int)PCORE(np)[0].equalize::histogram_lo[kHistogramBinSize][:] <= INT(extra_zero%1000);

   > EXE_LOCKSTEP(equalize::adjust_extra_zero,1,1);

   p=req->output+req->ws.channel*(kHistogramBinSize*VECTOR_WIDTH)*2*2;
   > (int)MEM(p,kHistogramBinSize*VECTOR_WIDTH)[:] <= (int)PCORE(np)[0].equalize::histogram_hi[0:kHistogramBinSize-1][:];
   p+=kHistogramBinSize*VECTOR_WIDTH*2;
   > (int)MEM(p,kHistogramBinSize*VECTOR_WIDTH)[:] <= (int)PCORE(np)[0].equalize::histogram_lo[0:kHistogramBinSize-1][:];
}

// Process request from host to do equalization/histogram

void do_equalize(int queue) {
   Request req;
   int resp,i;
   req.input=ztamMsgqReadPointer(queue);
   req.output=ztamMsgqReadPointer(queue);
   req.output2=ztamMsgqReadPointer(queue);
   req.nchannels=ztamMsgqReadInt(queue);
   req.equalize=ztamMsgqReadPointer(queue);
   req.w=ztamMsgqReadInt(queue);
   req.h=ztamMsgqReadInt(queue);
   resp=ztamMsgqReadInt(queue);
   if(req.equalize) {
      > SPU(1) <= (int)MEM(req.equalize,SPU_LOOKUP_SIZE)[:];
   }
   for(i=0;i < req.nchannels;i++) {
      req.ws.channel=i;
      ztamTaskSpawn(equalize,&req,1);
      equalize(&req,0);
      while(ztamTaskStatus(1))
         ztamTaskYield();
      equalize_final(&req);
   }
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

> EXPORT(do_equalize);
