#ifndef _ZTA_UTIL_H_
#define _ZTA_UTIL_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdint.h>
#include <vector>

// Some general utility functions...

class Util {
public:
   static void Float2Int(float *in,int16_t *out,int pos,int len);
   static void Int2Float(int16_t *in,float *out,int pos,int len);
   static float pow(float x,int power);
   static size_t GetTensorSize(std::vector<int>& shape);
};

#endif