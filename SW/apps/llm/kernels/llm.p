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
#include "llm_p.h"

_share vint16 llm::x[2];
vint16 llm::w[LLM_GS];
vint32 llm::acc;
vint16 llm::y;


// Start dotproduct of weight(in Q4) with activation (in Q8)
// We do this per block of 32 weights and 32 activation
// Reset accumulator=0

_kernel_ void llm::matmul_begin() {
   acc = 0;
}

// Dot product between weights (in Q4) with activation (in Q8)
// We do this in a block of 32 weights and 32 activations
// 2 4-bit weights are packed into 1 integer


_kernel_ void llm::matmul() {
   int i;

   acc += N0(w[0])*x[0][0];
   acc += N1(w[0])*x[0][1];
   acc += N2(w[0])*x[0][2];
   acc += N3(w[0])*x[0][3];
   acc += N0(w[1])*x[0][4];
   acc += N1(w[1])*x[0][5];
   acc += N2(w[1])*x[0][6];
   acc += N3(w[1])*x[0][7]; 
   acc += N0(w[2])*x[1][0];
   acc += N1(w[2])*x[1][1];
   acc += N2(w[2])*x[1][2];
   acc += N3(w[2])*x[1][3];
   acc += N0(w[3])*x[1][4];
   acc += N1(w[3])*x[1][5];
   acc += N2(w[3])*x[1][6];
   acc += N3(w[3])*x[1][7]; 
}

// Dot product is done
// Convert integer accumulator result to bfloat format

_kernel_ void llm::matmul_end() { 
   y = CONV_BFLOAT(acc); 
}

_share vint16 llm_q8::x[2];
vint16 llm_q8::w[LLM_GS];
vint32 llm_q8::acc;
vint16 llm_q8::y;

// Start dotproduct of weight(in Q8) with activation (in Q8)
// We do this per block of 32 weights and 32 activation
// Reset accumulator=0

_kernel_ void llm_q8::matmul_begin() { 
   acc = 0;
}

// Dot product between weights (in Q8) with activation (in Q8)
// We do this in a block of 32 weights and 32 activations

_kernel_ void llm_q8::matmul() { 
   acc += B0(w[0])*x[0][0];
   acc += B1(w[0])*x[0][1];
   acc += B0(w[1])*x[0][2];
   acc += B1(w[1])*x[0][3];
   acc += B0(w[2])*x[0][4];
   acc += B1(w[2])*x[0][5];
   acc += B0(w[3])*x[0][6];
   acc += B1(w[3])*x[0][7]; 
   acc += B0(w[4])*x[1][0];
   acc += B1(w[4])*x[1][1];
   acc += B0(w[5])*x[1][2];
   acc += B1(w[5])*x[1][3];
   acc += B0(w[6])*x[1][4];
   acc += B1(w[6])*x[1][5];
   acc += B0(w[7])*x[1][6];
   acc += B1(w[7])*x[1][7]; 
}

// Dot product between weights and activation is done
// Convert integer accumulator result to bfloat format

_kernel_ void llm_q8::matmul_end() { 
   y = CONV_BFLOAT(acc);
}

vint16 llm_dotproduct::x[12];

_kernel_ void llm_dotproduct::dummy() {
    x[0]=x[0];
}
