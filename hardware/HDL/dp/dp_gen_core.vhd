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

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;

ENTITY dp_gen_core IS
   port(
       SIGNAL clock_in                        :in std_logic;
       SIGNAL reset_in                        :in std_logic;

       -- signal to communicate with dp_fetch

       SIGNAL ready_out                       :out STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
       SIGNAL instruction_valid_in            :in STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
       SIGNAL instruction_in                  :in dp_instruction_t;
       SIGNAL pre_instruction_in              :in dp_instruction_t;
       SIGNAL wr_maxburstlen_in               :in burstlens_t(NUM_DP_DST_PORT-1 downto 0);
       SIGNAL full_in                         :in STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
       SIGNAL waitreq_in                      :in STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
       SIGNAL bar_in                          :in dp_addrs_t(dp_bus_id_max_c-1 downto 0);

       SIGNAL log1_out                        :out STD_LOGIC_VECTOR(host_width_c-1 downto 0);
       SIGNAL log1_valid_out                  :out STD_LOGIC;

       SIGNAL log2_out                        :out STD_LOGIC_VECTOR(host_width_c-1 downto 0);
       SIGNAL log2_valid_out                  :out STD_LOGIC;

       -- commands to send to dp_source for pcore memory space

       SIGNAL gen_pcore_src_valid_out         :out std_logic;
       SIGNAL gen_pcore_vm_out                :out std_logic;
       SIGNAL gen_pcore_fork_out              :out std_logic_vector(fork_max_c-1 downto 0);
       SIGNAL gen_pcore_data_flow_out         :out data_flow_t;
       SIGNAL gen_pcore_src_stream_out        :out STD_LOGIC;
       SIGNAL gen_pcore_dest_stream_out       :out STD_LOGIC;
       SIGNAL gen_pcore_stream_id_out         :out stream_id_t;
       SIGNAL gen_pcore_src_vector_out        :out dp_vector_t;
       SIGNAL gen_pcore_dst_vector_out        :out dp_vector_t;
       SIGNAL gen_pcore_src_scatter_out       :out scatter_t;
       SIGNAL gen_pcore_dst_scatter_out       :out scatter_t;
       SIGNAL gen_pcore_src_start_out         :out unsigned(ddr_vector_depth_c downto 0);
       SIGNAL gen_pcore_src_end_out           :out vector_fork_t;
       SIGNAL gen_pcore_dst_end_out           :out vector_fork_t;
       SIGNAL gen_pcore_src_addr_out          :out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_pcore_src_addr_mode_out     :out STD_LOGIC;
       SIGNAL gen_pcore_dst_addr_out          :out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_pcore_dst_addr_mode_out     :out STD_LOGIC;
       SIGNAL gen_pcore_src_eof_out           :out STD_LOGIC;
       SIGNAL gen_pcore_bus_id_source_out     :out dp_bus_id_t;
       SIGNAL gen_pcore_data_type_source_out  :out dp_data_type_t;
       SIGNAL gen_pcore_data_model_source_out :out dp_data_model_t;
       SIGNAL gen_pcore_bus_id_dest_out       :out dp_bus_id_t;
       SIGNAL gen_pcore_data_type_dest_out    :out dp_data_type_t;
       SIGNAL gen_pcore_data_model_dest_out   :out dp_data_model_t;
       SIGNAL gen_pcore_src_burstlen_out      :out burstlen_t;
       SIGNAL gen_pcore_dst_burstlen_out      :out burstlen_t;
       SIGNAL gen_pcore_thread_out            :out dp_thread_t;
       SIGNAL gen_pcore_mcast_out             :out mcast_t;
       SIGNAL gen_pcore_data_out              :out STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);


       -- commands to send to dp_source for sram memory space

       SIGNAL gen_sram_src_valid_out          :out STD_LOGIC;
       SIGNAL gen_sram_vm_out                 :out std_logic;
       SIGNAL gen_sram_fork_out               :out std_logic_vector(fork_max_c-1 downto 0);
       SIGNAL gen_sram_data_flow_out          :out data_flow_t;
       SIGNAL gen_sram_src_stream_out         :out STD_LOGIC;
       SIGNAL gen_sram_dest_stream_out        :out STD_LOGIC;
       SIGNAL gen_sram_stream_id_out          :out stream_id_t;
       SIGNAL gen_sram_src_vector_out         :out dp_vector_t;
       SIGNAL gen_sram_dst_vector_out         :out dp_vector_t;
       SIGNAL gen_sram_src_scatter_out        :out scatter_t;
       SIGNAL gen_sram_dst_scatter_out        :out scatter_t;
       SIGNAL gen_sram_src_start_out          :out unsigned(ddr_vector_depth_c downto 0);
       SIGNAL gen_sram_src_end_out            :out vector_fork_t;
       SIGNAL gen_sram_dst_end_out            :out vector_fork_t;
       SIGNAL gen_sram_src_addr_out           :out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_sram_src_addr_mode_out      :out STD_LOGIC;
       SIGNAL gen_sram_dst_addr_out           :out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_sram_dst_addr_mode_out      :out STD_LOGIC;
       SIGNAL gen_sram_src_eof_out            :out STD_LOGIC;
       SIGNAL gen_sram_bus_id_source_out      :out dp_bus_id_t;
       SIGNAL gen_sram_data_type_source_out   :out dp_data_type_t;
       SIGNAL gen_sram_data_model_source_out  :out dp_data_model_t;
       SIGNAL gen_sram_bus_id_dest_out        :out dp_bus_id_t;
       SIGNAL gen_sram_data_type_dest_out     :out dp_data_type_t;
       SIGNAL gen_sram_data_model_dest_out    :out dp_data_model_t;
       SIGNAL gen_sram_src_burstlen_out       :out burstlen_t;
       SIGNAL gen_sram_dst_burstlen_out       :out burstlen_t;
       SIGNAL gen_sram_thread_out             :out dp_thread_t;
       SIGNAL gen_sram_mcast_out              :out mcast_t;
       SIGNAL gen_sram_data_out               :out STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);

       -- commands to send to dp_source for ddr memory space

       SIGNAL gen_ddr_src_valid_out           :out STD_LOGIC;
       SIGNAL gen_ddr_vm_out                  :out std_logic;
       SIGNAL gen_ddr_fork_out                :out std_logic_vector(fork_max_c-1 downto 0);
       SIGNAL gen_ddr_data_flow_out           :out data_flow_t;
       SIGNAL gen_ddr_src_stream_out          :out STD_LOGIC;
       SIGNAL gen_ddr_dest_stream_out         :out STD_LOGIC;
       SIGNAL gen_ddr_stream_id_out           :out stream_id_t;
       SIGNAL gen_ddr_src_vector_out          :out dp_vector_t;
       SIGNAL gen_ddr_dst_vector_out          :out dp_vector_t;
       SIGNAL gen_ddr_src_scatter_out         :out scatter_t;
       SIGNAL gen_ddr_dst_scatter_out         :out scatter_t;
       SIGNAL gen_ddr_src_start_out           :out unsigned(ddr_vector_depth_c downto 0);
       SIGNAL gen_ddr_src_end_out             :out vector_fork_t;
       SIGNAL gen_ddr_dst_end_out             :out vector_fork_t;
       SIGNAL gen_ddr_src_addr_out            :out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_ddr_src_addr_mode_out       :out STD_LOGIC;
       SIGNAL gen_ddr_dst_addr_out            :out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_ddr_dst_addr_mode_out       :out STD_LOGIC;
       SIGNAL gen_ddr_src_eof_out             :out STD_LOGIC;
       SIGNAL gen_ddr_bus_id_source_out       :out dp_bus_id_t;
       SIGNAL gen_ddr_data_type_source_out    :out dp_data_type_t;
       SIGNAL gen_ddr_data_model_source_out   :out dp_data_model_t;
       SIGNAL gen_ddr_bus_id_dest_out         :out dp_bus_id_t;
       SIGNAL gen_ddr_data_type_dest_out      :out dp_data_type_t;
       SIGNAL gen_ddr_data_model_dest_out     :out dp_data_model_t;
       SIGNAL gen_ddr_src_burstlen_out        :out burstlen_t;
       SIGNAL gen_ddr_dst_burstlen_out        :out burstlen_t;
       SIGNAL gen_ddr_thread_out              :out dp_thread_t;
       SIGNAL gen_ddr_mcast_out               :out mcast_t;
       SIGNAL gen_ddr_data_out                :out STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0)
    );
