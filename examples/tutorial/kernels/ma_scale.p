#include "../../../software/target/base/zta.h"

_NT16_ class ma_scale;

float8 ma_scale::x;
_share float ma_scale::scale;
float8 ma_scale::z;

// Matrix scaling 
_kernel_ void ma_scale::scale()
{
   z=x*scale;
}

