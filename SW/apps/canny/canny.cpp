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

#include <math.h>
#include "../../base/types.h"
#include "../../base/tensor.h"
#include "../../base/graph.h"
extern "C"
{
#include "kernels/canny.h"
}
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

   sz=(m_w+2*TILE_MAX_KZ)*(m_h+2*TILE_MAX_KZ);
   m_magnitude=ztahostAllocSharedMem(sz*sizeof(int16_t));
   m_phase=ztahostAllocSharedMem(sz*sizeof(uint8_t));
   m_maxima=ztahostAllocSharedMem(sz*sizeof(int16_t));
   m_thresholdLo=81;
   m_thresholdHi=163;
//   m_thresholdHi=100;
   std::vector<int> dim={1,m_h,m_w};
   m_output->Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticMonochromeSingleChannel,dim);
   return ZtaStatusOk;
}

ZtaStatus GraphNodeCanny::Prepare(int queue,bool stepMode) {
   kernel_canny_exe(
      (unsigned int)GetNextRequestId(queue),
      (unsigned int)m_input->GetBuf(),
      (unsigned int)ZTA_SHARED_MEM_P(m_magnitude),
	  (unsigned int)ZTA_SHARED_MEM_P(m_phase),
	  (unsigned int)ZTA_SHARED_MEM_P(m_maxima),
	  (unsigned int)m_output->GetBuf(),
      m_thresholdLo,
      m_thresholdHi,
      m_w,
      m_h,
      m_w,
      m_h,
      0,
      0,
      m_w,
      m_h);
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
 
