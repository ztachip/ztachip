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


#ifdef __cplusplus
}
#endif
#endif
