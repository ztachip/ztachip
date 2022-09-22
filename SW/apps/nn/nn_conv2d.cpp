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

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn_conv2d.h"
extern "C"
{
#include "kernels/fcn.h"
#include "kernels/nn.h"
#include "kernels/conv.h"
}

// Do convolution layer

NeuralNetLayerConv2D::NeuralNetLayerConv2D(NeuralNet *nn,NeuralNetOperatorDef* def,ConvolutionType _type) : NeuralNetLayer(nn,def) {
   m_type=_type;
}

NeuralNetLayerConv2D::~NeuralNetLayerConv2D() {
}

ZtaStatus NeuralNetLayerConv2D::Prepare() {
   NeuralNetOperatorDef* op=&m_def;
   int topcnt=(*op->output_shape[0])[3];
   int topdim=(*op->output_shape[0])[1];
   int botcnt=(*op->input_shape[0])[3];
   int botdim=(*op->input_shape[0])[1]+2*op->u.conv.pad_w;
   int kz=(*op->u.conv.filter_shape)[1];
   int64_t D=((int64_t)1)<<(31-op->u.conv.output_shift);
   int64_t bias=((op->u.conv.output_activation_min-op->u.conv.output_offset)*D)/(int64_t)op->u.conv.output_multiplier;
   if((*op->input_shape[0])[1]==1) {
      // This is FCN layer
      m_shmFilter=GenFcWeight(op->u.conv.filter,topcnt,botcnt,
                              m_strategy.fcn.coef_dim,
                              &m_strategy.fcn.nthread,
                              &m_strategy.fcn.npcore);
   } else {
      // This is convolution layer
      m_shmFilter=GenConvolutionWeight(op->u.conv.filter,*op->u.conv.filter_shape,topcnt,
                                                   (op->op==NeuralNetOperatorConvDepthWise)?1:botcnt,kz);
      ConvolutionStrategy(topcnt,topdim,botcnt,botdim,
                         (*op->u.conv.filter_shape)[1],
                           op->u.conv.stride_w,
                           NUM_PCORE,
                           &m_strategy.conv.dx,
                           &m_strategy.conv.dycnt,
                           &m_strategy.conv.groupsz,
                           CONV_SMALL_BOT_DX,
                           CONV_SMALL_BOT_DY,
                           MAX_CONV_Y_DIM);
   }
   GenBias((int32_t *)op->u.conv.bias,topcnt,(int32_t)bias,&m_shmBiasHi,&m_shmBiasLo);

   m_shmSpu=ztahostBuildSpuBundle(3,
                              SpuEvalActivation,this,0,0,
                              SpuEvalInput,this,0,0,
                              SpuEvalFilter,this,0,0);

   m_nn->BufferAllocateExternal(m_shmSpu);
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerConv2D::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   int in_fmt,out_fmt;
   // Input is interleave fmt for depth_wise, flat format for other type of convolution
   in_fmt=(op->op==NeuralNetOperatorConvDepthWise)?kTensorFormatInterleaved:kTensorFormatFlat;
   if(m_nn->BufferGetInterleave(op->output[0]) && m_nn->BufferGetFlat(op->output[0])) {
      // Output both flat and interleave format
      out_fmt=kTensorFormatFlatAndInterleaved;
   } else if(m_nn->BufferGetInterleave(op->output[0])) {
      // Output interleave format only
      out_fmt=kTensorFormatInterleaved;
   } else if(m_nn->BufferGetFlat(op->output[0])) {
      // Output flat format only
      out_fmt=kTensorFormatFlat;
   } else {
      assert(0); // ?????
   } 

   if(op->op==NeuralNetOperatorConv2D) {
      if(((*op->input_shape[0])[1]==1)?true:false) {
         // Do inner product
         bool outInterleave=(m_nn->BufferGetInterleave(op->output[0])!=0);
         kernel_innerProduct_exe(
            (unsigned int)GetNextRequestId(queue),
			(unsigned int)m_shmFilter,
			(unsigned int)m_shmBiasHi,
			(unsigned int)m_shmBiasLo,
			(unsigned int)m_nn->BufferGetFlat(op->input[0]),
			(unsigned int)(outInterleave?m_nn->BufferGetInterleave(op->output[0]):m_nn->BufferGetFlat(op->output[0])),
            (*op->output_shape[0])[3],
            (*op->input_shape[0])[3],
            m_strategy.fcn.coef_dim[0],
            m_strategy.fcn.coef_dim[1],
			(unsigned int)m_shmSpu,
            op->u.conv.output_scale,
            m_strategy.fcn.npcore,
            m_strategy.fcn.nthread);
      } else {
         // Conv
          kernel_convolution_exe(
             (unsigned int)GetNextRequestId(queue),
    		 (unsigned int)m_shmFilter,
    		 (unsigned int)m_shmBiasHi,
    		 (unsigned int)m_shmBiasLo,
    		 (unsigned int)((in_fmt==kTensorFormatInterleaved)?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0])),
    		 (unsigned int)m_nn->BufferGetFlat(op->output[0]),
    		 (unsigned int)m_nn->BufferGetInterleave(op->output[0]),
             (*op->u.conv.filter_shape)[1],
             (*op->output_shape[0])[3],
             (*op->output_shape[0])[1],
             (*op->input_shape[0])[3],
             (*op->input_shape[0])[1]+2*op->u.conv.pad_w,
             op->u.conv.input_offset,
             op->u.conv.output_scale,
    		 (unsigned int)m_shmSpu,
             1,
             op->u.conv.stride_w,
             op->u.conv.pad_w,
             m_strategy.conv.dx,
             m_strategy.conv.dycnt,
             m_strategy.conv.groupsz,
             in_fmt,
             out_fmt);
      }
   } else {
      // ConvDepth
      kernel_convolution_depthwise_exe(
         (unsigned int)GetNextRequestId(queue),
		 (unsigned int)m_shmFilter,
		 (unsigned int)m_shmBiasHi,
		 (unsigned int)m_shmBiasLo,
		 (unsigned int)((in_fmt==kTensorFormatInterleaved)?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0])),
		 (unsigned int)(m_nn->BufferGetFlat(op->output[0])),
		 (unsigned int)(m_nn->BufferGetInterleave(op->output[0])),
         (*op->u.conv.filter_shape)[1],
         (*op->output_shape[0])[3],
         (*op->output_shape[0])[1],
         (*op->input_shape[0])[3],
         (*op->input_shape[0])[1]+2*op->u.conv.pad_w,
         op->u.conv.input_offset,
         op->u.conv.output_scale,
		 (unsigned int)m_shmSpu,
         1,
         op->u.conv.stride_w,
         op->u.conv.pad_w,
         m_strategy.conv.dx,
         m_strategy.conv.dycnt,
         m_strategy.conv.groupsz,
         in_fmt,
         out_fmt);
   }
   return ZtaStatusOk;
}

