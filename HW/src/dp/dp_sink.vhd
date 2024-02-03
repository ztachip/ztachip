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

-----------
--- This module interfaces with external write bus
--- Data to be transfered are queued in a fifo
--- There is a fifo for each bus
--- This module then transfers data from the FIFOs to external bus
------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;


ENTITY dp_sink IS
    GENERIC(
        NUM_DP_SRC_PORT   : integer;
        BURST_MODE        : STD_LOGIC;
        BUS_WIDTH         : integer;
        FORK              : integer;
        FIFO_DEPTH        : integer
        );
    PORT(   
        SIGNAL clock_in                : IN STD_LOGIC;
        SIGNAL reset_in                : IN STD_LOGIC;

        SIGNAL bus_addr_out            : OUT dp_full_addrs_t(FORK-1 downto 0);
        SIGNAL bus_fork_out            : OUT STD_LOGIC_VECTOR(FORK-1 downto 0);
        SIGNAL bus_addr_mode_out       : OUT STD_LOGIC;
        SIGNAL bus_vm_out              : OUT STD_LOGIC;
        SIGNAL bus_data_flow_out       : OUT data_flow_t;
        SIGNAL bus_vector_out          : OUT dp_vector_t;
        SIGNAL bus_stream_out          : OUT std_logic;
        SIGNAL bus_stream_id_out       : OUT stream_id_t;
        SIGNAL bus_scatter_out         : OUT scatter_t;
        SIGNAL bus_end_out             : OUT vectors_t(FORK-1 downto 0);
        SIGNAL bus_mcast_out           : OUT mcast_t;
        SIGNAL bus_cs_out              : OUT STD_LOGIC;
        SIGNAL bus_write_out           : OUT STD_LOGIC;
        SIGNAL bus_writedata_out       : OUT STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 DOWNTO 0);
        SIGNAL bus_wait_request_in     : IN STD_LOGIC;
        SIGNAL bus_burstlen_out        : OUT burstlen_t;
        SIGNAL bus_burstlen2_out       : OUT burstlen2_t;
        SIGNAL bus_burstlen3_out       : OUT burstlen_t;
        SIGNAL bus_id_out              : OUT dp_bus_id_t;
        SIGNAL bus_data_type_out       : OUT dp_data_type_t;
        SIGNAL bus_data_model_out      : OUT dp_data_model_t;
        SIGNAL bus_thread_out          : OUT dp_thread_t;

        SIGNAL wr_maxburstlen_out      : OUT burstlen_t;
        SIGNAL wr_full_out             : OUT STD_LOGIC;
        SIGNAL wr_req_in               : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_req_pending_p0_in    : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_req_pending_p1_in    : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_flow_in         : IN data_flows_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_vector_in            : IN dp_vectors_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_stream_in            : IN std_logic_vector(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_stream_id_in         : IN stream_ids_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_scatter_in           : IN scatters_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_end_in               : IN vector_forks_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_addr_in              : IN dp_fork_full_addrs_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_fork_in              : IN dp_forks_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_addr_mode_in         : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_src_vm_in            : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_datavalid_in         : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_in              : IN dp_datas_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_readdatavalid_in     : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_readdatavalid_vm_in  : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_readdata_in          : IN dp_fork_datas_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_burstlen_in          : IN burstlens_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_bus_id_in            : IN dp_bus_ids_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_thread_in            : IN dp_threads_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_type_in         : IN dp_data_types_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_model_in        : IN dp_data_models_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_mcast_in             : IN mcasts_t;

        SIGNAL read_pending_p0_out     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL read_pending_p1_out     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
END dp_sink;

ARCHITECTURE dp_sink_behaviour OF dp_sink IS
constant fifo_width_c:integer:=(2+dp_vector_t'length+ddr_data_width_c+BUS_WIDTH*FORK+FORK+scatter_t'length+burstlen_t'length+dp_bus_id_t'length+dp_thread_t'length+dp_data_type_t'length+dp_data_model_t'length+mcast_t'length+data_flow_t'length+vector_t'length*FORK+1+stream_id_t'length+1);
SIGNAL data:STD_LOGIC_VECTOR(fifo_width_c-1 downto 0);
SIGNAL rdreq:STD_LOGIC;
SIGNAL rdreq2:STD_LOGIC;
SIGNAL wrreq:STD_LOGIC;
SIGNAL empty:STD_LOGIC;
SIGNAL emptyn:STD_LOGIC;
SIGNAL empty2:STD_LOGIC;
SIGNAL q2:STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 downto 0);
subtype q_t is STD_LOGIC_VECTOR(fifo_width_c-1 downto 0);
type qs_t is array(0 to NUM_DP_SRC_PORT-1) of q_t;
SIGNAL q:q_t;
SIGNAL q_r:q_t;
SIGNAL valid:STD_LOGIC;
SIGNAL valid_r:STD_LOGIC;
SIGNAL valid_rr:STD_LOGIC;
SIGNAL bus_data_flow_r:data_flow_t;
SIGNAL bus_end_r:vectors_t(FORK-1 downto 0);
SIGNAL bus_vector_r:dp_vector_t;
SIGNAL bus_stream_r:std_logic;
SIGNAL bus_stream_id_r:stream_id_t;
SIGNAL bus_scatter_r:scatter_t;
SIGNAL bus_addr_r:dp_full_addrs_t(FORK-1 downto 0);
SIGNAL bus_fork_r:std_logic_vector(FORK-1 downto 0);
SIGNAL bus_addr_mode_r:STD_LOGIC;
SIGNAL bus_vm_r:STD_LOGIC;
SIGNAL bus_writedata_r:STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 DOWNTO 0);
SIGNAL bus_burstlen_r:burstlen_t;
SIGNAL bus_burstlen2_r:burstlen2_t;
SIGNAL bus_burstlen3_r:burstlen_t;
SIGNAL bus_id_r:dp_bus_id_t;
SIGNAL bus_thread_r:dp_thread_t;
SIGNAL bus_data_type_r:dp_data_type_t;
SIGNAL bus_data_model_r:dp_data_model_t;
SIGNAL bus_mcast_r:mcast_t:=(others=>'1');
SIGNAL req_p0_0_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL req_p0_1_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL req_p0_2_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL rsp_p0_0_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL rsp_p0_1_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL rsp_p0_2_r:unsigned(FIFO_DEPTH-1 downto 0);

