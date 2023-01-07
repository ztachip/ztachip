//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Fri Jan  6 23:59:17 2023
//Host        : LAPTOP-RM6TVNC2 running 64-bit major release  (build 9200)
//Command     : generate_target crossbar_wrapper.bd
//Design      : crossbar_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module crossbar_wrapper
   (ARESETN,
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
    PERIPHERAL_araddr,
    PERIPHERAL_arburst,
    PERIPHERAL_arcache,
    PERIPHERAL_arlen,
    PERIPHERAL_arlock,
    PERIPHERAL_arprot,
    PERIPHERAL_arqos,
    PERIPHERAL_arready,
    PERIPHERAL_arsize,
    PERIPHERAL_arvalid,
    PERIPHERAL_awaddr,
    PERIPHERAL_awburst,
    PERIPHERAL_awcache,
    PERIPHERAL_awlen,
    PERIPHERAL_awlock,
    PERIPHERAL_awprot,
    PERIPHERAL_awqos,
    PERIPHERAL_awready,
    PERIPHERAL_awsize,
    PERIPHERAL_awvalid,
    PERIPHERAL_bready,
    PERIPHERAL_bresp,
    PERIPHERAL_bvalid,
    PERIPHERAL_rdata,
    PERIPHERAL_rlast,
    PERIPHERAL_rready,
    PERIPHERAL_rresp,
    PERIPHERAL_rvalid,
    PERIPHERAL_wdata,
    PERIPHERAL_wlast,
    PERIPHERAL_wready,
    PERIPHERAL_wstrb,
    PERIPHERAL_wvalid,
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
  input ARESETN;
  input CAMERA_CLOCK_IN;
  input [31:0]CAMERA_IN_tdata;
  input [3:0]CAMERA_IN_tkeep;
  input CAMERA_IN_tlast;
  output CAMERA_IN_tready;
  input [0:0]CAMERA_IN_tuser;
  input CAMERA_IN_tvalid;
  input CLOCK;
  input [31:0]DBUS_araddr;
  input [1:0]DBUS_arburst;
  input [3:0]DBUS_arcache;
  input [0:0]DBUS_arid;
  input [7:0]DBUS_arlen;
  input [0:0]DBUS_arlock;
  input [2:0]DBUS_arprot;
  input [3:0]DBUS_arqos;
  output DBUS_arready;
  input [2:0]DBUS_arsize;
  input DBUS_arvalid;
  input [31:0]DBUS_awaddr;
  input [1:0]DBUS_awburst;
  input [3:0]DBUS_awcache;
  input [0:0]DBUS_awid;
  input [7:0]DBUS_awlen;
  input [0:0]DBUS_awlock;
  input [2:0]DBUS_awprot;
  input [3:0]DBUS_awqos;
  output DBUS_awready;
  input [2:0]DBUS_awsize;
  input DBUS_awvalid;
  output [0:0]DBUS_bid;
  input DBUS_bready;
  output [1:0]DBUS_bresp;
  output DBUS_bvalid;
  output [31:0]DBUS_rdata;
  output [0:0]DBUS_rid;
  output DBUS_rlast;
  input DBUS_rready;
  output [1:0]DBUS_rresp;
  output DBUS_rvalid;
  input [31:0]DBUS_wdata;
  input DBUS_wlast;
  output DBUS_wready;
  input [3:0]DBUS_wstrb;
  input DBUS_wvalid;
  input [31:0]IBUS_araddr;
  input [1:0]IBUS_arburst;
  input [3:0]IBUS_arcache;
  input [0:0]IBUS_arid;
  input [7:0]IBUS_arlen;
  input [0:0]IBUS_arlock;
  input [2:0]IBUS_arprot;
  input [3:0]IBUS_arqos;
  output IBUS_arready;
  input [2:0]IBUS_arsize;
  input IBUS_arvalid;
  output [31:0]IBUS_rdata;
  output [0:0]IBUS_rid;
  output IBUS_rlast;
  input IBUS_rready;
  output [1:0]IBUS_rresp;
  output IBUS_rvalid;
  output [31:0]PERIPHERAL_araddr;
  output [1:0]PERIPHERAL_arburst;
  output [3:0]PERIPHERAL_arcache;
  output [7:0]PERIPHERAL_arlen;
  output [0:0]PERIPHERAL_arlock;
  output [2:0]PERIPHERAL_arprot;
  output [3:0]PERIPHERAL_arqos;
  input PERIPHERAL_arready;
  output [2:0]PERIPHERAL_arsize;
  output PERIPHERAL_arvalid;
  output [31:0]PERIPHERAL_awaddr;
  output [1:0]PERIPHERAL_awburst;
  output [3:0]PERIPHERAL_awcache;
  output [7:0]PERIPHERAL_awlen;
  output [0:0]PERIPHERAL_awlock;
  output [2:0]PERIPHERAL_awprot;
  output [3:0]PERIPHERAL_awqos;
  input PERIPHERAL_awready;
  output [2:0]PERIPHERAL_awsize;
  output PERIPHERAL_awvalid;
  output PERIPHERAL_bready;
  input [1:0]PERIPHERAL_bresp;
  input PERIPHERAL_bvalid;
  input [31:0]PERIPHERAL_rdata;
  input PERIPHERAL_rlast;
  output PERIPHERAL_rready;
  input [1:0]PERIPHERAL_rresp;
  input PERIPHERAL_rvalid;
  output [31:0]PERIPHERAL_wdata;
  output PERIPHERAL_wlast;
  input PERIPHERAL_wready;
  output [3:0]PERIPHERAL_wstrb;
  output PERIPHERAL_wvalid;
  input SDRAM_CLOCK;
  output [31:0]SDRAM_araddr;
  output [1:0]SDRAM_arburst;
  output [3:0]SDRAM_arcache;
  output [7:0]SDRAM_arlen;
  output [0:0]SDRAM_arlock;
  output [2:0]SDRAM_arprot;
  output [3:0]SDRAM_arqos;
  input SDRAM_arready;
  output [2:0]SDRAM_arsize;
  output SDRAM_arvalid;
  output [31:0]SDRAM_awaddr;
  output [1:0]SDRAM_awburst;
  output [3:0]SDRAM_awcache;
  output [7:0]SDRAM_awlen;
  output [0:0]SDRAM_awlock;
  output [2:0]SDRAM_awprot;
  output [3:0]SDRAM_awqos;
  input SDRAM_awready;
  output [2:0]SDRAM_awsize;
  output SDRAM_awvalid;
  output SDRAM_bready;
  input [1:0]SDRAM_bresp;
  input SDRAM_bvalid;
  input [63:0]SDRAM_rdata;
  input SDRAM_rlast;
  output SDRAM_rready;
  input [1:0]SDRAM_rresp;
  input SDRAM_rvalid;
  output [63:0]SDRAM_wdata;
  output SDRAM_wlast;
  input SDRAM_wready;
  output [7:0]SDRAM_wstrb;
  output SDRAM_wvalid;
  input VIDEO_CLOCK;
  output [31:0]VIDEO_OUT_tdata;
  output [3:0]VIDEO_OUT_tkeep;
  output VIDEO_OUT_tlast;
  input VIDEO_OUT_tready;
  output [0:0]VIDEO_OUT_tuser;
  output VIDEO_OUT_tvalid;
  output [31:0]ZTA_CONTROL_araddr;
  output [1:0]ZTA_CONTROL_arburst;
  output [3:0]ZTA_CONTROL_arcache;
  output [7:0]ZTA_CONTROL_arlen;
  output [0:0]ZTA_CONTROL_arlock;
  output [2:0]ZTA_CONTROL_arprot;
  output [3:0]ZTA_CONTROL_arqos;
  input ZTA_CONTROL_arready;
  output [2:0]ZTA_CONTROL_arsize;
  output ZTA_CONTROL_arvalid;
  output [31:0]ZTA_CONTROL_awaddr;
  output [1:0]ZTA_CONTROL_awburst;
  output [3:0]ZTA_CONTROL_awcache;
  output [7:0]ZTA_CONTROL_awlen;
  output [0:0]ZTA_CONTROL_awlock;
  output [2:0]ZTA_CONTROL_awprot;
  output [3:0]ZTA_CONTROL_awqos;
  input ZTA_CONTROL_awready;
  output [2:0]ZTA_CONTROL_awsize;
  output ZTA_CONTROL_awvalid;
  output ZTA_CONTROL_bready;
  input [1:0]ZTA_CONTROL_bresp;
  input ZTA_CONTROL_bvalid;
  input [31:0]ZTA_CONTROL_rdata;
  input ZTA_CONTROL_rlast;
  output ZTA_CONTROL_rready;
  input [1:0]ZTA_CONTROL_rresp;
  input ZTA_CONTROL_rvalid;
  output [31:0]ZTA_CONTROL_wdata;
  output ZTA_CONTROL_wlast;
  input ZTA_CONTROL_wready;
  output [3:0]ZTA_CONTROL_wstrb;
  output ZTA_CONTROL_wvalid;
  input [31:0]ZTA_DATA_araddr;
  input [1:0]ZTA_DATA_arburst;
  input [3:0]ZTA_DATA_arcache;
  input [0:0]ZTA_DATA_arid;
  input [7:0]ZTA_DATA_arlen;
  input [0:0]ZTA_DATA_arlock;
  input [2:0]ZTA_DATA_arprot;
  input [3:0]ZTA_DATA_arqos;
  output ZTA_DATA_arready;
  input [2:0]ZTA_DATA_arsize;
  input ZTA_DATA_arvalid;
  input [31:0]ZTA_DATA_awaddr;
  input [1:0]ZTA_DATA_awburst;
  input [3:0]ZTA_DATA_awcache;
  input [0:0]ZTA_DATA_awid;
  input [7:0]ZTA_DATA_awlen;
  input [0:0]ZTA_DATA_awlock;
  input [2:0]ZTA_DATA_awprot;
  input [3:0]ZTA_DATA_awqos;
  output ZTA_DATA_awready;
  input [2:0]ZTA_DATA_awsize;
  input ZTA_DATA_awvalid;
  output [0:0]ZTA_DATA_bid;
  input ZTA_DATA_bready;
  output [1:0]ZTA_DATA_bresp;
  output ZTA_DATA_bvalid;
  output [63:0]ZTA_DATA_rdata;
  output [0:0]ZTA_DATA_rid;
  output ZTA_DATA_rlast;
  input ZTA_DATA_rready;
  output [1:0]ZTA_DATA_rresp;
  output ZTA_DATA_rvalid;
  input [63:0]ZTA_DATA_wdata;
  input ZTA_DATA_wlast;
  output ZTA_DATA_wready;
  input [7:0]ZTA_DATA_wstrb;
  input ZTA_DATA_wvalid;

  wire ARESETN;
  wire CAMERA_CLOCK_IN;
  wire [31:0]CAMERA_IN_tdata;
  wire [3:0]CAMERA_IN_tkeep;
  wire CAMERA_IN_tlast;
  wire CAMERA_IN_tready;
  wire [0:0]CAMERA_IN_tuser;
  wire CAMERA_IN_tvalid;
  wire CLOCK;
  wire [31:0]DBUS_araddr;
  wire [1:0]DBUS_arburst;
  wire [3:0]DBUS_arcache;
  wire [0:0]DBUS_arid;
  wire [7:0]DBUS_arlen;
  wire [0:0]DBUS_arlock;
  wire [2:0]DBUS_arprot;
  wire [3:0]DBUS_arqos;
  wire DBUS_arready;
  wire [2:0]DBUS_arsize;
  wire DBUS_arvalid;
  wire [31:0]DBUS_awaddr;
  wire [1:0]DBUS_awburst;
  wire [3:0]DBUS_awcache;
  wire [0:0]DBUS_awid;
  wire [7:0]DBUS_awlen;
  wire [0:0]DBUS_awlock;
  wire [2:0]DBUS_awprot;
  wire [3:0]DBUS_awqos;
  wire DBUS_awready;
  wire [2:0]DBUS_awsize;
  wire DBUS_awvalid;
  wire [0:0]DBUS_bid;
  wire DBUS_bready;
  wire [1:0]DBUS_bresp;
  wire DBUS_bvalid;
  wire [31:0]DBUS_rdata;
  wire [0:0]DBUS_rid;
  wire DBUS_rlast;
  wire DBUS_rready;
  wire [1:0]DBUS_rresp;
  wire DBUS_rvalid;
  wire [31:0]DBUS_wdata;
  wire DBUS_wlast;
  wire DBUS_wready;
  wire [3:0]DBUS_wstrb;
  wire DBUS_wvalid;
  wire [31:0]IBUS_araddr;
  wire [1:0]IBUS_arburst;
  wire [3:0]IBUS_arcache;
  wire [0:0]IBUS_arid;
  wire [7:0]IBUS_arlen;
  wire [0:0]IBUS_arlock;
  wire [2:0]IBUS_arprot;
  wire [3:0]IBUS_arqos;
  wire IBUS_arready;
  wire [2:0]IBUS_arsize;
  wire IBUS_arvalid;
  wire [31:0]IBUS_rdata;
  wire [0:0]IBUS_rid;
  wire IBUS_rlast;
  wire IBUS_rready;
  wire [1:0]IBUS_rresp;
  wire IBUS_rvalid;
  wire [31:0]PERIPHERAL_araddr;
  wire [1:0]PERIPHERAL_arburst;
  wire [3:0]PERIPHERAL_arcache;
  wire [7:0]PERIPHERAL_arlen;
  wire [0:0]PERIPHERAL_arlock;
  wire [2:0]PERIPHERAL_arprot;
  wire [3:0]PERIPHERAL_arqos;
  wire PERIPHERAL_arready;
  wire [2:0]PERIPHERAL_arsize;
  wire PERIPHERAL_arvalid;
  wire [31:0]PERIPHERAL_awaddr;
  wire [1:0]PERIPHERAL_awburst;
  wire [3:0]PERIPHERAL_awcache;
  wire [7:0]PERIPHERAL_awlen;
  wire [0:0]PERIPHERAL_awlock;
  wire [2:0]PERIPHERAL_awprot;
  wire [3:0]PERIPHERAL_awqos;
  wire PERIPHERAL_awready;
  wire [2:0]PERIPHERAL_awsize;
  wire PERIPHERAL_awvalid;
  wire PERIPHERAL_bready;
  wire [1:0]PERIPHERAL_bresp;
  wire PERIPHERAL_bvalid;
  wire [31:0]PERIPHERAL_rdata;
  wire PERIPHERAL_rlast;
  wire PERIPHERAL_rready;
  wire [1:0]PERIPHERAL_rresp;
  wire PERIPHERAL_rvalid;
  wire [31:0]PERIPHERAL_wdata;
  wire PERIPHERAL_wlast;
  wire PERIPHERAL_wready;
  wire [3:0]PERIPHERAL_wstrb;
  wire PERIPHERAL_wvalid;
  wire SDRAM_CLOCK;
  wire [31:0]SDRAM_araddr;
  wire [1:0]SDRAM_arburst;
  wire [3:0]SDRAM_arcache;
  wire [7:0]SDRAM_arlen;
  wire [0:0]SDRAM_arlock;
  wire [2:0]SDRAM_arprot;
  wire [3:0]SDRAM_arqos;
  wire SDRAM_arready;
  wire [2:0]SDRAM_arsize;
  wire SDRAM_arvalid;
  wire [31:0]SDRAM_awaddr;
  wire [1:0]SDRAM_awburst;
  wire [3:0]SDRAM_awcache;
  wire [7:0]SDRAM_awlen;
  wire [0:0]SDRAM_awlock;
  wire [2:0]SDRAM_awprot;
  wire [3:0]SDRAM_awqos;
  wire SDRAM_awready;
  wire [2:0]SDRAM_awsize;
  wire SDRAM_awvalid;
  wire SDRAM_bready;
  wire [1:0]SDRAM_bresp;
  wire SDRAM_bvalid;
  wire [63:0]SDRAM_rdata;
  wire SDRAM_rlast;
  wire SDRAM_rready;
  wire [1:0]SDRAM_rresp;
  wire SDRAM_rvalid;
  wire [63:0]SDRAM_wdata;
  wire SDRAM_wlast;
  wire SDRAM_wready;
  wire [7:0]SDRAM_wstrb;
  wire SDRAM_wvalid;
  wire VIDEO_CLOCK;
  wire [31:0]VIDEO_OUT_tdata;
  wire [3:0]VIDEO_OUT_tkeep;
  wire VIDEO_OUT_tlast;
  wire VIDEO_OUT_tready;
  wire [0:0]VIDEO_OUT_tuser;
  wire VIDEO_OUT_tvalid;
  wire [31:0]ZTA_CONTROL_araddr;
  wire [1:0]ZTA_CONTROL_arburst;
  wire [3:0]ZTA_CONTROL_arcache;
  wire [7:0]ZTA_CONTROL_arlen;
  wire [0:0]ZTA_CONTROL_arlock;
  wire [2:0]ZTA_CONTROL_arprot;
  wire [3:0]ZTA_CONTROL_arqos;
  wire ZTA_CONTROL_arready;
  wire [2:0]ZTA_CONTROL_arsize;
  wire ZTA_CONTROL_arvalid;
  wire [31:0]ZTA_CONTROL_awaddr;
  wire [1:0]ZTA_CONTROL_awburst;
  wire [3:0]ZTA_CONTROL_awcache;
  wire [7:0]ZTA_CONTROL_awlen;
  wire [0:0]ZTA_CONTROL_awlock;
  wire [2:0]ZTA_CONTROL_awprot;
  wire [3:0]ZTA_CONTROL_awqos;
  wire ZTA_CONTROL_awready;
  wire [2:0]ZTA_CONTROL_awsize;
  wire ZTA_CONTROL_awvalid;
  wire ZTA_CONTROL_bready;
  wire [1:0]ZTA_CONTROL_bresp;
  wire ZTA_CONTROL_bvalid;
  wire [31:0]ZTA_CONTROL_rdata;
  wire ZTA_CONTROL_rlast;
  wire ZTA_CONTROL_rready;
  wire [1:0]ZTA_CONTROL_rresp;
  wire ZTA_CONTROL_rvalid;
  wire [31:0]ZTA_CONTROL_wdata;
  wire ZTA_CONTROL_wlast;
  wire ZTA_CONTROL_wready;
  wire [3:0]ZTA_CONTROL_wstrb;
  wire ZTA_CONTROL_wvalid;
  wire [31:0]ZTA_DATA_araddr;
  wire [1:0]ZTA_DATA_arburst;
  wire [3:0]ZTA_DATA_arcache;
  wire [0:0]ZTA_DATA_arid;
  wire [7:0]ZTA_DATA_arlen;
  wire [0:0]ZTA_DATA_arlock;
  wire [2:0]ZTA_DATA_arprot;
  wire [3:0]ZTA_DATA_arqos;
  wire ZTA_DATA_arready;
  wire [2:0]ZTA_DATA_arsize;
  wire ZTA_DATA_arvalid;
  wire [31:0]ZTA_DATA_awaddr;
  wire [1:0]ZTA_DATA_awburst;
  wire [3:0]ZTA_DATA_awcache;
  wire [0:0]ZTA_DATA_awid;
  wire [7:0]ZTA_DATA_awlen;
  wire [0:0]ZTA_DATA_awlock;
  wire [2:0]ZTA_DATA_awprot;
  wire [3:0]ZTA_DATA_awqos;
  wire ZTA_DATA_awready;
  wire [2:0]ZTA_DATA_awsize;
  wire ZTA_DATA_awvalid;
  wire [0:0]ZTA_DATA_bid;
  wire ZTA_DATA_bready;
  wire [1:0]ZTA_DATA_bresp;
  wire ZTA_DATA_bvalid;
  wire [63:0]ZTA_DATA_rdata;
  wire [0:0]ZTA_DATA_rid;
  wire ZTA_DATA_rlast;
  wire ZTA_DATA_rready;
  wire [1:0]ZTA_DATA_rresp;
  wire ZTA_DATA_rvalid;
  wire [63:0]ZTA_DATA_wdata;
  wire ZTA_DATA_wlast;
  wire ZTA_DATA_wready;
  wire [7:0]ZTA_DATA_wstrb;
  wire ZTA_DATA_wvalid;

  crossbar crossbar_i
       (.ARESETN(ARESETN),
        .CAMERA_CLOCK_IN(CAMERA_CLOCK_IN),
        .CAMERA_IN_tdata(CAMERA_IN_tdata),
        .CAMERA_IN_tkeep(CAMERA_IN_tkeep),
        .CAMERA_IN_tlast(CAMERA_IN_tlast),
        .CAMERA_IN_tready(CAMERA_IN_tready),
        .CAMERA_IN_tuser(CAMERA_IN_tuser),
        .CAMERA_IN_tvalid(CAMERA_IN_tvalid),
        .CLOCK(CLOCK),
        .DBUS_araddr(DBUS_araddr),
        .DBUS_arburst(DBUS_arburst),
        .DBUS_arcache(DBUS_arcache),
        .DBUS_arid(DBUS_arid),
        .DBUS_arlen(DBUS_arlen),
        .DBUS_arlock(DBUS_arlock),
        .DBUS_arprot(DBUS_arprot),
        .DBUS_arqos(DBUS_arqos),
        .DBUS_arready(DBUS_arready),
        .DBUS_arsize(DBUS_arsize),
        .DBUS_arvalid(DBUS_arvalid),
        .DBUS_awaddr(DBUS_awaddr),
        .DBUS_awburst(DBUS_awburst),
        .DBUS_awcache(DBUS_awcache),
        .DBUS_awid(DBUS_awid),
        .DBUS_awlen(DBUS_awlen),
        .DBUS_awlock(DBUS_awlock),
        .DBUS_awprot(DBUS_awprot),
        .DBUS_awqos(DBUS_awqos),
        .DBUS_awready(DBUS_awready),
        .DBUS_awsize(DBUS_awsize),
        .DBUS_awvalid(DBUS_awvalid),
        .DBUS_bid(DBUS_bid),
        .DBUS_bready(DBUS_bready),
        .DBUS_bresp(DBUS_bresp),
        .DBUS_bvalid(DBUS_bvalid),
        .DBUS_rdata(DBUS_rdata),
        .DBUS_rid(DBUS_rid),
        .DBUS_rlast(DBUS_rlast),
        .DBUS_rready(DBUS_rready),
        .DBUS_rresp(DBUS_rresp),
        .DBUS_rvalid(DBUS_rvalid),
        .DBUS_wdata(DBUS_wdata),
        .DBUS_wlast(DBUS_wlast),
        .DBUS_wready(DBUS_wready),
        .DBUS_wstrb(DBUS_wstrb),
        .DBUS_wvalid(DBUS_wvalid),
        .IBUS_araddr(IBUS_araddr),
        .IBUS_arburst(IBUS_arburst),
        .IBUS_arcache(IBUS_arcache),
        .IBUS_arid(IBUS_arid),
        .IBUS_arlen(IBUS_arlen),
        .IBUS_arlock(IBUS_arlock),
        .IBUS_arprot(IBUS_arprot),
        .IBUS_arqos(IBUS_arqos),
        .IBUS_arready(IBUS_arready),
        .IBUS_arsize(IBUS_arsize),
        .IBUS_arvalid(IBUS_arvalid),
        .IBUS_rdata(IBUS_rdata),
        .IBUS_rid(IBUS_rid),
        .IBUS_rlast(IBUS_rlast),
        .IBUS_rready(IBUS_rready),
        .IBUS_rresp(IBUS_rresp),
        .IBUS_rvalid(IBUS_rvalid),
        .PERIPHERAL_araddr(PERIPHERAL_araddr),
        .PERIPHERAL_arburst(PERIPHERAL_arburst),
        .PERIPHERAL_arcache(PERIPHERAL_arcache),
        .PERIPHERAL_arlen(PERIPHERAL_arlen),
        .PERIPHERAL_arlock(PERIPHERAL_arlock),
        .PERIPHERAL_arprot(PERIPHERAL_arprot),
        .PERIPHERAL_arqos(PERIPHERAL_arqos),
        .PERIPHERAL_arready(PERIPHERAL_arready),
        .PERIPHERAL_arsize(PERIPHERAL_arsize),
        .PERIPHERAL_arvalid(PERIPHERAL_arvalid),
        .PERIPHERAL_awaddr(PERIPHERAL_awaddr),
        .PERIPHERAL_awburst(PERIPHERAL_awburst),
        .PERIPHERAL_awcache(PERIPHERAL_awcache),
        .PERIPHERAL_awlen(PERIPHERAL_awlen),
        .PERIPHERAL_awlock(PERIPHERAL_awlock),
        .PERIPHERAL_awprot(PERIPHERAL_awprot),
        .PERIPHERAL_awqos(PERIPHERAL_awqos),
        .PERIPHERAL_awready(PERIPHERAL_awready),
        .PERIPHERAL_awsize(PERIPHERAL_awsize),
        .PERIPHERAL_awvalid(PERIPHERAL_awvalid),
        .PERIPHERAL_bready(PERIPHERAL_bready),
        .PERIPHERAL_bresp(PERIPHERAL_bresp),
        .PERIPHERAL_bvalid(PERIPHERAL_bvalid),
        .PERIPHERAL_rdata(PERIPHERAL_rdata),
        .PERIPHERAL_rlast(PERIPHERAL_rlast),
        .PERIPHERAL_rready(PERIPHERAL_rready),
        .PERIPHERAL_rresp(PERIPHERAL_rresp),
        .PERIPHERAL_rvalid(PERIPHERAL_rvalid),
        .PERIPHERAL_wdata(PERIPHERAL_wdata),
        .PERIPHERAL_wlast(PERIPHERAL_wlast),
        .PERIPHERAL_wready(PERIPHERAL_wready),
        .PERIPHERAL_wstrb(PERIPHERAL_wstrb),
        .PERIPHERAL_wvalid(PERIPHERAL_wvalid),
        .SDRAM_CLOCK(SDRAM_CLOCK),
        .SDRAM_araddr(SDRAM_araddr),
        .SDRAM_arburst(SDRAM_arburst),
        .SDRAM_arcache(SDRAM_arcache),
        .SDRAM_arlen(SDRAM_arlen),
        .SDRAM_arlock(SDRAM_arlock),
        .SDRAM_arprot(SDRAM_arprot),
        .SDRAM_arqos(SDRAM_arqos),
        .SDRAM_arready(SDRAM_arready),
        .SDRAM_arsize(SDRAM_arsize),
        .SDRAM_arvalid(SDRAM_arvalid),
        .SDRAM_awaddr(SDRAM_awaddr),
        .SDRAM_awburst(SDRAM_awburst),
        .SDRAM_awcache(SDRAM_awcache),
        .SDRAM_awlen(SDRAM_awlen),
        .SDRAM_awlock(SDRAM_awlock),
        .SDRAM_awprot(SDRAM_awprot),
        .SDRAM_awqos(SDRAM_awqos),
        .SDRAM_awready(SDRAM_awready),
        .SDRAM_awsize(SDRAM_awsize),
        .SDRAM_awvalid(SDRAM_awvalid),
        .SDRAM_bready(SDRAM_bready),
        .SDRAM_bresp(SDRAM_bresp),
        .SDRAM_bvalid(SDRAM_bvalid),
        .SDRAM_rdata(SDRAM_rdata),
        .SDRAM_rlast(SDRAM_rlast),
        .SDRAM_rready(SDRAM_rready),
        .SDRAM_rresp(SDRAM_rresp),
        .SDRAM_rvalid(SDRAM_rvalid),
        .SDRAM_wdata(SDRAM_wdata),
        .SDRAM_wlast(SDRAM_wlast),
        .SDRAM_wready(SDRAM_wready),
        .SDRAM_wstrb(SDRAM_wstrb),
        .SDRAM_wvalid(SDRAM_wvalid),
        .VIDEO_CLOCK(VIDEO_CLOCK),
        .VIDEO_OUT_tdata(VIDEO_OUT_tdata),
        .VIDEO_OUT_tkeep(VIDEO_OUT_tkeep),
        .VIDEO_OUT_tlast(VIDEO_OUT_tlast),
        .VIDEO_OUT_tready(VIDEO_OUT_tready),
        .VIDEO_OUT_tuser(VIDEO_OUT_tuser),
        .VIDEO_OUT_tvalid(VIDEO_OUT_tvalid),
        .ZTA_CONTROL_araddr(ZTA_CONTROL_araddr),
        .ZTA_CONTROL_arburst(ZTA_CONTROL_arburst),
        .ZTA_CONTROL_arcache(ZTA_CONTROL_arcache),
        .ZTA_CONTROL_arlen(ZTA_CONTROL_arlen),
        .ZTA_CONTROL_arlock(ZTA_CONTROL_arlock),
        .ZTA_CONTROL_arprot(ZTA_CONTROL_arprot),
        .ZTA_CONTROL_arqos(ZTA_CONTROL_arqos),
        .ZTA_CONTROL_arready(ZTA_CONTROL_arready),
        .ZTA_CONTROL_arsize(ZTA_CONTROL_arsize),
        .ZTA_CONTROL_arvalid(ZTA_CONTROL_arvalid),
        .ZTA_CONTROL_awaddr(ZTA_CONTROL_awaddr),
        .ZTA_CONTROL_awburst(ZTA_CONTROL_awburst),
        .ZTA_CONTROL_awcache(ZTA_CONTROL_awcache),
        .ZTA_CONTROL_awlen(ZTA_CONTROL_awlen),
        .ZTA_CONTROL_awlock(ZTA_CONTROL_awlock),
        .ZTA_CONTROL_awprot(ZTA_CONTROL_awprot),
        .ZTA_CONTROL_awqos(ZTA_CONTROL_awqos),
        .ZTA_CONTROL_awready(ZTA_CONTROL_awready),
        .ZTA_CONTROL_awsize(ZTA_CONTROL_awsize),
        .ZTA_CONTROL_awvalid(ZTA_CONTROL_awvalid),
        .ZTA_CONTROL_bready(ZTA_CONTROL_bready),
        .ZTA_CONTROL_bresp(ZTA_CONTROL_bresp),
        .ZTA_CONTROL_bvalid(ZTA_CONTROL_bvalid),
        .ZTA_CONTROL_rdata(ZTA_CONTROL_rdata),
        .ZTA_CONTROL_rlast(ZTA_CONTROL_rlast),
        .ZTA_CONTROL_rready(ZTA_CONTROL_rready),
        .ZTA_CONTROL_rresp(ZTA_CONTROL_rresp),
        .ZTA_CONTROL_rvalid(ZTA_CONTROL_rvalid),
        .ZTA_CONTROL_wdata(ZTA_CONTROL_wdata),
        .ZTA_CONTROL_wlast(ZTA_CONTROL_wlast),
        .ZTA_CONTROL_wready(ZTA_CONTROL_wready),
        .ZTA_CONTROL_wstrb(ZTA_CONTROL_wstrb),
        .ZTA_CONTROL_wvalid(ZTA_CONTROL_wvalid),
        .ZTA_DATA_araddr(ZTA_DATA_araddr),
        .ZTA_DATA_arburst(ZTA_DATA_arburst),
        .ZTA_DATA_arcache(ZTA_DATA_arcache),
        .ZTA_DATA_arid(ZTA_DATA_arid),
        .ZTA_DATA_arlen(ZTA_DATA_arlen),
        .ZTA_DATA_arlock(ZTA_DATA_arlock),
        .ZTA_DATA_arprot(ZTA_DATA_arprot),
        .ZTA_DATA_arqos(ZTA_DATA_arqos),
        .ZTA_DATA_arready(ZTA_DATA_arready),
        .ZTA_DATA_arsize(ZTA_DATA_arsize),
        .ZTA_DATA_arvalid(ZTA_DATA_arvalid),
        .ZTA_DATA_awaddr(ZTA_DATA_awaddr),
        .ZTA_DATA_awburst(ZTA_DATA_awburst),
        .ZTA_DATA_awcache(ZTA_DATA_awcache),
        .ZTA_DATA_awid(ZTA_DATA_awid),
        .ZTA_DATA_awlen(ZTA_DATA_awlen),
        .ZTA_DATA_awlock(ZTA_DATA_awlock),
        .ZTA_DATA_awprot(ZTA_DATA_awprot),
        .ZTA_DATA_awqos(ZTA_DATA_awqos),
        .ZTA_DATA_awready(ZTA_DATA_awready),
        .ZTA_DATA_awsize(ZTA_DATA_awsize),
        .ZTA_DATA_awvalid(ZTA_DATA_awvalid),
        .ZTA_DATA_bid(ZTA_DATA_bid),
        .ZTA_DATA_bready(ZTA_DATA_bready),
        .ZTA_DATA_bresp(ZTA_DATA_bresp),
        .ZTA_DATA_bvalid(ZTA_DATA_bvalid),
        .ZTA_DATA_rdata(ZTA_DATA_rdata),
        .ZTA_DATA_rid(ZTA_DATA_rid),
        .ZTA_DATA_rlast(ZTA_DATA_rlast),
        .ZTA_DATA_rready(ZTA_DATA_rready),
        .ZTA_DATA_rresp(ZTA_DATA_rresp),
        .ZTA_DATA_rvalid(ZTA_DATA_rvalid),
        .ZTA_DATA_wdata(ZTA_DATA_wdata),
        .ZTA_DATA_wlast(ZTA_DATA_wlast),
        .ZTA_DATA_wready(ZTA_DATA_wready),
        .ZTA_DATA_wstrb(ZTA_DATA_wstrb),
        .ZTA_DATA_wvalid(ZTA_DATA_wvalid));
endmodule
