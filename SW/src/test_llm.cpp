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

// Testing LLM kernel functions by comparing results against reference implementation of
// the same kernel functions

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "soc.h"
#include "../base/zta.h"
#include "../base/util.h"
#include "../apps/llm/gguf/gguf.h"
#include "../apps/llm/gguf/zuf.h"
#include "../apps/llm/reference/llm_ref.h"
#include "../apps/llm/kernels/llm_m.h"

//-------------------------
// Verify results between kernel_llm_dot_product_exe and kernel_ref_llm_dot_product_exe
//---------------------------

static void test_llm_dot_product()
{
   int N=64;
   int K=4;
   int x2_dim=192;
   float16_t *x1,*x2,*y,*y2;
   int x1sz,x2sz,ysz;
   static int ok=0;
   static int bad=0;
   static int seed=0;

   seed=0;
   for(K=1;K < 1024;K++) {
   seed++;
   seed = (seed%7);

   x1sz = N;
   x2sz = K*x2_dim+N;
   ysz = K;
   x1 = (float16_t *)malloc(sizeof(float16_t)*x1sz);
   x2 = (float16_t *)malloc(sizeof(float16_t)*x2sz);
   y = (float16_t *)malloc(sizeof(float16_t)*ysz);
   y2 = (float16_t *)malloc(sizeof(float16_t)*ysz);

   for(int i=0;i < x1sz;i++)
      x1[i] = F2BF((float)(i+seed));
   for(int i=0;i < x2sz;i++)
      x2[i] = F2BF((float)((i+seed)%x2_dim));

   kernel_ref_llm_dot_product_exe(0,N,K,x1,x2,x2_dim,y,1.0);

   FLUSH_DATA_CACHE();
   kernel_llm_dot_product_exe(0,N,K,x1,x2,x2_dim,y2,1.0);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   for(int i=0;i < ysz;i++)
   {
      if(y[i] != y2[i]) {
         printf("[%d] %f %f %04X %04X \r\n",i,BF2F(y[i]),BF2F(y2[i]),(int)y[i],(int)y2[i]);
         bad++;
      }
      else
         ok++;
   }
   free(x1);
   free(x2);
   free(y);
   free(y2);
   }
   printf("TEST DOT_PRODUCT ok=%d fail=%d \r\n",ok,bad);
}

//-----------------
// Verify results between kernel_llm_dot_product2_exe and kernel_ref_llm_dot_product2_exe
//------------------

