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

#ifndef _TARGET_APPS_RESIZE_RESIZE_H_
#define _TARGET_APPS_RESIZE_RESIZE_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Graph node to do image resize
// Resize using boxing method

class GraphNodeResize : public GraphNode {
public:
   GraphNodeResize();
   GraphNodeResize(TENSOR *input,TENSOR *output,int w,int h);
   ZtaStatus Create(TENSOR *input,TENSOR *output,int w,int h);
   virtual ~GraphNodeResize();
   virtual ZtaStatus Verify();
   virtual ZtaStatus Execute(int queue,int stepMode);
private:
   void Cleanup();
   static int16_t spuCallback(int16_t input,void *pparm,uint32_t parm);
private:
   uint32_t m_func;
   int m_src_w;
   int m_src_h;
   int m_dst_w;
   int m_dst_h;
   int m_nChannel;
   TENSOR *m_input;
   TENSOR *m_output;
   ZTA_SHARED_MEM m_temp;
   ZTA_SHARED_MEM m_filter[2];
   ZTA_SHARED_MEM m_filteri[2];
   int m_filterLen[2];
   int m_scale_denomitor[2];
   ZTA_SHARED_MEM m_spu;
};

#endif
