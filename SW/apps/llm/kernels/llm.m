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

#include <stdbool.h> 
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include "../../../../SW/base/types.h"
#include "../../../../SW/base/ztalib.h"
#include "../../../../SW/src/soc.h"
#include "../../../../SW/base/util.h"
#include "llm_m.h" 
#include "llm_p.h"
#include "llm.p.img"

//--------------------------------------------------------------------------
// Approximate y=1/sqrt(x) with Taylor expansion
// Approximate y(0) with FPU.INVSQRT 
// Then approximate to float32 accuracy with Newton extension below
// y(n+1) = y(n) * (1.5f - x/2 * y(n) * y(n));
//--------------------------------------------------------------------------

void invsqrt(int cnt,float *x,float *y,float *temp,float *temp2)
{
   >FPU.INVSQRT(n=cnt,y=(float *)y,x=(float *)x); // Initial estimate

   >FPU.MAC(n=cnt,y=(float *)temp2,x1=(float *)x,x2=0.5);

   for(int i=0;i < 4;i++) {  
      >FPU.MAC(n=cnt,y=(float *)temp,a=0.0,x1=(float *)y,x2=(float *)y);

      >FPU.MAC(n=cnt,y=(float *)temp,a=1.5,x1=(float *)temp,x2=(float *)temp2,c=-1.0);

      >FPU.MAC(n=cnt,y=(float *)y,a=0.0,x1=(float *)temp,x2=(float *)y);
   }
}

//--------------------------------------------------------------------------
// Approximate reciprocal y=1/x with Taylor expansion
// Approximate x(0) with FPU.RECIPROCAL 
// Then improve accuracy with below
// x(n+1) = x(n)*(2-a*x(n))
// Do in batch of cnt float numbers
//--------------------------------------------------------------------------

static void reciprocal(int cnt,float *x,int xfmt,float *y,float *temp)
{
   if(cnt==1) {
   >FPU.RECIPROCAL(n=cnt,y=(float *)y,x=(xfmt)x);

   >FPU.MAC(N=cnt,y=(float *)temp,a=2.0,x1=(xfmt)x,x2=(float *)y,c=-1.0)...;

   >FPU.MAC(N=cnt,y=(float *)y,x1=(float *)temp,x2=(float *)y)...;

   >FPU.MAC(N=cnt,y=(float *)temp,a=2.0,x1=(xfmt)x,x2=(float *)y,c=-1.0)...;

   >FPU.MAC(N=cnt,y=(float *)y,x1=(float *)temp,x2=(float *)y)...;

   >FPU.MAC(N=cnt,y=(float *)temp,a=2.0,x1=(xfmt)x,x2=(float *)y,c=-1.0)...;

   >FPU.MAC(N=cnt,y=(float *)y,x1=(float *)temp,x2=(float *)y);
   } else {
   >FPU.V.RECIPROCAL(n=cnt,y=(float *)y,x=(xfmt)x);

   >FPU.V.MAC(N=cnt,y=(float *)temp,a=2.0,x1=(xfmt)x,x2=(float *)y,c=-1.0)...;

   >FPU.V.MAC(N=cnt,y=(float *)y,x1=(float *)temp,x2=(float *)y)...;

   >FPU.V.MAC(N=cnt,y=(float *)temp,a=2.0,x1=(xfmt)x,x2=(float *)y,c=-1.0)...;

   >FPU.V.MAC(N=cnt,y=(float *)y,x1=(float *)temp,x2=(float *)y)...;

   >FPU.V.MAC(N=cnt,y=(float *)temp,a=2.0,x1=(xfmt)x,x2=(float *)y,c=-1.0)...;

   >FPU.V.MAC(N=cnt,y=(float *)y,x1=(float *)temp,x2=(float *)y);
   }
}

//--------------------------------------------------------------------------
// Approximate EXP function with Taylor expresion
// First approximate EXP with...
//     FPU.EXP((int16)(floor(x/ln2)))
// FPU.EXP provides first approximation of EXP
// Then improve accuracy with taylor expansion below
// 1 + x*(1 + x*(0.5 + x*(0.16666667 + x*(0.04166667 + x*(0.00833333 + x*0.00138889)))))
//--------------------------------------------------------------------------

static void exponent(int N,float *x,float *y,float *tmp1,float *tmp2,float *tmp3,float bias,int yfmt) { 
   >FPU.V.MAC.FLOOR(n=N,y=(float *)tmp1,c=1.442695,x1=(float *)x); // tmp1= floor(x/ln2)

   >FPU.V.MAC(n=N,y=(int16 *)tmp2,x1=(float *)tmp1)...; // tmp2= (int8_t)tmp1

   >FPU.V.EXP(n=N,y=(float *)tmp3,x=(int16 *)tmp2)...; //tmp3 = exp(tmp2) 

   >FPU.V.MAC(n=N,y=(float *)x,a=(float *)x,c=-0.69314718,x1=(float *)tmp1)...; // x = x-tmp1*(ln2)

   >FPU.V.MAC(n=N,y=(float *)y,a=0.00833333,c=0.00138889,x1=(float *)x)...; // y= 0.00833333 + x*0.00138889

   >FPU.V.MAC(n=N,y=(float *)y,a=0.04166667,x1=(float *)x,x2=(float *)y)...; // y= 0.04166667 + x*y

   >FPU.V.MAC(n=N,y=(float *)y,a=0.16666667,x1=(float *)x,x2=(float *)y)...; // y=0.16666667 + x*y

   >FPU.V.MAC(n=N,y=(float *)y,a=0.5,x1=(float *)x,x2=(float *)y)...; // y=0.5 + x*y

   >FPU.V.MAC(n=N,y=(float *)y,a=1.0,x1=(float *)x,x2=(float *)y)...; // y=1 + x*y

   >FPU.V.MAC(n=N,y=(float *)y,a=1.0,x1=(float *)x,x2=(float *)y)...; // y=1 + x*y

   >FPU.V.MAC(n=N,y=(float *)y,a=(float)bias,x1=(float *)tmp3,x2=(float *)y); // y=y*tmp3
}

//----------------------------------------------------------------------------
// Perform matmul operation between activation and weights
// y[D]=x[N]*w[D][N]
// This operation is the dominant cost of LLM since this step is where most weights
// are transfered from DDR to ztachip.
// This operation is memory bound
// Weights in Q4 quantization
// The most critical aspects are the memory transfer of the weights. This is the dominant cost
// Weight tensors are reformat so that weights are transfered in burst mode. 
// Weight reformat is done offline when we convert from GGUF to ZUF
// This is the most critical kernel where both pcores and SPU hardware are used.
// C/C++ reference implementation
//  llm_sim.cpp:matmul_q4
// *** Note *** that reference implementation does not have weights memory layout of ztachip so the 
// implementation is very different but it shows the expected functions.
//----------------------------------------------------------------------------

// Work space defintion for this kernel

#define MATMUL_BATCH (VECTOR_WIDTH*NUM_THREAD_PER_CORE) 

typedef struct { 
   int N;
   int D;
   int GS;
   unsigned int x_v;
   unsigned int x_s;
   unsigned int w_v;
   unsigned int w_s;
   unsigned int result;
} REQUEST;

typedef struct
{
   float       s4[MATMUL_BATCH*NUM_PCORE]; 
   float16_t   s3[MATMUL_BATCH*NUM_PCORE];
   float16_t   s2[NUM_PCORE];
   float16_t   s1[MATMUL_BATCH*NUM_PCORE];
} matmul_ws;