int16_t NeuralNetLayerConv2D::SpuEvalActivation(int16_t _in,void *pparm,uint32_t parm,uint32_t parm2) {
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   static int SCALE=0;
   static int64_t N=0;
   static int64_t D=0;
   static int64_t X_min=0;
   static int64_t X_max=0;
   static int64_t x_min=0;
   static int64_t x_max=0;
   static int OFFSET=0;

   NeuralNetOperatorDef *op=layer?&((NeuralNetLayerConv2D *)layer)->m_def:0;
   if(op) {
      int64_t range;
      int32_t bits;
      OFFSET=op->u.conv.output_offset;
      N=(int64_t)op->u.conv.output_multiplier;
      D=((int64_t)1)<<(31-op->u.conv.output_shift);
      x_max=op->u.conv.output_activation_max;
      x_min=op->u.conv.output_activation_min;
      X_max=((x_max-OFFSET)*D)/N;
      X_min=((x_min-OFFSET)*D)/N;
      range=(X_max-X_min);
      assert(range >= 0);
      bits=0;
      while(range != 0) {
         range=range>>1;
         bits++;
      }
      SCALE=(bits > 11)?bits-11:0;
      op->u.conv.output_scale=SCALE;
   }
   float x;
   float _in2;
   int16_t out;
   _in2 = (float)_in*((float)(1<<SCALE));
   _in2 = _in2+X_min;
   x=(_in2*N+D/2)/D+OFFSET;
   if(x < x_min)
      x=(float)x_min;
   else if(x > x_max)
      x=(float)x_max;
   Util::Float2Int(&x,&out,DATA_BIT_WIDTH-1,1);
   return out;
}

