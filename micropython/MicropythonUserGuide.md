<div style="display:flex; align-items:flex-start; gap:0; background:#ffffff; color:#24292f;">

<div style="flex:0 0 auto; width:200px; min-width:120px; max-width:70%; resize:horizontal; overflow:auto; height:100vh; box-sizing:border-box; position:sticky; top:0; padding:12px 14px 24px 14px; background:#000000; color:#e8eaed; font-size:13px; line-height:1.7;">

<a href="../Documentation/index.md" style="display:inline-block; margin-bottom:12px; padding:5px 10px; background:#1f2937; color:#e8eaed; border:1px solid #3a4553; border-radius:5px; text-decoration:none; font-size:12px;">&#8592; Home</a>

<div style="background:#d6e8ff; color:#0b2545; padding:9px 10px; border-radius:6px; text-align:center; font-weight:bold; font-size:13px; line-height:1.35; margin-bottom:14px;">ztachip<br>MicroPython User Guide</div>

<b>Contents</b>

<details open>
<summary><b><a href="#1-introduction" style="color:#e8eaed; text-decoration:none;">1. Introduction</a></b></summary>
<ul style="margin:4px 0 4px 6px; padding-left:14px;">
<li><a href="#11-tensor-objects" style="color:#e8eaed; text-decoration:none;">1.1 Tensor objects</a></li>
<li><details>
<summary><a href="#12-graphnode-objects" style="color:#e8eaed; text-decoration:none;">1.2 GraphNode objects</a></summary>
<ul style="margin:2px 0 2px 4px; padding-left:14px;">
<li><a href="#121-graphnodecopyandtransforminputoutputcolorformatrowcol" style="color:#e8eaed; text-decoration:none;">1.2.1 GraphNodeCopyAndTransform</a></li>
<li><a href="#122-graphnodecannyinputoutput" style="color:#e8eaed; text-decoration:none;">1.2.2 GraphNodeCanny</a></li>
<li><a href="#123-graphnodegaussianinputoutput" style="color:#e8eaed; text-decoration:none;">1.2.3 GraphNodeGaussian</a></li>
<li><a href="#124-graphnodeharrisinput" style="color:#e8eaed; text-decoration:none;">1.2.4 GraphNodeHarris</a></li>
<li><a href="#125-graphnodeopticalflowinputoutput" style="color:#e8eaed; text-decoration:none;">1.2.5 GraphNodeOpticalFlow</a></li>
<li><a href="#126-graphnoderesizewidthheight" style="color:#e8eaed; text-decoration:none;">1.2.6 GraphNodeResize</a></li>
<li><a href="#127-graphnodeimageclassifierinput" style="color:#e8eaed; text-decoration:none;">1.2.7 GraphNodeImageClassifier</a></li>
<li><a href="#128-graphnodeobjectdetectioninput" style="color:#e8eaed; text-decoration:none;">1.2.8 GraphNodeObjectDetection</a></li>
</ul>
</details></li>
</ul>
</details>

<details open>
<summary><b><a href="#2-graph-object" style="color:#e8eaed; text-decoration:none;">2. Graph object</a></b></summary>
<ul style="margin:4px 0 4px 6px; padding-left:14px;">
<li><a href="#21-graphrun" style="color:#e8eaed; text-decoration:none;">2.1 Graph.Run</a></li>
<li><a href="#22-graphrunwithtimeouttimeout_in_ms" style="color:#e8eaed; text-decoration:none;">2.2 Graph.RunWithTimeout</a></li>
<li><a href="#23-graphisbusy" style="color:#e8eaed; text-decoration:none;">2.3 Graph.IsBusy</a></li>
</ul>
</details>

<details open>
<summary><b><a href="#3-drawing-functions" style="color:#e8eaed; text-decoration:none;">3. Drawing functions</a></b></summary>
<ul style="margin:4px 0 4px 6px; padding-left:14px;">
<li><a href="#31-ztacanvasdrawtexttextrowcol" style="color:#e8eaed; text-decoration:none;">3.1 zta.CanvasDrawText</a></li>
<li><a href="#32-ztacanvasdrawpointrc" style="color:#e8eaed; text-decoration:none;">3.2 zta.CanvasDrawPoint</a></li>
<li><a href="#33-ztacanvasdrawrectangletop_left_rowtop_lef_colbot_right_rowbot_right_col" style="color:#e8eaed; text-decoration:none;">3.3 zta.CanvasDrawRectangle</a></li>
<li><a href="#34-ztadisplayflushcanvas" style="color:#e8eaed; text-decoration:none;">3.4 zta.DisplayFlushCanvas</a></li>
</ul>
</details>

