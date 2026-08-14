# ztachip

**An open-source AI accelerator for edge devices — computer vision and AI inference, including state-of-the-art LLM/VLM models, on a low-cost FPGA or a custom ASIC**

ztachip is an AI accelerator for **RISC-V** running on edge devices. It is built
primarily for **FPGAs** — programmable chips you configure yourself, so no chip
fabrication is involved and a low-cost development board is all you need to get
started. Attach a camera and a VGA display to an Artix-7 board, load the image,
and it runs real workloads: edge detection, optical flow, motion detection and
colour conversion, TensorFlow models, and large vision/language models, with
nothing sent to a server. The same design can also be taken into a **custom
ASIC**, for advanced users with the resources for it.

What makes it interesting is efficiency rather than peak speed. Modern AI
inference with LLM/VLM at the edge is limited by memory bandwidth, not compute —
the cores spend most of their time waiting for model weights to arrive from
memory. ztachip is built around moving that data well, which is what *data-aware*
means in practice. It is **3.5× more efficient than a Raspberry Pi 5** in how well
it uses the memory bandwidth available to it.

It is also general-purpose within its domain. Most accelerators handle one narrow
class of workload; ztachip runs classical computer vision, neural-network
inference and transformer models on the same hardware, through the same
programming model.

It is easy to program and use. A few lines of MicroPython are enough to run
vision or state-of-the-art AI on it — no hardware knowledge required, just
Python.

Everything is open source under the Apache 2.0 license — RTL, compiler, software
stack and demos.

[▶ Watch the demo video](https://www.youtube.com/watch?v=ng0nCEYE6fc&t=499s)

![ztachip Architecture](./Documentation/images/ztachip_ai_agent.png)

---

# Documentation

See the **[ztachip Documentation](https://ztachip.github.io/)** for the technical overview, hardware architecture, programmer's guides and the MicroPython interface.

---

# Getting Started

**[Getting started with the demo on Artix-7 FPGA](https://ztachip.github.io/GettingStarted.html)** —
build the software and the FPGA image, connect the camera and VGA modules to a
Digilent Arty A7 board, and run the vision and LLM demos. The guide also reports
the benchmark results measured on that board.

The Arty A7 is the reference platform, not the only one. The same guide covers
the other two ways to run ztachip:

- **Porting to another FPGA, ASIC or SoC** — what to change in the hardware stack
  (platform configuration, wrapper library, top-level component) and in the
  software stack (core count, linker file, boot loader, peripheral drivers).
- **Running in simulation** — build the simulation image and run the example test
  programs under an RTL simulator, with no hardware at all.

---

# Contact

ztachip is free to use as an open-source project.

For technical questions, bug reports, feature requests, or general discussion, please open an **Issue** or start a **Discussion** on GitHub.

For business consulting and support, please [contact us](mailto:vuongdnguyen@hotmail.com?subject=Ztachip%20Support).

Follow ztachip on [Twitter](https://twitter.com/ztachip).
