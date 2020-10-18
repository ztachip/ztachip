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

-------
-- This component interfaces with DDR using avalon burst access mode
-------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY ddr IS
    generic(
        TX_ENABLE        : boolean;
        RX_ENABLE        : boolean
        );
    port(
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;
        SIGNAL dclock_in                : IN STD_LOGIC;
        SIGNAL dreset_in                : IN STD_LOGIC;

        -- Bus interface for read2 master to DDR
        SIGNAL read_addr_in             : IN STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);
        SIGNAL read_cs_in               : IN STD_LOGIC;
        SIGNAL read_in                  : IN STD_LOGIC;
        SIGNAL read_vm_in               : IN STD_LOGIC;
        SIGNAL read_vector_in           : IN dp_vector_t;
        SIGNAL read_fork_in             : IN STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
        SIGNAL read_start_in            : unsigned(ddr_vector_depth_c downto 0);
        SIGNAL read_end_in              : unsigned(ddr_vector_depth_c downto 0);
        SIGNAL read_data_ready_out      : OUT STD_LOGIC;
        SIGNAL read_fork_out            : OUT STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
        SIGNAL read_data_wait_in        : IN STD_LOGIC;
        SIGNAL read_data_valid_out      : OUT STD_LOGIC;
        SIGNAL read_data_valid_vm_out   : OUT STD_LOGIC;
        SIGNAL read_data_out            : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL read_wait_request_out    : OUT STD_LOGIC;
        SIGNAL read_burstlen_in         : IN burstlen_t;
        SIGNAL read_filler_data_in      : IN STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

        
        -- Bus interface for write master to DDR
        SIGNAL write_addr_in            : IN STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);
        SIGNAL write_cs_in              : IN STD_LOGIC;
        SIGNAL write_in                 : IN STD_LOGIC;
        SIGNAL write_vector_in          : IN dp_vector_t;   
        SIGNAL write_end_in             : IN vector_t;
        SIGNAL write_data_in            : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL write_wait_request_out   : OUT STD_LOGIC;
        SIGNAL write_burstlen_in        : IN burstlen_t;
        SIGNAL write_burstlen2_in       : IN burstlen2_t;
        SIGNAL write_burstlen3_in       : IN burstlen_t;

        SIGNAL ddr_addr_out             : OUT std_logic_vector(ddr_bus_width_c-1 downto 0); ---
        SIGNAL ddr_burstlen_out         : OUT unsigned(ddr_burstlen_width_c-1 downto 0); ---
        SIGNAL ddr_burstbegin_out       : OUT std_logic; ---
        SIGNAL ddr_readdatavalid_in     : IN std_logic; -------
        SIGNAL ddr_write_out            : OUT std_logic; -----
        SIGNAL ddr_read_out             : OUT std_logic; ---
        SIGNAL ddr_writedata_out        : OUT std_logic_vector(ddr_data_width_c-1 downto 0);  -----
        SIGNAL ddr_byteenable_out       : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0); ------
        SIGNAL ddr_readdata_in          : IN std_logic_vector(ddr_data_width_c-1 downto 0); ----
        SIGNAL ddr_wait_request_in      : IN std_logic
        );
END ddr;

ARCHITECTURE ddr_behavior of ddr IS 

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

COMPONENT scfifo
GENERIC (
    add_ram_output_register     : STRING;
    almost_full_value           : NATURAL;
    intended_device_family      : STRING;
    lpm_numwords                : NATURAL;
    lpm_showahead               : STRING;
    lpm_type                    : STRING;
    lpm_width                   : NATURAL;
    lpm_widthu                  : NATURAL;
    overflow_checking           : STRING;
    underflow_checking          : STRING;
    use_eab                     : STRING
);
PORT (
        clock       : IN STD_LOGIC ;
        empty       : OUT STD_LOGIC ;
        full        : OUT STD_LOGIC ;
        q           : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
        wrreq       : IN STD_LOGIC ;
        aclr        : IN STD_LOGIC ;
        almost_full : OUT STD_LOGIC ;
        data        : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
        rdreq       : IN STD_LOGIC;
        usedw       : OUT STD_LOGIC_VECTOR (lpm_widthu-1 DOWNTO 0)
);
END COMPONENT;


----
-- DDR write command to be sent to async FIFO before going to external bus
-- We would like to go through async FIFO since external bus is in a different clock domain
-- ddr_write_cmt_t is the write request format that get pushed to the async FIFO
-- Also define corresponding pack/unpack function for this record
------

type ddr_write_cmd_t is
record
   burstbegin:std_logic; -- Begin of burst
   burstlen:burstlen_t;  -- Burst length
   addr:std_logic_vector(ddr_bus_width_c-1 downto 0); -- Destination memory address
   byteena:std_logic_vector(ddr_data_byte_width_c-1 downto 0); -- Associated byteEnable with this write
end record;

signal dummy1:ddr_write_cmd_t;

