#include "../base/ztalib.h"
#include "../src/soc.h"

extern void kernel_test_exe();

int main()
{
   int i;
   int count=0;

   ztaInit();

   APB[APB_LED]=0;
   for(;;) {
      kernel_test_exe();
      count++;
      APB[APB_LED]=count;
   }
   return 0;
}

void irqCallback() {
}

