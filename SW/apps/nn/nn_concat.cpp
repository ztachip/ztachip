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
extern "C"
{
#include "kernels/fcn.h"
}
#include "nn_concat.h"

#define MAX_CONCATENATE  8

// Do concatenation layer

NeuralNetLayerConcat::NeuralNetLayerConcat(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
}

NeuralNetLayerConcat::~NeuralNetLayerConcat() {
}

ZtaStatus NeuralNetLayerConcat::Prepare() {
   NeuralNetOperatorDef* op=&m_def;
   const uint32_t concat_dimensions = (*op->output_shape[0]).size();
   uint32_t concat_size = 0;
   for (uint32_t i = 0; i < op->u.concat.num_input; i++) {
      concat_size += (*op->input_shape[i])[op->u.concat.axis];
   }
   uint32_t outer_size = 1;
   for (uint32_t i = 0; i < op->u.concat.axis; ++i) {
      outer_size *= (*op->output_shape[0])[i];
   }
   // For all input arrays,
   // FlatSize() = outer_size * Dims(axis) * base_inner_size;
   uint32_t base_inner_size = 1;
   for (uint32_t i = op->u.concat.axis + 1; i < concat_dimensions; ++i) {
      base_inner_size *= (*op->output_shape[0])[i];
   }
   // Generate spu lookup for input
   m_outerSize=outer_size;
   for(uint32_t i=0;i < op->u.concat.num_input;i++) {
      ZTA_SHARED_MEM spu;
      spu=ztahostBuildSpuBundle(1,SpuEval,this,i,0);
      m_nn->BufferAllocateExternal(spu);
      m_shmSpu.push_back(spu);
      m_copySize.push_back((*op->input_shape[i])[op->u.concat.axis]*base_inner_size);
   }
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerConcat::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   int destIndex=0;
   int idx=0;
   int cnt;
   unsigned int src[MAX_CONCATENATE];
   int copySize[MAX_CONCATENATE];
   unsigned int spu[MAX_CONCATENATE];
   unsigned int dest[MAX_CONCATENATE];

   cnt=op->input.size()*m_outerSize;
   assert(cnt <= MAX_CONCATENATE);
   for (int k=0;k < (int)m_outerSize;k++) {
      for (int i = 0; i < (int)op->input.size(); ++i) {
         const int copy_size = m_copySize[i];
         src[idx]=(unsigned int)m_nn->BufferGetInterleave(op->input[i])+k*copy_size;
         copySize[idx]=copy_size;
         spu[idx]=(unsigned int)m_shmSpu[i];
         dest[idx]=(unsigned int)m_nn->BufferGetInterleave(op->output[0])+destIndex;
         destIndex += copy_size;
         idx++;
      }
   }
   kernel_concatenate_exe(
      GetNextRequestId(queue),
      cnt,
	  src,
	  copySize,
	  spu,
	  dest);
   return ZtaStatusOk;
}

// SPU evaluation function for output activation

int16_t NeuralNetLayerConcat::SpuEval(int16_t _in,void *pparm,uint32_t index,uint32_t parm2) {
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   static float scale;
   static float bias;
   static int32_t zero;
   NeuralNetOperatorDef *op=layer?&(((NeuralNetLayerConcat *)layer)->m_def):0;
   if(op) {
      float inverse_output_scale=1.f/op->u.concat.output.scale;
      scale = op->u.concat.input[index].scale*inverse_output_scale;
      bias = -op->u.concat.input[index].zero_point*scale;
      zero=op->u.concat.output.zero_point;
   }
   int32_t value = static_cast<int32_t>(round((float)_in*scale+bias))+zero;
   if(value > 255)
      value=255;
   else if(value < 0)
      value=0;
   return static_cast<int16_t>(value);
};

