#include "../../../software/target/base/zta.h"

_NT16_ class TEST;

_kernel_ void TEST::exe(float p[8])
{
   int i;
   for(i=0;i < 8;i++)
   {
      p[i]=p[i]+1;
   }
}

