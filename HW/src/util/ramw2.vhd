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
-- This is the RAM block but operates in 2x clock
-- Each word is split into 2 words
-- This is useful when the RAM block is not deep enough to match the minimum
-- depth that can be configured in a FPGA's memory block 
-- ramw2 improves FPGA memory utilization.
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY ramw2 IS
   GENERIC (
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT (
        clock     : IN STD_LOGIC;
        clock_x2  : IN STD_LOGIC;
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END ramw2;

architecture ramw2_behaviour of ramw2 is
signal data:STD_LOGIC_VECTOR (width_a/2-1 DOWNTO 0);
signal data_r:STD_LOGIC_VECTOR (width_a/2-1 DOWNTO 0);
signal waddress:STD_LOGIC_VECTOR(widthad_a DOWNTO 0);
signal waddress_r:STD_LOGIC_VECTOR(widthad_a-1 DOWNTO 0);
signal raddress:STD_LOGIC_VECTOR(widthad_b DOWNTO 0);
signal raddress_r:STD_LOGIC_VECTOR(widthad_b-1 DOWNTO 0);
signal q:STD_LOGIC_VECTOR (width_b/2-1 DOWNTO 0);
signal q_latch:STD_LOGIC_VECTOR (width_b/2-1 DOWNTO 0);
signal wren:STD_LOGIC;
signal wren_r:STD_LOGIC;
begin

data <= data_a(data_a'length-1 downto data_a'length/2) when clock='0' else data_r;
waddress(waddress'length-1 downto 1) <= address_a when clock='0' else waddress_r;
waddress(0) <= (not clock); 
raddress(raddress'length-1 downto 1) <= address_b when clock='0' else raddress_r;
raddress(0) <= (not clock);
q_b(q_b'length/2-1 downto 0) <= q;
q_b(q_b'length-1 downto q_b'length/2) <= q_latch; 
wren <= (wren_r and clock) or (wren_a and (not clock));

sync_latch_i: SYNC_LATCH
   generic map
   (
      DATA_WIDTH=>q'length
   )
   port map
   (
      enable_in=>clock,
      data_in=>q,
      data_out=>q_latch
   );

process(clock)
begin
   if(rising_edge(clock)) then 
      data_r <= data_a(data_a'length/2-1 downto 0);
      waddress_r <= address_a;
      raddress_r <= address_b;
      wren_r <= wren_a;
   end if;
end process;

ram_i: DPRAM
   GENERIC MAP (
        numwords_a=>numwords_a*2,
        numwords_b=>numwords_b*2,
        widthad_a=>widthad_a+1,
        widthad_b=>widthad_b+1,
        width_a=>width_a/2,
        width_b=>width_b/2
    )
    PORT MAP (
        clock=>clock_x2,
        address_a=>waddress,
        data_a=>data,
        q_b=>q,
        wren_a=>wren,
        address_b=>raddress
    );
end ramw2_behaviour;
