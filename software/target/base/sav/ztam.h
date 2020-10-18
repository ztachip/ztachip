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
#ifndef _ZTAM_H_
#define _ZTAM_H_

#include "zta.h"
#include <stdint.h>

// Maximum size for ztam variable

#define MAX_VAR_SIZE  64

// Round up to multiple of b

#define ROUND(a,b)  ((((a)+(b)-1)/(b))*(b))

// Log type 
#define ZTAM_LOG_TYPE_NONE       0
#define ZTAM_LOG_TYPE_DP_START   1
#define ZTAM_LOG_TYPE_PRINT      2
#define ZTAM_LOG_TYPE_STATUS     3

// Log DP source/destination
#define ZTAM_LOG_DP_ID_PCORE     0
#define ZTAM_LOG_DP_ID_SRAM      1
#define ZTAM_LOG_DP_ID_DDR       2

// Log DP scatter mode
#define ZTAM_LOG_SCATTER_NONE    0
#define ZTAM_LOG_SCATTER_VECTOR  1
#define ZTAM_LOG_SCATTER_THREAD  2

// Log DP vector width
#define ZTAM_LOG_VECTOR_X1       0
#define ZTAM_LOG_VECTOR_X2       1
#define ZTAM_LOG_VECTOR_X4       3
#define ZTAM_LOG_VECTOR_X8       7

// Log entry definition...
// Log contains information about bus/processor activities

typedef struct
{
   union {
      struct {
         unsigned int pad:8;
         unsigned int fifo:6;
         unsigned int dest_double:1; 
         unsigned int dest_scatter:2;
         unsigned int dest_vector:3;
         unsigned int dest:2;
         unsigned int source_double:1;
         unsigned int source_scatter:2;
         unsigned int source_vector:3;
         unsigned int source:2;
         unsigned int type:2;
      } dp_start;
      struct {
         unsigned int ddr_read:1;
         unsigned int ddr_write_1;
         unsigned int sram_read:1;
         unsigned int sram_write_1;
         unsigned int register_read:1;
         unsigned int register_write_1;
         unsigned int vm2:1;
         unsigned int vm1:1;
         unsigned int type:2;
      } vm_status;
      struct {
         unsigned int pad:30;
         unsigned int type:2;
      } general;
      uint32_t dw;
   } u;
} ZTAM_LOG_ENTRY;

extern uint8_t *_M;
extern int _task_curr;
extern int ztam_fifo_avail;

/* Callback function definition */

typedef void (*CallbackFunc)(uint32_t);
typedef int bool;

#define true    1
#define false   0

/* API functions */ 

/* Task function API */
void ztamTaskInit();
void ztamTaskSpawn(void(*func)(uint32_t, uint32_t), uint32_t p1, uint32_t p2);
int ztamTaskGetCurr();
void ztamTaskSetCurr(int _vm);
bool ztamTaskStatus(int pid);
uint32_t ztamBuildKernelFunc(uint32_t _func,int num_pcore,int num_tid);

#define ztamTaskYield _taskYield

/* ztamSetVM: Set current Virtual machine */
extern void ztamSetVM(int vm);
/* ztamMsgReadInt: Read an integer sent from host */
extern int32_t ztamMsgReadInt(void);
/* ztamMsgReadFloat: Read a float number sent from host */ 
extern float ztamMsgReadFloat(void);
/* ztamMsgReadPointer: Read a pointer sent from host */
extern uint32_t ztamMsgReadPointer();
/* ztamMsgWriteInt: Send an integer to host */
extern void ztamMsgWriteInt(int32_t v);
/* ztamMsgWriteFloat: Send a float number to host */
extern void ztamMsgWriteFloat(float v);
/* ztamMsgWritePointer: Send an pointer to host */
extern void ztamMsgWritePointer(uint32_t v);
/* ztamYield: Check for any callback pending to be executed */
extern int ztamYield(void);
/* ztamPuts: Display a string */
extern void ztamPrintf(char *fmt,...);
/* Error */
void ztamAssert(char *msg);
/* Read and display MCORE log */
void ztamLogPrint(int step);

//#ifndef _task_curr2
#ifndef DEFINE_TASK_CURR2
#define DEFINE_TASK_CURR2
register int _task_curr2 asm ("$26");
#endif
//#endif

#endif
