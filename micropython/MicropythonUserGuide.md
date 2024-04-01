# Introduction to ztachip MicroPython programming

ztachip provides a Python interface to construct a graph of execution and then to schedule for the execution of the Graph.

Graph performs many vision and AI tasks. The execution of the Graph is running with full ztachip acceleration mode so there is not much loss of performance when applications are running as python programs. 

A Graph object is composed of GraphNode objects and Tensor objects:

- Tensors are data objects used to pass data between GraphNodes

- GraphNode is the processing node of a Graph. It performs on the input Tensors and produces output on the output Tensors. 

ztachip python programming begins with the import of module zta

```
import zta
```

## Tensor objects

There are 3 types of tensors to be created by the functions below

- zta.TensorCamera(): Tensor that is mapped to image capture from Camera

- zta.TensorDisplay(): Tensor that is mapped to the display canvas. Display canvas are working copy for the next display output.

- zta.Tensor(): temporary tensor used to carry intermediate results between GraphNodes.


## GraphNode objects

### GraphNodeCopyAndTransform(input,output,color,format,[row,col])

Perform a data copy from input tensor to output tensor. Perform some color and format conversion if required.

Parameters:

- input: input tensor to this GraphNode

- output: output tensor from this GraphNode

- color: color of the resulted output tensor

    - zta.MONO1: Single channel monochrome 

    - zta.MONO3: 3-channel monochrome where R,G,B channels have same value.

    - zta.COLOR: 3-channel RGB color.

- format: Format of the resulted output tensor 

    - zta.PLANAR: channels are seperated as RRR....GGG....BBB....
   
    - zta.INTERLEAVED: channels are seperated as RGBRGBRGB....

- row,col: Apply when output tensor is DisplayTensor. Specify where on the display to copy the tensor to. If not specified then [0,0] is assumed.

### GraphNodeCanny
### GraphNodeGaussian
### GraphNodeHarris
### GraphNodeOpticalFlow
### GraphNodeResize
### GraphNodeImageClassifier
### GraphNodeObjectDetection




  
