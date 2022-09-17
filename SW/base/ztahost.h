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

//-----------
// This file defined the API functions for host applications to communicate with
// ztachip
//------------

#ifndef __ZTAHOST_H__
#define __ZTAHOST_H__

#include <stdint.h>
#include "types.h"
#include "zta.h"

// Functions to manage shared memory....

typedef void * ZTA_SHARED_MEM;
#define ZTA_SHARED_MEM_P(p)         ((void *)(p))
#define ZTA_SHARED_MEM_PHYSICAL(p)  ((uint32_t)p)

// Build SPU lookup table
extern ZTA_SHARED_MEM ztahostBuildSpu(float (*func)(float,void *pparm,uint32_t parm),void *pparm,uint32_t parm);
extern ZTA_SHARED_MEM ztahostBuildSpuBundle(int numSpuImg,...);

// Allocate a shared memory block
extern ZTA_SHARED_MEM ztahostAllocSharedMem(int _size);

// Free a previously allocated shared memory block
extern void ztahostFreeSharedMem(ZTA_SHARED_MEM);


#endif
