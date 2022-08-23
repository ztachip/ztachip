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
#include "kernels/equalize.h"
#include "equalize.h"

extern "C" void kernel_equalize_exe(
   unsigned int _req_id,
   unsigned int _input,
   unsigned int _output,
   unsigned int _output2,
   int _nchannels,
   unsigned int _equalize,
   int _w,
   int _h
   );

// Graph node to do image equalization (improve image contrast)
// Calculate pixel value histogram and then apply image
// equalization.

GraphNodeEqualize::GraphNodeEqualize() {
   m_spu=0;
}

GraphNodeEqualize::GraphNodeEqualize(TENSOR *input,TENSOR *output) : GraphNodeEqualize() {
   Create(input,output);
}

GraphNodeEqualize::~GraphNodeEqualize() {
   Cleanup();
}

ZtaStatus GraphNodeEqualize::Create(TENSOR *input,TENSOR *output) {
   Cleanup();
   m_input=input;
   m_output=output;
   return ZtaStatusOk;
}


ZtaStatus GraphNodeEqualize::Verify() {
   if((*(m_input->GetDimension())).size() != 3)
      return ZtaStatusFail;
   m_w=(*(m_input->GetDimension()))[2];
   m_h=(*(m_input->GetDimension()))[1];
   m_nChannel=(*(m_input->GetDimension()))[0];
   SetContrast(2.0);
   std::vector<int> dim={m_nChannel,2,kHistogramBinSize,VECTOR_WIDTH};
   m_result.Create(TensorDataTypeInt16,TensorFormatSplit,TensorSemanticUnknown,dim);
   std::vector<int> dim2={m_nChannel,m_h,m_w};
   m_output->Create(TensorDataTypeUint8,TensorFormatSplit,m_input->GetSemantic(),dim2);
   m_histogramAvail=false;
   return ZtaStatusOk;
}

ZtaStatus GraphNodeEqualize::Prepare(int queue,bool stepMode) {
   if(m_histogramAvail) {
      GenEqualizer();
   }
   kernel_equalize_exe(
      (unsigned int)GetNextRequestId(queue),
	  (unsigned int)m_input->GetBuf(),
	  (unsigned int)m_result.GetBuf(),
	  (unsigned int)m_output->GetBuf(),
      m_nChannel,
	  (unsigned int)((m_histogramAvail && m_contrast>0)?m_spu:0),
      m_w,
      m_h
   );
   m_histogramAvail=true;
   return ZtaStatusOk;
}

ZTA_SHARED_MEM GraphNodeEqualize::GenEqualizer() {
   int16_t *histogram;
   int count;
   bool flag;
   int overflow;

   histogram = (int16_t *)m_result.GetBuf();
   for (int i=0;i < HISTOGRAM_BIN_COUNT;i++) {
      m_histogram[i]=0;
      for(int j=0;j < m_nChannel;j++) {
         m_histogram[i] += HISTOGRAM(histogram+j*64,i);
      }
   }
   for (int j = 0;j < 8;j++) {
      flag = false;
      for (int i=0;i < HISTOGRAM_BIN_COUNT;i++) {
         if (m_histogram[i] > m_threshold) {
            flag = true;
            overflow = m_histogram[i] - m_threshold;
            overflow = overflow / HISTOGRAM_BIN_COUNT;
            m_histogram[i] = m_threshold;
            for (int k = 0; k < HISTOGRAM_BIN_COUNT; k++)
               m_histogram[k] += overflow;
         }
      }
      if (!flag)
         break;
   }
   count=0;
   for(int i=0;i < HISTOGRAM_BIN_COUNT;i++) {
      m_histogram_sum[i]=count;
      count += m_histogram[i];
   }
   m_spu=ztahostBuildSpu(SpuCallback,this,0,m_spu);
   return m_spu;
}

float GraphNodeEqualize::SpuCallback(float input,void *pparm,uint32_t parm) {
   static GraphNodeEqualize *instance=0;
   uint8_t v;
   int count,i;
   if(pparm)
      instance=(GraphNodeEqualize *)pparm;
   if(input < 0)
      v=0;
   else if(input > 255.0)
      v=255;
   else
      v=input;
   i=(((int)v+1+HISTOGRAM_BIN_SIZE-1)/HISTOGRAM_BIN_SIZE)-1;
   count = instance->m_histogram_sum[i];
   count += (instance->m_histogram[i]*((v&(HISTOGRAM_BIN_SIZE-1))+1))/HISTOGRAM_BIN_SIZE;
   count = (255*count)/(instance->m_nChannel*instance->m_w*instance->m_h);
   if (count > 255)   
      count = 255;
   return (float)count;
}

void GraphNodeEqualize::Cleanup() {
   if(m_spu) {
      ztahostFreeSharedMem(m_spu);
      m_spu=0;
   }
}

void GraphNodeEqualize::SetContrast(float _contrast) {
   m_contrast=_contrast;
   m_threshold = (int)(m_contrast*(((float)(m_nChannel*m_w*m_h))/HISTOGRAM_BIN_COUNT));
}