# Introduction

Ztachip is a Multicore, Data-Aware, Embedded RISC-V AI Accelerator for Edge Inferencing running on low-end FPGA devices or custom ASIC.

Acceleration provided by ztachip can be up to 20-50x compared with a non-accelerated RISCV implementation
on many vision/AI tasks. ztachip performs also better when compared with a RISCV that is equipped with vector extension.

An innovative tensor processor hardware is implemented to accelerate a wide range of different tasks from
many common vision tasks such as edge-detection, optical-flow, motion-detection, color-conversion
to executing TensorFlow AI models. This is one key difference of ztachip when compared with other accelerators
that tend to accelerate only a narrow range of applications only (for example convolution neural network only).

A new tensor programming paradigm is introduced to allow programmers to leverage the massive processing/data parallelism enabled by ztachip tensor processor.

![Ztachip Architecture](./Documentation/images/ztachip_ai_agent.png)

# Features
## Hardware
Ztachip consists of the following functional units tied via an AXI Bus to a VexRicsv CPU, a DRAM and other
peripherals as follows
1. The Mcore, a Scheduling Processor
2. A Dataplane, to stream the next data and instruction to the Tensor Engine .
3. A Scratch-Pad Memory to temporarily hold data
4. A Stream Processor to manage data IO
5. Tensor Engine with 28x Pcores that can be configured to act like a systolic array to perform in memory compute each containing a Scalar and Vector ALU, with 16 Threads of execution on private memory.

## Software
The software provided consists of 
1. Ztachip DSL C-like compiler
2. AI vision libraries
3. Application examples
4. Micropython port and examples

## Demo

