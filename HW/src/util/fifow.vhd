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

-- This FIFO is optimized for very wide datawidth
-- Data are pushed/poped into more than 1 entries info a FIFO
-- This is for more optimized synthesis on FPGA where you need a shallow 
-- but wide FIFO and it is taking too many memory blocks from FPGA

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity scfifow is
	generic 
	(
        DATA_WIDTH  : natural;
        FIFO_DEPTH  : natural
	);
	port 
	(
        clock_in        : in std_logic;
        reset_in        : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_in        : in std_logic;
        writeready_out  : out STD_LOGIC;
        read_in         : in std_logic;
        q_out           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        empty_out       : out std_logic;
        wused_out       : out std_logic_vector(FIFO_DEPTH-1 downto 0)
	);
end scfifow;

architecture rtl of scfifow is

constant scalew_c:integer:=2;
constant scale_c:integer:=(2**scalew_c);
constant width_c:integer:=(DATA_WIDTH+scale_c-1)/scale_c;
signal wpending_r:unsigned(scalew_c-1 downto 0);
signal rpending_r:unsigned(scalew_c-1 downto 0);
signal q_avail_r:std_logic;
signal w_avail_r:std_logic;
signal q_r:std_logic_vector(scale_c*width_c-1 downto 0);
signal data_r:std_logic_vector(scale_c*width_c-1 downto 0);
signal wused:std_logic_vector(FIFO_DEPTH+scalew_c-1 downto 0);
signal write:std_logic;
signal data:std_logic_vector(width_c-1 downto 0);
signal read:std_logic;
signal empty:std_logic;
signal q:std_logic_vector(width_c-1 downto 0);
signal full:std_logic;
signal almost_full:std_logic;
begin


fifo_i : scfifo
	generic map 
	(
        DATA_WIDTH=>width_c,
        FIFO_DEPTH=>FIFO_DEPTH+scalew_c,
        LOOKAHEAD=>TRUE,
        ALMOST_FULL=>4
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>data,
        write_in=>write,
        read_in=>read,
        q_out=>q,
        ravail_out=>open,
        wused_out=>wused,
        empty_out=>empty,
        full_out=>full,
        almost_full_out=>almost_full
	);
 

-- Read signals
q_out <= q_r(q_out'length-1 downto 0);

empty_out <= (not q_avail_r);

read <= '1' when (empty='0' and q_avail_r='0') else '0';

-- Write signals
write <= w_avail_r;

writeready_out <= (not w_avail_r);

wused_out <= wused(wused'length-1 downto scalew_c);

data <= data_r(width_c-1 downto 0);


process(clock_in,reset_in)
begin
   if(reset_in='0') then
      wpending_r <= (others=>'0');
      rpending_r <= (others=>'0');
      q_avail_r <= '0';
      q_r <= (others=>'0');
      data_r <= (others=>'0');
      w_avail_r <= '0';
   else
      if(rising_edge(clock_in)) then
         -- Write to FIFO
         if w_avail_r='0' then
            if write_in='1' then
               wpending_r <= to_unsigned(0,wpending_r'length);
               data_r(data_in'length-1 downto 0) <= data_in;
               w_avail_r <= '1';
            end if;
         else
            if wpending_r=to_unsigned(scale_c-1,wpending_r'length) then
               w_avail_r <= '0';
            end if;
            wpending_r <= wpending_r+1;
            data_r((scale_c-1)*width_c-1 downto 0) <= data_r(scale_c*width_c-1 downto width_c);
         end if;
         
         -- Read FIFO
         if q_avail_r='0' then
            if empty='0' then
               q_r((scale_c-1)*width_c-1 downto 0) <= q_r(scale_c*width_c-1 downto width_c);
               q_r(scale_c*width_c-1 downto (scale_c-1)*width_c) <= q;
               if(rpending_r=to_unsigned(scale_c-1,rpending_r'length)) then
                  q_avail_r <= '1';
               end if;
               rpending_r <= rpending_r+1;
            end if;
         elsif read_in='1' then
            q_avail_r <= '0'; 
         end if;
      end if;
   end if;
end process;
end rtl;
