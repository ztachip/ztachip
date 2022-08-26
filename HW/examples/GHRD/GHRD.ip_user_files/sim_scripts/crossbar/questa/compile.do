vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/xlconstant_v1_1_7
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/lib_cdc_v1_0_2
vlib questa_lib/msim/proc_sys_reset_v5_0_13
vlib questa_lib/msim/smartconnect_v1_0
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_register_slice_v2_1_22
vlib questa_lib/msim/axi_vip_v1_1_8
vlib questa_lib/msim/lib_pkg_v1_0_2
vlib questa_lib/msim/fifo_generator_v13_2_5
vlib questa_lib/msim/lib_fifo_v1_0_14
vlib questa_lib/msim/blk_mem_gen_v8_4_4
vlib questa_lib/msim/lib_bmg_v1_0_13
vlib questa_lib/msim/lib_srl_fifo_v1_0_2
vlib questa_lib/msim/axi_datamover_v5_1_24
vlib questa_lib/msim/axi_vdma_v6_3_10
vlib questa_lib/msim/axi_apb_bridge_v3_0_17

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap xlconstant_v1_1_7 questa_lib/msim/xlconstant_v1_1_7
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap lib_cdc_v1_0_2 questa_lib/msim/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 questa_lib/msim/proc_sys_reset_v5_0_13
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_22 questa_lib/msim/axi_register_slice_v2_1_22
vmap axi_vip_v1_1_8 questa_lib/msim/axi_vip_v1_1_8
vmap lib_pkg_v1_0_2 questa_lib/msim/lib_pkg_v1_0_2
vmap fifo_generator_v13_2_5 questa_lib/msim/fifo_generator_v13_2_5
vmap lib_fifo_v1_0_14 questa_lib/msim/lib_fifo_v1_0_14
vmap blk_mem_gen_v8_4_4 questa_lib/msim/blk_mem_gen_v8_4_4
vmap lib_bmg_v1_0_13 questa_lib/msim/lib_bmg_v1_0_13
vmap lib_srl_fifo_v1_0_2 questa_lib/msim/lib_srl_fifo_v1_0_2
vmap axi_datamover_v5_1_24 questa_lib/msim/axi_datamover_v5_1_24
vmap axi_vdma_v6_3_10 questa_lib/msim/axi_vdma_v6_3_10
vmap axi_apb_bridge_v3_0_17 questa_lib/msim/axi_apb_bridge_v3_0_17

vlog -work xilinx_vip  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2020.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xlconstant_v1_1_7  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/fcfc/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_0/sim/bd_1779_one_0.v" \

vcom -work lib_cdc_v1_0_2  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_1779_psr0_0.vhd" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_1779_psr_aclk_0.vhd" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_1779_psr_aclk1_0.vhd" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/c012/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_1779_arsw_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_1779_rsw_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_1779_awsw_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_1779_wsw_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_1779_bsw_0.sv" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ea34/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_1779_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/4fd2/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_10/sim/bd_1779_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/8047/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_11/sim/bd_1779_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/b89e/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_12/sim/bd_1779_s00a2s_0.sv" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_13/sim/bd_1779_sarn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_14/sim/bd_1779_srn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_15/sim/bd_1779_s01mmu_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_16/sim/bd_1779_s01tr_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_17/sim/bd_1779_s01sic_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_18/sim/bd_1779_s01a2s_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_19/sim/bd_1779_sarn_1.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_20/sim/bd_1779_srn_1.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_21/sim/bd_1779_sawn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_22/sim/bd_1779_swn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_23/sim/bd_1779_sbn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_24/sim/bd_1779_s02mmu_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_25/sim/bd_1779_s02tr_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_26/sim/bd_1779_s02sic_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_27/sim/bd_1779_s02a2s_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_28/sim/bd_1779_sarn_2.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_29/sim/bd_1779_srn_2.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_30/sim/bd_1779_s03mmu_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_31/sim/bd_1779_s03tr_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_32/sim/bd_1779_s03sic_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_33/sim/bd_1779_s03a2s_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_34/sim/bd_1779_sawn_1.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_35/sim/bd_1779_swn_1.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_36/sim/bd_1779_sbn_1.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_37/sim/bd_1779_s04mmu_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_38/sim/bd_1779_s04tr_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_39/sim/bd_1779_s04sic_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_40/sim/bd_1779_s04a2s_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_41/sim/bd_1779_sarn_3.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_42/sim/bd_1779_srn_3.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_43/sim/bd_1779_sawn_2.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_44/sim/bd_1779_swn_2.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_45/sim/bd_1779_sbn_2.sv" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7005/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_46/sim/bd_1779_m00s2a_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_47/sim/bd_1779_m00arn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_48/sim/bd_1779_m00rn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_49/sim/bd_1779_m00awn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_50/sim/bd_1779_m00wn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_51/sim/bd_1779_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7bd7/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_52/sim/bd_1779_m00e_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_53/sim/bd_1779_m01s2a_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_54/sim/bd_1779_m01arn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_55/sim/bd_1779_m01rn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_56/sim/bd_1779_m01awn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_57/sim/bd_1779_m01wn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_58/sim/bd_1779_m01bn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_59/sim/bd_1779_m01e_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_60/sim/bd_1779_m02s2a_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_61/sim/bd_1779_m02arn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_62/sim/bd_1779_m02rn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_63/sim/bd_1779_m02awn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_64/sim/bd_1779_m02wn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_65/sim/bd_1779_m02bn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_66/sim/bd_1779_m02e_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_67/sim/bd_1779_m03s2a_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_68/sim/bd_1779_m03arn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_69/sim/bd_1779_m03rn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_70/sim/bd_1779_m03awn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_71/sim/bd_1779_m03wn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_72/sim/bd_1779_m03bn_0.sv" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/ip/ip_73/sim/bd_1779_m03e_0.sv" \

vlog -work xil_defaultlib  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/bd_0/sim/bd_1779.v" \

vlog -work axi_infrastructure_v1_1_0  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_22  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/af2c/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_8  -sv -L axi_vip_v1_1_8 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/94c3/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/ip/crossbar_smartconnect_0_0/sim/crossbar_smartconnect_0_0.v" \

vcom -work lib_pkg_v1_0_2  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_14  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \

vlog -work blk_mem_gen_v8_4_4  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \

vcom -work lib_bmg_v1_0_13  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/af67/hdl/lib_bmg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_24  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/4ab6/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vlog -work axi_vdma_v6_3_10  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl/axi_vdma_v6_3_rfs.v" \

vcom -work axi_vdma_v6_3_10  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl/axi_vdma_v6_3_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/crossbar/ip/crossbar_axi_vdma_0_0/sim/crossbar_axi_vdma_0_0.vhd" \

vcom -work axi_apb_bridge_v3_0_17  -93 \
"../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/c0b5/hdl/axi_apb_bridge_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/crossbar/ip/crossbar_axi_apb_bridge_0_0/sim/crossbar_axi_apb_bridge_0_0.vhd" \

vlog -work xil_defaultlib  "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/25b7/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/896c/hdl/verilog" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/ec67/hdl" "+incdir+../../../../GHRD.gen/sources_1/bd/crossbar/ipshared/7860/hdl" "+incdir+C:/Xilinx/Vivado/2020.2/data/xilinx_vip/include" \
"../../../bd/crossbar/sim/crossbar.v" \

vlog -work xil_defaultlib \
"glbl.v"

