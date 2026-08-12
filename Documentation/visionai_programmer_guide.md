ZTACHIP

Vision-AI Stack

Programmer Guide

v1.0

Author: Vuong Nguyen

https://github.com/ztachip/ztachip

<vuongdnguyen@hotmail.com>

-INTRODUCTION
=============

ztachip provides many pre-built acceleration functions for vision and AI
applications.

To support these acceleration functions, a graph-based framework is
introduced. Different vision and AI functions are connected into a graph
of execution nodes.

Users can use this graph framework to integrate their own custom
acceleration functions with ztachip vision-ai stack.

2- GRAPH FRAMEWORK

Graph is a ztachip framework used to connect different processing nodes
together. It is particular popular framework used by many other AI and
vision frameworks such as OpenCV, TensorFLow, OpenVX, etc\...

Each ztachip acceleration functions are packaged as a graph node.

The flow of execution is then specified by how the graph nodes are
connected to form a graph.

There can be multiple Graph objects representing different execution
flow.

ztachip graph framework is composed of the following C++ classes:

-   TENSOR: Objects that encapsulate tensor data objects. They are used
    as\...

    -   Input tensor data to a graph
    -   Output result tensor data from a graph.
    -   Intermediate tensor to transfer data between graph nodes.

-   GraphNode

    -   Unit of execution in a graph. GraphNode takes input data tensor
        from previous graph nodes and transfer output data tensor to
        next graph nodes.

-   Graph

    -   Objects that represent the graph.

Graph structure
---------------

Diagram below illustrates how the main objects of a Graph are
interconnected.

![](asset/Pictures/20000007000026DD000032077335D8D7.svm){width="9.726cm"
height="12.187cm"}

TENSOR
------

\
TENSOR class encapsulates tensor data objects.

Data exchange between graph nodes are TENSOR objects.\

### Class Interface

####  TENSOR()

Default constructor without initialization.

####  TENSOR( TensorDataType \_dataType, TensorFormat \_fmt, TensorObjType objType, std::vector\<int\> &dim, void \*shm)

Constructor with initialization.

Input

+-----------------------------------+-----------------------------------+
| \_dataType                        | Data type of this tensor.         |
|                                   |                                   |
|                                   | Reference 1.2.2.1 for             |
|                                   | TensorDataType definition.        |
+-----------------------------------+-----------------------------------+
| \_fmt                             | Layout format of this tensor      |
|                                   |                                   |
|                                   | Reference 1.2.2.2 for             |
|                                   | TensorFormat definition           |
+-----------------------------------+-----------------------------------+
| objType                           | Object type of this tensor        |
|                                   |                                   |
|                                   | Reference 1.2.2.3 for             |
|                                   | TensorObjType definition.         |
+-----------------------------------+-----------------------------------+
| dim                               | Dimension size of this tensor.    |
+-----------------------------------+-----------------------------------+
| shm                               | If non-zero then use this         |
|                                   | parameter as memory allocation    |
|                                   | block for this tensor. In this    |
|                                   | case, this object does not own    |
|                                   | this memory block and will not    |
|                                   | free it when done.                |
|                                   |                                   |
|                                   | If zero, then allocate new memory |
|                                   | block for this tensor. The memory |
|                                   | is owned by this object will be   |
|                                   | freed by this object\'s           |
|                                   | destructor.                       |
+-----------------------------------+-----------------------------------+

####  ZtaStatus Create( TensorDataType \_dataType, TensorFormat \_fmt, TensorObjType \_objType, std::vector\<int\> &dim, ZTA\_SHARED\_MEM \_shm=0)

Call to initialize this object when default constructor was used.

Parameters are like 1.2.1.2

Output:

-   ZtaStatusOk if sucessful

<!-- -->

-   ZtaStatusFail otherwise.

####  ZtaStatus Clone(TENSOR \*other)

To initialize this object to have the same parameters as another tensor.

New memory block is also allocated and initialized to have the same
contents as the other tensor.

Input

  ------- -------------------------------------------------------------
  other   Reinitialize this tensor with contents of \'other\' tensor.
  ------- -------------------------------------------------------------

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus Alias(TENSOR \*other)

