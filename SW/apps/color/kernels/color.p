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
#include "color.h"

_NT16_ class yuyv2rgb;

_share float8 yuyv2rgb::yuyv[PIXEL_PER_THREAD*YUYV_PIXEL_SIZE*NUM_THREAD_PER_CORE];

_share float8 yuyv2rgb::rgb[PIXEL_PER_THREAD*RGB_PIXEL_SIZE*NUM_THREAD_PER_CORE];
double8 yuyv2rgb::red[PIXEL_PER_THREAD];
double8 yuyv2rgb::blue[PIXEL_PER_THREAD];
double8 yuyv2rgb::green[PIXEL_PER_THREAD];
float8 *yuyv2rgb::p1;
float8 *yuyv2rgb::p2;

// Color conversion: YUYV -> RGB in interleave format

_kernel_ void yuyv2rgb::init_interleave() {
   int idx;
   idx=tid*(PIXEL_PER_THREAD*YUYV_PIXEL_SIZE);
   p1=&yuyv[idx];
   idx=tid*PIXEL_PER_THREAD*RGB_PIXEL_SIZE;
   p2=&rgb[idx];
}

// YUYV->RGB conversion in split format

_kernel_ void yuyv2rgb::init_split() {
   int idx;
   idx=tid*(PIXEL_PER_THREAD*YUYV_PIXEL_SIZE);
   p1=&yuyv[idx];
   idx=tid*PIXEL_PER_THREAD;
   p2=&rgb[idx];
}

// Convert from YUYV to RGB color space

_kernel_ void yuyv2rgb::convert() {
   int i;
   float8 u,v,g;

   u=p1[1]-128;
   v=p1[3]-128;
#pragma unroll
   for(i=0;i < PIXEL_PER_THREAD;i++) {
      // red
      red[i]=583*v;
      red[i]=red[i]+256;
      red[i] = red[i] >> 9;

      // Green
      green[i]=-202*u;
      green[i]=green[i]-297*v;
      green[i]=green[i]+256;
      green[i] = green[i] >> 9;

      // Blue color
      blue[i]=1040*u;
      blue[i]=blue[i]+256;
      blue[i] = blue[i] >> 9;
   }
}

// Done with conversion to BGR in interleave format (BGRBGRBGR...)

_kernel_ void yuyv2rgb::final_bgr_interleave() {
   int i;
   for(i=0;i < PIXEL_PER_THREAD;i++) {
      // red
      p2[RGB_PIXEL_SIZE*i+2] = red[i]+p1[2*i];

      // green
      p2[RGB_PIXEL_SIZE*i+1]=green[i]+p1[2*i];

      // Blue
      p2[RGB_PIXEL_SIZE*i]=blue[i]+p1[2*i];   
   }
}

// Done with conversion to BGR in split format (BBB...GGG...RRR...)

_kernel_ void yuyv2rgb::final_bgr_split() {
   int i;
   for(i=0;i < PIXEL_PER_THREAD;i++) {
      // red
      p2[i+2*PIXEL_PER_THREAD*NUM_THREAD_PER_CORE]=red[i]+p1[2*i];

      // green
      p2[i+PIXEL_PER_THREAD*NUM_THREAD_PER_CORE]=green[i]+p1[2*i];

      // Blue
      p2[i]=blue[i]+p1[2*i];   
   }
}

// Done with conversion to RGB in interleave format (RGBRGBRGB...)

_kernel_ void yuyv2rgb::final_rgb_interleave() {
   int i;
   for(i=0;i < PIXEL_PER_THREAD;i++)
   {
      // Blue
      p2[RGB_PIXEL_SIZE*i+2] = blue[i]+p1[2*i];

      // green
      p2[RGB_PIXEL_SIZE*i+1]=green[i]+p1[2*i];

      // Red
      p2[RGB_PIXEL_SIZE*i]=red[i]+p1[2*i];   
   }
}

// Done with conversion to RGB in split format (RRR...GGG...BBB)

_kernel_ void yuyv2rgb::final_rgb_split() {
   int i;
   for(i=0;i < PIXEL_PER_THREAD;i++) {
      // blue
      p2[i+2*PIXEL_PER_THREAD*NUM_THREAD_PER_CORE]=blue[i]+p1[2*i];

      // green
      p2[i+PIXEL_PER_THREAD*NUM_THREAD_PER_CORE]=green[i]+p1[2*i];

      // Red
      p2[i]=red[i]+p1[2*i];   
   }
}

// RGB TO RGB copy 

_NT16_ class copy;

_share float8 copy::in[RGB_PIXEL_SIZE*NUM_THREAD_PER_CORE];
_share float8 copy::out[RGB_PIXEL_SIZE*NUM_THREAD_PER_CORE];
float8 *copy::p1;
float8 *copy::p2;
double8 copy::_A;

#define RGB2MONO(r,g,b,m) {_A=(r)*154;_A+=(g)*302;_A+=(b)*56;_A+=256;m=_A>>9;}

_kernel_ void copy::in_interleave_init() {
   int i;
   i=tid*3;
   p1=&in[i];
}

_kernel_ void copy::in_split_init() {
   int i;
   i=tid;
   p1=&in[i];
}

_kernel_ void copy::out_interleave_init() {
   int i;
   i=tid*3;
   p2=&out[i];
}

_kernel_ void copy::out_split_init() {
   int i;
   i=tid;
   p2=&out[i];
}