END dp_gen_core;

ARCHITECTURE dp_gen_core_behaviour of dp_gen_core is

SIGNAL gen_src_valid_1:STD_LOGIC_VECTOR(dp_bus_id_max_c-1 downto 0);
SIGNAL gen_fork_1:std_logic_vector(fork_max_c-1 downto 0);
SIGNAL gen_vm_1:std_logic;
SIGNAL gen_data_flow_1:data_flow_t;
SIGNAL gen_src_stream_1:STD_LOGIC;
SIGNAL gen_dest_stream_1:STD_LOGIC;
SIGNAL gen_stream_id_1:stream_id_t;
SIGNAL gen_src_vector_1:dp_vector_t;
SIGNAL gen_dst_vector_1:dp_vector_t;
SIGNAL gen_src_scatter_1:scatter_t;
SIGNAL gen_dst_scatter_1:scatter_t;
SIGNAL gen_src_start_1:unsigned(ddr_vector_depth_c downto 0);
SIGNAL gen_src_end_1:vector_fork_t;
SIGNAL gen_dst_end_1:vector_fork_t;
SIGNAL gen_src_addr_1: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_src_addr_mode_1:STD_LOGIC;
SIGNAL gen_dst_addr_1: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_dst_addr_mode_1:STD_LOGIC;
SIGNAL gen_src_eof_1: STD_LOGIC;
SIGNAL gen_bus_id_source_1: dp_bus_id_t;
SIGNAL gen_data_type_source_1: dp_data_type_t;
SIGNAL gen_data_model_source_1: dp_data_model_t;
SIGNAL gen_bus_id_dest_1: dp_bus_id_t;
SIGNAL gen_data_type_dest_1: dp_data_type_t;
SIGNAL gen_data_model_dest_1: dp_data_model_t;
SIGNAL gen_src_burstlen_1: burstlen_t;
SIGNAL gen_dst_burstlen_1: burstlen_t;
SIGNAL gen_thread_1: dp_thread_t;
SIGNAL gen_mcast_1: mcast_t;
SIGNAL gen_data_1:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);

