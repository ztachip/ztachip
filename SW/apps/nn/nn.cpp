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

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztalib.h"
#include "flatbuffer/schema_generated.h"
#include "nn.h" 
#include "nn_add.h"
#include "nn_concat.h"
#include "nn_conv2d.h"
#include "nn_logistic.h"
#include "nn_objdetect.h"
#include "nn_poolavg.h"
#include "nn_reshape.h"

// Base class to process to process neural network
 
NeuralNet::NeuralNet() : GraphNode() {
   m_runningStep=-1;
   m_input=0;
}

NeuralNet::~NeuralNet() {
   Unload();
}

NeuralNetLayer *NeuralNet::CreateLayer(int layerId,NeuralNetOperatorDef* op_) {
   NeuralNetOperator op=static_cast<NeuralNetOperator>(op_->op);
   NeuralNetLayer *layer;
   switch(op) {
      case NeuralNetOperatorConv2D:
         layer=new NeuralNetLayerConv2D(this,op_,ConvolutionType2D);
         break;
      case NeuralNetOperatorConvDepthWise:
         layer=new NeuralNetLayerConv2D(this,op_,ConvolutionTypeDepthWise);
         break;
      case NeuralNetOperatorConcatenation:
         layer=new NeuralNetLayerConcat(this,op_);
         break;
      case NeuralNetOperatorLogistic:
         layer=new NeuralNetLayerLogistic(this,op_);
         break;
      case NeuralNetOperatorReshape:
         layer=new NeuralNetLayerReshape(this,op_);
         break;
      case NeuralNetOperatorDetection:
         layer=new NeuralNetLayerObjDetect(this,op_);
         break;
      case NeuralNetOperatorAdd:
         layer=new NeuralNetLayerAdd(this,op_);
         break;
      case NeuralNetOperatorAvgPool2D:
         layer=new NeuralNetLayerPoolAvg(this,op_);
         break;
      case NeuralNetOperatorUnknown:
         layer=0;
         break;
      default:
         assert(0);
   }
   m_operators.push_back(layer);
   assert(layerId==((int)m_operators.size()-1));
   return layer;
}

// Model loading begins by derived class
ZtaStatus NeuralNet::LoadBegin(TENSOR *input,std::vector<TENSOR *> &_output) {
   m_input=input;
   m_output=_output;
   return ZtaStatusOk;
}

