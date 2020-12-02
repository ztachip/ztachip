# AI Stack

ztachip comes with an AI stack. This document describes how to build AI applications with ztachip AI stack.

ztachip AI stack is implemented as graph nodes as described in [Application Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/app_programmer_guide.md).

## 1. Prerequisites

To proceed with this document. Please familiar yourself with the following documents.

[ztachip Software Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/SoftwareArchitecture.md)

[Application Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/app_programmer_guide.md)

## 2. AI processing as a GraphNode

ztachip tasks are scheduled as a Graph object composed of GraphNode objects that represent different tasks.

TfliteNn object is a GraphNode object that implements AI acceleration functions. 

Refer to [Application Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/app_programmer_guide.md) on how to program a graph. 

### 2.1 TfliteNn::Create(const char *modelFileName,TENSOR *inputTensor,int numOutputTensor,TENSOR *ouputTensor,...)

To create a GraphNode for AI processing.

   - mdelFileName: This is the tflite model file that can be downloaded from [Google TensorFlow Lite website](https://www.tensorflow.org/lite/). There are many pretrained models that can be downloaded from this site. ztachip uses these pre-trained model files as is without any additional retraining. This makes AI programming on ztachip very easy and straight forward.

   - inputTensor: input tensor to the AI model.

   - numOutputTensor: number of output tensors that are produced by the AI model.

   - outputTensor: tensors that hold output of the AI model.

## 3. Examples

Examples below show how you can run AI models that are built and pretrained by Google's TensorFlowLite framework.

There are no retraining steps required to use these prebuilt and pretrained models.

This makes ztachip AI stack straightforward to use.

There are many prebuilt AI models that can be downloaded from [Google's TensorFlowLite website](https://www.tensorflow.org/lite/models).

### 3.1 Image classification example

[Click here](https://github.com/ztachip/ztachip/blob/master/examples/classifier/classifier.cpp) for example on how to run Image Classfication task using MobiNetv2.0 AI model.


### 3.2 Object detection example

[Click here](https://github.com/ztachip/ztachip/blob/master/examples/objdetect/objdetect.cpp) for example on how to run object detection task using SSD Mobinetv1.0 AI model.



