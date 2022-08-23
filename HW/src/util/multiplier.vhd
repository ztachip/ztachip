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

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity multiplier is
	generic 
	(
		DATA_WIDTH      : natural;
        REGISTER_OUTPUT : BOOLEAN
	);
	port 
	(
		clock_in   : in std_logic;
        reset_in   : in std_logic;
        x_in       : in std_logic_vector(DATA_WIDTH-1 downto 0);
        y_in       : in std_logic_vector(DATA_WIDTH-1 downto 0);       
        z_out      : out std_logic_vector(2*DATA_WIDTH-1 downto 0)
	);
end multiplier;

architecture rtl of multiplier is
signal x   : signed(DATA_WIDTH-1 downto 0);
signal y   : signed(DATA_WIDTH-1 downto 0);
signal z   : signed(2*DATA_WIDTH-1 downto 0);
signal z_r : signed(2*DATA_WIDTH-1 downto 0);
begin

x <= signed(x_in);
y <= signed(y_in);
z <= x*y;

GEN1: if REGISTER_OUTPUT=TRUE generate
z_out <= std_logic_vector(z_r);
end generate GEN1;

GEN2: if REGISTER_OUTPUT=FALSE generate
z_out <= std_logic_vector(z);
end generate GEN2;

process(clock_in,reset_in)
begin
   if(reset_in='0') then
   else
      if(rising_edge(clock_in)) then 
         z_r <= z;
      end if;
   end if;
end process;

end rtl;