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

------
-- This is top component for PCORE
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;

ENTITY pcore IS
    GENERIC (
        CID :integer;
        PID :integer
        );
   PORT(SIGNAL clock_in              : IN STD_LOGIC;
        SIGNAL reset_in              : IN STD_LOGIC;    
                
        -- Instruction interface
        SIGNAL instruction_mu_in       : IN STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_imu_in      : IN STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_mu_valid_in : IN STD_LOGIC;
        SIGNAL instruction_imu_valid_in: IN STD_LOGIC;
        SIGNAL vm_in                 : IN STD_LOGIC;
		SIGNAL data_model_in         : IN dp_data_model_t;
        SIGNAL enable_in             : IN STD_LOGIC;
        SIGNAL tid_in                : IN tid_t;
        SIGNAL tid_valid1_in         : IN STD_LOGIC;
        SIGNAL pre_tid_in            : IN tid_t;
        SIGNAL pre_tid_valid1_in     : IN STD_LOGIC;
        SIGNAL pre_pre_tid_in        : IN tid_t;
        SIGNAL pre_pre_tid_valid1_in : IN STD_LOGIC;
        SIGNAL pre_pre_vm_in         : IN STD_LOGIC;
		SIGNAL pre_pre_data_model_in : IN dp_data_model_t;
        SIGNAL pre_iregister_auto_in : IN iregister_auto_t;

        SIGNAL i_y_neg_out           : OUT STD_LOGIC;
        SIGNAL i_y_zero_out          : OUT STD_LOGIC;

        -- DP interface
        SIGNAL dp_rd_vm_in           : IN STD_LOGIC;        
        SIGNAL dp_wr_vm_in           : IN STD_LOGIC;
        SIGNAL dp_code_in            : IN STD_LOGIC;
        SIGNAL dp_rd_addr_in         : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_addr_step_in    : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_share_in        : IN STD_LOGIC;
        SIGNAL dp_rd_fork_in         : IN STD_LOGIC;
        SIGNAL dp_wr_addr_in         : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_addr_step_in    : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_fork_in         : IN STD_LOGIC;
        SIGNAL dp_wr_share_in        : IN STD_LOGIC;
        SIGNAL dp_wr_mcast_in        : IN mcast_t;        
        SIGNAL dp_write_in           : IN STD_LOGIC;
        SIGNAL dp_write_gen_valid_in : IN STD_LOGIC;
        SIGNAL dp_write_vector_in    : IN dp_vector_t;
        SIGNAL dp_write_scatter_in   : IN scatter_t;
        SIGNAL dp_read_in            : IN STD_LOGIC;
        SIGNAL dp_read_vector_in     : IN dp_vector_t;
        SIGNAL dp_read_scatter_in    : IN scatter_t;
        SIGNAL dp_read_gen_valid_in  : IN STD_LOGIC;
        SIGNAL dp_read_data_flow_in  : IN data_flow_t;
        SIGNAL dp_read_data_type_in  : IN dp_data_type_t;
        SIGNAL dp_read_stream_in     : IN std_logic;
        SIGNAL dp_read_stream_id_in  : IN stream_id_t;
        SIGNAL dp_writedata_in       : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out       : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_vm_out    : OUT STD_LOGIC;
        SIGNAL dp_readena_out        : OUT STD_LOGIC;
        SIGNAL dp_read_vector_out    : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_vaddr_out     : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);

        SIGNAL dp_read_gen_valid_out : OUT STD_LOGIC;
        SIGNAL dp_read_data_flow_out : OUT data_flow_t;
        SIGNAL dp_read_data_type_out : OUT dp_data_type_t;
        SIGNAL dp_read_stream_out    : OUT std_logic;
        SIGNAL dp_read_stream_id_out : OUT stream_id_t;
        SIGNAL dp_config_in_in          : IN STD_LOGIC
    );
END pcore;

ARCHITECTURE behavior OF pcore IS
type mu_bus_t IS ARRAY(0 TO 1) OF STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);

SIGNAL rd_x1_data1:STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
SIGNAL rd_x2_data1:STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
SIGNAL rd_en1: STD_LOGIC;
SIGNAL rd_vm: STD_LOGIC;
--SIGNAL wr_tid1:tid_t;
SIGNAL wr_en1: STD_LOGIC;
SIGNAL wr_xreg1:STD_LOGIC;
SIGNAL wr_flag1:STD_LOGIC;
SIGNAL wr_data1:STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
SIGNAL wr_vector_lane:STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);
SIGNAL x1_addr1:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL x2_addr1:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL y_addr1:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);

SIGNAL rd_lane:iregister_t;
SIGNAL wr_lane:STD_LOGIC;

SIGNAL opcode1: STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL opcode2: STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL instruction_next_addr1:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL instruction_long_format1:STD_LOGIC;
SIGNAL mu_x1: std_logic_vector(vregister_width_c-1 downto 0);
SIGNAL mu_x2: std_logic_vector(vregister_width_c-1 downto 0);
SIGNAL mu_x_scalar: std_logic_vector(register_width_c-1 downto 0);
SIGNAL mu_y: std_logic_vector(vaccumulator_width_c-1 downto 0);
SIGNAL mu_y2: std_logic_vector(vregister_width_c-1 downto 0);
SIGNAL mu_result:std_logic_vector(vector_width_c-1 downto 0);
SIGNAL mu_opcodes:mu_opcode_t;
SIGNAL mu_tid:tid_t;
SIGNAL tid_decoder2dispatch:tid_t;

SIGNAL dp_write:STD_LOGIC;
SIGNAL dp_read:STD_LOGIC;

SIGNAL dp_mcast_addr: mcast_addr_t;

SIGNAL rd_x1_addr1:std_logic_vector(register_file_depth_c-1 downto 0);
SIGNAL rd_x2_addr1:std_logic_vector(register_file_depth_c-1 downto 0);
SIGNAL wr_addr1:std_logic_vector(register_file_depth_c-1 downto 0);
SIGNAL wr_result_addr1:std_logic_vector(xreg_depth_c-1 downto 0);

SIGNAL dp_rd_pid:pid_t;
SIGNAL dp_rd_cid:cid_t;
SIGNAL en1:STD_LOGIC;
SIGNAL mu_vm:STD_LOGIC;
SIGNAL mu_xreg1:std_logic;
SIGNAL mu_flag1:std_logic;
SIGNAL mu_wren:std_logic;

-- Constant parameters
SIGNAL x1_c1_en:STD_LOGIC;
SIGNAL x1_c1:STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);

-- Vector mode
SIGNAL x1_vector:STD_LOGIC;
SIGNAL x2_vector:STD_LOGIC;
SIGNAL y_vector:STD_LOGIC;
SIGNAL vector_lane:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL rd_x1_vector1:STD_LOGIC;
SIGNAL rd_x2_vector1:STD_LOGIC;
SIGNAL wr_vector:STD_LOGIC;

-- IREGISTER
SIGNAL i_rd_en1:STD_LOGIC;
SIGNAL i_rd_vm:STD_LOGIC;
SIGNAL i_rd_tid1:tid_t;
SIGNAL i_rd_data1:iregisters_t(iregister_max_c-1 downto 0);
SIGNAL i_wr_tid1:tid_t;
SIGNAL i_wr_en1:STD_LOGIC;
SIGNAL i_wr_vm:STD_LOGIC;
SIGNAL i_wr_addr1:iregister_addr_t;
SIGNAL i_wr_data1:iregister_t;

