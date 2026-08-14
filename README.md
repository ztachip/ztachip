# ztachip

**A Multicore, Data-Aware, Embedded RISC-V AI Accelerator for Edge Inference**

ztachip is a multicore, data-aware embedded RISC-V AI accelerator designed for edge inference on low-end FPGAs and custom ASICs.

ztachip can deliver **20–50× acceleration** over non-accelerated RISC-V implementations on many vision and AI workloads, including LLM inference. It can also outperform RISC-V processors equipped with vector extensions.

Its innovative tensor processor accelerates a broad range of workloads—from traditional computer-vision operations such as edge detection, optical flow, motion detection, and color conversion to TensorFlow AI models and LLM inference. Unlike accelerators designed for only a narrow class of applications, ztachip provides a more general-purpose acceleration architecture for edge AI and vision workloads.

A new tensor programming paradigm enables developers to efficiently exploit the massive processing and data parallelism available in the ztachip architecture.

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
