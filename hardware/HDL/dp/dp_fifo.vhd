------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
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
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY dp_fifo IS
    port(
            -- Signal from Avalon bus...
            SIGNAL clock_in                 : IN STD_LOGIC;
            SIGNAL mclock_in                : IN STD_LOGIC;
            SIGNAL reset_in                 : IN STD_LOGIC;    
            SIGNAL mreset_in                : IN STD_LOGIC;    

            SIGNAL writedata_in             : IN STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
            SIGNAL wreq_in                  : IN STD_LOGIC;
            SIGNAL wreq_priority_in         : IN STD_LOGIC;
            SIGNAL readdata1_out             : OUT STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
            SIGNAL readdata2_out             : OUT STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
            SIGNAL rdreq1_in                 : IN STD_LOGIC;
            SIGNAL rdreq2_in                 : IN STD_LOGIC;
            SIGNAL valid1_out               : OUT STD_LOGIC;
            SIGNAL valid2_out               : OUT STD_LOGIC;
            SIGNAL full_out                 : OUT STD_LOGIC;
            SIGNAL priority_full_out        : OUT STD_LOGIC;

            SIGNAL fifo_avail_out           : OUT std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0)
    );
END dp_fifo;

ARCHITECTURE dp_fifo_behaviour of dp_fifo is

COMPONENT dcfifo
   GENERIC (
        intended_device_family  : STRING;
        lpm_numwords            : NATURAL;
        lpm_showahead           : STRING;
        lpm_type                : STRING;
        lpm_width               : NATURAL;
        lpm_widthu              : NATURAL;
        overflow_checking       : STRING;
        rdsync_delaypipe        : NATURAL;
        read_aclr_synch         : STRING;
        underflow_checking      : STRING;
        use_eab                 : STRING;
        write_aclr_synch        : STRING;
        wrsync_delaypipe        : NATURAL
	);
	PORT (
         aclr    : IN STD_LOGIC ;
         data    : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
         rdclk   : IN STD_LOGIC ;
         rdreq   : IN STD_LOGIC ;
         wrclk   : IN STD_LOGIC ;
         wrreq   : IN STD_LOGIC ;
         q       : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
         rdempty : OUT STD_LOGIC ;
         rdusedw : OUT STD_LOGIC_VECTOR (lpm_widthu-1 DOWNTO 0);
         wrfull  : OUT STD_LOGIC;
         wrusedw : OUT STD_LOGIC_VECTOR (lpm_widthu-1 DOWNTO 0)
   );
END COMPONENT;

SIGNAL fifo_avail_r : std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0);
SIGNAL wrusedw : std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0);
SIGNAL wrusedw_priority : std_logic_vector(dp_fifo_priority_depth_c-1 DOWNTO 0);
SIGNAL full_r:std_logic;
SIGNAL priority_full_r:std_logic;
SIGNAL resetn:std_logic;
SIGNAL empty:std_logic;
SIGNAL empty_normal:std_logic;
SIGNAL empty_priority:std_logic;
SIGNAL readdata:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL readdata_normal:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL readdata_priority:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL wreq_normal:std_logic;
SIGNAL wreq_priority:std_logic;
SIGNAL rdreq:std_logic;
SIGNAL rdreq_normal:std_logic;
SIGNAL rdreq_priority:std_logic;
SIGNAL valid1:std_logic;
SIGNAL valid2:std_logic;
SIGNAL readdata1:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL readdata2:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL valid1_r:std_logic;
SIGNAL valid2_r:std_logic;
SIGNAL readdata1_r:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL readdata2_r:STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
SIGNAL writedata_r:std_logic_vector(dp_instruction_width_c-1 downto 0);
SIGNAL wreq_priority_r:STD_LOGIC;
SIGNAL wreq_normal_r:STD_LOGIC;
SIGNAL rdreq1_r:STD_LOGIC;
SIGNAL rdreq2_r:STD_LOGIC;
SIGNAL pause_r:STD_LOGIC;

attribute dont_merge : boolean;
attribute dont_merge of writedata_r : SIGNAL is true;
attribute dont_merge of wreq_priority_r : SIGNAL is true;
attribute dont_merge of wreq_normal_r : SIGNAL is true;

attribute preserve : boolean;
attribute preserve of writedata_r : SIGNAL is true;
attribute preserve of wreq_priority_r : SIGNAL is true;
attribute preserve of wreq_normal_r : SIGNAL is true;


