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

ENTITY avalon_lw IS
    port(
        SIGNAL hclock_in            : IN STD_LOGIC;
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL hreset_in            : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- Interface with host
        SIGNAL host_addr_in         : IN std_logic_vector(avalon_bus_width_c-1 downto 0);
        SIGNAL host_write_in        : IN STD_LOGIC;
        SIGNAL host_read_in         : IN STD_LOGIC;
        SIGNAL host_writedata_in    : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL host_readdata_out    : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL host_readdatavalid_out: OUT STD_LOGIC;
        SIGNAL host_ready_out       : OUT STD_LOGIC;
        -- Interface with MCORE
        SIGNAL addr_out             : OUT std_logic_vector(avalon_bus_width_c-1 downto 0);
        SIGNAL write_out            : OUT STD_LOGIC;
        SIGNAL read_out             : OUT STD_LOGIC;
        SIGNAL writedata_out        : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL readdata_in          : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL readdatavalid_in     : IN STD_LOGIC
        );        
END avalon_lw;

ARCHITECTURE avalon_lw_behaviour of avalon_lw is

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

constant a2z_fifo_width_c:integer:=host_width_c+avalon_bus_width_c+2;
constant a2z_fifo_depth_c:integer:=4;
constant z2a_fifo_depth_c:integer:=2;
SIGNAL a2z_data:std_logic_vector(a2z_fifo_width_c-1 downto 0);
SIGNAL a2z_wrreq:std_logic;
SIGNAL a2z_wrfull:std_logic;
SIGNAL a2z_rdreq:std_logic;
SIGNAL a2z_q:std_logic_vector(a2z_fifo_width_c-1 downto 0);
SIGNAL a2z_rdempty:std_logic;
SIGNAL z2a_q:std_logic_vector(host_width_c-1 downto 0);
SIGNAL z2a_q_r:std_logic_vector(host_width_c-1 downto 0);
SIGNAL z2a_rdreq:std_logic;
SIGNAL z2a_rdreq_r:std_logic;
SIGNAL z2a_rdempty:std_logic;

SIGNAL addr:std_logic_vector(avalon_bus_width_c-1 downto 0);
SIGNAL write:STD_LOGIC;
SIGNAL read:STD_LOGIC;
SIGNAL writedata:STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);

SIGNAL addr_r:std_logic_vector(avalon_bus_width_c-1 downto 0);
SIGNAL write_r:STD_LOGIC;
SIGNAL read_r:STD_LOGIC;
SIGNAL writedata_r:STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
SIGNAL wrusedw:STD_LOGIC_VECTOR(a2z_fifo_depth_c-1 downto 0);
SIGNAL wrusedw_r:STD_LOGIC_VECTOR(a2z_fifo_depth_c-1 downto 0);
SIGNAL wrusedw2:STD_LOGIC_VECTOR(z2a_fifo_depth_c-1 downto 0);
BEGIN

----
-- FIFO for data flow from avalon bus to ztachip internal
---

a2z : dcfifo
	GENERIC MAP (
		intended_device_family => "Cyclone V",
		lpm_numwords => 2**a2z_fifo_depth_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => a2z_fifo_width_c,
		lpm_widthu => a2z_fifo_depth_c,
		overflow_checking => "ON",
		rdsync_delaypipe => 5,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 5
	)
	PORT MAP (
		data => a2z_data,
		wrclk => hclock_in,
		wrreq => a2z_wrreq,
		wrfull => a2z_wrfull,
        wrusedw => wrusedw,

		rdclk => clock_in,
		rdreq => a2z_rdreq,
		q => a2z_q,
		rdempty => a2z_rdempty
	);

host_readdata_out <= z2a_q_r;
host_readdatavalid_out <= z2a_rdreq_r;
host_ready_out <= not wrusedw_r(wrusedw_r'length-1);

process(host_writedata_in,host_addr_in,host_read_in,host_write_in)
variable pos_v:integer;
begin
   pos_v:=0;
   a2z_data(host_writedata_in'length+pos_v-1 downto pos_v) <= host_writedata_in;
   pos_v := pos_v+host_writedata_in'length;
   a2z_data(host_addr_in'length+pos_v-1 downto pos_v) <= host_addr_in;
   pos_v := pos_v+host_addr_in'length;
   a2z_data(pos_v) <= host_read_in;
   pos_v := pos_v+1;
   a2z_data(pos_v) <= host_write_in;
   pos_v := pos_v+1;
end process;

a2z_wrreq <= host_read_in or host_write_in;
z2a_rdreq <= not z2a_rdempty;

-- FIFO for dataflow from ztachip to avalon...
z2a : dcfifo
	GENERIC MAP (
		intended_device_family => "Cyclone V",
		lpm_numwords => 2**z2a_fifo_depth_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => host_width_c,
		lpm_widthu => z2a_fifo_depth_c,
		overflow_checking => "ON",
		rdsync_delaypipe => 5,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 5
	)
	PORT MAP (
		rdclk => hclock_in,
		rdreq => z2a_rdreq,
		q => z2a_q,
		rdempty => z2a_rdempty,

		data => readdata_in,
		wrclk => clock_in,
		wrreq => readdatavalid_in,
        wrusedw => wrusedw2,
		wrfull => open -- not possible to be full...
	);

process(a2z_rdempty,a2z_q)
variable pos_v:integer;
begin
   a2z_rdreq <= (not a2z_rdempty);
   pos_v:=0;
   writedata <= a2z_q(host_writedata_in'length+pos_v-1 downto pos_v);
   pos_v := pos_v+host_writedata_in'length;
   addr <= a2z_q(host_addr_in'length+pos_v-1 downto pos_v);
   pos_v := pos_v+host_addr_in'length;
   read <= a2z_q(pos_v) and (not a2z_rdempty);
   pos_v := pos_v+1;
   write <= a2z_q(pos_v) and (not a2z_rdempty);
   pos_v := pos_v+1;
end process;

writedata_out <= writedata_r;
addr_out <= addr_r;
read_out <= read_r;
write_out <= write_r;

process(reset_in,clock_in)
begin
    if reset_in='0' then
       writedata_r <= (others=>'0');
       addr_r <= (others=>'0');
       read_r <= '0';
       write_r <= '0';
    else
        if clock_in'event and clock_in='1' then
           writedata_r <= writedata;
           addr_r <= addr;
           read_r <= read;
           write_r <= write;
        end if;
    end if;
end process;


process(hreset_in,hclock_in)
begin
    if hreset_in='0' then
       z2a_q_r <= (others=>'0');
       z2a_rdreq_r <= '0';
       wrusedw_r <= (others=>'0');
    else
        if hclock_in'event and hclock_in='1' then
           z2a_q_r <= z2a_q;
           z2a_rdreq_r <= z2a_rdreq;
           wrusedw_r <= wrusedw;
        end if;
    end if;
end process;


END avalon_lw_behaviour;