constant ddr_write_cmd_length_c:integer:=(1+
                                          dummy1.burstlen'length+
                                          dummy1.addr'length+
                                          dummy1.byteena'length);

subtype ddr_write_cmd_flat_t is std_logic_vector(ddr_write_cmd_length_c-1 downto 0);

function pack_ddr_write_cmd(rec_in: ddr_write_cmd_t) return ddr_write_cmd_flat_t is
variable len_v:integer;
variable q_v:ddr_write_cmd_flat_t;
begin
len_v := 0;
q_v(q_v'length-len_v-1) := rec_in.burstbegin;
len_v := len_v+1;
q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burstlen'length) := std_logic_vector(rec_in.burstlen);
len_v := len_v+rec_in.burstlen'length;
q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.addr'length) := rec_in.addr;
len_v := len_v+rec_in.addr'length;
q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.byteena'length) := rec_in.byteena;
len_v := len_v+rec_in.byteena'length;
return q_v;
end function pack_ddr_write_cmd;

function unpack_ddr_write_cmd(q_in: ddr_write_cmd_flat_t) return ddr_write_cmd_t is
variable len_v:integer;
variable rec_v:ddr_write_cmd_t;
begin
len_v := 0;
rec_v.burstbegin := q_in(q_in'length-len_v-1);
len_v := len_v+1;
rec_v.burstlen := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burstlen'length));
len_v := len_v+rec_v.burstlen'length;
rec_v.addr := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.addr'length);
len_v := len_v+rec_v.addr'length;
rec_v.byteena := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.byteena'length);
len_v := len_v+rec_v.byteena'length;
return rec_v;
end function unpack_ddr_write_cmd;

----
-- DDR read command to be sent to async FIFO before going to external bus
-- We would like to go through async FIFO since external bus is in a different clock domain
-- ddr_read_cmd_t is the read request format that get pushed to the async FIFO
-- Also define corresponding pack/unpack function for this record
------
type ddr_read_cmd_t is
record
   addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
   burstlen:unsigned(ddr_burstlen_width_c-1 downto 0);
   read:std_logic;
   burstbegin:std_logic;
end record;

signal dummy2:ddr_read_cmd_t;

constant ddr_read_cmd_length_c:integer:=( dummy2.addr'length+ -- ddr_read_cmd_t.addr
                                          dummy2.burstlen'length+ -- ddr_read_cmd_t.burstlen
                                          1+ -- ddr_read_cmd_t.read
                                          1 -- ddr_read_cmd_t.burstbegin
                                          );

subtype ddr_read_cmd_flat_t is std_logic_vector(ddr_read_cmd_length_c-1 downto 0);

function pack_ddr_read_cmd(rec_in: ddr_read_cmd_t) return ddr_read_cmd_flat_t is
variable len_v:integer;
variable q_v:ddr_read_cmd_flat_t;
begin
len_v:=0;
q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.addr'length) := rec_in.addr;
len_v := len_v+rec_in.addr'length;
q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burstlen'length) := std_logic_vector(rec_in.burstlen);
len_v := len_v+rec_in.burstlen'length;
q_v(q_v'length-len_v-1) := rec_in.read;
len_v := len_v+1;
q_v(q_v'length-len_v-1) := rec_in.burstbegin;
len_v := len_v+1;
return q_v;
end function pack_ddr_read_cmd;

function unpack_ddr_read_cmd(q_in: ddr_read_cmd_flat_t) return ddr_read_cmd_t is
variable len_v:integer;
variable rec_v:ddr_read_cmd_t;
begin
len_v := 0;
rec_v.addr := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.addr'length);
len_v := len_v+rec_v.addr'length;
rec_v.burstlen := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burstlen'length));
len_v := len_v+rec_v.burstlen'length;
rec_v.read := q_in(q_in'length-len_v-1);
len_v := len_v+1;
rec_v.burstbegin := q_in(q_in'length-len_v-1);
len_v := len_v+1;
return rec_v;
end function unpack_ddr_read_cmd;

---- Constants
----
constant read_record_fifo_depth_c:integer:=6;
constant read_record_fifo_size_c:integer:=64;
constant write_data_fifo_depth_c:integer:=4;
constant write_data_fifo_size_c:integer:=(2**write_data_fifo_depth_c);

constant all_ones_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_ones2_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_zeros_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'0');
constant all_zeros2_c:std_logic_vector(ddr_data_byte_width_c-1 downto 0):=(others=>'0');
constant all_zeros3_c:std_logic_vector(ddr_bus_width_c-1 downto 0):=(others=>'0');

subtype read_record_t is std_logic_vector((ddr_vector_depth_c+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+3+fork_max_c+1+2*data_width_c)-1 downto 0);
SIGNAL read_burstlen_r:burstlen_t;
SIGNAL write_burstlen_r:burstlen_t;
SIGNAL next_read_burstlen:burstlen_t;
SIGNAL next_write_burstlen:burstlen_t;
SIGNAL burstbegin:std_logic;
SIGNAL wrburstbegin:STD_LOGIC;
SIGNAL wrburstbegin_r:STD_LOGIC;
SIGNAL read_data_valid:STD_LOGIC;

SIGNAL read_record_write:read_record_t;
SIGNAL read_record_write_r:read_record_t;
SIGNAL read_record_write_ena:STD_LOGIC;
SIGNAL read_record_write_ena_r:STD_LOGIC;
SIGNAL read_record_write_ena_rr:STD_LOGIC;
SIGNAL read_record_write_ena_rrr:STD_LOGIC;
SIGNAL read_record_read_ena:STD_LOGIC;
SIGNAL read_record_read_empty:STD_LOGIC;
SIGNAL read_record_read_empty_r:STD_LOGIC;
SIGNAL read_record_read_full:STD_LOGIC;
SIGNAL read_record_read_full_r:STD_LOGIC;
SIGNAL read_record_read:read_record_t;

SIGNAL read_data_read_ena:STD_LOGIC;
SIGNAL read_data_read_ena_2:STD_LOGIC;
SIGNAL read_data_read_empty:STD_LOGIC;
SIGNAL read_data_read:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL read_wait_request:std_logic;

SIGNAL read_data_read_r:std_logic_vector(2*ddr_data_width_c-1 downto 0);
SIGNAL read_data_read_valid_r:std_logic_vector(1 downto 0);

SIGNAL resetn:STD_LOGIC;
SIGNAL read2:STD_LOGIC;
SIGNAL write2:STD_LOGIC;

SIGNAL ddr_read:STD_LOGIC;
SIGNAL ddr_write:STD_LOGIC;
SIGNAL byteenable:STD_LOGIC_VECTOR(2*ddr_data_byte_width_c-1 downto 0);
SIGNAL ddr_write_cmd:ddr_write_cmd_t;
SIGNAL write_data_write:ddr_write_cmd_t;
SIGNAL write_data_write_r:ddr_write_cmd_t;
SIGNAL wdata:STD_LOGIC_VECTOR(ddr_write_cmd_length_c+ddr_data_width_c-1 downto 0);
SIGNAL write_data_write_ena:STD_LOGIC;
SIGNAL write_data_write_ena_r:STD_LOGIC;
SIGNAL write_data_write_ena_rr:STD_LOGIC;
SIGNAL write_data_write_ena_rrr:STD_LOGIC;
SIGNAL write_data_write_ena_rrrr:STD_LOGIC;
SIGNAL write_data_read_ena:STD_LOGIC;
SIGNAL write_data_read_empty:STD_LOGIC;
SIGNAL write_data_read_empty_r:STD_LOGIC;
SIGNAL write_data_write_full:STD_LOGIC;
SIGNAL write_data_write_full_r:STD_LOGIC;
SIGNAL write_data_write_usedw:std_logic_vector(write_data_fifo_depth_c-1 downto 0);
SIGNAL write_data_read:STD_LOGIC_VECTOR(ddr_write_cmd_length_c+ddr_data_width_c-1 downto 0);
SIGNAL write_burst_write_ena:std_logic;
SIGNAL write_burst_write:std_logic_vector(burstlen_t'length+ddr_bus_width_c-1 downto 0);
SIGNAL write_burst_read_ena:std_logic;
SIGNAL write_burstlen:burstlen_t;
SIGNAL write_burstbegin:std_logic;
SIGNAL write_ddr_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);


SIGNAL write_data:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 downto 0);
SIGNAL write_data_r:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 downto 0);
SIGNAL write_data_2_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL byteenable_r:STD_LOGIC_VECTOR(2*ddr_data_byte_width_c-1 downto 0);
SIGNAL beginburst_r:STD_LOGIC;
SIGNAL wr_ddr_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL rd_ddr_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL write_next_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL wr_ddr_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL wr_ddr_burstlen:burstlen_t;
SIGNAL rd_ddr_burstlen:burstlen_t;
SIGNAL wr_ddr_burstlen_r:burstlen_t;
SIGNAL read_data_ready:std_logic;

SIGNAL read_burstlen2:burstlen_t;
SIGNAL read_burstlen3:burstlen_t;
SIGNAL write_burstlen2:burstlen_t;
SIGNAL write_burstlen3:burstlen_t;
SIGNAL read_addr:STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);
SIGNAL write_addr:STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);

SIGNAL read_piggyback:STD_LOGIC;
SIGNAL read_piggyback_r:STD_LOGIC;

SIGNAL read_data:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL read_pause_r:STD_LOGIC;
SIGNAL read_pause_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL read_pause_burstlen_r:unsigned(ddr_burstlen_width_c-1 downto 0);

SIGNAL w_x1:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_x2:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_x4:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_x8:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);

SIGNAL w_mask1:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask2:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask3:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask4:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask5:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask6:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask7:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask8:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);


