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
#include "equalize.h"

// Perform histogram equalization

// Add a short positive number to a long positive integer

#define LONG_PLUS_SHORT(y_hi,y_lo,x)  \
                       {(y_lo) = (y_lo)+(x); \
                       _VMASK=-1; \
                       _VMASK=GT((y_lo),1000); \
                       y_hi = y_hi+1; \
                       y_lo = y_lo-1000; \
                       _VMASK=-1;}

// Add a long integer to a long integer...
#define LONG_PLUS_LONG(y_hi,y_lo,x_hi,x_lo) \
                      {y_lo = y_lo+x_lo; \
                       y_hi = y_hi+x_hi; \
                       _VMASK=-1; \
                       _VMASK=GT(y_lo,1000); \
                       y_hi = y_hi+1; \
                       y_lo = y_lo-1000; \
                       _VMASK=-1;}

_share vint16 equalize::histogram_lo[NUM_THREAD_PER_CORE*kHistogramBinSize];
_share vint16 equalize::histogram_hi[NUM_THREAD_PER_CORE*kHistogramBinSize];
vint16 equalize::histogram[kHistogramBinSize];
_share int16 equalize::in[kHistogramInSize*NUM_THREAD_PER_CORE];
int16 *equalize::p;
int16 *equalize::histogram_p;

// Module initialization

_kernel_ void equalize::init() {
   int i,ii;
   vint16 *t;
   vint16 *p_lo,*p_hi;

   t=histogram;
   histogram_p=t<<VECTOR_DEPTH;
   i=tid*kHistogramInSize;
   p=&in[i];
   for(i=0;i < kHistogramBinSize;i++)
      histogram[i]=0;
   i=tid*kHistogramBinSize;
   p_lo=&histogram_lo[i];
   p_hi=&histogram_hi[i];
   for(ii=0;ii < kHistogramBinSize;ii++) {
      p_lo[ii]=0;
      p_hi[ii]=0;
   }
}

// Accumulate histogram count to bigger counter...

_kernel_ void equalize::accumulate() {
   int i,ii;
   vint16 *p_lo;
   vint16 *p_hi;
   ii=tid*kHistogramBinSize;
   p_lo=&histogram_lo[ii];
   p_hi=&histogram_hi[ii];
   for(i=0;i < kHistogramBinSize;i++) {
      LONG_PLUS_SHORT(p_hi[i],p_lo[i],histogram[i]);
      histogram[i]=0;
   }
}

// Accumulate accross all threads...

_kernel_ void equalize::done(_global int count) {
   int ii,i,j,idx;
   vint16 *p_lo,*p_hi;
   ii=tid;
   p_lo=&histogram_lo[ii];
   p_hi=&histogram_hi[ii];
   idx=kHistogramBinSize;
   for(j=1;j < count;j++,idx+=kHistogramBinSize) {
      LONG_PLUS_LONG(p_hi[0],p_lo[0],p_hi[idx],p_lo[idx]);
   }
}

_kernel_ void equalize::adjust_extra_zero() {
   histogram_lo[0][0]=histogram_lo[0][0]-histogram_lo[kHistogramBinSize][0];
   histogram_hi[0][0]=histogram_hi[0][0]-histogram_hi[kHistogramBinSize][0];
   if(histogram_lo[0][0] < 0) {
      histogram_lo[0][0]=histogram_lo[0][0]+1000;
      histogram_hi[0][0]=histogram_hi[0][0]-1;
   }
}

_kernel_ void equalize::exe() {
   int ii,i;

#pragma unroll
   for(i=0;i < kHistogramInSize;i++) {
      ii=ASN_RAW(p[i]);
      ii=(ii >> kHistogramBinBit);
      histogram_p[ii]=histogram_p[ii]+1;
   }
}

