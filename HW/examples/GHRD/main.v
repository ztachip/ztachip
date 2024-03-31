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
//  +-----------+
//  +           + AXI-MM     +--------------+
//  +           +----------->+  DDR         +--> DDR3 Bus
//  +           +            +  Controller  +
//  +           +            +--------------+
//  +           +
//  + soc_base  + AXI-Stream +--------------+
//  +           +------------+     VGA      +--> VGA signals
//  +           +            +--------------+
//  +           +
//  +           + AXI-Stream +--------------+
//  +           +------------+    Camera    +--> OV7670 I2C/Signals               
//  +           +            +--------------+
//  +-----------+
//

//--------------------------------------------------------------------------
//                  TOP COMPONENT DECLARATION
//                  SIGNAL/PIN ASSIGNMENTS
//--------------------------------------------------------------------------
                              
module main(

   // External memory data bus is 64-bit wide
   // This should match with exmem_data_width_c defined in HW/src/config.vhd
   `define EXMEM_DATA_WIDTH 64

   // External memory data bus is 32-bit wide
   // This should match with exmem_data_width_c defined in HW/src/config.vhd
   //`define EXMEM_DATA_WIDTH 32

   // RISCV is booted using Xilinx built-in JTAG
   `define RISCV_MODE "RISCV_XILINX_BSCAN2_JTAG" 

   // RISCV is booted using an external JTAG adapter
   // `define RISCV_MODE "RISCV_JTAG" 

   // RISCV is running in simulation mode.
   // `define RISCV_MODE "RISCV_SIM" 
     
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
   
   wire               SDRAM_clk;
   wire [31:0]        SDRAM_araddr;
   wire [1:0]         SDRAM_arburst;
   wire [7:0]         SDRAM_arlen;
   wire               SDRAM_arready;
   wire [2:0]         SDRAM_arsize;
   wire               SDRAM_arvalid;
   wire [31:0]        SDRAM_awaddr;
   wire [1:0]         SDRAM_awburst;
   wire [7:0]         SDRAM_awlen;
   wire               SDRAM_awready;
   wire [2:0]         SDRAM_awsize;
   wire               SDRAM_awvalid;
   wire               SDRAM_bready;
   wire [1:0]         SDRAM_bresp;
   wire               SDRAM_bvalid;
   wire               SDRAM_rlast;
   wire               SDRAM_rready;
   wire [1:0]         SDRAM_rresp;
   wire               SDRAM_rvalid;
   wire               SDRAM_wlast;
   wire               SDRAM_wready;
   wire               SDRAM_wvalid;

   wire [`EXMEM_DATA_WIDTH-1:0] SDRAM_rdata;
   wire [`EXMEM_DATA_WIDTH-1:0] SDRAM_wdata;
   wire [`EXMEM_DATA_WIDTH/8-1:0] SDRAM_wstrb;
      
   wire [31:0]        VIDEO_tdata;
   wire               VIDEO_tlast;
   wire               VIDEO_tready;
   wire               VIDEO_tvalid;

   wire [31:0]        camera_tdata;
   wire               camera_tlast;
   wire               camera_tready;
   wire [0:0]         camera_tuser;
   wire               camera_tvalid;

   wire [19:0]        APB_PADDR;
   wire               APB_PENABLE;
   wire               APB_PREADY;
   wire               APB_PWRITE;
   wire [31:0]        APB_PWDATA;
   wire [31:0]        APB_PRDATA;
   wire               APB_PSLVERROR;

   soc_base #(.RISCV(`RISCV_MODE)) soc_base_inst (

      .clk_main(clk_main),
      .clk_x2_main(clk_x2_main),
      .clk_reset(1), // Dont need reset for FPGA design. Register already initialized after programming.

      // With this example, JTAG is using Xilinx built-in JTAG. So no external 
      // JTAG adapter is required
      // To boot with an external JTAG, TMS/TMO/TDO/TCLK need to be routed
      // to GPIO pins that in turn connect to an external JTAG adapter
      // To enable booting using external JTAG, set RISCV_MODE="RISCV_JTAG" above

      .TMS(0),
      .TDI(0),
      .TDO(),
      .TCK(0),

      .VIDEO_clk(clk_vga),  
      .VIDEO_tdata(VIDEO_tdata),
      .VIDEO_tready(VIDEO_tready),
      .VIDEO_tvalid(VIDEO_tvalid),
      .VIDEO_tlast(VIDEO_tlast),

      .camera_clk(CAMERA_PCLK),
      .camera_tdata(camera_tdata),
      .camera_tlast(camera_tlast),
      .camera_tready(camera_tready),
      .camera_tvalid(camera_tvalid),

      .SDRAM_clk(SDRAM_clk),
      .SDRAM_reset(1), // Dont need reset for FPGA design. Register already intialized after programming. 
      .SDRAM_araddr(SDRAM_araddr),
      .SDRAM_arburst(SDRAM_arburst),
      .SDRAM_arlen(SDRAM_arlen),
      .SDRAM_arready(SDRAM_arready),
      .SDRAM_arsize(SDRAM_arsize),
      .SDRAM_arvalid(SDRAM_arvalid),
      .SDRAM_awaddr(SDRAM_awaddr),
      .SDRAM_awburst(SDRAM_awburst),
      .SDRAM_awlen(SDRAM_awlen),
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

      .APB_PADDR(APB_PADDR),
      .APB_PENABLE(APB_PENABLE),
      .APB_PREADY(APB_PREADY),
      .APB_PWRITE(APB_PWRITE),
      .APB_PWDATA(APB_PWDATA),
      .APB_PRDATA(APB_PRDATA),
      .APB_PSLVERROR(APB_PSLVERROR)
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
      .ui_clk(SDRAM_clk),
      .ui_clk_sync_rst(),
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
      .s_axi_awlock(0),
      .s_axi_awcache(0),
      .s_axi_awprot(0),
      .s_axi_awqos(0),
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
      .s_axi_bid(),
      .s_axi_bresp(SDRAM_bresp),
      .s_axi_bvalid(SDRAM_bvalid),
      // Slave Interface Read Address Ports
      .s_axi_arid(0),
      .s_axi_araddr(SDRAM_araddr),
      .s_axi_arlen(SDRAM_arlen),
      .s_axi_arsize(SDRAM_arsize),
      .s_axi_arburst(SDRAM_arburst),
      .s_axi_arlock(0),
      .s_axi_arcache(0),
      .s_axi_arprot(0),
      .s_axi_arqos(0),
      .s_axi_arvalid(SDRAM_arvalid),
      .s_axi_arready(SDRAM_arready),
      // Slave Interface Read Data Ports
      .s_axi_rready(SDRAM_rready),
      .s_axi_rid(),
      .s_axi_rdata(SDRAM_rdata),
      .s_axi_rresp(SDRAM_rresp),
      .s_axi_rlast(SDRAM_rlast),
      .s_axi_rvalid(SDRAM_rvalid),			  
      .sys_rst(sys_resetn)
   );

   // GPIO
                 
   gpio gpio_inst(
         .clock_in(clk_main),
         .reset_in(1),
         .apb_paddr(APB_PADDR),
         .apb_penable(APB_PENABLE),
         .apb_pready(APB_PREADY),
         .apb_pwrite(APB_PWRITE),
         .apb_pwdata(APB_PWDATA),
         .apb_prdata(APB_PRDATA),
         .apb_pslverror(APB_PSLVERROR),
         .led_out(led),
         .button_in(pushbutton)
      );

   UART #(.BAUD_RATE(115200)) UART_inst(
		   .clock_in(clk_main),
		   .reset_in(1),
		   .uart_rx_in(UART_RXD),
		   .uart_tx_out(UART_TXD),
         .apb_paddr(APB_PADDR),
         .apb_penable(APB_PENABLE),
         .apb_pready(APB_PREADY),
         .apb_pwrite(APB_PWRITE),
         .apb_pwdata(APB_PWDATA),
         .apb_prdata(APB_PRDATA),
         .apb_pslverror(APB_PSLVERROR)
	   );

   TIME TIME_inst(
		   .clock_in(clk_main),
		   .reset_in(1),
         .apb_paddr(APB_PADDR),
         .apb_penable(APB_PENABLE),
         .apb_pready(APB_PREADY),
         .apb_pwrite(APB_PWRITE),
         .apb_pwdata(APB_PWDATA),
         .apb_prdata(APB_PRDATA),
         .apb_pslverror(APB_PSLVERROR)
	   );

   //-----------
   // VGA
   //-----------
   
   vga vga_inst(
      .clk_in(clk_vga),
      .tdata_in(VIDEO_tdata),
      .tready_out(VIDEO_tready),
      .tvalid_in(VIDEO_tvalid),
      .tlast_in(VIDEO_tlast),
      .VGA_HS_O_out(VGA_HS_O),
      .VGA_VS_O_out(VGA_VS_O),
      .VGA_R_out(VGA_R),
      .VGA_B_out(VGA_B),
      .VGA_G_out(VGA_G)
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
      .tuser_out(),
      .tvalid_out(camera_tvalid)
   );

   // ------------------
   // Clock synthesizer
   // -------------------

   clk_wiz_0 clk_wiz_inst(
      .clk_out1(clk_vga),
      .clk_out2(clk_mig_ref),
      .clk_out3(clk_mig_sysclk),
      .clk_out4(clk_camera),
      .clk_out5(clk_main),
      .clk_out6(clk_x2_main),
      .resetn(sys_resetn),
      .locked(),
      .clk_in1(sys_clock));

endmodule
