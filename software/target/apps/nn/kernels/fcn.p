#include "../../../base/zta.h"
#include "fcn.h"

_NT16_ class inner_product,max_pool,concatenate;

//---  Process fully-connected layer (innerproduct)

_share float inner_product::bot[IP_CHUNK_SIZE];
float8 inner_product::coef[IP_CHUNK_SIZE];
float8 inner_product::top;
float inner_product::out_scale;
double8 inner_product::_A;
float8 inner_product::biasHi;
float8 inner_product::biasLo;

_kernel_ void inner_product::init(float _out_scale) {
   out_scale=_out_scale;
}

_kernel_ void inner_product::start() {
   _A = biasLo;
   _A += biasHi*1024;
}

_kernel_ void inner_product::exe() {
   int i;
#pragma unroll
   for(i=0;i < IP_CHUNK_SIZE;i++) {
      _A += bot[i]*coef[i];
   }
}

// Activation

_kernel_ void inner_product::activate_none() {
   _A = _A >> out_scale-18;
   _A = _A >> out_scale-15; 
   _A = _A >> out_scale-12; 
   _A = _A >> out_scale-9; 
   _A = _A >> out_scale-6; 
   _A = _A >> out_scale-3; 
   top = _A >> out_scale;
}

// ---- Pooling layer...

float8 max_pool::bot[POOL_BOT_SIZE];
double8 max_pool::_A;
float max_pool::out_scale;
float8 max_pool::top;

_kernel_ void max_pool::init(float _out_scale) {
   out_scale=_out_scale;
   _A=0;
}

// Do pooling averate.
// Since pcore cannot do division, just do addition here
// Divide for averaging is done by stream processor later
 
_kernel_ void max_pool::exe() {
   float8 *p;
   int i;
   p=bot;
#pragma unroll
   for(i=0;i < POOL_BOT_SIZE;i++) {
      _A += p[0];
      p++;
   }
}

_kernel_ void max_pool::finish() {
   _A = _A >> out_scale-18;
   _A = _A >> out_scale-15; 
   _A = _A >> out_scale-12; 
   _A = _A >> out_scale-9; 
   _A = _A >> out_scale-6; 
   _A = _A >> out_scale-3; 
   top = _A >> out_scale;
   _A = 0;
}

// --- Do concatenation layer.

_share float concatenate::buf[CONCATENATE_BUFSZ];

// No pcore code required for concatenation layer
// Concatenation layer is processed by mcore and stream processor only

_kernel_ void concatenate::dummy(float _dummy) {
   buf[0]=_dummy;
}
