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

First you must complete ztachip [Software Build Procedure](https://github.com/ztachip/ztachip/blob/master/Documentation/BuildProcedure.md), then you can proceed with building your custom acceleration codes like the example below...

```
cd [ZTACHIP INSTALLATION FOLDER]
source ./setenv.sh
# Go to folder where your custom acceleration codes are
cd examples/tutorial
## Build your custom host applications
make clean
make all
## Build ztachip binary image that also includes your custom acceleration codes.
make clean -f Makefile.kernels
make all -f Makefile.kernels
```

## Debugging your codes.

Tutorial above includes example of debugging. Put back define DEBUG_PRINT in [ma_add.m](https://github.com/ztachip/ztachip/blob/master/examples/tutorial/kernels/ma_add.m). Then rebuild the tutorial.

This compilation flag enable calls to ztamPrintf and LOG_ON directive.

When running tutorial, you should see debug string from ztamPrintf("do ma_add\n");

With LOG_ON directive, you should also see tensor engine activity tracing below after running tutorial.

```
           XX PP SS PP SS DD
           01 WR WR WR WR WR
[       0]    +            +
[       2]    |            | PCORE V8 X1  <= DDR V8 X1 
[     134]    |            | PCORE V8 X1  <= DDR V8 X1 
[     137]    |     +      |
[       2]    |     |      | PCORE V8 X1  <= DDR V8 X1 
[      56]    +     |      |
[       1] +        |      |
[      35] +        |      |
[      42]          |      | PCORE V8 X1  <= DDR V8 X1 
[       2]     +    |     +|
[       2]     |    |     || DDR V8 X1  <= PCORE V8 X1 
[       5]     |    |+    ||
[     141]     +    |+    ||
[       8]          |     |+
[      17]          |     + 
[      52]          +       
[       1]  +               
[       1]  |        +    + 
[       2]  |        |    |  DDR V8 X1  <= PCORE V8 X1 
[      32]  +        |    | 
[       2]     +     |    | 
[     141]     +     +    | 
[       5]                + 
```

Refer to [MCORE Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/mcore_programmer_guide.md) on
how to interpret Tensor Engine activity trace.

Another common method to debug is for apps to pass to mcore a temporary DDR memory block inorder to store intermediate tensor data from PCORE memory space for inspection during debugging.




