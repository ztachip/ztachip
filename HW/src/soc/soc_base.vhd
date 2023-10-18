-----------------------------------------------------------------------------
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
------------------------------------------------------------------------------
--
-- This is the soc base where custom soc can be built on
--
----------------------------------------------------------------------------
--                  SOC BASE COMPONENT DECLARATION
--                  SIGNAL/PIN ASSIGNMENTS
----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity soc_base is
   port 
   (
   -- Reference clock/external reset

   clk_main        :IN STD_LOGIC;
   clk_x2_main     :IN STD_LOGIC;


   -- SDRAM axi signals

   SDRAM_clk       :IN STD_LOGIC;
   SDRAM_araddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM_arburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM_arlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
   SDRAM_arready   :IN STD_LOGIC;
   SDRAM_arsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
   SDRAM_arvalid   :OUT STD_LOGIC;
   SDRAM_awaddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM_awburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM_awlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
   SDRAM_awready   :IN STD_LOGIC;
   SDRAM_awsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
   SDRAM_awvalid   :OUT STD_LOGIC;
   SDRAM_bready    :OUT STD_LOGIC;
   SDRAM_bresp     :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM_bvalid    :IN STD_LOGIC;
   SDRAM_rdata     :IN STD_LOGIC_VECTOR(63 downto 0);
   SDRAM_rlast     :IN STD_LOGIC;
   SDRAM_rready    :OUT STD_LOGIC;
   SDRAM_rresp     :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM_rvalid    :IN STD_LOGIC;
   SDRAM_wdata     :OUT STD_LOGIC_VECTOR(63 downto 0);
   SDRAM_wlast     :OUT STD_LOGIC;
   SDRAM_wready    :IN STD_LOGIC;
   SDRAM_wstrb     :OUT STD_LOGIC_VECTOR(7 downto 0);
   SDRAM_wvalid    :OUT STD_LOGIC;

   -- VIDEO streaming bus  

   VIDEO_clk       :IN STD_LOGIC;
   VIDEO_tdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
   VIDEO_tlast     :OUT STD_LOGIC;
   VIDEO_tready    :IN STD_LOGIC;
   VIDEO_tvalid    :OUT STD_LOGIC;

   -- Camera streaming bus

   camera_clk      :IN STD_LOGIC;
   camera_tdata    :IN STD_LOGIC_VECTOR(31 downto 0);
   camera_tlast    :IN STD_LOGIC;
   camera_tready   :OUT STD_LOGIC;
   camera_tvalid   :IN STD_LOGIC;

   -- GPIO signals
   
   led             :OUT STD_LOGIC_VECTOR(3 downto 0);
   pushbutton      :IN STD_LOGIC_VECTOR(3 downto 0);

   -- UART Signals
   
   UART_TXD        :OUT STD_LOGIC;
   UART_RXD        :IN STD_LOGIC

   );
end soc_base;
   
architecture rtl of soc_base is

