#include "../../../base/zta.h"
#include "harris.h"

// Perform harris-corner algorithm
// Refer to https://en.wikipedia.org/wiki/Harris_Corner_Detector

_NT16_ class harris;

_share float8 harris::inbuf[HARRIS_MAX_INBUF];
_share float8 harris::x_gradient[HARRIS_MAX_OUTBUF];
_share float8 harris::y_gradient[HARRIS_MAX_OUTBUF];
_share float harris::k_x[TILE_MAX_KZ][TILE_MAX_KZ];
_share float harris::k_y[TILE_MAX_KZ][TILE_MAX_KZ];
float8 *harris::in_p;
float8 *harris::x_gradient_p;
float8 *harris::y_gradient_p;
int harris::pad;
double8 harris::_A;
double8 harris::_B;

_kernel_ void harris::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(TILE_DX_DIM+TILE_MAX_KZ-1);
   in_p=&inbuf[j];
   x_gradient_p=&x_gradient[i];
   y_gradient_p=&y_gradient[i];
   pad = (TILE_DX_DIM-1);
   // Kernel used for harris-corner algo
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

_kernel_ void harris::calc_gradient() {
   int x,y;
   float8 max,min;
   float8 *p2;

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
   x_gradient_p[0]=_A>>0;
   y_gradient_p[0]=_B>>0;
}

// Phase 1

_NT16_ class harris1;

_share float8 harris1::x_gradient[HARRIS_MAX_INBUF];
_share float8 harris1::y_gradient[HARRIS_MAX_INBUF];
_share float8 harris1::score[TILE_DX_DIM*TILE_DY_DIM];
float8 *harris1::x_gradient_p;
float8 *harris1::y_gradient_p;
int harris1::pad;
double8 harris1::_XX;
double8 harris1::_YY;
double8 harris1::_XY;
double8 harris1::_SUM;

_kernel_ void harris1::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(TILE_DX_DIM+TILE_MAX_KZ-1);
   x_gradient_p=&x_gradient[j];
   y_gradient_p=&y_gradient[j];
   pad = (TILE_DX_DIM-1);
}

// Calculate gradient...

_kernel_ void harris1::calc() {
   int i;
   int x,y;
   float8 xx,yy,xy;
   float8 sum;
   float8 *x_p,*y_p;

   x_p=x_gradient_p;
   y_p=y_gradient_p;

   // Calculate gradient in X-direction....

   _XX=0;
   _YY=0;
   _XY=0;
#pragma unroll
   for(y=0;y < TILE_MAX_KZ;y++) {
#pragma unroll
      for(x=0;x < TILE_MAX_KZ;x++) {
         _XX += x_p[0]*x_p[0];
         _YY += y_p[0]*y_p[0];
         _XY += x_p[0]*y_p[0];
         x_p++;
         y_p++;
      }
      x_p += pad;
      y_p += pad;
   }

   _XX=_XX>>10;
   _XX+=1;
   xx=_XX>>1;

   _YY=_YY>>10;
   _YY+=1;
   yy=_YY>>1;

   _XY=_XY>>10;
   _XY+=1;
   xy=_XY>>1;
   
   // Calculate TRACE
   _SUM=xx*yy;
   _SUM=(_SUM<<1);
   _SUM += xx*xx;
   _SUM += yy*yy;

   // TRACE*0.0625
   _SUM = _SUM >> 4;
         
   _SUM -= xx*yy;
   _SUM += xy*xy;

   _SUM = _SUM>>10;
   _SUM += 1;
   sum = _SUM >> 1;

   i=tid;
   score[i]=0-sum;
   _VMASK=LT(score[i],0);
   score[i]=0;
   _VMASK=-1;
}

// Phase 2
// Calculate score

_NT16_ class harris2;

_share float8 harris2::score[HARRIS_MAX_INBUF];
_share float8 harris2::output[TILE_DX_DIM*TILE_DY_DIM];
float8 *harris2::score_p;
float8 *harris2::output_p;
int harris2::pad;

_kernel_ void harris2::init() {
   int i,j;
   i=tid;
   j=(i&3)+(i>>2)*(TILE_DX_DIM+TILE_MAX_KZ-1);
   score_p=&score[j];
   output_p=&output[i];
   pad = (TILE_DX_DIM-1);
}

_kernel_ void harris2::calc() {
   int x,y;
   float8 *p2;
   float8 v;
   int c;

   p2=score_p;

   // Calculate gradient in X-direction....

   v=p2[7];
   c=0;
#pragma unroll
   for(y=0;y < TILE_MAX_KZ;y++) {
#pragma unroll
      for(x=0;x < TILE_MAX_KZ;x++) {
         c=c | GT(p2[0],v);
         p2++;
      }
      p2 += pad;
   }
   output_p[0]=v;
   _VMASK=c;
   output_p[0]=0;
   _VMASK=-1;
}




