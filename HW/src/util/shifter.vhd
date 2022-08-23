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

entity barrel_shifter_a is
   generic
   (
      DIST_WIDTH : natural;
      DATA_WIDTH : natural
   );
   port 
   (
      direction_in : in std_logic;
      data_in      : in std_logic_vector((DATA_WIDTH-1) downto 0);
      distance_in  : in std_logic_vector((DIST_WIDTH-1) downto 0);
      data_out     : out std_logic_vector((DATA_WIDTH-1) downto 0)
   );
end entity;

architecture rtl of barrel_shifter_a is
signal result:bit_vector((DATA_WIDTH-1) downto 0);
signal data:bit_vector(DATA_WIDTH-1 downto 0);
signal distance:unsigned(DIST_WIDTH-1 downto 0);
begin

data <= To_BitVector(data_in);
distance <= unsigned(distance_in);
result <= (data sra to_integer(distance)) when (direction_in = '1') else (data sla to_integer(distance));
data_out <= To_StdLogicVector(result); 

end rtl;
