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

// Utility functions to display log from ztachip core

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
#include "ztalog.h"

// Log type 
#define ZTA_LOG_TYPE_NONE       0
#define ZTA_LOG_TYPE_DP_START   1
#define ZTA_LOG_TYPE_PRINT      2
#define ZTA_LOG_TYPE_STATUS     3

// Log DP source/destination
#define ZTA_LOG_DP_ID_PCORE     0
#define ZTA_LOG_DP_ID_SRAM      1
#define ZTA_LOG_DP_ID_DDR       2

// Log DP scatter mode
#define ZTA_LOG_SCATTER_NONE    0
#define ZTA_LOG_SCATTER_VECTOR  1
#define ZTA_LOG_SCATTER_THREAD  2

// Log DP vector width
#define ZTA_LOG_VECTOR_X1       0
#define ZTA_LOG_VECTOR_X2       1
#define ZTA_LOG_VECTOR_X4       3
#define ZTA_LOG_VECTOR_X8       7
#define ZTA_LOG_VECTOR_X16      15

typedef struct
{
   union {
      struct {
         unsigned int type:2;
         unsigned int source:2;
         unsigned int source_vector:4;
         unsigned int source_scatter:2;
         unsigned int source_double:1;
         unsigned int dest:2;
         unsigned int dest_vector:4;
         unsigned int dest_scatter:2;
         unsigned int dest_double:1;
         unsigned int vm:1;
         unsigned int pad:11;
      } dp_start;
      struct {
         unsigned int type:2;
         unsigned int vm1:1;
         unsigned int vm2:1;
         unsigned int register0_write:1;
         unsigned int register0_read:1;
         unsigned int sram0_write:1;
         unsigned int sram0_read:1;
         unsigned int register1_write:1;
         unsigned int register1_read:1;
         unsigned int sram1_write:1;
         unsigned int sram1_read:1;
         unsigned int ddr_write:1;
         unsigned int ddr_read:1;
         unsigned int fpu1:1;
         unsigned int fpu2:1;
         unsigned int empty:1;
      } vm_status;
      struct {
         unsigned int type:2;
         unsigned int pad:30;
      } general;
      uint32_t dw;
   } u;
} ZTA_LOG_ENTRY;

#define LOG_TIMESTAMP 17 // Must be the same as ztachip_pkt.vhd/log_timestamp_c

#define LOG_STATUS_MAX 15 //Must be the same as ztachip_pkt.vhd/log_status_max_c 

static bool logEnable=false;

void ztaLogEnable() {
   if(logEnable) 
      return;
   logEnable=true;
   ZTAM_GREG(0,REG_DP_RUN,0)=DP_OPCODE_LOG_ON+(DP_CONDITION_ALL_FLUSH<<3);
}

void ztaLogDisable() {
   if(!logEnable)
      return;
   logEnable=false;
   ZTAM_GREG(0,REG_DP_RUN,0)=DP_OPCODE_LOG_OFF+(DP_CONDITION_ALL_FLUSH<<3);
}

// Flush log...

void ztaLogFlush() {
   while((ZTAM_GREG(0,REG_READ_LOG,0)) != 0) {
      ZTAM_GREG(0,REG_READ_LOG_TIME,0);
   }
}

// Show processor/bus status

static void printStatus(int timeDelta,uint32_t currStatus,uint32_t lastStatus) {
   int i;
   char str[10];
   if(timeDelta >= 0) {
      for(i=7;i >= 0;i--) {
         str[i]='0'+(timeDelta%10);
         timeDelta=timeDelta/10;
         if(timeDelta==0) {
            i--;
            break;
         }
      }
      for(;i >= 0;i--)
         str[i]=' ';
      str[8]=0;
      printf("[");
      printf(str);
      printf("] ");
   } else {
      printf("           ");
   }
   for(i=0;i < LOG_STATUS_MAX;i++) {
      if((i%2)==0 && i > 0)
         printf(" ");
      if(currStatus&(1<<i)) {
         if(!(lastStatus&(1<<i)))
            printf("+");
         else
            printf("|");
      } else {
         if(lastStatus&(1<<i))
            printf("+");
         else
            printf(" ");
      }
   }
}

// Display mcore log entries
// Log shows all bus transactions...

void ztaLogPrint() {
   int i;
   bool showBanner=false;
   ZTA_LOG_ENTRY logCmd;
   uint32_t logParm;
   uint32_t lastStatus=0;
   uint32_t lastTime=0;
   bool lastTimeValid=false;
   uint32_t timestamp;
   uint32_t timeDelta;
   static char *s_bus_id[3]={"PCORE","SRAM","DDR"};

   for(;;) {
      logCmd.u.dw=ZTAM_GREG(0,REG_READ_LOG,0);
      if(logCmd.u.dw==0)
         break;
      if(!showBanner) {
         printf("           XX PP SS PP SS DD FF E\r\n");
         printf("           01 WR WR WR WR WR 01 0\r\n");
         showBanner=true;
      }
      logParm=ZTAM_GREG(0,REG_READ_LOG_TIME,0);
      switch(logCmd.u.general.type) {
         case ZTA_LOG_TYPE_DP_START:
            timestamp=(logParm>>LOG_STATUS_MAX);
            timeDelta=(int)timestamp-(int)lastTime;
            if(timeDelta < 0)
               timeDelta+=0x100000;
            lastTime=timestamp;
            printStatus(lastTimeValid?timeDelta:0,logParm,lastStatus);
            lastTimeValid=true;
            lastStatus=logParm;
            printf(" %s(%d) V%d X%d %s <= %s(%d) V%d X%d %s\r\n",
                  s_bus_id[logCmd.u.dp_start.dest],
                  logCmd.u.dp_start.vm,
                  logCmd.u.dp_start.dest_vector+1,
                  logCmd.u.dp_start.dest_double+1,
                  logCmd.u.dp_start.dest_scatter?"SCATTER":"",
                  s_bus_id[logCmd.u.dp_start.source],
                  logCmd.u.dp_start.vm,
                  logCmd.u.dp_start.source_vector+1,
                  logCmd.u.dp_start.source_double+1,
                  logCmd.u.dp_start.source_scatter?"SCATTER":"");
            break;
         case ZTA_LOG_TYPE_PRINT:
            printStatus(-1,lastStatus,lastStatus);
            printf(" ");
            printf((char *)(logCmd.u.dw>>2),logParm);
            printf("\r\n");
            break;
         case ZTA_LOG_TYPE_STATUS:
            timestamp=(logParm>>LOG_STATUS_MAX);
            timeDelta=(int)timestamp-(int)lastTime;
            if(timeDelta < 0)
               timeDelta+=0x100000;
            lastTime=timestamp;
            printStatus(lastTimeValid?timeDelta:0,logParm,lastStatus);
            lastTimeValid=true;
            printf("\r\n");
            lastStatus=logParm;
         default:
            break;      
      }
   }
}
