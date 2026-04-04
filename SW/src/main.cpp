#include <stdlib.h>
#include <stdio.h>
#include "../base/ztalib.h"
#include "../apps/gdi/gdi.h"
#include "soc.h"
#include "../base/net.h"

extern "C"
{
extern int main(void);
extern void irqCallback(void);
}

// __dso_handle is function pointer to do any cleanup of global object when 
// program exit.
// But this is a baremetal embedded system so we never have a program exit
// except when doing a reboot
// Set __dso_handle to zero

void *__dso_handle=0;

extern int test(void);

extern int vision_ai(void);

extern int chat();

extern void test_llm();

//-----------------------------------------
// Application main entry
// 2 execution cases: vision example or test suites.
//-----------------------------------------

int main() {
   ztaInit();
   GdiInit();
   NetInit(0x0a0a0a63); // My local IP=10.10.10.99

#ifdef ZTACHIP_UNIT_TEST
   // Run unit tests against test vectors
   while(1){
      test();
      // test_llm(); 
   }
#endif

#ifdef ZTACHIP_LLM_TEST
   // Run chatbot with smollm2-135M LLM model
   for(;;) {
      chat();
   }
#endif

   // Run various vision tests
   //   - object detection
   //   - image classfication
   //   - optical flow
   //   - Harris-Corner point-of-interests
   //   - Edge detection
   DisplayInit(DISPLAY_WIDTH,DISPLAY_HEIGHT);
   CameraInit(WEBCAM_WIDTH,WEBCAM_HEIGHT);
   for(;;) {
      vision_ai();
   }
   return 0;
}

void irqCallback() {
}
