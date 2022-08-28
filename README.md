# Introduction

ztachip is a RISCV accelerator for vision and AI edge applications running on low-end FPGA devices.

Acceleration provided by ztachip can be up to 20-50x compared with a non-accelerated RISCV implementation
on many vision/AI tasks.

An innovative new tensor processor is implemented to accelerate a wide range of different tasks from
many common vision tasks such as edge-detection, optical-flow, motion-detection, color-conversion
to executing TensorFlowLite AI models.

# Code structure

- SW/compiler: compiler to generate instructions for the accelerator.

- SW/apps: vision and AI stack implementation. This folder is a good place to learn on how to
program your own custom acceleration.

- SW/base: SW framework library and some utilities

- SW/fs: read-only file system to be downloaded together with the build image.

- SW/src: codes for the reference design example. This is a good place to learn on how to use ztachip
prebuilt vision and AI stack.

- HW/examples: HDL codes for the reference design.

- HW/platform: This is a thin wrapper layer to help ztachip to be synthesized efficiently
on different FPGA or ASIC. Choose the appropriate sub-folder that corresponds to your FPGA target.
A generic implementation is also provided for simulation environment. Any FPGA/ASIC can be supported
with the appropriate implementation of this wrapper layer.

- HW/src: ztachip HDL source codes.

# Build procedure

## Prerequisites (Ubuntu)

```
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
sudo apt-get install -y bison
sudo apt install flex
```

## Download and build RISCV tool chain

```
export PATH=/opt/riscv/bin:$PATH
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32im --with-abi=ilp32
sudo make
```

## Download and build ztachip

```
git clone https://github.com/ztachip/ztachip.git
export PATH=/opt/riscv/bin:$PATH
cd ztachip
cd SW/compiler
make clean all
cd ../fs
python3 bin2c.py
cd ../src
make clean all -f makefile.kernels
make clean all
```

## Download and build openocd required for GDB debugger

```
git clone https://github.com/SpinalHDL/openocd_riscv
cd openocd_riscv
cp <ztachip installation folder>/examples/open_ocd/soc_init.cfg .
cp <ztachip installation folder>/examples/open_ocd/usb_connect.cfg .
cp <ztachip installation folder>/examples/open_ocd/xilinx-xc7.cfg .
cp <ztachip installation folder>/examples/open_ocd/jtagspi.cfg .
cp <ztachip installation folder>/examples/open_ocd/cpu0.yaml .
```

## Build FPGA

- Download Xilinx Vivado Webpack free edition.

- With Vivado, open project ztachip/HW/examples/GHRD/GHRD.xpr

- The target board used in this example is the [ArtyA7-100T](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/)

- Build FPGA image and program it to flash as described in
[Arty Programming Guide](https://digilent.com/reference/learn/programmable-logic/tutorials/arty-programming-guide/start)

# Run reference design example

The following demos are demonstrated on the [ArtyA7-100T FPGA development board](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/).

- Image classification with TensorFlowLite's Mobinet

- Object detection with TensorFlowLite's SSD-Mobinet

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


## Launch OpenOCD for GDB debugger's JTAG connectivity

```
cd <openocd_riscv installation folder>
sudo src/openocd -f usb_connect.cfg -c 'set MURAX_CPU0_YAML cpu0.yaml' -f soc_init.cfg
```

## Launch GDB debugger

```
export PATH=/opt/riscv/bin:$PATH
cd <ztachip installation folder>/SW/src
riscv32-unknown-elf-gdb ../build/ztachip.elf
```

## Load and run program using GDB debugger

From GDB debugger prompt, issue the commands below

```
target remote localhost:3333
set remotetimeout 60
set arch riscv:rv32
monitor reset halt
load
continue
```

# Other links

Go to [Programmer's guide to writing tensor applications]() for information on how to write your
custom acceleration codes.

Go to [Vision/AI stack users guide]() for information on how to use ztachip prebuilt vision/ai stack.


