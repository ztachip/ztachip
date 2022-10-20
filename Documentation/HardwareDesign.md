# Hardware architecture

## ztachip (top)

![hw_ztachip](images/hw_ztachip.png)

### Interfaces:

- axilite_* : AXILite bus for RISCV to push tensor instructions to ztachip

- axi_* : AXI bus for ztachip to initiate DMA memory transfer to/from external memory

### Subcomponents:

- [axilite](../HW/src/top/axilite.vhd): bridge to connect dp_core with RISCV via axiLite bus protocol.

- [sram_core](../HW/src/top/sram_core.vhd): scratch memory block to hold temporary
data is sometimes required during tensor data transfer

- [ddr_rx](../HW/src/top/ddr_rx.vhd): Handling DMA transfer from external DDR memory to
core's internal memory.

- [ddr_tx](../HW/src/top/ddr_tx.vhd): Handling DMA transfer from core's internal memory to
external DDR memory

- [core](../HW/src/pcore/core.vhd): This is the tensor arithmetic execution unit which is composed of
an array of lightweight VLIW processors.

- [dp_core](../HW/src/dp/dp_core.vhd): This is the central tensor processor unit that coordinates
all activities within ztachip including memory transfer and launching execution on
the VLIW processor array.

### Functions:

This is the top-level component of ztachip.

The central tensor processor unit is [dp_core](../HW/src/dp/dp_core.vhd)

[dp_core](../HW/src/dp/dp_core.vhd) receives tensor instructions from RISCV via axilite_* interface.

[dp_core](../HW/src/dp/dp_core.vhd) then executes the tensor instructions by performing the following:

- Coordinating tensor data operations which transfer tensor data between [sram_core](../HW/src/top/sram_core.vhd),
[core](../HW/src/pcore/core.vhd)'s internal memory and
external DDR memory. Tensor data operations may also include other complex functions such as
transpose, dimension resize, data-remap...

- Dispatching tensor operator execution requests to [core](../HW/src/pcore/core.vhd) which then in turn dispatch the execution to an array of VLIW processors. 

## ztachip.dp_core

![hw_dp_core](images/hw_dp_core.png)

### Interfaces:

bus_* : bus for [dp_core](../HW/src/dp/dp_core.vhd) to receive tensor instructions from RISCV.

task_*: bus to send tensor operator execution instructions to [core](../HW/src/pcore/core.vhd)

readmaster1* : bus to receive DMA data transfer from [core](../HW/src/pcore/core.vhd)'s internal memory.

readmaster2* : bus to receive DMA data transfer from [sram_core](../HW/src/top/sram_core.vhd)'s scratch-pad memory

readmaster3* : bus to receive DMA data transfer from external DDR memory through [ddr_rx](../HW/src/top/ddr_rx.vhd)

writemaster1* : bus to send DMA data transfer to [core](../HW/src/pcore/core.vhd)'s internal memory.

writemaster2* : bus to send DMA data transfer to [sram_core](../HW/src/top/sram_core.vhd)'s scratch-pad memory.

writemaster3* : bus to send DMA data transfer to external DDR memory through [ddr_tx](../HW/src/top/ddr_tx.vhd)

### Subcomponents

- [dp_fetch](../HW/src/dp/dp_fetch.vhd): This component receives tensor instructions from RISCV and then
dispatch them at the right time. Tensor data operations are dispatched to [dp_gen_core](../HW/src/dp/dp_gen_core.vhd). Tensor operator execution is dispatched to [core](../HW/src/pcore/core.vhd) via task* interface signals.
    
- [dp_gen_core](../HW/src/dp/dp_gen_core.vhd): This component receives tensor data operation instructions from [dp_fetch](../HW/src/dp/dp_fetch.vhd). It then generates the memory addresses for the transfer. There can be 2 tensor data operations executing at the same time with each assigned to one of the two [dp_gen](../HW/src/dp/dp_gen.vhd) subcomponents.