----------------------------------------------------------------------------
--                       IMPLEMENTATION
----------------------------------------------------------------------------   
            
   SIGNAL clk_reset:STD_LOGIC;
   
   -- VexRiscv IBUS axi signals
      
   SIGNAL ibus_araddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ibus_arlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL ibus_arsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ibus_arburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ibus_arvalid:STD_LOGIC;
   SIGNAL ibus_arready:STD_LOGIC;
   SIGNAL ibus_arid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ibus_arlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ibus_arcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ibus_arprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ibus_arqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ibus_rready:STD_LOGIC;
   SIGNAL ibus_rid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ibus_rdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ibus_rresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ibus_rlast:STD_LOGIC;
   SIGNAL ibus_rvalid:STD_LOGIC;


   -- VexRiscv DBUS axi signals

   SIGNAL dbus_awaddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus_awlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL dbus_awsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus_awburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus_awvalid:STD_LOGIC;
   SIGNAL dbus_awready:STD_LOGIC;
   SIGNAL dbus_awid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus_awlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus_awcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus_awprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus_awqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus_wdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus_wstrb:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus_wlast:STD_LOGIC;
   SIGNAL dbus_wvalid:STD_LOGIC;
   SIGNAL dbus_wready:STD_LOGIC;
   SIGNAL dbus_bready:STD_LOGIC;
   SIGNAL dbus_bresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus_bvalid:STD_LOGIC;
   SIGNAL dbus_bid:STD_LOGIC_VECTOR(0 downto 0);
      
   SIGNAL dbus_araddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus_arlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL dbus_arsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus_arburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus_arvalid:STD_LOGIC;
   SIGNAL dbus_arready:STD_LOGIC;
   SIGNAL dbus_arid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus_arlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus_arcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus_arprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus_arqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus_rready:STD_LOGIC;
   SIGNAL dbus_rdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus_rresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus_rlast:STD_LOGIC;
   SIGNAL dbus_rvalid:STD_LOGIC;
   SIGNAL dbus_rid:STD_LOGIC_VECTOR(0 downto 0);

   SIGNAL dbus2_awaddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus2_awlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL dbus2_awsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus2_awburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus2_awvalid:STD_LOGIC;
   SIGNAL dbus2_awready:STD_LOGIC;
   SIGNAL dbus2_awid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus2_awlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus2_awcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus2_awprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus2_awqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus2_wdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus2_wstrb:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus2_wlast:STD_LOGIC;
   SIGNAL dbus2_wvalid:STD_LOGIC;
   SIGNAL dbus2_wready:STD_LOGIC;
   SIGNAL dbus2_bready:STD_LOGIC;
   SIGNAL dbus2_bresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus2_bvalid:STD_LOGIC;
   SIGNAL dbus2_bid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus2_araddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus2_arlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL dbus2_arsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus2_arburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus2_arvalid:STD_LOGIC;
   SIGNAL dbus2_arready:STD_LOGIC;
   SIGNAL dbus2_arid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus2_arlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL dbus2_arcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus2_arprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL dbus2_arqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL dbus2_rready:STD_LOGIC;
   SIGNAL dbus2_rdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL dbus2_rresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL dbus2_rlast:STD_LOGIC;
   SIGNAL dbus2_rvalid:STD_LOGIC;
   SIGNAL dbus2_rid:STD_LOGIC_VECTOR(0 downto 0);

   SIGNAL apb_awaddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL apb_awlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL apb_awsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL apb_awburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL apb_awvalid:STD_LOGIC;
   SIGNAL apb_awready:STD_LOGIC;
   SIGNAL apb_awid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL apb_awlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL apb_awcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL apb_awprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL apb_awqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL apb_wdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL apb_wstrb:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL apb_wlast:STD_LOGIC;
   SIGNAL apb_wvalid:STD_LOGIC;
   SIGNAL apb_wready:STD_LOGIC;
   SIGNAL apb_bready:STD_LOGIC;
   SIGNAL apb_bresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL apb_bvalid:STD_LOGIC;
   SIGNAL apb_bid:STD_LOGIC_VECTOR(0 downto 0);
      
   SIGNAL apb_araddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL apb_arlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL apb_arsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL apb_arburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL apb_arvalid:STD_LOGIC;
   SIGNAL apb_arready:STD_LOGIC;
   SIGNAL apb_arid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL apb_arlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL apb_arcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL apb_arprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL apb_arqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL apb_rready:STD_LOGIC;
   SIGNAL apb_rdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL apb_rresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL apb_rlast:STD_LOGIC;
   SIGNAL apb_rvalid:STD_LOGIC;
   SIGNAL apb_rid:STD_LOGIC_VECTOR(0 downto 0);

   SIGNAL vdma_awaddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL vdma_awlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL vdma_awsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL vdma_awburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL vdma_awvalid:STD_LOGIC;
   SIGNAL vdma_awready:STD_LOGIC;
   SIGNAL vdma_awid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL vdma_awlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL vdma_awcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL vdma_awprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL vdma_awqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL vdma_wdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL vdma_wstrb:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL vdma_wlast:STD_LOGIC;
   SIGNAL vdma_wvalid:STD_LOGIC;
   SIGNAL vdma_wready:STD_LOGIC;
   SIGNAL vdma_bready:STD_LOGIC;
   SIGNAL vdma_bresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL vdma_bvalid:STD_LOGIC;
   SIGNAL vdma_bid:STD_LOGIC_VECTOR(0 downto 0);

   SIGNAL rvdma_araddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL rvdma_arlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL rvdma_arsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL rvdma_arburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL rvdma_arvalid:STD_LOGIC;
   SIGNAL rvdma_arready:STD_LOGIC;
   SIGNAL rvdma_arid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL rvdma_arlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL rvdma_arcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL rvdma_arprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL rvdma_arqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL rvdma_rready:STD_LOGIC;
   SIGNAL rvdma_rdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL rvdma_rresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL rvdma_rlast:STD_LOGIC;
   SIGNAL rvdma_rvalid:STD_LOGIC;
   SIGNAL rvdma_rid:STD_LOGIC_VECTOR(0 downto 0);
   
   -- ztachip control axi bus

   SIGNAL ZTA_CONTROL_awaddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ZTA_CONTROL_awlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL ZTA_CONTROL_awsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_CONTROL_awburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_CONTROL_awvalid:STD_LOGIC;
   SIGNAL ZTA_CONTROL_awready:STD_LOGIC;
   SIGNAL ZTA_CONTROL_awid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_CONTROL_awlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_CONTROL_awcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_CONTROL_awprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_CONTROL_awqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_CONTROL_wdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ZTA_CONTROL_wstrb:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_CONTROL_wlast:STD_LOGIC;
   SIGNAL ZTA_CONTROL_wvalid:STD_LOGIC;
   SIGNAL ZTA_CONTROL_wready:STD_LOGIC;
   SIGNAL ZTA_CONTROL_bready:STD_LOGIC;
   SIGNAL ZTA_CONTROL_bresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_CONTROL_bvalid:STD_LOGIC;
   SIGNAL ZTA_CONTROL_bid:STD_LOGIC_VECTOR(0 downto 0);
      
   SIGNAL ZTA_CONTROL_araddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ZTA_CONTROL_arlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL ZTA_CONTROL_arsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_CONTROL_arburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_CONTROL_arvalid:STD_LOGIC;
   SIGNAL ZTA_CONTROL_arready:STD_LOGIC;
   SIGNAL ZTA_CONTROL_arid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_CONTROL_arlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_CONTROL_arcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_CONTROL_arprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_CONTROL_arqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_CONTROL_rready:STD_LOGIC;
   SIGNAL ZTA_CONTROL_rdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ZTA_CONTROL_rresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_CONTROL_rlast:STD_LOGIC;
   SIGNAL ZTA_CONTROL_rvalid:STD_LOGIC;
   SIGNAL ZTA_CONTROL_rid:STD_LOGIC_VECTOR(0 downto 0);
   
   -- ztachip data axi bus
      
   SIGNAL ZTA_DATA_araddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ZTA_DATA_arburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_DATA_arcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_DATA_arid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_DATA_arlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL ZTA_DATA_arlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_DATA_arprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_DATA_arqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_DATA_arready:STD_LOGIC;
   SIGNAL ZTA_DATA_arsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_DATA_arvalid:STD_LOGIC;
   SIGNAL ZTA_DATA_awaddr:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL ZTA_DATA_awburst:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_DATA_awcache:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_DATA_awid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_DATA_awlen:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL ZTA_DATA_awlock:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_DATA_awprot:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_DATA_awqos:STD_LOGIC_VECTOR(3 downto 0);
   SIGNAL ZTA_DATA_awready:STD_LOGIC;
   SIGNAL ZTA_DATA_awsize:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL ZTA_DATA_awvalid:STD_LOGIC;
   SIGNAL ZTA_DATA_bid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_DATA_bready:STD_LOGIC;
   SIGNAL ZTA_DATA_bresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_DATA_bvalid:STD_LOGIC;
   SIGNAL ZTA_DATA_rdata:STD_LOGIC_VECTOR(63 downto 0);
   SIGNAL ZTA_DATA_rid:STD_LOGIC_VECTOR(0 downto 0);
   SIGNAL ZTA_DATA_rlast:STD_LOGIC;
   SIGNAL ZTA_DATA_rready:STD_LOGIC;
   SIGNAL ZTA_DATA_rresp:STD_LOGIC_VECTOR(1 downto 0);
   SIGNAL ZTA_DATA_rvalid:STD_LOGIC;
   SIGNAL ZTA_DATA_wdata:STD_LOGIC_VECTOR(63 downto 0);
   SIGNAL ZTA_DATA_wlast:STD_LOGIC;
   SIGNAL ZTA_DATA_wready:STD_LOGIC;
   SIGNAL ZTA_DATA_wstrb:STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL ZTA_DATA_wvalid:STD_LOGIC;
   
   SIGNAL APB_PADDR:STD_LOGIC_VECTOR(19 downto 0);
   SIGNAL APB_PENABLE:STD_LOGIC;
   SIGNAL APB_PREADY:STD_LOGIC;
   SIGNAL APB_PWRITE:STD_LOGIC;
   SIGNAL APB_PWDATA:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL APB_PRDATA:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL APB_PSLVERROR:STD_LOGIC;

   SIGNAL s_wdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL s_wready:STD_LOGIC;
   SIGNAL s_wvalid:STD_LOGIC;  
   
   SIGNAL s_rdata:STD_LOGIC_VECTOR(31 downto 0);
   SIGNAL s_rready:STD_LOGIC;
   SIGNAL s_rvalid:STD_LOGIC;
   SIGNAL arlen:unsigned(2 downto 0);
   SIGNAL awlen:unsigned(2 downto 0);
      
