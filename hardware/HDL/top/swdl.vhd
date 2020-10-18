------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
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
------------------------------------------------------------------------------

--------
-- This module implements message queue for MCORE and host to communicate with
-- each other
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY swdl IS
    port(
       SIGNAL mclock_in:in std_logic;
       SIGNAL mreset_in:in std_logic;
       SIGNAL pclock_in:in std_logic;
       SIGNAL preset_in:in std_logic;

       -- Read access from mcore
        SIGNAL mcore_addr_in        : register_addr_t;
        SIGNAL mcore_read_in        : IN STD_LOGIC;
        SIGNAL mcore_write_in       : IN STD_LOGIC;
        SIGNAL mcore_readdata_out   : OUT STD_LOGIC_VECTOR(mregister_width_c-1 DOWNTO 0);

       -- SWDL from host ligh weight bus
       SIGNAL host_write_in:IN std_logic;
       SIGNAL host_writedata_in:IN std_logic_vector(host_width_c-1 downto 0);
       SIGNAL host_write_addr_in:IN STD_LOGIC_VECTOR(avalon_page_width_c-1 downto 0);
       
       -- SWDL from DDR streaming
	   SIGNAL stream_write_addr_in:IN STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
       SIGNAL stream_write_data_in:IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
       SIGNAL stream_write_enable_in:IN std_logic;
       SIGNAL stream_wait_out:OUT std_logic;

       SIGNAL prog_text_ena_out:OUT std_logic;
       SIGNAL prog_text_data_out:OUT std_logic_vector(mcore_instruction_width_c-1 downto 0);
       SIGNAL prog_text_addr_out:OUT std_logic_vector(mcore_instruction_depth_c-1 downto 0)
        );        
END swdl;

ARCHITECTURE swdl_behaviour of swdl is
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
		underflow_checking      : STRING;
		use_eab                 : STRING;
		wrsync_delaypipe        : NATURAL
	);
	PORT (
			data	: IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
			rdclk	: IN STD_LOGIC;
			rdreq	: IN STD_LOGIC;
			wrclk	: IN STD_LOGIC;
			wrreq	: IN STD_LOGIC;
            wrusedw : OUT STD_LOGIC_VECTOR(lpm_widthu-1 downto 0);
			q	    : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
			rdempty	: OUT STD_LOGIC;
			wrfull	: OUT STD_LOGIC 
	);
END COMPONENT;

constant mcore_instruction_fifo_depth_c:integer:=(mcore_actual_instruction_depth_c-2);
SIGNAL prog_fifo_write_data:std_logic_vector(mcore_instruction_depth_c+mcore_instruction_width_c-1 downto 0);
SIGNAL prog_fifo_write:std_logic;
SIGNAL prog_fifo_full:std_logic;
SIGNAL prog_fifo_read_data:std_logic_vector(mcore_instruction_depth_c+mcore_instruction_width_c-1 downto 0);
SIGNAL prog_fifo_read:std_logic;
SIGNAL prog_fifo_empty:std_logic;

SIGNAL mcore_regno:register_t;
SIGNAL mcore_rden_r:STD_LOGIC;
SIGNAL mcore_readdata_r:STD_LOGIC_VECTOR(mregister_width_c-1 DOWNTO 0);
SIGNAL mcore_addr_r:register_addr_t;
SIGNAL mcore_read_r:STD_LOGIC;
SIGNAL mcore_write_r:STD_LOGIC;
SIGNAL count_r:unsigned(15 downto 0);
SIGNAL prog_text_ena:std_logic;
BEGIN

prog_text_ena <= host_write_in or (not prog_fifo_empty);
prog_text_data_out <= host_writedata_in when host_write_in='1' else prog_fifo_read_data(mcore_instruction_width_c-1 downto 0);
prog_text_addr_out <= host_write_addr_in(mcore_instruction_depth_c-1 downto 0) when host_write_in='1' else prog_fifo_read_data(prog_fifo_read_data'length-1 downto mcore_instruction_width_c);
prog_fifo_read <= (not host_write_in) and (not prog_fifo_empty);
prog_fifo_write_data <= stream_write_addr_in(mcore_instruction_depth_c+2-1 downto 2) & stream_write_data_in(mcore_instruction_width_c-1 downto 0);
prog_fifo_write <= '1' when (stream_write_enable_in='1' and prog_fifo_full='0') else '0';

prog_text_ena_out <= prog_text_ena;
stream_wait_out <= stream_write_enable_in and prog_fifo_full;

-- count_r must be large enough to hold the count for largest mcore program memory transfer...
assert (count_r'length < mcore_actual_instruction_depth_c) report "SWDL complete count is too small" severity note;

swdl_fifo_i : dcfifo
	GENERIC MAP (
		intended_device_family => "Cyclone V",
		lpm_numwords => 2**mcore_instruction_fifo_depth_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => mcore_instruction_depth_c+mcore_instruction_width_c,
		lpm_widthu => mcore_instruction_fifo_depth_c,
		rdsync_delaypipe => 5,
		underflow_checking => "ON",
		overflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 5
	)
	PORT MAP (
		data => prog_fifo_write_data,
		wrclk => pclock_in,
		wrreq => prog_fifo_write,
		wrfull => prog_fifo_full,
        wrusedw => open,

		rdclk => mclock_in,
		rdreq => prog_fifo_read,
		q => prog_fifo_read_data,
		rdempty => prog_fifo_empty
	);

mcore_readdata_out <= mcore_readdata_r when mcore_rden_r='1' else (others=>'Z');
mcore_regno <= unsigned(mcore_addr_r(register_t'length-1 downto 0));

process(mreset_in,mclock_in)
begin
    if mreset_in='0' then
        mcore_rden_r <= '0';
        mcore_readdata_r <= (others=>'0');
        mcore_addr_r <= (others=>'0');
        mcore_read_r <= '0';
        mcore_write_r <= '0';
        count_r <= (others=>'0');
    else
        if mclock_in'event and mclock_in='1' then
            mcore_addr_r <= mcore_addr_in;
            mcore_read_r <= mcore_read_in;
	        mcore_write_r <= mcore_write_in;
            if mcore_read_r='1' and to_integer(mcore_regno)=register_swdl_complete_read_c then
                mcore_readdata_r(count_r'length-1 downto 0) <= std_logic_vector(count_r);
                mcore_readdata_r(mcore_readdata_r'length-1 downto count_r'length) <= (others=>'0');
                mcore_rden_r <= '1';
		    else
                mcore_rden_r <= '0';
			end if;
            if mcore_write_r='1' and to_integer(mcore_regno)=register_swdl_complete_clear_c then
               count_r <= (others=>'0');
            end if;
            if prog_text_ena='1' then
               count_r <= count_r+1;
            end if;
        end if;
    end if;
end process;



END swdl_behaviour;