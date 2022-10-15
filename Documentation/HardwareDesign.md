# Hardware architecture

## ztachip

![hw_ztachip](images/hw_ztachip.png)

Interfaces:

- axiline_* : AXILite bus for riscv to push tensor instructions to ztachip

- axi_* : AXI bus for ztachip to initiate DMA memory transfer to external memory

Subcomponents:

- [sram_core](../HW/src/top/sram_core.vhd): scratch memory to hold temporary
data sometimes required during tensor data transfer

- [axilite](../HW/src/top/axilite.vhd): bridge to connect internal components 
such as dp_core with AXILite bus to RISCV.

- [ddr_rx](../HW/src/top/ddr_rx.vhd): Handling DMA transfer from external memory to
internal memory.

- [ddr_tx](../HW/src/top/ddr_tx.vhd): Handling DMA transfer from internal memory to
external memoy

- [core](../HW/src/pcore/core.vhd): This is the main processing unit which holds
an array of lightweight VLIW processors.

- [dp_core](../HW/src/dp/dp_core.vhd): The main tensor processor unit that coordinates
all activities within ztachip including memory transfer and launching execution on
the VLIW processor array.

Functions:

This is the top level component of ztachip.

dp_core receives tensor instructions from RISCV via axilite_* interface.

dp_core then executes the tensor instructions. There are 2 types of tensor instructions:

- Tensor data operations which transfer tensor data between sram_core,core and external memory.

- Tensor execution operations which are performed by core. 

![hw_dp_core](images/hw_dp_core.png)

![hw_core](images/hw_core.png)

![hw_pcore](images/hw_pcore.png) 

