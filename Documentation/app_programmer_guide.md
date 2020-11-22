# ztachip Application Programmer guide

## 1. Prerequisites
To proceed with this document. Please familiar yourself with the following documents. 

[ztachip Hardware Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareArchitecture.md)

[ztachip Software Architecture](https://github.com/ztachip/ztachip/blob/master/Documentation/SoftwareArchitecture.md)

[PCORE Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/pcore_programmer_guide.md)

[MCORE Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/mcore_programmer_guide.md)

## 2. Overview

This document specifies the ztachip API available for applications running on the host processor.

## 3. Low level API

This the first layer of software interface to ztachip hardware.

Higher level abstraction layer such as graph API is built ontop of this layer.

### 3.1 Initialization

#### 3.1.1 ZtaStatus ztahostInit(const char *ztachipFile,uint32_t regBaseAddr,uint32_t dmaBaseAddr,uint32_t dmaBaseSize) 

Initialize ztachip hardware.

This must be the first function to be called.

Parameters:

   - ztachipFile: MCORE and PCORE firmware image.

   - regBaseAddr: register base address of ztachip. Refer to [FPGA Build Procedure](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareBuildProcedure.md) on how register base address is chosen.

   - dmaBaseAddr: Buffers shared between applications and ztachip must be outside the memory region assigned to Linux and UBOOT. Refer to [Build Procedure](https://github.com/ztachip/ztachip/blob/master/Documentation/BuildProcedure.md) on how to allocate this DMA memory region.

   - dmaBaseSize: size of dmaBaseAddr above in bytes.

Return value:

   - ZtaStatusOk if sucessful.

   - ZtaStatusFailed if fail.

### 3.2 Buffer management 

API functions to allocate and free DMA buffers from dmaBaseAddr memory region specified in 3.1.1.

Buffers shared between applications and ztachip must be allocated via these functions.

#### 3.2.1 ZTA_SHARED_MEM ztahostAllocSharedMem(int _size) 

Allocates a DMA buffer

Parameters:

   - _size: buffer size in bytes

Return value:

   - Handle to DMA buffer.

#### 3.2.2 void ztahostFreeSharedMem(ZTA_SHARED_MEM shm)

Free a DMA buffer previous allocated by ztahostAllocSharedMem.

Parameters:

   - shm: Handle to DMA buffer to be freed.

#### 3.2.3 void *ZTA_SHARED_MEM_P(ZTA_SHARED_MEM shm)

Return virtual memory address associated with a DMA handle. Application would use this address to access the DMA buffer.

Parameters:

   - shm: DMA buffer handle

Return value:

   - Pointer to virtual memory address associated with this DMA buffer.

#### 3.2.4 int ZTA_SHARED_MEM_LEN(ZTA_SHARED_MEM shm)

Return size of the DMA buffer

Parameters:

   - shm: DMA buffer handle

Return value:

   - Size of DMA buffer in bytes.

#### 3.2.5 uint32_t *ZTA_SHARED_MEM_PHYSICAL(ZTA_SHARED_MEM shm)

Return physical memory addresss associated with the DMA buffer.

Parameters:

   - shm: DMA buffer handle

Return value:

   - Physical memory addresss associated with DMA buffer.

### 3.3 MCORE communication

Applications communicate with MCORE programs via a hardware-based message queue.

There are 2 message queues available, one for high priority messages and one for lower priority messages. Requests on high priority queue will go ahead of lower priority one. This is useful when applications have time sensitive acceleration tasks interleaved with non-critical acceleration tasks.

Sections below specify the API functions to send/receive messages to/from MCORE programs.

#### 3.3.1 void ztahostMsgqWriteInt(int queue,int32_t v)

Write 32-bit integer to the message queue.

Parameters:

   - queue: 0 for high priority queue, 1 for low priority queue.

   - v: Write a 32-bit integer value to message queue.

#### 3.3.2 void ztahostMsgqWritePointer(int queue,ZTA_SHARED_MEM p,uint32_t offset) 

Write a DMA buffer pointer to the message queue.

Parameters:

   - queue: 0 for high priority queue, 1 for low priority queue.

   - p: DMA buffer handle to be passed 

   - offset: additional offset to be added to the DMA address.

#### 3.3.3 int ztahostMsgqWriteAvail(int queue) 

Return number of free entries remaining in message queue.

Parameters:

   - queue: 0 for high priority queue, 1 for low priority queue.

#### 3.3.4 int32_t ztahostMsgReadInt() 

Read a 32-bit integer number from message queue.

#### 3.3.5 int ztahostMsgReadAvail() 

Return number of message queue entries available for read.

### 3.4 Stream processor programming 

ztachip has a stream processor which does input to output transformation.

The transformation is implemented as a lookup table with linear interpolation for input values in between.

The lookup+interpolation table is built by host application using function below

#### 3.4.1 ZTA_SHARED_MEM ztahostBuildSpu(float (*func)(float input,void *pparm,uint32_t parm),void *pparm,uint32_t parm,ZTA_SHARED_MEM _shm)

To build stream processor lookup+interpolation table.

Parameters:

   - func: callback function. This callback would return a value as result of input transformation. On the first call, the callback has pparm and parm set to pparm and parm specified by ztahostBuildSpu input parameters. At subsequent calls, pparm and parm are set to zero.

   - pparm: void pointer to be passed to callback function. This is for callback function internal reference.

   - parm: 32 bit integer to be passed to callback function. This is for callback function internal reference.

   - shm: DMA buffer handle to save the generated lookup+interpolation table.

Return Values:

   - Return DMA buffer handle where lookup+interpolation table is saved. This is the same as shm input paramter.

   - Return 0 if fail.

### 3.5 Export functions

To provide a handle that would execute a MCORE program function.

#### 3.5.1 uint32_t ztahostGetExportFunction(const char *funcName) 

In MCORE program, an exported function is defined like below... 

```
void do_convolution(int queue)
   :
   :
}

> EXPORT(do_convolution);
```

And the 32-bit value returned by ztahostGetExportFunction is the handle to be passed to MCORE to identify the remote function call.










