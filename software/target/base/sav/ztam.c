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
#include <stdarg.h>
#include "ztam.h"

// This file contains supporting functions for codes running on mcore

static int in_yield=0;
static bool taskStatus[2];
extern int _task_curr2;
int ztam_fifo_avail=0;

// Task entry point...

static void taskEntry(int thisFunc, void(*func)(int, int), int p1, int p2) {
   _taskYield();
   if (func)
      (*func)(p1, p2);
   taskStatus[_task_curr2] = false;
   for (;;) {
      _taskYield();
   }
}

// Perform initialization for code running on mcore

void ztamInit() {
   _task_curr2 = 0;
   taskStatus[0] = false;
   taskStatus[1] = false;
   _taskSpawn(taskEntry,0,0,0);
}

// Spawn a new task

void ztamTaskSpawn(void(*func)(uint32_t, uint32_t), uint32_t p1, uint32_t p2) {
   taskStatus[(_task_curr2+1)%2] = true;
   _taskSpawn(taskEntry, func, p1, p2);
   _taskYield();
}

// All information to launch a kernel is packed into 32 bit word

uint32_t ztamBuildKernelFunc(uint32_t _func,int num_pcore,int num_tid) {
   uint32_t func,p0,p1,dataModel;
   func=EXE_FUNC_FIELD(_func); // First instruction address to kernel functions
   p0=EXE_P0_FIELD(_func); // Firt parameter
   p1=EXE_P1_FIELD(_func); // Second parameter
   dataModel=EXE_MODEL_FIELD(_func); // Kernel memory model (large/small)
   return DP_EXE_CMD(1,func,num_pcore-1,_task_curr2,p0,p1,num_tid-1,dataModel);
}

// Return current task

int ztamTaskGetCurr() {
   return _task_curr2;
}

// Return task status

bool ztamTaskStatus(int pid) {
   return taskStatus[pid];
}

// Retrieve an integer from message queue with host CPU

int32_t ztamMsgReadInt() {
   while((ZTAM_GREG(0,REG_MSGQ_READ_AVAIL,0))==0) {
      ztamYield();
   }
   return (int32_t)(ZTAM_GREG(0,REG_MSGQ_READ,0));
}


// Retrieve a pointer from message queue with host CPU

uint32_t ztamMsgReadPointer() {
   while((ZTAM_GREG(0,REG_MSGQ_READ_AVAIL,0))==0) {
      ztamYield();
   }
   return (uint32_t)(ZTAM_GREG(0,REG_MSGQ_READ,0));
}

// Write an integer to the message queue with host CPU

void ztamMsgWriteInt(int32_t v) {
   while((ZTAM_GREG(0,REG_MSGQ_WRITE_AVAIL,0))==0) {
      ztamYield();
   }
   ZTAM_GREG(0,REG_MSGQ_WRITE,0)=v;
}

// Write a pointer to the message queue with host CPU

void ztamMsgWritePointer(uint32_t v) {
   while((ZTAM_GREG(0,REG_MSGQ_WRITE_AVAIL,0))==0) {
      ztamYield();
   }
   ZTAM_GREG(0,REG_MSGQ_WRITE,0)=v;
}

// Set current task

void ztamTaskSetCurr(int _vm) {
   _task_curr2 = _vm;
}

// Output a formated string to serial port FIFO.
// Serial port FIFO can then be polled from host CPU

void ztamPrintf(char *fmt,...) {
   va_list vl;
   unsigned char *p;
   int i;
   unsigned char *p2;
   int count;
   char *svar;
   int ivar;
   double fvar;

   va_start(vl,fmt);
   p=(unsigned char *)fmt;
   while(*p) {
      if(p[0]=='%' && p[1]=='s') {
         svar=va_arg(vl,char *);
         while(*svar) {
            while(ZTAM_GREG(0,REG_SERIAL_WRITE_AVAIL,0)<4);
            ZTAM_GREG(0,REG_SERIAL_WRITE,0)=(uint32_t)(*svar);
            svar++;
         }
         p += 2;
      } else if(*p=='%' && p[1]=='d') {
         ivar=va_arg(vl,int);
         while(ZTAM_GREG(0,REG_SERIAL_WRITE_AVAIL,0)<4);
         ZTAM_GREG(0,REG_SERIAL_WRITE,0)=(uint32_t)1;
         for(i=0,p2=(unsigned char *)&ivar;i < sizeof(ivar);i++,p2++) {
            while(ZTAM_GREG(0,REG_SERIAL_WRITE_AVAIL,0)<4);
            ZTAM_GREG(0,REG_SERIAL_WRITE,0)=(uint32_t)(*p2);  
         }
         p += 2;
      } else if(*p=='%' && p[1]=='f') {
         fvar=va_arg(vl,double);
         while(ZTAM_GREG(0,REG_SERIAL_WRITE_AVAIL,0)<4);
         ZTAM_GREG(0,REG_SERIAL_WRITE,0)=(uint32_t)2;
         for(i=0,p2=(unsigned char *)&fvar;i < sizeof(fvar);i++,p2++) {
            while(ZTAM_GREG(0,REG_SERIAL_WRITE_AVAIL,0)<4);
            ZTAM_GREG(0,REG_SERIAL_WRITE,0)=(uint32_t)*p2;
         }
         p += 2;
      } else {
         while(ZTAM_GREG(0,REG_SERIAL_WRITE_AVAIL,0)<4);
         ZTAM_GREG(0,REG_SERIAL_WRITE,0)=(uint32_t)*p;
         p++;
      }
   }
   va_end(vl);
}