Initialize this object to be a reference to another TENSOR object.

Input

+-----------------------------------+-----------------------------------+
| other                             | This object is just a reference   |
|                                   | to the \'other\' tensor.          |
|                                   |                                   |
|                                   | This tensor does not own its data |
|                                   | contents since it is just         |
|                                   | referencing other tensor\'s data  |
|                                   | contents.                         |
+-----------------------------------+-----------------------------------+

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus Alias(void \*\_shm)

Data content for this tensor is a reference to a given allocated memory
block.

This tensor does not own the memory block and will not free it upon
completion.

Input

  ------- ------------------------------------------------------------------
  \_shm   This tensors data content is referencing \'\_shm\' memory block.
  ------- ------------------------------------------------------------------

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus CreateWithBitmap( const char \*bmpFile, TensorFormat fmt=TensorFormatSplit)

Initialize this tensor with the dimensions of a bitmap.

Load the bitmap content into this tensor.

Input

+---------+---------------------------------------------------------+
| bmpFile | File name of the bitmap to initialize this tensor with. |
|         |                                                         |
|         | Bitmap file must be 24-bit BMP format.                  |
+---------+---------------------------------------------------------+
| Fmt     | Layout format of this tensor.                           |
|         |                                                         |
|         | Reference 1.2.2.2 for TensorFormat definition.          |
+---------+---------------------------------------------------------+

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  TensorDataType GetDataType()

Return data type of this tensor.

Reference 1.2.2.1 for TensorDataType definition.

####  TensorFormat GetFormat()

Return data layout format of this tensor.

Reference 1.2.2.2 for TensorFormat definition.

####  TensorObjType GetObjType()

Return object type of this tensor.

Reference 1.2.2.3 for TensorObjType definition.

####  std::vector\<int\> \*GetDimension()

Return dimension list of this tensor.

The list starts with size of outer-most dimension and ends with size
inner-most dimension.

####  int GetDimension(int \_idx)

Return size of a dimension of this tensor.

Input

+-----------------------------------+-----------------------------------+
| \_idx                             | Dimension index to return its     |
|                                   | size.                             |
|                                   |                                   |
|                                   | \_idx ranges from 0 to            |
|                                   | (num\_dimension-1) with 0 means   |
|                                   | outer-most dimension and          |
|                                   | (num\_dimension-1) means          |
|                                   | inner-most dimension.             |
+-----------------------------------+-----------------------------------+

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  void \*GetBuf()

Return data buffer address of this tensor.

####  int GetBufLen()

Return total length of data buffer of this tensor.

####  static size\_t GetTensorSize(std::vector\<int\>& shape)

This is a utility function that returns the buffer size for a tensor
with a particular dimension.

Size return is number of elements for the tensor.

###  Data Types

####  TensorDataType Enumeration

This class supports the following data types

  ---------------------- --------------------------
  TensorDataTypeInt8     Signed 8-bit integer.
  TensorDataTypeUint8    Unsigned 8-bit integer.
  TensorDataTypeInt16    Signed 16-bit integer.
  TensorDataTypeUint16   Unsigned 16-bit integer.
  ---------------------- --------------------------

####  TensorFormat Enumeration

This enumeration supports for the following data layout format

+-----------------------------------+-----------------------------------+
| TensorFormatInterleaved           | For example with a tensor 3x2     |
|                                   |                                   |
|                                   | In this layout format, tensor     |
|                                   | elements layout in data buffer is |
|                                   | as followed.                      |
|                                   |                                   |
|                                   | \[0\]\[0\]                        |
|                                   |                                   |
|                                   | \[1\]\[0\]                        |
|                                   |                                   |
|                                   | \[2\]\[0\]                        |
|                                   |                                   |
|                                   | \[0\]\[1\]                        |
|                                   |                                   |
|                                   | \[1\]\[1\]                        |
|                                   |                                   |
|                                   | \[2\]\[1\]                        |
+-----------------------------------+-----------------------------------+
| TensorFormatSplit                 | For example with a tensor 3x2     |
|                                   |                                   |
|                                   | In this layout format, tensor     |
|                                   | elements layout in data buffer is |
|                                   | as followed.                      |
|                                   |                                   |
|                                   | \[0\]\[0\]                        |
|                                   |                                   |
|                                   | \[0\]\[1\]                        |
|                                   |                                   |
|                                   | \[1\]\[0\]                        |
|                                   |                                   |
|                                   | \[1\]\[1\]                        |
|                                   |                                   |
|                                   | \[2\]\[0\]                        |
|                                   |                                   |
|                                   | \[2\]\[1\]                        |
+-----------------------------------+-----------------------------------+

