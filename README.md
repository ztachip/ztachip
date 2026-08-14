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
Digilent Arty A7 board, and run the vision and LLM demos.

---

# Benchmark

Small LLM inference performance on edge devices is largely constrained by **memory bandwidth**. In these scenarios, additional compute capability provides limited benefit when processing cores spend most of their time waiting for model data to be transferred from memory.

For this reason, a useful metric for comparing edge LLM implementations is:

**Tokens per second (TPS) per GB/s of memory bandwidth**

## Benchmark Results

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

## Conclusion

The Raspberry Pi platforms achieve higher raw token-generation rates because they provide substantially higher overall hardware and memory-bandwidth resources.

However, **ztachip achieves significantly higher utilization of the available memory bandwidth**:

- **7.2× more efficient** than the Raspberry Pi 4
- **3.5× more efficient** than the Raspberry Pi 5

This efficiency is particularly important for low-cost and resource-constrained edge AI platforms, where memory bandwidth and power are often more limited than compute capability.

---

# Run ztachip in Simulation

First, build the example test program used for simulation.

The example test applications are located under:

```text
SW/apps/test
SW/sim
```

Build the simulation image:

```bash
export PATH=/opt/riscv/bin:$PATH

cd ztachip

cd SW/compiler
make clean all

cd ..
make clean all -f makefile.kernels
make clean all -f makefile.sim
```

The generated simulation memory image is:

```text
<ztachip>/SW/build/ztachip_sim.hex
```

Copy this file into the directory where you run your simulator.

The image will be loaded into the simulated memory.

Compile the RTL sources from the following directories:

```text
HW/src
HW/platform/simulation
HW/simulation
HW/riscv/sim
```

The top-level simulation component is:

```text
HW/simulation/main.vhd
```

Provide a clock to:

```text
main:clk
```

The following output should blink each time a test successfully passes:

```text
main:led_out
```

---

# Contact

ztachip is free to use as an open-source project.

For technical questions, bug reports, feature requests, or general discussion, please open an **Issue** or start a **Discussion** on GitHub.

For business consulting and support, please [contact us](mailto:vuongdnguyen@hotmail.com?subject=Ztachip%20Support).

Follow ztachip on [Twitter](https://twitter.com/ztachip).
