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
#include <vector>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn_poolavg.h"

extern "C" void kernel_Pooling_exe(
   unsigned int _req_id,
   unsigned int _bot,
   unsigned int _top,
   int _ksz,
   int _stride,
   int _topcnt,
   int _topdim,
   int _botcnt,
   int _botdim,
   unsigned int _stream,
   int _output_shift
);

// Do pool average layer

NeuralNetLayerPoolAvg::NeuralNetLayerPoolAvg(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
}

NeuralNetLayerPoolAvg::~NeuralNetLayerPoolAvg() {
}

ZtaStatus NeuralNetLayerPoolAvg::Prepare() {
   m_shmSpu=ztahostBuildSpuBundle(1,SpuAvgPool,this,0,0);
   m_nn->BufferAllocateExternal(m_shmSpu);
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerPoolAvg::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   bool interleave=(m_nn->BufferGetInterleave(op->output[0])!=0);
   kernel_Pooling_exe(
      (unsigned int)GetNextRequestId(queue),
      (unsigned int)(interleave?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0])),
	  (unsigned int)(interleave?m_nn->BufferGetInterleave(op->output[0]):m_nn->BufferGetFlat(op->output[0])),
      op->u.pool_avg.filter_w,
      op->u.pool_avg.stride_w,
      (*op->output_shape[0])[3],
      (*op->output_shape[0])[2],
      (*op->input_shape[0])[3],
      (*op->input_shape[0])[2],
	  (unsigned int)m_shmSpu,
      m_outputShift);
   return ZtaStatusOk;
}

float NeuralNetLayerPoolAvg::SpuAvgPool(float _in,void *pparm,uint32_t parm,uint32_t parm2)
{
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   NeuralNetOperatorDef *op=layer?&((NeuralNetLayerPoolAvg *)layer)->m_def:0;
   static float D=0.0;
   static float N=0.0;
   static int activation_max=0;
   static int activation_min=0;
   if(op) {
      int cnt,bit=0;
      cnt=op->u.pool_avg.filter_w*op->u.pool_avg.filter_h;
      while(cnt > 0) {
         cnt=cnt>>1;
         bit++;
      }
      if(bit > 2) {
         bit -= 2;
      } else if(bit > 1) {
         bit -= 1;
      }
      D=static_cast<float>(op->u.pool_avg.filter_w*op->u.pool_avg.filter_h);
      N=static_cast<float>((1<<bit));
      activation_max=op->u.pool_avg.activation_max;
      activation_min=op->u.pool_avg.activation_min;
      ((NeuralNetLayerPoolAvg *)layer)->m_outputShift=bit;
   }
   _in=static_cast<float>(((_in*(float)N)/(float)D)+0.5);
   if(_in > activation_max) {
      return static_cast<float>(activation_max);
   } else if(_in < activation_min) {
      return static_cast<float>(activation_min);
   } else {
      return _in;
   }
}  

