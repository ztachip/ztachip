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

#ifndef _TARGET_APPS_CANNY_CANNY_H_
#define _TARGET_APPS_CANNY_CANNY_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do edge detection using Canny algorithm
// Refer to https://en.wikipedia.org/wiki/Canny_edge_detector

class GraphNodeCanny : public GraphNode {
public:
   GraphNodeCanny();
   GraphNodeCanny(TENSOR *input,TENSOR *output);
   virtual ~GraphNodeCanny();
   ZtaStatus Create(TENSOR *input,TENSOR *output);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Execute(int queue,int stepMode);
   void SetThreshold(int _loThreshold,int _hiThreshold);
   void GetThreshold(int *_loThreshold,int *_hiThreshold);
private:
   void Cleanup();
private:
   TENSOR *m_input;
   TENSOR *m_output;
   int m_w;
   int m_h;
   int m_nChannel;
   uint32_t m_func;
   int m_thresholdLo;
   int m_thresholdHi;
   ZTA_SHARED_MEM m_magnitude;
   ZTA_SHARED_MEM m_phase;
   ZTA_SHARED_MEM m_maxima;
};

#endif
