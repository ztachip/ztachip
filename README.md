# ztachip

**A multicore, data-aware, embedded RISC-V AI accelerator for edge inference**

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE.md)
[![Documentation](https://img.shields.io/badge/docs-ztachip.github.io-blue.svg)](https://ztachip.github.io/)
[![Twitter](https://img.shields.io/badge/twitter-@ztachip-blue.svg)](https://twitter.com/ztachip)

ztachip accelerates vision and AI workloads on low-end FPGAs and custom ASICs, delivering
**20–50× the performance** of a non-accelerated RISC-V implementation — and outperforming
RISC-V cores with vector extensions.

Its tensor processor is deliberately general: the same hardware runs classic vision
operations such as edge detection, optical flow, motion detection and colour conversion,
full TensorFlow models, and transformer models for LLM and VLM inference. A tensor
programming model lets software exploit that parallelism without hardware expertise.

[▶ Watch the demo video](https://www.youtube.com/watch?v=ng0nCEYE6fc&t=499s)

![ztachip Architecture](./Documentation/images/ztachip_ai_agent.png)

---

## Contents

- [Documentation](#documentation)
- [What you need](#what-you-need)
- [Running the demo](#running-the-demo) — [1. Toolchain](#1-install-the-risc-v-toolchain) ·
  [2. Software](#2-build-the-ztachip-software) · [3. FPGA](#3-build-and-program-the-fpga) ·
  [4. Hardware](#4-connect-the-hardware) · [5. Models](#5-prepare-the-llm-models) ·
  [6. Load and run](#6-load-and-run)
- [Benchmark](#benchmark)
- [Simulation](#running-ztachip-in-simulation)
- [Porting](#porting-ztachip)
- [License and contact](#license-and-contact)

---

## Documentation

Full documentation — technical overview, hardware architecture, programmer's guides and the
MicroPython interface — is published at **[ztachip.github.io](https://ztachip.github.io/)**.

---

## What you need

**Hardware**

| Component | Notes |
| :--- | :--- |
| [Digilent Arty A7-100T](https://digilent.com/shop/arty-a7-artix-7-fpga-development-board/) | The reference FPGA board |
| [Digilent Pmod VGA](https://digilent.com/shop/pmod-vga-video-graphics-array/) | Display output |
| [Camera module](https://www.aliexpress.com/item/1005009373256992.html) | Vision input |

**Software** — Ubuntu, the free [Xilinx Vivado WebPACK](https://www.xilinx.com/support/download.html),
and these packages:

```bash
sudo apt-get install autoconf automake autotools-dev curl python3 \
    libmpc-dev libmpfr-dev libgmp-dev gawk build-essential \
    bison flex texinfo gperf libtool patchutils bc \
    zlib1g-dev libexpat-dev python3-pip

pip3 install numpy
```

---

## Running the demo

Six steps, from an empty machine to the demo running on the board:

| Step | What happens |
| :--- | :--- |
| [1. Toolchain](#1-install-the-risc-v-toolchain) | Install the RISC-V compiler |
| [2. Software](#2-build-the-ztachip-software) | Build the ztachip compiler, kernels and firmware |
| [3. FPGA](#3-build-and-program-the-fpga) | Build the bitstream and program it into flash |
| [4. Hardware](#4-connect-the-hardware) | Attach the camera and display, open the serial console |
| [5. Models](#5-prepare-the-llm-models) | Serve the quantized LLM models over TFTP |
| [6. Load and run](#6-load-and-run) | Load the firmware over JTAG and start it |

Throughout, `$ZTACHIP` refers to your ztachip checkout:

```bash
git clone https://github.com/ztachip/ztachip.git
export ZTACHIP=$PWD/ztachip
```

### 1. Install the RISC-V toolchain

Download the [prebuilt toolchain](https://github.com/ztachip/ztachip/releases/download/AI_agents/riscv.tar.gz)
and extract it into `/opt`:

```bash
sudo tar -xzvf riscv.tar.gz -C /
```

<details>
<summary>Or build the toolchain from source</summary>

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv32im --with-abi=ilp32
sudo make
```

</details>

The toolchain is installed under `/opt/riscv`. Add it to your path — every build step below
assumes it:

```bash
export PATH=/opt/riscv/bin:$PATH
```

### 2. Build the ztachip software

Build the compiler, the file system, the kernels and the software image:

```bash
cd $ZTACHIP/SW/compiler
make clean all

cd ../fs
python3 bin2c.py

cd ..
make clean all -f makefile.kernels
make clean all
```

**MicroPython (recommended).** Running ztachip under MicroPython gives you a Python interface
to the accelerator, and is the mode the demos below assume:

```bash
git clone https://github.com/micropython/micropython.git
cp -avr $ZTACHIP/micropython/ztachip_port micropython/ports/

cd micropython/ports/ztachip_port
export ZTACHIP=$ZTACHIP
make clean
make
```

### 3. Build and program the FPGA

Create the Vivado project, build the FPGA image and program it into flash by following the
[FPGA build procedure](Documentation/Vivado.md).

### 4. Connect the hardware

Attach the VGA and camera modules to the Arty A7 board:

![Arty A7 Board](Documentation/images/arty_board.bmp)

![Camera connected to Arty A7](Documentation/images/camera_and_arty_connect.bmp)

Open the serial console provided over the board's USB interface, with **flow control
disabled**:

```bash
sudo minicom -w -D /dev/ttyUSB1
```

> **First connection:** reset the board with the button next to the USB port and wait for the
> green LED. The USB serial interface must connect before ztachip does.

### 5. Prepare the LLM models

The demo loads its models over TFTP. Run a TFTP server on the PC interface connected to the
board, with the interface addressed as `10.10.10.10`, and place both model files in its
download directory:

- [SMOLLM2.ZUF](https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLLM2.ZUF)
- [SMOLFC.ZUF](https://github.com/ztachip/ztachip/releases/download/AI_agents/SMOLFC.ZUF)

These are quantized versions of the LLM models; see the
[model quantization procedure](Documentation/QuantizeProcedure.md) to produce your own.

### 6. Load and run

The firmware is loaded over JTAG with GDB, using OpenOCD for the connection.

**Build OpenOCD** (once):

```bash
sudo apt-get install libtool automake libusb-1.0.0-dev \
    texinfo libusb-dev libyaml-dev pkg-config

git clone https://github.com/SpinalHDL/openocd_riscv
cd openocd_riscv
./bootstrap
./configure --enable-ftdi --enable-dummy
make

cp $ZTACHIP/tools/openocd/{soc_init.cfg,usb_connect.cfg,xilinx-xc7.cfg,jtagspi.cfg,cpu0.yaml} .
```

**Start OpenOCD** and leave it running. The green LED below the reset button must be on,
confirming the FPGA is configured:

```bash
sudo src/openocd \
    -f usb_connect.cfg \
    -c 'set MURAX_CPU0_YAML cpu0.yaml' \
    -f soc_init.cfg
```

**Load the firmware** from a second terminal:

```bash
export PATH=/opt/riscv/bin:$PATH

# MicroPython mode (recommended)
cd <micropython>/ports/ztachip_port && riscv32-unknown-elf-gdb ./build/firmware.elf

# or bare-metal mode
cd $ZTACHIP/SW/src && riscv32-unknown-elf-gdb ../build/ztachip.elf
```

At the GDB prompt:

```gdb
set pagination off
target remote localhost:3333
set remotetimeout 60
set arch riscv:rv32
monitor reset halt
load
continue
```

**Then, on the board:**

- **MicroPython mode** — in the serial console press <kbd>Ctrl</kbd>+<kbd>E</kbd>, paste one of the
  [example programs](micropython/examples), and press <kbd>Ctrl</kbd>+<kbd>D</kbd> to run it.
  Any button stops it and returns to the Python console.
- **Bare-metal mode** — press any button to step through the vision and LLM demos.

The [demo video](https://www.youtube.com/watch?v=ng0nCEYE6fc&t=499s) walks through this whole
sequence.

---

## Benchmark

Small LLM inference at the edge is constrained by **memory bandwidth**, not compute: extra
processing power buys little when the cores spend their time waiting for model weights. The
meaningful metric is therefore **tokens per second per GB/s of memory bandwidth**.

The comparison below focuses on the fixed cost of inference — matrix multiplication and weight
transfers — using short prompts. Raspberry Pi figures are from
[arXiv:2511.07425v1](https://arxiv.org/html/2511.07425v1).

| Platform | Performance | Memory Bandwidth | Efficiency |
| :--- | ---: | ---: | ---: |
| Raspberry Pi 4 | 11 TPS | 12 GB/s | 0.92 TPS/(GB/s) |
| Raspberry Pi 5 | 32 TPS | 17 GB/s | 1.88 TPS/(GB/s) |
| **ztachip (Arty)** | 8 TPS | 1.2 GB/s | **6.70 TPS/(GB/s)** |

The Raspberry Pi boards generate more tokens per second outright, because they have far more
hardware and bandwidth to draw on. But ztachip extracts **7.2× more work per unit of bandwidth
than the Pi 4 and 3.5× more than the Pi 5** — which is what matters on low-cost edge platforms,
where bandwidth and power run out long before compute does.

Inference also has a variable component, dominated by attention and softmax over the context
window. ztachip's dedicated FPU processes those at the rate DDR can feed it, keeping that part
memory-bound too.

---

## Running ztachip in simulation

Build the simulation image from the test applications in `SW/apps/test` and `SW/sim`:

```bash
export PATH=/opt/riscv/bin:$PATH

cd $ZTACHIP/SW/compiler
make clean all

cd ..
make clean all -f makefile.kernels
make clean all -f makefile.sim
```

Copy the resulting memory image, `SW/build/ztachip_sim.hex`, into the directory you run the
simulator from; it is loaded into simulated memory at startup.

Compile the RTL from `HW/src`, `HW/platform/simulation`, `HW/simulation` and `HW/riscv/sim`.
The top-level component is `HW/simulation/main.vhd`: drive `main:clk`, and `main:led_out`
blinks once per passing test.

---

## Porting ztachip

ztachip is designed to be moved to other hardware. See the
[porting procedure](Documentation/PortProcedure.md) for taking ztachip and its applications to
other **FPGA, ASIC and SoC platforms**.

---

## License and contact

ztachip is open source — hardware and software — under the [Apache 2.0 license](LICENSE.md).

For questions, bug reports and feature requests, open an
[issue](https://github.com/ztachip/ztachip/issues) or start a
[discussion](https://github.com/ztachip/ztachip/discussions). For business consulting and
support, [contact us](mailto:vuongdnguyen@hotmail.com?subject=Ztachip%20Support).
