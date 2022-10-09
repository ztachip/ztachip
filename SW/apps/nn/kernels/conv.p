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
#include "conv.h"

// Convolution 3x3 kernel

_share float8 convolution::coef[MAX_SMALL_KERNEL_SIZE];
_share float convolution::bot[CONV_SMALL_BOTSZ];
_share float8 convolution::biasHi;
_share float8 convolution::biasLo;
float8 convolution::top[MAX_CONV_Y_DIM];
float *convolution::p;
int convolution::out_scale;
float convolution::in_scale;
double8 convolution::_A[MAX_CONV_Y_DIM];
int convolution::dx;

_kernel_ void convolution::start(_global int count) {
   int i;
   for(i=0;i < count;i++) {
      _A[i] = biasLo;
      _A[i] += biasHi*1024;
   }
}

_kernel_ void convolution::init(int stride,int conv_dx_log,int mypid,int _out_scale,float _in_scale,int _dx) {
    int i;
    i=mypid*_dx;
    i=i*stride+tid*stride;
    p=&bot[i];
    out_scale=_out_scale;
    in_scale=_in_scale;
    dx=_dx;
}

_kernel_ void convolution::exe3x3(_global int k,_global int offset) {
   int i,j;
   float *p2;

#pragma unroll
   for(j=0;j < 3;j++) {
      _A[k] += p[offset+j]*coef[j];
   }
   p2 = p+dx;
#pragma unroll
   for(i=1;i < 2;i++) {
#pragma unroll
      for(j=0;j < 3;j++) {
         _A[k] += p2[offset+j]*coef[i*3+j];
      }
      p2 += dx;
   }
#pragma unroll
   for(j=0;j < 3;j++) {
      _A[k] += p2[offset+j]*coef[2*3+j];
   }
}

_kernel_ void convolution::activate(_global int idx) {
   top[idx] = _A[idx] >> out_scale;
}

// Depth-wise Convolution

_share float8 convolution_depthwise::coef[MAX_DEPTHWISE_KERNEL_SIZE];
_share float8 convolution_depthwise::bot[CONV_DEPTHWISE_BOTSZ];
_share float8 convolution_depthwise::biasHi;
_share float8 convolution_depthwise::biasLo;
float8 convolution_depthwise::top[CONV_DEPTHWISE_Y_DIM];
float8 *convolution_depthwise::p;
int convolution_depthwise::out_scale;
float convolution_depthwise::in_scale;
double8 convolution_depthwise::_A[CONV_DEPTHWISE_Y_DIM];
int convolution_depthwise::dx;

_kernel_ void convolution_depthwise::init(int stride,int mypid,int _out_scale,float _in_scale,int _dx) {
   int i;
   i=mypid*_dx;
   i=i*stride+tid*stride;
   p=&bot[i];
   out_scale=_out_scale;
   in_scale=_in_scale;
   dx=_dx;
}

_kernel_ void convolution_depthwise::init2(int stride,int mypid,int _out_scale,float _in_scale,int _dx) {
   int i,j;
   i=(tid>>3);
   j=(tid&7);
   i=j*stride+i*_dx*stride+mypid*_dx*2*stride;
   p=&bot[i];
   out_scale=_out_scale;
   in_scale=_in_scale;
   dx=_dx;
}

_kernel_ void convolution_depthwise::exe3x3(_global int k,_global int offset) {
   int i,j;
   float8 *p2;

   _A[k] = biasLo;
   _A[k] += biasHi*1024;
#pragma unroll
   for(j=0;j < 3;j++) {
      _A[k] += p[offset+j]*coef[j];
   }
   p2 = p+dx;
#pragma unroll
   for(i=1;i < 2;i++) {
#pragma unroll
      for(j=0;j < 3;j++) {
         _A[k] += p2[offset+j]*coef[i*3+j];
      }
      p2 += dx;
   }
#pragma unroll
   for(j=0;j < 3;j++) {
      _A[k] += p2[offset+j]*coef[2*3+j];
   }
   top[k] = _A[k] >> out_scale;
}

