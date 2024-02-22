#include <stdlib.h>
#include "../base/ztalib.h"
#include "soc.h"
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

//-----------------------------------------
// Application main entry
// 2 execution cases: vision example or test suites.
//-----------------------------------------

int main() {
   ztaInit();

#ifdef ZTACHIP_UNIT_TEST
   while(1){
      test();
   }
#else
   for(;;) {
      vision_ai();
   }
#endif
    return 0;
}

void irqCallback() {
}
