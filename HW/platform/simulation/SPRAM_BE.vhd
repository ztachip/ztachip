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
-- This module implements single-port ram with byte-enable for simulation
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY SPRAM_BE IS
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
       byteena_a   : IN STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
       q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
    );
END SPRAM_BE;

architecture rtl of SPRAM_BE is

type word_t is array (0 to width_a/8-1) of std_logic_vector(7 downto 0);
TYPE memory_t IS ARRAY(0 TO numwords_a-1) OF word_t;
SIGNAL ram_block : memory_t;
SIGNAL q:word_t;
SIGNAL data:word_t;
SIGNAL address_r:STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);

begin

assert width_a <= 128 report "SPRAM_BE generation error" severity note;

q <= ram_block(to_integer(unsigned(address_r)));
unpack: for I in 0 to width_a/8 - 1 generate    
   q_a(I*8+7 downto I*8) <= q(I);
end generate unpack;

pack: for I in 0 to width_a/8 - 1 generate    
   data(I) <= data_a(I*8+7 downto I*8);
end generate pack; 
   
process(clock0)
begin
   if clock0'event and clock0='1' then
      if wren_a='1' then
         FOR I in 0 to width_a/8-1 loop
            if byteena_a(I)='1' then
               ram_block(to_integer(unsigned(address_a)))(I) <= data(I);
            end if;
         end loop;
      end if;
      address_r <= address_a;
   end if;
end process;

end rtl;
