
#include "../../../base/ztam.h"
#include "fcn.h"

extern void mycallback(int parm2);

typedef struct {
   uint32_t coef;
   uint32_t biasHi;
   uint32_t biasLo;   
   uint32_t bot;
   uint32_t top;
   int topcnt;
   int topdim;
   int botcnt;
   int botdim;
   int coeftopcnt;
   int coefbotcnt;
   int dx;
   int top_scale;
   int stream;
   int num_thread;
   int num_pcore;
} RequestFcn;

// Do fully connected layer...

static void innerProduct(void *_p,int pid) {
   RequestFcn *req=(RequestFcn *)_p;
   int index;
   int i,j;
   int npcore,nthread;
   int coeftopcnt;
   int dx2;
   int index2;
   int topfmt=DP_DATA_TYPE_UINT8;
   int botfmt=DP_DATA_TYPE_UINT8;
   int biasfmt=DP_DATA_TYPE_INT16;
   int weightfmt=DP_DATA_TYPE_UINT8;
   
   if(pid==0) {
      // Load stream processor code
      > SPU <= (int)MEM(req->stream,SPU_LOOKUP_SIZE*3)[:];
   }

   nthread=req->num_thread;
   coeftopcnt=req->coeftopcnt*IP_CHUNK_SIZE;
   dx2=req->dx*IP_CHUNK_SIZE;

   > PCORE(NUM_PCORE)[*][0:nthread-1].inner_product::init._out_scale <= INT(req->top_scale);
   > EXE_LOCKSTEP(inner_product::init,NUM_PCORE,nthread);
   ztamTaskYield();

   for(i=(pid==0)?0:req->dx;i < req->topcnt;i += 2*req->dx) {
      index2=i*IP_CHUNK_SIZE;
      npcore=req->num_pcore;

      > (biasfmt)PCORE(npcore)[:][0:nthread-1].inner_product::biasHi[:] <= (biasfmt)MEM(req->biasHi,req->topcnt)[i:i+req->dx-1];
      > (biasfmt)PCORE(npcore)[:][0:nthread-1].inner_product::biasLo[:] <= (biasfmt)MEM(req->biasLo,req->topcnt)[i:i+req->dx-1];

      > EXE_LOCKSTEP(inner_product::start,npcore,nthread);
      ztamTaskYield();
   
      // Do innerproduct. This is a memory bound operation
         
      for(j=0,index=0;j < req->botcnt;j+=IP_CHUNK_SIZE,index++) {
         > FOR(I=0:req->num_pcore-1) FOR(J=0:nthread-1) FOR(K=0:IP_CHUNK_SIZE-1) FOR(L=0:VECTOR_WIDTH-1)    
         > (weightfmt)PCORE[I][J].inner_product::coef[K][L] <= PROC(2) <= (weightfmt)MEM(req->coef,req->coefbotcnt,coeftopcnt)[index][index2:index2+dx2-1];
         > (botfmt) PCORE(npcore)[*].inner_product::bot[:] <= PROC(1) <= (botfmt)MEM(req->bot,req->botcnt)[j:j+IP_CHUNK_SIZE-1];
         > EXE_LOCKSTEP(inner_product::exe,npcore,nthread);
         if((j+IP_CHUNK_SIZE) >= req->botcnt) {
            > EXE_LOCKSTEP(inner_product::activate_none,npcore,nthread);
            > (topfmt)MEM(req->top,req->topcnt)[i:i+req->dx-1] <=  PROC(0) <= (topfmt)PCORE(req->num_pcore)[:][0:nthread-1].inner_product::top[:];
         }
         ztamTaskYield();
      }
   }
}

typedef struct {
   int topcnt;
   int topdim;
   int botcnt;
   int botdim;
   int ksz;
   int stride;
   uint32_t top;
   uint32_t bot;
   int output_shift;
   uint32_t stream;
} RequestPool;

// Do pooling layer

static void pooling(void *_p,int pid) {
   RequestPool *req=(RequestPool *)_p;
   int i,j;
   int from,to;
   int np; 
   int fmt=DP_DATA_TYPE_UINT8;
   int botsz;
   int cnt,step,remain,nt;

   if(pid==0) {
      > SPU <= (int)MEM(req->stream,SPU_LOOKUP_SIZE*3)[:];
   }
   np=NUM_PCORE;
   cnt=req->topcnt;
   botsz=req->botdim*req->botdim;
   step=NUM_THREAD_PER_CORE*VECTOR_WIDTH*np;
   
   if(pid==0) {
      from=0;
      to=cnt/2;
   } else {
      from=cnt/2;
      to=cnt;
   }
   > PCORE(np)[*][:].max_pool::init._out_scale <= INT(req->output_shift);
   > EXE_LOCKSTEP(max_pool::init,np);
   ztamTaskYield();
 
   for(i=from;i < to;i+=step) {
      remain=to-i;
      nt=(remain+VECTOR_WIDTH*np-1)/(VECTOR_WIDTH*np);
      for(j=0;j < botsz;j += POOL_BOT_SIZE) {
         >(fmt) SCATTER(0) FOR(I=0:np-1) FOR(J=0:nt-1) FOR(K=0:VECTOR_WIDTH-1) PCORE(np)[I].THREAD[J].max_pool::bot[:][K] <= 
         >(fmt) MEM(req->bot,cnt,botsz)[i:i+VECTOR_WIDTH*np*nt-1][j:j+POOL_BOT_SIZE-1];
         >EXE_LOCKSTEP(max_pool::exe,np);
         ztamTaskYield();       
      }
      >EXE_LOCKSTEP(max_pool::finish,np);
      ztamTaskYield();
      
      // Output results...
        
      >(fmt) MEM(req->top,cnt)[i:i+VECTOR_WIDTH*np*nt-1] <= PROC(0) <= (fmt) FOR(I=0:np-1) FOR(J=0:nt-1) PCORE(np)[I].THREAD[J].max_pool::top[:];
   }
}

