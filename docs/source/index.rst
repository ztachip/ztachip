ztachip documentation
======================

.. raw:: html

   <div class="zta-hero">
     <p><strong>Multicore, Data-Aware, Embedded RISC-V AI Accelerator</strong>
     for edge inferencing on low-end FPGA devices or custom ASIC. Free and
     open source (MIT).</p>
     <p>
       <a href="https://github.com/ztachip/ztachip">View on GitHub</a>
       &nbsp;&middot;&nbsp;
       <a href="https://github.com/ztachip/ztachip/issues">Report an issue</a>
     </p>
   </div>

Acceleration provided by ztachip can be up to 20-50x compared with a
non-accelerated RISC-V implementation on many vision/AI tasks, and it
outperforms a RISC-V core equipped with a vector extension. An innovative
tensor processor hardware accelerates a wide range of tasks — from vision
primitives like edge detection, optical flow, motion detection and color
conversion, to running full TensorFlow AI models — rather than just a narrow
band of workloads such as convolution.

.. image:: https://github.com/ztachip/ztachip/raw/master/Documentation/images/ztachip_arch.png
   :alt: ztachip architecture
   :align: center
   :width: 100%

.. raw:: html

   <div class="zta-grid">
     <div class="zta-card">
       <h3>Hardware</h3>
       <p>Mcore scheduling processor, dataplane, scratch-pad memory, stream
       processor, and a Tensor Engine with 28x Pcores acting as a
       configurable systolic array.</p>
     </div>
     <div class="zta-card">
       <h3>Software</h3>
       <p>A C-like DSL compiler for the tensor processor, prebuilt vision/AI
       libraries, application examples, and a MicroPython port.</p>
     </div>
     <div class="zta-card">
       <h3>Runs on low-end FPGA</h3>
       <p>Demonstrated on the Arty A7-100T board, including a multitasking
       demo running object detection, edge detection, Harris-corner and
       motion detection simultaneously.</p>
     </div>
   </div>

This site renders the documents that live under ``Documentation/`` and
``micropython/`` in the `ztachip/ztachip
<https://github.com/ztachip/ztachip>`_ repository. Each page below pulls
directly from those source files, so editing a ``.md`` file in the repo and
re-running the docs build is all that's needed to update this site.

.. toctree::
   :maxdepth: 2
   :caption: Contents

   overview
   hardware_design
   programmer_guide
   visionai_guide
   micropython_guide