SIGNAL gen_src_valid_2:STD_LOGIC_VECTOR(dp_bus_id_max_c-1 downto 0);
SIGNAL gen_vm_2:std_logic;
SIGNAL gen_fork_2:std_logic_vector(fork_max_c-1 downto 0);
SIGNAL gen_data_flow_2:data_flow_t;
SIGNAL gen_src_stream_2:STD_LOGIC;
SIGNAL gen_dest_stream_2:STD_LOGIC;
SIGNAL gen_stream_id_2:stream_id_t;
SIGNAL gen_src_vector_2:dp_vector_t;
SIGNAL gen_dst_vector_2:dp_vector_t;
SIGNAL gen_src_scatter_2:scatter_t;
SIGNAL gen_dst_scatter_2:scatter_t;
SIGNAL gen_src_start_2:unsigned(ddr_vector_depth_c downto 0);
SIGNAL gen_src_end_2:vector_fork_t;
SIGNAL gen_dst_end_2:vector_fork_t;
SIGNAL gen_src_addr_2: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_src_addr_mode_2:STD_LOGIC;
SIGNAL gen_dst_addr_2: dp_full_addrs_t(fork_max_c-1 downto 0);
SIGNAL gen_dst_addr_mode_2:STD_LOGIC;
SIGNAL gen_src_eof_2: STD_LOGIC;
SIGNAL gen_bus_id_source_2: dp_bus_id_t;
SIGNAL gen_data_type_source_2: dp_data_type_t;
SIGNAL gen_data_model_source_2: dp_data_model_t;
SIGNAL gen_bus_id_dest_2: dp_bus_id_t;
SIGNAL gen_data_type_dest_2: dp_data_type_t;
SIGNAL gen_data_model_dest_2: dp_data_model_t;
SIGNAL gen_src_burstlen_2: burstlen_t;
SIGNAL gen_dst_burstlen_2: burstlen_t;
SIGNAL gen_thread_2: dp_thread_t;
SIGNAL gen_mcast_2: mcast_t;
SIGNAL gen_data_2:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);

BEGIN

-- Control signal to dp_source for pcore memory space

process(
        gen_src_valid_1,gen_src_valid_2,
        gen_vm_1,gen_vm_2,
        gen_fork_1,gen_fork_2,
        gen_data_flow_1,gen_data_flow_2,
        gen_src_stream_1,gen_src_stream_2,
        gen_dest_stream_1,gen_dest_stream_2,
        gen_stream_id_1,gen_stream_id_2,
        gen_src_vector_1,gen_src_vector_2,
        gen_dst_vector_1,gen_dst_vector_2,
        gen_src_scatter_1,gen_src_scatter_2,
        gen_dst_scatter_1,gen_dst_scatter_2,
        gen_src_start_1,gen_src_start_2,
        gen_src_end_1,gen_src_end_2,
        gen_dst_end_1,gen_dst_end_2,
        gen_src_addr_1,gen_src_addr_2,
        gen_src_addr_mode_1,gen_src_addr_mode_2,
        gen_dst_addr_1,gen_dst_addr_2,
        gen_dst_addr_mode_1,gen_dst_addr_mode_2,
        gen_src_eof_1,gen_src_eof_2,
        gen_bus_id_source_1,gen_bus_id_source_2,
        gen_data_type_source_1,gen_data_type_source_2,
        gen_data_model_source_1,gen_data_model_source_2,
        gen_bus_id_dest_1,gen_bus_id_dest_2,
        gen_data_type_dest_1,gen_data_type_dest_2,
        gen_data_model_dest_1,gen_data_model_dest_2,
        gen_src_burstlen_1,gen_src_burstlen_2,
        gen_dst_burstlen_1,gen_dst_burstlen_2,
        gen_thread_1,gen_thread_2,
        gen_mcast_1,gen_mcast_2,
        gen_data_1,gen_data_2)

