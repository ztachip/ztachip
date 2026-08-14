# Installing Vivado Free WebPACK Edition

Vivado WebPACK edition is a free IDE for the Artix7 FPGA family.

[Installing Vivado WebPACK edition](https://www.xilinx.com/support/download.html)

# Create project file

Launch Vivado

On the TCL console command line, issuing the following commands

```
cd <ztachip installation folder>/HW/examples/GHRD
set argv linux # For Linux Only
source create_project.tcl
```

A project file ztachip.xpr should be created after the completion of the execution of create_project.tcl.


# Build and flash procedure. 

Open Vivado project file ztachip/HW/examples/GHRD/ztachip.xpr

Then start with synthesis step as shown below

![vivado step1](images/vivado_step1.bmp)

After the synthesis step has been completed, Vivado will prompt you to continue with Implementation step. Choose the option and click OK.

![vivado step2](images/vivado_step2.bmp)

After Implementation step has been completed, Vivado will prompt you to continue with Bitstream Generation step. Choose the option and click OK. 

![vivado step3](images/vivado_step3.bmp)

After the Bitstream Generation step has been completed, Vivado will prompt you to Open Hardware Manager. Choose the option and click OK.

![vivado step4](images/vivado_step4.bmp)

Make sure your board is connected to PC with provided USB cable by Arty Development package.

From Hardware Manager, connect to target as shown below 

![vivado step5](images/vivado_step5.bmp)

On the left panel, click on "Add Configuration Memory Device" menu option and then choose to create the flash device as shown below

![vivado step5](images/vivado_step5_1.bmp)

Then program the board as shown below. The image to be flashed is ztachip/HW/examples/GHRD/ztachip.runs/impl_1/main.bin

If the file is not there, verify that -bin option is selected under Project Settings/Bitstream and then rerun the BitStream Generation step.

![vivado step7](images/vivado_step7.bmp)

That's it. Your board's FPGA will be programmed with the new image automatically after power reboot.

# Support for open-source toolchain

Open-source toolchains normally support only Verilog.

You can convert ztachip rtl to verilog using ghdl

Install [GHDL](https://github.com/ghdl/ghdl)

Then convert RTL code from VHDL to verilog with command below

```
cd <ztachip folder>/tools/ghdl
./convert.sh
```

All vhdl code will be converted and combined to a single file tools/ghdl/soc.v

As an example for all verilog project, create Vivado project but using [create_project2.tcl](../HW/examples/GHRD/create_project2.tcl) instead




