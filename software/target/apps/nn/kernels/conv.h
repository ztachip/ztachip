#ifndef _CONV_H_
#define _CONV_H_

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
#define CONV_1X1_BOTSZ 512
#define CONV_1X1_Y_DIM 8

// Concatenation kernel
#define CONCATENATE_BUFSZ 1600

#endif