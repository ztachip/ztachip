---------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Author: Vuong Nguyen
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except IN compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to IN writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------
--
-- This is the reference design to show how to build a SOC with ztachip as 
-- accelerator for vision/AI workload
--
--  +-----------+
--  +           + AXI-MM     +--------------+
--  +           +----------->+  DDR         +--> DDR3 Bus
--  +           +            +  Controller  +
--  +           +            +--------------+
--  +           +
--  + soc_base  + AXI-Stream +--------------+
--  +           +------------+     VGA      +--> VGA signals
--  +           +            +--------------+
--  +           +
--  +           + AXI-Stream +--------------+
--  +           +------------+    Camera    +--> OV7670 I2C/Signals               
--  +           +            +--------------+
--  +-----------+
--

----------------------------------------------------------------------------
--                  TOP COMPONENT DECLARATION
--                  SIGNAL/PIN ASSIGNMENTS
----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.ztachip_pkg.all;
use work.config.all;

ENTITY main IS 
   PORT(
   SIGNAL sys_resetn          :IN STD_LOGIC;
   SIGNAL sys_clock           :IN STD_LOGIC;
   
   --  DDR signals 
   
   SIGNAL ddr3_sdram_addr     :OUT STD_LOGIC_VECTOR(13 downto 0);
   SIGNAL ddr3_sdram_ba       :OUT STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ddr3_sdram_cas_n    :OUT STD_LOGIC;
   SIGNAL ddr3_sdram_ck_n     :OUT STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ddr3_sdram_ck_p     :OUT STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ddr3_sdram_cke      :OUT STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ddr3_sdram_cs_n     :OUT STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ddr3_sdram_dm       :OUT STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ddr3_sdram_dq       :INOUT STD_LOGIC_VECTOR(15 downto 0);
   SIGNAL ddr3_sdram_dqs_n    :INOUT STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ddr3_sdram_dqs_p    :INOUT STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ddr3_sdram_odt      :OUT STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ddr3_sdram_ras_n    :OUT STD_LOGIC;
   SIGNAL ddr3_sdram_reset_n  :OUT STD_LOGIC;
   SIGNAL ddr3_sdram_we_n     :OUT STD_LOGIC;
   
   -- UART signals
   
   SIGNAL UART_TXD            :OUT STD_LOGIC;
   SIGNAL UART_RXD            :IN STD_LOGIC;
   
   -- GPIO signals
   
   SIGNAL led                 :OUT STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL pushbutton          :IN STD_LOGIC_VECTOR(3 downto 0);
   
   -- VGA signals
   
   SIGNAL VGA_HS_O            :OUT STD_LOGIC;
   SIGNAL VGA_VS_O            :OUT STD_LOGIC;
   SIGNAL VGA_R               :OUT STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL VGA_B               :OUT STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL VGA_G               :OUT STD_LOGIC_VECTOR(3 downto 0);
   
   -- CAMERA signals

   SIGNAL CAMERA_SCL          :OUT STD_LOGIC;
   SIGNAL CAMERA_VS           :IN STD_LOGIC;
   SIGNAL CAMERA_PCLK         :IN STD_LOGIC;
   SIGNAL CAMERA_D            :IN STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL CAMERA_RESET        :OUT STD_LOGIC;
   SIGNAL CAMERA_SDR          :INOUT STD_LOGIC;
   SIGNAL CAMERA_RS           :IN STD_LOGIC;
   SIGNAL CAMERA_MCLK         :OUT STD_LOGIC;
   SIGNAL CAMERA_PWDN         :OUT STD_LOGIC
   );
END main;
   
