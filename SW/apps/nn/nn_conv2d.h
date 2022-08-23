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

#ifndef _ZTA_NN_CONV2D_H_
#define _ZTA_NN_CONV2D_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn.h"

enum ConvolutionType {
   ConvolutionType2D,
   ConvolutionTypeDepthWise
};

class NeuralNetLayerConv2D : public NeuralNetLayer {
public:
   NeuralNetLayerConv2D(NeuralNet *nn,NeuralNetOperatorDef *def,ConvolutionType _type);
   ~NeuralNetLayerConv2D();
   ZtaStatus Prepare();
   ZtaStatus Evaluate(int queue);
   LayerIoType GetIoType() {return (m_type==ConvolutionTypeDepthWise)?LayerIoTypeInInterleaveOutInterleaveAndOrFlat:LayerIoTypeInFlatOutInterleaveAndOrFlat;}
private:
   static float SpuEvalActivation(float _in,void *pparm,uint32_t parm);
   static float SpuEvalInput(float _in,void *pparm,uint32_t parm);
   static float SpuEvalFilter(float _in,void *pparm,uint32_t parm);
   ZtaStatus ConvolutionStrategy(int topcnt, int topdim, int botcnt, int botdim,int ksz,int stride,int num_pcore,
                                 int *conv_dx,int *conv_dycnt,int *conv_groupsz,
                                 int max_conv_dx,int max_conv_dy,int max_dycnt);
   ZTA_SHARED_MEM GenConvolutionWeight(uint8_t *_coef,std::vector<int> &shape,int topcnt,int botcnt,int kz);
   ZTA_SHARED_MEM GenFcWeight(uint8_t *_coef,int _topcnt,int _botcnt,int *coef_dim,int *_nthread,int *_npcore);
   void GenBias(int32_t *bias,int biasLen,int32_t activationBias,ZTA_SHARED_MEM *shmHi,ZTA_SHARED_MEM *shmLo);
public:
   ConvolutionType m_type;
   ZTA_SHARED_MEM m_shmFilter;
   ZTA_SHARED_MEM m_shmBiasHi;
   ZTA_SHARED_MEM m_shmBiasLo;
   ZTA_SHARED_MEM m_shmSpuInputStream;
   ZTA_SHARED_MEM m_shmSpuActivationStream;
   ZTA_SHARED_MEM m_shmSpuFilterStream;
   ZTA_SHARED_MEM m_shmSpu;
   union {
      struct {
         int dx;
         int dycnt;
         int groupsz;
      } conv;
      struct {
         int nthread;
         int npcore;
         int coef_dim[3];
      } fcn;
   } m_strategy;
private:
   uint32_t m_fcnFunc;
   uint32_t m_convFunc;
   uint32_t m_convDepthwiseFunc;
};

#endif
