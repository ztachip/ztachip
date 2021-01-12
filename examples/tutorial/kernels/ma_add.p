#include "../../../software/target/base/zta.h"

_NT16_ class ma_add;

float8 ma_add::x;
float8 ma_add::y;
float8 ma_add::z;

// Matrix addition
_kernel_ void ma_add::add()
{
   z=x+y;
}

