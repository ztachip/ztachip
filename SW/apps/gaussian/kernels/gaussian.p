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
#include "gaussian.h"

// Perform gaussian blurring algorithm
// Refer to https://en.wikipedia.org/wiki/Gaussian_blur

_NT16_ class iconv;

_share float8 iconv::inbuf[ICONV_MAX_INBUF];
_share float8 iconv::outbuf[ICONV_MAX_OUTBUF];
_share float iconv::k[TILE_MAX_KZ][TILE_MAX_KZ];
float8 *iconv::in_p;
float8 *iconv::out_p;
int iconv::pad;
double8 iconv::_A;

_kernel_ void iconv::init(int _ksz) {
   int i,j;
   i=tid;
   j=(i&7)+(i>>3)*(TILE_DX_DIM+_ksz-1);
   in_p=&inbuf[j];
   out_p=&outbuf[i];
   pad = (TILE_DX_DIM-1);
}

// Do 7x7 convolution

_kernel_ void iconv::exe_7x7() {
   int x,y,i;
   float8 *p2;

   for(i=0;i < 2;i++) {
      p2=in_p+i*((6+TILE_DX_DIM)<<1);
      _A=0;
#pragma unroll
      for(y=0;y < 7;y++) {
#pragma unroll
         for(x=0;x < 7;x++) {
            _A += p2[0]*k[y][x];
            p2++;
         }
         p2 += pad;
      }
      _A=(_A>>9);
      _A=_A+1;
      p2=out_p+(TILE_DX_DIM<<1)*i;
      p2[0]=(_A>>1);
   }
}
