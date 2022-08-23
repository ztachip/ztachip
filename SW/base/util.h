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

#ifndef _ZTA_UTIL_H_
#define _ZTA_UTIL_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdint.h>
#include <vector>
#include "types.h"
#include "tensor.h"

// Some general utility functions...

class Util {
public:
   static void Float2Int(float *in,int16_t *out,int pos,int len);
   static void Int2Float(int16_t *in,float *out,int pos,int len);
   static float pow(float x,int power);
   static size_t GetTensorSize(std::vector<int>& shape);
};

ZtaStatus BitmapRead(const char *bmpFile,TENSOR *outputTensor,TensorFormat fmt=TensorFormatSplit);

#endif