// SPU evaluation function for input

int16_t NeuralNetLayerConv2D::SpuEvalInput(int16_t _in,void *pparm,uint32_t parm,uint32_t parm2) {
   int16_t out;
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   static int32_t offset=0;
   NeuralNetOperatorDef *op=layer?&((NeuralNetLayerConv2D *)layer)->m_def:0;
   if(op)
      offset=op->u.conv.input_offset;
   out=(int16_t)(_in+offset);
   return out;
}

// SPU evaluation for filter

int16_t NeuralNetLayerConv2D::SpuEvalFilter(int16_t _in,void *pparm,uint32_t parm,uint32_t parm2) {
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   int16_t out;
   static int32_t offset=0;
   NeuralNetOperatorDef *op=layer?&((NeuralNetLayerConv2D *)layer)->m_def:0;
   if(op)
      offset=op->u.conv.weights_offset;
   out=(int16_t)(_in+offset);
   return out;
}
// Find a good strategy to do this convolution

ZtaStatus NeuralNetLayerConv2D::ConvolutionStrategy(int topcnt, int topdim, int botcnt, int botdim,int ksz,int stride,int num_pcore,
                                      int *conv_dx,int *conv_dycnt,int *conv_groupsz,
                                      int max_conv_dx,int max_conv_dy,int max_dycnt) {
   int count;
   float efficiency2=-1.0;
   float efficiency, efficiency3;
   int minCount,dycntcnt,conv_dycntcnt;
   int group,dy,x,y;
   topcnt = (topcnt+1)/2;
   minCount=-1;
   for (int dx = 1; dx <= NUM_THREAD_PER_CORE; dx++) {
      x=dx*stride+ksz-stride;
      if (x > max_conv_dx)
         continue;
      count=(topdim+dx-1)/dx;
      if(count < minCount || minCount<0) {
         minCount=count;
         *conv_dx=dx;
      }
   }
   max_conv_dy=(max_conv_dx*max_conv_dy)/ROUND(((*conv_dx)*stride+ksz-stride),VECTOR_WIDTH);
   for (int groupsz = 1; groupsz < num_pcore; groupsz++) {
      if ((num_pcore%groupsz) != 0)
         continue;
      group=num_pcore/groupsz;
      count=ROUND(topcnt,group*VECTOR_WIDTH);
      efficiency3=(float)topcnt / count;
      conv_dycntcnt=-1;
      for (int dycnt=max_dycnt;dycnt >= 1;dycnt--) {
         dy = groupsz*dycnt;
         y = dy*stride + ksz - stride;
         if (y > max_conv_dy)
            continue;
         count = (topdim+dy-1)/dy;
         dycntcnt = count;
         count = (count-1)*dy;
         count += ROUND(topdim-count,groupsz);
         efficiency = efficiency3*(float)(topdim)/(float)(count);
         if ((efficiency > efficiency2) ||
            (efficiency == efficiency2 && dycntcnt == conv_dycntcnt)) {
            efficiency2 = efficiency;
            conv_dycntcnt = dycntcnt;
            *conv_dycnt = dycnt;
            *conv_groupsz = groupsz;
         }
      }
   }
   return ZtaStatusOk;
}

// Generate weight data in shared memory block...
// Reorganize convolution coefficient to match vector word format for pcore

