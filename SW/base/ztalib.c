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
#include <stdbool.h>
#include "ztalib.h"

static bool taskStatus=false;

// Task entry point...

static void taskEntry(int thisFunc, void(*func)(int, int), int p1, int p2) {
   ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;
   _taskYield();
   if (func)
      (*func)(p1, p2);
   taskStatus = false;
   for (;;) {
	  ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;
      _taskYield();
   }
}

// Perform initialization for code running on mcore

void ztaInit() {
   taskStatus = false;
   _taskSpawn((uint32_t)taskEntry,0,0,0);
}


// Start execution by spawning 2 threads
void ztaDualHartExecute(void(*func)(void *,int),void *pparm) {
   // Launch a thread to execute on tensor processor's first HART
   taskStatus = true;
   _taskSpawn((uint32_t)taskEntry,(uint32_t)func,(uint32_t)pparm,1);
   ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;
   _taskYield();

   (*func)(pparm,0);

   // Wait for both threads to be finished
   while(taskStatus)
      ztaTaskYield();
}

// All information to launch a kernel is packed into 32 bit word

uint32_t ztaBuildKernelFunc(uint32_t _func,int num_pcore,int num_tid) {
   uint32_t func,p0,p1,dataModel;
   func=EXE_FUNC_FIELD(_func); // First instruction address to kernel functions
   p0=EXE_P0_FIELD(_func); // Firt parameter
   p1=EXE_P1_FIELD(_func); // Second parameter
   dataModel=EXE_MODEL_FIELD(_func); // Kernel memory model (large/small)
   return DP_EXE_CMD(1,func,num_pcore-1,0,p0,p1,num_tid-1,dataModel);
}

// Allocate shared memory from non-cached data region

ZTA_SHARED_MEM ztaAllocSharedMem(int _size) {
   uint32_t p,p2;
   // We lose up to 8 bytes to align to 64-bit boundary and lose 
   // another 8 bytes for header
   _size += 16; 
	p=(uint32_t)malloc(_size);
   p2 = ((p+7)/8)*8; // Round to neareset 64-bit boundary
   ((uint32_t *)(p2))[0]=p;
   ((uint32_t *)(p2))[1]=_size;
   return (ZTA_SHARED_MEM)(p2+8);
}

// Free a previously allocated shared memory

void ztaFreeSharedMem(ZTA_SHARED_MEM p) {
   uint32_t p2;
   p2 = (uint32_t)p-8;
	free((void *)(((uint32_t *)p2)[0]));
}

// Build ztachip lookup table

static ZTA_SHARED_MEM buildSpu(SPU_FUNC func,void *pparm,uint32_t parm,uint32_t parm2) {
   uint16_t v;
   int16_t v2,v4,slope;
   int16_t *p;
   ZTA_SHARED_MEM shm;

   shm=ztaAllocSharedMem(SPU_SIZE*2*sizeof(int16_t));
   p=(int16_t *)ZTA_SHARED_MEM_VIRTUAL(shm);
   for(int i=0;i < SPU_SIZE;i++) {
      v=((i*SPU_REMAINDER)&0xFFF);
      if(v & 0x800)
         v |= 0xF800;
      v2=(*func)(v,(i==0)?pparm:0,parm,parm2);
      v=((i*SPU_REMAINDER+(SPU_REMAINDER-1))&0xFFF);
      if(v & 0x800)
         v |= 0xF800;
      v4=(*func)(v,0,parm,parm2);
      slope=(int16_t)(((((int)v4-(int)v2)))*SPU_REMAINDER)/(SPU_REMAINDER-1);
      p[2*i]=slope;
      p[2*i+1]=v2;
   }
   return shm;
}

ZTA_SHARED_MEM ztaBuildSpuBundle(int numSpuImg,...) {
   ZTA_SHARED_MEM bundle,spu;
   SPU_FUNC func;
   void *pparm;
   uint32_t parm,parm2;
   int16_t *pp;
   int i;
   va_list args;

   va_start(args,numSpuImg);

   bundle=ztaAllocSharedMem((numSpuImg*SPU_SIZE*2+1)*sizeof(int16_t));
   pp=(int16_t *)ZTA_SHARED_MEM_VIRTUAL(bundle);
   pp[0]=numSpuImg;
   pp++;
   for(i=0;i < numSpuImg;i++,pp+=SPU_SIZE*2) {
	  func = va_arg(args,SPU_FUNC);
	  pparm = va_arg(args,void *);
	  parm = va_arg(args,uint32_t);
	  parm2 = va_arg(args,uint32_t);
	  spu=buildSpu(func,pparm,parm,parm2);
      memcpy(pp,ZTA_SHARED_MEM_VIRTUAL(spu),SPU_SIZE*2*sizeof(int16_t));
      ztaFreeSharedMem(spu);
   }
   va_end(args);
   return bundle;
}

// Reading response message from ztachip core

bool ztaReadResponse(uint32_t *resp) {
   if(ZTAM_GREG(0,REG_DP_READ_INDICATION_AVAIL,0)==0) {
      *resp=0;
      return false;
   }
   ZTAM_GREG(0,REG_DP_READ_INDICATION,0);
   *resp=ZTAM_GREG(0,REG_DP_READ_INDICATION_PARM,0);
   ZTAM_GREG(0,REG_DP_READ_SYNC,0);
   return true;
}

// Abort all excution

void ztaAbort(int _errorCode) {
	extern void _exit(int);
   _exit(_errorCode);
}
