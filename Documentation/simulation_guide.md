# Simulation User Guide

This guide describes the steps involved in running ztachip in simulation mode.

Simulation mode is important during hardware development.

## Simulation steps

Application program is simulated with tcl script [ztachip/hardware/simulation/host.tcl](https://github.com/ztachip/ztachip/blob/master/hardware/simulation/host.tcl)

MCORE and PCORE programs being simulated are [hardware/simulation/software/mcore.m](https://github.com/ztachip/ztachip/blob/master/hardware/simulation/software/mcore.m) and [hardware/simulation/software/pcore.p](https://github.com/ztachip/ztachip/blob/master/hardware/simulation/software/pcore.p)

The example provided is a simple vector addition by 1. 

You can modify these 3 files to fit your test requirements.

To simulate, following the steps below...

- Complete [Software Build Procedure](https://github.com/ztachip/ztachip/blob/master/Documentation/BuildProcedure.md)

  This will also build the ztachip image used during simulation.

- Open ModelSim program. This comes with Intel Quartus Development Suite installation.

- Open project file ztachip/hardware/simulation/ztachip.mpf

- Click Compile->Compile All

- Open View window by making sure View->Wave option is checked.

- Click Simulate->Start Simulation. Then open work/testbench component

- Click Tools->Tcl->Execute Macros then open ztachip/hardware/simulation/host.tcl

## TCL script supporting library

Application programs in simulation are TCL scripts. 

ztachip provides a library [sim.tcl](https://github.com/ztachip/ztachip/blob/master/hardware/simulation/sim.tcl) for available functions that can be called from TCL script.

Below are TCL script library functions

### ztaInit(fname)

This is the first function to call to initialize ztachip

- fname: ztachip binary image. In the provided example, this is located at ztachip/software/target/builds/ztachip_sim.hex

### ztaMemWriteInt32(addr,value)

Write a 32-bit integer value to simulated DDR memory

- addr: byte address of simulate DDR memory

- value: value to be written to simulated DDR memory.

### ztaMemWriteInt16(addr,value)

Write a 16-bit integer value to simulated DDR memory

- addr: byte address of simulate DDR memory

- value: value to be written to simulated DDR memory.

### ztaMemWriteInt8(addr,value)

Write a 8-bit integer value to simulated DDR memory

- addr: byte address of simulate DDR memory

- value: value to be written to simulated DDR memory.

### ztaMemReadInt32(addr)

Read a 32-bit integer from simulated DDR memory

- addr: byte address of simulated DDR memory to be read.

### ztaMemReadInt16(addr)

Read a 16-bit integer from simulated DDR memory

- addr: byte address of simulated DDR memory to be read.

### ztaMemReadInt8(addr)

Read a 8-bit integer from simulated DDR memory

- addr: byte address of simulated DDR memory to be read.

### ztaMsgWriteInt

Put an integer to the first message queue

### ztaMsgReadInt

Read an integer from the first message queue.


