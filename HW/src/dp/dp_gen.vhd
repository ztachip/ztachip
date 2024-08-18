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

---------
-- This module implements source/destination address generation for a dp_opcode_transfer_c
-- command
-- Address is generated as nested loop interation with programmable strides
---------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY dp_gen IS
    generic (
        NUM_DP_DST_PORT     : integer;
        SOURCE_BURST_MODE   : STD_LOGIC;
        DEST_BURST_MODE     : STD_LOGIC;
        INSTANCE            : integer
    );
    port(
        SIGNAL clock_in                         : IN STD_LOGIC;
        SIGNAL reset_in                         : IN STD_LOGIC;    
                
        -- Output to other stages
        
        SIGNAL ready_out                        : OUT STD_LOGIC;

        -- Input from fetch stage
        
        SIGNAL instruction_valid_in             : IN STD_LOGIC;
        SIGNAL instruction_latch_in             : IN STD_LOGIC;
        SIGNAL instruction_source_in            : IN dp_template_t;
        SIGNAL instruction_dest_in              : IN dp_template_t;
        SIGNAL instruction_stream_process_in    : IN STD_LOGIC;
        SIGNAL instruction_stream_process_id_in : IN stream_id_t;
        SIGNAL instruction_vm_in                : IN std_logic;
        SIGNAL pre_instruction_source_in        : IN dp_template_t;
        SIGNAL pre_instruction_dest_in          : IN dp_template_t;
        SIGNAL pre_instruction_bus_id_source_in : IN dp_bus_id_t;
        SIGNAL pre_instruction_bus_id_dest_in   : IN dp_bus_id_t;
        SIGNAL instruction_source_addr_mode_in  : IN STD_LOGIC;
        SIGNAL instruction_dest_addr_mode_in    : IN STD_LOGIC;
        SIGNAL instruction_bus_id_source_in     : IN dp_bus_id_t;
        SIGNAL instruction_data_type_source_in  : IN dp_data_type_t;
        SIGNAL instruction_data_model_source_in : IN dp_data_model_t;
        SIGNAL instruction_bus_id_dest_in       : IN dp_bus_id_t;
        SIGNAL instruction_data_type_dest_in    : IN dp_data_type_t;
        SIGNAL instruction_data_model_dest_in   : IN dp_data_model_t;
        SIGNAL instruction_gen_len_in           : IN unsigned(dp_addr_width_c-1 downto 0);
        SIGNAL instruction_mcast_in             : IN mcast_t;
        SIGNAL instruction_thread_in            : IN dp_thread_t;
        SIGNAL instruction_data_in              : IN STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);
        SIGNAL instruction_repeat_in            : IN STD_LOGIC;

        -- Input for sink node

        SIGNAL wr_maxburstlen_in                : IN burstlens_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_full_in                       : IN STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);

        -- Input from next stage

        SIGNAL waitreq_in                       : IN STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);

        -- Output to next stage

        SIGNAL gen_valid_out                    : OUT STD_LOGIC_VECTOR(dp_bus_id_max_c-1 downto 0);
        SIGNAL gen_vm_out                       : OUT STD_LOGIC;
        SIGNAL gen_fork_out                     : OUT STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
        SIGNAL gen_data_flow_out                : OUT data_flow_t;
        SIGNAL gen_src_stream_out               : OUT STD_LOGIC;
        SIGNAL gen_dest_stream_out              : OUT STD_LOGIC;
        SIGNAL gen_stream_id_out                : OUT stream_id_t;
        SIGNAL gen_src_vector_out               : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
        SIGNAL gen_dst_vector_out               : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
        SIGNAL gen_src_scatter_out              : OUT scatter_t;
        SIGNAL gen_dst_scatter_out              : OUT scatter_t;
        SIGNAL gen_src_start_out                : OUT unsigned(ddr_vector_depth_c downto 0);
        SIGNAL gen_src_end_out                  : OUT vector_fork_t;
        SIGNAL gen_dst_end_out                  : OUT vector_fork_t;
        SIGNAL gen_addr_source_out              : OUT dp_full_addrs_t(fork_max_c-1 downto 0);
        SIGNAL gen_addr_source_mode_out         : OUT STD_LOGIC;
        SIGNAL gen_addr_dest_out                : OUT dp_full_addrs_t(fork_max_c-1 downto 0);
        SIGNAL gen_addr_dest_mode_out           : OUT STD_LOGIC;
        SIGNAL gen_eof_out                      : OUT STD_LOGIC;
        SIGNAL gen_bus_id_source_out            : OUT dp_bus_id_t;
        SIGNAL gen_data_type_source_out         : OUT dp_data_type_t;
        SIGNAL gen_data_model_source_out        : OUT dp_data_model_t;
        SIGNAL gen_bus_id_dest_out              : OUT dp_bus_id_t;
        SIGNAL gen_busy_dest_out                : OUT std_logic;
        SIGNAL gen_data_type_dest_out           : OUT dp_data_type_t;
        SIGNAL gen_data_model_dest_out          : OUT dp_data_model_t;
        SIGNAL gen_burstlen_source_out          : OUT burstlen_t;
        SIGNAL gen_burstlen_dest_out            : OUT burstlen_t;
        SIGNAL gen_thread_out                   : OUT dp_thread_t;
        SIGNAL gen_mcast_out                    : OUT mcast_t;
        SIGNAL gen_data_out                     : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);

        SIGNAL gen_bar_in                       : IN dp_addrs_t(dp_bus_id_max_c-1 downto 0);

        SIGNAL log_out                          : OUT STD_LOGIC_VECTOR(host_width_c-1 downto 0);
        SIGNAL log_valid_out                    : OUT STD_LOGIC
    );
END dp_gen;

ARCHITECTURE dp_gen_behaviour of dp_gen is

subtype burstpos_end_t is unsigned(dp_addr_width_c+2 downto 0);
type burstpos_ends_t is array(natural range <>) of burstpos_end_t;

SIGNAL s_template_r:dp_template_t;
SIGNAL s_i0_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i1_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i2_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i3_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i4_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i0_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i1_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i2_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i3_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i4_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_burstlen_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_burstpos_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_burstStride_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_burstRemain_r:unsigned(dp_addr_width_c-1 downto 0):=(others=>'1');
SIGNAL s_valid_r:STD_LOGIC:='1';

SIGNAL s_i0_start_r:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i1_start_r:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i2_start_r:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i3_start_r:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i4_start_r:unsigned(dp_addr_width_c+1-1 downto 0);

SIGNAL s_burstpos_stride_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_burstpos_start_r:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_burstpos_start_rr:unsigned(ddr_vector_depth_c downto 0);
SIGNAL s_burstpos_start_rrr:unsigned(ddr_vector_depth_c downto 0);
SIGNAL s_burstpos_start_rrrr:unsigned(ddr_vector_depth_c downto 0);

SIGNAL s_burstpos_end_r:burstpos_end_t;
SIGNAL s_burstpos_end_rr:vector_t;
SIGNAL s_burstpos_end_rrr:vector_t;

SIGNAL d_burstpos_end_r:burstpos_end_t;
SIGNAL d_burstpos_end_rr:vector_t;
SIGNAL d_burstpos_end_rrr:vector_t;


SIGNAL d_template_r:dp_template_t;
SIGNAL d_i0_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i1_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i2_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i3_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i4_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i0_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i1_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i2_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i3_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i4_count_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_burst_max_r:unsigned(dp_addr_width_c downto 0);
SIGNAL d_burstlen_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_burstpos_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_burstStride_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_burstRemain_r:unsigned(dp_addr_width_c-1 downto 0):=(others=>'1');
SIGNAL d_valid_r:STD_LOGIC:='1';

SIGNAL currlen_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL currlen_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL totallen_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL reload:STD_LOGIC;

SIGNAL s_burstlen_wrap:STD_LOGIC;
SIGNAL s_i0_wrap:STD_LOGIC;
SIGNAL s_i1_wrap:STD_LOGIC;
SIGNAL s_i2_wrap:STD_LOGIC;
SIGNAL s_i3_wrap:STD_LOGIC;
SIGNAL s_i4_wrap:STD_LOGIC;
SIGNAL s_burstlen_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_burstpos_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i0_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i1_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i2_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i3_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i4_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i0_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i1_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i2_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i3_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_i4_count_new:unsigned(dp_addr_width_c-1 downto 0);

SIGNAL s_burstpos_start_new:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i0_start_new:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i1_start_new:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i2_start_new:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i3_start_new:unsigned(dp_addr_width_c+1-1 downto 0);
SIGNAL s_i4_start_new:unsigned(dp_addr_width_c+1-1 downto 0);

SIGNAL d_burstlen_wrap:STD_LOGIC;
SIGNAL d_i0_wrap:STD_LOGIC;
SIGNAL d_i1_wrap:STD_LOGIC;
SIGNAL d_i2_wrap:STD_LOGIC;
SIGNAL d_i3_wrap:STD_LOGIC;
SIGNAL d_i4_wrap:STD_LOGIC;
SIGNAL d_burstlen_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_burstpos_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i0_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i1_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i2_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i3_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i4_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i0_new2:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i1_new2:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i2_new2:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i3_new2:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i4_new2:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i0_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i1_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i2_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i3_count_new:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_i4_count_new:unsigned(dp_addr_width_c-1 downto 0);

SIGNAL running_r:STD_LOGIC;
SIGNAL running_rr:STD_LOGIC;
SIGNAL running_rrr:STD_LOGIC;
SIGNAL running_rrrr:STD_LOGIC;
SIGNAL gen_valid_r:STD_LOGIC_VECTOR(dp_bus_id_max_c-1 downto 0);
SIGNAL dp_dst_bus_id_r:dp_bus_id_t;
SIGNAL dp_dst_bus_id_rr:dp_bus_id_t;
SIGNAL dp_dst_bus_id_rrr:dp_bus_id_t;
SIGNAL dp_dst_bus_id_rrrr:dp_bus_id_t;
SIGNAL dp_src_bus_id_r:dp_bus_id_t;
SIGNAL dp_src_bus_id_rr:dp_bus_id_t;
SIGNAL dp_src_bus_id_rrr:dp_bus_id_t;
SIGNAL dp_src_bus_id_rrrr:dp_bus_id_t;
SIGNAL dp_dst_data_type_r:dp_data_type_t;
SIGNAL dp_dst_data_type_rr:dp_data_type_t;
SIGNAL dp_dst_data_type_rrr:dp_data_type_t;
SIGNAL dp_dst_data_type_rrrr:dp_data_type_t;
SIGNAL dp_src_data_type_r:dp_data_type_t;
SIGNAL dp_src_data_type_rr:dp_data_type_t;
SIGNAL dp_src_data_type_rrr:dp_data_type_t;
SIGNAL dp_src_data_type_rrrr:dp_data_type_t;
SIGNAL dp_src_data_model_r:dp_data_model_t;
SIGNAL dp_src_data_model_rr:dp_data_model_t;
SIGNAL dp_src_data_model_rrr:dp_data_model_t;
SIGNAL dp_src_data_model_rrrr:dp_data_model_t;
SIGNAL dp_dst_data_model_r:dp_data_model_t;
SIGNAL dp_dst_data_model_rr:dp_data_model_t;
SIGNAL dp_dst_data_model_rrr:dp_data_model_t;
SIGNAL dp_dst_data_model_rrrr:dp_data_model_t;
SIGNAL dp_thread_r:dp_thread_t;
SIGNAL dp_thread_rr:dp_thread_t;
SIGNAL dp_thread_rrr:dp_thread_t;
SIGNAL dp_thread_rrrr:dp_thread_t;
SIGNAL dp_mcast_r:mcast_t:=(others=>'1');
SIGNAL dp_mcast_rr:mcast_t:=(others=>'1');
SIGNAL dp_mcast_rrr:mcast_t:=(others=>'1');
SIGNAL dp_mcast_rrrr:mcast_t:=(others=>'1');
SIGNAL data_r:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL data_rr:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL data_rrr:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL data_rrrr:std_logic_vector(ddr_data_width_c-1 downto 0);

