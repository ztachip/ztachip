#include "../../../software/target/base/ztam.h"

extern void mycallback(int);

static uint32_t x;
static uint32_t y;
static uint32_t z; 
static uint32_t sz;

// Do matrix addition

static void do_ma_add(void *_p,int pid) {
   int from,to,batchSize,i;
   int fmt=DP_DATA_TYPE_UINT8;

   // main thread do the top half, child thread do the bottom half
   from=(pid==0)?0:sz/2;
   to=(pid==0)?sz/2:sz;
   batchSize=NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i < to;i+=batchSize) {
      > (fmt)PCORE[:].THREAD[:].ma_add::x[:] <= (fmt)MEM(x,sz)[i:i+batchSize-1];
      > (fmt)PCORE[:].THREAD[:].ma_add::y[:] <= (fmt)MEM(y,sz)[i:i+batchSize-1];
      > EXE_LOCKSTEP(ma_add::add,NUM_PCORE);
      ztamTaskYield();
      > (fmt)MEM(z,(pid==0)?sz/2:sz)[i:i+batchSize-1] <= (fmt)PCORE[:].THREAD[:].ma_add::z[:];
   }
}

void ma_add(int queue) {

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

   ztamTaskSpawn(do_ma_add,0,1);
   do_ma_add(0,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
}

> EXPORT(ma_add);
