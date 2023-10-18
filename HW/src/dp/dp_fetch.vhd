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
use work.config.all;

ENTITY dp_fetch IS
    GENERIC (
            DP_THREAD_ID     : integer;
            NUM_DP_SRC_PORT  : integer;
            NUM_DP_DST_PORT  : integer
            );
    port(
            -- Signal from Avalon bus...
            SIGNAL clock_in                 : IN STD_LOGIC;
            SIGNAL clock_x2_in              : IN STD_LOGIC;
            SIGNAL reset_in                 : IN STD_LOGIC;    
            SIGNAL bus_waddr_in             : IN register_addr_t;
            SIGNAL bus_raddr_in             : IN register_addr_t;
            SIGNAL bus_write_in             : IN STD_LOGIC;
            SIGNAL bus_read_in              : IN STD_LOGIC;
            SIGNAL bus_writedata_in         : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
            SIGNAL bus_readdata_out         : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
            SIGNAL bus_readdatavalid_out    : OUT STD_LOGIC;
            SIGNAL bus_writewait_out        : OUT STD_LOGIC;
            SIGNAL bus_readwait_out         : OUT STD_LOGIC;
                                   
            -- Signal from next stage
            
            SIGNAL ready_in                 : IN STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);        
            
            -- Signal to next stage
            
            SIGNAL instruction_valid_out    : OUT STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
            SIGNAL instruction_out          : OUT dp_instruction_t;
            SIGNAL pre_instruction_out      : OUT dp_instruction_t;

            -- Sink counter
            
            SIGNAL pcore_sink_counter_in    : IN dp_counters_t(1 downto 0);
            SIGNAL sram_sink_counter_in     : IN dp_counters_t(1 downto 0);
            SIGNAL ddr_sink_counter_in      : IN dp_counter_t;

            -- Task control
            
            SIGNAL task_start_addr_out      : OUT instruction_addr_t;
            SIGNAL task_pending_out         : OUT STD_LOGIC;
            SIGNAL task_out                 : OUT STD_LOGIC;
            SIGNAL task_vm_out              : OUT STD_LOGIC;
            SIGNAL task_pcore_out           : OUT pcore_t;
            SIGNAL task_lockstep_out        : OUT STD_LOGIC;
            SIGNAL task_tid_mask_out        : OUT tid_mask_t;
            SIGNAL task_iregister_auto_out  : OUT iregister_auto_t;
            SIGNAL task_data_model_out      : OUT dp_data_model_t;
            SIGNAL task_busy_in             : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            SIGNAL task_ready_in            : IN STD_LOGIC;

            -- Indication

            SIGNAL indication_avail_out     : OUT STD_LOGIC;

            SIGNAL log1_in                  : IN STD_LOGIC_VECTOR(host_width_c-1 downto 0);
            SIGNAL log1_valid_in            : IN STD_LOGIC;

            SIGNAL log2_in                  : IN STD_LOGIC_VECTOR(host_width_c-1 downto 0);
            SIGNAL log2_valid_in            : IN STD_LOGIC;

            SIGNAL pcore_read_pending_p0_in : STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
            SIGNAL sram_read_pending_p0_in  : STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
            SIGNAL ddr_read_pending_p0_in   : STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);

            SIGNAL pcore_read_pending_p1_in : STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
            SIGNAL sram_read_pending_p1_in  : STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
            SIGNAL ddr_read_pending_p1_in   : STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
            
            SIGNAL ddr_tx_busy_in           : IN STD_LOGIC
    );
END dp_fetch;

ARCHITECTURE dp_fetch_behaviour of dp_fetch is

COMPONENT altsyncram
GENERIC (
        address_aclr_b                     : STRING;
        address_reg_b                      : STRING;
        clock_enable_input_a               : STRING;
        clock_enable_input_b               : STRING;
        clock_enable_output_b              : STRING;
        intended_device_family             : STRING;
        lpm_type                           : STRING;
        numwords_a                         : NATURAL;
        numwords_b                         : NATURAL;
        operation_mode                     : STRING;
        outdata_aclr_b                     : STRING;
        outdata_reg_b                      : STRING;
        power_up_uninitialized             : STRING;
        read_during_write_mode_mixed_ports : STRING;
        widthad_a                          : NATURAL;
        widthad_b                          : NATURAL;
        width_a                            : NATURAL;
        width_b                            : NATURAL;
        width_byteena_a                    : NATURAL
    );
    PORT (
        address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        clock0      : IN STD_LOGIC ;
        data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b         : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a      : IN STD_LOGIC ;
        address_b   : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

SIGNAL fifo_avail:std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0);
SIGNAL match:STD_LOGIC;
SIGNAL irec: dp_instruction_t; -- Record going into the fifo
SIGNAL irec_generic: dp_instruction_generic_t; -- Record going into the fifo
SIGNAL orec: dp_instruction_t; -- Record going out the fifo
SIGNAL orecs: dp_instructions_t(1 downto 0); -- Record going out the fifo
SIGNAL orec_generic: dp_instruction_generic_t; -- Record going out the fifo
SIGNAL data:std_logic_vector(dp_instruction_width_c-1 downto 0);
SIGNAL q1:std_logic_vector(dp_instruction_width_c-1 downto 0);
SIGNAL q2:std_logic_vector(dp_instruction_width_c-1 downto 0);
SIGNAL rdreq:STD_LOGIC;
SIGNAL rdreqs:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL wreq:STD_LOGIC;
SIGNAL wreq_all:STD_LOGIC;
SIGNAL full:STD_LOGIC;
SIGNAL ready:STD_LOGIC;
SIGNAL ready_which:std_logic;
SIGNAL ready2:STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
SIGNAL valid:STD_LOGIC;
SIGNAL valids:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL wregno: unsigned(register_t'length-1 downto 0);
SIGNAL rregno: unsigned(register_t'length-1 downto 0);
SIGNAL pcore_sink_counter_r:dp_counters_t(1 downto 0);
SIGNAL sram_sink_counter_r:dp_counters_t(1 downto 0);
SIGNAL ddr_sink_counter_r:dp_counter_t;
SIGNAL sink_pcore_busy_r:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL sink_sram_busy_r:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL sink_ddr_busy_r:STD_LOGIC;
SIGNAL pcore_source_busy_r:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL sram_source_busy_r:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL ddr_source_busy_r:STD_LOGIC;
SIGNAL log_enable_r:STD_LOGIC;
SIGNAL print_indication_r:STD_LOGIC;
SIGNAL print_indication_rr:STD_LOGIC;
SIGNAL print_param_r:STD_LOGIC_VECTOR(2*host_width_c-1 downto 0);
SIGNAL print_param_rr:STD_LOGIC_VECTOR(2*host_width_c-1 downto 0);
SIGNAL wreq2:STD_LOGIC;
SIGNAL wreq2_indication:STD_LOGIC;
SIGNAL pcore_read_pending: STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
SIGNAL sram_read_pending: STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
SIGNAL ddr_read_pending: STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);

subtype dp_fifo_record_t is std_logic_vector(dp_instruction_width_c-1 downto 0);
subtype dp_template_record_t is std_logic_vector(dp_template_width_c-1 downto 0);

-- Indication signals...
SIGNAL indication_full_r:STD_LOGIC;
SIGNAL indication_full:STD_LOGIC;
SIGNAL indication_rdreq:STD_LOGIC;
SIGNAL in_indication:std_logic_vector(dp_indication_num_parm_c*host_width_c+dp_opcode_t'length-1 downto 0);
SIGNAL indication:std_logic_vector(dp_indication_num_parm_c*host_width_c+dp_opcode_t'length-1 downto 0);
SIGNAL indication_rdusedw:std_logic_vector(dp_indication_depth_c-1 downto 0);
SIGNAL indication_wrusedw:std_logic_vector(dp_indication_depth_c-1 downto 0);
SIGNAL indication_parm_r:std_logic_vector(dp_indication_num_parm_c*host_width_c-1 downto 0);
SIGNAL indication_r:std_logic_vector(host_width_c-1 downto 0);
SIGNAL indication_sync_r:std_logic;

-- Avalon bus read control

SIGNAL bus_readdata_r:STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);

SIGNAL instruction_valid_r:STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
SIGNAL instruction_valid_rr:STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
SIGNAL instruction_r:dp_instruction_t;
SIGNAL instruction_rr:dp_instruction_t;
SIGNAL instruction:dp_instruction_t;

SIGNAL log_status_last_r:STD_LOGIC_VECTOR(2*host_width_c-1 downto 0);
SIGNAL log_write:STD_LOGIC_VECTOR(2*host_width_c-1 downto 0);
SIGNAL log_read:STD_LOGIC_VECTOR(2*host_width_c-1 downto 0);
SIGNAL log_readtime_r:STD_LOGIC_VECTOR(host_width_c-1 downto 0);
SIGNAL log_rdreq:STD_LOGIC;
SIGNAL log_empty:STD_LOGIC;
SIGNAL log_full:STD_LOGIC;
SIGNAL log_time_r:unsigned(host_width_c-1 downto 0);
SIGNAL log_last_status_r:STD_LOGIC_VECTOR(log_status_max_c-1 downto 0);
SIGNAL log_wrreq:STD_LOGIC;
SIGNAL log_wrreq2:STD_LOGIC;

SIGNAL load:std_logic;
SIGNAL load_r:std_logic;
SIGNAL load_busid_r:dp_template_id_t;

SIGNAL dp_var_waddress:std_logic_vector(dp_template_id_depth_c-1 downto 0);
SIGNAL dp_var_raddress:std_logic_vector(dp_template_id_depth_c-1 downto 0);
SIGNAL dp_var_write:dp_template_record_t;
SIGNAL dp_var_read:dp_template_record_t;
SIGNAL dp_var_we:std_logic;
SIGNAL dp_var_template:dp_template_t;

SIGNAL task2:STD_LOGIC;
SIGNAL waitrequest:STD_LOGIC;

-- Current allocated resources for each DP engine

SIGNAL source_bus_id_r:dp_bus_ids_t(dp_max_gen_c-1 downto 0);
SIGNAL source_vm_r:std_logic_vector(dp_max_gen_c-1 downto 0);
SIGNAL dest_bus_id_r:dp_bus_ids_t(dp_max_gen_c-1 downto 0);

SIGNAL outOfOrderOk:STD_LOGIC;

type safe_mask_t is array (dp_bus_id_max_c downto 0) of std_logic_vector(dp_bus_id_max_c downto 0);

SIGNAL new_cmd_is_safe_r:safe_mask_t;
SIGNAL condition_vm0_busy_r:dp_condition_t;
SIGNAL condition_vm1_busy_r:dp_condition_t;

SIGNAL curr_vm_r:STD_LOGIC;

-- Pack template into a linear buffer

function pack_dp_template(rec_in: dp_template_t) return dp_template_record_t is

variable len_v:integer;
variable q_v:dp_template_record_t;
begin
   len_v := 0;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride0'length) := std_logic_vector(rec_in.stride0);
   len_v := len_v + rec_in.stride0'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride0_count'length) := std_logic_vector(rec_in.stride0_count);
   len_v := len_v + rec_in.stride0_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride0_max'length) := std_logic_vector(rec_in.stride0_max);
   len_v := len_v + rec_in.stride0_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride0_min'length) := std_logic_vector(rec_in.stride0_min);
   len_v := len_v + rec_in.stride0_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride1'length) := std_logic_vector(rec_in.stride1);
   len_v := len_v + rec_in.stride1'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride1_count'length) := std_logic_vector(rec_in.stride1_count);
   len_v := len_v + rec_in.stride1_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride1_max'length) := std_logic_vector(rec_in.stride1_max);
   len_v := len_v + rec_in.stride1_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride1_min'length) := std_logic_vector(rec_in.stride1_min);
   len_v := len_v + rec_in.stride1_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride2'length) := std_logic_vector(rec_in.stride2);
   len_v := len_v + rec_in.stride2'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride2_count'length) := std_logic_vector(rec_in.stride2_count);
   len_v := len_v + rec_in.stride2_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride2_max'length) := std_logic_vector(rec_in.stride2_max);
   len_v := len_v + rec_in.stride2_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride2_min'length) := std_logic_vector(rec_in.stride2_min);
   len_v := len_v + rec_in.stride2_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride3'length) := std_logic_vector(rec_in.stride3);
   len_v := len_v + rec_in.stride3'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride3_count'length) := std_logic_vector(rec_in.stride3_count);
   len_v := len_v + rec_in.stride3_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride3_max'length) := std_logic_vector(rec_in.stride3_max);
   len_v := len_v + rec_in.stride3_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride3_min'length) := std_logic_vector(rec_in.stride3_min);
   len_v := len_v + rec_in.stride3_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride4'length) := std_logic_vector(rec_in.stride4);
   len_v := len_v + rec_in.stride4'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride4_count'length) := std_logic_vector(rec_in.stride4_count);
   len_v := len_v + rec_in.stride4_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride4_max'length) := std_logic_vector(rec_in.stride4_max);
   len_v := len_v + rec_in.stride4_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.stride4_min'length) := std_logic_vector(rec_in.stride4_min);
   len_v := len_v + rec_in.stride4_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burst_max'length) := std_logic_vector(rec_in.burst_max);
   len_v := len_v + rec_in.burst_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burst_max2'length) := std_logic_vector(rec_in.burst_max2);
   len_v := len_v + rec_in.burst_max2'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burst_max_init'length) := std_logic_vector(rec_in.burst_max_init);
   len_v := len_v + rec_in.burst_max_init'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burst_max_index'length) := std_logic_vector(rec_in.burst_max_index);
   len_v := len_v + rec_in.burst_max_index'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burst_min'length) := std_logic_vector(rec_in.burst_min);
   len_v := len_v + rec_in.burst_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.bar'length) := std_logic_vector(rec_in.bar);
   len_v := len_v + rec_in.bar'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.count'length) := std_logic_vector(rec_in.count);
   len_v := len_v + rec_in.count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burstStride'length) := std_logic_vector(rec_in.burstStride);
   len_v := len_v + rec_in.burstStride'length;
   q_v(q_v'length-len_v-1) := rec_in.double_precision;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.data_model'length) := std_logic_vector(rec_in.data_model);
   len_v := len_v + rec_in.data_model'length;
   q_v(q_v'length-len_v-1) := rec_in.scatter;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.totalcount'length) := std_logic_vector(rec_in.totalcount);
   len_v := len_v + rec_in.totalcount'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.mcast'length) := std_logic_vector(rec_in.mcast);
   len_v := len_v + rec_in.mcast'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.data'length) := std_logic_vector(rec_in.data);
   len_v := len_v + rec_in.data'length;
   q_v(q_v'length-len_v-1) := rec_in.repeat;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.datatype'length) := std_logic_vector(rec_in.datatype);
   len_v := len_v + rec_in.datatype'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.bus_id'length) := std_logic_vector(rec_in.bus_id);
   len_v := len_v + rec_in.bus_id'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.bufsize'length) := std_logic_vector(rec_in.bufsize);
   len_v := len_v + rec_in.bufsize'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burst_max_len'length) := std_logic_vector(rec_in.burst_max_len);
   len_v := len_v + rec_in.burst_max_len'length;
   return q_v;