ARCHITECTURE behavior OF main IS

   COMPONENT mig_7series_0 is
      PORT(
      signal ddr3_dq:INOUT STD_LOGIC_VECTOR(15 downto 0);
      signal ddr3_dqs_n:INOUT STD_LOGIC_VECTOR(1 downto 0);
      signal ddr3_dqs_p:INOUT STD_LOGIC_VECTOR(1 downto 0);
      signal ddr3_addr:OUT STD_LOGIC_VECTOR(13 downto 0);
      signal ddr3_ba:OUT STD_LOGIC_VECTOR(2 downto 0);
      signal ddr3_ras_n:OUT STD_LOGIC;
      signal ddr3_cas_n:OUT STD_LOGIC;
      signal ddr3_we_n:OUT STD_LOGIC;
      signal ddr3_reset_n:OUT STD_LOGIC;
      signal ddr3_ck_p:OUT STD_LOGIC_VECTOR(0 downto 0);
      signal ddr3_ck_n:OUT STD_LOGIC_VECTOR(0 downto 0);
      signal ddr3_cke:OUT STD_LOGIC_VECTOR(0 downto 0);
      signal ddr3_cs_n:OUT STD_LOGIC_VECTOR(0 downto 0);
      signal ddr3_dm:OUT STD_LOGIC_VECTOR(1 downto 0);
      signal ddr3_odt:OUT STD_LOGIC_VECTOR(0 downto 0);
      signal sys_clk_i:IN STD_LOGIC;
      signal clk_ref_i:IN STD_LOGIC;
      signal ui_clk:OUT STD_LOGIC;
      signal ui_clk_sync_rst:OUT STD_LOGIC;
      signal mmcm_locked:OUT STD_LOGIC;
      signal aresetn:IN STD_LOGIC;
      signal app_sr_req:IN STD_LOGIC;
      signal app_ref_req:IN STD_LOGIC;
      signal app_zq_req:IN STD_LOGIC;
      signal app_sr_active:OUT STD_LOGIC;
      signal app_ref_ack:OUT STD_LOGIC;
      signal app_zq_ack:OUT STD_LOGIC;
      signal s_axi_awid:IN STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_awaddr:IN STD_LOGIC_VECTOR(27 downto 0);
      signal s_axi_awlen:IN STD_LOGIC_VECTOR(7 downto 0);
      signal s_axi_awsize:IN STD_LOGIC_VECTOR(2 downto 0);
      signal s_axi_awburst:IN STD_LOGIC_VECTOR(1 downto 0);
      signal s_axi_awlock:IN STD_LOGIC_VECTOR(0 downto 0);
      signal s_axi_awcache:IN STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_awprot:IN STD_LOGIC_VECTOR(2 downto 0);
      signal s_axi_awqos:IN STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_awvalid:IN STD_LOGIC;
      signal s_axi_awready:OUT STD_LOGIC;
      signal s_axi_wdata:IN STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
      signal s_axi_wstrb:IN STD_LOGIC_VECTOR(exmem_data_width_c/8-1 downto 0);
      signal s_axi_wlast:IN STD_LOGIC;
      signal s_axi_wvalid:IN STD_LOGIC;
      signal s_axi_wready:OUT STD_LOGIC;
      signal s_axi_bready:IN STD_LOGIC;
      signal s_axi_bid:OUT STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_bresp:OUT STD_LOGIC_VECTOR(1 downto 0);
      signal s_axi_bvalid:OUT STD_LOGIC;
      signal s_axi_arid:IN STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_araddr:IN STD_LOGIC_VECTOR(27 downto 0);
      signal s_axi_arlen:IN STD_LOGIC_VECTOR(7 downto 0);
      signal s_axi_arsize:IN STD_LOGIC_VECTOR(2 downto 0);
      signal s_axi_arburst:IN STD_LOGIC_VECTOR(1 downto 0);
      signal s_axi_arlock:IN STD_LOGIC_VECTOR(0 downto 0);
      signal s_axi_arcache:IN STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_arprot:IN STD_LOGIC_VECTOR(2 downto 0);
      signal s_axi_arqos:IN STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_arvalid:IN STD_LOGIC;
      signal s_axi_arready:OUT STD_LOGIC;
      signal s_axi_rready:IN STD_LOGIC;
      signal s_axi_rid:OUT STD_LOGIC_VECTOR(3 downto 0);
      signal s_axi_rdata:OUT STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
      signal s_axi_rresp:OUT STD_LOGIC_VECTOR(1 downto 0);
      signal s_axi_rlast:OUT STD_LOGIC;
      signal s_axi_rvalid:OUT STD_LOGIC;
      signal init_calib_complete:OUT STD_LOGIC;
      signal device_temp:OUT STD_LOGIC_VECTOR(11 downto 0);
      signal sys_rst:IN STD_LOGIC
      );
   END COMPONENT;

   COMPONENT clk_wiz_0 IS
      PORT(
      signal clk_out1:OUT STD_LOGIC;
      signal clk_out2:OUT STD_LOGIC;
      signal clk_out3:OUT STD_LOGIC;
      signal clk_out4:OUT STD_LOGIC;
      signal clk_out5:OUT STD_LOGIC;
      signal clk_out6:OUT STD_LOGIC;
      signal resetn:IN STD_LOGIC;
      signal locked:OUT STD_LOGIC;
      signal clk_in1:IN STD_LOGIC
      );
   END COMPONENT;

   -- RISCV is booted using Xilinx built-in JTAG
   constant RISCV_MODE:string:="RISCV_XILINX_BSCAN2_JTAG"; 

   -- RISCV is booted using an external JTAG adapter
   -- constant RISCV_MODE:string:="RISCV_JTAG"; 

   -- RISCV is running in simulation mode.
   -- constant RISCV_MODE:string:="RISCV_SIM"; 
     
   SIGNAL SDRAM_clk        :STD_LOGIC;
   SIGNAL SDRAM_araddr     :STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL SDRAM_arburst    :STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL SDRAM_arlen      :STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL SDRAM_arready    :STD_LOGIC;
   SIGNAL SDRAM_arsize     :STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL SDRAM_arvalid    :STD_LOGIC;
   SIGNAL SDRAM_awaddr     :STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL SDRAM_awburst    :STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL SDRAM_awlen      :STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL SDRAM_awready    :STD_LOGIC;
   SIGNAL SDRAM_awsize     :STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL SDRAM_awvalid    :STD_LOGIC;
   SIGNAL SDRAM_bready     :STD_LOGIC;
   SIGNAL SDRAM_bresp      :STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL SDRAM_bvalid     :STD_LOGIC;
   SIGNAL SDRAM_rlast      :STD_LOGIC;
   SIGNAL SDRAM_rready     :STD_LOGIC;
   SIGNAL SDRAM_rresp      :STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL SDRAM_rvalid     :STD_LOGIC;
   SIGNAL SDRAM_wlast      :STD_LOGIC;
   SIGNAL SDRAM_wready     :STD_LOGIC;
   SIGNAL SDRAM_wvalid     :STD_LOGIC;

   SIGNAL SDRAM_rdata      :STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
   SIGNAL SDRAM_wdata      :STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
   SIGNAL SDRAM_wstrb      :STD_LOGIC_VECTOR(exmem_data_width_c/8-1 downto 0);
      
   SIGNAL VIDEO_tdata      :STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL VIDEO_tlast      :STD_LOGIC;
   SIGNAL VIDEO_tready     :STD_LOGIC;
   SIGNAL VIDEO_tvalid     :STD_LOGIC;

   SIGNAL camera_tdata     :STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL camera_tlast     :STD_LOGIC;
   SIGNAL camera_tready    :STD_LOGIC;
   SIGNAL camera_tuser     :STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL camera_tvalid    :STD_LOGIC;

   SIGNAL APB_PADDR        :STD_LOGIC_VECTOR(19 downto 0);
   SIGNAL APB_PENABLE      :STD_LOGIC;
   SIGNAL APB_PREADY       :STD_LOGIC;
   SIGNAL APB_PWRITE       :STD_LOGIC;
   SIGNAL APB_PWDATA       :STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL APB_PRDATA       :STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL APB_PSLVERROR    :STD_LOGIC;
   SIGNAL clk_vga          :STD_LOGIC;
   SIGNAL clk_mig_ref      :STD_LOGIC;
   SIGNAL clk_mig_sysclk   :STD_LOGIC;
   SIGNAL clk_camera       :STD_LOGIC;
   SIGNAL clk_main         :STD_LOGIC;
   SIGNAL clk_x2_main      :STD_LOGIC;