begin
if gen_src_valid_1(dp_bus_id_register_c)='1' then
   gen_pcore_src_valid_out <= gen_src_valid_1(dp_bus_id_register_c);
   gen_pcore_vm_out <= gen_vm_1;
   gen_pcore_fork_out <= gen_fork_1;
   gen_pcore_data_flow_out <= gen_data_flow_1;
   gen_pcore_src_stream_out <= gen_src_stream_1;
   gen_pcore_dest_stream_out <= gen_dest_stream_1;
   gen_pcore_stream_id_out <= gen_stream_id_1;
   gen_pcore_src_vector_out <= gen_src_vector_1;
   gen_pcore_dst_vector_out <= gen_dst_vector_1;
   gen_pcore_src_scatter_out <= gen_src_scatter_1;
   gen_pcore_dst_scatter_out <= gen_dst_scatter_1;
   gen_pcore_src_start_out <= gen_src_start_1;
   gen_pcore_src_end_out <= gen_src_end_1;
   gen_pcore_dst_end_out <= gen_dst_end_1;
   gen_pcore_src_addr_out <= gen_src_addr_1;
   gen_pcore_src_addr_mode_out <= gen_src_addr_mode_1;
   gen_pcore_dst_addr_out <= gen_dst_addr_1;
   gen_pcore_dst_addr_mode_out <= gen_dst_addr_mode_1;
   gen_pcore_src_eof_out <= gen_src_eof_1;
   gen_pcore_bus_id_source_out <= gen_bus_id_source_1;
   gen_pcore_data_type_source_out <= gen_data_type_source_1;
   gen_pcore_data_model_source_out <= gen_data_model_source_1;
   gen_pcore_bus_id_dest_out <= gen_bus_id_dest_1;
   gen_pcore_data_type_dest_out <= gen_data_type_dest_1;
   gen_pcore_data_model_dest_out <= gen_data_model_dest_1;
   gen_pcore_src_burstlen_out <= gen_src_burstlen_1;
   gen_pcore_dst_burstlen_out <= gen_dst_burstlen_1;
   gen_pcore_thread_out <= gen_thread_1;
   gen_pcore_mcast_out <= gen_mcast_1;
   gen_pcore_data_out <= gen_data_1;
else
   gen_pcore_src_valid_out <= gen_src_valid_2(dp_bus_id_register_c);
   gen_pcore_vm_out <= gen_vm_2;
   gen_pcore_fork_out <= gen_fork_2;
   gen_pcore_data_flow_out <= gen_data_flow_2;
   gen_pcore_src_stream_out <= gen_src_stream_2;
   gen_pcore_dest_stream_out <= gen_dest_stream_2;
   gen_pcore_stream_id_out <= gen_stream_id_2;
   gen_pcore_src_vector_out <= gen_src_vector_2;
   gen_pcore_dst_vector_out <= gen_dst_vector_2;
   gen_pcore_src_scatter_out <= gen_src_scatter_2;
   gen_pcore_dst_scatter_out <= gen_dst_scatter_2;
   gen_pcore_src_start_out <= gen_src_start_2;
   gen_pcore_src_end_out <= gen_src_end_2;
   gen_pcore_dst_end_out <= gen_dst_end_2;
   gen_pcore_src_addr_out <= gen_src_addr_2;
   gen_pcore_src_addr_mode_out <= gen_src_addr_mode_2;
   gen_pcore_dst_addr_out <= gen_dst_addr_2;
   gen_pcore_dst_addr_mode_out <= gen_dst_addr_mode_2;
   gen_pcore_src_eof_out <= gen_src_eof_2;
   gen_pcore_bus_id_source_out <= gen_bus_id_source_2;
   gen_pcore_data_type_source_out <= gen_data_type_source_2;
   gen_pcore_data_model_source_out <= gen_data_model_source_2;
   gen_pcore_bus_id_dest_out <= gen_bus_id_dest_2;
   gen_pcore_data_type_dest_out <= gen_data_type_dest_2;
   gen_pcore_data_model_dest_out <= gen_data_model_dest_2;
   gen_pcore_src_burstlen_out <= gen_src_burstlen_2;
   gen_pcore_dst_burstlen_out <= gen_dst_burstlen_2;
   gen_pcore_thread_out <= gen_thread_2;
   gen_pcore_mcast_out <= gen_mcast_2;
   gen_pcore_data_out <= gen_data_2;
end if;
end process;


-- Control signal to dp_source for sram memory space

process(
        gen_src_valid_1,gen_src_valid_2,
        gen_vm_1,gen_vm_2,
        gen_fork_1,gen_fork_2,
        gen_data_flow_1,gen_data_flow_2,
        gen_src_stream_1,gen_src_stream_2,
        gen_dest_stream_1,gen_dest_stream_2,
        gen_stream_id_1,gen_stream_id_2,
        gen_src_vector_1,gen_src_vector_2,
        gen_dst_vector_1,gen_dst_vector_2,
        gen_src_scatter_1,gen_src_scatter_2,
        gen_dst_scatter_1,gen_dst_scatter_2,
        gen_src_start_1,gen_src_start_2,
        gen_src_end_1,gen_src_end_2,
        gen_dst_end_1,gen_dst_end_2,
        gen_src_addr_1,gen_src_addr_2,
        gen_src_addr_mode_1,gen_src_addr_mode_2,
        gen_dst_addr_1,gen_dst_addr_2,
        gen_dst_addr_mode_1,gen_dst_addr_mode_2,
        gen_src_eof_1,gen_src_eof_2,
        gen_bus_id_source_1,gen_bus_id_source_2,
        gen_data_type_source_1,gen_data_type_source_2,
        gen_data_model_source_1,gen_data_model_source_2,
        gen_bus_id_dest_1,gen_bus_id_dest_2,
        gen_data_type_dest_1,gen_data_type_dest_2,
        gen_data_model_dest_1,gen_data_model_dest_2,
        gen_src_burstlen_1,gen_src_burstlen_2,
        gen_dst_burstlen_1,gen_dst_burstlen_2,
        gen_thread_1,gen_thread_2,
        gen_mcast_1,gen_mcast_2,
        gen_data_1,gen_data_2)