- [dp_source](../HW/src/dp/dp_source.vhd): This component is responsible for generating the DMA transfer read requests to the source of the tensor data operations. It then forwards the received data to the appropriate 
[dp_sink](../HW/src/dp/dp_sink.vhd) components which are then responsible for the DMA transfer of the received data to the destination point.

- [dp_sink](../HW/src/dp/dp_sink.vhd): This component is responsible for generating DMA transfer write request to the destination point of the tensor data operations. It receives the data and addresses information for the transfer from
the appropriate [dp_source](../HW/src/dp/dp_source.vhd) above.

### Functions

This component is the main tensor processor of ztachip. It performs the following functions:

- Receives tensor instructions from RISCV. Each tensor instruction are associated with a hardware thread.
There are 2 hardware threads available. Hardware threads are useful to provide the ability to overlay
the tensor operator execution phase of one thread with the data transfer phase of the other threads.

- Decodes the tensor instructions. 

- Instructions may be executed out-of-order but applications can enforce the order. 

- Data operations are then processed by [dp_gen_core](../HW/src/dp/dp_gen_core.vhd),
[dp_source](../HW/src/dp/dp_source.vhd) and 
[dp_sink](../HW/src/dp/dp_sink.vhd). 
There can be up to 2 data operations executing at the same time. For example, data transfer from the 
[core](../HW/src/pcore/core.vhd)'s internal memory
to DDR external memory can occur at the same time as data transfer from the scratch-pad to 
[core](../HW/src/pcore/core.vhd)'s internal memory.

- Tensor operator execution is forwarded to [core](../HW/src/pcore/core.vhd) via interface signal task*

- Before tensor operator execution can be issued, all memory transfer with [core](../HW/src/pcore/core.vhd)'s internal memory must be completed. Since there is a seperate [core](../HW/src/pcore/core.vhd)'s internal memory for each hardware thread, for example, memory transfer to [core](../HW/src/pcore/core.vhd)'s internal memory belonging to thread#1 can still be running at the same time while [core](../HW/src/pcore/core.vhd) is busy performing tensor operator execution but on thread#2.

## ztachip.core

![hw_core](images/hw_core.png)

### Interfaces:

- dp_write*: bus to receive DMA data transfer to its internal memory

- dp_read*: bus to send DMA data transfer from its internal memory

- task* : bus to receive tensor operator execution commands from [dp_core](../HW/src/dp/dp_core.vhd)

### Subcomponents:

- [stream](../HW/src/pcore/stream.vhd): this is a stream processor that performs data mapping between input and output.  
One stream processor is used to perform data mapping before data is written to core's internal memory
And a second stream processor performs data mapping on data as it is just retrieved from core's internal memory.

- [cell](../HW/src/top/cell.vhd): 4 pcore are grouped in a cell. The purpose is to improve the fan-out performance of bus signals.

- [cell.pcore](../HW/src/pcore/pcore.vhd): Implements the VLIW processor array. All tensor operator execution are performed by many ot these pcores.

- [instr](../HW/src/pcore/instr.vhd): This is the master processor for all pcore's VLIW processor cores that are just simply ALUs running in locked step mode with each other.

- [instr.instr_fetch](../HW/src/pcore/instr_fetch.vhd): This component performs thread scheduling of execution. pcore
are multi-threaded processors with 16 hardware threads executing in a round-robin fashion. 
VLIW instructions are complex and require a very deep pipeline, hardware multi-threading is a commonly used technique to hide
the impact of instruction latency. Performance of 1 VLIW instruction per clock per pcore can then be achieved.

- [instr.rom](../HW/src/pcore/rom.vhd): Holding VLIW instruction code. All VLIW cores are sharing the same instruction code. Since VLIW processors are all running in lock-step, only 1 instruction is fetched for all the VLIW processors at every clock.

### Functions:

- This component is responsible for all tensor operator execution tasks.

- It is composed of an array of [pcores](../HW/src/pcore/pcore.vhd). And each pcore is a VLIW vector processor.

- Requests for tensor operator execution are coming from [dp_core](../HW/src/dp/dp_core.vhd) via task* interface signal.

