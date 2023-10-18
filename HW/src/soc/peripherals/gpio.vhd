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

 entity gpio is
    PORT (
       signal clock_in              : IN STD_LOGIC;
       signal reset_in              : IN STD_LOGIC;

       signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
       signal apb_penable           : IN STD_LOGIC;
       signal apb_pready            : OUT STD_LOGIC;
       signal apb_pwrite            : IN STD_LOGIC;
       signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
       signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
       signal apb_pslverror         : OUT STD_LOGIC;

       signal led_out               : out std_Logic_vector(3 downto 0);
       signal button_in             : in std_logic_vector(3 downto 0)       
    );
 end gpio;
  
architecture Behavioral of gpio is  
signal led_r:std_logic_vector(3 downto 0);
signal button_r:std_logic_vector(3 downto 0);
signal button_rr:std_logic_vector(3 downto 0);
signal apb_led_match:std_logic;
signal apb_pb_match:std_logic;
signal apb_match:std_logic;
begin

led_out<=led_r;

apb_led_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_led_c,apb_addr_len_c)))
                          else '0';

apb_pb_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_pb_c,apb_addr_len_c)))
                          else '0';
                          
apb_match <= apb_led_match or apb_pb_match;

apb_pready <= '1' when (apb_match='1' and apb_penable='1') else 'Z';

apb_prdata(apb_prdata'length-1 downto button_rr'length) <= (others=>'0') 
                                                           when (apb_pb_match='1' and apb_penable='1' and apb_pwrite='0') 
                                                           else 
                                                           (others=>'Z');

apb_prdata(button_rr'length-1 downto 0) <= button_rr
                                           when (apb_pb_match='1' and apb_penable='1' and apb_pwrite='0') 
                                           else 
                                           (others=>'Z');

apb_pslverror <= '0' when (apb_match='1' and apb_penable='1') else 'Z';


process(clock_in)
begin
   if reset_in = '0' then
      led_r <= (others=>'0');
      button_r <= (others=>'0');
      button_rr <= (others=>'0');
   else
      if rising_edge(clock_in) then     
         -- Latch in button value
        button_rr <= button_r;
        button_r <= button_in;
        if(apb_pwrite='1' and apb_penable='1' and apb_led_match='1') then
           led_r <= apb_pwdata(led_r'length-1 downto 0);
        end if;
      end if;
   end if;  
end process;

end Behavioral;
