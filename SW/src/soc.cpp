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
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "soc.h"
#include "../base/zta.h"
#include "../base/util.h"

#define WEBCAM_WIDTH        640

#define WEBCAM_HEIGHT       480

#define NUM_CAMERA_CAPTURE  8

#define NUM_VIDEO_FRAME     4

#define BAR_LED ((volatile unsigned int *)0xf4000000)

#define BAR_PB  ((volatile unsigned int *)0xf4000008)

static void *buffer_vga[NUM_VIDEO_FRAME];

static void *buffer_camera[NUM_CAMERA_CAPTURE];

static int curr_video=0;

//----------------------------
// Initialize VGA display driver
// The driver configures the Xilinx's VDMA IP
//-----------------------------

ZtaStatus DisplayInit(int w,int h) {
   int r;
   static bool init=false;
   if(init)
      return ZtaStatusOk;
   if(w!=WEBCAM_WIDTH || h!=WEBCAM_HEIGHT)
      return ZtaStatusFail;
   // Configure VGA display output stream
   *((volatile unsigned int *)(0xF1000000+0)) = (*((unsigned int *)(0xF1000000+0)) & 0xfffffffc) | 1;
   for(r=0;r < NUM_VIDEO_FRAME;r++) {
      buffer_vga[r]=malloc(WEBCAM_WIDTH*3*(WEBCAM_HEIGHT+2));
      *((volatile unsigned int *)(0xF1000000+0x5C+r*4))=(unsigned int)buffer_vga[r];
   }
   *((volatile unsigned int *)(0xF1000000+0x58))=WEBCAM_WIDTH*3;
   *((volatile unsigned int *)(0xF1000000+0x54))=WEBCAM_WIDTH*3;
   *((volatile unsigned int *)(0xF1000000+0x50))=WEBCAM_HEIGHT;
   init=true;
   return ZtaStatusOk;
}

//---------------------------------
// Get display buffer so that application can work with for next screen
// update
//---------------------------------

uint8_t *DisplayGetBuffer() {
   return (uint8_t *)buffer_vga[curr_video];
}

//---------------------------------
// Make the current working display buffer returned from DisplayGetBuffer()
// to be the active screen display buffer
//-----------------------------------

ZtaStatus DisplayUpdateBuffer() {
   *((volatile unsigned int *)(0xF1000000+0x28))=curr_video;
   curr_video++;
   if(curr_video >= NUM_VIDEO_FRAME)
      curr_video=0;
   return ZtaStatusOk;
}

//------------------------------------
// Initialize the camera driver
// The driver configures the Xilinx's VDMA IP core
//------------------------------------

ZtaStatus CameraInit(int w,int h) {
   int r;
   static bool init=false;
   if(init)
      return ZtaStatusOk;
   if(w!=WEBCAM_WIDTH || h!=WEBCAM_HEIGHT)
      return ZtaStatusFail;
   // Configure camera input stream
   *((volatile unsigned int *)(0xF1000000+0x30)) = *((unsigned int *)(0xF1000000+0x30)) | 3;
   for(r=0;r < NUM_CAMERA_CAPTURE;r++) {
      buffer_camera[r]=malloc(WEBCAM_WIDTH*3*(WEBCAM_HEIGHT+2));
      *((volatile unsigned int *)(0xF1000000+0xAC+r*4))=(unsigned int)buffer_camera[r];
   }
   *((volatile unsigned int *)(0xF1000000+0xA8))=WEBCAM_WIDTH*3;
   *((volatile unsigned int *)(0xF1000000+0xA4))=WEBCAM_WIDTH*3;
   *((volatile unsigned int *)(0xF1000000+0xA0))=WEBCAM_HEIGHT;
   init=true;
   return ZtaStatusOk;
}

//---------------------------------------
// Get latest camera capture if available
//---------------------------------------

uint8_t *CameraGetCapture() {
   static int last_read=0;
   int next_read,curr_read;
   unsigned int vv;

   vv=*((volatile unsigned int *)(0xF1000000+0x34));
   if(vv & 0x0000d000)
      *((volatile unsigned int *)(0xF1000000+0x34))=0x0000d000;
   vv=*((volatile unsigned int *)(0xF1000000+0x28));
   next_read=(vv>>24)&0x1f;
   if(next_read != last_read) {
      last_read=next_read;
      curr_read=(last_read==0)?(NUM_CAMERA_CAPTURE-1):last_read-1;
      return (uint8_t *)buffer_camera[curr_read];
   }
   else
      return 0;
}

//----------------------------------------
// Set LED state (on/off)
//----------------------------------------

void LedSetState(uint32_t ledState) {
   BAR_LED[0]=ledState;
}

//-----------------------------------------
// Get push button current state
//-----------------------------------------

uint32_t PushButtonGetState() {
   return BAR_PB[0];
}


