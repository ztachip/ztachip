[&#8592; Home](index.md)

# Getting Started: Running a Vision/AI Demo on Artix-7 FPGA

<details>
<summary><b>Contents</b></summary>

- [1. Software Build Procedure](#1-software-build-procedure)
  - [1.1 Prerequisites (Ubuntu)](#11-prerequisites-ubuntu)
  - [1.2 Download and Build the RISC-V Toolchain](#12-download-and-build-the-risc-v-toolchain)
    - [1.2.1 Option 1: Use the Prebuilt Toolchain](#121-option-1-use-the-prebuilt-toolchain)
    - [1.2.2 Option 2: Build the Toolchain from Source](#122-option-2-build-the-toolchain-from-source)
  - [1.3 Download ztachip](#13-download-ztachip)
  - [1.4 Build ztachip](#14-build-ztachip)
  - [1.5 MicroPython Integration (Recommended)](#15-micropython-integration-recommended)
- [2. FPGA Build Procedure](#2-fpga-build-procedure)
  - [2.1 Installing Vivado WebPACK Edition](#21-installing-vivado-webpack-edition)
  - [2.2 Create the Project File](#22-create-the-project-file)
  - [2.3 Build and Flash the FPGA Image](#23-build-and-flash-the-fpga-image)
  - [2.4 Support for Open-Source Toolchains](#24-support-for-open-source-toolchains)
- [3. Running the Demos](#3-running-the-demos)
  - [3.1 Preparing the Hardware](#31-preparing-the-hardware)
  - [3.2 Open the Serial Port](#32-open-the-serial-port)
  - [3.3 Download and Build OpenOCD](#33-download-and-build-openocd)
  - [3.4 Launch OpenOCD](#34-launch-openocd)
  - [3.5 Demo Preparation](#35-demo-preparation)
  - [3.6 Upload the Software Image with GDB](#36-upload-the-software-image-with-gdb)
    - [3.6.1 Bare-Metal Mode](#361-bare-metal-mode)
    - [3.6.2 MicroPython Mode (Recommended)](#362-micropython-mode-recommended)
  - [3.7 Start the Image Transfer](#37-start-the-image-transfer)
  - [3.8 Run the Program](#38-run-the-program)
- [4. Benchmark](#4-benchmark)
  - [4.1 Benchmark Results](#41-benchmark-results)
  - [4.2 Conclusion](#42-conclusion)

</details>

This guide walks through everything needed to see ztachip running: building the
software, building the FPGA image, and loading and running the vision and AI
demos on a Digilent Arty A7 board.

## 1. Software Build Procedure

### 1.1 Prerequisites (Ubuntu)

Install the required Ubuntu packages:

```bash
sudo apt-get install autoconf automake autotools-dev curl python3 \
    libmpc-dev libmpfr-dev libgmp-dev gawk build-essential \
    bison flex texinfo gperf libtool patchutils bc \
    zlib1g-dev libexpat-dev python3-pip

pip3 install numpy
```

### 1.2 Download and Build the RISC-V Toolchain

#### 1.2.1 Option 1: Use the Prebuilt Toolchain

Download the prebuilt RISC-V [toolchain](https://github.com/ztachip/ztachip/releases/download/AI_agents/riscv.tar.gz).

Then extract it into `/opt`:

```bash
sudo tar -xzvf riscv.tar.gz -C /
```

The toolchain will be installed under:

```text
/opt/riscv
```

#### 1.2.2 Option 2: Build the Toolchain from Source

If you prefer to build the RISC-V GNU toolchain yourself:

```bash
export PATH=/opt/riscv/bin:$PATH

git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain

./configure --prefix=/opt/riscv --with-arch=rv32im --with-abi=ilp32

sudo make
```

### 1.3 Download ztachip

Clone the ztachip repository:

```bash
git clone https://github.com/ztachip/ztachip.git
```

### 1.4 Build ztachip

Add the RISC-V toolchain to your path and build the ztachip compiler, file system, kernels, and software image:

```bash
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

### 1.5 MicroPython Integration (Recommended)

ztachip can run under MicroPython, providing a Python programming interface for accessing ztachip functionality.

See the [MicroPython Programmer's Guide](../micropython/MicropythonUserGuide.md) for more information.

To build ztachip with MicroPython:

```bash
git clone https://github.com/micropython/micropython.git

cd micropython/ports

cp -avr <ztachip installation folder>/micropython/ztachip_port .

cd ztachip_port

export PATH=/opt/riscv/bin:$PATH
export ZTACHIP=<ztachip installation folder>

make clean
make
```

## 2. FPGA Build Procedure

The reference FPGA implementation uses Xilinx Vivado. The steps below create the
Vivado project, build the FPGA image, and program it into the board's flash.

### 2.1 Installing Vivado WebPACK Edition

Vivado WebPACK edition is a free IDE for the Artix-7 FPGA family.

[Installing Vivado WebPACK edition](https://www.xilinx.com/support/download.html)

### 2.2 Create the Project File

Launch Vivado.

On the TCL console command line, issue the following commands:

```tcl
cd <ztachip installation folder>/HW/examples/GHRD
set argv linux # For Linux Only
source create_project.tcl
```

A project file `ztachip.xpr` should be created after `create_project.tcl` has finished executing.

### 2.3 Build and Flash the FPGA Image

Open the Vivado project file `ztachip/HW/examples/GHRD/ztachip.xpr`.

Then start with the synthesis step as shown below.

![vivado step1](images/vivado_step1.bmp)

After the synthesis step has been completed, Vivado will prompt you to continue with the implementation step. Choose the option and click OK.

![vivado step2](images/vivado_step2.bmp)

After the implementation step has been completed, Vivado will prompt you to continue with the bitstream generation step. Choose the option and click OK.

![vivado step3](images/vivado_step3.bmp)

After the bitstream generation step has been completed, Vivado will prompt you to open the Hardware Manager. Choose the option and click OK.

![vivado step4](images/vivado_step4.bmp)

Make sure your board is connected to the PC with the USB cable provided in the Arty development package.

From the Hardware Manager, connect to the target as shown below.

![vivado step5](images/vivado_step5.bmp)

On the left panel, click on the "Add Configuration Memory Device" menu option, then choose to create the flash device as shown below.

![vivado step5_1](images/vivado_step5_1.bmp)

Then program the board as shown below. The image to be flashed is `ztachip/HW/examples/GHRD/ztachip.runs/impl_1/main.bin`.

If the file is not there, verify that the `-bin` option is selected under Project Settings/Bitstream, then rerun the bitstream generation step.

![vivado step7](images/vivado_step7.bmp)

That's it. Your board's FPGA will be programmed with the new image automatically after a power reboot.

### 2.4 Support for Open-Source Toolchains

Open-source toolchains normally support only Verilog.

You can convert the ztachip RTL to Verilog using GHDL.

Install [GHDL](https://github.com/ghdl/ghdl).

Then convert the RTL code from VHDL to Verilog with the command below.

```bash
cd <ztachip folder>/tools/ghdl
./convert.sh
```

All VHDL code will be converted and combined into a single file, `tools/ghdl/soc.v`.

As an example of an all-Verilog project, create the Vivado project using [create_project2.tcl](../HW/examples/GHRD/create_project2.tcl) instead.

## 3. Running the Demos

### 3.1 Preparing the Hardware

The reference design requires the following hardware components:

- [Digilent Arty A7-100T development board](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/)
- [Digilent Pmod VGA module](https://digilent.com/shop/pmod-vga-video-graphics-array/)
- [Camera module](https://www.aliexpress.com/item/1005009373256992.html)

Attach the VGA and camera modules to the Arty A7 board as shown below.

![Arty A7 Board](images/arty_board.bmp)

Connect the camera module to the Arty A7 board as shown below.

![Camera connected to Arty A7](images/camera_and_arty_connect.bmp)

### 3.2 Open the Serial Port

When running the ztachip MicroPython image, connect to the serial port provided through the Arty A7 USB interface.

Serial-port flow control must be disabled.

For example:

```bash
sudo minicom -w -D /dev/ttyUSB1
```

> **Note:** After connecting to the serial port for the first time, reset the board by pressing the button next to the USB port. Wait for the green LED to turn on. The USB serial interface must be the first device to connect to USB before ztachip.

### 3.3 Download and Build OpenOCD

OpenOCD provides the JTAG connection used by the GDB debugger.

In this example, the program is loaded onto the board using **GDB + JTAG**.

Install the required packages:

```bash
sudo apt-get install libtool automake libusb-1.0.0-dev \
    texinfo libusb-dev libyaml-dev pkg-config
```

Download and build OpenOCD:

```bash
git clone https://github.com/SpinalHDL/openocd_riscv

cd openocd_riscv

./bootstrap
./configure --enable-ftdi --enable-dummy

make
```

Copy the ztachip OpenOCD configuration files into the OpenOCD directory:

```bash
cp <ztachip installation folder>/tools/openocd/soc_init.cfg .
cp <ztachip installation folder>/tools/openocd/usb_connect.cfg .
cp <ztachip installation folder>/tools/openocd/xilinx-xc7.cfg .
cp <ztachip installation folder>/tools/openocd/jtagspi.cfg .
cp <ztachip installation folder>/tools/openocd/cpu0.yaml .
```

### 3.4 Launch OpenOCD

Make sure the **green LED below the reset button near the USB connector is on**. This indicates that the FPGA has been configured correctly.

Then launch OpenOCD to provide the JTAG connection for GDB:

```bash
cd <openocd_riscv installation folder>

sudo src/openocd \
    -f usb_connect.cfg \
    -c 'set MURAX_CPU0_YAML cpu0.yaml' \
    -f soc_init.cfg
```

Keep OpenOCD running while using GDB.

### 3.5 Demo Preparation

The demo requires LLM model files to be available.

A **TFTP server** must be running on the PC Ethernet interface connected to the Arty A7 board.

Configure the PC Ethernet interface with the following IP address:

```text
10.10.10.10
```

Copy the following two model files into the TFTP server's download directory:

- [SMOLLM2.ZUF](https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLLM2.ZUF)
- [SMOLFC.ZUF](https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLFC.ZUF)

These files contain quantized versions of the LLM models.

See the [Model Quantization Procedure](QuantizeProcedure.md) for instructions on creating the quantized models.

### 3.6 Upload the Software Image with GDB

#### 3.6.1 Bare-Metal Mode

To run ztachip without MicroPython integration, open another terminal and start GDB with the standalone ztachip software image:

```bash
export PATH=/opt/riscv/bin:$PATH

cd <ztachip installation folder>/SW/src

riscv32-unknown-elf-gdb ../build/ztachip.elf
```

#### 3.6.2 MicroPython Mode (Recommended)

To run ztachip with MicroPython integration, open another terminal and start GDB with the MicroPython firmware image:

```bash
export PATH=/opt/riscv/bin:$PATH

cd <MicroPython installation folder>/ports/ztachip_port

riscv32-unknown-elf-gdb ./build/firmware.elf
```

### 3.7 Start the Image Transfer

From the GDB prompt, enter:

```gdb
set pagination off
target remote localhost:3333
set remotetimeout 60
set arch riscv:rv32
monitor reset halt
load
```

### 3.8 Run the Program

After the program has been successfully loaded, run it from the GDB prompt:

```gdb
continue
```

If running in bare-metal mode, press any button to move between different vision/LLM demos.

If running in MicroPython mode, at the serial console, hit CTRL+E, then paste one of the Python programs from this [folder](../micropython/examples) and hit CTRL+D to run. Then hit any button to stop and return to the Python console.

A demonstration showing how to run the demo is available in this [video](https://www.youtube.com/watch?v=ng0nCEYE6fc&t=499s).

## 4. Benchmark

Small LLM inference performance on edge devices is largely constrained by **memory bandwidth**. In these scenarios, additional compute capability provides limited benefit when processing cores spend most of their time waiting for model data to be transferred from memory.

For this reason, a useful metric for comparing edge LLM implementations is:

**Tokens per second (TPS) per GB/s of memory bandwidth**

### 4.1 Benchmark Results

The following results compare **ztachip running on the Arty platform** with the Raspberry Pi 4 and Raspberry Pi 5.

LLM inference performance can be divided into two main components:

- **Fixed component:** Dominated by matrix multiplication and model-weight transfers. This represents the primary bottleneck and cost for many edge AI applications, where long chat histories and large context windows are less common.

- **Variable component:** Dominated by attention mechanisms and softmax calculations across the context window. ztachip includes a dedicated FPU compute unit capable of processing context operations at rates that match the available DDR memory-transfer bandwidth, keeping this component primarily memory-bound.

The comparison below focuses on the **fixed-cost component** by using shorter prompts and questions.

*Raspberry Pi benchmark data sourced from [arXiv:2511.07425v1](https://arxiv.org/html/2511.07425v1).*

| Platform | Performance | Memory Bandwidth | Efficiency |
| :--- | ---: | ---: | ---: |
| **Raspberry Pi 4** | 11 TPS | 12 GB/s | 0.92 TPS/(GB/s) |
| **Raspberry Pi 5** | 32 TPS | 17 GB/s | 1.88 TPS/(GB/s) |
| **ztachip (Arty)** | 8 TPS | 1.2 GB/s | **6.70 TPS/(GB/s)** |

### 4.2 Conclusion

The Raspberry Pi platforms achieve higher raw token-generation rates because they provide substantially higher overall hardware and memory-bandwidth resources.

However, **ztachip achieves significantly higher utilization of the available memory bandwidth**:

- **7.2× more efficient** than the Raspberry Pi 4
- **3.5× more efficient** than the Raspberry Pi 5

This efficiency is particularly important for low-cost and resource-constrained edge AI platforms, where memory bandwidth and power are often more limited than compute capability.