SIGNAL req_p1_0_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL req_p1_1_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL req_p1_2_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL rsp_p1_0_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL rsp_p1_1_r:unsigned(FIFO_DEPTH-1 downto 0);
SIGNAL rsp_p1_2_r:unsigned(FIFO_DEPTH-1 downto 0);

subtype fifo_data_t is std_logic_vector(fifo_width_c-1 downto 0);
type fifo_datas_t is array(0 to NUM_DP_SRC_PORT-1) of fifo_data_t;
subtype usedw_t is std_logic_vector(FIFO_DEPTH-1 downto 0);
type usedws_t is array(0 to NUM_DP_SRC_PORT-1) of usedw_t;
SIGNAL usedw: usedw_t;
SIGNAL usedw2: usedw_t;
SIGNAL fifo_data:fifo_data_t;

SIGNAL wr_addr:dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL wr_fork:std_logic_vector(FORK-1 downto 0);
SIGNAL wr_addr_mode:STD_LOGIC;
SIGNAL wr_vm:STD_LOGIC;
SIGNAL wr_data_flow:data_flow_t;
SIGNAL wr_vector:dp_vector_t;
SIGNAL wr_stream:std_logic;
SIGNAL wr_stream_id:stream_id_t;
SIGNAL wr_scatter:scatter_t;
SIGNAL wr_end:vector_fork_t;
SIGNAL wr_datavalid:std_logic;
SIGNAL wr_data:dp_data_t;
SIGNAL wr_data2:std_logic_vector(ddr_data_width_c*FORK-1 downto 0);
SIGNAL wr_burstlen:burstlen_t;
SIGNAL wr_bus_id:dp_bus_id_t;
SIGNAL wr_thread:dp_thread_t;
SIGNAL wr_data_type:dp_data_type_t;
SIGNAL wr_data_model:dp_data_model_t;
SIGNAL wr_mcast:mcast_t;
SIGNAL wr_req:STD_LOGIC;
SIGNAL wr_req2:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_req2_all:STD_LOGIC;

SIGNAL full_1:STD_LOGIC;
SIGNAL full_2:STD_LOGIC;

SIGNAL read_pending_p0_r:STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL read_pending_p1_r:STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL wr_full_r:STD_LOGIC;
SIGNAL wr_maxburstlen_r:burstlen_t;

SIGNAL full_1_r:STD_LOGIC;
SIGNAL full_2_r:STD_LOGIC;

attribute noprune: boolean; 
attribute noprune of full_1_r: signal is true;
attribute noprune of full_2_r: signal is true;

---------
-- Component declaration
---------

BEGIN

wr_full_out <= wr_full_r;
wr_maxburstlen_out <= wr_maxburstlen_r;

-----
-- FIFO to hold inbound data
-- There is a FIFO for each bus
-----

