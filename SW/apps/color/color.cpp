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
#include "kernels/color.h"
#include "color.h"

extern "C" void kernel_copy_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   int _w,
   int _h,
   int _src_channel_fmt,
   int _src_channel_color,
   int _dst_channel_fmt,
   int _dst_channel_color,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_x,
   int _dst_y,
   int _dst_w,
   int _dst_h,
   unsigned int _equalize);

extern "C" void kernel_yuyv2rgb_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _spu,
   int _w,
   int _h,
   int _dst_channel_fmt,
   int _dst_channel_color,
   int _src_w,
   int _src_h,
   int _x_off,
   int _y_off,
   int _dst_x,
   int _dst_y,
   int _dst_w,
   int _dst_h);

// Do color space conversion and reshaping
// Change between RGB<->BGR<->MONO<->YUYV color space
// Reshape between interleave format and split format for color plane

GraphNodeColorAndReshape::GraphNodeColorAndReshape() {
   m_input=0;
   m_output=0;
   m_spu=0;
}

GraphNodeColorAndReshape::GraphNodeColorAndReshape(TENSOR *input,TENSOR *output,
                                                   TensorSemantic _dstColorSpace,
                                                   TensorFormat _dstFormat,
                                                   int clip_x,int clip_y,
                                                   int clip_w,int clip_h,
                                                   int dst_x,int dst_y,
                                                   int dst_w,int dst_h) : GraphNode() {
   Create(input,output,_dstColorSpace,_dstFormat,clip_x,clip_y,clip_w,clip_h,dst_x,dst_y,dst_w,dst_h);
}

GraphNodeColorAndReshape::~GraphNodeColorAndReshape() {
   Cleanup();
}

ZtaStatus GraphNodeColorAndReshape::Create(TENSOR *input,TENSOR *output,
                                          TensorSemantic _dstColorSpace,
                                          TensorFormat _dstFormat,
                                          int clip_x,int clip_y,
                                          int clip_w,int clip_h,
                                          int dst_x,int dst_y,
                                          int dst_w,int dst_h) {
   Cleanup();
   m_input=input;
   m_output=output;
   m_dstColorSpace=_dstColorSpace;
   m_dstFormat=_dstFormat;
   m_clip_x=clip_x;
   m_clip_y=clip_y;
   m_clip_w=clip_w;
   m_clip_h=clip_h;
   m_dst_x=dst_x;
   m_dst_y=dst_y;
   m_dst_w=dst_w;
   m_dst_h=dst_h;
   return ZtaStatusOk;
}

void GraphNodeColorAndReshape::Cleanup() {
   if(m_spu) {
      ztahostFreeSharedMem(m_spu);
      m_spu=0;
   }
}

// Implement verify operation required by GraphNode base class

