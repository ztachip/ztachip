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
#include "canny.h"

// Perform canny edge detection algorithm
// Refer to https://en.wikipedia.org/wiki/Canny_edge_detector

_share float8 canny::inbuf[CANNY_MAX_INBUF];
_share float8 canny::magnitude[CANNY_MAX_OUTBUF];
_share float8 canny::phase[CANNY_MAX_OUTBUF];
_share float canny::k_x[TILE_MAX_KZ][TILE_MAX_KZ];
_share float canny::k_y[TILE_MAX_KZ][TILE_MAX_KZ];
float8 *canny::in_p;
float8 *canny::magnitude_p;
float8 *canny::phase_p;
int canny::pad;
double8 canny::_A;
double8 canny::_B;

_kernel_ void canny::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(TILE_DX_DIM+TILE_MAX_KZ-1);
   in_p=&inbuf[j];
   magnitude_p=&magnitude[i];
   phase_p=&phase[i];
   pad = (TILE_DX_DIM-1);

   // Convolution kernels used by canny edgeDetection algo
   k_x[0][0]=-1;
   k_x[0][1]=0;
   k_x[0][2]=1;
   k_x[1][0]=-2;
   k_x[1][1]=0;
   k_x[1][2]=2;
   k_x[2][0]=-1;
   k_x[2][1]=0;
   k_x[2][2]=1;

   k_y[0][0]=-1;
   k_y[0][1]=-2;
   k_y[0][2]=-1;
   k_y[1][0]=0;
   k_y[1][1]=0;
   k_y[1][2]=0;
   k_y[2][0]=1;
   k_y[2][1]=2;
   k_y[2][2]=1;
}

_kernel_ void canny::calc_gradient() {
   int x,y;
   float8 *p2;
   float8 t;
   float8 x_gradient,y_gradient;
   float8 max,min;

   p2=in_p;

   // Calculate gradient in X-direction....

   _A=0;
   _B=0;
#pragma unroll
   for(y=0;y < TILE_MAX_KZ;y++) {
#pragma unroll
      for(x=0;x < TILE_MAX_KZ;x++) {
         _A += p2[0]*k_x[y][x];
         _B += p2[0]*k_y[y][x];
         p2++;
      }
      p2 += pad;
   }
   x_gradient=_A>>0;
   y_gradient=_B>>0;

   phase_p[0]=DIRECTION_NW_SE;
   _VMASK=GE(x_gradient*y_gradient,0);
   phase_p[0]=DIRECTION_NE_SW;
   _VMASK=-1;
   _VMASK=LT(x_gradient,0);
   x_gradient=x_gradient*(-1);
   _VMASK=-1;
   _VMASK=LT(y_gradient,0);
   y_gradient=y_gradient*(-1);
   _VMASK=-1;
   min=x_gradient;
   _VMASK=GT(x_gradient,y_gradient);
   min=y_gradient;
   _VMASK=-1;
   max=x_gradient;
   _VMASK=GT(y_gradient,x_gradient);
   max=y_gradient;
   _VMASK=-1;

   // Calculate magnitude by approximation MAX+MIN/2

   magnitude_p[0]=max+(min>>1);

   // Calculate phase

   _A=x_gradient*19;
   t=_A-y_gradient*8;
   _VMASK=LT(t,0);
   phase_p[0]=DIRECTION_NS;
   _VMASK=-1;

   _A=x_gradient*3;
   t=_A-y_gradient*8;
   _VMASK=GT(t,0);
   phase_p[0]=DIRECTION_EW;
   _VMASK=-1;
}


// Phase 1 canny...
// Perform local maxima suppression

_share float8 canny1::magnitude[CANNY_MAX_INBUF];
_share float8 canny1::phase[TILE_DX_DIM*TILE_DY_DIM];
_share float8 canny1::maxima[TILE_DX_DIM*TILE_DY_DIM];
float8 *canny1::m_p;
float8 *canny1::phase_p;
float8 *canny1::maxima_p;

_kernel_ void canny1::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(TILE_DX_DIM+TILE_MAX_KZ-1);
   m_p=&magnitude[j];
   phase_p=&phase[i];
   maxima_p=&maxima[i];
}

_kernel_ void canny1::calc_maxima() {
   int c;
   float8 v;

   v=m_p[7];
   maxima_p[0]=v;

   // East-west direction
   c=EQ(phase_p[0],DIRECTION_EW);
   _VMASK=GE(m_p[6],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;
   _VMASK=GE(m_p[8],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;

   // North-South direction
   c=EQ(phase_p[0],DIRECTION_NS);
   _VMASK=GE(m_p[1],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;
   _VMASK=GE(m_p[13],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;

   // North-East direction
   c=EQ(phase_p[0],DIRECTION_NW_SE);
   _VMASK=GE(m_p[2],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;
   _VMASK=GE(m_p[12],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;

   // North-West direction
   c=EQ(phase_p[0],DIRECTION_NE_SW);
   _VMASK=GE(m_p[0],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;
   _VMASK=GE(m_p[14],v) & c;
   maxima_p[0]=0;
   _VMASK=-1;  
}

// Phase 2 canny. 
// Do edge detection threshold hysteresis

_share float8 canny2::maxima[CANNY_MAX_INBUF];
_share float8 canny2::output[TILE_DX_DIM*TILE_DY_DIM];
float8 *canny2::in_p;
float8 *canny2::out_p;
_share float canny2::threshold_lo;
_share float canny2::threshold_hi;

_kernel_ void canny2::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(TILE_DX_DIM+TILE_MAX_KZ-1);
   in_p=&maxima[j];
   out_p=&output[i];
}

// Calculate edge threshold hystersis

_kernel_ void canny2::threshold_hysteris() {
   int c;
   float8 v;

   out_p[0]=0;
   v=in_p[7];
   _VMASK=GE(v,threshold_hi);
   out_p[0]=255;
   _VMASK=-1;

   c=GE(v,threshold_lo);
   
   _VMASK=GE(in_p[0],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;

   _VMASK=GE(in_p[1],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;

   _VMASK=GE(in_p[2],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;

   _VMASK=GE(in_p[6],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;

   _VMASK=GE(in_p[8],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;

   _VMASK=GE(in_p[12],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;

   _VMASK=GE(in_p[13],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;

   _VMASK=GE(in_p[14],threshold_hi) & c;
   out_p[0]=255;
   _VMASK=-1;
}
