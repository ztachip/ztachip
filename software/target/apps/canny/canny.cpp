#include <math.h>
#include "../../base/types.h"
#include "../../base/tensor.h"
#include "../../base/graph.h"
#include "kernels/canny.h"
#include "canny.h"

// Graph node to do edge detection using Canny algorithm
// Refer to https://en.wikipedia.org/wiki/Canny_edge_detector

GraphNodeCanny::GraphNodeCanny() {
   m_magnitude=0;
   m_phase=0;
   m_maxima=0;
}

GraphNodeCanny::GraphNodeCanny(TENSOR *input,TENSOR *output) : GraphNodeCanny() {
   m_magnitude=0;
   m_phase=0;
   m_maxima=0;
   Create(input,output);
}

GraphNodeCanny::~GraphNodeCanny() {
   Cleanup();
}

ZtaStatus GraphNodeCanny::Create(TENSOR *input,TENSOR *output) {
   Cleanup();
   m_input=input;
   m_output=output;
   return ZtaStatusOk;
}


ZtaStatus GraphNodeCanny::Verify() {
   int sz;
      
   if((*(m_input->GetDimension())).size() != 3)
      return ZtaStatusFail;
   m_w=(*(m_input->GetDimension()))[2];
   m_h=(*(m_input->GetDimension()))[1];
   m_nChannel=(*(m_input->GetDimension()))[0];
   if(m_nChannel != 1)
      return ZtaStatusFail;

   m_func=ztahostGetExportFunction("do_canny");

   sz=(m_w+2*TILE_MAX_KZ)*(m_h+2*TILE_MAX_KZ);
   m_magnitude=ztahostAllocSharedMem(sz*sizeof(int16_t));
   m_phase=ztahostAllocSharedMem(sz*sizeof(uint8_t));
   m_maxima=ztahostAllocSharedMem(sz*sizeof(int16_t));
   m_thresholdLo=81;
   m_thresholdHi=163;

   std::vector<int> dim={1,m_h,m_w};
   m_output->Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticMonochromeSingleChannel,dim);
   return ZtaStatusOk;
}

ZtaStatus GraphNodeCanny::Schedule(int queue) {
   ztahostMsgqWriteInt(queue,m_func);
   ztahostMsgqWriteInt(queue,1);
   ztahostMsgqWriteInt(queue,1);
   ztahostMsgqWritePointer(queue,m_input->GetBuf());
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_magnitude));
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_phase)); 
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_maxima)); 
   ztahostMsgqWritePointer(queue,m_output->GetBuf());
   ztahostMsgqWriteInt(queue,m_thresholdLo);
   ztahostMsgqWriteInt(queue,m_thresholdHi);
   ztahostMsgqWriteInt(queue,m_w);
   ztahostMsgqWriteInt(queue,m_h);
   ztahostMsgqWriteInt(queue,m_w);
   ztahostMsgqWriteInt(queue,m_h);
   ztahostMsgqWriteInt(queue,0);
   ztahostMsgqWriteInt(queue,0);
   ztahostMsgqWriteInt(queue,m_w);
   ztahostMsgqWriteInt(queue,m_h);
   ztahostMsgqWriteInt(queue,GetNextRequestId(queue));
   return ZtaStatusOk;
}

void GraphNodeCanny::Cleanup() {
   if(m_magnitude) {
      ztahostFreeSharedMem(m_magnitude);
      m_magnitude=0;
   }
   if(m_phase) {
      ztahostFreeSharedMem(m_phase);
      m_phase=0;
   }
   if(m_maxima) {
      ztahostFreeSharedMem(m_maxima);
      m_maxima=0;
   }
}

// Set contrast threshold

void GraphNodeCanny::SetThreshold(int _loThreshold,int _hiThreshold) {
   m_thresholdLo=_loThreshold;
   m_thresholdHi=_hiThreshold;
}

// Get current contrast threshold

void GraphNodeCanny::GetThreshold(int *_loThreshold,int *_hiThreshold) {
   *_loThreshold=m_thresholdLo;
   *_hiThreshold=m_thresholdHi;
}
 
