//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

// This file implements the kernels for LLM but in plain C/C++ so that
// it can be run on PC

#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <math.h>
#include <stdlib.h>
#include "../../../../SW/base/types.h"
#include "../../../../SW/base/util.h"
#include "../../../../SW/src/soc.h"
#include "../kernels/llm_p.h"
#include "llm_ref.h"

extern void kernel_llm_done();

#define WDIM 6 // Number of dimensions of weight tensor

//#define TENSOR_IS_REORDER // Tensors are reordered for running on ztachip

// Round INT32 to INT32 but keep just 12 bit MSB if numbers need more than 12-bit accuracy
// This is to simulate when INT32 results from pcore get trasfered to outside of pcore memory
// space

static int32_t round12(int32_t v) {
   int v2;
   uint32_t mask;
   int pos;
   int shift;

   if (v == 0)
       return 0;
   if (v < 0)
      v2 = -v;
   else
      v2 = v;
   mask = 0x80000000;
   pos = 31;
   while ((v2 & mask) == 0)
   {
      mask = mask >> 1;
      pos--;
   }
   shift = pos - 11;
   if (shift > 0) {
      v2 = (v2 >> shift);
      v2 = (v2 << shift);
   }
   if (v < 0)
      v2 = -v2;
   return v2;
}

#ifdef TENSOR_IS_REORDER
inline uint32_t WV(uint32_t xx,uint32_t *e,uint32_t *e2,int *reshape) {
    uint32_t y=0;
    uint32_t x;
    for(uint32_t i=0;i < WDIM;i++) { 
        x = xx / e[i];
        xx -= x * e[i];
        y += x*e2[reshape[i]];
    }
    return y;
}

inline uint32_t WS(uint32_t xx,uint32_t N2,uint32_t D) {
    return ((xx/(N2))+(xx%(N2))*D);
}
#else
#define WV(a,b,c,d)  (a)
#define WS(a,b,c)  (a)
#endif

// This kernel reference function perform matrix multiplication y[D]=x[N]*w[D][N]
// activation x is quantized as Q8
// Weights w are quantized as Q4
// Results are in BFLOAT

void kernel_ref_llm_matmul_q4_exe(
   int _req_id,
   int N, // Dimension of _x and _w
   int D, // Result dimension _y
   int GS, // Quantized group
   int16_t *x_v, // x value vector with dimention Nx1
   float16_t *x_s, // x scaling vector with dimension (N/QS)x1
   uint8_t *w_v, // w value vector with dimension DxN
   float16_t *w_s, // w scaling vector with dimension Dx(N/QS)
   float16_t *result
) {
    uint32_t b;
    int32_t sum;
    uint8_t hi,lo;
    float r,sumf;
    int N2=N/GS_DEFAULT;
    uint32_t sz[WDIM],sz2[WDIM];
    int d[WDIM] = {D/VECTOR_WIDTH,VECTOR_WIDTH,N/GS_DEFAULT,GS_DEFAULT/LLM_GS/2,2,LLM_GS/2};
    int reshape[WDIM] = {2,5,1,0,3,4}; // tensor index mapping from original->new: 0->2;1->5;2->1;3->0;4->3;5->4
    int reshape_inv[WDIM]; // tensor index mapping from new to original
    assert(GS==GS_DEFAULT);

    for(int i=0;i < WDIM;i++)
        reshape_inv[reshape[i]] = i;
    for(int i=0;i < WDIM;i++) {
        sz[i] = 1;
        sz2[i] = 1;
        for(int j=i+1;j < WDIM;j++) {
            sz[i] *= d[j];
            sz2[i] *= d[reshape_inv[j]];
        }
    }

    for(uint32_t i=0;i < D;i++) {
        r = 0.0;
        for(uint32_t j=0,b=0;j < N;j += GS_DEFAULT,b++) {
            sum = 0;
            for(uint32_t k=0;k < GS_DEFAULT;k+=2) {
                hi = (w_v[WV(i*N/2+(j+k)/2,sz,sz2,reshape)] >> 4) & 0x0F;
                hi = (hi & 0x8)?(hi|0xF0):hi;
                lo = (w_v[WV(i*N/2+(j+k)/2,sz,sz2,reshape)] & 0x0F);
                lo = (lo & 0x8)?(lo|0xF0):lo;
                sum += ((int32_t)((int8_t)lo))*((int32_t)((int16_t)x_v[j+k]));
                sum += ((int32_t)((int8_t)hi))*((int32_t)((int16_t)x_v[j+k+1]));
            }
            sumf = round12(sum);
            r += BF2F(x_s[b])*(FP16_2_F(w_s[WS(i*N2+b,N2,D)])*(float)sumf);
        }
        result[i] = F2BF(r);
    }
}

