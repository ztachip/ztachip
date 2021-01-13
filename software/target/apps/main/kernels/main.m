#include "../../../base/ztam.h"

// This is the main module.
// This module accepts requests from applications and call the corresponding
// modules to process the requests.
// Perform mcore code overlay swap. 
// Load pcore code required by an application service request.

static int M_c[kMcoreMaxOverlay];
static int M_cLen[kMcoreMaxOverlay];
static int M_overlay[kMcoreMaxOverlay];
static int M_overlayLen[kMcoreMaxOverlay];
static bool M_overlayReady=false;
static int M_pcore[kMcoreMaxOverlay];
static int M_pcoreSize[kMcoreMaxOverlay];
static int M_lastOverlay=-1;

// Dummy functions defined in link file to identify end of each code overlay sections.

extern void zta_ox_begin(),zta_o0_end(),zta_o1_end(),zta_o2_end(),zta_o3_end();
extern void zta_o4_end(),zta_o5_end(),zta_o6_end(),zta_o7_end(),zta_o8_end();
extern void zta_o9_end(),zta_o10_end(),zta_o11_end(),zta_o12_end(),zta_o13_end();
extern void zta_o14_end(),zta_o15_end();

typedef void (*func_t)(int);

uint32_t overlay[kMcoreMaxOverlay]={
   (uint32_t)zta_o0_end,
   (uint32_t)zta_o1_end,
   (uint32_t)zta_o2_end,
   (uint32_t)zta_o3_end,
   (uint32_t)zta_o4_end,
   (uint32_t)zta_o5_end,
   (uint32_t)zta_o6_end,
   (uint32_t)zta_o7_end,
   (uint32_t)zta_o8_end,
   (uint32_t)zta_o9_end,
   (uint32_t)zta_o10_end,
   (uint32_t)zta_o11_end,
   (uint32_t)zta_o12_end,
   (uint32_t)zta_o13_end,
   (uint32_t)zta_o14_end,
   (uint32_t)zta_o15_end,   
};

// Callback to indicate transfer of mcore code from DDR has been completed

static void ovReadyCallback(int parm) {
   M_overlayReady=true;
}

// Transfer of pcore code from DDR.
// pcores must be idle at this time...

static void loadPCORE(int c_p,int c_len,int pcore_p,int pcoreLen) {
   >FLUSH; // Make sure all previous activities have ended...
   ztamTaskSetCurr(1);
   c_len=((c_len+3)>>2)<<2;

   // Set pcore process1's constant memory space
   if(c_len > 0) {
      > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   }
   ztamTaskSetCurr(0);

   // Set pcore process0's constant memory space.
   if(c_len > 0) {
      > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   }

   // Set pcore code space
   > PROG((pcoreLen/2)) <= (int)MEM(pcore_p,(pcoreLen/2)*4)[:];
   > FLUSH;
}

// Load mcore code memory's overlay section with the right page
 
static void loadOverlay(int which)
{
   int i,begin,end,pp,addr,count;

   if(M_lastOverlay==which) {
      // Code overlay already the right page
      return;
   }
   
   // Load pcode code...
   
   loadPCORE(M_c[which+1],M_cLen[which+1],M_pcore[which+1],M_pcoreSize[which+1]);
   ZTAM_GREG(0,REG_SWDL_COMPLETE_CLEAR,0)=0;
   
   // Start transfer of MCORE code from DDR

   M_overlayReady=false;
   begin=(int)zta_ox_begin;

   // scratch address outside its range will go to mcore code space instead

   addr=((1<<(SRAM_DEPTH+1))+(begin-kMcoreCodeSpaceAddr));
   count=M_overlayLen[which]/2;
   pp=M_overlay[which];
   >SCRATCH(addr,count,2)[:][:] <<= MEM(pp)[0:(2*count-1)];
   >CALLBACK_PRIO(ovReadyCallback,0);
   
   // Wait for transfer to be completed...

   while(!M_overlayReady)
      ztamYield();
   
   // Make sure all mcore code has been programmed

   while((ZTAM_GREG(0,REG_SWDL_COMPLETE_READ,0))!=count);
   M_lastOverlay=which;
}

// Call back to send response back to application

void mycallback(int parm) {
//#ifdef ZTA_DEBUG
//   ztamLogPrint(1000000);
//#endif
   ztamMsgWriteInt(2);
   ztamMsgWriteInt(parm);
   ztamMsgWriteInt(0);
}

// Genesis...

void main() {
   uint32_t cmd;
   int pp;
   int i,j,len;
   int page;
   uint32_t section;
   func_t func;
   int queue;
   uint32_t resp;

   // Always start with this...

   ztamInit();

   // Get some startup information such as pcore/mcore code
    
   ztamMsgqReadInt(0); // Not used
   ztamMsgqReadInt(0); // Not used

   // Get PCORE's constant memory for each overlay

   for(i=0;i < kMcoreMaxOverlay;i++) {
      M_cLen[i]=ztamMsgqReadInt(0);
      M_c[i]=ztamMsgqReadInt(0);
   }

   // Get PCORE's code memory for each overlay

   for(i=0;i < kMcoreMaxOverlay;i++) {
      M_pcoreSize[i]=ztamMsgqReadInt(0);
      M_pcore[i]=ztamMsgqReadInt(0);
   }

   // Calculate mcore's overlay code DDR address for each overlay

   section=ztamMsgqReadPointer(0);
   for(i=0;i < kMcoreMaxOverlay;i++) {
      M_overlayLen[i] = overlay[i]-kMcoreCodeSpaceAddr;
      M_overlay[i] = section;
      section += M_overlayLen[i];
   }

   // Waiting for incoming request from application
   queue=0;
   for(;;) {
      for(;;) {
         if(ztamMsgqReadAvail(0)>0) {
            queue=0;
            break;
         } else if(ztamMsgqReadAvail(1)>0) {
            queue=1;
            break;
         }
         ztamYield();
      }
      cmd=ztamMsgqReadInt(queue);
      resp=ztamMsgqReadInt(queue);
      func=(func_t)(cmd & 0xFFFFFF);
      page=cmd>>24;
      if(page>0)
         loadOverlay(page-1);
      (*func)(queue);
      >CALLBACK(mycallback,resp);
    }
}