static void matmul_q4(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   int x,y,ystart,ymax;
   int nth,gs,cnt,cnt2;
   int FACTOR,N,ii,sz,s,e;
   uint32_t resp;
   matmul_ws *ws; 
   int fast;
   uint32_t y_type,a_type,a;
   float16_t *s1,*s2,*s3;
   char _end_;

   ws = (matmul_ws *)((pid==0)?0:(SRAM_SIZE/2));
   cnt2 = NUM_PCORE;
   cnt = MATMUL_BATCH;
   FACTOR = req->GS/LLM_GS;
   N = req->N/req->GS;
   sz = req->D/2;
   sz = ((sz + cnt -1)/cnt)*cnt;
   if(sz > req->D)
      sz = req->D;
   ystart = (pid==0)?0:sz;
   ymax = (pid==0)?sz:req->D;

   for(y=ystart;y < ymax;y += MATMUL_BATCH) 
   {
      cnt = (ymax-y); 
      if(cnt > MATMUL_BATCH)
         cnt = MATMUL_BATCH;
      cnt = ((cnt+NUM_THREAD_PER_CORE-1)/NUM_THREAD_PER_CORE)*NUM_THREAD_PER_CORE;
      nth = cnt/VECTOR_WIDTH;
      s=2*(LLM_GS/2)*VECTOR_WIDTH*y/VECTOR_WIDTH;
      e=2*(LLM_GS/2)*VECTOR_WIDTH*(y+cnt)/VECTOR_WIDTH;
      fast = (cnt >= 32)?2:0;

      > $W_SCALE_D := DTYPE(INT16)SCRATCH((uint32_t)ws->s1,NUM_PCORE,cnt)[$][0:cnt-1];
      
      > $W_SCALE_S := DTYPE(INT16)MEM(req->w_s,req->N/req->GS,req->D)[$][y:y+cnt-1];

      for(x=0;x < N;x+=NUM_PCORE) 
      {
         cnt2 = N-x;
         if(cnt2 > NUM_PCORE)
            cnt2 = NUM_PCORE;
      
         > $X_D := DTYPE(INT16)PCORE[0:cnt2-1].llm::x[:][:];         
         > $X_S := DTYPE(INT16)MEM(req->x_v,req->N/req->GS,FACTOR*LLM_GS)[x:x+cnt2-1][$];  
         > $W_S := DTYPE(INT8)MEM(req->w_v,FACTOR/2,(req->N/req->GS),2*(req->D/VECTOR_WIDTH)*(LLM_GS/2)*VECTOR_WIDTH)[$][x:x+cnt2-1][s:e-1];
         > $W_D := DTYPE(INT8)PCORE[0:cnt2-1].THREAD[0:nth-1].llm::w[0:LLM_GS-1][:];

         for(gs=0;gs < FACTOR;gs+=2) { 

            // Cannot fit the whole group in PCORE
            // So do dot product in multiple steps and add results together

            > $X_D <= $X_S[gs*LLM_GS:gs*LLM_GS+2*LLM_GS-1];  
            > $W_D <= $W_S[gs/2];
   
            if(gs==0) {
               > EXE_LOCKSTEP(llm::matmul_begin,cnt2);  // First interation 
            }
            > EXE_LOCKSTEP(llm::matmul,cnt2);
            if(gs==(FACTOR-2)) {
               > EXE_LOCKSTEP(llm::matmul_end,cnt2); // Last interation, prepare results to send out
            }
            ztaTaskYield();
         }

         // Send scales of weights to SRAM,  
         > $W_SCALE_D[0:cnt2-1] <= $W_SCALE_S[x:x+cnt2-1];

         // Send scales of x to SRAM,
         > DTYPE(INT16)SCRATCH((uint32_t)ws->s2,NUM_PCORE)[0:cnt2-1] <= DTYPE(INT16)MEM(req->x_s,req->N/req->GS)[x:x+cnt2-1];  

         // Send results from HART0 to SRAM
         > DTYPE(BFLOAT)SCRATCH((uint32_t)ws->s3,cnt2,cnt)[0:cnt2-1][0:cnt-1] <= DTYPE(BFLOAT)PCORE[:].THREAD[0:nth-1].llm::y[0:VECTOR_WIDTH-1];      
         
         ztaTaskYield();

         // Perform the scaling for final results
         for(ii=0,s1=ws->s1,s2=ws->s2,s3=ws->s3;
            ii < cnt2;
            ii++,s2++,s1 += cnt,s3 += cnt) {
               
               y_type = ((ii==(cnt2-1) && (x+NUM_PCORE)>=N)?FPU_SET_W_BFLOAT:FPU_SET_W_FP32)|FPU_SET_M_ADDR;
               a_type = (((x==0) && (ii==0))?FPU_SET_M_VALUE:FPU_SET_M_ADDR)|FPU_SET_W_FP32;
               a = (uint32_t)(((x==0) && (ii==0))?0:ws->s4);

               // SPU instructions are grouped together for better performance
               // When _end_ = 0, it means the end of a group of SPU instructions
               // When _end_ = ',', it means more SPU instruction to follow but next instruction must wait for the 
               //                   completion of previous step
               // When _end_ = ':', it means some SPU instruction to follow but next instruction can start without
               //                   Waiting for previous step to be completed. This improves SPU FIFO performance.

               _end_ = (ii==(cnt2-1))?0:(fast?':':'.');

               >FPU.V.MAC(N=cnt,y=(y_type)ws->s4,A=(a_type)a,c=(bfloat *)s2,x1=(float16 *)s1,x2=(zfloat *)s3) _end_;
         }
         ztaTaskYield();
      }
      // Snd results to DDR when FPU computation completed
      > DTYPE(INT16)MEM(req->result,(pid==0)?sz:req->D)[y:(y+cnt)-1] <= DTYPE(INT16)SCRATCH((uint32_t)ws->s4)[0:cnt-1]; 
   }
}

//----------------------------------------------------------------------------
// Perform matmul operation between activation and weights
// y[D]=x[N]*w[D][N]
// This operation is the dominant cost of LLM since this step is where most weights
// are transfered from DDR to ztachip.
// This operation is memory bound
// Weights in Q8 quantization
// Last matmul typically require weights to be at higher precision
// The most critical aspects are the memory transfer of the weights. This is the 
// dominant cost
// Weight tensors are reformat so that weights are transfered in burst mode. 
// Weight reformat is done offline when we convert from GGUF to ZUF
// This is the most critical kernel where both pcores and SPU hardware are used.
// C/C++ reference implementation
//  llm_sim.cpp:matmul_q8
// *** Note *** that reference implementation does not have weights memory layout 
// of ztachip so the implementation is very different but it shows the expected 
// functions.
//----------------------------------------------------------------------------

