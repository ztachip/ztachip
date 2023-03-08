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


ENTITY axilite IS
   PORT( 
        SIGNAL clock_in                : IN STD_LOGIC;
        SIGNAL reset_in                : IN STD_LOGIC;

        SIGNAL axilite_araddr_in       : IN std_logic_vector(io_depth_c-1 downto 0);
        SIGNAL axilite_arvalid_in      : IN std_logic;
        SIGNAL axilite_arready_out     : OUT std_logic;
        SIGNAL axilite_rvalid_out      : OUT std_logic;
        SIGNAL axilite_rlast_out       : OUT std_logic;
        SIGNAL axilite_rdata_out       : OUT std_logic_vector(host_width_c-1 downto 0);
        SIGNAL axilite_rready_in       : IN std_logic;    
        SIGNAL axilite_rresp_out       : OUT std_logic_vector(1 downto 0);

        SIGNAL axilite_awaddr_in       : IN std_logic_vector(io_depth_c-1 downto 0);
        SIGNAL axilite_awvalid_in      : IN std_logic;
        SIGNAL axilite_wvalid_in       : IN std_logic;
        SIGNAL axilite_wdata_in        : IN std_logic_vector(host_width_c-1 downto 0);
        SIGNAL axilite_awready_out     : OUT std_logic;
        SIGNAL axilite_wready_out      : OUT std_logic;
        SIGNAL axilite_bvalid_out      : OUT std_logic;
        SIGNAL axilite_bready_in       : IN std_logic;
        SIGNAL axilite_bresp_out       : OUT std_logic_vector(1 downto 0);
        
        SIGNAL bus_waddr_out           : OUT std_logic_vector(io_depth_c-1 downto 0);
        SIGNAL bus_raddr_out           : OUT std_logic_vector(io_depth_c-1 downto 0);
        SIGNAL bus_write_out           : OUT std_logic;
        SIGNAL bus_read_out            : OUT std_logic;
        SIGNAL bus_writedata_out       : OUT std_logic_vector(host_width_c-1 downto 0);
        SIGNAL bus_readdata_in         : IN std_logic_vector(host_width_c-1 downto 0);
        SIGNAL bus_readdatavalid_in    : IN std_logic;
        SIGNAL bus_writewait_in        : IN std_logic;
        SIGNAL bus_readwait_in         : IN std_logic
    );
END axilite;

ARCHITECTURE behaviour of axilite IS
constant max_pending_write_depth_c:integer:=6;
SIGNAL axilite_rdata:std_logic_vector(host_width_c-1 downto 0);
SIGNAL bus_read:std_logic;
SIGNAL bus_readdatavalid_r:std_logic;
SIGNAL bus_readdata_r:std_logic_vector(host_width_c-1 downto 0);
SIGNAL waddr_fifo_write:std_logic;
SIGNAL waddr_fifo_read:std_logic;
SIGNAL wdata_fifo_write:std_logic;
SIGNAL wdata_fifo_read:std_logic;
SIGNAL wdata_fifo_empty:std_logic;
SIGNAL wdata_fifo_full:std_logic;
SIGNAL waddr_fifo_empty:std_logic;
SIGNAL waddr_fifo_full:std_logic;
SIGNAL bus_write:std_logic;
BEGIN

bus_read <= axilite_arvalid_in; -- Do not issue read until all previous write queues are empty

bus_read_out <= bus_read;

bus_raddr_out <= axilite_araddr_in;

axilite_rlast_out <= bus_readdatavalid_in or bus_readdatavalid_r;

axilite_rvalid_out <= bus_readdatavalid_in or bus_readdatavalid_r;

axilite_rdata <= bus_readdata_in when bus_readdatavalid_in='1' else bus_readdata_r;

axilite_arready_out <= (not bus_readwait_in);

axilite_rdata_out <= axilite_rdata;

bus_write <= '1' when (waddr_fifo_empty='0') and (wdata_fifo_empty='0') and (axilite_bready_in='1') 
             else '0';

bus_write_out <= bus_write;

axilite_awready_out <= not waddr_fifo_full;

axilite_wready_out <= not wdata_fifo_full;

axilite_bvalid_out <= waddr_fifo_read;

axilite_rresp_out <= (others=>'0');

axilite_bresp_out <= (others=>'0');

-- Fifo to latch in incoming write request

waddr_fifo_write <= axilite_awvalid_in and (not waddr_fifo_full);

waddr_fifo_read <= (not bus_writewait_in) and (bus_write); 

waddr_fifo_i : scfifo
	generic map
	(
        DATA_WIDTH=>io_depth_c,
        FIFO_DEPTH=>max_pending_write_depth_c,
        LOOKAHEAD=>true
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>axilite_awaddr_in,
        write_in=>waddr_fifo_write,
        read_in=>waddr_fifo_read,
        q_out=>bus_waddr_out,
        ravail_out=>open,
        wused_out=>open,
        empty_out=>waddr_fifo_empty,
        full_out=>waddr_fifo_full,
        almost_full_out=>open
	);

-- Fifo to latch in incoming write data

wdata_fifo_write <= axilite_wvalid_in and (not wdata_fifo_full);

wdata_fifo_read <= (not bus_writewait_in) and (bus_write); 

wdata_fifo_i : scfifo
	generic map
	(
        DATA_WIDTH=>host_width_c,
        FIFO_DEPTH=>max_pending_write_depth_c,
        LOOKAHEAD=>true
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>axilite_wdata_in,
        write_in=>wdata_fifo_write,
        read_in=>wdata_fifo_read,
        q_out=>bus_writedata_out,
        ravail_out=>open,
        wused_out=>open,
        empty_out=>wdata_fifo_empty,
        full_out=>wdata_fifo_full,
        almost_full_out=>open
	);

	

process(clock_in,reset_in)
begin
   if reset_in = '0' then
      bus_readdatavalid_r <= '0';
      bus_readdata_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         if bus_readdatavalid_in='1' and axilite_rready_in='0' then
            bus_readdatavalid_r <= '1';
            bus_readdata_r <= bus_readdata_in;
         elsif bus_readdatavalid_r='1' and axilite_rready_in='1' then
            bus_readdatavalid_r <= '0';
         end if;
      end if;
   end if;
end process;

END behaviour;