ZtaStatus GraphNodeColorAndReshape::Verify() {
   TensorSemantic semantic;

   m_srcColorSpace=m_input->GetSemantic();
   if((*(m_input->GetDimension())).size() != 3)
      return ZtaStatusFail;
   m_src_w=(*(m_input->GetDimension()))[2];
   m_src_h=(*(m_input->GetDimension()))[1];
   m_nChannel=(*(m_input->GetDimension()))[0];
   if(m_srcColorSpace==TensorSemanticYUYV) {
      if(m_nChannel != 1) {
         return ZtaStatusFail;
      }
      if(m_input->GetDataType() != TensorDataTypeUint16 && 
         m_input->GetDataType() != TensorDataTypeInt16) {
         return ZtaStatusFail;
      }
      if(m_dstColorSpace != TensorSemanticRGB &&
         m_dstColorSpace != TensorSemanticBGR) {
         return ZtaStatusFail;
      } 
      if(m_spu) 
         ztahostFreeSharedMem(m_spu);
      m_spu=ztahostBuildSpuBundle(1,SpuCallback,0,0,0);
   } else if(m_srcColorSpace==TensorSemanticMonochromeSingleChannel) {
      // Monochrome with 1 channel
      if(m_nChannel != 1)
         return ZtaStatusFail;
      if(m_input->GetDataType() != TensorDataTypeUint8)
         return ZtaStatusFail;
      m_srcorder=kChannelColorMono;
      m_srcfmt=kChannelFmtSingle;
   } else if(m_srcColorSpace==TensorSemanticRGB || m_srcColorSpace==TensorSemanticBGR || m_srcColorSpace==TensorSemanticMonochrome) {
      // Convert from RGB/BGR space
      if((*(m_input->GetDimension())).size() != 3)
         return ZtaStatusFail;
      if(m_input->GetDataType() != TensorDataTypeUint8)
         return ZtaStatusFail;
      if(m_nChannel != 3)
         return ZtaStatusFail;
      if(m_srcColorSpace==TensorSemanticRGB)
         m_srcorder=kChannelColorRGB;
      else if(m_srcColorSpace==TensorSemanticBGR)
         m_srcorder=kChannelColorBGR;
      else
         m_srcorder=kChannelColorMono;
      m_srcfmt=(m_input->GetFormat()==TensorFormatSplit)?kChannelFmtSplit:kChannelFmtInterleave;
   } else {
      assert(0);
      return ZtaStatusFail;
   }
   if(m_clip_w==0)
      m_clip_w=m_src_w;
   if(m_clip_h==0)
      m_clip_h=m_src_h;
   if(m_dst_w==0)
      m_dst_w=m_clip_w;
   if(m_dst_h==0)
      m_dst_h=m_clip_h;
   switch(m_dstColorSpace) {
      case TensorSemanticRGB:
         m_dstorder=kChannelColorRGB;
         m_dstfmt=(m_dstFormat==TensorFormatSplit)?kChannelFmtSplit:kChannelFmtInterleave;
         semantic=TensorSemanticRGB;
         break;
      case TensorSemanticBGR:
         m_dstorder=kChannelColorBGR;
         m_dstfmt=(m_dstFormat==TensorFormatSplit)?kChannelFmtSplit:kChannelFmtInterleave;
         semantic=TensorSemanticBGR;
         break;
      case TensorSemanticYUYV:
         return ZtaStatusFail;
      case TensorSemanticMonochrome:
         m_dstorder=kChannelColorMono;
         m_dstfmt=(m_dstFormat==TensorFormatSplit)?kChannelFmtSplit:kChannelFmtInterleave;
         semantic=TensorSemanticMonochrome;
         break;
      case TensorSemanticMonochromeSingleChannel:
         m_dstorder=kChannelColorMono;
         m_dstfmt=kChannelFmtSingle;
         m_dstFormat=TensorFormatSplit;
         semantic=TensorSemanticMonochromeSingleChannel;
         break;
      default:
         assert(0);
   }
   if(m_dstColorSpace==TensorSemanticMonochromeSingleChannel) {
      std::vector<int> dim={1,m_dst_h,m_dst_w};
      m_output->Create(TensorDataTypeUint8,m_dstFormat,semantic,dim);
   } else {
      std::vector<int> dim={3,m_dst_h,m_dst_w};
      m_output->Create(TensorDataTypeUint8,m_dstFormat,semantic,dim);
   }
   return ZtaStatusOk;
}

// Implement schedule function required by GraphNode base class

ZtaStatus GraphNodeColorAndReshape::Prepare(int queue,bool stepMode) {
   if(m_srcColorSpace==TensorSemanticYUYV) {
      kernel_yuyv2rgb_exe(
         GetNextRequestId(queue),
         (unsigned int)m_input->GetBuf(),
         (unsigned int)m_output->GetBuf(),
		 (unsigned int)ZTA_SHARED_MEM_P(m_spu),
         m_clip_w,
         m_clip_h,
         m_dstfmt,
         m_dstorder,
         m_src_w,
         m_src_h,
         m_clip_x,
         m_clip_y,
         m_dst_x,
         m_dst_y,
         m_dst_w,
         m_dst_h);
   } else {
      kernel_copy_exe(
          GetNextRequestId(queue),
    	  (unsigned int)m_input->GetBuf(),
    	  (unsigned int)m_output->GetBuf(),
    	  m_clip_w,
    	  m_clip_h,
    	  m_srcfmt,
    	  m_srcorder,
    	  m_dstfmt,
    	  m_dstorder,
    	  m_src_w,
    	  m_src_h,
    	  m_clip_x,
    	  m_clip_y,
    	  m_dst_x,
    	  m_dst_y,
    	  m_dst_w,
    	  m_dst_h,
    	  0);
   }
   return ZtaStatusOk;
}

float GraphNodeColorAndReshape::SpuCallback(float input,void *pparm,uint32_t parm,uint32_t parm2)
{
   if(input < 0)
      return 0;
   else if(input > 255.0)
      return 255;
   else
      return input;
}
