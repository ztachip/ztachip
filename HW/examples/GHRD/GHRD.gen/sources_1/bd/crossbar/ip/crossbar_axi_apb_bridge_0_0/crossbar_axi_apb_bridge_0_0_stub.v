// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Fri Jul 29 00:06:54 2022
// Host        : LAPTOP-RM6TVNC2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top crossbar_axi_apb_bridge_0_0 -prefix
//               crossbar_axi_apb_bridge_0_0_ crossbar_axi_apb_bridge_0_0_stub.v
// Design      : crossbar_axi_apb_bridge_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "axi_apb_bridge,Vivado 2020.2" *)
module crossbar_axi_apb_bridge_0_0(s_axi_aclk, s_axi_aresetn, s_axi_awaddr, 
  s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wvalid, s_axi_wready, s_axi_bresp, 
  s_axi_bvalid, s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_arready, s_axi_rdata, 
  s_axi_rresp, s_axi_rvalid, s_axi_rready, m_apb_paddr, m_apb_psel, m_apb_penable, 
  m_apb_pwrite, m_apb_pwdata, m_apb_pready, m_apb_prdata, m_apb_pslverr)
/* synthesis syn_black_box black_box_pad_pin="s_axi_aclk,s_axi_aresetn,s_axi_awaddr[31:0],s_axi_awvalid,s_axi_awready,s_axi_wdata[31:0],s_axi_wvalid,s_axi_wready,s_axi_bresp[1:0],s_axi_bvalid,s_axi_bready,s_axi_araddr[31:0],s_axi_arvalid,s_axi_arready,s_axi_rdata[31:0],s_axi_rresp[1:0],s_axi_rvalid,s_axi_rready,m_apb_paddr[31:0],m_apb_psel[0:0],m_apb_penable,m_apb_pwrite,m_apb_pwdata[31:0],m_apb_pready[0:0],m_apb_prdata[31:0],m_apb_pslverr[0:0]" */;
  input s_axi_aclk;
  input s_axi_aresetn;
  input [31:0]s_axi_awaddr;
  input s_axi_awvalid;
  output s_axi_awready;
  input [31:0]s_axi_wdata;
  input s_axi_wvalid;
  output s_axi_wready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_bready;
  input [31:0]s_axi_araddr;
  input s_axi_arvalid;
  output s_axi_arready;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input s_axi_rready;
  output [31:0]m_apb_paddr;
  output [0:0]m_apb_psel;
  output m_apb_penable;
  output m_apb_pwrite;
  output [31:0]m_apb_pwdata;
  input [0:0]m_apb_pready;
  input [31:0]m_apb_prdata;
  input [0:0]m_apb_pslverr;
endmodule
