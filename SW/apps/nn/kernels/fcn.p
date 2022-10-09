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
#include "fcn.h"

//---  Process fully-connected layer (innerproduct)

_share float inner_product::bot[IP_CHUNK_SIZE];
float8 inner_product::coef[IP_CHUNK_SIZE];
float8 inner_product::top;
int inner_product::out_scale;
double8 inner_product::_A;
float8 inner_product::biasHi;
float8 inner_product::biasLo;

_kernel_ void inner_product::init(int _out_scale) {
   out_scale=_out_scale;
}

_kernel_ void inner_product::start() {
   _A = biasLo;
   _A += biasHi*1024;
}

_kernel_ void inner_product::exe() {
   int i;
#pragma unroll
   for(i=0;i < IP_CHUNK_SIZE;i++) {
      _A += bot[i]*coef[i];
   }
}

// Activation

_kernel_ void inner_product::activate_none() {
   top = _A >> out_scale;
}

// ---- Pooling layer...

float8 max_pool::bot[POOL_BOT_SIZE];
double8 max_pool::_A;
int max_pool::out_scale;
float8 max_pool::top;

_kernel_ void max_pool::init(int _out_scale) {
   out_scale=_out_scale;
   _A=0;
}

// Do pooling averate.
// Since pcore cannot do division, just do addition here
// Divide for averaging is done by stream processor later
 
_kernel_ void max_pool::exe() {
   float8 *p;
   int i;
   p=bot;
#pragma unroll
   for(i=0;i < POOL_BOT_SIZE;i++) {
      _A += p[0];
      p++;
   }
}

_kernel_ void max_pool::finish() {
   top = _A >> out_scale;
   _A = 0;
}

// --- Do concatenation layer.

_share float concatenate::buf[CONCATENATE_BUFSZ];

// No pcore code required for concatenation layer
// Concatenation layer is processed by mcore and stream processor only

_kernel_ void concatenate::dummy(float _dummy) {
   buf[0]=_dummy;
}
