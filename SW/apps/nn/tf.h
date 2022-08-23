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

#ifndef _ZTA_TF_H_
#define _ZTA_TF_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include "flatbuffer/schema_generated.h"
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "../../base/graph.h"
#include "../../base/tensor.h"
#include "nn.h"

using namespace tflite;

#define TFLITE_SCHEMA_VERSION 3

#define TF_LITE_ENSURE_STATUS(a)  ((a)==TfliteStatusOk)


struct TfliteNnPadding {
   int32_t h;
   int32_t h_off;
   int32_t w;
   int32_t w_off;
};

// Definition for Tflit buffer
struct TfliteNnBufferDef
{
   uint8_t *buf;
   size_t size;
};

struct TfliteNnTensorDef
{
   NeuralNetTensorType type;
   struct {
      std::vector<float> m_scale;
      std::vector<int32_t> m_zeroPoint;
   } quantization;
   int m_buffer;
   std::vector<int> m_shape;
};

class TfliteNn : public NeuralNet {
public:
   TfliteNn();
   virtual ~TfliteNn();
   ZtaStatus Create(const char *fname,TENSOR *_input,int numOutput,...);   
   virtual ZtaStatus Verify();
   ZtaStatus Load(const char *fname,TENSOR *_input,int numOutput,...);
   ZtaStatus Unload();
private:
   // Parsing functions
   NeuralNetOperator ParseOpcode(const tflite::OperatorCode *opcode);
   NeuralNetActivation ParseActivation(tflite::ActivationFunctionType activation_);
   NeuralNetTensorType ParseTensorType(tflite::TensorType type_);
   int ComputePadding(int stride,int dilation_rate,int in_size,int filter_size,int out_size);
   int ComputePaddingWithOffset(int stride,int dilation_rate,int in_size,int filter_size,int out_size,int* offset);
   int ComputeOutSize(tflite::Padding padding,int image_size,int filter_size,int stride,int dilation_rate = 1);
   TfliteNnPadding ComputePaddingHeightWidth(
            int stride_height,int stride_width,int dilation_rate_height,
            int dilation_rate_width,int in_height,int in_width,int filter_height,
            int filter_width,tflite::Padding padding,int* out_height,int* out_width);
   void QuantizeMultiplier(double double_multiplier, int32_t* quantized_multiplier,int* shift);
   ZtaStatus PopulateConvolutionQuantizationParams(
            const TfliteNnTensorDef* input,
            const TfliteNnTensorDef* filter, const TfliteNnTensorDef* bias, TfliteNnTensorDef* output,
            const NeuralNetActivation activation, int32_t* multiplier, int32_t* shift,
            int32_t* output_activation_min, int32_t* output_activation_max,
            int32_t* per_channel_multiplier, int* per_channel_shift);
   ZtaStatus GetQuantizedConvolutionMultipler(const TfliteNnTensorDef* input,
            const TfliteNnTensorDef* filter,
            const TfliteNnTensorDef* bias,
            TfliteNnTensorDef* output,
            double* multiplier);
   ZtaStatus GetQuantizedConvolutionMultipler(const TfliteNnTensorDef* input,
            const TfliteNnTensorDef* filter,
            TfliteNnTensorDef* output,
            double* multiplier);
   void CalculateActivationRangeQuantizedImpl(NeuralNetActivation activation,
            int32_t qmin, int32_t qmax,
            TfliteNnTensorDef* output,
            int32_t* act_min, int32_t* act_max);
   ZtaStatus CalculateActivationRangeQuantized(NeuralNetActivation activation,
            TfliteNnTensorDef* output,
            int32_t* act_min,
            int32_t* act_max);
   void CalculateActivationRangeUint8(NeuralNetActivation activation,
            TfliteNnTensorDef* output, int32_t* act_min,
            int32_t* act_max);
   void CalculateActivationRangeInt8(NeuralNetActivation activation,
            TfliteNnTensorDef* output, int32_t* act_min,
            int32_t* act_max);
   void QuantizeMultiplierSmallerThanOneExp(double double_multiplier,
            int32_t* quantized_multiplier,
            int32_t* left_shift);
private:
   FILE *m_fp;
   uint8_t *m_buf;
   const tflite::Model *m_model;
   TENSOR *m_input;
   std::vector<TENSOR *> m_output;
   std::string m_modelName;
public:
   std::vector<TfliteNnBufferDef> m_buffers;
   std::vector<TfliteNnTensorDef> m_tensors;
};

#endif
