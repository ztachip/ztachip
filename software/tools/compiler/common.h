#ifndef _COMMON_H_
#define _COMMON_H_

#define ZTA_OK      0
#define ZTA_FAIL   -1
#define ZTA_PENDING 1

#define ZTA_FOREVER -1

#define DIM(a) (sizeof(a)/sizeof((a)[0]))
#define ABS(a)   (((a)>=0)?(a):-(a))
#ifdef MAX
#undef MAX
#endif
#define MAX(a,b)   (((a)>(b))?(a):(b))
#ifdef MIN
#undef MIN
#endif
#define MIN(a,b)   (((a)<(b))?(a):(b))

#define DIMENSION(a)  (sizeof(a)/sizeof((a)[0]))

// Max string length
#define MAX_STRING_LEN   256      // Maximum string size

// Round a number to nearest multiple of a
#define ROUND(a,b)  ((((a)+(b)-1)/(b))*(b))

// Convert 32bit number from host format to network format
#define H2N(h,n)  {(n)[0]=(((h)>>24)&0xff);(n)[1]=(((h)>>16)&0xff);(n)[2]=(((h)>>8)&0xff);(n)[3]=((h)&0xff);}

// Convert 16 bit number from network format to host format
#define N2H(n,h)  {(h)=(((uint32_t)((n)[0]))<<24)+(((uint32_t)((n)[1]))<<16)+(((uint32_t)((n)[2]))<<8)+(((uint32_t)((n)[3]))<<0);}

// Convert 16bit number from host format to network format
#define H2N16(h,n)  {(n)[0]=(((h)>>8)&0xff);(n)[1]=((h)&0xff);}

// Convert 16 bit number from network format to host format
#define N2H16(n,h)  {(h)= (((uint16_t)((n)[0]))<<8) + (((uint16_t)((n)[1]))<<0);}

#endif
