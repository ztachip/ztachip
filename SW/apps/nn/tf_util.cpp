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
#include <math.h>
#include "flatbuffer/schema_generated.h"
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztalib.h"
#include "tf.h"

// Padding utilities

NeuralNetTensorType TfliteNn::ParseTensorType(tflite::TensorType type_) {
   switch(type_) {
      case TensorType_UINT8:
         return NeuralNetTensorType_UINT8;
      case TensorType_INT8:
         return NeuralNetTensorType_INT8;
      case TensorType_INT32:
         return NeuralNetTensorType_INT32;
      case TensorType_FLOAT32:
         return NeuralNetTensorType_FLOAT32;
      default:
         return NeuralNetTensorType_Unknown;
   }
}

NeuralNetActivation TfliteNn::ParseActivation(tflite::ActivationFunctionType activation_) {
   switch(activation_) {
      case ActivationFunctionType_NONE:
         return NeuralNetActivationNone;
      case ActivationFunctionType_RELU:
         return NeuralNetActivationRelu;
      case ActivationFunctionType_RELU_N1_TO_1:
         return NeuralNetActivationUnknown;
      case ActivationFunctionType_RELU6:
         return NeuralNetActivationRelu6;
      case ActivationFunctionType_TANH:
         return NeuralNetActivationUnknown;
      case ActivationFunctionType_SIGN_BIT:
         return NeuralNetActivationUnknown;
      default:
         return NeuralNetActivationUnknown;
   }
   return NeuralNetActivationUnknown;
}

NeuralNetOperator TfliteNn::ParseOpcode(const tflite::OperatorCode *opcode)
{
   switch(opcode->builtin_code()) {
      case BuiltinOperator_ADD:
         return NeuralNetOperatorAdd;
      case BuiltinOperator_AVERAGE_POOL_2D:
         return NeuralNetOperatorAvgPool2D;
      case BuiltinOperator_CONV_2D:
         return NeuralNetOperatorConv2D;
      case BuiltinOperator_DEPTHWISE_CONV_2D:
         return NeuralNetOperatorConvDepthWise;
      case BuiltinOperator_CONCATENATION:
         return NeuralNetOperatorConcatenation;
      case BuiltinOperator_LOGISTIC:
         return NeuralNetOperatorLogistic;
      case BuiltinOperator_RESHAPE:
         return NeuralNetOperatorReshape;
      case BuiltinOperator_CUSTOM:
         if(strcmp(opcode->custom_code()->c_str(),"TFLite_Detection_PostProcess")==0)
            return NeuralNetOperatorDetection;
         else {
            return NeuralNetOperatorUnknown;
         }
      default:
         return NeuralNetOperatorUnknown; 
   }
}

int TfliteNn::ComputePadding(int stride, int dilation_rate, int in_size,
                          int filter_size, int out_size) {
  int effective_filter_size = (filter_size - 1) * dilation_rate + 1;
  int padding = ((out_size - 1) * stride + effective_filter_size - in_size) / 2;
  return padding > 0 ? padding : 0;
}

int TfliteNn::ComputePaddingWithOffset(int stride, int dilation_rate, int in_size,
                                    int filter_size, int out_size,
                                    int* offset) {
  int effective_filter_size = (filter_size - 1) * dilation_rate + 1;
  int total_padding =
      ((out_size - 1) * stride + effective_filter_size - in_size);
  total_padding = total_padding > 0 ? total_padding : 0;
  *offset = total_padding % 2;
  return total_padding / 2;
}

int TfliteNn::ComputeOutSize(tflite::Padding padding, int image_size,
                          int filter_size, int stride, int dilation_rate) {
  int effective_filter_size = (filter_size - 1) * dilation_rate + 1;
  switch (padding) {
    case Padding_SAME:
      return (image_size + stride - 1) / stride;
    case Padding_VALID:
      return (image_size + stride - effective_filter_size) / stride;
    default:
      return 0;
  }
}