BEGIN

soc_base_inst: soc_base
   generic map(
      RISCV=>RISCV_MODE
   )
   port map (
      clk_main=>clk_main,
      clk_x2_main=>clk_x2_main,
      clk_reset=>'1', -- Dont need reset for FPGA design. Register already initialized after programming.

      -- With this example, JTAG is using Xilinx built-in JTAG. So no external 
      -- JTAG adapter is required
      -- To boot with an external JTAG, TMS/TMO/TDO/TCLK need to be routed
      -- to GPIO pins that in turn connect to an external JTAG adapter
      -- To enable booting using external JTAG, set RISCV_MODE="RISCV_JTAG" above

      TMS=>'0',
      TDI=>'0',
      TDO=>open,
      TCK=>'0',

      VIDEO_clk=>clk_vga,  
      VIDEO_tdata=>VIDEO_tdata,
      VIDEO_tready=>VIDEO_tready,
      VIDEO_tvalid=>VIDEO_tvalid,
      VIDEO_tlast=>VIDEO_tlast,

      camera_clk=>CAMERA_PCLK,
      camera_tdata=>camera_tdata,
      camera_tlast=>camera_tlast,
      camera_tready=>camera_tready,
      camera_tvalid=>camera_tvalid,

      SDRAM_clk=>SDRAM_clk,
      SDRAM_reset=>'1', -- Dont need reset for FPGA design. Register already intialized after programming. 
      SDRAM_araddr=>SDRAM_araddr,
      SDRAM_arburst=>SDRAM_arburst,
      SDRAM_arlen=>SDRAM_arlen,
      SDRAM_arready=>SDRAM_arready,
      SDRAM_arsize=>SDRAM_arsize,
      SDRAM_arvalid=>SDRAM_arvalid,
      SDRAM_awaddr=>SDRAM_awaddr,
      SDRAM_awburst=>SDRAM_awburst,
      SDRAM_awlen=>SDRAM_awlen,
      SDRAM_awready=>SDRAM_awready,
      SDRAM_awsize=>SDRAM_awsize,
      SDRAM_awvalid=>SDRAM_awvalid,
      SDRAM_bready=>SDRAM_bready,
      SDRAM_bresp=>SDRAM_bresp,
      SDRAM_bvalid=>SDRAM_bvalid,
      SDRAM_rdata=>SDRAM_rdata,
      SDRAM_rlast=>SDRAM_rlast,
      SDRAM_rready=>SDRAM_rready,
      SDRAM_rresp=>SDRAM_rresp,
      SDRAM_rvalid=>SDRAM_rvalid,
      SDRAM_wdata=>SDRAM_wdata,
      SDRAM_wlast=>SDRAM_wlast,
      SDRAM_wready=>SDRAM_wready,
      SDRAM_wstrb=>SDRAM_wstrb,
      SDRAM_wvalid=>SDRAM_wvalid,

      APB_PADDR=>APB_PADDR,
      APB_PENABLE=>APB_PENABLE,
      APB_PREADY=>APB_PREADY,
      APB_PWRITE=>APB_PWRITE,
      APB_PWDATA=>APB_PWDATA,
      APB_PRDATA=>APB_PRDATA,
      APB_PSLVERROR=>APB_PSLVERROR
   );