<details open>
<summary><b><a href="#4-camera-function" style="color:#e8eaed; text-decoration:none;">4. Camera function</a></b></summary>
<ul style="margin:4px 0 4px 6px; padding-left:14px;">
<li><a href="#41-cameracapture" style="color:#e8eaed; text-decoration:none;">4.1 CameraCapture</a></li>
</ul>
</details>

<details open>
<summary><b><a href="#5-miscellaneous-functions" style="color:#e8eaed; text-decoration:none;">5. Miscellaneous functions</a></b></summary>
<ul style="margin:4px 0 4px 6px; padding-left:14px;">
<li><a href="#51-setledledval" style="color:#e8eaed; text-decoration:none;">5.1 SetLed</a></li>
<li><a href="#52-buttonstate" style="color:#e8eaed; text-decoration:none;">5.2 ButtonState</a></li>
<li><a href="#53-getelapsestimemsec" style="color:#e8eaed; text-decoration:none;">5.3 GetElapsesTimeMsec</a></li>
<li><a href="#54-deleteall" style="color:#e8eaed; text-decoration:none;">5.4 DeleteAll</a></li>
</ul>
</details>

</div>

<div style="flex:1 1 auto; min-width:0; background:#ffffff; color:#24292f; padding:0 24px;">

## 1. Introduction

ztachip provides a Python interface to construct a graph of execution and then to schedule for the execution of the Graph.

Graph performs many vision and AI tasks. The execution of the Graph is running with full ztachip acceleration mode so there is not much loss of performance when applications are running as python programs.

A Graph object is composed of GraphNode objects and Tensor objects:

- Tensors are data objects used to pass data between GraphNodes

- GraphNode is the processing node of a Graph. It performs on the input Tensors and produces output on the output Tensors.

ztachip python programming begins with the import of module zta

```python
import zta
```

Many examples on how to use the Python API are provided [here](examples)

### 1.1 Tensor objects

There are 3 types of tensors to be created by the functions below

- TensorCamera(): Tensor that is mapped to image capture from Camera

- TensorDisplay(): Tensor that is mapped to the display canvas. Display canvas are working copy for the next display output.

- Tensor(): temporary tensor used to carry intermediate results between GraphNodes.

### 1.2 GraphNode objects

#### 1.2.1 GraphNodeCopyAndTransform(input,output,color,format,[row,col])

This GraphNode performs data copy from input tensor to output tensor. Perform some color and format conversion if required.

Parameters:

| Name | Description |
| --- | --- |
| input | input tensor to this GraphNode |
| output | output tensor from this GraphNode |
| color | color of the resulted output tensor<br>zta.MONO1: Single channel monochrome<br>zta.MONO3: 3-channel monochrome where R,G,B channels have same value.<br>zta.COLOR: 3-channel RGB color. |
| format | Format of the resulted output tensor<br>zta.PLANAR: channels are seperated as RRR....GGG....BBB....<br>zta.INTERLEAVED: channels are seperated as RGBRGBRGB.... |
| row,col | Apply when output tensor is DisplayTensor. Specify where on the display to copy the tensor to. If not specified then [0,0] is assumed. |

#### 1.2.2 GraphNodeCanny(input,output)

This graphNode performs Canny edge detection algorithm.

Edge detection threshold is set by GraphNodeCanny.SetThreshold(loThreshold,hiThreshold)

Parameters:

| Name | Description |
| --- | --- |
| input | Input tensor. This node expects input to be color=zta.MONO1 and format=zta.PLANAR. |
| output | Output tensor. It has color=zta.MONO1 and format=zta.PLANAR |

#### 1.2.3 GraphNodeGaussian(input,output)

This graphNode performs Gaussian blurring algorithm.

Gaussian sigma is set by GraphNodeGaussian.SetSigma(sigma)

Parameters:

| Name | Description |
| --- | --- |
| input | Input tensor. This node expects input to be color=zta.COLOR and format=zta.PLANAR. |
| output | Output tensor. Output has color=zta.COLOR and format=zta.PLANAR |