SIGNAL s_bufsize_r:dp_addr_t;
SIGNAL s_bufsize_rr:dp_addr_t;
SIGNAL s_temp1_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_temp2_r:dp_full_addr_t;
SIGNAL s_temp3_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_temp4_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_temp5_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL s_temp4_rr:dp_full_addr_t;
SIGNAL s_gen_addr_r:dp_full_addr_t;
SIGNAL s_gen_burstlen_r:burstlen_t;
SIGNAL s_gen_burstlen_rr:burstlen_t;
SIGNAL s_gen_burstlen_progress_r:std_logic;

SIGNAL s_i0_valid:STD_LOGIC;
SIGNAL s_i1_valid:STD_LOGIC;
SIGNAL s_i2_valid:STD_LOGIC;
SIGNAL s_i3_valid:STD_LOGIC;
SIGNAL s_i4_valid:STD_LOGIC;
SIGNAL s_burst_valid:STD_LOGIC;

SIGNAL s_i0_start_valid:STD_LOGIC;
SIGNAL s_i1_start_valid:STD_LOGIC;
SIGNAL s_i2_start_valid:STD_LOGIC;
SIGNAL s_i3_start_valid:STD_LOGIC;
SIGNAL s_i4_start_valid:STD_LOGIC;
SIGNAL s_burst_start_valid:STD_LOGIC;

SIGNAL d_bufsize_r:dp_addr_t;
SIGNAL d_bufsize_rr:dp_addr_t;
SIGNAL d_temp1_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_temp2_r:unsigned(dp_full_addr_width_c-1 downto 0);
SIGNAL d_temp3_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_temp4_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_temp5_r:unsigned(dp_addr_width_c-1 downto 0);
SIGNAL d_temp4_rr:dp_full_addr_t;
SIGNAL d_gen_addr_r:dp_full_addr_t;
SIGNAL d_gen_burstlen_r:burstlen_t;
SIGNAL d_gen_burstlen_rr:burstlen_t;

SIGNAL d_i0_valid:STD_LOGIC;
SIGNAL d_i1_valid:STD_LOGIC;
SIGNAL d_i2_valid:STD_LOGIC;
SIGNAL d_i3_valid:STD_LOGIC;
SIGNAL d_i4_valid:STD_LOGIC;
SIGNAL d_burst_valid:STD_LOGIC;

SIGNAL eof_r:STD_LOGIC;
SIGNAL eof_rr:STD_LOGIC;
SIGNAL eof_rrr:STD_LOGIC;
SIGNAL eof_rrrr:STD_LOGIC;
SIGNAL done_r:STD_LOGIC:='1';

SIGNAL repeat_r:STD_LOGIC;

SIGNAL data_flow_r:data_flow_t;
SIGNAL data_flow_rr:data_flow_t;
SIGNAL data_flow_rrr:data_flow_t;
SIGNAL data_flow_rrrr:data_flow_t;

SIGNAL stream_src_r:STD_LOGIC;
SIGNAL stream_src_rr:STD_LOGIC;
SIGNAL stream_src_rrr:STD_LOGIC;
SIGNAL stream_src_rrrr:STD_LOGIC;

SIGNAL stream_dest_r:STD_LOGIC;
SIGNAL stream_dest_rr:STD_LOGIC;
SIGNAL stream_dest_rrr:STD_LOGIC;
SIGNAL stream_dest_rrrr:STD_LOGIC;

SIGNAL vm_r:STD_LOGIC;
SIGNAL vm_rr:STD_LOGIC;
SIGNAL vm_rrr:STD_LOGIC;
SIGNAL vm_rrrr:STD_LOGIC;

SIGNAL stream_id_r:stream_id_t;
SIGNAL stream_id_rr:stream_id_t;
SIGNAL stream_id_rrr:stream_id_t;
SIGNAL stream_id_rrrr:stream_id_t;

SIGNAL src_double_r:STD_LOGIC;
SIGNAL src_double_rr:STD_LOGIC;
SIGNAL src_double_rrr:STD_LOGIC;
SIGNAL src_double_rrrr:STD_LOGIC;

SIGNAL dst_double_r:STD_LOGIC;
SIGNAL dst_double_rr:STD_LOGIC;
SIGNAL dst_double_rrr:STD_LOGIC;
SIGNAL dst_double_rrrr:STD_LOGIC;

SIGNAL src_vector_r:dp_vector_t;
SIGNAL src_vector_rr:dp_vector_t;
SIGNAL src_vector_rrr:dp_vector_t;
SIGNAL src_vector_rrrr:dp_vector_t;

SIGNAL dst_vector_r:dp_vector_t;
SIGNAL dst_vector_rr:dp_vector_t;
SIGNAL dst_vector_rrr:dp_vector_t;
SIGNAL dst_vector_rrrr:dp_vector_t;

SIGNAL src_addr_mode_r:STD_LOGIC;
SIGNAL src_addr_mode_rr:STD_LOGIC;
SIGNAL src_addr_mode_rrr:STD_LOGIC;
SIGNAL src_addr_mode_rrrr:STD_LOGIC;

SIGNAL dst_addr_mode_r:STD_LOGIC;
SIGNAL dst_addr_mode_rr:STD_LOGIC;
SIGNAL dst_addr_mode_rrr:STD_LOGIC;
SIGNAL dst_addr_mode_rrrr:STD_LOGIC;

SIGNAL src_scatter_r:scatter_t;
SIGNAL src_scatter_rr:scatter_t;
SIGNAL src_scatter_rrr:scatter_t;
SIGNAL src_scatter_rrrr:scatter_t;

SIGNAL dst_scatter_r:scatter_t;
SIGNAL dst_scatter_rr:scatter_t;
SIGNAL dst_scatter_rrr:scatter_t;
SIGNAL dst_scatter_rrrr:scatter_t;

SIGNAL src_vector:dp_vector_t;
SIGNAL dst_vector:dp_vector_t;
SIGNAL src_scatter:scatter_t;
SIGNAL dst_scatter:scatter_t;

SIGNAL src_is_burst_r:STD_LOGIC;
SIGNAL src_is_burst_rr:STD_LOGIC;
SIGNAL dst_is_burst_r:STD_LOGIC;
SIGNAL dst_is_burst_rr:STD_LOGIC;

SIGNAL is_vector:STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
SIGNAL src_is_vector_r:STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
SIGNAL dst_is_vector_r:STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
SIGNAL src_is_scatter_r:scatters_t(ddr_vector_depth_c-1 downto 0);
SIGNAL dst_is_scatter_r:scatters_t(ddr_vector_depth_c-1 downto 0);

SIGNAL s_burst_actual_max_r:unsigned(dp_addr_width_c downto 0);

SIGNAL log:STD_LOGIC_VECTOR(host_width_c-1 downto 0);
SIGNAL log_r:STD_LOGIC_VECTOR(host_width_c-1 downto 0);
SIGNAL log_valid_r:STD_LOGIC;

SIGNAL source_double_precision:STD_LOGIC;
SIGNAL dest_double_precision:STD_LOGIC;

SIGNAL waitreq:STD_LOGIC;

SIGNAL ready:STD_LOGIC;

