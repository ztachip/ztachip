<style>
pre { background:#e4e6e8 !important;
      padding:12px 14px; border:1px solid #d8dce0; border-radius:6px; }

/* Base: the highlighter paints tokens with the editor theme, which on a dark
   theme is far too light for this grey. Everything starts near-black ... */
pre, pre code, pre span, pre * {
      background:transparent !important; color:#1f2328 !important; }

/* ... then the token classes take over, in a palette meant for a light
   background. These are more specific, so they win over the rule above. */
pre code .hljs-comment, pre code .hljs-quote {
      color:#6a737d !important; font-style:italic; }
pre code .hljs-keyword, pre code .hljs-selector-tag,
pre code .hljs-literal, pre code .hljs-doctag {
      color:#d73a49 !important; }
pre code .hljs-string, pre code .hljs-meta-string,
pre code .hljs-regexp { color:#032f62 !important; }
pre code .hljs-number, pre code .hljs-built_in,
pre code .hljs-type, pre code .hljs-variable,
pre code .hljs-template-variable { color:#005cc5 !important; }
pre code .hljs-title, pre code .hljs-section,
pre code .hljs-function .hljs-title { color:#6f42c1 !important; }
pre code .hljs-meta, pre code .hljs-meta-keyword {
      color:#e36209 !important; }
pre code .hljs-attr, pre code .hljs-attribute,
pre code .hljs-name { color:#22863a !important; }
pre code .pl-c, pre code .pl-c span {
      color:#6a737d !important; font-style:italic; }
pre code .pl-k { color:#d73a49 !important; }
pre code .pl-s, pre code .pl-s span, pre code .pl-pds {
      color:#032f62 !important; }
pre code .pl-c1, pre code .pl-cce { color:#005cc5 !important; }
pre code .pl-en, pre code .pl-entl { color:#6f42c1 !important; }

/* inline code: !important so a dark editor theme cannot repaint it */
code { background:#e4e6e8 !important; color:#1f2328 !important;
       padding:1px 4px; border-radius:4px; }

/* tables need visible rules on the white page */
table { border-collapse:collapse !important; margin:6px 0 14px 0; }
table th, table td { border:1px solid #c9ced4 !important;
       padding:6px 10px !important; }
table th { background:#eef1f4 !important; color:#1f2328 !important;
       text-align:left; }
table tr, table tbody tr:nth-child(2n) {
       background:#ffffff !important; color:#1f2328 !important; }
</style>

<div style="background:#ffffff; color:#24292f; padding:0 24px;">

<a href="index.md" style="display:inline-block; margin:14px 0; padding:5px 12px; background:#eef1f4; color:#24292f; border:1px solid #c9ced4; border-radius:5px; text-decoration:none; font-size:13px;">&#8592; Home</a>

# 1. Abstract

The recent explosion in AI creates an almost limitless demand for computing power.
AI workload is especially challenging since it is demanding in both computing power
and memory bandwidth.

In addition, AI deployed at the edge also demands very low power.

It is generally agreed in the computing community that the way forward is that we
need a special architecture for this kind of workload. This is formally known as
Domain-Specific-Architecture (DSA).

ztachip is one such DSA particularly optimized for vision and AI workload.

# 2. Challenges

DSA also presents many challenges including

1. DSA is designed for a special set of applications in exchange for higher efficiencies.
However, we would like the DSA domain to be as diverse as possible while still benefiting
from a more efficient hardware implementation.

2. DSA implies both a special hardware and software architecture for a particular domain of applications.
How can we present DSA concepts without requiring users to have cross-disciplined knowledge?
It will be difficult to find software engineers that are also knowledgeable in hardware design.

The most common DSA used today is the Systolic-Array (SA).
SA maps very well to many important math operations required in AI, namely
matrix multiplication, dot product, convolution...

![systolic](images/systolic.bmp)

However, SA is also very difficult to program. Users of SA often rely on prebuilt
libraries provided by hardware vendors. Training/research AI workload that requires custom algorithm
implementation is therefore not suitable for SA.

SA is also not flexible enough to adapt to a wider range of applications. For example,
most ASICs with SA still require a powerful CPU and GPU to perform other
tasks such as vision preprocessing. For many edge AI applications involving vision,
the vision preprocessing steps are often just as computing intensive as the AI steps.

# 3. DSA with ztachip

ztachip is an opensourse DSA architecture. It is a novel architecture as far as we
know.

The primary objective for ztachip is to provide DSA that covers a wide range of
applications and not just for AI. DSA programming with ztachip should also be intuitive
and simple.

ztachip targets applications that can be expressed as a sequence of tensor operations.
Tensor operations include data operation and computing operation. Data operations involving
tensors may also involve complex operations such as tensor transpose, tensor dimension resize,
data remapping, etc...

**Typical sequence of a ztachip application**

```
TENSOR_A <= DATA_TRANSFORMATION <= TENSOR_B

TENSOR_OPERATOR(TENSOR_A)

TENSOR_B <= DATA_TRANSFORMATION <= TENSOR_A
:
:
```

The reason for the above constraints is that we would like data plane operations to be
decoupled from computing operations. Tensor data operations are used to moved
data between external memory and internal memory. And tensor computing operations are performed
strictly from internal memory only. This strategy provides many advantages to the hardware
design including

- Memory transfer to/from external memory is streaming with prefetching and without round trip delay

- Tensor data operations specify exactly the data required for later execution. This
eliminates the need for caching.

- Computing operations are presented as tensor operators. This is an intuitive way
to specify algorithm parallelism. Many hardware threads can then be mapped to a large number
of parallel tasks. For example with vector addition, each element-wise addition can be mapped to a thread.

- Tensor computing involves only with internal memory, greatly simplifying
the hardware design since there is no memory stall cycles to contend with.

# 4. What are provided with ztachip

ztachip provides the following DSA components:

- Hardware stack with all the RTL source codes that can be ported to different
FPGA and ASIC.

- A compiler to implement the necessary Domain Specific Language (DSL) to
hide the complexities from users. This means software engineers don't have to know
about the hardware aspects and the same software can then be ported to different
hardware with different capacities with just a recompilation

- Software stack is provided that implements many vision and AI algorithms. Native support
for TensorFlow without retraining is also provided.

![dsa_component](images/dsa_component.bmp)

# 5. Results

The 2 metrics of interest are domain coverage and performance.

## 5.1 Domain coverage

For domain coverage, ztachip's DSL has been proven on a wide range of applications,
from transformer models through to vision preprocessing and classic AI tasks.

- Transformer models for LLM (Large Language Model) and VLM (Vision Language Model) inference.

- Image classification with TensorFlow's Mobinet AI model.

- Object detection with TensorFlow's SSD-Mobinet AI model.

- Edge detection using Canny algorithm

- Color space (RGB/YUYV) conversion

- Equalizer for contrast enhancement

- Gaussian convolution for image blurring

- Harris Corner Detection algorithm, commonly used by robotic SLAM also.

- Optical flow algorithm to detect motion

- Image resizing

## 5.2 Performance and power consumption

Performance is also very promising. Using the popular Mobinet-SSD AI model as a reference point,
ztachip achieves a performance of 10fps at a 20GOPS of hardware computing resource.

Compared with Nvidia Jetson Nano, it has a performance of 40fps but with a computing hardware resource at 500GOPS.

Therefore ztachip has a 6x better computing resource utilization than Nvidia in this case, resulting in much lower
power consumption.

Memory requirements for ztachip are also much lower due to the efficient use of memory.

# 6. Future developments

ztachip current implementation operates on vector data types (8 x 8/12/16-bit).

The logical next step is for native support of matrix data types (8 x 8 x 8/12/16-bit).

ALU (Arithmetic Logical Units) sub-system is extended from a 8 unit wide vector of ALU units to a 8x8 matrix of ALU units. This will provide an 8x improvement in computing density when bus width is limited to 8 data elements. An improvement of 32x from current implementation is possible when bus width is extended to 16 data elements.

To provide an intuitive programming syntax to support matrix data types.


</div>
