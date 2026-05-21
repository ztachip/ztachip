create_project ztachip . -part xc7a100tcsg324-1

read_verilog main.v
read_verilog ../../riscv/xilinx_jtag/riscv.v
read_vhdl ../../src/config.vhd
read_vhdl ../../src/ztachip_pkg.vhd
read_vhdl ../../src/alu/alu.vhd
read_vhdl ../../src/dp/dp.vhd 
read_vhdl ../../src/dp/dp_core.vhd 
read_vhdl ../../src/dp/dp_fetch.vhd 
read_vhdl ../../src/dp/dp_fifo.vhd 
read_vhdl ../../src/dp/dp_gen.vhd
read_vhdl ../../src/dp/dp_gen_core.vhd
read_vhdl ../../src/dp/dp_sink.vhd
read_vhdl ../../src/dp/dp_source.vhd
read_vhdl ../../src/ialu/ialu.vhd
read_vhdl ../../src/ialu/iregister_file.vhd
read_vhdl ../../src/ialu/iregister_ram.vhd
read_vhdl ../../src/pcore/core.vhd
read_vhdl ../../src/pcore/instr.vhd
read_vhdl ../../src/pcore/instr_decoder2.vhd
read_vhdl ../../src/pcore/instr_dispatch2.vhd
read_vhdl ../../src/pcore/instr_fetch.vhd
read_vhdl ../../src/pcore/pcore.vhd
read_vhdl ../../src/pcore/register_bank.vhd
read_vhdl ../../src/pcore/register_file.vhd
read_vhdl ../../src/pcore/rom.vhd
read_vhdl ../../src/pcore/stream.vhd
read_vhdl ../../src/pcore/xregister_file.vhd
read_vhdl ../../src/soc/soc_base.vhd
read_vhdl ../../src/soc/tcm.vhd
read_vhdl ../../src/soc/axi/axi_apb_bridge.vhd
read_vhdl ../../src/soc/axi/axi_merge.vhd
read_vhdl ../../src/soc/axi/axi_merge_read.vhd
read_vhdl ../../src/soc/axi/axi_merge_write.vhd
read_vhdl ../../src/soc/axi/axi_read.vhd
read_vhdl ../../src/soc/axi/axi_split.vhd
read_vhdl ../../src/soc/axi/axi_split_read.vhd
read_vhdl ../../src/soc/axi/axi_split_write.vhd
read_vhdl ../../src/soc/axi/axi_stream_read.vhd
read_vhdl ../../src/soc/axi/axi_stream_write.vhd
read_vhdl ../../src/soc/axi/axi_write.vhd
read_vhdl ../../src/soc/axi/axi_ram_read.vhd
read_vhdl ../../src/soc/axi/axi_ram_write.vhd
read_vhdl ../../src/soc/axi/axi_resize_read.vhd
read_vhdl ../../src/soc/axi/axi_resize_write.vhd
read_vhdl ../../src/soc/peripherals/camera.vhd
read_vhdl ../../src/soc/peripherals/gpio.vhd
read_vhdl ../../src/soc/peripherals/vga.vhd
read_vhdl ../../src/soc/peripherals/time.vhd
read_vhdl ../../src/soc/peripherals/uart.vhd
read_vhdl ../../src/soc/peripherals/ethlite.vhd
read_vhdl ../../src/top/axilite.vhd
read_vhdl ../../src/top/cell.vhd
read_vhdl ../../src/top/ddr_rx.vhd
read_vhdl ../../src/top/ddr_tx.vhd
read_vhdl ../../src/top/sram.vhd
read_vhdl ../../src/top/sram_core.vhd
read_vhdl ../../src/top/ztachip.vhd
read_vhdl ../../src/util/shifter_l.vhd
read_vhdl ../../src/util/shifter.vhd
read_vhdl ../../src/util/ramw2.vhd
read_vhdl ../../src/util/ramw.vhd
read_vhdl ../../src/util/ram2r1w.vhd
read_vhdl ../../src/util/multiplier.vhd
read_vhdl ../../src/util/fifow.vhd
read_vhdl ../../src/util/fifo.vhd
read_vhdl ../../src/util/delayv.vhd
read_vhdl ../../src/util/delayi.vhd
read_vhdl ../../src/util/delay.vhd
read_vhdl ../../src/util/arbiter.vhd
read_vhdl ../../src/util/afifo.vhd
read_vhdl ../../src/util/afifo2.vhd
read_vhdl ../../src/util/adder.vhd
read_vhdl ../../src/fpu/falu_core.vhd
read_vhdl ../../src/fpu/falu_vector.vhd
read_vhdl ../../src/fpu/falu2.vhd
read_vhdl ../../src/fpu/falu.vhd
read_vhdl ../../src/fpu/fp12.vhd
read_vhdl ../../src/fpu/fp2int.vhd
read_vhdl ../../src/fpu/fp_floor.vhd
read_vhdl ../../src/fpu/fpmax.vhd
read_vhdl ../../src/fpu/fpu.vhd
read_vhdl ../../src/fpu/fpu_fifo.vhd
read_vhdl ../../src/fpu/fpu_hazard.vhd
read_verilog ../../platform/Xilinx/CCD_SYNC.v
read_verilog ../../platform/Xilinx/SYNC_LATCH.v
read_verilog ../../platform/Xilinx/SHIFT.v
read_verilog ../../platform/Xilinx/DPRAM_BE.v
read_verilog ../../platform/Xilinx/DPRAM_DUAL_CLOCK.v
read_verilog ../../platform/Xilinx/DPRAM.v
read_verilog ../../platform/Xilinx/SPRAM_BE.v
read_verilog ../../platform/Xilinx/SPRAM.v
read_verilog ../../platform/Xilinx/FP32_MUL.v
read_verilog ../../platform/Xilinx/FP32_ADDSUB.v

