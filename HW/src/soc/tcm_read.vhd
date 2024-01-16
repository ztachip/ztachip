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

entity TCM_read is
   generic(
      RAM_DEPTH:integer
   );
   port(   
      TCM_clk       :IN STD_LOGIC;
      TCM_reset     :IN STD_LOGIC;
      TCM_araddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_arburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_arlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_arready   :OUT STD_LOGIC;
      TCM_arsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_arvalid   :IN STD_LOGIC;
      TCM_rdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
      TCM_rlast     :OUT STD_LOGIC;
      TCM_rready    :IN STD_LOGIC;
      TCM_rresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_rvalid    :OUT STD_LOGIC;

      ram_q         :IN std_logic_vector(31 downto 0);
      ram_raddr     :OUT std_logic_vector(RAM_DEPTH-3 downto 0)
   );
end TCM_read;

---
-- This top level component for simulatio
---

architecture rtl of TCM_read is

signal read_addr_r:unsigned(31 downto 0);
signal read_len_r:unsigned(7 downto 0);
signal read_size_r:std_logic_vector(2 downto 0);
signal read_busy_r:std_logic;
signal rlast:std_logic;
signal rlast_r:std_logic;
signal rvalid:std_logic;
signal rvalid_r:std_logic;
signal rready:std_logic;

begin

rready <= '1' when (rvalid_r='0' or TCM_rready='1') else '0';

TCM_arready <= '1' when read_busy_r='0' or 
                     (read_busy_r='1' and rready='1' and 
                     read_len_r=to_unsigned(0,read_len_r'length))
               else '0';

rlast <= '1' when read_busy_r='1' and read_len_r=to_unsigned(0,read_len_r'length) else '0';

rvalid <= read_busy_r;

TCM_rvalid <= rvalid_r;

TCM_rlast <= rlast_r;

TCM_rresp <= (others=>'0');

TCM_rdata <= ram_q;

ram_raddr <= std_logic_vector(read_addr_r(ram_raddr'length+1 downto 2));

process(TCM_clk,TCM_reset)
begin
if TCM_reset = '0' then
   read_addr_r <= (others=>'0');
   read_len_r <= (others=>'0');
   read_size_r <= (others=>'0');
   read_busy_r <= '0';
   rvalid_r <= '0';
   rlast_r <= '0';
else
   if TCM_clk'event and TCM_clk='1' then
      if(rvalid_r='0' or (rvalid_r='1' and TCM_rready='1')) then
         rvalid_r <= rvalid;
         rlast_r <= rlast;
      else
         rvalid_r <= not TCM_rready;
      end if;
      if(read_busy_r='1') then
         if(rready='1') then
            if(read_len_r=to_unsigned(0,read_len_r'length)) then
               read_addr_r <= unsigned(TCM_araddr);
               read_len_r <= unsigned(TCM_arlen);
               read_size_r <= TCM_arsize;
               read_busy_r <= TCM_arvalid;
            else
               read_addr_r <= read_addr_r+to_unsigned(4,read_addr_r'length);
               read_len_r <= read_len_r-to_unsigned(1,read_len_r'length);
            end if;
         end if;
      else
         read_addr_r <= unsigned(TCM_araddr);
         read_len_r <= unsigned(TCM_arlen);
         read_size_r <= TCM_arsize;
         read_busy_r <= TCM_arvalid;
      end if;
   end if;
end if;

end process;

end rtl;