// Model loading has been completed from derived class
ZtaStatus NeuralNet::LoadEnd() {
   // Assign input tensor as input data to the model
   if(AssignInputTensor(true) != ZtaStatusOk)
      return ZtaStatusFail;   

   // Prune out all the passthrough layers (reshape)
   for(int i=(int)m_operators.size()-1;i >= 0;i--) {
      if(m_operators[i]->GetIoType()==LayerIoPassthrough) {
         int output_id=m_operators[i]->m_def.output[0];
         int input_id=m_operators[i]->m_def.input[0];
         for(int j=0;j < (int)m_operators.size();j++) {
            if(i==j)
               continue;
            if(m_operators[j]->GetIoType() != LayerIoPassthrough) {
               for(int k=0;k < (int)m_operators[j]->m_def.input.size();k++) {
                  if(m_operators[j]->m_def.input[k]==output_id)
                     m_operators[j]->m_def.input[k]=input_id;
               }
            }
         }
      }
   }

   // Assign output format type
   bool cont=true;
   while(cont) {
   cont=false;
   for(int i=0;i < (int)m_operators.size();i++) {
      switch(m_operators[i]->GetIoType()) {
         // Check for output requirement
         case LayerIoTypeInInterleaveOutInterleave: {
            // Input must be interleaved
            for(int j=0;j < (int)m_operators[i]->m_def.input.size();j++) {
               if(!BufferGetInterleave(m_operators[i]->m_def.input[j])) {
                  BufferAllocate(m_operators[i]->m_def.input[j],m_operators[i]->m_def.input_type[j],
                                 TENSOR::GetTensorSize(*m_operators[i]->m_def.input_shape[j]),false,true);
                  cont=true;
               }
            }
            // Output must be interleaved
            for(int j=0;j < (int)m_operators[i]->m_def.output.size();j++) {
               if(!BufferGetInterleave(m_operators[i]->m_def.output[j])) {
                  BufferAllocate(m_operators[i]->m_def.output[j],m_operators[i]->m_def.output_type[j],
                		  TENSOR::GetTensorSize(*m_operators[i]->m_def.output_shape[j]),false,true);
                  cont=true;
               }
            }
            break;
            }
         case LayerIoTypeInOutSame: {
            // Output and input must be the same
            if(BufferIsInit(m_operators[i]->m_def.input[0])) {
               if(!BufferIsInit(m_operators[i]->m_def.output[0])) {
                  bool interleaveFmt=(BufferGetInterleave(m_operators[i]->m_def.input[0])!=0);
                  bool flatFmt=(BufferGetFlat(m_operators[i]->m_def.input[0])!=0);
                  BufferAllocate(m_operators[i]->m_def.output[0],m_operators[i]->m_def.output_type[0],
                		  TENSOR::GetTensorSize(*m_operators[i]->m_def.output_shape[0]),flatFmt,interleaveFmt);
                  cont=true;
               }
            }
            if(BufferIsInit(m_operators[i]->m_def.output[0])) {
               if(!BufferIsInit(m_operators[i]->m_def.input[0])) {
                  bool interleaveFmt=(BufferGetInterleave(m_operators[i]->m_def.output[0])!=0);
                  bool flatFmt=(BufferGetFlat(m_operators[i]->m_def.output[0])!=0);
                  BufferAllocate(m_operators[i]->m_def.input[0],m_operators[i]->m_def.input_type[0],
                		  TENSOR::GetTensorSize(*m_operators[i]->m_def.input_shape[0]),flatFmt,interleaveFmt);
                  cont=true;
               }
            }
            break;
            }
         case LayerIoTypeInFlatOutInterleaveAndOrFlat: {
            // Input must be flat format
            if(!BufferGetFlat(m_operators[i]->m_def.input[0])) {
               BufferAllocate(m_operators[i]->m_def.input[0],m_operators[i]->m_def.input_type[0],
            		   TENSOR::GetTensorSize(*m_operators[i]->m_def.input_shape[0]),true,false);
               cont=true;
            }            
            break;
            }
         case LayerIoTypeInInterleaveOutInterleaveAndOrFlat: {
            // Input must be interleaved   
            if(!BufferGetInterleave(m_operators[i]->m_def.input[0])) {
               BufferAllocate(m_operators[i]->m_def.input[0],m_operators[i]->m_def.input_type[0],
            		   TENSOR::GetTensorSize(*m_operators[i]->m_def.input_shape[0]),false,true);
               cont=true;
            }
            break;
            }
         case LayerIoTypeInFlatOutFlat: {
            // Input and output must be flat format
            for(int j=0;j < static_cast<int>(m_operators[i]->m_def.input.size());j++) {
               if(!BufferGetFlat(m_operators[i]->m_def.input[j])) {
                  BufferAllocate(m_operators[i]->m_def.input[j],m_operators[i]->m_def.input_type[j],
                		  TENSOR::GetTensorSize(*m_operators[i]->m_def.input_shape[j]),true,false);
                  cont=true;
               }
            }
            for(int j=0;j < static_cast<int>(m_operators[i]->m_def.output.size());j++) {
               if(!BufferGetFlat(m_operators[i]->m_def.output[j])) {
                  BufferAllocate(m_operators[i]->m_def.output[j],m_operators[i]->m_def.output_type[j],
                		  TENSOR::GetTensorSize(*m_operators[i]->m_def.output_shape[j]),true,false);
                  cont=true;
               }
            }
            break;
            }
         case LayerIoPassthrough: {   
            // Igore reshape. Just a passthrough
            break;
            }
         default: {
            assert(0);
            break;
            }
      }
   }
   }
   for(int i=0;i < static_cast<int>(m_operators.size());i++) {
      for(int j=0;j < static_cast<int>(m_operators[i]->m_def.output.size());j++) {
         if(!BufferGetFlat(m_operators[i]->m_def.output[j]) && !BufferGetInterleave(m_operators[i]->m_def.output[j])) { 
            // If no allocation yet then default to flat format
            BufferAllocate(m_operators[i]->m_def.output[j],m_operators[i]->m_def.output_type[j],
            		TENSOR::GetTensorSize(*m_operators[i]->m_def.output_shape[j]),true,false);
         }
      }
   }

   // Assign output tensors to application's supplied tensors
   if(AssignOutputTensors(true) != ZtaStatusOk)
      return ZtaStatusFail;
   return ZtaStatusOk;
}

// Model is unload by derived class
ZtaStatus NeuralNet::Unload() {
   BufferFreeAll();
   for(int i=0;i < (int)m_operators.size();i++) {
      delete m_operators[i];
   }
   m_operators.clear();
   return ZtaStatusOk;
}

// Assign input tensor