constant all_ones2_c:unsigned(vector_depth_c-1 downto 0):=(others=>'1');
constant all_ones_c:unsigned(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_zeros_c:unsigned(ddr_vector_depth_c-1 downto 0):=(others=>'0');
constant all_zeros2_c:unsigned(dp_addr_width_c-1 downto 0):=(others=>'0');
constant depth_c:integer:=bus_width_c;

constant len_zero_v:unsigned(dp_addr_width_c-1 downto 0):=(others=>'0');
SIGNAL debug_source_bar:std_logic_vector(31 downto 0);
SIGNAL debug_dest_bar:std_logic_vector(31 downto 0);

SIGNAL gen_busy_dest_r:std_logic;
BEGIN

gen_src_scatter_out <= src_scatter_rrrr;
gen_dst_scatter_out <= dst_scatter_rrrr;
gen_data_flow_out <= data_flow_rrrr;
gen_src_stream_out <= stream_src_rrrr;
gen_dest_stream_out <= stream_dest_rrrr;
gen_stream_id_out <= stream_id_rrrr;
gen_vm_out <= vm_rrrr;

source_double_precision <= instruction_source_in.double_precision when instruction_bus_id_source_in/=dp_bus_id_register_c else '0';
dest_double_precision <= instruction_dest_in.double_precision when instruction_bus_id_dest_in/=dp_bus_id_register_c else '0';

ready_out <= ready;
ready <= '1' when (running_r='0' and running_rr='0' and running_rrr='0' and running_rrrr='0') and (reload='1') 
                      else '0';

reload <= '1' when (running_r='0' or done_r='1') else '0';


currlen_new <= currlen_r-1;

gen_src_vector_out <= std_logic_vector(src_vector_rrrr);
gen_addr_source_out(0) <= s_gen_addr_r;
gen_dst_vector_out <= std_logic_vector(dst_vector_rrrr);
gen_addr_dest_out(0) <= d_gen_addr_r;

gen_addr_source_mode_out <= src_addr_mode_rrrr;
gen_addr_dest_mode_out <= dst_addr_mode_rrrr;

gen_src_start_out <= s_burstpos_start_rrrr;
gen_src_end_out(0) <= s_burstpos_end_rrr;

gen_dst_end_out(0) <= d_burstpos_end_rrr;

-- Create log entry

log_out <= log_r;

log_valid_out <= log_valid_r;

---
-- Generate log entry
----

process(instruction_bus_id_source_in,src_vector,src_scatter,source_double_precision,
        instruction_bus_id_dest_in,dst_vector,dst_scatter,dest_double_precision)
variable pos_v:integer;
begin
   pos_v := 0;

   log(pos_v+log_type_t'length-1 downto pos_v) <= log_type_dp_begin_c;
   pos_v := pos_v+log_type_t'length;

   log(pos_v+instruction_bus_id_source_in'length-1 downto pos_v) <= std_logic_vector(instruction_bus_id_source_in);
   pos_v := pos_v+instruction_bus_id_source_in'length;

   log(pos_v+src_vector'length-1 downto pos_v) <= std_logic_vector(src_vector);
   pos_v := pos_v+src_vector'length;

   log(pos_v+src_scatter'length-1 downto pos_v) <= std_logic_vector(src_scatter);
   pos_v := pos_v+src_scatter'length;

   log(pos_v) <= source_double_precision;
   pos_v := pos_v+1;

   log(pos_v+instruction_bus_id_dest_in'length-1 downto pos_v) <= std_logic_vector(instruction_bus_id_dest_in);
   pos_v := pos_v+instruction_bus_id_dest_in'length;

   log(pos_v+dst_vector'length-1 downto pos_v) <= std_logic_vector(dst_vector);
   pos_v := pos_v+dst_vector'length;

   log(pos_v+dst_scatter'length-1 downto pos_v) <= std_logic_vector(dst_scatter);
   pos_v := pos_v+dst_scatter'length;

   log(pos_v) <= dest_double_precision;
   pos_v := pos_v+1;

   log(host_width_c-1 downto pos_v) <= (others=>'0');
end process;

-------
-- Check which transfer width and scatter mode is possible
-------

process(clock_in,reset_in)
variable depth_v:integer;
begin

if reset_in='0' then
   src_is_scatter_r <= (others=>(others=>'0'));
   dst_is_scatter_r <= (others=>(others=>'0'));
   src_is_vector_r <= (others=>'0');
   dst_is_vector_r <= (others=>'0');
else
if clock_in'event and clock_in='1' then
   for I in 0 to ddr_vector_depth_c-1 loop
      depth_v := ddr_vector_depth_c-I;

      if (pre_instruction_source_in.count(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v)) and 
         (pre_instruction_bus_id_source_in=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length)) and
         (pre_instruction_source_in.scatter='1') then
         if pre_instruction_source_in.burstStride=to_unsigned(vector_width_c,dp_addr_width_c) then
            src_is_scatter_r(I) <= scatter_vector_c;
         elsif pre_instruction_source_in.burstStride=to_unsigned(register_size_c,dp_addr_width_c) then
            src_is_scatter_r(I) <= scatter_thread_c;
         else
            src_is_scatter_r(I) <= scatter_none_c;
         end if;
      else
         src_is_scatter_r(I) <= scatter_none_c;
      end if;

      if (pre_instruction_dest_in.count(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v)) and 
         (pre_instruction_bus_id_dest_in=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length)) and
         (pre_instruction_dest_in.scatter='1') then
         if pre_instruction_dest_in.burstStride=to_unsigned(vector_width_c,dp_addr_width_c) then
            dst_is_scatter_r(I) <= scatter_vector_c;
         elsif pre_instruction_dest_in.burstStride=to_unsigned(register_size_c,dp_addr_width_c) then
            dst_is_scatter_r(I) <= scatter_thread_c;
         else
            dst_is_scatter_r(I) <= scatter_none_c;
         end if;
      else
         dst_is_scatter_r(I) <= scatter_none_c;
      end if;

      if pre_instruction_bus_id_source_in=to_unsigned(dp_bus_id_ddr_c,dp_bus_id_t'length) then
         if pre_instruction_source_in.burstStride=to_unsigned(0,pre_instruction_source_in.burstStride'length) or
           (pre_instruction_source_in.burstStride=to_unsigned(1,pre_instruction_source_in.burstStride'length) and
            pre_instruction_source_in.count(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v)) then
            src_is_vector_r(I) <= '1';
         else
            src_is_vector_r(I) <= '0';
         end if;
      elsif pre_instruction_source_in.burstStride=to_unsigned(0,pre_instruction_source_in.burstStride'length) or
           (pre_instruction_source_in.stride0(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
            pre_instruction_source_in.stride1(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
            pre_instruction_source_in.stride2(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
            pre_instruction_source_in.stride3(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
            pre_instruction_source_in.stride4(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
            pre_instruction_source_in.burstStride=to_unsigned(1,pre_instruction_source_in.burstStride'length) and
            pre_instruction_source_in.count(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v) and 
            pre_instruction_source_in.burst_max(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v) and
            pre_instruction_source_in.bar(depth_v-1 downto 0)=to_unsigned(0,depth_v)
       ) then
          src_is_vector_r(I) <= '1';
       else
          src_is_vector_r(I) <= '0';
       end if;

       if pre_instruction_bus_id_dest_in=to_unsigned(dp_bus_id_ddr_c,dp_bus_id_t'length) then
          if pre_instruction_dest_in.burstStride=to_unsigned(0,pre_instruction_dest_in.burstStride'length) or
            (pre_instruction_dest_in.burstStride=to_unsigned(1,pre_instruction_dest_in.burstStride'length) and
             pre_instruction_dest_in.count(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v)) then
          dst_is_vector_r(I) <= '1';
       else
          dst_is_vector_r(I) <= '0';
       end if;
    elsif pre_instruction_dest_in.burstStride=to_unsigned(0,pre_instruction_dest_in.burstStride'length) or
         (pre_instruction_dest_in.stride0(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
          pre_instruction_dest_in.stride1(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
          pre_instruction_dest_in.stride2(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
          pre_instruction_dest_in.stride3(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
          pre_instruction_dest_in.stride4(depth_v-1 downto 0)=to_unsigned(0,depth_v) and 
          pre_instruction_dest_in.burstStride=to_unsigned(1,pre_instruction_dest_in.burstStride'length) and
          pre_instruction_dest_in.count(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v) and 
          pre_instruction_dest_in.burst_max(depth_v-1 downto 0)=to_unsigned(2**depth_v-1,depth_v) and 
          pre_instruction_dest_in.bar(depth_v-1 downto 0)=to_unsigned(0,depth_v)) then
       dst_is_vector_r(I) <= '1';
   else
       dst_is_vector_r(I) <= '0';
   end if;
end loop;
end if;
end if;
end process;

----
-- Determine transfer width and scatter mode
----

process(src_is_vector_r,src_is_scatter_r,dst_is_vector_r,dst_is_scatter_r,instruction_source_in,instruction_dest_in,
        instruction_bus_id_source_in,instruction_bus_id_dest_in)
begin
if ((src_is_vector_r(0)='1' or src_is_scatter_r(0)/=scatter_none_c) and instruction_source_in.double_precision='0') and 
   ((dst_is_vector_r(0)='1' or dst_is_scatter_r(0)/=scatter_none_c) and instruction_dest_in.double_precision='0') then
   src_vector <= std_logic_vector(to_unsigned(ddr_vector_width_c-1,src_vector'length));
   dst_vector <= std_logic_vector(to_unsigned(ddr_vector_width_c-1,src_vector'length));
   src_scatter <= src_is_scatter_r(0);
   dst_scatter <= dst_is_scatter_r(0);
elsif (src_is_vector_r(1)='1' or src_is_scatter_r(1)/=scatter_none_c) and 
      (dst_is_vector_r(1)='1' or dst_is_scatter_r(1)/=scatter_none_c) then
   src_vector <= std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,src_vector'length));
   dst_vector <= std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,src_vector'length));
   src_scatter <= src_is_scatter_r(1);
   dst_scatter <= dst_is_scatter_r(1);
elsif (src_is_vector_r(2)='1' or src_is_scatter_r(2)/=scatter_none_c) and 
      (dst_is_vector_r(2)='1' or dst_is_scatter_r(2)/=scatter_none_c) then
   src_vector <= std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,src_vector'length));
   dst_vector <= std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,src_vector'length));
   src_scatter <= src_is_scatter_r(2);
   dst_scatter <= dst_is_scatter_r(2);
else
   src_vector <= std_logic_vector(to_unsigned(0,src_vector'length));
   dst_vector <= std_logic_vector(to_unsigned(0,src_vector'length));
   src_scatter <= scatter_none_c;
   dst_scatter <= scatter_none_c;
end if;
end process;


-------
-- Calculate next addess
-------

s_burstlen_new <= s_burstlen_r+1;
s_burstpos_new <= s_burstpos_r+s_template_r.burstStride(dp_addr_width_c-1 downto 0);
s_i0_new <= s_i0_r+s_template_r.stride0(dp_addr_width_c-1 downto 0);
s_i1_new <= s_i1_r+s_template_r.stride1(dp_addr_width_c-1 downto 0);
s_i2_new <= s_i2_r+s_template_r.stride2(dp_addr_width_c-1 downto 0);
s_i3_new <= s_i3_r+s_template_r.stride3(dp_addr_width_c-1 downto 0);
s_i4_new <= s_i4_r+s_template_r.stride4(dp_addr_width_c-1 downto 0);

s_burstpos_start_new <= s_burstpos_start_r+unsigned('0' & std_logic_vector(s_burstpos_stride_r(dp_addr_width_c-1 downto 0)));
s_i0_start_new <= s_i0_start_r+unsigned('0' & std_logic_vector(s_template_r.stride0(dp_addr_width_c-1 downto 0)));
s_i1_start_new <= s_i1_start_r+unsigned('0' & std_logic_vector(s_template_r.stride1(dp_addr_width_c-1 downto 0)));
s_i2_start_new <= s_i2_start_r+unsigned('0' & std_logic_vector(s_template_r.stride2(dp_addr_width_c-1 downto 0)));
s_i3_start_new <= s_i3_start_r+unsigned('0' & std_logic_vector(s_template_r.stride3(dp_addr_width_c-1 downto 0)));
s_i4_start_new <= s_i4_start_r+unsigned('0' & std_logic_vector(s_template_r.stride4(dp_addr_width_c-1 downto 0)));

s_i0_count_new <= s_i0_count_r+1;
s_i1_count_new <= s_i1_count_r+1;
s_i2_count_new <= s_i2_count_r+1;
s_i3_count_new <= s_i3_count_r+1;
s_i4_count_new <= s_i4_count_r+1;

d_burstlen_new <= d_burstlen_r+1;
d_burstpos_new <= d_burstpos_r+d_template_r.burstStride;
d_i0_new <= d_i0_r+d_template_r.stride0;
d_i1_new <= d_i1_r+d_template_r.stride1;
d_i2_new <= d_i2_r+d_template_r.stride2;
d_i3_new <= d_i3_r+d_template_r.stride3;
d_i4_new <= d_i4_r+d_template_r.stride4;

d_i0_new2 <= d_i0_r+ unsigned(std_logic_vector(d_template_r.stride0(dp_addr_width_c-2 downto 0))&'0');
d_i1_new2 <= d_i1_r+ unsigned(std_logic_vector(d_template_r.stride1(dp_addr_width_c-2 downto 0))&'0');
d_i2_new2 <= d_i2_r+ unsigned(std_logic_vector(d_template_r.stride2(dp_addr_width_c-2 downto 0))&'0');
d_i3_new2 <= d_i3_r+ unsigned(std_logic_vector(d_template_r.stride3(dp_addr_width_c-2 downto 0))&'0');
d_i4_new2 <= d_i4_r+ unsigned(std_logic_vector(d_template_r.stride4(dp_addr_width_c-2 downto 0))&'0');

d_i0_count_new <= d_i0_count_r+1;
d_i1_count_new <= d_i1_count_r+1;
d_i2_count_new <= d_i2_count_r+1;
d_i3_count_new <= d_i3_count_r+1;
d_i4_count_new <= d_i4_count_r+1;

--------
-- Output
---------
 
gen_valid_out <= gen_valid_r;
gen_fork_out <= (others=>'0');
gen_bus_id_dest_out <= dp_dst_bus_id_rrrr;
gen_busy_dest_out <= gen_busy_dest_r;
gen_data_type_dest_out <= dp_dst_data_type_rrrr;
gen_data_model_dest_out <= dp_dst_data_model_rrrr;
gen_bus_id_source_out <= dp_src_bus_id_rrrr;
gen_data_type_source_out <= dp_src_data_type_rrrr;
gen_data_model_source_out <= dp_src_data_model_rrrr;
gen_eof_out <= '1' when (eof_rrrr='1' or s_gen_burstlen_progress_r='0') else '0';
gen_burstlen_source_out <= s_gen_burstlen_rr;
gen_burstlen_dest_out <= d_gen_burstlen_rr;
gen_thread_out <= dp_thread_rrrr;
gen_mcast_out <= dp_mcast_rrrr;
gen_data_out <= data_rrrr;

waitreq <= '1' when (waitreq_in and gen_valid_r)/=std_logic_vector(to_unsigned(0,NUM_DP_DST_PORT)) else '0';

------
-- Iteration loop wrap around check
------

s_burstlen_wrap <= '1' when (unsigned(s_burstlen_r) = unsigned(s_template_r.count(dp_addr_width_c-1 downto 0))) else '0';
s_i0_wrap <= '1' when (unsigned(s_i0_count_r) = unsigned(s_template_r.stride0_count(dp_addr_width_c-1 downto 0))) else '0';
s_i1_wrap <= '1' when (unsigned(s_i1_count_r) = unsigned(s_template_r.stride1_count(dp_addr_width_c-1 downto 0))) else '0';
s_i2_wrap <= '1' when (unsigned(s_i2_count_r) = unsigned(s_template_r.stride2_count(dp_addr_width_c-1 downto 0))) else '0';
s_i3_wrap <= '1' when (unsigned(s_i3_count_r) = unsigned(s_template_r.stride3_count(dp_addr_width_c-1 downto 0))) else '0';
s_i4_wrap <= '1' when (unsigned(s_i4_count_r) = unsigned(s_template_r.stride4_count(dp_addr_width_c-1 downto 0))) else '0';

s_i0_valid <= '1' when (unsigned(s_i0_r) <= unsigned(s_template_r.stride0_max(dp_addr_width_c-1 downto 0)) and s_template_r.stride0_max(dp_addr_width_c)='0') else '0';
s_i1_valid <= '1' when (unsigned(s_i1_r) <= unsigned(s_template_r.stride1_max(dp_addr_width_c-1 downto 0)) and s_template_r.stride1_max(dp_addr_width_c)='0') else '0';
s_i2_valid <= '1' when (unsigned(s_i2_r) <= unsigned(s_template_r.stride2_max(dp_addr_width_c-1 downto 0)) and s_template_r.stride2_max(dp_addr_width_c)='0') else '0';
s_i3_valid <= '1' when (unsigned(s_i3_r) <= unsigned(s_template_r.stride3_max(dp_addr_width_c-1 downto 0)) and s_template_r.stride3_max(dp_addr_width_c)='0') else '0';
s_i4_valid <= '1' when (unsigned(s_i4_r) <= unsigned(s_template_r.stride4_max(dp_addr_width_c-1 downto 0)) and s_template_r.stride4_max(dp_addr_width_c)='0') else '0';
s_burst_valid <= '1' when (unsigned(s_burstpos_r) <= unsigned(s_template_r.burst_max(dp_addr_width_c-1 downto 0)) and s_template_r.burst_max(dp_addr_width_c)='0') else '0';

s_i0_start_valid <= not s_i0_start_r(dp_addr_width_c+1-1);
s_i1_start_valid <= not s_i1_start_r(dp_addr_width_c+1-1);
s_i2_start_valid <= not s_i2_start_r(dp_addr_width_c+1-1);
s_i3_start_valid <= not s_i3_start_r(dp_addr_width_c+1-1);
s_i4_start_valid <= not s_i4_start_r(dp_addr_width_c+1-1);
s_burst_start_valid <= '1' when ((signed(s_burstpos_start_r)+signed(s_burstpos_stride_r)) >= 1) else '0';

d_burstlen_wrap <= '1' when (unsigned(d_burstlen_r) = unsigned(d_template_r.count)) else '0';
d_i0_wrap <= '1' when (unsigned(d_i0_count_r) = unsigned(d_template_r.stride0_count)) else '0';
d_i1_wrap <= '1' when (unsigned(d_i1_count_r) = unsigned(d_template_r.stride1_count)) else '0';
d_i2_wrap <= '1' when (unsigned(d_i2_count_r) = unsigned(d_template_r.stride2_count)) else '0';
d_i3_wrap <= '1' when (unsigned(d_i3_count_r) = unsigned(d_template_r.stride3_count)) else '0';
d_i4_wrap <= '1' when (unsigned(d_i4_count_r) = unsigned(d_template_r.stride4_count)) else '0';

d_i0_valid <= '1' when (unsigned(d_i0_r) <= unsigned(d_template_r.stride0_max(dp_addr_width_c-1 downto 0)) and d_template_r.stride0_max(dp_addr_width_c)='0') else '0';
d_i1_valid <= '1' when (unsigned(d_i1_r) <= unsigned(d_template_r.stride1_max(dp_addr_width_c-1 downto 0)) and d_template_r.stride1_max(dp_addr_width_c)='0') else '0';
d_i2_valid <= '1' when (unsigned(d_i2_r) <= unsigned(d_template_r.stride2_max(dp_addr_width_c-1 downto 0)) and d_template_r.stride2_max(dp_addr_width_c)='0') else '0';
d_i3_valid <= '1' when (unsigned(d_i3_r) <= unsigned(d_template_r.stride3_max(dp_addr_width_c-1 downto 0)) and d_template_r.stride3_max(dp_addr_width_c)='0') else '0';
d_i4_valid <= '1' when (unsigned(d_i4_r) <= unsigned(d_template_r.stride4_max(dp_addr_width_c-1 downto 0)) and d_template_r.stride4_max(dp_addr_width_c)='0') else '0';
d_burst_valid <= '1' when (unsigned(d_burstpos_r) <= unsigned(d_burst_max_r(dp_addr_width_c-1 downto 0)) and d_burst_max_r(dp_addr_width_c)='0') else '0';

------
-- Perform address calculation
-- Since there are several iteration stages to be added together, addresses after computed in stages
-- for better fmax performance
-----

process(reset_in,clock_in)
variable s_burstlen_v:burstlen_t;
variable d_burstlen_v:burstlen_t;
variable burstRemain_v:unsigned(dp_addr_width_c-1 downto 0);
variable addr_v:unsigned(dp_full_addr_width_c-1 downto 0);
variable s_end_v:burstpos_end_t;
variable d_end_v:burstpos_end_t;
variable remain_v:signed(dp_addr_width_c downto 0);
variable burstpos_v:burstpos_end_t;
begin
    if reset_in='0' then
        dp_dst_bus_id_rr <= (others=>'0');
        dp_dst_bus_id_rrr <= (others=>'0');
        dp_dst_bus_id_rrrr <= (others=>'0');
        dp_src_bus_id_rr <= (others=>'0');
        dp_src_bus_id_rrr <= (others=>'0');
        dp_src_bus_id_rrrr <= (others=>'0');
        dp_dst_data_type_rr <= (others=>'0');
        dp_dst_data_type_rrr <= (others=>'0');
        dp_dst_data_type_rrrr <= (others=>'0');
        dp_dst_data_model_rr <= (others=>'0');
        dp_dst_data_model_rrr <= (others=>'0');
        dp_dst_data_model_rrrr <= (others=>'0');
        dp_src_data_type_rr <= (others=>'0');
        dp_src_data_type_rrr <= (others=>'0');
        dp_src_data_type_rrrr <= (others=>'0');
        dp_src_data_model_rr <= (others=>'0');
        dp_src_data_model_rrr <= (others=>'0');
        dp_src_data_model_rrrr <= (others=>'0');
        dp_thread_rr <= (others=>'0');
        dp_thread_rrr <= (others=>'0');
        dp_thread_rrrr <= (others=>'0');
        dp_mcast_rr <= (others=>'1');
        dp_mcast_rrr <= (others=>'1');
        dp_mcast_rrrr <= (others=>'1');
        running_rr <= '0';
        running_rrr <= '0';
        running_rrrr <= '0';
        gen_valid_r <= (others=>'0');
        data_rr <= (others=>'0');
        data_rrr <= (others=>'0');
        data_rrrr <= (others=>'0');

        s_bufsize_r <= (others=>'0');
        s_bufsize_rr <= (others=>'0');
        s_temp1_r <= (others=>'0');
        s_temp2_r <= (others=>'0');
        s_temp3_r <= (others=>'0');
        s_temp4_r <= (others=>'0');
        s_temp4_rr <= (others=>'0');
        s_temp5_r <= (others=>'0');
        s_gen_addr_r <= (others=>'0');
        s_gen_burstlen_r <= (others=>'0');
        s_gen_burstlen_rr <= (others=>'0');
        s_gen_burstlen_progress_r <= '0';

        d_bufsize_r <= (others=>'0');
        d_bufsize_rr <= (others=>'0');
        d_temp1_r <= (others=>'0');
        d_temp2_r <= (others=>'0');
        d_temp3_r <= (others=>'0');
        d_temp4_r <= (others=>'0');
        d_temp4_rr <= (others=>'0');
        d_temp5_r <= (others=>'0');
        d_gen_addr_r <= (others=>'0');
        d_gen_burstlen_r <= (others=>'0');
        d_gen_burstlen_rr <= (others=>'0');

        eof_rr <= '0';
        eof_rrr <= '0';
        eof_rrrr <= '0';

        src_vector_rr <= (others=>'0');
        src_vector_rrr <= (others=>'0');
        src_vector_rrrr <= (others=>'0');

        s_burstpos_start_rr <= (others=>'0');
        s_burstpos_start_rrr <= (others=>'0');
        s_burstpos_start_rrrr <= (others=>'0');

        src_addr_mode_rr <= '0';
        src_addr_mode_rrr <= '0';
        src_addr_mode_rrrr <= '0';

        data_flow_rr <= (others=>'0');
        data_flow_rrr <= (others=>'0');
        data_flow_rrrr <= (others=>'0');

        stream_src_rr <= '0';
        stream_src_rrr <= '0';
        stream_src_rrrr <= '0';

        stream_dest_rr <= '0';
        stream_dest_rrr <= '0';
        stream_dest_rrrr <= '0';

        stream_id_rr <= (others=>'0');
        stream_id_rrr <= (others=>'0');
        stream_id_rrrr <= (others=>'0');

        vm_rr <= '0';
        vm_rrr <= '0';
        vm_rrrr <= '0';

        src_double_rr <= '0';
        src_double_rrr <= '0';
        src_double_rrrr <= '0';

        dst_double_rr <= '0';
        dst_double_rrr <= '0';
        dst_double_rrrr <= '0';

        dst_vector_rr <= (others=>'0');
        dst_vector_rrr <= (others=>'0');
        dst_vector_rrrr <= (others=>'0');

        dst_addr_mode_rr <= '0';
        dst_addr_mode_rrr <= '0';
        dst_addr_mode_rrrr <= '0';

        src_scatter_rr <= (others=>'0');
        src_scatter_rrr <= (others=>'0');
        src_scatter_rrrr <= (others=>'0');

        dst_scatter_rr <= (others=>'0');
        dst_scatter_rrr <= (others=>'0');
        dst_scatter_rrrr <= (others=>'0');

        d_burstStride_r <= (others=>'0');
        d_burstRemain_r <= (others=>'1');
        d_valid_r <= '1';
        s_burstStride_r <= (others=>'0');
        s_burstRemain_r <= (others=>'1');
        s_valid_r <= '1';

        src_is_burst_rr <= '0';
        dst_is_burst_rr <= '0';

        s_burstpos_end_r <= (others=>'0');
        s_burstpos_end_rr <= (others=>'0');
        s_burstpos_end_rrr <= (others=>'0');

        d_burstpos_end_r <= (others=>'0');
        d_burstpos_end_rr <= (others=>'0');
        d_burstpos_end_rrr <= (others=>'0');

        gen_busy_dest_r <= '0';
    else
        if clock_in'event and clock_in='1' then
             if waitreq='0' then
                running_rr <= running_r;
                running_rrr <= running_rr;
                running_rrrr <= running_rrr;
                FOR II in 0 to dp_bus_id_max_c-1 LOOP
                   if dp_src_bus_id_rrr=to_unsigned(II,dp_bus_id_t'length) then
                      gen_valid_r(II) <= running_rrr;
                   else
                      gen_valid_r(II) <= '0';
                   end if;
                END LOOP;
                gen_busy_dest_r <= wr_full_in(to_integer(dp_dst_bus_id_rrr));
                data_rr <= data_r;
                data_rrr <= data_rr;
                data_rrrr <= data_rrr;
                dp_dst_bus_id_rr <= dp_dst_bus_id_r;
                dp_dst_bus_id_rrr <= dp_dst_bus_id_rr;
                dp_dst_bus_id_rrrr <= dp_dst_bus_id_rrr;
                dp_src_bus_id_rr <= dp_src_bus_id_r;
                dp_src_bus_id_rrr <= dp_src_bus_id_rr;
                dp_src_bus_id_rrrr <= dp_src_bus_id_rrr;

                dp_dst_data_type_rr <= dp_dst_data_type_r;
                dp_dst_data_type_rrr <= dp_dst_data_type_rr;
                dp_dst_data_type_rrrr <= dp_dst_data_type_rrr;
                dp_src_data_type_rr <= dp_src_data_type_r;
                dp_src_data_type_rrr <= dp_src_data_type_rr;
                dp_src_data_type_rrrr <= dp_src_data_type_rrr;

                dp_src_data_model_rr <= dp_src_data_model_r;
                dp_src_data_model_rrr <= dp_src_data_model_rr;
                dp_src_data_model_rrrr <= dp_src_data_model_rrr;

                dp_dst_data_model_rr <= dp_dst_data_model_r;
                dp_dst_data_model_rrr <= dp_dst_data_model_rr;
                dp_dst_data_model_rrrr <= dp_dst_data_model_rrr;

                dp_mcast_rr <= dp_mcast_r;
                dp_mcast_rrr <= dp_mcast_rr;
                dp_mcast_rrrr <= dp_mcast_rrr;

                dp_thread_rr <= dp_thread_r;
                dp_thread_rrr <= dp_thread_rr;
                dp_thread_rrrr <= dp_thread_rrr;
                
                eof_rr <= eof_r;
                eof_rrr <= eof_rr;
                eof_rrrr <= eof_rrr;

                src_is_burst_rr <= src_is_burst_r;
                dst_is_burst_rr <= dst_is_burst_r;

                ---------
                --- Calculate source address
                ---------

                s_temp1_r <= s_i0_r+s_i1_r+s_i3_r; -- First stage of address calculation
                s_bufsize_r <= s_template_r.bufsize(dp_addr_width_c-1 downto 0);
                s_bufsize_rr <= s_bufsize_r;
                s_temp2_r <= s_template_r.bar(dp_full_addr_width_c-1 downto 0); -- First stage of address calculation
                s_temp3_r <= s_template_r.count(dp_addr_width_c-1 downto 0)-s_burstlen_r; -- First stage of address calculation
                s_temp4_r <= s_burstpos_r+s_i2_r+s_i4_r; -- First stage of address calculation
                s_temp5_r <= s_temp1_r+s_temp4_r; -- Second stage of address calculation
                s_temp4_rr <= s_temp2_r; -- Second stage of address calculation
                addr_v := resize(unsigned(s_temp5_r),dp_full_addr_width_c)+s_temp4_rr;
                if src_double_rrr='1' then
                   s_gen_addr_r <= addr_v sll 1; -- Third stage of address calculation
                else
                   s_gen_addr_r <= addr_v;
                end if;
                if s_gen_burstlen_r > wr_maxburstlen_in(to_integer(dp_dst_bus_id_rrr)) then
                   s_burstlen_v :=  wr_maxburstlen_in(to_integer(dp_dst_bus_id_rrr));
                else
                   s_burstlen_v := s_gen_burstlen_r;
                end if;                                       
                s_gen_burstlen_rr <= s_burstlen_v;
                if( s_burstlen_v = to_unsigned(0,burstlen_t'length)) then
                   s_gen_burstlen_progress_r <= '0';
                else
                   s_gen_burstlen_progress_r <= '1';
                end if;

                ---
                -- Check to see how much to clip and the end of burst
                ---

                burstpos_v := unsigned(resize(s_burstpos_r,s_end_v'length));
                s_end_v := (unsigned(resize(s_burst_actual_max_r(dp_addr_width_c-1 downto 0),s_end_v'length))-burstpos_v)+to_unsigned(1,s_end_v'length);
                if src_double_r='1' then
                   s_end_v := s_end_v sll 1;
                end if;
                s_burstpos_end_r <= s_end_v;                    
                if s_burstpos_end_r(s_burstpos_end_r'length-1)='1' then
                   -- Overflow. Zap all the read to zero
                   s_burstpos_end_rr(s_burstpos_end_rr'length-1 downto 0) <= (others=>'0');
                elsif s_burstpos_end_r(s_burstpos_end_r'length-1 downto ddr_vector_depth_c+1)=to_unsigned(0,s_burstpos_end_r'length-ddr_vector_depth_c-1) then
                   -- The remaining read is <= ddr_vector_width. Zap the overflow to zero
                   s_burstpos_end_rr <= s_burstpos_end_r(ddr_vector_depth_c downto 0);
                else
                   -- The remaining read is > ddr_vector_width. Take everything from this read
                   s_burstpos_end_rr(s_burstpos_end_rr'length-1 downto 0) <= (others=>'1');
                end if;

                -- Cap to keep read within buffer size

                remain_v := signed(resize(s_bufsize_rr(dp_addr_width_c-2 downto 0),dp_addr_width_c+1))-signed(resize(s_temp5_r,dp_addr_width_c+1));
                if src_double_rrr='1' then
                   remain_v := remain_v sll 1;
                end if;
                if remain_v <= 0 then
                   s_burstpos_end_rrr <= (others=>'0');
                elsif unsigned(remain_v) > resize(s_burstpos_end_rr,dp_addr_width_c+1) then
                   s_burstpos_end_rrr <= s_burstpos_end_rr;
                else
                   s_burstpos_end_rrr <= unsigned(remain_v(s_burstpos_end_rrr'length-1 downto 0));
                end if;
                s_burstStride_r <= s_template_r.burstStride(dp_addr_width_c-1 downto 0);
                burstRemain_v := unsigned('0' & (std_logic_vector(s_template_r.burst_max(dp_addr_width_c-2 downto 0))))-unsigned(std_logic_vector(s_burstpos_r));
                if unsigned(src_vector_r)=to_unsigned(ddr_vector_width_c/4-1,ddr_vector_depth_c) then
                   s_burstRemain_r(burstRemain_v'length-ddr_vector_depth_c+2-1 downto 0) <= burstRemain_v(burstRemain_v'length-1 downto ddr_vector_depth_c-2);
                   s_burstRemain_r(burstRemain_v'length-1 downto burstRemain_v'length-ddr_vector_depth_c+2) <= (others=>'0');
                elsif unsigned(src_vector_r)=to_unsigned(ddr_vector_width_c/2-1,ddr_vector_depth_c) then
                   s_burstRemain_r(burstRemain_v'length-ddr_vector_depth_c+1-1 downto 0) <= burstRemain_v(burstRemain_v'length-1 downto ddr_vector_depth_c-1);
                   s_burstRemain_r(burstRemain_v'length-1 downto burstRemain_v'length-ddr_vector_depth_c+1) <= (others=>'0');
                elsif unsigned(src_vector_r)=to_unsigned(ddr_vector_width_c-1,ddr_vector_depth_c) then
                   s_burstRemain_r(burstRemain_v'length-ddr_vector_depth_c-1 downto 0) <= burstRemain_v(burstRemain_v'length-1 downto ddr_vector_depth_c);
                   s_burstRemain_r(burstRemain_v'length-1 downto burstRemain_v'length-ddr_vector_depth_c) <= (others=>'0');
                else
                   s_burstRemain_r <= burstRemain_v;
                end if;
                s_valid_r <= (s_i0_valid and s_i1_valid and s_i2_valid and s_i3_valid and s_i4_valid and s_burst_valid) and
                             (s_i0_start_valid and s_i1_start_valid and s_i2_start_valid and s_i3_start_valid and s_i4_start_valid and s_burst_start_valid);
                if s_valid_r='0' then
                   s_gen_burstlen_r <= (others=>'0');
                elsif SOURCE_BURST_MODE='1' and src_is_burst_rr='1' then                        
                   if( s_temp3_r(s_temp3_r'length-1 downto burstlen_t'length)=to_unsigned(0,s_temp3_r'length-burstlen_t'length) and
                      s_temp3_r(burstlen_t'length-1 downto 0)/=to_unsigned(burstlen_max_c,burstlen_t'length)) then
                      s_burstlen_v := s_temp3_r(burstlen_t'length-1 downto 0);
                   else
                      s_burstlen_v := to_unsigned(burstlen_max_c-1,burstlen_t'length);
                   end if;
                   if s_burstRemain_r(dp_addr_width_c-1)='1' then
                      s_gen_burstlen_r <= (others=>'0');
                   elsif(s_burstRemain_r(s_burstRemain_r'length-1 downto burstlen_t'length)=to_unsigned(0,s_burstRemain_r'length-burstlen_t'length) and 
                      s_burstlen_v > s_burstRemain_r(burstlen_t'length-1 downto 0)) then
                      s_gen_burstlen_r <= s_burstRemain_r(burstlen_t'length-1 downto 0)+1;
                   else
                      s_gen_burstlen_r <= s_burstlen_v+1;
                   end if;
                else
                   if(s_burstRemain_r(dp_addr_width_c-1)='1') then
                      s_gen_burstlen_r <= (others=>'0');
                   else
                      s_gen_burstlen_r <= to_unsigned(1,burstlen_t'length); -- Calculate burst len at second stage of addess calculation
                   end if;
                end if;

                data_flow_rr <= data_flow_r;
                data_flow_rrr <= data_flow_rr;
                data_flow_rrrr <= data_flow_rrr;

                stream_src_rr <= stream_src_r;
                stream_src_rrr <= stream_src_rr;
                stream_src_rrrr <= stream_src_rrr;

                stream_dest_rr <= stream_dest_r;
                stream_dest_rrr <= stream_dest_rr;
                stream_dest_rrrr <= stream_dest_rrr;

                stream_id_rr <= stream_id_r;
                stream_id_rrr <= stream_id_rr;
                stream_id_rrrr <= stream_id_rrr;

                vm_rr <= vm_r;
                vm_rrr <= vm_rr;
                vm_rrrr <= vm_rrr;

                src_double_rr <= src_double_r;
                src_double_rrr <= src_double_rr;
                src_double_rrrr <= src_double_rrr;

                dst_double_rr <= dst_double_r;
                dst_double_rrr <= dst_double_rr;
                dst_double_rrrr <= dst_double_rrr;

                src_vector_rr <= src_vector_r;
                src_vector_rrr <= src_vector_rr;
                if src_double_rrr='1' then
                   src_vector_rrrr(dp_vector_t'length-1 downto 1) <= src_vector_rrr(dp_vector_t'length-2 downto 0);
                   src_vector_rrrr(0) <= '1';
                else
                   src_vector_rrrr <= src_vector_rrr;
                end if;

                -- When burst position is negative. We want to zap the read content to zero.
                -- This is required for convolution read of feature map with padding.

                if s_burstpos_start_r(s_burstpos_start_r'length-1)='0' then
                   -- Start position is positive means no clipping to zero at the beginning
                   s_burstpos_start_rr <= (others=>'0');
                elsif s_burstpos_start_r(s_burstpos_start_r'length-1 downto ddr_vector_depth_c)=to_unsigned(2**(s_burstpos_start_r'length-ddr_vector_depth_c)-1,s_burstpos_start_r'length-ddr_vector_depth_c) then
                   -- Start position is negative but within a ddr_vector_width. So clip at beginning by this amount
                   s_burstpos_start_rr <= s_burstpos_start_r(ddr_vector_depth_c downto 0);
                else
                   -- Start position is negative but by more than a ddr_vector_width. So clip everything for this read
                   s_burstpos_start_rr(s_burstpos_start_rr'length-2 downto 0) <= (others=>'0');
                   s_burstpos_start_rr(s_burstpos_start_rr'length-1) <= '1';
                end if;
                s_burstpos_start_rrr <= s_burstpos_start_rr;
                s_burstpos_start_rrrr <= s_burstpos_start_rrr;

                dst_vector_rr <= dst_vector_r;
                dst_vector_rrr <= dst_vector_rr;
                if dst_double_rrr='1' then
                   dst_vector_rrrr(dp_vector_t'length-1 downto 1) <= dst_vector_rrr(dp_vector_t'length-2 downto 0);
                   dst_vector_rrrr(0) <= '1';
                else
                   dst_vector_rrrr <= dst_vector_rrr;
                end if;

                src_addr_mode_rr <= src_addr_mode_r;
                src_addr_mode_rrr <= src_addr_mode_rr;
                src_addr_mode_rrrr <= src_addr_mode_rrr;

                dst_addr_mode_rr <= dst_addr_mode_r;
                dst_addr_mode_rrr <= dst_addr_mode_rr;
                dst_addr_mode_rrrr <= dst_addr_mode_rrr;                

                src_scatter_rr <= src_scatter_r;
                src_scatter_rrr <= src_scatter_rr;
                src_scatter_rrrr <= src_scatter_rrr;

                dst_scatter_rr <= dst_scatter_r;
                dst_scatter_rrr <= dst_scatter_rr;
                dst_scatter_rrrr <= dst_scatter_rrr;

                ----------
                ---- Calculate destination address
                ----------

                d_bufsize_r <= d_template_r.bufsize(dp_addr_width_c-1 downto 0);
                d_bufsize_rr <= d_bufsize_r;
                d_temp1_r <= d_i0_r+d_i1_r+d_i3_r; -- First stage of address calculation
                d_temp2_r <= d_template_r.bar; -- First stage of address calculation
                d_temp3_r <= d_template_r.count-d_burstlen_r; -- First stage of address calculation
                d_temp4_r <= d_burstpos_r+d_i2_r+d_i4_r; -- First stage of address calculation
                d_temp5_r <= d_temp1_r+d_temp4_r; -- Second stage of address calculation

                d_temp4_rr <= d_temp2_r; -- Second stage of address calculation
                addr_v := resize(unsigned(d_temp5_r),dp_full_addr_width_c)+d_temp4_rr;
                if dst_double_rrr='1' then
                   d_gen_addr_r <= addr_v sll 1; -- Third stage of address calculation
                else
                   d_gen_addr_r <= addr_v;
                end if;

                d_gen_burstlen_rr <= d_gen_burstlen_r;  -- Latch gen burstlen for third stage of address calculation

                burstpos_v := unsigned(resize(d_burstpos_r,d_end_v'length));
                d_end_v := (unsigned(resize(d_burst_max_r(dp_addr_width_c-1 downto 0),d_end_v'length))-burstpos_v)+to_unsigned(1,d_end_v'length);
                if dst_double_r='1' then
                   d_end_v := d_end_v sll 1;
                end if;
                d_burstpos_end_r <= d_end_v;                    
                if d_burstpos_end_r(d_burstpos_end_r'length-1)='1' then
                   d_burstpos_end_rr(d_burstpos_end_rr'length-1 downto 0) <= (others=>'0');
                elsif d_burstpos_end_r(d_burstpos_end_r'length-1 downto ddr_vector_depth_c+1)=to_unsigned(0,d_burstpos_end_r'length-ddr_vector_depth_c-1) then
                   d_burstpos_end_rr <= d_burstpos_end_r(ddr_vector_depth_c downto 0);
                else
                   d_burstpos_end_rr(d_burstpos_end_rr'length-1 downto 0) <= (others=>'1');
                end if;

                -- Cap to keep read within buffer size
                remain_v := signed(resize(d_bufsize_rr(dp_addr_width_c-2 downto 0),dp_addr_width_c+1))-signed(resize(d_temp5_r,dp_addr_width_c+1));
                if dst_double_rrr='1' then
                   remain_v := remain_v sll 1;
                end if;
                if remain_v <= 0 then
                   d_burstpos_end_rrr <= (others=>'0');
                elsif unsigned(remain_v) > resize(d_burstpos_end_rr,dp_addr_width_c+1) then
                   d_burstpos_end_rrr <= d_burstpos_end_rr;
                else
                   d_burstpos_end_rrr <= unsigned(remain_v(d_burstpos_end_rrr'length-1 downto 0));
                end if;

                d_burstStride_r <= d_template_r.burstStride;
                burstRemain_v := unsigned('0' & std_logic_vector(d_burst_max_r(dp_addr_width_c-2 downto 0)))-unsigned(std_logic_vector(d_burstpos_r));
                if unsigned(dst_vector_r)=to_unsigned(ddr_vector_width_c/4-1,ddr_vector_depth_c) then
                   d_burstRemain_r(burstRemain_v'length-ddr_vector_depth_c+2-1 downto 0) <= burstRemain_v(burstRemain_v'length-1 downto ddr_vector_depth_c-2);
                   d_burstRemain_r(burstRemain_v'length-1 downto burstRemain_v'length-ddr_vector_depth_c+2) <= (others=>'0');
                elsif unsigned(dst_vector_r)=to_unsigned(ddr_vector_width_c/2-1,ddr_vector_depth_c) then
                   d_burstRemain_r(burstRemain_v'length-ddr_vector_depth_c+1-1 downto 0) <= burstRemain_v(burstRemain_v'length-1 downto ddr_vector_depth_c-1);
                   d_burstRemain_r(burstRemain_v'length-1 downto burstRemain_v'length-ddr_vector_depth_c+1) <= (others=>'0');
                elsif unsigned(dst_vector_r)=to_unsigned(ddr_vector_width_c-1,ddr_vector_depth_c) then                
                   d_burstRemain_r(burstRemain_v'length-ddr_vector_depth_c-1 downto 0) <= burstRemain_v(burstRemain_v'length-1 downto ddr_vector_depth_c);
                   d_burstRemain_r(burstRemain_v'length-1 downto burstRemain_v'length-ddr_vector_depth_c) <= (others=>'0');
                else
                   d_burstRemain_r <= burstRemain_v;
                end if;
                d_valid_r <= (d_i0_valid and d_i1_valid and d_i2_valid and d_i3_valid and d_i4_valid and d_burst_valid);
                if d_valid_r='0' then
                    d_gen_burstlen_r <= (others=>'0');
                elsif DEST_BURST_MODE='1' and dst_is_burst_rr='1' then
                    if( d_temp3_r(d_temp3_r'length-1 downto burstlen_t'length)=to_unsigned(0,d_temp3_r'length-burstlen_t'length) and
                        d_temp3_r(burstlen_t'length-1 downto 0)/=to_unsigned(burstlen_max_c,burstlen_t'length)) then
                        d_burstlen_v := d_temp3_r(burstlen_t'length-1 downto 0);
                    else
                        d_burstlen_v := to_unsigned(burstlen_max_c-1,burstlen_t'length);
                    end if;
                    if d_burstRemain_r(dp_addr_width_c-1)='1' then
                        d_gen_burstlen_r <= (others=>'0');
                    elsif(d_burstRemain_r(d_burstRemain_r'length-1 downto burstlen_t'length)=to_unsigned(0,d_burstRemain_r'length-burstlen_t'length) and 
                          d_burstlen_v > d_burstRemain_r(burstlen_t'length-1 downto 0)) then
                        d_gen_burstlen_r <= d_burstRemain_r(burstlen_t'length-1 downto 0)+1;
                    else
                        d_gen_burstlen_r <= d_burstlen_v+1;
                    end if;
                else
                    if(d_burstRemain_r(dp_addr_width_c-1)='1') then
                        d_gen_burstlen_r <= (others=>'0');
                    else
                        d_gen_burstlen_r <= to_unsigned(1,burstlen_t'length); -- Calculate burst len at second stage of addess calculation
                    end if;
                end if;            
            else
                gen_busy_dest_r <= wr_full_in(to_integer(dp_dst_bus_id_rrrr));
            end if;
        end if;
    end if;
end process;


---------
-- State machine for loop interation
---------
process(reset_in,clock_in)
variable half_v:std_logic_vector(register_width_c-1 downto 0);
variable burst_min_v:unsigned(dp_addr_width_c+1-1 downto 0);
variable burst_stride_v:unsigned(dp_addr_width_c-1 downto 0);
variable totallen_v:unsigned(dp_addr_width_c-1 downto 0);
begin
   if reset_in = '0' then
      running_r <= '0';
      dp_dst_bus_id_r <= (others=>'0');
      dp_src_bus_id_r <= (others=>'0');
      dp_dst_data_type_r <= (others=>'0');
      dp_src_data_type_r <= (others=>'0');
      dp_src_data_model_r <= (others=>'0');
      dp_dst_data_model_r <= (others=>'0');
      dp_thread_r <= (others=>'0');
      dp_mcast_r <= (others=>'1');
      data_r <= (others=>'0');

      s_i0_r <= (others=>'0');
      s_i1_r <= (others=>'0');
      s_i2_r <= (others=>'0');
      s_i3_r <= (others=>'0');
      s_i4_r <= (others=>'0');

      s_i0_count_r <= (others=>'0');
      s_i1_count_r <= (others=>'0');
      s_i2_count_r <= (others=>'0');
      s_i3_count_r <= (others=>'0');
      s_i4_count_r <= (others=>'0');

      s_i0_start_r <= (others=>'0');
      s_i1_start_r <= (others=>'0');
      s_i2_start_r <= (others=>'0');
      s_i3_start_r <= (others=>'0');
      s_i4_start_r <= (others=>'0');
      s_burstpos_start_r <= (others=>'0');
      s_burstpos_stride_r <= (others=>'0');

      s_burstlen_r <= (others=>'0');
      s_burstpos_r <= (others=>'0');

      d_i0_r <= (others=>'0');
      d_i1_r <= (others=>'0');
      d_i2_r <= (others=>'0');
      d_i3_r <= (others=>'0');
      d_i4_r <= (others=>'0');
      d_i0_count_r <= (others=>'0');
      d_i1_count_r <= (others=>'0');
      d_i2_count_r <= (others=>'0');
      d_i3_count_r <= (others=>'0');
      d_i4_count_r <= (others=>'0');
      d_burstlen_r <= (others=>'0');
      d_burstpos_r <= (others=>'0');
      d_burst_max_r <= (others=>'0');

      currlen_r <= (others=>'0');
      done_r <= '1';
      totallen_r <= (others=>'0');
      eof_r <= '0';
      repeat_r <= '0';
      data_flow_r <= (others=>'0');
      stream_src_r <= '0';
      stream_dest_r <= '0';
      stream_id_r <= (others=>'0');
      vm_r <= '0';
      src_vector_r <= (others=>'0');
      dst_vector_r <= (others=>'0');
      src_addr_mode_r <= '0';
      dst_addr_mode_r <= '0';
      src_scatter_r <= (others=>'0');
      dst_scatter_r <= (others=>'0');
      src_double_r <= '0';
      dst_double_r <= '0';

      src_is_burst_r <= '0';
      dst_is_burst_r <= '0';
      s_burst_actual_max_r <= (others=>'0');

      log_r <= (others=>'0');
      log_valid_r <= '0';
   else
      if clock_in'event and clock_in='1' then
         log_valid_r <= '0';
         if (waitreq='0') or (reload='1' and instruction_valid_in='1') then
            if reload='1' then
               if instruction_valid_in='1' then
                  log_r <= log;
                  log_valid_r <= '1';
               end if;
               
               ---------
               -- reload new instruction
               ---------

               running_r <= instruction_valid_in;

               if instruction_latch_in='1' then
                  s_template_r.stride0 <= instruction_source_in.stride0;
                  s_template_r.stride0_count <= instruction_source_in.stride0_count;
                  s_template_r.stride0_max <= instruction_source_in.stride0_max;
                  s_template_r.stride0_min <= instruction_source_in.stride0_min;
                  s_template_r.stride1 <= instruction_source_in.stride1;
                  s_template_r.stride1_count <= instruction_source_in.stride1_count;
                  s_template_r.stride1_max <= instruction_source_in.stride1_max;
                  s_template_r.stride1_min <= instruction_source_in.stride1_min;
                  s_template_r.stride2 <= instruction_source_in.stride2;
                  s_template_r.stride2_count <= instruction_source_in.stride2_count;
                  s_template_r.stride2_max <= instruction_source_in.stride2_max;
                  s_template_r.stride2_min <= instruction_source_in.stride2_min;
                  s_template_r.stride3 <= instruction_source_in.stride3;
                  s_template_r.stride3_count <= instruction_source_in.stride3_count;
                  s_template_r.stride3_max <= instruction_source_in.stride3_max;
                  s_template_r.stride3_min <= instruction_source_in.stride3_min;
                  s_template_r.stride4 <= instruction_source_in.stride4;
                  s_template_r.stride4_count <= instruction_source_in.stride4_count;
                  s_template_r.stride4_max <= instruction_source_in.stride4_max;
                  s_template_r.stride4_min <= instruction_source_in.stride4_min;
                  s_template_r.burst_max(s_template_r.burst_max'length-1 downto dp_vector_t'length) <= instruction_source_in.burst_max(instruction_source_in.burst_max'length-1 downto dp_vector_t'length);
                  FOR I in 0 to dp_vector_t'length-1 loop
                     s_template_r.burst_max(I) <= instruction_source_in.burst_max(I) or src_vector(I);
                  end loop;
                  s_burst_actual_max_r <= instruction_source_in.burst_max;

                  s_template_r.bufsize <= instruction_source_in.bufsize;
                  s_template_r.bar <= instruction_source_in.bar;
                  s_template_r.burst_max_len <= instruction_source_in.burst_max_len;
                    
                  if src_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,dp_vector_t'length)) then
                     s_template_r.count(s_template_r.count'length-ddr_vector_depth_c-1 downto 0) <= instruction_source_in.count(instruction_source_in.count'length-1 downto ddr_vector_depth_c);
                     s_template_r.count(s_template_r.count'length-1 downto s_template_r.count'length-ddr_vector_depth_c) <= (others=>'0');
                  elsif src_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,dp_vector_t'length)) then
                     s_template_r.count(s_template_r.count'length-ddr_vector_depth_c+1-1 downto 0) <= instruction_source_in.count(instruction_source_in.count'length-1 downto ddr_vector_depth_c-1);
                     s_template_r.count(s_template_r.count'length-1 downto s_template_r.count'length-ddr_vector_depth_c+1) <= (others=>'0');
                  elsif src_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,dp_vector_t'length)) then
                     s_template_r.count(s_template_r.count'length-ddr_vector_depth_c+2-1 downto 0) <= instruction_source_in.count(instruction_source_in.count'length-1 downto ddr_vector_depth_c-2);
                     s_template_r.count(s_template_r.count'length-1 downto s_template_r.count'length-ddr_vector_depth_c+2) <= (others=>'0');                    
                  else
                     s_template_r.count <= instruction_source_in.count;
                  end if;

                  if source_double_precision='1' then
                     burst_min_v := instruction_source_in.burst_min sll 1;
                  else
                     burst_min_v := instruction_source_in.burst_min;
                  end if;
                  s_template_r.burst_min <= burst_min_v;

                  if instruction_source_in.burstStride=to_unsigned(1,instruction_source_in.burstStride'length) then
                     src_is_burst_r <= '1';
                  else
                     src_is_burst_r <= '0';
                  end if;
                  if src_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,dp_vector_t'length)) then
                     if src_is_scatter_r(0)=scatter_none_c then
                        burst_stride_v := to_unsigned(1*ddr_vector_width_c/1,s_template_r.burstStride'length);
                     elsif src_is_scatter_r(0)=scatter_vector_c then
                        burst_stride_v := to_unsigned(vector_width_c*ddr_vector_width_c/1,s_template_r.burstStride'length);
                     else
                        burst_stride_v := to_unsigned(register_size_c*ddr_vector_width_c/1,s_template_r.burstStride'length);
                     end if;
                  elsif src_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,dp_vector_t'length)) then
                     if src_is_scatter_r(1)=scatter_none_c then
                        burst_stride_v := to_unsigned(1*ddr_vector_width_c/2,s_template_r.burstStride'length);
                     elsif src_is_scatter_r(1)=scatter_vector_c then
                        burst_stride_v := to_unsigned(vector_width_c*ddr_vector_width_c/2,s_template_r.burstStride'length);
                     else
                        burst_stride_v := to_unsigned(register_size_c*ddr_vector_width_c/2,s_template_r.burstStride'length);
                     end if;
                  elsif src_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,dp_vector_t'length)) then
                     if src_is_scatter_r(1)=scatter_none_c then
                        burst_stride_v := to_unsigned(1*ddr_vector_width_c/4,s_template_r.burstStride'length);
                     elsif src_is_scatter_r(1)=scatter_vector_c then
                        burst_stride_v := to_unsigned(vector_width_c*ddr_vector_width_c/4,s_template_r.burstStride'length);
                     else
                        burst_stride_v := to_unsigned(register_size_c*ddr_vector_width_c/4,s_template_r.burstStride'length);
                     end if;
                  else
                     burst_stride_v := instruction_source_in.burstStride;
                  end if;                   
                  s_template_r.burstStride <= burst_stride_v;
                  if source_double_precision='1' then
                     s_burstpos_stride_r <= burst_stride_v sll 1;
                  else
                     s_burstpos_stride_r <= burst_stride_v;
                  end if;

                  d_template_r.stride0 <= instruction_dest_in.stride0;
                  d_template_r.stride0_count <= instruction_dest_in.stride0_count;
                  d_template_r.stride0_max <= instruction_dest_in.stride0_max;
                  d_template_r.stride1 <= instruction_dest_in.stride1;
                  d_template_r.stride1_count <= instruction_dest_in.stride1_count;
                  d_template_r.stride1_max <= instruction_dest_in.stride1_max;
                  d_template_r.stride2 <= instruction_dest_in.stride2;
                  d_template_r.stride2_count <= instruction_dest_in.stride2_count;
                  d_template_r.stride2_max <= instruction_dest_in.stride2_max;
                  d_template_r.stride3 <= instruction_dest_in.stride3;
                  d_template_r.stride3_count <= instruction_dest_in.stride3_count;
                  d_template_r.stride3_max <= instruction_dest_in.stride3_max;
                  d_template_r.stride4 <= instruction_dest_in.stride4;
                  d_template_r.stride4_count <= instruction_dest_in.stride4_count;
                  d_template_r.stride4_max <= instruction_dest_in.stride4_max;
                  d_template_r.bar <= instruction_dest_in.bar;
                  d_template_r.bufsize <= instruction_dest_in.bufsize;
                    
                  d_burst_max_r <= instruction_dest_in.burst_max_init;
                  d_template_r.burst_max <= instruction_dest_in.burst_max_init;
                  d_template_r.burst_max2 <= instruction_dest_in.burst_max2;
                  d_template_r.burst_max_index <= instruction_dest_in.burst_max_index;
                  d_template_r.burst_max_len <= instruction_dest_in.burst_max_len;

                  if dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,dp_vector_t'length)) then
                     d_template_r.count(d_template_r.count'length-ddr_vector_depth_c-1 downto 0) <= instruction_dest_in.count(instruction_dest_in.count'length-1 downto ddr_vector_depth_c);
                     d_template_r.count(d_template_r.count'length-1 downto d_template_r.count'length-ddr_vector_depth_c) <= (others=>'0');
                  elsif dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,dp_vector_t'length)) then
                     d_template_r.count(d_template_r.count'length-ddr_vector_depth_c+1-1 downto 0) <= instruction_dest_in.count(instruction_dest_in.count'length-1 downto ddr_vector_depth_c-1);
                     d_template_r.count(d_template_r.count'length-1 downto d_template_r.count'length-ddr_vector_depth_c+1) <= (others=>'0');
                  elsif dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,dp_vector_t'length)) then
                     d_template_r.count(d_template_r.count'length-ddr_vector_depth_c+2-1 downto 0) <= instruction_dest_in.count(instruction_dest_in.count'length-1 downto ddr_vector_depth_c-2);
                     d_template_r.count(d_template_r.count'length-1 downto d_template_r.count'length-ddr_vector_depth_c+2) <= (others=>'0');
                  else
                     d_template_r.count <= instruction_dest_in.count;
                  end if;

                  if instruction_dest_in.burstStride=to_unsigned(1,instruction_dest_in.burstStride'length) then
                     dst_is_burst_r <= '1';
                  else
                     dst_is_burst_r <= '0';
                  end if;

                  if dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,dp_vector_t'length)) then
                     if dst_is_scatter_r(0)=scatter_none_c then
                        d_template_r.burstStride <= to_unsigned(1*ddr_vector_width_c/1,s_template_r.burstStride'length);
                     elsif dst_is_scatter_r(0)=scatter_vector_c then
                        d_template_r.burstStride <= to_unsigned(vector_width_c*ddr_vector_width_c/1,d_template_r.burstStride'length);
                     else
                        d_template_r.burstStride <= to_unsigned(register_size_c*ddr_vector_width_c/1,d_template_r.burstStride'length);
                     end if;
                  elsif dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,dp_vector_t'length)) then
                     if dst_is_scatter_r(1)=scatter_none_c then
                        d_template_r.burstStride <= to_unsigned(1*ddr_vector_width_c/2,s_template_r.burstStride'length);
                     elsif dst_is_scatter_r(1)=scatter_vector_c then
                        d_template_r.burstStride <= to_unsigned(vector_width_c*ddr_vector_width_c/2,d_template_r.burstStride'length);
                     else
                        d_template_r.burstStride <= to_unsigned(register_size_c*ddr_vector_width_c/2,d_template_r.burstStride'length);
                     end if;
                  elsif dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,dp_vector_t'length)) then
                     if dst_is_scatter_r(1)=scatter_none_c then
                        d_template_r.burstStride <= to_unsigned(1*ddr_vector_width_c/4,s_template_r.burstStride'length);
                     elsif dst_is_scatter_r(1)=scatter_vector_c then
                        d_template_r.burstStride <= to_unsigned(vector_width_c*ddr_vector_width_c/4,d_template_r.burstStride'length);
                     else
                        d_template_r.burstStride <= to_unsigned(register_size_c*ddr_vector_width_c/4,d_template_r.burstStride'length);
                     end if;
                  else
                     d_template_r.burstStride <= instruction_dest_in.burstStride;
                  end if;

                  src_vector_r <= src_vector; 
                  dst_vector_r <= dst_vector;
                  src_scatter_r <= src_scatter;
                  dst_scatter_r <= dst_scatter;

                  src_addr_mode_r <= instruction_source_addr_mode_in;
                  dst_addr_mode_r <= instruction_dest_addr_mode_in;

                  if instruction_bus_id_dest_in=dp_bus_id_register_c then
                     stream_dest_r <= instruction_stream_process_in;
                     stream_src_r <= '0';
                  else
                     stream_dest_r <= '0';
                     stream_src_r <= instruction_stream_process_in;
                  end if;

                  vm_r <= instruction_vm_in;

                  stream_id_r <= instruction_stream_process_id_in;
                  if instruction_bus_id_source_in=dp_bus_id_register_c and instruction_bus_id_dest_in=dp_bus_id_register_c then
                     if instruction_source_in.double_precision='0' and instruction_dest_in.double_precision='0' then
                        data_flow_r <= std_logic_vector(to_unsigned(data_flow_direct_c,data_flow_t'length));   
                     else
                        data_flow_r <= std_logic_vector(to_unsigned(data_flow_converge_c,data_flow_t'length));   
                     end if;                                          
                  elsif source_double_precision='1' and dest_double_precision='0' then
                     data_flow_r <= std_logic_vector(to_unsigned(data_flow_converge_c,data_flow_t'length));
                  elsif source_double_precision='0' and dest_double_precision='1' then
                     data_flow_r <= std_logic_vector(to_unsigned(data_flow_diverge_c,data_flow_t'length));
                  else
                     data_flow_r <= std_logic_vector(to_unsigned(data_flow_direct_c,data_flow_t'length));
                  end if;

                  src_double_r <= source_double_precision;
                  dst_double_r <= dest_double_precision;

                  if dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,dp_vector_t'length)) then
                     totallen_v(dp_addr_width_c-1 downto dp_addr_width_c-ddr_vector_depth_c) := to_unsigned(0,ddr_vector_depth_c);
                     totallen_v(dp_addr_width_c-ddr_vector_depth_c-1 downto 0) := instruction_gen_len_in(dp_addr_width_c-1 downto ddr_vector_depth_c)-1;
                  elsif dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,dp_vector_t'length)) then
                     totallen_v(dp_addr_width_c-1 downto dp_addr_width_c-ddr_vector_depth_c+1) := to_unsigned(0,ddr_vector_depth_c-1);
                     totallen_v(dp_addr_width_c-ddr_vector_depth_c+1-1 downto 0) := instruction_gen_len_in(dp_addr_width_c-1 downto ddr_vector_depth_c-1)-1;
                  elsif dst_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,dp_vector_t'length)) then
                     totallen_v(dp_addr_width_c-1 downto dp_addr_width_c-ddr_vector_depth_c+2) := to_unsigned(0,ddr_vector_depth_c-2);
                     totallen_v(dp_addr_width_c-ddr_vector_depth_c+2-1 downto 0) := instruction_gen_len_in(dp_addr_width_c-1 downto ddr_vector_depth_c-2)-1;
                  else
                     totallen_v := instruction_gen_len_in-1;
                  end if;
                  totallen_r <= totallen_v;
                  currlen_r <= totallen_v;
                  if unsigned(totallen_v)=len_zero_v then
                     done_r <= '1';
                  else
                     done_r <= '0';
                  end if;
                  dp_dst_bus_id_r <= instruction_bus_id_dest_in;
                  dp_src_bus_id_r <= instruction_bus_id_source_in;
                  dp_dst_data_type_r <= instruction_data_type_dest_in;
                  dp_src_data_type_r <= instruction_data_type_source_in;
                  dp_src_data_model_r <= instruction_data_model_source_in;
                  dp_dst_data_model_r <= instruction_data_model_dest_in;
                  dp_thread_r <= instruction_thread_in;
                  dp_mcast_r <= instruction_mcast_in;

                  if source_double_precision='1' then
                     data_r <=  instruction_data_in(2*data_width_c-1 downto data_width_c) & 
                                instruction_data_in(1*data_width_c-1 downto 0) &
                                instruction_data_in(2*data_width_c-1 downto data_width_c) &
                                instruction_data_in(1*data_width_c-1 downto 0) &
                                instruction_data_in(2*data_width_c-1 downto data_width_c) &
                                instruction_data_in(1*data_width_c-1 downto 0) &
                                instruction_data_in(2*data_width_c-1 downto data_width_c) &
                                instruction_data_in(1*data_width_c-1 downto 0);
                  else
                     data_r <=  instruction_data_in(data_width_c-1 downto 0) & 
                                instruction_data_in(data_width_c-1 downto 0) & 
                                instruction_data_in(data_width_c-1 downto 0) & 
                                instruction_data_in(data_width_c-1 downto 0) &
                                instruction_data_in(data_width_c-1 downto 0) &
                                instruction_data_in(data_width_c-1 downto 0) &
                                instruction_data_in(data_width_c-1 downto 0) &
                                instruction_data_in(data_width_c-1 downto 0);
                  end if;
                  repeat_r <= instruction_repeat_in;

                  if instruction_source_in.burstStride=to_unsigned(0,dp_addr_width_c) then
                     eof_r <= '1';
                  else
                     eof_r <= '0';
                  end if;
               end if;

               s_i0_r <= (others=>'0');
               s_i1_r <= (others=>'0');
               s_i2_r <= (others=>'0');
               s_i3_r <= (others=>'0');
               s_i4_r <= (others=>'0');

               s_i0_count_r <= (others=>'0');
               s_i1_count_r <= (others=>'0');
               s_i2_count_r <= (others=>'0');
               s_i3_count_r <= (others=>'0');
               s_i4_count_r <= (others=>'0');

               s_burstlen_r <= (others=>'0');
               s_burstpos_r <= (others=>'0');

               s_i0_start_r <= instruction_source_in.stride0_min;
               s_i1_start_r <= instruction_source_in.stride1_min;
               s_i2_start_r <= instruction_source_in.stride2_min;
               s_i3_start_r <= instruction_source_in.stride3_min;
               s_i4_start_r <= instruction_source_in.stride4_min;

               s_burstpos_start_r <= burst_min_v;

               d_i0_r <= (others=>'0');
               d_i1_r <= (others=>'0');
               d_i2_r <= (others=>'0');
               d_i3_r <= (others=>'0');
               d_i4_r <= (others=>'0');

               d_i0_count_r <= (others=>'0');
               d_i1_count_r <= (others=>'0');
               d_i2_count_r <= (others=>'0');
               d_i3_count_r <= (others=>'0');
               d_i4_count_r <= (others=>'0');

               d_burstlen_r <= (others=>'0');
               d_burstpos_r <= (others=>'0');
            else
               currlen_r <= currlen_new;
               if unsigned(currlen_new)=len_zero_v then
                  done_r <= '1';
               else
                  done_r <= '0';
               end if;
               if s_burstlen_wrap='0' then
                  s_burstlen_r <= s_burstlen_new;
                  s_burstpos_r <= s_burstpos_new;
                  s_burstpos_start_r <= s_burstpos_start_new;
               elsif s_i4_wrap='0' then
                  s_burstlen_r <= (others=>'0');
                  s_burstpos_r <= (others=>'0');
                  s_i4_r <= s_i4_new;
                  s_i4_count_r <= s_i4_count_new;
                  s_burstpos_start_r <= s_template_r.burst_min(dp_addr_width_c+1-1 downto 0);
                  s_i4_start_r <= s_i4_start_new;
               elsif s_i3_wrap='0' then
                  s_burstlen_r <= (others=>'0');
                  s_burstpos_r <= (others=>'0');
                  s_i4_r <= (others=>'0');
                  s_i4_count_r <= (others=>'0');
                  s_i3_r <= s_i3_new;
                  s_i3_count_r <= s_i3_count_new;
                  s_burstpos_start_r <= s_template_r.burst_min(dp_addr_width_c+1-1 downto 0);
                  s_i4_start_r <= s_template_r.stride4_min(dp_addr_width_c+1-1 downto 0);
                  s_i3_start_r <= s_i3_start_new;
               elsif s_i2_wrap='0' then
                  s_burstlen_r <= (others=>'0');
                  s_burstpos_r <= (others=>'0');
                  s_i4_r <= (others=>'0');
                  s_i4_count_r <= (others=>'0');
                  s_i3_r <= (others=>'0');
                  s_i3_count_r <= (others=>'0');
                  s_i2_r <= s_i2_new;
                  s_i2_count_r <= s_i2_count_new;
                  s_burstpos_start_r <= s_template_r.burst_min(dp_addr_width_c+1-1 downto 0);
                  s_i4_start_r <= s_template_r.stride4_min(dp_addr_width_c+1-1 downto 0);
                  s_i3_start_r <= s_template_r.stride3_min(dp_addr_width_c+1-1 downto 0);
                  s_i2_start_r <= s_i2_start_new;
               elsif s_i1_wrap='0' then
                  s_burstlen_r <= (others=>'0');
                  s_burstpos_r <= (others=>'0');
                  s_i4_r <= (others=>'0');
                  s_i4_count_r <= (others=>'0');
                  s_i3_r <= (others=>'0');
                  s_i3_count_r <= (others=>'0');
                  s_i2_r <= (others=>'0');
                  s_i2_count_r <= (others=>'0');
                  s_i1_r <= s_i1_new;
                  s_i1_count_r <= s_i1_count_new;

                  s_burstpos_start_r <= s_template_r.burst_min(dp_addr_width_c+1-1 downto 0);
                  s_i4_start_r <= s_template_r.stride4_min(dp_addr_width_c+1-1 downto 0);
                  s_i3_start_r <= s_template_r.stride3_min(dp_addr_width_c+1-1 downto 0);
                  s_i2_start_r <= s_template_r.stride2_min(dp_addr_width_c+1-1 downto 0);
                  s_i1_start_r <= s_i1_start_new;
               elsif s_i0_wrap='0' then
                  s_burstlen_r <= (others=>'0');
                  s_burstpos_r <= (others=>'0');
                  s_i4_r <= (others=>'0');
                  s_i4_count_r <= (others=>'0');
                  s_i3_r <= (others=>'0');
                  s_i3_count_r <= (others=>'0');
                  s_i2_r <= (others=>'0');
                  s_i2_count_r <= (others=>'0');
                  s_i1_r <= (others=>'0');
                  s_i1_count_r <= (others=>'0');
                  s_i0_r <= s_i0_new;
                  s_i0_count_r <= s_i0_count_new;

                  s_burstpos_start_r <= s_template_r.burst_min(dp_addr_width_c+1-1 downto 0);
                  s_i4_start_r <= s_template_r.stride4_min(dp_addr_width_c+1-1 downto 0);
                  s_i3_start_r <= s_template_r.stride3_min(dp_addr_width_c+1-1 downto 0);
                  s_i2_start_r <= s_template_r.stride2_min(dp_addr_width_c+1-1 downto 0);
                  s_i1_start_r <= s_template_r.stride1_min(dp_addr_width_c+1-1 downto 0);
                  s_i0_start_r <= s_i0_start_new;
               else
                  eof_r <= not repeat_r;
                  s_burstlen_r <= (others=>'0');
                  s_burstpos_r <= (others=>'0');
                  s_i4_r <= (others=>'0');
                  s_i4_count_r <= (others=>'0');
                  s_i3_r <= (others=>'0');
                  s_i3_count_r <= (others=>'0');
                  s_i2_r <= (others=>'0');
                  s_i2_count_r <= (others=>'0');
                  s_i1_r <= (others=>'0');
                  s_i1_count_r <= (others=>'0');
                  s_i0_r <= (others=>'0');
                  s_i0_count_r <= (others=>'0');
                  s_burstpos_start_r <= s_template_r.burst_min(dp_addr_width_c+1-1 downto 0);
                  s_i4_start_r <= s_template_r.stride4_min(dp_addr_width_c+1-1 downto 0);
                  s_i3_start_r <= s_template_r.stride3_min(dp_addr_width_c+1-1 downto 0);
                  s_i2_start_r <= s_template_r.stride2_min(dp_addr_width_c+1-1 downto 0);
                  s_i1_start_r <= s_template_r.stride1_min(dp_addr_width_c+1-1 downto 0);
                  s_i0_start_r <= s_template_r.stride0_min(dp_addr_width_c+1-1 downto 0);
               end if;
               if d_burstlen_wrap='0' then
                  d_burstlen_r <= d_burstlen_new;
                  d_burstpos_r <= d_burstpos_new;
               elsif d_i4_wrap='0' then
                  d_burstlen_r <= (others=>'0');
                  d_burstpos_r <= (others=>'0');
                  d_i4_r <= d_i4_new;
                  d_i4_count_r <= d_i4_count_new;
                  if((d_template_r.burst_max_index=4) and 
                     (d_i4_new2 > d_template_r.stride4_max(dp_addr_width_c-1 downto 0))) then
                      d_burst_max_r <= d_template_r.burst_max2;
                  else
                      d_burst_max_r <= d_template_r.burst_max;
                  end if;
               elsif d_i3_wrap='0' then
                  d_burstlen_r <= (others=>'0');
                  d_burstpos_r <= (others=>'0');
                  d_burst_max_r <= d_template_r.burst_max;
                  d_i4_r <= (others=>'0');
                  d_i4_count_r <= (others=>'0');
                  d_i3_r <= d_i3_new;
                  d_i3_count_r <= d_i3_count_new;
                  if((d_template_r.burst_max_index=3) and 
                     (d_i3_new2 > d_template_r.stride3_max(dp_addr_width_c-1 downto 0))) then
                      d_burst_max_r <= d_template_r.burst_max2;
                  else
                      d_burst_max_r <= d_template_r.burst_max;
                  end if;
               elsif d_i2_wrap='0' then
                  d_burstlen_r <= (others=>'0');
                  d_burstpos_r <= (others=>'0');
                  d_burst_max_r <= d_template_r.burst_max;
                  d_i4_r <= (others=>'0');
                  d_i4_count_r <= (others=>'0');
                  d_i3_r <= (others=>'0');
                  d_i3_count_r <= (others=>'0');
                  d_i2_r <= d_i2_new;
                  d_i2_count_r <= d_i2_count_new;
                  if((d_template_r.burst_max_index=2) and 
                     (d_i2_new2 > d_template_r.stride2_max(dp_addr_width_c-1 downto 0))) then
                      d_burst_max_r <= d_template_r.burst_max2;
                  else
                      d_burst_max_r <= d_template_r.burst_max;
                  end if;
               elsif d_i1_wrap='0' then
                  d_burstlen_r <= (others=>'0');
                  d_burstpos_r <= (others=>'0');
                  d_burst_max_r <= d_template_r.burst_max;
                  d_i4_r <= (others=>'0');
                  d_i4_count_r <= (others=>'0');
                  d_i3_r <= (others=>'0');
                  d_i3_count_r <= (others=>'0');
                  d_i2_r <= (others=>'0');
                  d_i2_count_r <= (others=>'0');
                  d_i1_r <= d_i1_new;
                  d_i1_count_r <= d_i1_count_new;
                  if((d_template_r.burst_max_index=1) and 
                     (d_i1_new2 > d_template_r.stride1_max(dp_addr_width_c-1 downto 0))) then
                     d_burst_max_r <= d_template_r.burst_max2;
                  else
                     d_burst_max_r <= d_template_r.burst_max;
                  end if;
               elsif d_i0_wrap='0' then
                  d_burstlen_r <= (others=>'0');
                  d_burstpos_r <= (others=>'0');
                  d_burst_max_r <= d_template_r.burst_max;
                  d_i4_r <= (others=>'0');
                  d_i4_count_r <= (others=>'0');
                  d_i3_r <= (others=>'0');
                  d_i3_count_r <= (others=>'0');
                  d_i2_r <= (others=>'0');
                  d_i2_count_r <= (others=>'0');
                  d_i1_r <= (others=>'0');
                  d_i1_count_r <= (others=>'0');
                  d_i0_r <= d_i0_new;
                  d_i0_count_r <= d_i0_count_new;
                  if((d_template_r.burst_max_index=0) and 
                     (d_i0_new2 > d_template_r.stride0_max(dp_addr_width_c-1 downto 0))) then
                      d_burst_max_r <= d_template_r.burst_max2;
                  else
                      d_burst_max_r <= d_template_r.burst_max;
                  end if;
               else
                  d_burstlen_r <= (others=>'0');
                  d_burstpos_r <= (others=>'0');
                  d_burst_max_r <= d_template_r.burst_max;
                  d_i4_r <= (others=>'0');
                  d_i4_count_r <= (others=>'0');
                  d_i3_r <= (others=>'0');
                  d_i3_count_r <= (others=>'0');
                  d_i2_r <= (others=>'0');
                  d_i2_count_r <= (others=>'0');
                  d_i1_r <= (others=>'0');
                  d_i1_count_r <= (others=>'0');
                  d_i0_r <= (others=>'0');
                  d_i0_count_r <= (others=>'0');
               end if;
            end if;
         end if;
      end if;
   end if; 
end process;
END dp_gen_behaviour;
