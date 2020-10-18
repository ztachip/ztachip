#ifndef _EXAMPLES_VISION_AI_WEBCAM_H_
#define _EXAMPLES_VISION_AI_WEBCAM_H_

extern int WebcamInit(int w,int h);
extern bool WebcamCapture(uint16_t *image);
extern void WebcamClose();

#endif