end function pack_dp_template;

-------
-- Unpack dp_template from a linear buffer
--------

function unpack_dp_template(q_in : dp_template_record_t) return dp_template_t is  
variable rec_v:dp_template_t;
variable len_v:integer;
begin
    len_v := 0;
    rec_v.stride0 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride0'length));
    len_v := len_v + rec_v.stride0'length;
    rec_v.stride0_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride0_count'length));
    len_v := len_v + rec_v.stride0_count'length;
    rec_v.stride0_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride0_max'length));
    len_v := len_v + rec_v.stride0_max'length;
    rec_v.stride0_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride0_min'length));
    len_v := len_v + rec_v.stride0_min'length;
    rec_v.stride1 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride1'length));
    len_v := len_v + rec_v.stride1'length;
    rec_v.stride1_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride1_count'length));
    len_v := len_v + rec_v.stride1_count'length;
    rec_v.stride1_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride1_max'length));
    len_v := len_v + rec_v.stride1_max'length;
    rec_v.stride1_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride1_min'length));
    len_v := len_v + rec_v.stride1_min'length;
    rec_v.stride2 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride2'length));
    len_v := len_v + rec_v.stride2'length;
    rec_v.stride2_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride2_count'length));
    len_v := len_v + rec_v.stride2_count'length;
    rec_v.stride2_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride2_max'length));
    len_v := len_v + rec_v.stride2_max'length;
    rec_v.stride2_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride2_min'length));
    len_v := len_v + rec_v.stride2_min'length;
    rec_v.stride3 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride3'length));
    len_v := len_v + rec_v.stride3'length;
    rec_v.stride3_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride3_count'length));
    len_v := len_v + rec_v.stride3_count'length;
    rec_v.stride3_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride3_max'length));
    len_v := len_v + rec_v.stride3_max'length;
    rec_v.stride3_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride3_min'length));
    len_v := len_v + rec_v.stride3_min'length;
    rec_v.stride4 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride4'length));
    len_v := len_v + rec_v.stride4'length;
    rec_v.stride4_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride4_count'length));
    len_v := len_v + rec_v.stride4_count'length;
    rec_v.stride4_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride4_max'length));
    len_v := len_v + rec_v.stride4_max'length;
    rec_v.stride4_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.stride4_min'length));
    len_v := len_v + rec_v.stride4_min'length;
    rec_v.burst_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burst_max'length));
    len_v := len_v + rec_v.burst_max'length;
    rec_v.burst_max2 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burst_max2'length));
    len_v := len_v + rec_v.burst_max2'length;
    rec_v.burst_max_init := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burst_max_init'length));
    len_v := len_v + rec_v.burst_max_init'length;
    rec_v.burst_max_index := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burst_max_index'length));
    len_v := len_v + rec_v.burst_max_index'length;
    rec_v.burst_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burst_min'length));
    len_v := len_v + rec_v.burst_min'length;
    rec_v.bar := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.bar'length));
    len_v := len_v + rec_v.bar'length;
    rec_v.count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.count'length));
    len_v := len_v + rec_v.count'length;
    rec_v.burstStride := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burstStride'length));
    len_v := len_v + rec_v.burstStride'length;
    rec_v.double_precision := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.data_model := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.data_model'length);
    len_v := len_v + rec_v.data_model'length;
    rec_v.scatter := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.totalcount := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.totalcount'length));
    len_v := len_v + rec_v.totalcount'length;
    rec_v.mcast := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.mcast'length);
    len_v := len_v + rec_v.mcast'length;
    rec_v.data := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.data'length);
    len_v := len_v + rec_v.data'length;
    rec_v.repeat := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.datatype := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.datatype'length));
    len_v := len_v + rec_v.datatype'length;
    rec_v.bus_id := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.bus_id'length));
    len_v := len_v + rec_v.bus_id'length;
    rec_v.bufsize := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.bufsize'length));
    len_v := len_v + rec_v.bufsize'length;
    rec_v.burst_max_len := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burst_max_len'length));
    len_v := len_v + rec_v.burst_max_len'length;
    return rec_v;
end function unpack_dp_template;

-----------
--- Function to pack incoming DP <dp_opcode_transfer_c> instruction to FIFO
-----------

