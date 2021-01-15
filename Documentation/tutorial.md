# HOW TO ADD YOUR OWN CUSTOM ACCLERATION FUNCTIONS TO ZTACHIP - A SIMPLE TUTORIAL

A tutorial to demonstrate how to add your own custom acceleration functions to ztachip. 

The example can be found in ztachip/examples/tutorial

This tutorial can be used as a template to add user-defined acceleration functions.

## Tutorial Components

There are 2 acceleration functions in this tutorial, one acceleration function is matrix addition and the other
acceleration function is matrix scaling (multiply each element with a scalar)

The example is implemented according to [ztachip Software Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/SoftwareArchitecture.md). 

In summary, there are 4 layers to ztachip software architecture

   - pcore program layer: Implement tensor operators

   - mcore program layer: Implement acceleration function in terms of tensor instructions.

   - graph node layer: Represent acceleration functions to user applications as graph nodes

   - user application layer: Use ztachip acceleration functions as a graph.

### pcore program layer 

[ma_add.p](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/kernels/ma_add.p) - Implement tensor operator for matrix addition

[ma_scale.p](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/kernels/ma_scale.p) - Implement tensor operator for matrix scaling

### mcore program layer

[ma_add.m](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/kernels/ma_add.m) - Implement mcore program to perform matrix addition

[ma_scale.m](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/kernels/ma_scale.m) - Implement mcore program to perform matrix scaling

### Graph Node layer

[ma_add.cpp](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/ma_add.cpp) - Implement graph node to accelerate matrix addition

[ma_scale.cpp](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/ma_scale.cpp) - Implement graph node to accelerate matrix scaling 

### User application layer

[tutorial.cpp](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/tutorial.cpp) - Example demonstrates matrix calculation acceleration with ztachip.


## Build procedure

Below is the procedure to build the tutorial.

There are 2 build. One build to generate host application, and the other build is to generate ztachip binary image (to be loaded to FPGA)

The genetated ztachip binary image is located at ztachip/software/target/builds/ztachip.hex

The generated host application binary is ./tutorial

You can modify the [Makefile](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/Makefile) and [Makefile.kernels](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/Makefile.kernels) in the tutorial to match your own applications.

```
cd [ZTACHIP INSTALLATION FOLDER]
source ./setenv.sh
cd examples/tutorial
## Build host applications
make clean
make all
## Build ztachip binary image to be loaded to FPGA
make clean -f Makefile.kernels
make all -f Makefile.kernels
```