_kernel_ void copy::interleave2split() {
   p2[0]=p1[0];
   p2[NUM_THREAD_PER_CORE]=p1[1];
   p2[2*NUM_THREAD_PER_CORE]=p1[2];
}

_kernel_ void copy::interleaveRGB2split_mono() {
   float8 mono;
   RGB2MONO(p1[0],p1[1],p1[2],mono);
   p2[0]=mono;
   p2[NUM_THREAD_PER_CORE]=mono;
   p2[2*NUM_THREAD_PER_CORE]=mono;
}

_kernel_ void copy::interleaveBGR2split_mono() {
   float8 mono;
   RGB2MONO(p1[2],p1[1],p1[0],mono);
   p2[0]=mono;
   p2[NUM_THREAD_PER_CORE]=mono;
   p2[2*NUM_THREAD_PER_CORE]=mono;
}

_kernel_ void copy::interleave2split_reverse() {
   p2[0]=p1[2];
   p2[NUM_THREAD_PER_CORE]=p1[1];
   p2[2*NUM_THREAD_PER_CORE]=p1[0];
}

_kernel_ void copy::split2interleave() {
   p2[0]=p1[0];
   p2[1]=p1[NUM_THREAD_PER_CORE];
   p2[2]=p1[2*NUM_THREAD_PER_CORE];
}

_kernel_ void copy::splitRGB2interleave_mono() {
   float8 mono;
   RGB2MONO(p1[0],p1[NUM_THREAD_PER_CORE],p1[2*NUM_THREAD_PER_CORE],mono);
   p2[0]=mono;
   p2[1]=mono;
   p2[2]=mono;
}

_kernel_ void copy::splitBGR2interleave_mono() {
   float8 mono;
   RGB2MONO(p1[2*NUM_THREAD_PER_CORE],p1[NUM_THREAD_PER_CORE],p1[0],mono);
   p2[0]=mono;
   p2[1]=mono;
   p2[2]=mono;
}

_kernel_ void copy::split2interleave_reverse() {
   p2[0]=p1[2*NUM_THREAD_PER_CORE];
   p2[1]=p1[NUM_THREAD_PER_CORE];
   p2[2]=p1[0];
}

_kernel_ void copy::split2split() {
   p2[0]=p1[0];
   p2[NUM_THREAD_PER_CORE]=p1[NUM_THREAD_PER_CORE];
   p2[2*NUM_THREAD_PER_CORE]=p1[2*NUM_THREAD_PER_CORE];
}

_kernel_ void copy::splitRGB2split_mono() {
   float8 mono;

   RGB2MONO(p1[0],p1[NUM_THREAD_PER_CORE],p1[2*NUM_THREAD_PER_CORE],mono);
   p2[0]=mono;
   p2[NUM_THREAD_PER_CORE]=mono;
   p2[2*NUM_THREAD_PER_CORE]=mono;
}

_kernel_ void copy::splitBGR2split_mono() {
   float8 mono;

   RGB2MONO(p1[2*NUM_THREAD_PER_CORE],p1[NUM_THREAD_PER_CORE],p1[0],mono);
   p2[0]=mono;
   p2[NUM_THREAD_PER_CORE]=mono;
   p2[2*NUM_THREAD_PER_CORE]=mono;
}

_kernel_ void copy::split2split_reverse() {
   p2[0]=p1[2*NUM_THREAD_PER_CORE];
   p2[NUM_THREAD_PER_CORE]=p1[NUM_THREAD_PER_CORE];
   p2[2*NUM_THREAD_PER_CORE]=p1[0];
}

_kernel_ void copy::interleave2interleave() {
   p2[0]=p1[0];
   p2[1]=p1[1];
   p2[2]=p1[2];
}

_kernel_ void copy::interleaveRGB2interleave_mono() {
   float8 mono;
   RGB2MONO(p1[0],p1[1],p1[2],mono);
   p2[0]=mono;
   p2[1]=mono;
   p2[2]=mono;
}

_kernel_ void copy::interleaveBGR2interleave_mono() {
   float8 mono;
   RGB2MONO(p1[2],p1[1],p1[0],mono);
   p2[0]=mono;
   p2[1]=mono;
   p2[2]=mono;
}

_kernel_ void copy::interleave2interleave_reverse() {
   p2[0]=p1[2];
   p2[1]=p1[1];
   p2[2]=p1[0];
}

_kernel_ void copy::split_mono2interleave_mono() {
   p2[0]=p1[0];
   p2[1]=p1[0];
   p2[2]=p1[0];
}

_kernel_ void copy::mono2mono() {
   p2[0]=p1[0];
}

_kernel_ void copy::interleaveRGB2mono() {
   RGB2MONO(p1[0],p1[1],p1[2],p2[0]);
}

_kernel_ void copy::splitRGB2mono() {
   RGB2MONO(p1[0],p1[NUM_THREAD_PER_CORE],p1[2*NUM_THREAD_PER_CORE],p2[0]);
}

_kernel_ void copy::interleaveBGR2mono() {
   RGB2MONO(p1[2],p1[1],p1[0],p2[0]);
}

_kernel_ void copy::splitBGR2mono() {
   RGB2MONO(p1[2*NUM_THREAD_PER_CORE],p1[NUM_THREAD_PER_CORE],p1[0],p2[0]);
}