SIGNAL write_piggyback:STD_LOGIC;
SIGNAL write_complete:STD_LOGIC;
SIGNAL write_over_complete:STD_LOGIC;
SIGNAL write_flush_r:STD_LOGIC;
SIGNAL write_can_piggyback_r:STD_LOGIC;
SIGNAL write_busy:STD_LOGIC;


SIGNAL read_fifo_read_ena:std_logic;
SIGNAL read_fifo_read_empty:std_logic;
SIGNAL read_fifo_write_ena:std_logic;
SIGNAL read_fifo_write_full:std_logic;
SIGNAL read_fifo_write:ddr_read_cmd_t;
SIGNAL read_fifo_read:ddr_read_cmd_t;
SIGNAL read_fifo_write_flat:std_logic_vector(ddr_read_cmd_length_c-1 downto 0);
SIGNAL read_fifo_read_flat:std_logic_vector(ddr_read_cmd_length_c-1 downto 0);

-- read pending counter needs to have large range than actual max value in order
-- to handle wrap around arithmetic

SIGNAL read_complete_r:unsigned(4*ddr_max_read_pend_depth_c-1 downto 0);
SIGNAL read_request_r:unsigned(4*ddr_max_read_pend_depth_c-1 downto 0);
SIGNAL read_pending_full_r:std_logic;


BEGIN
----------------------------------------------------------


-- DDR RX ---
GEN_READ_FIFO: if RX_ENABLE=true generate
read_data_fifo_i: dcfifo
    GENERIC MAP (
		intended_device_family => "Cyclone V",
		lpm_numwords => ddr_max_read_pend_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => ddr_data_width_c,
		lpm_widthu => ddr_max_read_pend_depth_c,
		overflow_checking => "ON",
		rdsync_delaypipe => 5,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 5
    )
    PORT MAP (	
		data => ddr_readdata_in,
		wrclk => dclock_in,
		wrreq => ddr_readdatavalid_in,
		wrfull => open,
        wrusedw => open,

		rdclk => clock_in,
		rdreq => read_data_read_ena_2,
		q => read_data_read,
		rdempty => read_data_read_empty
	);


read_fifo_read_ena <= '1' when ((read_fifo_read_empty='0') and ddr_wait_request_in='0') else '0';
read_fifo_write_ena <= '1' when read_fifo_write.read='1' and read_fifo_write_full='0' else '0'; 

ddr_rx_fifo_i: dcfifo
    GENERIC MAP (    
		intended_device_family => "Cyclone V",
		lpm_numwords => ddr_rx_fifo_size_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => ddr_read_cmd_length_c,
		lpm_widthu => ddr_rx_fifo_depth,
		overflow_checking => "ON",
		rdsync_delaypipe => 5,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 5
	)
    PORT MAP (
		data => read_fifo_write_flat,
		wrclk => clock_in,
		wrreq => read_fifo_write_ena,
		wrfull => read_fifo_write_full,
        wrusedw => open,

		rdclk => dclock_in,
		rdreq => read_fifo_read_ena,
		q => read_fifo_read_flat,
		rdempty => read_fifo_read_empty
	);

read_fifo_read <= unpack_ddr_read_cmd(read_fifo_read_flat);
read_fifo_write_flat <= pack_ddr_read_cmd(read_fifo_write);

end GENERATE GEN_READ_FIFO;

NO_GEN_READ_FIFO: if RX_ENABLE=false generate
read_data_read_empty <= '1';
read_data_read <= (others=>'0');
read_fifo_read <= ((others=>'0'),(others=>'0'),'0','0');
read_fifo_write_full <= '0';
read_fifo_read_empty <= '1';
end generate NO_GEN_READ_FIFO;

-- DDR TX ---