static void matmul_q8(void *_p,int pid) {
   REQUEST *req=(REQUEST *)_p;
   int x,y,ystart,ymax;
   int nth,gs,cnt,cnt2;
   int FACTOR,N,ii,sz,s,e;
   uint32_t resp;
   matmul_ws *ws;
   uint32_t y_type,a_type,a;
   float16_t *s2,*s1,*s3;
   int fast;
   char _end_;

   ws = (matmul_ws *)((pid==0)?0:(SRAM_SIZE/2));
   cnt2 = NUM_PCORE;
   cnt = MATMUL_BATCH;
   FACTOR = req->GS/LLM_GS;
   N = req->N/req->GS;
   sz = req->D/2;
   sz = ((sz + cnt -1)/cnt)*cnt;
   if(sz > req->D)
      sz = req->D;
   ystart = (pid==0)?0:sz;
   ymax = (pid==0)?sz:req->D;

   for(y=ystart;y < ymax;y += MATMUL_BATCH) 
   {
      cnt = (ymax-y); 
      if(cnt > MATMUL_BATCH)
         cnt = MATMUL_BATCH;
      cnt = ((cnt+NUM_THREAD_PER_CORE-1)/NUM_THREAD_PER_CORE)*NUM_THREAD_PER_CORE;
      nth = cnt/VECTOR_WIDTH;
      s=(LLM_GS)*VECTOR_WIDTH*y/VECTOR_WIDTH;
      e=(LLM_GS)*VECTOR_WIDTH*(y+cnt)/VECTOR_WIDTH;
      fast = (cnt >= 32)?2:0;
      for(x=0;x < N;x+=NUM_PCORE) 
      {
         cnt2 = N-x;
         if(cnt2 > NUM_PCORE)
            cnt2 = NUM_PCORE;
               
         > $X_D := DTYPE(INT16)PCORE[0:cnt2-1].llm_q8::x[:][:];

         > $X_S := DTYPE(INT16)MEM(req->x_v,req->N/req->GS,FACTOR*LLM_GS)[x:x+cnt2-1][$];  

         > $W_S := DTYPE(INT8)MEM(req->w_v,FACTOR,(req->N/req->GS),(req->D/VECTOR_WIDTH)*(LLM_GS)*VECTOR_WIDTH)[$][x:x+cnt2-1][s:e-1];

         > $W_D := DTYPE(INT8)PCORE[0:cnt2-1].THREAD[0:nth-1].llm_q8::w[0:LLM_GS-1][:];

         for(gs=0;gs < FACTOR;gs++) {

            // Cannot fit the whole group in PCORE
            // So do dot product in multiple steps and add results together

            > $X_D <= $X_S[gs*LLM_GS:gs*LLM_GS+LLM_GS-1];

            > $W_D <= $W_S[gs];  
   
            if(gs==0) {
               > EXE_LOCKSTEP(llm_q8::matmul_begin,cnt2);  // First interation 
            }
            > EXE_LOCKSTEP(llm_q8::matmul,cnt2);
            if(gs==(FACTOR-1)) {
               > EXE_LOCKSTEP(llm_q8::matmul_end,cnt2); // Last interation, prepare results to send out
            }
            ztaTaskYield();
         }

         // Send scales of weights to SRAM, 
         > DTYPE(INT16)SCRATCH((uint32_t)ws->s1,cnt2,cnt)[0:cnt2-1][0:cnt-1] <= DTYPE(INT16)MEM(req->w_s,req->N/req->GS,req->D)[x:x+cnt2-1][y:y+cnt-1];

         // Send scales of x to SRAM,
         > DTYPE(INT16)SCRATCH((uint32_t)ws->s2,cnt2)[:] <= DTYPE(INT16)MEM(req->x_s,req->N/req->GS)[x:x+cnt2-1];  

         // Send results from HART0 to SRAM
         > DTYPE(BFLOAT)SCRATCH((uint32_t)ws->s3,cnt2,cnt)[0:cnt2-1][0:cnt-1] <= DTYPE(BFLOAT)PCORE[:].THREAD[0:nth-1].llm_q8::y[0:VECTOR_WIDTH-1];      
         
         ztaTaskYield(); 

         // Perform the scaling for final result
         for(ii=0,s1=ws->s1,s2=ws->s2,s3=ws->s3;
            ii < cnt2;
            ii++,s2++,s1 += cnt,s3 += cnt) {

               y_type = ((ii==(cnt2-1) && (x+NUM_PCORE)>=N)?FPU_SET_W_BFLOAT:FPU_SET_W_FP32)|FPU_SET_M_ADDR;

               a_type = (((x==0) && (ii==0))?FPU_SET_M_VALUE:FPU_SET_M_ADDR)|FPU_SET_W_FP32;

               a = (uint32_t)(((x==0) && (ii==0))?0:ws->s4);

               // SPU instructions are grouped together for better performance
               // When _end_ = 0, it means the end of a group of SPU instructions
               // When _end_ = ',', it means more SPU instruction to follow but next instruction must wait for the 
               //                   completion of previous step
               // When _end_ = ':', it means some SPU instruction to follow but next instruction can start without
               //                   Waiting for previous step to be completed. This improves SPU FIFO performance.

               _end_ = (ii==(cnt2-1))?0:(fast?':':'.');

               >FPU.V.MAC(N=cnt,y=(y_type)ws->s4,A=(a_type)a,c=(bfloat *)s2,x1=(float16 *)s1,x2=(zfloat *)s3) _end_;
         }
         ztaTaskYield();
      }
      // Snd results to DDR when FPU computation completed
      > DTYPE(INT16)MEM(req->result,(pid==0)?sz:req->D)[y:(y+cnt)-1] <= DTYPE(INT16)SCRATCH((uint32_t)ws->s4)[0:cnt-1]; 
   }
}

// This kernel function perform matrix multiplication y[D]=x[N]*w[D][N]
// Each entry of x and w is quantized to float with a int8_t value + scaling factor
// Quantization is done in group of GS entries.

void kernel_llm_matmul_q4_exe(
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
   uint32_t resp;
   REQUEST req; 

   ztaInitPcore(zta_pcore_img);

   req.N = N;
   req.D = D;
   req.GS = GS;
   req.x_v = (unsigned int)x_v;
   req.x_s = (unsigned int)x_s;
   req.w_v = (unsigned int)w_v;
   req.w_s = (unsigned int)w_s;
   req.result = (unsigned int)result;

   //FLUSH_DATA_CACHE(); 

   ztaDualHartExecute(matmul_q4,&req);

   ztaJobDone(_req_id); 
}

void kernel_llm_matmul_q8_exe(
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
   uint32_t resp;
   REQUEST req; 

   ztaInitPcore(zta_pcore_img);

   req.N = N;
   req.D = D;
   req.GS = GS;
   req.x_v = (unsigned int)x_v;
   req.x_s = (unsigned int)x_s;
   req.w_v = (unsigned int)w_v;
   req.w_s = (unsigned int)w_s;
   req.result = (unsigned int)result;

   //FLUSH_DATA_CACHE(); 

   ztaDualHartExecute(matmul_q8,&req);

   ztaJobDone(_req_id); 
}

//--------------------------------------------------------------------------
// Quantize BFLOAT to INT8 + scaling factor
// This function is used to quantize activation before the matmul operation
// with weights in INT4 integers.
// N : dimention of x tensor
// x : tensor to be quantized
// s : scaling factor after quantization
// q : INT8 value after quantization
//
// Reference C/C++ implementation
//    llm_ref.c::kernel_ref_llm_quantize_exe
//--------------------------------------------------------------------------

// Work space definition for this kernel

#define BATCH_QUANT 1024 

#define BATCH_DIVIDE 1024 

typedef struct {
   float    y16[BATCH_QUANT];
   float    x[BATCH_QUANT];
   float    y[BATCH_QUANT];
   float    temp[BATCH_QUANT];
   float    x2[BATCH_QUANT];
   float    y2[BATCH_QUANT];
} quantize_ws;

void kernel_llm_quantize_exe(int reqId,int N,float16_t *x,float16_t *s,int16_t *q) {
   int cnt,cnt2;
   unsigned int y16;
   uint32_t resp;
   int GS=32;
   int num_groups = N / GS;
   int i,j,k,m;
   int remain,remain2;
   uint32_t x1,y;
   int group;
   uint32_t qy,qc,qx;
   quantize_ws *ws=0;
   char _end_;

   assert((N%32)==0); 

   y16 = (uint32_t)s;
   cnt=BATCH_QUANT;
   cnt2=cnt/GS;

   for(i=0,j=0;i < N;i+=cnt,j+=cnt2) 
   {
      remain = N-i;
      if(remain < 64)
         remain = 64;
      if(remain > BATCH_QUANT)
         remain = BATCH_QUANT;
      remain2 = remain/32;

      // Find the max in the group 

      > DTYPE(INT16)SCRATCH((uint32_t)ws->x,remain)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[i:i+remain-1];

      > FPU.V.MAX.ABS(N=remain,y=(float *)ws->y,x=(bfloat *)ws->x,g=31);

      // Then divide the MAX by 2047, get result in FP16, this the the scaling factor used
      // when dequantize
//VUONG FAIL HERE
      >FPU.V.MAC(N=remain2,y=(bfloat *)ws->y16,x1=(float *)ws->y,x2=(float)4.8851978505e-4);

      >DTYPE(INT16)MEM(y16,N/32)[j:j+remain2-1] <= DTYPE(INT16)SCRATCH((uint32_t)ws->y16,remain2)[:];

      reciprocal(remain2,ws->y16,FPU_SET_W_BFLOAT|FPU_SET_M_ADDR,ws->y,ws->temp);

      x1 = (unsigned int)(&((uint16_t *)x)[j * GS]);
      y = (unsigned int)(&q[0]);

      > DTYPE(INT16)SCRATCH((uint32_t)ws->x2,remain)[:] <= DTYPE(INT16)MEM(x1,remain)[:];

      // Scale the group to INT8

      for (m = 0,qy=(uint32_t)(ws->y2),qc=(uint32_t)(ws->y),qx=(uint32_t)(ws->x2); 
           m < cnt2;
           m++,qy+=(GS*sizeof(int16_t)),qc+=4,qx+=GS*2) {
         group = j+m;
         if(group >= num_groups) 
            break; 

         // Group the SPU instructions into block of instructions except for the last step
         // This improves pipeline performance of SPU
         // _end_ = 0 means the end of a group of SPU instructions
         // _end_ = . means there are other SPU instruction to follow

         _end_ = (((m%8)==7) || group==(num_groups-1) || (m==(cnt2-1)))? 0 : '.';

         > FPU.V.MAC(N=GS,y=(int16 *)qy,c=(float *)qc,x1=(bfloat *)qx) _end_;
      }
      >DTYPE(INT16)MEM(y,N)[i:(i+remain)-1] <= DTYPE(INT16)SCRATCH((uint32_t)ws->y2,remain)[:];    
      >BARRIER;
   }
   ztaJobDone(reqId);
} 

//-----------------------------------------------------------------
// Perform dot product y[0:K=1]=SUM(x1[0:N-1]*x2[0:K-1][0:N-1]);
// This is primarily used by LLM's attention first stage.
// This operation is both computing and memory bound. Do it using
// dual HART to overlap memory and computing cycles.
// Below is the expected clock counts for computing and memory 
//    Computing clock = (N+N)*K + K = 2*N*K + K
//    Memory transfer clock = N+N*K
// Reference C/C++ implementation
//    llm_ref.c::kernel_ref_llm_quantize_exe
//-----------------------------------------------------------------

