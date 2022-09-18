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

#ifndef _ZTA_NN_H_
#define _ZTA_NN_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <string>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "../../base/graph.h"
#include "../../base/tensor.h"

#define TFLITE_MAX_NUM_INPUT  16

typedef enum {
// Input is interleave and output is interleaved
LayerIoTypeInInterleaveOutInterleave,
// Input and output are both interleaved or are both flat
LayerIoTypeInOutSame,
// Input is interleaved and output is interleaved and/or flat
LayerIoTypeInInterleaveOutInterleaveAndOrFlat,
// Input is flat and output is interleaved and/or flat
LayerIoTypeInFlatOutInterleaveAndOrFlat,
// Input and output are flat
LayerIoTypeInFlatOutFlat,
// This layer is a passthrough. Can treat input and output to be the same
LayerIoPassthrough
} LayerIoType;

typedef enum {
  NeuralNetTensorType_FLOAT32 = 0,
  NeuralNetTensorType_FLOAT16 = 1,
  NeuralNetTensorType_INT32 = 2,
  NeuralNetTensorType_UINT8 = 3,
  NeuralNetTensorType_INT64 = 4,
  NeuralNetTensorType_STRING = 5,
  NeuralNetTensorType_BOOL = 6,
  NeuralNetTensorType_INT16 = 7,
  NeuralNetTensorType_COMPLEX64 = 8,
  NeuralNetTensorType_INT8 = 9,
  NeuralNetTensorType_Unknown=-1
} NeuralNetTensorType;

typedef enum {
   NeuralNetActivationNone,
   NeuralNetActivationRelu,
   NeuralNetActivationRelu6,
   NeuralNetActivationRelu1,
   NeuralNetActivationUnknown
} NeuralNetActivation;

typedef enum {
   NeuralNetOperatorConv2D=0,
   NeuralNetOperatorConvDepthWise,
   NeuralNetOperatorConcatenation,
   NeuralNetOperatorLogistic,
   NeuralNetOperatorReshape,
   NeuralNetOperatorDetection,
   NeuralNetOperatorAdd,
   NeuralNetOperatorAvgPool2D,
   NeuralNetOperatorUnknown,
   NeuralNetOperatorMax
} NeuralNetOperator;

struct NeuralNetBuffer {
   ZTA_SHARED_MEM shmFlat;
   bool shmFlatIsRef;
   ZTA_SHARED_MEM shmInterleave;
   bool shmInterleaveIsRef;
   size_t sz;
};

struct NeuralNetOperatorDef {
   int op;
   int index;
   std::vector<int> input;
   std::vector<int> output;
   std::vector<std::vector<int>*> input_shape;
   std::vector<std::vector<int>*> output_shape;
   std::vector<NeuralNetTensorType> input_type;
   std::vector<NeuralNetTensorType> output_type;
   union {
      struct {
         int32_t pad_w;
         int32_t pad_h;
         int32_t stride_w;
         int32_t stride_h;
         int32_t dilation_w_factor;
         int32_t dilation_h_factor;
         int32_t input_offset;
         int32_t weights_offset;
         int32_t output_offset;
         int32_t output_multiplier;
         int32_t output_shift;
         int32_t output_activation_min;
         int32_t output_activation_max;
         int32_t output_scale;
         uint8_t *bias;
         uint8_t *filter;
         std::vector<int> *filter_shape;
         std::vector<int> *bias_shape;
      } conv;
      struct {
         size_t size;
      } reshape;
      struct {
         uint32_t axis;
         uint32_t num_input;
         struct {
            int32_t zero_point;
            float scale;
         } input[TFLITE_MAX_NUM_INPUT];
         struct {
            int32_t zero_point;
            float scale;
         } output;
      } concat;
      struct {
         struct {
            float scale;
            int32_t zero_point;
         } input;
         struct {
            float scale;
            int32_t zero_point;
         } output;
      } logistic;
      struct {
         uint8_t *anchors;
         struct {
            float scale;
            int32_t zero_point;
         } input_box;
         struct {
            float scale;
            int32_t zero_point;
         } input_class;
         struct {
            float scale;
            int32_t zero_point;
         } input_anchor;
         float scale_x;
         float scale_y;
         float scale_w;
         float scale_h;
         float score_threshold;
         float iou_threshold;
      } detection;
      struct {
         size_t size;
         int32_t input_shift;
         struct {
            int32_t offset;
            int32_t shift;
            int32_t multiplier;
         } input[2];
         struct {
            int32_t offset;
            int32_t multiplier;
            int32_t shift;
         } output;
         int32_t activation_min;
         int32_t activation_max;
      } add;
      struct {
         int32_t stride_w;
         int32_t stride_h;
         int32_t filter_w;
         int32_t filter_h;
         int32_t pad_w;
         int32_t pad_h;
         int32_t activation_min;
         int32_t activation_max;
      } pool_avg;
   } u; 
};

class NeuralNet;
class NeuralNetLayer {
public:
   NeuralNetLayer(NeuralNet *nn,NeuralNetOperatorDef* def);
   virtual ~NeuralNetLayer();
   virtual ZtaStatus Prepare()=0;
   virtual ZtaStatus Evaluate(int queue)=0;
   virtual LayerIoType GetIoType()=0;
   virtual bool RunAtHost() {return false;}
   uint32_t GetNextRequestId(int queue);
public:
   NeuralNet *m_nn;
   NeuralNetOperatorDef m_def;
};

class NeuralNet : public GraphNode {
public:
   NeuralNet();
   virtual ~NeuralNet();
   ZtaStatus LoadBegin(TENSOR *input,std::vector<TENSOR *> &_output);
   ZtaStatus LoadEnd();
   virtual ZtaStatus Unload();

   // Verify virtual functions required by based class GraphNode

   virtual ZtaStatus Verify();
   virtual ZtaStatus Prepare(int queue,bool stepMode);

   bool IsRunning() {return (m_runningStep >= 0);}
   NeuralNetLayer *CreateLayer(int layerId,NeuralNetOperatorDef* op_);
public:
   // Some supporting functions to interpret results of inference...
   static ZtaStatus GetTop5(uint8_t *prediction,int predictionSize,int *top5);
   ZtaStatus LabelLoad(const char *fname);
   const char *LabelGet(int _idx);
public:
   ZTA_SHARED_MEM BufferAllocate(size_t sz);
   void BufferAllocateExternal(ZTA_SHARED_MEM shm);
   ZtaStatus BufferAllocate(int bufid,NeuralNetTensorType type,size_t sz,bool flatFmt,bool interleaveFmt);
   ZtaStatus BufferAllocate(int bufid,TENSOR *_tensor);
   ZTA_SHARED_MEM BufferGetFlat(int bufid);
   ZTA_SHARED_MEM BufferGetInterleave(int bufid);
   bool BufferIsInit(int bufid);
   void BufferFreeAll();
   void BufferSetAsExternal(int bufid,bool flatFmt,bool interleaveFmt);
private:
   ZtaStatus AssignInputTensor(bool firstTime);
   ZtaStatus AssignOutputTensors(bool firstTime);
public:
   std::vector<NeuralNetLayer *> m_operators;
public:
   // Some utilities
   inline float dequantize(uint8_t x,int32_t zero,float scale) { 
      return ((static_cast<float>(x) - zero) * scale);
   }
private:
   TENSOR *m_input;
   std::vector<TENSOR *> m_output;
   std::vector<NeuralNetBuffer> m_bufLst;
   std::vector<ZTA_SHARED_MEM> m_bufUnboundLst;
   int m_runningStep;
   std::vector<std::string> m_labels;
};

#endif
