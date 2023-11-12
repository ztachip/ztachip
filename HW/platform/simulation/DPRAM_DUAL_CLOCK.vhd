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
----------
-- This module implements simple dual-port ram for simulation
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY DPRAM_DUAL_CLOCK IS
   GENERIC (
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT (
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        clock_a   : IN STD_LOGIC;
        clock_b   : IN STD_LOGIC;
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END DPRAM_DUAL_CLOCK;

architecture dpram_dual_port_behaviour of DPRAM_DUAL_CLOCK is

TYPE mem IS ARRAY(0 TO numwords_a-1) OF std_logic_vector(width_a-1 DOWNTO 0);
SIGNAL ram_block : mem;
SIGNAL address_r :STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);

begin

q_b <= ram_block(to_integer(unsigned(address_r)));

process(clock_a)
begin
   if clock_a'event and clock_a='1' then
      if wren_a='1' then
         ram_block(to_integer(unsigned(address_a))) <= data_a;
      end if;
   end if;
end process;

process(clock_b)
begin
   if clock_b'event and clock_b='1' then
      address_r <= address_b;
   end if;
end process;


end dpram_dual_port_behaviour;