// Convolution 1x1

//_share float8 convolution1x1::coef[2];
//_share float convolution1x1::bot[CONV_1X1_BOTSZ];
_share float8 convolution1x1::coef[4];
_share float convolution1x1::bot[CONV_1X1_BOTSZ];
_share float8 convolution1x1::biasHi;
_share float8 convolution1x1::biasLo;
_share float8 convolution1x1::top[CONV_1X1_Y_DIM*NUM_THREAD_PER_CORE];
float *convolution1x1::p;
float8 *convolution1x1::p2;
int convolution1x1::out_scale;
double8 convolution1x1::_A[CONV_1X1_Y_DIM];
int convolution1x1::dysz;

_kernel_ void convolution1x1::start(_global int count) {
   int i;
   for(i=0;i < count;i++) {
      _A[i] = biasLo;
      _A[i] += biasHi*1024;
   }
}

_kernel_ void convolution1x1::init(int mypid,int _out_scale,int _dysz,int _conv_dx) {
   int i;
   i=mypid*_conv_dx+tid;
   p=&bot[i];
   out_scale=_out_scale;
   dysz=_dysz;
   i=tid;
   p2=&top[i];
}

// Do 8 elements with loop unrolling...

_kernel_ void convolution1x1::exe8(_global int idx,_global int idx2) {
   int jj;
   _A[0] += p[idx]*coef[idx2];
   jj = dysz+idx;
   _A[1] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[2] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[3] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[4] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[5] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[6] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[7] += p[jj]*coef[idx2];
}

// Do 7 elements with loop unrolling...

_kernel_ void convolution1x1::exe7(_global int idx,_global int idx2) {
   int jj;
   _A[0] += p[idx]*coef[idx2];
   jj = dysz+idx;
   _A[1] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[2] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[3] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[4] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[5] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[6] += p[jj]*coef[idx2];
}

// Do 6 elements with loop unrolling...

_kernel_ void convolution1x1::exe6(_global int idx,_global int idx2) {
   int jj;
   _A[0] += p[idx]*coef[idx2];
   jj = dysz+idx;
   _A[1] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[2] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[3] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[4] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[5] += p[jj]*coef[idx2];
}

// Do 5 elements with loop unrolling...

_kernel_ void convolution1x1::exe5(_global int idx,_global int idx2) {
   int jj;
   _A[0] += p[idx]*coef[idx2];
   jj = dysz+idx;
   _A[1] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[2] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[3] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[4] += p[jj]*coef[idx2];
}

// Do 4 elements with loop unrolling...

_kernel_ void convolution1x1::exe4(_global int idx,_global int idx2) {
   int jj;
   _A[0] += p[idx]*coef[idx2];
   jj = dysz+idx;
   _A[1] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[2] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[3] += p[jj]*coef[idx2];
}

// Do 3 elements with loop unrolling...

_kernel_ void convolution1x1::exe3(_global int idx,_global int idx2) {
   int jj;
   _A[0] += p[idx]*coef[idx2];
   jj = dysz+idx;
   _A[1] += p[jj]*coef[idx2];
   jj = jj+dysz;
   _A[2] += p[jj]*coef[idx2];
}

// Do 2 elements with loop unrolling...

_kernel_ void convolution1x1::exe2(_global int idx,_global int idx2) {
   int jj;
   _A[0] += p[idx]*coef[idx2];
   jj = dysz+idx;
   _A[1] += p[jj]*coef[idx2];
}

// Do just 1 element 

_kernel_ void convolution1x1::exe(_global int idx,_global int idx2) {
   _A[0] += p[idx]*coef[idx2];
}

_kernel_ void convolution1x1::activate(_global int idx,_global int idx2) {
   p2[idx2] = _A[idx] >> out_scale;
}

// Add

_kernel_ void add::exe(float8 x1,float8 x2,float8 y) {
   y=x1+x2;
}

