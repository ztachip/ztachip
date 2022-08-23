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
#include "kernels/harris.h"
#include "harris.h"

extern "C" void kernel_harris_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _x_gradient,
   unsigned int _y_gradient,
   unsigned int _score,
   unsigned int _output,
   int _w,
   int _h,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_w,
   int _dst_h);

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
   return ZtaStatusOk;
}

ZtaStatus GraphNodeHarris::Prepare(int queue,bool stepMode) {
   kernel_harris_exe(
      (unsigned int)GetNextRequestId(queue),
	  (unsigned int)m_input->GetBuf(),
	  (unsigned int)ZTA_SHARED_MEM_P(m_x_gradient),
	  (unsigned int)ZTA_SHARED_MEM_P(m_y_gradient),
	  (unsigned int)ZTA_SHARED_MEM_P(m_score),
	  (unsigned int)m_output->GetBuf(),
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
