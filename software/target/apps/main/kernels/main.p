#include "../../../base/zta.h"

_NT16_ class main;

// Current main module has no assiated pcore
// Create a dummy one anyway since the build now expects a pcore
// image for each mcore image

_kernel_ void main::dummy(float x)
{
   x=1;
}