TfliteNnPadding TfliteNn::ComputePaddingHeightWidth(
    int stride_height, int stride_width, int dilation_rate_height,
    int dilation_rate_width, int in_height, int in_width, int filter_height,
    int filter_width, tflite::Padding padding, int* out_height, int* out_width) {
  *out_width = ComputeOutSize(padding, in_width, filter_width, stride_width,
                              dilation_rate_width);
  *out_height = ComputeOutSize(padding, in_height, filter_height, stride_height,
                               dilation_rate_height);

  TfliteNnPadding padding_values;
  int offset = 0;
  padding_values.h =
      ComputePaddingWithOffset(stride_height, dilation_rate_height, in_height,
                               filter_height, *out_height, &offset);
  padding_values.h_off = offset;
  padding_values.w =
      ComputePaddingWithOffset(stride_width, dilation_rate_width, in_width,
                               filter_width, *out_width, &offset);
  padding_values.w_off = offset;
  return padding_values;
}

// Quantization utilities

void TfliteNn::QuantizeMultiplier(double double_multiplier, int32_t* quantized_multiplier,int* shift) {
  if (double_multiplier == 0.) {
    *quantized_multiplier = 0;
    *shift = 0;
    return;
  }
  const double q = frexp(double_multiplier, shift);
  int64_t q_fixed = static_cast<int64_t>(round(q * (1ll << 31)));
  assert(q_fixed <= (1ll << 31));
  if (q_fixed == (1ll << 31)) {
    q_fixed /= 2;
    ++*shift;
  }
  assert(q_fixed <= std::numeric_limits<int32_t>::max());
  // A shift amount smaller than -31 would cause all bits to be shifted out
  // and thus all results would be zero. We implement that instead with
  // q_fixed==0, so as to avoid hitting issues with right-shift
  // operations with shift amounts greater than 31. Note that this happens
  // roughly when abs(double_multiplier) < 2^-31 and the present handling means
  // that we're effectively flushing tiny double_multiplier's to zero.
  // We could conceivably handle values in the range (roughly) [32, 63]
  // as 'denormals' i.e. (shift==0, q_fixed < 2^30). In that point of view
  // the present handling is just doing 'flush denormals to zero'. We could
  // reconsider and actually generate nonzero denormals if a need arises.
  if (*shift < -31) {
    *shift = 0;
    q_fixed = 0;
  }
  *quantized_multiplier = static_cast<int32_t>(q_fixed);
}

ZtaStatus TfliteNn::PopulateConvolutionQuantizationParams(
    const TfliteNnTensorDef* input,
    const TfliteNnTensorDef* filter, const TfliteNnTensorDef* bias, TfliteNnTensorDef* output,
    const NeuralNetActivation activation, int32_t* multiplier, int32_t* shift,
    int32_t* output_activation_min, int32_t* output_activation_max,
    int32_t* per_channel_multiplier, int* per_channel_shift) {

  // Populate multiplier and shift using affine quantization.
  const int num_channels = filter->quantization.m_scale.size();
  const float input_scale = input->quantization.m_scale[0];
  const float output_scale = output->quantization.m_scale[0];
  const std::vector<float> &filter_scales = filter->quantization.m_scale;
  if(num_channels != 1) {
     return ZtaStatusFail;
  }
  for (int i = 0; i < num_channels; ++i) {
    const double filter_scale = static_cast<double>(filter_scales[i]);
    const double effective_output_scale = static_cast<double>(input_scale) *
                                          filter_scale /
                                          static_cast<double>(output_scale);
    int32_t significand;
    int shift;
    QuantizeMultiplier(effective_output_scale, &significand, &shift);
    if(per_channel_multiplier)
      per_channel_multiplier[i] = significand;
    if(per_channel_shift)
      per_channel_shift[i] = shift;
  }

  // Populate scalar quantization parameters.
  // This check on legacy quantization parameters is kept only for backward
  // compatibility.
  if (input->type == NeuralNetTensorType_UINT8) {
    // Check bias scale == input scale * filter scale.
    double real_multiplier = 0.0;
    GetQuantizedConvolutionMultipler(input,filter,bias,output,&real_multiplier);
    int exponent;

    // Populate quantization parameteters with multiplier and shift.
    QuantizeMultiplier(real_multiplier, multiplier, &exponent);
    *shift = -exponent;
    CalculateActivationRangeUint8(activation, output, output_activation_min,
                                  output_activation_max);
  }
  return ZtaStatusOk;
}