begin
if gen_src_valid_1(dp_bus_id_sram_c)='1' then
   gen_sram_src_valid_out <= gen_src_valid_1(dp_bus_id_sram_c);
   gen_sram_vm_out <= gen_vm_1;
   gen_sram_fork_out <= gen_fork_1;
   gen_sram_data_flow_out <= gen_data_flow_1;
   gen_sram_src_stream_out <= gen_src_stream_1;
   gen_sram_dest_stream_out <= gen_dest_stream_1;
   gen_sram_stream_id_out <= gen_stream_id_1;
   gen_sram_src_vector_out <= gen_src_vector_1;
   gen_sram_dst_vector_out <= gen_dst_vector_1;
   gen_sram_src_scatter_out <= gen_src_scatter_1;
   gen_sram_dst_scatter_out <= gen_dst_scatter_1;
   gen_sram_src_start_out <= gen_src_start_1;
   gen_sram_src_end_out <= gen_src_end_1;
   gen_sram_dst_end_out <= gen_dst_end_1;
   gen_sram_src_addr_out <= gen_src_addr_1;
   gen_sram_src_addr_mode_out <= gen_src_addr_mode_1;
   gen_sram_dst_addr_out <= gen_dst_addr_1;
   gen_sram_dst_addr_mode_out <= gen_dst_addr_mode_1;
   gen_sram_src_eof_out <= gen_src_eof_1;
   gen_sram_bus_id_source_out <= gen_bus_id_source_1;
   gen_sram_data_type_source_out <= gen_data_type_source_1;
   gen_sram_data_model_source_out <= gen_data_model_source_1;
   gen_sram_bus_id_dest_out <= gen_bus_id_dest_1;
   gen_sram_data_type_dest_out <= gen_data_type_dest_1;
   gen_sram_data_model_dest_out <= gen_data_model_dest_1;
   gen_sram_src_burstlen_out <= gen_src_burstlen_1;
   gen_sram_dst_burstlen_out <= gen_dst_burstlen_1;
   gen_sram_thread_out <= gen_thread_1;
   gen_sram_mcast_out <= gen_mcast_1;
   gen_sram_data_out <= gen_data_1;
else
   gen_sram_src_valid_out <= gen_src_valid_2(dp_bus_id_sram_c);
   gen_sram_vm_out <= gen_vm_2;
   gen_sram_fork_out <= gen_fork_2;
   gen_sram_data_flow_out <= gen_data_flow_2;
   gen_sram_src_stream_out <= gen_src_stream_2;
   gen_sram_dest_stream_out <= gen_dest_stream_2;
   gen_sram_stream_id_out <= gen_stream_id_2;
   gen_sram_src_vector_out <= gen_src_vector_2;
   gen_sram_dst_vector_out <= gen_dst_vector_2;
   gen_sram_src_scatter_out <= gen_src_scatter_2;
   gen_sram_dst_scatter_out <= gen_dst_scatter_2;
   gen_sram_src_start_out <= gen_src_start_2;
   gen_sram_src_end_out <= gen_src_end_2;
   gen_sram_dst_end_out <= gen_dst_end_2;
   gen_sram_src_addr_out <= gen_src_addr_2;
   gen_sram_src_addr_mode_out <= gen_src_addr_mode_2;
   gen_sram_dst_addr_out <= gen_dst_addr_2;
   gen_sram_dst_addr_mode_out <= gen_dst_addr_mode_2;
   gen_sram_src_eof_out <= gen_src_eof_2;
   gen_sram_bus_id_source_out <= gen_bus_id_source_2;
   gen_sram_data_type_source_out <= gen_data_type_source_2;
   gen_sram_data_model_source_out <= gen_data_model_source_2;
   gen_sram_bus_id_dest_out <= gen_bus_id_dest_2;
   gen_sram_data_type_dest_out <= gen_data_type_dest_2;
   gen_sram_data_model_dest_out <= gen_data_model_dest_2;
   gen_sram_src_burstlen_out <= gen_src_burstlen_2;
   gen_sram_dst_burstlen_out <= gen_dst_burstlen_2;
   gen_sram_thread_out <= gen_thread_2;
   gen_sram_mcast_out <= gen_mcast_2;
   gen_sram_data_out <= gen_data_2;
