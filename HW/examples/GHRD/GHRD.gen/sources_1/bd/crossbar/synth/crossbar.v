//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Thu Aug 25 01:22:08 2022
//Host        : LAPTOP-RM6TVNC2 running 64-bit major release  (build 9200)
//Command     : generate_target crossbar.bd
//Design      : crossbar
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "crossbar,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=crossbar,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "crossbar.hwdef" *) 
module crossbar
   (APB_0_paddr,
    APB_0_penable,
    APB_0_prdata,
    APB_0_pready,
    APB_0_psel,
    APB_0_pslverr,
    APB_0_pwdata,
    APB_0_pwrite,
    ARESETN,
    CAMERA_CLOCK_IN,
    CAMERA_IN_tdata,
    CAMERA_IN_tkeep,
    CAMERA_IN_tlast,
    CAMERA_IN_tready,
    CAMERA_IN_tuser,
    CAMERA_IN_tvalid,
    CLOCK,
    DBUS_araddr,
    DBUS_arburst,
    DBUS_arcache,
    DBUS_arid,
    DBUS_arlen,
    DBUS_arlock,
    DBUS_arprot,
    DBUS_arqos,
    DBUS_arready,
    DBUS_arsize,
    DBUS_arvalid,
    DBUS_awaddr,
    DBUS_awburst,
    DBUS_awcache,
    DBUS_awid,
    DBUS_awlen,
    DBUS_awlock,
    DBUS_awprot,
    DBUS_awqos,
    DBUS_awready,
    DBUS_awsize,
    DBUS_awvalid,
    DBUS_bid,
    DBUS_bready,
    DBUS_bresp,
    DBUS_bvalid,
    DBUS_rdata,
    DBUS_rid,
    DBUS_rlast,
    DBUS_rready,
    DBUS_rresp,
    DBUS_rvalid,
    DBUS_wdata,
    DBUS_wlast,
    DBUS_wready,
    DBUS_wstrb,
    DBUS_wvalid,
    IBUS_araddr,
    IBUS_arburst,
    IBUS_arcache,
    IBUS_arid,
    IBUS_arlen,
    IBUS_arlock,
    IBUS_arprot,
    IBUS_arqos,
    IBUS_arready,
    IBUS_arsize,
    IBUS_arvalid,
    IBUS_rdata,
    IBUS_rid,
    IBUS_rlast,
    IBUS_rready,
    IBUS_rresp,
    IBUS_rvalid,
    SDRAM_CLOCK,
    SDRAM_araddr,
    SDRAM_arburst,
    SDRAM_arcache,
    SDRAM_arlen,
    SDRAM_arlock,
    SDRAM_arprot,
    SDRAM_arqos,
    SDRAM_arready,
    SDRAM_arsize,
    SDRAM_arvalid,
    SDRAM_awaddr,
    SDRAM_awburst,
    SDRAM_awcache,
    SDRAM_awlen,
    SDRAM_awlock,
    SDRAM_awprot,
    SDRAM_awqos,
    SDRAM_awready,
    SDRAM_awsize,
    SDRAM_awvalid,
    SDRAM_bready,
    SDRAM_bresp,
    SDRAM_bvalid,
    SDRAM_rdata,
    SDRAM_rlast,
    SDRAM_rready,
    SDRAM_rresp,
    SDRAM_rvalid,
    SDRAM_wdata,
    SDRAM_wlast,
    SDRAM_wready,
    SDRAM_wstrb,
    SDRAM_wvalid,
    VIDEO_CLOCK,
    VIDEO_OUT_tdata,
    VIDEO_OUT_tkeep,
    VIDEO_OUT_tlast,
    VIDEO_OUT_tready,
    VIDEO_OUT_tuser,
    VIDEO_OUT_tvalid,
    ZTA_CONTROL_araddr,
    ZTA_CONTROL_arburst,
    ZTA_CONTROL_arcache,
    ZTA_CONTROL_arlen,
    ZTA_CONTROL_arlock,
    ZTA_CONTROL_arprot,
    ZTA_CONTROL_arqos,
    ZTA_CONTROL_arready,
    ZTA_CONTROL_arsize,
    ZTA_CONTROL_arvalid,
    ZTA_CONTROL_awaddr,
    ZTA_CONTROL_awburst,
    ZTA_CONTROL_awcache,
    ZTA_CONTROL_awlen,
    ZTA_CONTROL_awlock,
    ZTA_CONTROL_awprot,
    ZTA_CONTROL_awqos,
    ZTA_CONTROL_awready,
    ZTA_CONTROL_awsize,
    ZTA_CONTROL_awvalid,
    ZTA_CONTROL_bready,
    ZTA_CONTROL_bresp,
    ZTA_CONTROL_bvalid,
    ZTA_CONTROL_rdata,
    ZTA_CONTROL_rlast,
    ZTA_CONTROL_rready,
    ZTA_CONTROL_rresp,
    ZTA_CONTROL_rvalid,
    ZTA_CONTROL_wdata,
    ZTA_CONTROL_wlast,
    ZTA_CONTROL_wready,
    ZTA_CONTROL_wstrb,
    ZTA_CONTROL_wvalid,
    ZTA_DATA_araddr,
    ZTA_DATA_arburst,
    ZTA_DATA_arcache,
    ZTA_DATA_arid,
    ZTA_DATA_arlen,
    ZTA_DATA_arlock,
    ZTA_DATA_arprot,
    ZTA_DATA_arqos,
    ZTA_DATA_arready,
    ZTA_DATA_arsize,
    ZTA_DATA_arvalid,
    ZTA_DATA_awaddr,
    ZTA_DATA_awburst,
    ZTA_DATA_awcache,
    ZTA_DATA_awid,
    ZTA_DATA_awlen,
    ZTA_DATA_awlock,
    ZTA_DATA_awprot,
    ZTA_DATA_awqos,
    ZTA_DATA_awready,
    ZTA_DATA_awsize,
    ZTA_DATA_awvalid,
    ZTA_DATA_bid,
    ZTA_DATA_bready,
    ZTA_DATA_bresp,
    ZTA_DATA_bvalid,
    ZTA_DATA_rdata,
    ZTA_DATA_rid,
    ZTA_DATA_rlast,
    ZTA_DATA_rready,
    ZTA_DATA_rresp,
    ZTA_DATA_rvalid,
    ZTA_DATA_wdata,
    ZTA_DATA_wlast,
    ZTA_DATA_wready,
    ZTA_DATA_wstrb,
    ZTA_DATA_wvalid);
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PADDR" *) output [31:0]APB_0_paddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PENABLE" *) output APB_0_penable;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PRDATA" *) input [31:0]APB_0_prdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PREADY" *) input [0:0]APB_0_pready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PSEL" *) output [0:0]APB_0_psel;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PSLVERR" *) input [0:0]APB_0_pslverr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PWDATA" *) output [31:0]APB_0_pwdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 APB_0 PWRITE" *) output APB_0_pwrite;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input ARESETN;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CAMERA_CLOCK_IN CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CAMERA_CLOCK_IN, ASSOCIATED_BUSIF CAMERA_IN, CLK_DOMAIN crossbar_CAMERA_CLOCK_IN, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input CAMERA_CLOCK_IN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 CAMERA_IN TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CAMERA_IN, CLK_DOMAIN crossbar_CAMERA_CLOCK_IN, FREQ_HZ 25000000, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [31:0]CAMERA_IN_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 CAMERA_IN TKEEP" *) input [3:0]CAMERA_IN_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 CAMERA_IN TLAST" *) input CAMERA_IN_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 CAMERA_IN TREADY" *) output CAMERA_IN_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 CAMERA_IN TUSER" *) input [0:0]CAMERA_IN_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 CAMERA_IN TVALID" *) input CAMERA_IN_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLOCK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLOCK, ASSOCIATED_BUSIF IBUS:DBUS:ZTA_CONTROL:ZTA_DATA, ASSOCIATED_RESET ARESETN, CLK_DOMAIN crossbar_CLOCK, FREQ_HZ 166000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input CLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DBUS, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN crossbar_CLOCK, DATA_WIDTH 32, FREQ_HZ 166000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 1, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 1, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 64, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 64, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]DBUS_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARBURST" *) input [1:0]DBUS_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARCACHE" *) input [3:0]DBUS_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARID" *) input [0:0]DBUS_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARLEN" *) input [7:0]DBUS_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARLOCK" *) input [0:0]DBUS_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARPROT" *) input [2:0]DBUS_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARQOS" *) input [3:0]DBUS_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARREADY" *) output DBUS_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARSIZE" *) input [2:0]DBUS_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS ARVALID" *) input DBUS_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWADDR" *) input [31:0]DBUS_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWBURST" *) input [1:0]DBUS_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWCACHE" *) input [3:0]DBUS_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWID" *) input [0:0]DBUS_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWLEN" *) input [7:0]DBUS_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWLOCK" *) input [0:0]DBUS_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWPROT" *) input [2:0]DBUS_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWQOS" *) input [3:0]DBUS_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWREADY" *) output DBUS_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWSIZE" *) input [2:0]DBUS_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS AWVALID" *) input DBUS_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS BID" *) output [0:0]DBUS_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS BREADY" *) input DBUS_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS BRESP" *) output [1:0]DBUS_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS BVALID" *) output DBUS_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS RDATA" *) output [31:0]DBUS_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS RID" *) output [0:0]DBUS_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS RLAST" *) output DBUS_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS RREADY" *) input DBUS_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS RRESP" *) output [1:0]DBUS_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS RVALID" *) output DBUS_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS WDATA" *) input [31:0]DBUS_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS WLAST" *) input DBUS_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS WREADY" *) output DBUS_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS WSTRB" *) input [3:0]DBUS_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DBUS WVALID" *) input DBUS_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME IBUS, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN crossbar_CLOCK, DATA_WIDTH 32, FREQ_HZ 166000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 1, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 1, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 64, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 64, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_ONLY, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]IBUS_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARBURST" *) input [1:0]IBUS_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARCACHE" *) input [3:0]IBUS_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARID" *) input [0:0]IBUS_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARLEN" *) input [7:0]IBUS_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARLOCK" *) input [0:0]IBUS_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARPROT" *) input [2:0]IBUS_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARQOS" *) input [3:0]IBUS_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARREADY" *) output IBUS_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARSIZE" *) input [2:0]IBUS_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS ARVALID" *) input IBUS_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS RDATA" *) output [31:0]IBUS_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS RID" *) output [0:0]IBUS_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS RLAST" *) output IBUS_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS RREADY" *) input IBUS_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS RRESP" *) output [1:0]IBUS_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 IBUS RVALID" *) output IBUS_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SDRAM_CLOCK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SDRAM_CLOCK, ASSOCIATED_BUSIF SDRAM, CLK_DOMAIN crossbar_SDRAM_CLOCK, FREQ_HZ 166000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input SDRAM_CLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME SDRAM, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN crossbar_SDRAM_CLOCK, DATA_WIDTH 64, FREQ_HZ 166000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 64, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 64, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]SDRAM_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARBURST" *) output [1:0]SDRAM_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARCACHE" *) output [3:0]SDRAM_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARLEN" *) output [7:0]SDRAM_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARLOCK" *) output [0:0]SDRAM_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARPROT" *) output [2:0]SDRAM_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARQOS" *) output [3:0]SDRAM_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARREADY" *) input SDRAM_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARSIZE" *) output [2:0]SDRAM_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM ARVALID" *) output SDRAM_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWADDR" *) output [31:0]SDRAM_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWBURST" *) output [1:0]SDRAM_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWCACHE" *) output [3:0]SDRAM_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWLEN" *) output [7:0]SDRAM_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWLOCK" *) output [0:0]SDRAM_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWPROT" *) output [2:0]SDRAM_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWQOS" *) output [3:0]SDRAM_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWREADY" *) input SDRAM_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWSIZE" *) output [2:0]SDRAM_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM AWVALID" *) output SDRAM_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM BREADY" *) output SDRAM_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM BRESP" *) input [1:0]SDRAM_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM BVALID" *) input SDRAM_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM RDATA" *) input [63:0]SDRAM_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM RLAST" *) input SDRAM_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM RREADY" *) output SDRAM_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM RRESP" *) input [1:0]SDRAM_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM RVALID" *) input SDRAM_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM WDATA" *) output [63:0]SDRAM_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM WLAST" *) output SDRAM_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM WREADY" *) input SDRAM_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM WSTRB" *) output [7:0]SDRAM_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SDRAM WVALID" *) output SDRAM_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.VIDEO_CLOCK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.VIDEO_CLOCK, ASSOCIATED_BUSIF VIDEO_OUT, CLK_DOMAIN crossbar_VIDEO_CLOCK, FREQ_HZ 25000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input VIDEO_CLOCK;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 VIDEO_OUT TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME VIDEO_OUT, CLK_DOMAIN crossbar_VIDEO_CLOCK, FREQ_HZ 25000000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1" *) output [31:0]VIDEO_OUT_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 VIDEO_OUT TKEEP" *) output [3:0]VIDEO_OUT_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 VIDEO_OUT TLAST" *) output VIDEO_OUT_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 VIDEO_OUT TREADY" *) input VIDEO_OUT_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 VIDEO_OUT TUSER" *) output [0:0]VIDEO_OUT_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 VIDEO_OUT TVALID" *) output VIDEO_OUT_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ZTA_CONTROL, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN crossbar_CLOCK, DATA_WIDTH 32, FREQ_HZ 166000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 64, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 64, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [31:0]ZTA_CONTROL_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARBURST" *) output [1:0]ZTA_CONTROL_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARCACHE" *) output [3:0]ZTA_CONTROL_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARLEN" *) output [7:0]ZTA_CONTROL_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARLOCK" *) output [0:0]ZTA_CONTROL_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARPROT" *) output [2:0]ZTA_CONTROL_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARQOS" *) output [3:0]ZTA_CONTROL_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARREADY" *) input ZTA_CONTROL_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARSIZE" *) output [2:0]ZTA_CONTROL_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL ARVALID" *) output ZTA_CONTROL_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWADDR" *) output [31:0]ZTA_CONTROL_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWBURST" *) output [1:0]ZTA_CONTROL_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWCACHE" *) output [3:0]ZTA_CONTROL_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWLEN" *) output [7:0]ZTA_CONTROL_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWLOCK" *) output [0:0]ZTA_CONTROL_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWPROT" *) output [2:0]ZTA_CONTROL_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWQOS" *) output [3:0]ZTA_CONTROL_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWREADY" *) input ZTA_CONTROL_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWSIZE" *) output [2:0]ZTA_CONTROL_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL AWVALID" *) output ZTA_CONTROL_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL BREADY" *) output ZTA_CONTROL_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL BRESP" *) input [1:0]ZTA_CONTROL_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL BVALID" *) input ZTA_CONTROL_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL RDATA" *) input [31:0]ZTA_CONTROL_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL RLAST" *) input ZTA_CONTROL_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL RREADY" *) output ZTA_CONTROL_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL RRESP" *) input [1:0]ZTA_CONTROL_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL RVALID" *) input ZTA_CONTROL_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL WDATA" *) output [31:0]ZTA_CONTROL_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL WLAST" *) output ZTA_CONTROL_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL WREADY" *) input ZTA_CONTROL_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL WSTRB" *) output [3:0]ZTA_CONTROL_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_CONTROL WVALID" *) output ZTA_CONTROL_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ZTA_DATA, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN crossbar_CLOCK, DATA_WIDTH 64, FREQ_HZ 166000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 1, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 1, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 64, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 64, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]ZTA_DATA_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARBURST" *) input [1:0]ZTA_DATA_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARCACHE" *) input [3:0]ZTA_DATA_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARID" *) input [0:0]ZTA_DATA_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARLEN" *) input [7:0]ZTA_DATA_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARLOCK" *) input [0:0]ZTA_DATA_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARPROT" *) input [2:0]ZTA_DATA_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARQOS" *) input [3:0]ZTA_DATA_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARREADY" *) output ZTA_DATA_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARSIZE" *) input [2:0]ZTA_DATA_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA ARVALID" *) input ZTA_DATA_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWADDR" *) input [31:0]ZTA_DATA_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWBURST" *) input [1:0]ZTA_DATA_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWCACHE" *) input [3:0]ZTA_DATA_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWID" *) input [0:0]ZTA_DATA_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWLEN" *) input [7:0]ZTA_DATA_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWLOCK" *) input [0:0]ZTA_DATA_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWPROT" *) input [2:0]ZTA_DATA_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWQOS" *) input [3:0]ZTA_DATA_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWREADY" *) output ZTA_DATA_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWSIZE" *) input [2:0]ZTA_DATA_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA AWVALID" *) input ZTA_DATA_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA BID" *) output [0:0]ZTA_DATA_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA BREADY" *) input ZTA_DATA_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA BRESP" *) output [1:0]ZTA_DATA_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA BVALID" *) output ZTA_DATA_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA RDATA" *) output [63:0]ZTA_DATA_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA RID" *) output [0:0]ZTA_DATA_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA RLAST" *) output ZTA_DATA_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA RREADY" *) input ZTA_DATA_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA RRESP" *) output [1:0]ZTA_DATA_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA RVALID" *) output ZTA_DATA_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA WDATA" *) input [63:0]ZTA_DATA_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA WLAST" *) input ZTA_DATA_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA WREADY" *) output ZTA_DATA_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA WSTRB" *) input [7:0]ZTA_DATA_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ZTA_DATA WVALID" *) input ZTA_DATA_wvalid;

  wire ARESETN_1;
  wire CAMERA_CLOCK_IN_1;
  wire [31:0]CAMERA_IN_1_TDATA;
  wire [3:0]CAMERA_IN_1_TKEEP;
  wire CAMERA_IN_1_TLAST;
  wire CAMERA_IN_1_TREADY;
  wire [0:0]CAMERA_IN_1_TUSER;
  wire CAMERA_IN_1_TVALID;
  wire CLOCK_1;
  wire [31:0]DBUS_1_ARADDR;
  wire [1:0]DBUS_1_ARBURST;
  wire [3:0]DBUS_1_ARCACHE;
  wire [0:0]DBUS_1_ARID;
  wire [7:0]DBUS_1_ARLEN;
  wire [0:0]DBUS_1_ARLOCK;
  wire [2:0]DBUS_1_ARPROT;
  wire [3:0]DBUS_1_ARQOS;
  wire DBUS_1_ARREADY;
  wire [2:0]DBUS_1_ARSIZE;
  wire DBUS_1_ARVALID;
  wire [31:0]DBUS_1_AWADDR;
  wire [1:0]DBUS_1_AWBURST;
  wire [3:0]DBUS_1_AWCACHE;
  wire [0:0]DBUS_1_AWID;
  wire [7:0]DBUS_1_AWLEN;
  wire [0:0]DBUS_1_AWLOCK;
  wire [2:0]DBUS_1_AWPROT;
  wire [3:0]DBUS_1_AWQOS;
  wire DBUS_1_AWREADY;
  wire [2:0]DBUS_1_AWSIZE;
  wire DBUS_1_AWVALID;
  wire [0:0]DBUS_1_BID;
  wire DBUS_1_BREADY;
  wire [1:0]DBUS_1_BRESP;
  wire DBUS_1_BVALID;
  wire [31:0]DBUS_1_RDATA;
  wire [0:0]DBUS_1_RID;
  wire DBUS_1_RLAST;
  wire DBUS_1_RREADY;
  wire [1:0]DBUS_1_RRESP;
  wire DBUS_1_RVALID;
  wire [31:0]DBUS_1_WDATA;
  wire DBUS_1_WLAST;
  wire DBUS_1_WREADY;
  wire [3:0]DBUS_1_WSTRB;
  wire DBUS_1_WVALID;
  wire [31:0]IBUS_1_ARADDR;
  wire [1:0]IBUS_1_ARBURST;
  wire [3:0]IBUS_1_ARCACHE;
  wire [0:0]IBUS_1_ARID;
  wire [7:0]IBUS_1_ARLEN;
  wire [0:0]IBUS_1_ARLOCK;
  wire [2:0]IBUS_1_ARPROT;
  wire [3:0]IBUS_1_ARQOS;
  wire IBUS_1_ARREADY;
  wire [2:0]IBUS_1_ARSIZE;
  wire IBUS_1_ARVALID;
  wire [31:0]IBUS_1_RDATA;
  wire [0:0]IBUS_1_RID;
  wire IBUS_1_RLAST;
  wire IBUS_1_RREADY;
  wire [1:0]IBUS_1_RRESP;
  wire IBUS_1_RVALID;
  wire SDRAM_CLOCK_1;
  wire VIDEO_CLOCK_1;
  wire [31:0]ZTA_DATA_1_ARADDR;
  wire [1:0]ZTA_DATA_1_ARBURST;
  wire [3:0]ZTA_DATA_1_ARCACHE;
  wire [0:0]ZTA_DATA_1_ARID;
  wire [7:0]ZTA_DATA_1_ARLEN;
  wire [0:0]ZTA_DATA_1_ARLOCK;
  wire [2:0]ZTA_DATA_1_ARPROT;
  wire [3:0]ZTA_DATA_1_ARQOS;
  wire ZTA_DATA_1_ARREADY;
  wire [2:0]ZTA_DATA_1_ARSIZE;
  wire ZTA_DATA_1_ARVALID;
  wire [31:0]ZTA_DATA_1_AWADDR;
  wire [1:0]ZTA_DATA_1_AWBURST;
  wire [3:0]ZTA_DATA_1_AWCACHE;
  wire [0:0]ZTA_DATA_1_AWID;
  wire [7:0]ZTA_DATA_1_AWLEN;
  wire [0:0]ZTA_DATA_1_AWLOCK;
  wire [2:0]ZTA_DATA_1_AWPROT;
  wire [3:0]ZTA_DATA_1_AWQOS;
  wire ZTA_DATA_1_AWREADY;
  wire [2:0]ZTA_DATA_1_AWSIZE;
  wire ZTA_DATA_1_AWVALID;
  wire [0:0]ZTA_DATA_1_BID;
  wire ZTA_DATA_1_BREADY;
  wire [1:0]ZTA_DATA_1_BRESP;
  wire ZTA_DATA_1_BVALID;
  wire [63:0]ZTA_DATA_1_RDATA;
  wire [0:0]ZTA_DATA_1_RID;
  wire ZTA_DATA_1_RLAST;
  wire ZTA_DATA_1_RREADY;
  wire [1:0]ZTA_DATA_1_RRESP;
  wire ZTA_DATA_1_RVALID;
  wire [63:0]ZTA_DATA_1_WDATA;
  wire ZTA_DATA_1_WLAST;
  wire ZTA_DATA_1_WREADY;
  wire [7:0]ZTA_DATA_1_WSTRB;
  wire ZTA_DATA_1_WVALID;
  wire [31:0]axi_apb_bridge_0_APB_M_PADDR;
  wire axi_apb_bridge_0_APB_M_PENABLE;
  wire [31:0]axi_apb_bridge_0_APB_M_PRDATA;
  wire [0:0]axi_apb_bridge_0_APB_M_PREADY;
  wire [0:0]axi_apb_bridge_0_APB_M_PSEL;
  wire [0:0]axi_apb_bridge_0_APB_M_PSLVERR;
  wire [31:0]axi_apb_bridge_0_APB_M_PWDATA;
  wire axi_apb_bridge_0_APB_M_PWRITE;
  wire [31:0]axi_vdma_0_M_AXIS_MM2S_TDATA;
  wire [3:0]axi_vdma_0_M_AXIS_MM2S_TKEEP;
  wire axi_vdma_0_M_AXIS_MM2S_TLAST;
  wire axi_vdma_0_M_AXIS_MM2S_TREADY;
  wire [0:0]axi_vdma_0_M_AXIS_MM2S_TUSER;
  wire axi_vdma_0_M_AXIS_MM2S_TVALID;
  wire [31:0]axi_vdma_0_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_vdma_0_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_vdma_0_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_vdma_0_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_vdma_0_M_AXI_MM2S_ARPROT;
  wire axi_vdma_0_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_vdma_0_M_AXI_MM2S_ARSIZE;
  wire axi_vdma_0_M_AXI_MM2S_ARVALID;
  wire [31:0]axi_vdma_0_M_AXI_MM2S_RDATA;
  wire axi_vdma_0_M_AXI_MM2S_RLAST;
  wire axi_vdma_0_M_AXI_MM2S_RREADY;
  wire [1:0]axi_vdma_0_M_AXI_MM2S_RRESP;
  wire axi_vdma_0_M_AXI_MM2S_RVALID;
  wire [31:0]axi_vdma_0_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_vdma_0_M_AXI_S2MM_AWBURST;
  wire [3:0]axi_vdma_0_M_AXI_S2MM_AWCACHE;
  wire [7:0]axi_vdma_0_M_AXI_S2MM_AWLEN;
  wire [2:0]axi_vdma_0_M_AXI_S2MM_AWPROT;
  wire axi_vdma_0_M_AXI_S2MM_AWREADY;
  wire [2:0]axi_vdma_0_M_AXI_S2MM_AWSIZE;
  wire axi_vdma_0_M_AXI_S2MM_AWVALID;
  wire axi_vdma_0_M_AXI_S2MM_BREADY;
  wire [1:0]axi_vdma_0_M_AXI_S2MM_BRESP;
  wire axi_vdma_0_M_AXI_S2MM_BVALID;
  wire [31:0]axi_vdma_0_M_AXI_S2MM_WDATA;
  wire axi_vdma_0_M_AXI_S2MM_WLAST;
  wire axi_vdma_0_M_AXI_S2MM_WREADY;
  wire [3:0]axi_vdma_0_M_AXI_S2MM_WSTRB;
  wire axi_vdma_0_M_AXI_S2MM_WVALID;
  wire [31:0]smartconnect_0_M00_AXI_ARADDR;
  wire [1:0]smartconnect_0_M00_AXI_ARBURST;
  wire [3:0]smartconnect_0_M00_AXI_ARCACHE;
  wire [7:0]smartconnect_0_M00_AXI_ARLEN;
  wire [0:0]smartconnect_0_M00_AXI_ARLOCK;
  wire [2:0]smartconnect_0_M00_AXI_ARPROT;
  wire [3:0]smartconnect_0_M00_AXI_ARQOS;
  wire smartconnect_0_M00_AXI_ARREADY;
  wire [2:0]smartconnect_0_M00_AXI_ARSIZE;
  wire smartconnect_0_M00_AXI_ARVALID;
  wire [31:0]smartconnect_0_M00_AXI_AWADDR;
  wire [1:0]smartconnect_0_M00_AXI_AWBURST;
  wire [3:0]smartconnect_0_M00_AXI_AWCACHE;
  wire [7:0]smartconnect_0_M00_AXI_AWLEN;
  wire [0:0]smartconnect_0_M00_AXI_AWLOCK;
  wire [2:0]smartconnect_0_M00_AXI_AWPROT;
  wire [3:0]smartconnect_0_M00_AXI_AWQOS;
  wire smartconnect_0_M00_AXI_AWREADY;
  wire [2:0]smartconnect_0_M00_AXI_AWSIZE;
  wire smartconnect_0_M00_AXI_AWVALID;
  wire smartconnect_0_M00_AXI_BREADY;
  wire [1:0]smartconnect_0_M00_AXI_BRESP;
  wire smartconnect_0_M00_AXI_BVALID;
  wire [63:0]smartconnect_0_M00_AXI_RDATA;
  wire smartconnect_0_M00_AXI_RLAST;
  wire smartconnect_0_M00_AXI_RREADY;
  wire [1:0]smartconnect_0_M00_AXI_RRESP;
  wire smartconnect_0_M00_AXI_RVALID;
  wire [63:0]smartconnect_0_M00_AXI_WDATA;
  wire smartconnect_0_M00_AXI_WLAST;
  wire smartconnect_0_M00_AXI_WREADY;
  wire [7:0]smartconnect_0_M00_AXI_WSTRB;
  wire smartconnect_0_M00_AXI_WVALID;
  wire [31:0]smartconnect_0_M01_AXI_ARADDR;
  wire smartconnect_0_M01_AXI_ARREADY;
  wire smartconnect_0_M01_AXI_ARVALID;
  wire [31:0]smartconnect_0_M01_AXI_AWADDR;
  wire smartconnect_0_M01_AXI_AWREADY;
  wire smartconnect_0_M01_AXI_AWVALID;
  wire smartconnect_0_M01_AXI_BREADY;
  wire [1:0]smartconnect_0_M01_AXI_BRESP;
  wire smartconnect_0_M01_AXI_BVALID;
  wire [31:0]smartconnect_0_M01_AXI_RDATA;
  wire smartconnect_0_M01_AXI_RREADY;
  wire [1:0]smartconnect_0_M01_AXI_RRESP;
  wire smartconnect_0_M01_AXI_RVALID;
  wire [31:0]smartconnect_0_M01_AXI_WDATA;
  wire smartconnect_0_M01_AXI_WREADY;
  wire smartconnect_0_M01_AXI_WVALID;
  wire [8:0]smartconnect_0_M02_AXI_ARADDR;
  wire smartconnect_0_M02_AXI_ARREADY;
  wire smartconnect_0_M02_AXI_ARVALID;
  wire [8:0]smartconnect_0_M02_AXI_AWADDR;
  wire smartconnect_0_M02_AXI_AWREADY;
  wire smartconnect_0_M02_AXI_AWVALID;
  wire smartconnect_0_M02_AXI_BREADY;
  wire [1:0]smartconnect_0_M02_AXI_BRESP;
  wire smartconnect_0_M02_AXI_BVALID;
  wire [31:0]smartconnect_0_M02_AXI_RDATA;
  wire smartconnect_0_M02_AXI_RREADY;
  wire [1:0]smartconnect_0_M02_AXI_RRESP;
  wire smartconnect_0_M02_AXI_RVALID;
  wire [31:0]smartconnect_0_M02_AXI_WDATA;
  wire smartconnect_0_M02_AXI_WREADY;
  wire smartconnect_0_M02_AXI_WVALID;
  wire [31:0]smartconnect_0_M03_AXI_ARADDR;
  wire [1:0]smartconnect_0_M03_AXI_ARBURST;
  wire [3:0]smartconnect_0_M03_AXI_ARCACHE;
  wire [7:0]smartconnect_0_M03_AXI_ARLEN;
  wire [0:0]smartconnect_0_M03_AXI_ARLOCK;
  wire [2:0]smartconnect_0_M03_AXI_ARPROT;
  wire [3:0]smartconnect_0_M03_AXI_ARQOS;
  wire smartconnect_0_M03_AXI_ARREADY;
  wire [2:0]smartconnect_0_M03_AXI_ARSIZE;
  wire smartconnect_0_M03_AXI_ARVALID;
  wire [31:0]smartconnect_0_M03_AXI_AWADDR;
  wire [1:0]smartconnect_0_M03_AXI_AWBURST;
  wire [3:0]smartconnect_0_M03_AXI_AWCACHE;
  wire [7:0]smartconnect_0_M03_AXI_AWLEN;
  wire [0:0]smartconnect_0_M03_AXI_AWLOCK;
  wire [2:0]smartconnect_0_M03_AXI_AWPROT;
  wire [3:0]smartconnect_0_M03_AXI_AWQOS;
  wire smartconnect_0_M03_AXI_AWREADY;
  wire [2:0]smartconnect_0_M03_AXI_AWSIZE;
  wire smartconnect_0_M03_AXI_AWVALID;
  wire smartconnect_0_M03_AXI_BREADY;
  wire [1:0]smartconnect_0_M03_AXI_BRESP;
  wire smartconnect_0_M03_AXI_BVALID;
  wire [31:0]smartconnect_0_M03_AXI_RDATA;
  wire smartconnect_0_M03_AXI_RLAST;
  wire smartconnect_0_M03_AXI_RREADY;
  wire [1:0]smartconnect_0_M03_AXI_RRESP;
  wire smartconnect_0_M03_AXI_RVALID;
  wire [31:0]smartconnect_0_M03_AXI_WDATA;
  wire smartconnect_0_M03_AXI_WLAST;
  wire smartconnect_0_M03_AXI_WREADY;
  wire [3:0]smartconnect_0_M03_AXI_WSTRB;
  wire smartconnect_0_M03_AXI_WVALID;

  assign APB_0_paddr[31:0] = axi_apb_bridge_0_APB_M_PADDR;
  assign APB_0_penable = axi_apb_bridge_0_APB_M_PENABLE;
  assign APB_0_psel[0] = axi_apb_bridge_0_APB_M_PSEL;
  assign APB_0_pwdata[31:0] = axi_apb_bridge_0_APB_M_PWDATA;
  assign APB_0_pwrite = axi_apb_bridge_0_APB_M_PWRITE;
  assign ARESETN_1 = ARESETN;
  assign CAMERA_CLOCK_IN_1 = CAMERA_CLOCK_IN;
  assign CAMERA_IN_1_TDATA = CAMERA_IN_tdata[31:0];
  assign CAMERA_IN_1_TKEEP = CAMERA_IN_tkeep[3:0];
  assign CAMERA_IN_1_TLAST = CAMERA_IN_tlast;
  assign CAMERA_IN_1_TUSER = CAMERA_IN_tuser[0];
  assign CAMERA_IN_1_TVALID = CAMERA_IN_tvalid;
  assign CAMERA_IN_tready = CAMERA_IN_1_TREADY;
  assign CLOCK_1 = CLOCK;
  assign DBUS_1_ARADDR = DBUS_araddr[31:0];
  assign DBUS_1_ARBURST = DBUS_arburst[1:0];
  assign DBUS_1_ARCACHE = DBUS_arcache[3:0];
  assign DBUS_1_ARID = DBUS_arid[0];
  assign DBUS_1_ARLEN = DBUS_arlen[7:0];
  assign DBUS_1_ARLOCK = DBUS_arlock[0];
  assign DBUS_1_ARPROT = DBUS_arprot[2:0];
  assign DBUS_1_ARQOS = DBUS_arqos[3:0];
  assign DBUS_1_ARSIZE = DBUS_arsize[2:0];
  assign DBUS_1_ARVALID = DBUS_arvalid;
  assign DBUS_1_AWADDR = DBUS_awaddr[31:0];
  assign DBUS_1_AWBURST = DBUS_awburst[1:0];
  assign DBUS_1_AWCACHE = DBUS_awcache[3:0];
  assign DBUS_1_AWID = DBUS_awid[0];
  assign DBUS_1_AWLEN = DBUS_awlen[7:0];
  assign DBUS_1_AWLOCK = DBUS_awlock[0];
  assign DBUS_1_AWPROT = DBUS_awprot[2:0];
  assign DBUS_1_AWQOS = DBUS_awqos[3:0];
  assign DBUS_1_AWSIZE = DBUS_awsize[2:0];
  assign DBUS_1_AWVALID = DBUS_awvalid;
  assign DBUS_1_BREADY = DBUS_bready;
  assign DBUS_1_RREADY = DBUS_rready;
  assign DBUS_1_WDATA = DBUS_wdata[31:0];
  assign DBUS_1_WLAST = DBUS_wlast;
  assign DBUS_1_WSTRB = DBUS_wstrb[3:0];
  assign DBUS_1_WVALID = DBUS_wvalid;
  assign DBUS_arready = DBUS_1_ARREADY;
  assign DBUS_awready = DBUS_1_AWREADY;
  assign DBUS_bid[0] = DBUS_1_BID;
  assign DBUS_bresp[1:0] = DBUS_1_BRESP;
  assign DBUS_bvalid = DBUS_1_BVALID;
  assign DBUS_rdata[31:0] = DBUS_1_RDATA;
  assign DBUS_rid[0] = DBUS_1_RID;
  assign DBUS_rlast = DBUS_1_RLAST;
  assign DBUS_rresp[1:0] = DBUS_1_RRESP;
  assign DBUS_rvalid = DBUS_1_RVALID;
  assign DBUS_wready = DBUS_1_WREADY;
  assign IBUS_1_ARADDR = IBUS_araddr[31:0];
  assign IBUS_1_ARBURST = IBUS_arburst[1:0];
  assign IBUS_1_ARCACHE = IBUS_arcache[3:0];
  assign IBUS_1_ARID = IBUS_arid[0];
  assign IBUS_1_ARLEN = IBUS_arlen[7:0];
  assign IBUS_1_ARLOCK = IBUS_arlock[0];
  assign IBUS_1_ARPROT = IBUS_arprot[2:0];
  assign IBUS_1_ARQOS = IBUS_arqos[3:0];
  assign IBUS_1_ARSIZE = IBUS_arsize[2:0];
  assign IBUS_1_ARVALID = IBUS_arvalid;
  assign IBUS_1_RREADY = IBUS_rready;
  assign IBUS_arready = IBUS_1_ARREADY;
  assign IBUS_rdata[31:0] = IBUS_1_RDATA;
  assign IBUS_rid[0] = IBUS_1_RID;
  assign IBUS_rlast = IBUS_1_RLAST;
  assign IBUS_rresp[1:0] = IBUS_1_RRESP;
  assign IBUS_rvalid = IBUS_1_RVALID;
  assign SDRAM_CLOCK_1 = SDRAM_CLOCK;
  assign SDRAM_araddr[31:0] = smartconnect_0_M00_AXI_ARADDR;
  assign SDRAM_arburst[1:0] = smartconnect_0_M00_AXI_ARBURST;
  assign SDRAM_arcache[3:0] = smartconnect_0_M00_AXI_ARCACHE;
  assign SDRAM_arlen[7:0] = smartconnect_0_M00_AXI_ARLEN;
  assign SDRAM_arlock[0] = smartconnect_0_M00_AXI_ARLOCK;
  assign SDRAM_arprot[2:0] = smartconnect_0_M00_AXI_ARPROT;
  assign SDRAM_arqos[3:0] = smartconnect_0_M00_AXI_ARQOS;
  assign SDRAM_arsize[2:0] = smartconnect_0_M00_AXI_ARSIZE;
  assign SDRAM_arvalid = smartconnect_0_M00_AXI_ARVALID;
  assign SDRAM_awaddr[31:0] = smartconnect_0_M00_AXI_AWADDR;
  assign SDRAM_awburst[1:0] = smartconnect_0_M00_AXI_AWBURST;
  assign SDRAM_awcache[3:0] = smartconnect_0_M00_AXI_AWCACHE;
  assign SDRAM_awlen[7:0] = smartconnect_0_M00_AXI_AWLEN;
  assign SDRAM_awlock[0] = smartconnect_0_M00_AXI_AWLOCK;
  assign SDRAM_awprot[2:0] = smartconnect_0_M00_AXI_AWPROT;
  assign SDRAM_awqos[3:0] = smartconnect_0_M00_AXI_AWQOS;
  assign SDRAM_awsize[2:0] = smartconnect_0_M00_AXI_AWSIZE;
  assign SDRAM_awvalid = smartconnect_0_M00_AXI_AWVALID;
  assign SDRAM_bready = smartconnect_0_M00_AXI_BREADY;
  assign SDRAM_rready = smartconnect_0_M00_AXI_RREADY;
  assign SDRAM_wdata[63:0] = smartconnect_0_M00_AXI_WDATA;
  assign SDRAM_wlast = smartconnect_0_M00_AXI_WLAST;
  assign SDRAM_wstrb[7:0] = smartconnect_0_M00_AXI_WSTRB;
  assign SDRAM_wvalid = smartconnect_0_M00_AXI_WVALID;
  assign VIDEO_CLOCK_1 = VIDEO_CLOCK;
  assign VIDEO_OUT_tdata[31:0] = axi_vdma_0_M_AXIS_MM2S_TDATA;
  assign VIDEO_OUT_tkeep[3:0] = axi_vdma_0_M_AXIS_MM2S_TKEEP;
  assign VIDEO_OUT_tlast = axi_vdma_0_M_AXIS_MM2S_TLAST;
  assign VIDEO_OUT_tuser[0] = axi_vdma_0_M_AXIS_MM2S_TUSER;
  assign VIDEO_OUT_tvalid = axi_vdma_0_M_AXIS_MM2S_TVALID;
  assign ZTA_CONTROL_araddr[31:0] = smartconnect_0_M03_AXI_ARADDR;
  assign ZTA_CONTROL_arburst[1:0] = smartconnect_0_M03_AXI_ARBURST;
  assign ZTA_CONTROL_arcache[3:0] = smartconnect_0_M03_AXI_ARCACHE;
  assign ZTA_CONTROL_arlen[7:0] = smartconnect_0_M03_AXI_ARLEN;
  assign ZTA_CONTROL_arlock[0] = smartconnect_0_M03_AXI_ARLOCK;
  assign ZTA_CONTROL_arprot[2:0] = smartconnect_0_M03_AXI_ARPROT;
  assign ZTA_CONTROL_arqos[3:0] = smartconnect_0_M03_AXI_ARQOS;
  assign ZTA_CONTROL_arsize[2:0] = smartconnect_0_M03_AXI_ARSIZE;
  assign ZTA_CONTROL_arvalid = smartconnect_0_M03_AXI_ARVALID;
  assign ZTA_CONTROL_awaddr[31:0] = smartconnect_0_M03_AXI_AWADDR;
  assign ZTA_CONTROL_awburst[1:0] = smartconnect_0_M03_AXI_AWBURST;
  assign ZTA_CONTROL_awcache[3:0] = smartconnect_0_M03_AXI_AWCACHE;
  assign ZTA_CONTROL_awlen[7:0] = smartconnect_0_M03_AXI_AWLEN;
  assign ZTA_CONTROL_awlock[0] = smartconnect_0_M03_AXI_AWLOCK;
  assign ZTA_CONTROL_awprot[2:0] = smartconnect_0_M03_AXI_AWPROT;
  assign ZTA_CONTROL_awqos[3:0] = smartconnect_0_M03_AXI_AWQOS;
  assign ZTA_CONTROL_awsize[2:0] = smartconnect_0_M03_AXI_AWSIZE;
  assign ZTA_CONTROL_awvalid = smartconnect_0_M03_AXI_AWVALID;
  assign ZTA_CONTROL_bready = smartconnect_0_M03_AXI_BREADY;
  assign ZTA_CONTROL_rready = smartconnect_0_M03_AXI_RREADY;
  assign ZTA_CONTROL_wdata[31:0] = smartconnect_0_M03_AXI_WDATA;
  assign ZTA_CONTROL_wlast = smartconnect_0_M03_AXI_WLAST;
  assign ZTA_CONTROL_wstrb[3:0] = smartconnect_0_M03_AXI_WSTRB;
  assign ZTA_CONTROL_wvalid = smartconnect_0_M03_AXI_WVALID;
  assign ZTA_DATA_1_ARADDR = ZTA_DATA_araddr[31:0];
  assign ZTA_DATA_1_ARBURST = ZTA_DATA_arburst[1:0];
  assign ZTA_DATA_1_ARCACHE = ZTA_DATA_arcache[3:0];
  assign ZTA_DATA_1_ARID = ZTA_DATA_arid[0];
  assign ZTA_DATA_1_ARLEN = ZTA_DATA_arlen[7:0];
  assign ZTA_DATA_1_ARLOCK = ZTA_DATA_arlock[0];
  assign ZTA_DATA_1_ARPROT = ZTA_DATA_arprot[2:0];
  assign ZTA_DATA_1_ARQOS = ZTA_DATA_arqos[3:0];
  assign ZTA_DATA_1_ARSIZE = ZTA_DATA_arsize[2:0];
  assign ZTA_DATA_1_ARVALID = ZTA_DATA_arvalid;
  assign ZTA_DATA_1_AWADDR = ZTA_DATA_awaddr[31:0];
  assign ZTA_DATA_1_AWBURST = ZTA_DATA_awburst[1:0];
  assign ZTA_DATA_1_AWCACHE = ZTA_DATA_awcache[3:0];
  assign ZTA_DATA_1_AWID = ZTA_DATA_awid[0];
  assign ZTA_DATA_1_AWLEN = ZTA_DATA_awlen[7:0];
  assign ZTA_DATA_1_AWLOCK = ZTA_DATA_awlock[0];
  assign ZTA_DATA_1_AWPROT = ZTA_DATA_awprot[2:0];
  assign ZTA_DATA_1_AWQOS = ZTA_DATA_awqos[3:0];
  assign ZTA_DATA_1_AWSIZE = ZTA_DATA_awsize[2:0];
  assign ZTA_DATA_1_AWVALID = ZTA_DATA_awvalid;
  assign ZTA_DATA_1_BREADY = ZTA_DATA_bready;
  assign ZTA_DATA_1_RREADY = ZTA_DATA_rready;
  assign ZTA_DATA_1_WDATA = ZTA_DATA_wdata[63:0];
  assign ZTA_DATA_1_WLAST = ZTA_DATA_wlast;
  assign ZTA_DATA_1_WSTRB = ZTA_DATA_wstrb[7:0];
  assign ZTA_DATA_1_WVALID = ZTA_DATA_wvalid;
  assign ZTA_DATA_arready = ZTA_DATA_1_ARREADY;
  assign ZTA_DATA_awready = ZTA_DATA_1_AWREADY;
  assign ZTA_DATA_bid[0] = ZTA_DATA_1_BID;
  assign ZTA_DATA_bresp[1:0] = ZTA_DATA_1_BRESP;
  assign ZTA_DATA_bvalid = ZTA_DATA_1_BVALID;
  assign ZTA_DATA_rdata[63:0] = ZTA_DATA_1_RDATA;
  assign ZTA_DATA_rid[0] = ZTA_DATA_1_RID;
  assign ZTA_DATA_rlast = ZTA_DATA_1_RLAST;
  assign ZTA_DATA_rresp[1:0] = ZTA_DATA_1_RRESP;
  assign ZTA_DATA_rvalid = ZTA_DATA_1_RVALID;
  assign ZTA_DATA_wready = ZTA_DATA_1_WREADY;
  assign axi_apb_bridge_0_APB_M_PRDATA = APB_0_prdata[31:0];
  assign axi_apb_bridge_0_APB_M_PREADY = APB_0_pready[0];
  assign axi_apb_bridge_0_APB_M_PSLVERR = APB_0_pslverr[0];
  assign axi_vdma_0_M_AXIS_MM2S_TREADY = VIDEO_OUT_tready;
  assign smartconnect_0_M00_AXI_ARREADY = SDRAM_arready;
  assign smartconnect_0_M00_AXI_AWREADY = SDRAM_awready;
  assign smartconnect_0_M00_AXI_BRESP = SDRAM_bresp[1:0];
  assign smartconnect_0_M00_AXI_BVALID = SDRAM_bvalid;
  assign smartconnect_0_M00_AXI_RDATA = SDRAM_rdata[63:0];
  assign smartconnect_0_M00_AXI_RLAST = SDRAM_rlast;
  assign smartconnect_0_M00_AXI_RRESP = SDRAM_rresp[1:0];
  assign smartconnect_0_M00_AXI_RVALID = SDRAM_rvalid;
  assign smartconnect_0_M00_AXI_WREADY = SDRAM_wready;
  assign smartconnect_0_M03_AXI_ARREADY = ZTA_CONTROL_arready;
  assign smartconnect_0_M03_AXI_AWREADY = ZTA_CONTROL_awready;
  assign smartconnect_0_M03_AXI_BRESP = ZTA_CONTROL_bresp[1:0];
  assign smartconnect_0_M03_AXI_BVALID = ZTA_CONTROL_bvalid;
  assign smartconnect_0_M03_AXI_RDATA = ZTA_CONTROL_rdata[31:0];
  assign smartconnect_0_M03_AXI_RLAST = ZTA_CONTROL_rlast;
  assign smartconnect_0_M03_AXI_RRESP = ZTA_CONTROL_rresp[1:0];
  assign smartconnect_0_M03_AXI_RVALID = ZTA_CONTROL_rvalid;
  assign smartconnect_0_M03_AXI_WREADY = ZTA_CONTROL_wready;
  crossbar_axi_apb_bridge_0_0 axi_apb_bridge_0
       (.m_apb_paddr(axi_apb_bridge_0_APB_M_PADDR),
        .m_apb_penable(axi_apb_bridge_0_APB_M_PENABLE),
        .m_apb_prdata(axi_apb_bridge_0_APB_M_PRDATA),
        .m_apb_pready(axi_apb_bridge_0_APB_M_PREADY),
        .m_apb_psel(axi_apb_bridge_0_APB_M_PSEL),
        .m_apb_pslverr(axi_apb_bridge_0_APB_M_PSLVERR),
        .m_apb_pwdata(axi_apb_bridge_0_APB_M_PWDATA),
        .m_apb_pwrite(axi_apb_bridge_0_APB_M_PWRITE),
        .s_axi_aclk(CLOCK_1),
        .s_axi_araddr(smartconnect_0_M01_AXI_ARADDR),
        .s_axi_aresetn(ARESETN_1),
        .s_axi_arready(smartconnect_0_M01_AXI_ARREADY),
        .s_axi_arvalid(smartconnect_0_M01_AXI_ARVALID),
        .s_axi_awaddr(smartconnect_0_M01_AXI_AWADDR),
        .s_axi_awready(smartconnect_0_M01_AXI_AWREADY),
        .s_axi_awvalid(smartconnect_0_M01_AXI_AWVALID),
        .s_axi_bready(smartconnect_0_M01_AXI_BREADY),
        .s_axi_bresp(smartconnect_0_M01_AXI_BRESP),
        .s_axi_bvalid(smartconnect_0_M01_AXI_BVALID),
        .s_axi_rdata(smartconnect_0_M01_AXI_RDATA),
        .s_axi_rready(smartconnect_0_M01_AXI_RREADY),
        .s_axi_rresp(smartconnect_0_M01_AXI_RRESP),
        .s_axi_rvalid(smartconnect_0_M01_AXI_RVALID),
        .s_axi_wdata(smartconnect_0_M01_AXI_WDATA),
        .s_axi_wready(smartconnect_0_M01_AXI_WREADY),
        .s_axi_wvalid(smartconnect_0_M01_AXI_WVALID));
  crossbar_axi_vdma_0_0 axi_vdma_0
       (.axi_resetn(ARESETN_1),
        .m_axi_mm2s_aclk(CLOCK_1),
        .m_axi_mm2s_araddr(axi_vdma_0_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_vdma_0_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_vdma_0_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_vdma_0_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_vdma_0_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_vdma_0_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_vdma_0_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_vdma_0_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_vdma_0_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_vdma_0_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_vdma_0_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_vdma_0_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_vdma_0_M_AXI_MM2S_RVALID),
        .m_axi_s2mm_aclk(CLOCK_1),
        .m_axi_s2mm_awaddr(axi_vdma_0_M_AXI_S2MM_AWADDR),
        .m_axi_s2mm_awburst(axi_vdma_0_M_AXI_S2MM_AWBURST),
        .m_axi_s2mm_awcache(axi_vdma_0_M_AXI_S2MM_AWCACHE),
        .m_axi_s2mm_awlen(axi_vdma_0_M_AXI_S2MM_AWLEN),
        .m_axi_s2mm_awprot(axi_vdma_0_M_AXI_S2MM_AWPROT),
        .m_axi_s2mm_awready(axi_vdma_0_M_AXI_S2MM_AWREADY),
        .m_axi_s2mm_awsize(axi_vdma_0_M_AXI_S2MM_AWSIZE),
        .m_axi_s2mm_awvalid(axi_vdma_0_M_AXI_S2MM_AWVALID),
        .m_axi_s2mm_bready(axi_vdma_0_M_AXI_S2MM_BREADY),
        .m_axi_s2mm_bresp(axi_vdma_0_M_AXI_S2MM_BRESP),
        .m_axi_s2mm_bvalid(axi_vdma_0_M_AXI_S2MM_BVALID),
        .m_axi_s2mm_wdata(axi_vdma_0_M_AXI_S2MM_WDATA),
        .m_axi_s2mm_wlast(axi_vdma_0_M_AXI_S2MM_WLAST),
        .m_axi_s2mm_wready(axi_vdma_0_M_AXI_S2MM_WREADY),
        .m_axi_s2mm_wstrb(axi_vdma_0_M_AXI_S2MM_WSTRB),
        .m_axi_s2mm_wvalid(axi_vdma_0_M_AXI_S2MM_WVALID),
        .m_axis_mm2s_aclk(VIDEO_CLOCK_1),
        .m_axis_mm2s_tdata(axi_vdma_0_M_AXIS_MM2S_TDATA),
        .m_axis_mm2s_tkeep(axi_vdma_0_M_AXIS_MM2S_TKEEP),
        .m_axis_mm2s_tlast(axi_vdma_0_M_AXIS_MM2S_TLAST),
        .m_axis_mm2s_tready(axi_vdma_0_M_AXIS_MM2S_TREADY),
        .m_axis_mm2s_tuser(axi_vdma_0_M_AXIS_MM2S_TUSER),
        .m_axis_mm2s_tvalid(axi_vdma_0_M_AXIS_MM2S_TVALID),
        .s_axi_lite_aclk(CLOCK_1),
        .s_axi_lite_araddr(smartconnect_0_M02_AXI_ARADDR),
        .s_axi_lite_arready(smartconnect_0_M02_AXI_ARREADY),
        .s_axi_lite_arvalid(smartconnect_0_M02_AXI_ARVALID),
        .s_axi_lite_awaddr(smartconnect_0_M02_AXI_AWADDR),
        .s_axi_lite_awready(smartconnect_0_M02_AXI_AWREADY),
        .s_axi_lite_awvalid(smartconnect_0_M02_AXI_AWVALID),
        .s_axi_lite_bready(smartconnect_0_M02_AXI_BREADY),
        .s_axi_lite_bresp(smartconnect_0_M02_AXI_BRESP),
        .s_axi_lite_bvalid(smartconnect_0_M02_AXI_BVALID),
        .s_axi_lite_rdata(smartconnect_0_M02_AXI_RDATA),
        .s_axi_lite_rready(smartconnect_0_M02_AXI_RREADY),
        .s_axi_lite_rresp(smartconnect_0_M02_AXI_RRESP),
        .s_axi_lite_rvalid(smartconnect_0_M02_AXI_RVALID),
        .s_axi_lite_wdata(smartconnect_0_M02_AXI_WDATA),
        .s_axi_lite_wready(smartconnect_0_M02_AXI_WREADY),
        .s_axi_lite_wvalid(smartconnect_0_M02_AXI_WVALID),
        .s_axis_s2mm_aclk(CAMERA_CLOCK_IN_1),
        .s_axis_s2mm_tdata(CAMERA_IN_1_TDATA),
        .s_axis_s2mm_tkeep(CAMERA_IN_1_TKEEP),
        .s_axis_s2mm_tlast(CAMERA_IN_1_TLAST),
        .s_axis_s2mm_tready(CAMERA_IN_1_TREADY),
        .s_axis_s2mm_tuser(CAMERA_IN_1_TUSER),
        .s_axis_s2mm_tvalid(CAMERA_IN_1_TVALID));
  crossbar_smartconnect_0_0 smartconnect_0
       (.M00_AXI_araddr(smartconnect_0_M00_AXI_ARADDR),
        .M00_AXI_arburst(smartconnect_0_M00_AXI_ARBURST),
        .M00_AXI_arcache(smartconnect_0_M00_AXI_ARCACHE),
        .M00_AXI_arlen(smartconnect_0_M00_AXI_ARLEN),
        .M00_AXI_arlock(smartconnect_0_M00_AXI_ARLOCK),
        .M00_AXI_arprot(smartconnect_0_M00_AXI_ARPROT),
        .M00_AXI_arqos(smartconnect_0_M00_AXI_ARQOS),
        .M00_AXI_arready(smartconnect_0_M00_AXI_ARREADY),
        .M00_AXI_arsize(smartconnect_0_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(smartconnect_0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(smartconnect_0_M00_AXI_AWADDR),
        .M00_AXI_awburst(smartconnect_0_M00_AXI_AWBURST),
        .M00_AXI_awcache(smartconnect_0_M00_AXI_AWCACHE),
        .M00_AXI_awlen(smartconnect_0_M00_AXI_AWLEN),
        .M00_AXI_awlock(smartconnect_0_M00_AXI_AWLOCK),
        .M00_AXI_awprot(smartconnect_0_M00_AXI_AWPROT),
        .M00_AXI_awqos(smartconnect_0_M00_AXI_AWQOS),
        .M00_AXI_awready(smartconnect_0_M00_AXI_AWREADY),
        .M00_AXI_awsize(smartconnect_0_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(smartconnect_0_M00_AXI_AWVALID),
        .M00_AXI_bready(smartconnect_0_M00_AXI_BREADY),
        .M00_AXI_bresp(smartconnect_0_M00_AXI_BRESP),
        .M00_AXI_bvalid(smartconnect_0_M00_AXI_BVALID),
        .M00_AXI_rdata(smartconnect_0_M00_AXI_RDATA),
        .M00_AXI_rlast(smartconnect_0_M00_AXI_RLAST),
        .M00_AXI_rready(smartconnect_0_M00_AXI_RREADY),
        .M00_AXI_rresp(smartconnect_0_M00_AXI_RRESP),
        .M00_AXI_rvalid(smartconnect_0_M00_AXI_RVALID),
        .M00_AXI_wdata(smartconnect_0_M00_AXI_WDATA),
        .M00_AXI_wlast(smartconnect_0_M00_AXI_WLAST),
        .M00_AXI_wready(smartconnect_0_M00_AXI_WREADY),
        .M00_AXI_wstrb(smartconnect_0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(smartconnect_0_M00_AXI_WVALID),
        .M01_AXI_araddr(smartconnect_0_M01_AXI_ARADDR),
        .M01_AXI_arready(smartconnect_0_M01_AXI_ARREADY),
        .M01_AXI_arvalid(smartconnect_0_M01_AXI_ARVALID),
        .M01_AXI_awaddr(smartconnect_0_M01_AXI_AWADDR),
        .M01_AXI_awready(smartconnect_0_M01_AXI_AWREADY),
        .M01_AXI_awvalid(smartconnect_0_M01_AXI_AWVALID),
        .M01_AXI_bready(smartconnect_0_M01_AXI_BREADY),
        .M01_AXI_bresp(smartconnect_0_M01_AXI_BRESP),
        .M01_AXI_bvalid(smartconnect_0_M01_AXI_BVALID),
        .M01_AXI_rdata(smartconnect_0_M01_AXI_RDATA),
        .M01_AXI_rready(smartconnect_0_M01_AXI_RREADY),
        .M01_AXI_rresp(smartconnect_0_M01_AXI_RRESP),
        .M01_AXI_rvalid(smartconnect_0_M01_AXI_RVALID),
        .M01_AXI_wdata(smartconnect_0_M01_AXI_WDATA),
        .M01_AXI_wready(smartconnect_0_M01_AXI_WREADY),
        .M01_AXI_wvalid(smartconnect_0_M01_AXI_WVALID),
        .M02_AXI_araddr(smartconnect_0_M02_AXI_ARADDR),
        .M02_AXI_arready(smartconnect_0_M02_AXI_ARREADY),
        .M02_AXI_arvalid(smartconnect_0_M02_AXI_ARVALID),
        .M02_AXI_awaddr(smartconnect_0_M02_AXI_AWADDR),
        .M02_AXI_awready(smartconnect_0_M02_AXI_AWREADY),
        .M02_AXI_awvalid(smartconnect_0_M02_AXI_AWVALID),
        .M02_AXI_bready(smartconnect_0_M02_AXI_BREADY),
        .M02_AXI_bresp(smartconnect_0_M02_AXI_BRESP),
        .M02_AXI_bvalid(smartconnect_0_M02_AXI_BVALID),
        .M02_AXI_rdata(smartconnect_0_M02_AXI_RDATA),
        .M02_AXI_rready(smartconnect_0_M02_AXI_RREADY),
        .M02_AXI_rresp(smartconnect_0_M02_AXI_RRESP),
        .M02_AXI_rvalid(smartconnect_0_M02_AXI_RVALID),
        .M02_AXI_wdata(smartconnect_0_M02_AXI_WDATA),
        .M02_AXI_wready(smartconnect_0_M02_AXI_WREADY),
        .M02_AXI_wvalid(smartconnect_0_M02_AXI_WVALID),
        .M03_AXI_araddr(smartconnect_0_M03_AXI_ARADDR),
        .M03_AXI_arburst(smartconnect_0_M03_AXI_ARBURST),
        .M03_AXI_arcache(smartconnect_0_M03_AXI_ARCACHE),
        .M03_AXI_arlen(smartconnect_0_M03_AXI_ARLEN),
        .M03_AXI_arlock(smartconnect_0_M03_AXI_ARLOCK),
        .M03_AXI_arprot(smartconnect_0_M03_AXI_ARPROT),
        .M03_AXI_arqos(smartconnect_0_M03_AXI_ARQOS),
        .M03_AXI_arready(smartconnect_0_M03_AXI_ARREADY),
        .M03_AXI_arsize(smartconnect_0_M03_AXI_ARSIZE),
        .M03_AXI_arvalid(smartconnect_0_M03_AXI_ARVALID),
        .M03_AXI_awaddr(smartconnect_0_M03_AXI_AWADDR),
        .M03_AXI_awburst(smartconnect_0_M03_AXI_AWBURST),
        .M03_AXI_awcache(smartconnect_0_M03_AXI_AWCACHE),
        .M03_AXI_awlen(smartconnect_0_M03_AXI_AWLEN),
        .M03_AXI_awlock(smartconnect_0_M03_AXI_AWLOCK),
        .M03_AXI_awprot(smartconnect_0_M03_AXI_AWPROT),
        .M03_AXI_awqos(smartconnect_0_M03_AXI_AWQOS),
        .M03_AXI_awready(smartconnect_0_M03_AXI_AWREADY),
        .M03_AXI_awsize(smartconnect_0_M03_AXI_AWSIZE),
        .M03_AXI_awvalid(smartconnect_0_M03_AXI_AWVALID),
        .M03_AXI_bready(smartconnect_0_M03_AXI_BREADY),
        .M03_AXI_bresp(smartconnect_0_M03_AXI_BRESP),
        .M03_AXI_bvalid(smartconnect_0_M03_AXI_BVALID),
        .M03_AXI_rdata(smartconnect_0_M03_AXI_RDATA),
        .M03_AXI_rlast(smartconnect_0_M03_AXI_RLAST),
        .M03_AXI_rready(smartconnect_0_M03_AXI_RREADY),
        .M03_AXI_rresp(smartconnect_0_M03_AXI_RRESP),
        .M03_AXI_rvalid(smartconnect_0_M03_AXI_RVALID),
        .M03_AXI_wdata(smartconnect_0_M03_AXI_WDATA),
        .M03_AXI_wlast(smartconnect_0_M03_AXI_WLAST),
        .M03_AXI_wready(smartconnect_0_M03_AXI_WREADY),
        .M03_AXI_wstrb(smartconnect_0_M03_AXI_WSTRB),
        .M03_AXI_wvalid(smartconnect_0_M03_AXI_WVALID),
        .S00_AXI_araddr(IBUS_1_ARADDR),
        .S00_AXI_arburst(IBUS_1_ARBURST),
        .S00_AXI_arcache(IBUS_1_ARCACHE),
        .S00_AXI_arid(IBUS_1_ARID),
        .S00_AXI_arlen(IBUS_1_ARLEN),
        .S00_AXI_arlock(IBUS_1_ARLOCK),
        .S00_AXI_arprot(IBUS_1_ARPROT),
        .S00_AXI_arqos(IBUS_1_ARQOS),
        .S00_AXI_arready(IBUS_1_ARREADY),
        .S00_AXI_arsize(IBUS_1_ARSIZE),
        .S00_AXI_arvalid(IBUS_1_ARVALID),
        .S00_AXI_rdata(IBUS_1_RDATA),
        .S00_AXI_rid(IBUS_1_RID),
        .S00_AXI_rlast(IBUS_1_RLAST),
        .S00_AXI_rready(IBUS_1_RREADY),
        .S00_AXI_rresp(IBUS_1_RRESP),
        .S00_AXI_rvalid(IBUS_1_RVALID),
        .S01_AXI_araddr(DBUS_1_ARADDR),
        .S01_AXI_arburst(DBUS_1_ARBURST),
        .S01_AXI_arcache(DBUS_1_ARCACHE),
        .S01_AXI_arid(DBUS_1_ARID),
        .S01_AXI_arlen(DBUS_1_ARLEN),
        .S01_AXI_arlock(DBUS_1_ARLOCK),
        .S01_AXI_arprot(DBUS_1_ARPROT),
        .S01_AXI_arqos(DBUS_1_ARQOS),
        .S01_AXI_arready(DBUS_1_ARREADY),
        .S01_AXI_arsize(DBUS_1_ARSIZE),
        .S01_AXI_arvalid(DBUS_1_ARVALID),
        .S01_AXI_awaddr(DBUS_1_AWADDR),
        .S01_AXI_awburst(DBUS_1_AWBURST),
        .S01_AXI_awcache(DBUS_1_AWCACHE),
        .S01_AXI_awid(DBUS_1_AWID),
        .S01_AXI_awlen(DBUS_1_AWLEN),
        .S01_AXI_awlock(DBUS_1_AWLOCK),
        .S01_AXI_awprot(DBUS_1_AWPROT),
        .S01_AXI_awqos(DBUS_1_AWQOS),
        .S01_AXI_awready(DBUS_1_AWREADY),
        .S01_AXI_awsize(DBUS_1_AWSIZE),
        .S01_AXI_awvalid(DBUS_1_AWVALID),
        .S01_AXI_bid(DBUS_1_BID),
        .S01_AXI_bready(DBUS_1_BREADY),
        .S01_AXI_bresp(DBUS_1_BRESP),
        .S01_AXI_bvalid(DBUS_1_BVALID),
        .S01_AXI_rdata(DBUS_1_RDATA),
        .S01_AXI_rid(DBUS_1_RID),
        .S01_AXI_rlast(DBUS_1_RLAST),
        .S01_AXI_rready(DBUS_1_RREADY),
        .S01_AXI_rresp(DBUS_1_RRESP),
        .S01_AXI_rvalid(DBUS_1_RVALID),
        .S01_AXI_wdata(DBUS_1_WDATA),
        .S01_AXI_wlast(DBUS_1_WLAST),
        .S01_AXI_wready(DBUS_1_WREADY),
        .S01_AXI_wstrb(DBUS_1_WSTRB),
        .S01_AXI_wvalid(DBUS_1_WVALID),
        .S02_AXI_araddr(axi_vdma_0_M_AXI_MM2S_ARADDR),
        .S02_AXI_arburst(axi_vdma_0_M_AXI_MM2S_ARBURST),
        .S02_AXI_arcache(axi_vdma_0_M_AXI_MM2S_ARCACHE),
        .S02_AXI_arlen(axi_vdma_0_M_AXI_MM2S_ARLEN),
        .S02_AXI_arlock(1'b0),
        .S02_AXI_arprot(axi_vdma_0_M_AXI_MM2S_ARPROT),
        .S02_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S02_AXI_arready(axi_vdma_0_M_AXI_MM2S_ARREADY),
        .S02_AXI_arsize(axi_vdma_0_M_AXI_MM2S_ARSIZE),
        .S02_AXI_arvalid(axi_vdma_0_M_AXI_MM2S_ARVALID),
        .S02_AXI_rdata(axi_vdma_0_M_AXI_MM2S_RDATA),
        .S02_AXI_rlast(axi_vdma_0_M_AXI_MM2S_RLAST),
        .S02_AXI_rready(axi_vdma_0_M_AXI_MM2S_RREADY),
        .S02_AXI_rresp(axi_vdma_0_M_AXI_MM2S_RRESP),
        .S02_AXI_rvalid(axi_vdma_0_M_AXI_MM2S_RVALID),
        .S03_AXI_awaddr(axi_vdma_0_M_AXI_S2MM_AWADDR),
        .S03_AXI_awburst(axi_vdma_0_M_AXI_S2MM_AWBURST),
        .S03_AXI_awcache(axi_vdma_0_M_AXI_S2MM_AWCACHE),
        .S03_AXI_awlen(axi_vdma_0_M_AXI_S2MM_AWLEN),
        .S03_AXI_awlock(1'b0),
        .S03_AXI_awprot(axi_vdma_0_M_AXI_S2MM_AWPROT),
        .S03_AXI_awqos({1'b0,1'b0,1'b0,1'b0}),
        .S03_AXI_awready(axi_vdma_0_M_AXI_S2MM_AWREADY),
        .S03_AXI_awsize(axi_vdma_0_M_AXI_S2MM_AWSIZE),
        .S03_AXI_awvalid(axi_vdma_0_M_AXI_S2MM_AWVALID),
        .S03_AXI_bready(axi_vdma_0_M_AXI_S2MM_BREADY),
        .S03_AXI_bresp(axi_vdma_0_M_AXI_S2MM_BRESP),
        .S03_AXI_bvalid(axi_vdma_0_M_AXI_S2MM_BVALID),
        .S03_AXI_wdata(axi_vdma_0_M_AXI_S2MM_WDATA),
        .S03_AXI_wlast(axi_vdma_0_M_AXI_S2MM_WLAST),
        .S03_AXI_wready(axi_vdma_0_M_AXI_S2MM_WREADY),
        .S03_AXI_wstrb(axi_vdma_0_M_AXI_S2MM_WSTRB),
        .S03_AXI_wvalid(axi_vdma_0_M_AXI_S2MM_WVALID),
        .S04_AXI_araddr(ZTA_DATA_1_ARADDR),
        .S04_AXI_arburst(ZTA_DATA_1_ARBURST),
        .S04_AXI_arcache(ZTA_DATA_1_ARCACHE),
        .S04_AXI_arid(ZTA_DATA_1_ARID),
        .S04_AXI_arlen(ZTA_DATA_1_ARLEN),
        .S04_AXI_arlock(ZTA_DATA_1_ARLOCK),
        .S04_AXI_arprot(ZTA_DATA_1_ARPROT),
        .S04_AXI_arqos(ZTA_DATA_1_ARQOS),
        .S04_AXI_arready(ZTA_DATA_1_ARREADY),
        .S04_AXI_arsize(ZTA_DATA_1_ARSIZE),
        .S04_AXI_arvalid(ZTA_DATA_1_ARVALID),
        .S04_AXI_awaddr(ZTA_DATA_1_AWADDR),
        .S04_AXI_awburst(ZTA_DATA_1_AWBURST),
        .S04_AXI_awcache(ZTA_DATA_1_AWCACHE),
        .S04_AXI_awid(ZTA_DATA_1_AWID),
        .S04_AXI_awlen(ZTA_DATA_1_AWLEN),
        .S04_AXI_awlock(ZTA_DATA_1_AWLOCK),
        .S04_AXI_awprot(ZTA_DATA_1_AWPROT),
        .S04_AXI_awqos(ZTA_DATA_1_AWQOS),
        .S04_AXI_awready(ZTA_DATA_1_AWREADY),
        .S04_AXI_awsize(ZTA_DATA_1_AWSIZE),
        .S04_AXI_awvalid(ZTA_DATA_1_AWVALID),
        .S04_AXI_bid(ZTA_DATA_1_BID),
        .S04_AXI_bready(ZTA_DATA_1_BREADY),
        .S04_AXI_bresp(ZTA_DATA_1_BRESP),
        .S04_AXI_bvalid(ZTA_DATA_1_BVALID),
        .S04_AXI_rdata(ZTA_DATA_1_RDATA),
        .S04_AXI_rid(ZTA_DATA_1_RID),
        .S04_AXI_rlast(ZTA_DATA_1_RLAST),
        .S04_AXI_rready(ZTA_DATA_1_RREADY),
        .S04_AXI_rresp(ZTA_DATA_1_RRESP),
        .S04_AXI_rvalid(ZTA_DATA_1_RVALID),
        .S04_AXI_wdata(ZTA_DATA_1_WDATA),
        .S04_AXI_wlast(ZTA_DATA_1_WLAST),
        .S04_AXI_wready(ZTA_DATA_1_WREADY),
        .S04_AXI_wstrb(ZTA_DATA_1_WSTRB),
        .S04_AXI_wvalid(ZTA_DATA_1_WVALID),
        .aclk(CLOCK_1),
        .aclk1(SDRAM_CLOCK_1),
        .aresetn(ARESETN_1));
endmodule
