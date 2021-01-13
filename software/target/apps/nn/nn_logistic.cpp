#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn_logistic.h"

// Do logistic layer

#define kLogisticScale 8

NeuralNetLayerLogistic::NeuralNetLayerLogistic(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
   m_func=ztahostGetExportFunction("do_logistic");
}

NeuralNetLayerLogistic::~NeuralNetLayerLogistic() {
}

ZtaStatus NeuralNetLayerLogistic::Prepare() {
   ZTA_SHARED_MEM shm,shm1,shm2;
   int16_t *shmp;
   shm1=m_nn->BuildSpu(SpuEval,this,0);
   shm2=m_nn->BuildSpu(SpuEvalScale,this,0);
   shm=m_nn->BufferAllocate(SPU_SIZE*2*sizeof(int16_t)*2);
   shmp=(int16_t *)ZTA_SHARED_MEM_P(shm);
   memcpy(shmp,ZTA_SHARED_MEM_P(shm1),SPU_SIZE*2*sizeof(int16_t));
   shmp+=2*SPU_SIZE;
   memcpy(shmp,ZTA_SHARED_MEM_P(shm2),SPU_SIZE*2*sizeof(int16_t));
   shmp+=2*SPU_SIZE;
   m_shmSpu=shm;
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerLogistic::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   bool isInterleave=(m_nn->BufferGetInterleave(op->output[0])!=0);
   if(ztahostMsgqWriteAvail(queue) < 8)
      return ZtaStatusPending;
   ztahostMsgqWriteInt(queue,m_func); // Command id
   ztahostMsgqWriteInt(queue,m_nn->GetNextRequestId(queue));
   ztahostMsgqWriteInt(queue,Util::GetTensorSize(*op->input_shape[0]));
   ztahostMsgqWritePointer(queue,isInterleave?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0]));
   ztahostMsgqWritePointer(queue,isInterleave?m_nn->BufferGetInterleave(op->output[0]):m_nn->BufferGetFlat(op->output[0]));
   ztahostMsgqWritePointer(queue,m_shmSpu);
   return ZtaStatusOk;
}

float NeuralNetLayerLogistic::SpuEval(float _in,void *pparm,uint32_t parm) {
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
   return (float)lookup[index];
}

float NeuralNetLayerLogistic::SpuEvalScale(float _in,void *pparm,uint32_t index) {
   return (float)_in*kLogisticScale;
}


