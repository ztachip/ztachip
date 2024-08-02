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

#include "../../../base/zta.h"
#include "objdet.h"

vint16 objdet::score[CLASS_PER_THREAD];

vint16 objdet::result[2];

int16 objdet::curr_class;

_kernel_ void objdet::init() {
   curr_class=0;
   result[RESULT_MAX_SCORE]=0;
   result[RESULT_CLASS]=0;
}

_kernel_ void objdet::find_max() {
   int i;

   // Go over every class of every box to find 
   // the max score.
   // A box is assigned to a vector element per thread per core
   // So each clock, we find the max of NUM_PCORE*NUM_THREAD*VECTOR_WIDTH=1024

#pragma unroll
   for(i=0;i < CLASS_PER_THREAD;i++) {
      _VMASK = LT(result[RESULT_MAX_SCORE],score[i]);
      result[RESULT_MAX_SCORE]=score[i];
      result[RESULT_CLASS]=curr_class; 
      _VMASK=-1;
      curr_class=curr_class+1;
   }
}



