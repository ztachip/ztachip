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

typedef void * ZTA_SHARED_MEM;

#define ZTA_SHARED_MEM_VIRTUAL(p)   ((void *)(p))

#define ZTA_SHARED_MEM_PHYSICAL(p)  ((uint32_t)p)

// Allocate a shared memory block

extern ZTA_SHARED_MEM ztaAllocSharedMem(int _size);

// Free a previously allocated shared memory block

extern void ztaFreeSharedMem(ZTA_SHARED_MEM);

typedef int16_t (*SPU_FUNC)(int16_t,void *pparm,uint32_t parm,uint32_t parm2);

// Build SPU lookup table

extern ZTA_SHARED_MEM ztaBuildSpuBundle(int numSpuImg,...);



#endif
