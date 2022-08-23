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

----
-- This module interfaces with external bus for read access
-- Then destination address is coupled with received data and sent to dp_sink
-- Write access is delayed to match read latency
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY dp_source IS
    generic(
        BUS_ID          : integer;
        NUM_DP_DST_PORT : integer;
        LATENCY         : integer;
        BUS_WIDTH       : integer;
        FORK            : integer;
        INSTANCE        : integer
        );
    port(
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;

        -- Signal to drive memory bus to perform read access        
        
        SIGNAL bus_addr_out             : OUT dp_full_addrs_t(FORK-1 downto 0);
        SIGNAL bus_addr_mode_out        : OUT STD_LOGIC;
        SIGNAL bus_cs_out               : OUT STD_LOGIC;
        SIGNAL bus_read_out             : OUT STD_LOGIC;
        SIGNAL bus_read_vm_out          : OUT STD_LOGIC;
        SIGNAL bus_read_fork_out        : OUT std_logic_vector(FORK-1 downto 0);
        SIGNal bus_read_data_flow_out   : OUT data_flow_t;
        SIGNAL bus_read_stream_out      : OUT STD_LOGIC;
        SIGNAL bus_read_stream_id_out   : OUT stream_id_t;
        SIGNAL bus_read_vector_out      : OUT dp_vector_t;
        SIGNAL bus_read_scatter_out     : OUT scatter_t;
        SIGNAL bus_read_start_out       : OUT unsigned(ddr_vector_depth_c downto 0);
        SIGNAL bus_read_end_out         : OUT vectors_t(FORK-1 downto 0);
        SIGNAL bus_readdatavalid_in     : IN STD_LOGIC;
        SIGNAL bus_readdatavalid_vm_in  : IN STD_LOGIC;
        SIGNAL bus_readdata_in          : IN STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 DOWNTO 0);
        SIGNAL bus_wait_request_in      : IN STD_LOGIC;
        SIGNAL bus_burstlen_out         : OUT burstlen_t;
        SIGNAL bus_id_out               : OUT dp_bus_id_t;
        SIGNAL bus_data_type_out        : OUT dp_data_type_t;
        SIGNAL bus_data_model_out       : OUT dp_data_model_t;

        -- Signal from DP generator
        
        SIGNAL gen_waitreq_out          : OUT STD_LOGIC;
        SIGNAL gen_valid_in             : IN STD_LOGIC;
        SIGNAL gen_vm_in                : IN STD_LOGIC;
        SIGNAL gen_fork_in              : IN STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
        SIGNAL gen_data_flow_in         : IN data_flow_t;
        SIGNAL gen_src_stream_in        : IN STD_LOGIC;
        SIGNAL gen_dest_stream_in       : IN STD_LOGIC;
        SIGNAL gen_stream_id_in         : stream_id_t;
        SIGNAL gen_src_vector_in        : IN dp_vector_t;
        SIGNAL gen_dst_vector_in        : IN dp_vector_t;
        SIGNAL gen_src_scatter_in       : IN scatter_t;
        SIGNAL gen_dst_scatter_in       : IN scatter_t;
        SIGNAL gen_src_start_in         : unsigned(ddr_vector_depth_c downto 0);
        SIGNAL gen_src_end_in           : vector_fork_t;
        SIGNAL gen_dst_end_in           : vector_fork_t;
        SIGNAL gen_src_eof_in           : IN STD_LOGIC;
        SIGNAL gen_src_addr_in          : IN dp_full_addrs_t(fork_max_c-1 downto 0);
        SIGNAL gen_src_addr_mode_in     : IN STD_LOGIC;
        SIGNAL gen_dst_addr_in          : IN dp_full_addrs_t(fork_max_c-1 downto 0);
        SIGNAL gen_dst_addr_mode_in     : IN STD_LOGIC;
        SIGNAL gen_bus_id_source_in     : IN dp_bus_id_t;
        SIGNAL gen_data_type_source_in  : IN dp_data_type_t;
        SIGNAL gen_data_model_source_in : IN dp_data_model_t;
        SIGNAL gen_bus_id_dest_in       : IN dp_bus_id_t;
        SIGNAL gen_data_type_dest_in    : IN dp_data_type_t;
        SIGNAL gen_data_model_dest_in   : IN dp_data_model_t;
        SIGNAL gen_src_burstlen_in      : IN burstlen_t;
        SIGNAL gen_dst_burstlen_in      : IN burstlen_t;
        SIGNAL gen_thread_in            : IN dp_thread_t;
        SIGNAL gen_mcast_in             : IN mcast_t;
        SIGNAL gen_src_data_in          : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);

        -- Signal to send received data to transmit node
        
        SIGNAL wr_req_out               : OUT STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_req_pending_p0_out    : OUT STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_req_pending_p1_out    : OUT STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_full_in               : IN STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_data_flow_out         : OUT data_flows_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_vector_out            : OUT dp_vectors_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_stream_out            : OUT std_logic_vector(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_stream_id_out         : OUT stream_ids_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_scatter_out           : OUT scatters_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_end_out               : OUT vector_forks_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_addr_out              : OUT dp_full_addrs_t(fork_max_c-1 downto 0);
        SIGNAL wr_fork_out              : OUT STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
        SIGNAL wr_addr_mode_out         : OUT STD_LOGIC;
        SIGNAL wr_src_vm_out            : OUT STD_LOGIC;
        SIGNAL wr_datavalid_out         : OUT STD_LOGIC;
        SIGNAL wr_data_out              : OUT dp_data_t;
        SIGNAL wr_readdatavalid_out     : OUT STD_LOGIC;
        SIGNAL wr_readdatavalid_vm_out  : OUT STD_LOGIC;
        SIGNAL wr_readdata_out          : OUT dp_fork_data_t;
        SIGNAL wr_burstlen_out          : OUT burstlen_t;
        SIGNAL wr_bus_id_out            : OUT dp_bus_id_t;
        SIGNAL wr_thread_out            : OUT dp_thread_t;
        SIGNAL wr_data_type_out         : OUT dp_data_type_t;
        SIGNAL wr_data_model_out        : OUT dp_data_model_t;
        SIGNAL wr_mcast_out             : OUT mcast_t
        );
