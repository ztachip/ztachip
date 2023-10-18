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

#ifndef _TARGET_APPS_GAUSSIAN_GAUSSIAN_H_
#define _TARGET_APPS_GAUSSIAN_GAUSSIAN_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do gaussian convolution on an image
// The effect is image blurring

class GraphNodeGaussian : public GraphNode {
public:
   GraphNodeGaussian();
   GraphNodeGaussian(TENSOR *input,TENSOR *output);
   virtual ~GraphNodeGaussian();
   ZtaStatus Create(TENSOR *input,TENSOR *output);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Execute(int queue,int stepMode);
   void SetSigma(float _sigma);
   float GetSigma();
private:
   void Cleanup();
   float gaussian(int x,int y,float sigma);
   void BuildKernel();
private:
   TENSOR *m_input;
   TENSOR *m_output;
   int m_w;
   int m_h;
   int m_nChannel;
   int m_ksz;
   uint32_t m_func;
   float m_sigma;
   ZTA_SHARED_MEM m_kernel;
};

#endif