dp_sink_fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>fifo_width_c,
        FIFO_DEPTH=>FIFO_DEPTH,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>fifo_data,
        write_in=>wr_req,
        read_in=>rdreq,
        q_out=>q,
        ravail_out=>open,
        wused_out=>usedw,
        empty_out=>empty,
        full_out=>full_1,
        almost_full_out=>open
	);

dp_sink_fifo_i2:scfifo
	generic map 
	(
        DATA_WIDTH=>ddr_data_width_c*FORK,
        FIFO_DEPTH=>FIFO_DEPTH,
        LOOKAHEAD=>FALSE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>wr_data2,
        write_in=>wr_req2_all,
        read_in=>rdreq2,
        q_out=>q2,
        ravail_out=>open,
        wused_out=>usedw2,
        empty_out=>empty2,
        full_out=>full_2,
        almost_full_out=>open
	);
--------
-- Output
--------

bus_cs_out <= valid_rr;
bus_data_flow_out <= bus_data_flow_r;
bus_end_out <= bus_end_r;
bus_vector_out <= bus_vector_r;
bus_stream_out <= bus_stream_r;
bus_stream_id_out <= bus_stream_id_r;
bus_scatter_out <= bus_scatter_r;
bus_write_out <= valid_rr;
bus_addr_out <= bus_addr_r;
bus_fork_out <= bus_fork_r;
bus_addr_mode_out <= bus_addr_mode_r;
bus_vm_out <= bus_vm_r;
bus_id_out <= bus_id_r;
bus_writedata_out <= bus_writedata_r;
bus_burstlen_out <= bus_burstlen_r;
bus_burstlen2_out <= bus_burstlen2_r;
bus_burstlen3_out <= bus_burstlen3_r;
bus_data_type_out <= bus_data_type_r;
bus_data_model_out <= bus_data_model_r;
bus_mcast_out <= bus_mcast_r;
bus_thread_out <= bus_thread_r;

-----
--- Pack write access information to FIFO
--- Do this for each bus
-----

wr_req <= wr_req_in(0) or wr_req_in(1) or wr_req_in(2);

wr_req2(0) <= '1' when (wr_readdatavalid_in(0)='1' and (req_p0_0_r /= rsp_p0_0_r or req_p1_0_r /= rsp_p1_0_r)) else '0';

wr_req2(1) <= '1' when (wr_readdatavalid_in(1)='1' and (req_p0_1_r /= rsp_p0_1_r or req_p1_1_r /= rsp_p1_1_r)) else '0';

wr_req2(2) <= '1' when (wr_readdatavalid_in(2)='1' and (req_p0_2_r /= rsp_p0_2_r or req_p1_2_r /= rsp_p1_2_r)) else '0';

wr_req2_all <= wr_req2(0) or wr_req2(1) or wr_req2(2);

read_pending_p0_out <= read_pending_p0_r or wr_req_pending_p0_in;

read_pending_p1_out <= read_pending_p1_r or wr_req_pending_p1_in;

process(wr_req2,wr_readdata_in)
begin
for I in 0 to FORK-1 loop
   if wr_req2(0)='1' then
      wr_data2((I+1)*ddr_data_width_c-1 downto I*ddr_data_width_c) <= wr_readdata_in(0)(I);
   elsif wr_req2(1)='1' then 
      wr_data2((I+1)*ddr_data_width_c-1 downto I*ddr_data_width_c) <= wr_readdata_in(1)(I);
   else
      wr_data2((I+1)*ddr_data_width_c-1 downto I*ddr_data_width_c) <= wr_readdata_in(2)(I);
   end if;
end loop;
end process;

process(wr_req_in,wr_data_flow_in,wr_vector_in,wr_scatter_in,wr_end_in,wr_data_in,wr_addr_in,wr_fork_in,wr_addr_mode_in,wr_burstlen_in,wr_bus_id_in,wr_thread_in,
        wr_data_model_in,wr_data_type_in,wr_mcast_in,wr_datavalid_in,wr_readdata_in,wr_stream_in,wr_stream_id_in,wr_src_vm_in)
