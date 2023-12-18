------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Author: Vuong Nguyen
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Provides cross clock domain bridge for AXI write interface 
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity axi_convert_64to32 is
   port 
   (
   clock_in          :IN STD_LOGIC;
   reset_in          :IN STD_LOGIC;

   -- Input bus in 64-bit
   
   SDRAM64_araddr    :IN STD_LOGIC_VECTOR(31 downto 0);
   SDRAM64_arburst   :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_arlen     :IN STD_LOGIC_VECTOR(7 downto 0);
   SDRAM64_arready   :OUT STD_LOGIC;
   SDRAM64_arsize    :IN STD_LOGIC_VECTOR(2 downto 0);
   SDRAM64_arvalid   :IN STD_LOGIC;
   SDRAM64_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
   SDRAM64_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
   SDRAM64_awready   :OUT STD_LOGIC;
   SDRAM64_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
   SDRAM64_awvalid   :IN STD_LOGIC;
   SDRAM64_bready    :IN STD_LOGIC;
   SDRAM64_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_bvalid    :OUT STD_LOGIC;
   SDRAM64_rdata     :OUT STD_LOGIC_VECTOR(63 downto 0);
   SDRAM64_rdata_mask:IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_rlast     :OUT STD_LOGIC;
   SDRAM64_rready    :IN STD_LOGIC;
   SDRAM64_rresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_rvalid    :OUT STD_LOGIC;
   SDRAM64_wdata     :IN STD_LOGIC_VECTOR(63 downto 0);
   SDRAM64_wdata_mask:IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_wlast     :IN STD_LOGIC;
   SDRAM64_wready    :OUT STD_LOGIC;
   SDRAM64_wstrb     :IN STD_LOGIC_VECTOR(7 downto 0);
   SDRAM64_wvalid    :IN STD_LOGIC;

   -- Output bus in 32-bit

   SDRAM32_araddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_arburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_arlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
   SDRAM32_arready   :IN STD_LOGIC;
   SDRAM32_arsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
   SDRAM32_arvalid   :OUT STD_LOGIC;
   SDRAM32_awaddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_awburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_awlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
   SDRAM32_awready   :IN STD_LOGIC;
   SDRAM32_awsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
   SDRAM32_awvalid   :OUT STD_LOGIC;
   SDRAM32_bready    :OUT STD_LOGIC;
   SDRAM32_bresp     :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_bvalid    :IN STD_LOGIC;
   SDRAM32_rdata     :IN STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_rlast     :IN STD_LOGIC;
   SDRAM32_rready    :OUT STD_LOGIC;
   SDRAM32_rresp     :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_rvalid    :IN STD_LOGIC;
   SDRAM32_wdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_wlast     :OUT STD_LOGIC;
   SDRAM32_wready    :IN STD_LOGIC;
   SDRAM32_wstrb     :OUT STD_LOGIC_VECTOR(3 downto 0);
   SDRAM32_wvalid    :OUT STD_LOGIC
   );
end axi_convert_64to32;

architecture rtl of axi_convert_64to32 is

signal read_hold_r:std_logic;

signal rdata_r:std_logic_vector(31 downto 0);

signal wdata_in_progress_r:std_logic;

signal wdata_in_progress:std_logic;

begin

SDRAM32_araddr <= SDRAM64_araddr;
SDRAM32_arburst <= SDRAM64_arburst;
--SDRAM32_arlen <= SDRAM64_arlen;
SDRAM64_arready <=  SDRAM32_arready;
--SDRAM32_arsize <= SDRAM64_arsize;
SDRAM32_arvalid <= SDRAM64_arvalid;
SDRAM32_awaddr <= SDRAM64_awaddr;
SDRAM32_awburst <= SDRAM64_awburst;
--SDRAM32_awlen <= SDRAM64_awlen;
SDRAM64_awready <= SDRAM32_awready;
--SDRAM32_awsize <= SDRAM64_awsize;
SDRAM32_awvalid <= SDRAM64_awvalid;
SDRAM32_bready <= SDRAM64_bready;
SDRAM64_bresp <= SDRAM32_bresp;
SDRAM64_bvalid <= SDRAM32_bvalid;
--SDRAM64_rdata <= SDRAM32_rdata;
--SDRAM64_rlast <= SDRAM32_rlast;
SDRAM32_rready <= SDRAM64_rready;
SDRAM64_rresp <=  SDRAM32_rresp;
--SDRAM64_rvalid <= SDRAM32_rvalid;
--SDRAM32_wdata <= SDRAM64_wdata;
--SDRAM32_wlast <= SDRAM64_wlast;
--SDRAM64_wready <= SDRAM32_wready;
--SDRAM32_wstrb <= SDRAM64_wstrb;
SDRAM32_wvalid <= SDRAM64_wvalid;