// Work space definition for this kernel

#define DOT_PRODUCT_BATCH  64

#define DOT_PRODUCT_BATCH2  32

typedef struct {
   float16_t   x1[DOT_PRODUCT_BATCH];
   float16_t   x2[DOT_PRODUCT_BATCH2][DOT_PRODUCT_BATCH];
   float       sum[DOT_PRODUCT_BATCH];
   float16_t   sum2[DOT_PRODUCT_BATCH];
} dot_product_ws;

typedef struct 
{
   int N;
   int K;
   float16_t *x1;
   float16_t *_x2;
   int _x2_dim;
   float16_t *_y;
   float scale;
} REQUEST_DOT_PRODUCT; 

static void llm_dot_product_exe(void *_p,int pid)
{
   int i,j,k,cnt,cnt2;
   uint32_t resp;
   dot_product_ws *ws=0;
   int sz;
   bool last;
   REQUEST_DOT_PRODUCT *req = (REQUEST_DOT_PRODUCT *)_p;
   uint32_t sum;
   uint32_t scale;
   uint32_t x1;
   uint32_t x2;
   uint32_t y,yfmt,A,Afmt;
   char _end_;

   if(pid==0) {
      ws = (dot_product_ws *)0;
   } else {
      ws = (dot_product_ws *)(SRAM_SIZE/2);
   }
   sz = (req->K+1)/2; // Each heart doing half of N

   if(sz > req->K)
      sz=req->K;

   for(j=(pid==0)?0:sz;j < ((pid==0)?sz:req->K);j+=DOT_PRODUCT_BATCH2)
   {
      cnt2 = (pid==0)?sz:req->K-j;
      if(cnt2 >= DOT_PRODUCT_BATCH2) {
         cnt2 = DOT_PRODUCT_BATCH2;
      }
      if(cnt2==0)
         break;

      for(i=0;i < req->N;i += DOT_PRODUCT_BATCH)
      {
         cnt = (req->N-i);
         if(cnt <= DOT_PRODUCT_BATCH) {
            last = true;
         }
         else
         {
            cnt = DOT_PRODUCT_BATCH;
            last = false;
         }
      
         > DTYPE(INT16)SCRATCH((uint32_t)ws->x1)[0:cnt-1] <= DTYPE(INT16)MEM((uint32_t)req->x1,req->N)[i:(i+cnt)-1];

         > DTYPE(INT16)SCRATCH((uint32_t)ws->x2,DOT_PRODUCT_BATCH2,DOT_PRODUCT_BATCH)[0:cnt2-1][0:cnt-1] <= DTYPE(INT16)MEM((uint32_t)req->_x2,req->K,req->_x2_dim)[j:j+cnt2-1][i:(i+cnt)-1];

         sum = (uint32_t)&ws->sum[0];
         scale = *((uint32_t *)&req->scale);
         x1 = (uint32_t)ws->x1;
         x2 = (uint32_t)(&ws->x2[0][0]);

         for(k=0;k < cnt2;k++,sum += 4,x2 += DOT_PRODUCT_BATCH*2)
         {
            y = last?(uint32_t)(&ws->sum2[k]):sum; 

            yfmt = ((last)?FPU_SET_W_BFLOAT:FPU_SET_W_FP32)|FPU_SET_M_ADDR; 
            
            A=(i==0)?0:sum;
            
            Afmt=((i==0)?FPU_SET_M_VALUE:FPU_SET_M_ADDR)|FPU_SET_W_FP32;

            // Group SPU instructions except for the last step. This improves SPU pipeline performance
            // _end_ = 0 --> Last step of SPU instructions block of execution
            // -end_ = : --> More SPU instructions to follow
            
            _end_=(k==(cnt2-1))?0:':'; 
            
            // Below is the long dot product. A parameter is used to combine multiple dotproduct results
            // y = A+sum(x1*x2*scale)

            >FPU.V.FMA(N=cnt,y=(yfmt)y,c=(float)scale,x1=(bfloat *)x1,x2=(bfloat *)x2,A=(Afmt)A) _end_;
         }
         ztaTaskYield();  
      }
      >DTYPE(INT16)MEM((uint32_t)req->_y,((pid==0)?sz:req->K))[j:j+cnt2-1] <= DTYPE(INT16)SCRATCH((uint32_t)ws->sum2,cnt2)[0:cnt2-1];   
   } 
   >BARRIER;
}

void kernel_llm_dot_product_exe(int reqId,int N,int K,float16_t *x1,float16_t *_x2,int _x2_dim,float16_t *_y,float scale)
{
   REQUEST_DOT_PRODUCT req;
   uint32_t resp;

   req.N = N;
   req.K = K;
   req.x1 = x1;
   req._x2 = _x2;
   req._x2_dim = _x2_dim;
   req._y = _y;
   req.scale = scale;
   
   ztaDualHartExecute(llm_dot_product_exe,&req);

   ztaJobDone(reqId); 
}

//--------------------------------------------------------------------------
// Perform dot product y[0:N-1]=SUM(x1[0:K-1]*x2[0:N-1][0:K-1])
// This is used by LLM's attention second stage after attention first stage
// and softmax.
// Reference C/C++ implementation
//    llm_ref.c:llm_ref_dot_product2_exe
//--------------------------------------------------------------------------

// Work space definition for this kernel
//#define DOT_PRODUCT_K_BATCH 64

#define DOT_PRODUCT_K_BATCH 48

#define DOT_PRODUCT_N_BATCH 32

typedef struct {
   float16_t   sram_x1[DOT_PRODUCT_K_BATCH];
   float16_t   sram_x2[DOT_PRODUCT_N_BATCH][DOT_PRODUCT_K_BATCH];
   float16_t   temp[DOT_PRODUCT_K_BATCH][DOT_PRODUCT_N_BATCH];
   float       sram_sum[DOT_PRODUCT_N_BATCH];
   float16_t   sram_sum2[DOT_PRODUCT_N_BATCH];
   float16_t   temp2[16][DOT_PRODUCT_N_BATCH];
} dot_product2_ws;

typedef struct {
   int N;
   int _K;
   float16_t *x1;
   float16_t *x2;
   int x2_dim;
   float16_t *_y;
} REQUEST_DOT_PRODUCT2;

// -->DP N=64 _K=1 x2_dim=192 