ZTA_SHARED_MEM NeuralNetLayerConv2D::GenConvolutionWeight(uint8_t *_coef,std::vector<int> &shape,int topcnt,int botcnt,int kz) {
   int dx,dx2,h,w,kzz=kz*kz;
   uint8_t *t,*t2,*out;
   ZTA_SHARED_MEM shm;
   uint8_t *tensor2;
   size_t sz;
   int filtertopcnt=shape[0];
   int filterbotcnt=shape[3];
   sz=ROUND(filtertopcnt,VECTOR_WIDTH)*kzz*filterbotcnt;
   tensor2=(uint8_t *)malloc(sz);
   memset(tensor2,0,sz);
   for(int i=0;i < filtertopcnt;i++) {
      for(int j=0;j < kzz;j++) {
         for(int k=0;k < filterbotcnt;k++)
            tensor2[i*filterbotcnt*kzz+k*kzz+j]=_coef[i*kzz*filterbotcnt+j*filterbotcnt+k];
      }
   }
   dx=kzz*botcnt;
   dx2=VECTOR_WIDTH*botcnt;
   if ((topcnt & (VECTOR_WIDTH-1)) != 0)
      topcnt += VECTOR_WIDTH-(topcnt & (VECTOR_WIDTH-1));
   h=(topcnt/VECTOR_WIDTH)*kzz;
   w=botcnt;

   // Interleave weights so that each element of vector is a seperate channel

   t=(uint8_t *)malloc(h*w*VECTOR_WIDTH);
   t2=(uint8_t *)malloc(VECTOR_WIDTH*kzz);
   memset(t,0,h*w*VECTOR_WIDTH);
   memset(t2,0,VECTOR_WIDTH*kzz);
   shm = m_nn->BufferAllocate(h*w*VECTOR_WIDTH);
   out = (uint8_t *)ZTA_SHARED_MEM_P(shm);
   for (int r = 0; r < topcnt/VECTOR_WIDTH; r++) {
      for (int c=0;c < botcnt;c++) {
         for (int c1=c*kzz,index=0; c1 < c*kzz+kzz;c1++) {
            for (int r1 = r*VECTOR_WIDTH; r1 < r*VECTOR_WIDTH+VECTOR_WIDTH; r1++) {
               t2[index] = tensor2[r1*dx+c1];
               index++;
            }
         }
         for (int r1=r*kzz,index=0;r1 < r*kzz+kzz;r1++) {
            for (int c1=c*VECTOR_WIDTH;c1 < c*VECTOR_WIDTH+VECTOR_WIDTH;c1++) {
               t[r1*dx2+c1] = t2[index];
               index++;
            }
         }
      }
   }
   // Transpose the coefficient tensor... 
   for (int r1 = 0; r1 < h; r1++) {
      for (int c1 = 0; c1 < w; c1++) {
         memcpy(out+c1*h*VECTOR_WIDTH+r1*VECTOR_WIDTH,t+r1*w*VECTOR_WIDTH+c1*VECTOR_WIDTH,VECTOR_WIDTH);
      }
   }
   free(t);
   free(t2);
   free(tensor2);
   return shm;
}

// Generate bias data block in shared memory

void NeuralNetLayerConv2D::GenBias(int32_t *bias,int biasLen,int32_t activationBias,ZTA_SHARED_MEM *shmHi,ZTA_SHARED_MEM *shmLo) {
   ZTA_SHARED_MEM biasLo_p,biasHi_p;
   int16_t *biasLo,*biasHi;
   int32_t v;
   int16_t hi,lo;
   int range=(1<<(DATA_BIT_WIDTH-2));
   biasHi_p = m_nn->BufferAllocate(biasLen*sizeof(int16_t));
   biasLo_p = m_nn->BufferAllocate(biasLen*sizeof(int16_t));
   biasLo = (int16_t *)ZTA_SHARED_MEM_P(biasLo_p);
   biasHi = (int16_t *)ZTA_SHARED_MEM_P(biasHi_p);
   for(int i=0;i<biasLen;i++) {
      v=bias[i]-activationBias;
      hi=(int16_t)(v/range);
      lo=(int16_t)(v%range);
      biasHi[i]=hi;
      biasLo[i]=lo;
      assert(std::abs(hi) < range);
      assert(std::abs(lo) < range);
      assert((hi*range+lo)==v);
   }
   *shmHi=biasHi_p;
   *shmLo=biasLo_p;
   return;
}

