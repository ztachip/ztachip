//---------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//----------------------------------------------------------------------------
//
// This is the reference design to show how to build a SOC with ztachip as 
// accelerator for vision/AI workload
//
// The example here is based on Xilinx ArtyA7 board. However, it is generic
// and can be adapted to other FPGA or ASIC platform.
// When ported to other FPGA/ASIC, the components to be replaced in this example
// are DDR-Controller and AXI crossbar. Other components including ztachip are 
// generic HDL implementation.
//
// Processor used here is RISCV based on VexRiscv implementation
//
// Components are interconnected over AXI bus (memory-map/stream/peripheral).
//
//    1) DDR memory controller is connected via 64-bit AXI memory-mapped bus.
//    2) RISCV has 2 AXI bus
//       * one for cpu instruction bus
//       * one for cpu data bus
//    3) ZTACHIP has 2 AXI bus
//       * one to receive tensor instructions from RISCV
//       * one to initiate memory DMA transfer
//    4) VGA receives screen data from DDR memory over AXI streaming bus.
//       * DDR Memory blocks are managed by Xilinx VDMA within AXI crossbar.
//    5) CAMERA sends captured data to DDR memory over AXI streaming bus.
//       * DDR Memory blocks are managed by Xilinx VDMA within AXI crossbar. 
//    6) GPIO is connected via AXI Advanced Peripheral Bus.
//
//  +-----------+
//  +           + AXI-MM     +--------------+
//  +           +----------->+  DDR         +--> DDR3 Bus
//  +           +            +  Controller  +
//  +           +            +--------------+
//  +           +
//  +           + AXI-MM     +--------------+
//  +           +<-----------+ I  RISCV     +
//  +           +<-----------+ D (VexRiscv) +
//  +           +            +--------------+
//  +           +
//  +    AXI    + AXI-MM     +--------------+
//  +  CROSSBAR +----------->+ C  ztachip   +
//  +           +<-----------+ D            +
//  +           +            +--------------+
//  +           +
//  +           + AXI-Stream +--------------+
//  +           +------------+     VGA      +--> VGA signals
//  +           +            +--------------+
//  +           +
//  +           + AXI-Stream +--------------+
//  +           +------------+    Camera    +--> OV7670 I2C/Signals               
//  +           +            +--------------+
//  +           +
//  +           + AXI-APB    +--------------+
//  +           +------------+     GPIO     +--> LED/BUTTON
//  +           +            +--------------+
//  +-----------+
//

//--------------------------------------------------------------------------
//                  TOP COMPONENT DECLARATION
//                  SIGNAL/PIN ASSIGNMENTS
//--------------------------------------------------------------------------
                              
module main(
   
   // Reference clock/external reset
   
   input          sys_resetn,
   input          sys_clock,
   
   //  DDR signals 
   
   output [13:0]  ddr3_sdram_addr,
   output [2:0]   ddr3_sdram_ba,
   output         ddr3_sdram_cas_n,
   output [0:0]   ddr3_sdram_ck_n,
   output [0:0]   ddr3_sdram_ck_p,
   output [0:0]   ddr3_sdram_cke,
   output [0:0]   ddr3_sdram_cs_n,
   output [1:0]   ddr3_sdram_dm,
   inout [15:0]   ddr3_sdram_dq,
   inout [1:0]    ddr3_sdram_dqs_n,
   inout [1:0]    ddr3_sdram_dqs_p,
   output [0:0]   ddr3_sdram_odt,
   output         ddr3_sdram_ras_n,
   output         ddr3_sdram_reset_n,
   output         ddr3_sdram_we_n,
   
   // UART signals
   
   output         UART_TXD,
   input          UART_RXD,
   
   // GPIO signals
   
   output [3:0]   led,
   input [3:0]    pushbutton,
   
   // VGA signals
   
   output         VGA_HS_O,
   output         VGA_VS_O,
   output [3:0]   VGA_R,
   output [3:0]   VGA_B,
   output [3:0]   VGA_G,
   
   // CAMERA signals
   
   output         CAMERA_SCL,
   input          CAMERA_VS,
   input          CAMERA_PCLK,
   input [7:0]    CAMERA_D,
   output         CAMERA_RESET,
   inout          CAMERA_SDR,
   input          CAMERA_RS,
   output         CAMERA_MCLK,
   output         CAMERA_PWDN      
   );
   
