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

#ifndef _COLOR_H_
#define _COLOR_H_

extern void kernel_copy_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   int _w,
   int _h,
   int _src_channel_fmt,
   int _src_channel_color,
   int _dst_channel_fmt,
   int _dst_channel_color,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_x,
   int _dst_y,
   int _dst_w,
   int _dst_h,
   unsigned int _equalize);

extern void kernel_yuyv2rgb_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _spu,
   int _w,
   int _h,
   int _dst_channel_fmt,
   int _dst_channel_color,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_x,
   int _dst_y,
   int _dst_w,
   int _dst_h
);

// Image data format
#define kChannelFmtInterleave 0 // Color but color are interleaved
#define kChannelFmtSplit      1 // Color but color space are split
#define kChannelFmtSingle     2 // Single color...

// Image color format
#define kChannelColorRGB      0 // Order is red-green-blue
#define kChannelColorBGR      1 // Order is blue-green-red
#define kChannelColorMono     2 // Single channel so not applicable

// Number of bytes per YUYV pixel
#define YUYV_PIXEL_SIZE   2

// Number of bytes per RGB pixel
#define RGB_PIXEL_SIZE    3

// Number of pixels processed per thread
#define PIXEL_PER_THREAD  2

#define YUYV_BUF_SIZE  (YUYV_PIXEL_SIZE*PIXEL_PER_THREAD*NUM_THREAD_PER_CORE)

#define RGB_BUF_SIZE  (RGB_PIXEL_SIZE*PIXEL_PER_THREAD*NUM_THREAD_PER_CORE)

// RGB->RGB

#define RGB2RGB_BUF_SIZE (RGB_PIXEL_SIZE*NUM_THREAD_PER_CORE)


#endif