begin

   clk_reset <= '0';  

   UART_TXD <= '0';
   
   ZTA_CONTROL_rlast <= '1';

   ZTA_CONTROL_rid <= (others=>'0');
   
   ZTA_CONTROL_bid <= (others=>'0');
   
   -- -----------------------------
   -- CPU. RISCV based on VexRiscv
   -- ------------------------------
                    
   cpu_inst : MyVexRiscv 
      port map 
      (
         io_asyncReset=>clk_reset,
         io_mainClk=>clk_main,

         io_iBus_ar_valid=>ibus_arvalid,
         io_iBus_ar_ready=>ibus_arready,
         io_iBus_ar_payload_addr=>ibus_araddr,
         io_iBus_ar_payload_id=>ibus_arid(0),
         io_iBus_ar_payload_region=>open,
         io_iBus_ar_payload_len=>ibus_arlen,
         io_iBus_ar_payload_size=>ibus_arsize,
         io_iBus_ar_payload_burst=>ibus_arburst,
         io_iBus_ar_payload_lock=>ibus_arlock,
         io_iBus_ar_payload_cache=>ibus_arcache,
         io_iBus_ar_payload_qos=>ibus_arqos,
         io_iBus_ar_payload_prot=>ibus_arprot,
         io_iBus_r_valid=>ibus_rvalid,
         io_iBus_r_ready=>ibus_rready,
         io_iBus_r_payload_data=>ibus_rdata,
         io_iBus_r_payload_id=>ibus_rid(0),
         io_iBus_r_payload_resp=>ibus_rresp,
         io_iBus_r_payload_last=>ibus_rlast, 

         io_dBus_aw_valid=>dbus_awvalid,
         io_dBus_aw_ready=>dbus_awready,
         io_dBus_aw_payload_addr=>dbus_awaddr,
         io_dBus_aw_payload_id=>dbus_awid(0),
         io_dBus_aw_payload_region=>open,
         io_dBus_aw_payload_len=>dbus_awlen,
         io_dBus_aw_payload_size=>dbus_awsize,
         io_dBus_aw_payload_burst=>dbus_awburst,
         io_dBus_aw_payload_lock=>dbus_awlock,
         io_dBus_aw_payload_cache=>dbus_awcache,
         io_dBus_aw_payload_qos=>dbus_awqos,
         io_dBus_aw_payload_prot=>dbus_awprot,
         io_dBus_w_valid=>dbus_wvalid,
         io_dBus_w_ready=>dbus_wready,
         io_dBus_w_payload_data=>dbus_wdata,
         io_dBus_w_payload_strb=>dbus_wstrb,
         io_dBus_w_payload_last=>dbus_wlast,
         io_dBus_b_valid=>dbus_bvalid,
         io_dBus_b_ready=>dbus_bready,
         io_dBus_b_payload_id=>dbus_bid(0),
         io_dBus_b_payload_resp=>dbus_bresp,

         io_dBus_ar_valid=>dbus_arvalid,
         io_dBus_ar_ready=>dbus_arready,
         io_dBus_ar_payload_addr=>dbus_araddr,
         io_dBus_ar_payload_id=>dbus_arid(0),
         io_dBus_ar_payload_region=>open,
         io_dBus_ar_payload_len=>dbus_arlen,
         io_dBus_ar_payload_size=>dbus_arsize,
         io_dBus_ar_payload_burst=>dbus_arburst,
         io_dBus_ar_payload_lock=>dbus_arlock,
         io_dBus_ar_payload_cache=>dbus_arcache,
         io_dBus_ar_payload_qos=>dbus_arqos,
         io_dBus_ar_payload_prot=>dbus_arprot,
         io_dBus_r_valid=>dbus_rvalid,
         io_dBus_r_ready=>dbus_rready,
         io_dBus_r_payload_data=>dbus_rdata,
         io_dBus_r_payload_id=>dbus_rid(0),
         io_dBus_r_payload_resp=>dbus_rresp,
         io_dBus_r_payload_last=>dbus_rlast
      );