#### 1.2.4 GraphNodeHarris(input)

This graphNode performs Harris-Corner point-of-interest detection algo.

The resulted point-of-interests are then retrieved by calling GetPOI() which returns a list of POI coordinates [col,row]....

Parameters:

| Name | Description |
| --- | --- |
| input | Input tensor. This node expects input to be color=zta.MONO1 and format=zta.PLANAR. |

#### 1.2.5 GraphNodeOpticalFlow(input,output)

This GraphNoode performs motion detection using OpticalFlow algo.

Parameters:

| Name | Description |
| --- | --- |
| input | Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR |
| output | Motion is produced as color-coded pixel. Output has color=zta.COLOR and format=zta.PLANAR |

#### 1.2.6 GraphNodeResize(width,height)

This GraphNode performs image resize. Currently only image reduction is supported.

Parameters:

| Name | Description |
| --- | --- |
| input | Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR |
| output | Output tensor has color=zta.COLOR and format=zta.PLANAR |

#### 1.2.7 GraphNodeImageClassifier(input)

This GraphNode performs Mobinet image classification from TensorFlowLite.

Top 5 classification results are returned by calling GraphNodeImageClassifier.GetTop5 which returns a list of 5 tuples [probability,name]...

Parameters:

| Name | Description |
| --- | --- |
| input | Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR and image size=224x224 |

#### 1.2.8 GraphNodeObjectDetection(input)

This GraphNode performs SSD-Mobinet object detection from TensorFlowLite

List of detected objects are returned by calling GraphNodeObjectDetection.GetObjects() which returns a list of tuples describing the detected rectangular region of the objects [topleft_col,topleft_row,botright_col,botright_row,probability,name]

Parameters:

| Name | Description |
| --- | --- |
| input | Input tensor. This node expects input to have color=zta.COLOR and format=zta.PLANAR and image size=300x300 |

## 2. Graph object

Graph is constructed from a list of GraphNodes objects described earlier.

Graph execution is performed with the following functions:

### 2.1 Graph.Run()

To execute the graph until completion.

### 2.2 Graph.RunWithTimeout(timeout_in_ms)

To execute the graph but only up to a time limit.

Parameters:

| Name | Description |
| --- | --- |
| timeout_in_ms | Time limit in milliseconds. |

### 2.3 Graph.IsBusy()

To check if graph is still busy running. Normally used in conjection with RunWithTimeout.

## 3. Drawing functions

Drawing is done on a canvas work area defined by TensorDisplay and not directly to the display.

### 3.1 zta.CanvasDrawText(text,row,col)

Draw a string at location [row,col].

Parameters:

| Name | Description |
| --- | --- |
| text | String to be displayed. |
| row | Row where the string is displayed. |
| col | Column where the string is displayed. |

### 3.2 zta.CanvasDrawPoint(r,c)

Draw a point at location [row,col].

Parameters:

| Name | Description |
| --- | --- |
| r | Row where the point is drawn. |
| c | Column where the point is drawn. |

### 3.3 zta.CanvasDrawRectangle([top_left_row,top_lef_col],[bot_right_row,bot_right_col])

Draw a rectangle by specifying the topleft and botright corners.

Parameters:

| Name | Description |
| --- | --- |
| top_left_row | Row of the top-left corner of the rectangle. |
| top_lef_col | Column of the top-left corner of the rectangle. |
| bot_right_row | Row of the bottom-right corner of the rectangle. |
| bot_right_col | Column of the bottom-right corner of the rectangle. |

### 3.4 zta.DisplayFlushCanvas()

Flush the canvas to the display screen.

## 4. Camera function

### 4.1 CameraCapture()

Return True is a new camera capture becomes available, False otherwise.

## 5. Miscellaneous functions

### 5.1 SetLed(ledVal)

Set LED.

Parameters:

| Name | Description |
| --- | --- |
| ledVal | Bit mask selecting which LEDs are on. Bit 0 is the first LED, bit 1 the second, and so on. |

### 5.2 ButtonState()

Return button state (True is pressed, False otherwise).

### 5.3 GetElapsesTimeMsec()

Return time in msec from previous call to this function.

### 5.4 DeleteAll()

To release all previously allocated Graph, GraphNode and Tensor objects. Call before exiting Python program.


</div>

</div>