SIGNAL dp_readdata_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0);
SIGNAL dp_readdata2_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0);
SIGNAL dp_readena_r:STD_LOGIC;
SIGNAL dp_readdata_vm_r:STD_LOGIC;
SIGNAL dp_read_gen_valid2_r:STD_LOGIC;
SIGNAL dp_read_data_flow2_r:data_flow_t;
SIGNAL dp_read_data_type2_r:dp_data_type_t;
SIGNAL dp_read_vector2_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vaddr2_r:std_logic_vector(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_stream2_r:std_logic;
SIGNAL dp_read_stream_id2_r:stream_id_t;

SIGNAL rd_enable1:STD_LOGIC;

SIGNAL i_opcode:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL i_x1:iregister_t;
SIGNAL i_x2:iregister_t;
SIGNAL i_y:iregister_t;
SIGNAL i_y_neg:std_logic;
SIGNAL i_y_zero:std_logic;

SIGNAL wr_vm:STD_LOGIC;           
SIGNAL result_write_addr:xreg_addr_t;
SIGNAL result_vector:STD_LOGIC;
SIGNAL result_raddr1:xreg_addr_t;
SIGNAL result_waddr1:xreg_addr_t;
SIGNAL result_read_vm:std_logic;
SIGNAL result_read:iregister_t;
SIGNAL xreg_read:STD_LOGIC_VECTOR(vaccumulator_width_c-1 downto 0);

SIGNAL dp_rd_vm_2:STD_LOGIC;
SIGNAL dp_rd_fork_2:STD_LOGIC;
SIGNAL dp_wr_vm_2:STD_LOGIC;
SIGNAL dp_wr_fork_2:STD_LOGIC;
SIGNAL dp_rd_addr_2:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_addr_2:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_mcast_2:mcast_t;        
SIGNAL dp_write_2:STD_LOGIC;
SIGNAL dp_write_vector_2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_write_scatter_2:scatter_t;
SIGNAL dp_write_share_2:std_logic;
SIGNAL dp_write_step_2:STD_LOGIC_VECTOR(local_bus_width_c-1 downto 0);
SIGNAL dp_write_gen_valid_2:STD_LOGIC;
SIGNAL dp_read_2:STD_LOGIC;
SIGNAL dp_read_vector_2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_scatter_2:scatter_t;
SIGNAL dp_read_share_2:std_logic;
SIGNAL dp_read_step_2:STD_LOGIC_VECTOR(local_bus_width_c-1 downto 0);
SIGNAL dp_read_gen_valid_2:STD_LOGIC;
SIGNAL dp_read_data_flow_2:data_flow_t;
SIGNAL dp_read_data_type_2:dp_data_type_t;
SIGNAL dp_read_stream_2:std_logic;
SIGNAL dp_read_stream_id_2:stream_id_t;
SIGNAL dp_writedata_2:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
SIGNAL dp_writedata_3:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
SIGNAL read_scatter_cnt_2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL read_scatter_vector_2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL write_scatter_cnt_2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL write_scatter_vector_2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL write_scatter_curr_2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL write_scatter_curr_r:unsigned(ddr_vector_depth_c-1 downto 0);

SIGNAL dp_read_vector_2_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_scatter_2_r:scatter_t;
SIGNAL dp_read_share_2_r:std_logic;
SIGNAL dp_read_step_2_r:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL read_scatter_cnt_2_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL read_scatter_vector_2_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_gen_valid_2_r:STD_LOGIC;
SIGNAL dp_read_data_flow_2_r:data_flow_t;
SIGNAL dp_read_data_type_2_r:dp_data_type_t;
SIGNAL dp_read_stream_2_r:std_logic;
SIGNAL dp_read_stream_id_2_r:stream_id_t;
SIGNAL dp_rd_addr_2_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_write_vector_2_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_wr_addr_2_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_writedata_3_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);

SIGNAL dp_rd_vm_r:STD_LOGIC;
SIGNAL dp_rd_fork_r:STD_LOGIC;
SIGNAL dp_wr_vm_r:STD_LOGIC;
SIGNAL dp_wr_fork_r:STD_LOGIC;
SIGNAL dp_rd_addr_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_addr_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_mcast_r:mcast_t;        
SIGNAL dp_write_r:STD_LOGIC;
SIGNAL dp_write_gen_valid_r:STD_LOGIC;
SIGNAL dp_write_vector_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_write_scatter_r:scatter_t;
SIGNAL dp_write_share_r:std_logic;
SIGNAL dp_write_step_r:STD_LOGIC_VECTOR(local_bus_width_c-1 downto 0);
SIGNAL dp_read_r:STD_LOGIC;
SIGNAL dp_read_vector_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_scatter_r:scatter_t;
SIGNAL dp_read_share_r:std_logic;
SIGNAL dp_read_step_r:std_logic_vector(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_read_gen_valid_r:STD_LOGIC;
SIGNAL dp_read_data_flow_r:data_flow_t;
SIGNAL dp_read_data_type_r:dp_data_type_t;
SIGNAL dp_read_stream_r:std_logic;
SIGNAL dp_read_stream_id_r:stream_id_t;
SIGNAL dp_writedata_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
SIGNAL read_scatter_cnt_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL read_scatter_vector_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL write_scatter_cnt_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL write_scatter_vector_r:unsigned(ddr_vector_depth_c-1 downto 0);

SIGNAL read_match:STD_LOGIC;
SIGNAL write_match:STD_LOGIC;

SIGNAL dp_readena_vm:std_logic;

SIGNAL dp_read_vector_vm:unsigned(ddr_vector_depth_c-1 downto 0);

SIGNAL dp_read_vaddr_vm:std_logic_vector(ddr_vector_depth_c-1 downto 0);

SIGNAL dp_read_scatter_vm:scatter_t;
SIGNAL dp_read_scatter_cnt_vm:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_scatter_vector_vm:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_readdata_vm:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0);
SIGNAL dp_readdata_vm_vm:STD_LOGIC;
SIGNAL dp_read_gen_valid_vm:STD_LOGIC;
SIGNAL dp_read_data_flow_vm:data_flow_t;
SIGNAL dp_read_data_type_vm:dp_data_type_t;
SIGNAL dp_read_stream_vm:std_logic;
SIGNAL dp_read_stream_id_vm:stream_id_t;

SIGNAL tid_valid1:STD_LOGIC;
SIGNAL pre_tid_valid1:STD_LOGIC;
SIGNAL pre_pre_tid_valid1:STD_LOGIC;

SIGNAL instruction_mu_r:STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_imu_r:STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_mu_valid_r:STD_LOGIC;
SIGNAL instruction_imu_valid_r:STD_LOGIC;

SIGNAL vm_r:STD_LOGIC;
SIGNAL data_model_r:dp_data_model_t;
SIGNAL tid_r:tid_t;
SIGNAL tid_valid1_r:STD_LOGIC;
SIGNAL pre_tid_r:tid_t;
SIGNAL pre_tid_valid1_r:STD_LOGIC;
SIGNAL pre_pre_tid_r:tid_t;
SIGNAL pre_pre_tid_valid1_r:STD_LOGIC;
SIGNAL pre_pre_vm_r:STD_LOGIC;
SIGNAL pre_pre_data_model_r:dp_data_model_t;
SIGNAL pre_iregister_auto_r:iregister_auto_t;

SIGNAL error_write:STD_LOGIC;
SIGNAL error_read:STD_LOGIC;

SIGNAL dp_write_2_r:STD_LOGIC;
SIGNAL dp_write_vm_2_r:STD_LOGIC;
SIGNAL dp_write_fork_2_r:STD_LOGIC;
SIGNAL dp_read_2_r:STD_LOGIC;
SIGNAL dp_read_vm_2_r:STD_LOGIC;
SIGNAL dp_read_fork_2_r:STD_LOGIC;

SIGNAL dp_rd_vm_in_r:STD_LOGIC;        
SIGNAL dp_wr_vm_in_r:STD_LOGIC;
SIGNAL dp_code_in_r:STD_LOGIC;
SIGNAL dp_rd_addr_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_rd_share_in_r:STD_LOGIC;
SIGNAL dp_rd_step_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_share_in_r:STD_LOGIC;
SIGNAL dp_wr_step_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_mcast_in_r:mcast_t;        
SIGNAL dp_write_in_r:STD_LOGIC;
SIGNAL dp_wr_fork_in_r:STD_LOGIC;
SIGNAL dp_write_gen_valid_in_r:STD_LOGIC;
SIGNAL dp_write_vector_in_r:dp_vector_t;
SIGNAL dp_write_scatter_in_r:scatter_t;
SIGNAL dp_rd_fork_in_r:STD_LOGIC;
SIGNAL dp_read_in_r:STD_LOGIC;
SIGNAL dp_read_vector_in_r:dp_vector_t;
SIGNAL dp_read_scatter_in_r:scatter_t;
SIGNAL dp_read_gen_valid_in_r:STD_LOGIC;
SIGNAL dp_read_data_flow_in_r:data_flow_t;
SIGNAL dp_read_data_type_in_r:dp_data_type_t;
SIGNAL dp_read_stream_in_r:std_logic;
SIGNAL dp_read_stream_id_in_r:stream_id_t;
SIGNAL dp_writedata_in_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
SIGNAL dp_config_in_r:STD_LOGIC;

