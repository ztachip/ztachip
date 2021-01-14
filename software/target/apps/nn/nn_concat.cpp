#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn_concat.h"

// Do concatenation layer

NeuralNetLayerConcat::NeuralNetLayerConcat(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
   m_func=ztahostGetExportFunction("do_concatenate");
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
      m_shmSpu.push_back(m_nn->BuildSpu(SpuEval,this,i));
      m_copySize.push_back((*op->input_shape[i])[op->u.concat.axis]*base_inner_size);
   }
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerConcat::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   if(ztahostMsgqWriteAvail(queue) < (4+(int)m_outerSize*(int)op->input.size()*4+1))
      return ZtaStatusPending;
   ztahostMsgqWriteInt(queue,m_func); // Command id
   ztahostMsgqWriteInt(queue,GetNextRequestId(queue));
   ztahostMsgqWriteInt(queue,op->input.size()*m_outerSize);
   int destIndex=0;
   for (int k=0;k < (int)m_outerSize;k++) {
      for (int i = 0; i < (int)op->input.size(); ++i) {
         const int copy_size = m_copySize[i];
         ztahostMsgqWritePointer(queue,m_nn->BufferGetInterleave(op->input[i]),k*copy_size);
         ztahostMsgqWriteInt(queue,copy_size);
         ztahostMsgqWritePointer(queue,m_shmSpu[i]);
         ztahostMsgqWritePointer(queue,m_nn->BufferGetInterleave(op->output[0]),destIndex);
         destIndex += copy_size;
      }
   }
   return ZtaStatusOk;
}

// SPU evaluation function for output activation

float NeuralNetLayerConcat::SpuEval(float _in,void *pparm,uint32_t index) {
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
   const int32_t value = static_cast<int32_t>(round(_in*scale+bias))+zero; 
   return static_cast<float>(std::max(std::min(255, value),0)); 
};


