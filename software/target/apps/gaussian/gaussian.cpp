#include <math.h>
#include "../../base/types.h"
#include "../../base/tensor.h"
#include "../../base/graph.h"
#include "kernels/gaussian.h"
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
   m_func=ztahostGetExportFunction("do_iconv");
   std::vector<int> dim={m_nChannel,m_h,m_w};
   m_output->Create(TensorDataTypeUint8,TensorFormatSplit,m_input->GetSemantic(),dim);
   return ZtaStatusOk;
}

ZtaStatus GraphNodeGaussian::Schedule(int queue) {
   ztahostMsgqWriteInt(queue,m_func);
   ztahostMsgqWriteInt(queue,1);
   ztahostMsgqWriteInt(queue,1);
   ztahostMsgqWritePointer(queue,(void *)m_input->GetBuf());
   ztahostMsgqWritePointer(queue,(void *)m_output->GetBuf());
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_kernel));
   ztahostMsgqWriteInt(queue,m_nChannel);
   ztahostMsgqWriteInt(queue,m_ksz);   
   ztahostMsgqWriteInt(queue,m_w); // w
   ztahostMsgqWriteInt(queue,m_h); // h
   ztahostMsgqWriteInt(queue,m_w); // src_w
   ztahostMsgqWriteInt(queue,m_h); // src_h
   ztahostMsgqWriteInt(queue,0); // x_off
   ztahostMsgqWriteInt(queue,0); // y_off
   ztahostMsgqWriteInt(queue,m_w); // dst_w
   ztahostMsgqWriteInt(queue,m_h); // dst_h
   ztahostMsgqWriteInt(queue,GetNextRequestId(queue));
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
