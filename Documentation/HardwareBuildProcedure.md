# ZTACHIP FPGA build procedure

This document describes FPGA build procedure targeting [DE10-NANO board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046) running [Linux Xfce Desktop](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046&PartNo=4)

But you can adapt this reference design to other FPGA platforms.

This document assumes that you are familiar with Quartus/Qsys development environment

### Download ztachip from github

```
   cd ~
   git clone https://github.com/ztachip/ztachip.git ztachip
```

### Open reference design project file

Open ~/ztachip/hardware/examples/DE10_NANO_SoC_FB/DE10_NANO_SoC_FB.qpf

### Open Qsys design file

ztachip is integrated to a FPGA design as a Qsys component. 

Refer to this Qsys design file as reference if you would like to integrate ztachip to other FPGA hardware.

- Under Tools->Qsys,open ~/ztachip/hardware/examples/DE10_NANO_SoC_FB/soc_system.qsys

- Under Tools->Option,set IP SearchPath=~/ztachip/hardware/HDL

- File -> RefreshSystem

- Generate->Generate HDL->Generate button

- Close Qsys

### Build FPGA image

Processing -> Start compilation

### Install FPGA image on target

There are also steps to build bootloader image that corresponds to a FPGA image.

Refer to Quartus documentation on how to install FPGA image on target boards.
 