axi_split_i : axi_split
   GENERIC MAP (
      NUM_MASTER_PORT=>3,
      BAR_LO_BIT=>(30,30,31),
      BAR_HI_BIT=>(31,31,31),
      BAR=>(2,3,0)
   )
   PORT MAP
   (
      clock_in=>clk_main,
      reset_in=>'1',

      axislave_araddr_in=>dbus_araddr,
      axislave_arlen_in=>dbus_arlen,
      axislave_arvalid_in=>dbus_arvalid,
      axislave_arid_in=>dbus_arid,
      axislave_arlock_in=>dbus_arlock,
      axislave_arcache_in=>dbus_arcache,
      axislave_arprot_in=>dbus_arprot,
      axislave_arqos_in=>dbus_arqos,
      axislave_rid_out=>dbus_rid,
      axislave_rvalid_out=>dbus_rvalid,
      axislave_rlast_out=>dbus_rlast,
      axislave_rdata_out=>dbus_rdata,
      axislave_rresp_out=>dbus_rresp,
      axislave_arready_out=>dbus_arready,
      axislave_rready_in=>dbus_rready,
      axislave_arburst_in=>dbus_arburst,
      axislave_arsize_in=>dbus_arsize,

      axislave_awaddr_in=>dbus_awaddr,
      axislave_awlen_in=>dbus_awlen,
      axislave_awvalid_in=>dbus_awvalid,
      axislave_wvalid_in=>dbus_wvalid,
      axislave_wdata_in=>dbus_wdata,
      axislave_wlast_in=>dbus_wlast,
      axislave_wstrb_in=>dbus_wstrb,
      axislave_awready_out=>dbus_awready,
      axislave_wready_out=>dbus_wready,
      axislave_bresp_out=>dbus_bresp,
      axislave_bid_out=>dbus_bid,
      axislave_bvalid_out=>dbus_bvalid,
      axislave_awburst_in=>dbus_awburst,
      axislave_awcache_in=>dbus_awcache,
      axislave_awid_in=>dbus_awid,
      axislave_awlock_in=>dbus_awlock,
      axislave_awprot_in=>dbus_awprot,
      axislave_awqos_in=>dbus_awqos,
      axislave_awsize_in=>dbus_awsize,
      axislave_bready_in=>dbus_bready,
                           
      aximaster0_araddr_out=>dbus2_araddr,
      aximaster0_arlen_out=>dbus2_arlen,
      aximaster0_arvalid_out=>dbus2_arvalid,
      aximaster0_arid_out=>dbus2_arid,
      aximaster0_arlock_out=>dbus2_arlock,
      aximaster0_arcache_out=>dbus2_arcache,
      aximaster0_arprot_out=>dbus2_arprot,
      aximaster0_arqos_out=>dbus2_arqos,
      aximaster0_rid_in=>dbus2_rid,
      aximaster0_rvalid_in=>dbus2_rvalid,
      aximaster0_rlast_in=>dbus2_rlast,
      aximaster0_rdata_in=>dbus2_rdata,
      aximaster0_rresp_in=>dbus2_rresp,
      aximaster0_arready_in=>dbus2_arready,
      aximaster0_rready_out=>dbus2_rready,
      aximaster0_arburst_out=>dbus2_arburst,
      aximaster0_arsize_out=>dbus2_arsize,

      aximaster0_awaddr_out=>dbus2_awaddr,
      aximaster0_awlen_out=>dbus2_awlen,
      aximaster0_awvalid_out=>dbus2_awvalid,
      aximaster0_wvalid_out=>dbus2_wvalid,
      aximaster0_wdata_out=>dbus2_wdata,
      aximaster0_wlast_out=>dbus2_wlast,
      aximaster0_wstrb_out=>dbus2_wstrb,
      aximaster0_awready_in=>dbus2_awready,
      aximaster0_wready_in=>dbus2_wready,
      aximaster0_bresp_in=>dbus2_bresp,
      aximaster0_bid_in=>dbus2_bid,
      aximaster0_bvalid_in=>dbus2_bvalid,
      aximaster0_awburst_out=>dbus2_awburst,
      aximaster0_awcache_out=>dbus2_awcache,
      aximaster0_awid_out=>dbus2_awid,
      aximaster0_awlock_out=>dbus2_awlock,
      aximaster0_awprot_out=>dbus2_awprot,
      aximaster0_awqos_out=>dbus2_awqos,
      aximaster0_awsize_out=>dbus2_awsize,
      aximaster0_bready_out=>dbus2_bready,

      aximaster1_araddr_out=>apb_araddr,
      aximaster1_arlen_out=>apb_arlen,
      aximaster1_arvalid_out=>apb_arvalid,
      aximaster1_arid_out=>apb_arid,
      aximaster1_arlock_out=>apb_arlock,
      aximaster1_arcache_out=>apb_arcache,
      aximaster1_arprot_out=>apb_arprot,
      aximaster1_arqos_out=>apb_arqos,
      aximaster1_rid_in=>apb_rid,
      aximaster1_rvalid_in=>apb_rvalid,
      aximaster1_rlast_in=>apb_rlast,
      aximaster1_rdata_in=>apb_rdata,
      aximaster1_rresp_in=>apb_rresp,
      aximaster1_arready_in=>apb_arready,
      aximaster1_rready_out=>apb_rready,
      aximaster1_arburst_out=>apb_arburst,
      aximaster1_arsize_out=>apb_arsize,

      aximaster1_awaddr_out=>apb_awaddr,
      aximaster1_awlen_out=>apb_awlen,
      aximaster1_awvalid_out=>apb_awvalid,
      aximaster1_wvalid_out=>apb_wvalid,
      aximaster1_wdata_out=>apb_wdata,
      aximaster1_wlast_out=>apb_wlast,
      aximaster1_wstrb_out=>apb_wstrb,
      aximaster1_awready_in=>apb_awready,
      aximaster1_wready_in=>apb_wready,
      aximaster1_bresp_in=>apb_bresp,
      aximaster1_bid_in=>apb_bid,
      aximaster1_bvalid_in=>apb_bvalid,
      aximaster1_awburst_out=>apb_awburst,
      aximaster1_awcache_out=>apb_awcache,
      aximaster1_awid_out=>apb_awid,
      aximaster1_awlock_out=>apb_awlock,
      aximaster1_awprot_out=>apb_awprot,
      aximaster1_awqos_out=>apb_awqos,
      aximaster1_awsize_out=>apb_awsize,
      aximaster1_bready_out=>apb_bready,

      aximaster2_araddr_out=>ZTA_CONTROL_araddr,
      aximaster2_arlen_out=>ZTA_CONTROL_arlen,
      aximaster2_arvalid_out=>ZTA_CONTROL_arvalid,
      aximaster2_arid_out=>ZTA_CONTROL_arid,
      aximaster2_arlock_out=>ZTA_CONTROL_arlock,
      aximaster2_arcache_out=>ZTA_CONTROL_arcache,
      aximaster2_arprot_out=>ZTA_CONTROL_arprot,
      aximaster2_arqos_out=>ZTA_CONTROL_arqos,
      aximaster2_rid_in=>ZTA_CONTROL_rid,
      aximaster2_rvalid_in=>ZTA_CONTROL_rvalid,
      aximaster2_rlast_in=>ZTA_CONTROL_rlast,
      aximaster2_rdata_in=>ZTA_CONTROL_rdata,
      aximaster2_rresp_in=>ZTA_CONTROL_rresp,
      aximaster2_arready_in=>ZTA_CONTROL_arready,
      aximaster2_rready_out=>ZTA_CONTROL_rready,
      aximaster2_arburst_out=>ZTA_CONTROL_arburst,
      aximaster2_arsize_out=>ZTA_CONTROL_arsize,

      aximaster2_awaddr_out=>ZTA_CONTROL_awaddr,
      aximaster2_awlen_out=>ZTA_CONTROL_awlen,
      aximaster2_awvalid_out=>ZTA_CONTROL_awvalid,
      aximaster2_wvalid_out=>ZTA_CONTROL_wvalid,
      aximaster2_wdata_out=>ZTA_CONTROL_wdata,
      aximaster2_wlast_out=>ZTA_CONTROL_wlast,
      aximaster2_wstrb_out=>ZTA_CONTROL_wstrb,
      aximaster2_awready_in=>ZTA_CONTROL_awready,
      aximaster2_wready_in=>ZTA_CONTROL_wready,
      aximaster2_bresp_in=>ZTA_CONTROL_bresp,
      aximaster2_bid_in=>ZTA_CONTROL_bid,
      aximaster2_bvalid_in=>ZTA_CONTROL_bvalid,
      aximaster2_awburst_out=>ZTA_CONTROL_awburst,
      aximaster2_awcache_out=>ZTA_CONTROL_awcache,
      aximaster2_awid_out=>ZTA_CONTROL_awid,
      aximaster2_awlock_out=>ZTA_CONTROL_awlock,
      aximaster2_awprot_out=>ZTA_CONTROL_awprot,
      aximaster2_awqos_out=>ZTA_CONTROL_awqos,
      aximaster2_awsize_out=>ZTA_CONTROL_awsize,
      aximaster2_bready_out=>ZTA_CONTROL_bready        
   );

