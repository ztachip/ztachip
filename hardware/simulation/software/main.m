#include "../../../software/target/base/ztam.h"

static int M_c[kMcoreMaxOverlay];
static int M_cLen[kMcoreMaxOverlay];
static int M_overlay=0;
static int M_lastOverlay=-1;
static int M_overlayReady=0;
static int M_pcore[kMcoreMaxOverlay];
static int M_pcoreSize[kMcoreMaxOverlay];

int cmd[8];

void mycallback(int parm1) {
#ifdef ZTA_DEBUG
   ztamLogPrint(1000000);
#endif
   ztamMsgWriteInt(0x2);
   ztamMsgWriteInt(parm1);
   ztamMsgWriteInt(5);
}

void load_pcore(int c_p,int c_len,int pcore_p,int pcoreLen) {
   ztamTaskSetCurr(1);
   c_len=((c_len+3)>>2)<<2;
   > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   ztamTaskSetCurr(0);
   > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   > PROG((pcoreLen/2)) <= (int)MEM(pcore_p,(pcoreLen/2)*4)[:];
   > FLUSH;
}

void main() {
   int i;
   int len;
   int pp;
   int v;

   ztamInit();
 
   // Wait for boot loader command
   // Load overlay information
   ztamMsgqReadInt(0);
   ztamMsgqReadInt(0);
   for(i=0;i < kMcoreMaxOverlay;i++) {
      M_cLen[i]=ztamMsgqReadInt(0);
      M_c[i]=ztamMsgqReadInt(0);
   }
   for(i=0;i < kMcoreMaxOverlay;i++) {
      M_pcoreSize[i]=ztamMsgqReadInt(0);
      M_pcore[i]=ztamMsgqReadInt(0);
   }
   M_overlay=ztamMsgqReadInt(0);

   // Load PCORE program...
   load_pcore(M_c[0],M_cLen[0],M_pcore[0],M_pcoreSize[0]);

   for(;;) {
      len=ztamMsgqReadInt(0);
      for(i=0;i < len;i++) {
         cmd[i]=ztamMsgqReadInt(0);   
      }
      pp=cmd[4];
      >$0 := MEM(pp)[0:31];
      >PCORE[0][:].TEST::exe.p[0:1] <= $0;
      >EXE_LOCKSTEP(TEST::exe,NUM_PCORE);
      >MEM(pp)[0:31] <= PCORE[0][:].TEST::exe.p[0:1];
      >CALLBACK(mycallback,cmd[0]);
   }
}