- The component [instr](../HW/src/pcore/instr.vhd) is controlling the execution of all pcore's VLIW processors.
VLIW processors are very lightweight processors that are mostly just ALU with memory running in lock-step mode with each other.  

## ztachip.core.stream

![hw_stream](images/hw_stream.png)

This module provides an arbitrary data mapping between input value and output.

[stream](../HW/src/pcore/pcore.vhd) performs data mapping on data just before it is written to pcore's memory space.

[stream](../HW/src/pcore/pcore.vhd) also performs data mapping on data just after it is read from pcore's memory space.

The data mapping is realized using the formula below

```
y = lookup_quotient[x[11:5]] + x[4:0]* lookup_remainder[x[4:0]] 
```

Effectively, the formula above provides a multi-point linear-interpolation between
input and output.

stream provides up to 4 different data-mapping functions at the same time. The 
parameter stream_id_in selects which data mapping to be performed.

stream is very commonly used in AI applications to perform activation functions as
data being written back to memory. 


## ztachip.core.pcore

![hw_pcore](images/hw_pcore.png) 

### Interfaces:

- dp_read* : bus to send DMA data transfer from pcore's internal memory

- dp_write*: bus to send DMA data transfer to pcore's internal memory

- instruction*: bus to receive VLIW instructions to be executed.

### Subcomponents:

- [alu](../HW/src/alu/alu.vhd) : This is the unit that performs the bulk of arithmetic
vector calculation. There are 8 ALUs for each of the 8 elements in a vector word.

- [xregister_file](../HW/src/pcore/xregister_file.vhd) : Register banks holding int32 accumulators used by FMA operations.

- [register_bank](../HW/src/pcore/register_bank.vhd): Holding internal memory. All computations are operated directly
from this internal memory without intermediate register load/store operations like more traditional processor
design.

- [register_bank.register_file](../HW/src/pcore/register_file.vhd): There are 2 pages of internal memory with each
page associated with one of the two tensor processor's hardware threads. The two register_file implement the
two internal memory pages.

- [instr_decoder2](../HW/src/pcore/instr_decoder2.vhd): Main decoder for VLIW instructions.

- [instr_dispatch2](../HW/src/pcore/instr_dispatch2.vhd): Component that interfaces between 
[instr_decoder2](../HW/src/pcore/instr_decoder2.vhd) and bank of
[alu](../HW/src/alu/alu.vhd). It forwards execution instructions from instr_decoder2 to [alu](../HW/src/alu/alu.vhd). 
It is also responsible for moving data from [register_bank](../HW/src/pcore/register_bank.vhd)
to [alu](../HW/src/alu/alu.vhd). It is responsible for saving results from [alu](../HW/src/alu/alu.vhd) back to [register_bank](../HW/src/pcore/register_bank.vhd).

- [ialu](../HW/src/ialu/ialu.vhd): VLIW may also contain integer arithmetic operation for tasks such as loop counter, 
array indexing calculation, address calculation. This component is responsible for such calculation.

- [iregister_file](../HW/src/ialu/iregister_file.vhd): Register banks holding integer values used by ialu.

### Functions

This component performs tensor operator execution.

There are many instances of pcore running in parallel.

pcore has a VLIW architecture. 

pcore execution is multi-threaded. There are 16 hardware threads of execution running
in round-robin fashion.

The VLIW instruction is very wide that contains many sub-functions
that perform the following tasks simultaneously within a single VLIW instruction.

- Address calculation for 2 input parameters and 1 output parameter.

- Fetching input parameter vectors from [register_bank](../HW/src/pcore/register_bank.vhd).

- Fetching 32-bit accumulator from [xregister_file](../HW/src/pcore/xregister_file.vhd). These accumulator values are then used by alu performing FMA (Fused-multiply-add) operations.

- Performing integer calculations on [ialu](../HW/src/ialu/ialu.vhd).

- Perform vector calculation on the bank of [alu](../HW/src/alu/alu.vhd).

