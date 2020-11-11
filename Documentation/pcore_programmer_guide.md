# PCORE Programmer Guide.

## 1. Prerequisites
To proceed with this document. Please familiar yourself with the software and hardware architecture of ztachip

[ztachip Hardware Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareArchitecture.md)

[ztachip Software Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/SoftwareArchitecture.md)

## 2. Overview

PCORE programs are codes that are executed on the PCORE array of processors.

These programs have a C-like syntax, but not all C features are supported.

PCORE program files have suffix *.p

There can be multiple *.p files and they are dynamically loaded to PCORE processors on demand.

There can only be one active PCORE program running at a time. 

At a highlevel view, they implement TENSOR operators that can then be invoked by MCORE programs. TENSOR operators can be viewed as functions with TENSORs as inputs and outputs.

PCORE processors all execute the same instructions in lock-step.
PCORE execution is then further scheduled into thread block. There are 16 threads per PCORE processor. Threads scheduling are hardware based with zero-overhead.
PCORE thread executions are pipelined and interleaved between different threads. This allows for 1 instruction to be executed per clock. 

PCORE also has a VLIW architecture. Meaning each VLIW instructions contain multiple operations. 

## 3. VLIW instructions

PCORE processor has a VLIW architecture. Each instructions can perform upto 3 operations:

### 3.1 Vector operations
Vector operations are executed in the vector ALU units.
Implement operations such as FMA,ADD,SUBTRACT,MULTIPLY,SHIFT. These operations are the ones that carry out most of the computing.
For more expressive capabilities, operands to vector operations can be direct address, direct address with offset, pointer, pointer with offset.

### 3.2 Scalar operations
Scalar operations are executed in the scalar ALU units.
Implement integer operations such as ADD,SUB,MUL,SHIFT. These operations are normally used for array indexing, address calculation, loop counter...

### 3.3 Control operations
Perform conditional branching 

## 4. PCORE program syntax.

### 4.1 General description

PCORE programs define TENSOR operators as objects with their own attributes and operations.

All objects are defined as single instance objects. Meaning you dont have to allocate the objects and the objects are automatically created and destroyed.

Example below is a PCORE program which defines matrix addition operation.

```
   // Declare object matrix
   _NT16_ class matrix;

   // Tensor operator for matrix addition
   _kernel_ void matrix::add(float8 x,float8 y,float8 z) 
   {
      z=x+y;
   }

```

### 4.2 Memory layout

Different classes defined within the same *.p file are overlayed in the same memory region.

Which means when you switch to using a different class, the current class variable values will be overwritten. 

Memory region used for classes allocation can be private or shared PCORE memory space.

### 4.2 Class declaration

Each class must be declared with the following syntax
```
[_NT16_|_NT8_|_NT4_] class [class_name]
```
Where

`_NT16_` means this object is allocated among all 16 threads.

`_NT8_` means this object is allocated among 8 threads.

`_NT4_` means this object is allocated among 4 threads.

Example:
```
_NT16_ class matrix; // Defines object class matrix. This object is allocated among all 16 threads;

```

### 4.3 Data types 

#### 4.3.1 float
scalar of 12 bit integer. This data type is used with vector ALU. Variables of this type are used to hold computing values. Note that this is not actually a float type but rather it is a 12 bit integer type.

Example:
```
   float myclass::myvar; // myvar is variable of type float and belonged to class myclass.
```

#### 4.3.2 float8
vector of 8x12 bit integers. This data type is used with vector ALU. Variables of this type are used to hold computing values. Note that this is not actually a vector of float type but rather it is a vector of 12-bit integers.

Example:
```
   float8 myclass::myvar; // myvar is variable of type float8 and belonged to class myclass.
```

#### 4.3.3 int
scalar 12 bit integer. This data type is used with scalar ALU. Variable of this type is normally used for loop index, array index...

Example:
```
   int myclass::myvar; // myvar is variable of type int and belonged to class myclass.
```

#### 4.3.4 float *
pointer to a float variable or array of float variables.

Example:
```
   float *myclass::myvar; // myvar is variable of type float * and belonged to class myclass.
```


#### 4.3.5 float8 *
pointer to a float8 variable or array of float8 variables.

Example:
```
   float8 *myclass::myvar; // myvar is variable of type float8 * and belonged to class myclass.
```


### 4.4 Data scope

#### 4.4.1 Private scope

There is an instance of the variable allocated for each thread.

For example:

```
   float myclass::my_private_variable;  // seperate instance of my_private_variable are allocated for each thread
```

#### 4.4.2 Shared scope

There is only one instance of the variable shared among all the threads within the same PCORE processor.

Shared variables are preceded with keyword `_share`

For example:

```
   _share myclass::my_shared_variable; // my_shared_variable is shared among all the threads in the same PCORE.
```

### 4.5 Class operations

These are functions that can be invoked by MCORE programs.

They have void return type and preceded with keyword `_kernel_`

They may optionally have an input parameter list. Parameter list are temporary variables that have a lifetime of the function call only.

When another function being called, the parameter list of the new functions may override that parameter variables of the previous function call.

For example:

```
   _kernel_ void matrix::my_function(float8 x,float8 y,float8 z)
   {
      z=x+y;
   }
```

### 4.6 Special syntax

#### 4.6.1 _VMASK

This is a special integer variable where each bit controls a vector ALU lane.

For example:

_VMASK=1 enables only the first lane of the vector ALU. 

_VMASK=3 enables the first and second lane of vector ALU.

To enable all the lanes, set _VMASK=-1

#### 4.6.2 GE(v1,v2)
Test for v1 >= v2. Result is an integer where each bit corresponds to condition being true for the vector lane.

You would normally assigned the result to _VMASK.

#### 4.6.2 GT(v1,v2)
Test for v1 > v2. Result is an integer where each bit corresponds to condition being true for the vector lane.

You would normally assigned the result to _VMASK.

#### 4.6.2 LE(v1,v2)
Test for v1 <= v2. Result is an integer where each bit corresponds to condition being true for the vector lane.

You would normally assigned the result to _VMASK.

#### 4.6.2 LT(v1,v2)
Test for v1 < v2. Result is an integer where each bit corresponds to condition being true for the vector lane.

You would normally assigned the result to _VMASK.

#### 4.6.2 EQ(v1,v2)
Test for v1 == v2. Result is an integer where each bit corresponds to condition being true for the vector lane.

You would normally assigned the result to _VMASK.

#### 4.6.2 NE(v1,v2)
Test for v1 != v2. Result is an integer where each bit corresponds to condition being true for the vector lane.

You would normally assigned the result to _VMASK.

## 5. Examples

[Example of a pcore program implementing convolution operator](https://github.com/ztachip/ztachip/blob/master/software/target/apps/nn/kernels/conv.p)

[Example of a pcore program implementing Canny edge detection](https://github.com/ztachip/ztachip/blob/master/software/target/apps/canny/kernels/canny.p)

[Example of a pcore program implementing image resize](https://github.com/ztachip/ztachip/blob/master/software/target/apps/resize/kernels/resize.p)



