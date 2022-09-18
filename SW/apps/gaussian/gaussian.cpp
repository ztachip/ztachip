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
#include "kernels/gaussian.h"
}
#include "gaussian.h"

#define SIGMA 0.84089642
#define PI 3.14159265


// Graph node to do gaussian convolution on an image
// The effect is image blurring

GraphNodeGaussian::GraphNodeGaussian() {
   m_kernel=0;
}

GraphNodeGaussian::GraphNodeGaussian(TENSOR *input,TENSOR *output) : GraphNodeGaussian() {
   Create(input,output);
}

GraphNodeGaussian::~GraphNodeGaussian() {
   Cleanup();
}

ZtaStatus GraphNodeGaussian::Create(TENSOR *input,TENSOR *output) {
   Cleanup();
   m_input=input;
   m_output=output;
   return ZtaStatusOk;
}


ZtaStatus GraphNodeGaussian::Verify() {
   if((*(m_input->GetDimension())).size() != 3)
      return ZtaStatusFail;
   m_w=(*(m_input->GetDimension()))[2];
   m_h=(*(m_input->GetDimension()))[1];
   m_nChannel=(*(m_input->GetDimension()))[0];
   if(m_input->GetFormat() != TensorFormatSplit && m_nChannel > 1)
      return ZtaStatusFail;
   m_ksz=7;
   m_kernel=ztahostAllocSharedMem(m_ksz*m_ksz*sizeof(int16_t));
   m_sigma=SIGMA;
   BuildKernel();
   std::vector<int> dim={m_nChannel,m_h,m_w};
   m_output->Create(TensorDataTypeUint8,TensorFormatSplit,m_input->GetSemantic(),dim);
   return ZtaStatusOk;
}

ZtaStatus GraphNodeGaussian::Prepare(int queue,bool stepMode) {
   kernel_gaussian_exe(
      (unsigned int)GetNextRequestId(queue),
	  (unsigned int)m_input->GetBuf(),
	  (unsigned int)m_output->GetBuf(),
	  (unsigned int)ZTA_SHARED_MEM_P(m_kernel),
      m_nChannel,
      m_ksz,
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

float GraphNodeGaussian::gaussian(int x,int y,float sigma) {
   return (exp(-((x*x)+(y*y))/(2*sigma*sigma)))/(2*PI*sigma*sigma);
}

void GraphNodeGaussian::BuildKernel() {
   int16_t *kernel;
   kernel=(int16_t *)ZTA_SHARED_MEM_P(m_kernel);
   for(int y=0;y < m_ksz;y++) {
      for(int x=0;x < m_ksz;x++) {
         kernel[x+y*m_ksz]=(int)(gaussian(x-m_ksz/2,y-m_ksz/2,m_sigma)*1024);
      }
   }
}

void GraphNodeGaussian::SetSigma(float _sigma) {
   m_sigma = _sigma;
   BuildKernel();
}

float GraphNodeGaussian::GetSigma() {
   return m_sigma;
}

void GraphNodeGaussian::Cleanup() {
   if(m_kernel) {
      ztahostFreeSharedMem(m_kernel);
      m_kernel=0;
   }
}
