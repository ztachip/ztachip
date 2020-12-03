# Vision Stack

ztachip comes with a vision stack.

Vision stack provides functions such as image resize, edge detection, color conversion, harris-corner detection, optical-flow,... 

ztachip vision stack is implemented as graph nodes as described in [Application Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/app_programmer_guide.md).

## 1. Prerequisites

To proceed with this document. Please familiar yourself with the following documents.

[Application Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/app_programmer_guide.md)

## 2. Vision processing as a GraphNode

### 2.1 Image blurring

Performs image blurring with Gaussian filter convolution. 

#### 2.1.1 GraphNodeGaussian::GraphNodeGaussian(TENSOR *input,TENSOR *output)

Constructor to create gaussian blurring graph node.

   - input: input tensor

   - output: output tensor

#### 2.1.2 GraphNodeGaussian::SetSigma(float sigma)

Set sigma factor of gaussian function.

#### 2.1.3 Example

[Gaussian blurring example](https://github.com/ztachip/ztachip/blob/master/examples/blur/blur.cpp)

### 2.2 Edge detection

Perform edge detection using Canny algorithm

#### 2.2.1 GraphNodeCanny::GraphNodeCanny(TENSOR *input,TENSOR *output)

Constructor to create Edge Detection graph node. 

#### 2.2.2 GraphNodeCanny::SetTheshold(int loThreshold,int hiThreshold)

Set edge detection threshold

   - loThreshold: low threshold for edge detection

   - hiThreshold: high threshold for edge detection

#### 2.2.3 Example

[Edge detection example](https://github.com/ztachip/ztachip/blob/master/examples/edge_detect/edge_detect.cpp)

### 2.3 Harris-Corner detection

Perform harris-corner detection algorithm

#### 2.3.1 GraphNodeHarris::GraphNodeHarris(TENSOR *input,TENSOR *output) 

Constructor to create Harris-Corner processing graph node.

   - input: input tensor

   - output: output tensor

#### 2.3.2 Example

[Harris-Corner example](https://github.com/ztachip/ztachip/blob/master/examples/harris_corner/harris_corner.cpp)

### 2.4 Image resize

Perform image resize. Only downscaling is supported.

#### 2.4.1 GraphNodeResize::GraphNodeResize(TENSOR *input,TENSOR *output,int destination_h,int destination_w)

Constructor to create image resize graph node.

   - input: input tensor

   - output: output tensor

   - destination_h: height of resized image.

   - destination_w: width of resized image.

#### 2.4.2 Example

[Example of image resize](https://github.com/ztachip/ztachip/blob/master/examples/resize/resize.cpp)

### 2.5 Color conversion and reshaping

Perform color space conversion and image reshaping.

#### 2.5.1 GraphNodeColorAndReshape::GraphNodeColorAndReshape

Constructor to create color conversion and image reshaping graph node.

   - input: input tensor

   - output: output tensor

   - _dstColorSpace: destination color space based on TensorSemantic enumeration.

   - _dstFormat: data layout format based on TensorFormat enumeration.

   - clip_x: x origin of input region

   - clip_y: y origin of input region 
      
   - clip_w: width of input region

   - clip_h: height of input region

   - dst_x: x origin of output region

   - dst_y: y origin of output region

   - dst_w: width of output region

   - dst_h: height of output region

#### 2.5.2 Example

[Color conversion example](https://github.com/ztachip/ztachip/blob/master/examples/greyscale/greyscale.cpp)


### 2.6 Optical Flow

Perform optical flow algorithm

#### 2.6.1 GraphNodeOpticalFlow::GraphNodeOpticalFlow()

Constructor to create optical-flow graph node.

   - tensorOpticalFlowInput: input tensor

   - tensorOpticalFlowGradientX: optical flow gradient in x direction

   - tensorOpticalFlowGradientY: optical flow gradient in y direction

   - tensorOpticalFlowGradientT: optical flow gradient in time

   - tensorOpticalFlowVectX: optical flow direction x-component

   - tensorOpticalFlowVectY: optical flow direction y-component

   - tensorOpticalFlowDisplay: a color coded display of optical flow direction and magnitude.

#### 2.6.2 Example

[OpticalFlow example](https://github.com/ztachip/ztachip/blob/master/examples/vision_ai/vision_ai.cpp)