axi_merge_inst : axi_merge 
   GENERIC MAP (
      R_FIFO_CMD_DEPTH=>(5,5,5),
      R_FIFO_DATA_DEPTH=>(5,5,7),
      R_FIFO_W_CMD_DEPTH=>6,
      R_FIFO_W_DATA_DEPTH=>9,

      W_FIFO_CMD_DEPTH=>(5,5,5),
      W_FIFO_DATA_DEPTH=>(5,5,5),
      W_FIFO_W_CMD_DEPTH=>8,
      W_FIFO_W_DATA_DEPTH=>8
   )
   PORT MAP (
      clock_in=>SDRAM_clk,
      reset_in=>'1',

      axislavew_clock_in=>clk_main,
      axislavew_araddr_in=>ZTA_DATA_araddr,
      axislavew_arlen_in=>ZTA_DATA_arlen,
      axislavew_arvalid_in=>ZTA_DATA_arvalid, 
      axislavew_arid_in=>ZTA_DATA_arid,
      axislavew_arlock_in=>ZTA_DATA_arlock,
      axislavew_arcache_in=>ZTA_DATA_arcache,
      axislavew_arprot_in=>ZTA_DATA_arprot,
      axislavew_arqos_in=>ZTA_DATA_arqos,
      axislavew_rid_out=>ZTA_DATA_rid,
      axislavew_rvalid_out=>ZTA_DATA_rvalid,
      axislavew_rlast_out=>ZTA_DATA_rlast,
      axislavew_rdata_out=>ZTA_DATA_rdata,
      axislavew_rresp_out=>ZTA_DATA_rresp,
      axislavew_arready_out=>ZTA_DATA_arready,
      axislavew_rready_in=>ZTA_DATA_rready,
      axislavew_arburst_in=>ZTA_DATA_arburst,
      axislavew_arsize_in=>ZTA_DATA_arsize,
            
      axislavew_awaddr_in=>ZTA_DATA_awaddr,
      axislavew_awlen_in=>ZTA_DATA_awlen,
      axislavew_awvalid_in=>ZTA_DATA_awvalid,
      axislavew_wvalid_in=>ZTA_DATA_wvalid,
      axislavew_wdata_in=>ZTA_DATA_wdata,
      axislavew_wlast_in=>ZTA_DATA_wlast,
      axislavew_wstrb_in=>ZTA_DATA_wstrb,
      axislavew_awready_out=>ZTA_DATA_awready,
      axislavew_wready_out=>ZTA_DATA_wready,
      axislavew_bresp_out=>ZTA_DATA_bresp,
      axislavew_bid_out=>ZTA_DATA_bid,
      axislavew_bvalid_out=>ZTA_DATA_bvalid,
      axislavew_awburst_in=>ZTA_DATA_awburst,
      axislavew_awcache_in=>ZTA_DATA_awcache,
      axislavew_awid_in=>ZTA_DATA_awid,
      axislavew_awlock_in=>ZTA_DATA_awlock,
      axislavew_awprot_in=>ZTA_DATA_awprot,
      axislavew_awqos_in=>ZTA_DATA_awqos,
      axislavew_awsize_in=>ZTA_DATA_awsize,
      axislavew_bready_in=>ZTA_DATA_bready,

      axislave1_clock_in=>clk_main,
      axislave1_araddr_in=>ibus_araddr,
      axislave1_arlen_in=>ibus_arlen,
      axislave1_arvalid_in=>ibus_arvalid,
      axislave1_arid_in=>ibus_arid,
      axislave1_arlock_in=>ibus_arlock,
      axislave1_arcache_in=>ibus_arcache,
      axislave1_arprot_in=>ibus_arprot,
      axislave1_arqos_in=>ibus_arqos,
      axislave1_rid_out=>ibus_rid,
      axislave1_rvalid_out=>ibus_rvalid,
      axislave1_rlast_out=>ibus_rlast,
      axislave1_rdata_out=>ibus_rdata,
      axislave1_rresp_out=>ibus_rresp,
      axislave1_arready_out=>ibus_arready,
      axislave1_rready_in=>ibus_rready,
      axislave1_arburst_in=>ibus_arburst,
      axislave1_arsize_in=>ibus_arsize,

      axislave1_awaddr_in=>(others=>'0'),
      axislave1_awlen_in=>(others=>'0'),
      axislave1_awvalid_in=>'0',
      axislave1_wvalid_in=>'0',
      axislave1_wdata_in=>(others=>'0'),
      axislave1_wlast_in=>'0',
      axislave1_wstrb_in=>(others=>'0'),
      axislave1_awready_out=>open,
      axislave1_wready_out=>open,
      axislave1_bresp_out=>open,
      axislave1_bid_out=>open,
      axislave1_bvalid_out=>open,
      axislave1_awburst_in=>(others=>'0'),
      axislave1_awcache_in=>(others=>'0'),
      axislave1_awid_in=>(others=>'0'),
      axislave1_awlock_in=>(others=>'0'),
      axislave1_awprot_in=>(others=>'0'),
      axislave1_awqos_in=>(others=>'0'),
      axislave1_awsize_in=>(others=>'0'),
      axislave1_bready_in=>'0',

      axislave2_clock_in=>clk_main,
      axislave2_araddr_in=>dbus2_araddr,
      axislave2_arlen_in=>dbus2_arlen,
      axislave2_arvalid_in=>dbus2_arvalid,
      axislave2_arid_in=>dbus2_arid,
      axislave2_arlock_in=>dbus2_arlock,
      axislave2_arcache_in=>dbus2_arcache,
      axislave2_arprot_in=>dbus2_arprot,
      axislave2_arqos_in=>dbus2_arqos,
      axislave2_rid_out=>dbus2_rid,
      axislave2_rvalid_out=>dbus2_rvalid,
      axislave2_rlast_out=>dbus2_rlast,
      axislave2_rdata_out=>dbus2_rdata,
      axislave2_rresp_out=>dbus2_rresp,
      axislave2_arready_out=>dbus2_arready,
      axislave2_rready_in=>dbus2_rready,
      axislave2_arburst_in=>dbus2_arburst,
      axislave2_arsize_in=>dbus2_arsize,

      axislave2_awaddr_in=>dbus2_awaddr,
      axislave2_awlen_in=>dbus2_awlen,
      axislave2_awvalid_in=>dbus2_awvalid,
      axislave2_wvalid_in=>dbus2_wvalid,
      axislave2_wdata_in=>dbus2_wdata,
      axislave2_wlast_in=>dbus2_wlast,
      axislave2_wstrb_in=>dbus2_wstrb,
      axislave2_awready_out=>dbus2_awready,
      axislave2_wready_out=>dbus2_wready,
      axislave2_bresp_out=>dbus2_bresp,
      axislave2_bid_out=>dbus2_bid,
      axislave2_bvalid_out=>dbus2_bvalid,
      axislave2_awburst_in=>dbus2_awburst,
      axislave2_awcache_in=>dbus2_awcache,
      axislave2_awid_in=>dbus2_awid,
      axislave2_awlock_in=>dbus2_awlock,
      axislave2_awprot_in=>dbus2_awprot,
      axislave2_awqos_in=>dbus2_awqos,
      axislave2_awsize_in=>dbus2_awsize,
      axislave2_bready_in=>dbus2_bready,

      axislave0_clock_in=>clk_main,
      axislave0_araddr_in=>rvdma_araddr,
      axislave0_arlen_in=>rvdma_arlen,
      axislave0_arvalid_in=>rvdma_arvalid,
      axislave0_arid_in=>rvdma_arid,
      axislave0_arlock_in=>rvdma_arlock,
      axislave0_arcache_in=>rvdma_arcache,
      axislave0_arprot_in=>rvdma_arprot,
      axislave0_arqos_in=>rvdma_arqos,
      axislave0_rid_out=>rvdma_rid,
      axislave0_rvalid_out=>rvdma_rvalid,
      axislave0_rlast_out=>rvdma_rlast,
      axislave0_rdata_out=>rvdma_rdata,
      axislave0_rresp_out=>rvdma_rresp,
      axislave0_arready_out=>rvdma_arready,
      axislave0_rready_in=>rvdma_rready,
      axislave0_arburst_in=>rvdma_arburst,
      axislave0_arsize_in=>rvdma_arsize,

      axislave0_awaddr_in=>vdma_awaddr,
      axislave0_awlen_in=>vdma_awlen,
      axislave0_awvalid_in=>vdma_awvalid,
      axislave0_wvalid_in=>vdma_wvalid,
      axislave0_wdata_in=>vdma_wdata,
      axislave0_wlast_in=>vdma_wlast,
      axislave0_wstrb_in=>vdma_wstrb,
      axislave0_awready_out=>vdma_awready,
      axislave0_wready_out=>vdma_wready,
      axislave0_bresp_out=>vdma_bresp,
      axislave0_bid_out=>vdma_bid,
      axislave0_bvalid_out=>vdma_bvalid,
      axislave0_awburst_in=>vdma_awburst,
      axislave0_awcache_in=>vdma_awcache,
      axislave0_awid_in=>vdma_awid,
      axislave0_awlock_in=>vdma_awlock,
      axislave0_awprot_in=>vdma_awprot,
      axislave0_awqos_in=>vdma_awqos,
      axislave0_awsize_in=>vdma_awsize,
      axislave0_bready_in=>vdma_bready,
                              
      aximaster_araddr_out=>SDRAM_araddr,
      aximaster_arlen_out=>SDRAM_arlen,
      aximaster_arvalid_out=>SDRAM_arvalid,
      aximaster_arid_out=>open,
      aximaster_arlock_out=>open,
      aximaster_arcache_out=>open,
      aximaster_arprot_out=>open,
      aximaster_arqos_out=>open,
      aximaster_rid_in=>(others=>'0'), 
      aximaster_rvalid_in=>SDRAM_rvalid,
      aximaster_rlast_in=>SDRAM_rlast,
      aximaster_rdata_in=>SDRAM_rdata,
      aximaster_rresp_in=>SDRAM_rresp,
      aximaster_arready_in=>SDRAM_arready,
      aximaster_rready_out=>SDRAM_rready,
      aximaster_arburst_out=>SDRAM_arburst,
      aximaster_arsize_out=>SDRAM_arsize,

      aximaster_awaddr_out=>SDRAM_awaddr,
      aximaster_awlen_out=>SDRAM_awlen,
      aximaster_awvalid_out=>SDRAM_awvalid,
      aximaster_wvalid_out=>SDRAM_wvalid,
      aximaster_wdata_out=>SDRAM_wdata,
      aximaster_wlast_out=>SDRAM_wlast,
      aximaster_wstrb_out=>SDRAM_wstrb,
      aximaster_awready_in=>SDRAM_awready,
      aximaster_wready_in=>SDRAM_wready,
      aximaster_bresp_in=>SDRAM_bresp,
      aximaster_bid_in=>(others=>'0'),
      aximaster_bvalid_in=>SDRAM_bvalid,
      aximaster_awburst_out=>SDRAM_awburst,
      aximaster_awcache_out=>open,
      aximaster_awid_out=>open,
      aximaster_awlock_out=>open,
      aximaster_awprot_out=>open,
      aximaster_awqos_out=>open,
      aximaster_awsize_out=>SDRAM_awsize,
      aximaster_bready_out=>SDRAM_bready
   );

