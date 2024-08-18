# How to port to other FPGA,ASIC and SOC

The example provided with this repo is meant to be reference design and it is implemented on the Arty-A7 development kit from Digilent and based on Xilinx Artix-7 FPGA. However ztachip, both SW and HW stack, can be ported to any FPGA/ASIC and SOC platform based on the procedure described below. 

## Porting Hardware stack

- Update [HW/src/config.vhd](../HW/src/config.vhd) to match your platform/FPGA capabilties such as resource availability, memory block size, SDRAM bus width.

- Compile all files under [HW/src](../HW/src). They are generic VHDL codes without any special primitives so it is ready to be ported to any FPGA/ASIC

- Have a version of [wrapper library](../HW/platform) for your FPGA/ASIC. There are 6 components that you need to map to your FPGA/ASIC library. They are mostly just some basic memory block primitives so any FPGA/ASIC toolchain would have them. There is also a [wrapper version for simulation](../HW/platform/simulation) that you can reference for expected behaviour.

- Reference [HW/examples/GHRD/main.v](../HW/examples/GHRD/main.v). This is the top component of the reference design. Base on this example to implement the top component for your design. 


## Porting Software stack

- Update NUM_PCORE in [SW/base/zta.h](../SW/base/zta.h) to be 8 for large version and 4 for small version. This must be the same value as pid_gen_max_c configured in [HW/src/config.vhd](../HW/src/config.vhd) 

- Update linker file [SW/linker.ld](../SW/linker.ld) to match your SOC DDR memory size. The important parameters are RAM,_heap_size,_stack_size

- Update boot-loader [SW/base/crt.S](../SW/base/crt.S) if your SOC has any special bootloading method. In the provided example, the boot loader is simple since it expects code/data to be already loaded by JTAG before execution begins.

- Your SOC may have different peripherals with new drivers to be implemented. All peripheral drivers are implemented in [SW/src/soc.cpp](../SW/src/soc.cpp)

- Refer [here](HW/riscv/README.md) if you like to use a different RISCV implementation. ztachip by default uses [VexRiscv](https://github.com/SpinalHDL/VexRiscv)



