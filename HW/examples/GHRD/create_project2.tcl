create_project ztachip . -part xc7a100tcsg324-1

read_verilog main.v
read_verilog ../../riscv/xilinx_jtag/riscv.v
read_verilog ../../../tools/ghdl/soc.v
read_verilog ../../platform/Xilinx/CCD_SYNC.v
read_verilog ../../platform/Xilinx/SYNC_LATCH.v
read_verilog ../../platform/Xilinx/SHIFT.v
read_verilog ../../platform/Xilinx/DPRAM_BE.v
read_verilog ../../platform/Xilinx/DPRAM_DUAL_CLOCK.v
read_verilog ../../platform/Xilinx/DPRAM.v
read_verilog ../../platform/Xilinx/SPRAM_BE.v
read_verilog ../../platform/Xilinx/SPRAM.v
read_xdc main.xdc

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
			CONFIG.RESET_TYPE {ACTIVE_LOW}] [get_ips clk_wiz_0]
generate_target all [get_files ztachip.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

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
