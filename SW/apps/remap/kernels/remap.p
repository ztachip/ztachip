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
#include "remap.h"
 
_share int16 remap::input[REMAP_INPUT_SIZE];
_share vint16 remap::map[REMAP_TILE_DX2*REMAP_TILE_DY2];
_share vint16 remap::x_fract[REMAP_TILE_DX*REMAP_TILE_DY];
_share vint16 remap::y_fract[REMAP_TILE_DX*REMAP_TILE_DY];
_share vint16 remap::tile[REMAP_TILE_DX2*REMAP_TILE_DY2];
_share vint16 remap::output[REMAP_TILE_DX*REMAP_TILE_DY]; 
 
 // Load tile with input image 
 // within region REMAP_TILE_DX2*REMAP_TILE_DY2
  
 _kernel_ void remap::load_tiles(_global int offset) {
   int idx;
   int I;
   int i;
   vint16 *p,*p2;
    
   i=tid+offset;
   p=&map[i];
   p2=&tile[i]; 
#pragma unroll
   for(I=0;I < 8;I++) {
      idx=ASN_RAW(p[I]);  
      p2[I] = input[idx];
   }
}

// Interpolate within region REMAP_TILE_DX*REMAP_TILE_DY

_kernel_ void remap::interpolate() {
   int i,j;
   vint16 v5, v6;
    
   i=tid;
   j=i+(i>>2);     
   v5 = tile[j]+ (tile[j+1] - tile[j]) * x_fract[i];
   j += REMAP_TILE_DX2;
   v6 = tile[j] + (tile[j+1] - tile[j]) * x_fract[i];
   output[i] = v5 + (v6 - v5) * y_fract[i];
}
