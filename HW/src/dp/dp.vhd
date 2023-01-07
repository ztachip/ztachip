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

-- This is the top module for DP (data-plane) processor.
-- Instructions are sent from MCORE to DP via dp_fetch
-- Instructions are then dispatched to dp_gen. There is a dp_gen instance for 
-- pcore,sram and ddr bus.
-- dp_source is responsible for driving the bus for read access
-- dp_sink is responsible for driving the bus for write access

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY dp IS
    generic(
            DP_THREAD_ID:integer;
            DP_READMASTER1_BURST_MODE:STD_LOGIC;
            DP_WRITEMASTER1_BURST_MODE:STD_LOGIC;
            DP_READMASTER2_BURST_MODE:STD_LOGIC;
            DP_WRITEMASTER2_BURST_MODE:STD_LOGIC;
            DP_READMASTER3_BURST_MODE:STD_LOGIC;
            DP_WRITEMASTER3_BURST_MODE:STD_LOGIC
    );
    port(
            SIGNAL clock_in                         : in STD_LOGIC;
            SIGNAL clock_x2_in                      : in STD_LOGIC;
            SIGNAL reset_in                         : in STD_LOGIC;
            
            -- Bus interface for configuration        
            SIGNAL bus_waddr_in                     : IN register_addr_t;
            SIGNAL bus_raddr_in                     : IN register_addr_t;
            SIGNAL bus_write_in                     : IN STD_LOGIC;
            SIGNAL bus_read_in                      : IN STD_LOGIC;
            SIGNAL bus_writedata_in                 : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
            SIGNAL bus_readdata_out                 : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
            SIGNAL bus_readdatavalid_out            : OUT STD_LOGIC;
            SIGNAL bus_writewait_out                : OUT STD_LOGIC;
            SIGNAL bus_readwait_out                 : OUT STD_LOGIC;
                        
            -- Bus interface for read master 1

            SIGNAL readmaster1_addr_out             : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
            SIGNAL readmaster1_fork_out             : OUT dp_fork_t;
            SIGNAL readmaster1_addr_mode_out        : OUT STD_LOGIC;
            SIGNAL readmaster1_cs_out               : OUT STD_LOGIC;
            SIGNAL readmaster1_read_out             : OUT STD_LOGIC;
            SIGNAL readmaster1_read_vm_out          : OUT STD_LOGIC;
            SIGNAL readmaster1_read_data_flow_out   : OUT data_flow_t;
            SIGNAL readmaster1_read_stream_out      : OUT STD_LOGIC;
            SIGNAL readmaster1_read_stream_id_out   : OUT stream_id_t;
            SIGNAL readmaster1_read_vector_out      : OUT dp_vector_t;
            SIGNAL readmaster1_read_scatter_out     : OUT scatter_t;
            SIGNAL readmaster1_readdatavalid_in     : IN STD_LOGIC;
            SIGNAL readmaster1_readdatavalid_vm_in  : IN STD_LOGIC;
            SIGNAL readmaster1_readdata_in          : IN STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL readmaster1_wait_request_in      : IN STD_LOGIC;
            SIGNAL readmaster1_burstlen_out         : OUT burstlen_t;
            SIGNAL readmaster1_bus_id_out           : OUT dp_bus_id_t;
            SIGNAL readmaster1_data_type_out        : OUT dp_data_type_t;
            SIGNAL readmaster1_data_model_out       : OUT dp_data_model_t;

            -- Bus interface for write master 1

            SIGNAL writemaster1_addr_out            : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
            SIGNAL writemaster1_fork_out            : OUT dp_fork_t;
            SIGNAL writemaster1_addr_mode_out       : OUT STD_LOGIC;
            SIGNAL writemaster1_vm_out              : OUT STD_LOGIC;
            SIGNAL writemaster1_mcast_out           : OUT mcast_t;
            SIGNAL writemaster1_cs_out              : OUT STD_LOGIC;
            SIGNAL writemaster1_write_out           : OUT STD_LOGIC;
            SIGNAL writemaster1_write_data_flow_out : OUT data_flow_t;
            SIGNAL writemaster1_write_vector_out    : OUT dp_vector_t;
            SIGNAL writemaster1_write_stream_out    : OUT std_logic;
            SIGNAL writemaster1_write_stream_id_out : OUT stream_id_t; 
            SIGNAL writemaster1_write_scatter_out   : OUT scatter_t;
            SIGNAL writemaster1_writedata_out       : OUT STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL writemaster1_wait_request_in     : IN STD_LOGIC;
            SIGNAL writemaster1_burstlen_out        : OUT burstlen_t;
            SIGNAL writemaster1_bus_id_out          : OUT dp_bus_id_t;
            SIGNAL writemaster1_data_type_out       : OUT dp_data_type_t;
            SIGNAL writemaster1_data_model_out      : OUT dp_data_model_t;
            SIGNAL writemaster1_thread_out          : OUT dp_thread_t;
            SIGNAL writemaster1_counter_in          : IN dp_counters_t(1 DOWNTO 0);

            -- Bus interface for read master 2

            SIGNAL readmaster2_addr_out             : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
            SIGNAL readmaster2_fork_out             : OUT std_logic_vector(fork_sram_c-1 downto 0);
            SIGNAL readmaster2_cs_out               : OUT STD_LOGIC;
            SIGNAL readmaster2_read_out             : OUT STD_LOGIC;
            SIGNAL readmaster2_read_vm_out          : OUT STD_LOGIC;
            SIGNAL readmaster2_read_vector_out      : OUT dp_vector_t;
            SIGNAL readmaster2_read_scatter_out     : OUT scatter_t;
            SIGNAL readmaster2_readdatavalid_in     : IN STD_LOGIC;
            SIGNAL readmaster2_readdatavalid_vm_in  : IN STD_LOGIC;
            SIGNAL readmaster2_readdata_in          : IN STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL readmaster2_wait_request_in      : IN STD_LOGIC;
            SIGNAL readmaster2_burstlen_out         : OUT burstlen_t;
            SIGNAL readmaster2_bus_id_out           : OUT dp_bus_id_t;

            -- Bus interface for write master 2

            SIGNAL writemaster2_addr_out            : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
            SIGNAL writemaster2_vm_out              : OUT STD_LOGIC;
            SIGNAL writemaster2_fork_out            : OUT std_logic_vector(fork_sram_c-1 downto 0);
            SIGNAL writemaster2_cs_out              : OUT STD_LOGIC;
            SIGNAL writemaster2_write_out           : OUT STD_LOGIC;
            SIGNAL writemaster2_write_vector_out    : OUT dp_vector_t;
            SIGNAL writemaster2_write_scatter_out   : OUT scatter_t;
            SIGNAL writemaster2_writedata_out       : OUT STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL writemaster2_wait_request_in     : IN STD_LOGIC;
            SIGNAL writemaster2_burstlen_out        : OUT burstlen_t;
            SIGNAL writemaster2_bus_id_out          : OUT dp_bus_id_t;
            SIGNAL writemaster2_thread_out          : OUT dp_thread_t;
            SIGNAL writemaster2_counter_in          : IN dp_counters_t(1 downto 0);

            -- Bus interface for read master 3
            
            SIGNAL readmaster3_addr_out             : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
            SIGNAL readmaster3_cs_out               : OUT STD_LOGIC;
            SIGNAL readmaster3_read_out             : OUT STD_LOGIC;
            SIGNAL readmaster3_read_vm_out          : OUT STD_LOGIC;
            SIGNAL readmaster3_read_vector_out      : OUT dp_vector_t;
            SIGNAL readmaster3_read_scatter_out     : OUT scatter_t;
            SIGNAL readmaster3_read_start_out       : OUT unsigned(ddr_vector_depth_c downto 0);
            SIGNAL readmaster3_read_end_out         : OUT vectors_t(fork_ddr_c-1 downto 0);
            SIGNAL readmaster3_readdatavalid_in     : IN STD_LOGIC;
            SIGNAL readmaster3_readdatavalid_vm_in  : IN STD_LOGIC;
            SIGNAL readmaster3_readdata_in          : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
            SIGNAL readmaster3_wait_request_in      : IN STD_LOGIC;
            SIGNAL readmaster3_burstlen_out         : OUT burstlen_t;
            SIGNAL readmaster3_bus_id_out           : OUT dp_bus_id_t;
            SIGNAL readmaster3_filler_data_out      : OUT STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

            -- Bus interface for write master 3
            
            SIGNAL writemaster3_addr_out            : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
            SIGNAL writemaster3_cs_out              : OUT STD_LOGIC;
            SIGNAL writemaster3_write_out           : OUT STD_LOGIC;
            SIGNAL writemaster3_vm_out              : OUT STD_LOGIC;
            SIGNAL writemaster3_write_vector_out    : OUT dp_vector_t;
            SIGNAL writemaster3_write_scatter_out   : OUT scatter_t;
            SIGNAL writemaster3_write_end_out       : OUT vectors_t(fork_ddr_c-1 downto 0);
            SIGNAL writemaster3_writedata_out       : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
            SIGNAL writemaster3_wait_request_in     : IN STD_LOGIC;
            SIGNAL writemaster3_burstlen_out        : OUT burstlen_t;
            SIGNAL writemaster3_burstlen2_out       : OUT burstlen2_t;
            SIGNAL writemaster3_burstlen3_out       : OUT burstlen_t;
            SIGNAL writemaster3_bus_id_out          : OUT dp_bus_id_t;
            SIGNAL writemaster3_thread_out          : OUT dp_thread_t;
            SIGNAL writemaster3_counter_in          : IN dp_counter_t;

            -- Task control
            
            SIGNAL task_start_addr_out              : OUT instruction_addr_t;
            SIGNAL task_out                         : OUT STD_LOGIC;
            SIGNAL task_pending_out                 : OUT STD_LOGIC;
            SIGNAL task_vm_out                      : OUT STD_LOGIC;
            SIGNAL task_pcore_out                   : OUT pcore_t;
            SIGNAL task_lockstep_out                : OUT STD_LOGIC;
            SIGNAL task_tid_mask_out                : OUT tid_mask_t;
            SIGNAL task_iregister_auto_out          : OUT iregister_auto_t;
            SIGNAL task_data_model_out              : OUT dp_data_model_t;
            SIGNAL task_busy_in                     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            SIGNAL task_ready_in                    : IN STD_LOGIC;

            -- BAR info
            
            SIGNAL bar_in                           : IN dp_addrs_t(dp_bus_id_max_c-1 downto 0);

            -- Indication
            
            SIGNAL indication_avail_out             : OUT STD_LOGIC;
            
            SIGNAL ddr_tx_busy_in                   : IN STD_LOGIC
    );