axi_apb_bridge_inst : axi_apb_bridge
   PORT MAP
   (
      clock_in=>clk_main,
      reset_in=>'1',

      axislave_araddr_in=>apb_araddr,
      axislave_arlen_in=>apb_arlen,
      axislave_arvalid_in=>apb_arvalid,
      axislave_arid_in=>apb_arid,
      axislave_arlock_in=>apb_arlock,
      axislave_arcache_in=>apb_arcache,
      axislave_arprot_in=>apb_arprot,
      axislave_arqos_in=>apb_arqos,
      axislave_rid_out=>apb_rid,
      axislave_rvalid_out=>apb_rvalid,
      axislave_rlast_out=>apb_rlast,
      axislave_rdata_out=>apb_rdata,
      axislave_rresp_out=>apb_rresp,
      axislave_arready_out=>apb_arready,
      axislave_rready_in=>apb_rready,
      axislave_arburst_in=>apb_arburst,
      axislave_arsize_in=>apb_arsize,

      axislave_awaddr_in=>apb_awaddr,
      axislave_awlen_in=>apb_awlen,
      axislave_awvalid_in=>apb_awvalid,
      axislave_wvalid_in=>apb_wvalid,
      axislave_wdata_in=>apb_wdata,
      axislave_wlast_in=>apb_wlast,
      axislave_wstrb_in=>apb_wstrb,
      axislave_awready_out=>apb_awready,
      axislave_wready_out=>apb_wready,
      axislave_bresp_out=>apb_bresp,
      axislave_bid_out=>apb_bid,
      axislave_bvalid_out=>apb_bvalid,
      axislave_awburst_in=>apb_awburst,
      axislave_awcache_in=>apb_awcache,
      axislave_awid_in=>apb_awid,
      axislave_awlock_in=>apb_awlock,
      axislave_awprot_in=>apb_awprot,
      axislave_awqos_in=>apb_awqos,
      axislave_awsize_in=>apb_awsize,
      axislave_bready_in=>apb_bready,
         
      apb_paddr_out=>APB_PADDR,
      apb_penable_out=>APB_PENABLE,
      apb_pready_in=>APB_PREADY,
      apb_pwrite_out=>APB_PWRITE,
      apb_pwdata_out=>APB_PWDATA,
      apb_prdata_in=>APB_PRDATA,
      apb_pslverror_in=>APB_PSLVERROR
   );

