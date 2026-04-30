//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except INBUF compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to INBUF writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "../../../../SW/base/ztalib.h"
#include "../../../../SW/src/soc.h"
#include "test_dma.p.img"


int8_t INBUF[2*1024+64];

int8_t OUTBUF[2*1024+64];

static int SEED=0;

static int OFFSET=4;

// ---------------
// Suite of tests to test various memory transfer scenario in different vector
// width
//-----------------

typedef struct {
   uint32_t in_p;
   uint32_t out_p;
   int len;
} REQUEST;

//------------------------------
// Test DDR<->PCORE transfers of INT8 data in vector mode
//------------------------------

#if 0
static void dma_1_1(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      >DTYPE(INT8)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[:].test_dma_1::x[:] <= DTYPE(INT8)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_1::exe,NUM_PCORE);

      ztaTaskYield();

      >DTYPE(INT8)MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] <= DTYPE(INT8)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[:].test_dma_1::y[:];
   }
   >BARRIER;
} 

//------------------------------
// Test DDR<->PCORE transfers of INT8 data in scalar mode
//------------------------------

static void dma_1_2(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      > DTYPE(INT8) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:1) FOR(I=0:NUM_PCORE-1) FOR(J=0:7) PCORE(NUM_PCORE)[I].THREAD(2,8)[JJ][J].test_dma_1::x[K] 
      > <= 
      > DTYPE(INT8)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_1::exe,NUM_PCORE);

      ztaTaskYield();

      > DTYPE(INT8) MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] 
      > <= 
      > DTYPE(INT8) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:1) FOR(I=0:NUM_PCORE-1) FOR(J=0:7) PCORE(NUM_PCORE)[I].THREAD(2,8)[JJ][J].test_dma_1::y[K];
   }
   >BARRIER;
}

//------------------------------
// Test DDR<->PCORE transfers of INT8 data in scatter mode
//------------------------------

static void dma_1_3(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      > SCATTER DTYPE(INT8) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:1) FOR(I=0:NUM_PCORE-1) FOR(J=0:7) PCORE(NUM_PCORE)[I].THREAD(2,8)[JJ][J].test_dma_1::x[K] 
      > <= 
      > DTYPE(INT8)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_1::exe,NUM_PCORE);

      ztaTaskYield();

      > DTYPE(INT8) MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] 
      > <= 
      > SCATTER DTYPE(INT8) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:1) FOR(I=0:NUM_PCORE-1) FOR(J=0:7) PCORE(NUM_PCORE)[I].THREAD(2,8)[JJ][J].test_dma_1::y[K];
   }
   >BARRIER;
}

static int16_t spuEval(int16_t _in,void *pparm,uint32_t parm,uint32_t parm2) {
    return _in+2;
}

void test_dma_1(int testcase) {
   uint32_t resp;
   REQUEST req; 
   int i;
   int8_t *inbuf;
   int8_t *outbuf;
   int sz;
   static ZTA_SHARED_MEM stream=0;

   if(stream==0)
      stream=ztaBuildSpuBundle(1,spuEval,0,0,0);   

   ztaInitPcore(zta_pcore_img);
   ztaInitStream(stream);

   sz=1024;

   inbuf = &INBUF[OFFSET];
   outbuf = &OUTBUF[OFFSET];

   req.in_p=(uint32_t)inbuf;
   req.out_p=(uint32_t)outbuf;
   req.len = sz;
   
   for(i=0;i < req.len;i++)
      inbuf[i]=(int8_t)(i&0x3F)+SEED;

   FLUSH_DATA_CACHE();
   if(testcase==1)
      ztaDualHartExecute(dma_1_1,&req);
   else if(testcase==2)
      ztaDualHartExecute(dma_1_2,&req);
   else if(testcase==3)
      ztaDualHartExecute(dma_1_3,&req);
   else
   {
      assert(0);
   }

   ztaJobDone(0);

   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   } 
   FLUSH_DATA_CACHE();
   for(i=0;i < req.len;i++) {
      if(outbuf[i] != ((i&0x3F)+1+SEED)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
   SEED = (SEED+1)%4;
}
#endif

//------------------------------
// Test DDR<->PCORE transfers of UINT8 data in vector mode
//------------------------------

#if 0
static void dma_2_1(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      >DTYPE(UINT8)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[:].test_dma_2::x[:] <= DTYPE(UINT8)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_2::exe,NUM_PCORE);

      ztaTaskYield();

      >DTYPE(UINT8)MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] <= DTYPE(UINT8)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[:].test_dma_2::y[:];
   }
}