END dp;

ARCHITECTURE dp_behaviour of dp is

SIGNAL ready:STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
SIGNAL valid:STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
SIGNAL instruction: dp_instruction_t;
SIGNAL pre_instruction: dp_instruction_t;

SIGNAL gen_pcore_src_valid:STD_LOGIC;
SIGNAL gen_pcore_vm:STD_LOGIC;
SIGNAL gen_pcore_src_addr: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_pcore_src_addr_mode:STD_LOGIC;
SIGNAL gen_pcore_src_eof: STD_LOGIC;
SIGNAL gen_pcore_src_burstlen: burstlen_t;
SIGNAL gen_pcore_dst_addr: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_pcore_dst_addr_mode:STD_LOGIC;
SIGNAL gen_pcore_dst_burstlen: burstlen_t;
SIGNAL gen_pcore_bus_id_source: dp_bus_id_t;
SIGNAL gen_pcore_bus_id_dest: dp_bus_id_t;
SIGNAL gen_pcore_data_type_source: dp_data_type_t;
SIGNAL gen_pcore_data_type_dest: dp_data_type_t;
SIGNAL gen_pcore_data_model_source: dp_data_model_t;
SIGNAL gen_pcore_data_model_dest: dp_data_model_t;
SIGNAL gen_pcore_thread: dp_thread_t;
SIGNAL gen_pcore_mcast: mcast_t;
SIGNAL gen_pcore_fork:std_logic_vector(fork_max_c-1 downto 0);
SIGNAL gen_pcore_src_vector:dp_vector_t;
SIGNAL gen_pcore_dst_vector:dp_vector_t;
SIGNAL gen_pcore_src_scatter:scatter_t;
SIGNAL gen_pcore_dst_scatter:scatter_t;
SIGNAL gen_pcore_src_start:unsigned(ddr_vector_depth_c downto 0);
SIGNAL gen_pcore_src_end:vector_fork_t;
SIGNAL gen_pcore_dst_end:vector_fork_t;
SIGNAL gen_pcore_data:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL gen_pcore_data_flow:data_flow_t;
SIGNAL gen_pcore_src_stream:STD_LOGIC;
SIGNAL gen_pcore_dest_stream:STD_LOGIC;
SIGNAL gen_pcore_stream_id:stream_id_t;

SIGNAL gen_sram_src_valid:STD_LOGIC;
SIGNAL gen_sram_vm:STD_LOGIC;
SIGNAL gen_sram_src_addr: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_sram_src_addr_mode:STD_LOGIC;
SIGNAL gen_sram_src_eof: STD_LOGIC;
SIGNAL gen_sram_src_burstlen: burstlen_t;
SIGNAL gen_sram_dst_addr: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_sram_dst_addr_mode:STD_LOGIC;
SIGNAL gen_sram_dst_burstlen: burstlen_t;
SIGNAL gen_sram_bus_id_source: dp_bus_id_t;
SIGNAL gen_sram_bus_id_dest: dp_bus_id_t;
SIGNAL gen_sram_data_type_source: dp_data_type_t;
SIGNAL gen_sram_data_type_dest: dp_data_type_t;
SIGNAL gen_sram_data_model_source: dp_data_model_t;
SIGNAL gen_sram_data_model_dest: dp_data_model_t;
SIGNAL gen_sram_thread: dp_thread_t;
SIGNAL gen_sram_mcast: mcast_t;
SIGNAL gen_sram_fork:std_logic_vector(fork_max_c-1 downto 0);
SIGNAL gen_sram_src_vector:dp_vector_t;
SIGNAL gen_sram_dst_vector:dp_vector_t;
SIGNAL gen_sram_src_scatter:scatter_t;
SIGNAL gen_sram_dst_scatter:scatter_t;
SIGNAL gen_sram_src_start:unsigned(ddr_vector_depth_c downto 0);
SIGNAL gen_sram_src_end:vector_fork_t;
SIGNAL gen_sram_dst_end:vector_fork_t;
SIGNAL gen_sram_data:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL gen_sram_data_flow:data_flow_t;
SIGNAL gen_sram_src_stream:STD_LOGIC;
SIGNAL gen_sram_dest_stream:STD_LOGIC;
SIGNAL gen_sram_stream_id:stream_id_t;