#ifdef TENSOR_IS_REORDER
inline uint32_t WV2(uint32_t xx,uint32_t *e,uint32_t *e2,int *reshape) {
    uint32_t y=0;
    uint32_t x;
    for(uint32_t i=0;i < WDIM;i++) { 
        x = xx / e[i];
        xx -= x * e[i];
        y += x*e2[reshape[i]];
    }
    return y;
}

inline uint32_t WS2(uint32_t xx,uint32_t N2,uint32_t D) {
    return ((xx/(N2))+(xx%(N2))*D);
}
#else
#define WV2(a,b,c,d)  (a)
#define WS2(a,b,c)  (a)
#endif

// This kernel reference function perform matrix multiplication y[D]=x[N]*w[D][N]
// activation x is quantized as Q8
// Weights w are quantized as Q8
// Results are in BFLOAT

void kernel_ref_llm_matmul_q8_exe(
   int _req_id,
   int N, // Dimension of _x and _w
   int D, // Result dimension _y
   int GS, // Quantized group
   int16_t *x_v, // x value vector with dimention Nx1
   float16_t *x_s, // x scaling vector with dimension (N/QS)x1
   uint8_t *w_v, // w value vector with dimension DxN
   float16_t *w_s, // w scaling vector with dimension Dx(N/QS)
   float16_t *result
) {
    uint32_t b;
    int32_t sum;
    uint8_t hi,lo;
    float r,sumf;
    int N2=N/GS_DEFAULT;
    uint32_t sz[WDIM],sz2[WDIM];
    int d[WDIM] = {D/VECTOR_WIDTH,VECTOR_WIDTH,N/GS_DEFAULT,GS_DEFAULT/LLM_GS,1,LLM_GS};
    int reshape[WDIM] = {2,5,1,0,3,4}; // tensor index mapping from original->new: 0->2;1->5;2->1;3->0;4->3;5->4
    int reshape_inv[WDIM]; // tensor index mapping from new to original
    assert(GS==GS_DEFAULT);

    for(int i=0;i < WDIM;i++)
        reshape_inv[reshape[i]] = i;
    for(int i=0;i < WDIM;i++) {
        sz[i] = 1;
        sz2[i] = 1;
        for(int j=i+1;j < WDIM;j++) {
            sz[i] *= d[j];
            sz2[i] *= d[reshape_inv[j]];
        }
    }

    for(uint32_t i=0;i < D;i++) {
        r = 0.0;
        for(uint32_t j=0,b=0;j < N;j += GS_DEFAULT,b++) {
            sum = 0;
            for(uint32_t k=0;k < GS_DEFAULT;k+=2) {
                lo = w_v[WV2(i*N+(j+k),sz,sz2,reshape)];
                hi = w_v[WV2(i*N+(j+k+1),sz,sz2,reshape)];
                sum += ((int32_t)((int8_t)lo))*((int32_t)((int16_t)x_v[j+k]));
                sum += ((int32_t)((int8_t)hi))*((int32_t)((int16_t)x_v[j+k+1]));
            }
            sumf = round12(sum);
//            sumf = sum;
            r += BF2F(x_s[b])*FP16_2_F(w_s[WS2(i*N2+b,N2,D)])*sumf;
        }
        result[i] = F2BF(r);
    }
}