axi_stream_write_inst : axi_stream_write
   GENERIC MAP (
      WRITE_BUF_DEPTH=>2,
      WRITE_STREAM_DEPTH=>10,
      WRITE_PAGE_SIZE=>921600,
      WRITE_MAX_PENDING=>32
   )
   PORT MAP (
      clock_in=>clk_main,
      reset_in=>'1',

      ddr_awaddr_out=>vdma_awaddr,
      ddr_awlen_out=>vdma_awlen,
      ddr_awvalid_out=>vdma_awvalid,
      ddr_wvalid_out=>vdma_wvalid,
      ddr_wdata_out=>vdma_wdata,
      ddr_wlast_out=>vdma_wlast,
      ddr_wstrb_out=>vdma_wstrb,
      ddr_awready_in=>vdma_awready,
      ddr_wready_in=>vdma_wready,
      ddr_bresp_in=>vdma_bresp,
      ddr_bvalid_in=>vdma_bvalid,
      ddr_bid_in=>(others=>'0'),
      ddr_awburst_out=>vdma_awburst,
      ddr_awcache_out=>vdma_awcache,
      ddr_awid_out=>vdma_awid,
      ddr_awlock_out=>vdma_awlock,
      ddr_awprot_out=>vdma_awprot,
      ddr_awqos_out=>vdma_awqos,
      ddr_awsize_out=>vdma_awsize,
      ddr_bready_out=>vdma_bready,

      s_wclk_in=>camera_clk,
      s_wdata_in=>camera_tdata,
      s_wready_out=>camera_tready,
      s_wvalid_in=>camera_tvalid,
      s_wlast_in=>camera_tlast,

      apb_paddr=>APB_PADDR,
      apb_penable=>APB_PENABLE,
      apb_pready=>APB_PREADY,
      apb_pwrite=>APB_PWRITE,
      apb_pwdata=>APB_PWDATA,
      apb_prdata=>APB_PRDATA,
      apb_pslverror=>APB_PSLVERROR,

      ready_out=>open
   );
   