static void llm_dot_product2_exe(void *_p,int pid)
{
   int i,j,k,kk;
   uint32_t resp;
   int K;
   int cnt,cnt2,cnt3,cnt4;
   int sz;
   dot_product2_ws *ws;
   int max_y;
   bool last;
   REQUEST_DOT_PRODUCT2 *req = (REQUEST_DOT_PRODUCT2 *)_p;
   uint32_t sum,x1,x2;
   uint32_t y,yfmt,A,Afmt;
   char _end_;

   if(pid==0) {
      ws = (dot_product2_ws *)0;
   } else {
      ws = (dot_product2_ws *)(SRAM_SIZE/2);
   }

   assert((req->N%8)==0);

   sz = req->N/2; // Each heart doing half of N

   K = ((req->_K+7)/8)*8; // SUM operation requires multiple of 4 number of entries

   for(k=(pid==0)?0:sz;k < ((pid==0)?sz:req->N);k += DOT_PRODUCT_N_BATCH)
   {
      cnt2 = ((pid==0)?sz:req->N)-k;
      if(cnt2 > DOT_PRODUCT_N_BATCH)
         cnt2 = DOT_PRODUCT_N_BATCH;
      if(cnt2==0)
         break;
      
      for(j=0;j < K;j += DOT_PRODUCT_K_BATCH)
      {
         cnt = K-j;
         if(cnt <= DOT_PRODUCT_K_BATCH) {
            last = true;
         } else {
            last = false;
            cnt = DOT_PRODUCT_K_BATCH; 
         }

         // Transfer tensors from DDR to SRAM 

         > DTYPE(INT16)SCRATCH((uint32_t)ws->sram_x1,cnt)[0:cnt-1] <= DTYPE(INT16)MEM((uint32_t)req->x1,req->_K)[j:j+cnt-1];

         cnt3 = 4;
         cnt4 = (cnt+cnt3-1)/cnt3;

         > FOR(L=0:cnt4-1) FOR(I=0:cnt3-1) FOR(J=0:NUM_PCORE-1) FOR(K=0:cnt2/NUM_PCORE-1) DTYPE(INT16) PCORE[J].THREAD[I].llm_dotproduct::x[L][K] 
         > <= 
         > DTYPE(INT16)MEM((uint32_t)req->x2,req->_K,req->x2_dim)[j:j+cnt3*cnt4-1][k:k+cnt2-1];

         > BARRIER;
         
         > FOR(J=0:cnt2/NUM_PCORE-1) FOR(L=0:cnt4-1) FOR(K=0:NUM_PCORE-1) FOR(I=0:cnt3-1) DTYPE(INT16)SCRATCH((uint32_t)ws->sram_x2,NUM_PCORE,DOT_PRODUCT_N_BATCH/NUM_PCORE,DOT_PRODUCT_K_BATCH/4,4)[K][J][L][I]
         > <=
         > FOR(K=0:cnt2/NUM_PCORE-1) FOR(L=0:cnt4-1) FOR(J=0:NUM_PCORE-1) FOR(I=0:cnt3-1) SCATTER DTYPE(INT16) PCORE[J].THREAD[I].llm_dotproduct::x[L][K];

         // Perform dot product 
         sum = (uint32_t)&ws->sram_sum[0];
         
         x2 = (uint32_t)&ws->sram_x2[0][0];
         
         x1 = (uint32_t)ws->sram_x1;

         for(i=0;i < cnt2;i++,sum+=4,x2+=DOT_PRODUCT_K_BATCH*2)
         {
            y = last?(uint32_t)(&ws->sram_sum2[i]):sum;

            yfmt = ((last)?FPU_SET_W_BFLOAT:FPU_SET_W_FP32)|FPU_SET_M_ADDR; 

            A=(j==0)?0:sum;

            Afmt=((j==0)?FPU_SET_M_VALUE:FPU_SET_M_ADDR)|FPU_SET_W_FP32;

            // SPU instructions are group together for better SPU pipeline performance
            // _end_=0 --> This is the last SPU instruction in the group of instructions
            // _end_=: --> There are more SPU instructions to follow. : means start the next step immediately and
            //             not waiting for previous step to complete

            _end_ = (i==(cnt2-1))?0:':'; 
//            _end_ = (i==(cnt2-1))?0:'.';

            >FPU.V.FMA(N=cnt,y=(yfmt)y,x1=(bfloat *)x2,x2=(bfloat *)x1,A=(Afmt)A) _end_;   
         } 
         ztaTaskYield(); 
      }
      >DTYPE(INT16)MEM((uint32_t)req->_y,((pid==0)?sz:req->N))[k:k+cnt2-1] <= DTYPE(INT16)SCRATCH((uint32_t)ws->sram_sum2,DOT_PRODUCT_N_BATCH)[0:cnt2-1];   
   }
}

void kernel_llm_dot_product2_exe(int reqId,int N,int _K,float16_t *x1,float16_t *x2,int x2_dim,float16_t *_y)
{
   REQUEST_DOT_PRODUCT2 req;
   uint32_t resp;

   req.N = N;
   req._K = _K;
   req.x1 = x1;
   req.x2 = x2;
   req.x2_dim = x2_dim;
   req._y = _y;

   ztaDualHartExecute(llm_dot_product2_exe,&req);

   ztaJobDone(reqId);
}

//--------------------------------------------------------------------------
// Approximate cosine with Taylor expansion
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_llm_cosine_exe
//--------------------------------------------------------------------------

// Work space definiton for this kernel

#define COSINE_BATCH 512 

typedef struct{
   float    xin[COSINE_BATCH]; 
   float    x[COSINE_BATCH];
   float    x2[COSINE_BATCH];
   float    y[COSINE_BATCH];
   float    y2[COSINE_BATCH];
   float    tmp1[COSINE_BATCH];
   float    tmp2[COSINE_BATCH];
} ws_cosine;

void kernel_llm_cosine_exe(int reqId,int N,float *x,float scale,float *y)
{
   int i;
   int cnt;
   ws_cosine *ws=0;
   uint32_t resp;

   for(i=0;i < N;i += COSINE_BATCH) {
      cnt = N-i;
      if(cnt > COSINE_BATCH)
         cnt = COSINE_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->xin[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,2*N)[2*i:2*i+2*cnt-1];
      
      // Calculate x=((x)mod2pi)−pi
//VUONG TRY HERR

      >FPU.V.MAC(N=cnt,y=(float *)ws->x,c=(float)scale,x1=(float *)ws->xin); // x = scale*x

      >FPU.V.MAC(N=cnt,y=(float *)ws->x,A=3.141592741,x1=(float *)ws->x); // x = x+pi

      >FPU.V.MAC.FLOOR(N=cnt,y=(float *)ws->tmp1,c=0.15915493667,x1=(float *)ws->x); // t1= floor(x/2pi)

      >FPU.V.MAC.ABS(N=cnt,y=(float *)ws->tmp2,A=(float *)ws->x,c=-6.28318548,x1=(float *)ws->tmp1); // t2 = x-t1*(2*pi)

      >FPU.V.MAC.ABS(N=cnt,y=(float *)ws->x,A=(float *)ws->tmp2,c=-3.14159274); // x = t2-pi 
      
      // Now approximate with Taylor expresion
      
      >FPU.V.MAC(N=cnt,y=(float *)ws->x,A=-1.57079637,x1=(float *)ws->x); // x = x-pi/2

      >FPU.V.MAC(N=cnt,y=(float *)ws->x2,x1=(float *)ws->x,x2=(float *)ws->x); // x2 = x*x

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=0.000198412701,C=-0.0000027557301,x1=(float *)ws->x2); // y= 1/5040 + x2*(-1/362880)

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=-0.0083333338,x1=(float *)ws->x2,x2=(float *)ws->y); // y= -1/120 + x2*y

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=0.166666672,x1=(float *)ws->x2,x2=(float *)ws->y); // y=1/6 + (x2*y)

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=-1.0,x1=(float *)ws->x2,x2=(float *)ws->y); // y=-1 + x2*y

      >FPU.V.MAC(N=cnt,y=(float *)ws->y2,x1=(float *)ws->x,x2=(float *)ws->y); // y = y*x

      >DTYPE(INT16)MEM((uint32_t)y,2*N)[2*i:2*i+2*cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->y2[0]),2*cnt)[0:2*cnt-1];   
      
      > BARRIER;
   }
   ztaJobDone(reqId); 
}

//--------------------------------------------------------------------------
// Approximate sine function with Taylor expansion
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_llm_sine_exe
//--------------------------------------------------------------------------

void kernel_llm_sine_exe(int reqId,int N,float *x,float scale,float *y)
{
   int i;
   int cnt;
   ws_cosine *ws=0;
   uint32_t resp;

   for(i=0;i < N;i += COSINE_BATCH) {
      cnt = N-i;
      if(cnt > COSINE_BATCH)
         cnt = COSINE_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->xin[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,2*N)[2*i:2*i+2*cnt-1];

      // Calculate x=((x)mod2π)−π
  
      >FPU.V.MAC(N=cnt,y=(float *)ws->x,C=(float)scale,x1=(float *)ws->xin); // x = scale*x

      >FPU.V.MAC(N=cnt,y=(float *)ws->x,A=4.712389,c=-1.0,x1=(float *)ws->x); // x = 1.5pi-x;

      >FPU.V.MAC.FLOOR(N=cnt,y=(float *)ws->tmp1,c=0.159154937,x1=(float *)ws->x); // t1= floor(x/2pi)

      >FPU.V.MAC.ABS(N=cnt,y=(float *)ws->tmp2,A=(float *)ws->x,c=-6.28318548,x1=(float *)ws->tmp1); // t2 = x-t1*(2*pi)

      >FPU.V.MAC.ABS(N=cnt,y=(float *)ws->x,A=(float *)ws->tmp2,c=-3.14159274); // x = t2-pi
  
      // Not approximate with Taylor expresion
  
      >FPU.V.MAC(N=cnt,y=(float *)ws->x,A=-1.5707964,x1=(float *)ws->x); // x = x-pi/2

      >FPU.V.MAC(N=cnt,y=(float *)ws->x2,x1=(float *)ws->x,x2=(float *)ws->x); // x2 = x*x;

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=0.000198412701,c=-0.000002755730,x1=(float *)ws->x2); // y= 1/5040 + x2*(-1/362880)

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=-0.0083333338,x1=(float *)ws->x2,x2=(float *)ws->y); // y= -1/120 + x2*y

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=0.166666672,x1=(float *)ws->x2,x2=(float *)ws->y); // y=1/6 + (x2*y)

      >FPU.V.MAC(N=cnt,y=(float *)ws->y,A=-1.0,x1=(float *)ws->x2,x2=(float *)ws->y); // y=-1 + x2*y
      
      >FPU.V.MAC(N=cnt,y=ws->y2,x1=(float *)ws->x,x2=(float *)ws->y); // y = y*x

      >DTYPE(INT16)MEM((uint32_t)y,2*N)[2*i:2*i+2*cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->y2[0]),2*cnt)[0:2*cnt-1];   

      > BARRIER;
   }
   ztaJobDone(reqId); 
}

