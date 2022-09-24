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
#include "../../base/ztalib.h"
#include "kernels/fcn.h"
#include "nn_logistic.h"

// Do logistic layer

#define kLogisticScale 8

NeuralNetLayerLogistic::NeuralNetLayerLogistic(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
}

NeuralNetLayerLogistic::~NeuralNetLayerLogistic() {
}

ZtaStatus NeuralNetLayerLogistic::Prepare() {
   m_shmSpu=ztaBuildSpuBundle(2,
                              SpuEval,this,0,0,
                              SpuEvalScale,this,0,0);
   m_nn->BufferAllocateExternal(m_shmSpu);
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerLogistic::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   bool isInterleave=(m_nn->BufferGetInterleave(op->output[0])!=0);
   kernel_logistic_exe(
      (unsigned int)GetNextRequestId(queue),
      TENSOR::GetTensorSize(*op->input_shape[0]),
      (unsigned int)(isInterleave?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0])),
	  (unsigned int)(isInterleave?m_nn->BufferGetInterleave(op->output[0]):m_nn->BufferGetFlat(op->output[0])),
	  (unsigned int)m_shmSpu);
   return ZtaStatusOk;
}

int16_t NeuralNetLayerLogistic::SpuEval(int16_t _in,void *pparm,uint32_t parm,uint32_t parm2) {
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   static uint8_t lookup[256*kLogisticScale];
   NeuralNetOperatorDef *op=layer?&((NeuralNetLayerLogistic *)layer)->m_def:0;
   if(op) {
      float inverse_scale = 1/op->u.logistic.output.scale;
      int32_t maxval = 256*kLogisticScale-1;
      int32_t minval = 0;
      for (int32_t val = minval; val <= maxval; ++val) {
         float dequantized =
            op->u.logistic.input.scale*((val+kLogisticScale-1)/kLogisticScale-(float)op->u.logistic.input.zero_point);
         float transformed = (1.0f / (1.0f + exp(-dequantized)));
         float rescaled = round(transformed*inverse_scale);
         int32_t quantized =
            static_cast<int32_t>(rescaled+op->u.logistic.output.zero_point);
         if(quantized < 0)
            quantized=0;
         else if(quantized > 255)
            quantized=255;
         lookup[val] = quantized;
      }
   }
   int index=(int)_in;
   if(index < 0)
      index=0;
   else if(index > (256*kLogisticScale-1))
      index=256*kLogisticScale-1;
   return (int16_t)lookup[index];
}

int16_t NeuralNetLayerLogistic::SpuEvalScale(int16_t _in,void *pparm,uint32_t index,uint32_t parm2) {
   float out;
   out=(float)_in*kLogisticScale;
   return FLOAT2INT(out);
}


