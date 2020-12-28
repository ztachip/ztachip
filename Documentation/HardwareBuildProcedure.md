# ZTACHIP FPGA build procedure

This document describes FPGA build procedure targeting [DE10-NANO board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046) running [Linux Xfce Desktop](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046&PartNo=4)

You should start first by installing [Linux Xfce Desktop](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046&PartNo=4) to your DE10-NANO board.

### Download and install Intel Quartus Development Suite.

Download and install [Quartus Prime Lite Edition version 17.0](https://fpgasoftware.intel.com/17.0/?edition=lite)

Here we use the Windows version of Quartus.

### Download ztachip from github

Choose a folder [WORKSPACE] as a place to download ztachip.

```
   cd [WORKSPACE] 
   git clone https://github.com/ztachip/ztachip.git ztachip
```

### Open reference design project file

Open [WORKSPACE]/ztachip/hardware/examples/DE10_NANO_SoC_FB/DE10_NANO_SoC_FB.qpf

### How to integrate ztachip to your FPGA project 

This example is based on reference design DE10_NANO_SoC_FB.qpf provided by the board vendor.

ztachip is integrated to a FPGA design as a Qsys component. 

ztachip QSYS component is defined in [ztachip_hw.tcl](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/ztachip_hw.tcl)

After QSYS IP search path is set to [WORKSPACE]/ztachip/hardware/HDL, QSYS should detect ztachip component package and make it available to be inserted to model.

Picture below shows ztachip qsys configuration as defined in [WORKSPACE]/ztachip/hardware/examples/DE10_NANO_SoC_FB/soc_system.qsys

![ztachip qsys](images/ztachip_qsys.png)

In the qsys configuration above, we have the following ztachip elements:

   - clk/reset: This is clock domain (50mhz) for Host to FPGA register access memory bus.

   - pclk/preset: This is clock domain (140mhz) for pcore processors.

   - mclk/mreset: This is clock domain (120mhz) for mcore processor.

   - dclk/dreset: This is clock domain (180mhz) for FPGA to DDR memory bus.

   - s0: This is Host to FPGA register access bus. It runs on clk/reset clock domain.

   - m0: This is first FPGA to DDR access memory bus. It runs on dclk/dreset clock domain.

   - m1: This is second FPGA to DDR access memory bus. It runs on dclk/dreset clock domain.

   - hclock: Tied to clk/reset clock domain.

   - mclock: Tied to mclk/mreset clock domain.

   - pclock: Tied to pclk/preset clock domain.

   - dclock: Tied to dclk/dreset clock domain.

   - 0x80000-0xFFFFF: This is the memory mapped address for ztachip register access. This value is to be entered to ztahostInit as described in [Application Programmer Guide](https://github.com/ztachip/ztachip/blob/master/Documentation/app_programmer_guide.md)

The 4 clock domains above are injected into QSYS model by this [top component](https://github.com/ztachip/ztachip/blob/master/hardware/examples/DE10_NANO_SoC_FB/DE10_NANO_SOC_FB.v).

Also include [ztachip.qip](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/ztachip.qip) to your project build. This will include all ztachip HDL files.


### Build Qsys 

- Under Tools->Qsys,open [WORKSPACE]/ztachip/hardware/examples/DE10_NANO_SoC_FB/soc_system.qsys

- Under Tools->Option,set IP SearchPath=[WORKSPACE]/ztachip/hardware/HDL

- File -> RefreshSystem

- Generate->Generate HDL->Generate button

- Close Qsys

### Build FPGA image

Processing -> Start compilation

### Install FPGA image on target

Quartus produces FPGA image in SOF format. 

Open a Windows Command Prompt and convert the output FPGA image to RBF format with following commands

```
   cd [WORKSPACE]/ztachip/hardware/examples/DE10_NANO_SoC_FB/output_files
   sof_to_rbf.bat
```

The steps above produces FPGA image file named soc_system.rbf 

Plug DE10_NANO's MicroSD card to the PC, you should find in its folder a FPGA image with suffix rbf. Upgrade this FPGA image with the newly generated soc_system.rbf (Keep name the same when upgrade)

Associate with every FPGA image, especially when there is a change to FPGA-DDR memory interface, you also need to build and flash a new preloader image to MicroSD card. [Click here](https://rocketboards.org/foswiki/Documentation/SoCSWWS1IntroToAlteraSoCDevicesLab1Preloader#Generating_the_Preloader_with_BSP_Editor_GUI) for information about preloader.

