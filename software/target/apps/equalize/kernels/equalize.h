#ifndef APPS_EQUALIZE_KERNELS_EQUALIZE_H_
#define APPS_EQUALIZE_KERNELS_EQUALIZE_H_

#define kHistogramInSize   8  // Number of pixels to be processed per thread
#define kHistogramBinSize  4  // Size of histogram bin in vector unit
#define kHistogramBinBit   3  // Number of bit to shift data to get index into histogram bin 

#define HISTOGRAM_HI_FACTOR 1000 // Multiplication factor for histogram hi value 

#endif