####  TensorObjType Enumeration

This enumeration supports the following tensor object types

  -------------------------------------- ----------------------------------------------------------------------------
  TensorObjTypeRGB                       Object type is an image with pixel color in RGB order
  TensorObjTypeBGR                       Image with pixel color in BGR order
  TensorObjTypeYUYV                      Image in YUYV color space.
  TensorObjTypeMonochrome                Monochrome image but in RGB format with R,G,B having same values
  TensorObjTypeMonochromeSingleChannel   Monochrome image but only with 1 byte per pixel representing the intensity
  TensorObjTypeUnknown                   Unknown data object type
  -------------------------------------- ----------------------------------------------------------------------------

GraphNode Class
---------------

This is a class template with virtual functions to be implemented by a
derived class.

Objects with GraphNode as base class are the execution units of a graph.

ztachip acceleration functions implemented by corresponding tensor
programs and pcore programs are encapsulated within a derived class of
GraphNode.

### Class Interface

####  GraphNode()

Default constructor

####  ZtaStatus Verify()

This is a virtual function to be implemented by a derived class.

The derived class verifies the integrity of this graph node and performs
any necessary initialization required before the start of execution.

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus Execute(int queue,bool stepMode)

This is a virtual function to be implemented by a derived class.

The derived class perform the execution associated with this node.

Input

+-----------------------------------+-----------------------------------+
| queue                             | There may be multiple graphs      |
|                                   | running simultaneously.           |
|                                   |                                   |
|                                   | Each graph has a unique queue id. |
|                                   |                                   |
|                                   | Graph node will use this queue id |
|                                   | to generate a unique job-id which |
|                                   | will then be passed to ztachip    |
|                                   | for task completion notification. |
+-----------------------------------+-----------------------------------+
| stepMode                          | If false, then execute this node  |
|                                   | till completion.                  |
|                                   |                                   |
|                                   | If true, then partially execute   |
|                                   | this node. This function will be  |
|                                   | invoked again for the node to     |
|                                   | continue with the execution.      |
|                                   |                                   |
|                                   | This is useful when a graph node  |
|                                   | may take a long execution time,   |
|                                   | and step mode allows execution of |
|                                   | a slow graph to be pre-empted by  |
|                                   | other more critical graph.        |
+-----------------------------------+-----------------------------------+

Output:

-   ZtaStatusOk if processing is completed successfully.
-   ZtaStatusPending if processing is successful but not fully
    completed. More processing is still required.
-   ZtaStatusFail if errors are encountered.

####  uint32\_t GetJobId(int queue)

Generate a unique job id for a tensor program execution.

Refer to \[1\] on how tensor program would use this job-id.

Example in \[1\] shows that tensor program is waiting for the completion
of the task by waiting for the notification message from ztachip about
the completion of job-id. However, when tensor program is called from
within a graph framework, tensor program must not wait for the
completion message since this is done by graph framework instead.

Input

+-------+-------------------------------------------------------------+
| queue | The same as queue id passed from Execute function (1.3.1.3) |
|       |                                                             |
|       | Each graph has a unique queue id.                           |
+-------+-------------------------------------------------------------+

Output:

Unique job id for a tensor processing task.

### Example of implementing a graph node.

Below is an example that shows how a new graph node is implemented.

GraphNode primary function is to provide wrapper functions for a tensor
program so that tensor program can be invoked as part of a graph
execution.

// Declare a new graph node. It is derived from GraphNode

