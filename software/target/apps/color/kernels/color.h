#ifndef _COLOR_H_
#define _COLOR_H_

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