end if; 
end process;

-- Control signal to dp_source for ddr memory space

process(
        gen_src_valid_1,gen_src_valid_2,
        gen_vm_1,gen_vm_2,
        gen_fork_1,gen_fork_2,
        gen_data_flow_1,gen_data_flow_2,
        gen_src_stream_1,gen_src_stream_2,
        gen_dest_stream_1,gen_dest_stream_2,
        gen_stream_id_1,gen_stream_id_2,
        gen_src_vector_1,gen_src_vector_2,
        gen_dst_vector_1,gen_dst_vector_2,
        gen_src_scatter_1,gen_src_scatter_2,
        gen_dst_scatter_1,gen_dst_scatter_2,
        gen_src_start_1,gen_src_start_2,
        gen_src_end_1,gen_src_end_2,
        gen_dst_end_1,gen_dst_end_2,
        gen_src_addr_1,gen_src_addr_2,
        gen_src_addr_mode_1,gen_src_addr_mode_2,
        gen_dst_addr_1,gen_dst_addr_2,
        gen_dst_addr_mode_1,gen_dst_addr_mode_2,
        gen_src_eof_1,gen_src_eof_2,
        gen_bus_id_source_1,gen_bus_id_source_2,
        gen_data_type_source_1,gen_data_type_source_2,
        gen_data_model_source_1,gen_data_model_source_2,
        gen_bus_id_dest_1,gen_bus_id_dest_2,
        gen_data_type_dest_1,gen_data_type_dest_2,
        gen_data_model_dest_1,gen_data_model_dest_2,
        gen_src_burstlen_1,gen_src_burstlen_2,
        gen_dst_burstlen_1,gen_dst_burstlen_2,
        gen_thread_1,gen_thread_2,
        gen_mcast_1,gen_mcast_2,
        gen_data_1,gen_data_2)
begin
if gen_src_valid_1(dp_bus_id_ddr_c)='1' then
   gen_ddr_src_valid_out <= gen_src_valid_1(dp_bus_id_ddr_c);
   gen_ddr_vm_out <= gen_vm_1;
   gen_ddr_fork_out <= gen_fork_1;
   gen_ddr_data_flow_out <= gen_data_flow_1;
   gen_ddr_src_stream_out <= gen_src_stream_1;
   gen_ddr_dest_stream_out <= gen_dest_stream_1;
   gen_ddr_stream_id_out <= gen_stream_id_1;
   gen_ddr_src_vector_out <= gen_src_vector_1;
   gen_ddr_dst_vector_out <= gen_dst_vector_1;
   gen_ddr_src_scatter_out <= gen_src_scatter_1;
   gen_ddr_dst_scatter_out <= gen_dst_scatter_1;
   gen_ddr_src_start_out <= gen_src_start_1;
   gen_ddr_src_end_out <= gen_src_end_1;
   gen_ddr_dst_end_out <= gen_dst_end_1;
   gen_ddr_src_addr_out <= gen_src_addr_1;
   gen_ddr_src_addr_mode_out <= gen_src_addr_mode_1;
   gen_ddr_dst_addr_out <= gen_dst_addr_1;
   gen_ddr_dst_addr_mode_out <= gen_dst_addr_mode_1;
   gen_ddr_src_eof_out <= gen_src_eof_1;
   gen_ddr_bus_id_source_out <= gen_bus_id_source_1;
   gen_ddr_data_type_source_out <= gen_data_type_source_1;
   gen_ddr_data_model_source_out <= gen_data_model_source_1;
   gen_ddr_bus_id_dest_out <= gen_bus_id_dest_1;
   gen_ddr_data_type_dest_out <= gen_data_type_dest_1;
   gen_ddr_data_model_dest_out <= gen_data_model_dest_1;
   gen_ddr_src_burstlen_out <= gen_src_burstlen_1;
   gen_ddr_dst_burstlen_out <= gen_dst_burstlen_1;
   gen_ddr_thread_out <= gen_thread_1;
   gen_ddr_mcast_out <= gen_mcast_1;
   gen_ddr_data_out <= gen_data_1;
