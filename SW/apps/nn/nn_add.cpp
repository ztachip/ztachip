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
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn_add.h"

extern "C" void kernel_add_exe(
   unsigned int _req_id,
   int _size,
   unsigned int _input_0,
   unsigned int _input_1,
   unsigned int _output,
   unsigned int _stream
);

// Do Add layer

NeuralNetLayerAdd::NeuralNetLayerAdd(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
}

NeuralNetLayerAdd::~NeuralNetLayerAdd() {
}

ZtaStatus NeuralNetLayerAdd::Prepare() {
   int range;
   int bits;
   int shift;
   int32_t min[3],max[3];
   NeuralNetOperatorDef* op=&m_def;
   op->u.add.output.shift=-op->u.add.output.shift;
   op->u.add.input[0].shift=-op->u.add.input[0].shift;
   op->u.add.input[1].shift=-op->u.add.input[1].shift;
   min[0]=(int32_t)SpuInputEval((float)0,this,0,op->u.add.output.shift);
   max[0]=(int32_t)SpuInputEval((float)255,this,0,op->u.add.output.shift);
   range=std::abs(min[0]);
   if(range<std::abs(max[0]))
      range=std::abs(max[0]);
   bits=0;
   while(range != 0) {
      range=range>>1;
      bits++;
   }
   if(bits < 10)
      shift=10-bits;
   else
      shift=0;
   min[1]=(int32_t)SpuInputEval((float)0,this,1,op->u.add.output.shift);
   max[1]=(int32_t)SpuInputEval((float)255,this,1,op->u.add.output.shift);
   range=std::abs(min[1]);
   if(range<std::abs(max[1]))
      range=std::abs(max[1]);
   bits=0;
   while(range != 0) {
      range=range>>1;
      bits++;
   }
   if(bits < 10)
      shift=std::min(10-bits,shift);
   // Let intermediate values be a bit bigger to gain more resolution

   m_shmSpu=ztahostBuildSpuBundle(3,
                                  SpuOutputEval,this,0,shift,
                                  SpuInputEval,this,0,op->u.add.output.shift-shift,
                                  SpuInputEval,this,1,op->u.add.output.shift-shift);

   m_nn->BufferAllocateExternal(m_shmSpu);

   op->u.add.output.shift=shift;
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerAdd::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   bool interleave=(m_nn->BufferGetInterleave(op->input[0])!=0);
   kernel_add_exe(
      (unsigned int)GetNextRequestId(queue),
      op->u.add.size,
	  (unsigned int)((interleave)?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0])),
	  (unsigned int)((interleave)?m_nn->BufferGetInterleave(op->input[1]):m_nn->BufferGetFlat(op->input[1])),
	  (unsigned int)((interleave)?m_nn->BufferGetInterleave(op->output[0]):m_nn->BufferGetFlat(op->output[0])),
	  (unsigned int)m_shmSpu);
   return ZtaStatusOk;
}

float NeuralNetLayerAdd::SpuInputEval(float _in,void *pparm,uint32_t parm,uint32_t parm2)
{  
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   NeuralNetOperatorDef *op_=(layer)?&((NeuralNetLayerAdd *)layer)->m_def:0;
   static NeuralNetOperatorDef *op=0;
   uint8_t input;
   int output_shift=parm2;
   if(op_)
      op=op_;
   input = (uint8_t)_in;
   const int32_t input_val=op->u.add.input[parm].offset+input;
   const int32_t shifted_input_val=input_val*(1 << op->u.add.input_shift);
   int32_t scaled_input_val=((int64_t)shifted_input_val*(int64_t)op->u.add.input[parm].multiplier+(1 << 30)) >> (31);
   if (op->u.add.input[parm].shift >= 1) {
      scaled_input_val = (scaled_input_val+(1 << (op->u.add.input[parm].shift - 1))) >> op->u.add.input[parm].shift;
   }
   int32_t raw_sum = scaled_input_val;
   int32_t raw_output=(((int64_t)raw_sum*(int64_t)op->u.add.output.multiplier+(1 << 30)) >> (31));
   if (output_shift >= 1) {
      raw_output = (raw_output+(1 << (output_shift - 1))) >> output_shift;
   }
   return (float)raw_output;
}

float NeuralNetLayerAdd::SpuOutputEval(float _in,void *pparm,uint32_t parm,uint32_t parm2)
{
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   NeuralNetOperatorDef *op_=(layer)?&((NeuralNetLayerAdd *)layer)->m_def:0;
   static NeuralNetOperatorDef *op=0;
   int32_t raw_output,shift;
   if(op_)
      op=op_;
   shift=parm2;
   raw_output=(int32_t)_in;
   if(shift>=1)
      raw_output += (1<<(shift-1));
   raw_output=raw_output >> shift;
   raw_output+=op->u.add.output.offset;
   int32_t clamped_output;
   if (raw_output < op->u.add.activation_min) {
      clamped_output=op->u.add.activation_min;
   } else if (raw_output > op->u.add.activation_max) {
      clamped_output=op->u.add.activation_max;
   } else {
      clamped_output=raw_output;
   }
   return static_cast<float>(clamped_output);
}
