#include <math.h>
#include "../../base/types.h"
#include "../../base/tensor.h"
#include "../../base/graph.h"
#include "kernels/of.h"
#include "of.h"

// Graph node to do optical flow using Lucas-Kanade algorithm
// https://en.wikipedia.org/wiki/Lucas%E2%80%93Kanade_method

GraphNodeOpticalFlow::GraphNodeOpticalFlow() {
   m_input1=0;
   m_x_gradient=0;
   m_y_gradient=0;
   m_t_gradient=0;
   m_x_vect=0;
   m_y_vect=0;
   m_display=0;
   m_spu=0;
}

GraphNodeOpticalFlow::GraphNodeOpticalFlow(TENSOR *input1,
                                          TENSOR *x_gradient,
                                          TENSOR *y_gradient,
                                          TENSOR *t_gradient,
                                          TENSOR *x_vect,
                                          TENSOR *y_vect,
                                          TENSOR *display) : GraphNodeOpticalFlow() {
   Create(input1,x_gradient,y_gradient,t_gradient,x_vect,y_vect,display);
}

GraphNodeOpticalFlow::~GraphNodeOpticalFlow() {
   Cleanup();
}

ZtaStatus GraphNodeOpticalFlow::Create(TENSOR *input1,
                                       TENSOR *x_gradient,
                                       TENSOR *y_gradient,
                                       TENSOR *t_gradient,
                                       TENSOR *x_vect,
                                       TENSOR *y_vect,
                                       TENSOR *display) {
   Cleanup();
   m_input1=input1;
   m_x_gradient=x_gradient;
   m_y_gradient=y_gradient;
   m_t_gradient=t_gradient;
   m_x_vect=x_vect;
   m_y_vect=y_vect;
   m_display=display;
   return ZtaStatusOk;
}


ZtaStatus GraphNodeOpticalFlow::Verify() {
   if((*(m_input1->GetDimension())).size() != 3)
      return ZtaStatusFail;
   for(int i=0;i < 2;i++) {
      m_buffer[i].Clone(m_input1);
   }
   m_bufferHead=0;
   m_input1->Alias(&m_buffer[m_bufferHead]);
   m_w=(*(m_input1->GetDimension()))[2];
   m_h=(*(m_input1->GetDimension()))[1];
   m_nChannel=(*(m_input1->GetDimension()))[0];
   if(m_nChannel != 1)
      return ZtaStatusFail;
   if(m_input1->GetSemantic() != TensorSemanticMonochromeSingleChannel)
      return ZtaStatusFail;
   if((*(m_input1->GetDimension())).size() != 3)
      return ZtaStatusFail;
   if((*(m_input1->GetDimension()))[2] != m_w)
      return ZtaStatusFail;
   if((*(m_input1->GetDimension()))[1] != m_h)
      return ZtaStatusFail;
   if((*(m_input1->GetDimension()))[0] != 1)
      return ZtaStatusFail;
   if(m_input1->GetSemantic() != TensorSemanticMonochromeSingleChannel)
      return ZtaStatusFail;

   std::vector<int> dim={m_h,m_w};
   m_x_gradient->Create(TensorDataTypeInt16,TensorFormatSplit,TensorSemanticUnknown,dim);
   m_y_gradient->Create(TensorDataTypeInt16,TensorFormatSplit,TensorSemanticUnknown,dim);
   m_t_gradient->Create(TensorDataTypeInt16,TensorFormatSplit,TensorSemanticUnknown,dim);
   m_x_vect->Create(TensorDataTypeInt16,TensorFormatSplit,TensorSemanticUnknown,dim);
   m_y_vect->Create(TensorDataTypeInt16,TensorFormatSplit,TensorSemanticUnknown,dim);
   std::vector<int> dim2={3,m_h,m_w};
   m_display->Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim2);

   ZTA_SHARED_MEM spu[4];
   int16_t *pp;
   spu[0]=ztahostBuildSpu(SpuCallback,0,0);
   spu[1]=ztahostBuildSpu(SpuDisplayLeftHorizontalCallback,0,0);
   spu[2]=ztahostBuildSpu(SpuDisplayRightHorizontalCallback,0,0);
   spu[3]=ztahostBuildSpu(SpuDisplayVerticalCallback,0,0);
   m_spu=ztahostAllocSharedMem(4*SPU_SIZE*2*sizeof(int16_t));
   pp=(int16_t *)ZTA_SHARED_MEM_P(m_spu);
   memcpy(pp,ZTA_SHARED_MEM_P(spu[0]),SPU_SIZE*2*sizeof(int16_t));
   pp+=SPU_SIZE*2;
   memcpy(pp,ZTA_SHARED_MEM_P(spu[1]),SPU_SIZE*2*sizeof(int16_t));
   pp+=SPU_SIZE*2;
   memcpy(pp,ZTA_SHARED_MEM_P(spu[2]),SPU_SIZE*2*sizeof(int16_t));
   pp+=SPU_SIZE*2;
   memcpy(pp,ZTA_SHARED_MEM_P(spu[3]),SPU_SIZE*2*sizeof(int16_t));

   ztahostFreeSharedMem(spu[0]);
   ztahostFreeSharedMem(spu[1]);
   ztahostFreeSharedMem(spu[2]);
   ztahostFreeSharedMem(spu[3]);

   m_func=ztahostGetExportFunction("do_of");
   return ZtaStatusOk;
}

