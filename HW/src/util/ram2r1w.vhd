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
--
-- This module implements memory block with 2 read port and 1 write port
-- This is implemented by doubling the clock of a dual-port RAM
--
--
--                 clock          clock_x2
--                   |             |                clock
--                   V             V                  |
--                 +---+    +--------------+          V 1
-- read_addr1 ---->|0  |    |              |      +-------+
--                 |Mux|--->|              |--+---| Latch |--->read_data1
-- read_addr2 ---->|1  |    |              |  |   +-------+
--                 +---+    |   Dual-Port  |  +--------------->read_data2
--                          |    RAM       |
-- (wren and (not clock))-->|              |
--                          |              |
-- write_addr ------------->|              |
-- write_data ------------->|              |
--                          +--------------+
--
------------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY ram2r1w IS
   GENERIC (
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT (
        clock      : IN STD_LOGIC;
        clock_x2   : IN STD_LOGIC;
        address_a  : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        byteena_a  : IN STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
        data_a     : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        wren_a     : IN STD_LOGIC;
        address1_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
        q1_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        address2_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
        q2_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0)
    );
END ram2r1w;

architecture ram2r1w_behaviour of ram2r1w is
SIGNAL wren:STD_LOGIC;
SIGNAL address2_r:STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
SIGNAL address:STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
SIGNAL q_b:STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
SIGNAL q_latch:STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
SIGNAL address_a_r:STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
SIGNAL byteena_a_r:STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
SIGNAL data_a_r:STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
SIGNAL wren_a_r:STD_LOGIC:='0';     
begin

q1_b <= q_latch;
q2_b <= q_b;
wren <= wren_a_r and (clock);
address <= address1_b when clock='0' else address2_r;

process(clock)
BEGIN
   if clock'event and clock='1' then
      address2_r <= address2_b;
      address_a_r <= address_a;
      byteena_a_r <= byteena_a;
      data_a_r <= data_a;
      wren_a_r <= wren_a;
   end if;
end process;

process(clock,q_b)
begin
if clock='1' then
   q_latch <= q_b;
end if;

end process;

ram2_i : DPRAM_BE
    GENERIC MAP (
        numwords_a=>numwords_a,
        numwords_b=>numwords_b,
        widthad_a=>widthad_a,
        widthad_b=>widthad_b,
        width_a=>width_a,
        width_b=>width_b
    )
    PORT MAP (
        address_a => address_a_r,
        byteena_a => byteena_a_r,
        clock0 => clock_x2,
        data_a => data_a_r,
        wren_a => wren,
        address_b => address,
        q_b => q_b
    );

end ram2r1w_behaviour;
