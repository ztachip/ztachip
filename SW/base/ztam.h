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

#ifndef _ZTAM_H_
#define _ZTAM_H_

#include "zta.h"

#ifndef uint32_t
typedef unsigned int uint32_t;
#endif
#ifndef int32_t
typedef int int32_t;
#endif
#ifndef uint8_t
typedef unsigned char uint8_t;
#endif
#ifndef int8_t
typedef signed char int8_t;
#endif
#ifndef uint16_t
typedef unsigned short uint16_t;
#endif
#ifndef int16_t
typedef short int16_t;
#endif
#ifndef bool
typedef int bool;
#endif
#define true    1
#define false   0
typedef void (*CallbackFunc)(uint32_t);

// Round up to multiple of b

#define ROUND(a,b) ((((a)+(b)-1)/(b))*(b))

/* Task function API */

extern void _taskYield(void);
extern void _taskSpawn(uint32_t,uint32_t,uint32_t,uint32_t);
void ztamInit();
void ztamTaskInit();
void ztamTaskSpawn(void(*func)(void *,int), void *_p, uint32_t p2);
bool ztamTaskStatus(int pid);
uint32_t ztamBuildKernelFunc(uint32_t _func,int num_pcore,int num_tid);
#define ztamTaskYield() {ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;_taskYield();}
void ztamAssert(char *msg);

#endif