END dp_source;

ARCHITECTURE dp_source_behaviour OF dp_source IS
SIGNAL doit:STD_LOGIC;
SIGNAL wr_req: STD_LOGIC;
SIGNAL wr_addr: dp_full_addrs_t(FORK-1 downto 0);
SIGNAL wr_fork: STD_LOGIC_VECTOR(FORK-1 downto 0);
SIGNAL wr_addr_mode:STD_LOGIC;
SIGNAL wr_src_vm:STD_LOGIC;
SIGNAL dp_bus_id: dp_bus_id_t;
SIGNAL dp_data_type: dp_data_type_t;
SIGNAL dp_data_model: dp_data_model_t;
SIGNAL dp_thread:dp_thread_t;
SIGNAL dp_mcast:mcast_t;
SIGNAL wr_burstlen: burstlen_t;
SIGNAL wr_req2: STD_LOGIC;
SIGNAL dp_bus_id2: dp_bus_id_t;
SIGNAL dp_data_type2: dp_data_type_t;
SIGNAL dp_thread2:dp_thread_t;
SIGNAL dp_mcast2:mcast_t;
SIGNAL wr_burstlen2: burstlen_t;
SIGNAL gen_src_eof2:STD_LOGIC;
SIGNAL gen_src_data2:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL gen_valid:STD_LOGIC;
SIGNAL bus_readdata:STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 DOWNTO 0);
SIGNAL bus_readdata2:STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 DOWNTO 0);

BEGIN

gen_valid <= gen_valid_in and (not wr_full_in(to_integer(gen_bus_id_dest_in)));


bus_readdata <= bus_readdata_in when bus_readdatavalid_in='1' else (others=>'0');
 
