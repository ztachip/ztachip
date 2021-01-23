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

![pcore](images/pcore.png)

## Tensor Engine

![tensor engine](images/dp_core.png)

## mcore 

![mcore](images/mcore.png)