ZTA_SHARED_MEM NeuralNetLayerConv2D::GenFcWeight(uint8_t *_coef,int _topcnt,int _botcnt,int *coef_dim,int *_nthread,int *_npcore) {
   int8_t temp[IP_CHUNK_SIZE*VECTOR_WIDTH];
   int8_t temp2[IP_CHUNK_SIZE*VECTOR_WIDTH];
   int8_t *temp3;
   int nthread,dx;
   int topcnt2,botcnt2;
   int size;
   int8_t *_gen_coef;
   ZTA_SHARED_MEM out_p;
   int num_pcore=NUM_PCORE;
   nthread=-1;
   int min_extra=-1;
   for(int i=(NUM_THREAD_PER_CORE/2);i < NUM_THREAD_PER_CORE;i++) {
      dx=num_pcore*i*VECTOR_WIDTH;
      int extra=dx*((_topcnt+dx-1)/dx)-_topcnt;
      if(min_extra < 0 || extra < min_extra) {
         min_extra=extra;
         nthread=i;
      }
   }
   dx=num_pcore*nthread*VECTOR_WIDTH;
   topcnt2=((_topcnt+dx-1)/dx)*dx;
   botcnt2=((_botcnt+IP_CHUNK_SIZE-1)/IP_CHUNK_SIZE)*IP_CHUNK_SIZE;
   size=topcnt2*botcnt2;
   out_p=m_nn->BufferAllocate(size);
   _gen_coef = (int8_t *)ZTA_SHARED_MEM_P(out_p);
   for(int i = 0; i < _topcnt; i++) {
      for(int j = 0; j < _botcnt; j++) {
         _gen_coef[j + i*botcnt2] = _coef[j + i*(_botcnt)];
      }
   }
   for(int pid = 0; pid < 2; pid++) {
      for(int i = (pid == 0) ? 0 : dx; i < _topcnt; i += 2 * dx) {
         for(int j = 0; j < _botcnt; j += IP_CHUNK_SIZE) {
            for(int k = i; k < (i + dx); k += VECTOR_WIDTH) {
               for(int l = 0; l < VECTOR_WIDTH; l++) {
                  memcpy(temp + l*IP_CHUNK_SIZE, _gen_coef + ((k + l)*botcnt2 + j),IP_CHUNK_SIZE);
               }
               for(int kk=0;kk < VECTOR_WIDTH;kk++) {
                  for(int jj=0;jj < IP_CHUNK_SIZE;jj++) {
                     temp2[jj*VECTOR_WIDTH + kk]=temp[kk*IP_CHUNK_SIZE + jj];
                  }
               }
               for(int l=0;l < VECTOR_WIDTH;l++) {
                  memcpy(_gen_coef+((k + l)*botcnt2 + j),temp2+l*IP_CHUNK_SIZE,IP_CHUNK_SIZE);
               }
            }
         }
      }
   }
   _topcnt = topcnt2;
   _botcnt = botcnt2/IP_CHUNK_SIZE;
   // Transpose the matrix
   int h = _topcnt;
   int w = _botcnt;
   temp3 = (int8_t *)malloc(h*w*IP_CHUNK_SIZE);
   for (int r1 = 0; r1 < h; r1++) {
      for (int c1 = 0; c1 < w; c1++) {
         memcpy(temp3+c1*h*IP_CHUNK_SIZE+r1*IP_CHUNK_SIZE,
               _gen_coef+r1*w*IP_CHUNK_SIZE+c1*IP_CHUNK_SIZE, 
               IP_CHUNK_SIZE);
      }
   }
   memcpy(_gen_coef,temp3,h*w*IP_CHUNK_SIZE);
   free(temp3);
   coef_dim[0]=_topcnt;
   coef_dim[1]=_botcnt;
   coef_dim[2]=IP_CHUNK_SIZE;
   *_nthread=nthread;
   *_npcore=num_pcore;
   return out_p;
}


