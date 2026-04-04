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
#ifdef __cplusplus
extern "C" {
#endif
#include <stdio.h>
#include <stdint.h>
#include "types.h"

extern void randInit(uint32_t _seed);

extern float randGen();

// Some common macros

#define ROUND(a,b)  ((((a)+(b)-1)/(b))*(b))

#define ABS(a)  (((a)>=0)?(a):(-(a)))

#define MAX(a,b)  (((a)>(b))?(a):(b))

#define MIN(a,b)  (((a)<(b))?(a):(b))

#define DIM(a)  (sizeof(a)/sizeof((a)[0]))

// Convert between network oder and byte order

#define H2N(h,n)  {(n)[0]=(((h)>>24)&0xff);(n)[1]=(((h)>>16)&0xff);(n)[2]=(((h)>>8)&0xff);(n)[3]=((h)&0xff);}

#define N2H(n,h)  {(h)=(((uint32_t)((n)[0]))<<24)+(((uint32_t)((n)[1]))<<16)+(((uint32_t)((n)[2]))<<8)+(((uint32_t)((n)[3]))<<0);}

#define H2N16(h,n)  {(n)[0]=(((h)>>8)&0xff);(n)[1]=((h)&0xff);}

#define N2H16(n,h)  {(h)= (((uint16_t)((n)[0]))<<8) + (((uint16_t)((n)[1]))<<0);}

// Some general utility functions...

int16_t FLOAT2INT(float in);

uint8_t *bmpRead(const char *filename,int *h,int *w);

// Convert from BFLOAT to FLOAT
inline float BF2F(float16_t x) {
    float y;
    ((uint16_t *)&y)[0] = 0;    
    ((uint16_t *)&y)[1] = x;
    return y;
}

// Convert from float to BFLOAT
inline float16_t F2BF(float x) {
    return ((uint16_t *)&x)[1];
}

inline float16_t F2FP16(float x) {
    union { float f; uint32_t u; } v;
    uint32_t f_bits;
    uint32_t sign;
    int32_t exp;
    uint32_t mant;
    bool round;

    v.f = x;
    f_bits = v.u;
    sign = (f_bits >> 16) & 0x8000;
    exp = ((f_bits >> 23) & 0xFF) - 127;
    mant = f_bits & 0x7FFFFF;
    exp += 15;
    mant >>= 12;
    round = (mant&1)?true:false;
    mant >>= 1;
    if(round && mant != 0x3ff)
        mant++;
    if (exp <= 0)
        return 0;
    if (exp >= 31)
        return (sign | 0x7C00);
    return sign | (exp << 10) | mant;
}

inline float FP16_2_F(float16_t x) {
    union { uint32_t u; float f; } v;
    uint32_t sign = (x & 0x8000) << 16;
    uint32_t exp  = (x & 0x7C00) >> 10;
    uint32_t mant = (x & 0x03FF);

    if(exp == 0) {
        // zero/subnormal treat as zero
        v.u = sign;
    } else if(exp == 0x1F) {
        // Inf/NaN
        v.u = sign | 0x7F800000 | (mant << 13);
    } else {
        // normalized
        exp = exp + (127 - 15);
        v.u = sign | (exp << 23) | (mant << 13);
    }
    return v.f;
}

inline int BFCMP(float16_t a,float16_t b) {
    // Transform sign-magnitude bits to linear signed integers
    // If sign bit is set, value = -(magnitude). Else, value = magnitude.
    int16_t ia = (a & 0x8000)? -(int16_t)(a & 0x7FFF):(int16_t)a;
    int16_t ib = (b & 0x8000)? -(int16_t)(b & 0x7FFF):(int16_t)b;
    return (ia > ib) - (ia < ib);
}

// cast float to its hex presentation

#define F2HEX(x)  (*((uint32_t *)(&(x))))

#ifdef __cplusplus
}
#endif
#endif
