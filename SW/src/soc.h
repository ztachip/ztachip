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

#ifndef _SOC_H_
#define _SOC_H_

#include <stdint.h>
#include "../base/types.h"

// Memory mapped of APB bus

#define APB ((volatile unsigned int *)0xC0000000)

// APB register map

#define APB_LED               0

#define APB_PB                2

#define APB_VIDEO_BUFFER      11

#define APB_VIDEO_ENABLE      9

#define APB_CAMERA_BUFFER     5

#define APB_CAMERA_ENABLE     3

#define APB_CAMERA_CURR_FRAME 4

#define APB_UART_READ         15 

#define APB_UART_WRITE        16 

#define APB_UART_READ_AVAIL   17 

#define APB_UART_WRITE_AVAIL  18 

#define APB_TIME_GET          19 


// Flush data cache with VexRiscv
// This is dependent on the Riscv implementation since flushing datacache
// is not defined in official Riscv specs

#define FLUSH_DATA_CACHE()  {asm(".word 0x500F");}

ZtaStatus DisplayInit(int w,int h);

uint8_t *DisplayGetBuffer(void);

ZtaStatus DisplayUpdateBuffer(void);

ZtaStatus CameraInit(int w,int h);

bool CameraCaptureReady();

uint8_t *CameraGetCapture(void);

void LedSetState(uint32_t ledState);

uint32_t PushButtonGetState();

uint8_t UartRead();

void UartWrite(uint8_t ch);

int UartReadAvailable();

int UartWriteAvailable();

#define TimeGet() (APB[APB_TIME_GET])

#endif
