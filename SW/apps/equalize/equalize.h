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

#ifndef _TARGET_APPS_EQUALIZE_EQUALIZE_H_
#define _TARGET_APPS_EQUALIZE_EQUALIZE_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do image equalization (improve image contrast)
// Calculate pixel value histogram and then apply image
// equalization.

#define HISTOGRAM(h,j)  ((h)[(j)]*1000 + (h)[(j)+32])
#define HISTOGRAM_BIN_SIZE  8
#define HISTOGRAM_BIN_COUNT  (256/HISTOGRAM_BIN_SIZE)

class GraphNodeEqualize : public GraphNode {
public:
   GraphNodeEqualize();
   GraphNodeEqualize(TENSOR *input,TENSOR *output);
   virtual ~GraphNodeEqualize();
   ZtaStatus Create(TENSOR *input,TENSOR *output);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Execute(int queue,bool stepMode);
   ZTA_SHARED_MEM GenEqualizer();
   float GetContrast() {return m_contrast;}
   void SetContrast(float _contrast);
public:
   ZTA_SHARED_MEM m_spu;
private:
   void Cleanup();
   static int16_t SpuCallback(int16_t input,void *pparm,uint32_t parm,uint32_t parm2);
private:
   TENSOR *m_input;
   TENSOR *m_output;
   TENSOR m_result;
   int m_threshold;
   int m_w;
   int m_h;
   int m_nChannel;
   uint32_t m_func;
   float m_contrast;
   int m_histogram[HISTOGRAM_BIN_COUNT];
   int m_histogram_sum[HISTOGRAM_BIN_COUNT];
   bool m_histogramAvail;
};

#endif