class MyGraphNode : public GraphNode {

MyGraphNode();

\~MyGraphNode();

ZtaStatus Create(TENSOR \*in,TENSOR \*out);

ZtaStatus Prepare() {}

ZtaStatus Verify() {}

ZtaStatus Execute(int queue,bool stepMode);

private:

TENSOR \*m\_in;

TENSOR \*m\_out;

}

// Initialize this node.

ZtaStatus MyGraphNode ::Create(TENSOR \*in,TENSOR \*out) {

// In this example, output tensor has same format as input tensor

m\_in=in;

m\_out=out;

m\_out-\>Clone(m\_in);

return ZtaStatusOk;

}

// Verify this node.

ZtaStatus MyGraphNode ::Verify() {

return ZtaStatusOk;

}

// Prepare for new execution run.

ZtaStatus MyGraphNode ::Prepare() {

return ZtaStatusOk;

}

// Execute this node

ZtaStatus MyGraphNode ::Execute(int queue,stepMode) {

// Get a job id and run the tensor program

my\_tensor\_program(GetJobId(queue),

(uint8\_t \*)m\_in-\>GetBuf(),

(uint8\_t \*)m\_out-\>GetBuf(),

m\_in-\>GetBufLen());

return ZtaStatusOk;

}

Graph
-----

Object of this class implements a flow of execution of multiple steps
with each step are performed by a graph node.

Graph object owns all the graph nodes and coordinates the execution of
these nodes.

There can be multiple instances of Graph objects with each instance
performing a separate task.

### Class Interface

####  Graph()

Default constructor of this class

####  ZtaStatus Clear()

Reset the graph by clearing all the nodes.

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus Add(GraphNode \*node)

Add a graph node to the end of the graph.

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus Verify()

Verify the integrity of the graph.

Graph will then call Verify function of each node in the graph.

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus Prepare()

This function marks the beginning of a new graph execution. Previous
execution results are discarded.

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  ZtaStatus RunSingleStep()

Execute this graph in step mode.

In this mode, this function may have to be called multiple times to
reach execution completion.

This mode is useful when we want to run multiple graphs at the same
time, and we don\'t want a slow graph to block the execution of other
graphs that are more time critical.

Output:

-   ZtaStatusOk if graph processing is completed successfully.
-   ZtaStatusPending if graph processing is successful but not fully
    completed. More processing is still required by calling
    RunSingleStep() function again.
-   ZtaStatusFail otherwise.

####  ZtaStatus RunUntilCompletion()

To execute the graph until completion.

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

####  bool IsRunning()

Return true if graph is currently busy, false if graph is idle and ready
to accept a new execution run.

### Example running a single graph 

Example below shows how a single graph is created and executed.

// Declare graph,node and tensor objects

Graph graph;

Task1GraphNode node1;

Task2GraphNode node2;

TENSOR tensor\_input,tensor\_output,tensor\_temp;

// Initialize tensor\_input dimension and content from a bitmap image

tensor\_input.CreateWithBitmap("bitmap.bmp");

// Initialize and attach graph nodes to the graph

// node1 executes first, then node1 passes its output to node2 via
tensor\_temp,

// then node2 is the final stage of the graph.

// input to the graph is the tensor\_input.

// output of the graph is the tensor\_output.

node1.Create(&tensor\_input,&tensor\_temp);

node2.Create(&tensor\_temp,&tensor\_output);

graph.Add(&node1);

graph.Add(&node2);

// Verify the graph

graph.Verify();

// Prepare for execution

graph.Prepare();

// Execute the graph till completion

graph.RunUntilCompletion();

// Done. Result is now in tensor\_output

### Example running multiple graphs

Example below shows how to create and execute multiple graphs
simultaneously

This is like previous example except that there are 2 instances of the
graph.

// Declare graph,node and tensor objects

Graph graph\[2\];

Task1GraphNode node1;

Task2GraphNode node2;

Task3GraphNode node3;

Task4GraphNode node4;

TENSOR tensor\_input\[2\],tensor\_output\[2\],tensor\_temp\[2\];

// Initialize tensor\_input dimension and content from a bitmap image