//--------------------------------------------------------------------------
// Approximate y=EXP(x)
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_llm_exp_exe
//--------------------------------------------------------------------------

// Work space definition for this kernel

#define EXP_BATCH 128

typedef struct{
   float    x[EXP_BATCH];
   float    y[EXP_BATCH];
   float    tmp1[EXP_BATCH];
   float    tmp2[EXP_BATCH];
   float    tmp3[EXP_BATCH];
} ws_exp;

void kernel_llm_exp_exe(int reqId,int N,float *x,float *y)
{
   int i;
   int cnt;
   ws_exp *ws=0;
   uint32_t resp;

   for(i=0;i < N;i += EXP_BATCH) {
      cnt = N-i;
      if(cnt > EXP_BATCH)
         cnt = EXP_BATCH;
      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,2*N)[2*i:2*i+2*cnt-1];

      exponent(cnt,
               ws->x,
               ws->y,
               ws->tmp1,
               ws->tmp2,
               ws->tmp3,
               0.0f,
               2);
  
      >DTYPE(INT16)MEM((uint32_t)y,2*N)[2*i:2*i+2*cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->y[0]),2*cnt)[0:2*cnt-1];   
      
      > BARRIER;
   }
   ztaJobDone(reqId);  
}

//--------------------------------------------------------------------------
// Kernel to accelerate SwigGLU operation
// This is used as LLM's activation function
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_SwiGLU_exp_exe
//--------------------------------------------------------------------------  

// Work space definition for this kernel

#define SWIGLU_BATCH  512

typedef struct
{
   float    hb[SWIGLU_BATCH];
   float    hb2[SWIGLU_BATCH];
   float    tmp1[SWIGLU_BATCH];
   float    tmp2[SWIGLU_BATCH];
   float    tmp3[SWIGLU_BATCH];
   float    tmp4[SWIGLU_BATCH];
   float    tmp5[SWIGLU_BATCH];
} swiglu_ws;

void kernel_llm_SwiGLU_exe(int reqId,float16_t *hb,float16_t *hb2,int N)
{ 
   int i,cnt;
   swiglu_ws *ws=0;
   uint32_t resp;

   for(i=0;i < N;i += SWIGLU_BATCH) {
      cnt = N-i;
      if(cnt > SWIGLU_BATCH)
         cnt = SWIGLU_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->hb[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)hb,N)[i:i+cnt-1];

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->hb2[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)hb2,N)[i:i+cnt-1];

      >FPU.V.MAC(N=cnt,y=(float *)ws->tmp1,c=-1.0,x1=(bfloat *)ws->hb); // tmp1 = -hb

      // tmp5 = expf(tmp1)
      exponent(cnt,
               ws->tmp1, // x
               ws->tmp5, // y
               ws->tmp2,
               ws->tmp3,
               ws->tmp4,
               1.0f,
               2);

      reciprocal(cnt,ws->tmp5,FPU_SET_W_FP32|FPU_SET_M_ADDR,ws->tmp3,ws->tmp2); // tmp3 = 1/tmp1

      >FPU.V.MAC(N=cnt,y=(float *)ws->tmp1,x1=(float *)ws->tmp3,x2=(bfloat *)ws->hb); // tmp1 = tmp3 * hb

      >FPU.V.MAC(N=cnt,y=(bfloat *)ws->hb,x1=(float *)ws->tmp1,x2=(bfloat *)ws->hb2); // hb = tmp1 * hb2

      >DTYPE(INT16)MEM((uint32_t)hb,N)[i:i+cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->hb[0]),cnt)[0:cnt-1];   

      > BARRIER;
   }
   ztaJobDone(reqId);
}

//--------------------------------------------------------------------------
// Kernel to accelerate softmax 
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_softmax_exe 
//--------------------------------------------------------------------------

// Work space definition for this kernel

#define SOFTMAX_BATCH  512

typedef struct
{
   float    x[SOFTMAX_BATCH+32];
   float    tmp1[SOFTMAX_BATCH+32];
   float    tmp2[SOFTMAX_BATCH+8+32];
   float    tmp3[SOFTMAX_BATCH+32];
   float    tmp4[SOFTMAX_BATCH+32];
   float    tmp5[SOFTMAX_BATCH+32];
   float    sum;
   float    max;
   float    scale;
   float    temp;
} softmax_ws; 

void kernel_llm_softmax_exe(int reqId,float16_t *x,int N)
{
   int i;
   int cnt,cnt2;
   uint32_t resp;
   softmax_ws *ws=0;
   softmax_ws *ws2;
   float max_val2;
   float scale;
   static float *scratch=0;
   static int scratch_N=0;

   if(!scratch || scratch_N < N) {
      
      // We need some memory for intermediate results

      if(scratch)
         free(scratch);
      scratch = (float *)malloc(N*sizeof(float));
      scratch_N = N;
   }
   
   // First find the max value
   
   for(i=0;i < N;i += SOFTMAX_BATCH) {
      cnt = N-i;
      if(cnt > SOFTMAX_BATCH)
         cnt = SOFTMAX_BATCH;
      cnt2 = ((cnt+3)/4)*4;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[i:i+cnt-1];
      
      > DTYPE(INT16)SCRATCH(((uint32_t)&ws->x[0])+2*cnt,8)[:] <= INT16(0xff7f);
      
      // Find the maximum value. 
      // A parameter of FPU.MAX is used to chain the FPU.MAX results together. Max from one batch passed to next batch

      if(i==0) {
         >FPU.V.MAX(N=cnt2,y=(float *)&ws->max,x=(bfloat *)ws->x);
      } else {
         >FPU.V.MAX(N=cnt2,A=(float *)&ws->max,y=(float *)&ws->max,x=(bfloat *)ws->x);
      }
   }

   for(i=0;i < N;i += SOFTMAX_BATCH) {
      cnt = N-i;
      if(cnt > SOFTMAX_BATCH)
         cnt = SOFTMAX_BATCH;
      cnt2 = ((cnt+3)/4)*4;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[i:i+cnt-1];

      // temp1 = x - max
      >FPU.V.MAC(N=cnt,y=(float *)ws->tmp1,A=(bfloat *)ws->x,c=(float *)&ws->max,x1=-1.0);
      
      // tmp2 = expf(tmp1)
      exponent(cnt,
               ws->tmp1,
               ws->tmp2,
               ws->tmp3,
               ws->tmp4,
               ws->tmp5,
               0.0f,
               2); 

      > DTYPE(INT16)SCRATCH(((uint32_t)&ws->tmp2[0])+4*cnt,16)[:] <= INT16(0);

      // Take the sum 
      // A parameter of FPU.SUM is used to chain the FPU.SUM results together. Sum from one batch is passed to next batch

      if(i==0) {
         >FPU.V.SUM(N=cnt2,y=(float *)&ws->sum,x=(float *)ws->tmp2);
      } else {
         >FPU.V.SUM(N=cnt2,y=(float *)&ws->sum,x=(float *)ws->tmp2,A=(float *)&ws->sum);
      }
      >DTYPE(INT16)MEM((uint32_t)scratch,2*N)[2*i:2*i+2*cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->tmp2[0]),2*cnt)[0:2*cnt-1];   

      > BARRIER; 
   }

   // Calculate final results

   reciprocal(1,&ws->sum,FPU_SET_W_FP32|FPU_SET_M_ADDR,&ws->scale,&ws->temp);

   for(i=0;i < N;i += SOFTMAX_BATCH) {
      cnt = N-i;
      if(cnt > SOFTMAX_BATCH)
         cnt = SOFTMAX_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)scratch,2*N)[2*i:2*i+2*cnt-1];

      // temp1 = x - max_val
      >FPU.V.MAC(N=cnt,y=(bfloat *)ws->tmp1,C=(float *)&ws->scale,x1=(float *)ws->x);
      
      >DTYPE(INT16)MEM((uint32_t)x,N)[i:i+cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->tmp1[0]),cnt)[0:cnt-1];   

      > BARRIER; 
   }
   ztaJobDone(reqId); 
}

