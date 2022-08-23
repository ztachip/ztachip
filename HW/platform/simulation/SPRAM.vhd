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
-- This module implements simple single-port ram for simulation
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY SPRAM IS
   GENERIC (
       numwords_a                      : NATURAL;
       widthad_a                       : NATURAL;
       width_a                         : NATURAL
    );
    PORT (
       address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
       clock0      : IN STD_LOGIC ;
       data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
       wren_a      : IN STD_LOGIC ;
       q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
    );
END SPRAM;

architecture rtl of SPRAM is

subtype word_t is std_logic_vector((width_a-1) downto 0);
type memory_t is array(numwords_a-1 downto 0) of word_t;
signal ram : memory_t;
signal address_r:STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);

begin

   process(clock0)
   begin
      if(rising_edge(clock0)) then
         if(wren_a = '1') then
            ram(to_integer(unsigned(address_a))) <= data_a;
         end if;

         -- Register the address for reading
         address_r <= address_a;
      end if;
   end process;
   q_a <= ram(to_integer(unsigned(address_r)));
end rtl;
