# ztachip Documentation

A multicore, data-aware, embedded RISC-V accelerator for edge vision and AI inference.
Fully open source — hardware and software — under the Apache 2.0 license.

### [Getting Started: Running a Vision/AI Demo on Artix-7 FPGA](GettingStarted.md)

Everything needed to see ztachip working on real hardware: building the software
and the RISC-V toolchain, building the FPGA image, wiring up the camera and VGA
modules on a Digilent Arty A7 board, and loading and running the vision and LLM
demos.

### [Technical Overview](Overview.md)

What ztachip is, the problem it solves and what it achieves. Explains why a
domain-specific architecture is needed for edge AI, what the project provides,
and how it compares on performance and power.

### [Hardware Architecture](HardwareDesign.md)

How the hardware is put together, component by component: the tensor processor
that coordinates everything, the engines that move tensor data to and from
memory, the floating point unit, and the array of VLIW cores that do the
arithmetic. Each component links to its RTL source.

### [Programmer's Guide](ztachip_programmer_guide.md)

How to program ztachip directly, in its own tensor language. Covers describing
data as tensors, moving them between memories, and running operators on them,
plus the pcore programs that define those operators, with complete worked
examples.

### [VisionAI Stack Programmer's Guide](visionai_programmer_guide.md)

How to build vision and AI applications by connecting ready-made processing
nodes into a graph. The nodes cover edge detection, colour conversion, resizing,
optical flow, TensorFlow models and transformer models for LLM and VLM
inference, and custom nodes can be added alongside them.

### [MicroPython Programmer's Guide](../micropython/MicropythonUserGuide.md)

How to build those same applications from Python, using the same graph of nodes
and tensors. The simplest way to use ztachip: a few lines of Python drive the
accelerator at full speed, with no hardware knowledge required, just Python
skills.
