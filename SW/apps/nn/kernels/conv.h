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

#ifndef _CONV_H_
#define _CONV_H_
#ifdef __cplusplus
extern "C" {
#endif

extern void kernel_convolution_depthwise_exe(
   unsigned int _req_id,
   unsigned int _coef,
   unsigned int _biasHi,
   unsigned int _biasLo,
   unsigned int _bot,
   unsigned int _top,
   unsigned int _top_interleave,
   int _ksz,
   int _topcnt,
   int _topdim,
   int _botcnt,
   int _botdim,
   int _input_offset,
   int _activation_scale,
   unsigned int _stream,
   int _group,
   int _stride,
   int _pad,
   int _conv_dx,
   int _dycnt,
   int _groupsz,
   int _in_interleave,
   int _out_interleave
);

extern void kernel_convolution_exe(
   unsigned int _req_id,
   unsigned int _coef,
   unsigned int _biasHi,
   unsigned int _biasLo,
   unsigned int _bot,
   unsigned int _top,
   unsigned int _top_interleave,
   int _ksz,
   int _topcnt,
   int _topdim,
   int _botcnt,
   int _botdim,
   int _input_offset,
   int _activation_scale,
   unsigned int _stream,
   int _group,
   int _stride,
   int _pad,
   int _conv_dx,
   int _dycnt,
   int _groupsz,
   int _in_interleave,
   int _out_interleave
);

extern void kernel_add_exe(
   unsigned int _req_id,
   int _size,
   unsigned int _input_0,
   unsigned int _input_1,
   unsigned int _output,
   unsigned int _stream
);

#define MAX_KERNEL_SIZE  128 // Maximum kernel dimention allowed

#define MAX_SMALL_KERNEL_SIZE  49 // Maximum kernel dimention allowed

#define MAX_CONV_Y_DIM   2 // Max number of results per thread

#define IP_CHUNK_SIZE   8

#define MAX_POOL_STRIDE 2

#define RELU_CHUNK_SIZE 8

#define STRIDE  4

#define POOL_DIM_DX  8

#define POOL_DIM_DY  2

#define MAX_POOL_KERNEL 3

#define CONV_LARGE_BOT_DY 15

#define CONV_LARGE_BOT_DX 40

#define CONV_SMALL_BOT_DY 24

#define CONV_SMALL_BOT_DX 40

#define CONV_SMALL_BOTSZ 960

#define POOL_BOT_SIZE  8

// Convolution depthwise

#define MAX_DEPTHWISE_KERNEL_SIZE 9

#define CONV_DEPTHWISE_Y_DIM  3

#define CONV_DEPTHWISE_BOT_DY 10

#define CONV_DEPTHWISE_BOT_DX 16

#define CONV_DEPTHWISE_BOTSZ 160

// Convolution 1x1
//#define CONV_1X1_BOTSZ 512

#define CONV_1X1_BOTSZ 840

#define CONV_1X1_Y_DIM 8

// Concatenation kernel

#define CONCATENATE_BUFSZ 1600

#ifdef __cplusplus
}
#endif
#endif