---------------------------
-- DDR Memory controller
---------------------------
   
mig_inst:mig_7series_0
   port map(
   ddr3_dq=>ddr3_sdram_dq,
   ddr3_dqs_n=>ddr3_sdram_dqs_n,
   ddr3_dqs_p=>ddr3_sdram_dqs_p,
   ddr3_addr=>ddr3_sdram_addr,
   ddr3_ba=>ddr3_sdram_ba,
   ddr3_ras_n=>ddr3_sdram_ras_n,
   ddr3_cas_n=>ddr3_sdram_cas_n,
   ddr3_we_n=>ddr3_sdram_we_n,
   ddr3_reset_n=>ddr3_sdram_reset_n,
   ddr3_ck_p=>ddr3_sdram_ck_p,
   ddr3_ck_n=>ddr3_sdram_ck_n,
   ddr3_cke=>ddr3_sdram_cke,
   ddr3_cs_n=>ddr3_sdram_cs_n,
   ddr3_dm=>ddr3_sdram_dm,
   ddr3_odt=>ddr3_sdram_odt,
   sys_clk_i=>clk_mig_sysclk,
   clk_ref_i=>clk_mig_ref,
   ui_clk=>SDRAM_clk,
   ui_clk_sync_rst=>open,
   mmcm_locked=>open,
   aresetn=>'1',
   app_sr_req=>'0',
   app_ref_req=>'0',
   app_zq_req=>'0',
   app_sr_active=>open,
   app_ref_ack=>open,
   app_zq_ack=>open,
   -- Slave Interface Write Address Ports
   s_axi_awid=>(others=>'0'),
   s_axi_awaddr=>SDRAM_awaddr(27 downto 0),
   s_axi_awlen=>SDRAM_awlen,
   s_axi_awsize=>SDRAM_awsize,
   s_axi_awburst=>SDRAM_awburst,
   s_axi_awlock=>(others=>'0'),
   s_axi_awcache=>(others=>'0'),
   s_axi_awprot=>(others=>'0'),
   s_axi_awqos=>(others=>'0'),
   s_axi_awvalid=>SDRAM_awvalid,
   s_axi_awready=>SDRAM_awready,
   -- Slave Interface Write Data Ports
   s_axi_wdata=>SDRAM_wdata,
   s_axi_wstrb=>SDRAM_wstrb,
   s_axi_wlast=>SDRAM_wlast,
   s_axi_wvalid=>SDRAM_wvalid,
   s_axi_wready=>SDRAM_wready,
   -- Slave Interface Write Response Ports
   s_axi_bready=>SDRAM_bready,
   s_axi_bid=>open,
   s_axi_bresp=>SDRAM_bresp,
   s_axi_bvalid=>SDRAM_bvalid,
   -- Slave Interface Read Address Ports
   s_axi_arid=>(others=>'0'),
   s_axi_araddr=>SDRAM_araddr(27 downto 0),
   s_axi_arlen=>SDRAM_arlen,
   s_axi_arsize=>SDRAM_arsize,
   s_axi_arburst=>SDRAM_arburst,
   s_axi_arlock=>(others=>'0'),
   s_axi_arcache=>(others=>'0'),
   s_axi_arprot=>(others=>'0'),
   s_axi_arqos=>(others=>'0'),
   s_axi_arvalid=>SDRAM_arvalid,
   s_axi_arready=>SDRAM_arready,
   -- Slave Interface Read Data Ports
   s_axi_rready=>SDRAM_rready,
   s_axi_rid=>open,
   s_axi_rdata=>SDRAM_rdata,
   s_axi_rresp=>SDRAM_rresp,
   s_axi_rlast=>SDRAM_rlast,
   s_axi_rvalid=>SDRAM_rvalid,			  
   sys_rst=>sys_resetn
   );

