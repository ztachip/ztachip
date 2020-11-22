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

   - class: class name that variable associated with as defined in associated PCORE programs.

   - variable: class variable holding tensor data elements as defined in associated PCORE programs.
   
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

   - class: class name that variable associated with as defined in associated PCORE program.

   - variable: class variable holding tensor data elements as defined in associated PCORE program.
    
Example
```
PCORE(8)[0:7].class::shared_variable[:]

PCORE(4,2)[0:3][0:1].class::shared_variable[:]

```

## 4. Tensor data memory transfer instructions

MCORE program emits these instructions to TensorEngine.

They are inserted to MCORE C-programs with special syntax line begins with '>'

These instructions move data from one memory space to another.

In addition to memory transfer, it can also perform tensor reshape,dimension resize,stream processing...

### 4.1 Basic tensor data transfer 

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

### 4.2 Tensor reshape

Example below transfers data from DDR tensor data object as tensor of dimension 8x16x8 eventhough actual tensor dimension is 100x200x8.

Tensor data associated with out-of-bound dimension index are padded with zero for read operation and skipped for write operation.
```
>PCORE(8)[0:7].THREAD[0:15].myclass::myfunc.var[0:7] <= DDR(p,100,200,8)[0:7][0:15][0:7];
```

### 4.3 Tensor dimenstion casting

You can cast the dimension of some components of PCORE tensor to different dimension.

Example:

```
>PCORE(8)[:].THREAD[0:15].myclass::myvar[0:15] <= DDR(p)[0:8*16*16-1];
```
recast THREAD dimension from 16 to 4x4. And recast myvar dimension from 16 to 4x4
```
>PCORE(8)[:].THREAD(4,4)[0:3][0:3].myclass::myvar(4,4)[0:3][0:3] <= DDR(p)[0:8*16*16-1];
```

### 4.4 Tensor data reordering

The way data are read/written to tensors is like a nested FOR loop.

And the dimension on the right is the inner loop.

And the dimension of the left is the outer loop.

However, the order can be changed by using FOR directive below 

```
>FOR(I=0:15) FOR(J=0:7) FOR(K=0:15) PCORE(8)[J].THREAD[I].myclass::myvar[K] <= DDR(p)[0:8*16*16-1];
```
In example above, the order in which data are written to PCORE are nested in this order: THREAD,PCORE,myvar with THREAD is the outer loop index and myvar is the inner loop index.

### 4.5 Tensor scatter transfer

In example below, transfer of innermost loop is scattered among consecutive vector words.

This is not efficient since the transfer is not a vector transfer. And the innerloop takes 8 clocks to complete.

```
>FOR(I=0:7) PCORE(8)[0:7].THREAD[0:15].myclass::myvar(8,8)[:][I] <= DDR(p)[0:8*16*8*8-1];
```

By adding SCATTER(0) directive, the transfer is interleaved among all the PCOREs so that each PCORE will have 8 clocks to complete the innerloop transfer to myvar. Since transfers are interleaved among the PCORES, there is no wait state. This way transfer can still occur in vector mode at rate of 1 vector per clock.

```
>SCATTER(0) FOR(I=0:7) PCORE(8)[0:7].THREAD[0:15].myclass::myvar(8,8)[:][I] <= DDR(p)[0:8*16*8*8-1];
```

Below is another scatter transfer where THREAD block index is the innermost loop. Transfer of innermost loop is scattered among different threads.

```
>SCATTER(0) FOR(I=0:7) FOR(J=0:7) PCORE(8)[0:7].THREAD(2,8)[:][:].myclass::myvar[J] <= DDR(p)[0:8*16*8*8-1];
```

## 5. Tensor operator execution

Tensor operators are functions defined in PCORE programs.

These functions operate on tensors allocated within PCORE memory space.

Input and results associated with tensor operators are then transfered to/from PCORE memory space to/from external DDR or sratch-pad memory space by TensorEngine under the instructions of MCORE program.

### 5.1 Syntax

Invoking a tensor operator from MCORE has the following syntax

Example below invokes a tensor operator exe of class convolution defined in corresponding PCORE program

```
> EXE_LOCKSTEP(convolution::exe); 
```

Example below invokes the tensor operator but the execution is limited only to np number of PCORES.

```
> EXE_LOCKSTEP(convolution::exe,np); 
```

Example below invokes tensor operator but the execution is limited only to np number of PCORES and nt number of threads per PCORE.

```
> EXE_LOCKSTEP(convolution::exe,np,nt); 
```

Example below invokes tensor operator in 2 steps. First a function pointer is assigned and then tensor operator is invoked via this function pointer.

```
func=ztamBuildKernelFunc(convolution::exe,np,nt); // Assign function pointer
> EXE_LOCKSTEP(func);
```


## 6 Stream processing

Transfer to/from PCORE memory space can be streamed through a stream processor for processing.

Stream processor performs lookup/interpolation translation from input values to output values. 

The stream processor lookup/interpolation table is constructed by host as described in [Application Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/app_programmer_guide.md)

There can be 4 stream programs loaded at same time.

Example:
```
> SPU <= (int)MEM(stream,SPU_LOOKUP_SIZE*2)[:];

> PCORE(NP)[0:NP-1].THREAD[0:NT-1].convolution.input[0:7] <= PROC(0) <= DDR(pin)[0:NP*NT*8-1];

> DDR(pout)[0:NP*NT*8-1] <= PROC(1) <= PCORE(NP)[0:NP-1].THREAD[0:NT-1].convolution.output[0:7];
```

Example above loads 2 stream programs from DDR memory. The stream programs are lookup/interpolation tables between input and output values.

In the example, as data being transfered from DDR to PCORE, data is also being processed by stream processor's program #0

And as data being transfered from PCORE to DDR, data is also being processed by stream processor's program #1




