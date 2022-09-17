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

#include "../../../base/ztam.h"

static int last_pcore_p=0;

// Load code/memory to pcore

void ztaInitPcore(int c_p,int c_len,int pcore_p,int pcoreLen) {
   ztamInit();
   if(last_pcore_p==pcore_p)
      return;
   c_len=c_len>>1;
   pcoreLen=pcoreLen>>2;
   last_pcore_p=pcore_p;
  
   ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;
   ;ZTAM_GREG(0,5,0)=(0+(11<<3));
   c_len=((c_len+3)>>2)<<2;

   // Set pcore process1's constant memory space
   // Set pcore process1's constant memory space
   if(c_len > 0) {
      > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   }
   ZTAM_GREG(0,REG_DP_VM_TOGGLE,0)=0;

   // Set pcore process0's constant memory space.
   if(c_len > 0) {
      > PCORE[*].root.constant[0:c_len-1] <= MEM(c_p)[0:c_len-1];
   }

   // Set pcore code space
   > PROG((pcoreLen>>1)) <= (int)MEM(pcore_p,(pcoreLen>>1)<<2)[:];
   > FLUSH;
}

void ztaInitStream(int _spu,int _spuCnt) {
   if(_spu && _spuCnt > 0) {
      > SPU <= (int)MEM(_spu,_spuCnt*SPU_LOOKUP_SIZE)[:];
      > FLUSH;
   }
}
