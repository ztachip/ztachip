#include <stdlib.h>

extern "C" int main(void);

extern "C" void irqCallback(void);

extern int test(void);

extern int vision_ai(void);

//-----------------------------------------
// Application main entry
// 2 execution cases: vision example or test suites.
//-----------------------------------------

int main() {
#if 1 
   while(1){
      test();
   }
#endif

#if 0 
   for(;;) {
      vision_ai();
   }
#endif
    return 0;
}

void irqCallback() {
}