SIGNAL gen_ddr_src_valid:STD_LOGIC;
SIGNAL gen_ddr_vm:STD_LOGIC;
SIGNAL gen_ddr_src_addr: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_ddr_src_addr_mode:STD_LOGIC;
SIGNAL gen_ddr_src_eof: STD_LOGIC;
SIGNAL gen_ddr_src_burstlen: burstlen_t;
SIGNAL gen_ddr_dst_addr: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_ddr_dst_addr_mode:STD_LOGIC;
SIGNAL gen_ddr_dst_burstlen: burstlen_t;
SIGNAL gen_ddr_bus_id_source: dp_bus_id_t;
SIGNAL gen_ddr_bus_id_dest: dp_bus_id_t;
SIGNAL gen_ddr_data_type_source: dp_data_type_t;
SIGNAL gen_ddr_data_type_dest: dp_data_type_t;
SIGNAL gen_ddr_data_model_source: dp_data_model_t;
SIGNAL gen_ddr_data_model_dest: dp_data_model_t;
SIGNAL gen_ddr_thread: dp_thread_t;
SIGNAL gen_ddr_mcast: mcast_t;
SIGNAL gen_ddr_fork:std_logic_vector(fork_max_c-1 downto 0);
SIGNAL gen_ddr_src_vector:dp_vector_t;
SIGNAL gen_ddr_dst_vector:dp_vector_t;
SIGNAL gen_ddr_src_scatter:scatter_t;
SIGNAL gen_ddr_dst_scatter:scatter_t;
SIGNAL gen_ddr_src_start:unsigned(ddr_vector_depth_c downto 0);
SIGNAL gen_ddr_src_end:vector_fork_t;
SIGNAL gen_ddr_dst_end:vector_fork_t;
SIGNAL gen_ddr_data:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL gen_ddr_data_flow:data_flow_t;
SIGNAL gen_ddr_src_stream:STD_LOGIC;
SIGNAL gen_ddr_dest_stream:STD_LOGIC;
SIGNAL gen_ddr_stream_id:stream_id_t;

SIGNAL wr_datavalid: STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_addr:dp_fork_full_addrs_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_fork:dp_forks_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_addr_mode:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_src_vm:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_data:dp_datas_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_readdata:dp_fork_datas_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_readdatavalid:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_readdatavalid_vm:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_burstlen:burstlens_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_bus_id:dp_bus_ids_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_thread:dp_threads_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_data_type:dp_data_types_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_data_model:dp_data_models_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_mcast:mcasts_t(NUM_DP_SRC_PORT-1 downto 0);

SIGNAL waitreq:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_full:STD_LOGIC;
SIGNAL wr_req:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_req_p0_pending:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_req_p1_pending:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);

SIGNAL wr_sram_full:STD_LOGIC;
SIGNAL wr_sram_req:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_req_p0_pending:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_req_p1_pending:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);

SIGNAL wr_ddr_full:STD_LOGIC;
SIGNAL wr_ddr_req:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_req_p0_pending:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_req_p1_pending:STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);

SIGNAL indication_avail:STD_LOGIC;
SIGNAL thread:dp_thread_t;

SIGNAL ddr_readdata_conv:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL ddr_readdatavalid:STD_LOGIC;

SIGNAL ddr_write_addr:STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);
SIGNAL ddr_write_vector:dp_vector_t;
SIGNAL ddr_write_scatter:STD_LOGIC;
SIGNAL ddr_write_cs:STD_LOGIC;
SIGNAL ddr_write_write:STD_LOGIC;
SIGNAL ddr_write_writedata:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL ddr_write_wait_request:STD_LOGIC;
SIGNAL ddr_write_burstlen:burstlen_t;
SIGNAL ddr_write_bus_id:dp_bus_id_t;
SIGNAL ddr_write_data_type:dp_data_type_t;
SIGNAL ddr_write_thread:dp_thread_t;
SIGNAL ddr_read_data_type:dp_data_type_t;


SIGNAL full:STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);

SIGNAL wr_maxburstlen:burstlens_t(NUM_DP_DST_PORT-1 downto 0);

SIGNAL pcore_read_pending_p0:STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
SIGNAL sram_read_pending_p0:STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
SIGNAL ddr_read_pending_p0:STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);

SIGNAL pcore_read_pending_p1:STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
SIGNAL sram_read_pending_p1:STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
SIGNAL ddr_read_pending_p1:STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);


SIGNAL wr_vector: dp_vectors_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_vector: dp_vectors_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_vector: dp_vectors_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_scatter: scatters_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_scatter: scatters_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_scatter: scatters_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_end: vector_forks_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_end: vector_forks_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_end: vector_forks_t(NUM_DP_SRC_PORT-1 downto 0);

