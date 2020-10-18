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

#endif