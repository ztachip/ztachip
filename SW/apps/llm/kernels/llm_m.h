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

#ifndef _TARGET_KERNELS_LLM_M_H_
#define _TARGET_KERNELS_LLM_M_H_

#include "stdint.h"
#include "../../../base/types.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void kernel_llm_matmul_q4_exe(int _req_id,
                                int N,int D,int GS,
                                int16_t *x_v,
                                float16_t *x_s,
                                uint8_t *w_v,
                                float16_t *w_s,
                                float16_t *result);
                                
extern void kernel_llm_matmul_q8_exe(int _req_id,
                                int N,int D,int GS,
                                int16_t *x_v,
                                float16_t *x_s,
                                uint8_t *w_v,
                                float16_t *w_s,
                                float16_t *result);

extern void kernel_llm_dot_product_exe(int reqId,int N,int K,float16_t *x1,float16_t *_x2,int _x2_dim,float16_t *_y,float scale);

extern void kernel_llm_quantize_exe(int reqId,int N,float16_t *x,float16_t *s,int16_t *q);

extern void kernel_llm_dot_product2_exe(int reqId,int N,int K,float16_t *x1,float16_t *_x2,int _x2_dim,float16_t *_y);

extern void kernel_llm_cosine_exe(int reqId,int N,float *x,float scale,float *y);

extern void kernel_llm_sine_exe(int reqId,int N,float *x,float scale,float *y);

extern void kernel_llm_SwiGLU_exe(int reqId,float16_t *hb,float16_t *hb2,int N); 

extern void kernel_llm_softmax_exe(int reqId,float16_t *x,int N);

extern void kernel_llm_rms_exe(int reqId,int N,float N_reciprocal,float16_t *x,bool x_is_fp16,float16_t *o,float *w);

extern void kernel_llm_rope_exe(int reqId,int N,float *fcr,float *fci,float16_t *v,float16_t *y);

extern void kernel_llm_residual_exe(int reqId,int N,float16_t *x,bool x_is_fp16,float16_t *y,float16_t *xb);

extern int kernel_llm_find_max(uint32_t jobId,float16_t *x,uint32_t N);

extern int kernel_llm_find_k_max(uint32_t jobId,float16_t *x,uint32_t N,int K,float scale,int *top,float16_t *topp);

extern void kernel_llm_done();

#ifdef __cplusplus
}
#endif
#endif
