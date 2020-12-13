This document summarizes the current status of ztachip. And future directions...

# Benchmark results

ztachip performance metrics are compared against the 2 popular AI edge platforms: Nvidia's Jetson Nano and Google TPU Edge.

## Computing efficiency

Computing efficiency is important since it indicates how much work you can extract out from your available computing units. A high computing efficiency results in lower die size/cost and lower power consumption.

For benchmarking, we use the performance metrics of running object detection AI model SSD-Mobinet since this is a good size AI model and this model is very useful in many vision applications.

Since ztachip in this example runs on a low end FPGA with a low number computing blocks available, a better comparison for computing utilization efficiencies would be fps performance divided by peek performance. A higher score would indicate how efficient the available computing resources are being utilized.

   - ztachip: SSD-Mobinet benchmark=9fps, max available computing resources=20 GOPS

   - Nvidia Nano: SSD-Mobinet benchmark=39fps, max available computing resources=472 GOPS

   - Google TPU Edge: SSD-Mobinet benchmark=48fps, max available computing resources=4000 GOPS

When combining the benchmark above, ztachip is 5.5x more computational efficient than Jetson Nano and 37x more computational efficient than TP
U Edge.

## Hardware efficiency

This metrics says how much silicon area are required for control logic overhead inorder to support the computing unit blocks.

With ztachip, this metrics gets better at higher vector width. For example at 64 bit vector width, computing takes about 30% and control about 70%. But at wider vector width such as 1024 bit, computing can take up to 90% while control logic takes only 10%.

## Memory bandwidth efficiency

Data transfer in the provided examples are often > 50% from peek data transfer performance.

MCORE programming overlay data transfer cycles with execution cycles, resulting in zero-delay data transfer.

Data transfers are almost always done in vector block transfer in the examples provided.

# Progammability

There are many [examples](https://github.com/ztachip/ztachip/tree/master/examples) provided that show how ztachip can be used to accelerate not just for AI applications but many vision tasks as well.

Unlike some ASIC solutions such as TPU edge, ztachip is fully programmable for any custom applications. The project comes with all necessary tools and compiler to build custom applications.

ztachip also comes with an AI stack and vision stack to help you jump start with your vision AI edge applications.

# Port to ASIC for better performance and lower power consumption

Assuming a 4x performance gain when converting from FPGA to ASIC, according to performance analysis above, ASIC version of ztachip should have performance comparable with Nvidia's Jetson Nano but with a much lower transistor count and power consumption.

# Future releases

Future releases with larger vector width support will have much higher performance.

# Conclusions

ztachip hardware architecture and its tensor programming paradigm provides good performance metrics.

In addition, ztachip programming paradigm is shown by examples to be flexible enough to be used to accelerate a large class of applications in AI and many popular vision processing tasks.

In more abstract term, ztachip is a promising framework for Domain Specific Architecture where the domain is a large class of applications that can be expressed in terms of ztachip's Tensor Programming Paradigm.