tensor\_input\[0\].CreateWithBitmap("bitmap1.bmp");

tensor\_input\[1\].CreateWithBitmap("bitmap2.bmp");

// Create first graph

node1.Create(&tensor\_input\[0\],&tensor\_temp\[0\]);

node2.Create(&tensor\_temp\[0\],&tensor\_output\[0\]);

graph\[0\].Add(&node1);

graph\[0\].Add(&node2);

graph\[0\].Verify();

graph\[0\].Prepare();

// Create second graph

node3.Create(&tensor\_input\[1\],&tensor\_temp\[1\]);

node4.Create(&tensor\_temp\[1\],&tensor\_output\[1\]);

graph\[1\].Add(&node3);

graph\[1\].Add(&node4);

graph\[1\].Verify();

graph\[1\].Prepare();

// We can run each graph to completion consecutively.

// But in this example, we interleave the execution of both graphs by
running

// them in step mode.

// Since graphs are executed in steps, we have control on how to
schedule the

// execution of these graphs or even interleaving graph execution with
other

// tasks that are not related to graph.

while(graph\[0\].IsRunning() \|\| graph\[1\].IsRunning()) {

if(graph\[0\].IsRunning())

graph\[0\].RunSingleStep();

if(graph\[1\].IsRunning())

graph\[1\].RunSingleStep();

}

// Done. Result are now in tensor\_output\[0\] and tensor\_output\[1\]

-VISION STACK
=============

ztachip has a library of graph nodes that perform many common vision
processing tasks.

These vision processing functions are very efficient and fast since they
are implemented based on tensor programming as described in \[1\].

This vision library is used under the graph framework as described in
chapter 1.

Vision stack provides the following vision processing acceleration:

-   Edge detection using Canny Algorithm
-   Color space conversion
-   Tensor reshaping
-   Image Gaussian blurring
-   Feature detection using Harris-Corner Algorithm
-   Motion detection with Optical-flow algorithm
-   Image resizes

GraphNodeCanny
--------------

GraphNodeCanny is graph node implementing edge detection algorithm based
on canny edge detector algorithm.

###  GraphNodeCanny(*TENSOR* \*input,*TENSOR* \*output)

Constructor for this graph node.

Input

  -------- ------------------------------------------------------------------------------------------------------------------------------
  input    Input image to perform edge detection
  output   Output tensor will be initialized to have the same width and height as input tensor but with the following tensor attributes
  -------- ------------------------------------------------------------------------------------------------------------------------------

###  Create(*TENSOR* \*input,*TENSOR* \*output)

Call to initialize graph node when default constructor was used.

Parameters are like 2.1.1

###  void SetThreshold(int \_loThreshold,int \_hiThreshold)

Setting edge detection threshold

Input

+-----------------------------------+-----------------------------------+
| \_loThreshold                     | \_loThreshold must be \<= 255.    |
|                                   |                                   |
|                                   | If pixel gradient id below        |
|                                   | \_loThreshold than pixel is       |
|                                   | rejected as edge.                 |
|                                   |                                   |
|                                   | Default low threshold is 81.      |
+-----------------------------------+-----------------------------------+
| \_hiThreshold                     | \_hiThreshold must be \<= 255     |
|                                   |                                   |
|                                   | If pixel gradient is above        |
|                                   | \_hiThreshold than pixel is       |
|                                   | accepted as edge.                 |
|                                   |                                   |
|                                   | Default high threshold is 163.    |
+-----------------------------------+-----------------------------------+

Output:

None

###  void GetThreshold(int \*\_loThreshold,int \*\_hiThreshold)

Return current edge detection threshold

GraphNodeColorAndReshape
------------------------

This graph node performs color space conversion and tensor reshaping.

###  GraphNodeColorAndReshape( *TENSOR* \*input, *TENSOR* \*output, *TensorObjType* \_dstColorSpace, *TensorFormat* \_dstFormat, int clip\_x=0, int clip\_y=0, int clip\_w=0, int clip\_h=0, int dst\_x=0, int dst\_y=0, int dst\_w=0, int dst\_h=0)

