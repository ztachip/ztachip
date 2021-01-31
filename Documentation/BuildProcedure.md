# Build procedure

You must complete [FPGA Build Procedure](https://github.com/ztachip/ztachip/blob/master/Documentation/HardwareBuildProcedure.md) before proceeding with the steps in this document.

This document describes the steps to build ztachip software stack 


## Install MIPS GNU cross-compiler and linker

This MIPS GNU toolchain is used to build mcore programs.

Do the commands below to install a prebuilt version of the toolchain.

Note that mips-elf must be installed under home directory.

From Ubuntu command prompt

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

- Build ztachip
```
      ~/intelFPGA/17.0/embedded/embedded_command_shell.sh
      cd [WORKSPACE]/ztachip
      source ./setup.sh
      make clean
      make all
```

## Run examples
Archive your built ztachip folder and then unarchive it on the target

On your Ubuntu machine
```
      cd [WORKSPACE] 
      tar -zcvf ztachip.tar.gz ztachip/software ztachip/examples
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
- Run ztachip realtime with webcam. This example is only available if DE10-NANO is installed with < Linux Xfce Desktop > Linux version.
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
