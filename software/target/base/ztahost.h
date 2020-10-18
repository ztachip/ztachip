//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
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

// Magic number to identified memory block

struct ZTA_MEM_HEADER {
   uint32_t vmem; // Virtual memory address
   uint32_t pmem; // Physical memory address
   uint32_t size; // Allocated size
   uint32_t pad; // Pad to make this structure multiple of VECTOR_WIDTH
};

// Functions to manage shared memory....

typedef void * ZTA_SHARED_MEM;
#define ZTA_SHARED_MEM_P(p)         ((void *)(p))
#define ZTA_SHARED_MEM_PHYSICAL(p)  ((p)?(((ZTA_MEM_HEADER *)((uint32_t)p-sizeof(ZTA_MEM_HEADER)))->pmem):0)
#define ZTA_SHARED_MEM_LEN(p)       ((p)?(((ZTA_MEM_HEADER *)((uint32_t)p-sizeof(ZTA_MEM_HEADER)))->size):0)

// Initializes the API. This should be the function to call by app

extern ZtaStatus ztahostInit(const char *ztachipFile,uint32_t baseAddr,uint32_t dmaBaseAddr,uint32_t dmaBaseSize,bool hasVideo=true);

// Return export function address

extern uint32_t ztahostGetExportFunction(const char *funcName);

// Return number of free slot in the outbox.

extern int ztahostMsgqWriteAvail(int queue);

// Push a signed 32 bit integer to the outbox

extern void ztahostMsgqWriteInt(int queue,int32_t v);

// Push a float number to the outbox

extern void ztahostMsgqWriteFloat(int queue,float v);

// Push a pointer to the outbox.
// Input parameter v is virtual address

extern void ztahostMsgqWritePointer(int queue,ZTA_SHARED_MEM v,uint32_t offset=0);

// Return number of messages available in the inbox

extern int ztahostMsgReadAvail();

// Retrieve a signed 32 bit integer from the inbox
// Block to wait if message is not yet available
// If the app doesnot want to be blocked then it should call
// ztahostMsgReadAvail first 

extern int32_t ztahostMsgReadInt();

// Retrieve a float number from the inbox
// Block to wait if message is not yet available
// If the app doesnot want to be blocked then it should call
// ztahostMsgReadAvail first 

extern float ztahostMsgReadFloat();

// Return address of the ztachip register memory map address

extern volatile void *ztahostGetRegisterMemMap();

// Return address of the SOC BRIDGE memory map

extern volatile void *ztahostGetBridgeMem();

// Setup lookup table

extern void ztahostSetLookup(int addr,int16_t val,int16_t coef);

// Build SPU lookup table
extern ZTA_SHARED_MEM ztahostBuildSpu(float (*func)(float,void *pparm,uint32_t parm),void *pparm,uint32_t parm,ZTA_SHARED_MEM _shm=0);

// Check if any data available at serial port from ztachip
void ztaSerial();

// Return current total allocation of shared memory
extern int ztahostGetTotalAllocSharedMem();

// Allocate a shared memory block
extern ZTA_SHARED_MEM ztahostAllocSharedMem(int _size);

// Free a previously allocated shared memory block
extern void ztahostFreeSharedMem(ZTA_SHARED_MEM);


#endif