static void dma_2_2(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      > DTYPE(UINT8) FOR(K=0:VECTOR_WIDTH-1) FOR(J=0:NUM_THREAD_PER_CORE-1) FOR(I=0:NUM_PCORE-1) PCORE(NUM_PCORE)[I].THREAD[J].test_dma_1::x[K] 
      > <= 
      > DTYPE(UINT8)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_2::exe,NUM_PCORE);

      ztaTaskYield();

      > DTYPE(UINT8) MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] 
      > <= 
      >  DTYPE(UINT8) FOR(K=0:VECTOR_WIDTH-1) FOR(J=0:NUM_THREAD_PER_CORE-1) FOR(I=0:NUM_PCORE-1) PCORE(NUM_PCORE)[I].THREAD[J].test_dma_1::y[K];
   }
   >BARRIER;
}

//------------------------------
// Test DDR<->PCORE transfers of UINT8 data in scatter mode
//------------------------------

static void dma_2_3(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      > SCATTER DTYPE(UINT8) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:1) FOR(I=0:NUM_PCORE-1) FOR(J=0:7) PCORE(NUM_PCORE)[I].THREAD(2,8)[JJ][J].test_dma_1::x[K] 
      > <= 
      > DTYPE(UINT8)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_1::exe,NUM_PCORE);

      ztaTaskYield();

      > DTYPE(UINT8) MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] 
      > <= 
      > SCATTER DTYPE(UINT8) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:1) FOR(I=0:NUM_PCORE-1) FOR(J=0:7) PCORE(NUM_PCORE)[I].THREAD(2,8)[JJ][J].test_dma_1::y[K];
   }
   >BARRIER;
}

void test_dma_2(int testcase) {
   uint32_t resp;
   REQUEST req; 
   int i;
   int8_t *inbuf;
   int8_t *outbuf;
   int sz;

   ztaInitPcore(zta_pcore_img);

   sz=1024;

   inbuf = &INBUF[OFFSET];
   outbuf = &OUTBUF[OFFSET];

   req.in_p=(uint32_t)inbuf;
   req.out_p=(uint32_t)outbuf;
   req.len = sz;
   
   for(i=0;i < req.len;i++)
      inbuf[i]=(int8_t)(i&0x3F)+SEED;

   FLUSH_DATA_CACHE();

   if(testcase==1)
      ztaDualHartExecute(dma_2_1,&req);
   else if(testcase==2)
      ztaDualHartExecute(dma_2_2,&req);
   else if(testcase==3)
      ztaDualHartExecute(dma_2_3,&req);
   else
   {
      assert(0);
   }

   ztaJobDone(0);

   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   } 
   FLUSH_DATA_CACHE();
   for(i=0;i < req.len;i++) {
      if(outbuf[i] != ((i&0x3F)+1+SEED)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
   SEED = (SEED+1)%4;
}
#endif

//------------------------------
// Test DDR<->PCORE transfers of UINT8 data in vector mode
//------------------------------

#if 1
static void dma_3_1(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      >DTYPE(INT16)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[:].test_dma_3::x[:] <= DTYPE(INT16)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_3::exe,NUM_PCORE);

      ztaTaskYield();

      >DTYPE(INT16)MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] <= DTYPE(INT16)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[:].test_dma_3::y[:];
   }
}

static void dma_3_2(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      > DTYPE(INT16) FOR(K=0:VECTOR_WIDTH-1) FOR(J=0:NUM_THREAD_PER_CORE-1) FOR(I=0:NUM_PCORE-1) PCORE(NUM_PCORE)[I].THREAD[J].test_dma_1::x[K] 
      > <= 
      > DTYPE(INT16)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_2::exe,NUM_PCORE);

      ztaTaskYield();

      > DTYPE(INT16) MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] 
      > <= 
      >  DTYPE(INT16) FOR(K=0:VECTOR_WIDTH-1) FOR(J=0:NUM_THREAD_PER_CORE-1) FOR(I=0:NUM_PCORE-1) PCORE(NUM_PCORE)[I].THREAD[J].test_dma_1::y[K];
   }
   >BARRIER;
}

