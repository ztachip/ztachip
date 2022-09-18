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

#include <stdint.h>
#include <stdbool.h>
#include "zta.h"

// Round up to multiple of b

#define ROUND(a,b) ((((a)+(b)-1)/(b))*(b))

/* Task function API */

void ztamInit();

void ztamDualHartExecute(void(*func)(void *,int),void *pparm);

uint32_t ztamBuildKernelFunc(uint32_t _func,int num_pcore,int num_tid);

#define ztamTaskYield() {ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;_taskYield();}

#endif
