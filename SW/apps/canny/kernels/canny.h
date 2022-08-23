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

#ifndef _CANNY_H_
#define _CANNY_H_

#define TILE_DX_DIM     4  // Tile dimension 
#define TILE_DY_DIM     4  // Tile dimension 
#define TILE_MAX_PAD    1  // Overlap region between tiles
#define TILE_MAX_KZ     3  // (TILE_MAX_PAD*2+1)

#define CANNY_MAX_INBUF    36 // (TILE_DX_DIM+2*TILE_MAX_PAD)*(TILE_DY_DIM+2*TILE_MAX_PAD)
#define CANNY_MAX_OUTBUF   16  // TILE_DX_DIM*TILE_DY_DIM
#define CANNY_MAX_KERNEL   9  // (TILE_MAX_PAD*2+1)**2

// Gradient direction

#define DIRECTION_EW    0
#define DIRECTION_NS    1
#define DIRECTION_NE_SW 2
#define DIRECTION_NW_SE 3

#endif
