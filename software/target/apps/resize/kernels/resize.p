#include "../../../base/zta.h"
#include "resize.h"

// Image resize using bicubic interpolation

_NT16_ class resize;

_share float8 resize::inbuf[RESIZE_MAX_INBUF];
_share float8 resize::outbuf[RESIZE_MAX_OUTBUF];
int resize::x;
int resize::y;
float8 *resize::p_in;
float8 *resize::p_out;
_share float resize::fract0[TILE_DIM];
_share float resize::fract1[TILE_DIM];
_share float resize::fract2[TILE_DIM];
double8 resize::_A;
double8 resize::_B;
_share float resize::pixel[8];

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
   float8 c[4];
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

_NT16_ class resize_box;

_share float8 resize_box::inbuf[BOX_RESIZE_MAX_INBUF];
_share float8 resize_box::outbuf[BOX_RESIZE_MAX_OUTBUF];
float8 *resize_box::p_in;
float8 *resize_box::p_out;
double8 resize_box::_A;
float resize_box::filter[BOX_RESIZE_MAX_FILTER];
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

