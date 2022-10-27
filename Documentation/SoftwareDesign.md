# Domain Specific Language Architecture.

## Overview

Domain-Specific_Architecture (DSA) is a general trend in 
computing community to keep up with the future computing demand fueled by the 
exponential growth of AI.

With DSA, the first goal is to define a domain of applications where 
the DSA can be applied to efficiently compared to a more general purpose computing
architecture.

ztachip domain are applications that can be expressed as a sequential steps of tensor
operations. There are 2 primary types of tensor operations defined:

- Tensor data operations: Involving operations such as tensor data copy, 
tensor transpose, dimension resize, data remapping...

- Tensor operator operations: Performing computational tasks on a set of tensors.

But to be effective, DSA would require a Special-Domain-Language (DSL) to abstract away the
complexities of DSA. 

The goal for DSL is to provide a programming language that is:

- Easy to use and learn.

- Hide the complexity of hardware implementation from software users.

- Flexible enough to cover as wide range of applications as possible.

ztachip's DSL is composed of 2 elements: 

- tensor-core programs

- p-core programs

## tensor-core programs

Tensor-core programs are codes that run on RISCV

Tensor-core programs have suffix *.m

Tensor-core programs are C-program but with some special extentions. There is a compiler
provided with ztachip that converts these special extension to tensor instructions before
the program can then be compiled with standard RISCV C compiler.
With tensor-core programs, programmers express the problem as a sequence of high level 
tensor instructions. Computational tasks are presented as tensor operators that will be 
defined later by p-core programs.

Below is an example of what a tensor-core program would look like.

```
// vector_add.m
// Vector addition of 2 vectors 4096 words long

>DTYPE(INT16)PCORE[0:7].THREAD[0:15].example::x[0:3][0:7] <= DTYPE(INT16)MEM(x_p)[0:4095];
>DTYPE(INT16)PCORE[0:7].THREAD[0:15].example::y[0:3][0:7] <= DTYPE(INT16)MEM(y_p)[0:4095];
>EXE_LOCKSTEP(example:vector_add);
>DTYPE(INT16)MEM(z_p)[0:4095] <= DTYPE(INT16)PCORE[0:7].THREAD[0:15].example::z[0:3][0:7];

```
In example above, x,y and z are array of dimension 4x8 allocated in p-core private memory space. 

Since there are 8 pcores with 16 threads per pcore, x,y,z are tensors of dimension 8x16x4x8

Then tensor-program copies 4096 words from external memory to tensor x.

Similarly, it copies 4096 words from external memory to tensor y

Then it invokes a tensor operator example::vector_add to add x+y to produce tensor z

Finally, it copies result in tensor z to external memory.


## p-core programs

p-core program implements the tensor operators that are referenced by tensor-core programs.

p-core program are files with suffix *.p

Tensor operators are implemented as operations of a C++ object.

Due to limited memory, all tensor operator objects are singleton and overlapped in memory.

Users must partition these objects in such a way that they are not in use at the same time.

Below is an example for the tensor operator example::vector_add referenced by tensor-core
program shown in previous example.


```
// vector_add.p

vint16 example::x[4];
vint16 example::y[4];
vint16 example::z[4];

_kernel void examle::vector_add()
{
   int i;
   for(i=0;i < 3;i++)
      z[i]=x[i]+y[i];
}
```

# Compare ztachip DSL with traditional programming

With traditional programming, data and execution steps are interleaved.
With vector addition example above, traditional architecture requires each vector elements (or a small number of them 
for the case of vector extension) to be 
loaded first to memory one at a time and then followed by addition. But this would create a lot of 
memory round trip delay and stall cycles when data is not readily available in L1 cache.

But with ztachip, data are loaded from external memory into internal memory in a streaming fashion with 
prefetching and no round-trip delay. This results in huge gain in memory bandwidth
usage efficiencies.

Also in the example above, each vector element additions are carried out by
seperate threads and pcores, enable huge processing parallelism.