delay_i1: delay generic map(DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>wr_req,out_out=>wr_req2,enable_in=>'1');
delay_i3: delayi generic map(SIZE=>dp_bus_id'length,DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>dp_bus_id,out_out=>dp_bus_id2,enable_in=>'1');
delay_i4: delayi generic map(SIZE=>dp_data_type'length,DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>dp_data_type,out_out=>dp_data_type2,enable_in=>'1');
delay_i5: delayi generic map(SIZE=>dp_thread'length,DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>dp_thread,out_out=>dp_thread2,enable_in=>'1');
delay_i6: delayi generic map(SIZE=>wr_burstlen'length,DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>wr_burstlen,out_out=>wr_burstlen2,enable_in=>'1');
delay_i7: delayv generic map(SIZE=>dp_mcast'length,DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>dp_mcast,out_out=>dp_mcast2,enable_in=>'1');
delay_i8: delay generic map(DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>gen_src_eof_in,out_out=>gen_src_eof2,enable_in=>'1');
delay_i9: delayv generic map(SIZE=>ddr_data_width_c,DEPTH => read_latency_max_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>gen_src_data_in,out_out=>gen_src_data2,enable_in=>'1');

GEN: if read_latency_max_c > LATENCY generate
delay_i10: delayv generic map(SIZE=>ddr_data_width_c*FORK,DEPTH => (read_latency_max_c-LATENCY)) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>bus_readdata,out_out=>bus_readdata2,enable_in=>'1');
end generate GEN;

GEN2: if read_latency_max_c <= LATENCY generate
bus_readdata2 <= bus_readdata;
end generate GEN2;

gen_waitreq_out <= '1' when (doit='1' and bus_wait_request_in='1' and gen_src_eof_in='0') or (gen_valid='0' and gen_valid_in='1') else '0';

--------
-- Output
--------

bus_read_fork_out <= gen_fork_in(FORK-1 downto 0);
bus_addr_out <= gen_src_addr_in(FORK-1 downto 0);
bus_addr_mode_out <= gen_src_addr_mode_in;
bus_id_out <= gen_bus_id_source_in;
bus_data_type_out <= gen_data_type_source_in;
bus_data_model_out <= gen_data_model_source_in;
bus_cs_out <= gen_valid and (not gen_src_eof_in);
bus_read_out <= gen_valid and (not gen_src_eof_in);
bus_read_vm_out <= gen_vm_in; 
bus_read_vector_out <= gen_src_vector_in;
bus_read_data_flow_out <= gen_data_flow_in;
bus_read_stream_out <= gen_src_stream_in;
bus_read_stream_id_out <= gen_stream_id_in;
bus_read_scatter_out <= gen_src_scatter_in;
bus_read_start_out <= gen_src_start_in;
bus_read_end_out <= gen_src_end_in(FORK-1 downto 0);
bus_burstlen_out <= gen_src_burstlen_in;
doit <= gen_valid;
wr_data_out <= gen_src_data_in;


GEN100: FOR I IN (FORK-1) DOWNTO 0 GENERATE
wr_readdata_out(I) <= bus_readdata((I+1)*ddr_data_width_c-1 downto I*ddr_data_width_c);
END GENERATE GEN100;

GEN101: IF (FORK < fork_max_c) GENERATE
   GEN102: FOR I IN (fork_max_c-1) DOWNTO FORK GENERATE
   wr_readdata_out(I) <= (others=>'0');
   END GENERATE GEN102;
END GENERATE GEN101;

------
-- Direct read data to appropriate destination bus
------

PROCESS(dp_bus_id,dp_data_type,dp_data_model,bus_readdata,wr_req,wr_addr,wr_addr_mode,wr_src_vm,wr_burstlen,dp_thread,dp_mcast,gen_src_eof_in,bus_readdatavalid_in,
        gen_dst_vector_in,gen_data_flow_in,gen_dst_scatter_in,gen_dst_end_in,wr_fork,gen_dest_stream_in,gen_stream_id_in,bus_readdatavalid_vm_in)
BEGIN
wr_datavalid_out <= not gen_src_eof_in;
wr_readdatavalid_out <= bus_readdatavalid_in;
wr_readdatavalid_vm_out <= bus_readdatavalid_vm_in;
wr_addr_out <= (others=>(others=>'0'));
wr_fork_out <= (others=>'0');
wr_addr_out(FORK-1 downto 0) <= wr_addr;
wr_fork_out(FORK-1 downto 0) <= wr_fork;
wr_addr_mode_out <= wr_addr_mode;
wr_src_vm_out <= wr_src_vm;
wr_burstlen_out <= unsigned(wr_burstlen);
wr_bus_id_out <= dp_bus_id;
wr_thread_out <= dp_thread;
wr_mcast_out <= dp_mcast;
wr_data_type_out <= dp_data_type;
wr_data_model_out <= dp_data_model;
FOR I in 0 to NUM_DP_DST_PORT-1 LOOP
    if I=to_integer(dp_bus_id) then
        wr_req_out(I) <= wr_req;
    else
        wr_req_out(I) <= '0';
    end if;
    if I=to_integer(dp_bus_id) then
        wr_req_pending_p0_out(I) <= gen_valid_in and (not gen_vm_in);
    else
        wr_req_pending_p0_out(I) <= '0';
    end if;
    if I=to_integer(dp_bus_id) then
        wr_req_pending_p1_out(I) <= gen_valid_in and gen_vm_in;
    else
        wr_req_pending_p1_out(I) <= '0';
    end if;
    wr_vector_out(I) <= gen_dst_vector_in;
    wr_stream_out(I) <= gen_dest_stream_in;
    wr_stream_id_out(I) <= gen_stream_id_in;
    wr_data_flow_out(I) <= gen_data_flow_in;
    wr_scatter_out(I) <= gen_dst_scatter_in;
    wr_end_out(I) <= gen_dst_end_in;
END LOOP;
END PROCESS;


process(doit,bus_wait_request_in,gen_fork_in,gen_dst_addr_in,gen_dst_burstlen_in,gen_bus_id_dest_in,gen_data_type_dest_in,
        gen_thread_in,gen_mcast_in,gen_src_eof_in,gen_dst_addr_mode_in,gen_data_model_dest_in,gen_vm_in)
begin
    if doit='1' and (bus_wait_request_in='0' or gen_src_eof_in='1') then
        wr_req <= '1';
    else
        wr_req <= '0';
    end if;
    wr_addr <= gen_dst_addr_in(FORK-1 downto 0);
    wr_fork <= gen_fork_in(FORK-1 downto 0);
    wr_addr_mode <= gen_dst_addr_mode_in;
    wr_src_vm <= gen_vm_in;
    wr_burstlen <= gen_dst_burstlen_in;
    dp_bus_id <= gen_bus_id_dest_in;
    dp_data_type <= gen_data_type_dest_in;
    dp_data_model <= gen_data_model_dest_in;
    dp_thread <= gen_thread_in;
    dp_mcast <= gen_mcast_in;
end process;

END dp_source_behaviour;
