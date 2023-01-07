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
       signal clock_in              : IN STD_LOGIC;
       signal reset_in              : IN STD_LOGIC;
        
       signal axilite_araddr_in     : IN std_logic_vector(31 downto 0);
       signal axilite_arvalid_in    : IN std_logic;
       signal axilite_arready_out   : OUT std_logic;
       signal axilite_rvalid_out    : OUT std_logic;
       signal axilite_rlast_out     : OUT std_logic;
       signal axilite_rdata_out     : OUT std_logic_vector(31 downto 0);
       signal axilite_rready_in     : IN std_logic; 
       signal axilite_rresp_out     : OUT std_logic_vector(1 downto 0);

       signal axilite_awaddr_in     : IN std_logic_vector(31 downto 0);
       signal axilite_awvalid_in    : IN std_logic;
       signal axilite_wvalid_in     : IN std_logic;
       signal axilite_wdata_in      : IN std_logic_vector(31 downto 0);
       signal axilite_awready_out   : OUT std_logic;
       signal axilite_wready_out    : OUT std_logic;
       signal axilite_bvalid_out    : OUT std_logic;
       signal axilite_bready_in     : IN std_logic;
       signal axilite_bresp_out     : OUT std_logic_vector(1 downto 0);

       signal led_out               : out std_Logic_vector(3 downto 0);
       signal button_in             : in std_logic_vector(3 downto 0)       
    );
 end gpio;
  
architecture Behavioral of gpio is  
signal led_r:std_logic_vector(3 downto 0);
signal button_r:std_logic_vector(3 downto 0);
signal button_rr:std_logic_vector(3 downto 0);
signal rvalid_r:std_logic;
signal bvalid_r:std_logic;
begin

led_out<=led_r;

axilite_arready_out <= not rvalid_r;

axilite_rvalid_out <= rvalid_r;

axilite_rlast_out <= rvalid_r;

axilite_rdata_out(axilite_rdata_out'length-1 downto button_rr'length) <= (others=>'0');

axilite_rdata_out(button_rr'length-1 downto 0) <= button_rr;

axilite_rresp_out <= (others=>'0');

axilite_awready_out <= '1';

axilite_wready_out <= '1';

axilite_bvalid_out <= bvalid_r;

axilite_rresp_out <= (others=>'0');

axilite_bresp_out <= (others=>'0');

process(clock_in)
begin
   if reset_in = '0' then
      led_r <= (others=>'0');
      button_r <= (others=>'0');
      button_rr <= (others=>'0');
      rvalid_r <= '0';
      bvalid_r <= '0';
   else
      if rising_edge(clock_in) then     
         -- Latch in button value
        button_rr <= button_r;
        button_r <= button_in;
        if(rvalid_r='1') then
           rvalid_r <= '0';
        elsif axilite_arvalid_in='1' then
           rvalid_r <= '1';
        end if;
        if(axilite_wvalid_in='1') then
           led_r <= axilite_wdata_in(led_r'length-1 downto 0);
           bvalid_r <= '1';
        else
           bvalid_r <= '0';
        end if;
      end if;
   end if;  
end process;

end Behavioral;
