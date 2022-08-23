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

#ifndef _TARGET_APPS_HARRIS_HARRIS_H_
#define _TARGET_APPS_HARRIS_HARRIS_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do harris-corder detection
// Refer to https://en.wikipedia.org/wiki/Harris_Corner_Detector

class GraphNodeHarris : public GraphNode {
public:
   GraphNodeHarris();
   GraphNodeHarris(TENSOR *input,TENSOR *output);
   virtual ~GraphNodeHarris();
   ZtaStatus Create(TENSOR *input,TENSOR *output);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Prepare(int queue,bool stepMode);
private:
   void Cleanup();
private:
   TENSOR *m_input;
   TENSOR *m_output;
   int m_w;
   int m_h;
   int m_nChannel;
   uint32_t m_func;
   ZTA_SHARED_MEM m_x_gradient;
   ZTA_SHARED_MEM m_y_gradient;
   ZTA_SHARED_MEM m_score;   
};

#endif