ZtaStatus GraphNodeOpticalFlow::Schedule(int queue) {
   int curr=m_bufferHead;
   m_bufferHead=(m_bufferHead+1)%2;
   m_input1->Alias(&m_buffer[m_bufferHead]);
   ztahostMsgqWriteInt(queue,m_func);
   ztahostMsgqWriteInt(queue,GetNextRequestId(queue));
   ztahostMsgqWritePointer(queue,m_buffer[curr].GetBuf());
   ztahostMsgqWritePointer(queue,m_buffer[m_bufferHead].GetBuf());
   ztahostMsgqWritePointer(queue,m_x_gradient->GetBuf()); 
   ztahostMsgqWritePointer(queue,m_y_gradient->GetBuf()); 
   ztahostMsgqWritePointer(queue,m_t_gradient->GetBuf()); 
   ztahostMsgqWritePointer(queue,m_x_vect->GetBuf()); 
   ztahostMsgqWritePointer(queue,m_y_vect->GetBuf()); 
   ztahostMsgqWritePointer(queue,m_display->GetBuf()); 
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_spu)); 
   ztahostMsgqWriteInt(queue,m_w); 
   ztahostMsgqWriteInt(queue,m_h);
   ztahostMsgqWriteInt(queue,m_w);
   ztahostMsgqWriteInt(queue,m_h);
   ztahostMsgqWriteInt(queue,0);
   ztahostMsgqWriteInt(queue,0);
   ztahostMsgqWriteInt(queue,m_w);
   ztahostMsgqWriteInt(queue,m_h);
   return ZtaStatusOk;
}

void GraphNodeOpticalFlow::Cleanup() {
   if(m_spu) {
      ztahostFreeSharedMem(m_spu);
      m_spu=0;
   } 
}

float GraphNodeOpticalFlow::SpuCallback(float _in,void *pparm,uint32_t parm) {
   if(_in==0)
      _in=1;
   return (float)round((int32_t)(((1048576/32))/_in));
}

float GraphNodeOpticalFlow::SpuDisplayLeftHorizontalCallback(float _in,void *pparm,uint32_t parm) {
   if(_in<0)
      _in=0;
   if(_in>=255)
      _in=255;
   return _in;
}


float GraphNodeOpticalFlow::SpuDisplayRightHorizontalCallback(float _in,void *pparm,uint32_t parm) {
   if(_in>0)
      _in=0;
   else
      _in=-_in;
   if(_in>=255)
      _in=255;
   return _in;
}


float GraphNodeOpticalFlow::SpuDisplayVerticalCallback(float _in,void *pparm,uint32_t parm) {
   if(_in < 0)
      _in=-_in;
   if(_in >= 255)
      _in=255;
   return _in;
}