BEGIN

fifo_avail_out <= fifo_avail_r;
full_out <= full_r;
priority_full_out <= priority_full_r;
resetn <= not reset_in;

fifo_i : dcfifo
   GENERIC MAP (
		intended_device_family => "Cyclone V",
		lpm_numwords => dp_fifo_max_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => dp_instruction_width_c,
		lpm_widthu => dp_fifo_depth_c,
		overflow_checking => "ON",
		rdsync_delaypipe => 5,
		read_aclr_synch => "OFF",
		underflow_checking => "ON",
		use_eab => "ON",
		write_aclr_synch => "OFF",
		wrsync_delaypipe => 5
	)
	PORT MAP (
        aclr => resetn,
		data => writedata_r,
		rdclk => clock_in,
		rdreq => rdreq_normal,
		wrclk => mclock_in,
		wrreq => wreq_normal_r,
		q => readdata_normal,
		rdempty => empty_normal,
		rdusedw => open,
		wrfull => open,
		wrusedw => wrusedw
	);

fifo_i2 : dcfifo
   GENERIC MAP (
		intended_device_family => "Cyclone V",
		lpm_numwords => dp_fifo_priority_max_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => dp_instruction_width_c,
		lpm_widthu => dp_fifo_priority_depth_c,
		overflow_checking => "ON",
		rdsync_delaypipe => 5,
		read_aclr_synch => "OFF",
		underflow_checking => "ON",
		use_eab => "ON",
		write_aclr_synch => "OFF",
		wrsync_delaypipe => 5
	)
	PORT MAP (
        aclr => resetn,
		data => writedata_r,
		rdclk => clock_in,
		rdreq => rdreq_priority,
		wrclk => mclock_in,
		wrreq => wreq_priority_r,
		q => readdata_priority,
		rdempty => empty_priority,
		rdusedw => open,
		wrfull => open,
		wrusedw => wrusedw_priority
	);

readdata1_out <= readdata1_r;
valid1_out <= valid1_r and (not pause_r);

readdata2_out <= readdata2_r;
valid2_out <= valid2_r and (not pause_r);

wreq_normal <= wreq_in and (not wreq_priority_in);
wreq_priority <= wreq_in and wreq_priority_in;

rdreq_normal <= '1' when rdreq='1' and empty_normal='0' and empty_priority='1' else '0';
rdreq_priority <= '1' when rdreq='1' and empty_priority='0' else '0';
empty <= empty_priority and empty_normal;
readdata <= readdata_priority when empty_priority='0' else readdata_normal; 

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
-- Fetch instructions from normal and priority instruction FIFO
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
      valid1 <= not empty;
      readdata1 <= readdata;
      rdreq <= not empty;
   else
      valid2 <= not empty;
      readdata2 <= readdata;
      rdreq <= not empty;
   end if;
elsif valid1_r='0' and valid2_r='1' then
   -- current is NOT available and next instruction available
   if rdreq2_r='1' then
      valid2 <= '0';
      valid1 <= not empty;
      readdata1 <= readdata;
      rdreq <= not empty;
   else
      valid1 <= '1';
      readdata1 <= readdata2_r;
      valid2 <= not empty;
      readdata2 <= readdata;
      rdreq <= not empty;
   end if;
else
   -- current is NOT available and next instruction NOT available
   valid1 <= not empty;
   readdata1 <= readdata;
   rdreq <= not empty;
end if;
end process;


process(mreset_in,mclock_in)
begin
    if mreset_in='0' then
        fifo_avail_r <= (others=>'0');
        full_r <= '0';
        priority_full_r <= '0';
        writedata_r <= (others=>'0');
        wreq_priority_r <= '0';
        wreq_normal_r <= '0';
    else
        if mclock_in'event and mclock_in='1' then
            writedata_r <= writedata_in;
            wreq_priority_r <= wreq_priority;
            wreq_normal_r <= wreq_normal;
            fifo_avail_r <= (not wrusedw);
            if(unsigned(not wrusedw) < to_unsigned(4,dp_fifo_depth_c)) then
			   full_r <= '1';
            else
               full_r <= '0';
            end if;
            if(unsigned(not wrusedw_priority) < to_unsigned(4,dp_fifo_priority_depth_c)) then
			   priority_full_r <= '1';
            else
               priority_full_r <= '0';
            end if;
        end if;
    end if;
end process;
end dp_fifo_behaviour;