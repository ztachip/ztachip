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
use work.config.all;
use work.ztachip_pkg.all;

 entity TIME is
   PORT (
      signal clock_in              : IN STD_LOGIC;
      signal reset_in              : IN STD_LOGIC;

      signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
      signal apb_penable           : IN STD_LOGIC;
      signal apb_pready            : OUT STD_LOGIC;
      signal apb_pwrite            : IN STD_LOGIC;
      signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
      signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
      signal apb_pslverror         : OUT STD_LOGIC   
   );
 end TIME;
  
architecture Behavioral of TIME is  
constant clock_divider_c:integer:=main_clock_c/1000;
signal match:std_logic;
signal time_r:unsigned(31 downto 0);
signal usec_r: integer range 0 to clock_divider_c-1;
begin

match <= apb_penable when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_time_get_c,apb_addr_len_c))) else '0';

apb_pready <= '1' when (match='1') else 'Z';

apb_prdata <= std_logic_vector(time_r) when (match='1') else (others=>'Z');

apb_pslverror <= '0' when (match='1') else 'Z';


process(clock_in)
begin
   if reset_in = '0' then
      time_r <= (others=>'0');
      usec_r <= 0;
   else
      if rising_edge(clock_in) then
         if(usec_r=(clock_divider_c-1)) then
            usec_r <= 0;
         else
            usec_r <= usec_r+1;
         end if;   
         if(usec_r=0) then
            time_r <= time_r+1;
         end if;
      end if;
   end if;  
end process;

end Behavioral;
