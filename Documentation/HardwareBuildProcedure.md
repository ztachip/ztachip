# ZTACHIP FPGA build procedure

This document describes FPGA build procedure targeting [DE10-NANO board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046) running [Linux Xfce Desktop](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046&PartNo=4) or [Linux Console](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046&PartNo=4) as its Linux operating system.

## Flash Linux to DE10-NANO

You start first by installing [Linux Xfce Desktop](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046&PartNo=4) to your DE10-NANO board's SDCard. This version of Linux has a GUI desktop. But since Altera implements HDMI in FPGA, the FPGA image associated with this version is significantly larger.

For a console only version of Linux. Install [Linux Console](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=1046&PartNo=4) instead. The FPGA image associated with this Linux is significantly smaller since it does not contain the IP for HDMI driver.

You can use [Disk32Manager](https://sourceforge.net/projects/win32diskimager) utility to flash Linux images to DE10-NANO's SDCard.

## Install ubuntu

In this example, we install Linux Ubuntu within Windows's [VirtualBox](https://www.virtualbox.org). This is convenient for the case that you have just a Windows based PC available. VirtualBox allows you to run Ubuntu Linux from within Windows.

Choose a folder [WORKSPACE] from Windows filesystem where you would like to install ztachip. Then map this [WORKSPACE] folder to Ubuntu's file system. [Click here](https://helpdeskgeek.com/virtualization/virtualbox-share-folder-host-guest/) for information on how to do this mapping. This shared folder can be accessed by both Windows and Ubuntu operating system.

This build procedure has been verified to be built successfully with Ubuntu 18.04 or later

## Install Intel Embedded Studio

Install the following packages required by Intel Embedded Studio

      sudo apt-get install lib32z1
      sudo apt-get update
      sudo apt-get install libgtk2.0-0:i386 libidn11:i386 libglu1-mesa:i386 libxmu6:i386
      sudo apt-get install libpangox-1.0-0:i386 libpangoxft-1.0-0:i386

Download [Intel Embedded Studio](https://fpgasoftware.intel.com/soceds/17.0/?edition=standard&platform=linux&download_manager=direct).
This document is based on Intel Embedded Studio v17.0

Run Intel Embedded Studio installer. Install Intel Embedded Studio in your Ubuntu's home folder.

      sudo ./SoCEDSSetup-17.0.0.595-linux.run

## Download and install Intel Quartus Development Suite.

From Windows, Download and install [Quartus Prime Lite Edition version 17.0](https://fpgasoftware.intel.com/17.0/?edition=lite)

Here we use the Windows version of Quartus.

## Download ztachip from github

```
   cd [WORKSPACE] 
   git clone https://github.com/ztachip/ztachip.git
```

## Open reference design project file

From Windows, launch Quartus Prime Lite Edition. Then...

- Open [WORKSPACE]/ztachip/hardware/examples/DE10_NANO_SoC_FB/DE10_NANO_SoC_FB.qpf if you use Linux Xfce Desktop version of Linux

- Open [WORKSPACE]/ztachip/hardware/examples/DE10_NANO_SoC_FB/DE10_NANO_SoC_GHRD.qpf if you use Linux Console version of Linux

For remaining of document, [TARGET] is used to indentify DE10_NANO_SoC_FB or DE10_NANO_SoC_GHRD depending on the your choice of target Linux version.

## How to integrate ztachip to your FPGA project 

This section provides explanation on how ztachip can be integrated to your design.

ztachip is integrated to a FPGA design as a Qsys component. 

ztachip QSYS component is defined in [ztachip_hw.tcl](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/ztachip_hw.tcl)

After QSYS IP search path is set to [WORKSPACE]/ztachip/hardware/HDL, QSYS should detect ztachip component package and make it available to be inserted to model.

Picture below shows ztachip qsys configuration as defined in [WORKSPACE]/ztachip/hardware/examples/[TARGET]/soc_system.qsys 

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

Also include [ztachip.qip](https://github.com/ztachip/ztachip/blob/master/hardware/HDL/ztachip.qip) to your project build. This will include all ztachip HDL files.

## Build Qsys 

First generate code with Qsys. This is Quartus high level design description.

From Quartus...

- Under Tools->Qsys,open [WORKSPACE]/ztachip/hardware/examples/[TARGET]/soc_system.qsys

- Under Tools->Option,set IP SearchPath=[WORKSPACE]/ztachip/hardware/HDL

- File -> RefreshSystem

- Generate->Generate HDL->Generate button

- Close Qsys

## Build FPGA image

From Quartus...

Processing -> Start compilation

## Install FPGA image on target

Quartus produces FPGA image in SOF format. 

Open a Windows Command Prompt and convert the output FPGA image to RBF format with following commands

```
   cd [WORKSPACE]/ztachip/hardware/examples/[TARGET]/output_files
   sof_to_rbf.bat
```

The steps above produces FPGA image file named soc_system.rbf 

Plug DE10_NANO's MicroSD card to the PC, copy soc_system.rbf above to MicroSD card.

## Build and install preloader image.

Associate with every FPGA image, especially when there is a change to FPGA-DDR memory interface, you also need to build and flash a new preloader image to MicroSD card. 

From Ubuntu console, run command below...

```
   bsp-editor
```

In the BSP Editor screen, 

   - Click File -> < New HPS BSP >

   - In the < Preloader Setting Directory >, choose [WORKSPACE]/ztachip/hardware/examples/[TARGET]/hps_isw_handoff/soc_system_hps_0 

   - Click OK then Generate and then Exit.

Now we will build the preloader image. Unfortunately preloader image build cannot be done in [WORKSPACE] folder since preloader build procedure needs to create link files which is not supported under VirtualBox's shared folder. So we copy the build source files and build it under home directory.

From Ubuntu console command...
```
   cd ~
   cp -avr [WORKSPACE]/ztachip/hardware/examples/[TARGET] .
   cd [TARGET]/software/spl_bsp
   ~/intelFPGA/17.0/embedded/embedded_command_shell.sh
   make
   make uboot
```

Then copy preloader-mkpimage.bin to [WORKSPACE] and then flash this preloader image to SDCard using dd utility. 

From a Windows command prompt, do the command below but replacing f: with the correct drive name for your SDCard.

```
   cd [WORKSPACE]
   [WORKSPACE]\ztachip\thirdparty\dd.exe  if=preloader-mkpimage.bin of=f: bs=64k seek=0 
```

## Update uboot.scr

This file tells uboot which FPGA image to load at boot time.

From Ubuntu console command

Create a file u-boot.txt with the following content

```
fatload mmc 0:1 $fpgadata soc_system.rbf;
fpga load 0 $fpgadata $filesize;
run bridge_enable_handoff;
mw 0xffc2508c 0;
run mmcload;
run mmcboot;
```

The run...

```
~/intelFPGA/17.0/embedded/embedded_command_shell.sh
mkimage  -A arm -O linux -T script -C none -a 0 -e 0 -n "My script" -d u-boot.txt u-boot.scr
```

Then copy u-boot.scr to DE10-NANO's SDCard.


### Prepare target board

ztachip needs some physical memory. Modify UBOOT parameter to reserve some physical memory (512K in this example).

Tell Linux to use only the top 512K of memory and the bottom 512K of memory is reserved for ztachip.

- Open serial port to DE10-NANO with baudrate 115200.(Refer to DE10-NANO user manual on how to setup serial port)
- Reboot
- As soon as there is output on serial port, hit Enter key
- Issue the following command
```
      setenv mmcboot 'setenv bootargs console=ttyS0,115200 root=${mmcroot} rw rootwait mem=512M;bootz ${loadaddr} - ${fdtaddr}'
      saveenv
      reset
```