wdata <= pack_ddr_write_cmd(write_data_write_r) & write_data_2_r;
ddr_write <= (not write_data_read_empty);
write_data_read_ena <= (not ddr_wait_request_in) and ddr_write;
ddr_write_out <= ddr_write;
ddr_writedata_out <= write_data_read(ddr_data_width_c-1 downto 0);
ddr_write_cmd <= unpack_ddr_write_cmd(write_data_read(write_data_read'length-1 downto ddr_data_width_c));
ddr_byteenable_out <= ddr_write_cmd.byteena;
write_burstbegin <= ddr_write and ddr_write_cmd.burstbegin;
write_ddr_addr <= ddr_write_cmd.addr;
write_burstlen <= ddr_write_cmd.burstlen;


GEN_WRITE_FIFO: if TX_ENABLE=true generate

write_data_write_full <= '1' when unsigned(write_data_write_usedw) >= to_unsigned(write_data_fifo_size_c-4,write_data_fifo_depth_c) else '0';

write_data_fifo_i: dcfifo
    GENERIC MAP (
		intended_device_family => "Cyclone V",
		lpm_numwords => write_data_fifo_size_c,
		lpm_showahead => "ON",
		lpm_type => "dcfifo",
		lpm_width => ddr_write_cmd_length_c+ddr_data_width_c,
		lpm_widthu => write_data_fifo_depth_c,
		overflow_checking => "ON",
		rdsync_delaypipe => 5,
		underflow_checking => "ON",
		use_eab => "ON",
		wrsync_delaypipe => 5
    )
    PORT MAP (
		data => wdata,
		wrclk => clock_in,
		wrreq => write_data_write_ena_r,
		wrfull => open,
        wrusedw => write_data_write_usedw,

		rdclk => dclock_in,
		rdreq => write_data_read_ena,
		q => write_data_read,
		rdempty => write_data_read_empty
    );

end GENERATE GEN_WRITE_FIFO;

NO_GEN_WRITE_FIFO: if TX_ENABLE=false generate
write_data_write_usedw <= (others=>'0');
write_data_read_empty <= '1';
write_data_read <= (others=>'0');
write_data_write_full <= '0';
end generate NO_GEN_WRITE_FIFO;

--------
-- Pack DDR read request to send to async FIFO
------
process(read_pause_r,read_pause_addr_r,read_pause_burstlen_r,ddr_read,rd_ddr_addr,rd_ddr_burstlen,write_ddr_addr,write_burstlen,burstbegin,write_burstbegin)
variable addr_v:std_logic_vector(ddr_bus_width_c-1 downto 0);
variable burstlen_v:unsigned(ddr_burstlen_width_c-1 downto 0);
variable read_v:std_logic;
variable burstbegin_v:std_logic;
begin
   if read_pause_r='1' then
      addr_v := read_pause_addr_r;
      burstlen_v := read_pause_burstlen_r;
      read_v :='1';
   else
      addr_v := rd_ddr_addr;
      burstlen_v := rd_ddr_burstlen(ddr_burstlen_width_c-1 downto 0);
      read_v := ddr_read;
   end if;
   burstbegin_v := (burstbegin and ddr_read);
   read_fifo_write.addr <= addr_v;
   read_fifo_write.burstlen <= burstlen_v;
   read_fifo_write.read <= read_v;
   read_fifo_write.burstbegin <= burstbegin_v;
end process;

process(read_fifo_read,read_fifo_read_empty,read_pause_r,read_pause_addr_r,read_pause_burstlen_r,ddr_read,rd_ddr_addr,rd_ddr_burstlen,write_ddr_addr,write_burstlen,burstbegin,write_burstbegin)
begin
if RX_ENABLE=true then
   -- Unpack DDR read requests from async FIFO and forward the request to external DDR bus
   ddr_addr_out <= read_fifo_read.addr;
   ddr_burstlen_out <= read_fifo_read.burstlen;
   ddr_read_out <= read_fifo_read.read and (not read_fifo_read_empty);
   ddr_burstbegin_out <= read_fifo_read.burstbegin and (not read_fifo_read_empty);
else
   -- Unpack DDR write requests from async FIFO and forward the request to external DDR bus
   ddr_addr_out <= write_ddr_addr;
   ddr_burstlen_out <= write_burstlen(ddr_burstlen_width_c-1 downto 0);
   ddr_read_out <= '0';
   ddr_burstbegin_out <= write_burstbegin;
end if;
end process;








----------------------------------------------------------

---- FIFO for DDR read access

GEN_READ_RECORD: if RX_ENABLE=true generate
read_record_fifo_i: scfifo
    GENERIC MAP (
        add_ram_output_register => "ON",
        almost_full_value => read_record_fifo_size_c-ddr_max_burstlen_c-5,
        intended_device_family => "Cyclone V",
        lpm_numwords => read_record_fifo_size_c,
        lpm_showahead => "ON",
        lpm_type => "scfifo",
        lpm_width => read_record_t'length,
        lpm_widthu => read_record_fifo_depth_c,
        overflow_checking => "ON",
        underflow_checking => "ON",
        use_eab => "ON"
    )
    PORT MAP (
        clock => clock_in,
        wrreq => read_record_write_ena_r,
        aclr => resetn,
        data => read_record_write_r,

        rdreq => read_record_read_ena,
        usedw => open,
        empty => read_record_read_empty,
        full => open,
        q => read_record_read,
        almost_full => read_record_read_full
    );

end GENERATE GEN_READ_RECORD;

NO_GEN_READ_RECORD: if RX_ENABLE=false generate
read_record_read_empty <= '1';
read_record_read <= (others=>'0');
read_record_read_full <= '0';
end generate NO_GEN_READ_RECORD;

-- TODO
read_addr <= read_addr_in;
write_addr <= write_addr_in;

--- FIFO for write access

-- Check if we can piggyback this write request with the current burst left over.

write_piggyback <= '1' when (TX_ENABLE=true) and (write_in='1' and 
                            write_burstlen_in /= to_unsigned(0,burstlen_t'length) and 
                            (write_data_write_full_r='0' and read_pause_r='0') and
                            write_burstlen_r=to_unsigned(0,burstlen_t'length) and 
                            write_flush_r='0' and
                            write_can_piggyback_r='1')
                   else '0';


-- Would the current transmit request complete the current word.

write_complete <= '1' when (TX_ENABLE=true) and ((unsigned('0' & write_addr(ddr_vector_depth_c-1 downto 0))+unsigned('0' & write_vector_in)+to_unsigned(1,ddr_vector_depth_c+1))>=to_unsigned(ddr_vector_width_c,ddr_vector_depth_c+1))
                  else '0';

-- Would the current transmit request spilled over to next word?
write_over_complete <= '1' when (TX_ENABLE=true) and ((unsigned('0' & write_addr(ddr_vector_depth_c-1 downto 0))+unsigned('0' & write_vector_in)+to_unsigned(1,ddr_vector_depth_c+1))>to_unsigned(ddr_vector_width_c,ddr_vector_depth_c+1))
                  else '0';

write_data_write_ena <= '1' when (TX_ENABLE=true) and 
                                 (((write2='1' and 
                                 ((next_write_burstlen=to_unsigned(0,burstlen_t'length) and write_burstlen_in=to_unsigned(1,write_burstlen_in'length)) or write_complete='1')) 
                                 or
                                 (write_piggyback='1' and (write_burstlen_in=to_unsigned(1,write_burstlen_in'length) or write_complete='1')) or
                                 (write_flush_r='1')) and
                                 (write_data_write_full_r='0'))
                                 else '0';



wrburstbegin <= (burstbegin or wrburstbegin_r);


-- Transfer received data back to application....
read_data_ready_out <= read_data_ready;
read_data_valid_vm_out <= read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2+fork_max_c+1-1);
read_fork_out <= read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2+fork_max_c-1 downto ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2);
read_data_ready <= (read_data_read_valid_r(1) and (read_data_read_valid_r(0) or (not read_record_read((ddr_vector_depth_c+1+ddr_vector_depth_c))))) and (not read_record_read_empty);
read_data_valid <= read_data_ready and (not read_data_wait_in);
--read_data_valid <= read_data_read_valid_r(1) and (not read_record_read_empty);
read_record_read_ena <= read_data_valid;
read_data_valid_out <= read_data_valid;
read_data_read_ena <= '1' when 
                  read_data_valid='1' and 
                  (
                  read_record_read(ddr_vector_depth_c)='1' or  -- end of burst
                  read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c)='1' or  -- access spread over burst boundary
                  read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+1)='1' -- Read end of the burst word
                  ) 
                  else '0';

-- Block read if write transaction is in progress.

write_busy <= '0' when (write_data_write_ena_r='0' and write_data_write_ena_rr='0' and write_data_write_ena_rrr='0' and write_data_write_ena_rrrr='0' and write_data_read_empty_r='1' and write_burstlen_r=to_unsigned(0,burstlen_t'length)) else '1';
read_wait_request <= '1' when (read_record_read_full_r='1') or write_busy='1' or read_pause_r='1' else '0';
read2 <= read_in when (RX_ENABLE=true) and (read_wait_request='0') else '0';
read_wait_request_out <= read_wait_request;

-- Only allow write if read operation are all flushed...

write2 <= write_in when (TX_ENABLE=true) and 
                        (write_data_write_full_r='0' and
                        read_pause_r='0' and
                        write_burstlen_in /= to_unsigned(0,burstlen_t'length) and
                        write_flush_r='0' and
                        write_piggyback='0') 
                        else '0';

burstbegin <= '1' when ((read2='1' and read_burstlen_r=to_unsigned(0,burstlen_t'length)) or 
                       (write2='1' and write_burstlen_r=to_unsigned(0,burstlen_t'length))) 
               else '0';
ddr_read <= '1' when (burstbegin='1' and read2='1') else '0';

-- Below are the conditions that may prevent a DDR write to be accepted...
write_wait_request_out <= '1' when (TX_ENABLE=true) and
                              ((write_data_write_full_r='1') or (read_pause_r='1') or (write_flush_r='1'))
							  else '0';


resetn <= not reset_in;

process(write_flush_r,byteenable,wr_ddr_addr,wr_ddr_burstlen,wrburstbegin,write_next_addr_r)
begin
if TX_ENABLE=false then
   write_data_write <= ('0',(others=>'0'),(others=>'0'),(others=>'0'));
else
if write_flush_r='0' then
   write_data_write.burstbegin <= wrburstbegin; 
   write_data_write.burstlen <= wr_ddr_burstlen; 
   write_data_write.addr <= wr_ddr_addr;
   write_data_write.byteena <= byteenable(ddr_data_byte_width_c-1 downto 0);
else
   write_data_write.burstbegin <= '0';
   write_data_write.burstlen <= to_unsigned(1,burstlen_t'length);
   write_data_write.addr <= write_next_addr_r;
   write_data_write.byteena <= byteenable(ddr_data_byte_width_c-1 downto 0);
end if;
end if;
end process;


------------------
-- Align burstlen to address boundary
------------------

process(read_burstlen_in,read_vector_in,read_addr)
variable burstlen_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable addr_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp3_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp4_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp5_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp6_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
begin

assert ddr_vector_width_c>=8 report "Invalid DDR vector width" severity note;
if RX_ENABLE=false then
read_burstlen2 <= (others=>'0');
read_burstlen3 <= (others=>'0');
else
burstlen_v := resize(read_burstlen_in,burstlen_v'length);
addr_v := resize(unsigned(read_addr(ddr_vector_depth_c-1 downto 0)),addr_v'length);
if unsigned(read_vector_in)=to_unsigned(1,ddr_vector_depth_c) then 
   if burstlen_v > to_unsigned((ddr_vector_width_c/2)*(ddr_max_burstlen_c-1),burstlen_v'length) then
      burstlen_v := to_unsigned((ddr_vector_width_c/2)*(ddr_max_burstlen_c-1),burstlen_v'length);
   end if;
   temp_v := burstlen_v sll 1;
elsif unsigned(read_vector_in)=to_unsigned(3,ddr_vector_depth_c) then
   if burstlen_v > to_unsigned((ddr_vector_width_c/4)*(ddr_max_burstlen_c-1),burstlen_v'length) then
      burstlen_v := to_unsigned((ddr_vector_width_c/4)*(ddr_max_burstlen_c-1),burstlen_v'length);
   end if;
   temp_v := burstlen_v sll 2;
elsif unsigned(read_vector_in)=to_unsigned(7,ddr_vector_depth_c) then -- vsize=1
   if burstlen_v > to_unsigned((ddr_vector_width_c/8)*(ddr_max_burstlen_c-1),burstlen_v'length) then
      burstlen_v := to_unsigned((ddr_vector_width_c/8)*(ddr_max_burstlen_c-1),burstlen_v'length);
   end if;
   temp_v := burstlen_v sll 3;
else
   if burstlen_v > to_unsigned(ddr_vector_width_c*(ddr_max_burstlen_c-1),burstlen_v'length) then
      burstlen_v := to_unsigned(ddr_vector_width_c*(ddr_max_burstlen_c-1),burstlen_v'length);
   end if;
   temp_v := burstlen_v;
end if;
temp3_v := temp_v+addr_v+to_unsigned(ddr_vector_width_c-1,temp3_v'length);
temp4_v := temp3_v srl ddr_vector_depth_c;
read_burstlen3 <= resize(temp4_v,read_burstlen3'length);
read_burstlen2 <= resize(burstlen_v,read_burstlen2'length);
end if;
end process;


process(reset_in,clock_in)
begin
    if reset_in = '0' then
       read_pause_r <= '0';
       read_pause_burstlen_r <= (others=>'0');
       read_pause_addr_r <= (others=>'0');
       read_record_read_full_r <= '0';
    else
        if clock_in'event and clock_in='1' then
           read_record_read_full_r <= read_record_read_full or read_pending_full_r;
           if burstbegin='1' and read_fifo_write_full='1' and ddr_read='1' then
              read_pause_r <= '1';
              read_pause_burstlen_r <= rd_ddr_burstlen(ddr_burstlen_width_c-1 downto 0);
              read_pause_addr_r <= rd_ddr_addr;
           elsif read_fifo_write_full='0' then
              read_pause_r <= '0';
           end if;
        end if;
    end if;
end process;

process(write_vector_in,write_addr,write_burstlen_in,write_burstlen2_in,write_burstlen3_in,write_piggyback)
variable temp2_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp3_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp4_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp5_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable temp6_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
variable write_vector_v:unsigned(ddr_vector_depth_c-1 downto 0);
begin
if TX_ENABLE=false then
write_burstlen2 <= (others=>'0');
write_burstlen3 <= (others=>'0');
else
write_burstlen2 <= write_burstlen3_in;
temp2_v := resize(unsigned(write_addr(ddr_vector_depth_c-1 downto 0)),temp2_v'length);
temp3_v := write_burstlen2_in+temp2_v+resize(unsigned(all_ones2_c),temp2_v'length);
temp4_v := temp3_v srl ddr_vector_depth_c;
write_burstlen3 <= resize(temp4_v,write_burstlen3'length);
end if;
end process;


--
-- Transfer read data to the outside
-- start_v is used to zero out beginning of data. For example when start_v=-1 then first byte will be zapped to zero
-- end_v is used to zero out end of data. For example when end_v=4 then only byte#0->byte#3 are kept and byte#4->byte#7 are zapped to zero
-- This is useful since in AI application, read address are not work alined and convolutional neural network also has padding option
-- in the reading of feature map. For example when feature map padding is 1, then we do a read at address-1 but with start_v=-1 then
-- the padding byte will be set to zero.
-- end_v is useful to enable wide vector read even when address and length of the read are not multiple of bus width...
 
process(read_record_read,read_data)
variable start_v:signed(ddr_vector_depth_c downto 0);
variable end_v:unsigned(ddr_vector_depth_c downto 0);
variable pos_v:integer;
variable filler_v:std_logic_vector(2*data_width_c-1 downto 0);
begin
if RX_ENABLE=false then
   read_data_out <= (others=>'0');
else
start_v := signed(read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+2-1 downto ddr_vector_depth_c+1+ddr_vector_depth_c+2));
end_v := unsigned(read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2-1 downto ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+2));
pos_v := ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2+fork_max_c+1;
filler_v := read_record_read(pos_v+filler_v'length-1 downto pos_v);
FOR I in 0 to ddr_vector_width_c-1 LOOP
   if start_v+to_signed(I,ddr_vector_depth_c+1) >= 0 and
      end_v > to_unsigned(I,ddr_vector_depth_c+1) then
      read_data_out(data_width_c*(I+1)-1 downto data_width_c*I) <= read_data(data_width_c*(I+1)-1 downto data_width_c*I);
   else
     if (I rem 2)=0 then
        read_data_out(data_width_c*(I+1)-1 downto data_width_c*I) <= filler_v(data_width_c-1 downto 0);
     else
        read_data_out(data_width_c*(I+1)-1 downto data_width_c*I) <= filler_v(2*data_width_c-1 downto data_width_c);
     end if;
   end if;
end loop;
end if;
end process;

------------------
--- Record read2 transaction and then save in fifo
-------------------

process(read_record_read,read_data_read_r)
begin
if RX_ENABLE=false then
   read_data(ddr_data_width_c-1 downto 0) <= (others=>'0');
else
    case read_record_read(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
        when "000"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(8*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8);
        when "001"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(9*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8);
        when "010"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(10*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8);
        when "011"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(11*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8);
        when "100"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(12*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8);
        when "101"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(13*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8);
        when "110"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(14*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8);
        when others=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(15*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8);
    end case;
end if;
end process;


process(next_read_burstlen,read_burstlen_in,read_addr,read2,read_wait_request,read_vector_in,read_start_in,read_end_in,read_fork_in,read_vm_in)
variable temp_v:unsigned(ddr_vector_depth_c downto 0);
variable end_of_burst_v:std_logic;
variable spread_v:std_logic;
variable end_of_word_v:std_logic;
variable pos_v:integer;
begin
if RX_ENABLE=false then
   read_record_write <= (others=>'0');
   read_piggyback <= '0';
   read_record_write_ena <= '0';
else
   read_record_write(ddr_vector_depth_c-1 downto 0) <= read_addr(ddr_vector_depth_c-1 downto 0); -- Read address
   if(next_read_burstlen=to_unsigned(0,burstlen_t'length)) then  -- Is this end of burst
      end_of_burst_v := '1';
   else
      end_of_burst_v := '0';
   end if;

   temp_v:=resize(unsigned(read_addr(ddr_vector_depth_c-1 downto 0)),ddr_vector_depth_c+1)+
           resize(unsigned(read_vector_in),ddr_vector_depth_c+1);
   read_record_write(ddr_vector_depth_c+1+ddr_vector_depth_c-1 downto ddr_vector_depth_c+1) <= read_vector_in; -- Vector length
   spread_v := temp_v(ddr_vector_depth_c); -- Does it spread into next word?

   if (unsigned(read_addr(ddr_vector_depth_c-1 downto 0))+unsigned(read_vector_in)=unsigned(all_ones_c)) then -- Reach end of word ?
      end_of_word_v := '1';
   else
      end_of_word_v := '0';
   end if;

   if end_of_burst_v='0' then
      read_record_write(ddr_vector_depth_c) <= '0';
      read_piggyback <= '0';
   else
      if read_burstlen_in > to_unsigned(1,burstlen_t'length) then
         -- Next read a is continuity read....
         -- Check if we can reuse the left over from current burst
         if spread_v='1' or end_of_word_v='0' then
            read_record_write(ddr_vector_depth_c) <= '0'; -- Not done. To be continue since there is some left over for next read
            read_piggyback <= '1';
         else
            read_record_write(ddr_vector_depth_c) <= '1'; -- Done bit. Advance to next read word received 
            read_piggyback <= '0';
         end if;
      else
         read_record_write(ddr_vector_depth_c) <= '1'; -- Done bit. Advance to next read word received 
         read_piggyback <= '0';
      end if;
   end if;
   pos_v := ddr_vector_depth_c+1+ddr_vector_depth_c;
   read_record_write(pos_v) <= spread_v;
   pos_v := pos_v+1;
   read_record_write(pos_v) <= end_of_word_v;
   pos_v := pos_v+1;
   read_record_write(pos_v+read_start_in'length-1 downto pos_v) <= std_logic_vector(read_start_in);
   pos_v := pos_v+read_start_in'length;
   read_record_write(pos_v+read_end_in'length-1 downto pos_v) <= std_logic_vector(read_end_in);
   pos_v := pos_v+read_end_in'length;
   read_record_write(pos_v+read_fork_in'length-1 downto pos_v) <= read_fork_in;
   pos_v := pos_v+read_fork_in'length;
   read_record_write(pos_v) <= read_vm_in;
   pos_v := pos_v+1;
   read_record_write(pos_v+read_filler_data_in'length-1 downto pos_v) <= read_filler_data_in;
   pos_v := pos_v+read_filler_data_in'length;
   read_record_write_ena <= read2 and (not read_wait_request);
end if;
end process;


-------
--- Calculate burst address and count
-------

process(read2,read_addr,read_burstlen2,read_burstlen3,read_vector_in,read_piggyback_r)
variable ddr_addr_v:std_logic_vector(ddr_bus_width_c-1 downto 0);
begin
if RX_ENABLE=false then
       rd_ddr_burstlen <= (others=>'0');
       rd_ddr_addr <= (others=>'0');
else
    ddr_addr_v(ddr_bus_width_c-1 downto dp_addr_width_c+data_byte_width_depth_c) := (others=>'0');
    ddr_addr_v(dp_addr_width_c+data_byte_width_depth_c-1 downto ddr_vector_depth_c+data_byte_width_depth_c) := read_addr(dp_addr_width_c-1 downto ddr_vector_depth_c);
    ddr_addr_v(ddr_vector_depth_c+data_byte_width_depth_c-1 downto 0) := (others=>'0');
    if read_piggyback_r='0' then
       rd_ddr_burstlen <= unsigned(read_burstlen3);
       rd_ddr_addr <= std_logic_vector(unsigned(ddr_addr_v));
    else
       rd_ddr_burstlen <= unsigned(read_burstlen3)-to_unsigned(1,read_burstlen3'length);
       rd_ddr_addr <= std_logic_vector(unsigned(ddr_addr_v) + to_unsigned(ddr_data_width_c/8,rd_ddr_addr'length));    
    end if;
end if;
end process;


process(write_addr,write_burstlen2,write_burstlen3,
       wrburstbegin_r,wr_ddr_burstlen_r,wr_ddr_addr_r,write_vector_in)
variable write_burstlen_v:std_logic_vector(burstlen_t'length-1 downto 0);
variable ddr_addr_v:std_logic_vector(ddr_bus_width_c-1 downto 0);
begin
if TX_ENABLE=false then
    wr_ddr_burstlen <= (others=>'0');
    wr_ddr_addr <= (others=>'0');
else
    if wrburstbegin_r='0' then
       ddr_addr_v(ddr_bus_width_c-1 downto dp_addr_width_c+data_byte_width_depth_c) := (others=>'0');
       ddr_addr_v(dp_addr_width_c+data_byte_width_depth_c-1 downto ddr_vector_depth_c+data_byte_width_depth_c) := write_addr(dp_addr_width_c-1 downto ddr_vector_depth_c);
       ddr_addr_v(ddr_vector_depth_c+data_byte_width_depth_c-1 downto 0) := (others=>'0');
       wr_ddr_burstlen <= unsigned(write_burstlen3);
       wr_ddr_addr <= std_logic_vector(unsigned(ddr_addr_v));
    else
       wr_ddr_burstlen <= wr_ddr_burstlen_r;
       ddr_addr_v := wr_ddr_addr_r;
       wr_ddr_addr <= ddr_addr_v;
    end if;
end if;
end process;

------------------
-- Calculate next burstlen after current transaction
------------------

process(read2,write2,read_burstlen_r,write_burstlen_r,read_wait_request,read_burstlen2,write_burstlen2)
begin
if RX_ENABLE=false then
   next_read_burstlen <= (others=>'0');
else
if read2='1' then
   if read_burstlen_r=to_unsigned(0,burstlen_t'length) then
      if read_wait_request='0' then
         next_read_burstlen <= read_burstlen2-1;
      else
         next_read_burstlen <= read_burstlen_r;
      end if;
   else
      if read_wait_request='0' then
         next_read_burstlen <= read_burstlen_r-1;
      else
         next_read_burstlen <= read_burstlen_r;
      end if;
   end if;
else
   next_read_burstlen <= read_burstlen_r;
end if;
end if;

if TX_ENABLE=false then
   next_write_burstlen <= (others=>'0');
else
if write2='1' then
   if write_burstlen_r=to_unsigned(0,burstlen_t'length) then
      next_write_burstlen <= write_burstlen2-1;
   else
      next_write_burstlen <= write_burstlen_r-1;
   end if;
else
   next_write_burstlen <= write_burstlen_r;
end if;
end if;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        read_burstlen_r <= (others=>'0');
        write_burstlen_r <= (others=>'0');
        write_data_write_ena_r <= '0';
        write_data_write_ena_rr <= '0';
        write_data_write_ena_rrr <= '0';
	    write_data_write_ena_rrrr <= '0';
        write_data_read_empty_r <= '0';
        write_data_write_r <= ('0',(others=>'0'),(others=>'0'),(others=>'0'));
        read_piggyback_r <= '0';
        read_record_write_r <= (others=>'0');
        read_record_write_ena_r <= '0';
        read_record_write_ena_rr <= '0';
        read_record_write_ena_rrr <= '0';
        write_next_addr_r <= (others=>'0');
        write_can_piggyback_r <= '0';
        write_flush_r <= '0';
        write_data_write_full_r <= '0';
        read_record_read_empty_r <= '1';
    else
        if clock_in'event and clock_in='1' then

            read_record_read_empty_r <= read_record_read_empty;
            write_data_write_full_r <= write_data_write_full;

            read_record_write_r <= read_record_write;
            read_record_write_ena_r <= read_record_write_ena;
            read_record_write_ena_rr <= read_record_write_ena_r;
            read_record_write_ena_rrr <= read_record_write_ena_rr;
            read_burstlen_r <= next_read_burstlen;
            write_burstlen_r <= next_write_burstlen;
            write_data_write_ena_r <= write_data_write_ena;
            write_data_write_ena_rr <= write_data_write_ena_r;
            write_data_write_ena_rrr <= write_data_write_ena_rr;
            write_data_write_ena_rrrr <= write_data_write_ena_rrr;
            write_data_read_empty_r <= write_data_read_empty;
            write_data_write_r <= write_data_write;
            if write_data_write_ena='1' then
               if write_piggyback='1' or write_flush_r='1' then
                  write_can_piggyback_r <= '0';
               else
                  write_can_piggyback_r <= write_over_complete;
               end if;
            elsif write2='1' then
               write_can_piggyback_r <= '1';
            end if;
            if write_data_write_ena='1' then
               if write_flush_r='0' then
                  if write_burstlen_in=to_unsigned(1,burstlen_t'length) and write_over_complete='1' then
                     write_flush_r <= '1';
                  else
                     write_flush_r <= '0';
                  end if;
               else
                  write_flush_r <= '0';
               end if;
            end if;
            if write_data_write_ena='1' then
               write_next_addr_r <= std_logic_vector(unsigned(wr_ddr_addr)+to_unsigned(2**(ddr_vector_depth_c+data_byte_width_depth_c),write_next_addr_r'length));
            end if;
            if read_record_write_ena='1' then
               read_piggyback_r <= read_piggyback;
            end if;
        end if;
    end if;
end process;


-- VUONG BURST
process(write_vector_in)
begin
if TX_ENABLE=false then
   w_x1 <= (others=>'0');
   w_x2 <= (others=>'0');
   w_x4 <= (others=>'0');
   w_x8 <= (others=>'0');
else
if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
   w_x1 <= (others=>'1');
   w_x2 <= (others=>'1');
   w_x4 <= (others=>'1');
   w_x8 <= (others=>'0');
elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then
   w_x1 <= (others=>'1');
   w_x2 <= (others=>'1');
   w_x4 <= (others=>'0');
   w_x8 <= (others=>'0');
elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
   w_x1 <= (others=>'1');
   w_x2 <= (others=>'0');
   w_x4 <= (others=>'0');
   w_x8 <= (others=>'0');
else
   w_x1 <= (others=>'1');
   w_x2 <= (others=>'1');
   w_x4 <= (others=>'1');
   w_x8 <= (others=>'1');
end if;
end if;
end process;

w_mask1 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(1,vector_t'length)) else (others=>'0');
w_mask2 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(2,vector_t'length)) else (others=>'0');
w_mask3 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(3,vector_t'length)) else (others=>'0');
w_mask4 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(4,vector_t'length)) else (others=>'0');
w_mask5 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(5,vector_t'length)) else (others=>'0');
w_mask6 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(6,vector_t'length)) else (others=>'0');
w_mask7 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(7,vector_t'length)) else (others=>'0');
w_mask8 <= (others=>'1') when (TX_ENABLE=true) and (write_end_in >= to_unsigned(8,vector_t'length)) else (others=>'0');

process(write2,write_piggyback,write_vector_in,write_addr,write_data_r,write_data_in,byteenable_r,w_x1,w_x2,w_x4,w_x8,
        w_mask1,w_mask2,w_mask3,w_mask4,w_mask5,w_mask6,w_mask7,w_mask8)
begin
if(TX_ENABLE=false) then
   byteenable <= (others=>'0');
else
if(write2='1' or write_piggyback='1') then
    case write_addr(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
        when "000" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8) <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8) <= byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8) <= byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8)  <= byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= byteenable_r(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1  downto 1*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1  downto 0*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "001" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8) <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8) <= byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8) <= byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8) <= byteenable_r(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1  downto 1*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1  downto 0*ddr_data_byte_width_c/8)  <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "010" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8) <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8)  <= byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8) <= byteenable_r(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1  downto 1*ddr_data_byte_width_c/8)  <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "011" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8)  <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= byteenable_r(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "100" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8)  <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= byteenable_r(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "101" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8)  <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8)  <= byteenable_r(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "110" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8)  <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1  downto 14*ddr_data_byte_width_c/8)  <= byteenable_r(15*ddr_data_byte_width_c/8-1  downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when others =>
            byteenable(16*ddr_data_byte_width_c/8-1  downto 15*ddr_data_byte_width_c/8)  <= byteenable_r(16*ddr_data_byte_width_c/8-1  downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1  downto 14*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8)  <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
    end case;
else
   byteenable <= byteenable_r;
end if;
end if;
end process;


process(write_data_r,write2,write_piggyback,write_addr,write_data_in,write_vector_in)
begin
if TX_ENABLE=false then
   write_data <= (others=>'0');
else
write_data <= write_data_r;
if(write2='1' or write_piggyback='1') then
    case write_addr(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
        when "000" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
                write_data(ddr_data_width_c/8+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
                write_data(ddr_data_width_c/1+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "001" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
                write_data(ddr_data_width_c/8+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
                write_data(ddr_data_width_c/1+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "010" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "011" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "100" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "101" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "110" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when others =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
    end case;
end if;
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in = '0' then
    byteenable_r <= (others=>'0');
    wrburstbegin_r <= '0';
    wr_ddr_addr_r <= (others=>'0');
    wr_ddr_burstlen_r <= (others=>'0');
    write_data_r <= (others=>'0');
    write_data_2_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
       if TX_ENABLE=true then
		   if(write_data_write_ena='1') then
			  byteenable_r(ddr_data_byte_width_c-1 downto 0) <= byteenable(2*ddr_data_byte_width_c-1 downto ddr_data_byte_width_c);
			  byteenable_r(2*ddr_data_byte_width_c-1 downto ddr_data_byte_width_c) <= (others=>'0');
			  write_data_r(ddr_data_width_c-1 downto 0) <= write_data(2*ddr_data_width_c-1 downto ddr_data_width_c);
			  write_data_2_r <= write_data(ddr_data_width_c-1 downto 0);
			  wrburstbegin_r <= '0';
			  wr_ddr_addr_r <= (others=>'0');
			  wr_ddr_burstlen_r <= (others=>'0');
		   elsif write2='1' or write_piggyback='1' then
			  write_data_r <= write_data;
			  byteenable_r <= byteenable;
			  if(burstbegin='1') then
				wrburstbegin_r <= burstbegin;
				wr_ddr_addr_r <= wr_ddr_addr;
				wr_ddr_burstlen_r <= wr_ddr_burstlen;
			  end if;
		   end if;
       end if;
    end if;
end if;
end process;

read_data_read_ena_2 <= (not read_data_read_empty) when read_data_read_ena='1' or read_data_read_valid_r(1)='0' or read_data_read_valid_r(0)='0' else '0';

process(reset_in,clock_in)
begin
if reset_in = '0' then
   read_data_read_r <= (others=>'0');
   read_data_read_valid_r <= (others=>'0');
   read_complete_r <= (others=>'0');
   read_request_r <= (others=>'0');   
   read_pending_full_r <= '0';
else
    if clock_in'event and clock_in='1' then
       -- Concatenate consecutive read inorder to read data that are spread between
       -- burst boundaries

       if(read_data_read_ena_2='1') then
          read_complete_r <= read_complete_r+to_unsigned(1,read_complete_r'length);
       end if;
       if read_fifo_write_ena='1' then
          read_request_r <= read_request_r+resize(read_fifo_write.burstlen,read_request_r'length);
       end if;
       if signed(read_request_r)-signed(read_complete_r) >= to_signed(ddr_max_read_pend_c-ddr_max_burstlen_c-4,read_complete_r'length) then
          read_pending_full_r <= '1';
       else
          read_pending_full_r <= '0';
       end if;

       if RX_ENABLE=true then
		   if read_data_read_ena='1' then
			  if read_record_read(ddr_vector_depth_c)='1' and
				 read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c)='1' then
				 -- Flush next word if this is end of burst and this access spread to next word...
				 read_data_read_valid_r(1) <= '0';
				 read_data_read_valid_r(0) <= not read_data_read_empty;
				 read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
			  else 
				 -- Advance to next word
				 read_data_read_r(ddr_data_width_c-1 downto 0) <= read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c);
				 read_data_read_valid_r(1) <= read_data_read_valid_r(0);
				 read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
				 read_data_read_valid_r(0) <= not read_data_read_empty;
			  end if;
		   else
			  if read_data_read_valid_r(1)='0' then
				 read_data_read_r(ddr_data_width_c-1 downto 0) <= read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c);
				 read_data_read_valid_r(1) <= read_data_read_valid_r(0);
				 read_data_read_valid_r(0) <= not read_data_read_empty;
				 read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
			  elsif read_data_read_valid_r(0)='0' then
				 read_data_read_valid_r(0) <= not read_data_read_empty;
				 read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
			  end if;
		   end if;
       end if;
    end if;
end if;
end process;

END ddr_behavior;
