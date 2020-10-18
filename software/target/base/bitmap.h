#ifndef SOFTWARE_TARGET_BASE_BITMAP_H_
#define SOFTWARE_TARGET_BASE_BITMAP_H_

#include <stdint.h>
#include "tensor.h"

ZtaStatus BitmapRead(const char *bmpFile,TENSOR *outputTensor);
ZtaStatus BitmapWrite(const char *fileName,TENSOR *image);

#endif
