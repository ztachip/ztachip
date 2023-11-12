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
#include "../../../../SW/base/ztalib.h"
#include "../../../../SW/src/soc.h"
#include "test.p.img"

#define BUFSZ (16*8*NUM_PCORE*2)

static volatile uint16_t inbuf[BUFSZ];
static volatile uint16_t outbuf[BUFSZ];

typedef struct {
   uint32_t in_p;
   uint32_t out_p;
   int len;
} REQUEST;


// Each thread is doing half the tensor
// First thread is processing the top half of tensor
// Second thread is processing the bottom half of tensor

static void test(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   uint32_t from,to;

   if(pid==0) {
      from=0;
      to=req->len/2-1;
   } else {
      from=req->len/2;
      to=req->len-1;
   }

   >DTYPE(INT16)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[0:15].test::_A[0:7] <= DTYPE(INT16)MEM(req->in_p)[from:to];

   >EXE_LOCKSTEP(test::add,NUM_PCORE);

   ztaTaskYield();

   >DTYPE(INT16)MEM(req->out_p)[from:to] <= DTYPE(INT16)PCORE(NUM_PCORE)[0:NUM_PCORE-1].THREAD[0:15].test::_Z[0:7];
}

//
// This is a simple test
// It add 1 to every elements of a tensor
//

void kernel_test_exe() {
   uint32_t resp;
   REQUEST req; 
   int i;

   ztaInitPcore(zta_pcore_img);

   req.in_p=(uint32_t)&inbuf[0];
   req.out_p=(uint32_t)&outbuf[0];
   req.len = BUFSZ;
   
   for(i=0;i < req.len;i++)
      inbuf[i]=(i&0xFF);

   FLUSH_DATA_CACHE();

   ztaDualHartExecute(test,&req);

   ztaJobDone(0);

   // Wait for response....
   for(;;) {
      if(ztaReadResponse(&resp))
         break;
   }   

   for(i=0;i < req.len;i++) {
      if(outbuf[i] != ((i&0xFF)+1)) {
         for(;;) {
            APB[0]=0xffffffff;
         }
      }
   }
}
