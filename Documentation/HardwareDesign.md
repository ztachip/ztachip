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

The central tensor processor unit is dp_core

dp_core receives tensor instructions from RISCV via axilite_* interface.

dp_core then executes the tensor instructions by performing the following:

- Coordinating tensor data operations which transfer tensor data between sram_core, core's internal memory and
external DDR memory.

- Dispatching tensor operator execution requests to core which then in turn dispatch the execution to an array
of VLIW processors. 

## ztachip.dp_core

![hw_dp_core](images/hw_dp_core.png)

## ztachip.core

![hw_core](images/hw_core.png)

## ztachip.core.pcore

![hw_pcore](images/hw_pcore.png) 