[![ztachip demo video](https://www.youtube.com/watch?v=ng0nCEYE6fc&t=499s)

# Documentation

1. [Technical overview](Documentation/Overview.md)

2. [Hardware Architecture](Documentation/HardwareDesign.md)

3. [Programmers Guide](https://github.com/ztachip/ztachip/raw/master/Documentation/ztachip_programmer_guide.pdf)

4. [VisionAI Stack Programmers Guide](https://github.com/ztachip/ztachip/raw/master/Documentation/visionai_programmer_guide.pdf)

5. [MicroPython Programmers Guide](micropython/MicropythonUserGuide.md)

# SW build procedure

There are several demos available which demonstrate various capabilities of ztchip.
Choose to build one of the 3 demos described below.

## Prerequisites (Ubuntu)

```
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev python3-pip
pip3 install numpy
```

## Download and build RISCV tool chain

Download riscv [toolchain](https://github.com/ztachip/ztachip/releases/download/AI_agents/riscv.tar.gz)

Then unarchive as shown below

```
sudo tar -xzvf riscv.tar.gz -C /
```


If you like to build it yourself, below is the procedure...

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

## Build procedure 

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

### Micropython integration (recommended)
Continue the build with steps below if you like to run ztachip under micropython [Python programming interface](micropython/MicropythonUserGuide.md)

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

# FPGA build procedure

- Download Xilinx Vivado Webpack free edition.

- Create the project file, build FPGA image and program it to flash as described in
[FPGA build procedure](Documentation/Vivado.md)

# Running the demos.

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

- [Camera module](https://www.aliexpress.com/item/1005009373256992.html?src=google&src=google&albch=shopping&acnt=603-455-9033&isdl=y&slnk=&plac=&mtctp=&albbt=Google_7_shopping&aff_platform=google&aff_short_key=_oFgTQeV&gclsrc=aw.ds&albagn=888888&ds_e_adid=&ds_e_matchtype=&ds_e_device=c&ds_e_network=x&ds_e_product_group_id=&ds_e_product_id=en1005009373256992&ds_e_product_merchant_id=5445730461&ds_e_product_country=CA&ds_e_product_language=en&ds_e_product_channel=online&ds_e_product_store_id=&ds_url_v=2&albcp=23541693768&albag=&isSmbAutoCall=false&needSmbHouyi=false&gad_source=1&gad_campaignid=23546808899&gbraid=0AAAABCRFad9mvAHB4TSXwyJe-26kItMYF&gclid=CjwKCAjw1bvTBhBbEiwAzbP8L7uGk2ZsaMEruqJy88fXzSv_ymCxoNGRwqF0V9_r31PD_ODI-n-FORoCH2MQAvD_BwE)
 
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

## Demo preparation

The demo requires some LLM model to be available.

The demo requires you to start a TFTP server on the PC Ethernet interface connected to Arty board.

The PC Ethernet interface is expected to be configured for address 10.10.10.10

Then copy these 2 files to the TBTP download directory.

[SMOLLM2.ZUF](https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLLM2.ZUF)

[SMOLFC.ZUF](https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLFC.ZUF)

The files above are the quantized version of LLM model. Click [here](Documentation/QuantizeProcedure.md) for procedure on how to build the quantized models.


## Uploading SW image via GDB debugger

### Upload procedure for ztachip without micropython integration (bare-metal mode)
Open another terminal, then issue commands below to upload the standalone image

```
export PATH=/opt/riscv/bin:$PATH
cd <ztachip installation folder>/SW/src
riscv32-unknown-elf-gdb ../build/ztachip.elf
```

### Upload procedure for ztachip running with micro-python integration (recommended)
Open another terminal, then issue commands below to upload the micropython image.

```
export PATH=/opt/riscv/bin:$PATH
cd <Micropython installation folder>/ports/ztachip_port
riscv32-unknown-elf-gdb ./build/firmware.elf
```

## Start the image transfer

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

Demonstration on how to run the demo is shown in this [video](https://www.youtube.com/watch?v=ng0nCEYE6fc&t=499s)

# Benchmark

Small LLM model performance running on edge devices is largely constrained by memory bandwidth. In these scenarios, a GPU offers minimal advantage because the compute cores spend most of their time waiting for memory operations to complete.

A more accurate metric for comparing performance is **tokens per second (TPS) per GB/s of memory bandwidth**.

#### Benchmark Results

The following data compares **ztachip** running on Arty hardware against the Raspberry Pi 4 and Raspberry Pi 5.

LLM performance can be divided into two distinct components:

* **Fixed Component:** Dominated by matrix multiplication and model weight transfers. This is the primary bottleneck and cost driver for edge AI applications, where long chat histories or large contexts are rarely used.
* **Variable Component:** Driven by attention mechanisms and softmax calculations across the context window. **ztachip's** with dedicated FPU computing unit, which matches context memory DDR transfer rates, this component remains memory-bound.

The comparison below isolates and focuses on the **fixed cost** component by utilizing shorter prompts and questions.

*(Data sourced from [arXiv:2511.07425v1](https://arxiv.org/html/2511.07425v1))*

| Platform | Performance (TPS) | Memory Bandwidth (MemBW) | Efficiency (TPS per GB/s) |
| :--- | :---: | :---: | :---: |
| **Raspberry Pi 4** | 11 TPS | 12 GB/s | 0.92 |
| **Raspberry Pi 5** | 32 TPS | 17 GB/s | 1.88 |
| **ztachip (Arty)** | 8 TPS | 1.2 GB/s | **6.70** |

---

## Conclusion

While the Raspberry Pi platforms achieve higher raw TPS due to significantly higher hardware specs, **ztachip** is vastly more efficient at utilizing available memory bandwidth.

* **7.2x more efficient** than the Raspberry Pi 4.
* **3.5x more efficient** than the Raspberry Pi 5.


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

Copy the generated image <ztachip>/SW/build/ztachip_sim.hex to folder where you run your simulator. 

This image will be loaded to the simulated memory.

Then compile all RTL codes below for simulation
```
HW/src
HW/platform/simulation
HW/simulation
HW/riscv/sim
```
The top component of your simulation is HW/simulation/main.vhd

Provide clock to main:clk

main:led_out should blink everytime a test result is passed.


# Contact

This project is free to use. You can open an issue or a discussion on github.
But for business consulting and support, please
 <a href="mailto:vuongdnguyen@hotmail.com?cc=&subject=Ztachip Support&body=Hi Vuong \n">contact us</a></p>
Follow ztachip on [Twitter](https://twitter.com/ztachip)