-- Convert 64-bit read AXI to 32-bit AXI
SDRAM32_arlen <= SDRAM64_arlen when SDRAM64_arsize="010" else (SDRAM64_arlen(6 downto 0) & '1');
SDRAM32_arsize <= "010";

process(SDRAM64_rdata_mask,read_hold_r,SDRAM32_rlast,rdata_r,SDRAM32_rvalid,SDRAM32_rdata)
begin
if(SDRAM64_rdata_mask="11") then
   if(read_hold_r='0') then
      SDRAM64_rlast <= '0';
      SDRAM64_rdata <= (others=>'0');
      SDRAM64_rvalid <= '0';
   else
      SDRAM64_rlast <= SDRAM32_rlast;
      SDRAM64_rdata <= SDRAM32_rdata & rdata_r;
      SDRAM64_rvalid <= SDRAM32_rvalid;
   end if;
else 
   SDRAM64_rlast <= SDRAM32_rlast;
   SDRAM64_rdata <= SDRAM32_rdata & SDRAM32_rdata;
   SDRAM64_rvalid <= SDRAM32_rvalid;
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in = '0' then
   read_hold_r <= '0';
   rdata_r <= (others=>'0');
else
   if clock_in'event and clock_in='1' then
      if(SDRAM64_rdata_mask="11" and SDRAM32_rvalid='1' and SDRAM64_rready='1') then
         read_hold_r <= not read_hold_r;
         rdata_r <= SDRAM32_rdata;
      end if; 
   end if;
end if;
end process;

-- Convert 64-bit write to 32-bit write AXI

SDRAM32_awlen <= SDRAM64_awlen when SDRAM64_awsize="010" else (SDRAM64_awlen(6 downto 0) & '1');
SDRAM32_awsize <= "010";

process(SDRAM64_awlen,SDRAM64_wlast,SDRAM64_awsize,SDRAM64_wdata_mask,
        wdata_in_progress_r,SDRAM32_wready,SDRAM64_wvalid,SDRAM64_wstrb,SDRAM64_wdata)
begin
if(SDRAM64_wdata_mask="11") then
   if(wdata_in_progress_r='0') then
      SDRAM64_wready <= '0';
      SDRAM32_wlast <= '0';
      SDRAM32_wdata <= SDRAM64_wdata(31 downto 0);
      SDRAM32_wstrb <= SDRAM64_wstrb(3 downto 0);
      wdata_in_progress <= (SDRAM64_wvalid and SDRAM32_wready);
   else
      SDRAM64_wready <= SDRAM32_wready;
      SDRAM32_wlast <= SDRAM64_wlast;
      SDRAM32_wdata <= SDRAM64_wdata(63 downto 32);
      SDRAM32_wstrb <= SDRAM64_wstrb(7 downto 4);
      wdata_in_progress <= not(SDRAM64_wvalid and SDRAM32_wready);
   end if;
else
   if(SDRAM64_wdata_mask="01") then
      SDRAM32_wdata <= SDRAM64_wdata(31 downto 0);
      SDRAM32_wstrb <= SDRAM64_wstrb(3 downto 0);
   else
      SDRAM32_wdata <= SDRAM64_wdata(63 downto 32);
      SDRAM32_wstrb <= SDRAM64_wstrb(7 downto 4);
   end if;
   SDRAM64_wready <= SDRAM32_wready;
   SDRAM32_wlast <= SDRAM64_wlast;
   wdata_in_progress <= '0';
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in = '0' then
   wdata_in_progress_r <= '0';
else
   if clock_in'event and clock_in='1' then
      wdata_in_progress_r <=wdata_in_progress;
   end if;
end if;
end process;

end rtl;