//--------------------------------------------------------------------------
// Kernel to accelerate RMSNorm stage of LLM
// RMSNorm is a lightweight normalization used in modern LLMs to stabilize 
// training and improve 
// performance compared to LayerNorm
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_llm_rms_exe 
//--------------------------------------------------------------------------

// Work space definition for this kernel

#define RMS_BATCH  512

typedef struct
{
   float    x2[RMS_BATCH+8];
   float    x[RMS_BATCH+8];
   float    o[RMS_BATCH];
   float    w[RMS_BATCH];
   float    sum;
   float    ss;
   float    ss2;
   float    tmp1;
   float    tmp2;
} rms_ws;

void kernel_llm_rms_exe(int reqId,int N,float16_t *x,bool x_is_fp16,float16_t *o,float *w)
{
   int i;
   int cnt;
   uint32_t resp;
   rms_ws *ws=0;
   rms_ws *ws2;
   float ss,ss2;
   static float _N_reciprocal;
   static int _N=0;
   float N_reciprocal;
   int diff;
   uint32_t xfmt;

   if(_N != N) {
      // Save for next time
      _N_reciprocal = 1/(float)N;
      _N = N;
   }
   xfmt = ((x_is_fp16)?FPU_SET_W_FP16:FPU_SET_W_BFLOAT)|FPU_SET_M_ADDR;
   N_reciprocal = _N_reciprocal;
   for(i=0;i < N;i += RMS_BATCH) {
      cnt = N-i;
      cnt = ((cnt+3)/4)*4;
      if(cnt > RMS_BATCH)
         cnt = RMS_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[i:i+cnt-1];

      if(i==0) {
         >FPU.V.FMA(N=cnt,y=(float *)&ws->sum,x1=(xfmt)ws->x,x2=(xfmt)ws->x,A=0.0);
      } else {
         >FPU.V.FMA(N=cnt,y=(float *)&ws->sum,x1=(xfmt)ws->x,x2=(xfmt)ws->x,A=(float *)&ws->sum);
      }
   }

   >FPU.MAC(N=1,y=(float *)&ws->ss,C=(float)N_reciprocal,x1=(float *)(&ws->sum));

   >FPU.MAC(N=1,a=1e-5,y=(float *)&ws->ss,x1=(float *)(&ws->ss));

   invsqrt(1,(float *)&ws->ss,(float *)&ws->ss2,(float *)&ws->tmp1,(float *)&ws->tmp2);

   for(i=0;i < N;i += RMS_BATCH) {
      cnt = N-i;
      if(cnt > RMS_BATCH)
         cnt = RMS_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->w[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)w,2*N)[2*i:2*i+2*cnt-1];

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[i:i+cnt-1];

      // o[j] = weight[j] * (ss * x[j]);

      >FPU.V.MAC(N=cnt,y=(bfloat *)ws->o,c=(float *)&ws->ss2,x1=(xfmt)ws->x,x2=(float *)ws->w);

      >DTYPE(INT16)MEM((uint32_t)o,N)[i:i+cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->o[0]),cnt)[0:cnt-1];   

      > BARRIER; 
   }
   ztaJobDone(reqId);
}

//--------------------------------------------------------------------------
// Kernel to accelerate LLM's RoPE operation
// It is the method most modern LLMs use to represent token positions inside 
// transformers.
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_llm_rope_exe 
//-------------------------------------------------------------------------- 

// Work space definition for this kernel

#define ROPE_BATCH 512

typedef struct
{
   float    fcr[ROPE_BATCH]; 
   float    fci[ROPE_BATCH];
   float    v[2*ROPE_BATCH];
   float    v0[ROPE_BATCH];
   float    v1[ROPE_BATCH];
   float    y[2*ROPE_BATCH];
   float    y0[ROPE_BATCH];
   float    y1[ROPE_BATCH];
} rope_ws;

void kernel_llm_rope_exe(
   int reqId,
   int N,
   float *fcr,
   float *fci,
   float16_t *v,
   float16_t *y
)
{
   int i,cnt;
   uint32_t resp;
   rope_ws *ws=0;

   for(i=0;i < N;i += ROPE_BATCH)
   {
      cnt = N-i;
      if(cnt > ROPE_BATCH)
         cnt = ROPE_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->fcr[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)fcr,2*N)[2*i:2*i+2*cnt-1];
      
      > DTYPE(INT16)SCRATCH((uint32_t)&ws->fci[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)fci,2*N)[2*i:2*i+2*cnt-1];

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->v[0],2*cnt)[:] <= DTYPE(INT16)MEM((uint32_t)v,2*N)[2*i:2*i+2*cnt-1];

      // v0[N] = v[N][0]

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->v0[0],cnt)[:] <= DTYPE(INT16)SCRATCH((uint32_t)&ws->v[0],cnt,2,1)[:][0][:];

      // v1[N] = v[N][1]

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->v1[0],cnt)[:] <= DTYPE(INT16)SCRATCH((uint32_t)&ws->v[0],cnt,2,1)[:][1][:];

      >FPU.V.MAC(N=cnt,y=(float *)ws->y0,x1=(bfloat *)ws->v0,x2=(float *)ws->fcr); // y0[N]=v0[N]*fcr[N]

      >FPU.V.MAC(N=cnt,y=(bfloat *)ws->y0,A=(float *)ws->y0,c=-1.0,x1=(bfloat *)ws->v1,x2=(float *)ws->fci); // y0[N]=y0[N]-v1[N]*fci[N]

      >FPU.V.MAC(N=cnt,y=(float *)ws->y1,x1=(bfloat *)ws->v0,x2=(float *)ws->fci); // y1[N]=v0[N]*fci[N]

      >FPU.V.MAC(N=cnt,y=(bfloat *)ws->y1,A=(float *)ws->y1,x1=(bfloat *)ws->v1,x2=(float *)ws->fcr); // y1[N]=y1[N]+v1[N]*fcr[N]

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->y[0],cnt,2,1)[:][0][:] <= DTYPE(INT16)SCRATCH((uint32_t)&ws->y0[0],cnt)[:];
      
      > DTYPE(INT16)SCRATCH((uint32_t)&ws->y[0],cnt,2,1)[:][1][:] <= DTYPE(INT16)SCRATCH((uint32_t)&ws->y1[0],cnt)[:];

      > BARRIER;

      >DTYPE(INT16)MEM((uint32_t)y,2*N)[2*i:2*i+2*cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->y[0]),2*cnt)[:];          

      > BARRIER;
   }
   ztaJobDone(reqId);
}

//-------------------------------------------------------------------------- 
// Kernel to accelerate LLM RESIDUAL operation
// Why residuals matter?
//    Prevent vanishing gradients
//    Allow deep models to train
//    Stabilize attention and FFN layers
//    Make it easier to add small updates to big representations
// Reference C/C++ implementation
//     llm_ref.c:kernel_ref_llm_residual_exe
//--------------------------------------------------------------------------

// Work space definition for this kernel

#define RESIDUAL_BATCH 128 

typedef struct 
{
   float    x[RESIDUAL_BATCH];
   float    xb[RESIDUAL_BATCH];
} residual_ws;

void kernel_llm_residual_exe(
   int reqId,
   int N,
   float16_t *x,
   bool x_is_fp16,
   float16_t *y,
   float16_t *xb
   )
{
   int i,cnt;
   uint32_t resp;
   residual_ws *ws=0;
   uint32_t xfmt;

   xfmt = ((x_is_fp16)?FPU_SET_W_FP16:FPU_SET_W_BFLOAT)|FPU_SET_M_ADDR;

   for(i=0;i < N;i += RESIDUAL_BATCH)
   {
      cnt = N-i;
      if(cnt > RESIDUAL_BATCH)
         cnt = RESIDUAL_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[i:i+cnt-1];

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->xb[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)xb,N)[i:i+cnt-1];

      >FPU.V.MAC(N=cnt,y=(bfloat *)ws->x,A=(xfmt)ws->x,x1=(bfloat *)ws->xb);

      >DTYPE(INT16)MEM((uint32_t)y,N)[i:i+cnt-1] <= DTYPE(INT16)SCRATCH(((uint32_t)&ws->x[0]),cnt)[0:cnt-1];   

      > BARRIER; 
   }
   ztaJobDone(reqId);
}

//--------------------------------------------------------------------------
// Find max per blocks first with acceleration
// Then find the maximum value of the results from all the blocks
// This is used by greedy sampling to find best result 
//--------------------------------------------------------------------------