else
   gen_ddr_src_valid_out <= gen_src_valid_2(dp_bus_id_ddr_c);
   gen_ddr_vm_out <= gen_vm_2;
   gen_ddr_fork_out <= gen_fork_2;
   gen_ddr_data_flow_out <= gen_data_flow_2;
   gen_ddr_src_stream_out <= gen_src_stream_2;
   gen_ddr_dest_stream_out <= gen_dest_stream_2;
   gen_ddr_stream_id_out <= gen_stream_id_2;
   gen_ddr_src_vector_out <= gen_src_vector_2;
   gen_ddr_dst_vector_out <= gen_dst_vector_2;
   gen_ddr_src_scatter_out <= gen_src_scatter_2;
   gen_ddr_dst_scatter_out <= gen_dst_scatter_2;
   gen_ddr_src_start_out <= gen_src_start_2;
   gen_ddr_src_end_out <= gen_src_end_2;
   gen_ddr_dst_end_out <= gen_dst_end_2;
   gen_ddr_src_addr_out <= gen_src_addr_2;
   gen_ddr_src_addr_mode_out <= gen_src_addr_mode_2;
   gen_ddr_dst_addr_out <= gen_dst_addr_2;
   gen_ddr_dst_addr_mode_out <= gen_dst_addr_mode_2;
   gen_ddr_src_eof_out <= gen_src_eof_2;
   gen_ddr_bus_id_source_out <= gen_bus_id_source_2;
   gen_ddr_data_type_source_out <= gen_data_type_source_2;
   gen_ddr_data_model_source_out <= gen_data_model_source_2;
   gen_ddr_bus_id_dest_out <= gen_bus_id_dest_2;
   gen_ddr_data_type_dest_out <= gen_data_type_dest_2;
   gen_ddr_data_model_dest_out <= gen_data_model_dest_2;
   gen_ddr_src_burstlen_out <= gen_src_burstlen_2;
   gen_ddr_dst_burstlen_out <= gen_dst_burstlen_2;
   gen_ddr_thread_out <= gen_thread_2;
   gen_ddr_mcast_out <= gen_mcast_2;
   gen_ddr_data_out <= gen_data_2;
end if;
end process;

dp_gen_primary_i: dp_gen GENERIC MAP(
                            NUM_DP_DST_PORT=>NUM_DP_DST_PORT,
                            SOURCE_BURST_MODE=>'1',
                            DEST_BURST_MODE=>'1'
                        )
                        PORT MAP(
                            clock_in=>clock_in,
                            reset_in=>reset_in,
                            -- Signals to/from dp_fetch stage
                            ready_out=>ready_out(0), -- The source controls the flow for new incoming DP commands
                            instruction_valid_in=>instruction_valid_in(0),
                            instruction_latch_in=>instruction_valid_in(0),
                            instruction_source_in=>instruction_in.source,
                            instruction_dest_in=>instruction_in.dest,
                            instruction_stream_process_in=>instruction_in.stream_process,
                            instruction_stream_process_id_in=>instruction_in.stream_process_id,
                            instruction_vm_in=>instruction_in.vm,
                            pre_instruction_source_in=>pre_instruction_in.source,
                            pre_instruction_dest_in=>pre_instruction_in.dest,
                            pre_instruction_bus_id_source_in=>pre_instruction_in.source_bus_id,
                            pre_instruction_bus_id_dest_in=>pre_instruction_in.dest_bus_id,
                            instruction_source_addr_mode_in=>instruction_in.source_addr_mode,
                            instruction_dest_addr_mode_in=>instruction_in.dest_addr_mode,
                            instruction_bus_id_source_in=>instruction_in.source_bus_id,
                            instruction_data_type_source_in=>instruction_in.source_data_type,
                            instruction_data_model_source_in=>instruction_in.source.data_model,
                            instruction_bus_id_dest_in=>instruction_in.dest_bus_id,
                            instruction_data_type_dest_in=>instruction_in.dest_data_type,
                            instruction_data_model_dest_in=>instruction_in.dest.data_model,
                            instruction_mcast_in=>instruction_in.mcast,
                            instruction_gen_len_in=>instruction_in.count,
                            instruction_thread_in=>(others=>'0'),
                            instruction_data_in=>instruction_in.data,
                            instruction_repeat_in=>instruction_in.repeat,
                            wr_maxburstlen_in=>wr_maxburstlen_in,
                            wr_full_in=>full_in,
                            -- Signal to/from dp_exec stage
                            waitreq_in=>waitreq_in,

                            gen_valid_out=>gen_src_valid_1, 
                            gen_vm_out=>gen_vm_1, 
                            gen_fork_out=>gen_fork_1,
                            gen_data_flow_out=>gen_data_flow_1,
                            gen_src_stream_out=>gen_src_stream_1,
                            gen_dest_stream_out=>gen_dest_stream_1,
                            gen_stream_id_out => gen_stream_id_1,
                            gen_src_vector_out=>gen_src_vector_1,
                            gen_dst_vector_out=>gen_dst_vector_1,
                            gen_src_scatter_out=>gen_src_scatter_1,
                            gen_dst_scatter_out=>gen_dst_scatter_1,
                            gen_src_start_out=>gen_src_start_1,
                            gen_src_end_out=>gen_src_end_1,
                            gen_dst_end_out=>gen_dst_end_1,
                            gen_addr_source_out=>gen_src_addr_1,
                            gen_addr_source_mode_out=>gen_src_addr_mode_1,
                            gen_addr_dest_out=>gen_dst_addr_1,
                            gen_addr_dest_mode_out=>gen_dst_addr_mode_1,
                            gen_eof_out=>gen_src_eof_1,
                            gen_bus_id_source_out=>gen_bus_id_source_1,
                            gen_data_type_source_out=>gen_data_type_source_1,
                            gen_data_model_source_out=>gen_data_model_source_1,
                            gen_bus_id_dest_out=>gen_bus_id_dest_1,
                            gen_data_type_dest_out=>gen_data_type_dest_1,
                            gen_data_model_dest_out=>gen_data_model_dest_1,
                            gen_burstlen_source_out=>gen_src_burstlen_1,
                            gen_burstlen_dest_out=>gen_dst_burstlen_1,
                            gen_thread_out=>gen_thread_1,
                            gen_mcast_out=>gen_mcast_1,
                            gen_data_out=>gen_data_1,

                            gen_bar_in=>bar_in,

                            log_out=>log1_out,
                            log_valid_out=>log1_valid_out
                            );