Constructor for this graph node.

Transform and copy input tensor to output tensor.

Transform from a source tensor with a DataType/DataFormat to a
destination tensor with a different DataType/DataFormat.

Input

+-----------------------------------+-----------------------------------+
| input                             | Input tensor                      |
+-----------------------------------+-----------------------------------+
| output                            | Output tensor                     |
+-----------------------------------+-----------------------------------+
| \_dstColorSpace                   | Object type of destination tensor |
+-----------------------------------+-----------------------------------+
| \_dstFormat                       | Data format layout of destination |
|                                   | tensor                            |
+-----------------------------------+-----------------------------------+
| clip\_x\                          | Identifies the region within      |
| clip\_y\                          | input tensor to be used as source |
| clip\_w                           | tensor.                           |
|                                   |                                   |
| clip\_h                           | clip\_x and clip\_y is the origin |
|                                   | of the region.                    |
|                                   |                                   |
|                                   | clip\_w and clip\_h is the        |
|                                   | dimension of the region.          |
+-----------------------------------+-----------------------------------+
| dst\_x\                           | Identifies the region within      |
| dst\_y                            | output tensor to write result to. |
|                                   |                                   |
| dst\_w                            | dst\_x and dst\_y is the origin   |
|                                   | of the region.                    |
| dst\_h                            |                                   |
|                                   | dst\_w and dst\_h is the          |
|                                   | dimension of the region.          |
+-----------------------------------+-----------------------------------+

###  Create( *TENSOR* \*input, *TENSOR* \*output, *TensorObjType* \_dstColorSpace, *TensorFormat* \_dstFormat, int clip\_x=0, int clip\_y=0, int clip\_w=0, int clip\_h=0, int dst\_x=0, int dst\_y=0, int dst\_w=0, int dst\_h=0)

Call to initialize graph node when default constructor was used.

Parameters are like 2.2.1

 GraphNodeGaussian
-----------------

This graph node performs image blurring using a Gaussian filter.

###  GraphNodeGaussian(*TENSOR* \*input,*TENSOR* \*output)

Constructor for this graph node.

Input:

  -------- --------------------------------------------
  input    Input tensor to apply the gaussian filter.
  output   Output tensor.
  -------- --------------------------------------------

###  ZtaStatus Create(*TENSOR* \*input,*TENSOR* \*output)

Call to initialize graph node when default constructor was used.

Parameters are like 2.3.1

###  void SetSigma(float \_sigma)

Set sigma value of the gaussian filter.

###  float GetSigma()

Return current sigma value of the the gaussian filter.

GraphNodeHarris
---------------

This graph node performs Harris-Corner feature detection on an image.

###  GraphNodeHarris(*TENSOR* \*input,*TENSOR* \*output)

Constructor for this graph node.

Input:

  -------- -----------------------------------------------------------------------------------
  input    Input tensor.

  output   Output tensor with width=input\'s width, height=input\'s height, dataType=int16.\
           Data elements are feature detection scores. zero for no detection.
  -------- -----------------------------------------------------------------------------------

###  ZtaStatus Create(*TENSOR* \*input,*TENSOR* \*output)

Call to initialize graph node when default constructor was used.

Parameters are like 2.4.1

GraphNodeOpticalFlow
--------------------

This graph node performs optical flow algorithm for motion detection on
two images captured consecutively in time.

###  GraphNodeOpticalFlow(TENSOR \*input1,

TENSOR \*x\_gradient,

TENSOR \*y\_gradient,

TENSOR \*t\_gradient,

TENSOR \*x\_vect,

TENSOR \*y\_vect,

TENSOR \*display)

Constructor for this graph node.

Input