SIGNAL wr_data_flow: data_flows_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_data_flow: data_flows_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_data_flow: data_flows_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_stream:std_logic_vector(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_stream:std_logic_vector(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_stream:std_logic_vector(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_stream_id:stream_ids_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_sram_stream_id:stream_ids_t(NUM_DP_SRC_PORT-1 downto 0);
SIGNAL wr_ddr_stream_id:stream_ids_t(NUM_DP_SRC_PORT-1 downto 0);

SIGNAL log1:STD_LOGIC_VECTOR(host_width_c-1 downto 0);
SIGNAL log1_valid:STD_LOGIC;
SIGNAL log2:STD_LOGIC_VECTOR(host_width_c-1 downto 0);
SIGNAL log2_valid:STD_LOGIC;

SIGNAL readmaster1_addr:dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL readmaster2_addr:dp_full_addrs_t(fork_sram_c-1 downto 0);
SIGNAL readmaster3_addr:dp_full_addrs_t(fork_ddr_c-1 downto 0);
SIGNAL writemaster1_addr:dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL writemaster2_addr:dp_full_addrs_t(fork_sram_c-1 downto 0);
SIGNAL writemaster3_addr:dp_full_addrs_t(fork_ddr_c-1 downto 0);

begin

readmaster1_addr_out <= std_logic_vector(readmaster1_addr(0)(local_bus_width_c-1 DOWNTO 0));
readmaster2_addr_out <= std_logic_vector(readmaster2_addr(0)(dp_bus2_addr_width_c-1 DOWNTO 0));
readmaster3_addr_out <= std_logic_vector(readmaster3_addr(0)(dp_full_addr_width_c-1 DOWNTO 0));
readmaster3_filler_data_out <= wr_data(dp_bus_id_ddr_c)(2*data_width_c-1 downto 0);
writemaster1_addr_out <= std_logic_vector(writemaster1_addr(0)(local_bus_width_c-1 DOWNTO 0));
writemaster2_addr_out <= std_logic_vector(writemaster2_addr(0)(dp_bus2_addr_width_c-1 DOWNTO 0));
writemaster3_addr_out <= std_logic_vector(writemaster3_addr(0)(dp_full_addr_width_c-1 DOWNTO 0));

-- Combine indication available signals from the 2 DP threads
indication_avail_out <= indication_avail;

-- Set address mask to identify process 

thread <= to_unsigned(0,dp_thread_t'length);

full <= wr_full & wr_sram_full & wr_ddr_full;

-----------------
-- FETCH stage. Taking requests from mcore
-----------------

dp_fetch_1_i: dp_fetch generic map(
                            DP_THREAD_ID=>DP_THREAD_ID,
                            NUM_DP_SRC_PORT=>NUM_DP_SRC_PORT,
                            NUM_DP_DST_PORT=>NUM_DP_DST_PORT
                            )
                        port map(
                            clock_in=>clock_in,
                            clock_x2_in=>clock_x2_in,
                            reset_in=>reset_in,
                            bus_waddr_in=>bus_waddr_in,
                            bus_raddr_in=>bus_raddr_in,
                            bus_write_in=>bus_write_in,
                            bus_read_in=>bus_read_in,
                            bus_writedata_in=>bus_writedata_in,
                            bus_readdata_out=>bus_readdata_out,
                            bus_readdatavalid_out=>bus_readdatavalid_out,
                            bus_writewait_out=>bus_writewait_out,
                            bus_readwait_out=>bus_readwait_out,
                            ready_in=>ready,
                            instruction_valid_out=>valid,
                            instruction_out=>instruction,
                            pre_instruction_out=>pre_instruction,
                            
                            pcore_sink_counter_in => writemaster1_counter_in,
                            sram_sink_counter_in => writemaster2_counter_in,
                            ddr_sink_counter_in => writemaster3_counter_in,

                            task_start_addr_out => task_start_addr_out,
                            task_out => task_out,
                            task_pending_out => task_pending_out,
                            task_vm_out => task_vm_out,
                            task_pcore_out =>task_pcore_out,
                            task_lockstep_out => task_lockstep_out,
                            task_tid_mask_out => task_tid_mask_out,
                            task_iregister_auto_out => task_iregister_auto_out,
                            task_data_model_out => task_data_model_out,
                            task_busy_in => task_busy_in,
                            task_ready_in => task_ready_in,

                            indication_avail_out => indication_avail,

                            log1_in => log1,
                            log1_valid_in => log1_valid,

                            log2_in => log2,
                            log2_valid_in => log2_valid,

                            pcore_read_pending_p0_in => pcore_read_pending_p0,
                            sram_read_pending_p0_in => sram_read_pending_p0,
                            ddr_read_pending_p0_in => ddr_read_pending_p0,

                            pcore_read_pending_p1_in => pcore_read_pending_p1,
                            sram_read_pending_p1_in => sram_read_pending_p1,
                            ddr_read_pending_p1_in => ddr_read_pending_p1,
                            
                            ddr_tx_busy_in => ddr_tx_busy_in
                            );

dp_gen_core_i: dp_gen_core
    port map(
       clock_in=>clock_in,
       reset_in=>reset_in,

       -- signal to communicate with dp_fetch
    
       ready_out=>ready,
       instruction_valid_in=>valid,
       instruction_in=>instruction,
       pre_instruction_in=>pre_instruction,
       wr_maxburstlen_in=>wr_maxburstlen,
       full_in=>full,
       waitreq_in=>waitreq,
       bar_in=>bar_in,

       log1_out=>log1,
       log1_valid_out=>log1_valid,
       
       log2_out=>log2,
       log2_valid_out=>log2_valid,

       -- commands to send to dp_source for pcore memory space

       gen_pcore_src_valid_out =>gen_pcore_src_valid,
       gen_pcore_vm_out => gen_pcore_vm,
       gen_pcore_fork_out =>gen_pcore_fork,
       gen_pcore_data_flow_out =>gen_pcore_data_flow,
       gen_pcore_src_stream_out =>gen_pcore_src_stream,
       gen_pcore_dest_stream_out =>gen_pcore_dest_stream,
       gen_pcore_stream_id_out =>gen_pcore_stream_id,
       gen_pcore_src_vector_out =>gen_pcore_src_vector,
       gen_pcore_dst_vector_out =>gen_pcore_dst_vector,
       gen_pcore_src_scatter_out =>gen_pcore_src_scatter,
       gen_pcore_dst_scatter_out =>gen_pcore_dst_scatter,
       gen_pcore_src_start_out =>gen_pcore_src_start,
       gen_pcore_src_end_out =>gen_pcore_src_end,
       gen_pcore_dst_end_out =>gen_pcore_dst_end,
       gen_pcore_src_addr_out =>gen_pcore_src_addr,
       gen_pcore_src_addr_mode_out =>gen_pcore_src_addr_mode,
       gen_pcore_dst_addr_out =>gen_pcore_dst_addr,
       gen_pcore_dst_addr_mode_out =>gen_pcore_dst_addr_mode,
       gen_pcore_src_eof_out =>gen_pcore_src_eof,
       gen_pcore_bus_id_source_out =>gen_pcore_bus_id_source,
       gen_pcore_data_type_source_out =>gen_pcore_data_type_source,
       gen_pcore_data_model_source_out =>gen_pcore_data_model_source,
       gen_pcore_bus_id_dest_out =>gen_pcore_bus_id_dest,
       gen_pcore_data_type_dest_out =>gen_pcore_data_type_dest,
       gen_pcore_data_model_dest_out =>gen_pcore_data_model_dest,
       gen_pcore_src_burstlen_out =>gen_pcore_src_burstlen,
       gen_pcore_dst_burstlen_out =>gen_pcore_dst_burstlen,
       gen_pcore_thread_out =>gen_pcore_thread,
       gen_pcore_mcast_out =>gen_pcore_mcast,
       gen_pcore_data_out =>gen_pcore_data,

       -- commands to send to dp_source for sram memory space

       gen_sram_src_valid_out =>gen_sram_src_valid,
       gen_sram_vm_out => gen_sram_vm,
       gen_sram_fork_out =>gen_sram_fork,
       gen_sram_data_flow_out =>gen_sram_data_flow,
       gen_sram_src_stream_out =>gen_sram_src_stream,
       gen_sram_dest_stream_out =>gen_sram_dest_stream,
       gen_sram_stream_id_out =>gen_sram_stream_id,
       gen_sram_src_vector_out =>gen_sram_src_vector,
       gen_sram_dst_vector_out =>gen_sram_dst_vector,
       gen_sram_src_scatter_out =>gen_sram_src_scatter,
       gen_sram_dst_scatter_out =>gen_sram_dst_scatter,
       gen_sram_src_start_out =>gen_sram_src_start,
       gen_sram_src_end_out =>gen_sram_src_end,
       gen_sram_dst_end_out =>gen_sram_dst_end,
       gen_sram_src_addr_out =>gen_sram_src_addr,
       gen_sram_src_addr_mode_out =>gen_sram_src_addr_mode,
       gen_sram_dst_addr_out =>gen_sram_dst_addr,
       gen_sram_dst_addr_mode_out =>gen_sram_dst_addr_mode,
       gen_sram_src_eof_out =>gen_sram_src_eof,
       gen_sram_bus_id_source_out =>gen_sram_bus_id_source,
       gen_sram_data_type_source_out =>gen_sram_data_type_source,
       gen_sram_data_model_source_out =>gen_sram_data_model_source,
       gen_sram_bus_id_dest_out =>gen_sram_bus_id_dest,
       gen_sram_data_type_dest_out =>gen_sram_data_type_dest,
       gen_sram_data_model_dest_out =>gen_sram_data_model_dest,
       gen_sram_src_burstlen_out =>gen_sram_src_burstlen,
       gen_sram_dst_burstlen_out =>gen_sram_dst_burstlen,
       gen_sram_thread_out =>gen_sram_thread,
       gen_sram_mcast_out =>gen_sram_mcast,
       gen_sram_data_out =>gen_sram_data,

       -- commands to send to dp_source for ddr memory space

       gen_ddr_src_valid_out =>gen_ddr_src_valid,
       gen_ddr_vm_out => gen_ddr_vm,
       gen_ddr_fork_out =>gen_ddr_fork,
       gen_ddr_data_flow_out =>gen_ddr_data_flow,
       gen_ddr_src_stream_out =>gen_ddr_src_stream,
       gen_ddr_dest_stream_out =>gen_ddr_dest_stream,
       gen_ddr_stream_id_out =>gen_ddr_stream_id,
       gen_ddr_src_vector_out =>gen_ddr_src_vector,
       gen_ddr_dst_vector_out =>gen_ddr_dst_vector,
       gen_ddr_src_scatter_out =>gen_ddr_src_scatter,
       gen_ddr_dst_scatter_out =>gen_ddr_dst_scatter,
       gen_ddr_src_start_out =>gen_ddr_src_start,
       gen_ddr_src_end_out =>gen_ddr_src_end,
       gen_ddr_dst_end_out =>gen_ddr_dst_end,
       gen_ddr_src_addr_out =>gen_ddr_src_addr,
       gen_ddr_src_addr_mode_out =>gen_ddr_src_addr_mode,
       gen_ddr_dst_addr_out =>gen_ddr_dst_addr,
       gen_ddr_dst_addr_mode_out =>gen_ddr_dst_addr_mode,
       gen_ddr_src_eof_out =>gen_ddr_src_eof,
       gen_ddr_bus_id_source_out =>gen_ddr_bus_id_source,
       gen_ddr_data_type_source_out =>gen_ddr_data_type_source,
       gen_ddr_data_model_source_out =>gen_ddr_data_model_source,
       gen_ddr_bus_id_dest_out =>gen_ddr_bus_id_dest,
       gen_ddr_data_type_dest_out =>gen_ddr_data_type_dest,
       gen_ddr_data_model_dest_out =>gen_ddr_data_model_dest,
       gen_ddr_src_burstlen_out =>gen_ddr_src_burstlen,
       gen_ddr_dst_burstlen_out =>gen_ddr_dst_burstlen,
       gen_ddr_thread_out =>gen_ddr_thread,
       gen_ddr_mcast_out =>gen_ddr_mcast,
       gen_ddr_data_out =>gen_ddr_data
    );

------------- 
--- Interface to PCORE read bus
-------------

dp_source1_i: dp_source
        GENERIC MAP(
            BUS_ID=>dp_bus_id_register_c,
            NUM_DP_DST_PORT=>NUM_DP_DST_PORT,
            LATENCY=>read_latency_register_c,
            BUS_WIDTH=>dp_full_addr_width_c,
            FORK=>fork_pcore_c,
            INSTANCE=>0
        )
        PORT MAP(
            clock_in=>clock_in,
            reset_in=>reset_in,

            bus_addr_out=>readmaster1_addr,
            bus_addr_mode_out=>readmaster1_addr_mode_out,
            bus_cs_out=>readmaster1_cs_out,
            bus_read_out=>readmaster1_read_out,
            bus_read_vm_out=>readmaster1_read_vm_out,
            bus_read_fork_out=>readmaster1_fork_out,
            bus_read_data_flow_out=>readmaster1_read_data_flow_out,
            bus_read_stream_out=>readmaster1_read_stream_out,
            bus_read_stream_id_out=>readmaster1_read_stream_id_out,
            bus_read_vector_out=>readmaster1_read_vector_out,
            bus_read_scatter_out=>readmaster1_read_scatter_out,
            bus_read_start_out=>open,
            bus_read_end_out=>open,
            bus_readdatavalid_in=>readmaster1_readdatavalid_in,
            bus_readdatavalid_vm_in=>readmaster1_readdatavalid_vm_in,
            bus_readdata_in=>readmaster1_readdata_in,
            bus_wait_request_in=>readmaster1_wait_request_in,
            bus_burstlen_out=>readmaster1_burstlen_out,
            bus_id_out=>readmaster1_bus_id_out,
            bus_data_type_out=>readmaster1_data_type_out,
            bus_data_model_out=>readmaster1_data_model_out,

            gen_waitreq_out=>waitreq(0),
            gen_valid_in=>gen_pcore_src_valid,
            gen_vm_in=>gen_pcore_vm,
            gen_fork_in=>gen_pcore_fork,
            gen_data_flow_in=>gen_pcore_data_flow,
            gen_src_stream_in=>gen_pcore_src_stream,
            gen_dest_stream_in=>gen_pcore_dest_stream,
            gen_stream_id_in=>gen_pcore_stream_id,
            gen_src_vector_in=>gen_pcore_src_vector,
            gen_dst_vector_in=>gen_pcore_dst_vector,
            gen_src_scatter_in=>gen_pcore_src_scatter,
            gen_dst_scatter_in=>gen_pcore_dst_scatter,
            gen_src_start_in=>gen_pcore_src_start,
            gen_src_end_in=>gen_pcore_src_end,
            gen_dst_end_in=>gen_pcore_dst_end,
            gen_src_eof_in=>gen_pcore_src_eof,
            gen_src_addr_in=>gen_pcore_src_addr,
            gen_src_addr_mode_in=>gen_pcore_src_addr_mode,
            gen_dst_addr_in=>gen_pcore_dst_addr,
            gen_dst_addr_mode_in=>gen_pcore_dst_addr_mode,
            gen_bus_id_source_in=>gen_pcore_bus_id_source,
            gen_data_type_source_in=>gen_pcore_data_type_source,
            gen_data_model_source_in=>gen_pcore_data_model_source,
            gen_bus_id_dest_in=>gen_pcore_bus_id_dest,
            gen_data_type_dest_in=>gen_pcore_data_type_dest,
            gen_data_model_dest_in=>gen_pcore_data_model_dest,
            gen_src_burstlen_in=>gen_pcore_src_burstlen,
            gen_dst_burstlen_in=>gen_pcore_dst_burstlen,
            gen_thread_in=>gen_pcore_thread,
            gen_mcast_in=>gen_pcore_mcast,
            gen_src_data_in=>gen_pcore_data,

            wr_req_out(0)=> wr_req(0),
            wr_req_out(1)=> wr_sram_req(0),
            wr_req_out(2)=> wr_ddr_req(0),

            wr_req_pending_p0_out(0)=> wr_req_p0_pending(0),
            wr_req_pending_p0_out(1)=> wr_sram_req_p0_pending(0),
            wr_req_pending_p0_out(2)=> wr_ddr_req_p0_pending(0),

            wr_req_pending_p1_out(0)=> wr_req_p1_pending(0),
            wr_req_pending_p1_out(1)=> wr_sram_req_p1_pending(0),
            wr_req_pending_p1_out(2)=> wr_ddr_req_p1_pending(0),
            
            wr_full_in(0) => wr_full,
            wr_full_in(1) => wr_sram_full,
            wr_full_in(2) => wr_ddr_full,

            wr_data_flow_out(0)=>wr_data_flow(0),
            wr_data_flow_out(1)=>wr_sram_data_flow(0),
            wr_data_flow_out(2)=>wr_ddr_data_flow(0),

            wr_vector_out(0)=>wr_vector(0),
            wr_vector_out(1)=>wr_sram_vector(0),
            wr_vector_out(2)=>wr_ddr_vector(0),

            wr_stream_out(0)=>wr_stream(0),
            wr_stream_out(1)=>wr_sram_stream(0),
            wr_stream_out(2)=>wr_ddr_stream(0),

            wr_stream_id_out(0)=>wr_stream_id(0),
            wr_stream_id_out(1)=>wr_sram_stream_id(0),
            wr_stream_id_out(2)=>wr_ddr_stream_id(0),

            wr_scatter_out(0)=>wr_scatter(0),
            wr_scatter_out(1)=>wr_sram_scatter(0),
            wr_scatter_out(2)=>wr_ddr_scatter(0),

            wr_end_out(0)=>wr_end(0),
            wr_end_out(1)=>wr_sram_end(0),
            wr_end_out(2)=>wr_ddr_end(0),

            wr_addr_out=> wr_addr(0),

            wr_fork_out=> wr_fork(0),

            wr_src_vm_out => wr_src_vm(0),

            wr_addr_mode_out=>wr_addr_mode(0),

            wr_datavalid_out => wr_datavalid(0),

            wr_data_out=> wr_data(0),

            wr_readdatavalid_out => wr_readdatavalid(0),

            wr_readdatavalid_vm_out => wr_readdatavalid_vm(0),

            wr_readdata_out => wr_readdata(0),

            wr_burstlen_out=> wr_burstlen(0),                        

            wr_bus_id_out=> wr_bus_id(0),                        

            wr_thread_out=>wr_thread(0),

            wr_data_type_out=>wr_data_type(0),

            wr_data_model_out=>wr_data_model(0),

            wr_mcast_out=>wr_mcast(0)
            );

------------
-- Interface to SRAM read bus
------------

dp_source2_i: dp_source 
        GENERIC MAP(
            BUS_ID=>dp_bus_id_sram_c,
            NUM_DP_DST_PORT=>NUM_DP_DST_PORT,
            LATENCY=>read_latency_sram_c,
            BUS_WIDTH=>dp_full_addr_width_c,
            FORK=>fork_sram_c,
            INSTANCE=>0
        )
        PORT MAP(
            clock_in=>clock_in,
            reset_in=>reset_in,

            bus_addr_out=>readmaster2_addr,
            bus_cs_out=>readmaster2_cs_out,
            bus_read_out=>readmaster2_read_out,
            bus_read_vm_out=>readmaster2_read_vm_out,
            bus_read_fork_out=>readmaster2_fork_out,
            bus_read_data_flow_out=>open,
            bus_read_stream_out=>open,
            bus_read_stream_id_out=>open,
            bus_read_vector_out=>readmaster2_read_vector_out,
            bus_read_scatter_out=>readmaster2_read_scatter_out,
            bus_read_start_out=>open,
            bus_read_end_out=>open,
            bus_readdatavalid_in=>readmaster2_readdatavalid_in,
            bus_readdatavalid_vm_in=>readmaster2_readdatavalid_vm_in,
            bus_readdata_in=>readmaster2_readdata_in,
            bus_wait_request_in=>readmaster2_wait_request_in,
            bus_burstlen_out=>readmaster2_burstlen_out,
            bus_id_out=>readmaster2_bus_id_out,
            bus_data_type_out=>open,
            bus_data_model_out=>open,

            gen_waitreq_out=>waitreq(1),
            gen_valid_in=>gen_sram_src_valid,
            gen_vm_in=>gen_sram_vm,
            gen_fork_in=>gen_sram_fork,
            gen_data_flow_in=>gen_sram_data_flow,
            gen_src_stream_in=>gen_sram_src_stream,
            gen_dest_stream_in=>gen_sram_dest_stream,
            gen_stream_id_in=>gen_sram_stream_id,
            gen_src_vector_in=>gen_sram_src_vector,
            gen_dst_vector_in=>gen_sram_dst_vector,
            gen_src_scatter_in=>gen_sram_src_scatter,
            gen_dst_scatter_in=>gen_sram_dst_scatter,
            gen_src_start_in=>gen_sram_src_start,
            gen_src_end_in=>gen_sram_src_end,
            gen_dst_end_in=>gen_sram_dst_end,
            gen_src_eof_in=>gen_sram_src_eof,
            gen_src_addr_in=>gen_sram_src_addr,
            gen_src_addr_mode_in=>gen_sram_src_addr_mode,
            gen_dst_addr_in=>gen_sram_dst_addr,
            gen_dst_addr_mode_in=>gen_sram_dst_addr_mode,
            gen_bus_id_source_in=>gen_sram_bus_id_source,
            gen_data_type_source_in=>gen_sram_data_type_source,
            gen_data_model_source_in=>gen_sram_data_model_source,
            gen_bus_id_dest_in=>gen_sram_bus_id_dest,
            gen_data_type_dest_in=>gen_sram_data_type_dest,
            gen_data_model_dest_in=>gen_sram_data_model_dest,
            gen_src_burstlen_in=>gen_sram_src_burstlen,
            gen_dst_burstlen_in=>gen_sram_dst_burstlen,
            gen_thread_in=>gen_sram_thread,
            gen_mcast_in=>gen_sram_mcast,
            gen_src_data_in=>gen_sram_data,

            wr_req_out(0)=> wr_req(1),
            wr_req_out(1)=> wr_sram_req(1),
            wr_req_out(2)=> wr_ddr_req(1),

            wr_req_pending_p0_out(0)=> wr_req_p0_pending(1),
            wr_req_pending_p0_out(1)=> wr_sram_req_p0_pending(1),
            wr_req_pending_p0_out(2)=> wr_ddr_req_p0_pending(1),

            wr_req_pending_p1_out(0)=> wr_req_p1_pending(1),
            wr_req_pending_p1_out(1)=> wr_sram_req_p1_pending(1),
            wr_req_pending_p1_out(2)=> wr_ddr_req_p1_pending(1),
                        
            wr_full_in(0) => wr_full,
            wr_full_in(1) => wr_sram_full,
            wr_full_in(2) => wr_ddr_full,

            wr_data_flow_out(0)=>wr_data_flow(1),
            wr_data_flow_out(1)=>wr_sram_data_flow(1),
            wr_data_flow_out(2)=>wr_ddr_data_flow(1),
                                    
            wr_vector_out(0)=>wr_vector(1),
            wr_vector_out(1)=>wr_sram_vector(1),
            wr_vector_out(2)=>wr_ddr_vector(1),

            wr_stream_out(0)=>wr_stream(1),
            wr_stream_out(1)=>wr_sram_stream(1),
            wr_stream_out(2)=>wr_ddr_stream(1),

            wr_stream_id_out(0)=>wr_stream_id(1),
            wr_stream_id_out(1)=>wr_sram_stream_id(1),
            wr_stream_id_out(2)=>wr_ddr_stream_id(1),

            wr_scatter_out(0)=>wr_scatter(1),
            wr_scatter_out(1)=>wr_sram_scatter(1),
            wr_scatter_out(2)=>wr_ddr_scatter(1),

            wr_end_out(0)=>wr_end(1),
            wr_end_out(1)=>wr_sram_end(1),
            wr_end_out(2)=>wr_ddr_end(1),

            wr_addr_out=> wr_addr(1),

            wr_fork_out=> wr_fork(1),

            wr_src_vm_out => wr_src_vm(1),

            wr_addr_mode_out=>wr_addr_mode(1),

            wr_datavalid_out => wr_datavalid(1),

            wr_data_out=> wr_data(1),

            wr_readdatavalid_out => wr_readdatavalid(1),

            wr_readdatavalid_vm_out => wr_readdatavalid_vm(1),

            wr_readdata_out => wr_readdata(1),

            wr_burstlen_out=> wr_burstlen(1),                        

            wr_bus_id_out=> wr_bus_id(1),                        

            wr_thread_out=>wr_thread(1),

            wr_data_type_out=>wr_data_type(1),

            wr_data_model_out=>wr_data_model(1),

            wr_mcast_out=>wr_mcast(1)
            );

--------------
-- Interface to DDR read bus 
--------------

dp_source3_i0: dp_source 
        GENERIC MAP(
            BUS_ID=>dp_bus_id_ddr_c,
            NUM_DP_DST_PORT=>NUM_DP_DST_PORT,
            LATENCY=>read_latency_ddr_c,
            BUS_WIDTH=>dp_full_addr_width_c,
            FORK=>fork_ddr_c,
            INSTANCE=>0
        )
        PORT MAP(
            clock_in=>clock_in,
            reset_in=>reset_in,

            bus_addr_out=>readmaster3_addr,
            bus_cs_out=>readmaster3_cs_out,
            bus_read_out=>readmaster3_read_out,
            bus_read_vm_out=>readmaster3_read_vm_out,
            bus_read_fork_out=>open,
            bus_read_data_flow_out=>open,
            bus_read_stream_out=>open,
            bus_read_stream_id_out=>open,
            bus_read_vector_out=>readmaster3_read_vector_out,
            bus_read_scatter_out=>readmaster3_read_scatter_out,
            bus_read_start_out=>readmaster3_read_start_out,
            bus_read_end_out=>readmaster3_read_end_out,
            bus_readdatavalid_in=>readmaster3_readdatavalid_in,
            bus_readdatavalid_vm_in=>readmaster3_readdatavalid_vm_in,
            bus_readdata_in=>readmaster3_readdata_in,
            bus_wait_request_in=>readmaster3_wait_request_in,
            bus_burstlen_out=>readmaster3_burstlen_out,
            bus_id_out=>readmaster3_bus_id_out,
            bus_data_type_out=>open,
            bus_data_model_out=>open,

            gen_waitreq_out=>waitreq(2),
            gen_valid_in=>gen_ddr_src_valid,
            gen_vm_in=>gen_ddr_vm,
            gen_fork_in=>gen_ddr_fork,
            gen_data_flow_in=>gen_ddr_data_flow,
            gen_src_stream_in=>gen_ddr_src_stream,
            gen_dest_stream_in=>gen_ddr_dest_stream,
            gen_stream_id_in=>gen_ddr_stream_id,
            gen_src_vector_in=>gen_ddr_src_vector,
            gen_dst_vector_in=>gen_ddr_dst_vector,
            gen_src_scatter_in=>gen_ddr_src_scatter,
            gen_dst_scatter_in=>gen_ddr_dst_scatter,
            gen_src_start_in=>gen_ddr_src_start,
            gen_src_end_in=>gen_ddr_src_end,
            gen_dst_end_in=>gen_ddr_dst_end,
            gen_src_eof_in=>gen_ddr_src_eof,
            gen_src_addr_in=>gen_ddr_src_addr,
            gen_src_addr_mode_in=>gen_ddr_src_addr_mode,
            gen_dst_addr_in=>gen_ddr_dst_addr,
            gen_dst_addr_mode_in=>gen_ddr_dst_addr_mode,
            gen_bus_id_source_in=>gen_ddr_bus_id_source,
            gen_data_type_source_in=>gen_ddr_data_type_source,
            gen_data_model_source_in=>gen_ddr_data_model_source,
            gen_bus_id_dest_in=>gen_ddr_bus_id_dest,
            gen_data_type_dest_in=>gen_ddr_data_type_dest,
            gen_data_model_dest_in=>gen_ddr_data_model_dest,
            gen_src_burstlen_in=>gen_ddr_src_burstlen,
            gen_dst_burstlen_in=>gen_ddr_dst_burstlen,
            gen_thread_in=>gen_ddr_thread,
            gen_mcast_in=>gen_ddr_mcast,
            gen_src_data_in=>gen_ddr_data,

            wr_req_out(0)=> wr_req(2),
            wr_req_out(1)=> wr_sram_req(2),
            wr_req_out(2)=> wr_ddr_req(2),

            wr_req_pending_p0_out(0)=> wr_req_p0_pending(2),
            wr_req_pending_p0_out(1)=> wr_sram_req_p0_pending(2),
            wr_req_pending_p0_out(2)=> wr_ddr_req_p0_pending(2),

            wr_req_pending_p1_out(0)=> wr_req_p1_pending(2),
            wr_req_pending_p1_out(1)=> wr_sram_req_p1_pending(2),
            wr_req_pending_p1_out(2)=> wr_ddr_req_p1_pending(2),
                        
            wr_full_in(0) => wr_full,
            wr_full_in(1) => wr_sram_full,
            wr_full_in(2) => wr_ddr_full,

            wr_data_flow_out(0)=>wr_data_flow(2),
            wr_data_flow_out(1)=>wr_sram_data_flow(2),
            wr_data_flow_out(2)=>wr_ddr_data_flow(2),

            wr_stream_out(0)=>wr_stream(2),
            wr_stream_out(1)=>wr_sram_stream(2),
            wr_stream_out(2)=>wr_ddr_stream(2),

            wr_stream_id_out(0)=>wr_stream_id(2),
            wr_stream_id_out(1)=>wr_sram_stream_id(2),
            wr_stream_id_out(2)=>wr_ddr_stream_id(2),

            wr_vector_out(0)=>wr_vector(2),
            wr_vector_out(1)=>wr_sram_vector(2),
            wr_vector_out(2)=>wr_ddr_vector(2),
                        
            wr_scatter_out(0)=>wr_scatter(2),
            wr_scatter_out(1)=>wr_sram_scatter(2),
            wr_scatter_out(2)=>wr_ddr_scatter(2),

            wr_end_out(0)=>wr_end(2),
            wr_end_out(1)=>wr_sram_end(2),
            wr_end_out(2)=>wr_ddr_end(2),

            wr_addr_out=> wr_addr(2),

            wr_fork_out=> wr_fork(2),

            wr_addr_mode_out=>wr_addr_mode(2),

            wr_src_vm_out => wr_src_vm(2),

            wr_datavalid_out => wr_datavalid(2),

            wr_data_out=> wr_data(2),

            wr_readdatavalid_out => wr_readdatavalid(2),

            wr_readdatavalid_vm_out => wr_readdatavalid_vm(2),

            wr_readdata_out => wr_readdata(2),

            wr_burstlen_out=> wr_burstlen(2),                        

            wr_bus_id_out=> wr_bus_id(2),                        

            wr_thread_out=>wr_thread(2),

            wr_data_type_out=>wr_data_type(2),

            wr_data_model_out=>wr_data_model(2),

            wr_mcast_out=>wr_mcast(2)
            );

---------------
-- Interface to PCORE write bus
---------------


dp_sink1_i: dp_sink
        GENERIC MAP(
            NUM_DP_SRC_PORT=>NUM_DP_SRC_PORT,
            BURST_MODE=>DP_WRITEMASTER1_BURST_MODE,
            BUS_WIDTH=>dp_full_addr_width_c,
            FORK=>fork_pcore_c,
            FIFO_DEPTH=>9
            )
        PORT MAP(
            clock_in=>clock_in,
            reset_in=>reset_in,

            bus_addr_out=>writemaster1_addr,
            bus_fork_out=>writemaster1_fork_out,
            bus_addr_mode_out=>writemaster1_addr_mode_out,
            bus_vm_out=>writemaster1_vm_out,
            bus_data_flow_out=>writemaster1_write_data_flow_out,
            bus_vector_out=>writemaster1_write_vector_out,
            bus_stream_out=>writemaster1_write_stream_out,
            bus_stream_id_out=>writemaster1_write_stream_id_out,
            bus_scatter_out=>writemaster1_write_scatter_out,
            bus_end_out=>open,
            bus_mcast_out=>writemaster1_mcast_out,
            bus_cs_out=>writemaster1_cs_out,
            bus_write_out=>writemaster1_write_out,
            bus_writedata_out=>writemaster1_writedata_out,
            bus_wait_request_in=>writemaster1_wait_request_in,
            bus_burstlen_out=>writemaster1_burstlen_out,
            bus_burstlen2_out=>open,
            bus_burstlen3_out=>open,
            bus_id_out=>writemaster1_bus_id_out,
            bus_data_type_out=>writemaster1_data_type_out,
            bus_data_model_out=>writemaster1_data_model_out,
            bus_thread_out=>writemaster1_thread_out,

            wr_maxburstlen_out =>wr_maxburstlen(0),
            wr_full_out=> wr_full,
            wr_req_in=> wr_req,
            wr_req_pending_p0_in=> wr_req_p0_pending,   
            wr_req_pending_p1_in=> wr_req_p1_pending,   
            wr_data_flow_in=>wr_data_flow,
            wr_vector_in=>wr_vector,
            wr_stream_in=>wr_stream,
            wr_stream_id_in=>wr_stream_id,
            wr_scatter_in=>wr_scatter,
            wr_end_in=>wr_end,
            wr_addr_in=>wr_addr,
            wr_fork_in=>wr_fork,
            wr_addr_mode_in=>wr_addr_mode,
            wr_src_vm_in=>wr_src_vm,
            wr_datavalid_in=>wr_datavalid,
            wr_data_in=>wr_data,
            wr_readdatavalid_in => wr_readdatavalid,
            wr_readdatavalid_vm_in => wr_readdatavalid_vm,
            wr_readdata_in=>wr_readdata,
            wr_burstlen_in=>wr_burstlen,
            wr_bus_id_in=>wr_bus_id,
            wr_thread_in=>wr_thread,
            wr_data_type_in=>wr_data_type,
            wr_data_model_in=>wr_data_model,
            wr_mcast_in=>wr_mcast,

            read_pending_p0_out=>pcore_read_pending_p0,
            read_pending_p1_out=>pcore_read_pending_p1
        );

------------
-- Interface to SRAM write bus
------------

dp_sink2_i: dp_sink
        GENERIC MAP(
            NUM_DP_SRC_PORT=>NUM_DP_SRC_PORT,
            BURST_MODE=>DP_WRITEMASTER2_BURST_MODE,
            BUS_WIDTH=>dp_full_addr_width_c,
            FORK=>fork_sram_c,
            FIFO_DEPTH=>9
            ) 
        PORT MAP(
            clock_in=>clock_in,
            reset_in=>reset_in,

            bus_addr_out=>writemaster2_addr,
            bus_fork_out=>writemaster2_fork_out,
            bus_addr_mode_out=>open,
            bus_vm_out=>writemaster2_vm_out,
            bus_data_flow_out=>open,
            bus_vector_out=>writemaster2_write_vector_out,
            bus_stream_out=>open,
            bus_stream_id_out=>open,
            bus_scatter_out=>writemaster2_write_scatter_out,
            bus_end_out=>open,
            bus_mcast_out=>open,
            bus_cs_out=>writemaster2_cs_out,
            bus_write_out=>writemaster2_write_out,
            bus_writedata_out=>writemaster2_writedata_out,
            bus_wait_request_in=>writemaster2_wait_request_in,
            bus_burstlen_out=>writemaster2_burstlen_out,
            bus_burstlen2_out=>open,
            bus_burstlen3_out=>open,
            bus_id_out=>writemaster2_bus_id_out,
            bus_data_type_out=>open,
            bus_data_model_out=>open,
            bus_thread_out=>writemaster2_thread_out,

            wr_maxburstlen_out =>wr_maxburstlen(1),
            wr_full_out=> wr_sram_full,
            wr_req_in=> wr_sram_req,
            wr_req_pending_p0_in=> wr_sram_req_p0_pending,
            wr_req_pending_p1_in=> wr_sram_req_p1_pending,
            wr_data_flow_in=>wr_sram_data_flow,
            wr_vector_in=>wr_sram_vector,
            wr_stream_in=>(others=>'0'),
            wr_stream_id_in=>(others=>(others=>'0')),
            wr_scatter_in=>wr_sram_scatter,
            wr_end_in=>wr_sram_end,
            wr_addr_in=>wr_addr,
            wr_fork_in=>wr_fork,
            wr_src_vm_in=>wr_src_vm,
            wr_addr_mode_in=>wr_addr_mode,
            wr_datavalid_in=>wr_datavalid,
            wr_data_in=>wr_data,
            wr_readdatavalid_in => wr_readdatavalid,
            wr_readdatavalid_vm_in => wr_readdatavalid_vm,
            wr_readdata_in=>wr_readdata,
            wr_burstlen_in=>wr_burstlen,
            wr_bus_id_in=>wr_bus_id,
            wr_thread_in=>wr_thread,
            wr_data_type_in=>wr_data_type,
            wr_data_model_in=>wr_data_model,
            wr_mcast_in=>wr_mcast,
            read_pending_p0_out=>sram_read_pending_p0,
            read_pending_p1_out=>sram_read_pending_p1
        );

-------------
-- Interface to DDR write bus
-------------

dp_sink3_i: dp_sink
        GENERIC MAP(
            NUM_DP_SRC_PORT=>NUM_DP_SRC_PORT,
            BURST_MODE=>DP_WRITEMASTER3_BURST_MODE,
            BUS_WIDTH=>dp_full_addr_width_c,
            FORK=>fork_ddr_c,
            FIFO_DEPTH=>9
            ) 
        PORT MAP(
            clock_in=>clock_in,
            reset_in=>reset_in,

            bus_addr_out=>writemaster3_addr,
            bus_fork_out=>open,
            bus_addr_mode_out=>open,
            bus_vm_out=>writemaster3_vm_out,
            bus_data_flow_out=>open,
            bus_vector_out=>writemaster3_write_vector_out,
            bus_stream_out=>open,
            bus_stream_id_out=>open,
            bus_scatter_out=>writemaster3_write_scatter_out,
            bus_end_out=>writemaster3_write_end_out,
            bus_mcast_out=>open,
            bus_cs_out=>writemaster3_cs_out,
            bus_write_out=>writemaster3_write_out,
            bus_writedata_out=>writemaster3_writedata_out,
            bus_wait_request_in=>writemaster3_wait_request_in,
            bus_burstlen_out=>writemaster3_burstlen_out,
            bus_burstlen2_out=>writemaster3_burstlen2_out,
            bus_burstlen3_out=>writemaster3_burstlen3_out,
            bus_id_out=>writemaster3_bus_id_out,
            bus_data_type_out=>open,
            bus_data_model_out=>open,
            bus_thread_out=>writemaster3_thread_out,

            wr_maxburstlen_out =>wr_maxburstlen(2),
            wr_full_out=> wr_ddr_full,
            wr_req_in=> wr_ddr_req,
            wr_req_pending_p0_in=> wr_ddr_req_p0_pending,
            wr_req_pending_p1_in=> wr_ddr_req_p1_pending,
            wr_data_flow_in=>wr_ddr_data_flow,
            wr_vector_in=>wr_ddr_vector,
            wr_stream_in=>(others=>'0'),
            wr_stream_id_in=>(others=>(others=>'0')),
            wr_scatter_in=>wr_ddr_scatter,
            wr_end_in=>wr_ddr_end,
            wr_addr_in=>wr_addr,
            wr_fork_in=>wr_fork,
            wr_src_vm_in=>wr_src_vm,
            wr_addr_mode_in=>wr_addr_mode,
            wr_datavalid_in=>wr_datavalid,
            wr_data_in=>wr_data,
            wr_readdatavalid_in => wr_readdatavalid,
            wr_readdatavalid_vm_in => wr_readdatavalid_vm,
            wr_readdata_in=>wr_readdata,
            wr_burstlen_in=>wr_burstlen,
            wr_bus_id_in=>wr_bus_id,
            wr_thread_in=>wr_thread,
            wr_data_type_in=>wr_data_type,
            wr_data_model_in=>wr_data_model,
            wr_mcast_in=>wr_mcast,
            read_pending_p0_out=>ddr_read_pending_p0,
            read_pending_p1_out=>ddr_read_pending_p1
        );
end dp_behaviour;

