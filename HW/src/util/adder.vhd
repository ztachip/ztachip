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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
   generic
   (
      DATA_WIDTH : natural
   );
   port 
   (
      x_in       : in std_logic_vector((DATA_WIDTH-1) downto 0);
      y_in       : in std_logic_vector((DATA_WIDTH-1) downto 0);
      add_sub_in : in std_logic;
      z_out      : out std_logic_vector((DATA_WIDTH-1) downto 0)
   );
end entity;

architecture rtl of adder is

signal x:signed(DATA_WIDTH-1 downto 0);
signal y:signed(DATA_WIDTH-1 downto 0);
signal z:signed(DATA_WIDTH-1 downto 0);

begin

x <= signed(x_in);
y <= signed(y_in);
z_out <= std_logic_vector(z);

process(x,y,add_sub_in)
begin
   -- Add if "add_sub" is 1, else subtract
   if (add_sub_in = '1') then
      z <= x + y;
   else
      z <= x - y;
   end if;
end process;

end rtl;