function pack_fifo(rec_in : dp_instruction_t) return dp_fifo_record_t is  
variable len_v:integer;
variable q_v:dp_fifo_record_t;
begin
   len_v := 0;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.opcode'length) := std_logic_vector(rec_in.opcode);
   len_v := len_v + rec_in.opcode'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.condition'length) := std_logic_vector(rec_in.condition);
   len_v := len_v + rec_in.condition'length;
   q_v(q_v'length-len_v-1) := rec_in.vm;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride0'length) := std_logic_vector(rec_in.source.stride0);
   len_v := len_v + rec_in.source.stride0'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride0_count'length) := std_logic_vector(rec_in.source.stride0_count);
   len_v := len_v + rec_in.source.stride0_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride0_max'length) := std_logic_vector(rec_in.source.stride0_max);
   len_v := len_v + rec_in.source.stride0_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride0_min'length) := std_logic_vector(rec_in.source.stride0_min);
   len_v := len_v + rec_in.source.stride0_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride1'length) := std_logic_vector(rec_in.source.stride1);
   len_v := len_v + rec_in.source.stride1'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride1_count'length) := std_logic_vector(rec_in.source.stride1_count);
   len_v := len_v + rec_in.source.stride1_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride1_max'length) := std_logic_vector(rec_in.source.stride1_max);
   len_v := len_v + rec_in.source.stride1_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride1_min'length) := std_logic_vector(rec_in.source.stride1_min);
   len_v := len_v + rec_in.source.stride1_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride2'length) := std_logic_vector(rec_in.source.stride2);
   len_v := len_v + rec_in.source.stride2'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride2_count'length) := std_logic_vector(rec_in.source.stride2_count);
   len_v := len_v + rec_in.source.stride2_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride2_max'length) := std_logic_vector(rec_in.source.stride2_max);
   len_v := len_v + rec_in.source.stride2_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride2_min'length) := std_logic_vector(rec_in.source.stride2_min);
   len_v := len_v + rec_in.source.stride2_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride3'length) := std_logic_vector(rec_in.source.stride3);
   len_v := len_v + rec_in.source.stride3'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride3_count'length) := std_logic_vector(rec_in.source.stride3_count);
   len_v := len_v + rec_in.source.stride3_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride3_max'length) := std_logic_vector(rec_in.source.stride3_max);
   len_v := len_v + rec_in.source.stride3_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride3_min'length) := std_logic_vector(rec_in.source.stride3_min);
   len_v := len_v + rec_in.source.stride3_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride4'length) := std_logic_vector(rec_in.source.stride4);
   len_v := len_v + rec_in.source.stride4'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride4_count'length) := std_logic_vector(rec_in.source.stride4_count);
   len_v := len_v + rec_in.source.stride4_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride4_max'length) := std_logic_vector(rec_in.source.stride4_max);
   len_v := len_v + rec_in.source.stride4_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.stride4_min'length) := std_logic_vector(rec_in.source.stride4_min);
   len_v := len_v + rec_in.source.stride4_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.burst_max'length) := std_logic_vector(rec_in.source.burst_max);
   len_v := len_v + rec_in.source.burst_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.burst_max2'length) := std_logic_vector(rec_in.source.burst_max2);
   len_v := len_v + rec_in.source.burst_max2'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.burst_max_init'length) := std_logic_vector(rec_in.source.burst_max_init);
   len_v := len_v + rec_in.source.burst_max_init'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.burst_max_index'length) := std_logic_vector(rec_in.source.burst_max_index);
   len_v := len_v + rec_in.source.burst_max_index'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.burst_min'length) := std_logic_vector(rec_in.source.burst_min);
   len_v := len_v + rec_in.source.burst_min'length;
   q_v(q_v'length-len_v-1) := rec_in.source.double_precision;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.data_model'length) := std_logic_vector(rec_in.source.data_model);
   len_v := len_v + rec_in.source.data_model'length;
   q_v(q_v'length-len_v-1) := rec_in.source.scatter;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.bar'length) := std_logic_vector(rec_in.source.bar);
   len_v := len_v + rec_in.source.bar'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.count'length) := std_logic_vector(rec_in.source.count);
   len_v := len_v + rec_in.source.count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.burstStride'length) := std_logic_vector(rec_in.source.burstStride);
   len_v := len_v + rec_in.source.burstStride'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.bufsize'length) := std_logic_vector(rec_in.source.bufsize);
   len_v := len_v + rec_in.source.bufsize'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source.burst_max_len'length) := std_logic_vector(rec_in.source.burst_max_len);
   len_v := len_v + rec_in.source.burst_max_len'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source_bus_id'length) := std_logic_vector(rec_in.source_bus_id);
   len_v := len_v + rec_in.source_bus_id'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.source_data_type'length) := std_logic_vector(rec_in.source_data_type);
   len_v := len_v + rec_in.source_data_type'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride0'length) := std_logic_vector(rec_in.dest.stride0);
   len_v := len_v + rec_in.dest.stride0'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride0_count'length) := std_logic_vector(rec_in.dest.stride0_count);
   len_v := len_v + rec_in.dest.stride0_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride0_max'length) := std_logic_vector(rec_in.dest.stride0_max);
   len_v := len_v + rec_in.dest.stride0_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride0_min'length) := std_logic_vector(rec_in.dest.stride0_min);
   len_v := len_v + rec_in.dest.stride0_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride1'length) := std_logic_vector(rec_in.dest.stride1);
   len_v := len_v + rec_in.dest.stride1'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride1_count'length) := std_logic_vector(rec_in.dest.stride1_count);
   len_v := len_v + rec_in.dest.stride1_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride1_max'length) := std_logic_vector(rec_in.dest.stride1_max);
   len_v := len_v + rec_in.dest.stride1_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride1_min'length) := std_logic_vector(rec_in.dest.stride1_min);
   len_v := len_v + rec_in.dest.stride1_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride2'length) := std_logic_vector(rec_in.dest.stride2);
   len_v := len_v + rec_in.dest.stride2'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride2_count'length) := std_logic_vector(rec_in.dest.stride2_count);
   len_v := len_v + rec_in.dest.stride2_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride2_max'length) := std_logic_vector(rec_in.dest.stride2_max);
   len_v := len_v + rec_in.dest.stride2_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride2_min'length) := std_logic_vector(rec_in.dest.stride2_min);
   len_v := len_v + rec_in.dest.stride2_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride3'length) := std_logic_vector(rec_in.dest.stride3);
   len_v := len_v + rec_in.dest.stride3'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride3_count'length) := std_logic_vector(rec_in.dest.stride3_count);
   len_v := len_v + rec_in.dest.stride3_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride3_max'length) := std_logic_vector(rec_in.dest.stride3_max);
   len_v := len_v + rec_in.dest.stride3_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride3_min'length) := std_logic_vector(rec_in.dest.stride3_min);
   len_v := len_v + rec_in.dest.stride3_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride4'length) := std_logic_vector(rec_in.dest.stride4);
   len_v := len_v + rec_in.dest.stride4'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride4_count'length) := std_logic_vector(rec_in.dest.stride4_count);
   len_v := len_v + rec_in.dest.stride4_count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride4_max'length) := std_logic_vector(rec_in.dest.stride4_max);
   len_v := len_v + rec_in.dest.stride4_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.stride4_min'length) := std_logic_vector(rec_in.dest.stride4_min);
   len_v := len_v + rec_in.dest.stride4_min'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.burst_max'length) := std_logic_vector(rec_in.dest.burst_max);
   len_v := len_v + rec_in.dest.burst_max'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.burst_max2'length) := std_logic_vector(rec_in.dest.burst_max2);
   len_v := len_v + rec_in.dest.burst_max2'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.burst_max_init'length) := std_logic_vector(rec_in.dest.burst_max_init);
   len_v := len_v + rec_in.dest.burst_max_init'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.burst_max_index'length) := std_logic_vector(rec_in.dest.burst_max_index);
   len_v := len_v + rec_in.dest.burst_max_index'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.burst_min'length) := std_logic_vector(rec_in.dest.burst_min);
   len_v := len_v + rec_in.dest.burst_min'length;
   q_v(q_v'length-len_v-1) := rec_in.dest.double_precision;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.data_model'length) := std_logic_vector(rec_in.dest.data_model);
   len_v := len_v + rec_in.dest.data_model'length;
   q_v(q_v'length-len_v-1) := rec_in.dest.scatter;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.bar'length) := std_logic_vector(rec_in.dest.bar);
   len_v := len_v + rec_in.dest.bar'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.count'length) := std_logic_vector(rec_in.dest.count);
   len_v := len_v + rec_in.dest.count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.burstStride'length) := std_logic_vector(rec_in.dest.burstStride);
   len_v := len_v + rec_in.dest.burstStride'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.bufsize'length) := std_logic_vector(rec_in.dest.bufsize);
   len_v := len_v + rec_in.dest.bufsize'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest.burst_max_len'length) := std_logic_vector(rec_in.dest.burst_max_len);
   len_v := len_v + rec_in.dest.burst_max_len'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest_bus_id'length) := std_logic_vector(rec_in.dest_bus_id);
   len_v := len_v + rec_in.dest_bus_id'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.dest_data_type'length) := std_logic_vector(rec_in.dest_data_type);
   len_v := len_v + rec_in.dest_data_type'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.mcast'length) := std_logic_vector(rec_in.mcast);
   len_v := len_v + rec_in.mcast'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.count'length) := std_logic_vector(rec_in.count);
   len_v := len_v + rec_in.count'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.data'length) := std_logic_vector(rec_in.data);
   len_v := len_v + rec_in.data'length;
   q_v(q_v'length-len_v-1) := std_logic(rec_in.repeat);
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := std_logic(rec_in.source_addr_mode);
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := std_logic(rec_in.dest_addr_mode);
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := std_logic(rec_in.stream_process);
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-stream_id_t'length) := std_logic_vector(rec_in.stream_process_id);
   len_v := len_v + stream_id_t'length;
   return q_v;
end function pack_fifo;

--------
-- Function to unpack <dp_opcode_transfer_c> instruction fifo
--------

function unpack_fifo(q_in : dp_fifo_record_t) return dp_instruction_t is  
variable rec_v:dp_instruction_t;
variable len_v:integer;
begin
    len_v := 0;
    rec_v.opcode := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.opcode'length));
    len_v := len_v + rec_v.opcode'length;
    rec_v.condition := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.condition'length);
    len_v := len_v + rec_v.condition'length;
    rec_v.vm := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.source.stride0 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride0'length));
    len_v := len_v + rec_v.source.stride0'length;
    rec_v.source.stride0_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride0_count'length));
    len_v := len_v + rec_v.source.stride0_count'length;
    rec_v.source.stride0_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride0_max'length));
    len_v := len_v + rec_v.source.stride0_max'length;
    rec_v.source.stride0_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride0_min'length));
    len_v := len_v + rec_v.source.stride0_min'length;
    rec_v.source.stride1 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride1'length));
    len_v := len_v + rec_v.source.stride1'length;
    rec_v.source.stride1_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride1_count'length));
    len_v := len_v + rec_v.source.stride1_count'length;
    rec_v.source.stride1_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride1_max'length));
    len_v := len_v + rec_v.source.stride1_max'length;
    rec_v.source.stride1_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride1_min'length));
    len_v := len_v + rec_v.source.stride1_min'length;
    rec_v.source.stride2 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride2'length));
    len_v := len_v + rec_v.source.stride2'length;
    rec_v.source.stride2_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride2_count'length));
    len_v := len_v + rec_v.source.stride2_count'length;
    rec_v.source.stride2_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride2_max'length));
    len_v := len_v + rec_v.source.stride2_max'length;
    rec_v.source.stride2_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride2_min'length));
    len_v := len_v + rec_v.source.stride2_min'length;
    rec_v.source.stride3 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride3'length));
    len_v := len_v + rec_v.source.stride3'length;
    rec_v.source.stride3_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride3_count'length));
    len_v := len_v + rec_v.source.stride3_count'length;
    rec_v.source.stride3_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride3_max'length));
    len_v := len_v + rec_v.source.stride3_max'length;
    rec_v.source.stride3_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride3_min'length));
    len_v := len_v + rec_v.source.stride3_min'length;
    rec_v.source.stride4 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride4'length));
    len_v := len_v + rec_v.source.stride4'length;
    rec_v.source.stride4_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride4_count'length));
    len_v := len_v + rec_v.source.stride4_count'length;
    rec_v.source.stride4_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride4_max'length));
    len_v := len_v + rec_v.source.stride4_max'length;
    rec_v.source.stride4_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.stride4_min'length));
    len_v := len_v + rec_v.source.stride4_min'length;
    rec_v.source.burst_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.burst_max'length));
    len_v := len_v + rec_v.source.burst_max'length;
    rec_v.source.burst_max2 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.burst_max2'length));
    len_v := len_v + rec_v.source.burst_max2'length;
    rec_v.source.burst_max_init := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.burst_max_init'length));
    len_v := len_v + rec_v.source.burst_max_init'length;
    rec_v.source.burst_max_index := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.burst_max_index'length));
    len_v := len_v + rec_v.source.burst_max_index'length;
    rec_v.source.burst_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.burst_min'length));
    len_v := len_v + rec_v.source.burst_min'length;
    rec_v.source.double_precision := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.source.data_model := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.data_model'length);
    len_v := len_v + rec_v.source.data_model'length;
    rec_v.source.scatter := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.source.bar := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.bar'length));
    len_v := len_v + rec_v.source.bar'length;
    rec_v.source.count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.count'length));
    len_v := len_v + rec_v.source.count'length;
    rec_v.source.burstStride := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.burstStride'length));
    len_v := len_v + rec_v.source.burstStride'length;
    rec_v.source.bufsize := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.bufsize'length));
    len_v := len_v + rec_v.source.bufsize'length;
    rec_v.source.burst_max_len := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source.burst_max_len'length));
    len_v := len_v + rec_v.source.burst_max_len'length;
    rec_v.source_bus_id := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source_bus_id'length));
    len_v := len_v + rec_v.source_bus_id'length;
    rec_v.source_data_type := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.source_data_type'length));
    len_v := len_v + rec_v.source_data_type'length;
    rec_v.dest.stride0 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride0'length));
    len_v := len_v + rec_v.dest.stride0'length;
    rec_v.dest.stride0_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride0_count'length));
    len_v := len_v + rec_v.dest.stride0_count'length;
    rec_v.dest.stride0_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride0_max'length));
    len_v := len_v + rec_v.dest.stride0_max'length;
    rec_v.dest.stride0_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride0_min'length));
    len_v := len_v + rec_v.dest.stride0_min'length;
    rec_v.dest.stride1 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride1'length));
    len_v := len_v + rec_v.dest.stride1'length;
    rec_v.dest.stride1_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride1_count'length));
    len_v := len_v + rec_v.dest.stride1_count'length;
    rec_v.dest.stride1_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride1_max'length));
    len_v := len_v + rec_v.dest.stride1_max'length;
    rec_v.dest.stride1_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride1_min'length));
    len_v := len_v + rec_v.dest.stride1_min'length;
    rec_v.dest.stride2 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride2'length));
    len_v := len_v + rec_v.dest.stride2'length;
    rec_v.dest.stride2_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride2_count'length));
    len_v := len_v + rec_v.dest.stride2_count'length;
    rec_v.dest.stride2_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride2_max'length));
    len_v := len_v + rec_v.dest.stride2_max'length;
    rec_v.dest.stride2_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride2_min'length));
    len_v := len_v + rec_v.dest.stride2_min'length;
    rec_v.dest.stride3 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride3'length));
    len_v := len_v + rec_v.dest.stride3'length;
    rec_v.dest.stride3_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride3_count'length));
    len_v := len_v + rec_v.dest.stride3_count'length;
    rec_v.dest.stride3_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride3_max'length));
    len_v := len_v + rec_v.dest.stride3_max'length;
    rec_v.dest.stride3_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride3_min'length));
    len_v := len_v + rec_v.dest.stride3_min'length;
    rec_v.dest.stride4 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride4'length));
    len_v := len_v + rec_v.dest.stride4'length;
    rec_v.dest.stride4_count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride4_count'length));
    len_v := len_v + rec_v.dest.stride4_count'length;
    rec_v.dest.stride4_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride4_max'length));
    len_v := len_v + rec_v.dest.stride4_max'length;
    rec_v.dest.stride4_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.stride4_min'length));
    len_v := len_v + rec_v.dest.stride4_min'length;
    rec_v.dest.burst_max := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.burst_max'length));
    len_v := len_v + rec_v.dest.burst_max'length;
    rec_v.dest.burst_max2 := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.burst_max2'length));
    len_v := len_v + rec_v.dest.burst_max2'length;
    rec_v.dest.burst_max_init := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.burst_max_init'length));
    len_v := len_v + rec_v.dest.burst_max_init'length;
    rec_v.dest.burst_max_index := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.burst_max_index'length));
    len_v := len_v + rec_v.dest.burst_max_index'length;
    rec_v.dest.burst_min := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.burst_min'length));
    len_v := len_v + rec_v.dest.burst_min'length;
    rec_v.dest.double_precision := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.dest.data_model := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.data_model'length);
    len_v := len_v + rec_v.dest.data_model'length;
    rec_v.dest.scatter := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.dest.bar := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.bar'length));
    len_v := len_v + rec_v.dest.bar'length;
    rec_v.dest.count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.count'length));
    len_v := len_v + rec_v.dest.count'length;
    rec_v.dest.burstStride := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.burstStride'length));
    len_v := len_v + rec_v.dest.burstStride'length;
    rec_v.dest.bufsize := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.bufsize'length));
    len_v := len_v + rec_v.dest.bufsize'length;
    rec_v.dest.burst_max_len := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest.burst_max_len'length));
    len_v := len_v + rec_v.dest.burst_max_len'length;
    rec_v.dest_bus_id := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest_bus_id'length));
    len_v := len_v + rec_v.dest_bus_id'length;
    rec_v.dest_data_type := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.dest_data_type'length));
    len_v := len_v + rec_v.dest_data_type'length;
    rec_v.mcast := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.mcast'length);
    len_v := len_v + rec_v.mcast'length;
    rec_v.count := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.count'length));
    len_v := len_v + rec_v.count'length;
    rec_v.data := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.data'length);
    len_v := len_v + rec_v.data'length;
    rec_v.repeat := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.source_addr_mode := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.dest_addr_mode := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.stream_process := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.stream_process_id := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-stream_id_t'length));
    len_v := len_v + stream_id_t'length;
    return rec_v;
end function unpack_fifo;

---------
--- Function to pack non-transfer DP instructions (dp_opcode_exec_vm_c|dp_opcode_indication_c) to fifo
---------

function pack_generic_fifo(rec_in : dp_instruction_generic_t) return dp_fifo_record_t is  
variable q_v:dp_fifo_record_t;
variable padding_v:std_logic_vector(dp_fifo_record_t'length-rec_in.opcode'length-rec_in.condition'length-1-rec_in.param'length-rec_in.parameters'length-1 downto 0);
begin
   padding_v := (others=>'0');
   q_v := std_logic_vector(rec_in.opcode) & 
          std_logic_vector(rec_in.condition) &
          rec_in.vm & 
          std_logic_vector(rec_in.param) &
          std_logic_vector(rec_in.parameters) &
          padding_v;
   return q_v;
end function pack_generic_fifo;

-------------
--- Function to unpack non-transfer DP instructions (dp_opcode_exec_vm_c|dp_opcode_indication_c) from fifo
-------------

function unpack_generic_fifo(q_in : dp_fifo_record_t) return dp_instruction_generic_t is  
variable rec_v:dp_instruction_generic_t;
variable len_v:integer;
begin
    len_v := 0;
    rec_v.opcode := unsigned(q_in(dp_fifo_record_t'length-len_v-1 downto dp_fifo_record_t'length-rec_v.opcode'length-len_v));
    len_v := len_v+rec_v.opcode'length;
    rec_v.condition := q_in(dp_fifo_record_t'length-len_v-1 downto dp_fifo_record_t'length-rec_v.condition'length-len_v);
    len_v := len_v+rec_v.condition'length;
    rec_v.vm := q_in(q_in'length-len_v-1);
    len_v := len_v+1;
    rec_v.param := q_in(dp_fifo_record_t'length-len_v-1 downto dp_fifo_record_t'length-rec_v.param'length-len_v);
    len_v := len_v+rec_v.param'length;
    rec_v.parameters := q_in(dp_fifo_record_t'length-len_v-1 downto dp_fifo_record_t'length-rec_v.parameters'length-len_v);
    return rec_v;
end function unpack_generic_fifo;

--------
-- Function to build DP data-transfer (dp_opcode_transfer_c) instruction 
--------

function opcode_exec_decode(bus_writedata_in : std_logic_vector(host_width_c-1 downto 0);
                            src_template_in:dp_template_t;
                            dest_template_in:dp_template_t;
                            datatype_in:dp_data_type_t;
                            source_bus_id_in:dp_bus_id_t;
                            dest_bus_id_in:dp_bus_id_t;
                            mcast_in:std_logic_vector(mcast_t'length-1 downto 0);
                            count_in:unsigned(dp_addr_width_c-1 downto 0);
                            data_in:std_logic_vector(2*data_width_c-1 downto 0);
                            repeat_in:std_logic;
                            vm_in:std_logic
                            ) return dp_instruction_t is
variable rec_v:dp_instruction_t;
variable len_v:integer;
variable condition_v:dp_condition_t; 
begin  
   len_v := 0;
   rec_v.opcode := unsigned(bus_writedata_in(rec_v.opcode'length+len_v-1 downto len_v));
   len_v := len_v+rec_v.opcode'length;
   condition_v := bus_writedata_in(rec_v.condition'length+len_v-1 downto len_v);
   rec_v.condition := condition_v;
   len_v := len_v+rec_v.condition'length;
   rec_v.vm := vm_in;
   len_v := len_v+1;
   rec_v.source := src_template_in;
   rec_v.source_bus_id := source_bus_id_in;
   len_v := len_v+rec_v.source_bus_id'length;
   rec_v.source_data_type := datatype_in;
   len_v := len_v+1;
   rec_v.dest := dest_template_in;
   rec_v.dest_bus_id := dest_bus_id_in;
   len_v := len_v+rec_v.dest_bus_id'length;
   rec_v.dest_data_type := datatype_in;
   len_v := len_v+1;
   rec_v.source_addr_mode := bus_writedata_in(len_v);
   len_v := len_v+1;
   rec_v.dest_addr_mode := bus_writedata_in(len_v);
   len_v := len_v+1;
   rec_v.stream_process := bus_writedata_in(len_v);
   len_v := len_v+1;
   rec_v.stream_process_id := unsigned(bus_writedata_in(stream_id_t'length+len_v-1 downto len_v));
   len_v := len_v+stream_id_t'length;
   rec_v.mcast := mcast_in;
   rec_v.count := count_in;
   rec_v.data := data_in;
   rec_v.repeat := repeat_in;
   return rec_v;
end function opcode_exec_decode;

-------
-- Function to build non-transfer DP instruction ((dp_opcode_exec_vm_c|dp_opcode_indication_c)
-------

function opcode_generic_decode(bus_writedata_in : std_logic_vector(host_width_c-1 downto 0);
                                parameters:std_logic_vector(host_width_c*dp_indication_num_parm_c-1 downto 0);
                                vm_in:std_logic) 
                              return dp_instruction_generic_t is
variable rec_v:dp_instruction_generic_t;
variable len_v:integer;
begin  
   len_v:=0;
   rec_v.opcode := unsigned(bus_writedata_in(rec_v.opcode'length+len_v-1 downto len_v));
   len_v := len_v+rec_v.opcode'length;
   rec_v.condition := bus_writedata_in(rec_v.condition'length+len_v-1 downto len_v);
   len_v := len_v+rec_v.condition'length;
   rec_v.vm := vm_in;
   rec_v.param := bus_writedata_in(rec_v.param'length+len_v-1 downto len_v);
   len_v := len_v+rec_v.param'length;
   rec_v.parameters := parameters;
   return rec_v;
end function opcode_generic_decode;

-------------
-- Signals/Registers declarations
-------------

SIGNAL wregno2: register2_t;
SIGNAL rregno2: register2_t;
SIGNAL src_template_r: dp_template_t:=((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0', (others=>'0'),'0',(others=>'0'),(others=>'1'),(others=>'0'),'0',(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'));
SIGNAL dest_template_r: dp_template_t:=((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0',(others=>'0'),'0',(others=>'0'),(others=>'1'),(others=>'0'),'0',(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'));
SIGNAL template_r:dp_template_t:=((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0',(others=>'0'),'0',(others=>'0'),(others=>'1'),(others=>'0'),'0',(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'));
SIGNAL pause:STD_LOGIC;
SIGNAL pauses:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL task_start_addr: instruction_addr_t;
SIGNAL task_pcore: pcore_t;
SIGNAL task_tid_mask:tid_mask_t;
SIGNAL task_data_model:dp_data_model_t;
SIGNAL task_iregister_auto:iregister_auto_t;
SIGNAL task_lockstep: STD_LOGIC;
SIGNAL task: STD_LOGIC;
SIGNAL task_vm:STD_LOGIC;
SIGNAL task_start_addr_r: instruction_addr_t;
SIGNAL task_pcore_r: pcore_t:=(others=>'1');
SIGNAL task_tid_mask_r:tid_mask_t:=(others=>'1');
SIGNAL task_data_model_r:dp_data_model_t;
SIGNAL task_iregister_auto_r:iregister_auto_t;
SIGNAL task_lockstep_r: STD_LOGIC;
SIGNAL task_r: STD_LOGIC;
SIGNAL task_vm_r:STD_LOGIC;
SIGNAL task_early_transfer_r:STD_LOGIC;
SIGNAL bus_waddr_r:register_addr_t;
SIGNAL bus_raddr_r:register_addr_t;
SIGNAL bus_write_r:STD_LOGIC;
SIGNAL bus_read_r:STD_LOGIC;
SIGNAL bus_writedata_r:STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
SIGNAL rden_r:STD_LOGIC;
SIGNAL avail:std_logic_vector(dp_max_gen_c-1 downto 0);
SIGNAL indication_empty:STD_LOGIC;
begin

indication_avail_out <= not indication_empty;
task_start_addr_out <= task_start_addr_r;
task_pending_out <= task_r;
task2 <= (task_r and task_ready_in and (not pcore_source_busy_r(0)) and (not sink_pcore_busy_r(0))) when task_vm_r='0' 
         else 
         (task_r and task_ready_in and (not pcore_source_busy_r(1)) and (not sink_pcore_busy_r(1)));
task_out <= task2;
task_vm_out <= task_vm_r;
task_pcore_out <= task_pcore_r;
task_lockstep_out <= task_lockstep_r;
task_tid_mask_out <= task_tid_mask_r;
task_iregister_auto_out <= task_iregister_auto_r;
task_data_model_out <= task_data_model_r;

avail <= ready_in and (not instruction_valid_r) and (not instruction_valid_rr);

waitrequest <= '1' when bus_write_in='1' and 
                        (
                        ((full='1' or load='1' or wreq='1') and unsigned(bus_waddr_in(register_t'length-1 downto 0))=to_unsigned(register_dp_run_c,wregno'length))
                        )
                   else '0';
bus_writewait_out <= waitrequest;
bus_readwait_out <= '0';

load <= '1' when bus_write_r='1' and wregno=register_dp_template_c and wregno2=to_unsigned(register2_dp_mode_c,wregno2'length) else '0';

process(log_time_r,log1_valid_in,log1_in,log2_valid_in,log2_in,task_busy_in,pcore_source_busy_r,sram_source_busy_r,ddr_source_busy_r,
        log_status_last_r,print_indication_rr,print_param_rr)
begin

-- Each log entries contain 2 words.
-- There are 3 types of log entries
-- 1) Tranfer entry: Begins of a DP transfer command
--       First word: DP transfer command + transfer information
--       Second word:  [24 bit timestamp][DDR_READ_BUSY][DDR_WRITE_BUSY][SRAM_READ_BUSY][SRAM_WRITE_BUSY][PCORE_READ_BUSY][PCORE_WRITE_BUSY][PCORE_PROC1_EXE_BUSY][PCORE_PROC0_EXE_BUSY]
-- 2) Debug print entry: Display debug string
--       First word: DP print command+pointer to formated string
--       Second word:  Additional parameter to be used with formated string
-- 3) Null entry: Carries status information. Sent whenever there is a change in status
--       First word: NULL command
--       Second word:  [24 bit timestamp][DDR_READ_BUSY][DDR_WRITE_BUSY][SRAM_READ_BUSY][SRAM_WRITE_BUSY][PCORE_READ_BUSY][PCORE_WRITE_BUSY][PCORE_PROC1_EXE_BUSY][PCORE_PROC0_EXE_BUSY]
    
if print_indication_rr='1' then
   -- There is a debug print message. Pointer to the formated string is appended to the command field
   -- Second parameter is additional parameter to the formated string
   log_write(2*host_width_c-1 downto host_width_c) <= print_param_rr(2*host_width_c-1 downto host_width_c);
   log_write(log_type_t'length-1 downto 0) <= log_type_print_c;
   log_write(host_width_c-1 downto log_type_t'length) <= print_param_rr(host_width_c-log_type_t'length-1 downto 0);
   log_wrreq <= '1';
else
   log_write(host_width_c+log_status_vm0_busy_c) <= task_busy_in(0); -- pcore execution status
   log_write(host_width_c+log_status_vm1_busy_c) <= task_busy_in(1);
   log_write(host_width_c+log_status_register_vm0_write_busy_c) <= sink_pcore_busy_r(0);
   log_write(host_width_c+log_status_register_vm0_read_busy_c) <= pcore_source_busy_r(0);
   log_write(host_width_c+log_status_sram_vm0_write_busy_c) <= sink_sram_busy_r(0);
   log_write(host_width_c+log_status_sram_vm0_read_busy_c) <= sram_source_busy_r(0);
   log_write(host_width_c+log_status_register_vm1_write_busy_c) <= sink_pcore_busy_r(1);
   log_write(host_width_c+log_status_register_vm1_read_busy_c) <= pcore_source_busy_r(1);
   log_write(host_width_c+log_status_sram_vm1_write_busy_c) <= sink_sram_busy_r(1);
   log_write(host_width_c+log_status_sram_vm1_read_busy_c) <= sram_source_busy_r(1);
   log_write(host_width_c+log_status_ddr_write_busy_c) <= sink_ddr_busy_r;
   log_write(host_width_c+log_status_ddr_read_busy_c) <= ddr_source_busy_r;
   log_write(2*host_width_c-1 downto host_width_c+log_status_max_c) <= std_logic_vector(log_time_r(log_timestamp_c-1 downto 0));
   if log1_valid_in='1' then
      -- Log entry for DP transfer initiated on first DP process
      log_write(host_width_c-1 downto 0) <= log1_in;
      log_wrreq <= '1';
   elsif log2_valid_in='1' then
      -- Log entry for DP transfer initiated on second DP process
      log_write(host_width_c-1 downto 0) <= log2_in;
      log_wrreq <= '1';
   else
      log_write(host_width_c-1 downto 0) <= (others=>'0');
      log_write(log_type_t'length-1 downto 0) <= log_type_status_c;
      if(log_write(host_width_c+log_status_max_c-1 downto host_width_c) /= log_status_last_r(host_width_c+log_status_max_c-1 downto host_width_c)) then
         -- Log entry about change in status (transfer completion | pcore execution completion)
         log_wrreq <= '1';
      else
         log_wrreq <= '0';
      end if;
   end if;
end if;
end process;


----------
-- FIFO to store log entries
-----------

log_wrreq2 <= log_wrreq and log_enable_r and (not log_full);

--log_fifo_i:scfifo
--	generic map 
--	(
--		DATA_WIDTH=>2*host_width_c,
--		FIFO_DEPTH=>log_depth_c,
--      LOOKAHEAD=>TRUE
--	)
--	port map 
--	(
--		clock_in=>clock_in,
--       reset_in=>reset_in,
--        data_in=>log_write,
--        write_in=>log_wrreq2,
--        read_in=>log_rdreq,
--        q_out=>log_read,
--        ravail_out=>open,
--        wused_out=>open,
--        empty_out=>log_empty,
--        full_out=>log_full,
--        almost_full_out=>open
--	);

log_empty <= '1';
log_full <= '0';
log_read <= (others=>'0');

----------
-- FIFO to store incoming DP instructions from mcore
-----------

rdreq <= '1' when (valid='1') and ((ready='1' and pause='0')) else '0';

fifo_i : dp_fifo
   PORT MAP (
        clock_in=>clock_in,
        reset_in=>reset_in,
        writedata_in=>data,
        wreq_in=>wreq,
        readdata1_out=>q1,
        readdata2_out=>q2,
        rdreq1_in=>rdreqs(0),
        rdreq2_in=>rdreqs(1),
        valid1_out=>valids(0),
        valid2_out=>valids(1),
        full_out=>full,
        fifo_avail_out => fifo_avail
        );

----------
-- MEM block to store template variables
-----------

GEN1: IF (2**dp_template_id_depth_c) <= (min_mem_depth_c/2) GENERATE
ram_i:ramw2
   GENERIC MAP (
        numwords_a=>2**dp_template_id_depth_c,
        numwords_b=>2**dp_template_id_depth_c,
        widthad_a=>dp_template_id_depth_c,
        widthad_b=>dp_template_id_depth_c,
        width_a=>dp_template_width_c,
        width_b=>dp_template_width_c
    )
    PORT MAP(
        address_a=>dp_var_waddress,
        clock=>clock_in,
        clock_x2=>clock_x2_in,
        data_a=>dp_var_write,
        q_b=>dp_var_read,
        wren_a=>dp_var_we,
        address_b=>dp_var_raddress
    );
END GENERATE GEN1;

GEN2: IF (2**dp_template_id_depth_c) > (min_mem_depth_c/2) GENERATE
ram_i:DPRAM
   GENERIC MAP (
        numwords_a=>2**dp_template_id_depth_c,
        numwords_b=>2**dp_template_id_depth_c,
        widthad_a=>dp_template_id_depth_c,
        widthad_b=>dp_template_id_depth_c,
        width_a=>dp_template_width_c,
        width_b=>dp_template_width_c
    )
    PORT MAP(
        address_a=>dp_var_waddress,
        clock=>clock_in,
        data_a=>dp_var_write,
        q_b=>dp_var_read,
        wren_a=>dp_var_we,
        address_b=>dp_var_raddress
    );
END GENERATE GEN2;

dp_var_write <= pack_dp_template(template_r);
dp_var_template <= unpack_dp_template(dp_var_read);
dp_var_waddress <= std_logic_vector(load_busid_r);
dp_var_we <= load_r;
dp_var_raddress <= bus_writedata_in(dp_template_id_t'length-1 downto 0) when (bus_writedata_in(dp_template_id_t'length-1)='1')
                   else
                   (bus_writedata_in(dp_template_id_t'length-2 downto 0) & curr_vm_r);

-------
-- FIFO to store indication messages to be sent out to mcore
-------

in_indication <= std_logic_vector(orec_generic.opcode) & orec_generic.parameters;

indication_i:scfifo
	generic map 
	(
		DATA_WIDTH=>dp_indication_num_parm_c*host_width_c+dp_opcode_t'length,
		FIFO_DEPTH=>dp_indication_depth_c,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
		clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>in_indication,
        write_in=>wreq2_indication,
        read_in=>indication_rdreq,
        q_out=>indication,
        ravail_out=>indication_rdusedw,
        wused_out=>indication_wrusedw,
        empty_out=>indication_empty,
        full_out=>indication_full,
        almost_full_out=>open
	);


pcore_read_pending <= pcore_read_pending_p0_in or pcore_read_pending_p1_in;

sram_read_pending <= sram_read_pending_p0_in or sram_read_pending_p1_in;

ddr_read_pending <= ddr_read_pending_p0_in or ddr_read_pending_p1_in;

bus_readdata_out <= bus_readdata_r;

bus_readdatavalid_out <= rden_r;

wregno <= unsigned(bus_waddr_r(register_t'length-1 downto 0));

wregno2 <= unsigned(bus_waddr_r(register2_t'length+register_t'length-1 downto register_t'length));

rregno <= unsigned(bus_raddr_r(register_t'length-1 downto 0));

rregno2 <= unsigned(bus_raddr_r(register2_t'length+register_t'length-1 downto register_t'length));

match <= '1';

-- Pack instruction to put into FIFO 

data <= pack_fifo(irec) when (irec.opcode=dp_opcode_transfer_c) else pack_generic_fifo(irec_generic);

--------------------
-- Unpack instruction from FIFO
---------------------

orecs(0) <= unpack_fifo(q1);
orecs(1) <= unpack_fifo(q2);
orec_generic <= unpack_generic_fifo(q1);

--------------------
-- Build record to be put into fifo
--------------------

irec <= opcode_exec_decode(bus_writedata_r,src_template_r,dest_template_r,
                           src_template_r.datatype,src_template_r.bus_id,dest_template_r.bus_id,
                           dest_template_r.mcast,dest_template_r.totalcount,
                           src_template_r.data,src_template_r.repeat,curr_vm_r);
irec_generic <= opcode_generic_decode(bus_writedata_r,indication_parm_r,curr_vm_r);

--------------------
-- Condition to push new record to fifo
---------------------


wreq_all <= '1' when bus_write_r='1' and 
                        ((wregno=to_unsigned(register_dp_run_c,wregno'length)))
                        else 
                        '0';

wreq <= (wreq_all and match);

-------------------------------------
-- Which DP engine is ready. Choose between the 2
-- This allows for 2 simultaneous DP running providing they are not conflicting on the bus usage
--------------------------------------

-- Check which DP engine is ready to accept new instructions

ready2(0) <= '1' when valid='1' and avail(0)='1' and (orec.opcode = dp_opcode_transfer_c) else '0';

ready2(1) <= '1' when valid='1' and avail(1)='1' and (orec.opcode = dp_opcode_transfer_c) else '0';

process(valid,avail,ready2,orec,source_bus_id_r,source_vm_r,dest_bus_id_r,instruction_valid_r)
begin
   if valid='1' and (orec.opcode /= dp_opcode_transfer_c) then
      ready <= '1';
      ready_which <= '0';
   elsif ready2(0)='1' and 
      ((orec.source_bus_id /= source_bus_id_r(1) and orec.dest_bus_id/=dest_bus_id_r(1)) or (avail(1)='1')) then
      -- Use first DP if it is ready and the second DP also not using the same source/dest bus
      ready <= ready2(0);
      ready_which <= '0';    
   elsif ready2(1)='1' and 
         ((orec.source_bus_id /= source_bus_id_r(0) and orec.dest_bus_id/=dest_bus_id_r(0)) or (avail(0)='1')) then
      -- Use second DP if it is ready and the first DP also not using the same source/dest bus
      ready <= ready2(1);
      ready_which <= '1';  
   else
      ready <= '0';
      ready_which <= '0';
   end if;
end process;

indication_rdreq <= '1' when bus_read_r='1' and rregno=(register_dp_read_indication_c) and match='1' else '0';

log_rdreq <= '1' when bus_read_r='1' and rregno=(register_dp_read_log_c) and match='1' else '0';

-------------------
-- Latch in incoming register access from mcore
-------------------

process(reset_in,clock_in)
begin
   if reset_in='0' then
      bus_waddr_r <= (others=>'0');
      bus_raddr_r <= (others=>'0');
      bus_write_r <= '0';
      bus_read_r <= '0';
      bus_writedata_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         bus_waddr_r <= bus_waddr_in;
         bus_raddr_r <= bus_raddr_in;
         if waitrequest='0' then
            bus_write_r <= bus_write_in;
         else
            bus_write_r <= '0';
         end if;
         bus_read_r <= bus_read_in;
         bus_writedata_r <= bus_writedata_in;
      end if;
   end if;
end process;

-------------------
-- Process read access from mcore
-------------------

process(reset_in,clock_in)
variable temp_v:std_logic_vector(host_width_c-1 downto 0);
variable temp2_v:std_logic_vector(host_width_c-1 downto 0);
begin
    if reset_in = '0' then
        bus_readdata_r <= (others=>'0');
        rden_r <= '0';
        indication_r <= (others=>'0');
        indication_sync_r <= '0';
        log_readtime_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            temp_v(dp_indication_depth_c-1 downto 0) := indication_rdusedw;
            temp_v(temp_v'length-1 downto dp_indication_depth_c) := (others=>'0');
            temp2_v := indication(host_width_c-1 downto 0);

            if bus_read_r='1' and match='1' then
                if rregno=register_dp_read_indication_c then
                    -- Read indication message id
                    bus_readdata_r <= temp2_v;
                    indication_r <= indication(dp_indication_num_parm_c*host_width_c-1 downto host_width_c);
                    indication_sync_r <= '0'; 
                    rden_r <= '1';
                elsif rregno=register_dp_read_sync_c  then
                    bus_readdata_r(0) <= indication_sync_r;
                    bus_readdata_r(host_width_c-1 downto 1) <= (others=>'0');
                    rden_r <= '1';
                elsif rregno=register_dp_read_indication_parm_c then
                    -- Read indication message parameters
                    bus_readdata_r <= indication_r;
                    rden_r <= '1';
                elsif rregno=register_dp_read_indication_avail_c then
                    -- Read number of indication messages available for retrieval
                    bus_readdata_r <= temp_v;
                    rden_r <= '1';
                elsif rregno=register_dp_instruction_fifo_avail_c then
                    assert false report "Unsupported DP function" severity error;
                    -- Read number of FIFO slots available to accept new DP instructions
                    bus_readdata_r(fifo_avail'length-1 downto 0) <= fifo_avail;
                    bus_readdata_r(bus_readdata_r'length-1 downto fifo_avail'length) <= (others=>'0');
                    rden_r <= '1';
                elsif rregno=register_dp_read_log_c  then
                    if log_empty='0' then
                       bus_readdata_r <= log_read(host_width_c-1 downto 0);
                    else
                       bus_readdata_r <= (others=>'0');
                    end if;
                    log_readtime_r <= log_read(2*host_width_c-1 downto host_width_c);
                    rden_r <= '1';
                elsif rregno=register_dp_read_log_time_c  then
                    bus_readdata_r <= log_readtime_r;
                    rden_r <= '1';
                else
                    bus_readdata_r <= (others=>'0');
                    rden_r <= '0';
                end if;
            else
                rden_r <= '0';
            end if;
        end if;
    end if;
end process;

------------------
-- Process register write access from mcore
-- mcore is trying to setup parameters for a dp instruction
------------------

process(reset_in,clock_in)
variable pos_v:integer;
variable bus_id_v:dp_bus_id_t;
begin
    if reset_in = '0' then
        template_r <= ((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0',(others=>'0'),'0',(others=>'0'),(others=>'1'),(others=>'0'),'0',(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'));
        src_template_r <= ((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0', (others=>'0'),'0',(others=>'0'),(others=>'1'),(others=>'0'),'0',(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'));
        dest_template_r <= ((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0',(others=>'0'),'0',(others=>'0'),(others=>'1'),(others=>'0'),'0',(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'));
        indication_parm_r <= (others=>'0');
        load_r <= '0';
        load_busid_r <= (others=>'0');
        curr_vm_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            if load_r='1' then
                -- Must not have a write access immediately followed register2_dp_mode_c
                if load_busid_r=to_unsigned(dp_template_id_src_c,dp_template_id_t'length) then
                   src_template_r <= template_r;
                elsif load_busid_r=to_unsigned(dp_template_id_dest_c,dp_template_id_t'length) then
                   dest_template_r <= template_r;
                end if;
                template_r <= ((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),'0',(others=>'0'),'0',(others=>'0'),(others=>'1'),(others=>'0'),'0',(others=>'0'),(others=>'0'),(others=>'1'),(others=>'0'));
            end if;
            if bus_write_r='1' then
                if wregno=register_dp_template_c then
                    -- Set source address information for subsequent dp_opcode_transfer_c instruction.
                    if wregno2=to_unsigned(register2_dp_stride0_c,wregno2'length) then
                        template_r.stride0 <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride0_count_c,wregno2'length) then
                        template_r.stride0_count <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride0_max_c,wregno2'length) then
                        template_r.stride0_max <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride1_c,wregno2'length) then
                        template_r.stride1 <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride1_count_c,wregno2'length) then
                        template_r.stride1_count <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride1_max_c,wregno2'length) then
                        template_r.stride1_max <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride2_c,wregno2'length) then
                        template_r.stride2 <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride2_count_c,wregno2'length) then
                        template_r.stride2_count <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride2_max_c,wregno2'length) then
                        template_r.stride2_max <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride3_c,wregno2'length) then
                        template_r.stride3 <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride3_count_c,wregno2'length) then
                        template_r.stride3_count <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride3_max_c,wregno2'length) then
                        template_r.stride3_max <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride4_c,wregno2'length) then
                        template_r.stride4 <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride4_count_c,wregno2'length) then
                        template_r.stride4_count <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride4_max_c,wregno2'length) then
                        template_r.stride4_max <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_burst_max_c,wregno2'length) then
                        template_r.burst_max <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                        template_r.burst_max2 <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                        template_r.burst_max_init <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_burst_max2_c,wregno2'length) then
                        template_r.burst_max2 <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_burst_max_init_c,wregno2'length) then
                        template_r.burst_max_init <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_burst_max_index_c,wregno2'length) then
                        template_r.burst_max_index <= unsigned(bus_writedata_r(template_r.burst_max_index'length-1 downto 0));                        
                    end if;
                    if wregno2=to_unsigned(register2_dp_bar_c,wregno2'length) then
                        if load_r='1' then
                            template_r.bar <= unsigned(bus_writedata_r(dp_full_addr_width_c-1 downto 0));
                        else
                            template_r.bar <= template_r.bar+unsigned(bus_writedata_r(dp_full_addr_width_c-1 downto 0));
                        end if;
                    end if;
                    if wregno2=to_unsigned(register2_dp_bufsize_c,wregno2'length) then
                        template_r.bufsize <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_burst_max_len_c,wregno2'length) then
                        template_r.burst_max_len <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_count_c,wregno2'length) then
                        template_r.count <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_burst_stride_c,wregno2'length) then
                        template_r.burstStride <= unsigned(bus_writedata_r(dp_addr_width_c-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_mode_c,wregno2'length) then
                        if bus_writedata_r(0)='1' then
                           pos_v := dp_template_id_t'length+1;
                           template_r.double_precision <= bus_writedata_r(pos_v);
                           pos_v := pos_v+1;
                           template_r.datatype <= unsigned(bus_writedata_r(pos_v+template_r.datatype'length-1 downto pos_v));
                           pos_v := pos_v+dp_data_type_t'length;
                           template_r.data_model <= bus_writedata_r(pos_v+template_r.data_model'length-1 downto pos_v);
                           pos_v := pos_v+dp_data_model_t'length;
                           template_r.scatter <= bus_writedata_r(pos_v);
                           pos_v := pos_v+1;
                           bus_id_v := unsigned(bus_writedata_r(pos_v+dp_bus_id_t'length-1 downto pos_v));
                           template_r.bus_id <= bus_id_v;
                           if bus_id_v=dp_bus_id_sram_c then
                              template_r.bar(sram_depth_c-1) <= curr_vm_r;
                           elsif bus_id_v=dp_bus_id_register_c then
                              template_r.bar(13 + register_depth_c) <= curr_vm_r;
                           end if;      
                           pos_v := pos_v+dp_bus_id_t'length;
                           template_r.repeat <= bus_writedata_r(pos_v);
                           pos_v := pos_v+1;
                           template_r.mcast <= bus_writedata_r(pos_v+template_r.mcast'length-1 downto pos_v);
                           pos_v := pos_v+template_r.mcast'length;
                        end if;
                        if (bus_writedata_r(dp_template_id_t'length)='1') then
                           load_busid_r <= unsigned(bus_writedata_r(dp_template_id_t'length downto 1));
                        else
                           load_busid_r(dp_template_id_t'length-1 downto 1) <= unsigned(bus_writedata_r(dp_template_id_t'length-1 downto 1));
                           load_busid_r(0) <= curr_vm_r;
                        end if;
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride0_min_c,wregno2'length) then
                        template_r.stride0_min <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride1_min_c,wregno2'length) then
                        template_r.stride1_min <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride2_min_c,wregno2'length) then
                        template_r.stride2_min <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride3_min_c,wregno2'length) then
                        template_r.stride3_min <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_stride4_min_c,wregno2'length) then
                        template_r.stride4_min <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_burst_min_c,wregno2'length) then
                        template_r.burst_min <= unsigned(bus_writedata_r(dp_addr_width_c downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_totalcount_c,wregno2'length) then
                        -- Set number of words to be transfered with subsequent dp_opcode_transfer_c instruction
                        template_r.totalcount <= unsigned(bus_writedata_r(template_r.totalcount'length-1 downto 0));
                    end if;
                    if wregno2=to_unsigned(register2_dp_data_c,wregno2'length) then
                        -- Set constant value used in case a transfer is running out of source address.
                        template_r.data <= bus_writedata_r(template_r.data'length-1 downto 0);
                    end if;
                elsif wregno=register_dp_restore_c then
                    template_r <= dp_var_template;
                end if;
                if wregno=register_dp_indication_parm0_c then
                    -- Set first parameter of a subsequent dp_opcode_indication_c instruction
                    indication_parm_r(host_width_c-1 downto 0) <= bus_writedata_r;
                end if;
                if wregno=register_dp_indication_parm1_c then
                    -- Set second parameter of a subsequent dp_opcode_indication_c instruction
                    indication_parm_r(2*host_width_c-1 downto host_width_c) <= bus_writedata_r;
                end if;
                if wregno=register_vm_toggle_c then
                    curr_vm_r <= not curr_vm_r;
                end if;
            end if;
            if load='1' then
                load_r <= '1';
            else
                load_r <= '0';
            end if;
        end if;
    end if;
end process;


process(clock_in,reset_in)
variable source_is_safe_v:safe_mask_t;
variable dest_is_safe_v:safe_mask_t;
begin
if reset_in = '0' then
   new_cmd_is_safe_r <= (others=>(others=>'0'));
else
   if clock_in'event and clock_in='1' then

      -- Determine is a bus is safe to issue a new read request
      -- If read is being targeted to a new destination from previous read, then all read transactions 
      -- must be completed first

      source_is_safe_v(dp_bus_id_register_c)(dp_bus_id_register_c) := (not sram_read_pending(dp_bus_id_register_c)) and (not ddr_read_pending(dp_bus_id_register_c));
      source_is_safe_v(dp_bus_id_register_c)(dp_bus_id_sram_c) := (not pcore_read_pending(dp_bus_id_register_c)) and (not ddr_read_pending(dp_bus_id_register_c));
      source_is_safe_v(dp_bus_id_register_c)(dp_bus_id_ddr_c) := (not pcore_read_pending(dp_bus_id_register_c)) and (not sram_read_pending(dp_bus_id_register_c));

      source_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_register_c) := (not sram_read_pending(dp_bus_id_sram_c)) and (not ddr_read_pending(dp_bus_id_sram_c));
      source_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_sram_c) := (not pcore_read_pending(dp_bus_id_sram_c)) and (not ddr_read_pending(dp_bus_id_sram_c));
      source_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_ddr_c) := (not pcore_read_pending(dp_bus_id_sram_c)) and (not sram_read_pending(dp_bus_id_sram_c));

      source_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_register_c) := (not sram_read_pending(dp_bus_id_ddr_c)) and (not ddr_read_pending(dp_bus_id_ddr_c));
      source_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_sram_c) := (not pcore_read_pending(dp_bus_id_ddr_c)) and (not ddr_read_pending(dp_bus_id_ddr_c));
      source_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_ddr_c) := (not pcore_read_pending(dp_bus_id_ddr_c)) and (not sram_read_pending(dp_bus_id_ddr_c));

      -- Avoid data arrived at sinker out of order.
      -- If sinker receives data from multiple sources, they may have different latency.
      -- Check is we change source to a sinker, make sure all pending read have been completed...

      dest_is_safe_v(dp_bus_id_register_c)(dp_bus_id_register_c) := (not pcore_read_pending(dp_bus_id_sram_c)) and (not pcore_read_pending(dp_bus_id_ddr_c));
      dest_is_safe_v(dp_bus_id_register_c)(dp_bus_id_sram_c) := (not pcore_read_pending(dp_bus_id_register_c)) and (not pcore_read_pending(dp_bus_id_ddr_c));
      dest_is_safe_v(dp_bus_id_register_c)(dp_bus_id_ddr_c) := (not pcore_read_pending(dp_bus_id_register_c)) and (not pcore_read_pending(dp_bus_id_sram_c));

      dest_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_register_c) := (not sram_read_pending(dp_bus_id_sram_c)) and (not sram_read_pending(dp_bus_id_ddr_c));
      dest_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_sram_c) := (not sram_read_pending(dp_bus_id_register_c)) and (not sram_read_pending(dp_bus_id_ddr_c));
      dest_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_ddr_c) := (not sram_read_pending(dp_bus_id_register_c)) and (not sram_read_pending(dp_bus_id_sram_c));

      dest_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_register_c) := (not ddr_read_pending(dp_bus_id_sram_c)) and (not ddr_read_pending(dp_bus_id_ddr_c));
      dest_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_sram_c) := (not ddr_read_pending(dp_bus_id_register_c)) and (not ddr_read_pending(dp_bus_id_ddr_c));
      dest_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_ddr_c) := (not ddr_read_pending(dp_bus_id_register_c)) and (not ddr_read_pending(dp_bus_id_sram_c));

      -- New DP transaction is safe when it is safe for both source and destination
      new_cmd_is_safe_r(dp_bus_id_register_c)(dp_bus_id_register_c) <= source_is_safe_v(dp_bus_id_register_c)(dp_bus_id_register_c) and dest_is_safe_v(dp_bus_id_register_c)(dp_bus_id_register_c);
      new_cmd_is_safe_r(dp_bus_id_register_c)(dp_bus_id_sram_c) <= source_is_safe_v(dp_bus_id_register_c)(dp_bus_id_sram_c) and dest_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_register_c);
      new_cmd_is_safe_r(dp_bus_id_register_c)(dp_bus_id_ddr_c) <= source_is_safe_v(dp_bus_id_register_c)(dp_bus_id_ddr_c) and dest_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_register_c);
      new_cmd_is_safe_r(dp_bus_id_sram_c)(dp_bus_id_register_c) <= source_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_register_c) and dest_is_safe_v(dp_bus_id_register_c)(dp_bus_id_sram_c);
      new_cmd_is_safe_r(dp_bus_id_sram_c)(dp_bus_id_sram_c) <= source_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_sram_c) and dest_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_sram_c);
      new_cmd_is_safe_r(dp_bus_id_sram_c)(dp_bus_id_ddr_c) <= source_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_ddr_c) and dest_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_sram_c);
      new_cmd_is_safe_r(dp_bus_id_ddr_c)(dp_bus_id_register_c) <= source_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_register_c) and dest_is_safe_v(dp_bus_id_register_c)(dp_bus_id_ddr_c);
      new_cmd_is_safe_r(dp_bus_id_ddr_c)(dp_bus_id_sram_c) <= source_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_sram_c) and dest_is_safe_v(dp_bus_id_sram_c)(dp_bus_id_ddr_c);
      new_cmd_is_safe_r(dp_bus_id_ddr_c)(dp_bus_id_ddr_c) <= source_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_ddr_c) and dest_is_safe_v(dp_bus_id_ddr_c)(dp_bus_id_ddr_c);
   end if;
end if;
end process;

outOfOrderOk <= '1' when
      (orecs(1).opcode = dp_opcode_transfer_c) and 
      (orecs(0).opcode = dp_opcode_transfer_c) and 
      (orecs(1).condition = std_logic_vector(to_unsigned(0,dp_condition_t'length))) and
      (
      (orecs(0).vm /= orecs(1).vm) or
      (
      (orecs(0).condition(dp_condition_register_flush_c)='0' or (orecs(1).dest_bus_id /=dp_bus_id_register_c and orecs(1).source_bus_id /=dp_bus_id_register_c)) and
      (orecs(0).condition(dp_condition_sram_flush_c)='0' or (orecs(1).dest_bus_id /=dp_bus_id_sram_c and orecs(1).source_bus_id /=dp_bus_id_sram_c)) and
      (orecs(0).condition(dp_condition_ddr_flush_c)='0' or (orecs(1).dest_bus_id /=dp_bus_id_ddr_c and orecs(1).source_bus_id /=dp_bus_id_ddr_c))
      )
      )
      else '0';

process(valids,pauses,orecs,rdreq)
variable pause_v:std_logic;
begin
   if pauses(0)='0' then
      -- Always prefer current instruction
      orec <= orecs(0);
      valid <= valids(0);
      rdreqs(0) <= rdreq;
      rdreqs(1) <= '0';
      pause <= pauses(0);
   elsif pauses(1)='0' and outOfOrderOk='1' then
      -- Can execute out of order
      orec <= orecs(1);
      valid <= valids(1);
      rdreqs(0) <= '0';
      rdreqs(1) <= rdreq;
      pause <= pauses(1);
   else
      orec <= orecs(0);
      valid <= valids(0);
      rdreqs(0) <= rdreq;
      rdreqs(1) <= '0';
      pause <= pauses(0);
   end if;
end process;


-------------
-- Check for condition that data plane operation is being paused.
-------------

process(valids,orecs,task_busy_in,indication_full_r,pcore_read_pending,sram_read_pending,ddr_read_pending,
       sink_pcore_busy_r,sink_sram_busy_r,sink_ddr_busy_r,task_ready_in,task_r,task_early_transfer_r,task_vm_r,
       pcore_source_busy_r,sram_source_busy_r,ddr_source_busy_r,
       new_cmd_is_safe_r)
variable pause_v:std_logic;
begin
FOR I in 0 to 1 loop
if valids(I)='1' then
    if indication_full_r='1' then
       pauses(I) <= '1';
    elsif (orecs(I).opcode /= dp_opcode_transfer_c) and (orecs(I).condition and (condition_vm0_busy_r or condition_vm1_busy_r)) /= std_logic_vector(to_unsigned(0,dp_condition_t'length)) then
        -- Wait for all transfers to register space to be flushed
        pauses(I) <= '1';
    elsif (orecs(I).opcode = dp_opcode_transfer_c) and (orecs(I).vm='0') and (orecs(I).condition and condition_vm0_busy_r) /= std_logic_vector(to_unsigned(0,dp_condition_t'length)) then
        pauses(I) <= '1';
    elsif (orecs(I).opcode = dp_opcode_transfer_c) and (orecs(I).vm='1') and (orecs(I).condition and condition_vm1_busy_r) /= std_logic_vector(to_unsigned(0,dp_condition_t'length)) then
        pauses(I) <= '1';
	elsif orecs(I).opcode=dp_opcode_exec_vm_c and orecs(I).vm='0' then
        -- To proceed with kernel execution, make sure all read access to PCORE are completed.
        -- Task lauch is further delayed when there is outstanding write request to PCORE (indicated by sink_pcore_busy_r) 
        if task_r='1' then
           pauses(I) <= '1';
        else
           pauses(I) <= '0';
        end if;
    elsif orecs(I).opcode=dp_opcode_exec_vm_c and orecs(I).vm='1' then
        -- To proceed with kernel execution, make sure all read access to PCORE are completed.
        -- Task lauch is further delayed when there is outstanding write request to PCORE (indicated by sink_pcore_busy_r) 
        if task_r='1' then
           pauses(I) <= '1';
        else
           pauses(I) <= '0';
        end if;
    elsif orecs(I).opcode = dp_opcode_transfer_c then
         if task_r='1' and 
               (
               (orecs(I).source_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and orecs(I).vm=task_vm_r) or
               (orecs(I).dest_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and orecs(I).vm=task_vm_r)  
               ) then
               -- An task execution is pending on a process. Block any transfer to/from to PCORE memory space of this process
               -- If task execution is already spanwed, then all transfer to/from the PCORE memory space for this process running the execution
               -- will be blocked so it is safe to start the transfer.
            pauses(I) <= '1';	  
         else
            pauses(I) <= not new_cmd_is_safe_r(to_integer(orecs(I).source_bus_id))(to_integer(orecs(I).dest_bus_id));
         end if;
    else
        pauses(I) <= '0';
    end if;
else
    pauses(I) <= '1';
end if;
end loop;
end process;

------------
-- Latch in new indication message to be sent to mcore....
------------

process(valid,orec,pause,ready)
begin
if ready='1' and 
    orec.opcode=to_unsigned(dp_opcode_indication_c,orec.opcode'length) and
    pause='0' then
    wreq2_indication <= '1';
else
    wreq2_indication <= '0';
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in = '0' then
   print_indication_r <= '0';
   print_indication_rr <= '0';  
   print_param_r <= (others=>'0');
   print_param_rr <= (others=>'0');
else
   if clock_in'event and clock_in='1' then
      print_param_r <= orec_generic.parameters(print_param_r'length-1 downto 0);
      print_param_rr <= print_param_r;
      print_indication_rr <= print_indication_r;
      if ready='1' and orec.opcode=to_unsigned(dp_opcode_print_c,orec.opcode'length) and pause='0' then
         print_indication_r <= '1';
      else
         print_indication_r <= '0';
      end if;
   end if;
end if;
end process;

-----------
-- Generate task launch request
-----------

process(valid,orec,orec_generic,pause,ready)
variable offset_v:integer;
begin
if ready='1' and 
    (orec.opcode=to_unsigned(dp_opcode_exec_vm_c,orec.opcode'length)) and (orec.vm='0') and 
    pause='0' then
    task <=  '1';
    task_vm <= '0';
    offset_v := 0;
    task_start_addr <= orec_generic.param(offset_v+task_start_addr'length-1 downto offset_v);
    offset_v := offset_v+task_start_addr'length;
    task_pcore <= unsigned(orec_generic.param(offset_v+task_pcore'length-1 downto offset_v));
    offset_v := offset_v+task_pcore'length;
    task_lockstep <= orec_generic.param(offset_v);
    offset_v := offset_v+1;
    task_iregister_auto(task_iregister_auto'length-1 downto task_iregister_auto'length-max_iregister_auto_c) <= unsigned(orec_generic.param(offset_v+max_iregister_auto_c-1 downto offset_v));
    offset_v := offset_v+max_iregister_auto_c;
    task_tid_mask <= orec_generic.param(offset_v+task_tid_mask'length-1 downto offset_v);
    offset_v := offset_v+task_tid_mask'length;
    task_data_model <= orec_generic.param(offset_v+task_data_model'length-1 downto offset_v);
    offset_v := offset_v+task_data_model'length;
    FOR I in 0 to max_iregister_auto_c-1 loop
        task_iregister_auto((I+1)*iregister_width_c-1 downto I*iregister_width_c) <= unsigned(orec_generic.parameters(iregister_width_c+I*host_width_c-1 downto I*host_width_c));
    end loop;
    assert max_iregister_auto_c <= dp_indication_num_parm_c report "Too many iregister_auto" severity note;
elsif ready='1' and 
    (orec.opcode=to_unsigned(dp_opcode_exec_vm_c,orec.opcode'length)) and (orec.vm='1') and 
    pause='0' then
    task <=  '1';
    task_vm <= '1';
    offset_v := 0;
    task_start_addr <= orec_generic.param(offset_v+task_start_addr'length-1 downto offset_v);
    offset_v := offset_v+task_start_addr'length;
    task_pcore <= unsigned(orec_generic.param(offset_v+task_pcore'length-1 downto offset_v));
    offset_v := offset_v+task_pcore'length;
    task_lockstep <= orec_generic.param(offset_v);
    offset_v := offset_v+1;
    task_iregister_auto(task_iregister_auto'length-1 downto task_iregister_auto'length-max_iregister_auto_c) <= unsigned(orec_generic.param(offset_v+max_iregister_auto_c-1 downto offset_v));
    offset_v := offset_v+max_iregister_auto_c;
    task_tid_mask <= orec_generic.param(offset_v+task_tid_mask'length-1 downto offset_v);
    offset_v := offset_v+task_tid_mask'length;
    task_data_model <= orec_generic.param(offset_v+task_data_model'length-1 downto offset_v);
    offset_v := offset_v+task_data_model'length;
    FOR I in 0 to max_iregister_auto_c-1 loop
       task_iregister_auto((I+1)*iregister_width_c-1 downto I*iregister_width_c) <= unsigned(orec_generic.parameters(iregister_width_c+I*host_width_c-1 downto I*host_width_c));
    end loop;
    assert max_iregister_auto_c <= dp_indication_num_parm_c report "Too many iregister_auto" severity note;
else
    task <= '0';
    task_vm <= '0';
    task_start_addr <= (others=>'0');
    task_pcore <= (others=>'1');
    task_lockstep <= '0';
    task_tid_mask <= (others=>'1');
    task_data_model <= (others=>'0');
    task_iregister_auto <= (others=>'0');
end if;
end process;


----------
-- Latch dp_opcode_transfer_c command from primary fifo to appropriate secondary fifo
-- There is a secondary fifo for every bus
----------

process(valid,orec,pause,ready)
begin
if ready='1' then
   if orec.opcode = dp_opcode_transfer_c then
      wreq2 <= not pause;
   else
      wreq2 <= '0';
   end if;
else
   wreq2 <= '0';
end if;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       log_enable_r <= '0';
    else
        if clock_in'event and clock_in='1' then
           if ready='1' and pause='0' then
              if orec.opcode = dp_opcode_log_on_c then
                 log_enable_r <= '1';
              elsif orec.opcode = dp_opcode_log_off_c then
                 log_enable_r <= '0';
              end if;
           end if;
        end if;
    end if;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        task_r <= '0';
        task_vm_r <= '0';
        task_early_transfer_r <= '0';
        task_start_addr_r <= (others=>'0');
        task_pcore_r <= (others=>'1');
        task_lockstep_r <= '0';
        task_tid_mask_r <= (others=>'1');
        task_data_model_r <= (others=>'0');
        task_iregister_auto_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            if task_r='0' then
                task_r <= task;
                task_vm_r <= task_vm;
                task_early_transfer_r <= '0';
                task_start_addr_r <= task_start_addr;
                task_pcore_r <= task_pcore;
                task_lockstep_r <= task_lockstep;
                task_tid_mask_r <= task_tid_mask;
                task_data_model_r <= task_data_model;
                task_iregister_auto_r <= task_iregister_auto;
            elsif task2='1' then
                task_r <= '0';
            else
                task_early_transfer_r <= wreq2;
            end if;
        end if;
    end if;
end process;

instruction <= orec;
instruction_valid_out <= instruction_valid_rr;
instruction_out <= instruction_rr;
pre_instruction_out <= instruction_r;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       instruction_valid_r <= (others=>'0');
       instruction_valid_rr <= (others=>'0');
       source_bus_id_r <= (others=>(others=>'0'));
       source_vm_r <= (others=>'0');
       dest_bus_id_r <= (others=>(others=>'0'));
    else
        if clock_in'event and clock_in='1' then
           if wreq2='0' then
              instruction_valid_r <= (others=>'0');
           else
              if ready_which='0' then
                 instruction_valid_r(0) <= wreq2;
                 instruction_valid_r(1) <= '0';
                 source_bus_id_r(0) <= instruction.source_bus_id;
                 source_vm_r(0) <= instruction.vm;
                 dest_bus_id_r(0) <= instruction.dest_bus_id;
              else
                 instruction_valid_r(0) <= '0';
                 instruction_valid_r(1) <= wreq2;
                 source_bus_id_r(1) <= instruction.source_bus_id;
                 source_vm_r(1) <= instruction.vm;
                 dest_bus_id_r(1) <= instruction.dest_bus_id;
              end if;
           end if;
           instruction_valid_rr <= instruction_valid_r;
           instruction_rr <= instruction_r;
           instruction_r <= instruction;
        end if;
    end if;
end process;

---------------
-- Fetch instructions from primary FIFO to secondary FIFO 
-- if next stage is ready
-------------

process(reset_in,clock_in)
variable count_v:unsigned(dp_addr_width_c-1 downto 0);
variable sink_pcore_busy_v:STD_LOGIC_VECTOR(1 DOWNTO 0);
variable sink_sram_busy_v:STD_LOGIC_VECTOR(1 DOWNTO 0);
variable sink_ddr_busy_v:STD_LOGIC;
variable pcore_source_busy_v:STD_LOGIC_VECTOR(1 downto 0);
variable sram_source_busy_v:STD_LOGIC_VECTOR(1 downto 0);
variable ddr_source_busy_v:STD_LOGIC;
begin
   if reset_in = '0' then
      pcore_sink_counter_r <= (others=>(others=>'0'));
      sram_sink_counter_r <= (others=>(others=>'0'));
      ddr_sink_counter_r <= (others=>'0');
      sink_pcore_busy_r <= (others=>'0');
      sink_sram_busy_r <= (others=>'0');
      sink_ddr_busy_r <= '0';
      indication_full_r <= '0';
      pcore_source_busy_r <= (others=>'0');
      sram_source_busy_r <= (others=>'0');
      ddr_source_busy_r <= '0';
      condition_vm0_busy_r <= (others=>'0');
      condition_vm1_busy_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then

         -- Check if indication fifo is almost full
         if(unsigned(indication_wrusedw) >= to_unsigned(dp_indication_max_c-8,dp_indication_depth_c)) then
            indication_full_r <= '1';
         else
            indication_full_r <= '0';
         end if; 

         -- Update total number of sink bytes from issues DP transactions
         if instruction_valid_r /= "00" then
            count_v := instruction_r.count;
            if instruction_r.dest.double_precision='1' and instruction_r.dest_bus_id /=dp_bus_id_register_c then
               count_v := count_v sll 1;
            end if;
            if instruction_r.dest_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) then
               if instruction_r.vm='0' then
                  pcore_sink_counter_r(0) <= pcore_sink_counter_r(0)+count_v;
               else
                  pcore_sink_counter_r(1) <= pcore_sink_counter_r(1)+count_v;
               end if;
               elsif instruction_r.dest_bus_id=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) then
                  if instruction_r.vm='0' then
                     sram_sink_counter_r(0) <= sram_sink_counter_r(0)+count_v;
                  else
                     sram_sink_counter_r(1) <= sram_sink_counter_r(1)+count_v;
                  end if;
               else
                  ddr_sink_counter_r <= ddr_sink_counter_r+count_v;
               end if;
            end if;

            -- Mark that there is a pending write transaction to PCORE's process 0 memory space
            if wreq2 /= '0' and 
               orec.dest_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and orec.vm='0' then
               sink_pcore_busy_v(0) := '1';
            elsif instruction_valid_r /= "00" and 
                  instruction_r.dest_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and
                  instruction_r.vm='0' then
               sink_pcore_busy_v(0) := '1';
            elsif pcore_sink_counter_r(0)=pcore_sink_counter_in(0) then
               sink_pcore_busy_v(0) := '0';
            else
               sink_pcore_busy_v(0) := '1';
            end if;

            -- Mark that there is a pending write transaction to PCORE's process 1 memory space

            if wreq2 /= '0' and orec.dest_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and orec.vm='1' then
               sink_pcore_busy_v(1) := '1';
            elsif instruction_valid_r /= "00" and 
               instruction_r.dest_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and
               instruction_r.vm='1' then
               sink_pcore_busy_v(1) := '1';
            elsif pcore_sink_counter_r(1)=pcore_sink_counter_in(1) then
               sink_pcore_busy_v(1) := '0';
            else
               sink_pcore_busy_v(1) := '1';
            end if;

            -- Mark that there is a pending write transaction to SRAM memory space

            if wreq2 /= '0' and orec.dest_bus_id=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and orec.vm='0' then
               sink_sram_busy_v(0) := '1';
            elsif instruction_valid_r /= "00" and instruction_r.dest_bus_id=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and orec.vm='0' then
               sink_sram_busy_v(0) := '1';
            elsif sram_sink_counter_r(0)=sram_sink_counter_in(0) then
               sink_sram_busy_v(0) := '0';
            else
               sink_sram_busy_v(0) := '1';
            end if;

            if wreq2 /= '0' and orec.dest_bus_id=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and orec.vm='1' then
               sink_sram_busy_v(1) := '1';
            elsif instruction_valid_r /= "00" and instruction_r.dest_bus_id=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and orec.vm='1' then
               sink_sram_busy_v(1) := '1';
            elsif sram_sink_counter_r(1)=sram_sink_counter_in(1) then
               sink_sram_busy_v(1) := '0';
            else
               sink_sram_busy_v(1) := '1';
            end if;

            -- Mark that there is a pending write transaction to DDR memory space
			
            if wreq2 /= '0' and orec.dest_bus_id=to_unsigned(dp_bus_id_ddr_c,dp_bus_id_t'length) then
               sink_ddr_busy_v := '1';
            elsif instruction_valid_r /= "00" and instruction_r.dest_bus_id=to_unsigned(dp_bus_id_ddr_c,dp_bus_id_t'length) then
               sink_ddr_busy_v := '1';
            elsif ddr_sink_counter_r=ddr_sink_counter_in and ddr_tx_busy_in='0' then
               sink_ddr_busy_v := '0';
            else
               sink_ddr_busy_v := '1';
            end if;


            -- Check if the source is busy
            -- Its busy if there is no current request involving this source and all outstanding read requests have been
            -- completed.

            -- Check if there is no pending PCORE space read 
            if (source_bus_id_r(0)=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and source_vm_r(0)='0' and (avail(0)='0')) or
               (source_bus_id_r(1)=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and source_vm_r(1)='0' and (avail(1)='0')) or
               (pcore_read_pending_p0_in(dp_bus_id_register_c)='1') or
               (sram_read_pending_p0_in(dp_bus_id_register_c)='1') or
               (ddr_read_pending(dp_bus_id_register_c)='1') then
               pcore_source_busy_v(0) := '1';
            else
               pcore_source_busy_v(0) := '0';
            end if;

            if (source_bus_id_r(0)=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and source_vm_r(0)='1' and (avail(0)='0')) or
               (source_bus_id_r(1)=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and source_vm_r(1)='1' and (avail(1)='0')) or
               (pcore_read_pending_p1_in(dp_bus_id_register_c)='1') or
               (sram_read_pending_p1_in(dp_bus_id_register_c)='1') or
               (ddr_read_pending(dp_bus_id_register_c)='1') then
               pcore_source_busy_v(1) := '1';
            else
               pcore_source_busy_v(1) := '0';
            end if;

            -- Check if there is no pending SRAM space read 

            if (source_bus_id_r(0)=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and source_vm_r(0)='0' and (avail(0)='0')) or
               (source_bus_id_r(1)=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and source_vm_r(1)='0' and (avail(1)='0')) or
               (pcore_read_pending_p0_in(dp_bus_id_sram_c)='1') or
               (sram_read_pending_p0_in(dp_bus_id_sram_c)='1') or
               (ddr_read_pending(dp_bus_id_sram_c)='1') then
               sram_source_busy_v(0) := '1';
            else
               sram_source_busy_v(0) := '0';
            end if;

            if (source_bus_id_r(0)=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and source_vm_r(0)='1' and (avail(0)='0')) or
               (source_bus_id_r(1)=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and source_vm_r(1)='1' and (avail(1)='0')) or
               (pcore_read_pending_p1_in(dp_bus_id_sram_c)='1') or
               (sram_read_pending_p1_in(dp_bus_id_sram_c)='1') or
               (ddr_read_pending(dp_bus_id_sram_c)='1') then
               sram_source_busy_v(1) := '1';
            else
               sram_source_busy_v(1) := '0';
            end if;

            -- Check if there is no pending DDR space read 

            if (source_bus_id_r(0)=to_unsigned(dp_bus_id_ddr_c,dp_bus_id_t'length) and (avail(0)='0')) or
               (source_bus_id_r(1)=to_unsigned(dp_bus_id_ddr_c,dp_bus_id_t'length) and (avail(1)='0')) or
               (pcore_read_pending(dp_bus_id_ddr_c)='1') or
               (sram_read_pending(dp_bus_id_ddr_c)='1') or
               (ddr_read_pending(dp_bus_id_ddr_c)='1') then
               ddr_source_busy_v := '1';
            else
               ddr_source_busy_v := '0';
            end if;

            -- As soon as DP transaction is issued, marked the source as busy

            if wreq2 /= '0' and orec.source_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and
               orec.vm='0' then
               pcore_source_busy_v(0) := '1';
            end if;
            if wreq2 /= '0' and orec.source_bus_id=to_unsigned(dp_bus_id_register_c,dp_bus_id_t'length) and
               orec.vm='1' then
               pcore_source_busy_v(1) := '1';
            end if;

            if wreq2 /= '0' and orec.source_bus_id=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and orec.vm='0' then
               sram_source_busy_v(0) := '1';
            end if;

            if wreq2 /= '0' and orec.source_bus_id=to_unsigned(dp_bus_id_sram_c,dp_bus_id_t'length) and orec.vm='1' then
               sram_source_busy_v(1) := '1';
            end if;

            if wreq2 /= '0' and orec.source_bus_id=to_unsigned(dp_bus_id_ddr_c,dp_bus_id_t'length) then
               ddr_source_busy_v := '1';
            end if;

            -- Update condition clear flag

            condition_vm0_busy_r(dp_condition_register_flush_c) <= pcore_source_busy_v(0) or sink_pcore_busy_v(0);
            condition_vm0_busy_r(dp_condition_sram_flush_c) <= sram_source_busy_v(0) or sink_sram_busy_v(0);
            condition_vm0_busy_r(dp_condition_ddr_flush_c) <= ddr_source_busy_v or sink_ddr_busy_v;

            condition_vm1_busy_r(dp_condition_register_flush_c) <= pcore_source_busy_v(1) or sink_pcore_busy_v(1);
            condition_vm1_busy_r(dp_condition_sram_flush_c) <= sram_source_busy_v(1) or sink_sram_busy_v(1);
            condition_vm1_busy_r(dp_condition_ddr_flush_c) <= ddr_source_busy_v or sink_ddr_busy_v;

            sink_pcore_busy_r(0) <= sink_pcore_busy_v(0);
            sink_pcore_busy_r(1) <= sink_pcore_busy_v(1);
            sink_sram_busy_r <= sink_sram_busy_v;
            sink_ddr_busy_r <= sink_ddr_busy_v;
            pcore_source_busy_r <= pcore_source_busy_v;
            sram_source_busy_r <= sram_source_busy_v;
            ddr_source_busy_r <= ddr_source_busy_v;
        end if;
    end if;
end process;
           
-- Register log entries 

process(reset_in,clock_in)
variable count_v:unsigned(dp_addr_width_c-1 downto 0);
begin
   if reset_in = '0' then
      log_time_r <= (others=>'0');
      log_status_last_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         log_time_r <= log_time_r+1;
         if log_wrreq='1' and log_write(log_type_t'length-1 downto 0) /= log_type_print_c then
            log_status_last_r <= log_write;
         end if;
      end if;
   end if;
end process;		
			            
end dp_fetch_behaviour;
