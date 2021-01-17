#include "../../../software/target/base/ztam.h"

static uint32_t x;
static uint32_t y;
static uint32_t z; 
static uint32_t sz;

//#define DEBUG_PRINT

// Do matrix addition

static void do_ma_add(void *_p,int pid) {
   int from,to,batchSize,i;
   int fmt=DP_DATA_TYPE_UINT8;

   // main thread do the top half, child thread do the bottom half
   from=(pid==0)?0:sz/2;
   to=(pid==0)?sz/2:sz;
   batchSize=NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i < to;i+=batchSize) {
      // Load input tensor from DDR to PCORE memory space
      > (fmt)PCORE[:].THREAD[:].ma_add::x[:] <= (fmt)MEM(x,sz)[i:i+batchSize-1];
      > (fmt)PCORE[:].THREAD[:].ma_add::y[:] <= (fmt)MEM(y,sz)[i:i+batchSize-1];
      > EXE_LOCKSTEP(ma_add::add,NUM_PCORE);
      // While waiting for computation to be completed, switch to the other thread
      // to issue memory operation requests to the other PCORE process
      ztamTaskYield();
      > (fmt)MEM(z,(pid==0)?sz/2:sz)[i:i+batchSize-1] <= (fmt)PCORE[:].THREAD[:].ma_add::z[:];
   }
}

void ma_add(int queue) {
#ifdef DEBUG_PRINT
   ztamPrintf("do ma_add \n");
#endif
   // Get request parameters which are memory address
   // of input tensor X,Y and output tensor Z

   x=ztamMsgqReadPointer(queue);
   y=ztamMsgqReadPointer(queue);
   z=ztamMsgqReadPointer(queue);
   sz=ztamMsgqReadInt(queue);

   // Do matrix add using 2 threads.
   // One thread doing top half of tensors and second thread
   // doing bottom half of tensors.
   // Since each threads manage its PCORE process space, a memory
   // cycle of one process space can overlap with execution cycle 
   // of the other PCORE process space.

#ifdef DEBUG_PRINT
   >LOG_ON;
#endif
   ztamTaskSpawn(do_ma_add,0,1);
   do_ma_add(0,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
#ifdef DEBUG_PRINT
   >LOG_OFF;
#endif
}

> EXPORT(ma_add);