begin
if wr_req_in(0)='1' then
    wr_datavalid <= wr_datavalid_in(0);
    wr_data <= wr_data_in(0);
    wr_addr <= wr_addr_in(0);
    wr_vm <= wr_src_vm_in(0);
    wr_fork <= wr_fork_in(0)(FORK-1 downto 0);
    wr_addr_mode <= wr_addr_mode_in(0);
    wr_data_flow <= wr_data_flow_in(0);
    wr_vector <= wr_vector_in(0);
    wr_stream <= wr_stream_in(0);
    wr_stream_id <= wr_stream_id_in(0);
    wr_scatter <= wr_scatter_in(0);
    wr_end <= wr_end_in(0);
    wr_burstlen <= wr_burstlen_in(0);
    wr_bus_id <= wr_bus_id_in(0);
    wr_thread <= wr_thread_in(0);
    wr_data_type <= wr_data_type_in(0);
    wr_data_model <= wr_data_model_in(0);
    wr_mcast <= wr_mcast_in(0);
elsif wr_req_in(1)='1' then
    wr_datavalid <= wr_datavalid_in(1);
    wr_data <= wr_data_in(1);
    wr_addr <= wr_addr_in(1);
    wr_vm <= wr_src_vm_in(1);
    wr_fork <= wr_fork_in(1)(FORK-1 downto 0);
    wr_addr_mode <= wr_addr_mode_in(1);
    wr_data_flow <= wr_data_flow_in(1);
    wr_vector <= wr_vector_in(1);
    wr_stream <= wr_stream_in(1);
    wr_stream_id <= wr_stream_id_in(1);
    wr_scatter <= wr_scatter_in(1);
    wr_end <= wr_end_in(1);
    wr_burstlen <= wr_burstlen_in(1);
    wr_bus_id <= wr_bus_id_in(1);
    wr_thread <= wr_thread_in(1);
    wr_data_type <= wr_data_type_in(1);
    wr_data_model <= wr_data_model_in(1);
    wr_mcast <= wr_mcast_in(1);
else
    wr_datavalid <= wr_datavalid_in(2);
    wr_data <= wr_data_in(2);
    wr_addr <= wr_addr_in(2);
    wr_vm <= wr_src_vm_in(2);
    wr_fork <= wr_fork_in(2)(FORK-1 downto 0);
    wr_addr_mode <= wr_addr_mode_in(2);
    wr_data_flow <= wr_data_flow_in(2);
    wr_vector <= wr_vector_in(2);
    wr_stream <= wr_stream_in(2);
    wr_stream_id <= wr_stream_id_in(2);
    wr_scatter <= wr_scatter_in(2);
    wr_end <= wr_end_in(2);
    wr_burstlen <= wr_burstlen_in(2);
    wr_bus_id <= wr_bus_id_in(2);
    wr_thread <= wr_thread_in(2);
    wr_data_type <= wr_data_type_in(2);
    wr_data_model <= wr_data_model_in(2);
    wr_mcast <= wr_mcast_in(2);
end if;
end process;

----
--- Packet write request to FIFO record
----

