#include <stdlib.h>
extern "C"
{
#include "../base/ztam.h"
extern int main(void);
extern void irqCallback(void);
}

extern int test(void);

extern int vision_ai(void);

//-----------------------------------------
// Application main entry
// 2 execution cases: vision example or test suites.
//-----------------------------------------

int main() {
   ztamInit();
#if 1 
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