//--------------------------------------------------------------------------
// This is a reference kernel function 
// Quantize BFLOAT to INT8 + scaling factor
// This function is used to quantize activation before the matmul operation
//--------------------------------------------------------------------------

void kernel_ref_llm_quantize_exe(int reqId,int N,float16_t *x,float16_t *s,int16_t *q) {
    int num_groups = N / GS_DEFAULT;
    float Q_MAX = 2047.0f;
    float s_reciprocal;
//    float Q_MAX = 127.0f;

    for (int group = 0; group < num_groups; group++) {
        float wmax = 0.0;
        for (int i = 0; i < GS_DEFAULT; i++) {
            float val = fabs(BF2F(x[group * GS_DEFAULT + i]));
            if (val > wmax) {
                wmax = val;
            }
        }

        // calculate and write the scaling factor
        float scale = wmax / Q_MAX;
        s[group] = F2BF(scale);
        s_reciprocal = 1.0 / BF2F(s[group]);

        // calculate and write the quantized values
        for (int i = 0; i < GS_DEFAULT; i++) {
            float quant_value = BF2F(x[group * GS_DEFAULT + i]) * s_reciprocal;
            int quantized = (int)(quant_value); 
            q[group * GS_DEFAULT + i] = (int16_t)quantized;
        }
    }
}

//--------------------------------------------------------------------------
// Reference kernel function implementing RMSNorm
//--------------------------------------------------------------------------

void kernel_ref_llm_rms_exe(int reqId,int N,float16_t *x,bool x_is_fp16,float16_t *o,float *w) {
    // calculate sum of squares
    float ss = 0.0f;
    float f;

    for (int j = 0; j < N; j++) {
        if(x_is_fp16)
            ss += FP16_2_F(x[j]) * FP16_2_F(x[j]);
        else
            ss += BF2F(x[j]) * BF2F(x[j]);
    }
    ss /= N;
    ss += 1e-5f;
    ss = 1.0f / sqrtf(ss);
    // normalize and scale
    for (int j = 0; j < N; j++) {
        if(x_is_fp16)
            f = w[j] * (ss * FP16_2_F(x[j]));
        else
            f = w[j] * (ss * BF2F(x[j]));
        o[j] = F2BF(f);
    }
}

//-----------------------------------------------------------------
// Reference kernel function
// Perform dot product y[0:K=1]=SUM(x1[0:N-1]*x2[0:K-1][0:N-1]);
// Computint clock = (N+N)*K + K = 2*N*K + K
// Mem = N+N*K
//-----------------------------------------------------------------

void kernel_ref_llm_dot_product_exe(int reqId,int N,int K,float16_t *x1,float16_t *_x2,int _x2_dim,float16_t *_y,float scale) {
    float sum;
    for(int i=0;i < K;i++) {
        sum = 0;
        for(int j=0;j < N;j++) {
            sum += BF2F(x1[j])*BF2F(_x2[i*_x2_dim+j]);
        }
        _y[i] = F2BF(sum*scale);
    }
}

//-----------------------------------------------------------------
// Reference kernel function
// Perform dot product y[0:N-1]=SUM(x1[0:K-1]*x2[0:K-1][0:N-1])
// This is similar to kernel_llm_dot_product execept we take the dot
// product to the transpose of x2
//-----------------------------------------------------------------

void kernel_ref_llm_dot_product2_exe(int reqId,int N,int _K,float16_t *x1,float16_t *x2,int x2_dim,float16_t *_y) {
    float sum;
    for(int i=0;i < N;i++) {
        sum = 0;
        for(int j=0;j < _K;j++) {
            sum += BF2F(x1[j])*BF2F(x2[j*x2_dim+i]);
        }
        _y[i] = F2BF(sum);
    } 
}

