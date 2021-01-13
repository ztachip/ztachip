#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn_poolavg.h"

// Do pool average layer

NeuralNetLayerPoolAvg::NeuralNetLayerPoolAvg(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
   m_func=ztahostGetExportFunction("do_Pooling");
}

NeuralNetLayerPoolAvg::~NeuralNetLayerPoolAvg() {
}

ZtaStatus NeuralNetLayerPoolAvg::Prepare() {
   m_shmSpu=m_nn->BuildSpu(SpuAvgPool,this,0);
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerPoolAvg::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   bool interleave=(m_nn->BufferGetInterleave(op->output[0])!=0);
   if(ztahostMsgqWriteAvail(queue) < 14)
      return ZtaStatusPending;
   ztahostMsgqWriteInt(queue,m_func); // Command id
   ztahostMsgqWriteInt(queue,m_nn->GetNextRequestId(queue));
   ztahostMsgqWritePointer(queue,interleave?m_nn->BufferGetInterleave(op->input[0]):m_nn->BufferGetFlat(op->input[0])); // bot
   ztahostMsgqWritePointer(queue,interleave?m_nn->BufferGetInterleave(op->output[0]):m_nn->BufferGetFlat(op->output[0])); // top
   ztahostMsgqWriteInt(queue,op->u.pool_avg.filter_w); // kernel size
   ztahostMsgqWriteInt(queue,op->u.pool_avg.stride_w); // stride
   ztahostMsgqWriteInt(queue,(*op->output_shape[0])[3]); // topcnt
   ztahostMsgqWriteInt(queue,(*op->output_shape[0])[2]); // topdim
   ztahostMsgqWriteInt(queue,(*op->input_shape[0])[3]); // botcnt
   ztahostMsgqWriteInt(queue,(*op->input_shape[0])[2]); // botdim  
   ztahostMsgqWritePointer(queue,m_shmSpu); // stream...
   ztahostMsgqWriteInt(queue,m_outputShift); // output right shift
   return ZtaStatusOk;
}

float NeuralNetLayerPoolAvg::SpuAvgPool(float _in,void *pparm,uint32_t parm)
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

