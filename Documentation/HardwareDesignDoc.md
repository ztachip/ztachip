# ZTACHIP Hardware Design Description

This document describes the hardware design of ztachip

## top component

This is the ztachip top component

![top](images/top.png)

[ztachip](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/top/ztachip.vhd) - This is the top component

[avalon_lw_adapter](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/top/avalon_lw_adapter.vhd) - Clock bridge between hclock(Host2FPGA bus clock domain) and mclock (mcore clock domain).

[avalon_adapter](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/top/avalon_adapter.vhd) - Interface with Altera Avalon Bus.

[msgq](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/top/msgq.vhd) - Message queue between host and mcore

[mcore](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/mcore/mcore.vhd) - MCORE processor that runs mcore programs. This is a MIPS-I processor.

[dp_core](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/dp/dp_core.vhd) - Tensor Engine

[sram_core](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/top/sram_core.vhd) - SRAM block

[ddr](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/top/ddr.vhd) - DDR interface block. There is one for READ direction and one for write direction)

[core](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/core.vhd) - Array of VLIW processor cores. These cores execute pcore programs.

## pcore 

Array of VLIW processors.

![core](images/core.png)

[core](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/core.vhd) - Array of VLIW processor cores. These cores execute pcore programs.

[stream](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/stream.vhd) - Array of VLIW processor cores. These cores execute pcore programs.

[cell](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/top/cell.vhd) - PCORE processors are group into groups called cell

 
[pcore](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/pcore.vhd) - VLIW/Vector processor 


[instr](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/instr.vhd) - Generate instructions for PCORE array. This is SIMD architecture so all PCORES process same instruction. 


![pcore](images/pcore.png)


[mu_adder](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/alu/imu.vhd) - ALU unit for vector arithmetic. 

[instr_decoder2](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/instr_decoder2.vhd) - Decode instructions, generate commands and memory addresses and forward them to instr_dispatch2. 

[instr_dispatch2](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/instr_dispatch2.vhd) - Dispatch commands from instr_decoder2 to mu_adder, passing data between mu_adder and register_bank

[iregister_file](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/ialu/iregister_file.vhd) - Hold registers used by scalar processor. 

[ialu](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/ialu/ialu.vhd) - Scalar processor. Mostly used for loop control and address calculation. 

[register_bank](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/register_bank.vhd) - Hold private/shared memory space for pcores. 

[register_file](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/register_file.vhd) - There are 2 register_file within a register_bank. Each register_file holds private/shared memory space for each tensor process. 

[flag](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/pcore/flag.vhd) - Hold accumulator and vector comparison results. 

## Tensor Engine

![tensor engine](images/dp_core.png)

## mcore 

![mcore](images/mcore.png)


