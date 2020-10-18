#include <math.h>
#include "../../base/types.h"
#include "../../base/tensor.h"
#include "../../base/graph.h"
#include "kernels/harris.h"
#include "harris.h"

// Graph node to do harris-corder detection
// Refer to https://en.wikipedia.org/wiki/Harris_Corner_Detector

GraphNodeHarris::GraphNodeHarris() {
   m_x_gradient=0;
   m_y_gradient=0;
   m_score=0;
}

GraphNodeHarris::GraphNodeHarris(TENSOR *input,TENSOR *output) : GraphNodeHarris() {
   Create(input,output);
}

GraphNodeHarris::~GraphNodeHarris() {
   Cleanup();
}

ZtaStatus GraphNodeHarris::Create(TENSOR *input,TENSOR *output) {
   Cleanup();
   m_input=input;
   m_output=output;
   return ZtaStatusOk;
}


ZtaStatus GraphNodeHarris::Verify() {
   if((*(m_input->GetDimension())).size() != 3)
      return ZtaStatusFail;
   m_w=(*(m_input->GetDimension()))[2];
   m_h=(*(m_input->GetDimension()))[1];
   m_nChannel=(*(m_input->GetDimension()))[0];
   if(m_nChannel != 1)
      return ZtaStatusFail;
   if(m_input->GetSemantic() != TensorSemanticMonochromeSingleChannel)
      return ZtaStatusFail;
   
   m_x_gradient=ztahostAllocSharedMem(m_w*m_h*sizeof(int16_t));
   m_y_gradient=ztahostAllocSharedMem(m_w*m_h*sizeof(int16_t));
   m_score=ztahostAllocSharedMem(m_w*m_h*sizeof(int16_t));
   std::vector<int> dim={m_h,m_w};
   m_output->Create(TensorDataTypeInt16,TensorFormatSplit,TensorSemanticUnknown,dim);
   m_func=ztahostGetExportFunction("do_harris");
   return ZtaStatusOk;
}

ZtaStatus GraphNodeHarris::Schedule(int queue) {
   ztahostMsgqWriteInt(queue,m_func);
   ztahostMsgqWriteInt(queue,1);
   ztahostMsgqWriteInt(queue,1);
   ztahostMsgqWritePointer(queue,m_input->GetBuf());
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_x_gradient)); 
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_y_gradient)); 
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_score));
   ztahostMsgqWritePointer(queue,m_output->GetBuf());
   ztahostMsgqWriteInt(queue,m_w); // w
   ztahostMsgqWriteInt(queue,m_h); // h
   ztahostMsgqWriteInt(queue,m_w); // src_w
   ztahostMsgqWriteInt(queue,m_h); // src_h
   ztahostMsgqWriteInt(queue,0); // x_off
   ztahostMsgqWriteInt(queue,0); // y_off
   ztahostMsgqWriteInt(queue,m_w); // dst_w
   ztahostMsgqWriteInt(queue,m_h); // dst_h
   ztahostMsgqWriteInt(queue,GetNextRequestId(queue));
   return ZtaStatusOk;
}


void GraphNodeHarris::Cleanup() {
   if(m_x_gradient) {
      ztahostFreeSharedMem(m_x_gradient);
      m_x_gradient=0;
   }
   if(m_y_gradient) {
      ztahostFreeSharedMem(m_y_gradient);
      m_y_gradient=0;
   }
   if(m_score) {
      ztahostFreeSharedMem(m_score);
      m_score=0;
   }
}
