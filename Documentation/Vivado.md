# Installing Vivado Free WebPack Edition.

Vivado WebPack edition is free IDE for the Artix7 FPGA family.

[Installing Vivado WebPack edition](https://www.xilinx.com/support/download.html)

# Build and flash procedure. 

Open Vivado project file ztachip/HW/examples/GHRD/GHRD.xpr

Then start with synthesis step as shown below

![vivado step1](vivado_step1.bmp)

After systhesis step has been completed, Vivado will prompt you to continue with Implementation step. Choose the option and click OK.

![vivado step2](vivado_step2.bmp)

After Implementation step has been completed, Vivado will prompt you to continue with Bitstream Generation step. Choose the option and click OK. 

![vivado step3](vivado_step3.bmp)

After Bistream Generation step has been completed, Vivado will prompt you to Open Hardware Manager. Choose the option and click OK.

![vivado step4](vivado_step4.bmp)

Make sure your board is connected to PC with provided USB cable by Arty Devlopment package.

From Hardware Manager, connect to target as shown below 

![vivado step5](vivado_step5.bmp)

In the Configuation Memory Device Properties panel, select the right flash chip for your board revision. Reference your Arty-A7 user manual for the information.

![vivado step6](vivado_step6.bmp)

Then program the board as shown below.

![vivado step7](vivado_step7.bmp)

That's it. Your board's FPGA will be programmed with the new image automatically after power reboot.