ZtaStatus NeuralNet::AssignInputTensor(bool firstTime) {
   // Check input image is correct dimension,type and format
   if(TENSOR::GetTensorSize(*m_operators[0]->m_def.input_shape[0])==TENSOR::GetTensorSize(m_input->m_dim) &&
      (m_input->GetFormat()==TensorFormatSplit) &&
      ((m_operators[0]->m_def.input_type[0]==NeuralNetTensorType_UINT8 && m_input->GetDataType()==TensorDataTypeUint8) || 
      (m_operators[0]->m_def.input_type[0]==NeuralNetTensorType_INT8 && m_input->GetDataType()==TensorDataTypeInt8) || 
      (m_operators[0]->m_def.input_type[0]==NeuralNetTensorType_INT16 && m_input->GetDataType()==TensorDataTypeInt16))) {
      // Only support the data types above for now...
      BufferAllocate(m_operators[0]->m_def.input[0],m_input);
      return ZtaStatusOk;
   } else {
      return ZtaStatusFail;
   }
}

// Assign output tensors to external tensors

ZtaStatus NeuralNet::AssignOutputTensors(bool firstTime) {
   std::vector<int> *dim;
   std::vector<int> dim2;
   NeuralNetTensorType dataType;
   int numOutput;
   int bufid;
   int last=m_operators.size()-1;

   if(m_operators[last]->m_def.op==NeuralNetOperatorReshape) {
      numOutput=m_operators[last]->m_def.input.size();
   } else {
      numOutput=m_operators[last]->m_def.output.size();
   }
   for(int which=0;which < numOutput;which++) {
      TensorFormat tensorFmt;
      TensorDataType tensorDataType;

      if(which >= (int)m_output.size())
         break;
      // Set format of output tensor

      if(m_operators[last]->m_def.op==NeuralNetOperatorReshape) {
         if(BufferGetFlat(m_operators[last]->m_def.input[which])) {
            tensorFmt=TensorFormatSplit;
            bufid=m_operators[last]->m_def.input[which];
         } else {
            tensorFmt=TensorFormatInterleaved;
            bufid=m_operators[last]->m_def.input[which];
         }
         dataType=m_operators[last]->m_def.input_type[which];
         dim=m_operators[last]->m_def.input_shape[which];
      } else {
         if(BufferGetFlat(m_operators[last]->m_def.output[which])) {
            tensorFmt=TensorFormatSplit;
            bufid=m_operators[last]->m_def.output[which];
         } else {
            tensorFmt=TensorFormatInterleaved;
            bufid=m_operators[last]->m_def.output[which];
         }
         dataType=m_operators[last]->m_def.output_type[which];
         dim=m_operators[last]->m_def.output_shape[which];
      }
      // Set data type of output tensor
      switch(dataType) {
         case NeuralNetTensorType_UINT8:
            tensorDataType=TensorDataTypeUint8;
            break;
         case NeuralNetTensorType_INT8:
            tensorDataType=TensorDataTypeInt8;
            break;
         case NeuralNetTensorType_INT16:
            tensorDataType=TensorDataTypeInt16;
            break;
         case NeuralNetTensorType_FLOAT32:
            tensorDataType=TensorDataTypeFloat32;
            break;
         default:
            assert(0);
      }
      // Set output tensor dimension
      dim2.clear();
      for(int i=1;i < (int)dim->size();i++) { // Drop first dimension. This is the batch count
         dim2.push_back((*dim)[i]);
      }
      // Allocate output tensor
      if(firstTime)
         m_output[which]->Create(tensorDataType,tensorFmt,TensorSemanticUnknown,dim2);
      // Then assign NN internal buffer to this external tensors...
      BufferAllocate(bufid,m_output[which]);
   }
   return ZtaStatusOk;
}

// Implement Verify virtual function required by based class GraphNode

ZtaStatus NeuralNet::Verify() {
   return ZtaStatusOk;
}

// Implement Prepare virtual function required by based class GraphNode

ZtaStatus NeuralNet::Prepare(int queue,bool stepMode)
{
   ZtaStatus rc;
   if(m_runningStep < 0) {
      m_runningStep=0; // Restart from beginning
      AssignInputTensor(false);
      AssignOutputTensors(false);
   }
   while(m_runningStep < (int)m_operators.size()) {
      if(m_operators[m_runningStep]->RunAtHost()) {
         if(!GraphNode::AllRequestAreCompleted(queue))
            return ZtaStatusPending;
      }
      rc=m_operators[m_runningStep]->Evaluate(queue);
      if(rc==ZtaStatusPending)
         return rc;
      if(rc != ZtaStatusOk)
         return ZtaStatusFail;
      m_runningStep++;
      if(stepMode)
         break;
   }
   if(m_runningStep >= (int)m_operators.size()) {
      m_runningStep=-1;
      return ZtaStatusOk; // Scheduling is done
   } else {
      return ZtaStatusPending;
   }
}

NeuralNetLayer::NeuralNetLayer(NeuralNet *nn,NeuralNetOperatorDef* def) {
   m_nn=nn;
   m_def=*def;
}

NeuralNetLayer::~NeuralNetLayer() {
};

uint32_t NeuralNetLayer::GetNextRequestId(int queue) {
   return m_nn->GetNextRequestId(queue);
}