read_xdc main.xdc

######################################################################################
#### Create IP instance for clock synthesizer 
######################################################################################

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
			CONFIG.CLKOUT1_USED {true} \
			CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.150} \
			CONFIG.CLKOUT2_USED {true} \
			CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
			CONFIG.CLKOUT3_USED {true} \
			CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {166.666} \
			CONFIG.CLKOUT4_USED {true} \
			CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {24.000} \
			CONFIG.CLKOUT5_USED {true} \
			CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {125.000} \
			CONFIG.CLKOUT6_USED {true} \
			CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {250.000} \
			CONFIG.CLKOUT7_USED {true} \
			CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {25.000} \
			CONFIG.RESET_TYPE {ACTIVE_LOW}] [get_ips clk_wiz_0]

generate_target all [get_files ztachip.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

######################################################################################
#### Create IP instance for F32 adder
######################################################################################

create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name float_addsub
set_property -dict [list \
			CONFIG.Operation_Type {Add/Subtract} \
			CONFIG.Maximum_Latency {False} \
			CONFIG.C_Latency {4} \
			CONFIG.Flow_Control {NonBlocking}] \
			[get_ips float_addsub]

generate_target all [get_files ztachip.srcs/sources_1/ip/float_addsub/float_addsub.xci]

######################################################################################
#### Create IP instance for F32 multiplier
######################################################################################

create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name float_mul
set_property -dict [list \
			CONFIG.operation_type {Multiply} \
			CONFIG.Maximum_Latency {False} \
			CONFIG.C_Latency {4} \
			CONFIG.Flow_Control {NonBlocking}] \
			[get_ips float_mul]

generate_target all [get_files ztachip.srcs/sources_1/ip/float_mul/float_mul.xci]


######################################################################################
#### Create IP instance for EthernetLite
######################################################################################

create_ip -name axi_ethernetlite \
          -vendor xilinx.com \
          -library ip \
          -version 3.0 \
          -module_name axi_ethernetlite_0

set_property -dict [list \
	CONFIG.AXI_ACLK_FREQ_MHZ {125} \
    CONFIG.C_TX_PING_PONG {1} \
    CONFIG.C_RX_PING_PONG {1} \
    CONFIG.C_INCLUDE_MDIO {1} \
    CONFIG.C_INCLUDE_INTERNAL_LOOPBACK {0} \
] [get_ips axi_ethernetlite_0]

generate_target all [get_files ztachip.srcs/sources_1/ip/axi_ethernetlite_0/axi_ethernetlite_0.xci]

######################################################################################
#### Create IP instance for DDR controller 
######################################################################################

create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.2 -module_name mig_7series_0

if {[string equal $argv linux]}  {
  exec cp mig.prj ztachip.srcs/sources_1/ip/mig_7series_0/mig.prj
} else {
  exec cmd /c copy mig.prj ztachip.srcs\\sources_1\\ip\\mig_7series_0\\mig.prj
}
set_property -dict [list CONFIG.XML_INPUT_FILE {mig.prj}] [get_ips mig_7series_0]

generate_target {instantiation_template} [get_files ztachip.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci]
generate_target all [get_files ztachip.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci]

update_compile_order -fileset sources_1
