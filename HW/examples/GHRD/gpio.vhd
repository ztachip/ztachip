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
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

 entity gpio is
    PORT (
       signal clk_in      : in  std_logic;
       signal paddr_in    : in  std_logic_vector(8 downto 0);
       signal penable_in  : in  std_logic;
       signal prdata_out  : out std_logic_vector(31 downto 0);
       signal pready_out  : out std_logic_vector(0 downto 0);
       signal psel_in     : in  std_logic_vector(0 downto 0);
       signal pslverr_out : out std_logic_vector(0 downto 0);
       signal pwdata_in   : in  std_logic_vector(31 downto 0);
       signal pwrite_in   : in  std_logic; 

       signal led_out     : out std_Logic_vector(3 downto 0);
       signal button_in   : in std_logic_vector(3 downto 0)       
    );
 end gpio;
  
architecture Behavioral of gpio is  
signal led_r:std_logic_vector(3 downto 0);
signal button_r:std_logic_vector(3 downto 0);
signal button_rr:std_logic_vector(3 downto 0);
begin

prdata_out(button_rr'length-1 downto 0) <= button_rr;

prdata_out(31 downto button_rr'length) <= (others=>'0');

led_out<=led_r;

pslverr_out <= "0";

pready_out <= "0" when (penable_in='0') else "1";

process(clk_in)
begin
  if rising_edge(clk_in) then
     if (pwrite_in='1' and psel_in="1" and penable_in='1') then
        -- Update led state
        led_r <= pwdata_in(led_r'length-1 downto 0);
     end if;
     
     -- Latch in button value
     button_rr <= button_r;
     button_r <= button_in;
  end if;  
end process;

end Behavioral;
