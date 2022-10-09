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

#ifndef _TARGET_APPS_COLOR_COLOR_H_
#define _TARGET_APPS_COLOR_COLOR_H_

#include "../../base/tensor.h"
#include "../../base/graph.h"

// Do color space conversion and reshaping
// Change between RGB<->BGR<->MONO<->YUYV color space
// Reshape between interleave format and split format for color plane


class GraphNodeColorAndReshape : public GraphNode {
public:
   GraphNodeColorAndReshape();
   GraphNodeColorAndReshape(TENSOR *input,TENSOR *output,
                            TensorObjType _dstColorSpace,
                            TensorFormat _dstFormat,
                            int clip_x=0,
                            int clip_y=0,
                            int clip_w=0,
                            int clip_h=0,
                            int dst_x=0,
                            int dst_y=0,
                            int dst_w=0,
                            int dst_h=0);
   virtual ~GraphNodeColorAndReshape();
   ZtaStatus Create(TENSOR *input,TENSOR *output,
                    TensorObjType dstColorSpace,
                    TensorFormat _dstFormat,
                    int clip_x=0,
                    int clip_y=0,
                    int clip_w=0,
                    int clip_h=0,
                    int dst_x=0,
                    int dst_y=0,
                    int dst_w=0,
                    int dst_h=0);
   virtual ZtaStatus Verify();
   virtual ZtaStatus Execute(int queue,bool stepMode);
private:
   static int16_t SpuCallback(int16_t input,void *pparm,uint32_t parm,uint32_t parm2);
   void Cleanup();
private:
   TENSOR *m_input;
   TENSOR *m_output;
   TensorObjType m_srcColorSpace;
   TensorObjType m_dstColorSpace;
   TensorFormat m_dstFormat;
   int m_srcorder;   
   int m_srcfmt;
   int m_dstorder;
   int m_dstfmt;
   int m_clip_x;
   int m_clip_y;
   int m_clip_w;
   int m_clip_h;
   int m_src_w;
   int m_src_h;
   int m_nChannel;
   int m_dst_x;
   int m_dst_y;
   int m_dst_w;
   int m_dst_h;
   uint32_t m_func;
   ZTA_SHARED_MEM m_spu;
};

#endif
