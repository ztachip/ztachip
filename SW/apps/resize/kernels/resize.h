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

#ifndef _MYAPP_H_
#define _MYAPP_H_
#ifdef __cplusplus
extern "C" {
#endif

extern void kernel_resize_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _temp,
   unsigned int _filter_0,
   unsigned int _filter_1,
   unsigned int _filteri_0,
   unsigned int _filteri_1,
   int _filterLen_0,
   int _filterLen_1,
   unsigned int _spu,
   int _nchannel,
   int _src_w,
   int _src_h,
   int _dst_w,
   int _dst_h,
   int _scale_x,
   int _scale_y
);


// Image resize

#define TILE_DIM      8  // Tile dimension 

#define TILE_PAD      3  // Overlap region between tiles

#define RESIZE_MAX_INBUF     121 // (TILE_IN_DIM+TILE_PAD)**2

#define RESIZE_MAX_OUTBUF    64  // TILE_OUT_DIM**2

#define RESIZE_BOX_MAX_DOWNSCALE  4

#define BOX_RESIZE_MAX_INBUF     64 

#define BOX_RESIZE_MAX_OUTBUF    16

#define BOX_RESIZE_MAX_FILTER    8

#define BOX_RESIZE_SCALE 8

#ifdef __cplusplus
}
#endif
#endif