static void test_llm_dot_product2()
{
   int N=64;
   int K=4;
   int x2_dim=192;
   float16_t *x1,*x2,*y,*y2;
   int x1sz,x2sz,ysz;
   static int ok=0;
   static int bad=0;
   static int seed=0;

   seed=0;
   for(K=1;K < 1024;K++) {
   seed++;
   seed = (seed%7);
   x1sz = K;
   x2sz = K*x2_dim+N;
   ysz = N;
   x1 = (float16_t *)malloc(sizeof(float16_t)*x1sz);
   x2 = (float16_t *)malloc(sizeof(float16_t)*x2sz);
   y = (float16_t *)malloc(sizeof(float16_t)*ysz);
   y2 = (float16_t *)malloc(sizeof(float16_t)*ysz);

   for(int i=0;i < x1sz;i++)
      x1[i] = F2BF((float)(i+seed));
   for(int i=0;i < x2sz;i++)
      x2[i] = F2BF((float)((i+seed)%x2_dim));

   kernel_ref_llm_dot_product2_exe(0,N,K,x1,x2,x2_dim,y);

   FLUSH_DATA_CACHE();

   kernel_llm_dot_product2_exe(0,N,K,x1,x2,x2_dim,y2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   for(int i=0;i < ysz;i++)
   {
      if(y[i] != y2[i]) {
         printf("[%d] %f %f %04X %04X \r\n",i,BF2F(y[i]),BF2F(y2[i]),(int)y[i],(int)y2[i]);
         bad++;
      }
      else
         ok++;
   }
   free(x1);
   free(x2);
   free(y);
   free(y2);
   }
   printf("TEST DOT_PRODUCT2 ok=%d fail=%d \r\n",ok,bad);
}

//---------------
// Verify results between kernel_llm_sine_exe and kernel_ref_llm_sine_exe
//----------------

void test_llm_sine() {
   float *x,*y,*y2;
   int N=288;
   float min=-50.0;
   float max=50.0;
   float step;
   float scale=1.0;
   float diff;
   float max_error=0;
   float error;
   static int bad=0;
   static int ok=0;

   x = (float *)malloc(sizeof(float)*N);
   y = (float *)malloc(sizeof(float)*N);
   y2 = (float *)malloc(sizeof(float)*N);
   
   for(max=1.0;max <= 50.0;max += 1.0)
   {
   min = -max;
   step = (max - min)/(float)N;

   for(int i=0;i < N;i++) {
      x[i] = (float)i * step + min;
   }
   
   kernel_ref_llm_sine_exe(0,N,x,scale,y);
   
   FLUSH_DATA_CACHE();

   kernel_llm_sine_exe(0,N,x,scale,y2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();
   
   for(int i=0;i < N;i++) {
      if(y[i] != y2[i]) {
         diff = y[i]-y2[i];
         error = diff/y[i];
         if(error >= 0.002) {
            printf("[%d] %f %f err=%f \r\n",i,y[i],y2[i],error);
            bad++;
         }
         else
            ok++;
      }
      else
         ok++;
   }
   }
   printf("SINE ok=%d bad=%d \r\n",ok,bad);
   free(x);
   free(y);
   free(y2);
}

//---------------
// Verify results between kernel_llm_cosine_exe and kernel_ref_llm_cosine_exe
//---------------

void test_llm_cosine() {
   float *x,*y,*y2;
   int N=288;
   float min=-50.0;
   float max=50.0;
   float step;
   float scale=1.0;
   float diff;
   float max_error=0;
   float error;
   static int bad=0;
   static int ok=0;

   x = (float *)malloc(sizeof(float)*N);
   y = (float *)malloc(sizeof(float)*N);
   y2 = (float *)malloc(sizeof(float)*N);
   
   for(max=1.0;max <= 50.0;max += 1.0)
   {
   min = -max;
   step = (max - min)/(float)N;

   for(int i=0;i < N;i++) {
      x[i] = (float)i * step + min;
   }
   
   kernel_ref_llm_cosine_exe(0,N,x,scale,y);
   
   FLUSH_DATA_CACHE();

   kernel_llm_cosine_exe(0,N,x,scale,y2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();
   
   for(int i=0;i < N;i++) {
      if(y[i] != y2[i]) {
         diff = y[i]-y2[i];
         error = diff/y[i];
         if(error >= 0.0025) {
            printf("[%d] %f %f err=%f \r\n",i,y[i],y2[i],error);
            bad++;
         }
         else
            ok++;
      }
      else
         ok++;
   }
   }
   printf("COSINE ok=%d bad=%d \r\n",ok,bad);
   free(x);
   free(y);
   free(y2);
}

//-------------------
// Verify results between kernel_llm_rope_exe and kernel_ref_llm_rope_exe
//--------------------

void test_llm_rope() {
   float *fcr,*fci;
   float16_t *v,*y,*y2;
   float y_expect,y_got;
   int N=192;
   static int bad=0;
   static int ok=0;
   float err;

   fcr = (float *)malloc(sizeof(float)*N);
   fci = (float *)malloc(sizeof(float)*N);
   v = (float16_t *)malloc(sizeof(float16_t)*2*N);
   y = (float16_t *)malloc(sizeof(float16_t)*2*N);
   y2 = (float16_t *)malloc(sizeof(float16_t)*2*N);
   
   randInit(1234);

   for(int i=0;i < N;i++) {
      fcr[i] = randGen();
      if(randGen() >= 0.5)
         fcr[i] = -fcr[i];
      fci[i] = randGen();
      if(randGen() >= 0.5)
         fci[i] = -fci[i];
   }
   for(int i=0;i < 2*N;i++)
      v[i] = F2BF((float)(i%11));

   kernel_ref_llm_rope_exe(0,N,fcr,fci,v,y);
   
   FLUSH_DATA_CACHE();

   kernel_llm_rope_exe(0,N,fcr,fci,v,y2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();
   
   for(int i=0;i < 2*N;i++) {
      y_expect = BF2F(y[i]);
      y_got = BF2F(y2[i]);
      if(y_expect != y_got) {
         err = y_expect-y_got;
         printf("%f %f err=%f \r\n",y_expect,y_got,err);
         bad++;
      } else {
         ok++;
      }
   }
   free(fcr);
   free(fci);
   free(v);
   free(y);
   free(y2);
   printf("ROPE ok=%d bad=%d \r\n",ok,bad);
}

//------------------------
// Verify results between kernel_llm_rms_exe and kernel_ref_llm_rms_exe
//------------------------

void test_llm_rms() {
   int N=576;
   float f;
   static int bad=0;
   static int ok=0;
   float err;
   float16_t *x;
   float *w;
   float16_t *o,*o2;
   float y_expect,y_got;

   randInit(1234);

   x = (float16_t *)malloc(sizeof(float16_t)*N);
   w = (float *)malloc(sizeof(float)*N);
   o = (float16_t *)malloc(sizeof(float16_t)*N);
   o2 = (float16_t *)malloc(sizeof(float16_t)*N);

   for(int j=0;j < 2;j++) {
      for(int i=0;i < N;i++) {
         f = randGen();
         if(j==0)
            x[i] = F2BF(f);
         else
            x[i] = F2FP16(f);
         f = randGen();
         w[i] = f;
      }

      kernel_ref_llm_rms_exe(0,N,x,(j==0)?false:true,o,w);
      
      kernel_llm_rms_exe(0,N,x,(j==0)?false:true,o2,w);

      kernel_llm_done();

      FLUSH_DATA_CACHE();

      for(int i=0;i < N;i++) {
         y_expect = BF2F(o[i]);
         y_got = BF2F(o2[i]);
         if(y_expect != y_got) {
            err = y_expect-y_got;
            printf("%f %f err=%f \r\n",y_expect,y_got,err);
            bad++;
         } else {
            ok++;
         }
      }
   }
   free(x);
   free(w);
   free(o);
   free(o2);
   printf("RMS ok=%d bad=%d \r\n",ok,bad);
}

//-----------------
// Verify results between kernel_llm_residual_exe and kernel_ref_llm_residual_exe
//------------------

void test_llm_residual() {
   int N=576;
   float f;
   static int bad=0;
   static int ok=0;
   float err;
   float16_t *x,*xb;
   float16_t *y,*y2;
   float y_expect,y_got;

   randInit(1234);

   x = (float16_t *)malloc(sizeof(float16_t)*N);
   xb = (float16_t *)malloc(sizeof(float16_t)*N);
   y = (float16_t *)malloc(sizeof(float16_t)*N);
   y2 = (float16_t *)malloc(sizeof(float16_t)*N);

   for(int j=0;j < 2;j++) {
      for(int i=0;i < N;i++) {
         f = randGen();
         if(j==0)
            x[i] = F2BF(f);
         else
            x[i] = F2FP16(f);
         f = randGen();
         if(j==0)
            xb[i] = F2BF(f);
         else
            xb[i] = F2FP16(f);
      }

      kernel_ref_llm_residual_exe(0,N,x,(j==0)?false:true,y,xb);

      kernel_llm_residual_exe(0,N,x,(j==0)?false:true,y2,xb);

      kernel_llm_done();

      FLUSH_DATA_CACHE();

      for(int i=0;i < N;i++) {
         y_expect = BF2F(y[i]);
         y_got = BF2F(y2[i]);
         if(y_expect != y_got) {
            err = y_expect-y_got;
            printf("%f %f err=%f \r\n",y_expect,y_got,err);
            bad++;
         } else {
            ok++;
         }
      }
   }
   free(x);
   free(xb);
   free(y);
   free(y2);
   printf("RESIDUAL ok=%d bad=%d \r\n",ok,bad);
}

//---------------------
// Verify results between kernel_llm_SwiGLU_exe and kernel_ref_llm_SwiGLU_exe
//----------------------

void test_llm_SwiGLU() {
   int N=1536;
   float f;
   static int bad=0;
   static int ok=0;
   float err;
   float16_t *hb[2];
   float16_t *hb2[2];
   float y_expect,y_got;
   float min=-30.0;
   float max=+50.0;
   float range;

   randInit(1234);

   hb[0] = (float16_t *)malloc(sizeof(float16_t)*N);
   hb2[0] = (float16_t *)malloc(sizeof(float16_t)*N);
   hb[1] = (float16_t *)malloc(sizeof(float16_t)*N);
   hb2[1] = (float16_t *)malloc(sizeof(float16_t)*N);
   
   range = max - min;
   for(int i=0;i < N;i++) {
      if(i==0)
         f = min; // Make sure we cover the lowest value
      else if(i==(N-1))
         f = max; // Make sure we cover the highest value
      else {
         f = randGen();
         f = min + (f * range);
      }
      hb[0][i] = F2BF(f);
      f = randGen();
      hb2[0][i] = F2BF(f);
      hb[1][i] = hb[0][i];
      hb2[1][i] = hb2[0][i];
   }

   kernel_ref_llm_SwiGLU_exe(0,hb[0],hb2[0],N);

   kernel_llm_SwiGLU_exe(0,hb[1],hb2[1],N);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   for(int i=0;i < N;i++) {
      y_expect = BF2F(hb[0][i]);
      y_got = BF2F(hb[1][i]);
      if(y_expect != y_got) {
         err = y_expect-y_got;
         printf("%f %f err=%f \r\n",y_expect,y_got,err);
         bad++;
      } else {
         ok++;
      }
   }
   free(hb[0]);
   free(hb2[0]);
   free(hb[1]);
   free(hb2[1]);
   printf("SWIGLU ok=%d bad=%d \r\n",ok,bad);
}

//-------------------
// Verify results between kernel_llm_softmax_exe and kernel_ref_llm_softmax_exe
//-------------------

void test_llm_softmax() {
   int N=512;
   float f;
   static int bad=0;
   static int ok=0;
   float err;
   float16_t *x0,*x1;
   float *xin;
   float y_expect,y_got;
   float min=-100.0;
   float max=100.0;
   float range;

   randInit(1234);

   x0 = (float16_t *)malloc(sizeof(float16_t)*N);
   x1 = (float16_t *)malloc(sizeof(float16_t)*N);
   xin = (float *)malloc(sizeof(float)*N);

   range = max - min;
   for(int i=0;i < N;i++) {
      if(i==0)
         f = min; // Make sure we cover the lowest value
      else if(i==(N-1))
         f = max; // Make sure we cover the highest value
      else {
         f = randGen();
         f = min + (f * range);
      }
      x0[i] = F2BF(f);
      x1[i] = F2BF(f);
      xin[i] = f;
   }

   kernel_ref_llm_softmax_exe(0,x0,N);

   kernel_llm_softmax_exe(0,x1,N);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   for(int i=0;i < N;i++) {
      y_expect = BF2F(x0[i]);
      y_got = BF2F(x1[i]);
      if(y_expect != y_got) {
         err = y_expect-y_got;
         err = ABS(err);
         if(err > 10e-30)
         {
            bad++;
         }
         else
            ok++;
      } else {
         ok++;
      }
   }
   free(x0);
   free(x1);
   free(xin);
   printf("SOFTMAX ok=%d bad=%d \r\n",ok,bad);
}

//---------------------
// Verify results between kernel_llm_quantize_exe and kernel_ref_llm_quantize_exe
//---------------------

void test_llm_quantize() {
   int N=1024;
   float f;
   static int bad=0;
   static int ok=0;
   float err;
   volatile float16_t *x,*s,*s2;
   volatile int16_t *q,*q2;
   float y_expect,y_got;
   float min=-512.0;
   float max=+4000.0;

   float range;

   randInit(1234);

   x = (volatile float16_t *)malloc(sizeof(float16_t)*N);
   s = (volatile float16_t *)malloc(sizeof(float16_t)*N);
   s2 = (volatile float16_t *)malloc(sizeof(float16_t)*N);
   q = (volatile int16_t *)malloc(sizeof(int16_t)*N);
   q2 = (volatile int16_t *)malloc(sizeof(int16_t)*N);

   memset((void *)x,0,sizeof(float16_t)*N);
   memset((void *)s,0,sizeof(float16_t)*N);
   memset((void *)s2,0,sizeof(float16_t)*N);
   memset((void *)q,0,sizeof(float16_t)*N);
   memset((void *)q2,0,sizeof(float16_t)*N);

   range = max - min;
   for(int i=0;i < N;i++) {
      float f;
      if(i==0)
         f = min; // Make sure we cover the lowest value
      else if(i==(N-1))
         f = max; // Make sure we cover the highest value
      else 
      {
         f = randGen();
         f = min + (f * range);
      }
      x[i] = F2BF(f);
   }

   FLUSH_DATA_CACHE();

   kernel_ref_llm_quantize_exe(0,N,(float16_t *)x,(float16_t *)s,(int16_t *)q);

   kernel_llm_quantize_exe(0,N,(float16_t *)x,(float16_t *)s2,(int16_t *)q2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   for(int i=0;i < N;i++) {
      y_expect = BF2F(s[i]);
      y_got = BF2F(s2[i]);
      if(y_expect != y_got) {
         err = y_expect-y_got;
         printf("S:%f %f (%04X %04X) err=%f \r\n",y_expect,y_got,(int)s[i],(int)s2[i],err);
         bad++;
      } else {
         ok++;
      }
      if(ABS(q[i]-q2[i]) > 1)
      {
         printf("Q:[%d] %d %d (good=%d bad=%d) \r\n",i,(int)q[i],(int)q2[i],ok,bad); 
         bad++;
      }
      else
         ok++;
   }
   free((void *)x);
   free((void *)s);
   free((void *)s2);
   free((void *)q);
   free((void *)q2);
   printf("QUANTIZE ok=%d bad=%d \r\n",ok,bad);
}

//--------------
// Verify results between kernel_llm_quantize_exe and kernel_ref_llm_quantize_exe
//---------------

void test_llm_matmul_q4() {
   int N=576;
   int D=1536;
   int16_t *x_v;
   float16_t *x_s;
   float16_t *y;
   float16_t *y2;
   float *w;
   float16_t *x;
   static GGUF gguf;
   float w_lo=-1.0;
   float w_range = 2.0;
   float x_lo = -20.0;
   float x_range = 100.0;
   float y_expect,y_got,error,max_error;
   static int ok=0;
   static int fail=0;

   printf("MATMUL_Q4\r\n");
   randInit(1234);

   x = (float16_t *)malloc(sizeof(float16_t)*N);
   memset(x,0,sizeof(float16_t)*N);
   x_v = (int16_t *)malloc(sizeof(int16_t)*N);
   memset(x_v,0,sizeof(int16_t)*N);
   x_s = (float16_t *)malloc(sizeof(float16_t)*N/32);
   memset(x_s,0,sizeof(float16_t)*N/32);
   w = (float *)malloc(N*D*sizeof(float));
   memset(w,0,N*D*sizeof(float));
   y = (float16_t *)malloc(sizeof(float16_t)*D);
   memset(y,0,sizeof(float16_t)*D);
   y2 = (float16_t *)malloc(sizeof(float16_t)*D);
   memset(y2,0,sizeof(float16_t)*D);

   // Generate random activation
   for(int i=0;i < N;i++) {
      x[i] = F2BF(x_lo+x_range*randGen());
   }
   kernel_ref_llm_quantize_exe(0,N,x,x_s,x_v);

   // Generate random weight
   for(int i=0;i < N*D;i++) {
      w[i] = w_lo+w_range*randGen();
   }

   printf("Quantize for simulation...\r\n");
   gguf.quantize(w,N*D,N,D,false,ZUF_QUANT_INT4);
   printf("Quantize done \r\n");

   kernel_ref_llm_matmul_q4_exe(0,N,D,32,x_v,x_s,gguf.m_qq,gguf.m_qs,y);  


   printf("Quantize for ztachip...\r\n");
   gguf.quantize(w,N*D,N,D,true,ZUF_QUANT_INT4);
   printf("Quantize done \r\n");

   kernel_llm_matmul_q4_exe(0,N,D,32,x_v,x_s,gguf.m_qq,gguf.m_qs,y2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   max_error=-100000;
   for(int i=0;i < D;i++) {
      y_expect = BF2F(y[i]);
      y_got = BF2F(y2[i]);
      if(y_expect==0)
         error = ABS(y_got);
      else
         error = ABS(y_expect-y_got)/y_expect;
      if(i==0)
         max_error = error;
      else
         max_error = MAX(max_error,error);
      if(y_expect == y_got)
         ok++;
      else
         fail++;
      if(y_expect != y_got)
         printf("[%d] %f %f %04X %04X maxErr=%f \r\n",i,y_expect,y_got,(int)y[i],(int)y2[i],max_error);
   }

   free(x);
   free(x_v);
   free(x_s);
   free(w);
   free(y);
   free(y2);
   printf("MATMUL+Q4 ok=%d fail=%d\r\n",ok,fail);
}

//----------------
// Verify results between kernel_llm_matmul_q8_exe and kernel_ref_llm_matmul_q8_exe
//----------------

void test_llm_matmul_q8() {
   int N=576;
   int D=1536;
   int16_t *x_v;
   float16_t *x_s;
   float16_t *y;
   float16_t *y2;
   float *w;
   float16_t *x;
   static GGUF gguf;
   float w_lo=-1.0;
   float w_range = 2.0;
   float x_lo = -20.0;
   float x_range = 100.0;
   float y_expect,y_got,error,max_error;
   static int ok=0;
   static int fail=0;

   printf("MATMUL_Q8\r\n");
   randInit(1234);

   x = (float16_t *)malloc(sizeof(float16_t)*N);
   memset(x,0,sizeof(float16_t)*N);
   x_v = (int16_t *)malloc(sizeof(int16_t)*N);
   memset(x_v,0,sizeof(int16_t)*N);
   x_s = (float16_t *)malloc(sizeof(float16_t)*N/32);
   memset(x_s,0,sizeof(float16_t)*N/32);
   w = (float *)malloc(N*D*sizeof(float));
   memset(w,0,N*D*sizeof(float));
   y = (float16_t *)malloc(sizeof(float16_t)*D);
   memset(y,0,sizeof(float16_t)*D);
   y2 = (float16_t *)malloc(sizeof(float16_t)*D);
   memset(y2,0,sizeof(float16_t)*D);

   // Generate random activation
   for(int i=0;i < N;i++) {
      x[i] = F2BF(x_lo+x_range*randGen());
   }
   kernel_ref_llm_quantize_exe(0,N,x,x_s,x_v);

   // Generate random weight
   for(int i=0;i < N*D;i++) {
      w[i] = w_lo+w_range*randGen();
   }

   printf("Quantize for simulation...\r\n");
   gguf.quantize(w,N*D,N,D,false,ZUF_QUANT_INT8);
   printf("Quantize done \r\n");

   kernel_ref_llm_matmul_q8_exe(0,N,D,32,x_v,x_s,gguf.m_qq,gguf.m_qs,y);  


   printf("Quantize for ztachip...\r\n");
   gguf.quantize(w,N*D,N,D,true,ZUF_QUANT_INT8);
   printf("Quantize done \r\n");

   kernel_llm_matmul_q8_exe(0,N,D,32,x_v,x_s,gguf.m_qq,gguf.m_qs,y2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   max_error=-100000;
   for(int i=0;i < D;i++) {
      y_expect = BF2F(y[i]);
      y_got = BF2F(y2[i]);
      if(y_expect==0)
         error = ABS(y_got);
      else
         error = ABS(y_expect-y_got)/y_expect;
      if(i==0)
         max_error = error;
      else
         max_error = MAX(max_error,error);
      if(y_expect == y_got)
         ok++;
      else
         fail++;
      if(y_expect != y_got)
         printf("[%d] %f %f %04X %04X maxErr=%f \r\n",i,y_expect,y_got,(int)y[i],(int)y2[i],max_error);
   }

   free(x);
   free(x_v);
   free(x_s);
   free(w);
   free(y);
   free(y2);
   printf("MATMUL+Q8 ok=%d fail=%d\r\n",ok,fail);
}

//-----------------
// Verify results between kernel_llm_find_k_max and kernel_ref_llm_find_k_max
//-----------------

void test_llm_k_max() {
   static int ok=0;
   static int fail=0;
   int N=30000;
   int K=40;
   float16_t *x;
   float x_lo=0.1,x_range=2.0;
   float scale=1.0;
   float min;
   int i,j;
   static int top[100];
   static float16_t topp[100];

   printf("test_llm_k_max \r\n");
   x = (float16_t *)malloc(sizeof(float16_t)*N);
   for(int i=0;i < N;i++) {
      x[i] = F2BF(x_lo+x_range*randGen());
   }

   kernel_llm_find_k_max(x,N,K,scale,top,topp);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   for(int i=0;i < K;i++) {
      if(i==0)
         min = BF2F(topp[i]);
      else
         min = MIN(min,BF2F(topp[i]));
   }

   for(i=0;i < N;i++) {
      for(j=0;j < K;j++) {
         if(top[j]==i)
            break;
      }
      if(j < K)
         continue;
      if(BF2F(x[i]) > min) {
         printf("FAIL x[i]=%f min=%f \r\n",BF2F(x[i]),min);
         fail++;
      }
   }
   // Make sure it is sorted from hi to lo

   for(i=0;i < K-1;i++) {
      if(topp[i] < topp[i+1]) {
         printf("SORT FAIL \r\n");
         fail++;
      }
   }

   ok++;
   printf("test_llm_k_max DONE ok=%d fail=%d \r\n",ok,fail);
   free(x);
}

// -------------------
// Verify LLM kernel functions
//---------------------

void test_llm() {
   test_llm_dot_product();
   test_llm_dot_product2();
   test_llm_sine();
   test_llm_cosine();
   test_llm_rope();
   test_llm_rms();
   test_llm_residual();
   test_llm_SwiGLU();
   test_llm_softmax();
   test_llm_quantize();
   test_llm_matmul_q4();
   test_llm_matmul_q8();
   test_llm_k_max();
}