dp_gen_secondary_i: dp_gen GENERIC MAP(
                            NUM_DP_DST_PORT=>NUM_DP_DST_PORT,
                            SOURCE_BURST_MODE=>'1',
                            DEST_BURST_MODE=>'1'
                        )
                        PORT MAP(
                            clock_in=>clock_in,
                            reset_in=>reset_in,
                            -- Signals to/from dp_fetch stage
                            ready_out=>ready_out(1), -- The source controls the flow for new incoming DP commands
                            instruction_valid_in=>instruction_valid_in(1),
                            instruction_latch_in=>instruction_valid_in(1),
                            instruction_source_in=>instruction_in.source,
                            instruction_dest_in=>instruction_in.dest,
                            instruction_stream_process_in=>instruction_in.stream_process,
                            instruction_stream_process_id_in=>instruction_in.stream_process_id,
                            instruction_vm_in=>instruction_in.vm,
                            pre_instruction_source_in=>pre_instruction_in.source,
                            pre_instruction_dest_in=>pre_instruction_in.dest,
                            pre_instruction_bus_id_source_in=>pre_instruction_in.source_bus_id,
                            pre_instruction_bus_id_dest_in=>pre_instruction_in.dest_bus_id,
                            instruction_source_addr_mode_in=>instruction_in.source_addr_mode,
                            instruction_dest_addr_mode_in=>instruction_in.dest_addr_mode,
                            instruction_bus_id_source_in=>instruction_in.source_bus_id,
                            instruction_data_type_source_in=>instruction_in.source_data_type,
                            instruction_data_model_source_in=>instruction_in.source.data_model,
                            instruction_bus_id_dest_in=>instruction_in.dest_bus_id,
                            instruction_data_type_dest_in=>instruction_in.dest_data_type,
                            instruction_data_model_dest_in=>instruction_in.dest.data_model,
                            instruction_mcast_in=>instruction_in.mcast,
                            instruction_gen_len_in=>instruction_in.count,
                            instruction_thread_in=>(others=>'0'),
                            instruction_data_in=>instruction_in.data,
                            instruction_repeat_in=>instruction_in.repeat,

                            wr_maxburstlen_in=>wr_maxburstlen_in,
                            wr_full_in=>full_in,
                            -- Signal to/from dp_exec stage
                            waitreq_in=>waitreq_in,

                            gen_valid_out=>gen_src_valid_2,
                            gen_vm_out=>gen_vm_2, 
                            gen_fork_out=>gen_fork_2,
                            gen_data_flow_out=>gen_data_flow_2,
                            gen_src_stream_out=>gen_src_stream_2,
                            gen_dest_stream_out=>gen_dest_stream_2,
                            gen_stream_id_out => gen_stream_id_2,
                            gen_src_vector_out=>gen_src_vector_2,
                            gen_dst_vector_out=>gen_dst_vector_2,
                            gen_src_scatter_out=>gen_src_scatter_2,
                            gen_dst_scatter_out=>gen_dst_scatter_2,
                            gen_src_start_out=>gen_src_start_2,
                            gen_src_end_out=>gen_src_end_2,
                            gen_dst_end_out=>gen_dst_end_2,
                            gen_addr_source_out=>gen_src_addr_2,
                            gen_addr_source_mode_out=>gen_src_addr_mode_2,
                            gen_addr_dest_out=>gen_dst_addr_2,
                            gen_addr_dest_mode_out=>gen_dst_addr_mode_2,
                            gen_eof_out=>gen_src_eof_2,
                            gen_bus_id_source_out=>gen_bus_id_source_2,
                            gen_data_type_source_out=>gen_data_type_source_2,
                            gen_data_model_source_out=>gen_data_model_source_2,
                            gen_bus_id_dest_out=>gen_bus_id_dest_2,
                            gen_data_type_dest_out=>gen_data_type_dest_2,
                            gen_data_model_dest_out=>gen_data_model_dest_2,
                            gen_burstlen_source_out=>gen_src_burstlen_2,
                            gen_burstlen_dest_out=>gen_dst_burstlen_2,
                            gen_thread_out=>gen_thread_2,
                            gen_mcast_out=>gen_mcast_2,
                            gen_data_out=>gen_data_2,

                            gen_bar_in=>bar_in,

                            log_out=>log2_out,
                            log_valid_out=>log2_valid_out
                            );

end dp_gen_core_behaviour;