ZtaStatus TfliteNn::GetQuantizedConvolutionMultipler(const TfliteNnTensorDef* input,
                                              const TfliteNnTensorDef* filter,
                                              const TfliteNnTensorDef* bias,
                                              TfliteNnTensorDef* output,
                                              double* multiplier) {
  return GetQuantizedConvolutionMultipler(input, filter, output,
                                          multiplier);
}

ZtaStatus TfliteNn::GetQuantizedConvolutionMultipler(const TfliteNnTensorDef* input,
                                              const TfliteNnTensorDef* filter,
                                              TfliteNnTensorDef* output,
                                              double* multiplier) {
  const double input_product_scale = input->quantization.m_scale[0] * filter->quantization.m_scale[0];
  *multiplier = input_product_scale / output->quantization.m_scale[0];
  return ZtaStatusOk;
}

void TfliteNn::CalculateActivationRangeQuantizedImpl(NeuralNetActivation activation,
                                           int32_t qmin, int32_t qmax,
                                           TfliteNnTensorDef* output,
                                           int32_t* act_min, int32_t* act_max) {
  const float scale = output->quantization.m_scale[0];
  const int32_t zero_point = output->quantization.m_zeroPoint[0];

  auto quantize = [scale, zero_point](float f) {
    return zero_point + static_cast<int32_t>(round(f / scale));
  };

  if (activation == NeuralNetActivationRelu) {
    *act_min = std::max(qmin, quantize(0.0));
    *act_max = qmax;
  } else if (activation == NeuralNetActivationRelu6) {
    *act_min = std::max(qmin, quantize(0.0));
    *act_max = std::min(qmax, quantize(6.0));
  } else if (activation == NeuralNetActivationRelu1) {
    *act_min = std::max(qmin, quantize(-1.0));
    *act_max = std::min(qmax, quantize(1.0));
  } else {
    *act_min = qmin;
    *act_max = qmax;
  }
}

ZtaStatus TfliteNn::CalculateActivationRangeQuantized(NeuralNetActivation activation,
                                               TfliteNnTensorDef* output,
                                               int32_t* act_min,
                                               int32_t* act_max) {
  int32_t qmin = 0;
  int32_t qmax = 0;
  if (output->type == NeuralNetTensorType_UINT8) {
    qmin = std::numeric_limits<uint8_t>::min();
    qmax = std::numeric_limits<uint8_t>::max();
  } else if (output->type == NeuralNetTensorType_INT8) {
    qmin = std::numeric_limits<int8_t>::min();
    qmax = std::numeric_limits<int8_t>::max();
  } else if (output->type == NeuralNetTensorType_INT16) {
    qmin = std::numeric_limits<int16_t>::min();
    qmax = std::numeric_limits<int16_t>::max();
  } else {
      return ZtaStatusFail;
  }

  CalculateActivationRangeQuantizedImpl(activation, qmin, qmax, output, act_min,
                                        act_max);
  return ZtaStatusOk;
}

void TfliteNn::CalculateActivationRangeUint8(NeuralNetActivation activation,
                                   TfliteNnTensorDef* output, int32_t* act_min,
                                   int32_t* act_max) {
  const int32_t qmin = std::numeric_limits<uint8_t>::min();
  const int32_t qmax = std::numeric_limits<uint8_t>::max();

  CalculateActivationRangeQuantizedImpl(activation, qmin, qmax, output, act_min,
                                        act_max);
}

void TfliteNn::CalculateActivationRangeInt8(NeuralNetActivation activation,
                                  TfliteNnTensorDef* output, int32_t* act_min,
                                  int32_t* act_max) {
  const int32_t qmin = std::numeric_limits<int8_t>::min();
  const int32_t qmax = std::numeric_limits<int8_t>::max();

  CalculateActivationRangeQuantizedImpl(activation, qmin, qmax, output, act_min,
                                        act_max);
}

void TfliteNn::QuantizeMultiplierSmallerThanOneExp(double double_multiplier,
                                         int32_t* quantized_multiplier,
                                         int32_t* left_shift) {
  assert(double_multiplier < 1.);
  assert(double_multiplier > 0.);
  int shift;
  QuantizeMultiplier(double_multiplier, quantized_multiplier, &shift);
  assert(shift <= 0);
  *left_shift = shift;
}

