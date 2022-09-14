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

--------
-- This module is accepting DP instructions from mcore
-- Instructions are stored in a primary fifo and then forwarded to a secondary fifo
-- when specified conditions are met
-- There is a secondary fifo for each bus controlled by DP.
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY dp_fifo IS
    port(
        -- Signal from Avalon bus...
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;    

        SIGNAL writedata_in             : IN STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
        SIGNAL wreq_in                  : IN STD_LOGIC;
        SIGNAL readdata1_out            : OUT STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
        SIGNAL readdata2_out            : OUT STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
        SIGNAL rdreq1_in                : IN STD_LOGIC;
        SIGNAL rdreq2_in                : IN STD_LOGIC;
        SIGNAL valid1_out               : OUT STD_LOGIC;
        SIGNAL valid2_out               : OUT STD_LOGIC;
        SIGNAL full_out                 : OUT STD_LOGIC;

        SIGNAL fifo_avail_out           : OUT std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0)
    );
END dp_fifo;

ARCHITECTURE dp_fifo_behaviour of dp_fifo is

SIGNAL fifo_avail_r : std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0);
SIGNAL wrusedw : std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0);
SIGNAL full_r:std_logic;
SIGNAL empty:std_logic;
SIGNAL empty_normal:std_logic;
SIGNAL readdata:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL readdata_normal:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL wreq_normal:std_logic;
SIGNAL rdreq:std_logic;
SIGNAL rdreq_normal:std_logic;
SIGNAL valid1:std_logic;
SIGNAL valid2:std_logic;
SIGNAL readdata1:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL readdata2:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL valid1_r:std_logic;
SIGNAL valid2_r:std_logic;
SIGNAL readdata1_r:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL readdata2_r:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL writedata_r:std_logic_vector(dp_instruction_width_c-1 downto 0);
SIGNAL wreq_normal_r:STD_LOGIC;
SIGNAL rdreq1_r:STD_LOGIC;
SIGNAL rdreq2_r:STD_LOGIC;
SIGNAL pause_r:STD_LOGIC;

BEGIN

fifo_avail_out <= fifo_avail_r;

full_out <= full_r;

fifo_i:scfifow
	generic map 
	(
        DATA_WIDTH=>dp_instruction_width_c,
        FIFO_DEPTH=>dp_fifo_depth_c
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>writedata_r,
        write_in=>wreq_normal_r,
        read_in=>rdreq_normal,
        q_out=>readdata_normal,
        wused_out=>wrusedw,
        empty_out=>empty_normal
	);


readdata1_out <= readdata1_r;

valid1_out <= valid1_r and (not pause_r) and (not((not valid1_r) and valid2_r));

readdata2_out <= readdata2_r;

valid2_out <= valid2_r and (not pause_r) and (not((not valid1_r) and valid2_r));

wreq_normal <= wreq_in;

rdreq_normal <= '1' when rdreq='1' and empty_normal='0' else '0';

empty <= empty_normal;

readdata <= readdata_normal; 

process(clock_in,reset_in)
begin
    if reset_in='0' then
       valid1_r <= '0';
       valid2_r <= '0';
       readdata1_r <= (others=>'0');
       readdata2_r <= (others=>'0');
       rdreq1_r <= '0';
       rdreq2_r <= '0';
       pause_r <= '0';
    else
        if clock_in'event and clock_in='1' then
           valid1_r <= valid1;
           valid2_r <= valid2;
           readdata1_r <= readdata1;
           readdata2_r <= readdata2;
           rdreq1_r <= rdreq1_in;
           rdreq2_r <= rdreq2_in;
           pause_r <= rdreq1_in or rdreq2_in;
        end if;
    end if;
end process;

----------------------------------------------------------------------------------------
-- Fetch instructions from instruction FIFO
-- There are 2 instructions being fetched. Current instruction and next instruction
-- This allows instruction to be executed out of order. For example if current instruction
-- is currently cannot be executed, then next instruction will be executed ahead out of order
-- There can only be 1 instruction executed out of order
-----------------------------------------------------------------------------------------

process(valid1_r,valid2_r,rdreq1_r,rdreq2_r,empty,readdata1_r,readdata2_r,readdata)
begin
rdreq <= '0';
valid1 <= valid1_r;
valid2 <= valid2_r;
readdata1 <= readdata1_r;
readdata2 <= readdata2_r;
if valid1_r='1' and valid2_r='1' then
   -- Both current and next instruction available
   if rdreq1_r='1' then
      -- Application just read current instruction
      -- Make next instruction to be current instruction
      -- Fetch next instruction with new one.
      valid1 <= '1';
      valid2 <= not empty;
      readdata1 <= readdata2_r;
      readdata2 <= readdata;
      rdreq <= not empty;
   elsif rdreq2_r='1' then
      -- Application just read an instruction out of order
      valid2 <= not empty;
      readdata2 <= readdata;
      rdreq <= not empty;
   end if;
elsif valid1_r='1' and valid2_r='0' then
   -- current is available and next instruction NOT available
   if rdreq1_r='1' then
      valid1 <= '0';
      valid2 <= not empty;
      readdata2 <= readdata;
      rdreq <= not empty;
   else
      valid2 <= not empty;
      readdata2 <= readdata;
      rdreq <= not empty;
   end if;
elsif valid1_r='0' and valid2_r='1' then
   -- current is NOT available and next instruction available
   if rdreq2_r='1' then
      valid2 <= not empty;
      readdata2 <= readdata;
      rdreq <= not empty;
      valid1 <= '0';
   else
      valid1 <= '1';
      readdata1 <= readdata2_r;
      valid2 <= not empty;
      readdata2 <= readdata;
      rdreq <= not empty;
   end if;
else
   -- current is NOT available and next instruction NOT available
   valid2 <= not empty;
   readdata2 <= readdata;
   rdreq <= not empty;
   valid1 <= '0';
end if;
end process;


process(reset_in,clock_in)
begin
    if reset_in='0' then
        fifo_avail_r <= (others=>'0');
        full_r <= '0';
        writedata_r <= (others=>'0');
        wreq_normal_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            writedata_r <= writedata_in;
            wreq_normal_r <= wreq_normal;
            fifo_avail_r <= (not wrusedw);
            if(unsigned(not wrusedw) < to_unsigned(16,dp_fifo_depth_c)) then
               full_r <= '1';
            else
               full_r <= '0';
            end if;
        end if;
    end if;
end process;
end dp_fifo_behaviour;
