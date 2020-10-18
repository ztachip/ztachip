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

// Do Add layer

NeuralNetLayerAdd::NeuralNetLayerAdd(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
   m_func=ztahostGetExportFunction("do_add");
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
   min[0]=(int32_t)SpuInputEval((float)0,this,0);
   max[0]=(int32_t)SpuInputEval((float)255,this,0);
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
   min[1]=(int32_t)SpuInputEval((float)0,this,1);
   max[1]=(int32_t)SpuInputEval((float)255,this,1);
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
   op->u.add.output.shift-=shift;
   ZTA_SHARED_MEM shmInputStream[2];
   ZTA_SHARED_MEM shmActivationStream;
   shmInputStream[0]=m_nn->BuildSpu(SpuInputEval,this,0);
   shmInputStream[1]=m_nn->BuildSpu(SpuInputEval,this,1);
   op->u.add.output.shift=shift;   
   shmActivationStream=m_nn->BuildSpu(SpuOutputEval,this,0);
   m_shmSpu=m_nn->BufferAllocate(SPU_SIZE*2*sizeof(int16_t)*3);
   int16_t *shmp=(int16_t *)ZTA_SHARED_MEM_P(m_shmSpu);
   memcpy(shmp,ZTA_SHARED_MEM_P(shmActivationStream),SPU_SIZE*2*sizeof(int16_t));
   shmp+=2*SPU_SIZE;
   memcpy(shmp,ZTA_SHARED_MEM_P(shmInputStream[0]),SPU_SIZE*2*sizeof(int16_t));
   shmp+=2*SPU_SIZE;
   memcpy(shmp,ZTA_SHARED_MEM_P(shmInputStream[1]),SPU_SIZE*2*sizeof(int16_t));
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerAdd::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   bool interleave=(m_nn->BufferGetInterleave(op->input[0])!=0);
   if(ztahostMsgqWriteAvail(queue) < 9)
      return ZtaStatusPending;
   ztahostMsgqWriteInt(queue,m_func);
   ztahostMsgqWriteInt(queue,1);
   ztahostMsgqWriteInt(queue,0);
   ztahostMsgqWriteInt(queue,op->u.add.size);
   ztahostMsgqWritePointer(queue,(interleave)?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0])); // bot
   ztahostMsgqWritePointer(queue,(interleave)?m_nn->BufferGetInterleave(op->input[1]):m_nn->BufferGetFlat(op->input[1])); // bot
   ztahostMsgqWritePointer(queue,(interleave)?m_nn->BufferGetInterleave(op->output[0]):m_nn->BufferGetFlat(op->output[0])); // bot
   ztahostMsgqWritePointer(queue,m_shmSpu);
   ztahostMsgqWriteInt(queue,m_nn->GetNextRequestId(queue));
   return ZtaStatusOk;
}

float NeuralNetLayerAdd::SpuInputEval(float _in,void *pparm,uint32_t parm)
{  
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   NeuralNetOperatorDef *op_=(layer)?&((NeuralNetLayerAdd *)layer)->m_def:0;
   static NeuralNetOperatorDef *op=0;
   uint8_t input;
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
   if (op->u.add.output.shift >= 1) {
      raw_output = (raw_output+(1 << (op->u.add.output.shift - 1))) >> op->u.add.output.shift;
   }
   return (float)raw_output;
}

float NeuralNetLayerAdd::SpuOutputEval(float _in,void *pparm,uint32_t parm)
{
   NeuralNetLayer *layer=static_cast<NeuralNetLayer *>(pparm);
   NeuralNetOperatorDef *op_=(layer)?&((NeuralNetLayerAdd *)layer)->m_def:0;
   static NeuralNetOperatorDef *op=0;
   int32_t raw_output,shift;
   if(op_)
      op=op_;
   shift=op->u.add.output.shift;
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
