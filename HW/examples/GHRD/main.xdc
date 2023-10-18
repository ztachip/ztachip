## Clock signal

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clock]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports sys_clock]

set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports sys_resetn]

##LEDs

set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports UART_TXD]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports UART_RXD]
#set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports UART_TXD]
#set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports UART_RXD]

set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports {pushbutton[0]}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {pushbutton[1]}]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports {pushbutton[2]}]
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33} [get_ports {pushbutton[3]}]

##Pmod Header JB

#set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {VGA_R[0]}]
#set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {VGA_R[1]}]
#set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {VGA_R[2]}]
#set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {VGA_R[3]}]
#set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {VGA_B[0]}]
#set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[1]}]
#set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {VGA_B[2]}]
#set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {VGA_B[3]}]

##Pmod Header JC

#set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {VGA_G[0]}]
#set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {VGA_G[1]}]
#set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {VGA_G[2]}]
#set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {VGA_G[3]}]
#set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports VGA_HS_O]
#set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports VGA_VS_O]


##Pmod Header JA

set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {VGA_R[0]}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {VGA_R[1]}]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports {VGA_R[2]}]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports {VGA_R[3]}]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports {VGA_B[0]}]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[1]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[2]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {VGA_B[3]}]

##Pmod Header JB

set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {VGA_G[0]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {VGA_G[1]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {VGA_G[2]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {VGA_G[3]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports VGA_HS_O]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports VGA_VS_O]

##Pmod Header JC
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports CAMERA_SCL]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports CAMERA_VS]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports CAMERA_PCLK]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[7]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[5]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[3]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[1]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports CAMERA_RESET]

##Pmod Header JD
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports CAMERA_SDR]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports CAMERA_RS]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports CAMERA_MCLK]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[6]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[4]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[2]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {CAMERA_D[0]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports CAMERA_PWDN]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets CAMERA_PCLK_IBUF]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]

set_false_path -from [filter [all_fanout -from [get_ports clka]
-flat -endpoints_only] {IS_LEAF}] -through [get_pins -of_objects
[get_cells -hier * -filter {PRIMITIVE_SUBGROUP==LUTRAM ||
PRIMITIVE_SUBGROUP==dram || PRIMITIVE_SUBGROUP==drom}]
-filter {DIRECTION==OUT}]