attribute dont_merge : boolean;
attribute dont_merge of instruction_mu_r : SIGNAL is true;
attribute dont_merge of instruction_imu_r : SIGNAL is true;
attribute dont_merge of instruction_mu_valid_r : SIGNAL is true;
attribute dont_merge of instruction_imu_valid_r : SIGNAL is true;
attribute dont_merge of vm_r : SIGNAL is true;
attribute dont_merge of data_model_r: SIGNAL is true;
attribute dont_merge of tid_r : SIGNAL is true;
attribute dont_merge of tid_valid1_r : SIGNAL is true;
attribute dont_merge of pre_tid_r : SIGNAL is true;
attribute dont_merge of pre_tid_valid1_r : SIGNAL is true;
attribute dont_merge of pre_pre_tid_r : SIGNAL is true;
attribute dont_merge of pre_pre_tid_valid1_r : SIGNAL is true;
attribute dont_merge of pre_pre_vm_r : SIGNAL is true;
attribute dont_merge of pre_pre_data_model_r : SIGNAL is true;
attribute dont_merge of pre_iregister_auto_r : SIGNAL is true;

attribute dont_merge of dp_rd_vm_in_r  : SIGNAL is true;
attribute dont_merge of dp_wr_vm_in_r : SIGNAL is true;
attribute dont_merge of dp_code_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_addr_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_share_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_step_in_r : SIGNAL is true;
attribute dont_merge of dp_wr_addr_in_r  : SIGNAL is true;
attribute dont_merge of dp_wr_share_in_r : SIGNAL is true;
attribute dont_merge of dp_wr_step_in_r : SIGNAL is true;
attribute dont_merge of dp_wr_mcast_in_r : SIGNAL is true;
attribute dont_merge of dp_write_in_r : SIGNAL is true;
attribute dont_merge of dp_wr_fork_in_r : SIGNAL is true;
attribute dont_merge of dp_write_gen_valid_in_r : SIGNAL is true;
attribute dont_merge of dp_write_vector_in_r  : SIGNAL is true;
attribute dont_merge of dp_write_scatter_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_fork_in_r : SIGNAL is true;
attribute dont_merge of dp_read_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_vector_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_scatter_in_r : SIGNAL is true;
attribute dont_merge of dp_read_gen_valid_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_data_flow_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_data_type_in_r : SIGNAL is true;
attribute dont_merge of dp_read_stream_in_r : SIGNAL is true;
attribute dont_merge of dp_read_stream_id_in_r : SIGNAL is true;
attribute dont_merge of dp_writedata_in_r : SIGNAL is true;
attribute dont_merge of dp_config_in_r : SIGNAL is true;

attribute preserve : boolean;

attribute preserve of instruction_mu_r : SIGNAL is true;
attribute preserve of instruction_imu_r : SIGNAL is true;
attribute preserve of instruction_mu_valid_r : SIGNAL is true;
attribute preserve of instruction_imu_valid_r : SIGNAL is true;
attribute preserve of vm_r : SIGNAL is true;
attribute preserve of data_model_r : SIGNAL is true;
attribute preserve of tid_r : SIGNAL is true;
attribute preserve of tid_valid1_r : SIGNAL is true;
attribute preserve of pre_tid_r : SIGNAL is true;
attribute preserve of pre_tid_valid1_r : SIGNAL is true;
attribute preserve of pre_pre_tid_r : SIGNAL is true;
attribute preserve of pre_pre_tid_valid1_r : SIGNAL is true;
attribute preserve of pre_pre_vm_r : SIGNAL is true;
attribute preserve of pre_pre_data_model_r : SIGNAL is true;
attribute preserve of pre_iregister_auto_r : SIGNAL is true;

attribute preserve of dp_rd_vm_in_r  : SIGNAL is true;
attribute preserve of dp_wr_vm_in_r : SIGNAL is true;
attribute preserve of dp_code_in_r : SIGNAL is true;
attribute preserve of dp_rd_addr_in_r : SIGNAL is true;
attribute preserve of dp_rd_share_in_r : SIGNAL is true;
attribute preserve of dp_rd_step_in_r : SIGNAL is true;
attribute preserve of dp_wr_addr_in_r  : SIGNAL is true;
attribute preserve of dp_wr_share_in_r : SIGNAL is true;
attribute preserve of dp_wr_step_in_r : SIGNAL is true;
attribute preserve of dp_wr_mcast_in_r : SIGNAL is true;
attribute preserve of dp_write_in_r : SIGNAL is true;
attribute preserve of dp_wr_fork_in_r : SIGNAL is true;
attribute preserve of dp_write_gen_valid_in_r : SIGNAL is true;
attribute preserve of dp_write_vector_in_r  : SIGNAL is true;
attribute preserve of dp_write_scatter_in_r : SIGNAL is true;
attribute preserve of dp_rd_fork_in_r : SIGNAL is true;
attribute preserve of dp_read_in_r  : SIGNAL is true;
attribute preserve of dp_read_vector_in_r  : SIGNAL is true;
attribute preserve of dp_read_scatter_in_r : SIGNAL is true;
attribute preserve of dp_read_gen_valid_in_r  : SIGNAL is true;
attribute preserve of dp_read_data_flow_in_r  : SIGNAL is true;
attribute preserve of dp_read_data_type_in_r : SIGNAL is true;
attribute preserve of dp_read_stream_in_r : SIGNAL is true;
attribute preserve of dp_read_stream_id_in_r : SIGNAL is true;
attribute preserve of dp_writedata_in_r : SIGNAL is true;
attribute preserve of dp_config_in_r : SIGNAL is true;


BEGIN

tid_valid1 <= tid_valid1_r and enable_in;
pre_tid_valid1 <= pre_tid_valid1_r and enable_in;
pre_pre_tid_valid1 <= pre_pre_tid_valid1_r and enable_in;

process(reset_in,clock_in)
begin

if reset_in = '0' then
   dp_rd_vm_in_r <= '0';
   dp_wr_vm_in_r <= '0';
   dp_code_in_r <= '0';
   dp_rd_addr_in_r  <= (others=>'0');
   dp_rd_share_in_r <= '0';
   dp_rd_step_in_r <= (others=>'0');
   dp_wr_addr_in_r <= (others=>'0');
   dp_wr_share_in_r <= '0';
   dp_wr_step_in_r <= (others=>'0');
   dp_wr_mcast_in_r <= (others=>'0');
   dp_write_in_r <= '0';
   dp_wr_fork_in_r <= '0';
   dp_write_gen_valid_in_r <= '0';
   dp_write_vector_in_r <= (others=>'0');
   dp_write_scatter_in_r <= (others=>'0');
   dp_rd_fork_in_r <= '0';
   dp_read_in_r <= '0';
   dp_read_vector_in_r <= (others=>'0');
   dp_read_scatter_in_r <= (others=>'0');
   dp_read_gen_valid_in_r <= '0';
   dp_read_data_flow_in_r <= (others=>'0');
   dp_read_data_type_in_r <= (others=>'0');
   dp_read_stream_in_r  <= '0';
   dp_read_stream_id_in_r <= (others=>'0');
   dp_writedata_in_r <= (others=>'0');
   dp_config_in_r <= '0';
else
   if clock_in'event and clock_in='1' then
      dp_rd_vm_in_r <= dp_rd_vm_in;
      dp_wr_vm_in_r <= dp_wr_vm_in;
      dp_code_in_r <= dp_code_in;
      dp_rd_addr_in_r  <= dp_rd_addr_in;
      dp_rd_share_in_r <= dp_rd_share_in;
      dp_rd_step_in_r <= dp_rd_addr_step_in;
      dp_wr_addr_in_r <= dp_wr_addr_in;
      dp_wr_share_in_r <= dp_wr_share_in;
      dp_wr_step_in_r <= dp_wr_addr_step_in;
      dp_wr_mcast_in_r <= dp_wr_mcast_in;
      dp_write_in_r <= dp_write_in;
      dp_wr_fork_in_r <= dp_wr_fork_in;
      dp_write_gen_valid_in_r <= dp_write_gen_valid_in;
      dp_write_vector_in_r <= dp_write_vector_in;
      dp_write_scatter_in_r <= dp_write_scatter_in;
      dp_rd_fork_in_r <= dp_rd_fork_in;
      dp_read_in_r <= dp_read_in;
      dp_read_vector_in_r <= dp_read_vector_in;
      dp_read_scatter_in_r <= dp_read_scatter_in;
      dp_read_gen_valid_in_r <= dp_read_gen_valid_in;
      dp_read_data_flow_in_r <= dp_read_data_flow_in;
      dp_read_data_type_in_r <= dp_read_data_type_in;
      dp_read_stream_in_r  <= dp_read_stream_in;
      dp_read_stream_id_in_r <= dp_read_stream_id_in;
      dp_writedata_in_r <= dp_writedata_in;
      dp_config_in_r <= dp_config_in_in;
   end if;
