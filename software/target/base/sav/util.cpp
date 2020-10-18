#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "types.h"
#include "ztahost.h"
#include "util.h"

// Some general utility functions...

// Raise to power

float Util::pow(float x,int power) {
   float y=1.0;
   for(int i=0;i < power;i++)
      y=y*x;
   return y;
}

// Convert from float to int12 format
// pos is position of decimal point

void Util::Float2Int(float *in,int16_t *out,int pos,int len) {
   bool flag;
   unsigned int v;
   int v2;
   int e, e2;
   short result;
   for (int i = 0; i < len; i++) {
      v = *((unsigned int *)&in[i]);
      if (v == 0) {
         result=0;
      } else {
         flag = false;
         e = (v >> 23) & 0xff;
         e2 = e-127;
         v2 = (v & 0x007FFFFF);
         v2 |= 0x00800000;
         if (pos >= (e2 + 1)) {
            v2 = v2 >> (pos - e2 - 1);
         } else {
            v2 = 0x00FFFFFF;
            flag=true;
         }
         result = (v2 >> 9)&(0x7fff);
         if (v2 & 0x100) {
            if (result < 0x7FFF) {
               result++;
            } else {
               flag = true;
            }
         }
         if (v & 0x80000000)
            result = -result;
         if (flag) {
            if (result < 0) {
               result=(short)(0x8000);
            }
         }
      }
      out[i]=(result>>4);
   }
}

// Convert from int12 format to float
// pos is the position of decimal place.

void Util::Int2Float(int16_t *in,float *out,int pos,int len) {
   int v;
   for(int i=0;i < len;i++) {
      v=(int)in[i];
      if(v==0) {
         out[i]=0.0;
      } else {
         if(((DATA_BIT_WIDTH-1)-pos) >= 0)
            out[i]=(float)v/Util::pow((float)2.0,(DATA_BIT_WIDTH-1)-pos);
         else
            out[i]=(float)v*Util::pow((float)2.0,pos-(DATA_BIT_WIDTH-1));
      }
   }
}

// Return total tensor array size

size_t Util::GetTensorSize(std::vector<int>& shape) {
   size_t sz=1;
   for(int i=0;i < (int)shape.size();i++) {
      sz*=shape[i];
   }
   return sz;
}