- [alu](../HW/src/alu/alu.vhd) may produce results as 32-bit accumulator, save these values to [xregister_file](../HW/src/pcore/xregister_file.vhd).

- [alu](../HW/src/alu/alu.vhd) may produce results as 12-bit word vector. Save these results back to 
[register_bank](../HW/src/pcore/register_bank.vhd). 

Since all the functions above are simultaneously performed in one single VLIW instruction, the
instruction pipeline is as long as 14 clocks. However, with hardware multi-threading execution, each
stage of the execution pipeline is occupied by different threads. Therefore we have an effective
execution rate of one VLIW instruction per clock per pcore.

For example, the code below is compiled into one single VLIW instruction. All data operations and
arithmetic calculation together take just one clock of execution and also without any memory stall cycles. 
This same code using traditional RISCV instructions would take up to 10 RISCV instructions that may also incur memory stall cycles in addition.

`z[i++] = x[i+2]+y[i+3];`

### pcore's internal memory

pcore's internal memory is partitioned into 2 pages with each page assigned to one of the two
tensor processor's threads. This is an important concept for ztachip since it allows
for one thread to access its internal memory while the other thread is performing 
tensor operator execution using the other internal memory's page. This allows for
a memory operation to be overlapped with tensor operator execution.

It is important to note that tensor operator execution operates only on internal memory without any reference to external memory.
This is an important concept since with ztachip, data operations are decoupled
from execution operations by having separate tensor instructions for data operations and execution operations.
Reference [here](Overview.md) for further explanation of this concept.

Internal memory holds 2 types of data

- Private data: Data is private to each of the 16 threads. Private memory words are interleaved between different threads as shown in the picture below.

- Shared data: Data is shared among all 16 threads but within the same pcore. Shared memory words are allocated from the bottom up as shown in the picture below.

```
+-------------------------+
+ Thread1.Private word#0  |
+-------------------------+ 
+ Thread2.Private word#0  |
+-------------------------+ 
           :
           :
+-------------------------+ 
+ Thread16.Private word#0 |
+-------------------------+ 
+ Thread1.Private word#1  |
+-------------------------+ 
+ Thread2.Private word#1  |
+-------------------------+ 
           :
           :
+-------------------------+ 
+ Thread16.Private word#1 |
+-------------------------+ 
           :
           :
+-------------------------+ 
+ Shared           word#3 |
+-------------------------+ 
+ Shared           word#2 |
+-------------------------+ 
+ Shared           word#1 |
+-------------------------+ 
+ Shared           word#0 |
+-------------------------+ 
```

## ztachip.core.pcore.alu

![hw_alu](images/hw_alu.png) 

### Interfaces

x1_in: This is a 12 bit input value. This parameter is fetched from
pcore internal memory stored in [register_file](../HW/src/pcore/register_file.vhd).

x2_in: This is 12 bit input value. This parameter is fetched from
pcore internal memory stored in [register_file](../HW/src/pcore/register_file.vhd)

xreg_in: 32-bit accumulator input. This is fetched from [xregister_file](../HW/src/pcore/xregister_file.vhd).

xscalar_in: constant used to specify the distance for shifting operation.

y_out: Results as a full 32-bit value. This is then be stored in [xregister_file](../HW/src/pcore/xregister_file.vhd).

y3_out: Results after being clipped to 12 bit. Value is properly clipped if exceeding range.
This is then be stored in [register_file](../HW/src/pcore/register_file.vhd).

y2_out: Result of comparator against y_out value. The comparator tests y_out for
various boolean conditions. This is then be stored in [xregister_file](../HW/src/pcore/xregister_file.vhd).

### Functions:

ALU has a fairly simple set of operations. We want the ALU to be as simple as 
possible to reduce resource requirements. They are meant to perform linear
arithmetic operations occurring normally during AI and vision processing tasks.

Other non-linear operations are taken care of by [stream](../HW/src/pcore/stream.vhd).

ALU and stream together were shown to be able to cover a wide range of AI and 
vision processing.

