# Build procedure

This document describes the steps to build ztachip software stack 

You should complete the [FPGA Build Procedure](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareBuildProcedure.md) first before proceeding with this document's procedure.

## Install ubuntu

ztachip is built under 64bit Linux Ubuntu environment. 

In this example, we install Linux Ubuntu within [VirtualBox](https://www.virtualbox.org).

Create a VirtualBox's shared folder that maps [WORKSPACE] to Ubuntu's file system. [Click here](https://helpdeskgeek.com/virtualization/virtualbox-share-folder-host-guest/) for information on mapping shared folder.

This build procedure has been verified to be built successfully with Ubuntu 18.04 or later

## Install Intel Embedded Studio

Install the following packages required by Intel Embedded Studio

      sudo apt-get install lib32z1 
      sudo apt-get update
      sudo apt-get install libgtk2.0-0:i386 libidn11:i386 libglu1-mesa:i386 libxmu6:i386
      sudo apt-get install libpangox-1.0-0:i386 libpangoxft-1.0-0:i386

Download [Intel Embedded Studio](https://fpgasoftware.intel.com/soceds/17.0/?edition=standard&platform=linux&download_manager=direct).
This document is based on Intel Embedded Studio v17.0

Run Intel Embedded Studio installer

      sudo ./SoCEDSSetup-17.0.0.595-linux.run

## Install MIPS GNU cross-compiler and linker

This MIPS GNU toolchain is used to build mcore programs.

Do the commands below to install a prebuilt version of the toolchain.

Note that mips-elf must be installed under home directory.

```
       cd ~ 
       git clone https://github.com/ztachip/mips-elf.git
```

For information on how to build the toolchain yourself, refer to this [document](https://github.com/ztachip/ztachip/blob/master/Documentation/mips-elf-BuildProcedure.md)


## Build ztachip
- Install the following packages.
```
      sudo apt-get install -y bison
      sudo apt install flex
```
- From previous [FPGA Build Procedure](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareBuildProcedure.md), you should already have ztachip installed under [WORKSPACE] 

- Setup build environment 
```
      cd ~/intelFPGA/17.0/embedded
      cd ./embedded_command_shell.sh
```
- Build ztachip
```
      cd [WORKSPACE]/ztachip
      make clean
      make all
```

## Prepare target board

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
## Run examples
Archive your built ztachip folder and then unarchive it on the target

On your Ubuntu machine
```
      cd [WORKSPACE] 
      tar -zcvf ztachip.tar.gz ztachip
      scp ztachip.tar.gz root@[YOUR_TARGET_BOARD_IPADDRESS]:/home/root/.
```

Then on ssh terminal session with your target (DE10-Nano)
```
      cd ~
      tar -xvf ztachip.tar.gz
```
- Run health check. Test most functions of ztachip against test vectors

```
      cd ~/ztachip/examples/test
      ./test
```
- Run image classification example using TensorFlow lite's MobinetV2
```
      cd ~/ztachip/examples/classifier
      ./classifier ../bitmap/cat.bmp
```
- Run object detection example using TensorFLow lite's SSD-MobinetV1
```
      cd ~/ztachip/examples/objdetect
      ./objdetect ../bitmap/dogcat.bmp
```
- Run edge detection example. Result is edge_detect.bmp
```
      cd ~/ztachip/examples/edge_detect
      ./edge_detect ../bitmap/cat.bmp
```
- Run harris corner feature extraction example. Result is harris.bmp
```
      cd ~/ztachip/examples/harris
      ./harris ../bitmap/dogcat.bmp
```
- Run image resize example. Result is resize.bmp
```
      cd ~/ztachip/examples/resize
      ./resize ../bitmap/cat.bmp
```
- Run color to greyscale conversion example. Result is greyscale.bmp
```
      cd ~/ztachip/examples/greyscale
      ./greyscale ../bitmap/cat.bmp
```
- Run image blurring example. Result is blur.bmp
```
      cd ~/ztachip/examples/blur
      ./blur ../bitmap/cat.bmp
```
- Run ztachip realtime with webcam
```
      cd ~/ztachip/examples/vision_ai
      ## This example has to be built on target since it need the installed GTK library on target.
      make clean
      make all      
      ### Image classifier
      ./vision_ai 0
      ### Object detection
      ./vision_ai 1
      ### Edge detection
      ./vision_ai 2
      ### Equalizer/Contrast enhancer
      ./vision_ai 3
      ### Image blurring
      ./vision_ai 4
      ### Harris corner detection
      ./vision_ai 5
      ### Optical flow
      ./vision_ai 6
      ### ObjectDetection+EdgeDetection+HarrisCornerDetection+OpticalFlow
      ./vision_ai 7

```
