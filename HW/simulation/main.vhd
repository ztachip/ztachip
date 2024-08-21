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
      signal clk:in std_logic;
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
signal clk_x2_main:std_logic;
signal clk_main:std_logic;
signal clk_r:std_logic:='0';
signal reset_r:std_logic_vector(3 downto 0):=(others=>'0');
signal reset:std_logic;
begin

--Generate clocks

clk_x2_main <= clk;
clk_main <= clk_r;
reset <= reset_r(reset_r'length-1);

process(clk)
begin
   if clk'event and clk='1' then
      clk_r <= not clk_r;
   end if;
end process;

process(clk_main)
begin
   if clk_main'event and clk_main='1' then
      if(reset_r(reset_r'length-1)='0') then
          reset_r <= std_logic_vector(unsigned(reset_r)+1);
      end if;
   end if;
end process;

soc_base_inst: soc_base 
   PORT MAP(
      clk_main=>clk_main,
      clk_x2_main=>clk_x2_main,
      clk_camera=>'0',
      clk_vga=>'0',
      clk_reset=>reset,

      SDRAM_clk=>clk_main,
      SDRAM_reset=>reset,
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

      APB_PADDR=>open,
      APB_PENABLE=>open,
      APB_PREADY=>open,
      APB_PWRITE=>open,
      APB_PWDATA=>open,
      APB_PRDATA=>open,
      APB_PSLVERROR=>open,

      led=>led_out,
      pushbutton=>(others=>'0'),
   
      UART_TXD=>open,
      UART_RXD=>'0',

      VGA_HS_O=>open,
      VGA_VS_O=>open,
      VGA_R=>open,
      VGA_B=>open,
      VGA_G=>open,

      CAMERA_SCL=>open,
      CAMERA_VS=>'0',
      CAMERA_PCLK=>'0',
      CAMERA_D=>(others=>'0'),
      CAMERA_RESET=>open,
      CAMERA_SDR=>open,
      CAMERA_RS=>'0',
      CAMERA_MCLK=>open,
      CAMERA_PWDN=>open
   );

mem64_inst:mem64
   port map(   
      SDRAM_clk=>clk_main,
      SDRAM_reset=>reset,
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



end rtl;
