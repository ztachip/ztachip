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
#include "of.h"

// Doing dense optical flow using Lucas-Kanade method.
// https://en.wikipedia.org/wiki/Lucas%E2%80%93Kanade_method

_share vint16 of::inbuf1[OF_MAX_INBUF];
_share vint16 of::inbuf2[OF_MAX_INBUF];
_share vint16 of::x_gradient[OF_MAX_OUTBUF];
_share vint16 of::y_gradient[OF_MAX_OUTBUF];
_share vint16 of::t_gradient[OF_MAX_OUTBUF];
_share int16 of::k_x[TILE_MAX_KZ][TILE_MAX_KZ];
_share int16 of::k_y[TILE_MAX_KZ][TILE_MAX_KZ];
vint16 *of::in1_p;
vint16 *of::in2_p;
int of::pad;
vint32 of::_A;
vint32 of::_B;
vint32 of::_C;

_kernel_ void of::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(TILE_DX_DIM+TILE_MAX_KZ-1);
   in1_p=&inbuf1[j];
   in2_p=&inbuf2[j];
   pad = (TILE_DX_DIM-1);
   // Kernel used to detect gradient
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

_kernel_ void of::calc_gradient() {
   int x,y;
   vint16 max,min;
   vint16 *p1,*p2;
   int idx;

   p1=in1_p;
   p2=in2_p;
   idx=tid;

   // Calculate gradient in X-direction....

   _A=0;
   _B=0;
   _C=0;
#pragma unroll
   for(y=0;y < TILE_MAX_KZ;y++) {
#pragma unroll
      for(x=0;x < TILE_MAX_KZ;x++) {
         _A += p1[0]*k_x[y][x];
         _B += p1[0]*k_y[y][x];
         _C += p1[0];
         _C -= p2[0];
         p1++;
         p2++;
      }
      p1 += pad;
      p2 += pad;
   }
   x_gradient[idx]=_A>>0;
   y_gradient[idx]=_B>>0;
   t_gradient[idx]=_C>>0;
}

// Calculate optical flow with Lucas-Kanade method 

_share vint16 of1::x_gradient[OF1_MAX_INBUF];
_share vint16 of1::y_gradient[OF1_MAX_INBUF];
_share vint16 of1::t_gradient[OF1_MAX_INBUF];
int of1::input_idx;
int of1::output_idx;
int of1::pad;
vint32 of1::IX2;
vint32 of1::IY2;
vint32 of1::IXY;
vint32 of1::IXT;
vint32 of1::IYT;
vint32 of1::T;
vint32 of1::A;

_kernel_ void of1::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(OF1_TILE_DX_DIM+OF1_TILE_MAX_KZ-1);
   input_idx=j;
   output_idx=(i>>2)*(OF1_TILE_DX_IN_DIM)+(i&3)+OF1_TILE_DX_DIM;
   pad = (OF1_TILE_DX_DIM-1);
}

_kernel_ void of1::calc_lucus_kanade() {
   int x,y;
   vint16 *x_p,*y_p;
   vint16 *t_p;
   vint16 t1,t2;

   x_p=&x_gradient[input_idx];
   y_p=&y_gradient[input_idx];
   t_p=&t_gradient[input_idx];

   // Calculate gradient in X-direction....

   IX2=0;
   IY2=0;
   IXY=0;
   IXT=0;
   IYT=0;

#pragma unroll
   for(y=0;y < OF1_TILE_MAX_KZ;y++) {
#pragma unroll
      for(x=0;x < OF1_TILE_MAX_KZ;x++) {
         IX2 += x_p[0]*x_p[0];
         IY2 += y_p[0]*y_p[0];
         IXY += x_p[0]*y_p[0];
         IXT += x_p[0]*t_p[0];
         IYT += y_p[0]*t_p[0];
         x_p++;
         y_p++;
         t_p++;
      }
      x_p += pad;
      y_p += pad;
      t_p += pad;
   }

   IX2=IX2>>16;
   IY2=IY2>>16;
   IXY=IXY>>16;
   IXT=IXT>>16;
   IYT=IYT>>16;

   // Calculate determinant
   T=0;t1=IX2>>0;t2=IY2>>0;T+=t1*t2;t1=IXY>>0;T-=t1*t1;t_gradient[output_idx]=T>>1;

   // Calculate xvect,yvect
   T=0;t1=IY2>>0;t2=IXT>>0;T+=t1*t2;t1=IXY>>0;t2=IYT>>0;T+=t1*t2;x_gradient[output_idx]=T>>2;
   T=0;t1=IXY>>0;t2=IXT>>0;T+=t1*t2;t1=IX2>>0;t2=IYT>>0;T-=t1*t2;y_gradient[output_idx]=T>>2;

   _VMASK=EQ(t_gradient[output_idx],0);
   x_gradient[output_idx]=0;
   y_gradient[output_idx]=0;
   _VMASK=-1;
}

_kernel_ void of1::calc_lucus_kanade_final() {
  A=x_gradient[output_idx]*t_gradient[output_idx];
  x_gradient[output_idx]=A>>10;

  A=y_gradient[output_idx]*t_gradient[output_idx];
  y_gradient[output_idx]=A>>10;
}
