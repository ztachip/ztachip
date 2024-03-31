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
#include <stdarg.h>
#include <vector>
#include "flatbuffer/schema_generated.h"
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztalib.h"
#include "tf.h"

// Graph node to execute TFLITE model
// Process TFLITE model directly from Google. 
// No retraining is required

TfliteNn::TfliteNn() {
   m_fp=0;
   m_buf=0;
   m_model=0;
}

TfliteNn::~TfliteNn()
{
   Unload();
}

ZtaStatus TfliteNn::Unload() {
   NeuralNet::Unload();
   if(m_buf) {
      free(m_buf);
      m_buf=0;
   }
   if(m_fp) {
      fclose(m_fp);
      m_fp=0;
   }
   m_buffers.clear();
   m_tensors.clear();
   return ZtaStatusOk;
}

ZtaStatus TfliteNn::Create(const char *fname,TENSOR *_input,int numOutput,...) {
   va_list args;
   TENSOR *t;

   m_input=_input;
   m_output.clear();
   va_start(args,numOutput);
   for(int i=0;i < numOutput;i++) {
      t=va_arg(args,TENSOR *);
      m_output.push_back(t);
   }
   va_end(args);
   m_modelName=fname;
   return ZtaStatusOk;
}

ZtaStatus TfliteNn::Verify() {
   size_t sz;
   NeuralNetLayer *layer;
   std::vector<TENSOR *> output;

   Unload();
   
   NeuralNet::LoadBegin(m_input,m_output);

   m_fp=fopen(m_modelName.c_str(),"rb");
   assert(m_fp);
   fseek(m_fp, 0L, SEEK_END);
   sz = ftell(m_fp);
   m_buf=(uint8_t *)malloc(sz);
   fseek(m_fp,0,SEEK_SET);
   if(fread(m_buf,1,sz,m_fp) != sz) {
      return ZtaStatusFail;
   }
   m_model = ::tflite::GetModel(m_buf);
   if(m_model->version() != TFLITE_SCHEMA_VERSION) {
      return ZtaStatusFail;
   }

   // Get opcode list used in this model
   auto opcodes = m_model->operator_codes();
   auto subgraphs = m_model->subgraphs();
   std::vector<NeuralNetOperator> oplst;
   for (const OperatorCode* opcode : *opcodes) {
      oplst.push_back(ParseOpcode(opcode));
   }

   // Get list of all buffers...
   auto* buffers = m_model->buffers();
   for(uint32_t i=0;i < (uint32_t)((*buffers).size());i++) {
      auto* buffer = (*buffers)[i];
      auto* array = buffer?buffer->data():0;
      TfliteNnBufferDef def;
      def.buf=array?(uint8_t *)array->data():0;
      def.size=array?array->size():0;
      m_buffers.push_back(def);
   }

   // Now get the node definitions
   for (uint32_t subgraph_index = 0; subgraph_index < (uint32_t)subgraphs->size();
       ++subgraph_index) {
      const tflite::SubGraph* subgraph = (*subgraphs)[subgraph_index];
      auto operators = subgraph->operators();
      auto tensors = subgraph->tensors();
      if (!operators || !tensors) {
         return ZtaStatusFail;
      }
      // Get list of tensor definitions
      for (uint32_t i = 0; i < (uint32_t)tensors->size(); ++i) {
         const auto* tensor = tensors->Get(i);
         TfliteNnTensorDef def;
         def.type=ParseTensorType(tensor->type());
         if(tensor->quantization()->zero_point() && tensor->quantization()->scale()) {
            for(uint32_t j=0;j < (uint32_t)tensor->quantization()->zero_point()->size();j++) {
               def.quantization.m_zeroPoint.push_back(static_cast<int32_t>(tensor->quantization()->zero_point()->Get(j)));
               def.quantization.m_scale.push_back(tensor->quantization()->scale()->Get(j));
            }
         
}
         def.m_buffer=tensor->buffer();
         for(uint32_t j=0;j < (uint32_t)tensor->shape()->size();j++) {
            def.m_shape.push_back(tensor->shape()->Get(j));
         }
         m_tensors.push_back(def);
      }
      // Get list of operator definitions
      for (uint32_t i = 0; i < (uint32_t)operators->size(); ++i) {
         const auto* op = operators->Get(i);
         NeuralNetOperatorDef def;
         def.op=oplst[op->opcode_index()];
         def.index=i;
         switch(def.op) {
            case NeuralNetOperatorConvDepthWise:
            case NeuralNetOperatorConv2D: {
               tflite::Padding padding;
               tflite::ActivationFunctionType fused_activation_function;
               int32_t stride_w,stride_h,dilation_w_factor,dilation_h_factor;
               if(def.op==NeuralNetOperatorConvDepthWise) {
                  const tflite::DepthwiseConv2DOptions *conv_depth_params = op->builtin_options_as_DepthwiseConv2DOptions();
                  if(!conv_depth_params )
                     return ZtaStatusFail;
                  stride_w=conv_depth_params->stride_w();
                  stride_h=conv_depth_params->stride_h();
                  dilation_w_factor=conv_depth_params->dilation_w_factor();
                  dilation_h_factor=conv_depth_params->dilation_h_factor();
                  padding=conv_depth_params->padding();
                  fused_activation_function=conv_depth_params->fused_activation_function();
               } else {
                  const tflite::Conv2DOptions* conv_params = op->builtin_options_as_Conv2DOptions();
                  if(!conv_params )
                    return ZtaStatusFail;
                  stride_w=conv_params->stride_w();
                  stride_h=conv_params->stride_h();
                  dilation_w_factor=conv_params->dilation_w_factor();
                  dilation_h_factor=conv_params->dilation_h_factor();
                  padding=conv_params->padding();
                  fused_activation_function=conv_params->fused_activation_function();
               }
               TfliteNnTensorDef &input=m_tensors[op->inputs()->Get(0)];
               TfliteNnTensorDef &filter=m_tensors[op->inputs()->Get(1)];
               TfliteNnTensorDef &bias=m_tensors[op->inputs()->Get(2)];
               TfliteNnTensorDef &output=m_tensors[op->outputs()->Get(0)];
               int width = input.m_shape[2];
               int height = input.m_shape[1];
               int filter_width = filter.m_shape[2];
               int filter_height = filter.m_shape[1];
               int out_width,out_height;
               TfliteNnPadding pad;
               pad = ComputePaddingHeightWidth(
                                    stride_h,
                                    stride_w,
                                    dilation_h_factor, 
                                    dilation_w_factor,
                                    height,
                                    width,
                                    filter_height,
                                    filter_width,
                                    padding, 
                                    &out_height,
                                    &out_width);
               def.u.conv.pad_w=pad.w;
               def.u.conv.pad_h=pad.h;
               def.u.conv.stride_w=stride_w;
               def.u.conv.stride_h=stride_h;
               def.u.conv.dilation_w_factor=dilation_w_factor;
               def.u.conv.dilation_h_factor=dilation_h_factor;
               PopulateConvolutionQuantizationParams(
                     &input,&filter,&bias,&output,
                     ParseActivation(fused_activation_function),
                     &def.u.conv.output_multiplier,
                     &def.u.conv.output_shift,
                     &def.u.conv.output_activation_min,
                     &def.u.conv.output_activation_max,
                     0,0);
               def.u.conv.output_shift = -def.u.conv.output_shift;
               def.u.conv.input_offset = -input.quantization.m_zeroPoint[0];
               def.u.conv.weights_offset = -filter.quantization.m_zeroPoint[0];
               def.u.conv.output_offset = output.quantization.m_zeroPoint[0];
               assert(op->inputs()->size()==3);
               def.u.conv.filter=m_buffers[m_tensors[op->inputs()->Get(1)].m_buffer].buf;
               def.u.conv.bias=m_buffers[m_tensors[op->inputs()->Get(2)].m_buffer].buf;
               def.input_shape.push_back(&input.m_shape);
               def.input_type.push_back(input.type);
               def.output_shape.push_back(&output.m_shape);
               def.output_type.push_back(output.type);
               def.u.conv.filter_shape=&filter.m_shape;
               def.u.conv.bias_shape=&bias.m_shape;
               def.input.push_back(op->inputs()->Get(0));
               def.output.push_back(op->outputs()->Get(0));
               break;
               }
            case NeuralNetOperatorConcatenation: {
               const auto *concat_params = op->builtin_options_as_ConcatenationOptions();
               def.u.concat.axis=concat_params->axis();
               assert(op->inputs()->size() < TFLITE_MAX_NUM_INPUT);
               def.u.concat.num_input=op->inputs()->size();
               for(int i=0;i < (int)op->inputs()->size();i++) {
                  def.input.push_back(op->inputs()->Get(i));
                  def.u.concat.input[i].scale=m_tensors[op->inputs()->Get(i)].quantization.m_scale[0];
                  def.u.concat.input[i].zero_point=m_tensors[op->inputs()->Get(i)].quantization.m_zeroPoint[0];
                  def.input_shape.push_back(&m_tensors[op->inputs()->Get(i)].m_shape);
                  def.input_type.push_back(m_tensors[op->inputs()->Get(i)].type);
               }
               def.output.push_back(op->outputs()->Get(0));
               def.u.concat.output.scale=m_tensors[op->outputs()->Get(0)].quantization.m_scale[0];
               def.u.concat.output.zero_point=m_tensors[op->outputs()->Get(0)].quantization.m_zeroPoint[0];
               def.output_shape.push_back(&m_tensors[op->outputs()->Get(0)].m_shape);
               def.output_type.push_back(m_tensors[op->outputs()->Get(0)].type);
               break;
               }
            case NeuralNetOperatorLogistic: {
               def.input.push_back(op->inputs()->Get(0));
               def.u.logistic.input.scale=m_tensors[op->inputs()->Get(0)].quantization.m_scale[0];
               def.u.logistic.input.zero_point=m_tensors[op->inputs()->Get(0)].quantization.m_zeroPoint[0];
               def.input_shape.push_back(&m_tensors[op->inputs()->Get(0)].m_shape);
               def.input_type.push_back(m_tensors[op->inputs()->Get(0)].type);
               def.output.push_back(op->outputs()->Get(0));
               def.u.logistic.output.scale=m_tensors[op->outputs()->Get(0)].quantization.m_scale[0];
               def.u.logistic.output.zero_point=m_tensors[op->outputs()->Get(0)].quantization.m_zeroPoint[0];
               def.output_shape.push_back(&m_tensors[op->outputs()->Get(0)].m_shape);
               def.output_type.push_back(m_tensors[op->outputs()->Get(0)].type);
               break;
               }
            case NeuralNetOperatorDetection: {
               const TfliteNnTensorDef& input_box_encodings = m_tensors[op->inputs()->Get(0)];
               const TfliteNnTensorDef& input_class_predictions = m_tensors[op->inputs()->Get(1)];
               const TfliteNnTensorDef& input_anchors = m_tensors[op->inputs()->Get(2)];
               def.u.detection.anchors=m_buffers[m_tensors[op->inputs()->Get(2)].m_buffer].buf;
               def.input.push_back(op->inputs()->Get(0));
               def.u.detection.input_box.scale=input_box_encodings.quantization.m_scale[0];
               def.u.detection.input_box.zero_point=input_box_encodings.quantization.m_zeroPoint[0];
               def.input_shape.push_back(&m_tensors[op->inputs()->Get(0)].m_shape);
               def.input_type.push_back(m_tensors[op->inputs()->Get(0)].type);
               def.input.push_back(op->inputs()->Get(1));
               def.u.detection.input_class.scale=input_class_predictions.quantization.m_scale[0];
               def.u.detection.input_class.zero_point=input_class_predictions.quantization.m_zeroPoint[0];
               def.input_shape.push_back(&m_tensors[op->inputs()->Get(1)].m_shape);
               def.input_type.push_back(m_tensors[op->inputs()->Get(1)].type);
               def.input.push_back(op->inputs()->Get(2));
               def.u.detection.input_anchor.scale=input_anchors.quantization.m_scale[0];
               def.u.detection.input_anchor.zero_point=input_anchors.quantization.m_zeroPoint[0];
               def.input_shape.push_back(&m_tensors[op->inputs()->Get(2)].m_shape);
               def.input_type.push_back(m_tensors[op->inputs()->Get(2)].type);
               def.output.push_back(op->outputs()->Get(0));
               def.output_shape.push_back(&m_tensors[op->outputs()->Get(0)].m_shape);
               def.output_type.push_back(m_tensors[op->outputs()->Get(0)].type);
               def.output.push_back(op->outputs()->Get(1));
               def.output_shape.push_back(&m_tensors[op->outputs()->Get(1)].m_shape);
               def.output_type.push_back(m_tensors[op->outputs()->Get(1)].type);
               def.output.push_back(op->outputs()->Get(2));
               def.output_shape.push_back(&m_tensors[op->outputs()->Get(2)].m_shape);
               def.output_type.push_back(m_tensors[op->outputs()->Get(2)].type);
               def.output.push_back(op->outputs()->Get(3));
               def.output_shape.push_back(&m_tensors[op->outputs()->Get(3)].m_shape);
               def.output_type.push_back(m_tensors[op->outputs()->Get(3)].type);
               def.u.detection.scale_x=10.0;
               def.u.detection.scale_y=10.0;
               def.u.detection.scale_w=5.0;
               def.u.detection.scale_h=5.0;
               break;
               }
            case NeuralNetOperatorReshape: {
               TfliteNnTensorDef &input=m_tensors[op->inputs()->Get(0)];
               def.input.push_back(op->inputs()->Get(0));
               def.output.push_back(op->outputs()->Get(0));
               def.u.reshape.size=1;
               for(int i=0;i < (int)input.m_shape.size();i++) {
                  def.u.reshape.size *= input.m_shape[i];
               }
               for(int i=0;i < (int)op->inputs()->size();i++) {
                  def.input_shape.push_back(&m_tensors[op->inputs()->Get(i)].m_shape);
                  def.input_type.push_back(m_tensors[op->inputs()->Get(i)].type);
               }
               for(int i=0;i < (int)op->outputs()->size();i++) {
                  def.output_shape.push_back(&m_tensors[op->outputs()->Get(i)].m_shape);
                  def.output_type.push_back(m_tensors[op->outputs()->Get(i)].type);
               }
               break;
               }
            case NeuralNetOperatorAdd: {
               const tflite::AddOptions *add_params=op->builtin_options_as_AddOptions();
               TfliteNnTensorDef &input1=m_tensors[op->inputs()->Get(0)];
               TfliteNnTensorDef &input2=m_tensors[op->inputs()->Get(1)];
               TfliteNnTensorDef &output=m_tensors[op->outputs()->Get(0)];            
               const int32_t left_shift=20;
               assert(add_params);
               assert(op->inputs()->size()==2);
               assert(op->outputs()->size()==1);
               def.input.push_back(op->inputs()->Get(0));
               def.input.push_back(op->inputs()->Get(1));
               def.output.push_back(op->outputs()->Get(0));
               def.input_shape.push_back(&input1.m_shape);
               def.input_shape.push_back(&input2.m_shape);
               def.input_type.push_back(input1.type);
               def.input_type.push_back(input2.type);
               def.output_shape.push_back(&output.m_shape);
               def.output_type.push_back(output.type);
               def.u.add.size=TENSOR::GetTensorSize(output.m_shape);
               def.u.add.input[0].offset=-input1.quantization.m_zeroPoint[0];
               def.u.add.input[1].offset=-input2.quantization.m_zeroPoint[0];
               def.u.add.output.offset=output.quantization.m_zeroPoint[0];
               def.u.add.input_shift=left_shift;
               const double twice_max_input_scale =
                     2 * std::max(input1.quantization.m_scale[0],input2.quantization.m_scale[0]);
               const double real_input1_multiplier =
                     input1.quantization.m_scale[0] / twice_max_input_scale;
               const double real_input2_multiplier =
                     input2.quantization.m_scale[0] / twice_max_input_scale;
               const double real_output_multiplier =
                     twice_max_input_scale /
                     ((1 << left_shift) * output.quantization.m_scale[0]);
               QuantizeMultiplierSmallerThanOneExp(
                     real_input1_multiplier, &def.u.add.input[0].multiplier,&def.u.add.input[0].shift);
               QuantizeMultiplierSmallerThanOneExp(
                     real_input2_multiplier, &def.u.add.input[1].multiplier,&def.u.add.input[1].shift);
               QuantizeMultiplierSmallerThanOneExp(
                     real_output_multiplier, &def.u.add.output.multiplier,&def.u.add.output.shift);
               tflite::ActivationFunctionType activation=add_params->fused_activation_function();
               if (output.type == NeuralNetTensorType_UINT8) {
                  CalculateActivationRangeUint8(ParseActivation(activation),
                                             &output,
                                             &def.u.add.activation_min,
                                             &def.u.add.activation_max);
               } else {
                  CalculateActivationRangeInt8(ParseActivation(activation),
                                             &output,
                                             &def.u.add.activation_min,
                                             &def.u.add.activation_max);
               }
               break;
               }
            case NeuralNetOperatorAvgPool2D: {
               int out_height,out_width;
               const tflite::Pool2DOptions *pool_params=op->builtin_options_as_Pool2DOptions();
               TfliteNnTensorDef &input=m_tensors[op->inputs()->Get(0)];
               TfliteNnTensorDef &output=m_tensors[op->outputs()->Get(0)];            
               assert(op->inputs()->size()==1);
               assert(op->outputs()->size()==1);
               assert(pool_params);
               def.input.push_back(op->inputs()->Get(0));
               def.output.push_back(op->outputs()->Get(0));
               def.input_shape.push_back(&input.m_shape);
               def.input_type.push_back(input.type);
               def.output_shape.push_back(&output.m_shape);
               def.output_type.push_back(output.type);
               def.u.pool_avg.stride_w=pool_params->stride_w();
               def.u.pool_avg.stride_h=pool_params->stride_h();
               def.u.pool_avg.filter_w=pool_params->filter_width();
               def.u.pool_avg.filter_h=pool_params->filter_height();
               TfliteNnPadding pad = ComputePaddingHeightWidth(
                        def.u.pool_avg.stride_h,def.u.pool_avg.stride_w,
                        1,1, input.m_shape[1],input.m_shape[2],def.u.pool_avg.filter_h,
                        def.u.pool_avg.filter_w,pool_params->padding(), &out_height, &out_width);
               def.u.pool_avg.pad_w=pad.w;
               def.u.pool_avg.pad_h=pad.h;
               tflite::ActivationFunctionType activation=pool_params->fused_activation_function();
               CalculateActivationRangeUint8(ParseActivation(activation),&output,
                              &def.u.pool_avg.activation_min,&def.u.pool_avg.activation_max);
               break;
               }
            default:
               assert(0); // ????
         }
         if(!(layer=NeuralNet::CreateLayer(i,&def)))
            return ZtaStatusFail;
         if(layer->Prepare() != ZtaStatusOk)
            return ZtaStatusFail;
      }
      NeuralNet::LoadEnd();
   }
   return ZtaStatusOk;
}