end if;
end process;


process(dp_wr_addr_in_r,dp_write_in_r,dp_wr_fork_in_r,dp_wr_mcast_in_r,dp_code_in_r,dp_config_in_r)
variable mcast_addr_v:mcast_addr_t;
variable myaddr_v:mcast_addr_t;
variable mcast_v:mcast_addr_t;
variable mcast_mode_v:std_logic;
variable to_addr_v:mcast_addr_t;
begin
   mcast_v := dp_wr_mcast_in_r(mcast_addr_t'length-1 downto 0);
   mcast_mode_v := dp_wr_mcast_in_r(mcast_t'length-1);
   mcast_addr_v := dp_wr_addr_in_r(register_depth_c+mcast_addr_v'length+tid_t'length-1 downto register_depth_c+tid_t'length);
   if dp_wr_fork_in_r='0' then
      myaddr_v(myaddr_v'length-1 downto pid_t'length) := std_logic_vector(to_unsigned(CID,cid_t'length));
   else
      myaddr_v(myaddr_v'length-1 downto pid_t'length) := (others=>'0');
   end if;
   myaddr_v(pid_t'length-1 downto 0) := std_logic_vector(to_unsigned(PID,pid_t'length));
   to_addr_v := std_logic_vector(unsigned(mcast_addr_v)+unsigned(mcast_v));
   if( (dp_write_in_r='1') and (dp_code_in_r='0') and (dp_config_in_r='0') and
	  (
	  (mcast_mode_v='1' and (mcast_v and mcast_addr_v)=(mcast_v and myaddr_v))
	  or 
	  (mcast_mode_v='0' and (unsigned(myaddr_v) >= unsigned(mcast_addr_v)) and (unsigned(myaddr_v) <= unsigned(to_addr_v)))
      )
	  ) then
      write_match <= '1';
   else
      write_match <= '0';
   end if;
end process;

process(read_scatter_cnt_r,dp_rd_vm_in_r,dp_rd_addr_in_r,
        dp_read_in_r,dp_read_vector_in_r,dp_read_scatter_in_r,dp_read_gen_valid_in_r,dp_read_data_flow_in_r,
        dp_read_stream_in_r,dp_read_stream_id_in_r,
        dp_rd_vm_r,dp_rd_addr_r,
        dp_read_r,dp_read_vector_r,dp_read_scatter_r,dp_read_gen_valid_r,dp_read_data_flow_r,dp_read_data_type_r,
        dp_read_stream_r,dp_read_stream_id_r,
        read_scatter_vector_r,
        read_match,dp_read_data_type_in_r,dp_read_share_r,dp_read_step_r,dp_rd_share_in_r,dp_rd_step_in_r,
		dp_rd_fork_in_r,dp_rd_fork_r)
begin
if (read_scatter_cnt_r = to_unsigned(0,read_scatter_cnt_r'length)) then
   -- Latch in the new read request
   dp_rd_vm_2 <= dp_rd_vm_in_r;
   dp_rd_fork_2 <= dp_rd_fork_in_r;
   dp_rd_addr_2 <= dp_rd_addr_in_r;
   dp_read_2 <= dp_read_in_r;
   if dp_read_scatter_in_r/=scatter_none_c then
      dp_read_vector_2 <= (others=>'0');
   else
      dp_read_vector_2 <= unsigned(dp_read_vector_in_r);
   end if;
   dp_read_scatter_2 <= dp_read_scatter_in_r;
   dp_read_share_2 <= dp_rd_share_in_r;
   dp_read_step_2 <= dp_rd_step_in_r;
   dp_read_step_2 <= dp_rd_step_in_r;
   dp_read_gen_valid_2 <= dp_read_gen_valid_in_r;
   dp_read_data_flow_2 <= dp_read_data_flow_in_r;
   dp_read_data_type_2 <= dp_read_data_type_in_r;
   dp_read_stream_2 <= dp_read_stream_in_r;
   dp_read_stream_id_2 <= dp_read_stream_id_in_r;
   if (read_match='1' and dp_read_scatter_in_r/=scatter_none_c and dp_read_gen_valid_in_r='1') then
      read_scatter_cnt_2 <= unsigned(dp_read_vector_in_r);
      read_scatter_vector_2 <= unsigned(dp_read_vector_in_r);
   else
      read_scatter_cnt_2 <= (others=>'0');
      read_scatter_vector_2 <= (others=>'0');
   end if;
else
   -- Continue with the scatter read....
   dp_rd_vm_2 <= dp_rd_vm_r;
   dp_rd_fork_2 <= dp_rd_fork_r;
   dp_rd_addr_2 <= dp_rd_addr_r;
   dp_read_2 <= dp_read_r;
   dp_read_vector_2 <= dp_read_vector_r;
   dp_read_scatter_2 <= dp_read_scatter_r;
   dp_read_share_2 <= dp_read_share_r;
   dp_read_step_2 <= dp_read_step_r;
   dp_read_step_2 <= dp_read_step_r;
   dp_read_gen_valid_2 <= dp_read_gen_valid_r;
   dp_read_data_flow_2 <= dp_read_data_flow_r;
   dp_read_data_type_2 <= dp_read_data_type_r;
   dp_read_stream_2 <= dp_read_stream_r;
   dp_read_stream_id_2 <= dp_read_stream_id_r;
   read_scatter_cnt_2 <= read_scatter_cnt_r-to_unsigned(1,read_scatter_cnt_r'length);
   read_scatter_vector_2 <= read_scatter_vector_r;
end if;
end process;

process(write_scatter_cnt_r,write_scatter_curr_r,dp_wr_vm_in_r,dp_wr_addr_in_r,dp_wr_mcast_in_r,dp_write_in_r,dp_code_in_r,dp_config_in_r,
        dp_write_vector_in_r,dp_write_scatter_in_r,dp_writedata_in_r,
        dp_wr_vm_r,dp_wr_fork_r,dp_wr_addr_r,dp_wr_mcast_r,dp_write_r,dp_write_vector_r,dp_write_scatter_r,dp_write_share_r,dp_write_step_r,
        dp_writedata_r,write_match,dp_write_gen_valid_in_r,dp_write_gen_valid_r,
		  write_scatter_vector_r,dp_wr_share_in_r,dp_wr_step_in_r,dp_wr_fork_in_r)
begin
if write_scatter_cnt_r = to_unsigned(0,write_scatter_cnt_r'length) then
   -- Latch in new write request....
   dp_wr_vm_2 <= dp_wr_vm_in_r;
   dp_wr_fork_2 <= dp_wr_fork_in_r;
   dp_wr_addr_2 <= dp_wr_addr_in_r;
   dp_wr_mcast_2 <= dp_wr_mcast_in_r;        
   dp_write_2 <= dp_write_in_r and (not dp_code_in_r) and (not dp_config_in_r);
   if dp_write_scatter_in_r/=scatter_none_c then
      dp_write_vector_2 <= (others=>'0');
   else
      dp_write_vector_2 <= unsigned(dp_write_vector_in_r);
   end if;
   dp_write_gen_valid_2 <= dp_write_gen_valid_in_r;
   dp_write_scatter_2 <= dp_write_scatter_in_r;
   dp_write_share_2 <= dp_wr_share_in_r;
   dp_write_step_2 <= dp_wr_step_in_r;
   dp_writedata_2 <= dp_writedata_in_r;
   if (write_match='1' and dp_write_scatter_in_r/=scatter_none_c and dp_write_gen_valid_in_r='1') then
      write_scatter_cnt_2 <= unsigned(dp_write_vector_in_r);
      write_scatter_vector_2 <= unsigned(dp_write_vector_in_r);
      write_scatter_curr_2 <= (others=>'0');
   else
      write_scatter_cnt_2 <= (others=>'0');
      write_scatter_vector_2 <= (others=>'0');
      write_scatter_curr_2 <= (others=>'0');
   end if;
else
   --- Continue with the scatter write....
   dp_wr_vm_2 <= dp_wr_vm_r;
   dp_wr_fork_2 <= dp_wr_fork_r;
   dp_wr_addr_2 <= dp_wr_addr_r;
   dp_wr_mcast_2 <= dp_wr_mcast_r;        
   dp_write_2 <= dp_write_r;
   dp_write_vector_2 <= dp_write_vector_r;
   dp_write_gen_valid_2 <= dp_write_gen_valid_r;
   dp_write_scatter_2 <= dp_write_scatter_r;
   dp_write_share_2 <= dp_write_share_r;
   dp_write_step_2 <= dp_write_step_r;
   dp_writedata_2 <= dp_writedata_r;
   write_scatter_cnt_2 <= write_scatter_cnt_r-to_unsigned(1,write_scatter_cnt_r'length);
   write_scatter_vector_2 <= write_scatter_vector_r;
   write_scatter_curr_2 <= write_scatter_curr_r+to_unsigned(1,write_scatter_curr_r'length);
end if;
end process;

process(reset_in,clock_in)
variable addr_v:unsigned(local_bus_width_c-1 DOWNTO 0);
begin
   if reset_in = '0' then
      dp_rd_vm_r <= '0';
      dp_rd_fork_r <= '0';
      dp_rd_addr_r <= (others=>'0');
      dp_read_r <= '0';
      dp_read_vector_r <= (others=>'0');
      dp_read_scatter_r <= (others=>'0');
      dp_read_gen_valid_r <= '0';
      dp_read_data_flow_r <= (others=>'0');
      dp_read_data_type_r <= (others=>'0');
      read_scatter_cnt_r <= (others=>'0');
      read_scatter_vector_r <= (others=>'0');
      dp_read_stream_r <= '0';
      dp_read_stream_id_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         assert (not (read_match='1' and (read_scatter_cnt_r /= to_unsigned(0,read_scatter_cnt_r'length)))) report "pcore read access error" severity error;
         if dp_read_scatter_2=scatter_vector_c then
            if dp_read_share_2='0' then
               addr_v := unsigned(dp_rd_addr_2)+unsigned(dp_read_step_2);
            else
               addr_v := unsigned(dp_rd_addr_2)-to_unsigned(vector_width_c,dp_rd_addr_r'length);
            end if;
         else
            addr_v := unsigned(dp_rd_addr_2)+to_unsigned(vector_width_c,dp_rd_addr_r'length);
         end if;
         dp_rd_addr_r <= std_logic_vector(addr_v);
         if read_scatter_cnt_r = to_unsigned(0,read_scatter_cnt_r'length) then
            -- Begin of a scatter read
            dp_rd_vm_r <= dp_rd_vm_2;
            dp_rd_fork_r <= dp_rd_fork_2;
            dp_read_r <= dp_read_2;
            dp_read_vector_r <= dp_read_vector_2;
            dp_read_scatter_r <= dp_read_scatter_2;
            dp_read_share_r <= dp_read_share_2;
            dp_read_step_r <= dp_read_step_2;
            dp_read_gen_valid_r <= dp_read_gen_valid_2;
            dp_read_data_flow_r <= dp_read_data_flow_2;
            dp_read_data_type_r <= dp_read_data_type_2;
            dp_read_stream_r <= dp_read_stream_2;
            dp_read_stream_id_r <= dp_read_stream_id_2;
            read_scatter_cnt_r <= read_scatter_cnt_2;
            read_scatter_vector_r <= read_scatter_vector_2;
         else
            -- Update the scatter read
            read_scatter_cnt_r <= read_scatter_cnt_2;
            read_scatter_vector_r <= read_scatter_vector_2;
         end if;
      end if;
   end if;
end process;


process(reset_in,clock_in)
begin
   if reset_in = '0' then
         dp_read_vector_2_r <= (others=>'0');
         dp_read_scatter_2_r <= (others=>'0');
         dp_read_share_2_r <= '0';
         dp_read_step_2_r <= (others=>'0');
         read_scatter_cnt_2_r <= (others=>'0');
         read_scatter_vector_2_r <= (others=>'0');
         dp_read_gen_valid_2_r <= '0';
         dp_read_data_flow_2_r <= (others=>'0');
         dp_read_data_type_2_r <= (others=>'0');
         dp_read_stream_2_r <= '0';
         dp_read_stream_id_2_r <= (others=>'0');
         dp_rd_addr_2_r <= (others=>'0');
         dp_write_vector_2_r <= (others=>'0');
         dp_wr_addr_2_r <= (others=>'0');
         dp_writedata_3_r <= (others=>'0');
         dp_write_2_r <= '0';
         dp_write_vm_2_r <= '0';
         dp_write_fork_2_r <= '0';
         dp_read_fork_2_r <= '0';
         dp_read_2_r <= '0';
         dp_read_vm_2_r <= '0';
   else
      if clock_in'event and clock_in='1' then
         dp_read_vector_2_r <= dp_read_vector_2;
         dp_read_scatter_2_r <= dp_read_scatter_2;
         dp_read_share_2_r <= dp_read_share_2;
         dp_read_step_2_r <= dp_read_step_2;
         read_scatter_cnt_2_r <= read_scatter_cnt_2;
         read_scatter_vector_2_r <= read_scatter_vector_2;
         dp_read_gen_valid_2_r <= dp_read_gen_valid_2;
         dp_read_data_flow_2_r <= dp_read_data_flow_2;
         dp_read_data_type_2_r <= dp_read_data_type_2;
         dp_read_stream_2_r <= dp_read_stream_2;
         dp_read_stream_id_2_r <= dp_read_stream_id_2;
         dp_rd_addr_2_r <= dp_rd_addr_2;
         dp_write_vector_2_r <= dp_write_vector_2;
         dp_wr_addr_2_r <= dp_wr_addr_2;
         dp_writedata_3_r <= dp_writedata_3;

         dp_write_2_r <= dp_write;
         dp_write_vm_2_r <= dp_wr_vm_2;
         dp_write_fork_2_r <= dp_wr_fork_2;
         dp_read_2_r <= dp_read;
         dp_read_vm_2_r <= dp_rd_vm_2;
         dp_read_fork_2_r <= dp_rd_fork_2;
      end if;
   end if;
end process;

process(reset_in,clock_in)
variable addr_v:unsigned(local_bus_width_c-1 DOWNTO 0);
begin
   if reset_in = '0' then
      dp_wr_vm_r <= '0';
      dp_wr_fork_r <= '0';
      dp_wr_addr_r <= (others=>'0');
      dp_wr_mcast_r <= (others=>'0');        
      dp_write_r <= '0';
      dp_write_gen_valid_r <= '0';
      dp_write_vector_r <= (others=>'0');
      dp_write_scatter_r <= (others=>'0');
      dp_write_share_r <= '0';
      dp_write_step_r <= (others=>'0');
      dp_writedata_r <= (others=>'0');
      write_scatter_cnt_r <= (others=>'0');
      write_scatter_vector_r <= (others=>'0');
      write_scatter_curr_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         assert (not (write_match='1' and (write_scatter_cnt_r /= to_unsigned(0,write_scatter_cnt_r'length)))) report "pcore write access error" severity error;
         if dp_write_scatter_2=scatter_vector_c then
            if dp_write_share_2='0' then
               addr_v := unsigned(dp_wr_addr_2)+unsigned(dp_write_step_2);
            else
               addr_v := unsigned(dp_wr_addr_2)-to_unsigned(vector_width_c,dp_wr_addr_r'length);
            end if;
         else
            addr_v := unsigned(dp_wr_addr_2)+to_unsigned(vector_width_c,dp_wr_addr_r'length);
         end if;
         dp_wr_addr_r <= std_logic_vector(addr_v);
         if write_scatter_cnt_r = to_unsigned(0,write_scatter_cnt_r'length) then
            -- Begin of a scatter write
            dp_wr_vm_r <= dp_wr_vm_2;
            dp_wr_fork_r <= dp_wr_fork_2;
            dp_wr_mcast_r <= dp_wr_mcast_2;        
            dp_write_r <= dp_write_2;
            dp_write_vector_r <= dp_write_vector_2;
            dp_write_gen_valid_r <= dp_write_gen_valid_2;
            dp_write_scatter_r <= dp_write_scatter_2;
            dp_write_share_r <= dp_write_share_2;
            dp_write_step_r <= dp_write_step_2;
            dp_writedata_r <= dp_writedata_2;
         end if;
         -- Continuation of a scatter write....
         write_scatter_cnt_r <= write_scatter_cnt_2;
         write_scatter_vector_r <= write_scatter_vector_2;
         write_scatter_curr_r <= write_scatter_curr_2;
      end if;
   end if;
end process;

process(dp_write_scatter_2,dp_write_share_2,dp_write_step_2,write_scatter_cnt_2,write_scatter_curr_2,dp_writedata_2,write_scatter_vector_2)
variable cnt_v:unsigned(ddr_vector_depth_c-1 downto 0);
begin
cnt_v := write_scatter_curr_2;
if dp_write_scatter_2/=scatter_none_c then
   case cnt_v is
      when "111" =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(8*register_width_c-1 downto 7*register_width_c);
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');
      when "110" =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(7*register_width_c-1 downto 6*register_width_c); 
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');  
      when "101" =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(6*register_width_c-1 downto 5*register_width_c);
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');
      when "100" =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(5*register_width_c-1 downto 4*register_width_c); 
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');  
      when "011" =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(4*register_width_c-1 downto 3*register_width_c); 
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');  
      when "010" =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(3*register_width_c-1 downto 2*register_width_c); 
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');  
      when "001" =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(2*register_width_c-1 downto 1*register_width_c); 
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');  
      when others =>
         dp_writedata_3(register_width_c-1 downto 0) <= dp_writedata_2(1*register_width_c-1 downto 0*register_width_c); 
         dp_writedata_3(ddrx_data_width_c-1 downto register_width_c) <= (others=>'0');  
   end case;
else
   dp_writedata_3 <= dp_writedata_2;
end if;
end process;


-- There should not be an PCORE access while at the middle of a scatter transaction


error_write <= '1' when write_match='1' and (write_scatter_cnt_r /= to_unsigned(0,write_scatter_cnt_r'length)) else '0';
error_read <= '1' when read_match='1' and (read_scatter_cnt_r /= to_unsigned(0,write_scatter_cnt_r'length)) else '0';

process(dp_rd_addr_in_r,dp_read_in_r,dp_rd_fork_in_r)
variable pid_v:pid_t;
variable cid_v:cid_t;
begin
pid_v := unsigned(dp_rd_addr_in_r(bus_width_c-cid_t'length-1 DOWNTO register_depth_c+tid_t'length));
cid_v := unsigned(dp_rd_addr_in_r(bus_width_c-1 DOWNTO bus_width_c-cid_t'length));
if dp_rd_fork_in_r='0' then
   if( dp_read_in_r='1' and pid_v=to_unsigned(PID,pid_t'length) and cid_v=to_unsigned(CID,cid_t'length)) then
      read_match <= '1';
   else
      read_match <= '0';
   end if;
else
   if( dp_read_in_r='1' and pid_v=to_unsigned(PID,pid_t'length)) then
      read_match <= '1';
   else
      read_match <= '0';
   end if;
end if;
end process;


-------
--- Decode read/write access from DP
-------

dp_readena_out <= dp_readena_r;
dp_read_gen_valid_out <= dp_read_gen_valid2_r;
dp_read_data_flow_out <= dp_read_data_flow2_r when dp_readena_r='1' else (others=>'0');
dp_read_data_type_out <= dp_read_data_type2_r when dp_readena_r='1' else (others=>'0');
dp_read_stream_out <= dp_read_stream2_r when dp_readena_r='1' else '0';
dp_read_stream_id_out <= dp_read_stream_id2_r when dp_readena_r='1' else (others=>'0');

dp_read_vector_out <= dp_read_vector2_r when dp_readena_r='1' else (others=>'Z');
dp_read_vaddr_out <= dp_read_vaddr2_r when dp_readena_r='1' else (others=>'Z');


dp_rd_pid <= unsigned(dp_rd_addr_2(bus_width_c-cid_t'length-1 DOWNTO register_depth_c+tid_t'length));
dp_rd_cid <= unsigned(dp_rd_addr_2(bus_width_c-1 DOWNTO bus_width_c-cid_t'length));

dp_mcast_addr <= dp_wr_addr_2(register_depth_c+dp_mcast_addr'length+tid_t'length-1 downto register_depth_c+tid_t'length);



process(dp_readena_r,dp_read_gen_valid2_r,dp_readdata_r,dp_readdata2_r,dp_readdata_vm_r)
begin
if dp_readena_r='0' then
   dp_readdata_out <= (others=>'Z');
   dp_readdata_vm_out <= 'Z';
else
   if dp_read_gen_valid2_r='1' then
      dp_readdata_out <= dp_readdata_r;
   else
      dp_readdata_out <= dp_readdata2_r;
   end if;
   dp_readdata_vm_out <= dp_readdata_vm_r;
end if;
end process;


process(clock_in,reset_in)
variable cnt_v:unsigned(ddr_vector_depth_c-1 downto 0);
begin
    if reset_in='0' then
       instruction_mu_r <= (others=>'0');
       instruction_imu_r <= (others=>'0');
       instruction_mu_valid_r <= '0';
       instruction_imu_valid_r <= '0';
       vm_r <= '0';
       data_model_r <= (others=>'0');
       tid_r <= (others=>'0');
       tid_valid1_r <= '0';
       pre_tid_r <= (others=>'0');
       pre_tid_valid1_r <= '0';
       pre_pre_tid_r <= (others=>'0');
       pre_pre_tid_valid1_r <= '0';
       pre_pre_vm_r <= '0';
       pre_pre_data_model_r <= (others=>'0');
       pre_iregister_auto_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
           instruction_mu_r <= instruction_mu_in;
           instruction_imu_r <= instruction_imu_in;
           instruction_mu_valid_r <= instruction_mu_valid_in;
           instruction_imu_valid_r <= instruction_imu_valid_in;
           vm_r <= vm_in;
           data_model_r <= data_model_in;
           tid_r <= tid_in;
           tid_valid1_r <= tid_valid1_in;
           pre_tid_r <= pre_tid_in;
           pre_tid_valid1_r <= pre_tid_valid1_in;
           pre_pre_tid_r <= pre_pre_tid_in;
           pre_pre_tid_valid1_r <= pre_pre_tid_valid1_in;
           pre_pre_vm_r <= pre_pre_vm_in;
           pre_pre_data_model_r <= pre_pre_data_model_in;
           pre_iregister_auto_r <= pre_iregister_auto_in;
        end if;
    end if;
end process;

process(clock_in,reset_in)
variable cnt_v:unsigned(ddr_vector_depth_c-1 downto 0);
begin
    if reset_in='0' then
        dp_readena_r <= '0';
        dp_readdata_r <= (others=>'0');
        dp_readdata_vm_r <= '0';
        dp_readdata2_r <= (others=>'0');
        dp_read_gen_valid2_r <= '0';
        dp_read_data_flow2_r <= (others=>'0');
        dp_read_data_type2_r <= (others=>'0');
        dp_read_stream2_r <= '0';
        dp_read_stream_id2_r <= (others=>'0');
        dp_read_vector2_r <= (others=>'0');
        dp_read_vaddr2_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            dp_readdata_vm_r <= dp_readdata_vm_vm;
            if dp_readena_vm='1' then
                if dp_read_scatter_vm/=scatter_none_c then
                   cnt_v := dp_read_scatter_vector_vm-dp_read_scatter_cnt_vm;
                   case cnt_v is
                      when "111" =>
                         dp_readdata_r(8*register_width_c-1 downto 7*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                      when "110" =>
                         dp_readdata_r(7*register_width_c-1 downto 6*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                      when "101" =>
                         dp_readdata_r(6*register_width_c-1 downto 5*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                      when "100" =>
                         dp_readdata_r(5*register_width_c-1 downto 4*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                      when "011" =>
                         dp_readdata_r(4*register_width_c-1 downto 3*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                      when "010" =>
                         dp_readdata_r(3*register_width_c-1 downto 2*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                      when "001" =>
                         dp_readdata_r(2*register_width_c-1 downto 1*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                      when others =>
                         dp_readdata_r(1*register_width_c-1 downto 0*register_width_c) <= dp_readdata_vm(register_width_c-1 downto 0);
                   end case;
                   if dp_read_scatter_cnt_vm=to_unsigned(0,dp_read_scatter_cnt_vm'length) then
                      dp_readena_r <= '1';
                   else
                      dp_readena_r <= '0';
                   end if;
                   dp_read_vector2_r <= (others=>'0');
                   dp_read_vaddr2_r <= (others=>'0');
                else
                   dp_read_vector2_r <= dp_read_vector_vm;
                   dp_read_vaddr2_r <= dp_read_vaddr_vm;
                   if dp_read_gen_valid_vm='1' then
                      dp_readdata_r <= dp_readdata_vm;
                   else
                      dp_readdata2_r <= dp_readdata_vm;
                   end if;
                   dp_readena_r <= '1';
                end if;
                dp_read_gen_valid2_r <= dp_read_gen_valid_vm;
                dp_read_data_flow2_r <= dp_read_data_flow_vm;
                dp_read_data_type2_r <= dp_read_data_type_vm;
                dp_read_stream2_r <= dp_read_stream_vm;
                dp_read_stream_id2_r <= dp_read_stream_id_vm;
            else
               dp_readena_r <= '0';
            end if;
        end if;
    end if;
end process;

result_write_addr <= wr_result_addr1;

----
-- Component to hold returned integer values from MU units
-----

flag_i: flag port map(
        clock_in => clock_in,
        reset_in => reset_in, 
        write_result_vector_in => wr_vector,
		write_result_lane_in => wr_vector_lane,
        write_addr_in => result_write_addr, 
        write_vm_in =>wr_vm,
        write_result_ena_in => wr_flag1,
        write_xreg_ena_in => wr_xreg1,
        write_data_in => mu_y,
        write_result_in => mu_result,
        read_addr_in => result_raddr1,
        read_vm_in => result_read_vm,
        read_result_out => result_read,
        read_xreg_out => xreg_read
        );

---------
-- Instantiate IREGISTER file
-- Access to IREGISTER file has 1 clock latency
-- Use instruction_pre_tid_in info to prefetch IREGISTER values for use in next cycle
---------

iregister_i: iregister_file port map(
            clock_in=>clock_in,
            reset_in=>reset_in,

            rd_en1_in=>i_rd_en1,
            rd_vm_in=>i_rd_vm,
            rd_tid1_in=>i_rd_tid1,
            rd_data1_out=>i_rd_data1,

            rd_lane_out=>rd_lane,

            wr_tid1_in=>i_wr_tid1,
            wr_en1_in=>i_wr_en1,
            wr_vm_in=>i_wr_vm,
            wr_lane_in=>wr_lane,
            wr_addr1_in=>i_wr_addr1,
            wr_data1_in=>i_wr_data1
            );

------
-- Decode DP read access
------

process(dp_read_2,dp_rd_pid,dp_rd_cid,dp_rd_fork_2)
begin
if dp_rd_fork_2='0' then
   if( dp_read_2='1' and dp_rd_pid=to_unsigned(PID,pid_t'length) and dp_rd_cid=to_unsigned(CID,cid_t'length)) then 
      dp_read <= '1';
   else
      dp_read <= '0';
   end if;
else
   if( dp_read_2='1' and dp_rd_pid=to_unsigned(PID,pid_t'length)) then 
      dp_read <= '1';
   else
      dp_read <= '0';
   end if;
end if;
end process;

------
-- Decode DP write access
------

process(dp_write_2,dp_mcast_addr,dp_wr_mcast_2,dp_wr_fork_2)
variable mcast_v:mcast_addr_t;
variable mcast_mode_v:std_logic;
variable to_addr_v:mcast_addr_t;
variable myaddr_v:mcast_addr_t;    
begin
mcast_v := dp_wr_mcast_2(mcast_addr_t'length-1 downto 0);
mcast_mode_v := dp_wr_mcast_2(mcast_t'length-1);
to_addr_v := std_logic_vector(unsigned(dp_mcast_addr)+unsigned(mcast_v));

if dp_wr_fork_2='1' then
   myaddr_v := std_logic_vector(to_unsigned(0,cid_t'length)) & std_logic_vector(to_unsigned(PID,pid_t'length));
else
   myaddr_v := std_logic_vector(to_unsigned(CID,cid_t'length)) & std_logic_vector(to_unsigned(PID,pid_t'length));
end if;

if( (dp_write_2='1') and    
	( 
    (mcast_mode_v='1' and (mcast_v and dp_mcast_addr)=(mcast_v and myaddr_v))
	or
    (mcast_mode_v='0' and (unsigned(myaddr_v) >= unsigned(dp_mcast_addr)) and (unsigned(myaddr_v) <= unsigned(to_addr_v)))
    )
	) then
    dp_write <= '1';
else
    dp_write <= '0';
end if;
end process;

--------
--- Instantiate MU#0
--------

mu_0_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(accumulator_width_c-1 downto 0),
                                x1_in=>mu_x1(register_width_c-1 downto 0),
                                x2_in=>mu_x2(register_width_c-1 downto 0),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(accumulator_width_c-1 downto 0),
                                y2_out=>mu_result(0),
                                y3_out=>mu_y2(register_width_c-1 downto 0));

mu_1_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(2*accumulator_width_c-1 downto 1*accumulator_width_c),
                                x1_in=>mu_x1(2*register_width_c-1 downto 1*register_width_c),
                                x2_in=>mu_x2(2*register_width_c-1 downto 1*register_width_c),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(2*accumulator_width_c-1 downto 1*accumulator_width_c),
                                y2_out=>mu_result(1),
                                y3_out=>mu_y2(2*register_width_c-1 downto 1*register_width_c));

mu_2_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(3*accumulator_width_c-1 downto 2*accumulator_width_c),
                                x1_in=>mu_x1(3*register_width_c-1 downto 2*register_width_c),
                                x2_in=>mu_x2(3*register_width_c-1 downto 2*register_width_c),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(3*accumulator_width_c-1 downto 2*accumulator_width_c),
                                y2_out=>mu_result(2),
                                y3_out=>mu_y2(3*register_width_c-1 downto 2*register_width_c));

mu_3_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(4*accumulator_width_c-1 downto 3*accumulator_width_c),
                                x1_in=>mu_x1(4*register_width_c-1 downto 3*register_width_c),
                                x2_in=>mu_x2(4*register_width_c-1 downto 3*register_width_c),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(4*accumulator_width_c-1 downto 3*accumulator_width_c),
                                y2_out=>mu_result(3),
                                y3_out=>mu_y2(4*register_width_c-1 downto 3*register_width_c));

mu_4_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(5*accumulator_width_c-1 downto 4*accumulator_width_c),
                                x1_in=>mu_x1(5*register_width_c-1 downto 4*register_width_c),
                                x2_in=>mu_x2(5*register_width_c-1 downto 4*register_width_c),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(5*accumulator_width_c-1 downto 4*accumulator_width_c),
                                y2_out=>mu_result(4),
                                y3_out=>mu_y2(5*register_width_c-1 downto 4*register_width_c));

mu_5_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(6*accumulator_width_c-1 downto 5*accumulator_width_c),
                                x1_in=>mu_x1(6*register_width_c-1 downto 5*register_width_c),
                                x2_in=>mu_x2(6*register_width_c-1 downto 5*register_width_c),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(6*accumulator_width_c-1 downto 5*accumulator_width_c),
                                y2_out=>mu_result(5),
                                y3_out=>mu_y2(6*register_width_c-1 downto 5*register_width_c));

mu_6_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(7*accumulator_width_c-1 downto 6*accumulator_width_c),
                                x1_in=>mu_x1(7*register_width_c-1 downto 6*register_width_c),
                                x2_in=>mu_x2(7*register_width_c-1 downto 6*register_width_c),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(7*accumulator_width_c-1 downto 6*accumulator_width_c),
                                y2_out=>mu_result(6),
                                y3_out=>mu_y2(7*register_width_c-1 downto 6*register_width_c));

mu_7_i: mu_adder port map(clock_in=>clock_in,
                                reset_in=>reset_in,
                                mu_opcode_in=>mu_opcodes,
                                mu_tid_in=>mu_tid,
                                xreg_in=>xreg_read(8*accumulator_width_c-1 downto 7*accumulator_width_c),
                                x1_in=>mu_x1(8*register_width_c-1 downto 7*register_width_c),
                                x2_in=>mu_x2(8*register_width_c-1 downto 7*register_width_c),
                                x_scalar_in=>mu_x_scalar,
                                y_out=>mu_y(8*accumulator_width_c-1 downto 7*accumulator_width_c),
                                y2_out=>mu_result(7),
                                y3_out=>mu_y2(8*register_width_c-1 downto 7*register_width_c));

-----
-- Instantiate IMU for integer arithmetic
------

i_y_neg_out <= i_y_neg and enable_in;
i_y_zero_out <= i_y_zero and enable_in;

ialu_i: ialu port map( clock_in => clock_in,
                        reset_in => reset_in,
                        opcode_in => i_opcode,
                        x1_in => i_x1,
                        x2_in => i_x2,
                        y_out => i_y,
                        y_neg_out => i_y_neg,
                        y_zero_out => i_y_zero
                        );

 result_vector <= rd_x1_vector1 or rd_x2_vector1;

register_bank_i: register_bank port map(
        clock_in => clock_in,
        reset_in => reset_in,

        rd_en_in => rd_en1,
        rd_en_vm_in => rd_vm,
        rd_en_out => rd_enable1,
        rd_x1_vector_in => rd_x1_vector1,
        rd_x1_addr_in => rd_x1_addr1,
        rd_x2_vector_in => rd_x2_vector1,
        rd_x2_addr_in => rd_x2_addr1,
        rd_x1_data_out => rd_x1_data1,
        rd_x2_data_out => rd_x2_data1,

        wr_en_in => wr_en1,
        wr_en_vm_in => wr_vm,
        wr_vector_in => wr_vector,
        wr_addr_in => wr_addr1(register_file_depth_c-1 downto 0),
        wr_data_in => wr_data1,
        wr_lane_in => wr_vector_lane,

        -- DP interface
        dp_rd_vector_in => dp_read_vector_2_r,
        dp_rd_scatter_in => dp_read_scatter_2_r,
        dp_rd_scatter_cnt_in => read_scatter_cnt_2_r,
        dp_rd_scatter_vector_in => read_scatter_vector_2_r,
        dp_rd_gen_valid_in => dp_read_gen_valid_2_r,
        dp_rd_data_flow_in => dp_read_data_flow_2_r,
        dp_rd_data_type_in => dp_read_data_type_2_r,
        dp_rd_stream_in => dp_read_stream_2_r,
        dp_rd_stream_id_in => dp_read_stream_id_2_r,
        dp_rd_addr_in => dp_rd_addr_2_r(bus_width_c-1 downto 0),
        dp_wr_vector_in => dp_write_vector_2_r,
        dp_wr_addr_in => dp_wr_addr_2_r(bus_width_c-1 downto 0),
        dp_write_in => dp_write_2_r,
        dp_write_vm_in => dp_write_vm_2_r,
        dp_read_in => dp_read_2_r,
        dp_read_vm_in => dp_read_vm_2_r,
        dp_writedata_in => dp_writedata_3_r,
        dp_readdata_out => dp_readdata_vm,
        dp_readdata_vm_out => dp_readdata_vm_vm,
        dp_readena_out => dp_readena_vm,
        dp_read_vector_out => dp_read_vector_vm,
        dp_read_vaddr_out => dp_read_vaddr_vm,
        dp_read_scatter_out => dp_read_scatter_vm,
        dp_read_scatter_cnt_out => dp_read_scatter_cnt_vm,
        dp_read_scatter_vector_out => dp_read_scatter_vector_vm,
        dp_read_gen_valid_out => dp_read_gen_valid_vm,
        dp_read_data_flow_out => dp_read_data_flow_vm,
        dp_read_data_type_out => dp_read_data_type_vm,
        dp_read_stream_out => dp_read_stream_vm,
        dp_read_stream_id_out => dp_read_stream_id_vm
        );

--------
-- Instantiate DECODE stage
-- Decode instructions
-- Dispatch instructions to dispatch stage 
---------

instr_decoder2_i: instr_decoder2 generic map(
                                    CID=>CID,
                                    PID=>PID
                                    )
                                port map(
                                            clock_in => clock_in,
                                            reset_in    => reset_in,
                                            instruction_mu_in => instruction_mu_r,
                                            instruction_imu_in => instruction_imu_r,
                                            instruction_mu_valid_in => instruction_mu_valid_r,
                                            instruction_imu_valid_in => instruction_imu_valid_r,
                                            instruction_tid_in =>tid_r,
                                            instruction_tid_valid_in=>tid_valid1,
                                            instruction_vm_in=>vm_r,
											instruction_data_model_in=>data_model_r,
                                            instruction_pre_pre_vm_in =>pre_pre_vm_r,
											instruction_pre_pre_data_model_in => pre_pre_data_model_r,
                                            instruction_pre_tid_in =>pre_tid_r,
                                            instruction_pre_tid_valid_in =>pre_tid_valid1,
                                            instruction_pre_pre_tid_in =>pre_pre_tid_r,
                                            instruction_pre_pre_tid_valid_in=>pre_pre_tid_valid1,
                                            instruction_pre_iregister_auto_in=>pre_iregister_auto_r,

                                            opcode1_out => opcode1,
                                            en1_out => en1,

                                            instruction_tid_out => tid_decoder2dispatch,
                                            xreg1_out => mu_xreg1,
                                            flag1_out => mu_flag1,
                                            wren_out => mu_wren,

                                            vm_out => mu_vm,

                                            x1_addr1_out => x1_addr1,
                                            x2_addr1_out => x2_addr1,
                                            y_addr1_out => y_addr1,

                                            x1_vector_out => x1_vector,
                                            x2_vector_out => x2_vector,
                                            y_vector_out => y_vector,
                                            vector_lane_out => vector_lane,

                                            -- Constant parameters
                                            x1_c1_en_out => x1_c1_en,
                                            x1_c1_out => x1_c1,

                                            -- IREGISTER
                                            i_rd_en_out => i_rd_en1,
                                            i_rd_vm_out => i_rd_vm,
                                            i_rd_tid_out => i_rd_tid1,
                                            i_rd_data_in => i_rd_data1,
                                            i_wr_tid_out => i_wr_tid1,
                                            i_wr_en_out => i_wr_en1,
                                            i_wr_vm_out => i_wr_vm,
                                            i_wr_addr_out => i_wr_addr1,
                                            i_wr_data_out => i_wr_data1,

                                            --LANE control
                                            lane_in => rd_lane,
                                            wr_lane_out => wr_lane,

                                            -- IALU
                                            i_opcode_out => i_opcode,
                                            i_x1_out => i_x1,
                                            i_x2_out => i_x2,
                                            i_y_in => i_y,
                                    
                                            -- RESULT
                                            result_waddr_out => result_waddr1,
                                            result_raddr_out => result_raddr1,
                                            result_vm_out => result_read_vm,
                                            result_in => result_read
                                            );

------
-- Instantiate DISPATCH stage for MU#0
-- Issue read access to load required register values
-- Issue write access to save MU results into register_file or flag unit.
-------


instr_dispatch2_i1: instr_dispatch2 port map(
            clock_in => clock_in,
            reset_in => reset_in,
            opcode_in => opcode1,
            instruction_tid_in =>tid_decoder2dispatch,
            xreg_in=>mu_xreg1,
            flag_in=>mu_flag1,
            wren_in=>mu_wren,
            
            en_in => en1,

            vm_in => mu_vm,
            
            x1_addr1_in => x1_addr1,
            x2_addr1_in => x2_addr1,
            y_addr1_in => y_addr1,
            result_addr1_in => result_waddr1,

            x1_vector_in => x1_vector,
            x2_vector_in => x2_vector,
            y_vector_in => y_vector,
            vector_lane_in => vector_lane,

            rd_en_out => rd_en1,
            rd_vm_out => rd_vm,        
            rd_x1_addr_out => rd_x1_addr1,
            rd_x2_addr_out => rd_x2_addr1,
            rd_x1_data_in => rd_x1_data1,
            rd_x2_data_in => rd_x2_data1,

            rd_x1_vector_out => rd_x1_vector1,
            rd_x2_vector_out => rd_x2_vector1,

            -- Constant parameters

            x1_c1_en_in=>x1_c1_en,
            x1_c1_in=>x1_c1,

            wr_xreg_out => wr_xreg1,
            wr_flag_out => wr_flag1,
            wr_en_out => wr_en1,
            wr_vm_out => wr_vm,
            wr_vector_out => wr_vector,
            wr_addr_out => wr_addr1,
            wr_result_addr_out => wr_result_addr1,
			wr_data_out => wr_data1,
            wr_lane_out => wr_vector_lane,

            mu_x1_out => mu_x1,
            mu_x2_out => mu_x2,
            mu_x_scalar_out => mu_x_scalar,
            mu_opcode_out => mu_opcodes,
            mu_tid_out => mu_tid,
            mu_y_in => mu_y2);
        
                                 
END behavior;
