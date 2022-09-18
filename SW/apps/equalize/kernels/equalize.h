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

#ifndef APPS_EQUALIZE_KERNELS_EQUALIZE_H_
#define APPS_EQUALIZE_KERNELS_EQUALIZE_H_

extern void kernel_equalize_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _output2,
   int _nchannels,
   unsigned int _equalize,
   int _w,
   int _h
   );

#define kHistogramInSize   8  // Number of pixels to be processed per thread
#define kHistogramBinSize  4  // Size of histogram bin in vector unit
#define kHistogramBinBit   3  // Number of bit to shift data to get index into histogram bin 

#define HISTOGRAM_HI_FACTOR 1000 // Multiplication factor for histogram hi value 

#endif