//------------------------------------------------------------------
// Reference kernel function implementing ROPE
//------------------------------------------------------------------

void kernel_ref_llm_rope_exe(
   int reqId,
   int N, // dimension
   float *fcr, // dimension N
   float *fci, // dimension N
   float16_t *v, // dimension 2N
   float16_t *y
) {
    float v0,v1,y0,y1;
    for (int i = 0; i < N; i++) {
        v0 = BF2F(v[2*i]);
        v1 = BF2F(v[2*i+1]);
        y0 = v0 * fcr[i] - v1 * fci[i];
        y1 = v0 * fci[i] + v1 * fcr[i];
        y[2*i] = F2BF(y0);
        y[2*i+1] = F2BF(y1);
    }
}

//-------------------------------------------------------------------
// Reference kernel function implementing cosine function
//-------------------------------------------------------------------

void kernel_ref_llm_cosine_exe(int reqId,int N,float *x,float scale,float *y) {
    for(int i=0;i < N;i++) {
        y[i] = cos(x[i]*scale);
    }
}

//-------------------------------------------------------------------
// Reference kernel function implementing sine function
//-------------------------------------------------------------------

void kernel_ref_llm_sine_exe(int reqId,int N,float *x,float scale,float *y) {
    for(int i=0;i < N;i++) {
        y[i] = sin(x[i]*scale);
    }
}

//-------------------------------------------------------------------
// Reference kernel function implementing RESIDUAL operation
//-------------------------------------------------------------------

void kernel_ref_llm_residual_exe(
   int reqId,
   int N,
   float16_t *x,
   bool x_is_fp16,
   float16_t *y,
   float16_t *xb
   )
{
    float f;
    for (int i = 0; i < N; i++) {
        if(x_is_fp16)
            f = FP16_2_F(x[i]) + BF2F(xb[i]);
        else
            f = BF2F(x[i]) + BF2F(xb[i]);
        y[i] = F2BF(f);
    }
}

//-------------------------------------------------------------------
// Reference kernel function implementing LLM activation function SwiGLU
//-------------------------------------------------------------------

void kernel_ref_llm_SwiGLU_exe(int reqId,float16_t *hb,float16_t *hb2,int N) {
    // SwiGLU non-linearity
    for (int i = 0; i < N; i++) {
        float val = BF2F(hb[i]);
        // silu(x)=x*σ(x), where σ(x) is the logistic sigmoid
        val *= (1.0f / (1.0f + expf(-val)));
        // elementwise multiply with w3(x)
        val *= BF2F(hb2[i]);
        hb[i] = F2BF(val);
    }
}

//------------------------------------------------------------------------
// Reference kernel function implementing softmax
//------------------------------------------------------------------------

void kernel_ref_llm_softmax_exe(int reqId,float16_t *x,int N) {
    float* _x;

    _x = (float *)malloc(sizeof(float) * N);
    // find max value (for numerical stability)
    float max_val = BF2F(x[0]);

    for (int i = 1; i < N; i++) {
        if (BF2F(x[i]) > max_val) {
            max_val = BF2F(x[i]);
        }
    }
    // exp and sum
    float sum = 0.0f;
    for (int i = 0; i < N; i++) {
        _x[i] = expf(BF2F(x[i]) - max_val);
        sum += _x[i];
    }
    // normalize
    for (int i = 0; i < N; i++) {
        x[i] = F2BF(_x[i]/sum);
    }
    free(_x);
}

//-------------------------------------------------------------------------
// Reference kernel function for greedy sampling
//-------------------------------------------------------------------------

int kernel_ref_llm_find_max(float16_t *x,uint32_t N) {
    int max = 0;

    for(int i=1;i < N;i++) {
        if(BF2F(x[i]) > BF2F(x[max]))
            max = i;
    }
    return max;
}

// Not implemented yet...
int kernel_ref_llm_find_k_max(float16_t* x, uint32_t _N, int K, float scale,int* top, float* topp) {

    return 0;
}