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
#include "resize.h"

// Image resize using bicubic interpolation

_share vint16 resize::inbuf[RESIZE_MAX_INBUF];
_share vint16 resize::outbuf[RESIZE_MAX_OUTBUF];
int resize::x;
int resize::y;
vint16 *resize::p_in;
vint16 *resize::p_out;
_share int16 resize::fract0[TILE_DIM];
_share int16 resize::fract1[TILE_DIM];
_share int16 resize::fract2[TILE_DIM];
vint32 resize::_A;
vint32 resize::_B;
_share int16 resize::pixel[8];

// Assigned pixel to be processed by each thread
// _coord is encoded [AAAAAA][YYYY][XXXX]

_kernel_ void resize::init(int _pixel,int _pixel2) {
   int i;
   x=(_pixel)&7;
   y=(_pixel>>3)&7;
   i=y*(TILE_DIM+TILE_PAD)+x;
   p_in=&inbuf[i];

   x=(_pixel2)&7; // x coordinate of output pixel within the tile
   y=(_pixel2>>3)&7; // y coordinate of output pixel within the tile
   i=y*TILE_DIM+x; // Position to output pixel
   p_out=&outbuf[i]; // Pointer to output pixel
}

// Do interpolation...

#define HERMITE(X,OUT,IN) { _B=-IN[0]; \
                            _B=_B+3*IN[1]; \
                            _B=_B-3*IN[2]; \
                            OUT=_B+IN[3]; \
                            _A=OUT*fract2[X]; \
                            _B=2*IN[0]; \
                            _B=_B-5*IN[1]; \
                            _B=_B+4*IN[2]; \
                             OUT=_B-IN[3]; \
                            _A+=OUT*fract1[X]; \
                             OUT=(IN[2]-IN[0]); \
                            _A+=OUT*fract0[X]; \
                            _A=_A >> 3; \
                            _A=_A >> 3; \
                            OUT=_A >> 2; \
                            OUT+=IN[1];}
// Resize the tiles.
// Each thread is processing a pixel. 
// Tiles are interleaved into vector format
// So each call to this kernel will process (NUM_PCORE*VECTOR_WIDTH) tiles of 4x4 simultaneously 
//
_kernel_ void resize::exe() {
   vint16 c[4];
   HERMITE(x,c[0],p_in);
   p_in+=TILE_DIM+TILE_PAD;
   HERMITE(x,c[1],p_in);
   p_in+=TILE_DIM+TILE_PAD;
   HERMITE(x,c[2],p_in);
   p_in+=TILE_DIM+TILE_PAD;
   HERMITE(x,c[3],p_in);
   HERMITE(y,p_out[0],c);
}

// Image resize using boxing method

_share vint16 resize_box::inbuf[BOX_RESIZE_MAX_INBUF];
_share vint16 resize_box::outbuf[BOX_RESIZE_MAX_OUTBUF];
vint16 *resize_box::p_in;
vint16 *resize_box::p_out;
vint32 resize_box::_A;
int16 resize_box::filter[BOX_RESIZE_MAX_FILTER];
int resize_box::scale;

_kernel_ void resize_box::init(int filteri) {
   int i;
   i=tid;
   p_out=&outbuf[i];
   p_in=&inbuf[filteri];
   scale=BOX_RESIZE_SCALE;
}

// Resize by weighted averaging up to 3 pixels.

_kernel_ void resize_box::exe3() {
   int i;
   _A = p_in[0]*filter[0];
#pragma unroll
   for(i=1;i < 3;i++) {
      _A += p_in[i]*filter[i];
   }
   _A=_A>>scale;
   p_out[0]=_A;
}

// Resize by weighted averaging up to 4 pixels.

_kernel_ void resize_box::exe4() {
   int i;
   _A = p_in[0]*filter[0];
#pragma unroll
   for(i=1;i < 4;i++) {
      _A += p_in[i]*filter[i];
   }
   _A=_A>>scale;
   p_out[0]=_A;
}

// Resize by weighted averaging up to 5 pixels.

_kernel_ void resize_box::exe5() {
   int i;
   _A = p_in[0]*filter[0];
#pragma unroll
   for(i=1;i < 5;i++) {
      _A += p_in[i]*filter[i];
   }
   _A=_A>>scale;
   p_out[0]=_A;
}

// Resize by weighted averaging up to 6 pixels.

_kernel_ void resize_box::exe6() {
   int i;
   _A = p_in[0]*filter[0];
#pragma unroll
   for(i=1;i < 6;i++) {
      _A += p_in[i]*filter[i];
   }
   _A=_A>>scale;
   p_out[0]=_A;
}

// Resize by weighted averaging up to 7 pixels.

_kernel_ void resize_box::exe7() {
   int i;
   _A = p_in[0]*filter[0];
#pragma unroll
   for(i=1;i < 7;i++) {
      _A += p_in[i]*filter[i];
   }
   _A=_A>>scale;
   p_out[0]=_A;
}

// Resize by weighted averaging up to 8 pixels.

_kernel_ void resize_box::exe8() {
   int i;
   _A = p_in[0]*filter[0];
#pragma unroll
   for(i=1;i < 8;i++) {
      _A += p_in[i]*filter[i];
   }
   _A=_A>>scale;
   p_out[0]=_A;
}

