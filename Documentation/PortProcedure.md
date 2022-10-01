# How to port to other FPGA or ASIC


Porting HDL codes


- Depending on your FPGA/ASIC capacity, update pid_gen_max_c [here](HW/src/config.vhd) to be 8 for large version or 4 for small version


- Compile all files under [here](HW/src). They are generic VHDL codes without any special primitives so it is ready to be ported to any FPGA/ASIC


- Have a version of [wrapper library](HW/platform) for your FPGA/ASIC. There are 4 components that you need to map to your FPGA/ASIC library. They are just some basic memory block primitives so any FPGA/ASIC toolchain would have them. There is also a [wrapper version for simulation](HW/platform/simulation) that you can reference for expected behaviour.


- ztachip is simply connected to your SOC as an AXI peripheral. Reference [here](HW/examples/GHRD/main.v) as example on how to integrate ztachip to your design.


Porting Software stack


- Update NUM_PCORE [here](SW/base/zta.h) to be 8 for large version and 4 for small version. This must be the same value as pid_gen_max_c configured above


- Update MEM_MAP [here](SW/base/zta.h) to be the memory map address that you map ztachip to on your AXI bus.


- Update linker file [linker.ld](SW/linker.ld) to match your SOC DDR memory size. The important parameters are RAM,_heap_size,_stack_size


- Update [boot loader](SW/base/crt.S) if your SOC has any special bootloading method. In the provided example, the boot loader is simple since it expected code/data to be loaded via JTAG already.


- Update [FLUSH_DATA_CACHE macro](SW/src/soc.h) if you were to use other Riscv implementation besides [VexRiscv](https://github.com/SpinalHDL/VexRiscv). This macro is required occassionally to keep ztachip memory coherent with riscv. Unfortunately cache flushing is not well defined in riscv specs and different riscv implementation
may have different method.


- Your SOC may have different peripherals with new drivers to be implemented. All peripheral interfaces to be implemented are [here](SW/src/soc.cpp)


- Recompile everything including compiler
 

