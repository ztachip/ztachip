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

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include "../src/soc.h"
#ifndef SIMULATION
#ifdef ZTACHIP_UNIT_TEST
#include "../fs/gen/optical_flow_1_in.c"
#include "../fs/gen/optical_flow_2_in.c"
#include "../fs/gen/optical_flow_It.c"
#include "../fs/gen/optical_flow_Ix.c"
#include "../fs/gen/optical_flow_Iy.c"
#include "../fs/gen/optical_flow_vx.c"
#include "../fs/gen/optical_flow_vy.c"
#include "../fs/gen/color_conversion_100_100_in.c"
#include "../fs/gen/color_conversion_monochrome_100_100_out.c"
#include "../fs/gen/color_conversion_bgr_interleave_100_100_out.c"
#include "../fs/gen/color_conversion_rgb_interleave_100_100_out.c"
#include "../fs/gen/color_conversion_bgr_split_100_100_out.c"
#include "../fs/gen/color_conversion_rgb_split_100_100_out.c"
#include "../fs/gen/canny_200_in.c"
#include "../fs/gen/canny_final_out.c"
#include "../fs/gen/canny_magnitude_out.c"
#include "../fs/gen/canny_phase_out.c"
#include "../fs/gen/canny_200_out.c"
#include "../fs/gen/canny_maxima_out.c"
#include "../fs/gen/harris_corner_200_in.c"
#include "../fs/gen/harris_after_suppression.c"
#include "../fs/gen/resize_248_140.c"
#include "../fs/gen/resize_320_172.c"
#include "../fs/gen/resize_400_180.c"
#include "../fs/gen/resize_560_200.c"
#include "../fs/gen/resize_660_256.c"
#include "../fs/gen/resize_768_300.c"
#include "../fs/gen/resize_800_400.c"
#include "../fs/gen/resize.c"
#include "../fs/gen/gaussian_200_in.c"
#include "../fs/gen/gaussian_200_out.c"
#include "../fs/gen/histogram_in.c"
#include "../fs/gen/histogram_out.c"
#include "../fs/gen/classifier.c"
#include "../fs/gen/classifier_input.c"
#include "../fs/gen/ssd_input.c"
#include "../fs/gen/detect_boxes.c"
#include "../fs/gen/detect_classes.c"
#endif
#include "../fs/gen/alphabet.c"
#include "../fs/gen/alphabet2.c"
#include "../fs/gen/mobilenet_v2_1_0_224_quant.c"
#include "../fs/gen/labels_mobilenet_quant_v1_224.c"
#include "../fs/gen/detect.c"
#include "../fs/gen/labelmap.c"
#endif

// This file implements functions required by newlib
// Functions implement filesystem calls, task management and memory management

#define FP_FIRST    (STDERR_FILENO+1)
#define FP_MAX_NUM  16

extern void _heap_start();
extern void _heap_end();

static unsigned int heap=(unsigned int)_heap_start;

// List of files opened

static struct {
   bool status;
   int len;
   int curr;
   const uint8_t *body;
} files[FP_MAX_NUM];

// Kill a process
// Not implemented...

int _kill(int pid, int sig) {
    errno = EINVAL;
    return -1;
}

// Get process id
// There is only one process

int _getpid(void) {
    return 1;
}

// Is file console output

int _isatty(int file) {
    return (file == STDOUT_FILENO || file == STDERR_FILENO);
}

// Exit a process
// Not implemented

void _exit(int code) {
    for(;;) {}
}

// Allocate memory block from heap

void *_sbrk (int nbytes) {
   void *p;
   p=(void *)heap;
   heap += nbytes;
   if(heap >= (unsigned int)_heap_end)
      _exit(-1);
   return p;
}

// Return amount of heap that get used

unsigned int heap_usage() {
    return (unsigned int)heap-(unsigned int)_heap_start;
}

unsigned int heap_avail() {
    return (unsigned int)_heap_end-(unsigned int)heap;
}

// Open a file
// There are some files pre-defined as C array

