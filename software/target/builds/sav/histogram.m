#include "..\..\..\base\ztam.h"
#include "histogram.h"

// Perform histogram equalization

typedef struct {
   uint32_t input;
   uint32_t output;
   uint32_t output2;
   int nchannels;
   uint32_t equalize;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   struct {
      int channel;
      int extra_zero[2];
   } ws;
} Request;

extern void mycallback(int);

static void histogram(Request *req,int pid) {
   int x,y;
   int step,step_x,step_y;
   int dx,dy;
   uint32_t input,output,output2,p;
   int x_off,y_off;
   int src_w,src_h;
   int i,j,count,extra_zero;
   int np,nt;
   bool clip;
   int len;

   input=req->input+req->src_w*req->src_h*req->ws.channel;
   output=req->output+req->ws.channel*(kHistogramBinSize*VECTOR_WIDTH)*2*2;
   output2=req->output2+req->w*req->h*req->ws.channel;
   np=NUM_PCORE;
   nt=NUM_THREAD_PER_CORE;
   step_x = kHistogramInSize*nt;
   step_y = np;
   dx=req->w;
   dy=req->h;
   src_w=req->src_w;
   src_h=req->src_h;
   x_off=req->x_off;
   y_off=req->y_off;

   if(x_off==0 && y_off==0 && src_w==dx && src_h==dy) {
      // No clipping...
      dx=dx*dy;
      dy=1;
      src_w=src_w*src_h;
      src_h=1;
      step_x=step_x*step_y;
      step_y=1;
      clip=false;
   } else {
      clip=true;
   }
   if(!clip) {
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
   } else {
      // Split the job in the Y direction
      if(pid==0) {
         dy=dy/2;
         src_h=y_off+dy;
      } else {
         input=input+(y_off+dy/2)*src_w;
         src_h=src_h-(y_off+dy/2);
         dy=dy-dy/2;
         y_off=0;
      }
   }

   if(clip) {
      // If read access is clipped, access pattern may have extra reads inorder
      // to fit the read tiles...
      // Try to maximize utilization by reducing number of threads
      for(nt=NUM_MIN_THREAD_FOR_MAX_EFFICIENCY;nt <= NUM_THREAD_PER_CORE;nt++) {
         step=kHistogramInSize*nt;
         if(((dx+step-1)/step) <= ((dx+step_x-1)/step_x))
            break;  
      }
      step_x=step;
   }

   count=1000/kHistogramInSize;

   i=0;
   j=0;
   > EXE_LOCKSTEP(histogram::init,np,nt);
   ztamTaskYield();

   for(y=0;y < dy;y+=step_y) {
      for(x=0;x < dx;x += step_x) {
         if(clip) {
            >(ushort)PCORE(np)[:].histogram::in[0:step_x-1] <= (ushort)MEM(input,src_h,src_w)[y+y_off:y+y_off+step_y-1][x+x_off:x+x_off+step_x-1];
         } else {
            >(ushort)PCORE(np)[:].histogram::in[0:kHistogramInSize*nt-1] <= (ushort)MEM(input,src_w)[x:x+step_x-1];
         }
         > EXE_LOCKSTEP(histogram::exe,np,nt);

         ztamTaskYield();

         i++;
         j+=(step_x*step_y);
         if(i >= count) {
            > EXE_LOCKSTEP(histogram::accumulate,np,nt);
            ztamTaskYield();
            i=0;
         }
> LOG_ON;
         if(req->equalize) {
            >(ushort)MEM(output2,src_w)[x:x+step_x-1] <= PROC(0) <= (ushort)PCORE(np)[:].histogram::in[0:kHistogramInSize*nt-1];
         } else {
            >(ushort)MEM(output2,src_w)[x:x+step_x-1] <= (ushort)PCORE(np)[:].histogram::in[0:kHistogramInSize*nt-1];
         }
> LOG_OFF;
      }
   }

   > EXE_LOCKSTEP(histogram::accumulate,np,nt);

   ztamTaskYield();

   > histogram::done.count <= INT(nt);

   // Summarize results among the threads...
   > EXE_LOCKSTEP(histogram::done,np,kHistogramBinSize);
   ztamTaskYield();

   // Save results to SCRATCH...
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=(pid==0)?0:len*2*2;
   >(int)SCRATCH(p,len)[0:len-1] <= (int)PCORE(np)[0:np-1].histogram::histogram_lo[0:kHistogramBinSize-1][:];
   p += len*2;
   >(int)SCRATCH(p,len)[0:len-1] <= (int)PCORE(np)[0:np-1].histogram::histogram_hi[0:kHistogramBinSize-1][:];

   req->ws.extra_zero[pid]=j-dx*dy;
}

// Aggregate the results from all the cores from both process 1 & 2

static void histogram_final(Request *req) {
   uint32_t p;
   int np,len,extra_zero;

   np=NUM_PCORE;
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=0;
   >PCORE(np)[0].histogram::histogram_lo[0:kHistogramBinSize*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].histogram::histogram_hi[0:kHistogramBinSize*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].histogram::histogram_lo[kHistogramBinSize*np:kHistogramBinSize*2*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];
   p += len*2;
   >PCORE(np)[0].histogram::histogram_hi[kHistogramBinSize*np:kHistogramBinSize*2*np-1][:] <= (int)SCRATCH(p,len)[0:len-1];

   if((2*np) > NUM_THREAD_PER_CORE)
      ztamAssert("Histogram FAIL");

   > histogram::done.count <= INT(2*np);
   > EXE_LOCKSTEP(histogram::done,1,kHistogramBinSize);

   extra_zero=req->ws.extra_zero[0]+req->ws.extra_zero[1];

   >(int)PCORE(np)[0].histogram::histogram_hi[kHistogramBinSize][:] <= INT(extra_zero/1000);
   >(int)PCORE(np)[0].histogram::histogram_lo[kHistogramBinSize][:] <= INT(extra_zero%1000);

   > EXE_LOCKSTEP(histogram::adjust_extra_zero,1,1);

   p=req->output+req->ws.channel*(kHistogramBinSize*VECTOR_WIDTH)*2*2;
   > (int)MEM(p,kHistogramBinSize*VECTOR_WIDTH)[:] <= (int)PCORE(np)[0].histogram::histogram_hi[0:kHistogramBinSize-1][:];
   p+=kHistogramBinSize*VECTOR_WIDTH*2;
   > (int)MEM(p,kHistogramBinSize*VECTOR_WIDTH)[:] <= (int)PCORE(np)[0].histogram::histogram_lo[0:kHistogramBinSize-1][:];
}


void do_histogram() {
   Request req;
   int resp,i;
   req.input=ztamMsgReadPointer();
   req.output=ztamMsgReadPointer();
   req.output2=ztamMsgReadPointer();
   req.nchannels=ztamMsgReadInt();
   req.equalize=ztamMsgReadPointer();
   req.w=ztamMsgReadInt();
   req.h=ztamMsgReadInt();
   req.src_w=ztamMsgReadInt();
   req.src_h=ztamMsgReadInt();
   req.x_off=ztamMsgReadInt();
   req.y_off=ztamMsgReadInt();
   resp=ztamMsgReadInt();
   if(req.equalize) {
      > SPU(1) <= (int)MEM(req.equalize,SPU_LOOKUP_SIZE)[:];
   }
   for(i=0;i < req.nchannels;i++) {
      req.ws.channel=i;
      ztamTaskSpawn(histogram,&req,1);
      histogram(&req,0);
      while(ztamTaskStatus(1))
         ztamTaskYield();
      histogram_final(&req);
   }
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

> EXPORT(do_histogram);