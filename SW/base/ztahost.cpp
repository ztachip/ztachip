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

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <malloc.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <signal.h>
#include "util.h"
#include "ztahost.h"

// Allocate shared memory from non-cached data region

ZTA_SHARED_MEM ztahostAllocSharedMem(int _size) {
	return (ZTA_SHARED_MEM)malloc(_size);
}

// Free a previously allocated shared memory

void ztahostFreeSharedMem(ZTA_SHARED_MEM p) {
	free((void *)p);
}

// Build ztachip lookup table

ZTA_SHARED_MEM ztahostBuildSpu(SPU_FUNC func,void *pparm,uint32_t parm) {
   uint16_t v;
   float v2;
   int16_t v3,v4,slope;
   int16_t *p;
   ZTA_SHARED_MEM shm;

   shm = ztahostAllocSharedMem(SPU_SIZE*2*sizeof(int16_t));
   p=(int16_t *)ZTA_SHARED_MEM_P(shm);
   for(int i=0;i < SPU_SIZE;i++) {
      v=((i*SPU_REMAINDER)&0xFFF);
      if(v & 0x800)
         v |= 0xF800;
      Util::Int2Float((int16_t *)&v,&v2,DATA_BIT_WIDTH-1,1);
      v2=(*func)(v2,(i==0)?pparm:0,parm);
      Util::Float2Int(&v2,&v3,DATA_BIT_WIDTH-1,1);
      v=((i*SPU_REMAINDER+(SPU_REMAINDER-1))&0xFFF);
      if(v & 0x800)
         v |= 0xF800;
      Util::Int2Float((int16_t *)&v,&v2,DATA_BIT_WIDTH-1,1);
      v2=(*func)(v2,0,parm);
      Util::Float2Int(&v2,&v4,DATA_BIT_WIDTH-1,1);
      slope=(int16_t)(((((int)v4-(int)v3)))*SPU_REMAINDER)/(SPU_REMAINDER-1);
      p[2*i]=slope;
      p[2*i+1]=v3;
   }
   return shm;
}


ZTA_SHARED_MEM ztahostBuildSpuBundle(int numSpuImg,...) {
   ZTA_SHARED_MEM bundle,spu;
   SPU_FUNC func;
   void *pparm;
   uint32_t parm;
   int16_t *pp;
   int i;
   va_list args;

   va_start(args,numSpuImg);

   bundle=ztahostAllocSharedMem(numSpuImg*SPU_SIZE*2*sizeof(int16_t));
   pp=(int16_t *)ZTA_SHARED_MEM_P(bundle);
   for(i=0;i < numSpuImg;i++,pp+=SPU_SIZE*2) {
	  func = va_arg(args,SPU_FUNC);
	  pparm = va_arg(args,void *);
	  parm = va_arg(args,uint32_t);
	  spu=ztahostBuildSpu(func,pparm,parm);
      memcpy(pp,ZTA_SHARED_MEM_P(spu),SPU_SIZE*2*sizeof(int16_t));
      ztahostFreeSharedMem(spu);
   }
   va_end(args);
   return bundle;
}