int _open(const char *name, int flags, int mode) {
   int i;
   for(i=0;i < FP_MAX_NUM;i++) {
      if(!files[i].status)
         break;
   }
   if(i >= FP_MAX_NUM) {
      errno = ENOENT;
      return -1;
   }
#ifndef SIMULATION
   if(strcmp(name,"alphabet.bmp")==0) {
      files[i].status=true;
      files[i].curr=0;
      files[i].len=sizeof(alphabet);
      files[i].body=alphabet;
   } else if(strcmp(name,"alphabet2.bmp")==0) {
      files[i].status=true;
      files[i].curr=0;
      files[i].len=sizeof(alphabet2);
      files[i].body=alphabet2;
   } else if(strcmp(name,"mobilenet_v2_1_0_224_quant.tflite")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(mobilenet_v2_1_0_224_quant);
      files[i].body=mobilenet_v2_1_0_224_quant;
   } else if(strcmp(name,"labels_mobilenet_quant_v1_224.txt")==0) {
      files[i].status=true;
      files[i].curr=0;
      files[i].len=sizeof(labels_mobilenet_quant_v1_224);
      files[i].body=labels_mobilenet_quant_v1_224;
   } else if(strcmp(name,"detect.tflite")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(detect);
      files[i].body=detect;
   } else if(strcmp(name,"labelmap.txt")==0) {
      files[i].status=true;
      files[i].curr=0;
      files[i].len=sizeof(labelmap);
      files[i].body=labelmap;
#ifdef ZTACHIP_UNIT_TEST
   } else if(strcmp(name,"optical_flow_1_in")==0) {
      files[i].status=true;
      files[i].curr=0;
      files[i].len=sizeof(optical_flow_1_in);
      files[i].body=optical_flow_1_in;
   } else if(strcmp(name,"optical_flow_2_in")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(optical_flow_2_in);
      files[i].body=optical_flow_2_in;
   } else if(strcmp(name,"optical_flow_It.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(optical_flow_It);
      files[i].body=optical_flow_It;
   } else if(strcmp(name,"optical_flow_Ix.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(optical_flow_Ix);
      files[i].body=optical_flow_Ix;
   } else if(strcmp(name,"optical_flow_Iy.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(optical_flow_Iy);
      files[i].body=optical_flow_Iy;
   } else if(strcmp(name,"optical_flow_vx.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(optical_flow_vx);
      files[i].body=optical_flow_vx;
   } else if(strcmp(name,"optical_flow_vy.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(optical_flow_vy);
      files[i].body=optical_flow_vy;
   } else if(strcmp(name,"color_conversion_100_100_in.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(color_conversion_100_100_in);
      files[i].body=color_conversion_100_100_in;
   } else if(strcmp(name,"color_conversion_monochrome_100_100_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(color_conversion_monochrome_100_100_out);
      files[i].body=color_conversion_monochrome_100_100_out;
   } else if(strcmp(name,"color_conversion_bgr_interleave_100_100_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(color_conversion_bgr_interleave_100_100_out);
      files[i].body=color_conversion_bgr_interleave_100_100_out;
   } else if(strcmp(name,"color_conversion_rgb_interleave_100_100_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(color_conversion_rgb_interleave_100_100_out);
      files[i].body=color_conversion_rgb_interleave_100_100_out;
   } else if(strcmp(name,"color_conversion_bgr_split_100_100_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(color_conversion_bgr_split_100_100_out);
      files[i].body=color_conversion_bgr_split_100_100_out;
   } else if(strcmp(name,"color_conversion_rgb_split_100_100_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(color_conversion_rgb_split_100_100_out);
      files[i].body=color_conversion_rgb_split_100_100_out;
   } else if(strcmp(name,"canny_200_in.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(canny_200_in);
      files[i].body=canny_200_in;
   } else if(strcmp(name,"canny_final_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(canny_final_out);
      files[i].body=canny_final_out;
   } else if(strcmp(name,"canny_magnitude_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(canny_magnitude_out);
      files[i].body=canny_magnitude_out;
   } else if(strcmp(name,"canny_phase_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(canny_phase_out);
      files[i].body=canny_phase_out;
   } else if(strcmp(name,"canny_200_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(canny_200_out);
      files[i].body=canny_200_out;
   } else if(strcmp(name,"canny_maxima_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(canny_maxima_out);
      files[i].body=canny_maxima_out;
   } else if(strcmp(name,"harris_corner_200_in.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(harris_corner_200_in);
      files[i].body=harris_corner_200_in;
   } else if(strcmp(name,"harris_after_suppression.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(harris_after_suppression);
      files[i].body=harris_after_suppression;
   } else if(strcmp(name,"resize_248_140.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize_248_140);
      files[i].body=resize_248_140;
   } else if(strcmp(name,"resize_320_172.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize_320_172);
      files[i].body=resize_320_172;
   } else if(strcmp(name,"resize_400_180.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize_400_180);
      files[i].body=resize_400_180;
   } else if(strcmp(name,"resize_560_200.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize_560_200);
      files[i].body=resize_560_200;
   } else if(strcmp(name,"resize_660_256.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize_660_256);
      files[i].body=resize_660_256;
   } else if(strcmp(name,"resize_768_300.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize_768_300);
      files[i].body=resize_768_300;
   } else if(strcmp(name,"resize_800_400.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize_800_400);
      files[i].body=resize_800_400;
   } else if(strcmp(name,"resize.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(resize);
      files[i].body=resize;
   } else if(strcmp(name,"gaussian_200_in.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(gaussian_200_in);
      files[i].body=gaussian_200_in;
   } else if(strcmp(name,"gaussian_200_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(gaussian_200_out);
      files[i].body=gaussian_200_out;
   } else if(strcmp(name,"histogram_out.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(histogram_out);
      files[i].body=histogram_out;
   } else if(strcmp(name,"histogram_in.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(histogram_in);
      files[i].body=histogram_in;
   } else if(strcmp(name,"classifier.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(classifier);
      files[i].body=classifier;
   } else if(strcmp(name,"classifier_input.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(classifier_input);
      files[i].body=classifier_input;
   } else if(strcmp(name,"ssd_input.bmp")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(ssd_input);
      files[i].body=ssd_input;
   } else if(strcmp(name,"detect_boxes.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(detect_boxes);
      files[i].body=detect_boxes;
   } else if(strcmp(name,"detect_classes.bin")==0) {
	  files[i].status=true;
	  files[i].curr=0;
      files[i].len=sizeof(detect_classes);
      files[i].body=detect_classes;
#endif
   } else {
      errno = ENOENT;
      return -1;
   }
   return i+FP_FIRST;
#else
   errno = ENOENT;
   return -1;
#endif
}

// Close a file

int _close(int file) {
   file -= FP_FIRST;
   if((file < 0 || file >= FP_MAX_NUM) || !files[file].status) {
      errno = EBADF;
      return -1;
   }
   files[file].status=false;
   return 0;
}

// Read from an opened file

ssize_t _read(int file, void *ptr, size_t len) {
   int remain;
   file -= FP_FIRST;
   if((file < 0 || file >= FP_MAX_NUM) || !files[file].status) {
      errno = EBADF;
      return -1;
   }
   remain=files[file].len-files[file].curr;
   if(len > remain)
      len=remain;
   memcpy(ptr,files[file].body+files[file].curr,len);
   files[file].curr += len;
   return len;
}

// Get statistics about the file such as its length

int _fstat(int file, struct stat *st) {
   file -= FP_FIRST;
   if((file < 0 || file >= FP_MAX_NUM) || !files[file].status) {
      errno = EBADF;
      return -1;
   }
   memset(st,0,sizeof(struct stat));
   st->st_size=files[file].len;
   return 0;
}

// Write to a file
// Not implemented

ssize_t _write(int fd, const void *ptr, size_t len) {
   if(fd == STDOUT_FILENO || fd == STDERR_FILENO) {
      int i;
      char *p;
      for(i=0,p=(char *)ptr;i < len;i++,p++) {
         while(UartWriteAvailable()==0);
         UartWrite(*p);
      }
      return len;
   }
   else {
      errno = ENOSYS;
      return -1;
   }
}

// Position a read cursor of an opened file

off_t _lseek(int file, off_t ptr, int dir) {
   file -= FP_FIRST;
   if((file < 0 || file >= FP_MAX_NUM) || !files[file].status) {
      errno = EBADF;
      return -1;
   }
   if(dir==SEEK_SET)
      files[file].curr=ptr;
   else if(dir==SEEK_CUR)
      files[file].curr+=ptr;
   else
      files[file].curr=files[file].len;
   if(files[file].curr>files[file].len)
      files[file].curr=files[file].len;
   return files[file].curr;
}