-- GPIO
                 
gpio_inst:gpio
   port map(
      clock_in=>clk_main,
      reset_in=>'1',
      apb_paddr=>APB_PADDR,
      apb_penable=>APB_PENABLE,
      apb_pready=>APB_PREADY,
      apb_pwrite=>APB_PWRITE,
      apb_pwdata=>APB_PWDATA,
      apb_prdata=>APB_PRDATA,
      apb_pslverror=>APB_PSLVERROR,
      led_out=>led,
      button_in=>pushbutton
   );

UART_INST:UART 
   generic map(
      BAUD_RATE=>115200
      )
   port map(
      clock_in=>clk_main,
      reset_in=>'1',
      uart_rx_in=>UART_RXD,
      uart_tx_out=>UART_TXD,
      apb_paddr=>APB_PADDR,
      apb_penable=>APB_PENABLE,
      apb_pready=>APB_PREADY,
      apb_pwrite=>APB_PWRITE,
      apb_pwdata=>APB_PWDATA,
      apb_prdata=>APB_PRDATA,
      apb_pslverror=>APB_PSLVERROR
   );

TIME_inst : TIMER
   port map(
      clock_in=>clk_main,
      reset_in=>'1',
      apb_paddr=>APB_PADDR,
      apb_penable=>APB_PENABLE,
      apb_pready=>APB_PREADY,
      apb_pwrite=>APB_PWRITE,
      apb_pwdata=>APB_PWDATA,
      apb_prdata=>APB_PRDATA,
      apb_pslverror=>APB_PSLVERROR
   );

-----------
-- VGA
-----------

vga_inst: vga
   port map(
      clk_in=>clk_vga,
      tdata_in=>VIDEO_tdata,
      tready_out=>VIDEO_tready,
      tvalid_in=>VIDEO_tvalid,
      tlast_in=>VIDEO_tlast,
      VGA_HS_O_out=>VGA_HS_O,
      VGA_VS_O_out=>VGA_VS_O,
      VGA_R_out=>VGA_R,
      VGA_B_out=>VGA_B,
      VGA_G_out=>VGA_G
   );

------------------------
-- Camera
------------------------

camera_inst: camera
   port map(
      clk_in=>clk_camera,
      SIOC=>CAMERA_SCL,
      SIOD=>CAMERA_SDR,
      RESET=>CAMERA_RESET,
      PWDN=>CAMERA_PWDN,
      XCLK=>CAMERA_MCLK,  
      CAMERA_PCLK=>CAMERA_PCLK,
      CAMERA_D=>CAMERA_D,
      CAMERA_VS=>CAMERA_VS,
      CAMERA_RS=>CAMERA_RS,
      tdata_out=>camera_tdata,
      tlast_out=>camera_tlast,
      tready_in=>camera_tready,
      tuser_out=>open,
      tvalid_out=>camera_tvalid
   );

------------------
-- Clock synthesizer
-------------------

clk_wiz_inst:clk_wiz_0
   port map(
      clk_out1=>clk_vga,
      clk_out2=>clk_mig_ref,
      clk_out3=>clk_mig_sysclk,
      clk_out4=>clk_camera,
      clk_out5=>clk_main,
      clk_out6=>clk_x2_main,
      resetn=>sys_resetn,
      locked=>open,
      clk_in1=>sys_clock
   );

END behavior;
