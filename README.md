# Introduction

ztachip is a RISCV accelerator for vision and AI edge applications running on low-end FPGA devices
or custom ASIC.

Acceleration provided by ztachip can be up to 20-50x compared with a non-accelerated RISCV implementation
on many vision/AI tasks. ztachip performs also better when compared with a RISCV that is equipped with
vector extension.

An innovative tensor processor hardware is implemented to accelerate a wide range of different tasks from
many common vision tasks such as edge-detection, optical-flow, motion-detection, color-conversion
to executing TensorFlow AI models. This is one key difference of ztachip when compared with other accelerators
that tend to accelerate only a narrow range of applications only (for example convolution neural network only).

A new tensor programming paradigm is introduced to allow programmers to leverage the
massive processing/data parallelism enabled by ztachip tensor processor.

[![ztachip demo video](Documentation/images/demo_video.bmp)](https://www.youtube.com/watch?v=amubm828YGs)

# Documentation

[Technical overview](Documentation/Overview.md)

[Hardware Architecture](Documentation/HardwareDesign.md)

[Programmers Guide](https://github.com/ztachip/ztachip/raw/master/Documentation/ztachip_programmer_guide.pdf)

[VisionAI Stack Programmers Guide](https://github.com/ztachip/ztachip/raw/master/Documentation/visionai_programmer_guide.pdf)

[MicroPython Programmers Guide](micropython/MicropythonUserGuide.md)

# Code structure

- [SW/compiler](SW/compiler): compiler to generate instructions for the tensor processor.

- [SW/apps](SW/apps): vision and AI stack implementation. Many prebuilt acceleration functions are provided to provide
programmers with a fast path to leverage ztachip acceleration.
This folder is also a good place to learn on how to program your own custom acceleration functions.

- [SW/base](SW/base): SW framework library and some utilities

- [SW/fs](SW/fs): read-only file system to be downloaded together with the build image.

- [SW/src](SW/src): codes for the reference design example. This is a good place to learn on how to use ztachip
prebuilt vision and AI stack.

- [HW/examples](HW/examples): HDL codes for the reference design.

- [HW/examples/GHRD/MyVexRiscv.scala](HW/examples/GHRD/MyVexRiscv.scala): RISCV core used in this example is based on VexRiscv implementation. This file is used by [VexRiscv project](https://github.com/SpinalHDL/VexRiscv) to generate the Riscv core.

- [HW/platform](HW/platform): This is a thin wrapper layer to help ztachip to be synthesized efficiently
on different FPGA or ASIC. Choose the appropriate sub-folder that corresponds to your FPGA target.
A generic implementation is also provided for simulation environment. Any FPGA/ASIC can be supported
with the appropriate implementation of this wrapper layer.

- [HW/src](HW/src): main ztachip HDL source codes.

# Build procedure

The build procedure produces 2 seperate images.

One image is a standalone executable where user applications are using ztachip using a native [C/C++ library interface] (https://github.com/ztachip/ztachip/raw/master/Documentation/visionai_programmer_guide.pdf)

The second image is a micropython port of ztachip. With this image, applications are using ztachip using a [Python programming interface](micropython/MicropythonUserGuide.md)


## Prerequisites (Ubuntu)

```
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev python3-pip
pip3 install numpy
```

## Download and build RISCV tool chain

The build below is a pretty long.

```
export PATH=/opt/riscv/bin:$PATH
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32im --with-abi=ilp32
sudo make
```

## Download ztachip
```
git clone https://github.com/ztachip/ztachip.git
```

## Build ztachip as standalone image
```
export PATH=/opt/riscv/bin:$PATH
cd ztachip
cd SW/compiler
make clean all
cd ../fs
python3 bin2c.py
cd ..
make clean all -f makefile.kernels
make clean all
```

## Build ztachip as micropython port
You are required to complete the previous build procedure for standalone image even if your
target image is micropython image. 
Below is procedure to build micropython image after you have completed the standalone image build procedure.

```
git clone https://github.com/micropython/micropython.git
cd micropython/ports
cp -avr <ztachip installation folder>/micropython/ztachip_port .
cd ztachip_port
export PATH=/opt/riscv/bin:$PATH
export ZTACHIP=<ztachip installation folder>
make clean
make
```

## Build FPGA

- Download Xilinx Vivado Webpack free edition.

- Create the project file, build FPGA image and program it to flash as described in
[FPGA build procedure](Documentation/Vivado.md)

# Run reference design example

The following demos are demonstrated on the [ArtyA7-100T FPGA development board](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/).

- Image classification with TensorFlow's Mobinet

- Object detection with TensorFlow's SSD-Mobinet

- Edge detection using Canny algorithm

- Point-of-interest using Harris-Corner algorithm

- Motion detection

- Multi-tasking with ObjectDetection, edge detection, Harris-Corner, Motion Detection running at
same time

To run the demo, press button0 to switch between different AI/vision applications.

## Preparing hardware

Reference design example required the hardware components below... 

- [Arty A7-100T development board](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/)

- [VGA module](https://digilent.com/shop/pmod-vga-video-graphics-array/)

- [Camera module](https://www.amazon.ca/640X480-Interface-Exposure-Control-Display/dp/B07PX4N3YS/ref=sr_1_2_sspa?gclid=EAIaIQobChMIttra8bjo-QIVCMqzCh27tA5XEAAYASAAEgKJTPD_BwE&hvadid=596026577980&hvdev=c&hvlocphy=9000555&hvnetw=g&hvqmt=e&hvrand=6338354247560979516&hvtargid=kwd-296249713094&hydadcr=13589_13421122&keywords=ov7670+camera+module&qid=1661652319&sr=8-2-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUEzVDhCRUlYWEJZUU8xJmVuY3J5cHRlZElkPUEwMDExNDE5M1ZRSEw3WDdEWk9VWiZlbmNyeXB0ZWRBZElkPUEwMTgwOTYwWTFXWUNPWE8xQzk2JndpZGdldE5hbWU9c3BfYXRmJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ==)

Attach the VGA and Camera modules to Arty-A7 board according to picture below 

![arty_board](Documentation/images/arty_board.bmp)

Connect camera_module to Arty board according to picture below

![camera_to_arty](Documentation/images/camera_and_arty_connect.bmp)

## Open serial port

If you are running ztachip's micropython image, then you need to connect to the serial port. Arty-A7 provides serial port connectivity via USB. Serial port flow control must be disabled.

```
sudo minicom -w -D /dev/ttyUSB1
```

Note: After the first time connecting to serial port, reset the board again (press button next to USB port and wait for led to turn green) since USB serial must be the first device to connect to USB before ztachip.

## Download and build OpenOCD package required for GDB debugger's JTAG connectivity

In this example, we will load the program using GDB debugger and JTAG

```
sudo apt-get install libtool automake libusb-1.0.0-dev texinfo libusb-dev libyaml-dev pkg-config
git clone https://github.com/SpinalHDL/openocd_riscv
cd openocd_riscv
./bootstrap
./configure --enable-ftdi --enable-dummy
make
cp <ztachip installation folder>/tools/openocd/soc_init.cfg .
cp <ztachip installation folder>/tools/openocd/usb_connect.cfg .
cp <ztachip installation folder>/tools/openocd/xilinx-xc7.cfg .
cp <ztachip installation folder>/tools/openocd/jtagspi.cfg .
cp <ztachip installation folder>/tools/openocd/cpu0.yaml .
```

## Launch OpenOCD

Make sure the green led below the reset button (near USB connector) is on. This indicates that FPGA has been loaded correctly.
Then launch OpenOCD to provide JTAG connectivity for GDB debugger

```
cd <openocd_riscv installation folder>
sudo src/openocd -f usb_connect.cfg -c 'set MURAX_CPU0_YAML cpu0.yaml' -f soc_init.cfg
```

## Uploading SW image via GDB debugger

### Upload procedure for standalone SW image option
Open another terminal, then issue commands below to upload the standalone image

```
export PATH=/opt/riscv/bin:$PATH
cd <ztachip installation folder>/SW/src
riscv32-unknown-elf-gdb ../build/ztachip.elf
```

### Upload procedure for micropython SW image option
Open another terminal, then issue commands below to upload the micropython image.

```
export PATH=/opt/riscv/bin:$PATH
cd <Micropython installation folder>/ports/ztachip_port
riscv32-unknown-elf-gdb ./build/firmware.elf
```

### Start the image transfer

From GDB debugger prompt, issue the commands below
This step takes some time since some AI models are also transfered.

```
set pagination off
target remote localhost:3333
set remotetimeout 60
set arch riscv:rv32
monitor reset halt
load
```

## Run the program

After sucessfully loading the program, issue command below at GDB prompt

```
continue
```

### Running standalone image
If you are running the standalone image, press button0 to switch between different AI/vision applications. The sample application running is implemented in [vision_ai.cpp](SW/src/vision_ai.cpp)

### Running micropython image
If you are running the micropython image, Micropython allows for entering python code in paste mode at the serial port.  
To use the paste mode, hit Ctrl+E then paste one of the [examples](micropython/examples/) to the serial port, then hit ctrl+D to execute the python code.

Hit any button to return back to Micropython prompt.

# How to port ztachip to other FPGA,ASIC and SOC 

Click [here](Documentation/PortProcedure.md) for procedure on how to port ztachip and its applications to other FPGA/ASIC and SOC.

# Run ztachip in simulation

First build example test program for simulation.
The example test program is under SW/apps/test and SW/sim

```
export PATH=/opt/riscv/bin:$PATH
cd ztachip
cd SW/compiler
make clean all
cd ..
make clean all -f makefile.kernels
make clean all -f makefile.sim
```

Then compile all RTL codes below for simulation
```
HW/src
HW/platform/simulation
HW/simulation
```
The top component of your simulation is HW/simulation/main.vhd

main:reset_in must be driven low for few clocks before going high.

main:clk_x2_main must be twice the speed of main:clk_main and in phase.

The main:led_out should blink everytime a test result is passed.


# Contact

This project is free to use. But for business consulting and support, please contact vuongdnguyen@hotmail.com

Follow ztachip on Twitter: https://twitter.com/ztachip 

