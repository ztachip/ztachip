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

- TensorCamera(): Tensor that is mapped to image capture from Camera

- TensorDisplay(): Tensor that is mapped to the display canvas. Display canvas are working copy for the next display output.

- Tensor(): temporary tensor used to carry intermediate results between GraphNodes.


## GraphNode objects

### GraphNodeCopyAndTransform(input,output,color,format,[row,col])

This GraphNode performs data copy from input tensor to output tensor. Perform some color and format conversion if required.

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

### GraphNodeCanny(input,output)

This graphNode performs Canny edge detection algorithm.

Edge detection threshold is set by GraphNodeCanny.SetThreshold(loThreshold,hiThreshold)

Parameters:

- input: Input tensor. This node expects input to be color=zta.MONO1 and format=zta.PLANAR.

- output: Output tensor. It has color=zta.MONO1 and format=zta.PLANAR  

### GraphNodeGaussian(input,output)

This graphNode performs Gaussian blurring algorithm.

Gaussian sigma is set by GraphNodeGaussian.SetSigma(sigma)

Parameters:

- input: Input tensor. This node expects input to be color=zta.COLOR and format=zta.PLANAR.

- output: Output tensor. Output has color=zta.COLOR and format=zta.PLANAR  

### GraphNodeHarris(input)

This graphNode performs Harris-Corner point-of-interest detection algo.

The resulted point-of-interests are then retrieved by calling GetPOI() which returns a list of POI coordinates [col,row]....

Parameters:

- input: Input tensor. This node expects input to be color=zta.MONO1 and format=zta.PLANAR.

### GraphNodeOpticalFlow(input,output)

This GraphNoode performs motion detection using OpticalFlow algo.

Parameters:

- input: Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR

- output: Motion is produced as color-coded pixel. Output has color=zta.COLOR and format=zta.PLANAR 


### GraphNodeResize(width,height)

This GraphNode performs image resize. Currently only image reduction is supported. 

Parameters:

- input: Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR

- output: Output tensor has color=zta.COLOR and format=zta.PLANAR 

### GraphNodeImageClassifier(input)

This GraphNode performs Mobinet image classification from TensorFlowLite.

Top 5 classification results are returned by calling GraphNodeImageClassifier.GetTop5 which returns a list of 5 tuples [probability,name]...

Parameters:

- input: Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR and image size=224x224


### GraphNodeObjectDetection(input)

This GraphNode performs SSD-Mobinet object detection from TensorFlowLite

List of detected objects are returned by calling GraphNodeObjectDetection.GetObjects() which returns a list of tuples describing the detected rectangular region of the objects [topleft_col,topleft_row,botright_col,botright_row,probability,name]

Parameters:

- input: Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR and image size=300x300

# Graph object

Graph is constructed from a list of GraphNodes objects described earlier.

Graph execution is performed with the following functions:

- Graph.Run(): To execute the graph until completion

- Graph.RunWithTimeout(timeout_in_ms): To execute the graph but only up to a time limit.A

- Graph.IsBusy(): To check if graph is still busy running. Normally in conjection with RunWithTimeout.

# Drawing functions.

Drawing is done on a canvas work area defined by TensorDisplay and not directly to the display.

- zta.CanvasDrawText(text,row,col): Draw a string at location [row,col]

- zta.CanvasDrawPoint(r,c): Draw a point at location [row,col]

- zta.CanvasDrawRectangle([top_left_row,top_lef_col],[bot_right_row,bot_right_col]) : Draw a rectangle by specifying the topleft and botright corners.

- zta.DisplayFlushCanvas(): Flush the canvas to the display screen.

# Camera function

- CameraCapture(): Return True is a new camera capture becomes available, False otherwise.

# Miscellaneous functions

- SetLed(ledVal) : Set LED

- ButtonState() : Return button state (True is pressed, False otherwise)

- GetElapsesTimeMsec() : Return time in msec from previous call to this function


  
