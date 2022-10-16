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

The central tensor processor unit is [dp_core]((../HW/src/dp/dp_core.vhd)

[dp_core]((../HW/src/dp/dp_core.vhd)) receives tensor instructions from RISCV via axilite_* interface.

[dp_core]((../HW/src/dp/dp_core.vhd)) then executes the tensor instructions by performing the following:

- Coordinating tensor data operations which transfer tensor data between [sram_core]((../HW/src/top/sram_core.vhd)),
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

- [instr.rom](../HW/src/pcore/rom.vhd): Holding VLIW instruction code. All VLIW cores are sharing the same instruction code. Since VLIW processors are all running in lock-step, only 1 instruction is fetched for all the VLIW processors at every clock.

### Functions:

- This component is responsible for all tensor operator execution tasks.

- It is composed of an array of [pcores](../HW/src/pcore/pcore.vhd). And each pcore is a VLIW vector processor.

- Requests for tensor operator execution are coming from [dp_core](../HW/src/dp/dp_core.vhd) via task* interface signal.

- The component [instr](../HW/src/pcore/instr.vhd) is controlling the execution of all pcore's VLIW processors.
VLIW processors are very lightweight processors that are mostly just ALU with memory running in lock-step mode with each other.  

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

- [instr_dispatch2](../HW/src/pcore/instr_decoder2.vhd): Component that interfaces between 
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

pcore execution is multi-threaded. There are 16 hardware threads of execution. 

The VLIW instruction is very wide that contains many sub-functions
that perform the following tasks simultaneously within a single VLIW instruction.

- Address calculation for 2 input parameters and 1 output parameter.

- Fetching input parameter vectors from [register_bank](../HW/src/pcore/register_bank.vhd).

- Fetching 32-bit accumulator from [xregister_file](../HW/src/pcore/xregister_file.vhd). These accumulator values are then used by alu performing FMA (Fused-multiply-add) operations.

- Performing integer calculations on [ialu](../HW/src/ialu/ialu.vhd).

- Perform vector calculation on the bank of [alu](../HW/src/alu/alu.vhd).

- [alu](../HW/src/alu/alu.vhd) may produce results as 32-bit accumulator, save these values to [xregister_file](../HW/src/pcore/xregister_file.vhd).

- [alu](../HW/src/alu/alu.vhd) may produce results as 16-bit vector. Save these results back to 
[register_bank](../HW/src/pcore/register_bank.vhd). 

Since all the functions above are simultaneously performed in one single VLIW instruction, the
instruction pipeline is as long as 14 clocks. However, with hardware multi-threading execution, each
stage of the execution pipeline is occupied by different threads. Therefore we have an effective
execution rate of one VLIW instruction per clock per pcore.

For example, the code below is compiled into one single VLIW instruction and taken one clock of execution.

`z[i++] = x[i+2]+y[i+3];`

### Internal memory format

Internal memory holds 2 types of data

- Private data: Data is private to each of the 16 threads

- Shared data: Data is shared among all 16 threads but within the same pcore.

Private memory words are interleaved between different threads as shown in picture below.

Shared memory words are allocated from the bottom up as shown in picture below.


`
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
`








