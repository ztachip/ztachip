<div style="background:#ffffff; color:#24292f; padding:0 24px 24px 24px;">

<div style="background:#d6e8ff; color:#0b2545; padding:16px; border-radius:8px; text-align:center; font-weight:bold; font-size:20px; line-height:1.35; margin:16px 0 6px 0;">ztachip Documentation</div>

<p style="text-align:center; color:#57606a; margin:0 0 22px 0;">A multicore, data-aware, embedded RISC-V accelerator for edge vision and AI inference.<br>Fully open source &#8212; hardware and software &#8212; under the Apache 2.0 license.</p>

<a href="Overview.md" style="display:block; text-decoration:none; background:#f6f8fa; border:1px solid #c9ced4; border-left:6px solid #0a6abf; border-radius:8px; padding:14px 18px; margin-bottom:12px;">
  <span style="display:block; color:#0a4a8f; font-weight:bold; font-size:16px; margin-bottom:5px;">Technical Overview &#8594;</span>
  <span style="display:block; color:#41484f; font-size:13px; line-height:1.55;">What ztachip is, the problem it solves and what it achieves. Explains why a domain-specific architecture is needed for edge AI, what the project provides, and how it compares on performance and power.</span>
</a>

<a href="HardwareDesign.md" style="display:block; text-decoration:none; background:#f6f8fa; border:1px solid #c9ced4; border-left:6px solid #0a6abf; border-radius:8px; padding:14px 18px; margin-bottom:12px;">
  <span style="display:block; color:#0a4a8f; font-weight:bold; font-size:16px; margin-bottom:5px;">Hardware Architecture &#8594;</span>
  <span style="display:block; color:#41484f; font-size:13px; line-height:1.55;">How the hardware is put together, component by component: the tensor processor that coordinates everything, the engines that move tensor data to and from memory, the floating point unit, and the array of VLIW cores that do the arithmetic. Each component links to its RTL source.</span>
</a>

<a href="ztachip_programmer_guide.md" style="display:block; text-decoration:none; background:#f6f8fa; border:1px solid #c9ced4; border-left:6px solid #0a6abf; border-radius:8px; padding:14px 18px; margin-bottom:12px;">
  <span style="display:block; color:#0a4a8f; font-weight:bold; font-size:16px; margin-bottom:5px;">Programmer's Guide &#8594;</span>
  <span style="display:block; color:#41484f; font-size:13px; line-height:1.55;">How to program ztachip directly, in its own tensor language. Covers describing data as tensors, moving them between memories, and running operators on them, plus the pcore programs that define those operators, with complete worked examples.</span>
</a>

<a href="visionai_programmer_guide.md" style="display:block; text-decoration:none; background:#f6f8fa; border:1px solid #c9ced4; border-left:6px solid #0a6abf; border-radius:8px; padding:14px 18px; margin-bottom:12px;">
  <span style="display:block; color:#0a4a8f; font-weight:bold; font-size:16px; margin-bottom:5px;">VisionAI Stack Programmer's Guide &#8594;</span>
  <span style="display:block; color:#41484f; font-size:13px; line-height:1.55;">How to build vision and AI applications by connecting ready-made processing nodes into a graph. The nodes cover edge detection, colour conversion, resizing, optical flow, TensorFlow models and transformer models for LLM and VLM inference, and custom nodes can be added alongside them.</span>
</a>

<a href="../micropython/MicropythonUserGuide.md" style="display:block; text-decoration:none; background:#f6f8fa; border:1px solid #c9ced4; border-left:6px solid #0a6abf; border-radius:8px; padding:14px 18px; margin-bottom:12px;">
  <span style="display:block; color:#0a4a8f; font-weight:bold; font-size:16px; margin-bottom:5px;">MicroPython Programmer's Guide &#8594;</span>
  <span style="display:block; color:#41484f; font-size:13px; line-height:1.55;">How to build those same applications from Python, using the same graph of nodes and tensors. The simplest way to use ztachip: a few lines of Python drive the accelerator at full speed, with no hardware knowledge required, just Python skills.</span>
</a>

</div>
