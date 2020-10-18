#ifndef _ZTA_TYPES_H_
#define _ZTA_TYPES_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>

typedef enum {
   ZtaStatusOk=0,
   ZtaStatusFail=-1,
   ZtaStatusBusy=1,
   ZtaStatusPending=2
} ZtaStatus;

#define ROUND(a,b)  ((((a)+(b)-1)/(b))*(b))
#define ABS(a) (((a)>=0)?(a):(-(a)))

#ifndef uint32_t
typedef unsigned int uint32_t;
#endif
#ifndef int32_t
typedef int int32_t;
#endif
#ifndef uint8_t
typedef unsigned char uint8_t;
#endif
#ifndef int8_t
typedef signed char int8_t;
#endif
#ifndef uint16_t
typedef unsigned short uint16_t;
#endif
#ifndef int16_t
typedef short int16_t;
#endif

#endif
