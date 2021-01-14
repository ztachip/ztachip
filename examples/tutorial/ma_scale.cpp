#include <math.h>
#include "../../software/target/base/types.h"
#include "../../software/target/base/tensor.h"
#include "../../software/target/base/graph.h"
#include "ma_scale.h"

// Graph node to do matrix scaling

GraphNodeMaScale::GraphNodeMaScale() {
}

GraphNodeMaScale::GraphNodeMaScale(TENSOR *input,TENSOR *output,int scale) {
   Create(input,output,scale);
}

GraphNodeMaScale::~GraphNodeMaScale() {
}

ZtaStatus GraphNodeMaScale::Create(TENSOR *input,TENSOR *output,int scale) {
   m_input=input;
   m_output=output;
   m_scale=scale;
   return ZtaStatusOk;
}


ZtaStatus GraphNodeMaScale::Verify() {
   m_func=ztahostGetExportFunction("ma_scale");
   assert(m_func != 0);
   // Output tensor dimension must be same as input tensor
   m_output->Clone(m_input);
   return ZtaStatusOk;
}

// Issue request to mcore

ZtaStatus GraphNodeMaScale::Schedule(int queue) {
   ztahostMsgqWriteInt(queue,m_func);
   ztahostMsgqWriteInt(queue,GetNextRequestId(queue));
   ztahostMsgqWritePointer(queue,(void *)m_input->GetBuf());
   ztahostMsgqWritePointer(queue,(void *)m_output->GetBuf());
   ztahostMsgqWriteInt(queue,m_scale);
   ztahostMsgqWriteInt(queue,m_input->GetBufLen());
   return ZtaStatusOk;
}
