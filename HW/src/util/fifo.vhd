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

entity scfifo is
	generic 
	(
        DATA_WIDTH  : natural;
        FIFO_DEPTH  : natural;
        LOOKAHEAD   : boolean;
        ALMOST_FULL : natural := 1
	);
	port 
	(
        clock_in        : in std_logic;
        reset_in        : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_in        : in std_logic;
        read_in         : in std_logic;
        q_out           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        ravail_out      : out std_logic_vector(FIFO_DEPTH-1 downto 0);
        wused_out       : out std_logic_vector(FIFO_DEPTH-1 downto 0);
        empty_out       : out std_logic;
        full_out        : out std_logic;
        almost_full_out : out std_logic
	);
end scfifo;

architecture rtl of scfifo is

-- Declare the RAM signal.	
signal q:std_logic_vector((DATA_WIDTH -1) downto 0);
signal q_r:std_logic_vector((DATA_WIDTH -1) downto 0);
signal address_a:std_logic_vector(FIFO_DEPTH-1 downto 0);
signal address_b:std_logic_vector(FIFO_DEPTH-1 downto 0);
signal waddr_r:unsigned(FIFO_DEPTH-1 downto 0);
signal waddr_rr:unsigned(FIFO_DEPTH-1 downto 0);
signal raddr_r:unsigned(FIFO_DEPTH-1 downto 0);
signal raddr:unsigned(FIFO_DEPTH-1 downto 0);
signal we:std_logic;
signal ravail:unsigned(FIFO_DEPTH-1 downto 0);
signal wused:unsigned(FIFO_DEPTH-1 downto 0);
signal not_empty_r:std_logic;
signal full_r:std_logic;
begin

address_a <= std_logic_vector(waddr_r);
address_b <= std_logic_vector(raddr);

ram_i : DPRAM
   generic map
      (
        numwords_a=>2**FIFO_DEPTH,
        numwords_b=>2**FIFO_DEPTH,
        widthad_a=>FIFO_DEPTH,
        widthad_b=>FIFO_DEPTH,
        width_a=>DATA_WIDTH,
        width_b=>DATA_WIDTH
      )
   port map
      (
        address_a => address_a,
        address_b => address_b,
        clock=>clock_in,
        data_a => data_in,
        wren_a => write_in,
        q_b => q
      );

ravail <= (waddr_rr-raddr_r);
wused <= (waddr_r-raddr_r);
empty_out <= not not_empty_r;
full_out <= full_r;
almost_full_out <= '1' when (wused >= to_unsigned(ALMOST_FULL,FIFO_DEPTH)) else '0';
ravail_out <= std_logic_vector(ravail);
wused_out <= std_logic_vector(wused);
raddr <= (raddr_r+1) when (read_in='1') else raddr_r;

GEN_LOOKAHEAD_TRUE: if LOOKAHEAD=true generate
q_out <= q;
end generate GEN_LOOKAHEAD_TRUE;

GEN_LOOKAHEAD_FALSE: if LOOKAHEAD=false generate
q_out <= q_r;
end generate GEN_LOOKAHEAD_FALSE;
 
process(clock_in,reset_in)
begin
   if(reset_in='0') then
      raddr_r <= (others=>'0');
      waddr_r <= (others=>'0');
      waddr_rr <= (others=>'0');
      q_r <= (others=>'0');
      not_empty_r <= '0';
      full_r <= '0';
   else
      if(rising_edge(clock_in)) then 
         if(write_in = '1') then
            waddr_r <= (waddr_r+1);
            if((waddr_r+2)=raddr) then
               full_r <= '1';
            else
               full_r <= '0';
            end if;
         else
            if((waddr_r+1)=raddr) then
               full_r <= '1';
            else
               full_r <= '0';
            end if;
         end if;
         waddr_rr <= waddr_r;
 
         -- On a read during a write to the same address, the read will
         -- return the OLD data at the address
         if read_in='1' then
            q_r <= q;
         end if;
         raddr_r <= raddr;

         if(waddr_r=raddr) then
             not_empty_r <= '0';
         else
             not_empty_r <= '1';
         end if;
      end if;
   end if;
end process;

end rtl;
