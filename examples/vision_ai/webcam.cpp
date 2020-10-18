#include <errno.h>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>
#include "webcam.h"

// WEBCAM driver

#define WEBCAM_QUEUE_SIZE  1 
static uint8_t *buffer_virtual[WEBCAM_QUEUE_SIZE];
static uint32_t buffer_physical[WEBCAM_QUEUE_SIZE];
static int fd=-1;
static int webcam_w,webcam_h;

static int xioctl(int fd, int request, void *arg) {
   int r;
   do r = ioctl (fd, request, arg);
   while (-1 == r && EINTR == errno);
   return r;
}

// Initialize webcam for capturing
// Allocate buffers.
// We need 2 buffers inorder to capture images in a ping-pong
// fashion so that image processing can overlap with next
// image capture...

int WebcamInit(int w,int h) {

   // Configure webcam for 640/480 image size and
   // data format YUYV

   fd = open("/dev/video0", O_RDWR);
   if (fd == -1) {
      perror("Opening video device");
      return 1;
   }
   webcam_w=w;
   webcam_h=h;

   struct v4l2_format fmtReq = {0};
   fmtReq.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
   fmtReq.fmt.pix.width = w; 
   fmtReq.fmt.pix.height = h;
   fmtReq.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
   fmtReq.fmt.pix.field = V4L2_FIELD_NONE;
   if (-1 == xioctl(fd, VIDIOC_S_FMT, &fmtReq)) {
      perror("Setting Pixel Format");
      return -1;
   }

   // Allocate 2 buffers for capturing...
   
   struct v4l2_requestbuffers bufAllocReq = {0};
   bufAllocReq.count = WEBCAM_QUEUE_SIZE;
   bufAllocReq.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
   bufAllocReq.memory = V4L2_MEMORY_MMAP;
   // Allocate buffers. Just need 1
   if (-1 == xioctl(fd, VIDIOC_REQBUFS, &bufAllocReq)) {
      perror("Requesting Buffer");
      return -1;
   }

   // Query about the allocated buffer

   struct v4l2_buffer bufReq = {0};
   bufReq.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
   bufReq.memory = V4L2_MEMORY_MMAP;
   bufReq.index = 0;

   for(int i=0;i < WEBCAM_QUEUE_SIZE;i++) {
      bufReq.index = i;
      if(-1 == xioctl(fd, VIDIOC_QUERYBUF, &bufReq)) {
         perror("Querying Buffer");
         return -1;
      }
      buffer_physical[i]=bufReq.m.offset; 
      buffer_virtual[i]=(uint8_t *)mmap(NULL,bufReq.length,PROT_READ|PROT_WRITE,MAP_SHARED,fd,bufReq.m.offset);
   }

   // Turn on streaming...

   if(-1 == xioctl(fd,VIDIOC_STREAMON,&bufReq.type)) {
      perror("Start Capture");
      return -1;
   }

   // Queue buffers to receive webcam images

   for(int i=0;i < WEBCAM_QUEUE_SIZE;i++) {
      bufReq.index=i;
      if(-1 == xioctl(fd,VIDIOC_QBUF,&bufReq)) {
         perror("Query Buffer");
         return 1;
      }
   }
   return 0;
}

// Capture camera input

bool WebcamCapture(uint16_t *imageCapture) {
   struct v4l2_buffer bufReq = {0};
   fd_set fds;

   FD_ZERO(&fds);
   FD_SET(fd, &fds);
   struct timeval tv;
   tv.tv_sec=0;
   tv.tv_usec=0;
   // Wait for capture image becomes available...
   int r = select(fd+1,&fds,NULL,NULL,&tv);
   if(r <= 0) {
      return false;
   }

   bufReq.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
   bufReq.memory = V4L2_MEMORY_MMAP;
   bufReq.index = 0;
   // Get received image buffer
   if(-1 == xioctl(fd, VIDIOC_DQBUF, &bufReq)) {
      return false;
   }
   memcpy(imageCapture,buffer_virtual[bufReq.index],webcam_w*webcam_h*2);
   // Resubmit request
   if(-1 == xioctl(fd,VIDIOC_QBUF,&bufReq)) {
      return false;
   }
   return true;
}

// Done. Close the webcam

void WebcamClose() {
   if(fd >= 0) {
      close(fd);
      fd=-1;
   }
}

