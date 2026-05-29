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
-----------------------------------------------------------------------------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

---------
-- This is a faster version of FIFO for timing
-- The read data is first registered to register before making it available
-- Use fifo2 instead of standard fifo to improve timing
------------

ENTITY fifo2 IS
	generic 
	(
        DATA_WIDTH  : natural;
        FIFO_DEPTH  : natural;
        ALMOST_FULL : natural := 1
	);
	port 
	(
        clock_in        : in std_logic;
        reset_in        : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_in        : in std_logic;
        read_in         : in std_logic;
        flush_in        : in std_logic:='0';
        q_out           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        wused_out       : out std_logic_vector(FIFO_DEPTH-1 downto 0);
        full_out        : out std_logic;
        almost_full_out : out std_logic;
        empty_out       : out std_logic
	);
END fifo2;

ARCHITECTURE fifo2_behaviour of fifo2 is

signal empty:std_logic;
signal q:std_logic_vector(DATA_WIDTH-1 downto 0);
signal q_r:std_logic_vector(DATA_WIDTH-1 downto 0);
signal valid_r:std_logic;
signal read:std_logic;
BEGIN

fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>DATA_WIDTH,
        FIFO_DEPTH=>FIFO_DEPTH,
        LOOKAHEAD=>TRUE,
        ALMOST_FULL=>ALMOST_FULL
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>data_in,
        write_in=>write_in,
        read_in=>read,
        flush_in=>flush_in,
        q_out=>q,
        ravail_out=>open,
        wused_out=>wused_out,
        empty_out=>empty,
        full_out=>full_out,
        almost_full_out=>almost_full_out
	);

empty_out <= not valid_r;

q_out <= q_r;

read <= '1' when (valid_r='0' or read_in='1') and empty='0' else '0';

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        valid_r <= '0';
        q_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            if(flush_in='1') then
                valid_r <= '0';
            elsif(read='1') then
                q_r <= q;
                valid_r <= '1';
            elsif(read_in='1') then
                valid_r <= '0';
            end if;
        end if;
    end if;
end process;

END fifo2_behaviour;