ALU has the following arithmetic blocks:

- Multiplication of two 12 bit values.

- Adding the result of multiplication to a 32-bit accumulator value.

- Perform shift operation

- Perform boolean comparison of the result. Comparison against zero include GT,GE,LT,LE,EQ,NE

- Casting the 32-bit result to 12 bit result. Value is clipped if it is overflowed or underflowed after casting.

With the above blocks, the following opcodes are supported

```
  COMPARE_LT       : y2_out=(y_out < 0)?1:0
  COMPARE_LE       : y2_out=(y_out <= 0)?1:0
  COMPARE_GT       : y2_out=(y_out > 0)?1:0
  COMPARE_GE       : y2_out=(y_out >= 0)?1:0
  COMPARE_EQ       : y2_out=(y_out==0)?1:0
  COMPARE_NE       : y2_out=(y_out!=0)?1:0
  MULTIPLY         : y_out=x1*x2
  FMA              : xreg_in += x1_in;
  FMS              : xreg_in -= x1_in
  ASSIGN           : y_out=x1_in
  ACCUMULATOR_SHL  : y_out=(xreg_in << x_scalar_in)
  ACCUMULATOR_SHR  : y_out=(xreg_in >> x_scalar_in)
  INT12 SHR        : y_out=(x1_in >> x_scalar_in)
  INT12 SHL        : y_out=(x1_in << x_scalar_in)
```

## ztachip.core.pcore.instr_decoder2

This is the main component that decodes the computing components of VLIW instructions

There are 3 main operations to each VLIW instruction:

- operation on [pcore.alu](../HW/src/alu/alu.vhd): To perform math operations on vector data

- operation on [pcore.ialu](../HW/src/ialu/ialu.vhd): To perform simple scalar integer operation.

- branching operation. But this is performed by master processor [core.instr](../HW/src/pcore/instr.vhd) since
all VLIW processors are running in lockstep therefore sharing the same 
branching operation.

VLIW instructions are 128 bit long and have the following format

```
MU                 -- pcore.alu instruction 
   oc         5    -- opcode
   save       1    -- Save alu.y_out=>xregister_file
   x3              -- x3 parameter;map to alu.xscalar_in
      vector  1    -- 1 if parameter is vector,0 if scalar
      addr    12   -- Internal memory address of x3
      attr    4    -- Attribute
   x1              -- x1 parameter;map to alu.x1_in
      vector  1    -- 1 if parameter is vector,0 if scalar
      addr    12   -- Internal memory address of x1
      attr    4    -- Attribute
   x2              -- x2 parameter;map to alu.x2_in
      vector  1    -- 1 if parameter is vector,0 if scalar
      addr    12   -- Internal memory address of x2
      attr    4    -- Attribute
   y               -- y parameter;map to alu.y*_out
      vector  1    -- 1 if parameter is vector,0 if scalar
      addr    12   -- Internal memory address of y
      attr    4    -- Attribute
IMU                -- pcore.ialu instruction
   oc         5    -- opcode 
   x1         4    -- x1 parameter; map to ialu.x1_in
   x2         4    -- x2 parameter; map to ialu.x2_in
   y          4    -- y parameter; map to ialu.y_out
   const      13   -- Constant field
CTRL
   oc         5    -- Branching opcode based on IMU.y value
   addr       11   -- Code address to jump to
```

MU.attr field above provides many ways for parameters to reference memory.

Table below shows different addressing options for parameters.

where IREG is ialu's register file and MEM is pcore's internal memory.

```
ATTR  DESCRIPTION                  MEMORY ACCESS PATTERN
===========================================================
11RR  Access via pointer+index     MEM[IREG[addr]+IREG[RR]] 
1011  Access via pointer           MEM[IREG[addr]]
1000  Access shared memory         MEM[addr]
1001  Access private memory        MEM[addr]
00RR  Access shared memory+index   MEM[addr+IREG[RR]]
01RR  Access private memory+index  MEM[addr+IREG[RR]]

```