// Do concantenation layer...
// Pretty straightforward, concatenate tensor data together

void do_concatenate(int queue) {
   int i,resp,cnt,idx;
   uint32_t spu,src,dest;
   int copySize;
   int len,remain;
   int fmt=DP_DATA_TYPE_UINT8;

   cnt=ztamMsgqReadInt(queue);
   for(i=0;i < cnt;i++) {
      src=ztamMsgqReadPointer(queue);
      copySize=ztamMsgqReadInt(queue);
      spu=ztamMsgqReadPointer(queue);
      dest=ztamMsgqReadPointer(queue);
      if(spu) {
         // Load stream processor code
         > SPU(1) <= (int)MEM(spu,SPU_LOOKUP_SIZE)[:];
         > FLUSH;
      }
      remain=copySize;
      idx=0;
      while(remain > 0) {
         len=remain;
         len=ROUND(len,VECTOR_WIDTH);
         if(len > CONCATENATE_BUFSZ)
            len=CONCATENATE_BUFSZ;
         >(fmt)PCORE(NUM_PCORE)[0].concatenate::buf[0:len-1] <= (fmt)MEM(src)[idx:idx+len-1];
         >FLUSH;
         if(spu) {
            >(fmt)MEM(dest,copySize)[idx:idx+len-1] <= PROC(0) <= (fmt)PCORE(NUM_PCORE)[0].concatenate::buf[0:len-1];
         } else {
            >(fmt)MEM(dest,copySize)[idx:idx+len-1] <= (fmt)PCORE(NUM_PCORE)[0].concatenate::buf[0:len-1];
         }
         >FLUSH;
         idx += len;
         remain -= len;
      }
   }
   resp=ztamMsgqReadInt(queue);
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

// Do logistic layer

void do_logistic(int queue) {
   int i,resp,cnt,idx;
   uint32_t spu,src,dest;
   int copySize;
   int len,remain;
   int fmt=DP_DATA_TYPE_UINT8;

   copySize=ztamMsgqReadInt(queue);
   src=ztamMsgqReadPointer(queue);
   dest=ztamMsgqReadPointer(queue);
   spu=ztamMsgqReadPointer(queue);
   resp=ztamMsgqReadInt(queue);
   // Load stream processor code
   > SPU(2) <= (int)MEM(spu,2*SPU_LOOKUP_SIZE)[:];
   > FLUSH;
   remain=copySize;
   idx=0;
   while(remain > 0) {
      len=remain;
      len=ROUND(len,VECTOR_WIDTH);
      if(len > CONCATENATE_BUFSZ)
         len=CONCATENATE_BUFSZ;
      >(fmt)PCORE(NUM_PCORE)[0].concatenate::buf[0:len-1] <= PROC(1) <= (fmt)MEM(src)[idx:idx+len-1];
      >FLUSH;
      >(fmt)MEM(dest,copySize)[idx:idx+len-1] <= PROC(0) <= (fmt)PCORE(NUM_PCORE)[0].concatenate::buf[0:len-1];
      >FLUSH;
      idx += len;
      remain -= len;
   }
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

// Process fully-connected layer request from host

void do_innerProduct(int queue)
{
   RequestFcn req;
   int resp;
   req.coef=ztamMsgqReadPointer(queue);
   req.biasHi=ztamMsgqReadPointer(queue);
   req.biasLo=ztamMsgqReadPointer(queue);
   req.bot=ztamMsgqReadPointer(queue);
   req.top=ztamMsgqReadPointer(queue);
   req.topcnt=ztamMsgqReadInt(queue);
   req.botcnt=ztamMsgqReadInt(queue);
   req.coeftopcnt=ztamMsgqReadInt(queue);
   req.coefbotcnt=ztamMsgqReadInt(queue);
   req.stream=ztamMsgqReadPointer(queue);
   req.top_scale=ztamMsgqReadInt(queue);
   req.num_pcore=ztamMsgqReadInt(queue);
   req.num_thread=ztamMsgqReadInt(queue);
   resp=ztamMsgqReadInt(queue);
   req.dx=req.num_pcore*req.num_thread*VECTOR_WIDTH;
   ztamTaskSpawn(innerProduct,&req,1);
   innerProduct(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

// Process pooling layer request from host

void do_Pooling(int queue)
{
   RequestPool req;
   int resp;
   req.bot=ztamMsgqReadPointer(queue);
   req.top=ztamMsgqReadPointer(queue);
   req.ksz=ztamMsgqReadInt(queue);
   req.stride=ztamMsgqReadInt(queue);
   req.topcnt=ztamMsgqReadInt(queue);
   req.topdim=ztamMsgqReadInt(queue);
   req.botcnt=ztamMsgqReadInt(queue);
   req.botdim=ztamMsgqReadInt(queue);
   req.stream=ztamMsgqReadPointer(queue);
   req.output_shift=ztamMsgqReadInt(queue);
   resp=ztamMsgqReadInt(queue);
   ztamTaskSpawn(pooling,&req,1);
   pooling(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

> EXPORT(do_concatenate);
> EXPORT(do_logistic);
> EXPORT(do_innerProduct);
> EXPORT(do_Pooling);
