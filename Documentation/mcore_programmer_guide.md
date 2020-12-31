# MCORE Programmer guide

## 1. Prerequisites
To proceed with this document. Please familiar yourself with the software and hardware architecture of ztachip

[ztachip Hardware Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareArchitecture.md)

[ztachip Software Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/SoftwareArchitecture.md)

## 2. Overview

MCORE programs are codes that are executed on MCORE processor. 

The program emits tensor instructions to the Tensor Engine. Tensor instructions perform functions such as tensor data movement,resize,reshape and tensor operator dispatching.

MCORE programs are C programs with embedded tensor syntax extensions. Tensor extensions are lines that begin with '>'.

There can be up to 2 threads running in the MCORE processor. The 2 threads are useful in interleaving memory operation cycle from one thread to tensor operator execution cycle from the other thread. This greatly reduces memory access delay.

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

   SRATCH(p,dy,dx)[y:dy-1][x:dx-1]
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

PCORE(dy,dx)[0:dy-1][0:dx-1].thread[0:15].class::private_variable[:]

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

PCORE(4,2)[0:dy-1][0:dx-1].class::shared_variable[:]

```

## 4. Tensor data memory transfer instructions

MCORE program emits these instructions to TensorEngine.

They are inserted to MCORE C-programs with special syntax line begins with '>'

These instructions move data from one memory space to another.

In addition to memory transfer, it can also perform tensor reshape,dimension resize,stream processing...

### 4.1 Basic tensor data transfer from DDR to PCORE private memory space

```
>PCORE[0:1].THREAD[0:1].myclass::myfunc.var[0:1] <= DDR(p)[0:2*2*2-1];
```

Example above transfers data from DDR tensor data object to PCORE tensor data object resided in PCORE private memory space.

The result of the transfer is listed below
```
PCORE   THREAD  private_var      <=  DDR
-----------------------------------------
0       0       private_var[0]       p[0]
0       0       private_var[1]       p[1]
0       1       private_var[0]       p[2]
0       1       private_var[1]       p[3]
1       0       private_var[0]       p[4]
1       0       private_var[1]       p[5]
1       1       private_var[0]       p[6]
1       1       private_var[1]       p[7]
```
### 4.2 Basic tensor data transfer from DDR to PCORE shared memory space.

```
>PCORE[0:1].myclass::myfunc.shared_var[0:1] <= DDR(p)[0:2*2-1];
```

Example above transfers data from DDR tensor data object to PCORE tensor data object resided in PCORE shared memory space. 

The result of the transfer is listed below
```
PCORE   shared_var    <=   DDR
-------------------------------
0       shared_var[0]      p[0]
0       shared_var[1]      p[1]
1       shared_var[0]      p[2]
1       shared_var[1]      p[3]
```
### 4.3 Basic tensor data transfer from DDR to SCRATCH-PAD memory space.

```
int len=4;
>SCRATCH(0,100)[0:len-1] <= DDR(p,100)[0:len-1];
```

Example above transfers data from DDR tensor data object to scratch-pad tensor data object.

SCRATCH-PAD tensor is a 1 dimensional tensor of dimension 100.

DDR tensor is a 1 dimensional tensor of dimention 100

The result of the transfer is listed below
```
SCRATCH-PAD      DDR
------------------------
SCRATCH[0]  <=   p[0]
SCRATCH[1]  <=   p[1]
SCRATCH[2]  <=   p[2]
SCRATCH[3]  <=   p[3]
```
### 4.4 Basic tensor data transfer from DDR to SCRATCH-PAD memory space.

```
int dx=2;
int dy=4;
>SCRATCH(0,100,200)[0:dy-1][0:dx-1] <= DDR(p,1000,2000)[0:dy-1][0:dx-1];
```

Example above transfers data from DDR tensor data object to scratch-pad tensor data object.

DDR tensor is a 2 dimensional tensor of dimension 1000x2000

Scratch-pad tensor is a 2 dimensional tensor of dimension 100x200

The result of the transfer is listed below
```
SCRATCH-PAD      DDR
------------------------
SCRATCH[0][0] <= p[0][0]
SCRATCH[0][1] <= p[0][1]
SCRATCH[1][0] <= p[1][0]
SCRATCH[1][1] <= p[1][1]
SCRATCH[2][0] <= p[2][0]
SCRATCH[2][1] <= p[2][1]
SCRATCH[3][0] <= p[3][0]
SCRATCH[3][1] <= p[3][1]
```

### 4.5 Tensor reshape

```
>PCORE[0].THREAD[0:2].myclass::myfunc.var[0:3] <= DDR(p,100,2,2)[0][0:2][0:3];
```

Example above transfers data from DDR tensor data object as tensor of dimension 8x16x8 eventhough actual tensor dimension is 100x200x8.

Tensor data associated with out-of-bound dimension index are padded with zero for read operation and skipped for write operation.

The result of the transfer is listed below
```
PCORE   THREAD    var   <=   DDR
---------------------------------------------------------------------------
0          0        0        p[0][0][0]
0          0        1        p[0][0][1]
0          0        2        p[0][0][2] <- (Out of bound-Replace with zero)
0          0        3        p[0][0][3] <- (Out of bound-Replace with zero)
0          1        0        p[0][1][0]
0          1        1        p[0][1][1]
0          1        2        p[0][1][2] <- (Out of bound-Replace with zero)
0          1        3        p[0][1][3] <- (Out of bound-Replace with zero)
0          2        0        p[0][2][0] <- (Out of bound-Replace with zero)
0          2        1        p[0][2][1] <- (Out of bound-Replace with zero)
0          2        2        p[0][2][2] <- (Out of bound-Replace with zero)
0          2        3        p[0][2][3] <- (Out of bound-Replace with zero)
```

### 4.6 Tensor dimenstion casting

You can cast the dimension of the components of PCORE tensor to different dimension.

Example:

```
>PCORE(8)[:].THREAD[0:15].myclass::myvar[0:15] <= DDR(p)[0:8*16*16-1];
```
recast THREAD dimension from 16 to 4x4. And recast myvar dimension from 16 to 4x4
```
>PCORE(8)[:].THREAD(4,4)[0:3][0:3].myclass::myvar(4,4)[0:3][0:3] <= DDR(p)[0:8*16*16-1];
```

### 4.7 Tensor data reordering

The way data are read/written to tensors is like a nested FOR loop.

The order starts with index from right to left.

However, the order can be changed by using FOR directive below. The order starts with index without FOR loop from right to left and then the order continues 
with index associated with FOR directive going from right to left. 

For example:

```
>FOR(K=0:3) FOR(I=0:1) PCORE[0:2].THREAD[I].myclass::myvar[K] <= DDR(p)[0:2*3*4-1];
```

The result of the transfer above is listed below

```
myvar     THREAD        PCORE       <=  DDR
-------------------------------------------- 
  0          0            0             p[0]
  0          0            1             p[1]
  0          0            2             p[2]
  0          1            0             p[3]
  0          1            1             p[4]
  0          1            2             p[5]
  1          0            0             p[6]
  1          0            1             p[7]
  1          0            2             p[8]
  1          1            0             p[9]
  1          1            1             p[10]
  1          1            2             p[11]
  2          0            0             p[12]
  2          0            1             p[13]
  2          0            2             p[14]
  2          1            0             p[15]
  2          1            1             p[16]
  2          1            2             p[17]
  3          0            0             p[18]
  3          0            1             p[19]
  3          0            2             p[20]
  3          1            0             p[21]
  3          1            1             p[22]
  3          1            2             p[23]