// Work space definition for this kernel

#define MAX_BATCH (4096)
#define MAX_GROUP_SZ 64

typedef struct  {
   uint16_t    x[MAX_BATCH];
   uint16_t    y[MAX_BATCH/MAX_GROUP_SZ];
} find_max_ws;

static int find_max(uint16_t *x,int N)
{
   float f;
   float max=0;
   int i,found=0; 
   
   for(i=0;i < N;i++,x++) {
      f = BF2F(*x);
      if(i==0) {
         max = f;
         found = i;
      }
      else if(max < f) {
         max = f;
         found = i;
      }
   }
   return found;
}

#define K_MAX 128

#define MAX_K_GROUP_SZ 64

#define MAX_K_BATCH (MAX_K_GROUP_SZ*32)

typedef struct  {
   uint16_t    x[2][MAX_K_BATCH];
   uint16_t    y[2][MAX_K_BATCH/MAX_K_GROUP_SZ];
} find_max_k_ws;

//--------------------------------------------------------------------------
// Find the top-k tokens of highest probability
//--------------------------------------------------------------------------

int kernel_llm_find_k_max(float16_t *x,uint32_t _N,int K, float scale,int *top,float16_t *topp) {
   uint32_t cnt,cnt2;
   int N;
   int toggle=0;
   uint32_t v;
   uint32_t t;
   static union {
      struct {
         uint16_t idx;
         float16_t f;
      } s;
      uint32_t dw;
   } max[K_MAX];
   bool last;
   find_max_k_ws *ws;
   volatile find_max_k_ws *ws2;
   
   assert(K <= K_MAX);

   ws=(find_max_k_ws *)0;
   
   ws2 = (find_max_k_ws *)0x40000000;

   for(int i=0;i < K;i++) {
      max[i].dw = 0;
   }

   N = ((_N+MAX_K_GROUP_SZ-1)/MAX_K_GROUP_SZ)*MAX_K_GROUP_SZ;

   // Fetch tokens from DDR to SCRATCH

   >DTYPE(INT16)SCRATCH((uint32_t)&ws->x[toggle][0],MAX_K_BATCH)[:] <= DTYPE(INT16)MEM((uint32_t)x,_N)[0:MAX_K_BATCH-1];

   >FPU.V.MAC(N=MAX_K_BATCH,y=(bfloat *)ws->x[toggle],c=(float)scale,x1=(bfloat *)ws->x[toggle]);

   >FPU.V.MAX(N=MAX_K_BATCH,y=(bfloat *)ws->y[toggle],x=(bfloat *)ws->x[toggle],g=63);

   for (int i = 0; i < N; i+=MAX_K_BATCH) {
      cnt = N-i;
      cnt = MIN(cnt,MAX_K_BATCH);
      cnt = MAX(cnt,MAX_K_GROUP_SZ);
      last = ((i+cnt) >= N)?true:false;  

      kernel_llm_done();
      
      if(!last) {
         // Prefetch tokens and get FPGA to process for next batch of tokens
         //  while RISCV is busy processing 
         cnt2 = N-(i+MAX_K_BATCH);
         cnt2 = MIN(cnt2,MAX_K_BATCH);
         cnt2 = MAX(cnt2,MAX_K_GROUP_SZ);

         >DTYPE(INT16)SCRATCH((uint32_t)&ws->x[!toggle][0],cnt2)[:] <= DTYPE(INT16)MEM((uint32_t)x,_N)[i+MAX_K_BATCH:i+MAX_K_BATCH+cnt2-1];

         >FPU.V.MAC(N=cnt2,y=(bfloat *)ws->x[!toggle],c=(float)scale,x1=(bfloat *)ws->x[!toggle]);

         >FPU.V.MAX(N=cnt2,y=(bfloat *)ws->y[!toggle],x=(bfloat *)ws->x[!toggle],g=63);
      }

      FLUSH_DATA_CACHE();

      for(int j=0;j < cnt;j+=MAX_K_GROUP_SZ) {
         if( BFCMP(ws2->y[toggle][j/MAX_K_GROUP_SZ],max[K-1].s.f) <= 0)
            continue;
         for(int k=0;k < MAX_K_GROUP_SZ;k++) {
            v = ws2->x[toggle][j+k];
            if (BFCMP(v,max[K-1].s.f) > 0) {
               max[K-1].s.f = v;
               max[K-1].s.idx = i+j+k;
               // Push the new entries down the max probability list in order
               // of probability value
               for(int kk=K-1;kk >= 1;kk--) {
                  if(BFCMP(max[kk].s.f,max[kk-1].s.f) <= 0)
                     break;
                  t = max[kk-1].dw;max[kk-1].dw=max[kk].dw;max[kk].dw=t;
               }
            }
         }
      }
      toggle = !toggle;
   }

   for(int i=0;i < K;i++) {
      top[i] = (int)max[i].s.idx;
      topp[i] = max[i].s.f;
   }
   return 0;
}

//--------------------------------------------------------------------------
// Kernel to find the maximum of series of blocks
// We need to do into 2 steps because we need to find the position
// of the max value with find_max function
//--------------------------------------------------------------------------

int kernel_llm_find_max(float16_t *x,uint32_t N) {
   uint32_t i,cnt,cnt2;
   float max;
   int maxi=0;
   int group;
   int numGroup;
   find_max_ws *ws=(find_max_ws *)0;
   volatile find_max_ws *ws2 = (find_max_ws *)0x40000000;

   for(i=0;i < N;i+=MAX_BATCH) {
      cnt = N-i;
      cnt = ((cnt+3)/4)*4;
      if(cnt > MAX_BATCH)
         cnt = MAX_BATCH;

      > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[i:i+cnt-1];

      >FPU.V.MAX(N=cnt,y=(bfloat *)ws->y,x=(bfloat *)ws->x);

      kernel_llm_done();

      FLUSH_DATA_CACHE();

      if(i==0) {
         maxi = i;
         max = BF2F(ws2->y[0]);
      }
      else {
         if(max < BF2F(ws2->y[0])) {
            maxi = i;
            max = BF2F(ws2->y[0]);
         }
      }
   } 

   cnt = N-maxi;

   cnt = ((cnt+MAX_GROUP_SZ-1)/MAX_GROUP_SZ)*MAX_GROUP_SZ;

   numGroup = cnt/MAX_GROUP_SZ;

   numGroup = ((numGroup+3)/4)*4;

   cnt = numGroup * MAX_GROUP_SZ;

   if(cnt > MAX_BATCH)
      cnt = MAX_BATCH;

   > DTYPE(INT16)SCRATCH((uint32_t)&ws->x[0],cnt)[:] <= DTYPE(INT16)MEM((uint32_t)x,N)[maxi:maxi+cnt-1];

   cnt2=(MAX_GROUP_SZ-1);

   >FPU.V.MAX(N=cnt,y=(bfloat *)ws->y,x=(bfloat *)ws->x,g=(FPU_SET_M_VALUE|FPU_SET_W_FP32)cnt2);

   kernel_llm_done();

   FLUSH_DATA_CACHE();

   group = find_max((uint16_t *)(&ws2->y[0]),cnt/MAX_GROUP_SZ);

   return maxi+group*MAX_GROUP_SZ+find_max((uint16_t *)(&ws2->x[group*MAX_GROUP_SZ]),MAX_GROUP_SZ); 
}

//--------------------------------------------------------------------------
// To mark the last step of LLM forward chain
// We stop at end of every token since we need to do the sampling step
// which requires serial computation from RISCV
//--------------------------------------------------------------------------

void kernel_llm_done()
{
   static uint32_t reqid=1000;
   uint32_t resp;
//   > WAIT_FPU;
   ztaJobDone(reqid); 
   for(;;) {
      if(ztaReadResponse(&resp) && resp==reqid)
         break;
   }
   reqid++;
}

//--------------------------------------------------------------------------
// Some tools to measure elapsed time between tick and tock.
//--------------------------------------------------------------------------

static uint32_t mytick;

void kernel_tick()
{
   uint32_t resp;
   ztaJobDone(98); 
   for(;;) {
      if(ztaReadResponse(&resp))
      {
         if(resp==98)
            break;
      }
   }
   mytick = Time2Get();
}

uint32_t kernel_tock()
{
   uint32_t resp;
   ztaJobDone(98); 
   for(;;) {
      if(ztaReadResponse(&resp))
      {
         if(resp==98)
            break;
      }
   }
   return (((int)Time2Get()-(int)mytick))/120;
}