//--------------------------------------------------------------------------
//                       IMPLEMENTATION
//--------------------------------------------------------------------------   
            
   // Clocks
   wire 		      ui_clk;
   wire 		      ui_clk_sync_rst;
   wire               clk_camera;   
   wire               clk_vga;
   wire               clk_mig_ref;
   wire               clk_mig_sysclk;
   wire               clk_main;

   // Resets
   wire               clk_resetn;
   wire               clk_reset;
   
   // VexRiscv IBUS axi signals
      
   wire [31:0]        ibus_araddr;
   wire [7:0]         ibus_arlen;
   wire [2:0]         ibus_arsize;
   wire [1:0]         ibus_arburst;
   wire               ibus_arvalid;
   wire               ibus_arready;
   wire [1:0]         ibus_arid;
   wire [0:0]         ibus_arlock;
   wire [3:0]         ibus_arcache;
   wire [2:0]         ibus_arprot;
   wire [3:0]         ibus_arqos;
   wire               ibus_rready;
   wire [1:0]         ibus_rid;
   wire [31:0]        ibus_rdata;
   wire [1:0]         ibus_rresp;
   wire               ibus_rlast;
   wire               ibus_rvalid;

   // VexRiscv DBUS axi signals

   wire [31:0]        dbus_awaddr;
   wire [7:0]         dbus_awlen;
   wire [2:0]         dbus_awsize;
   wire [1:0]         dbus_awburst;
   wire               dbus_awvalid;
   wire               dbus_awready;
   wire [1:0]         dbus_awid;
   wire [0:0]         dbus_awlock;
   wire [3:0]         dbus_awcache;
   wire [2:0]         dbus_awprot;
   wire [3:0]         dbus_awqos;
   wire [31:0]        dbus_wdata;
   wire [3:0]         dbus_wstrb;
   wire               dbus_wlast;
   wire               dbus_wvalid;
   wire               dbus_wready;
   wire               dbus_bready;
   wire [1:0]         dbus_bresp;
   wire               dbus_bvalid;
   wire [1:0]         dbus_bid;
   wire [31:0]        dbus_araddr;
   wire [7:0]         dbus_arlen;
   wire [2:0]         dbus_arsize;
   wire [1:0]         dbus_arburst;
   wire               dbus_arvalid;
   wire               dbus_arready;
   wire [1:0]         dbus_arid;
   wire [0:0]         dbus_arlock;
   wire [3:0]         dbus_arcache;
   wire [2:0]         dbus_arprot;
   wire [3:0]         dbus_arqos;
   wire               dbus_rready;
   wire [31:0]        dbus_rdata;
   wire [1:0]         dbus_rresp;
   wire               dbus_rlast;
   wire               dbus_rvalid;
   wire [1:0]         dbus_rid;

   // SDRAM axi signals
   
   wire [31:0]        SDRAM_araddr;
   wire [1:0]         SDRAM_arburst;
   wire [3:0]         SDRAM_arcache;
   wire [7:0]         SDRAM_arlen;
   wire [0:0]         SDRAM_arlock;
   wire [2:0]         SDRAM_arprot;
   wire [3:0]         SDRAM_arqos;
   wire [0:0]         SDRAM_arready;
   wire [2:0]         SDRAM_arsize;
   wire [0:0]         SDRAM_arvalid;
   wire [31:0]        SDRAM_awaddr;
   wire [1:0]         SDRAM_awburst;
   wire [3:0]         SDRAM_awcache;
   wire [7:0]         SDRAM_awlen;
   wire [0:0]         SDRAM_awlock;
   wire [2:0]         SDRAM_awprot;
   wire [3:0]         SDRAM_awqos;
   wire [0:0]         SDRAM_awready;
   wire [2:0]         SDRAM_awsize;
   wire [0:0]         SDRAM_awvalid;
   wire [0:0]         SDRAM_bready;
   wire [1:0]         SDRAM_bresp;
   wire [0:0]         SDRAM_bvalid;
   wire [63:0]        SDRAM_rdata;
   wire [0:0]         SDRAM_rlast;
   wire [0:0]         SDRAM_rready;
   wire [1:0]         SDRAM_rresp;
   wire [0:0]         SDRAM_rvalid;
   wire [63:0]        SDRAM_wdata;
   wire [0:0]         SDRAM_wlast;
   wire [0:0]         SDRAM_wready;
   wire [7:0]         SDRAM_wstrb;
   wire [0:0]         SDRAM_wvalid;
   wire [3:0]         SDRAM_bid;
   wire [3:0]         SDRAM_rid;
  
   // ztachip control axi bus

   wire [31:0]        ZTA_CONTROL_araddr;
   wire [2:0]         ZTA_CONTROL_arprot;
   wire               ZTA_CONTROL_arready;
   wire               ZTA_CONTROL_arvalid;
   wire [31:0]        ZTA_CONTROL_awaddr;
   wire [2:0]         ZTA_CONTROL_awprot;
   wire               ZTA_CONTROL_awready;
   wire               ZTA_CONTROL_awvalid;
   wire               ZTA_CONTROL_bready;
   wire [1:0]         ZTA_CONTROL_bresp;
   wire               ZTA_CONTROL_bvalid;
   wire [31:0]        ZTA_CONTROL_rdata;
   wire               ZTA_CONTROL_rready;
   wire [1:0]         ZTA_CONTROL_rresp;
   wire               ZTA_CONTROL_rvalid;
   wire [31:0]        ZTA_CONTROL_wdata;
   wire               ZTA_CONTROL_wready;
   wire [3:0]         ZTA_CONTROL_wstrb;
   wire               ZTA_CONTROL_wvalid;
   
   // ztachip data axi bus
      
   wire [31:0]        ZTA_DATA_araddr;
   wire [1:0]         ZTA_DATA_arburst;
   wire [3:0]         ZTA_DATA_arcache;
   wire [0:0]         ZTA_DATA_arid;
   wire [7:0]         ZTA_DATA_arlen;
   wire [0:0]         ZTA_DATA_arlock;
   wire [2:0]         ZTA_DATA_arprot;
   wire [3:0]         ZTA_DATA_arqos;
   wire               ZTA_DATA_arready;
   wire [2:0]         ZTA_DATA_arsize;
   wire               ZTA_DATA_arvalid;
   wire [31:0]        ZTA_DATA_awaddr;
   wire [1:0]         ZTA_DATA_awburst;
   wire [3:0]         ZTA_DATA_awcache;
   wire [0:0]         ZTA_DATA_awid;
   wire [7:0]         ZTA_DATA_awlen;
   wire [0:0]         ZTA_DATA_awlock;
   wire [2:0]         ZTA_DATA_awprot;
   wire [3:0]         ZTA_DATA_awqos;
   wire               ZTA_DATA_awready;
   wire [2:0]         ZTA_DATA_awsize;
   wire               ZTA_DATA_awvalid;
   wire [0:0]         ZTA_DATA_bid;
   wire               ZTA_DATA_bready;
   wire [1:0]         ZTA_DATA_bresp;
   wire               ZTA_DATA_bvalid;
   wire [63:0]        ZTA_DATA_rdata;
   wire [0:0]         ZTA_DATA_rid;
   wire               ZTA_DATA_rlast;
   wire               ZTA_DATA_rready;
   wire [1:0]         ZTA_DATA_rresp;
   wire               ZTA_DATA_rvalid;
   wire [63:0]        ZTA_DATA_wdata;
   wire               ZTA_DATA_wlast;
   wire               ZTA_DATA_wready;
   wire [7:0]         ZTA_DATA_wstrb;
   wire               ZTA_DATA_wvalid;
    
   // APB AXI bus
   wire [8:0]         apb_0_paddr;
   wire               apb_0_penable;
   wire [31:0]        apb_0_prdata;
   wire [0:0]         apb_0_pready;
   wire [0:0]         apb_0_psel;
   wire [0:0]         apb_0_pslverr;
   wire [31:0]        apb_0_pwdata;
   wire               apb_0_pwrite; 

   // Camera AXI streaming bus signals
     
   wire [31:0]        camera_tdata;
   wire               camera_tlast;
   wire               camera_tready;
   wire [0:0]         camera_tuser;
   wire               camera_tvalid;

   // Video AXI streaming bus signals
   
   wire [31:0]        VIDEO_tdata;
   wire [3:0]         VIDEO_tkeep;  
   wire               VIDEO_tlast;
   wire               VIDEO_tready;
   wire [0:0]         VIDEO_tuser;
   wire               VIDEO_tvalid;
   
   assign UART_TXD=0;
   assign clk_resetn = !ui_clk_sync_rst;
   assign clk_reset = ui_clk_sync_rst;

   // ------------------
   // Clock synthesizer
   // -------------------
   
   clk_wiz_0 clk_wiz_inst(
       .clk_out1(clk_vga),
       .clk_out2(clk_mig_ref),
       .clk_out3(clk_mig_sysclk),
       .clk_out4(clk_camera),
       .clk_out5(clk_main),
       .resetn(sys_resetn),
       .locked(),
       .clk_in1(sys_clock));

   // -----------------------------
   // CPU. RISCV based on VexRiscv
   // ------------------------------
                
   Riscv cpu_inst (
       .io_asyncReset(clk_reset),
       .io_mainClk(clk_main),
       .io_iBus_ar_valid(ibus_arvalid),
       .io_iBus_ar_ready(ibus_arready),
       .io_iBus_ar_payload_addr(ibus_araddr),
       .io_iBus_ar_payload_id(ibus_arid),
       .io_iBus_ar_payload_region(),
       .io_iBus_ar_payload_len(ibus_arlen),
       .io_iBus_ar_payload_size(ibus_arsize),
       .io_iBus_ar_payload_burst(ibus_arburst),
       .io_iBus_ar_payload_lock(ibus_arlock),
       .io_iBus_ar_payload_cache(ibus_arcache),
       .io_iBus_ar_payload_qos(ibus_arqos),
       .io_iBus_ar_payload_prot(ibus_arprot),
       .io_iBus_r_valid(ibus_rvalid),
       .io_iBus_r_ready(ibus_rready),
       .io_iBus_r_payload_data(ibus_rdata),
       .io_iBus_r_payload_id(ibus_rid),
       .io_iBus_r_payload_resp(ibus_rresp),
       .io_iBus_r_payload_last(ibus_rlast), 
       .io_dBus_aw_valid(dbus_awvalid),
       .io_dBus_aw_ready(dbus_awready),
       .io_dBus_aw_payload_addr(dbus_awaddr),
       .io_dBus_aw_payload_id(dbus_awid),
       .io_dBus_aw_payload_region(),
       .io_dBus_aw_payload_len(dbus_awlen),
       .io_dBus_aw_payload_size(dbus_awsize),
       .io_dBus_aw_payload_burst(dbus_awburst),
       .io_dBus_aw_payload_lock(dbus_awlock),
       .io_dBus_aw_payload_cache(dbus_awcache),
       .io_dBus_aw_payload_qos(dbus_awqos),
       .io_dBus_aw_payload_prot(dbus_awprot),
       .io_dBus_w_valid(dbus_wvalid),
       .io_dBus_w_ready(dbus_wready),
       .io_dBus_w_payload_data(dbus_wdata),
       .io_dBus_w_payload_strb(dbus_wstrb),
       .io_dBus_w_payload_last(dbus_wlast),
       .io_dBus_b_valid(dbus_bvalid),
       .io_dBus_b_ready(dbus_bready),
       .io_dBus_b_payload_id(dbus_bid),
       .io_dBus_b_payload_resp(dbus_bresp),
       .io_dBus_ar_valid(dbus_arvalid),
       .io_dBus_ar_ready(dbus_arready),
       .io_dBus_ar_payload_addr(dbus_araddr),
       .io_dBus_ar_payload_id(dbus_arid),
       .io_dBus_ar_payload_region(),
       .io_dBus_ar_payload_len(dbus_arlen),
       .io_dBus_ar_payload_size(dbus_arsize),
       .io_dBus_ar_payload_burst(dbus_arburst),
       .io_dBus_ar_payload_lock(dbus_arlock),
       .io_dBus_ar_payload_cache(dbus_arcache),
       .io_dBus_ar_payload_qos(dbus_arqos),
       .io_dBus_ar_payload_prot(dbus_arprot),
       .io_dBus_r_valid(dbus_rvalid),
       .io_dBus_r_ready(dbus_rready),
       .io_dBus_r_payload_data(dbus_rdata),
       .io_dBus_r_payload_id(dbus_rid),
       .io_dBus_r_payload_resp(dbus_rresp),
       .io_dBus_r_payload_last(dbus_rlast)
   );

   //------------------------
   // AXI crossbar
   //------------------------
   
   crossbar crossbar_inst
       (.ARESETN(clk_resetn),
       .CLOCK(clk_main),
    
       .SDRAM_CLOCK(ui_clk),

       // Connection to GPIO block using AXI-APB (Advanced Peripheral Bus)
           
       .APB_0_paddr(apb_0_paddr),
       .APB_0_penable(apb_0_penable),
       .APB_0_prdata(apb_0_prdata),
       .APB_0_pready(apb_0_pready),
       .APB_0_psel(apb_0_psel),
       .APB_0_pslverr(apb_0_pslverr),
       .APB_0_pwdata(apb_0_pwdata),
       .APB_0_pwrite(apb_0_pwrite),

       // Connection to instruction bus of cpu block
               
       .IBUS_araddr(ibus_araddr),
       .IBUS_arburst(ibus_arburst),
       .IBUS_arcache(ibus_arcache),
       .IBUS_arlen(ibus_arlen),
       .IBUS_arlock(ibus_arlock),
       .IBUS_arprot(ibus_arprot),
       .IBUS_arqos(ibus_arqos),
       .IBUS_arready(ibus_arready),
       .IBUS_arsize(ibus_arsize),
       .IBUS_arvalid(ibus_arvalid),
       .IBUS_arid(ibus_arid),
       .IBUS_rdata(ibus_rdata),
       .IBUS_rlast(ibus_rlast),
       .IBUS_rready(ibus_rready),
       .IBUS_rresp(ibus_rresp),
       .IBUS_rvalid(ibus_rvalid),
       .IBUS_rid(ibus_rid),

       // Connection to databus of CPU block
         
       .DBUS_araddr(dbus_araddr),
       .DBUS_arburst(dbus_arburst),
       .DBUS_arcache(dbus_arcache),
       .DBUS_arlen(dbus_arlen),
       .DBUS_arlock(dbus_arlock),
       .DBUS_arprot(dbus_arprot),
       .DBUS_arqos(dbus_arqos),
       .DBUS_arready(dbus_arready),
       .DBUS_arsize(dbus_arsize),
       .DBUS_arvalid(dbus_arvalid),
       .DBUS_arid(dbus_arid),
       .DBUS_awaddr(dbus_awaddr),
       .DBUS_awburst(dbus_awburst),
       .DBUS_awcache(dbus_awcache),
       .DBUS_awlen(dbus_awlen),
       .DBUS_awlock(dbus_awlock),
       .DBUS_awprot(dbus_awprot),
       .DBUS_awqos(dbus_awqos),
       .DBUS_awready(dbus_awready),
       .DBUS_awsize(dbus_awsize),
       .DBUS_awvalid(dbus_awvalid),
       .DBUS_awid(dbus_awid),
       .DBUS_bready(dbus_bready),
       .DBUS_bresp(dbus_bresp),
       .DBUS_bvalid(dbus_bvalid),
       .DBUS_rdata(dbus_rdata),
       .DBUS_rlast(dbus_rlast),
       .DBUS_rready(dbus_rready),
       .DBUS_rresp(dbus_rresp),
       .DBUS_rvalid(dbus_rvalid),
       .DBUS_rid(dbus_rid),
       .DBUS_wdata(dbus_wdata),
       .DBUS_wlast(dbus_wlast),
       .DBUS_wready(dbus_wready),
       .DBUS_wstrb(dbus_wstrb),
       .DBUS_wvalid(dbus_wvalid),
       .DBUS_bid(dbus_bid),
    
       // Connection to DDR memory controller
       
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
    
       // Connection to VGA block
       
       .VIDEO_CLOCK(clk_vga),
       .VIDEO_OUT_tdata(VIDEO_tdata),
       .VIDEO_OUT_tkeep(VIDEO_tkeep),
       .VIDEO_OUT_tlast(VIDEO_tlast),
       .VIDEO_OUT_tready(VIDEO_tready),
       .VIDEO_OUT_tuser(VIDEO_tuser),
       .VIDEO_OUT_tvalid(VIDEO_tvalid),  
    
       // Connection to camera block
  
       .CAMERA_CLOCK_IN(CAMERA_PCLK),
       .CAMERA_IN_tdata(camera_tdata),
       .CAMERA_IN_tkeep(1),
       .CAMERA_IN_tlast(camera_tlast),
       .CAMERA_IN_tready(camera_tready),
       .CAMERA_IN_tuser(camera_tuser),
       .CAMERA_IN_tvalid(camera_tvalid),

       // Connection to ztachip control interface
       
       .ZTA_CONTROL_araddr(ZTA_CONTROL_araddr),
       .ZTA_CONTROL_arburst(),
       .ZTA_CONTROL_arcache(),
       .ZTA_CONTROL_arlen(),
       .ZTA_CONTROL_arlock(),
       .ZTA_CONTROL_arqos(),
       .ZTA_CONTROL_arsize(),
       .ZTA_CONTROL_arprot(ZTA_CONTROL_arprot),
       .ZTA_CONTROL_arready(ZTA_CONTROL_arready),
       .ZTA_CONTROL_arvalid(ZTA_CONTROL_arvalid),
       .ZTA_CONTROL_awaddr(ZTA_CONTROL_awaddr),
       .ZTA_CONTROL_awburst(),
       .ZTA_CONTROL_awcache(),
       .ZTA_CONTROL_awlen(),
       .ZTA_CONTROL_awlock(),
       .ZTA_CONTROL_awqos(),
       .ZTA_CONTROL_awprot(ZTA_CONTROL_awprot),
       .ZTA_CONTROL_awready(ZTA_CONTROL_awready),
       .ZTA_CONTROL_awvalid(ZTA_CONTROL_awvalid),
       .ZTA_CONTROL_bready(ZTA_CONTROL_bready),
       .ZTA_CONTROL_bresp(ZTA_CONTROL_bresp),
       .ZTA_CONTROL_bvalid(ZTA_CONTROL_bvalid),
       .ZTA_CONTROL_rdata(ZTA_CONTROL_rdata),
       .ZTA_CONTROL_rready(ZTA_CONTROL_rready),
       .ZTA_CONTROL_rresp(ZTA_CONTROL_rresp),
       .ZTA_CONTROL_rvalid(ZTA_CONTROL_rvalid),
       .ZTA_CONTROL_rlast(ZTA_CONTROL_rvalid),
       .ZTA_CONTROL_wdata(ZTA_CONTROL_wdata),
       .ZTA_CONTROL_wready(ZTA_CONTROL_wready),
       .ZTA_CONTROL_wstrb(ZTA_CONTROL_wstrb),
       .ZTA_CONTROL_wvalid(ZTA_CONTROL_wvalid),
    
       // Connection to ztachip data interface
       
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
       .ZTA_DATA_wvalid(ZTA_DATA_wvalid)
   );
    
   //---------------------------
   // DDR Memory controller
   //---------------------------
     
   mig_7series_0 mig_inst(
       .ddr3_dq(ddr3_sdram_dq),
       .ddr3_dqs_n(ddr3_sdram_dqs_n),
       .ddr3_dqs_p(ddr3_sdram_dqs_p),
       .ddr3_addr(ddr3_sdram_addr),
       .ddr3_ba(ddr3_sdram_ba),
       .ddr3_ras_n(ddr3_sdram_ras_n),
       .ddr3_cas_n(ddr3_sdram_cas_n),
       .ddr3_we_n(ddr3_sdram_we_n),
       .ddr3_reset_n(ddr3_sdram_reset_n),
       .ddr3_ck_p(ddr3_sdram_ck_p),
       .ddr3_ck_n(ddr3_sdram_ck_n),
       .ddr3_cke(ddr3_sdram_cke),
       .ddr3_cs_n(ddr3_sdram_cs_n),
       .ddr3_dm(ddr3_sdram_dm),
       .ddr3_odt(ddr3_sdram_odt),
       .sys_clk_i(clk_mig_sysclk),
       .clk_ref_i(clk_mig_ref),
       .ui_clk(ui_clk),
       .ui_clk_sync_rst(ui_clk_sync_rst),
       .mmcm_locked(),
       .aresetn(1),
       .app_sr_req(0),
       .app_ref_req(0),
       .app_zq_req(0),
       .app_sr_active(),
       .app_ref_ack(),
       .app_zq_ack(),
       // Slave Interface Write Address Ports
       .s_axi_awid(0),
       .s_axi_awaddr(SDRAM_awaddr),
       .s_axi_awlen(SDRAM_awlen),
       .s_axi_awsize(SDRAM_awsize),
       .s_axi_awburst(SDRAM_awburst),
       .s_axi_awlock(SDRAM_awlock),
       .s_axi_awcache(SDRAM_awcache),
       .s_axi_awprot(SDRAM_awprot),
       .s_axi_awqos(SDRAM_awqos),
       .s_axi_awvalid(SDRAM_awvalid),
       .s_axi_awready(SDRAM_awready),
       // Slave Interface Write Data Ports
       .s_axi_wdata(SDRAM_wdata),
       .s_axi_wstrb(SDRAM_wstrb),
       .s_axi_wlast(SDRAM_wlast),
       .s_axi_wvalid(SDRAM_wvalid),
       .s_axi_wready(SDRAM_wready),
       // Slave Interface Write Response Ports
       .s_axi_bready(SDRAM_bready),
       .s_axi_bid(SDRAM_bid),
       .s_axi_bresp(SDRAM_bresp),
       .s_axi_bvalid(SDRAM_bvalid),
       // Slave Interface Read Address Ports
       .s_axi_arid(0),
       .s_axi_araddr(SDRAM_araddr),
       .s_axi_arlen(SDRAM_arlen),
       .s_axi_arsize(SDRAM_arsize),
       .s_axi_arburst(SDRAM_arburst),
       .s_axi_arlock(SDRAM_arlock),
       .s_axi_arcache(SDRAM_arcache),
       .s_axi_arprot(SDRAM_arprot),
       .s_axi_arqos(SDRAM_arqos),
       .s_axi_arvalid(SDRAM_arvalid),
       .s_axi_arready(SDRAM_arready),
       // Slave Interface Read Data Ports
       .s_axi_rready(SDRAM_rready),
       .s_axi_rid(SDRAM_rid),
       .s_axi_rdata(SDRAM_rdata),
       .s_axi_rresp(SDRAM_rresp),
       .s_axi_rlast(SDRAM_rlast),
       .s_axi_rvalid(SDRAM_rvalid),			  
       .sys_rst(sys_resetn)
   );

   //-----------------------
   // ztachip
   //-----------------------
   
   ztachip ztachip_inst( 
       .clock_in(clk_main),
       .reset_in(1),
       .axi_araddr_out(ZTA_DATA_araddr),
       .axi_arlen_out(ZTA_DATA_arlen),
       .axi_arvalid_out(ZTA_DATA_arvalid),
       .axi_rvalid_in(ZTA_DATA_rvalid),
       .axi_rlast_in(ZTA_DATA_rlast),
       .axi_rdata_in(ZTA_DATA_rdata),
       .axi_arready_in(ZTA_DATA_arready),
       .axi_rready_out(ZTA_DATA_rready),    
       .axi_arburst_out(ZTA_DATA_arburst),
       .axi_arcache_out(ZTA_DATA_arcache),
       .axi_arid_out(ZTA_DATA_arid),
       .axi_arlock_out(ZTA_DATA_arlock),
       .axi_arprot_out(ZTA_DATA_arprot),
       .axi_arqos_out(ZTA_DATA_arqos),
       .axi_arsize_out(ZTA_DATA_arsize),
            
       .axi_awaddr_out(ZTA_DATA_awaddr),
       .axi_awlen_out(ZTA_DATA_awlen),
       .axi_awvalid_out(ZTA_DATA_awvalid),
       .axi_waddr_out(),
       .axi_wvalid_out(ZTA_DATA_wvalid),
       .axi_wlast_out(ZTA_DATA_wlast),
       .axi_wdata_out(ZTA_DATA_wdata),
       .axi_wbe_out(ZTA_DATA_wstrb),
       .axi_awready_in(ZTA_DATA_awready),
       .axi_wready_in(ZTA_DATA_wready),
       .axi_bresp_in(ZTA_DATA_bvalid),       
       .axi_awburst_out(ZTA_DATA_awburst),
       .axi_awcache_out(ZTA_DATA_awcache),
       .axi_awid_out(ZTA_DATA_awid),
       .axi_awlock_out(ZTA_DATA_awlock),
       .axi_awprot_out(ZTA_DATA_awprot),
       .axi_awqos_out(ZTA_DATA_awqos),
       .axi_awsize_out(ZTA_DATA_awsize),
       .axi_bready_out(ZTA_DATA_bready),

       .axilite_araddr_in(ZTA_CONTROL_araddr),
       .axilite_arvalid_in(ZTA_CONTROL_arvalid),
       .axilite_arready_out(ZTA_CONTROL_arready),
       .axilite_rvalid_out(ZTA_CONTROL_rvalid),
       .axilite_rlast_out(),
       .axilite_rdata_out(ZTA_CONTROL_rdata),
       .axilite_rready_in(ZTA_CONTROL_rready),
       .axilite_rresp_out(ZTA_CONTROL_rresp),
       .axilite_awaddr_in(ZTA_CONTROL_awaddr),
       .axilite_awvalid_in(ZTA_CONTROL_awvalid),
       .axilite_wvalid_in(ZTA_CONTROL_wvalid),
       .axilite_wdata_in(ZTA_CONTROL_wdata),
       .axilite_awready_out(ZTA_CONTROL_awready),
       .axilite_wready_out(ZTA_CONTROL_wready),
       .axilite_bvalid_out(ZTA_CONTROL_bvalid),
       .axilite_bready_in(ZTA_CONTROL_bready),
       .axilite_bresp_out(ZTA_CONTROL_bresp)
   );

   //------------------------
   // Camera
   //------------------------
   
   camera camera_inst(
       .clk_in(clk_camera),
       .SIOC(CAMERA_SCL),
       .SIOD(CAMERA_SDR),
       .RESET(CAMERA_RESET),
       .PWDN(CAMERA_PWDN),
       .XCLK(CAMERA_MCLK),  
       .CAMERA_PCLK(CAMERA_PCLK),
       .CAMERA_D(CAMERA_D),
       .CAMERA_VS(CAMERA_VS),
       .CAMERA_RS(CAMERA_RS),
 
       .tdata_out(camera_tdata),
       .tlast_out(camera_tlast),
       .tready_in(camera_tready),
       .tuser_out(camera_tuser),
       .tvalid_out(camera_tvalid)
   );
   
   //-----------
   // VGA
   //-----------
   
   vga vga_inst(
       .clk_in(clk_vga),
       .tdata_in(VIDEO_tdata),
       .tready_out(VIDEO_tready),
       .tvalid_in(VIDEO_tvalid),

       .VGA_HS_O(VGA_HS_O),
       .VGA_VS_O(VGA_VS_O),
       .VGA_R(VGA_R),
       .VGA_B(VGA_B),
       .VGA_G(VGA_G)
   );

   //-------------
   // GPIO
   //-------------
                 
   gpio gpio_inst(
       .clk_in(clk_main),
       .paddr_in(apb_0_paddr),
       .penable_in(apb_0_penable),
       .prdata_out(apb_0_prdata),
       .pready_out(apb_0_pready),
       .psel_in(apb_0_psel),
       .pslverr_out(apb_0_pslverr),
       .pwdata_in(apb_0_pwdata),
       .pwrite_in(apb_0_pwrite),

       .led_out(led),
       .button_in(pushbutton)
   );

endmodule