+-----------------------------------+-----------------------------------+
| input1                            | input1 is expected to be an alias |
|                                   | tensor to an image buffer.        |
|                                   |                                   |
|                                   | At every new execution, there     |
|                                   | must a new buffer submitted with  |
|                                   | the previous buffer still valid   |
|                                   | and unchanged.                    |
|                                   |                                   |
|                                   | This graph node compares current  |
|                                   | image buffer with the last image  |
|                                   | buffer for motion detection.      |
+-----------------------------------+-----------------------------------+
| x\_gradient                       | buffer with dimension hxw of type |
|                                   | int16                             |
|                                   |                                   |
|                                   | Holds the gradient change in x    |
|                                   | direction.                        |
+-----------------------------------+-----------------------------------+
| y\_gradient                       | buffer with dimension hxw of type |
|                                   | int16                             |
|                                   |                                   |
|                                   | Holds the gradient change in y    |
|                                   | direction.                        |
+-----------------------------------+-----------------------------------+
| t\_gradient                       | buffer with dimension hxw of type |
|                                   | int16                             |
|                                   |                                   |
|                                   | Holds the gradient change in time |
|                                   | direction.                        |
+-----------------------------------+-----------------------------------+
| x\_vect                           | x component of motion vector      |
+-----------------------------------+-----------------------------------+
| y\_vect                           | y component of motion vector      |
+-----------------------------------+-----------------------------------+
| display                           | Buffer with dimension 3xhxw       |
|                                   | intended for display purposes. If |
|                                   | set to 0 then display will not be |
|                                   | generated,                        |
|                                   |                                   |
|                                   | Pixel colour represents motion    |
|                                   | vector direction.                 |
|                                   |                                   |
|                                   | \ - red means movement to the     |
|                                   | right                             |
|                                   |                                   |
|                                   | \ - green means movement to the   |
|                                   | left                              |
|                                   |                                   |
|                                   | \ - blue means vertical movement. |
|                                   |                                   |
|                                   | Pixel intensity represents motion |
|                                   | vector magnitude.                 |
+-----------------------------------+-----------------------------------+

### * ZtaStatus Create(TENSOR \*input1,*

TENSOR \*x\_gradient,

TENSOR \*y\_gradient,

TENSOR \*t\_gradient,

TENSOR \*x\_vect,

TENSOR \*y\_vect,

TENSOR \*display)

Call to initialize graph node when default constructor was used.

Parameters are like 2.5.1

GraphNodeResize
---------------

This graph node performs image resize

###  GraphNodeResize(TENSOR \*input,TENSOR \*output,int w,int h)

Resize image

  -------- --------------------------------
  input    Input tensor to be resized
  output   Output tensor
  w        Width of image after resizing
  h        Height of image after resizing
  -------- --------------------------------

###  ZtaStatus Create(TENSOR \*input,TENSOR \*output,int w,int h)

Call to initialize graph node when default constructor was used.

Parameters are like 2.6.1

3-AI STACK

ztachip provides acceleration functions for the execution of Google\'s
TensorFlowLite model.

AI stack is implemented as graph node.

The following Neural Network Layers are supported

-   Convolution
-   ConvolutionDepthWise
-   FCN
-   Add
-   Concatenation
-   Logistics
-   ObjectDetection
-   PoolAverage
-   Reshape
-   Relu

 TfliteNn
--------

This is a graph node that would execute a TensorFlowLite model.

It executes an AI model using the original TensorFlowLite trained model
binary that we can be downloaded from Google website. No model
retraining is required.

###  ZtaStatus Create(const char \*fname,TENSOR \*\_input, int numOutput,\...) 

Load a TensorFlowLite model and prepare for inferencing.

Input

+-----------------------------------+-----------------------------------+
| fname                             | TensorFlowLite model file name.   |
|                                   |                                   |
|                                   | It has suffix \*.tflite           |
+-----------------------------------+-----------------------------------+
| \_input                           | Input tensor to the model.        |
+-----------------------------------+-----------------------------------+
| numOutput                         | Number of output tensors          |
|                                   | expected. After this parameter,   |
|                                   | we expect numOutput numbers of    |
|                                   | tensors to follow                 |
+-----------------------------------+-----------------------------------+

Output:

-   ZtaStatusOk if successful
-   ZtaStatusFail otherwise.

### * ZtaStatus* Load(const char \*fname,*TENSOR* \*\_input,               int numOutput,\...)

Same as 2.7.1

### * *ZtaStatus Unload()

Unload and close the current TensorFlowLite model.