axi_stream_read_inst : axi_stream_read 
   GENERIC MAP (
      READ_BUF_DEPTH=>2,
      READ_STREAM_DEPTH=>10,
      READ_PAGE_SIZE=>921600,
      READ_MAX_PENDING=>128
   )
   PORT MAP (    
      clock_in=>clk_main,
      reset_in=>'1',

      ddr_araddr_out=>rvdma_araddr,
      ddr_arlen_out=>rvdma_arlen,
      ddr_arvalid_out=>rvdma_arvalid,
      ddr_arid_out=>rvdma_arid,
      ddr_arlock_out=>rvdma_arlock,
      ddr_arcache_out=>rvdma_arcache,
      ddr_arprot_out=>rvdma_arprot,
      ddr_arqos_out=>rvdma_arqos,
      ddr_rid_in=>rvdma_rid,
      ddr_rvalid_in=>rvdma_rvalid,
      ddr_rlast_in=>rvdma_rlast,
      ddr_rdata_in=>rvdma_rdata,
      ddr_rresp_in=>rvdma_rresp,
      ddr_arready_in=>rvdma_arready,
      ddr_rready_out=>rvdma_rready,
      ddr_arburst_out=>rvdma_arburst,
      ddr_arsize_out=>rvdma_arsize,
                           
      s_rclk_in=>VIDEO_clk,
      s_rdata_out=>VIDEO_tdata,
      s_rready_in=>VIDEO_tready,
      s_rvalid_out=>VIDEO_tvalid,
      s_rlast_out=>VIDEO_tlast,

      apb_paddr=>APB_PADDR,
      apb_penable=>APB_PENABLE,
      apb_pready=>APB_PREADY,
      apb_pwrite=>APB_PWRITE,
      apb_pwdata=>APB_PWDATA,
      apb_prdata=>APB_PRDATA,
      apb_pslverror=>APB_PSLVERROR
   );

   -------------
   -- GPIO
   -------------
                 
   gpio_inst : gpio
      PORT MAP(
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

   -------------------------
   -- ztachip
   -------------------------
   
   ZTA_DATA_arlen(ZTA_DATA_arlen'length-1 downto arlen'length) <= (others=>'0');
   ZTA_DATA_arlen(arlen'length-1 downto 0) <= std_logic_vector(arlen);
   
   ZTA_DATA_awlen(ZTA_DATA_awlen'length-1 downto awlen'length) <= (others=>'0');
   ZTA_DATA_awlen(awlen'length-1 downto 0) <= std_logic_vector(awlen);
   
   ztachip_inst : ztachip 
      PORT MAP ( 

         -- clk_main is the main clock for ztachip and riscv

         clock_in=>clk_main,

         -- clk_x2_main has to be exactly double of clk_main with edges aligned.
         -- x2 clock is used to achieve 2 read port RAM block by doubling the 
         -- clock of RAM block.

         clock_x2_in=>clk_x2_main,

         -- For FPGA, we dont need reset since all register reset values
         -- are initialized by signal declaration.
         -- With FPGA, the initial register values are set during image
         -- download, so reset signal is not really required.
         -- However, with ASIC, we should have a reset (active low)

         reset_in=>'1', 

         -- Read bus from DDR memory.
         -- All tensor memory transfer from DDR memory to internal
         -- memory are via this bus

         axi_araddr_out=>ZTA_DATA_araddr,
         axi_arlen_out=>arlen,
         axi_arvalid_out=>ZTA_DATA_arvalid,
         axi_rvalid_in=>ZTA_DATA_rvalid,
         axi_rlast_in=>ZTA_DATA_rlast,
         axi_rdata_in=>ZTA_DATA_rdata,
         axi_arready_in=>ZTA_DATA_arready,
         axi_rready_out=>ZTA_DATA_rready,    
         axi_arburst_out=>ZTA_DATA_arburst,
         axi_arcache_out=>ZTA_DATA_arcache, -- Not used. Can be ignored
         axi_arid_out=>ZTA_DATA_arid,       -- Not used. Can be ignored
         axi_arlock_out=>ZTA_DATA_arlock,   -- Not used. Can be ignored
         axi_arprot_out=>ZTA_DATA_arprot,   -- Not used. Can be ignored
         axi_arqos_out=>ZTA_DATA_arqos,     -- Not used. Can be ignored
         axi_arsize_out=>ZTA_DATA_arsize,

         -- Write bus to DDR memory
         -- All tensor memory transfer from internal memory to DDR memory
         -- are via this bus
            
         axi_awaddr_out=>ZTA_DATA_awaddr,
         axi_awlen_out=>awlen,
         axi_awvalid_out=>ZTA_DATA_awvalid,
         axi_waddr_out=>open,
         axi_wvalid_out=>ZTA_DATA_wvalid,
         axi_wlast_out=>ZTA_DATA_wlast,
         axi_wdata_out=>ZTA_DATA_wdata,
         axi_wbe_out=>ZTA_DATA_wstrb,
         axi_awready_in=>ZTA_DATA_awready,
         axi_wready_in=>ZTA_DATA_wready,
         axi_bresp_in=>ZTA_DATA_bvalid,       
         axi_awburst_out=>ZTA_DATA_awburst,
         axi_awcache_out=>ZTA_DATA_awcache, -- Not used. Can be ignored
         axi_awid_out=>ZTA_DATA_awid,       -- Not used. Can be ignored
         axi_awlock_out=>ZTA_DATA_awlock,   -- Not used. Can be ignored
         axi_awprot_out=>ZTA_DATA_awprot,   -- Not used. Can be ignored
         axi_awqos_out=>ZTA_DATA_awqos,     -- Not used. Can be ignored
         axi_awsize_out=>ZTA_DATA_awsize,
         axi_bready_out=>ZTA_DATA_bready,

         -- RISCV is communicating with ztachip via the bus below
         -- Tensor instructions are pushed from RISCV to ztachip's tensor
         -- processor via this bus.

         axilite_araddr_in=>ZTA_CONTROL_araddr(io_depth_c-1 downto 0),
         axilite_arvalid_in=>ZTA_CONTROL_arvalid,
         axilite_arready_out=>ZTA_CONTROL_arready,
         axilite_rvalid_out=>ZTA_CONTROL_rvalid,
         axilite_rlast_out=>open,
         axilite_rdata_out=>ZTA_CONTROL_rdata,
         axilite_rready_in=>ZTA_CONTROL_rready,
         axilite_rresp_out=>ZTA_CONTROL_rresp,
         axilite_awaddr_in=>ZTA_CONTROL_awaddr(io_depth_c-1 downto 0),
         axilite_awvalid_in=>ZTA_CONTROL_awvalid,
         axilite_wvalid_in=>ZTA_CONTROL_wvalid,
         axilite_wdata_in=>ZTA_CONTROL_wdata,
         axilite_awready_out=>ZTA_CONTROL_awready,
         axilite_wready_out=>ZTA_CONTROL_wready,
         axilite_bvalid_out=>ZTA_CONTROL_bvalid,
         axilite_bready_in=>ZTA_CONTROL_bready,
         axilite_bresp_out=>ZTA_CONTROL_bresp
   );

end rtl;