```

### 4.8 Tensor scatter transfer

#### 4.8.1 Tensor scatter transfer by vector word.

```
>FOR(I=0:7) PCORE(8)[0:7].THREAD[0:15].myclass::myvar(8,8)[:][I] <= DDR(p)[0:8*16*8*8-1];
```

In example above, transfer of innermost loop is scattered among consecutive vector words.

This is not efficient since the transfer is not a vector transfer. And the innerloop takes 8 clocks to complete.

By adding SCATTER(0) directive, the transfer is rearranged and interleaved among all the PCOREs so that each PCORE will have 8 clocks to complete the innerloop transfer to myvar. 

Since transfers are interleaved among the PCORES, there is no wait state. This way transfer can still occur in vector mode at rate of 1 vector per clock.

```
>SCATTER(0) FOR(I=0:7) PCORE(8)[0:7].THREAD[0:15].myclass::myvar(8,8)[:][I] <= DDR(p)[0:8*16*8*8-1];
```

#### 4.8.2 Tensor scatter transfer by thread.

```
>FOR(I=0:7) FOR(J=0:7) PCORE(8)[0:7].THREAD(2,8)[:][:].myclass::myvar[J] <= DDR(p)[0:8*16*8*8-1];
```

In example above, transfer of innermost loop is scattered among different threads.

This is not efficient since the transfer is not a vector transfer. And the innerloop takes 8 clocks to complete.

By adding SCATTER(0) directive, the transfer is rearranged and interleaved among all the PCOREs so that each PCORE will have 8 clocks to complete the innerloop transfer.

Since transfers are interleaved among the PCORES, there is no wait state. This way transfer can still occur in vector mode at rate of 1 vector per clock.


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

## 7. CALLBACK

MCORE instructions to TensorEngine are queued for processing.

CALLBACK construct is used to trigger a function callback whenever MCORE executions have reached a check point.

This is normally used to send back responses to host applications at completion of TensorEngine executions.

### 7.1 Syntax
```
>CALLBACK(callback_function,int parm);
```
Where:

   - callback_function: function to be called whenever TensorEngine execution has reached this point.

   - parm: integer to be passed to callback_function.

## 8. Host communication API

MCORE is communicating with host applications via message queues.

Functions below are API to read/write to/from the message queue.

### 8.1 ztamMsgqReadPointer
Read a DDR memory pointer passed from host applications.

### 8.2 ztamMsgqReadInt
Read a 32-bit interger value passed from host applications.

### 8.3 ztamMsgqWritePointer
Send a DDR memory pointer to host applications.

### 8.4 ztamMsgqWriteInt
Send a 32-bit integer value to host applications.

## 9. Thread management API

MCORE can have 2 processing threads: a main thread and a child thread.

Thread switching is not automatic but manual by calling to ztamTaskYield function below.

Normally, each thread will manage a seperate PCORE process space. This way you can interleave between memory cycle and execution cycle of the 2 PCORE processes. This is done to reduce/eliminate DDR memory access from delaying PCORE execution.

### 9.1 ztamTaskSpawn(void (*func)(void*,int),void *parm,int pid)

To spawn a child thread

Where:

   - func: task entry point function

   - parm: pointer to be passed to task entry point function.

   - pid: 0 for main thread,1 for child thread. 

### 9.2 ztamTaskStatus(int pid)

To check if task has been terminated.

Where:

   - pid: 0 for main main thread, 1 for child thread

### 9.3 ztamTaskYield() 

Yield execution to the other thread.