// Flush log...

void ztamLogFlush() {
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
      ztamPrintf("[");
      ztamPrintf(str);
      ztamPrintf("] ");
   } else {
      ztamPrintf("           ");
   }
   for(i=0;i < 12;i++) {
      if((i%2)==0 && i > 0)
         ztamPrintf(" ");
      if(currStatus&(1<<i)) {
         if(!(lastStatus&(1<<i)))
            ztamPrintf("+");
         else
            ztamPrintf("|");
      } else {
         if(lastStatus&(1<<i))
            ztamPrintf("+");
         else
            ztamPrintf(" ");
      }
   }
}

// Display mcore log entries
// Log shows all bus transactions...

void ztamLogPrint(int step) {
   int i;
   bool showBanner=false;
   ZTAM_LOG_ENTRY logCmd;
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
         ztamPrintf("           XX PP SS PP SS DD\r\n");
         ztamPrintf("           01 WR WR WR WR WR\r\n");
         showBanner=true;
      }
      logParm=ZTAM_GREG(0,REG_READ_LOG_TIME,0);
      switch(logCmd.u.general.type) {
         case ZTAM_LOG_TYPE_DP_START:
            timestamp=(logParm>>12);
            timeDelta=(int)timestamp-(int)lastTime;
            if(timeDelta < 0)
               timeDelta+=0x100000;
            lastTime=timestamp;
            printStatus(lastTimeValid?timeDelta:0,logParm,lastStatus);
            lastTimeValid=true;
            lastStatus=logParm;
            ztamPrintf(" %s V%d X%d %s <= %s V%d X%d %s\r\n",
                  s_bus_id[logCmd.u.dp_start.dest],
                  logCmd.u.dp_start.dest_vector+1,
                  logCmd.u.dp_start.dest_double+1,
                  logCmd.u.dp_start.dest_scatter?"SCATTER":"",
                  s_bus_id[logCmd.u.dp_start.source],
                  logCmd.u.dp_start.source_vector+1,
                  logCmd.u.dp_start.source_double+1,
                  logCmd.u.dp_start.source_scatter?"SCATTER":"");
            break;
         case ZTAM_LOG_TYPE_PRINT:
            printStatus(-1,lastStatus,lastStatus);
            ztamPrintf(" ");
            ztamPrintf((char *)(logCmd.u.dw>>2),logParm);
            ztamPrintf("\r\n");
            break;
         case ZTAM_LOG_TYPE_STATUS:
            timestamp=(logParm>>12);
            timeDelta=(int)timestamp-(int)lastTime;
            if(timeDelta < 0)
               timeDelta+=0x100000;
            lastTime=timestamp;
            printStatus(lastTimeValid?timeDelta:0,logParm,lastStatus);
            lastTimeValid=true;
            ztamPrintf("\r\n");
            lastStatus=logParm;
         default:
            break;      
      }
   }
}

// Yield processing to another task
// Check if there is any received indication message from DP

int ztamYield(void) {
   int parm1;
   int parm2;
   int sync;
   CallbackFunc func;

   if(in_yield)
      return 0;
   in_yield=1;
   if(ZTAM_GREG(0,REG_DP_READ_INDICATION_AVAIL,0)!=0) {
      parm1=ZTAM_GREG(0,REG_DP_READ_INDICATION,0);
      parm2=ZTAM_GREG(0,REG_DP_READ_INDICATION_PARM,0);
      sync=ZTAM_GREG(0,REG_DP_READ_SYNC,0);
      func=(CallbackFunc)parm1;
      (*func)(parm2);
      if(sync != 0)
          ZTAM_GREG(0,REG_DP_RESUME,0)=1;
      in_yield=0;
      return 1;
   } else if(ZTAM_GREG(0,REG_DP_READ_INDICATION_AVAIL,1)!=0) {
      parm1=ZTAM_GREG(0,REG_DP_READ_INDICATION,1);
      parm2=ZTAM_GREG(0,REG_DP_READ_INDICATION_PARM,1);
      sync=ZTAM_GREG(0,REG_DP_READ_SYNC,1);
      func=(CallbackFunc)parm1;
      (*func)(parm2);
      if(sync != 0)
          ZTAM_GREG(0,REG_DP_RESUME,1)=1;
      in_yield=0;
      return 1;
   } else {
      in_yield=0;
      return 0;
   }
}

// Fatal error.
// Display error message and then hangs...

void ztamAssert(char *msg) {
#ifdef ZTA_DEBUG
   ztamPrintf("\r\nERROR>%s\r\n",msg);
#endif
   for(;;) {
   }
}

#ifndef ZTA_DEBUG
const char msg1[]="%s %s %s\r\n";
const char msg2[]="svect = %d dvect = %d \r\n";
const char msg3[]="%s %s %s [%d] TRANSFER START: %s(v=%d s=%d p=%d) <= %s(v=%d s=%d p=%d) \r\n";
const char msg4[]="%s %s %s [%d] TRANSFER END\r\n";
const char msg5[]="%s %s %s [%d] VM_STATUS: vm1=%d vm2=%d (FIFO=%d)\r\n";
const char msg6[]="CPU usage=%d \r\n";
#endif