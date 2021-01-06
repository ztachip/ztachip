#include "../../../software/target/base/ztam.h"

void mycallback(int parm1) {
   ztamMsgWriteInt(0x2);
   ztamMsgWriteInt(parm1);
   ztamMsgWriteInt(5);
}

// Load PCORE program and constant memory

void load_pcore(int c_p,int c_len,int pcore_p,int pcore_len) {
   ztamTaskSetCurr(1);
   c_len=((c_len+3)>>2)<<2;
   > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   ztamTaskSetCurr(0);
   > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   > PROG((pcore_len/2)) <= (int)MEM(pcore_p,(pcore_len/2)*4)[:];
   > FLUSH;
}

void main() {
   int i;
   int len;
   int pp;
   int c_p;
   int cLen;
   int pcore_p;
   int pcoreLen;
   int cmd[8];

   ztamInit();
 
   // Wait for boot loader command
   // Load overlay information
   cLen=ztamMsgqReadInt(0);
   c_p=ztamMsgqReadInt(0);
   pcoreLen=ztamMsgqReadInt(0);
   pcore_p=ztamMsgqReadInt(0);

   // Load PCORE program...
   load_pcore(c_p,cLen,pcore_p,pcoreLen);

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
