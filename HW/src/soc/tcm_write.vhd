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
-- This module implements TCM (Tighly coupling memory)
-- It serves as L2 cache for RISCV
----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE std.textio.all;
USE ieee.std_logic_textio.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity TCM_write is
   generic(
      RAM_DEPTH:integer
   );
   port(   
      TCM_clk       :IN STD_LOGIC;
      TCM_reset     :IN STD_LOGIC;

      TCM_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_awready   :OUT STD_LOGIC;
      TCM_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_awvalid   :IN STD_LOGIC;
      TCM_bready    :IN STD_LOGIC;
      TCM_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_bvalid    :OUT STD_LOGIC;
      TCM_wdata     :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_wlast     :IN STD_LOGIC;
      TCM_wready    :OUT STD_LOGIC;
      TCM_wstrb     :IN STD_LOGIC_VECTOR(3 downto 0);
      TCM_wvalid    :IN STD_LOGIC;

      ram_waddr     :OUT std_logic_vector(RAM_DEPTH-3 downto 0);
      ram_wdata     :OUT std_logic_vector(31 downto 0);
      ram_wren      :OUT std_logic;
      ram_be        :OUT std_logic_vector(3 downto 0)
   );
end TCM_write;

---
-- This top level component for simulatio
---

architecture rtl of TCM_write is

signal write_addr_r:unsigned(31 downto 0);
signal write_len_r:unsigned(7 downto 0);
signal write_size_r:std_logic_vector(2 downto 0);
signal write_busy_r:std_logic;
signal wready:std_logic;

begin

wready <= write_busy_r and TCM_bready;

TCM_awready <= '1' when (write_busy_r='0') or 
                     (write_busy_r='1' and wready='1' and TCM_wvalid='1' and 
                     write_len_r=to_unsigned(0,write_len_r'length))
                     else '0';

TCM_wready <= wready;

TCM_bvalid <= '1' when (wready='1' and TCM_wvalid='1' and write_len_r=to_unsigned(0,write_len_r'length)) else '0';

TCM_bresp <= (others=>'0');

ram_waddr <= std_logic_vector(write_addr_r(ram_waddr'length+1 downto 2));

ram_wdata <= TCM_wdata;

ram_be <= TCM_wstrb;

ram_wren <= write_busy_r and wready and TCM_wvalid;

process(TCM_clk,TCM_reset)
begin
if TCM_reset = '0' then
   write_addr_r <= (others=>'0');
   write_len_r <= (others=>'0');
   write_size_r <= (others=>'0');
   write_busy_r <= '0';
else
   if TCM_clk'event and TCM_clk='1' then
      if(write_busy_r='1') then
         if(wready='1' and TCM_wvalid='1') then
            if(write_len_r=to_unsigned(0,write_len_r'length)) then
               write_addr_r <= unsigned(TCM_awaddr);
               write_len_r <= unsigned(TCM_awlen);
               write_size_r <= TCM_awsize;
               write_busy_r <= TCM_awvalid;
            else
               write_addr_r <= write_addr_r+to_unsigned(4,write_addr_r'length);
               write_len_r <= write_len_r-to_unsigned(1,write_len_r'length);
            end if;
         end if;
      else
         write_addr_r <= unsigned(TCM_awaddr);
         write_len_r <= unsigned(TCM_awlen);
         write_size_r <= TCM_awsize;
         write_busy_r <= TCM_awvalid;
      end if;
   end if;
end if;

end process;

end rtl;
