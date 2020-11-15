# MCORE Programmer guide

## 1. Prerequisites
To proceed with this document. Please familiar yourself with the software and hardware architecture of ztachip

[ztachip Hardware Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareArchitecture.md)

[ztachip Software Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/SoftwareArchitecture.md)

## 2. Overview

MCORE programs are codes that are executed on MCORE processor. 

The program emits tensor instructions to the Tensor Engine. Tensor instructions perform functions such as tensor data movement,resize,reshape and tensor operator dispatching.

MCORE programs are C programs with embedded tensor syntax extensions. Tensor extensions are lines that begin with '>'.

There can be up to 2 threads running in the MCORE processor. The 2 threads are usful in interleaving memory operation cycle from one thread to tensor operator execution cycle from the other thread. This greatly reduces memory access delay.

## 3. Tensor data objects 
Tensor data objects are objects defined in MCORE programs.

They can be viewed as data variables in MCORE programming paradigm.

Tensor objects can be allocated within PCORE, Scratch-pad and DDR memory space.

Tensors can be resided in PCORE private memory space, PCORE shared memory space, scratch-pad memory space or external DDR memory space.
PCORE memory space is further partitioned into 2 independent process space. This allows for memory operation from TensorEngine to be carried out while tensor operator execution from PCORE arrays can still access memory from the other process space.

### 3.1 Tensor data objects in DDR memory space
External DDR tensor has the syntax below. It specifies a tensor as a subset of another tensor by specifying a dimension index range.
```
   DDR(pointer,dimension,dimension,...)[begin:stride:end][begin:stride:end]...
```
Where:

   - pointer: memory address where TENSOR is stored in DDR memory

   - dimension: TENSOR dimensions

   - begin: starting index of dimension range.

   - stride: stride of the dimension range.

   - end:  ending index of dimension range.


Example:

```
   DDR(p,100,200)[0:1:19][20:1:29]
```
If stride of index range is ignored, then 1 is assumed
```
   DDR(p,100,200)[0:19][20:29]
```
If begin of index range is ignored, then 0 is assumed
```
   DDR(p,100,200)[:19][:29]
```
If end of index range is ignored, then end of dimension range is assumed.
```
   DDR(p,100,200)[0:][20:]
```

### 3.2 Tensor data objects in scratch-pad memory space 
Tensor that is allocated in scratch-pad memory space.

It has similar syntax to DDR tensor syntax except the keyword is SCRATCH

Example:
```
   SRATCH(p,100,200)[0:19][20:29]
```

### 3.3 Tensor data objects in PCORE private memory space

Each PCORE threads have its own private memory space.
PCORE private memory space is further partitioned into 2 independent process space. This allows for memory operation from TensorEngine to be carried out while tensor operator execution from PCORE arrays can still access memory from the other process space.

Tensors that are allocated in PCORE private memory space have the following syntax

```
PCORE(dimension,...)[begin:stride:end][begin:stride:end].thread[begin:stride:end].class::variable
```

Where:

   - dimension: PCORE array can be laid out as an 1D array or 2D array.

   - begin: starting index of dimension range.

   - stride: stride of the dimension range.

   - end: ending index of dimension range.

   - class: class name that variable associated with

   - variable: class variable holding tensor data elements
   
Example
```
PCORE(8)[0:7].thread[0:15].class::private_variable[:]

PCORE(4,2)[0:3][0:1].thread[0:15].class::private_variable[:]

```

### 3.4 Tensor data objects in PCORE shared memory space

PCORE threads in the same PCORE share the same shared memory space. Data allocated in the shared memory can be accessed by any threads in the same PCORE.
PCORE shared memory space is further partitioned into 2 independent process space. This allows for memory operation from TensorEngine to be carried out while tensor operator execution from PCORE arrays can still access memory from the other process space.

Tensors that are allocated in PCORE shared memory space have the following syntax

```
PCORE(dimension,...)[begin:stride:end][begin:stride:end].class::variable
```

Where:

   - dimension: PCORE array can be laid out as an 1D array or 2D array.

   - begin: starting index of dimension range.

   - stride: stride of the dimension range.

   - end: ending index of dimension range.

   - class: class name that variable associated with

   - variable: class variable holding tensor data elements
    
Example
```
PCORE(8)[0:7].class::shared_variable[:]

PCORE(4,2)[0:3][0:1].class::shared_variable[:]

```

## 4. Tensor data memory transfer instructions

MCORE program emits these instructions to TensorEngine.

They are inserted to MCORE C-programs with special syntax line begins with '>'

These instructions move data from one memory space/location to another.

In addition to memory transfer, it can also perform tensor reshape,dimension resize,stream processing...

### 4.1 Basic tensor data tramsfer 

Example below transfers data from DDR tensor data object to PCORE tensor data object resided in PCORE private memory space. 
In this example, there are 8 PCOREs (NP) with 16 threads (NT) in each PCORE. And each thread holds a variable var of dimension 8 in the PCORE private memory space.

```
>PCORE(NP)[0:NP-1].THREAD[0:NT-1].myclass::myfunc.var[0:7] <= DDR(p)[0:NP*NT*8-1];
```

Example below transfers data from DDR tensor data object to PCORE tensor data object resided in PCORE shared memory space. 
In this example, there are 8 PCOREs (NP). And each PCORE holds a variable var of dimension 8 in PCORE shared memory space.

```
>PCORE(NP)[0:NP-1].myclass::myfunc.var[0:7] <= DDR(p)[0:NP*NT*8-1];
```

Example below transfers data from DDR tensor data object to scratch-pad tensor data object.

DDR and scratch-pad tensors below are 1 dimensional tensor of dimension 100

```
>SCRATCH(0,100)[0:len-1] <= DDR(p,100)[0:len-1];
```
Example below transfers data from DDR tensor data object to scratch-pad tensor data object.

DDR tensor is a 2 dimensional tensor of dimension 1000x2000

Scratch-pad tensor is a 2 dimensional tensor of dimension 100x200
```
>SCRATCH(0,100,200)[0:dy-1][0:dx-1] <= DDR(p,1000,2000)[0:dy-1][0:dx-1];
```