//------------------------------
// Test DDR<->PCORE transfers of UINT8 data in scatter mode
//------------------------------

static void dma_3_3(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;
   int sz;
   int i;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }
   sz = NUM_PCORE*NUM_THREAD_PER_CORE*VECTOR_WIDTH;

   for(i=from;i <= to;i += sz) {
      > SCATTER DTYPE(INT16) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:3) FOR(I=0:NUM_PCORE-1) FOR(J=0:3) PCORE(NUM_PCORE)[I].THREAD(4,4)[JJ][J].test_dma_1::x[K] 
      > <= 
      > DTYPE(INT16)MEM(req->in_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1];

      >EXE_LOCKSTEP(test_dma_1::exe,NUM_PCORE);

      ztaTaskYield();

      > DTYPE(INT16) MEM(req->out_p,(pid==0)?(req->len/2):req->len)[i:i+sz-1] 
      > <= 
      > SCATTER DTYPE(INT16) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:3) FOR(I=0:NUM_PCORE-1) FOR(J=0:3) PCORE(NUM_PCORE)[I].THREAD(4,4)[JJ][J].test_dma_1::y[K];
   }
   >BARRIER;
}

void test_dma_3(int testcase) {
   uint32_t resp;
   REQUEST req; 
   int i;
   int16_t *inbuf;
   int16_t *outbuf;
   int sz;

   ztaInitPcore(zta_pcore_img);

   sz=1024;

   inbuf = (int16_t *)&INBUF[OFFSET];
   outbuf = (int16_t *)&OUTBUF[OFFSET];

   req.in_p=(uint32_t)inbuf;
   req.out_p=(uint32_t)outbuf;
   req.len = sz;
   
   for(i=0;i < req.len;i++)
      inbuf[i]=(int16_t)i+SEED;

   FLUSH_DATA_CACHE();

   if(testcase==1)
      ztaDualHartExecute(dma_3_1,&req);
   else if(testcase==2)
      ztaDualHartExecute(dma_3_2,&req);
   else if(testcase==3)
      ztaDualHartExecute(dma_3_3,&req);
   else
   {
      assert(0);
   }

   ztaJobDone(0);

   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   } 
   FLUSH_DATA_CACHE();
   for(i=0;i < req.len;i++) {
      if(outbuf[i] != (i+1+SEED)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
   SEED = (SEED+1)%4;
}
#endif
//------------------------------
// Test SCRATCH <->DDR transfers of INT8 data in vector mode
//------------------------------

#if 0
static void test_dma_4_1() {
   uint32_t resp;
   REQUEST req; 
   int i;
   int8_t *inbuf;
   int8_t *outbuf;
   int sz;

   ztaInitPcore(zta_pcore_img);

   sz=1024;
   
   inbuf = &INBUF[OFFSET];
   outbuf = &OUTBUF[OFFSET];

   for(i=0;i < sz;i++)
      inbuf[i]=(int16_t)(i&0x3f)+SEED;

   FLUSH_DATA_CACHE();

   >DTYPE(INT8)SCRATCH(0)[0:sz-1] <= DTYPE(INT8)MEM((uint32_t)inbuf)[0:sz-1];

   >BARRIER;

   >DTYPE(INT8)MEM((uint32_t)outbuf)[0:sz-1] <= DTYPE(INT8)SCRATCH(0)[0:sz-1];

   ztaJobDone(0);

   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   } 
   FLUSH_DATA_CACHE();
   for(i=0;i < sz;i++) {
      if(outbuf[i] != ((i&0x3f)+SEED)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
   SEED = (SEED+1)%4;
} 

//------------------------------
// Test SCRATCH <->DDR transfers of INT16 data in vector mode
//------------------------------

static void test_dma_4_2() {
   uint32_t resp;
   REQUEST req; 
   int i;
   int16_t *inbuf;
   int16_t *outbuf;
   int sz;

   ztaInitPcore(zta_pcore_img);

   sz=1024;

   inbuf = (int16_t *)&INBUF[OFFSET];
   outbuf = (int16_t *)&OUTBUF[OFFSET];

   for(i=0;i < sz;i++)
      inbuf[i]=(int16_t)i+SEED;

   FLUSH_DATA_CACHE();

   >DTYPE(INT16)SCRATCH(0)[0:sz-1] <= DTYPE(INT16)MEM((uint32_t)inbuf)[0:sz-1];

   >BARRIER;

   >DTYPE(INT16)MEM((uint32_t)outbuf)[0:sz-1] <= DTYPE(INT16)SCRATCH(0)[0:sz-1];

   ztaJobDone(0);

   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   } 
   FLUSH_DATA_CACHE();
   for(i=0;i < sz;i++) {
      if(outbuf[i] != (i+SEED)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
   SEED = (SEED+1)%4;
} 


//------------------------------
// Test SCRATCH <->DDR transfers of INT8 data in scalar mode
//------------------------------

static void test_dma_4_3() {
   uint32_t resp;
   REQUEST req; 
   int i;
   int8_t *inbuf;
   int8_t *outbuf;
   int sz;

   ztaInitPcore(zta_pcore_img);

   sz=1024;
   
   inbuf = &INBUF[OFFSET];
   outbuf = &OUTBUF[OFFSET];

   for(i=0;i < sz;i++)
      inbuf[i]=(int16_t)(i&0x3f)+SEED;

   FLUSH_DATA_CACHE();

   >DTYPE(INT8)SCRATCH(0)[0:sz-1] <= DTYPE(INT8)MEM((uint32_t)inbuf,sz,1)[0:sz-1][0];

   >BARRIER;

   >DTYPE(INT8)MEM((uint32_t)outbuf,sz,1)[0:sz-1][0] <= DTYPE(INT8)SCRATCH(0)[0:sz-1];

   ztaJobDone(0);

   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   } 
   FLUSH_DATA_CACHE();
   for(i=0;i < sz;i++) {
      if(outbuf[i] != ((i&0x3f)+SEED)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
   SEED = (SEED+1)%4;
} 

//------------------------------
// Test SCRATCH <->DDR transfers of INT16 data in scalar mode
//------------------------------

static void test_dma_4_4() {
   uint32_t resp;
   REQUEST req; 
   int i;
   int16_t *inbuf;
   int16_t *outbuf;
   int sz;

   ztaInitPcore(zta_pcore_img);

   sz=1024;

   inbuf = (int16_t *)&INBUF[OFFSET];
   outbuf = (int16_t *)&OUTBUF[OFFSET];

   for(i=0;i < sz;i++)
      inbuf[i]=(int16_t)i+SEED;

   FLUSH_DATA_CACHE();

   >DTYPE(INT16)SCRATCH(0)[0:sz-1] <= DTYPE(INT16)MEM((uint32_t)inbuf,sz,1)[0:sz-1][0];

   >BARRIER;

   >DTYPE(INT16)MEM((uint32_t)outbuf,sz,1)[0:sz-1][0] <= DTYPE(INT16)SCRATCH(0)[0:sz-1];

   ztaJobDone(0);

   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   } 
   FLUSH_DATA_CACHE();
   for(i=0;i < sz;i++) {
      if(outbuf[i] != (i+SEED)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
   SEED = (SEED+1)%4;
} 
#endif 

void test_dma()
{
   static int count=0;

#if 0
   test_dma_1(1); // DDR<->PCORE/UINT8/VECTOR
   test_dma_1(2); // DDR<->PCORE/UINT8/SCALAR
   test_dma_1(3); // DDR<->PCORE/UINT8/SCATTER
#endif
#if 0
   test_dma_2(1); // DDR<->PCORE/INT8/VECTOR
   test_dma_2(2); // DDR<->PCORE/INT8/SCALAR
   test_dma_2(3); // DDR<->PCORE/INT8/SCATTER
#endif
#if 1
   test_dma_3(1); // DDR<->PCORE/INT16/VECTOR
   test_dma_3(2); // DDR<->PCORE/INT16/SCALAR 
   test_dma_3(3); // DDR<->PCORE/INT16/SCALAR
#endif
#if 0
   test_dma_4_1(); // DDR<->SCRATCH/INT8/VECTOR
   test_dma_4_2(); // DDR<->SCRATCH/INT16/VECTOR
   test_dma_4_3(); // DDR<->SCRATCH/INT8/SCALAR
   test_dma_4_4(); // DDR<->SCRATCH/INT16/SCALAR
#endif
   APB[0]=++count;
   OFFSET += 2;
   if(OFFSET >= 16)
      OFFSET = 0;
}


