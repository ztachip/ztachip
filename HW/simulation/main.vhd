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
------------------------------------------------------------------------------


----------------------------------------------------------------------------
--                  TOP COMPONENT DECLARATION
----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE std.textio.all;
USE ieee.std_logic_textio.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

entity main is
   port(   
      signal reset_in:in std_logic;
      signal clk_main:in std_logic;
      signal clk_x2_main:in std_logic;
      signal led_out:out std_logic_vector(3 downto 0)
   );
end main;

---
-- This top level component for simulatio
---

architecture rtl of main is

signal SDRAM_araddr:std_logic_vector(31 downto 0);
signal SDRAM_arburst:std_logic_vector(1 downto 0);
signal SDRAM_arlen:std_logic_vector(7 downto 0);
signal SDRAM_arready:std_logic;
signal SDRAM_arsize:std_logic_vector(2 downto 0);
signal SDRAM_arvalid:std_logic;
signal SDRAM_awaddr:std_logic_vector(31 downto 0);
signal SDRAM_awburst:std_logic_vector(1 downto 0);
signal SDRAM_awlen:std_logic_vector(7 downto 0);
signal SDRAM_awready:std_logic;
signal SDRAM_awsize:std_logic_vector(2 downto 0);
signal SDRAM_awvalid:std_logic;
signal SDRAM_bready:std_logic;
signal SDRAM_bresp:std_logic_vector(1 downto 0);
signal SDRAM_bvalid:std_logic;
signal SDRAM_rdata:std_logic_vector(exmem_data_width_c-1 downto 0);
signal SDRAM_rlast:std_logic;
signal SDRAM_rready:std_logic;
signal SDRAM_rresp:std_logic_vector(1 downto 0);
signal SDRAM_rvalid:std_logic;
signal SDRAM_wdata:std_logic_vector(exmem_data_width_c-1 downto 0);
signal SDRAM_wlast:std_logic;
signal SDRAM_wready:std_logic;
signal SDRAM_wstrb:std_logic_vector(exmem_data_width_c/8-1 downto 0);
signal SDRAM_wvalid:std_logic;

signal led:std_logic_vector(3 downto 0);
signal VIDEO_tdata:std_logic_vector(31 downto 0);
signal VIDEO_tlast:std_logic;
signal VIDEO_tready:std_logic;
signal VIDEO_tvalid:std_Logic;
signal camera_tdata:std_logic_vector(31 downto 0);
signal camera_tlast:std_logic;
signal camera_tready:std_logic;
signal camera_tuser:std_logic_vector(0 downto 0);
signal camera_tvalid:std_logic;

begin

led_out <= led;
VIDEO_tready <= '0';
camera_tdata <= (others=>'0');
camera_tlast <= '0';
camera_tuser <= (others=>'0');
camera_tvalid <= '0';

soc_base_inst: soc_base 
   GENERIC MAP(
      RISCV=>"RISCV_SIM"
   )
   PORT MAP(

      clk_main=>clk_main,
      clk_x2_main=>clk_x2_main,
      clk_reset=>reset_in,

      led=>led,
      pushbutton=>(others=>'0'),

      UART_TXD=>open,
      UART_RXD=>'0',

      VIDEO_clk=>clk_main,  
      VIDEO_tdata=>VIDEO_tdata,
      VIDEO_tready=>VIDEO_tready,
      VIDEO_tvalid=>VIDEO_tvalid,
      VIDEO_tlast=>VIDEO_tlast,

      camera_clk=>clk_main,
      camera_tdata=>camera_tdata,
      camera_tlast=>camera_tlast,
      camera_tready=>camera_tready,
      camera_tvalid=>camera_tvalid,

      SDRAM_clk=>clk_main,
      SDRAM_reset=>reset_in,
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
      SDRAM_wvalid=>SDRAM_wvalid
   );

GEN1:IF exmem_data_width_c=32 GENERATE
mem32_inst:mem32
   port map(   
      SDRAM_clk=>clk_main,
      SDRAM_reset=>reset_in,
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
      SDRAM_wvalid=>SDRAM_wvalid
   );
END GENERATE GEN1;

GEN2:IF exmem_data_width_c=64 GENERATE
mem64_inst:mem64
   port map(   
      SDRAM_clk=>clk_main,
      SDRAM_reset=>reset_in,
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
      SDRAM_wvalid=>SDRAM_wvalid
   );
END GENERATE GEN2;

end rtl;
