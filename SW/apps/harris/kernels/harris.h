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

#ifndef _HARRIS_H_
#define _HARRIS_H_
#ifdef __cplusplus
extern "C" {
#endif

extern void kernel_harris_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _x_gradient,
   unsigned int _y_gradient,
   unsigned int _score,
   unsigned int _output,
   int _w,
   int _h,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_w,
   int _dst_h);

#define TILE_DX_DIM   4  // Tile dimension 
#define TILE_DY_DIM   4  // Tile dimension 
#define TILE_MAX_PAD  1  // Overlap region between tiles
#define TILE_MAX_KZ   3  // (TILE_MAX_PAD*2+1)

#define HARRIS_MAX_INBUF     36 // (TILE_DX_DIM+2*TILE_MAX_PAD)*(TILE_DY_DIM+2*TILE_MAX_PAD)
#define HARRIS_MAX_OUTBUF    16  // TILE_DX_DIM*TILE_DY_DIM
#define HARRIS_MAX_KERNEL    9  // (TILE_MAX_PAD*2+1)**2

#ifdef __cplusplus
}
#endif
#endif
