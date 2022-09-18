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

#include <stdarg.h>
#include <stdint.h>
#include "../base/ztam.h"

// Functions that are implemented in task.S

extern void _taskYield(void);
extern void _taskSpawn(uint32_t,uint32_t,uint32_t,uint32_t);

// This file contains supporting functions for codes running on mcore

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

void ztamInit() {
   taskStatus = false;
   _taskSpawn((uint32_t)taskEntry,0,0,0);
}


// Start execution by spawning 2 threads
void ztamDualHartExecute(void(*func)(void *,int),void *pparm) {
   // Launch a thread to execute on tensor processor's first HART
   taskStatus = true;
   _taskSpawn((uint32_t)taskEntry,(uint32_t)func,(uint32_t)pparm,1);
   ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;
   _taskYield();

   (*func)(pparm,0);

   // Wait for both threads to be finished
   while(taskStatus)
      ztamTaskYield();
}

// All information to launch a kernel is packed into 32 bit word

uint32_t ztamBuildKernelFunc(uint32_t _func,int num_pcore,int num_tid) {
   uint32_t func,p0,p1,dataModel;
   func=EXE_FUNC_FIELD(_func); // First instruction address to kernel functions
   p0=EXE_P0_FIELD(_func); // Firt parameter
   p1=EXE_P1_FIELD(_func); // Second parameter
   dataModel=EXE_MODEL_FIELD(_func); // Kernel memory model (large/small)
   return DP_EXE_CMD(1,func,num_pcore-1,0,p0,p1,num_tid-1,dataModel);
}