process(wr_vector,wr_stream,wr_stream_id,wr_scatter,wr_end,wr_data_flow,wr_mcast,wr_data_type,wr_data_model,wr_thread,wr_bus_id,wr_burstlen,wr_addr,wr_fork,wr_addr_mode,wr_data,wr_datavalid)
variable len_v:integer;
begin
    len_v := 0;
    fifo_data(0) <= wr_datavalid;
    len_v := len_v+1;
    fifo_data(len_v+ddr_data_width_c-1 downto len_v) <= std_logic_vector(wr_data);
    len_v := len_v+ddr_data_width_c;
    FOR I in 0 to FORK-1 loop
       fifo_data(len_v+BUS_WIDTH-1 downto len_v) <= std_logic_vector(wr_addr(I));
       len_v := len_v+BUS_WIDTH;
    end loop;
    fifo_data(len_v+FORK-1 downto len_v) <= wr_fork;
    len_v := len_v+FORK;
    fifo_data(len_v) <= wr_addr_mode;
    len_v := len_v+1;
    fifo_data(len_v) <= wr_vm;
    len_v := len_v+1;
    fifo_data(len_v+burstlen_t'length-1 downto len_v) <= std_logic_vector(wr_burstlen);
    len_v := len_v+burstlen_t'length;
    fifo_data(len_v+dp_bus_id_t'length-1 downto len_v) <= std_logic_vector(wr_bus_id);
    len_v := len_v+dp_bus_id_t'length;
    fifo_data(len_v+dp_thread_t'length-1 downto len_v) <= std_logic_vector(wr_thread);
    len_v := len_v+dp_thread_t'length;
    fifo_data(len_v+dp_data_type_t'length-1 downto len_v) <= std_logic_vector(wr_data_type);
    len_v := len_v+dp_data_type_t'length;
    fifo_data(len_v+dp_data_model_t'length-1 downto len_v) <= std_logic_vector(wr_data_model);
    len_v := len_v+dp_data_model_t'length;
    fifo_data(len_v+mcast_t'length-1 downto len_v) <= std_logic_vector(wr_mcast);
    len_v := len_v+mcast_t'length;
    fifo_data(len_v+wr_vector'length-1 downto len_v) <= wr_vector;
    len_v := len_v+wr_vector'length;
    fifo_data(len_v) <= wr_stream;
    len_v := len_v+1;
    fifo_data(len_v+wr_stream_id'length-1 downto len_v) <= std_logic_vector(wr_stream_id);
    len_v := len_v+wr_stream_id'length;
    fifo_data(len_v+wr_scatter'length-1 downto len_v) <= wr_scatter;
    len_v := len_v+wr_scatter'length;
    fifo_data(len_v+wr_data_flow'length-1 downto len_v) <= wr_data_flow;
    len_v := len_v+wr_data_flow'length;
    for I in 0 to FORK-1 loop
       fifo_data(len_v+wr_end(I)'length-1 downto len_v) <= std_logic_vector(wr_end(I));
       len_v := len_v+wr_end(I)'length;
    end loop;
end process;

--------
-- Transfer data from one of the FIFO (chosen by arbiter) to external write bus
-------

process(reset_in,clock_in)
variable bus_burstlen_v:burstlen_t;
variable bus_addr_v:dp_full_addrs_t(FORK-1 downto 0);
variable bus_fork_v:std_logic_vector(FORK-1 downto 0);
variable bus_addr_mode_v:STD_LOGIC;
variable bus_writedata_v:STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 DOWNTO 0);
variable bus_id_v:dp_bus_id_t;
variable usedw_v:unsigned(FIFO_DEPTH-1 downto 0);
variable temp_v:unsigned(FIFO_DEPTH-1 downto 0);
variable bus_thread_v:dp_thread_t;
variable bus_mcast_v:mcast_t;
variable bus_data_type_v:dp_data_type_t;
variable bus_data_model_v:dp_data_model_t;
variable len_v:integer;
variable vector_v:dp_vector_t;
variable scatter_v:scatter_t;
variable data_flow_v:data_flow_t;
variable end_v:vectors_t(FORK-1 downto 0);
variable burstlen2_v:burstlen2_t;
variable stream_v:std_logic;
variable stream_id_v:stream_id_t;
variable req_p0_0_v:unsigned(FIFO_DEPTH-1 downto 0);
variable req_p0_1_v:unsigned(FIFO_DEPTH-1 downto 0);
variable req_p0_2_v:unsigned(FIFO_DEPTH-1 downto 0);
variable rsp_p0_0_v:unsigned(FIFO_DEPTH-1 downto 0);
variable rsp_p0_1_v:unsigned(FIFO_DEPTH-1 downto 0);
variable rsp_p0_2_v:unsigned(FIFO_DEPTH-1 downto 0);

variable req_p1_0_v:unsigned(FIFO_DEPTH-1 downto 0);
variable req_p1_1_v:unsigned(FIFO_DEPTH-1 downto 0);
variable req_p1_2_v:unsigned(FIFO_DEPTH-1 downto 0);
variable rsp_p1_0_v:unsigned(FIFO_DEPTH-1 downto 0);
variable rsp_p1_1_v:unsigned(FIFO_DEPTH-1 downto 0);
variable rsp_p1_2_v:unsigned(FIFO_DEPTH-1 downto 0);

variable bus_vm_v:std_logic;

begin
    if reset_in = '0' then
        valid_r <= '0';
        valid_rr <= '0';
        bus_addr_r <= (others=>(others=>'0'));
        bus_fork_r <= (others=>'0');
        bus_addr_mode_r <= '0';
        bus_vm_r <= '0';
        bus_writedata_r <= (others=>'0');
        bus_burstlen_r <= (others=>'0');
        bus_burstlen2_r <= (others=>'0');
        bus_burstlen3_r <= (others=>'0');
        bus_id_r <= (others=>'0');
        bus_thread_r <= (others=>'0');
        bus_data_type_r <= (others=>'0');
        bus_data_model_r <= (others=>'0');
        bus_mcast_r <= (others=>'1');
        bus_vector_r <= (others=>'0');
        bus_stream_r <= '0';
        bus_stream_id_r <= (others=>'0');
        bus_data_flow_r <= (others=>'0');
        bus_end_r <= (others=>(others=>'0'));
        bus_scatter_r <= (others=>'0');
        q_r <= (others=>'0');
        req_p0_0_r <= (others=>'0');
        req_p0_1_r <= (others=>'0');
        req_p0_2_r <= (others=>'0');
        rsp_p0_0_r <= (others=>'0');
        rsp_p0_1_r <= (others=>'0');
        rsp_p0_2_r <= (others=>'0');
        req_p1_0_r <= (others=>'0');
        req_p1_1_r <= (others=>'0');
        req_p1_2_r <= (others=>'0');
        rsp_p1_0_r <= (others=>'0');
        rsp_p1_1_r <= (others=>'0');
        rsp_p1_2_r <= (others=>'0');
        read_pending_p0_r <= (others=>'0');
        read_pending_p1_r <= (others=>'0');
        full_1_r <= '0';
        full_2_r <= '0';        
    else
        if clock_in'event and clock_in='1' then
        
            full_1_r <= full_1;
            full_2_r <= full_2;
        
            if rdreq='1' then
                q_r <= q;
            end if;

            -- Update to write pending to process 0

            if (wr_req_in(0)='1' and wr_datavalid_in(0)='1' and wr_vm='0') then
                req_p0_0_v := req_p0_0_r+1;
            else
                req_p0_0_v := req_p0_0_r;
            end if;
            if (wr_req_in(1)='1' and wr_datavalid_in(1)='1' and wr_vm='0') then
                req_p0_1_v := req_p0_1_r+1;
            else
                req_p0_1_v := req_p0_1_r;
            end if;
            if (wr_req_in(2)='1' and wr_datavalid_in(2)='1' and wr_vm='0') then
                req_p0_2_v := req_p0_2_r+1;
            else
                req_p0_2_v := req_p0_2_r;
            end if;

            -- Update to write pending to process 1

            if (wr_req_in(0)='1' and wr_datavalid_in(0)='1' and wr_vm='1') then
                req_p1_0_v := req_p1_0_r+1;
            else
                req_p1_0_v := req_p1_0_r;
            end if;
            if (wr_req_in(1)='1' and wr_datavalid_in(1)='1' and wr_vm='1') then
                req_p1_1_v := req_p1_1_r+1;
            else
                req_p1_1_v := req_p1_1_r;
            end if;
            if (wr_req_in(2)='1' and wr_datavalid_in(2)='1' and wr_vm='1') then
                req_p1_2_v := req_p1_2_r+1;
            else
                req_p1_2_v := req_p1_2_r;
            end if;

            -- Update write complete to process 0

            if wr_req2(0)='1' and wr_readdatavalid_vm_in(0)='0' then
                rsp_p0_0_v := rsp_p0_0_r+1;
            else
                rsp_p0_0_v := rsp_p0_0_r;
            end if;
            if wr_req2(1)='1' and wr_readdatavalid_vm_in(1)='0' then
                rsp_p0_1_v := rsp_p0_1_r+1;
            else
                rsp_p0_1_v := rsp_p0_1_r;
            end if;
            if wr_req2(2)='1' and wr_readdatavalid_vm_in(2)='0' then
                rsp_p0_2_v := rsp_p0_2_r+1;
            else
                rsp_p0_2_v := rsp_p0_2_r;
            end if;

            -- Update write complete to process 1

            if wr_req2(0)='1' and wr_readdatavalid_vm_in(0)='1' then
                rsp_p1_0_v := rsp_p1_0_r+1;
            else
                rsp_p1_0_v := rsp_p1_0_r;
            end if;
            if wr_req2(1)='1' and wr_readdatavalid_vm_in(1)='1' then
                rsp_p1_1_v := rsp_p1_1_r+1;
            else
                rsp_p1_1_v := rsp_p1_1_r;
            end if;
            if wr_req2(2)='1' and wr_readdatavalid_vm_in(2)='1' then
                rsp_p1_2_v := rsp_p1_2_r+1;
            else
                rsp_p1_2_v := rsp_p1_2_r;
            end if;

            req_p0_0_r <= req_p0_0_v;
            req_p0_1_r <= req_p0_1_v;
            req_p0_2_r <= req_p0_2_v;
            rsp_p0_0_r <= rsp_p0_0_v;
            rsp_p0_1_r <= rsp_p0_1_v;
            rsp_p0_2_r <= rsp_p0_2_v;

            req_p1_0_r <= req_p1_0_v;
            req_p1_1_r <= req_p1_1_v;
            req_p1_2_r <= req_p1_2_v;
            rsp_p1_0_r <= rsp_p1_0_v;
            rsp_p1_1_r <= rsp_p1_1_v;
            rsp_p1_2_r <= rsp_p1_2_v;

            --- Update read pending for process 0

            if (req_p0_0_v /= rsp_p0_0_v) then
               read_pending_p0_r(0) <= '1';
            else
               read_pending_p0_r(0) <= '0';
            end if;
            
            if (req_p0_1_v /= rsp_p0_1_v) then
               read_pending_p0_r(1) <= '1';
            else
               read_pending_p0_r(1) <= '0';
            end if;
            
            if (req_p0_2_v /= rsp_p0_2_v) then
               read_pending_p0_r(2) <= '1';
            else
               read_pending_p0_r(2) <= '0';
            end if;

            --- Update read pending for process 1

            if (req_p1_0_v /= rsp_p1_0_v) then
               read_pending_p1_r(0) <= '1';
            else
               read_pending_p1_r(0) <= '0';
            end if;
            
            if (req_p1_1_v /= rsp_p1_1_v) then
               read_pending_p1_r(1) <= '1';
            else
               read_pending_p1_r(1) <= '0';
            end if;
            
            if (req_p1_2_v /= rsp_p1_2_v) then
               read_pending_p1_r(2) <= '1';
            else
               read_pending_p1_r(2) <= '0';
            end if;

            if bus_wait_request_in='0' or valid_rr='0' then
                valid_rr <= valid_r;
                valid_r <= valid;
                
                ----
                -- Unpack fifo for write access information
                ----

                if q_r(0)='1' then
                    bus_writedata_v := q2;
                else
                    FOR I in 0 to FORK-1 LOOP
                       bus_writedata_v((I+1)*ddr_data_width_c-1 downto I*ddr_data_width_c) := q_r(ddr_data_width_c downto 1);
                    END LOOP;
                end if;
                len_v:=1+ddr_data_width_c;
                FOR I in 0 to FORK-1 loop
                   bus_addr_v(I) := unsigned(q_r(len_v+BUS_WIDTH-1 downto len_v));
                   len_v := len_v+BUS_WIDTH;
                end loop;
                bus_fork_v := q_r(len_v+FORK-1 downto len_v);
                len_v := len_v+FORK;
                bus_addr_mode_v := q_r(len_v);
                len_v := len_v+1;
                bus_vm_v := q_r(len_v);
	            len_v := len_v+1;
                if BURST_MODE='1' then
                    bus_burstlen_v := unsigned(q_r(len_v+burstlen_t'length-1 downto len_v));
                    if q_r(0)='1' then
                        usedw_v := unsigned(usedw2)+1;
                    else
                        usedw_v := unsigned(usedw)+1;
                    end if;
                    temp_v(temp_v'length-1 downto burstlen_t'length) := (others=>'0');
                    temp_v(burstlen_t'length-1 downto 0) := bus_burstlen_v;
                    if temp_v > usedw_v then
                        bus_burstlen_v := usedw_v(burstlen_t'length-1 downto 0);
                    end if;
                else
                    bus_burstlen_v := to_unsigned(1,burstlen_t'length);
                end if;
                len_v := len_v+burstlen_t'length;
                bus_id_v := unsigned(q_r(len_v+dp_bus_id_t'length-1 downto len_v));
                len_v := len_v+dp_bus_id_t'length;
                bus_thread_v := unsigned(q_r(len_v+dp_thread_t'length-1 downto len_v));
                len_v := len_v+dp_thread_t'length;
                bus_data_type_v := unsigned(q_r(len_v+dp_data_type_t'length-1 downto len_v));
                len_v := len_v+dp_data_type_t'length;
                bus_data_model_v := q_r(len_v+dp_data_model_t'length-1 downto len_v);
                len_v := len_v+dp_data_model_t'length;
                bus_mcast_v := std_logic_vector(q_r(len_v+mcast_t'length-1 downto len_v));
                len_v := len_v+bus_mcast_v'length;
                vector_v := q_r(len_v+vector_v'length-1 downto len_v);
                len_v := len_v+vector_v'length;
                stream_v := q_r(len_v);
                len_v := len_v+1;
                stream_id_v := unsigned(q_r(len_v+stream_id_t'length-1 downto len_v));
                len_v := len_v + stream_id_t'length;
                scatter_v := q_r(len_v+scatter_v'length-1 downto len_v);
                len_v := len_v+scatter_v'length;
                data_flow_v := q_r(len_v+data_flow_v'length-1 downto len_v);
                len_v := len_v+data_flow_v'length;
                for I in 0 to FORK-1 loop
                   end_v(I) := unsigned(q_r(len_v+end_v(I)'length-1 downto len_v));
                   len_v := len_v+end_v(I)'length;
                end loop;
                burstlen2_v := resize(bus_burstlen_v,burstlen2_v'length);
                if unsigned(vector_v)=to_unsigned(1,ddr_vector_depth_c) then 
                   if burstlen2_v > to_unsigned((ddr_vector_width_c/2)*(ddr_max_burstlen_c-1),burstlen2_v'length) then
                      burstlen2_v := to_unsigned((ddr_vector_width_c/2)*(ddr_max_burstlen_c-1)-1,burstlen2_v'length);
                   end if;
                   bus_burstlen3_r <= burstlen2_v(burstlen_t'length-1 downto 0);
                   bus_burstlen2_r <= burstlen2_v sll 1;
                elsif unsigned(vector_v)=to_unsigned(3,ddr_vector_depth_c) then
                   if burstlen2_v > to_unsigned((ddr_vector_width_c/4)*(ddr_max_burstlen_c-1),burstlen2_v'length) then
                      burstlen2_v := to_unsigned((ddr_vector_width_c/4)*(ddr_max_burstlen_c-1)-1,burstlen2_v'length);
                   end if;
                   bus_burstlen3_r <= burstlen2_v(burstlen_t'length-1 downto 0);
                   bus_burstlen2_r <= burstlen2_v sll 2;
                elsif unsigned(vector_v)=to_unsigned(7,ddr_vector_depth_c) then -- vsize=1
                   if burstlen2_v > to_unsigned((ddr_vector_width_c/8)*(ddr_max_burstlen_c-1),burstlen2_v'length) then
                      burstlen2_v := to_unsigned((ddr_vector_width_c/8)*(ddr_max_burstlen_c-1)-1,burstlen2_v'length);
                   end if;
                   bus_burstlen3_r <= burstlen2_v(burstlen_t'length-1 downto 0);
                   bus_burstlen2_r <= burstlen2_v sll 3;
                else
                   if burstlen2_v > to_unsigned(ddr_vector_width_c*(ddr_max_burstlen_c-1),burstlen2_v'length) then
                      burstlen2_v := to_unsigned(ddr_vector_width_c*(ddr_max_burstlen_c-1)-1,burstlen2_v'length);
                   end if;
                   bus_burstlen3_r <= burstlen2_v(burstlen_t'length-1 downto 0);
                   bus_burstlen2_r <= burstlen2_v;
                end if;

                bus_burstlen_r <= bus_burstlen_v;
                bus_addr_r <= bus_addr_v;
                bus_fork_r <= bus_fork_v;
                bus_addr_mode_r <= bus_addr_mode_v;
                bus_vm_r <= bus_vm_v;
                bus_writedata_r <= bus_writedata_v;
                bus_id_r <= bus_id_v;
                bus_thread_r <= bus_thread_v;
                bus_data_type_r <= bus_data_type_v;
                bus_data_model_r <= bus_data_model_v;
                bus_mcast_r <= bus_mcast_v;
                bus_vector_r <= vector_v;
                bus_stream_r <= stream_v;
                bus_stream_id_r <= stream_id_v;
                bus_scatter_r <= scatter_v;
                bus_data_flow_r <= data_flow_v;
                bus_end_r <= end_v;
            end if;
        end if;
    end if;
end process;


process(clock_in,reset_in)
variable fifo_avail_v:unsigned(FIFO_DEPTH-1 downto 0);
variable avail_v:unsigned(FIFO_DEPTH-1 downto 0);
begin
if reset_in='0' then
   wr_full_r <= '0';
   wr_maxburstlen_r <= (others=>'0');
else
   if clock_in'event and clock_in='1' then
      avail_v := unsigned(not usedw);
      if(avail_v <= to_unsigned(burstlen_max_c+16,FIFO_DEPTH)) then
         wr_full_r <= '1';
      else
         wr_full_r <= '0';
      end if;
      wr_maxburstlen_r <= to_unsigned(burstlen_max_c,burstlen_t'length);
   end if;
end if;
end process;

emptyn <= '1' when (empty='0') and ((empty2='0') or q(0)='0') else '0';

process(valid_r,valid_rr,bus_wait_request_in,empty,emptyn,q)
begin
if valid_rr='1' then
    if bus_wait_request_in='1' then
        valid <= valid_r;
        rdreq <= '0';
        rdreq2 <= '0';
    elsif emptyn='1' then
        valid <= '1';
        rdreq <= emptyn;
        rdreq2 <= q(0);
    else
        valid <= '0';
        rdreq <= '0';
        rdreq2 <= '0';
    end if;
else
    if emptyn='1' then
        valid <= '1';
        rdreq <= emptyn;
        rdreq2 <= q(0);
    else
        valid <= '0';
        rdreq <= '0';
        rdreq2 <= '0';
    end if;
end if;
end process;
END dp_sink_behaviour;

