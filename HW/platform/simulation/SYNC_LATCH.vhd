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

entity SYNC_LATCH is
   generic
   (
      DATA_WIDTH : natural
   );
   port 
   (
      enable_in : IN STD_LOGIC;
      data_in   : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
      data_out  : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
   );
end SYNC_LATCH;

architecture rtl of SYNC_LATCH is
signal data_r:STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
begin

data_out <= data_r;

process(enable_in,data_in)
begin
   if(enable_in='1') then
      data_r <= data_in;
   end if;
end process;

end rtl;