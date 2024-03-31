---------------------------------------------------------------------------
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
---------------------------------------------------------------------------

--------------- 
-- This file defines constants that are used by ztachip implementation
-- Contains component declaration
---------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.config.all;

package ztachip_pkg is

---------
-- Number of threads
---------

constant tid_max_c:integer:=16;

subtype tid_t is unsigned(3 DOWNTO 0);

subtype tid_mask_t  is std_logic_vector(tid_t'length-1 downto 0);

--------
-- Message queue to communicate with host
--------

constant msgq_in_num_c          :integer:=2;                        -- Number of inbox fifo

constant msgq_in_depth_c        :integer:=11;                       -- number of bits required to represent number of inbox messages

constant msgq_in_max_c          :integer:=(2**msgq_in_depth_c-1);   -- inbox size

constant msgq_out_depth_c       :integer:=11;                       -- number of bits required to represent number of outbox messages

constant msgq_out_max_c         :integer:=(2**msgq_out_depth_c-1);  -- outbox size

----------
-- AXI read bus signal definitions
----------

subtype axi_araddr_t is std_logic_vector(31 downto 0);
subtype axi_arlen_t is std_logic_vector(7 downto 0);
subtype axi_arvalid_t is std_logic;     
subtype axi_arid_t is std_logic_vector(0 downto 0);
subtype axi_arlock_t is std_logic_vector(0 downto 0);
subtype axi_arcache_t is std_logic_vector(3 downto 0);
subtype axi_arprot_t is std_logic_vector(2 downto 0);
subtype axi_arqos_t is std_logic_vector(3 downto 0);
subtype axi_rid_t is std_logic_vector(0 downto 0);             
subtype axi_rvalid_t is std_logic;
subtype axi_rlast_t is std_logic;
subtype axi_rdata_t is std_logic_vector(31 downto 0);
subtype axi_rdata64_t is std_logic_vector(63 downto 0);
subtype axi_rresp_t is std_logic_vector(1 downto 0);
subtype axi_arready_t is std_logic;
subtype axi_rready_t is std_logic;
subtype axi_arburst_t is std_logic_vector(1 downto 0);
subtype axi_arsize_t is std_logic_vector(2 downto 0);

type axi_araddrs_t is array(natural range <>) of axi_araddr_t;
type axi_arlens_t is array(natural range <>) of axi_arlen_t;
type axi_arvalids_t is array(natural range <>) of axi_arvalid_t; 
type axi_arids_t is array(natural range <>) of axi_arid_t;
type axi_arlocks_t is array(natural range <>) of axi_arlock_t;
type axi_arcaches_t is array(natural range <>) of axi_arcache_t;
type axi_arprots_t is array(natural range <>) of axi_arprot_t;
type axi_arqoss_t is array(natural range <>) of axi_arqos_t;
type axi_rids_t is array(natural range <>) of axi_rid_t;
type axi_rvalids_t is array(natural range <>) of axi_rvalid_t;
type axi_rlasts_t is array(natural range <>) of axi_rlast_t;
type axi_rdatas_t is array(natural range <>) of axi_rdata_t;
type axi_rdata64s_t is array(natural range <>) of axi_rdata64_t;
type axi_rresps_t is array(natural range <>) of axi_rresp_t;
type axi_arreadys_t is array(natural range <>) of axi_arready_t;
type axi_rreadys_t is array(natural range <>) of axi_rready_t;
type axi_arbursts_t is array(natural range <>) of axi_arburst_t;
type axi_arsizes_t is array(natural range <>) of axi_arsize_t;

---------------------
-- AXI write bus signals
---------------------

subtype axi_awaddr_t is std_logic_vector(31 downto 0);
subtype axi_awlen_t is std_logic_vector(7 downto 0);
subtype axi_awvalid_t is std_logic;
subtype axi_wvalid_t is std_logic;
subtype axi_wdata_t is std_logic_vector(31 downto 0);
subtype axi_wdata64_t is std_logic_vector(63 downto 0);
subtype axi_wlast_t is std_logic;
subtype axi_wstrb_t is std_logic_vector(3 downto 0);
subtype axi_wstrb8_t is std_logic_vector(7 downto 0);
subtype axi_awready_t is std_logic;
subtype axi_wready_t is std_logic;
subtype axi_bresp_t is std_logic_vector(1 downto 0);
subtype axi_bid_t is std_logic_vector(0 downto 0);
subtype axi_bvalid_t is std_logic;
subtype axi_awburst_t is std_logic_vector(1 downto 0);
subtype axi_awcache_t is std_logic_vector(3 downto 0);
subtype axi_awid_t is std_logic_vector(0 downto 0);
subtype axi_awlock_t is std_logic_vector(0 downto 0);
subtype axi_awprot_t is std_logic_vector(2 downto 0);
subtype axi_awqos_t is std_logic_vector(3 downto 0);
subtype axi_awsize_t is std_logic_vector(2 downto 0);
subtype axi_bready_t is std_logic;

type axi_awaddrs_t is array(natural range <>) of axi_awaddr_t;
type axi_awlens_t is array(natural range <>) of axi_awlen_t;
type axi_awvalids_t is array(natural range <>) of axi_awvalid_t;
type axi_wvalids_t is array(natural range <>) of axi_wvalid_t;
type axi_wdatas_t is array(natural range <>) of axi_wdata_t;
type axi_wdata64s_t is array(natural range <>) of axi_wdata64_t;
type axi_wlasts_t is array(natural range <>) of axi_wlast_t;
type axi_wstrbs_t is array(natural range <>) of axi_wstrb_t;
type axi_wstrb8s_t is array(natural range <>) of axi_wstrb8_t;
type axi_awreadys_t is array(natural range <>) of axi_awready_t;
type axi_wreadys_t is array(natural range <>) of axi_wready_t;
type axi_bresps_t is array(natural range <>) of axi_bresp_t;
type axi_bids_t is array(natural range <>) of axi_bid_t;
type axi_bvalids_t is array(natural range <>) of axi_bvalid_t;
type axi_awbursts_t is array(natural range <>) of axi_awburst_t;
type axi_awcaches_t is array(natural range <>) of axi_awcache_t;
type axi_awids_t is array(natural range <>) of axi_awid_t;
type axi_awlocks_t is array(natural range <>) of axi_awlock_t;
type axi_awprots_t is array(natural range <>) of axi_awprot_t;
type axi_awqoss_t is array(natural range <>) of axi_awqos_t;
type axi_awsizes_t is array(natural range <>) of axi_awsize_t;
type axi_breadys_t is array(natural range <>) of axi_bready_t;

--------
--- Constants for MCORE implementation
--------

constant io_depth_c                 :integer:=24;   -- Address width of MCORE external memory access 

constant instruction_width_c        :integer:=128;

constant instruction_byte_width_c   :integer:=(instruction_width_c/8);

constant instruction_depth_c        :integer:=11;   -- mcore code address width

constant instruction_actual_depth_c :integer:=11;   -- mcore code address width

--------
--- PCORE constants
--------

constant vector_depth_c     :integer:=3;  -- vector width in term of number of bits required for addressing

constant host_width_c       :integer:=32;

constant data_byte_width_depth_c :integer:=0;

constant data_byte_width_c  :integer:=(2**data_byte_width_depth_c);

constant data_width_c       :integer:=(8*data_byte_width_c);

constant vector_width_c     :integer:=(2**vector_depth_c);    -- Vector width

constant accumulator_width_c:integer:=32;   -- accumulator width

constant register_width_c   :integer:=12;   -- register width

constant register_byte_width_c: integer:=(register_width_c/8);

constant vaccumulator_width_c:integer:=(accumulator_width_c*vector_width_c);   -- accumulator width

constant vregister_width_c  :integer:=(register_width_c*vector_width_c); -- Width of a vector register

constant register_depth_c   :integer:=(5+vector_depth_c);    -- Address width to access register banks from pcore's threads

constant register_size_c    :integer:=(2**register_depth_c);

constant fu_latency_c       :integer:=6;   -- Floating point math unit execusion latency 

constant pipeline_latency_c :integer:=9;    -- Number of cycles to start a thread instruction IN the pipeline

constant ddr_vector_depth_c :integer:=3;

constant ddr_vector_width_c :integer:=(2**ddr_vector_depth_c);

constant ddr_data_width_c   :integer:=(data_width_c*ddr_vector_width_c);

constant ddr_data_byte_width_c: integer:=(ddr_data_width_c/8);

constant ddr_burstlen_width_c: integer:=3;

constant ddrx_data_width_c  :integer:=(register_width_c*ddr_vector_width_c);

constant ddr_max_burstlen_c:integer:=6;

--constant ddr_max_write_pend_depth_c:integer:=6;

constant ddr_max_write_pend_depth_c:integer:=6;

--constant ddr_max_read_transaction_pend_depth_c:integer:=6;

--constant ddr_max_read_pend_depth_c:integer:=8;

constant ddr_max_read_transaction_pend_depth_c:integer:=6;

constant ddr_max_read_pend_depth_c:integer:=9;

constant ddr_max_write_pend_c:integer:=(2**ddr_max_write_pend_depth_c);

constant ddr_max_read_transaction_pend_c:integer:=(2**ddr_max_read_transaction_pend_depth_c);

constant ddr_max_read_pend_c:integer:=(2**ddr_max_read_pend_depth_c);

constant data_flow_direct_c:integer:=0;

constant data_flow_converge_c:integer:=1;

constant data_flow_diverge_c:integer:=2;

constant data_flow_stream_process_c:integer:=3;

subtype data_flow_t is std_logic_vector(1 DOWNTO 0);

type data_flows_t is array(natural range <>) of data_flow_t;

-- Scatter type

subtype scatter_t is std_logic_vector(1 downto 0);

type scatters_t is array(natural range <>) of scatter_t; 

constant scatter_none_c:scatter_t:="00";  -- Scatter none

constant scatter_vector_c:scatter_t:="01"; -- Scatter among vector elements

constant scatter_thread_c:scatter_t:="10"; -- scatter among threads

-- Fork parameters

constant fork_max_c:integer:=1;

-- FORK for every memory space 

constant fork_pcore_c:integer:=fork_max_c;

constant fork_sram_c:integer:=1;

constant fork_ddr_c:integer:=1;

--------
-- Register file size
--------

constant register_file_depth_c  :integer:=(register_depth_c+tid_t'length); -- Depth of register file

constant register_actual_file_depth_c:integer:=(register_file_depth_c-1); -- Actual size of register file...

constant local_addr_depth_c :integer:=(register_file_depth_c); -- Max address for internal local address (private and shared)

--------
--- SRAM constant
--------

constant sram_bank_depth_c  :integer:=14;   -- Address width to access SRAM bank

constant sram_depth_c       :integer:=15;   -- Address width to access SRAM memory

constant sram_num_bank_c    :integer:=2**(sram_depth_c-sram_bank_depth_c);

--------
--- DDR access window
--------

constant ddr_bus_width_c    :integer:=32;   -- Address width to access DDR window

--- DDR driver parameters

constant ddr_rx_fifo_width_c:integer:=ddr_bus_width_c+ddr_burstlen_width_c+2;

constant ddr_rx_fifo_depth:integer:=4;

constant ddr_rx_fifo_size_c:integer:=(2**ddr_rx_fifo_depth);

----
-- BUS2 address: 
-- This bus is for SRAM and MCORE memory access
------

constant dp_bus2_addr_width_c :integer:=18;

subtype dp_bus2_page_t is std_logic_vector(1 downto 0);

constant dp_bus2_page_sram_c:dp_bus2_page_t:="00";

constant dp_bus2_page_mcore_code_c:dp_bus2_page_t:="01";

--------
--- IALU constants
--------

constant iregister_width_c      :integer:=13;                       -- Bit width of IALU registers

constant iregister_width_log_c  :integer:=4;                        -- log(iregister_width_c)

constant iregister_depth_c      :integer:=3;                        -- Address width to access IALU registers

constant iregister_max_c        :integer:=(2**iregister_depth_c);   -- Max number of IALU registers

--------
-- IALU register datatype
--------

subtype iregister_t         is unsigned(iregister_width_c-1 downto 0);  -- IALU register datatype

subtype iregister_addr_t    is unsigned(iregister_depth_c-1 downto 0);  -- IALU register address datatype

type iregisters_t        is array(natural range <>) of iregister_t;  -- Array if iregister_t

-----
-- iregister override
-----

constant max_iregister_auto_c:integer:=2;

subtype iregister_auto_t  is unsigned(max_iregister_auto_c+iregister_width_c*max_iregister_auto_c-1 downto 0);

type iregister_autos_t is array(natural range <>) of iregister_auto_t;

-------
-- Accumulator register
-------

constant xreg_depth_c:integer:=(3+tid_t'length);

subtype xreg_addr_t is std_logic_vector(xreg_depth_c-1 downto 0);

---------
-- MU Instruction format
-- Instruction opcode field
---------

constant mu_instruction_width_c         :integer:=80;
constant mu_instruction_y_attr_lo_c     :integer:=0; -- LSB bit position of Y field
constant mu_instruction_y_attr_hi_c     :integer:=3; -- MSB bit position of Y field
constant mu_instruction_y_lo_c          :integer:=(mu_instruction_y_attr_hi_c+1); -- LSB bit position of Y field
constant mu_instruction_y_hi_c          :integer:=(mu_instruction_y_lo_c+local_addr_depth_c-1); -- MSB bit position of Y field
constant mu_instruction_y_vector_c      :integer:=(mu_instruction_y_hi_c+1); -- Vector mode
constant mu_instruction_x2_attr_lo_c    :integer:=(mu_instruction_y_vector_c+1); -- LSB Bit position of X2 field
constant mu_instruction_x2_attr_hi_c    :integer:=(mu_instruction_x2_attr_lo_c+3); -- MSB bit position of X2 field
constant mu_instruction_x2_lo_c         :integer:=(mu_instruction_x2_attr_hi_c+1); -- LSB Bit position of X2 field
constant mu_instruction_x2_hi_c         :integer:=(mu_instruction_x2_lo_c+local_addr_depth_c-1); -- MSB bit position of X2 field
constant mu_instruction_x2_vector_c     :integer:=(mu_instruction_x2_hi_c+1); -- vector mode
constant mu_instruction_x1_attr_lo_c    :integer:=(mu_instruction_x2_vector_c+1); -- LSB bit position of X1 field
constant mu_instruction_x1_attr_hi_c    :integer:=(mu_instruction_x1_attr_lo_c+3); -- MSB bit position of X1 field
constant mu_instruction_x1_lo_c         :integer:=(mu_instruction_x1_attr_hi_c+1); -- LSB bit position of X1 field
constant mu_instruction_x1_hi_c         :integer:=(mu_instruction_x1_lo_c+local_addr_depth_c-1); -- MSB bit position of X1 field
constant mu_instruction_x1_vector_c     :integer:=(mu_instruction_x1_hi_c+1); -- Vector mode
constant mu_instruction_x3_attr_lo_c    :integer:=(mu_instruction_x1_vector_c+1); -- LSB bit position of X1 field
constant mu_instruction_x3_attr_hi_c    :integer:=(mu_instruction_x3_attr_lo_c+3); -- MSB bit position of X1 field
constant mu_instruction_x3_lo_c         :integer:=(mu_instruction_x3_attr_hi_c+1); -- LSB bit position of X1 field
constant mu_instruction_x3_hi_c         :integer:=(mu_instruction_x3_lo_c+local_addr_depth_c-1); -- MSB bit position of X1 field
constant mu_instruction_x3_vector_c     :integer:=(mu_instruction_x3_hi_c+1); -- Vector mode

constant mu_instruction_type_save_c     :integer:=(mu_instruction_width_c-6);
constant mu_instruction_oc_lo_c         :integer:=(mu_instruction_width_c-5);
constant mu_instruction_oc_hi_c         :integer:=(mu_instruction_width_c-1);

constant mu_instruction_y_attr_width_c  :integer:=(mu_instruction_y_attr_hi_c-mu_instruction_y_attr_lo_c+1); -- Length of Y field
constant mu_instruction_y_width_c       :integer:=(mu_instruction_y_hi_c-mu_instruction_y_lo_c+1); -- Length of Y field
constant mu_instruction_x2_attr_width_c :integer:=(mu_instruction_x2_attr_hi_c-mu_instruction_x2_attr_lo_c+1); -- Length of X2 field
constant mu_instruction_x2_width_c      :integer:=(mu_instruction_x2_hi_c-mu_instruction_x2_lo_c+1); -- Length of X2 field
constant mu_instruction_x1_attr_width_c :integer:=(mu_instruction_x1_attr_hi_c-mu_instruction_x1_attr_lo_c+1); -- Length of X1 field
constant mu_instruction_x1_width_c      :integer:=(mu_instruction_x1_hi_c-mu_instruction_x1_lo_c+1); -- Length of X1 field
constant mu_instruction_oc_width_c      :integer:=(mu_instruction_oc_hi_c-mu_instruction_oc_lo_c+1);

subtype mu_opcode_t is std_logic_vector(mu_instruction_oc_width_c-1 downto 0);

type mu_opcodes_t is array(natural range <>) of mu_opcode_t;

-------
-- Control instruction
-------

constant ctrl_instruction_width_c           :integer:=16;
constant ctrl_instruction_oc_lo_c           :integer:=ctrl_instruction_width_c-5;
constant ctrl_instruction_oc_hi_c           :integer:=ctrl_instruction_width_c-1;
constant ctrl_instruction_oc_width_c        :integer:=(ctrl_instruction_oc_hi_c-ctrl_instruction_oc_lo_c+1);
constant ctrl_instruction_goto_addr_hi_c    :integer:=instruction_depth_c-1;
constant ctrl_instruction_goto_addr_lo_c    :integer:=0;
constant ctrl_instruction_goto_addr_width_c :integer:=(ctrl_instruction_goto_addr_hi_c-ctrl_instruction_goto_addr_lo_c+1);

------
-- IMU instruction
------

constant imu_instruction_width_c            :integer:=32;
constant imu_instruction_oc_lo_c            :integer:=imu_instruction_width_c-5;
constant imu_instruction_oc_hi_c            :integer:=imu_instruction_width_c-1;
constant imu_instruction_oc_width_c         :integer:=(imu_instruction_oc_hi_c-imu_instruction_oc_lo_c+1);
constant imu_instruction_x1_hi_c            :integer:=26;
constant imu_instruction_x1_lo_c            :integer:=23;
constant imu_instruction_x1_width_c         :integer:=(imu_instruction_x1_hi_c-imu_instruction_x1_lo_c+1);

constant imu_instruction_x2_hi_c            :integer:=22;
constant imu_instruction_x2_lo_c            :integer:=19;
constant imu_instruction_x2_width_c         :integer:=(imu_instruction_x2_hi_c-imu_instruction_x2_lo_c+1);

constant imu_instruction_y_hi_c             :integer:=18;
constant imu_instruction_y_lo_c             :integer:=15;
constant imu_instruction_y_width_c          :integer:=(imu_instruction_y_hi_c-imu_instruction_y_lo_c+1);

constant imu_instruction_const_hi_c         :integer:=14;
constant imu_instruction_const_lo_c         :integer:=imu_instruction_const_hi_c-iregister_width_c+1;
constant imu_instruction_const_width_c      :integer:=(iregister_width_c);

--------
-- IMU instruction parameter type
--------

subtype imu_instruction_parm_t is std_logic_vector(imu_instruction_x1_width_c-1 downto 0);

constant imu_instruction_parm_i0_c      :imu_instruction_parm_t:="0000";    -- IMU parameter is integer#0
constant imu_instruction_parm_i1_c      :imu_instruction_parm_t:="0001";    -- IMU parameter is integer#1
constant imu_instruction_parm_i2_c      :imu_instruction_parm_t:="0010";    -- IMU parameter is integer#2
constant imu_instruction_parm_i3_c      :imu_instruction_parm_t:="0011";    -- IMU parameter is integer#3
constant imu_instruction_parm_p0_c      :imu_instruction_parm_t:="0100";    -- IMU parameter is pointer#0
constant imu_instruction_parm_p1_c      :imu_instruction_parm_t:="0101";    -- IMU parameter is pointer#1
constant imu_instruction_parm_p2_c      :imu_instruction_parm_t:="0110";    -- IMU parameter is pointer#2
constant imu_instruction_parm_p3_c      :imu_instruction_parm_t:="0111";    -- IMU parameter is pointer#3
constant imu_instruction_parm_lane_c    :imu_instruction_parm_t:="1000";     -- Lane control
constant imu_instruction_parm_zero_c    :imu_instruction_parm_t:="1010";    -- IMU parameter is zero
constant imu_instruction_parm_const_c   :imu_instruction_parm_t:="1011";    -- IMU parameter is an immediate constant
constant imu_instruction_parm_tid_c     :imu_instruction_parm_t:="1100";    -- IMU parameter is TID (theadid)
constant imu_instruction_parm_pid_c     :imu_instruction_parm_t:="1101";    -- IMU parameter is PID (pcore id)
constant imu_instruction_parm_result1_c :imu_instruction_parm_t:="1110";     -- IMU parameter is result field from MU
constant imu_instruction_parm_stack_c   :imu_instruction_parm_t:="1111";     -- Stack pointer value

--------
-- MU opcode
--------

constant opcode_null_c                  :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00000"; -- NOP
constant mu_opcode_assign_c             :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00001"; -- Y=X1
constant mu_opcode_assign_raw_c         :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00010"; -- Y=X1
constant mu_opcode_add_c                :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00011"; -- Y=X1+X2
constant mu_opcode_sub_c                :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00100"; -- Y=X1-X2
constant mu_opcode_conv_c               :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00101"; -- Y=CONV(X1)
constant mu_opcode_cmp_lt_c             :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00110"; -- X1 < X2
constant mu_opcode_cmp_le_c             :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="00111"; -- X1 <= X2
constant mu_opcode_cmp_gt_c             :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="01000"; -- X1 > X2
constant mu_opcode_cmp_ge_c             :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="01001"; -- X1 >= X2
constant mu_opcode_cmp_eq_c             :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="01010"; -- X1 == X2
constant mu_opcode_cmp_ne_c             :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="01011"; -- X1 != X2
constant mu_opcode_mul_c                :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="01100"; -- Y=X1*X2
constant mu_opcode_acc_set_c            :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="01101"; -- ACC=X1
constant mu_opcode_get_mantissa_c       :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="01111"; -- Get Mantissa+sign part of float number
constant mu_opcode_get_exponent_c       :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="10000"; -- Get exponent part of float number
constant mu_opcode_set_exponent_c       :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="10001"; -- Set exponent part of float number
constant mu_opcode_set_float_c          :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="10010"; -- Set float from mantissa and exponent
constant mu_opcode_shl_c                :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):= "10011"; -- Shift operation on accumulator
constant mu_opcode_shla_c               :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="10100"; -- Shift operation on accumulator
constant mu_opcode_shr_c                :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):= "10101"; -- Shift operation on accumulator
constant mu_opcode_shra_c               :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="10110"; -- Shift operation on accumulator
constant mu_opcode_fm_c                 :STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0):="11000"; -- ACC=ACC+X1*X2

--- Fused multiply add-sub opcode definition
constant fm_oc_hi_c                     :integer:=4;
constant fm_oc_lo_c                     :integer:=3;
constant fm_add_sub_c                   :integer:=0; -- fma=1;fms=0
constant fm_neg_c                       :integer:=1; -- fnma|fnms=1; fma|fms=0;
constant fm_xreg_sel_c                  :integer:=2; -- 0 for x1*x2+_A; 1 for x1*_A+x2

--------
-- Control instruction opcodes
--------

constant ctrl_opcode_return_c   :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="00001"; -- RETURN
constant ctrl_opcode_jump_lt_c  :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="00010"; -- if(X1 < X2) jump
constant ctrl_opcode_jump_le_c  :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="00011"; -- if(X1 <= X2) jump
constant ctrl_opcode_jump_gt_c  :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="00100"; -- if(X1 > X2) jump
constant ctrl_opcode_jump_ge_c  :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="00101"; -- if(X1 >= X2) jump
constant ctrl_opcode_jump_eq_c  :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="00110"; -- if(X1 == X2) jump
constant ctrl_opcode_jump_ne_c  :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="00111"; -- if(X1 != X2) jump
constant ctrl_opcode_jump_c     :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="01000"; -- JUMP
constant ctrl_opcode_func_c     :STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0):="01001"; -- FUNC CALL

-------
-- IMU instruction opcode
-------

constant imu_opcode_add_c   :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="00001"; -- Do Y=X1+X2
constant imu_opcode_sub_c   :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="00010"; -- Do Y=X1-X2
constant imu_opcode_mul_c   :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="00011"; -- Do Y=X1*X2
constant imu_opcode_shl_c   :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="00100"; -- Do Y=X1<<X2
constant imu_opcode_shr_c   :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="00101"; -- Do Y=X1>>X2
constant imu_opcode_or_c    :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="00110"; -- Do Y=X1|X2
constant imu_opcode_and_c   :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="00111"; -- Do Y=X1&X2
constant imu_opcode_xor_c   :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="01000"; -- Do Y=X1^X2
constant imu_opcode_lshr_c  :STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0):="01001"; -- Do Y=X1>>X2 (No sign extension)

--------
-- MU constant attribute type
--------

subtype register_attr_t is std_logic_vector(3 downto 0);

constant register_attr_const_p0_c       :integer:=4;    -- Immediate constant #0
constant register_attr_const_null_c     :integer:=5;    -- NULL
constant register_attr_const_result_c   :integer:=6;    -- Hold MU integer return value
constant register_attr_const_tid_c      :integer:=7;    -- Hold MU integer return value
constant register_attr_const_xreg_c     :integer:=8;    -- Hold MU integer return value

---------
-- PCORE memory page
---------

subtype page_t is unsigned(1 DOWNTO 0);

subtype page2_t is unsigned(1 DOWNTO 0);

constant page2_register_c              :page2_t:=to_unsigned(0,page2_t'length); -- Access private memory 

constant page2_shared_register_c       :page2_t:=to_unsigned(1,page2_t'length); -- Access shared memory

constant page2_spe_register_c          :page2_t:=to_unsigned(2,page2_t'length); -- Access shared memory

constant page2_pcore_program_c         :page2_t:=to_unsigned(3,page2_t'length); -- Download PCORE program memory

--------
-- CELL ID
--------

subtype cid_t is unsigned(2 DOWNTO 0);

----------
-- Number of processor per cell
----------

constant pid_max_c:integer:= 4;

subtype pid_t is unsigned(1 DOWNTO 0);

----------
--- Total number of pcores
----------

subtype pcore_t is unsigned(cid_t'length+pid_t'length-1 DOWNTO 0);

---------
-- Avalon bus page
---------

subtype avalon_bus_page_t is unsigned(1 downto 0);

constant avalon_bus_page_config_c:avalon_bus_page_t:=to_unsigned(0,avalon_bus_page_t'length); -- Access configuration registers

constant avalon_bus_page_pcode_c:avalon_bus_page_t:=to_unsigned(1,avalon_bus_page_t'length); -- Access PCORE code space

constant avalon_bus_page_mcode_c:avalon_bus_page_t:=to_unsigned(2,avalon_bus_page_t'length); -- Access MCORE code space

constant avalon_bus_page_mdata_c:avalon_bus_page_t:=to_unsigned(3,avalon_bus_page_t'length); -- Access MCORE data space

--------
-- Constant memory size
--------

constant constant_depth_c: integer:= 8;

-------
-- PCORE bus address
--------

constant bus_width_c:integer:=(register_depth_c+tid_t'length+pid_t'length+cid_t'length); -- Address width to access PCORE

--------
-- AVALON bus address
--------

constant local_bus_width_c:integer:=(bus_width_c+page_t'length+page2_t'length+1); -- Total address width from avalon bus

--------
-- Avalon bus width 
--------

constant avalon_bus_width_c:integer:=17;

--------
-- Avalon bus page width
---------

constant avalon_page_width_c:integer:=(avalon_bus_width_c-avalon_bus_page_t'length);

--------
-- Multicast addr definition
--------

constant mcast_width_c:integer:=1+cid_t'length+pid_t'length; -- multicast address width

subtype mcast_t is std_logic_vector(mcast_width_c-1 downto 0);

subtype mcast_addr_t is STD_LOGIC_VECTOR(cid_t'length+pid_t'length-1 DOWNTO 0); -- multicast address datatype

type mcasts_t is array(natural range <>) of mcast_t; -- array of multicast address datatype

--------
-- PCORE instruction address
--------

subtype instruction_addr_t is STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0); -- PCORE instruction address datatype

type instruction_addrs_t is array(natural range <>) of instruction_addr_t; -- array of pcore instruction addresses

------
-- General types
------

type integer_array is array (natural range <>) of integer;

subtype vector_t is unsigned(ddr_vector_depth_c downto 0);

type vectors_t is array(natural range <>) of vector_t;

subtype vector_fork_t is vectors_t(fork_max_c-1 downto 0);

type vector_forks_t is array(natural range <>) of vector_fork_t;

--------
-- DP Read latency
--------

constant read_latency_register_c    :integer:=8; -- Latency of PCORE read access

constant read_latency_sram_c        :integer:=4; -- Latency of SRAM read access

constant read_latency_ddr_c         :integer:=1; -- Latency of DDR read access

constant read_latency_max_c         :integer:=8;  -- Warning . Below is the max of all previously defined latency

--------
-- DP data converter latency
--------

constant convert_latency_c          :integer:=6; -- Latency of data converted to/from DDR

-------
-- DDR burst definition
-------

constant burstlen_width_c:integer:=(ddr_burstlen_width_c-1+ddr_vector_depth_c);

subtype burstlen_t is unsigned(burstlen_width_c-1 downto 0);                 -- DDR bustlen definition

subtype burstlen2_t is unsigned(burstlen_width_c+ddr_vector_depth_c+1-1 downto 0);                 -- DDR bustlen definition

constant burstlen_max_c:integer:=(2**burstlen_t'length-1);  -- DDR bustlen size

type burstlens_t is array(natural range <>) of burstlen_t;  -- array of burstlen_t

--------
-- DP sink parameters
--------

constant dp_sink_fifo_depth_c       :integer:=8;

constant dp_sink_fifo_size_c        :integer:=(2**dp_sink_fifo_depth_c); -- WARNING. Must be > burstlength+dp_sink_fifo_full_margin_c 

--------
-- Data plane processor's bus...
--------

-- Constant for DP processor 

constant NUM_DP_SRC_PORT:integer:=3;

constant NUM_DP_DST_PORT:integer:=3;

constant dp_bus_id_register_c   :integer:=0; -- DP bus to access PCORE memory space

constant dp_bus_id_sram_c       :integer:=1; -- DP bus to access SRAM

constant dp_bus_id_ddr_c        :integer:=2; -- DP bus to access DDR

constant dp_bus_id_max_c        :integer:=3; -- Max number of DP bus

subtype dp_bus_id_t is unsigned(1 downto 0); -- DP busid datatype

-- 
-- Max number of DP generator
----

constant dp_max_gen_c:integer:=2;

-------
-- DP memory model
-- '00' for full model (all threads active)
-- '01' for 1/2 threads active
-- '10' for 1/4 threads active
-- '11' for 1/8 threads active
-------

subtype dp_data_model_t is std_logic_vector(1 downto 0);

type dp_data_models_t is array(natural range <>) of dp_data_model_t; 

--------
-- DP Data type
--------

subtype dp_data_type_t is unsigned(1 downto 0);          -- DP datatype

constant dp_data_type_integer_c     :dp_data_type_t:="01";    -- DP datatype is integer

constant dp_data_type_uinteger_c    :dp_data_type_t:="10";    -- DP datatype is integer

type dp_data_types_t is array(natural range <>) of dp_data_type_t;  -- array of DP datatypes

--------
--- DP window address width
---------

constant dp_addr_width_c: integer:=24;

---
-- Full address for DP engine
----
constant dp_full_addr_width_c: integer:=32;

---------
--- Stream processor
---------

constant stream_lookup_depth_c:integer:=9;

constant stream_lookup_size_c:integer:=(2**stream_lookup_depth_c);

subtype stream_id_t is unsigned(1 downto 0); -- stream id datatype

type stream_ids_t is array(natural range <>) of stream_id_t;

---------
-- DP instruction fifo depth. This fifo is where mcore is pushing instructions to
---------

constant dp_fifo_depth_c :integer:=7;

constant dp_fifo_max_c :integer:=(2**dp_fifo_depth_c-1);

constant dp_fifo_priority_depth_c :integer:=4;

constant dp_fifo_priority_max_c :integer:=(2**dp_fifo_priority_depth_c-1);

-- DP fifo to transfer instruction to source/sink components

constant dp_fifo2_depth_c :integer:=2;

constant dp_fifo2_max_c :integer:=3;

----------
-- DP data transfer instruction template
---------

type dp_template_t is
record
    stride0: unsigned(dp_addr_width_c-1 downto 0);          -- Increment step for outer loop
    stride0_count: unsigned(dp_addr_width_c-1 downto 0);    -- Number of increment steps for outer loop
    stride0_max: unsigned(dp_addr_width_c downto 0);        -- Max value for stride0
    stride0_min: unsigned(dp_addr_width_c downto 0);        -- Max value for stride0
    stride1: unsigned(dp_addr_width_c-1 downto 0);          -- Increment step for mid loop
    stride1_count: unsigned(dp_addr_width_c-1 downto 0);    -- Number of increment steps for mid loop
    stride1_max: unsigned(dp_addr_width_c downto 0);        -- Max value for stride1
    stride1_min: unsigned(dp_addr_width_c downto 0);        -- Max value for stride0
    stride2: unsigned(dp_addr_width_c-1 downto 0);          -- Increment step for inner loop
    stride2_count: unsigned(dp_addr_width_c-1 downto 0);    -- Number of increment steps for inner loop
    stride2_max: unsigned(dp_addr_width_c downto 0);        -- Max value for stride2
    stride2_min: unsigned(dp_addr_width_c downto 0);        -- Max value for stride2
    stride3: unsigned(dp_addr_width_c-1 downto 0);          -- Increment step for inner loop
    stride3_count: unsigned(dp_addr_width_c-1 downto 0);    -- Number of increment steps for inner loop
    stride3_max: unsigned(dp_addr_width_c downto 0);        -- Max value for stride3
    stride3_min: unsigned(dp_addr_width_c downto 0);        -- Max value for stride3
    stride4: unsigned(dp_addr_width_c-1 downto 0);          -- Increment step for inner loop
    stride4_count: unsigned(dp_addr_width_c-1 downto 0);    -- Number of increment steps for inner loop
    stride4_max: unsigned(dp_addr_width_c downto 0);        -- Max value for stride4
    stride4_min: unsigned(dp_addr_width_c downto 0);        -- Max value for stride4
    burst_max: unsigned(dp_addr_width_c downto 0);          -- Max value for burst
    burst_max2: unsigned(dp_addr_width_c downto 0);         -- Max value for burst
    burst_max_init: unsigned(dp_addr_width_c downto 0);
    burst_max_index: unsigned(2 downto 0);
    burst_min: unsigned(dp_addr_width_c downto 0);          -- Max value for burst
    bar: unsigned(dp_full_addr_width_c-1 downto 0);         -- Base address of this transfer
    count:unsigned(dp_addr_width_c-1 downto 0);             -- Number of transfer
    burstStride:unsigned(dp_addr_width_c-1 downto 0);       -- Increment after each transfer
    double_precision:std_logic;
    data_model:dp_data_model_t;
    scatter:std_logic;
    totalcount:unsigned(dp_addr_width_c-1 downto 0);        -- Total transfer count
    mcast:std_logic_vector(mcast_width_c-1 downto 0);       -- Multicast mask
    data:std_logic_vector(2*data_width_c-1 downto 0);       -- Constant data value
    repeat:std_logic;                                       -- Repeat mode
    datatype:dp_data_type_t;                                -- Data type
    bus_id:dp_bus_id_t;                                     -- Bus ID
    bufsize:unsigned(dp_addr_width_c-1 downto 0);           -- Max buffer size
    burst_max_len:unsigned(dp_addr_width_c-1 downto 0);     -- Max burst length
end record;

constant dp_template_width_c :integer:=26*dp_addr_width_c+dp_full_addr_width_c+14+2+3+dp_addr_width_c+mcast_width_c+2*data_width_c+1+dp_data_type_t'length+dp_bus_id_t'length+dp_addr_width_c+dp_data_model_t'length+dp_addr_width_c;

constant dp_template_id_depth_c :integer:=4;

constant dp_template_max_c :integer:=(2**dp_template_id_depth_c);

constant dp_template_id_src_c :integer:=(dp_template_max_c-2);  -- DP template is source

constant dp_template_id_dest_c :integer:=(dp_template_max_c-1); -- DP template is destination 

subtype dp_template_id_t is unsigned(dp_template_id_depth_c-1 downto 0); -- DP template ID

---------
-- DP datatypes
---------

subtype dp_addr_t is unsigned(dp_addr_width_c-1 downto 0);  -- DP address
type dp_addrs_t is array(natural range <>) of dp_addr_t;  -- array of DP addresses
subtype dp_full_addr_t is unsigned(dp_full_addr_width_c-1 downto 0); -- DP address
type dp_full_addrs_t is array(natural range <>) of dp_full_addr_t;-- array of DP addresses
subtype dp_fork_addr_t is dp_addrs_t(fork_max_c-1 downto 0);
type dp_fork_addrs_t is array(natural range <>) of dp_fork_addr_t;
subtype dp_fork_full_addr_t is dp_full_addrs_t(fork_max_c-1 downto 0); 
type dp_fork_full_addrs_t is array(natural range <>) of dp_fork_full_addr_t;
subtype dp_data_t is std_logic_vector(ddr_data_width_c-1 DOWNTO 0); -- DP data word
type dp_datas_t is array(natural range <>) of dp_data_t; -- array of DP data words
subtype dp_fork_data_t is dp_datas_t(fork_max_c-1 downto 0);
type dp_fork_datas_t is array(natural range <>) of dp_fork_data_t; -- array of DP data words
type dp_bus_ids_t is array(natural range <>) of dp_bus_id_t; -- DP bus id
subtype dp_counter_t is unsigned(dp_addr_width_c-1 downto 0); -- DP transfer counter
type dp_counters_t is array(natural range <>) of dp_counter_t; -- array of DP tranfer counter
subtype dp_vector_t is std_logic_vector(ddr_vector_depth_c-1 downto 0); -- DP vector depth
type dp_vectors_t is array(natural range <>) of dp_vector_t; -- array of DP vector depth
subtype dp_fork_t is std_logic_vector(fork_max_c-1 downto 0); -- DP fork
type dp_forks_t is array(natural range <>) of dp_fork_t; -- array of DP fork
subtype dp_datax_t is STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
type dp_dataxs_t is array(natural range <>) of dp_datax_t;

-----------
-- DP condition definitions...
-----------

constant dp_condition_register_flush_c:integer:=0; -- Wait for all write to register space of process 0 to be completed

constant dp_condition_sram_flush_c:integer:=1; -- Wait for all read/write to scratch space of process 0 to be completed

constant dp_condition_ddr_flush_c:integer:=3; -- Wait for all write to DDR space to be completed

subtype dp_condition_t is std_logic_vector(3 downto 0); -- DP condition datatype

----------
-- DP opcode
----------

constant dp_opcode_null_c          :integer:=0;    -- Do nothing
constant dp_opcode_transfer_c      :integer:=1;    -- Perform single data transfer
constant dp_opcode_exec_vm_c       :integer:=4;    -- Launch process#0 (Was 2)
constant dp_opcode_indication_c    :integer:=6;    -- Send an indication signal back to mcore
constant dp_opcode_log_on_c        :integer:=2;    -- Enable log
constant dp_opcode_log_off_c       :integer:=3;    -- Disable log
constant dp_opcode_print_c         :integer:=7;    -- Send debug print message
subtype dp_opcode_t is unsigned(2 downto 0);       -- DP opcode datatype


--------
-- DP config commands sent to PCORE
--------

subtype dp_config_reg_t is unsigned(2 downto 0);
constant dp_config_reg_exe_vm1_c :dp_config_reg_t:="000";
constant dp_config_reg_exe_vm2_c :dp_config_reg_t:="001";

--------
-- DP indication
--------

constant dp_indication_depth_c :integer:=8;    -- FIFO depth to send indication back to mcore
constant dp_indication_max_c :integer:=(2**dp_indication_depth_c-1);

--------
-- DP threads. To be implemented 
--------

constant dp_max_thread_c:integer:=2;
subtype dp_thread_t is unsigned(0 downto 0);
type dp_threads_t is array(natural range <>) of dp_thread_t;

-------
-- DP log
------

constant log_depth_c:integer:=8;
constant log_max_c:integer:=(2**log_depth_c);
subtype log_type_t is std_logic_vector(1 downto 0);
constant log_type_none_c:log_type_t:="00"; -- No log event
constant log_type_dp_begin_c:log_type_t:="01"; -- Begin of a DP transfer command
constant log_type_print_c:log_type_t:="10"; -- Debug print. Parameter point to a string 
constant log_type_status_c:log_type_t:="11"; -- Log is full event. There may be some missing events after this

------
-- Definition for log status.
-- Log status is the log_status_max_c LSB bit in the word retrieved from log FIFO
-- The rest MSB bits (log_timestamp_c number bits) is the time stamp when the status happened
------

constant log_timestamp_c:integer:=20; -- Size of log timestamp field.
constant log_status_max_c:integer:=12; -- Max number of log status bits
constant log_status_vm0_busy_c:integer:=0; -- PCORE process #0 is busy
constant log_status_vm1_busy_c:integer:=1; -- PCORE process #1 is busy
constant log_status_register_vm0_write_busy_c:integer:=2; -- Write bus to PCORE memory space is busy
constant log_status_register_vm0_read_busy_c:integer:=3; -- Read bus from PCORE memory space is busy
constant log_status_sram_vm0_write_busy_c:integer:=4; -- Write bus to SRAM memory space is busy
constant log_status_sram_vm0_read_busy_c:integer:=5; -- Read bus from SRAM memory space is busy
constant log_status_register_vm1_write_busy_c:integer:=6; -- Write bus to PCORE memory space is busy
constant log_status_register_vm1_read_busy_c:integer:=7; -- Read bus from PCORE memory space is busy
constant log_status_sram_vm1_write_busy_c:integer:=8; -- Write bus to SRAM memory space is busy
constant log_status_sram_vm1_read_busy_c:integer:=9; -- Read bus from SRAM memory space is busy
constant log_status_ddr_write_busy_c:integer:=10; -- Write bus to DDR memory space is busy
constant log_status_ddr_read_busy_c:integer:=11; -- Read bus from DDR memory space is busy

----------------
-- DP instruction format
---------

type dp_instruction_t is
record
    opcode:dp_opcode_t;                                 -- opcode
    condition:dp_condition_t;                           -- wait condition
    vm:std_logic;                                       -- Thread associated with this transfer
    source:dp_template_t;                               -- source for transfer command
    source_bus_id: dp_bus_id_t;                         -- source bus-id
    source_data_type:dp_data_type_t;                    -- source data-type
    dest:dp_template_t;                                 -- destination for transfer command
    dest_bus_id: dp_bus_id_t;                           -- destination bus-id
    dest_data_type:dp_data_type_t;                      -- destination data-type
    mcast:std_logic_vector(mcast_width_c-1 downto 0);   -- Multicast mask
    count:unsigned(dp_addr_width_c-1 downto 0);         -- Number of words for transfer command
    data:std_logic_vector(2*data_width_c-1 downto 0);   -- Constants when source is constant type
    repeat:std_logic;                                   -- Source is in repeat mode
    source_addr_mode:std_logic;                         -- Source memory model
    dest_addr_mode:std_logic;                           -- Dest memory model
    stream_process:std_logic;
    stream_process_id:stream_id_t;
end record;

-- dp_instruction_t width

constant dp_instruction_width_c :integer:=(57*dp_addr_width_c+2*dp_full_addr_width_c+2*dp_data_model_t'length+14*2+3*2+2*dp_bus_id_t'length+2*dp_data_type_t'length+2*1+dp_condition_t'length+dp_opcode_t'length+1+mcast_width_c+2*data_width_c+1+2+2+1+stream_id_t'length);

-- Array of dp_instruction_t

type dp_instructions_t is array(natural range <>) of dp_instruction_t;

-- Number of parameters for each DP indication events

constant dp_indication_num_parm_c   :integer:=2;

----------
-- Other DP instruction besides DP transfer command
----------

type dp_instruction_generic_t is
record
    opcode:dp_opcode_t;
    condition:dp_condition_t;
    vm:std_logic;
    param:std_logic_vector(host_width_c-dp_opcode_t'length-dp_condition_t'length-1 downto 0);
    parameters:std_logic_vector(host_width_c*dp_indication_num_parm_c-1 downto 0);
end record;

-------------
-- Register definitions
-------------

subtype register_t is unsigned(4 downto 0);

subtype register2_t is unsigned(5 downto 0);

subtype register_addr_t is std_logic_vector(register_t'length+register2_t'length+1-1 downto 0);

constant register_ddr_bar_c                     :integer:=1;  -- Set DDR start window address
constant register_dp_read_log_c                 :integer:=2;  -- Read LOG fifo
constant register_dp_read_log_time_c            :integer:=3;  -- Read LOG fifo
constant register_dp_run_c                      :integer:=5;  -- Execute a data plane command
constant register_lookup_set_addr_c             :integer:=6;  -- Setup lookup address for subsequent update
constant register_lookup_value_c                :integer:=7;  -- Set lookup table value     
constant register_lookup_coefficient_c          :integer:=4;  -- Set lookup remainder slope coefficient    
constant register_dp_template_c                 :integer:=8;  -- Set DP transfer source
constant register_dp_read_sync_c                :integer:=10; -- Read indication is sync or not
constant register_dp_read_indication_c          :integer:=11; -- Read indication fifo
constant register_dp_read_indication_avail_c    :integer:=12; -- Read number of indication words available IN fifo
constant register_dp_instruction_fifo_avail_c   :integer:=14; -- Read number of DP instruction that can still be pushed to fifo
constant register_soft_reset_c                  :integer:=15; -- Perform soft reset
constant register_swdl_complete_read_c          :integer:=20; -- Number of completed mcore program write words completed
constant register_swdl_complete_clear_c         :integer:=21; -- Clear number of completed mcore program write words completed
constant register_msgq_read_c                   :integer:=16; -- Read commands from host
constant register_msgq_read_avail_c             :integer:=17; -- Read how many commands from host available to be read
constant register_msgq_write_c                  :integer:=18; -- Write commands to host
constant register_msgq_write_avail_c            :integer:=19; -- Read how many commands to host that can be pushed to fifo
constant register_dp_max_pcore_c                :integer:=22; -- Set max number of PCORE
constant register_dp_indication_parm0_c         :integer:=23; -- Read indication parm0
constant register_dp_indication_parm1_c         :integer:=24; -- Read indication parm1
constant register_dp_read_indication_parm_c     :integer:=25; -- Read indication message-id
constant register_serial_read_c                 :integer:=26; -- Read serial port
constant register_serial_write_c                :integer:=27; -- Write serial port
constant register_serial_read_avail_c           :integer:=28; -- Number of bytes available in serial port for reading
constant register_serial_write_avail_c          :integer:=29; -- Number of bytes that can be sent on serial port
constant register_dp_resume_c                   :integer:=30; -- Number of bytes that can be sent on serial port
constant register_dp_restore_c                  :integer:=13; -- Restore dp_register to a source
constant register_vm_toggle_c                   :integer:=9;  -- Toggle current VM

-- Sub register values associated with register_dp_src_template_c and register_dp_dest_template_c 

constant register2_dp_stride0_c         :integer:=0;    -- Set outer loop stride count
constant register2_dp_stride0_count_c   :integer:=1;    -- Set outer loop count
constant register2_dp_stride1_c         :integer:=2;    -- Set mid loop stride count
constant register2_dp_stride1_count_c   :integer:=3;    -- Set mid loop count
constant register2_dp_bar_c             :integer:=4;    -- Set transfer base address
constant register2_dp_count_c           :integer:=5;    -- Set word count for each interation
constant register2_dp_stride2_c         :integer:=6;    -- Set inner loop stride count
constant register2_dp_stride2_count_c   :integer:=7;    -- Set inner loop count
constant register2_dp_burst_stride_c    :integer:=8;    -- Set stride used each interation transfer
constant register2_dp_stride0_max_c     :integer:=9;    -- Set max loop count
constant register2_dp_stride1_max_c     :integer:=10;   -- Set max loop count
constant register2_dp_stride2_max_c     :integer:=11;   -- Set max loop count
constant register2_dp_burst_max_c       :integer:=12;   -- Set max burst length
constant register2_dp_burst_max2_c      :integer:=27;   -- Set max burst length for last element
constant register2_dp_stride3_c         :integer:=13;   -- Set outer loop stride count
constant register2_dp_stride3_count_c   :integer:=14;   -- Set outer loop count
constant register2_dp_stride3_max_c     :integer:=15;   -- Set max loop count
constant register2_dp_stride4_c         :integer:=16;   -- Set outer loop stride count
constant register2_dp_stride4_count_c   :integer:=17;   -- Set outer loop count
constant register2_dp_stride4_max_c     :integer:=18;   -- Set max loop count
constant register2_dp_mode_c            :integer:=19;   -- Transfer mode: full precision(bit0)/scatter(bit1)
constant register2_dp_stride0_min_c     :integer:=20;   -- Set max loop count
constant register2_dp_stride1_min_c     :integer:=21;   -- Set max loop count
constant register2_dp_stride2_min_c     :integer:=22;   -- Set max loop count
constant register2_dp_stride3_min_c     :integer:=23;   -- Set max loop count
constant register2_dp_stride4_min_c     :integer:=24;   -- Set max loop count
constant register2_dp_burst_min_c       :integer:=25;   -- Set max burst length
constant register2_dp_totalcount_c      :integer:=26;   -- Set total transfer size
constant register2_dp_data_c            :integer:=28;   -- Constant data
constant register2_dp_fork_stride_c     :integer:=29;   -- Fork stride
constant register2_dp_fork_count_c      :integer:=30;   -- Fork count
constant register2_dp_bufsize_c         :integer:=31;   -- Set transfer base address
constant register2_dp_burst_max_init_c  :integer:=32;   -- Initial value of burst_max
constant register2_dp_burst_max_index_c :integer:=33;   -- stride index where last entry changes burst_max
constant register2_dp_burst_max_len_c   :integer:=34;   -- burst max length

----------
--- APB register map
---------

constant apb_addr_len_c:integer:=8;

constant apb_led_c:integer:=0;

constant apb_pb_c:integer:=8;

constant apb_wvdma_enable_c:integer:=12; 

constant apb_wvdma_get_curr_c:integer:=16;  

constant apb_wvdma_buf0_c:integer:=20;

constant apb_wvdma_buf1_c:integer:=24;

constant apb_wvdma_buf2_c:integer:=28;

constant apb_wvdma_buf3_c:integer:=32;

constant apb_rvdma_enable_c:integer:=36; 

constant apb_rvdma_get_curr_c:integer:=40;  

constant apb_rvdma_buf0_c:integer:=44;

constant apb_rvdma_buf1_c:integer:=48;

constant apb_rvdma_buf2_c:integer:=52;

constant apb_rvdma_buf3_c:integer:=56;

constant apb_uart_read_c:integer:=60;

constant apb_uart_write_c:integer:=64;

constant apb_uart_read_avail_c:integer:=68;

constant apb_uart_write_avail_c:integer:=72;

constant apb_time_get_c:integer:=76;

-----------------------------------------------------------------------------
--
--                       Component declaration
--
-----------------------------------------------------------------------------

component ztachip IS
    port(   
            clock_in                      : IN STD_LOGIC;
            clock_x2_in                   : IN STD_LOGIC;
            reset_in                      : IN STD_LOGIC;                       
                    
            axi_araddr_out                : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            axi_arlen_out                 : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
            axi_arvalid_out               : OUT std_logic;
            axi_rvalid_in                 : IN std_logic;
            axi_rlast_in                  : IN std_logic;
            axi_rdata_in                  : IN std_logic_vector(ddr_data_width_c-1 downto 0);
            axi_arready_in                : IN std_logic;
            axi_rready_out                : OUT std_logic;
            axi_arburst_out               : OUT std_logic_vector(1 downto 0);
            axi_arcache_out               : OUT std_logic_vector(3 downto 0);
            axi_arid_out                  : OUT std_logic_vector(0 downto 0);
            axi_arlock_out                : OUT std_logic_vector(0 downto 0);
            axi_arprot_out                : OUT std_logic_vector(2 downto 0);
            axi_arqos_out                 : OUT std_logic_vector(3 downto 0); 
            axi_arsize_out                : OUT std_logic_vector(2 downto 0);
            
            axi_awaddr_out                : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            axi_awlen_out                 : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
            axi_awvalid_out               : OUT std_logic;
            axi_waddr_out                 : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            axi_wvalid_out                : OUT std_logic;
            axi_wdata_out                 : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
            axi_wlast_out                 : OUT std_logic;
            axi_wbe_out                   : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0);
            axi_awready_in                : IN std_logic;
            axi_wready_in                 : IN std_logic;
            axi_bresp_in                  : IN std_logic;
            axi_awburst_out               : OUT std_logic_vector(1 downto 0);
            axi_awcache_out               : OUT std_logic_vector(3 downto 0);
            axi_awid_out                  : OUT std_logic_vector(0 downto 0);
            axi_awlock_out                : OUT std_logic_vector(0 downto 0);
            axi_awprot_out                : OUT std_logic_vector(2 downto 0);
            axi_awqos_out                 : OUT std_logic_vector(3 downto 0);
            axi_awsize_out                : OUT std_logic_vector(2 downto 0);
            axi_bready_out                : OUT std_logic;           
                        
            -- Host interface 

            axilite_araddr_in             : IN std_logic_vector(io_depth_c-1 downto 0);
            axilite_arvalid_in            : IN std_logic;
            axilite_arready_out           : OUT std_logic;
            axilite_rvalid_out            : OUT std_logic;
            axilite_rlast_out             : OUT std_logic;
            axilite_rdata_out             : OUT std_logic_vector(host_width_c-1 downto 0);
            axilite_rready_in             : IN std_logic; 
            axilite_rresp_out             : OUT std_logic_vector(1 downto 0);

            axilite_awaddr_in             : IN std_logic_vector(io_depth_c-1 downto 0);
            axilite_awvalid_in            : IN std_logic;
            axilite_wvalid_in             : IN std_logic;
            axilite_wdata_in              : IN std_logic_vector(host_width_c-1 downto 0);
            axilite_awready_out           : OUT std_logic;
            axilite_wready_out            : OUT std_logic;
            axilite_bvalid_out            : OUT std_logic;
            axilite_bready_in             : IN std_logic;
            axilite_bresp_out             : OUT std_logic_vector(1 downto 0)
            );
END component;

COMPONENT host IS
    port(   
            hclock_in                     : IN STD_LOGIC;
            hreset_in                     : IN STD_LOGIC;
            pclock_in                     : IN STD_LOGIC;
            preset_in                     : IN STD_LOGIC;
            mclock_in                     : IN STD_LOGIC;
            mreset_in                     : IN STD_LOGIC;                        
            dclock_in                     : IN STD_LOGIC;
            dreset_in                     : IN STD_LOGIC;                        
            
            avalon_bus_addr_in            : IN std_logic_vector(avalon_bus_width_c-1 downto 0);
            avalon_bus_write_in           : IN std_logic;
            avalon_bus_writedata_in       : IN std_logic_vector(host_width_c-1 downto 0);
            avalon_bus_readdata_out       : OUT std_logic_vector(host_width_c-1 downto 0);
            avalon_bus_wait_request_out   : OUT std_logic;
            avalon_bus_read_in            : IN std_logic;

            -- Communication with ztachip
           
            SIGNAL host_addr_out          : OUT STD_LOGIC_VECTOR(io_depth_c-1 downto 0);
            SIGNAL host_wren_out          : OUT STD_LOGIC;  
            SIGNAL host_rden_out          : OUT STD_LOGIC;      
            SIGNAL host_writedata_out     : OUT STD_LOGIC_VECTOR(host_width_c-1 downto 0);    
            SIGNAL host_readdata_in       : IN STD_LOGIC_VECTOR(host_width_c-1 downto 0);
            SIGNAL host_readdatavalid_in  : IN STD_LOGIC;
            SIGNAL host_waitrequest_in    : IN STD_LOGIC;
            
            SIGNAL indication_avail_out   : OUT STD_LOGIC
            );
END component;

component fifo is
    PORT
    (
        aclr        : IN STD_LOGIC ;
        clock       : IN STD_LOGIC ;
        data        : IN STD_LOGIC_VECTOR (dp_instruction_width_c-1 DOWNTO 0);
        rdreq       : IN STD_LOGIC ;
        wrreq       : IN STD_LOGIC ;
        empty       : OUT STD_LOGIC ;
        full        : OUT STD_LOGIC ;
        q           : OUT STD_LOGIC_VECTOR (dp_instruction_width_c-1 DOWNTO 0);
        usedw       : OUT STD_LOGIC_VECTOR (dp_fifo_depth_c-1 DOWNTO 0)
    );
END component;

component afifo is
	generic 
	(
        DATA_WIDTH  : natural;
        FIFO_DEPTH  : natural
	);
	port 
	(
        rclock_in       : in std_logic;
        wclock_in       : in std_logic;
        reset_in        : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_in        : in std_logic;
        read_in         : in std_logic;
        q_out           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        empty_out       : out std_logic;
        full_out        : out std_logic
	);
end component;

component rom IS
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        SIGNAL rdaddress_in         : IN STD_LOGIC_VECTOR (instruction_depth_c-1 DOWNTO 0);
        SIGNAL rdaddress_plus_2_in  : IN STD_LOGIC_VECTOR (instruction_depth_c-1 DOWNTO 0);
        SIGNAL instruction_out      : OUT STD_LOGIC_VECTOR (instruction_width_c-1 DOWNTO 0);
        SIGNAL wren_in              : IN STD_LOGIC;
        SIGNAL wraddress_in         : IN STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
        SIGNAL wrdata_in            : IN STD_LOGIC_VECTOR(instruction_width_c/2-1 DOWNTO 0)
    );
END component;

COMPONENT sram_bank IS
    GENERIC(
        DEPTH       : integer
        );
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- DP interface
        SIGNAL wr_addr_in           : IN STD_LOGIC_VECTOR(DEPTH-1 downto 0);
        SIGNAL byteena_in           : IN STD_LOGIC_VECTOR(ddr_data_byte_width_c-1 downto 0);
        SIGNAL writedata_in         : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL wren_in              : IN STD_LOGIC;
        SIGNAL rden_in              : IN STD_LOGIC;
        SIGNAL rd_addr_in           : IN STD_LOGIC_VECTOR(DEPTH-1 downto 0);
        SIGNAL readdata_out         : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT sram_core IS
    PORT (
        SIGNAL clock_in                : IN STD_LOGIC;
        SIGNAL reset_in                : IN STD_LOGIC;
        -- DP interface
        SIGNAL dp_rd_addr_in           : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
        SIGNAL dp_wr_addr_in           : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
        SIGNAL dp_rd_fork_in           : IN dp_fork_t;
        SIGNAL dp_wr_fork_in           : IN dp_fork_t;
        SIGNAL dp_write_in             : IN STD_LOGIC;
        SIGNAL dp_write_vector_in      : IN dp_vector_t;
        SIGNAL dp_read_in              : IN STD_LOGIC;
        SIGNAL dp_read_vm_in           : IN STD_LOGIC;
        SIGNAL dp_read_vector_in       : IN dp_vector_t;
        SIGNAL dp_read_gen_valid_in    : IN STD_LOGIC;
        SIGNAL dp_writedata_in         : IN STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdatavalid_out    : OUT STD_LOGIC;
        SIGNAL dp_readdatavalid_vm_out : OUT STD_LOGIC;
        SIGNAL dp_readdata_out         : OUT STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT sram IS
    GENERIC(
        DEPTH : integer
        );
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- DP interface
        SIGNAL dp_rd_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
        SIGNAL dp_wr_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);        
        SIGNAL dp_write_in          : IN STD_LOGIC;
        SIGNAL dp_write_vector_in   : IN dp_vector_t;
        SIGNAL dp_read_in           : IN STD_LOGIC;
        SIGNAL dp_read_vector_in    : IN dp_vector_t;
        SIGNAL dp_read_gen_valid_in : IN STD_LOGIC;
        SIGNAL dp_writedata_in      : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdatavalid_out : OUT STD_LOGIC;
        SIGNAL dp_readdata_out      : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT ddr_tx IS
    port(
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;

        -- Bus interface for write master to DDR
        SIGNAL write_addr_in            : IN STD_LOGIC_VECTOR(dp_full_addr_width_c-1 DOWNTO 0);
        SIGNAL write_cs_in              : IN STD_LOGIC;
        SIGNAL write_in                 : IN STD_LOGIC;
        SIGNAL write_vector_in          : IN dp_vector_t;
        SIGNAL write_end_in             : IN vector_t;
        SIGNAL write_data_in            : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL write_wait_request_out   : OUT STD_LOGIC;
        SIGNAL write_burstlen_in        : IN burstlen_t;
        SIGNAL write_burstlen2_in       : IN burstlen2_t;
        SIGNAL write_burstlen3_in       : IN burstlen_t;

        SIGNAL ddr_awaddr_out           : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_awlen_out            : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
        SIGNAL ddr_awvalid_out          : OUT std_logic;
        SIGNAL ddr_waddr_out            : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_wvalid_out           : OUT std_logic;
        SIGNAL ddr_wdata_out            : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL ddr_wlast_out            : OUT std_logic;
        SIGNAL ddr_wbe_out              : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0);
        SIGNAL ddr_awready_in           : IN std_logic;
        SIGNAL ddr_wready_in            : IN std_logic;
        SIGNAL ddr_bresp_in             : IN std_logic;

        SIGNAL ddr_awburst_out          : OUT std_logic_vector(1 downto 0);
        SIGNAL ddr_awcache_out          : OUT std_logic_vector(3 downto 0);
        SIGNAL ddr_awid_out             : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_awlock_out           : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_awprot_out           : OUT std_logic_vector(2 downto 0);
        SIGNAL ddr_awqos_out            : OUT std_logic_vector(3 downto 0);
        SIGNAL ddr_awsize_out           : OUT std_logic_vector(2 downto 0);
        SIGNAL ddr_bready_out           : OUT std_logic; 
        
        SIGNAL ddr_tx_busy_out          : OUT std_logic
        );
END COMPONENT;

COMPONENT ddr_rx IS
    port(
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;

        -- Bus interface for read2 master to DDR
        SIGNAL read_addr_in             : IN STD_LOGIC_VECTOR(dp_full_addr_width_c-1 DOWNTO 0);
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

        SIGNAL ddr_araddr_out           : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_arlen_out            : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
        SIGNAL ddr_arvalid_out          : OUT std_logic;
        SIGNAL ddr_rvalid_in            : IN std_logic;
        SIGNAL ddr_rlast_in             : IN std_logic;
        SIGNAL ddr_rdata_in             : IN std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL ddr_arready_in           : IN std_logic;
        SIGNAL ddr_rready_out           : OUT std_logic;
        SIGNAL ddr_arburst_out          : OUT std_logic_vector(1 downto 0);
        SIGNAL ddr_arcache_out          : OUT std_logic_vector(3 downto 0);
        SIGNAL ddr_arid_out             : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_arlock_out           : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_arprot_out           : OUT std_logic_vector(2 downto 0);
        SIGNAL ddr_arqos_out            : OUT std_logic_vector(3 downto 0); 
        SIGNAL ddr_arsize_out           : OUT std_logic_vector(2 downto 0)
        );
END COMPONENT;

COMPONENT axilite IS
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
END COMPONENT;

COMPONENT axi_read is
    generic (
        DATA_WIDTH      : integer:=32;
        FIFO_DEPTH      : integer:=4;
        FIFO_DATA_DEPTH : integer:=4;
        CCD             : boolean:=TRUE
    );
	port 
	(
        clock_in               : in std_logic;
        reset_in               : in std_logic;

        axislave_clock_in      : IN std_logic;
        axislave_araddr_in     : IN axi_araddr_t;
        axislave_arlen_in      : IN axi_arlen_t;
        axislave_arvalid_in    : IN axi_arvalid_t;
        axislave_arid_in       : IN axi_arid_t;
        axislave_arlock_in     : IN axi_arlock_t;
        axislave_arcache_in    : IN axi_arcache_t;
        axislave_arprot_in     : IN axi_arprot_t;
        axislave_arqos_in      : IN axi_arqos_t;
        axislave_rid_out       : OUT axi_rid_t;         
        axislave_rvalid_out    : OUT axi_rvalid_t;
        axislave_rlast_out     : OUT axi_rlast_t;
        axislave_rdata_out     : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        axislave_rresp_out     : OUT axi_rresp_t;
        axislave_arready_out   : OUT axi_arready_t;
        axislave_rready_in     : IN axi_rready_t;
        axislave_arburst_in    : IN axi_arburst_t;
        axislave_arsize_in     : IN axi_arsize_t;
         
        aximaster_clock_in     : IN std_logic;
        aximaster_araddr_out   : OUT axi_araddr_t;
        aximaster_arlen_out    : OUT axi_arlen_t;
        aximaster_arvalid_out  : OUT axi_arvalid_t;
        aximaster_arid_out     : OUT axi_arid_t;
        aximaster_arlock_out   : OUT axi_arlock_t;
        aximaster_arcache_out  : OUT axi_arcache_t;
        aximaster_arprot_out   : OUT axi_arprot_t;
        aximaster_arqos_out    : OUT axi_arqos_t;
        aximaster_rid_in       : IN axi_rid_t;
        aximaster_rvalid_in    : IN axi_rvalid_t;
        aximaster_rlast_in     : IN axi_rlast_t;
        aximaster_rdata_in     : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        aximaster_rresp_in     : IN axi_rresp_t;
        aximaster_arready_in   : IN axi_arready_t;
        aximaster_rready_out   : OUT axi_rready_t;
        aximaster_arburst_out  : OUT axi_arburst_t;
        aximaster_arsize_out   : OUT axi_arsize_t
	);
end component;

COMPONENT axi_write is
    generic (
        DATA_WIDTH      : integer:=32;
        FIFO_DEPTH      : integer:=4;
        FIFO_DATA_DEPTH : integer:=4;
        CCD             : boolean:=TRUE
    );
	port 
	(
        clock_in               : in std_logic;
        reset_in               : in std_logic;

        axislave_clock_in           : IN std_logic;
        axislave_awaddr_in          : IN axi_awaddr_t;
        axislave_awlen_in           : IN axi_awlen_t;
        axislave_awvalid_in         : IN axi_awvalid_t;
        axislave_wvalid_in          : IN axi_wvalid_t;
        axislave_wdata_in           : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        axislave_wlast_in           : IN axi_wlast_t;
        axislave_wstrb_in           : IN STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
        axislave_awready_out        : OUT axi_awready_t;
        axislave_wready_out         : OUT axi_wready_t;
        axislave_bresp_out          : OUT axi_bresp_t;
        axislave_bid_out            : OUT axi_bid_t;
        axislave_bvalid_out         : OUT axi_bvalid_t;
        axislave_awburst_in         : IN axi_awburst_t;
        axislave_awcache_in         : IN axi_awcache_t;
        axislave_awid_in            : IN axi_awid_t;
        axislave_awlock_in          : IN axi_awlock_t;
        axislave_awprot_in          : IN axi_awprot_t;
        axislave_awqos_in           : IN axi_awqos_t;
        axislave_awsize_in          : IN axi_awsize_t;
        axislave_bready_in          : IN axi_bready_t;
       
        aximaster_clock_in          : IN std_logic;
        aximaster_awaddr_out        : OUT axi_awaddr_t;
        aximaster_awlen_out         : OUT axi_awlen_t;
        aximaster_awvalid_out       : OUT axi_awvalid_t;
        aximaster_wvalid_out        : OUT axi_wvalid_t;
        aximaster_wdata_out         : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        aximaster_wlast_out         : OUT axi_wlast_t;
        aximaster_wstrb_out         : OUT STD_LOGIC_VECTOR((DATA_WIDTH/8)-1 downto 0);
        aximaster_awready_in        : IN axi_awready_t;
        aximaster_wready_in         : IN axi_wready_t;
        aximaster_bresp_in          : IN axi_bresp_t;
        aximaster_bid_in            : IN axi_bid_t;
        aximaster_bvalid_in         : IN axi_bvalid_t;
        aximaster_awburst_out       : OUT axi_awburst_t;
        aximaster_awcache_out       : OUT axi_awcache_t;
        aximaster_awid_out          : OUT axi_awid_t;
        aximaster_awlock_out        : OUT axi_awlock_t;
        aximaster_awprot_out        : OUT axi_awprot_t;
        aximaster_awqos_out         : OUT axi_awqos_t;
        aximaster_awsize_out        : OUT axi_awsize_t;
        aximaster_bready_out        : OUT axi_bready_t
	);
end COMPONENT;

constant MAX_SLAVE_PORT:integer:=3;

COMPONENT axi_merge_read is
    generic (
        NUM_SLAVE_PORT     : integer:=3;
        FIFO_CMD_DEPTH     : integer_array(2 downto 0);
        FIFO_DATA_DEPTH    : integer_array(2 downto 0);
        FIFO_W_CMD_DEPTH   : integer;
        FIFO_W_DATA_DEPTH  : integer
    );
	port 
	(
        clock_in                : IN std_logic;
        reset_in                : IN std_logic;

        axislavew_clock_in      : IN std_logic;
        axislavew_araddr_in     : IN axi_araddr_t:=(others=>'0');
        axislavew_arlen_in      : IN axi_arlen_t:=(others=>'0');
        axislavew_arvalid_in    : IN axi_arvalid_t:='0';     
        axislavew_arid_in       : IN axi_arid_t:=(others=>'0');
        axislavew_arlock_in     : IN axi_arlock_t:=(others=>'0');
        axislavew_arcache_in    : IN axi_arcache_t:=(others=>'0');
        axislavew_arprot_in     : IN axi_arprot_t:=(others=>'0');
        axislavew_arqos_in      : IN axi_arqos_t:=(others=>'0');
        axislavew_rid_out       : OUT axi_rid_t:=(others=>'0');
        axislavew_rvalid_out    : OUT axi_rvalid_t;
        axislavew_rlast_out     : OUT axi_rlast_t;
        axislavew_rdata_out     : OUT axi_rdata64_t;
        axislavew_rresp_out     : OUT axi_rresp_t;
        axislavew_arready_out   : OUT axi_arready_t;
        axislavew_rready_in     : IN axi_rready_t:='0';
        axislavew_arburst_in    : IN axi_arburst_t:=(others=>'0');
        axislavew_arsize_in     : IN axi_arsize_t:=(others=>'0');
        
        axislave_clocks_in      : IN std_logic_vector(MAX_SLAVE_PORT-1 downto 0);
        axislave_araddrs_in     : IN axi_araddrs_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_arlens_in      : IN axi_arlens_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_arvalids_in    : IN axi_arvalids_t(MAX_SLAVE_PORT-1 downto 0):=(others=>'0');     
        axislave_arids_in       : IN axi_arids_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_arlocks_in     : IN axi_arlocks_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_arcaches_in    : IN axi_arcaches_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_arprots_in     : IN axi_arprots_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_arqoss_in      : IN axi_arqoss_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_rids_out       : OUT axi_rids_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_rvalids_out    : OUT axi_rvalids_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_rlasts_out     : OUT axi_rlasts_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_rdatas_out     : OUT axi_rdata64s_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_rresps_out     : OUT axi_rresps_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_arreadys_out   : OUT axi_arreadys_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_rreadys_in     : IN axi_rreadys_t(MAX_SLAVE_PORT-1 downto 0):=(others=>'0');
        axislave_arbursts_in    : IN axi_arbursts_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        axislave_arsizes_in     : IN axi_arsizes_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
        
        aximaster_araddr_out    : OUT axi_araddr_t;
        aximaster_arlen_out     : OUT axi_arlen_t;
        aximaster_arvalid_out   : OUT axi_arvalid_t;
        aximaster_arid_out      : OUT axi_arid_t;
        aximaster_arlock_out    : OUT axi_arlock_t;
        aximaster_arcache_out   : OUT axi_arcache_t;
        aximaster_arprot_out    : OUT axi_arprot_t;
        aximaster_arqos_out     : OUT axi_arqos_t;
        aximaster_rid_in        : IN axi_rid_t;              
        aximaster_rvalid_in     : IN axi_rvalid_t;
        aximaster_rlast_in      : IN axi_rlast_t;
        aximaster_rdata_in      : IN axi_rdata64_t;
        aximaster_rdata_mask_out: OUT std_logic_vector(1 downto 0);
        aximaster_rresp_in      : IN axi_rresp_t;
        aximaster_arready_in    : IN axi_arready_t;
        aximaster_rready_out    : OUT axi_rready_t;
        aximaster_arburst_out   : OUT axi_arburst_t;
        aximaster_arsize_out    : OUT axi_arsize_t
	);
end COMPONENT;

component axi_merge_write is
    generic (
        NUM_SLAVE_PORT     : integer:=3;
        FIFO_CMD_DEPTH     : integer_array(2 downto 0);
        FIFO_DATA_DEPTH    : integer_array(2 downto 0);
        FIFO_W_CMD_DEPTH   : integer;
        FIFO_W_DATA_DEPTH  : integer
    );
	port 
	(
        clock_in           : IN std_logic;
        reset_in           : IN std_logic;
        
        axislavew_clock_in           : IN std_logic;
        axislavew_awaddr_in          : IN axi_awaddr_t;
        axislavew_awlen_in           : IN axi_awlen_t;
        axislavew_awvalid_in         : IN axi_awvalid_t;
        axislavew_wvalid_in          : IN axi_wvalid_t;
        axislavew_wdata_in           : IN axi_wdata64_t;
        axislavew_wlast_in           : IN axi_wlast_t;
        axislavew_wstrb_in           : IN axi_wstrb8_t;
        axislavew_awready_out        : OUT axi_awready_t;
        axislavew_wready_out         : OUT axi_wready_t;
        axislavew_bresp_out          : OUT axi_bresp_t;
        axislavew_bid_out            : OUT axi_bid_t;
        axislavew_bvalid_out         : OUT axi_bvalid_t;
        axislavew_awburst_in         : IN axi_awburst_t;
        axislavew_awcache_in         : IN axi_awcache_t;
        axislavew_awid_in            : IN axi_awid_t;
        axislavew_awlock_in          : IN axi_awlock_t;
        axislavew_awprot_in          : IN axi_awprot_t;
        axislavew_awqos_in           : IN axi_awqos_t;
        axislavew_awsize_in          : IN axi_awsize_t;
        axislavew_bready_in          : IN axi_bready_t;
        
        axislave_clocks_in           : IN std_logic_vector(MAX_SLAVE_PORT-1 downto 0);
        axislave_awaddrs_in          : IN axi_awaddrs_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awlens_in           : IN axi_awlens_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awvalids_in         : IN axi_awvalids_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_wvalids_in          : IN axi_wvalids_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_wdatas_in           : IN axi_wdata64s_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_wlasts_in           : IN axi_wlasts_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_wstrbs_in           : IN axi_wstrb8s_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awreadys_out        : OUT axi_awreadys_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_wreadys_out         : OUT axi_wreadys_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_bresps_out          : OUT axi_bresps_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_bids_out            : OUT axi_bids_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_bvalids_out         : OUT axi_bvalids_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awbursts_in         : IN axi_awbursts_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awcaches_in         : IN axi_awcaches_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awids_in            : IN axi_awids_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awlocks_in          : IN axi_awlocks_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awprots_in          : IN axi_awprots_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awqoss_in           : IN axi_awqoss_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_awsizes_in          : IN axi_awsizes_t(MAX_SLAVE_PORT-1 downto 0);
        axislave_breadys_in          : IN axi_breadys_t(MAX_SLAVE_PORT-1 downto 0);
        
        aximaster_awaddr_out         : OUT axi_awaddr_t;
        aximaster_awlen_out          : OUT axi_awlen_t;
        aximaster_awvalid_out        : OUT axi_awvalid_t;
        aximaster_wvalid_out         : OUT axi_wvalid_t;
        aximaster_wdata_out          : OUT axi_wdata64_t;
        aximaster_wdata_mask_out     : OUT std_logic_vector(1 downto 0);
        aximaster_wlast_out          : OUT axi_wlast_t;
        aximaster_wstrb_out          : OUT axi_wstrb8_t;
        aximaster_awready_in         : IN axi_awready_t;
        aximaster_wready_in          : IN axi_wready_t;
        aximaster_bresp_in           : IN axi_bresp_t;
        aximaster_bid_in             : IN axi_bid_t;
        aximaster_bvalid_in          : IN axi_bvalid_t;
        aximaster_awburst_out        : OUT axi_awburst_t;
        aximaster_awcache_out        : OUT axi_awcache_t;
        aximaster_awid_out           : OUT axi_awid_t;
        aximaster_awlock_out         : OUT axi_awlock_t;
        aximaster_awprot_out         : OUT axi_awprot_t;
        aximaster_awqos_out          : OUT axi_awqos_t;
        aximaster_awsize_out         : OUT axi_awsize_t;
        aximaster_bready_out         : OUT axi_bready_t
	);
end component;

component axi_split_read is
   generic (
      NUM_MASTER_PORT     : integer:=4;
      NUM_MASTER_PORT_USED: integer:=4;
      BAR_LO_BIT          : integer_array(3 downto 0);
      BAR_HI_BIT          : integer_array(3 downto 0);
      BAR                 : integer_array(3 downto 0)
   );
   port 
   (
      clock_in                : in std_logic;
      reset_in                : in std_logic;
               
      -- Slave port 
      axislave_araddr_in      : IN axi_araddr_t;
      axislave_arlen_in       : IN axi_arlen_t;
      axislave_arvalid_in     : IN axi_arvalid_t;
      axislave_arid_in        : IN axi_arid_t;
      axislave_arlock_in      : IN axi_arlock_t;
      axislave_arcache_in     : IN axi_arcache_t;
      axislave_arprot_in      : IN axi_arprot_t;
      axislave_arqos_in       : IN axi_arqos_t;
      axislave_rid_out        : OUT axi_rid_t;          
      axislave_rvalid_out     : OUT axi_rvalid_t;
      axislave_rlast_out      : OUT axi_rlast_t;
      axislave_rdata_out      : OUT axi_rdata_t;
      axislave_rresp_out      : OUT axi_rresp_t;
      axislave_arready_out    : OUT axi_arready_t;
      axislave_rready_in      : IN axi_rready_t;
      axislave_arburst_in     : IN axi_arburst_t;
      axislave_arsize_in      : IN axi_arsize_t;

      -- Master ports
      aximaster_araddrs_out   : OUT axi_araddrs_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arlens_out    : OUT axi_arlens_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arvalids_out  : OUT axi_arvalids_t(NUM_MASTER_PORT-1 downto 0);    
      aximaster_arids_out     : OUT axi_arids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arlocks_out   : OUT axi_arlocks_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arcaches_out  : OUT axi_arcaches_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arprots_out   : OUT axi_arprots_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arqoss_out    : OUT axi_arqoss_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_rids_in       : IN axi_rids_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_rvalids_in    : IN axi_rvalids_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_rlasts_in     : IN axi_rlasts_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_rdatas_in     : IN axi_rdatas_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_rresps_in     : IN axi_rresps_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_arreadys_in   : IN axi_arreadys_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_rreadys_out   : OUT axi_rreadys_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arbursts_out  : OUT axi_arbursts_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arsizes_out   : OUT axi_arsizes_t(NUM_MASTER_PORT-1 downto 0)
   );
end component;

component axi_split_write is
   generic (
      NUM_MASTER_PORT     : integer:=4;
      NUM_MASTER_PORT_USED: integer:=4;
      BAR_LO_BIT          : integer_array(3 downto 0);
      BAR_HI_BIT          : integer_array(3 downto 0);
      BAR                 : integer_array(3 downto 0)
   );
   port 
   (
      clock_in                   : in std_logic;
      reset_in                   : in std_logic;
            
      axislave_awaddr_in         : IN axi_awaddr_t;
      axislave_awlen_in          : IN axi_awlen_t;
      axislave_awvalid_in        : IN axi_awvalid_t;
      axislave_wvalid_in         : IN axi_wvalid_t;
      axislave_wdata_in          : IN axi_wdata_t;
      axislave_wlast_in          : IN axi_wlast_t;
      axislave_wstrb_in          : IN axi_wstrb_t;
      axislave_awready_out       : OUT axi_awready_t;
      axislave_wready_out        : OUT axi_wready_t;
      axislave_bresp_out         : OUT axi_bresp_t;
      axislave_bid_out           : OUT axi_bid_t;
      axislave_bvalid_out        : OUT axi_bvalid_t;
      axislave_awburst_in        : IN axi_awburst_t;
      axislave_awcache_in        : IN axi_awcache_t;
      axislave_awid_in           : IN axi_awid_t;
      axislave_awlock_in         : IN axi_awlock_t;
      axislave_awprot_in         : IN axi_awprot_t;
      axislave_awqos_in          : IN axi_awqos_t;
      axislave_awsize_in         : IN axi_awsize_t;
      axislave_bready_in         : IN axi_bready_t;

      -- Slave port
      aximaster_awaddrs_out      : OUT axi_awaddrs_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awlens_out       : OUT axi_awlens_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awvalids_out     : OUT axi_awvalids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wvalids_out      : OUT axi_wvalids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wdatas_out       : OUT axi_wdatas_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wlasts_out       : OUT axi_wlasts_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wstrbs_out       : OUT axi_wstrbs_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awreadys_in      : IN axi_awreadys_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_wreadys_in       : IN axi_wreadys_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_bresps_in        : IN axi_bresps_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_bids_in          : IN axi_bids_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_bvalids_in       : IN axi_bvalids_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_awbursts_out     : OUT axi_awbursts_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awcaches_out     : OUT axi_awcaches_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awids_out        : OUT axi_awids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awlocks_out      : OUT axi_awlocks_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awprots_out      : OUT axi_awprots_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awqoss_out       : OUT axi_awqoss_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awsizes_out      : OUT axi_awsizes_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_breadys_out      : OUT axi_breadys_t(NUM_MASTER_PORT-1 downto 0)        
   );
end component;

component axi_split is
   generic (
      NUM_MASTER_PORT       : integer:=4;
      NUM_MASTER_READ_PORT  : integer:=4;
      NUM_MASTER_WRITE_PORT : integer:=4;
      BAR_LO_BIT            : integer_array(3 downto 0);
      BAR_HI_BIT            : integer_array(3 downto 0);
      BAR                   : integer_array(3 downto 0)
   );
   port 
   (
      clock_in               : in std_logic;
      reset_in               : in std_logic;

      -- Slave port
      axislave_araddr_in     : IN axi_araddr_t;
      axislave_arlen_in      : IN axi_arlen_t;
      axislave_arvalid_in    : IN axi_arvalid_t;     
      axislave_arid_in       : IN axi_arid_t;
      axislave_arlock_in     : IN axi_arlock_t;
      axislave_arcache_in    : IN axi_arcache_t;
      axislave_arprot_in     : IN axi_arprot_t;
      axislave_arqos_in      : IN axi_arqos_t;
      axislave_rid_out       : OUT axi_rid_t;
      axislave_rvalid_out    : OUT axi_rvalid_t;
      axislave_rlast_out     : OUT axi_rlast_t;
      axislave_rdata_out     : OUT axi_rdata_t;
      axislave_rresp_out     : OUT axi_rresp_t;
      axislave_arready_out   : OUT axi_arready_t;
      axislave_rready_in     : IN axi_rready_t;
      axislave_arburst_in    : IN axi_arburst_t;
      axislave_arsize_in     : IN axi_arsize_t;

      axislave_awaddr_in     : IN axi_awaddr_t:=(others=>'0');
      axislave_awlen_in      : IN axi_awlen_t:=(others=>'0');
      axislave_awvalid_in    : IN axi_awvalid_t:='0';
      axislave_wvalid_in     : IN axi_wvalid_t:='0';
      axislave_wdata_in      : IN axi_wdata_t:=(others=>'0');
      axislave_wlast_in      : IN axi_wlast_t:='0';
      axislave_wstrb_in      : IN axi_wstrb_t:=(others=>'0');
      axislave_awready_out   : OUT axi_awready_t;
      axislave_wready_out    : OUT axi_wready_t;
      axislave_bresp_out     : OUT axi_bresp_t;
      axislave_bid_out       : OUT axi_bid_t;
      axislave_bvalid_out    : OUT axi_bvalid_t;
      axislave_awburst_in    : IN axi_awburst_t:=(others=>'0');
      axislave_awcache_in    : IN axi_awcache_t:=(others=>'0');
      axislave_awid_in       : IN axi_awid_t:=(others=>'0');
      axislave_awlock_in     : IN axi_awlock_t:=(others=>'0');
      axislave_awprot_in     : IN axi_awprot_t:=(others=>'0');
      axislave_awqos_in      : IN axi_awqos_t:=(others=>'0');
      axislave_awsize_in     : IN axi_awsize_t:=(others=>'0');
      axislave_bready_in     : IN axi_bready_t:='0';
                           
      -- Master port #0
      aximaster0_araddr_out  : OUT axi_araddr_t;
      aximaster0_arlen_out   : OUT axi_arlen_t;
      aximaster0_arvalid_out : OUT axi_arvalid_t;
      aximaster0_arid_out    : OUT axi_arid_t;
      aximaster0_arlock_out  : OUT axi_arlock_t;
      aximaster0_arcache_out : OUT axi_arcache_t;
      aximaster0_arprot_out  : OUT axi_arprot_t;
      aximaster0_arqos_out   : OUT axi_arqos_t;
      aximaster0_rid_in      : IN axi_rid_t:=(others=>'0');              
      aximaster0_rvalid_in   : IN axi_rvalid_t:='0';
      aximaster0_rlast_in    : IN axi_rlast_t:='0';
      aximaster0_rdata_in    : IN axi_rdata_t:=(others=>'0');
      aximaster0_rresp_in    : IN axi_rresp_t:=(others=>'0');
      aximaster0_arready_in  : IN axi_arready_t:='0';
      aximaster0_rready_out  : OUT axi_rready_t;
      aximaster0_arburst_out : OUT axi_arburst_t;
      aximaster0_arsize_out  : OUT axi_arsize_t;

      aximaster0_awaddr_out  : OUT axi_awaddr_t;
      aximaster0_awlen_out   : OUT axi_awlen_t;
      aximaster0_awvalid_out : OUT axi_awvalid_t;
      aximaster0_wvalid_out  : OUT axi_wvalid_t;
      aximaster0_wdata_out   : OUT axi_wdata_t;
      aximaster0_wlast_out   : OUT axi_wlast_t;
      aximaster0_wstrb_out   : OUT axi_wstrb_t;
      aximaster0_awready_in  : IN axi_awready_t:='0';
      aximaster0_wready_in   : IN axi_wready_t:='0';
      aximaster0_bresp_in    : IN axi_bresp_t:=(others=>'0');
      aximaster0_bid_in      : IN axi_bid_t:=(others=>'0');
      aximaster0_bvalid_in   : IN axi_bvalid_t:='0';
      aximaster0_awburst_out : OUT axi_awburst_t;
      aximaster0_awcache_out : OUT axi_awcache_t;
      aximaster0_awid_out    : OUT axi_awid_t;
      aximaster0_awlock_out  : OUT axi_awlock_t;
      aximaster0_awprot_out  : OUT axi_awprot_t;
      aximaster0_awqos_out   : OUT axi_awqos_t;
      aximaster0_awsize_out  : OUT axi_awsize_t;
      aximaster0_bready_out  : OUT axi_bready_t;

      -- Master port #1
      aximaster1_araddr_out  : OUT axi_araddr_t;
      aximaster1_arlen_out   : OUT axi_arlen_t;
      aximaster1_arvalid_out : OUT axi_arvalid_t;
      aximaster1_arid_out    : OUT axi_arid_t;
      aximaster1_arlock_out  : OUT axi_arlock_t;
      aximaster1_arcache_out : OUT axi_arcache_t;
      aximaster1_arprot_out  : OUT axi_arprot_t;
      aximaster1_arqos_out   : OUT axi_arqos_t;
      aximaster1_rid_in      : IN axi_rid_t:=(others=>'0');              
      aximaster1_rvalid_in   : IN axi_rvalid_t:='0';
      aximaster1_rlast_in    : IN axi_rlast_t:='0';
      aximaster1_rdata_in    : IN axi_rdata_t:=(others=>'0');
      aximaster1_rresp_in    : IN axi_rresp_t:=(others=>'0');
      aximaster1_arready_in  : IN axi_arready_t:='0';
      aximaster1_rready_out  : OUT axi_rready_t;
      aximaster1_arburst_out : OUT axi_arburst_t;
      aximaster1_arsize_out  : OUT axi_arsize_t;

      aximaster1_awaddr_out  : OUT axi_awaddr_t;
      aximaster1_awlen_out   : OUT axi_awlen_t;
      aximaster1_awvalid_out : OUT axi_awvalid_t;
      aximaster1_wvalid_out  : OUT axi_wvalid_t;
      aximaster1_wdata_out   : OUT axi_wdata_t;
      aximaster1_wlast_out   : OUT axi_wlast_t;
      aximaster1_wstrb_out   : OUT axi_wstrb_t;
      aximaster1_awready_in  : IN axi_awready_t:='0';
      aximaster1_wready_in   : IN axi_wready_t:='0';
      aximaster1_bresp_in    : IN axi_bresp_t:=(others=>'0');
      aximaster1_bid_in      : IN axi_bid_t:=(others=>'0');
      aximaster1_bvalid_in   : IN axi_bvalid_t:='0';
      aximaster1_awburst_out : OUT axi_awburst_t;
      aximaster1_awcache_out : OUT axi_awcache_t;
      aximaster1_awid_out    : OUT axi_awid_t;
      aximaster1_awlock_out  : OUT axi_awlock_t;
      aximaster1_awprot_out  : OUT axi_awprot_t;
      aximaster1_awqos_out   : OUT axi_awqos_t;
      aximaster1_awsize_out  : OUT axi_awsize_t;
      aximaster1_bready_out  : OUT axi_bready_t;

      -- Master port #2
      aximaster2_araddr_out  : OUT axi_araddr_t;
      aximaster2_arlen_out   : OUT axi_arlen_t;
      aximaster2_arvalid_out : OUT axi_arvalid_t;
      aximaster2_arid_out    : OUT axi_arid_t;
      aximaster2_arlock_out  : OUT axi_arlock_t;
      aximaster2_arcache_out : OUT axi_arcache_t;
      aximaster2_arprot_out  : OUT axi_arprot_t;
      aximaster2_arqos_out   : OUT axi_arqos_t;
      aximaster2_rid_in      : IN axi_rid_t:=(others=>'0');              
      aximaster2_rvalid_in   : IN axi_rvalid_t:='0';
      aximaster2_rlast_in    : IN axi_rlast_t:='0';
      aximaster2_rdata_in    : IN axi_rdata_t:=(others=>'0');
      aximaster2_rresp_in    : IN axi_rresp_t:=(others=>'0');
      aximaster2_arready_in  : IN axi_arready_t:='0';
      aximaster2_rready_out  : OUT axi_rready_t;
      aximaster2_arburst_out : OUT axi_arburst_t;
      aximaster2_arsize_out  : OUT axi_arsize_t;

      aximaster2_awaddr_out  : OUT axi_awaddr_t;
      aximaster2_awlen_out   : OUT axi_awlen_t;
      aximaster2_awvalid_out : OUT axi_awvalid_t;
      aximaster2_wvalid_out  : OUT axi_wvalid_t;
      aximaster2_wdata_out   : OUT axi_wdata_t;
      aximaster2_wlast_out   : OUT axi_wlast_t;
      aximaster2_wstrb_out   : OUT axi_wstrb_t;
      aximaster2_awready_in  : IN axi_awready_t:='0';
      aximaster2_wready_in   : IN axi_wready_t:='0';
      aximaster2_bresp_in    : IN axi_bresp_t:=(others=>'0');
      aximaster2_bid_in      : IN axi_bid_t:=(others=>'0');
      aximaster2_bvalid_in   : IN axi_bvalid_t:='0';
      aximaster2_awburst_out : OUT axi_awburst_t;
      aximaster2_awcache_out : OUT axi_awcache_t;
      aximaster2_awid_out    : OUT axi_awid_t;
      aximaster2_awlock_out  : OUT axi_awlock_t;
      aximaster2_awprot_out  : OUT axi_awprot_t;
      aximaster2_awqos_out   : OUT axi_awqos_t;
      aximaster2_awsize_out  : OUT axi_awsize_t;
      aximaster2_bready_out  : OUT axi_bready_t;

      -- Master port #3
      aximaster3_araddr_out  : OUT axi_araddr_t;
      aximaster3_arlen_out   : OUT axi_arlen_t;
      aximaster3_arvalid_out : OUT axi_arvalid_t;
      aximaster3_arid_out    : OUT axi_arid_t;
      aximaster3_arlock_out  : OUT axi_arlock_t;
      aximaster3_arcache_out : OUT axi_arcache_t;
      aximaster3_arprot_out  : OUT axi_arprot_t;
      aximaster3_arqos_out   : OUT axi_arqos_t;
      aximaster3_rid_in      : IN axi_rid_t:=(others=>'0');              
      aximaster3_rvalid_in   : IN axi_rvalid_t:='0';
      aximaster3_rlast_in    : IN axi_rlast_t:='0';
      aximaster3_rdata_in    : IN axi_rdata_t:=(others=>'0');
      aximaster3_rresp_in    : IN axi_rresp_t:=(others=>'0');
      aximaster3_arready_in  : IN axi_arready_t:='0';
      aximaster3_rready_out  : OUT axi_rready_t;
      aximaster3_arburst_out : OUT axi_arburst_t;
      aximaster3_arsize_out  : OUT axi_arsize_t;

      aximaster3_awaddr_out  : OUT axi_awaddr_t;
      aximaster3_awlen_out   : OUT axi_awlen_t;
      aximaster3_awvalid_out : OUT axi_awvalid_t;
      aximaster3_wvalid_out  : OUT axi_wvalid_t;
      aximaster3_wdata_out   : OUT axi_wdata_t;
      aximaster3_wlast_out   : OUT axi_wlast_t;
      aximaster3_wstrb_out   : OUT axi_wstrb_t;
      aximaster3_awready_in  : IN axi_awready_t:='0';
      aximaster3_wready_in   : IN axi_wready_t:='0';
      aximaster3_bresp_in    : IN axi_bresp_t:=(others=>'0');
      aximaster3_bid_in      : IN axi_bid_t:=(others=>'0');
      aximaster3_bvalid_in   : IN axi_bvalid_t:='0';
      aximaster3_awburst_out : OUT axi_awburst_t;
      aximaster3_awcache_out : OUT axi_awcache_t;
      aximaster3_awid_out    : OUT axi_awid_t;
      aximaster3_awlock_out  : OUT axi_awlock_t;
      aximaster3_awprot_out  : OUT axi_awprot_t;
      aximaster3_awqos_out   : OUT axi_awqos_t;
      aximaster3_awsize_out  : OUT axi_awsize_t;
      aximaster3_bready_out  : OUT axi_bready_t
   );
end component;

component axi_apb_bridge is
	port 
	(
        clock_in                   : in std_logic;
        reset_in                   : in std_logic;
        
        axislave_araddr_in         : IN axi_araddr_t;
        axislave_arlen_in          : IN axi_arlen_t;
        axislave_arvalid_in        : IN axi_arvalid_t;
        axislave_arid_in           : IN axi_arid_t;
        axislave_arlock_in         : IN axi_arlock_t;
        axislave_arcache_in        : IN axi_arcache_t;
        axislave_arprot_in         : IN axi_arprot_t;
        axislave_arqos_in          : IN axi_arqos_t;
        axislave_rid_out           : OUT axi_rid_t;         
        axislave_rvalid_out        : OUT axi_rvalid_t;
        axislave_rlast_out         : OUT axi_rlast_t;
        axislave_rdata_out         : OUT axi_rdata_t;
        axislave_rresp_out         : OUT axi_rresp_t;
        axislave_arready_out       : OUT axi_arready_t;
        axislave_rready_in         : IN axi_rready_t;
        axislave_arburst_in        : IN axi_arburst_t;
        axislave_arsize_in         : IN axi_arsize_t;
        
        axislave_awaddr_in         : IN axi_awaddr_t;
        axislave_awlen_in          : IN axi_awlen_t;
        axislave_awvalid_in        : IN axi_awvalid_t;
        axislave_wvalid_in         : IN axi_wvalid_t;
        axislave_wdata_in          : IN axi_wdata_t;
        axislave_wlast_in          : IN axi_wlast_t;
        axislave_wstrb_in          : IN axi_wstrb_t;
        axislave_awready_out       : OUT axi_awready_t;
        axislave_wready_out        : OUT axi_wready_t;
        axislave_bresp_out         : OUT axi_bresp_t;
        axislave_bid_out           : OUT axi_bid_t;
        axislave_bvalid_out        : OUT axi_bvalid_t;
        axislave_awburst_in        : IN axi_awburst_t;
        axislave_awcache_in        : IN axi_awcache_t;
        axislave_awid_in           : IN axi_awid_t;
        axislave_awlock_in         : IN axi_awlock_t;
        axislave_awprot_in         : IN axi_awprot_t;
        axislave_awqos_in          : IN axi_awqos_t;
        axislave_awsize_in         : IN axi_awsize_t;
        axislave_bready_in         : IN axi_bready_t;
        
        apb_paddr_out              : OUT STD_LOGIC_VECTOR(19 downto 0);
        apb_penable_out            : OUT STD_LOGIC;
        apb_pready_in              : IN STD_LOGIC;
        apb_pwrite_out             : OUT STD_LOGIC;
        apb_pwdata_out             : OUT STD_LOGIC_VECTOR(31 downto 0);
        apb_prdata_in              : IN STD_LOGIC_VECTOR(31 downto 0);
        apb_pslverror_in           : IN STD_LOGIC
	);
end component;

component axi_stream_write is
    generic (
        WRITE_BUF_DEPTH       : integer:=4;
        WRITE_STREAM_DEPTH    : integer:=9;
        WRITE_PAGE_SIZE       : integer;
        WRITE_MAX_PENDING     : integer
    );
	port 
	(
        signal clock_in          : IN std_logic;
        signal reset_in          : IN std_logic;
        
        signal ddr_awaddr_out    : OUT axi_awaddr_t;
        signal ddr_awlen_out     : OUT axi_awlen_t;
        signal ddr_awvalid_out   : OUT axi_awvalid_t;
        signal ddr_wvalid_out    : OUT axi_wvalid_t;
        signal ddr_wdata_out     : OUT axi_wdata64_t;
        signal ddr_wlast_out     : OUT axi_wlast_t;
        signal ddr_wstrb_out     : OUT axi_wstrb8_t;
        signal ddr_awready_in    : IN axi_awready_t;
        signal ddr_wready_in     : IN axi_wready_t;
        signal ddr_bresp_in      : IN axi_bresp_t;
        signal ddr_bid_in        : IN axi_bid_t;
        signal ddr_bvalid_in     : IN axi_bvalid_t;
        signal ddr_awburst_out   : OUT axi_awburst_t;
        signal ddr_awcache_out   : OUT axi_awcache_t;
        signal ddr_awid_out      : OUT axi_awid_t;
        signal ddr_awlock_out    : OUT axi_awlock_t;
        signal ddr_awprot_out    : OUT axi_awprot_t;
        signal ddr_awqos_out     : OUT axi_awqos_t;
        signal ddr_awsize_out    : OUT axi_awsize_t;
        signal ddr_bready_out    : OUT axi_bready_t;
        
        signal s_wclk_in         : in std_logic;
        signal s_wdata_in        : in std_logic_vector(31 downto 0);
        signal s_wready_out      : out std_logic;
        signal s_wvalid_in       : in std_logic;
        signal s_wlast_in        : in std_logic;
        
        signal apb_paddr          : IN STD_LOGIC_VECTOR(19 downto 0);
        signal apb_penable        : IN STD_LOGIC;
        signal apb_pready         : OUT STD_LOGIC;
        signal apb_pwrite         : IN STD_LOGIC;
        signal apb_pwdata         : IN STD_LOGIC_VECTOR(31 downto 0);
        signal apb_prdata         : OUT STD_LOGIC_VECTOR(31 downto 0);
        signal apb_pslverror      : OUT STD_LOGIC;

        signal ready_out          : OUT STD_LOGIC
	);
end component;

component axi_stream_read is
    generic (
        READ_BUF_DEPTH       : integer:=4;
        READ_STREAM_DEPTH    : integer:=9;
        READ_PAGE_SIZE       : integer:=64;
        READ_MAX_PENDING     : integer:=4
    );
	port 
	(
        signal clock_in          : IN std_logic;
        signal reset_in          : IN std_logic;
        
        ddr_araddr_out           : OUT axi_araddr_t;
        ddr_arlen_out            : OUT axi_arlen_t;
        ddr_arvalid_out          : OUT axi_arvalid_t;
        ddr_arid_out             : OUT axi_arid_t;
        ddr_arlock_out           : OUT axi_arlock_t;
        ddr_arcache_out          : OUT axi_arcache_t;
        ddr_arprot_out           : OUT axi_arprot_t;
        ddr_arqos_out            : OUT axi_arqos_t;
        ddr_rid_in               : IN axi_rid_t;
        ddr_rvalid_in            : IN axi_rvalid_t;
        ddr_rlast_in             : IN axi_rlast_t;
        ddr_rdata_in             : IN STD_LOGIC_VECTOR(63 downto 0);
        ddr_rresp_in             : IN axi_rresp_t;
        ddr_arready_in           : IN axi_arready_t;
        ddr_rready_out           : OUT axi_rready_t;
        ddr_arburst_out          : OUT axi_arburst_t;
        ddr_arsize_out           : OUT axi_arsize_t;
        
        signal s_rclk_in         : in std_logic;
        signal s_rdata_out       : out std_logic_vector(31 downto 0);
        signal s_rready_in       : in std_logic;
        signal s_rvalid_out      : out std_logic;
        signal s_rlast_out       : out std_logic;
              
       signal apb_paddr          : IN STD_LOGIC_VECTOR(19 downto 0);
       signal apb_penable        : IN STD_LOGIC;
       signal apb_pready         : OUT STD_LOGIC;
       signal apb_pwrite         : IN STD_LOGIC;
       signal apb_pwdata         : IN STD_LOGIC_VECTOR(31 downto 0);
       signal apb_prdata         : OUT STD_LOGIC_VECTOR(31 downto 0);
       signal apb_pslverror      : OUT STD_LOGIC
	);
end component;

component axi_merge is
    generic (
        R_FIFO_CMD_DEPTH     : integer_array(2 downto 0);
        R_FIFO_DATA_DEPTH    : integer_array(2 downto 0);
        R_FIFO_W_CMD_DEPTH   : integer;
        R_FIFO_W_DATA_DEPTH  : integer;
        W_FIFO_CMD_DEPTH     : integer_array(2 downto 0);
        W_FIFO_DATA_DEPTH    : integer_array(2 downto 0);
        W_FIFO_W_CMD_DEPTH   : integer;
        W_FIFO_W_DATA_DEPTH  : integer
    );
	port 
	(
        clock_in                : IN std_logic;
        reset_in                : IN std_logic;

        axislavew_clock_in      : IN std_logic;
        axislavew_araddr_in     : IN axi_araddr_t;
        axislavew_arlen_in      : IN axi_arlen_t;
        axislavew_arvalid_in    : IN axi_arvalid_t;     
        axislavew_arid_in       : IN axi_arid_t;
        axislavew_arlock_in     : IN axi_arlock_t;
        axislavew_arcache_in    : IN axi_arcache_t;
        axislavew_arprot_in     : IN axi_arprot_t;
        axislavew_arqos_in      : IN axi_arqos_t;
        axislavew_rid_out       : OUT axi_rid_t;
        axislavew_rvalid_out    : OUT axi_rvalid_t;
        axislavew_rlast_out     : OUT axi_rlast_t;
        axislavew_rdata_out     : OUT axi_rdata64_t;
        axislavew_rresp_out     : OUT axi_rresp_t;
        axislavew_arready_out   : OUT axi_arready_t;
        axislavew_rready_in     : IN axi_rready_t:='0';
        axislavew_arburst_in    : IN axi_arburst_t;
        axislavew_arsize_in     : IN axi_arsize_t;
        
        axislavew_awaddr_in     : IN axi_awaddr_t;
        axislavew_awlen_in      : IN axi_awlen_t;
        axislavew_awvalid_in    : IN axi_awvalid_t;
        axislavew_wvalid_in     : IN axi_wvalid_t;
        axislavew_wdata_in      : IN axi_wdata64_t;
        axislavew_wlast_in      : IN axi_wlast_t;
        axislavew_wstrb_in      : IN axi_wstrb8_t;
        axislavew_awready_out   : OUT axi_awready_t;
        axislavew_wready_out    : OUT axi_wready_t;
        axislavew_bresp_out     : OUT axi_bresp_t;
        axislavew_bid_out       : OUT axi_bid_t;
        axislavew_bvalid_out    : OUT axi_bvalid_t;
        axislavew_awburst_in    : IN axi_awburst_t;
        axislavew_awcache_in    : IN axi_awcache_t;
        axislavew_awid_in       : IN axi_awid_t;
        axislavew_awlock_in     : IN axi_awlock_t;
        axislavew_awprot_in     : IN axi_awprot_t;
        axislavew_awqos_in      : IN axi_awqos_t;
        axislavew_awsize_in     : IN axi_awsize_t;
        axislavew_bready_in     : IN axi_bready_t;
        
        axislave0_clock_in      : IN std_logic;
        axislave0_araddr_in     : IN axi_araddr_t;
        axislave0_arlen_in      : IN axi_arlen_t;
        axislave0_arvalid_in    : IN axi_arvalid_t;     
        axislave0_arid_in       : IN axi_arid_t;
        axislave0_arlock_in     : IN axi_arlock_t;
        axislave0_arcache_in    : IN axi_arcache_t;
        axislave0_arprot_in     : IN axi_arprot_t;
        axislave0_arqos_in      : IN axi_arqos_t;
        axislave0_rid_out       : OUT axi_rid_t;
        axislave0_rvalid_out    : OUT axi_rvalid_t;
        axislave0_rlast_out     : OUT axi_rlast_t;
        axislave0_rdata_out     : OUT axi_rdata64_t;
        axislave0_rresp_out     : OUT axi_rresp_t;
        axislave0_arready_out   : OUT axi_arready_t;
        axislave0_rready_in     : IN axi_rready_t;
        axislave0_arburst_in    : IN axi_arburst_t;
        axislave0_arsize_in     : IN axi_arsize_t;
        
        axislave0_awaddr_in     : IN axi_awaddr_t;
        axislave0_awlen_in      : IN axi_awlen_t;
        axislave0_awvalid_in    : IN axi_awvalid_t;
        axislave0_wvalid_in     : IN axi_wvalid_t;
        axislave0_wdata_in      : IN axi_wdata64_t;
        axislave0_wlast_in      : IN axi_wlast_t;
        axislave0_wstrb_in      : IN axi_wstrb8_t;
        axislave0_awready_out   : OUT axi_awready_t;
        axislave0_wready_out    : OUT axi_wready_t;
        axislave0_bresp_out     : OUT axi_bresp_t;
        axislave0_bid_out       : OUT axi_bid_t;
        axislave0_bvalid_out    : OUT axi_bvalid_t;
        axislave0_awburst_in    : IN axi_awburst_t;
        axislave0_awcache_in    : IN axi_awcache_t;
        axislave0_awid_in       : IN axi_awid_t;
        axislave0_awlock_in     : IN axi_awlock_t;
        axislave0_awprot_in     : IN axi_awprot_t;
        axislave0_awqos_in      : IN axi_awqos_t;
        axislave0_awsize_in     : IN axi_awsize_t;
        axislave0_bready_in     : IN axi_bready_t;

        axislave1_clock_in      : IN std_logic;
        axislave1_araddr_in     : IN axi_araddr_t;
        axislave1_arlen_in      : IN axi_arlen_t;
        axislave1_arvalid_in    : IN axi_arvalid_t;     
        axislave1_arid_in       : IN axi_arid_t;
        axislave1_arlock_in     : IN axi_arlock_t;
        axislave1_arcache_in    : IN axi_arcache_t;
        axislave1_arprot_in     : IN axi_arprot_t;
        axislave1_arqos_in      : IN axi_arqos_t;
        axislave1_rid_out       : OUT axi_rid_t;
        axislave1_rvalid_out    : OUT axi_rvalid_t;
        axislave1_rlast_out     : OUT axi_rlast_t;
        axislave1_rdata_out     : OUT axi_rdata_t;
        axislave1_rresp_out     : OUT axi_rresp_t;
        axislave1_arready_out   : OUT axi_arready_t;
        axislave1_rready_in     : IN axi_rready_t;
        axislave1_arburst_in    : IN axi_arburst_t;
        axislave1_arsize_in     : IN axi_arsize_t;

        axislave1_awaddr_in     : IN axi_awaddr_t;
        axislave1_awlen_in      : IN axi_awlen_t;
        axislave1_awvalid_in    : IN axi_awvalid_t;
        axislave1_wvalid_in     : IN axi_wvalid_t;
        axislave1_wdata_in      : IN axi_wdata_t;
        axislave1_wlast_in      : IN axi_wlast_t;
        axislave1_wstrb_in      : IN axi_wstrb_t;
        axislave1_awready_out   : OUT axi_awready_t;
        axislave1_wready_out    : OUT axi_wready_t;
        axislave1_bresp_out     : OUT axi_bresp_t;
        axislave1_bid_out       : OUT axi_bid_t;
        axislave1_bvalid_out    : OUT axi_bvalid_t;
        axislave1_awburst_in    : IN axi_awburst_t;
        axislave1_awcache_in    : IN axi_awcache_t;
        axislave1_awid_in       : IN axi_awid_t;
        axislave1_awlock_in     : IN axi_awlock_t;
        axislave1_awprot_in     : IN axi_awprot_t;
        axislave1_awqos_in      : IN axi_awqos_t;
        axislave1_awsize_in     : IN axi_awsize_t;
        axislave1_bready_in     : IN axi_bready_t;
        
        axislave2_clock_in      : IN std_logic;
        axislave2_araddr_in     : IN axi_araddr_t;
        axislave2_arlen_in      : IN axi_arlen_t;
        axislave2_arvalid_in    : IN axi_arvalid_t;     
        axislave2_arid_in       : IN axi_arid_t;
        axislave2_arlock_in     : IN axi_arlock_t;
        axislave2_arcache_in    : IN axi_arcache_t;
        axislave2_arprot_in     : IN axi_arprot_t;
        axislave2_arqos_in      : IN axi_arqos_t;
        axislave2_rid_out       : OUT axi_rid_t;
        axislave2_rvalid_out    : OUT axi_rvalid_t;
        axislave2_rlast_out     : OUT axi_rlast_t;
        axislave2_rdata_out     : OUT axi_rdata_t;
        axislave2_rresp_out     : OUT axi_rresp_t;
        axislave2_arready_out   : OUT axi_arready_t;
        axislave2_rready_in     : IN axi_rready_t;
        axislave2_arburst_in    : IN axi_arburst_t;
        axislave2_arsize_in     : IN axi_arsize_t;

        axislave2_awaddr_in         : IN axi_awaddr_t;
        axislave2_awlen_in          : IN axi_awlen_t;
        axislave2_awvalid_in        : IN axi_awvalid_t;
        axislave2_wvalid_in         : IN axi_wvalid_t;
        axislave2_wdata_in          : IN axi_wdata_t;
        axislave2_wlast_in          : IN axi_wlast_t;
        axislave2_wstrb_in          : IN axi_wstrb_t;
        axislave2_awready_out       : OUT axi_awready_t;
        axislave2_wready_out        : OUT axi_wready_t;
        axislave2_bresp_out         : OUT axi_bresp_t;
        axislave2_bid_out           : OUT axi_bid_t;
        axislave2_bvalid_out        : OUT axi_bvalid_t;
        axislave2_awburst_in        : IN axi_awburst_t;
        axislave2_awcache_in        : IN axi_awcache_t;
        axislave2_awid_in           : IN axi_awid_t;
        axislave2_awlock_in         : IN axi_awlock_t;
        axislave2_awprot_in         : IN axi_awprot_t;
        axislave2_awqos_in          : IN axi_awqos_t;
        axislave2_awsize_in         : IN axi_awsize_t;
        axislave2_bready_in         : IN axi_bready_t;
                        
        aximaster_araddr_out    : OUT axi_araddr_t;
        aximaster_arlen_out     : OUT axi_arlen_t;
        aximaster_arvalid_out   : OUT axi_arvalid_t;
        aximaster_arid_out      : OUT axi_arid_t;
        aximaster_arlock_out    : OUT axi_arlock_t;
        aximaster_arcache_out   : OUT axi_arcache_t;
        aximaster_arprot_out    : OUT axi_arprot_t;
        aximaster_arqos_out     : OUT axi_arqos_t;
        aximaster_rid_in        : IN axi_rid_t;              
        aximaster_rvalid_in     : IN axi_rvalid_t;
        aximaster_rlast_in      : IN axi_rlast_t;
        aximaster_rdata_in      : IN axi_rdata64_t;
        aximaster_rdata_mask_out: OUT std_logic_vector(1 downto 0);
        aximaster_rresp_in      : IN axi_rresp_t;
        aximaster_arready_in    : IN axi_arready_t;
        aximaster_rready_out    : OUT axi_rready_t;
        aximaster_arburst_out   : OUT axi_arburst_t;
        aximaster_arsize_out    : OUT axi_arsize_t;
        
        aximaster_awaddr_out    : OUT axi_awaddr_t;
        aximaster_awlen_out     : OUT axi_awlen_t;
        aximaster_awvalid_out   : OUT axi_awvalid_t;
        aximaster_wvalid_out    : OUT axi_wvalid_t;
        aximaster_wdata_out     : OUT axi_wdata64_t;
        aximaster_wdata_mask_out: OUT std_logic_vector(1 downto 0);
        aximaster_wlast_out     : OUT axi_wlast_t;
        aximaster_wstrb_out     : OUT axi_wstrb8_t;
        aximaster_awready_in    : IN axi_awready_t;
        aximaster_wready_in     : IN axi_wready_t;
        aximaster_bresp_in      : IN axi_bresp_t;
        aximaster_bid_in        : IN axi_bid_t;
        aximaster_bvalid_in     : IN axi_bvalid_t;
        aximaster_awburst_out   : OUT axi_awburst_t;
        aximaster_awcache_out   : OUT axi_awcache_t;
        aximaster_awid_out      : OUT axi_awid_t;
        aximaster_awlock_out    : OUT axi_awlock_t;
        aximaster_awprot_out    : OUT axi_awprot_t;
        aximaster_awqos_out     : OUT axi_awqos_t;
        aximaster_awsize_out    : OUT axi_awsize_t;
        aximaster_bready_out    : OUT axi_bready_t
	);
end component;

COMPONENT axi_convert_64to32 is
   port 
   (
   clock_in          :IN STD_LOGIC;
   reset_in          :IN STD_LOGIC;

   -- Input bus in 64-bit
   
   SDRAM64_araddr    :IN STD_LOGIC_VECTOR(31 downto 0);
   SDRAM64_arburst   :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_arlen     :IN STD_LOGIC_VECTOR(7 downto 0);
   SDRAM64_arready   :OUT STD_LOGIC;
   SDRAM64_arsize    :IN STD_LOGIC_VECTOR(2 downto 0);
   SDRAM64_arvalid   :IN STD_LOGIC;
   SDRAM64_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
   SDRAM64_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
   SDRAM64_awready   :OUT STD_LOGIC;
   SDRAM64_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
   SDRAM64_awvalid   :IN STD_LOGIC;
   SDRAM64_bready    :IN STD_LOGIC;
   SDRAM64_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_bvalid    :OUT STD_LOGIC;
   SDRAM64_rdata     :OUT STD_LOGIC_VECTOR(63 downto 0);
   SDRAM64_rdata_mask:IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_rlast     :OUT STD_LOGIC;
   SDRAM64_rready    :IN STD_LOGIC;
   SDRAM64_rresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_rvalid    :OUT STD_LOGIC;
   SDRAM64_wdata     :IN STD_LOGIC_VECTOR(63 downto 0);
   SDRAM64_wdata_mask:IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM64_wlast     :IN STD_LOGIC;
   SDRAM64_wready    :OUT STD_LOGIC;
   SDRAM64_wstrb     :IN STD_LOGIC_VECTOR(7 downto 0);
   SDRAM64_wvalid    :IN STD_LOGIC;

   -- Output bus in 32-bit

   SDRAM32_araddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_arburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_arlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
   SDRAM32_arready   :IN STD_LOGIC;
   SDRAM32_arsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
   SDRAM32_arvalid   :OUT STD_LOGIC;
   SDRAM32_awaddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_awburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_awlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
   SDRAM32_awready   :IN STD_LOGIC;
   SDRAM32_awsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
   SDRAM32_awvalid   :OUT STD_LOGIC;
   SDRAM32_bready    :OUT STD_LOGIC;
   SDRAM32_bresp     :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_bvalid    :IN STD_LOGIC;
   SDRAM32_rdata     :IN STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_rlast     :IN STD_LOGIC;
   SDRAM32_rready    :OUT STD_LOGIC;
   SDRAM32_rresp     :IN STD_LOGIC_VECTOR(1 downto 0);
   SDRAM32_rvalid    :IN STD_LOGIC;
   SDRAM32_wdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
   SDRAM32_wlast     :OUT STD_LOGIC;
   SDRAM32_wready    :IN STD_LOGIC;
   SDRAM32_wstrb     :OUT STD_LOGIC_VECTOR(3 downto 0);
   SDRAM32_wvalid    :OUT STD_LOGIC
   );
end COMPONENT;

COMPONENT core IS
    PORT(SIGNAL clock_in                : IN STD_LOGIC;
        SIGNAL clock_x2_in              : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;
        -- DP interface
        SIGNAL dp_rd_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_fork_in            : IN dp_fork_t;  
        SIGNAL dp_rd_addr_mode_in       : IN STD_LOGIC;
        SIGNAL dp_wr_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_fork_in            : IN dp_fork_t;  
        SIGNAL dp_wr_addr_mode_in       : IN STD_LOGIC;
        SIGNAL dp_wr_mcast_in           : IN mcast_t;            
        SIGNAL dp_write_in              : IN STD_LOGIC;
        SIGNAL dp_write_data_flow_in    : IN data_flow_t;
        SIGNAL dp_write_data_type_in    : IN dp_data_type_t;
        SIGNAL dp_write_data_model_in   : IN dp_data_model_t;
        SIGNAL dp_write_vector_in       : IN dp_vector_t;
        SIGNAL dp_write_stream_in       : IN std_logic;
        SIGNAL dp_write_stream_id_in    : IN stream_id_t;
        SIGNAL dp_write_scatter_in      : IN scatter_t;
        SIGNAL dp_write_wait_out        : OUT STD_LOGIC;
        SIGNAL dp_write_gen_valid_in    : IN STD_LOGIC;
        SIGNAL dp_read_in               : IN STD_LOGIC;
        SIGNAL dp_read_data_flow_in     : IN data_flow_t;
        SIGNAL dp_read_stream_in        : IN STD_LOGIC;
        SIGNAL dp_read_stream_id_in     : IN stream_id_t;
        SIGNAL dp_read_data_type_in     : IN dp_data_type_t;
        SIGNAL dp_read_data_model_in    : IN dp_data_model_t;
        SIGNAL dp_read_vector_in        : IN dp_vector_t;
        SIGNAL dp_read_scatter_in       : IN scatter_t;
        SIGNAL dp_read_gen_valid_in     : IN STD_LOGIC;
        SIGNAL dp_read_wait_out         : OUT STD_LOGIC;
        SIGNAL dp_writedata_in          : IN std_logic_vector(fork_max_c*ddr_data_width_c-1 downto 0);
        SIGNAL dp_readdatavalid_out     : OUT STD_LOGIC;
        SIGNAL dp_read_gen_valid_out    : OUT STD_LOGIC;
        SIGNAL dp_readdata_out          : OUT std_logic_vector(fork_max_c*ddr_data_width_c-1 downto 0);
        SIGNAL dp_readdata_vm_out       : OUT STD_LOGIC;
        -- Task control
        SIGNAL task_start_addr_in       : IN instruction_addr_t;
        SIGNAL task_in                  : IN STD_LOGIC;
        SIGNAL task_vm_in               : IN STD_LOGIC;
        SIGNAL task_pcore_in            : IN pcore_t;
        SIGNAL task_lockstep_in         : IN STD_LOGIC;
        SIGNAL task_tid_mask_in         : IN tid_mask_t;
        SIGNAL task_iregister_auto_in   : IN iregister_auto_t;
        SIGNAL task_data_model_in       : IN dp_data_model_t;

        SIGNAL busy_out                 : OUT STD_LOGIC_VECTOR(1 downto 0);
        SIGNAL ready_out                : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT stream IS
   PORT(SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        SIGNAL stream_id_in         : IN stream_id_t;
        SIGNAL input_in             : IN STD_LOGIC_VECTOR(register_width_c-1 downto 0);
        SIGNAL output_out           : OUT STD_LOGIC_VECTOR(register_width_c-1 downto 0);
        -- Host configuration
        SIGNAL config_in            : IN STD_LOGIC;
        SIGNAL config_reg_in        : IN std_logic_vector(stream_lookup_depth_c-1 downto 0);
        SIGNAL config_data_in       : IN std_logic_vector(2*register_width_c-1 downto 0)
    );
END COMPONENT;

COMPONENT dp IS
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
        SIGNAL clock_in                        : IN STD_LOGIC;
        SIGNAL clock_x2_in                     : IN STD_LOGIC;
        SIGNAL reset_in                        : IN STD_LOGIC;        
        SIGNAL bus_waddr_in                    : IN register_addr_t;
        SIGNAL bus_raddr_in                    : IN register_addr_t;
        SIGNAL bus_write_in                    : IN STD_LOGIC;
        SIGNAL bus_read_in                     : IN STD_LOGIC;
        SIGNAL bus_writedata_in                : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdata_out                : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdatavalid_out           : OUT STD_LOGIC;
        SIGNAL bus_writewait_out               : OUT STD_LOGIC;
        SIGNAL bus_readwait_out                : OUT STD_LOGIC;
        
        -- Bus interface for read master
        SIGNAL readmaster1_addr_out            : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL readmaster1_fork_out            : OUT dp_fork_t;
        SIGNAL readmaster1_addr_mode_out       : OUT STD_LOGIC;
        SIGNAL readmaster1_cs_out              : OUT STD_LOGIC;
        SIGNAL readmaster1_read_out            : OUT STD_LOGIC;
        SIGNAL readmaster1_read_vm_out         : OUT STD_LOGIC;
        SIGNAL readmaster1_read_data_flow_out  : OUT data_flow_t;
        SIGNAL readmaster1_read_stream_out     : OUT STD_LOGIC;
        SIGNAL readmaster1_read_stream_id_out  : OUT stream_id_t;
        SIGNAL readmaster1_read_vector_out     : OUT dp_vector_t;
        SIGNAL readmaster1_read_scatter_out    : OUT scatter_t;
        SIGNAL readmaster1_readdatavalid_in    : IN STD_LOGIC;
        SIGNAL readmaster1_readdatavalid_vm_in : IN STD_LOGIC;
        SIGNAL readmaster1_readdata_in         : IN STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL readmaster1_wait_request_in     : IN STD_LOGIC;
        SIGNAL readmaster1_burstlen_out        : OUT burstlen_t;
        SIGNAL readmaster1_bus_id_out          : OUT dp_bus_id_t;
        SIGNAL readmaster1_data_type_out       : OUT dp_data_type_t;
        SIGNAL readmaster1_data_model_out      : OUT dp_data_model_t;

        -- Bus interface for write master
        SIGNAL writemaster1_addr_out           : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL writemaster1_fork_out           : OUT dp_fork_t;
        SIGNAL writemaster1_addr_mode_out      : OUT STD_LOGIC;
        SIGNAL writemaster1_vm_out             : OUT STD_LOGIC;
        SIGNAL writemaster1_mcast_out          : OUT mcast_t;
        SIGNAL writemaster1_cs_out             : OUT STD_LOGIC;
        SIGNAL writemaster1_write_out          : OUT STD_LOGIC;
        SIGNAL writemaster1_write_data_flow_out: OUT data_flow_t;
        SIGNAL writemaster1_write_vector_out   : OUT dp_vector_t;
        SIGNAL writemaster1_write_stream_out   : OUT STD_LOGIC;
        SIGNAL writemaster1_write_stream_id_out:OUT stream_id_t;
        SIGNAL writemaster1_write_scatter_out  : OUT scatter_t;
        SIGNAL writemaster1_writedata_out      : OUT STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL writemaster1_wait_request_in    : IN STD_LOGIC;
        SIGNAL writemaster1_burstlen_out       : OUT burstlen_t;
        SIGNAL writemaster1_bus_id_out         : OUT dp_bus_id_t;
        SIGNAL writemaster1_data_type_out      : OUT dp_data_type_t;
        SIGNAL writemaster1_data_model_out     : OUT dp_data_model_t;
        SIGNAL writemaster1_thread_out         : OUT dp_thread_t;
        SIGNAL writemaster1_counter_in         : IN dp_counters_t(1 DOWNTO 0);            

        -- Bus interface for read master SRAM

        SIGNAL readmaster2_addr_out            : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
        SIGNAL readmaster2_fork_out            : OUT std_logic_vector(fork_sram_c-1 downto 0);
        SIGNAL readmaster2_cs_out              : OUT STD_LOGIC;
        SIGNAL readmaster2_read_out            : OUT STD_LOGIC;
        SIGNAL readmaster2_read_vm_out         : OUT STD_LOGIC;
        SIGNAL readmaster2_read_vector_out     : OUT dp_vector_t;
        SIGNAL readmaster2_read_scatter_out    : OUT scatter_t;
        SIGNAL readmaster2_readdatavalid_in    : IN STD_LOGIC;
        SIGNAL readmaster2_readdatavalid_vm_in : IN STD_LOGIC;
        SIGNAL readmaster2_readdata_in         : IN STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL readmaster2_wait_request_in     : IN STD_LOGIC;
        SIGNAL readmaster2_burstlen_out        : OUT burstlen_t;
        SIGNAL readmaster2_bus_id_out          : OUT dp_bus_id_t;

        -- Bus interface for write master SRAM
        SIGNAL writemaster2_addr_out           : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
        SIGNAL writemaster2_fork_out           : OUT std_logic_vector(fork_sram_c-1 downto 0);
        SIGNAL writemaster2_cs_out             : OUT STD_LOGIC;
        SIGNAL writemaster2_write_out          : OUT STD_LOGIC;
        SIGNAL writemaster2_vm_out             : OUT STD_LOGIC;
        SIGNAL writemaster2_write_vector_out   : OUT dp_vector_t;
        SIGNAL writemaster2_write_scatter_out  : OUT scatter_t;
        SIGNAL writemaster2_writedata_out      : OUT STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL writemaster2_wait_request_in    : IN STD_LOGIC;
        SIGNAL writemaster2_burstlen_out       : OUT burstlen_t;
        SIGNAL writemaster2_bus_id_out         : OUT dp_bus_id_t;
        SIGNAL writemaster2_thread_out         : OUT dp_thread_t;
        SIGNAL writemaster2_counter_in         : IN dp_counters_t(1 downto 0);            

        -- Bus interface for read master DDR

        SIGNAL readmaster3_addr_out            : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
        SIGNAL readmaster3_cs_out              : OUT STD_LOGIC;
        SIGNAL readmaster3_read_out            : OUT STD_LOGIC;
        SIGNAL readmaster3_read_vm_out         : OUT STD_LOGIC;
        SIGNAL readmaster3_read_vector_out     : OUT dp_vector_t;
        SIGNAL readmaster3_read_scatter_out    : OUT scatter_t;
        SIGNAL readmaster3_read_start_out      : OUT unsigned(ddr_vector_depth_c downto 0);
        SIGNAL readmaster3_read_end_out        : OUT vectors_t(fork_ddr_c-1 downto 0);
        SIGNAL readmaster3_readdatavalid_in    : IN STD_LOGIC;
        SIGNAL readmaster3_readdatavalid_vm_in : IN STD_LOGIC;
        SIGNAL readmaster3_readdata_in         : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL readmaster3_wait_request_in     : IN STD_LOGIC;
        SIGNAL readmaster3_burstlen_out        : OUT burstlen_t;
        SIGNAL readmaster3_bus_id_out          : OUT dp_bus_id_t;
        SIGNAL readmaster3_filler_data_out     : OUT STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

        -- Bus interface for write master DDR

        SIGNAL writemaster3_addr_out           : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
        SIGNAL writemaster3_cs_out             : OUT STD_LOGIC;
        SIGNAL writemaster3_write_out          : OUT STD_LOGIC;
        SIGNAL writemaster3_vm_out             : OUT STD_LOGIC;
        SIGNAL writemaster3_write_vector_out   : OUT dp_vector_t;
        SIGNAL writemaster3_write_scatter_out  : OUT scatter_t;
        SIGNAL writemaster3_write_end_out      : OUT vectors_t(fork_ddr_c-1 downto 0);
        SIGNAL writemaster3_writedata_out      : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL writemaster3_wait_request_in    : IN STD_LOGIC;
        SIGNAL writemaster3_burstlen_out       : OUT burstlen_t;
        SIGNAL writemaster3_burstlen2_out      : OUT burstlen2_t;
        SIGNAL writemaster3_burstlen3_out      : OUT burstlen_t;
        SIGNAL writemaster3_bus_id_out         : OUT dp_bus_id_t;
        SIGNAL writemaster3_thread_out         : OUT dp_thread_t;
        SIGNAL writemaster3_counter_in         : IN dp_counter_t;            

        -- Task control
        
        SIGNAL task_start_addr_out             : OUT instruction_addr_t;
        SIGNAL task_out                        : OUT STD_LOGIC;
        SIGNAL task_pending_out                : OUT STD_LOGIC;
        SIGNAL task_vm_out                     : OUT STD_LOGIC;
        SIGNAL task_pcore_out                  : OUT pcore_t;
        SIGNAL task_lockstep_out               : OUT STD_LOGIC;
        SIGNAL task_tid_mask_out               : OUT tid_mask_t;
        SIGNAL task_iregister_auto_out         : OUT iregister_auto_t;
        SIGNAL task_data_model_out             : OUT dp_data_model_t;

        SIGNAL task_busy_in                    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL task_ready_in                   : IN STD_LOGIC;

        -- BAR info
        SIGNAL bar_in                          : IN dp_addrs_t(dp_bus_id_max_c-1 downto 0);

        -- Indication
        SIGNAL indication_avail_out            : OUT STD_LOGIC;
        
        SIGNAL ddr_tx_busy_in                  : IN STD_LOGIC
    );
END COMPONENT;
    

COMPONENT dp_fifo IS
    port(
            SIGNAL clock_in                 : IN STD_LOGIC;
            SIGNAL reset_in                 : IN STD_LOGIC;     

            SIGNAL writedata_in             : IN STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
            SIGNAL wreq_in                  : IN STD_LOGIC;

            SIGNAL readdata1_out            : OUT STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
            SIGNAL readdata2_out            : OUT STD_LOGIC_VECTOR(dp_instruction_width_c-1 downto 0);
            SIGNAL rdreq1_in                : IN STD_LOGIC;
            SIGNAL rdreq2_in                : IN STD_LOGIC;
            SIGNAL valid1_out               : OUT STD_LOGIC;
            SIGNAL valid2_out               : OUT STD_LOGIC;

            SIGNAL full_out                 : OUT STD_LOGIC;
            SIGNAL fifo_avail_out           : OUT std_logic_vector(dp_fifo_depth_c-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT dp_fetch IS
    generic (
            DP_THREAD_ID:integer;
            NUM_DP_SRC_PORT:integer;
            NUM_DP_DST_PORT:integer
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
END COMPONENT;

COMPONENT dp_gen_core IS
    port(
       SIGNAL clock_in:in std_logic;
       SIGNAL reset_in:in std_logic;
       
       -- signal to communicate with dp_fetch
       
       SIGNAL ready_out:out STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
       SIGNAL instruction_valid_in:in STD_LOGIC_VECTOR(dp_max_gen_c-1 downto 0);
       SIGNAL instruction_in:in dp_instruction_t;
       SIGNAL pre_instruction_in:in dp_instruction_t;
       SIGNAL wr_maxburstlen_in:in burstlens_t(NUM_DP_DST_PORT-1 downto 0);
       SIGNAL full_in:in STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
       SIGNAL waitreq_in:in STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
       SIGNAL bar_in:in dp_addrs_t(dp_bus_id_max_c-1 downto 0);

       SIGNAL log1_out:out STD_LOGIC_VECTOR(host_width_c-1 downto 0);
       SIGNAL log1_valid_out:out STD_LOGIC;

       SIGNAL log2_out:out STD_LOGIC_VECTOR(host_width_c-1 downto 0);
       SIGNAL log2_valid_out:out STD_LOGIC;

       -- commands to send to dp_source for pcore memory space

       SIGNAL gen_pcore_src_valid_out:out std_logic;
       SIGNAL gen_pcore_vm_out:out std_logic;
       SIGNAL gen_pcore_fork_out:out std_logic_vector(fork_max_c-1 downto 0);
       SIGNAL gen_pcore_data_flow_out:out data_flow_t;
       SIGNAL gen_pcore_src_stream_out:out STD_LOGIC;
       SIGNAL gen_pcore_dest_stream_out:out STD_LOGIC;
       SIGNAL gen_pcore_stream_id_out:out stream_id_t;
       SIGNAL gen_pcore_src_vector_out:out dp_vector_t;
       SIGNAL gen_pcore_dst_vector_out:out dp_vector_t;
       SIGNAL gen_pcore_src_scatter_out:out scatter_t;
       SIGNAL gen_pcore_dst_scatter_out:out scatter_t;
       SIGNAL gen_pcore_src_start_out:out unsigned(ddr_vector_depth_c downto 0);
       SIGNAL gen_pcore_src_end_out:out vector_fork_t;
       SIGNAL gen_pcore_dst_end_out:out vector_fork_t;
       SIGNAL gen_pcore_src_addr_out: out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_pcore_src_addr_mode_out:out STD_LOGIC;
       SIGNAL gen_pcore_dst_addr_out: out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_pcore_dst_addr_mode_out:out STD_LOGIC;
       SIGNAL gen_pcore_src_eof_out: out STD_LOGIC;
       SIGNAL gen_pcore_bus_id_source_out: out dp_bus_id_t;
       SIGNAL gen_pcore_data_type_source_out: out dp_data_type_t;
       SIGNAL gen_pcore_data_model_source_out: out dp_data_model_t;
       SIGNAL gen_pcore_bus_id_dest_out: out dp_bus_id_t;
       SIGNAL gen_pcore_busy_dest_out: out std_logic;
       SIGNAL gen_pcore_data_type_dest_out: out dp_data_type_t;
       SIGNAL gen_pcore_data_model_dest_out: out dp_data_model_t;
       SIGNAL gen_pcore_src_burstlen_out: out burstlen_t;
       SIGNAL gen_pcore_dst_burstlen_out: out burstlen_t;
       SIGNAL gen_pcore_thread_out: out dp_thread_t;
       SIGNAL gen_pcore_mcast_out: out mcast_t;
       SIGNAL gen_pcore_data_out:out STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);


       -- commands to send to dp_source for sram memory space

       SIGNAL gen_sram_src_valid_out:out STD_LOGIC;
       SIGNAL gen_sram_vm_out:out std_logic;
       SIGNAL gen_sram_fork_out:out std_logic_vector(fork_max_c-1 downto 0);
       SIGNAL gen_sram_data_flow_out:out data_flow_t;
       SIGNAL gen_sram_src_stream_out:out STD_LOGIC;
       SIGNAL gen_sram_dest_stream_out:out STD_LOGIC;
       SIGNAL gen_sram_stream_id_out:out stream_id_t;
       SIGNAL gen_sram_src_vector_out:out dp_vector_t;
       SIGNAL gen_sram_dst_vector_out:out dp_vector_t;
       SIGNAL gen_sram_src_scatter_out:out scatter_t;
       SIGNAL gen_sram_dst_scatter_out:out scatter_t;
       SIGNAL gen_sram_src_start_out:out unsigned(ddr_vector_depth_c downto 0);
       SIGNAL gen_sram_src_end_out:out vector_fork_t;
       SIGNAL gen_sram_dst_end_out:out vector_fork_t;
       SIGNAL gen_sram_src_addr_out:out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_sram_src_addr_mode_out:out STD_LOGIC;
       SIGNAL gen_sram_dst_addr_out:out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_sram_dst_addr_mode_out:out STD_LOGIC;
       SIGNAL gen_sram_src_eof_out:out STD_LOGIC;
       SIGNAL gen_sram_bus_id_source_out:out dp_bus_id_t;
       SIGNAL gen_sram_data_type_source_out:out dp_data_type_t;
       SIGNAL gen_sram_data_model_source_out:out dp_data_model_t;
       SIGNAL gen_sram_bus_id_dest_out:out dp_bus_id_t;
       SIGNAL gen_sram_busy_dest_out:out std_logic;
       SIGNAL gen_sram_data_type_dest_out:out dp_data_type_t;
       SIGNAL gen_sram_data_model_dest_out:out dp_data_model_t;
       SIGNAL gen_sram_src_burstlen_out:out burstlen_t;
       SIGNAL gen_sram_dst_burstlen_out:out burstlen_t;
       SIGNAL gen_sram_thread_out:out dp_thread_t;
       SIGNAL gen_sram_mcast_out:out mcast_t;
       SIGNAL gen_sram_data_out:out STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);

       -- commands to send to dp_source for ddr memory space

       SIGNAL gen_ddr_src_valid_out:out STD_LOGIC;
       SIGNAL gen_ddr_vm_out:out std_logic;
       SIGNAL gen_ddr_fork_out:out std_logic_vector(fork_max_c-1 downto 0);
       SIGNAL gen_ddr_data_flow_out:out data_flow_t;
       SIGNAL gen_ddr_src_stream_out:out STD_LOGIC;
       SIGNAL gen_ddr_dest_stream_out:out STD_LOGIC;
       SIGNAL gen_ddr_stream_id_out:out stream_id_t;
       SIGNAL gen_ddr_src_vector_out:out dp_vector_t;
       SIGNAL gen_ddr_dst_vector_out:out dp_vector_t;
       SIGNAL gen_ddr_src_scatter_out:out scatter_t;
       SIGNAL gen_ddr_dst_scatter_out:out scatter_t;
       SIGNAL gen_ddr_src_start_out:out unsigned(ddr_vector_depth_c downto 0);
       SIGNAL gen_ddr_src_end_out:out vector_fork_t;
       SIGNAL gen_ddr_dst_end_out:out vector_fork_t;
       SIGNAL gen_ddr_src_addr_out:out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_ddr_src_addr_mode_out:out STD_LOGIC;
       SIGNAL gen_ddr_dst_addr_out:out dp_full_addrs_t(fork_max_c-1 downto 0);
       SIGNAL gen_ddr_dst_addr_mode_out:out STD_LOGIC;
       SIGNAL gen_ddr_src_eof_out:out STD_LOGIC;
       SIGNAL gen_ddr_bus_id_source_out:out dp_bus_id_t;
       SIGNAL gen_ddr_data_type_source_out:out dp_data_type_t;
       SIGNAL gen_ddr_data_model_source_out:out dp_data_model_t;
       SIGNAL gen_ddr_bus_id_dest_out:out dp_bus_id_t;
       SIGNAL gen_ddr_busy_dest_out:out std_logic;
       SIGNAL gen_ddr_data_type_dest_out:out dp_data_type_t;
       SIGNAL gen_ddr_data_model_dest_out:out dp_data_model_t;
       SIGNAL gen_ddr_src_burstlen_out:out burstlen_t;
       SIGNAL gen_ddr_dst_burstlen_out:out burstlen_t;
       SIGNAL gen_ddr_thread_out:out dp_thread_t;
       SIGNAL gen_ddr_mcast_out:out mcast_t;
       SIGNAL gen_ddr_data_out:out STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0)
    );
END COMPONENT;

COMPONENT dp_gen IS
    generic (
        NUM_DP_DST_PORT     :integer;
        SOURCE_BURST_MODE   :STD_LOGIC;
        DEST_BURST_MODE     :STD_LOGIC;
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
        SIGNAL instruction_vm_in                : IN STD_LOGIC;
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
        SIGNAL instruction_mcast_in             : IN mcast_t;
        SIGNAL instruction_gen_len_in           : IN unsigned(dp_addr_width_c-1 downto 0);
        SIGNAL instruction_thread_in            : IN dp_thread_t;
        SIGNAL instruction_data_in              : IN STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);
        SIGNAL instruction_repeat_in            : IN STD_LOGIC;

        -- Input for sink node
        SIGNAL wr_maxburstlen_in                : IN burstlens_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_full_in                       : IN STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
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
        SIGNAL gen_src_start_out                : OUT unsigned(ddr_vector_depth_c+1-1 downto 0);
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
END COMPONENT;

COMPONENT dp_gen_gen IS
    generic (
        NUM_DP_DST_PORT :integer;
        BURST_MODE      :STD_LOGIC;
        DIRECTION       :STRING
    );
    port(
        SIGNAL clock_in                     : IN STD_LOGIC;
        SIGNAL reset_in                     : IN STD_LOGIC;            
        -- Output to other stages
        SIGNAL ready_out                    : OUT STD_LOGIC;
        -- Input from fetch stage
        SIGNAL instruction_valid_in         : IN STD_LOGIC;
        SIGNAL instruction_in               : IN dp_template_t;
        SIGNAL instruction_bus_id_dest_in   : IN dp_bus_id_t;
        SIGNAL instruction_data_type_dest_in: IN dp_data_type_t;
        SIGNAL instruction_gen_len_in       : IN unsigned(dp_addr_width_c-1 downto 0);
        SIGNAL instruction_mcast_in         : IN mcast_t;
        SIGNAL instruction_thread_in        : IN dp_thread_t;
        SIGNAL instruction_data_in          : IN STD_LOGIC_VECTOR(data_width_c-1 downto 0);
        -- Input for sink node
        SIGNAL wr_full_in                   : IN STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
        -- Input from next stage
        SIGNAL waitreq_in                   : IN STD_LOGIC;
        -- Output to next stage
        SIGNAL gen_valid_out                : OUT STD_LOGIC;
        SIGNAL gen_data_out                 : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
        SIGNAL gen_bus_id_dest_out          : OUT dp_bus_id_t;
        SIGNAL gen_data_type_dest_out       : OUT dp_data_type_t;
        SIGNAL gen_thread_out               : OUT dp_thread_t;

        SIGNAL gen_mcast_out                : OUT mcast_t
        );
END COMPONENT;

COMPONENT dp_gen_source IS
    generic(
        NUM_DP_DST_PORT :integer;
        LATENCY         :integer
    );
    port(
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        -- Signal from DP generator
        
        SIGNAL gen_waitreq_out      : OUT STD_LOGIC;
        SIGNAL gen_valid_in         : IN STD_LOGIC;
        SIGNAL gen_src_data_in      : IN STD_LOGIC_VECTOR(data_width_c-1 downto 0);
        SIGNAL gen_dst_addr_in      : IN unsigned(dp_addr_width_c-1 downto 0);
        SIGNAL gen_bus_id_dest_in   : IN dp_bus_id_t;
        SIGNAL gen_data_type_dest_in: IN dp_data_type_t;
        SIGNAL gen_dst_burstlen_in  : IN burstlen_t;
        SIGNAL gen_thread_in        : IN dp_thread_t;
        SIGNAL gen_mcast_in         : IN mcast_t;

        -- Signal to send received data to transmit node

        SIGNAL wr_req_out           : OUT STD_LOGIC_VECTOR(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_addr_out          : OUT dp_addrs_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_data_out          : OUT dp_datas_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_burstlen_out      : OUT burstlens_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_bus_id_out        : OUT dp_bus_ids_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_thread_out        : OUT dp_threads_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_data_type_out     : OUT dp_data_types_t(NUM_DP_DST_PORT-1 downto 0);
        SIGNAL wr_mcast_out         : OUT mcasts_t(NUM_DP_DST_PORT-1 downto 0)
        );
END COMPONENT;

COMPONENT dp_source IS
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
        SIGNAL gen_busy_dest_in         : IN std_logic;
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
        SIGNAL wr_src_vm_out            : OUT STD_LOGIC;
        SIGNAL wr_addr_mode_out         : OUT STD_LOGIC;
        SIGNAL wr_datavalid_out         : OUT STD_LOGIC;
        SIGNAL wr_data_out              : OUT dp_data_t;
        SIGNAL wr_readdatavalid_out     : OUT STD_LOGIC;
        SIGNAL wr_readdatavalid_vm_out  : OUT STD_LOGIC;
        SIGNAL wr_readdata_out          : OUT dp_datas_t(fork_max_c-1 downto 0);
        SIGNAL wr_burstlen_out          : OUT burstlen_t;
        SIGNAL wr_bus_id_out            : OUT dp_bus_id_t;
        SIGNAL wr_thread_out            : OUT dp_thread_t;
        SIGNAL wr_data_type_out         : OUT dp_data_type_t;
        SIGNAL wr_data_model_out        : OUT dp_data_model_t;
        SIGNAL wr_mcast_out             : OUT mcast_t
        );
END COMPONENT;

COMPONENT dp_sink IS
    GENERIC(
        NUM_DP_SRC_PORT :integer;
        BURST_MODE      :STD_LOGIC;
        BUS_WIDTH       :integer;
        FORK            : integer;
        FIFO_DEPTH      : integer
        );
    PORT(   
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;
        SIGNAL bus_addr_out             : OUT dp_full_addrs_t(FORK-1 downto 0);
        SIGNAL bus_fork_out             : OUT STD_LOGIC_VECTOR(FORK-1 downto 0);
        SIGNAL bus_addr_mode_out        : OUT STD_LOGIC;
        SIGNAL bus_vm_out               : OUT STD_LOGIC;
        SIGNAL bus_data_flow_out        : OUT data_flow_t;
        SIGNAL bus_vector_out           : OUT dp_vector_t;
        SIGNAL bus_stream_out           : OUT std_logic;
        SIGNAL bus_stream_id_out        : OUT stream_id_t;
        SIGNAL bus_scatter_out          : OUT scatter_t;
        SIGNAL bus_end_out              : OUT vectors_t(FORK-1 downto 0);
        SIGNAL bus_mcast_out            : OUT mcast_t;
        SIGNAL bus_cs_out               : OUT STD_LOGIC;
        SIGNAL bus_write_out            : OUT STD_LOGIC;
        SIGNAL bus_writedata_out        : OUT STD_LOGIC_VECTOR(ddr_data_width_c*FORK-1 DOWNTO 0);
        SIGNAL bus_wait_request_in      : IN STD_LOGIC;
        SIGNAL bus_burstlen_out         : OUT burstlen_t;
        SIGNAL bus_burstlen2_out        : OUT burstlen2_t;
        SIGNAL bus_burstlen3_out        : OUT burstlen_t;
        SIGNAL bus_id_out               : OUT dp_bus_id_t;
        SIGNAL bus_data_type_out        : OUT dp_data_type_t;
        SIGNAL bus_data_model_out       : OUT dp_data_model_t;
        SIGNAL bus_thread_out           : OUT dp_thread_t;

        SIGNAL wr_maxburstlen_out       : OUT burstlen_t;
        SIGNAL wr_full_out              : OUT STD_LOGIC;
        SIGNAL wr_req_in                : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_req_pending_p0_in    : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_req_pending_p1_in    : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_vector_in             : IN dp_vectors_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_stream_in             : IN std_logic_vector(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_stream_id_in          : IN stream_ids_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_flow_in          : IN data_flows_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_scatter_in            : IN scatters_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_end_in                : IN vector_forks_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_addr_in               : IN dp_fork_full_addrs_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_fork_in               : IN dp_forks_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_addr_mode_in          : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_src_vm_in             : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_datavalid_in          : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_in               : IN dp_datas_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_readdatavalid_in      : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_readdatavalid_vm_in   : IN STD_LOGIC_VECTOR(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_readdata_in           : IN dp_fork_datas_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_burstlen_in           : IN burstlens_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_bus_id_in             : IN dp_bus_ids_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_thread_in             : IN dp_threads_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_type_in          : IN dp_data_types_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_data_model_in         : IN dp_data_models_t(NUM_DP_SRC_PORT-1 downto 0);
        SIGNAL wr_mcast_in              : IN mcasts_t;

        SIGNAL read_pending_p0_out      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL read_pending_p1_out      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
END COMPONENT;

COMPONENT dp_core IS
    port(   
        SIGNAL clock_in                     : IN STD_LOGIC;
        SIGNAL clock_x2_in                  : IN STD_LOGIC;
        SIGNAL reset_in                     : IN STD_LOGIC;               

        SIGNAL bus_waddr_in                 : IN register_addr_t;
        SIGNAL bus_raddr_in                 : IN register_addr_t;
        SIGNAL bus_write_in                 : IN STD_LOGIC;
        SIGNAL bus_read_in                  : IN STD_LOGIC;
        SIGNAL bus_writedata_in             : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdata_out             : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdatavalid_out        : OUT STD_LOGIC;
        SIGNAL bus_writewait_out            : OUT STD_LOGIC;
        SIGNAL bus_readwait_out             : OUT STD_LOGIC;
        
        -- Bus interface for read master
        SIGNAL readmaster1_addr_out         : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL readmaster1_fork_out         : OUT dp_fork_t;
        SIGNAL readmaster1_addr_mode_out    : OUT STD_LOGIC;
        SIGNAL readmaster1_cs_out           : OUT STD_LOGIC;
        SIGNAL readmaster1_read_out         : OUT STD_LOGIC;
        SIGNAL readmaster1_read_vm_out      : OUT STD_LOGIC;
        SIGNAL readmaster1_read_data_flow_out: OUT data_flow_t;
        SIGNAL readmaster1_read_stream_out  : OUT std_logic;
        SIGNAL readmaster1_read_stream_id_out: OUT stream_id_t;
        SIGNAL readmaster1_read_vector_out  : OUT dp_vector_t;
        SIGNAL readmaster1_read_scatter_out : OUT scatter_t;
        SIGNAL readmaster1_readdatavalid_in : IN STD_LOGIC;
        SIGNAL readmaster1_readdatavalid_vm_in : IN STD_LOGIC;
        SIGNAL readmaster1_readdata_in      : IN STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL readmaster1_wait_request_in  : IN STD_LOGIC;
        SIGNAL readmaster1_burstlen_out     : OUT burstlen_t;
        SIGNAL readmaster1_bus_id_out       : OUT dp_bus_id_t;
        SIGNAL readmaster1_data_type_out    : OUT dp_data_type_t;
        SIGNAL readmaster1_data_model_out   : OUT dp_data_model_t;

        -- Bus interface for write master
        SIGNAL writemaster1_addr_out        : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL writemaster1_fork_out        : OUT dp_fork_t;
        SIGNAL writemaster1_addr_mode_out   : OUT STD_LOGIC;
        SIGNAL writemaster1_vm_out          : OUT STD_LOGIC;
        SIGNAL writemaster1_mcast_out       : OUT mcast_t;
        SIGNAL writemaster1_cs_out          : OUT STD_LOGIC;
        SIGNAL writemaster1_write_out       : OUT STD_LOGIC;
        SIGNAL writemaster1_write_data_flow_out: OUT data_flow_t;
        SIGNAL writemaster1_write_vector_out: OUT dp_vector_t;
        SIGNAL writemaster1_write_stream_out: OUT std_logic;
        SIGNAL writemaster1_write_stream_id_out: OUT stream_id_t; 
        SIGNAL writemaster1_write_scatter_out: OUT scatter_t;
        SIGNAL writemaster1_writedata_out   : OUT STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL writemaster1_wait_request_in : IN STD_LOGIC;
        SIGNAL writemaster1_burstlen_out    : OUT burstlen_t;
        SIGNAL writemaster1_bus_id_out      : OUT dp_bus_id_t;
        SIGNAL writemaster1_data_type_out   : OUT dp_data_type_t;
        SIGNAL writemaster1_data_model_out  : OUT dp_data_model_t;
        SIGNAL writemaster1_thread_out      : OUT dp_thread_t;
        SIGNAL writemaster1_counter_in      : IN dp_counters_t(1 DOWNTO 0);            

        -- Bus interface for read master SRAM
        SIGNAL readmaster2_addr_out         : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
        SIGNAL readmaster2_fork_out         : OUT std_logic_vector(fork_sram_c-1 downto 0);
        SIGNAL readmaster2_cs_out           : OUT STD_LOGIC;
        SIGNAL readmaster2_read_out         : OUT STD_LOGIC;
        SIGNAL readmaster2_read_vm_out      : OUT STD_LOGIC;
        SIGNAL readmaster2_read_vector_out  : OUT dp_vector_t;
        SIGNAL readmaster2_read_scatter_out : OUT scatter_t;
        SIGNAL readmaster2_readdatavalid_in : IN STD_LOGIC;
        SIGNAL readmaster2_readdatavalid_vm_in : IN STD_LOGIC;
        SIGNAL readmaster2_readdata_in      : IN STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL readmaster2_wait_request_in  : IN STD_LOGIC;
        SIGNAL readmaster2_burstlen_out     : OUT burstlen_t;
        SIGNAL readmaster2_bus_id_out       : OUT dp_bus_id_t;

        -- Bus interface for write master SRAM
        SIGNAL writemaster2_addr_out        : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
        SIGNAL writemaster2_fork_out        : OUT std_logic_vector(fork_sram_c-1 downto 0);
        SIGNAL writemaster2_cs_out          : OUT STD_LOGIC;
        SIGNAL writemaster2_write_out       : OUT STD_LOGIC;
        SIGNAL writemaster2_vm_out          : OUT STD_LOGIC;
        SIGNAL writemaster2_write_vector_out: OUT dp_vector_t;
        SIGNAL writemaster2_write_scatter_out: OUT scatter_t;
        SIGNAL writemaster2_writedata_out   : OUT STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL writemaster2_wait_request_in : IN STD_LOGIC;
        SIGNAL writemaster2_burstlen_out    : OUT burstlen_t;
        SIGNAL writemaster2_bus_id_out      : OUT dp_bus_id_t;
        SIGNAL writemaster2_thread_out      : OUT dp_thread_t;
        SIGNAL writemaster2_counter_in      : IN dp_counters_t(1 downto 0);            

        -- Bus interface for read master DDR

        SIGNAL readmaster3_addr_out         : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
        SIGNAL readmaster3_cs_out           : OUT STD_LOGIC;
        SIGNAL readmaster3_read_out         : OUT STD_LOGIC;
        SIGNAL readmaster3_read_vm_out      : OUT STD_LOGIC;
        SIGNAL readmaster3_read_vector_out  : OUT dp_vector_t;
        SIGNAL readmaster3_read_scatter_out : OUT scatter_t;
        SIGNAL readmaster3_read_start_out   : OUT unsigned(ddr_vector_depth_c downto 0);
        SIGNAL readmaster3_read_end_out     : OUT vectors_t(fork_ddr_c-1 downto 0);
        SIGNAL readmaster3_readdatavalid_in : IN STD_LOGIC;
        SIGNAL readmaster3_readdatavalid_vm_in : IN STD_LOGIC;
        SIGNAL readmaster3_readdata_in      : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL readmaster3_wait_request_in  : IN STD_LOGIC;
        SIGNAL readmaster3_burstlen_out     : OUT burstlen_t;
        SIGNAL readmaster3_bus_id_out       : OUT dp_bus_id_t;
        SIGNAL readmaster3_filler_data_out  : OUT STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

        -- Bus interface for write master DDR
        
        SIGNAL writemaster3_addr_out        : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
        SIGNAL writemaster3_cs_out          : OUT STD_LOGIC;
        SIGNAL writemaster3_write_out       : OUT STD_LOGIC;
        SIGNAL writemaster3_vm_out          : OUT STD_LOGIC;
        SIGNAL writemaster3_write_vector_out: OUT dp_vector_t;
        SIGNAL writemaster3_write_scatter_out: OUT scatter_t;
        SIGNAL writemaster3_write_end_out   : OUT vectors_t(fork_ddr_c-1 downto 0);
        SIGNAL writemaster3_writedata_out   : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL writemaster3_wait_request_in : IN STD_LOGIC;
        SIGNAL writemaster3_burstlen_out    : OUT burstlen_t;
        SIGNAL writemaster3_burstlen2_out   : OUT burstlen2_t;
        SIGNAL writemaster3_burstlen3_out   : OUT burstlen_t;
        SIGNAL writemaster3_bus_id_out      : OUT dp_bus_id_t;
        SIGNAL writemaster3_thread_out      : OUT dp_thread_t;
        SIGNAL writemaster3_counter_in      : IN dp_counter_t;            

        -- Task control
        
        SIGNAL task_start_addr_out          : OUT instruction_addr_t;
        SIGNAL task_out                     : OUT STD_LOGIC;
        SIGNAL task_vm_out                  : OUT STD_LOGIC;
        SIGNAL task_pcore_out               : OUT pcore_t;
        SIGNAL task_lockstep_out            : OUT STD_LOGIC;
        SIGNAL task_tid_mask_out            : OUT tid_mask_t;
        SIGNAL task_iregister_auto_out      : OUT iregister_auto_t;
        SIGNAL task_data_model_out          : OUT dp_data_model_t;

        SIGNAL task_busy_in                 : IN STD_LOGIC_VECTOR(1 downto 0);
        SIGNAL task_ready_in                : IN STD_LOGIC;
        SIGNAL task_busy_out                : OUT STD_LOGIC_VECTOR(1 downto 0);

        -- BAR info
        
        SIGNAL bar_in                       : IN dp_addrs_t(dp_bus_id_max_c-1 downto 0);

        -- Indication
        SIGNAL indication_avail_out         : OUT STD_LOGIC;
        
        SIGNAL ddr_tx_busy_in               : IN STD_LOGIC
    );
END COMPONENT;

COMPONENT register_bank IS
   PORT( 
        SIGNAL clock_in               : IN STD_LOGIC;
        SIGNAL clock_x2_in            : IN STD_LOGIC;
        SIGNAL reset_in               : IN STD_LOGIC;

        SIGNAL rd_en_in               : IN STD_LOGIC;
        SIGNAL rd_en_vm_in            : IN STD_LOGIC;
        SIGNAL rd_en_out              : OUT STD_LOGIC;
        SIGNAL rd_x1_vector_in        : IN STD_LOGIC;
        SIGNAL rd_x1_addr_in          : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 1
        SIGNAL rd_x2_vector_in        : IN STD_LOGIC;
        SIGNAL rd_x2_addr_in          : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 2
        SIGNAL rd_x1_data_out         : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 1
        SIGNAL rd_x2_data_out         : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 2

        SIGNAL wr_en_in               : IN STD_LOGIC; -- Write enable
        SIGNAL wr_en_vm_in            : IN STD_LOGIC; -- Write enable
        SIGNAL wr_vector_in           : IN STD_LOGIC;
        SIGNAL wr_addr_in             : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Write address
        SIGNAL wr_data_in             : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Write value
        SIGNAL wr_lane_in             : IN STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);

        -- DP interface
        SIGNAL dp_rd_vector_in        : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_in       : IN scatter_t;
        SIGNAL dp_rd_scatter_cnt_in   : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_vector_in: IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_gen_valid_in     : IN STD_LOGIC;
        SIGNAL dp_rd_data_flow_in     : IN data_flow_t;
        SIGNAL dp_rd_data_type_in     : IN dp_data_type_t;
        SIGNAL dp_rd_stream_in        : IN std_logic;
        SIGNAL dp_rd_stream_id_in     : stream_id_t;
        SIGNAL dp_rd_addr_in          : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_vector_in        : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_wr_addr_in          : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_write_in            : IN STD_LOGIC;
        SIGNAL dp_write_vm_in         : IN STD_LOGIC;
        SIGNAL dp_read_in             : IN STD_LOGIC;
        SIGNAL dp_read_vm_in          : IN STD_LOGIC;
        SIGNAL dp_writedata_in        : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out        : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_vm_out     : OUT STD_LOGIC;
        SIGNAL dp_readena_out         : OUT STD_LOGIC;
        SIGNAL dp_read_vector_out     : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_vaddr_out      : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_scatter_out    : OUT scatter_t;
        SIGNAL dp_read_scatter_cnt_out: OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_scatter_vector_out : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_gen_valid_out  : OUT STD_LOGIC;
        SIGNAL dp_read_data_flow_out  : OUT data_flow_t;
        SIGNAL dp_read_data_type_out  : OUT dp_data_type_t;
        SIGNAL dp_read_stream_out     : OUT std_logic; 
        SIGNAL dp_read_stream_id_out  : OUT stream_id_t
        );
END COMPONENT;

COMPONENT register_file IS
   PORT( 
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL clock_x2_in          : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        SIGNAL rd_en_in             : IN STD_LOGIC;
        SIGNAL rd_en_out            : OUT STD_LOGIC;
        SIGNAL rd_x1_vector_in      : IN STD_LOGIC;
        SIGNAL rd_x1_addr_in        : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 1
        SIGNAL rd_x2_vector_in      : IN STD_LOGIC;
        SIGNAL rd_x2_addr_in        : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 2
        SIGNAL rd_x1_data_out       : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 1
        SIGNAL rd_x2_data_out       : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 2

        SIGNAL wr_en_in             : IN STD_LOGIC; -- Write enable
        SIGNAL wr_vector_in         : IN STD_LOGIC;
        SIGNAL wr_addr_in           : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Write address
        SIGNAL wr_data_in           : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Write value
        SIGNAL wr_lane_in           : IN STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);

        -- DP interface
        SIGNAL dp_rd_vector_in      : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_in     : IN scatter_t;
        SIGNAL dp_rd_scatter_cnt_in : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_vector_in: IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_gen_valid_in   : IN STD_LOGIC;
        SIGNAL dp_rd_data_flow_in   : IN data_flow_t;
        SIGNAL dp_rd_data_type_in   : IN dp_data_type_t;
        SIGNAL dp_rd_stream_in      : IN std_logic;
        SIGNAL dp_rd_stream_id_in   : stream_id_t;
        SIGNAL dp_rd_addr_in        : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_vector_in      : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_wr_addr_in        : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_write_in          : IN STD_LOGIC;
        SIGNAL dp_read_in           : IN STD_LOGIC;
        SIGNAL dp_writedata_in      : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out      : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readena_out       : OUT STD_LOGIC
        );
END COMPONENT;

COMPONENT ram2r1w IS
   GENERIC(
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT(
        clock      : IN STD_LOGIC ;
        clock_x2   : IN STD_LOGIC ;
        address_a  : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        byteena_a  : IN STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
        data_a     : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        wren_a     : IN STD_LOGIC ;
        address1_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
        q1_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        address2_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0);
        q2_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT instr IS
    port(   clock_in                        : IN STD_LOGIC;
            reset_in                        : IN STD_LOGIC;

            -- DP interface
            
            SIGNAL dp_code_in               : IN STD_LOGIC;
            SIGNAL dp_config_in             : IN STD_LOGIC;
            SIGNAL dp_wr_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);  
            SIGNAL dp_write_in              : IN STD_LOGIC;
            SIGNAL dp_writedata_in          : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
            
            -- Busy status
            
            SIGNAL busy_out                 : OUT STD_LOGIC_VECTOR(1 downto 0);
            SIGNAL ready_out                : OUT STD_LOGIC;

            -- Instruction interface
            
            SIGNAL instruction_mu_out       : OUT STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
            SIGNAL instruction_imu_out      : OUT STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
            SIGNAL instruction_mu_valid_out : OUT STD_LOGIC;
            SIGNAL instruction_imu_valid_out: OUT STD_LOGIC;
            SIGNAL vm_out                   : OUT STD_LOGIC;
            SIGNAL data_model_out           : OUT dp_data_model_t;
            SIGNAL enable_out               : OUT STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
            SIGNAL tid_out                  : OUT tid_t;
            SIGNAL tid_valid1_out           : OUT STD_LOGIC;
            SIGNAL pre_tid_out              : OUT tid_t;
            SIGNAL pre_tid_valid1_out       : OUT STD_LOGIC;
            SIGNAL pre_pre_tid_out          : OUT tid_t;
            SIGNAL pre_pre_tid_valid1_out   : OUT STD_LOGIC;
            SIGNAL pre_pre_vm_out           : OUT STD_LOGIC;
            SIGNAL pre_pre_data_model_out   : OUT dp_data_model_t;
            SIGNAL pre_iregister_auto_out   : OUT iregister_auto_t;
            SIGNAL i_y_neg_in               : IN STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
            SIGNAL i_y_zero_in              : IN STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0)
            );
END COMPONENT;

COMPONENT instr_fetch IS 
   PORT(SIGNAL clock_in                             : IN STD_LOGIC;
        SIGNAL reset_in                             : IN STD_LOGIC;

        -- Interface to instruction decoder stage

        SIGNAL instruction_mu_out                   : OUT STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_imu_out                  : OUT STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_mu_valid_out             : OUT STD_LOGIC;
        SIGNAL instruction_imu_valid_out            : OUT STD_LOGIC;
        SIGNAL instruction_vm_out                   : OUT STD_LOGIC;
        SIGNAL instruction_data_model_out           : OUT dp_data_model_t;
        SIGNAL instruction_tid_out                  : OUT tid_t;
        SIGNAL instruction_tid_valid_out            : OUT STD_LOGIC;
        SIGNAL instruction_pre_tid_out              : OUT tid_t;  -- TID value for next clock                                        
        SIGNAL instruction_pre_tid_valid_out        : OUT STD_LOGIC;  -- TID value for next clock                                        
        SIGNAL instruction_pre_pre_tid_out          : OUT tid_t;  -- TID value for next clock                                        
        SIGNAL instruction_pre_pre_tid_valid_out    : OUT STD_LOGIC; -- Tid valid for next clock
        SIGNAL instruction_pre_pre_vm_out           : OUT STD_LOGIC;
        SIGNAL instruction_pre_pre_data_model_out   : OUT dp_data_model_t;
        SIGNAL instruction_pcore_enable_out         : OUT STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
        SIGNAL instruction_pre_iregister_auto_out   : OUT iregister_auto_t;

        -- Interface with ROM for instruction fetching

        SIGNAL rom_addr_out                         : OUT STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0); -- ROM Address of next instruction
        SIGNAL rom_addr_plus_2_out                  : OUT STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0); -- ROM Address of next instruction+1
        SIGNAL rom_data_in                          : IN STD_LOGIC_VECTOR (instruction_width_c-1 DOWNTO 0);

        -- Ready indication
        
        SIGNAL busy_out                             : OUT STD_LOGIC_VECTOR(1 downto 0);
        SIGNAL ready_out                            : OUT STD_LOGIC;

        -- Signals to start a thread 
        
        SIGNAL task_start_addr_in                   : IN instruction_addr_t;    -- Address to start execution
        SIGNAL task_in                              : IN STD_LOGIC;
        SIGNAL task_pcore_max_in                    : IN pcore_t;
        SIGNAL task_vm_in                           : IN STD_LOGIC;
        SIGNAL task_lockstep_in                     : IN STD_LOGIC;
        SIGNAL task_tid_mask_in                     : IN tid_mask_t;
        SIGNAL task_iregister_auto_in               : IN iregister_auto_t;
        SIGNAL task_data_model_in                   : IN dp_data_model_t;

        SIGNAL i_y_neg_in                           : IN STD_LOGIC;
        SIGNAL i_y_zero_in                          : IN STD_LOGIC
        );
END COMPONENT;

COMPONENT instr_decoder2 IS
    GENERIC(
        CID:integer;
        PID:integer
    );
    PORT(
        -- Global signal
        
        SIGNAL clock_in                             : IN STD_LOGIC;
        SIGNAL reset_in                             : IN STD_LOGIC;    
        
        -- Signal received from previous stage
        
        SIGNAL instruction_mu_in                    : IN STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0); -- instruction to dispatch
        SIGNAL instruction_imu_in                   : IN STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0); -- instruction to dispatch
        SIGNAL instruction_mu_valid_in              : IN STD_LOGIC;
        SIGNAL instruction_imu_valid_in             : IN STD_LOGIC;
        SIGNAL instruction_tid_in                   : IN tid_t;
        SIGNAL instruction_tid_valid_in             : IN STD_LOGIC;
        SIGNAL instruction_vm_in                    : IN STD_LOGIC;
        SIGNAL instruction_data_model_in            : IN dp_data_model_t;
        SIGNAL instruction_pre_pre_vm_in            : IN STD_LOGIC;
        SIGNAL instruction_pre_pre_data_model_in    : IN dp_data_model_t;
        SIGNAL instruction_pre_tid_in               : IN tid_t;
        SIGNAL instruction_pre_tid_valid_in         : IN STD_LOGIC;
        SIGNAL instruction_pre_pre_tid_in           : IN tid_t;
        SIGNAL instruction_pre_pre_tid_valid_in     : IN STD_LOGIC;
        SIGNAL instruction_pre_iregister_auto_in    : IN iregister_auto_t;

        -- Signal send to next stage
        SIGNAL opcode1_out                          : OUT STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
        SIGNAL en1_out                              : OUT STD_LOGIC;
        SIGNAL instruction_tid_out                  : OUT tid_t;

        -- Flag
        SIGNAL xreg1_out                            : OUT STD_LOGIC;
        SIGNAL flag1_out                            : OUT STD_LOGIC;
        SIGNAL wren_out                             : OUT STD_LOGIC;

        SIGNAL vm_out                               : OUT STD_LOGIC;

        -- X,Y,Z parameters
        SIGNAL x1_addr1_out                         : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL x2_addr1_out                         : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL y_addr1_out                          : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);

        -- Vector mode
        SIGNAL x1_vector_out                        : OUT STD_LOGIC;
        SIGNAL x2_vector_out                        : OUT STD_LOGIC;
        SIGNAL y_vector_out                         : OUT STD_LOGIC;
        SIGNAL vector_lane_out                      : OUT STD_LOGIC_VECTOR(vector_width_c-1 downto 0);

        -- Constant parameters
        SIGNAL x1_c1_en_out                         : OUT STD_LOGIC;
        SIGNAL x1_c1_out                            : OUT STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);

        -- IREGISTER
        SIGNAL i_rd_en_out                          : OUT STD_LOGIC;
        SIGNAL i_rd_vm_out                          : OUT STD_LOGIC;
        SIGNAL i_rd_tid_out                         : OUT tid_t;
        SIGNAL i_rd_data_in                         : IN iregisters_t(iregister_max_c-1 downto 0);
        SIGNAL i_wr_tid_out                         : OUT tid_t;
        SIGNAL i_wr_en_out                          : OUT STD_LOGIC;
        SIGNAL i_wr_vm_out                          : OUT STD_LOGIC;
        SIGNAL i_wr_addr_out                        : OUT iregister_addr_t;
        SIGNAL i_wr_data_out                        : OUT iregister_t;

        --LANE
        SIGNAL lane_in                              : IN iregister_t;
        SIGNAL wr_lane_out                          : OUT STD_LOGIC;

        -- IALU
        SIGNAL i_opcode_out                         : OUT STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
        SIGNAL i_x1_out                             : OUT iregister_t;
        SIGNAL i_x2_out                             : OUT iregister_t;
        SIGNAL i_y_in                               : IN iregister_t;

        -- RESULT
        SIGNAL result_raddr_out                     : OUT STD_LOGIC_VECTOR(xreg_depth_c downto 0);
        SIGNAL result_waddr_out                     : OUT STD_LOGIC_VECTOR(xreg_depth_c downto 0);
        SIGNAL result_in                            : IN iregister_t
    );
END COMPONENT;

COMPONENT instr_dispatch2 IS
    PORT(SIGNAL clock_in            : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        SIGNAL opcode_in            : IN STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
        SIGNAL instruction_tid_in   : IN tid_t;
        SIGNAL xreg_in              : IN STD_LOGIC;
        SIGNAL flag_in              : IN STD_LOGIC;
        SIGNAL wren_in              : IN STD_LOGIC;

        SIGNAL en_in                : IN STD_LOGIC;

        SIGNAL vm_in                : IN STD_LOGIC;

        SIGNAL x1_addr1_in          : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL x2_addr1_in          : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL y_addr1_in           : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL result_addr1_in      : IN STD_LOGIC_VECTOR(xreg_depth_c downto 0);

        SIGNAL x1_c1_en_in          : IN STD_LOGIC;
        SIGNAL x1_c1_in             : IN STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);

        SIGNAL x1_vector_in         : IN STD_LOGIC;
        SIGNAL x2_vector_in         : IN STD_LOGIC;
        SIGNAL y_vector_in          : IN STD_LOGIC;
        SIGNAL vector_lane_in       : IN STD_LOGIC_VECTOR(vector_width_c-1 downto 0);

        SIGNAL rd_en_out            : OUT STD_LOGIC;   
        SIGNAL rd_vm_out            : OUT STD_LOGIC;       
        SIGNAL rd_x1_addr_out       : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Address for X1 register
        SIGNAL rd_x2_addr_out       : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Address for X2 register
        SIGNAL rd_x1_data_in        : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);  -- Value of X1 register
        SIGNAL rd_x2_data_in        : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Value of X2 register

        SIGNAL rd_x1_vector_out     : OUT STD_LOGIC;
        SIGNAL rd_x2_vector_out     : OUT STD_LOGIC;

        SIGNAL wr_xreg_out          : OUT STD_LOGIC;
        SIGNAL wr_flag_out          : OUT STD_LOGIC;
        SIGNAL wr_en_out            : OUT STD_LOGIC; -- Enable write 
        SIGNAL wr_vm_out            : OUT STD_LOGIC;
        SIGNAL wr_vector_out        : OUT STD_LOGIC;
        SIGNAL wr_addr_out          : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); --
        SIGNAL wr_result_addr_out   : OUT STD_LOGIC_VECTOR(xreg_depth_c downto 0); 
        SIGNAL wr_data_out          : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
        SIGNAL wr_lane_out          : OUT STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);

        SIGNAL mu_x1_out            : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
        SIGNAL mu_x2_out            : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
        SIGNAL mu_x_scalar_out      : OUT STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);
        SIGNAL mu_opcode_out        : OUT mu_opcode_t;
        SIGNAL mu_tid_out           : OUT tid_t;
        SIGNAL mu_y_in              : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0)
       );
END COMPONENT;

COMPONENT xregister_file IS
    PORT(
        -- Global signal
        SIGNAL clock_in               : IN STD_LOGIC;
        SIGNAL clock_x2_in            : IN STD_LOGIC;
        SIGNAL reset_in               : IN STD_LOGIC; 

        -- Flag enable input for MU
        
        SIGNAL write_result_vector_in : IN STD_LOGIC;
        SIGNAL write_result_lane_in   : IN STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);
        SIGNAL write_addr_in          : IN std_logic_vector(xreg_depth_c downto 0);
        SIGNAL write_result_ena_in    : IN STD_LOGIC;
        SIGNAL write_xreg_ena_in      : IN STD_LOGIC;
        SIGNAL write_data_in          : IN STD_LOGIC_VECTOR(vaccumulator_width_c-1 downto 0);
        SIGNAL write_result_in        : IN STD_LOGIC_VECTOR(vector_width_c-1 downto 0);

        -- Stored flag
        
        SIGNAL read_addr_in           : IN std_logic_vector(xreg_depth_c downto 0);
        SIGNAL read_result_out        : OUT iregister_t;
        SIGNAL read_xreg_out          : OUT STD_LOGIC_VECTOR(vaccumulator_width_c-1 downto 0)
    );
END COMPONENT;

COMPONENT pcore IS
    GENERIC (
        CID:integer;
        PID:integer
        );
   PORT(
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL clock_x2_in              : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;    
                
        -- Instruction interface
        SIGNAL instruction_mu_in        : IN STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0); -- instruction to dispatch
        SIGNAL instruction_imu_in       : IN STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0); -- instruction to dispatch
        SIGNAL instruction_mu_valid_in  : IN STD_LOGIC;
        SIGNAL instruction_imu_valid_in : IN STD_LOGIC;

        SIGNAL vm_in                    : IN STD_LOGIC;
        SIGNAL data_model_in            : IN dp_data_model_t;
        SIGNAL enable_in                : IN STD_LOGIC;

        SIGNAL tid_in                   : IN tid_t;
        SIGNAL tid_valid1_in            : IN STD_LOGIC;
        SIGNAL pre_tid_in               : IN tid_t;
        SIGNAL pre_tid_valid1_in        : IN STD_LOGIC;
        SIGNAL pre_pre_tid_in           : IN tid_t;
        SIGNAL pre_pre_tid_valid1_in    : IN STD_LOGIC;

        SIGNAL pre_pre_vm_in            : IN STD_LOGIC;
        SIGNAL pre_pre_data_model_in    : IN dp_data_model_t;

        SIGNAL pre_iregister_auto_in    : IN iregister_auto_t;

        SIGNAL i_y_neg_out              : OUT STD_LOGIC;
        SIGNAL i_y_zero_out             : OUT STD_LOGIC;

        -- DP interface

        SIGNAL dp_rd_vm_in              : IN STD_LOGIC;        
        SIGNAL dp_wr_vm_in              : IN STD_LOGIC;
        SIGNAL dp_code_in               : IN STD_LOGIC;
        SIGNAL dp_rd_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_addr_step_in       : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_share_in           : IN STD_LOGIC;
        SIGNAL dp_rd_fork_in            : IN STD_LOGIC;
        SIGNAL dp_wr_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_addr_step_in       : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_fork_in            : IN STD_LOGIC;
        SIGNAL dp_wr_share_in           : IN STD_LOGIC;        
        SIGNAL dp_wr_mcast_in           : IN mcast_t;    
        SIGNAL dp_write_in              : IN STD_LOGIC;
        SIGNAL dp_write_gen_valid_in    : IN STD_LOGIC;
        SIGNAL dp_write_vector_in       : IN dp_vector_t;
        SIGNAL dp_write_scatter_in      : IN scatter_t;
        SIGNAL dp_read_in               : IN STD_LOGIC;
        SIGNAL dp_read_vector_in        : IN dp_vector_t;
        SIGNAL dp_read_scatter_in       : IN scatter_t;
        SIGNAL dp_read_gen_valid_in     : IN STD_LOGIC;
        SIGNAL dp_read_data_flow_in     : IN data_flow_t;
        SIGNAL dp_read_data_type_in     : IN dp_data_type_t;
        SIGNAL dp_read_stream_in        : IN std_logic;
        SIGNAL dp_read_stream_id_in     : IN stream_id_t;
        SIGNAL dp_writedata_in          : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out          : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_vm_out       : OUT STD_LOGIC;
        SIGNAL dp_readena_out           : OUT STD_LOGIC;
        SIGNAL dp_read_vector_out       : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_vaddr_out        : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_gen_valid_out    : OUT STD_LOGIC;
        SIGNAL dp_read_data_flow_out    : OUT data_flow_t;
        SIGNAL dp_read_data_type_out    : OUT dp_data_type_t;
        SIGNAL dp_read_stream_out       : OUT std_logic;
        SIGNAL dp_read_stream_id_out    : OUT stream_id_t;
        SIGNAL dp_config_in_in          : IN STD_LOGIC            
    );
END COMPONENT;

COMPONENT cell IS
    generic (
        CID:integer
        );
    port(
        clock_in                     : IN STD_LOGIC;
        clock_x2_in                  : IN STD_LOGIC;
        reset_in                     : IN STD_LOGIC;

        -- DP interface

        SIGNAL dp_rd_vm_in           : IN STD_LOGIC;
        SIGNAL dp_wr_vm_in           : IN STD_LOGIC;
        SIGNAL dp_code_in            : IN STD_LOGIC;
        SIGNAL dp_rd_addr_in         : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_addr_step_in    : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_fork_in         : IN STD_LOGIC;
        SIGNAL dp_rd_share_in        : IN STD_LOGIC;
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
        SIGNAL dp_read_stream_in     : IN STD_LOGIC;
        SIGNAL dp_read_stream_id_in  : IN stream_id_t;
        SIGNAL dp_writedata_in       : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out       : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_vm_out    : OUT STD_LOGIC;
        SIGNAL dp_read_vector_out    : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_vaddr_out     : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_readdata_valid_out : OUT STD_LOGIC;
        SIGNAL dp_read_gen_valid_out : OUT STD_LOGIC;
        SIGNAL dp_read_data_flow_out : OUT data_flow_t;
        SIGNAL dp_read_data_type_out : OUT dp_data_type_t;
        SIGNAL dp_read_stream_out    : OUT STD_LOGIC;
        SIGNAL dp_read_stream_id_out : OUT stream_id_t;
        SIGNAL dp_config_in          : IN STD_LOGIC;

        -- Instruction interface

        SIGNAL instruction_mu_in       : IN STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_imu_in      : IN STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_mu_valid_in : IN STD_LOGIC;
        SIGNAL instruction_imu_valid_in: IN STD_LOGIC;
        SIGNAL vm_in                   : IN STD_LOGIC;
        SIGNAL data_model_in           : IN dp_data_model_t;
        SIGNAL enable_in               : IN STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
        SIGNAL tid_in                  : IN tid_t;
        SIGNAL tid_valid1_in           : IN STD_LOGIC;
        SIGNAL pre_tid_in              : IN tid_t;
        SIGNAL pre_tid_valid1_in       : IN STD_LOGIC;
        SIGNAL pre_pre_tid_in          : IN tid_t;
        SIGNAL pre_pre_tid_valid1_in   : IN STD_LOGIC;
        SIGNAL pre_pre_vm_in           : IN STD_LOGIC;
        SIGNAL pre_pre_data_model_in   : IN dp_data_model_t;
        SIGNAL pre_iregister_auto_in   : IN iregister_auto_t;
        SIGNAL i_y_neg_out             : OUT STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
        SIGNAL i_y_zero_out            : OUT STD_LOGIC_VECTOR(pid_max_c-1 downto 0)
        );
END COMPONENT;

COMPONENT mu_arbitrator IS
   PORT( 
        SIGNAL clock_in     : IN STD_LOGIC;
        SIGNAL reset_in     : IN STD_LOGIC;
        SIGNAL mu_req_in    : IN STD_LOGIC_VECTOR(pid_max_c-1 DOWNTO 0); 
        SIGNAL mu_grant_out : OUT STD_LOGIC_VECTOR(pid_max_c-1 DOWNTO 0)
       );
END COMPONENT;

COMPONENT alu IS
    PORT
    (
        clock_in        : IN STD_LOGIC ;
        reset_in        : IN STD_LOGIC;
        mu_opcode_in    : IN mu_opcode_t;
        mu_tid_in       : IN tid_t;
        xreg_in         : IN STD_LOGIC_VECTOR(accumulator_width_c-1 downto 0);
        x1_in           : IN STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
        x2_in           : IN STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
        x_scalar_in     : IN STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);
        y_out           : OUT STD_LOGIC_VECTOR (accumulator_width_c-1 DOWNTO 0);
        y2_out          : OUT STD_LOGIC;
        y3_out          : OUT STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0)
    );
end COMPONENT;

COMPONENT mu_mul IS
    PORT
    (
        clock_in           : IN STD_LOGIC ;
        reset_in           : IN STD_LOGIC;
        mu_opcode_in       : IN mu_opcode_t;
        mu_opcode_delay_in : IN mu_opcode_t;
        x1_in              : IN STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
        x2_in              : IN STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
        y_out              : OUT STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
        enable_out         : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT mu_conv IS
    PORT
    (
        clock_in        : IN STD_LOGIC ;
        reset_in        : IN STD_LOGIC;    
        oc1_in          : IN mu_opcode_t;
        oc2_in          : IN mu_opcode_t;        
        x1_in           : IN STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
        x2_in           : IN STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);        
        y_out           : OUT STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
        y1_en_out       : OUT STD_LOGIC;
        y2_en_out       : OUT STD_LOGIC
    );
END COMPONENT;

component iconv 
    PORT(        
        clock           : IN STD_LOGIC ;
        dataa           : IN STD_LOGIC_VECTOR (9 DOWNTO 0);    
        result          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)    
        );
end component;

component arbiter is
    generic(
        NUM_SIGNALS     : integer;
        PRIORITY_BASED  : boolean
        );
    port(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        SIGNAL req_in           : IN STD_LOGIC_VECTOR(NUM_SIGNALS-1 downto 0);
        SIGNAL gnt_out          : OUT STD_LOGIC_VECTOR(NUM_SIGNALS-1 downto 0);
        SIGNAL gnt_valid_out    : OUT STD_LOGIC
        );
end component;

component pll is
        port (
            refclk   : IN  std_logic := 'X'; -- clk
            rst      : IN  std_logic := 'X'; -- reset
            outclk_0 : OUT std_logic;        -- clk
            locked   : OUT std_logic         -- export
        );
end component pll;

COMPONENT scfifo is
	generic 
	(
		DATA_WIDTH  : natural;
		FIFO_DEPTH  : natural;
        LOOKAHEAD   : boolean;
        ALMOST_FULL : natural := 1
	);
	port 
	(
		clock_in   : in std_logic;
        reset_in   : in std_logic;
        data_in    : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_in   : in std_logic;
        read_in    : in std_logic;
        q_out      : out std_logic_vector(DATA_WIDTH-1 downto 0);
        ravail_out : out std_logic_vector(FIFO_DEPTH-1 downto 0);
        wused_out  : out std_logic_vector(FIFO_DEPTH-1 downto 0);
        empty_out  : out std_logic;
        full_out   : out std_logic;
        almost_full_out : out std_logic
	);
end COMPONENT;

COMPONENT scfifow is
	generic 
	(
        DATA_WIDTH  : natural;
        FIFO_DEPTH  : natural
	);
	port 
	(
        clock_in        : in std_logic;
        reset_in        : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_in        : in std_logic;
        writeready_out  : out std_logic;
        read_in         : in std_logic;
        q_out           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        empty_out       : out std_logic;
        wused_out       : out std_logic_vector(FIFO_DEPTH-1 downto 0)
	);
end COMPONENT;

COMPONENT ramw IS
   GENERIC(
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT(
        clock     : IN STD_LOGIC ;
        clock_x2  : IN STD_LOGIC ;
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        byteena_a : IN STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT ramw2 IS
   GENERIC(
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT(
        clock     : IN STD_LOGIC ;
        clock_x2  : IN STD_LOGIC ;
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT multiplier is
	generic 
	(
		DATA_WIDTH      : natural;
        REGISTER_OUTPUT : BOOLEAN
	);
	port 
	(
		clock_in   : in std_logic;
        reset_in   : in std_logic;
        x_in       : in std_logic_vector(DATA_WIDTH-1 downto 0);
        y_in       : in std_logic_vector(DATA_WIDTH-1 downto 0);       
        z_out      : out std_logic_vector(2*DATA_WIDTH-1 downto 0)
	);
end COMPONENT;

COMPONENT adder is
   generic
   (
      DATA_WIDTH : natural
   );
   port 
   (
      x_in       : in std_logic_vector((DATA_WIDTH-1) downto 0);
      y_in       : in std_logic_vector((DATA_WIDTH-1) downto 0);
      add_sub_in : in std_logic;
      z_out      : out std_logic_vector((DATA_WIDTH-1) downto 0)
   );
end COMPONENT;

COMPONENT barrel_shifter_a is
   generic
   (
      DIST_WIDTH : natural;
      DATA_WIDTH : natural
   );
   port 
   (
      direction_in : in std_logic;
      data_in      : in std_logic_vector((DATA_WIDTH-1) downto 0);
      distance_in  : in std_logic_vector((DIST_WIDTH-1) downto 0);
      data_out     : out std_logic_vector((DATA_WIDTH-1) downto 0)
   );
end COMPONENT;

COMPONENT barrel_shifter_l is
   generic
   (
      DIST_WIDTH : natural;
      DATA_WIDTH : natural
   );
   port 
   (
      direction_in : in std_logic;
      data_in      : in std_logic_vector((DATA_WIDTH-1) downto 0);
      distance_in  : in std_logic_vector((DIST_WIDTH-1) downto 0);
      data_out     : out std_logic_vector((DATA_WIDTH-1) downto 0)
   );
end COMPONENT;

component delay is
    generic(
        DEPTH:integer
    );
    port(
        SIGNAL clock_in     :IN STD_LOGIC;
        SIGNAL reset_in     :IN STD_LOGIC;
        SIGNAL in_in        :IN STD_LOGIC;
        SIGNAL out_out      :OUT STD_LOGIC;
        SIGNAL enable_in    :IN STD_LOGIC
    );
end component;

component delayv is
    generic(
        SIZE:integer;
        DEPTH:integer
    );
    port(
        SIGNAL clock_in     :IN STD_LOGIC;
        SIGNAL reset_in     :IN STD_LOGIC;
        SIGNAL in_in        :IN STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
        SIGNAL out_out      :OUT STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
        SIGNAL enable_in    :IN STD_LOGIC
    );
end component;

component delayi is
    generic(
        SIZE:integer;
        DEPTH:integer
    );
    port(
        SIGNAL clock_in     :IN STD_LOGIC;
        SIGNAL reset_in     :IN STD_LOGIC;
        SIGNAL in_in        :IN unsigned(SIZE-1 DOWNTO 0);
        SIGNAL out_out      :OUT unsigned(SIZE-1 DOWNTO 0);
        SIGNAL enable_in    :IN STD_LOGIC
    );
end component;

component int2fp
    PORT
    (
        clock        : IN STD_LOGIC ;
        dataa        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        result       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
end component;

component fp2int
    PORT
    (
        clk_en       : IN STD_LOGIC ;
        clock        : IN STD_LOGIC ;
        dataa        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        result       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
end component;

COMPONENT iregister_file IS
   PORT( 
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL clock_x2_in          : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        
        -- Interface 1
        
        SIGNAL rd_en1_in            : IN STD_LOGIC;
        SIGNAL rd_vm_in             : IN STD_LOGIC;
        SIGNAL rd_tid1_in           : IN tid_t;
        SIGNAL rd_data1_out         : OUT iregisters_t(iregister_max_c-1 downto 0);
        SIGNAL rd_lane_out          : OUT iregister_t;
        SIGNAL wr_tid1_in           : IN tid_t;
        SIGNAL wr_en1_in            : IN STD_LOGIC;
        SIGNAL wr_vm_in             : IN STD_LOGIC;
        SIGNAL wr_lane_in           : IN STD_LOGIC;
        SIGNAL wr_addr1_in          : IN iregister_addr_t;
        SIGNAL wr_data1_in          : IN iregister_t
    );
END COMPONENT;

COMPONENT iregister_ram IS
    GENERIC (
        DEPTH:integer;
        WIDTH:integer
        );
    PORT (
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL clock_x2_in      : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        -- PORT 1
        SIGNAL data1_in         : IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
        SIGNAL rdaddress1_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wraddress1_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wrbyteena1_in    : IN STD_LOGIC_VECTOR(WIDTH/8-1 DOWNTO 0);
        SIGNAL wren1_in         : IN STD_LOGIC;
        SIGNAL rden1_in         : IN STD_LOGIC;
        SIGNAL q1_out           : OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT ialu IS
    PORT
    (
    SIGNAL clock_in     :IN STD_LOGIC;
    SIGNAL reset_in     :IN STD_LOGIC;
    SIGNAL opcode_in    :IN STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
    SIGNAL x1_in        :IN iregister_t;
    SIGNAL x2_in        :IN iregister_t;
    SIGNAL y_out        :OUT iregister_t;
    SIGNAL y_neg_out    :OUT STD_LOGIC;
    SIGNAL y_zero_out   :OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT TCM_read is
   generic(
      RAM_DEPTH:integer
   );
   port(   
      TCM_clk       :IN STD_LOGIC;
      TCM_reset     :IN STD_LOGIC;
      TCM_araddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_arburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_arlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_arready   :OUT STD_LOGIC;
      TCM_arsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_arvalid   :IN STD_LOGIC;
      TCM_rdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
      TCM_rlast     :OUT STD_LOGIC;
      TCM_rready    :IN STD_LOGIC;
      TCM_rresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_rvalid    :OUT STD_LOGIC;

      ram_q         :IN std_logic_vector(31 downto 0);
      ram_raddr     :OUT std_logic_vector(RAM_DEPTH-3 downto 0)
   );
END COMPONENT;

COMPONENT TCM_write is
   generic(
      RAM_DEPTH:integer
   );
   port(   
      TCM_clk       :IN STD_LOGIC;
      TCM_reset     :IN STD_LOGIC;

      TCM_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_awready   :OUT STD_LOGIC;
      TCM_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_awvalid   :IN STD_LOGIC;
      TCM_bready    :IN STD_LOGIC;
      TCM_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_bvalid    :OUT STD_LOGIC;
      TCM_wdata     :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_wlast     :IN STD_LOGIC;
      TCM_wready    :OUT STD_LOGIC;
      TCM_wstrb     :IN STD_LOGIC_VECTOR(3 downto 0);
      TCM_wvalid    :IN STD_LOGIC;

      ram_waddr     :OUT std_logic_vector(RAM_DEPTH-3 downto 0);
      ram_wdata     :OUT std_logic_vector(31 downto 0);
      ram_wren      :OUT std_logic;
      ram_be        :OUT std_logic_vector(3 downto 0)
   );
END COMPONENT;

COMPONENT TCM is
   generic(
      RAM_DEPTH:integer
   );
   port(   
      TCM_clk       :IN STD_LOGIC;
      TCM_clk_x2    :IN STD_LOGIC;
      TCM_reset     :IN STD_LOGIC;

      TCM_araddr1   :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_arburst1  :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_arlen1    :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_arready1  :OUT STD_LOGIC;
      TCM_arsize1   :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_arvalid1  :IN STD_LOGIC;
      TCM_rdata1    :OUT STD_LOGIC_VECTOR(31 downto 0);
      TCM_rlast1    :OUT STD_LOGIC;
      TCM_rready1   :IN STD_LOGIC;
      TCM_rresp1    :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_rvalid1   :OUT STD_LOGIC;

      TCM_araddr2   :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_arburst2  :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_arlen2    :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_arready2  :OUT STD_LOGIC;
      TCM_arsize2   :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_arvalid2  :IN STD_LOGIC;
      TCM_rdata2    :OUT STD_LOGIC_VECTOR(31 downto 0);
      TCM_rlast2    :OUT STD_LOGIC;
      TCM_rready2   :IN STD_LOGIC;
      TCM_rresp2    :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_rvalid2   :OUT STD_LOGIC;

      TCM_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_awready   :OUT STD_LOGIC;
      TCM_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_awvalid   :IN STD_LOGIC;
      TCM_bready    :IN STD_LOGIC;
      TCM_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_bvalid    :OUT STD_LOGIC;
      TCM_wdata     :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_wlast     :IN STD_LOGIC;
      TCM_wready    :OUT STD_LOGIC;
      TCM_wstrb     :IN STD_LOGIC_VECTOR(3 downto 0);
      TCM_wvalid    :IN STD_LOGIC
   );
END COMPONENT;

-------------------------------------------------------------------
-- soc_base
-------------------------------------------------------------------

component soc_base is
    generic (
        RISCV : string;
        TCM_DEPTH : integer:=14 -- TCM size=2**TCM_DEPTH bytes
    );
    port 
    (
        -- Reference clock/external reset

        clk_main        :IN STD_LOGIC;
        clk_x2_main     :IN STD_LOGIC;
        clk_reset       :IN STD_LOGIC;

        -- JTAG signals

        TMS             :IN std_logic:='0';
        TDI             :IN std_logic:='0';
        TDO             :OUT std_logic;
        TCK             :IN std_logic:='0';

        -- SDRAM axi signals

        SDRAM_clk       :IN STD_LOGIC;
        SDRAM_reset     :IN STD_LOGIC;
        SDRAM_araddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
        SDRAM_arburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_arlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
        SDRAM_arready   :IN STD_LOGIC;
        SDRAM_arsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
        SDRAM_arvalid   :OUT STD_LOGIC;
        SDRAM_awaddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
        SDRAM_awburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_awlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
        SDRAM_awready   :IN STD_LOGIC;
        SDRAM_awsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
        SDRAM_awvalid   :OUT STD_LOGIC;
        SDRAM_bready    :OUT STD_LOGIC;
        SDRAM_bresp     :IN STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_bvalid    :IN STD_LOGIC;
        SDRAM_rdata     :IN STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
        SDRAM_rlast     :IN STD_LOGIC;
        SDRAM_rready    :OUT STD_LOGIC;
        SDRAM_rresp     :IN STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_rvalid    :IN STD_LOGIC;
        SDRAM_wdata     :OUT STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
        SDRAM_wlast     :OUT STD_LOGIC;
        SDRAM_wready    :IN STD_LOGIC;
        SDRAM_wstrb     :OUT STD_LOGIC_VECTOR(exmem_data_width_c/8-1 downto 0);
        SDRAM_wvalid    :OUT STD_LOGIC;

        -- APB bus signals

        APB_PADDR       :INOUT STD_LOGIC_VECTOR(19 downto 0);
        APB_PENABLE     :INOUT STD_LOGIC;
        APB_PREADY      :INOUT STD_LOGIC;
        APB_PWRITE      :INOUT STD_LOGIC;
        APB_PWDATA      :INOUT STD_LOGIC_VECTOR(31 downto 0);
        APB_PRDATA      :INOUT STD_LOGIC_VECTOR(31 downto 0);
        APB_PSLVERROR   :INOUT STD_LOGIC;

        -- VIDEO streaming bus  

        VIDEO_clk       :IN STD_LOGIC;
        VIDEO_tdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
        VIDEO_tlast     :OUT STD_LOGIC;
        VIDEO_tready    :IN STD_LOGIC;
        VIDEO_tvalid    :OUT STD_LOGIC;

        -- Camera streaming bus

        camera_clk      :IN STD_LOGIC;
        camera_tdata    :IN STD_LOGIC_VECTOR(31 downto 0);
        camera_tlast    :IN STD_LOGIC;
        camera_tready   :OUT STD_LOGIC;
        camera_tvalid   :IN STD_LOGIC
    );
end component;

-------------------------------------------------------------------
-- VexRiscv
-------------------------------------------------------------------

component VexRiscvForJtag is
    port(
        io_asyncReset : in std_logic;
        io_mainClk : in std_logic;
        io_iBus_ar_valid : out std_logic;
        io_iBus_ar_ready : in std_logic;
        io_iBus_ar_payload_addr : out unsigned(31 downto 0);
        io_iBus_ar_payload_id : out unsigned(0 downto 0);
        io_iBus_ar_payload_region : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_len : out unsigned(7 downto 0);
        io_iBus_ar_payload_size : out unsigned(2 downto 0);
        io_iBus_ar_payload_burst : out std_logic_vector(1 downto 0);
        io_iBus_ar_payload_lock : out std_logic_vector(0 downto 0);
        io_iBus_ar_payload_cache : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_qos : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_prot : out std_logic_vector(2 downto 0);
        io_iBus_r_valid : in std_logic;
        io_iBus_r_ready : out std_logic;
        io_iBus_r_payload_data : in std_logic_vector(31 downto 0);
        io_iBus_r_payload_id : in unsigned(0 downto 0);
        io_iBus_r_payload_resp : in std_logic_vector(1 downto 0);
        io_iBus_r_payload_last : in std_logic;
        io_dBus_aw_valid : out std_logic;
        io_dBus_aw_ready : in std_logic;
        io_dBus_aw_payload_addr : out unsigned(31 downto 0);
        io_dBus_aw_payload_id : out unsigned(0 downto 0);
        io_dBus_aw_payload_region : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_len : out unsigned(7 downto 0);
        io_dBus_aw_payload_size : out unsigned(2 downto 0);
        io_dBus_aw_payload_burst : out std_logic_vector(1 downto 0);
        io_dBus_aw_payload_lock : out std_logic_vector(0 downto 0);
        io_dBus_aw_payload_cache : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_qos : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_prot : out std_logic_vector(2 downto 0);
        io_dBus_w_valid : out std_logic;
        io_dBus_w_ready : in std_logic;
        io_dBus_w_payload_data : out std_logic_vector(31 downto 0);
        io_dBus_w_payload_strb : out std_logic_vector(3 downto 0);
        io_dBus_w_payload_last : out std_logic;
        io_dBus_b_valid : in std_logic;
        io_dBus_b_ready : out std_logic;
        io_dBus_b_payload_id : in unsigned(0 downto 0);
        io_dBus_b_payload_resp : in std_logic_vector(1 downto 0);
        io_dBus_ar_valid : out std_logic;
        io_dBus_ar_ready : in std_logic;
        io_dBus_ar_payload_addr : out unsigned(31 downto 0);
        io_dBus_ar_payload_id : out unsigned(0 downto 0);
        io_dBus_ar_payload_region : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_len : out unsigned(7 downto 0);
        io_dBus_ar_payload_size : out unsigned(2 downto 0);
        io_dBus_ar_payload_burst : out std_logic_vector(1 downto 0);
        io_dBus_ar_payload_lock : out std_logic_vector(0 downto 0);
        io_dBus_ar_payload_cache : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_qos : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_prot : out std_logic_vector(2 downto 0);
        io_dBus_r_valid : in std_logic;
        io_dBus_r_ready : out std_logic;
        io_dBus_r_payload_data : in std_logic_vector(31 downto 0);
        io_dBus_r_payload_id : in unsigned(0 downto 0);
        io_dBus_r_payload_resp : in std_logic_vector(1 downto 0);
        io_dBus_r_payload_last : in std_logic;
        io_jtag_tms : in std_logic;
        io_jtag_tdi : in std_logic;
        io_jtag_tdo : out std_logic;
        io_jtag_tck : in std_logic
    );
end component;

component VexRiscvForXilinxBscan2Jtag is
    port(
        io_asyncReset : in std_logic;
        io_mainClk : in std_logic;
        io_iBus_ar_valid : out std_logic;
        io_iBus_ar_ready : in std_logic;
        io_iBus_ar_payload_addr : out unsigned(31 downto 0);
        io_iBus_ar_payload_id : out unsigned(0 downto 0);
        io_iBus_ar_payload_region : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_len : out unsigned(7 downto 0);
        io_iBus_ar_payload_size : out unsigned(2 downto 0);
        io_iBus_ar_payload_burst : out std_logic_vector(1 downto 0);
        io_iBus_ar_payload_lock : out std_logic_vector(0 downto 0);
        io_iBus_ar_payload_cache : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_qos : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_prot : out std_logic_vector(2 downto 0);
        io_iBus_r_valid : in std_logic;
        io_iBus_r_ready : out std_logic;
        io_iBus_r_payload_data : in std_logic_vector(31 downto 0);
        io_iBus_r_payload_id : in unsigned(0 downto 0);
        io_iBus_r_payload_resp : in std_logic_vector(1 downto 0);
        io_iBus_r_payload_last : in std_logic;
        io_dBus_aw_valid : out std_logic;
        io_dBus_aw_ready : in std_logic;
        io_dBus_aw_payload_addr : out unsigned(31 downto 0);
        io_dBus_aw_payload_id : out unsigned(0 downto 0);
        io_dBus_aw_payload_region : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_len : out unsigned(7 downto 0);
        io_dBus_aw_payload_size : out unsigned(2 downto 0);
        io_dBus_aw_payload_burst : out std_logic_vector(1 downto 0);
        io_dBus_aw_payload_lock : out std_logic_vector(0 downto 0);
        io_dBus_aw_payload_cache : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_qos : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_prot : out std_logic_vector(2 downto 0);
        io_dBus_w_valid : out std_logic;
        io_dBus_w_ready : in std_logic;
        io_dBus_w_payload_data : out std_logic_vector(31 downto 0);
        io_dBus_w_payload_strb : out std_logic_vector(3 downto 0);
        io_dBus_w_payload_last : out std_logic;
        io_dBus_b_valid : in std_logic;
        io_dBus_b_ready : out std_logic;
        io_dBus_b_payload_id : in unsigned(0 downto 0);
        io_dBus_b_payload_resp : in std_logic_vector(1 downto 0);
        io_dBus_ar_valid : out std_logic;
        io_dBus_ar_ready : in std_logic;
        io_dBus_ar_payload_addr : out unsigned(31 downto 0);
        io_dBus_ar_payload_id : out unsigned(0 downto 0);
        io_dBus_ar_payload_region : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_len : out unsigned(7 downto 0);
        io_dBus_ar_payload_size : out unsigned(2 downto 0);
        io_dBus_ar_payload_burst : out std_logic_vector(1 downto 0);
        io_dBus_ar_payload_lock : out std_logic_vector(0 downto 0);
        io_dBus_ar_payload_cache : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_qos : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_prot : out std_logic_vector(2 downto 0);
        io_dBus_r_valid : in std_logic;
        io_dBus_r_ready : out std_logic;
        io_dBus_r_payload_data : in std_logic_vector(31 downto 0);
        io_dBus_r_payload_id : in unsigned(0 downto 0);
        io_dBus_r_payload_resp : in std_logic_vector(1 downto 0);
        io_dBus_r_payload_last : in std_logic
    );
end component;

component VexRiscvForSim is
    port(
        io_asyncReset : in std_logic;
        io_mainClk : in std_logic;
        io_iBus_ar_valid : out std_logic;
        io_iBus_ar_ready : in std_logic;
        io_iBus_ar_payload_addr : out unsigned(31 downto 0);
        io_iBus_ar_payload_id : out unsigned(0 downto 0);
        io_iBus_ar_payload_region : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_len : out unsigned(7 downto 0);
        io_iBus_ar_payload_size : out unsigned(2 downto 0);
        io_iBus_ar_payload_burst : out std_logic_vector(1 downto 0);
        io_iBus_ar_payload_lock : out std_logic_vector(0 downto 0);
        io_iBus_ar_payload_cache : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_qos : out std_logic_vector(3 downto 0);
        io_iBus_ar_payload_prot : out std_logic_vector(2 downto 0);
        io_iBus_r_valid : in std_logic;
        io_iBus_r_ready : out std_logic;
        io_iBus_r_payload_data : in std_logic_vector(31 downto 0);
        io_iBus_r_payload_id : in unsigned(0 downto 0);
        io_iBus_r_payload_resp : in std_logic_vector(1 downto 0);
        io_iBus_r_payload_last : in std_logic;
        io_dBus_aw_valid : out std_logic;
        io_dBus_aw_ready : in std_logic;
        io_dBus_aw_payload_addr : out unsigned(31 downto 0);
        io_dBus_aw_payload_id : out unsigned(0 downto 0);
        io_dBus_aw_payload_region : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_len : out unsigned(7 downto 0);
        io_dBus_aw_payload_size : out unsigned(2 downto 0);
        io_dBus_aw_payload_burst : out std_logic_vector(1 downto 0);
        io_dBus_aw_payload_lock : out std_logic_vector(0 downto 0);
        io_dBus_aw_payload_cache : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_qos : out std_logic_vector(3 downto 0);
        io_dBus_aw_payload_prot : out std_logic_vector(2 downto 0);
        io_dBus_w_valid : out std_logic;
        io_dBus_w_ready : in std_logic;
        io_dBus_w_payload_data : out std_logic_vector(31 downto 0);
        io_dBus_w_payload_strb : out std_logic_vector(3 downto 0);
        io_dBus_w_payload_last : out std_logic;
        io_dBus_b_valid : in std_logic;
        io_dBus_b_ready : out std_logic;
        io_dBus_b_payload_id : in unsigned(0 downto 0);
        io_dBus_b_payload_resp : in std_logic_vector(1 downto 0);
        io_dBus_ar_valid : out std_logic;
        io_dBus_ar_ready : in std_logic;
        io_dBus_ar_payload_addr : out unsigned(31 downto 0);
        io_dBus_ar_payload_id : out unsigned(0 downto 0);
        io_dBus_ar_payload_region : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_len : out unsigned(7 downto 0);
        io_dBus_ar_payload_size : out unsigned(2 downto 0);
        io_dBus_ar_payload_burst : out std_logic_vector(1 downto 0);
        io_dBus_ar_payload_lock : out std_logic_vector(0 downto 0);
        io_dBus_ar_payload_cache : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_qos : out std_logic_vector(3 downto 0);
        io_dBus_ar_payload_prot : out std_logic_vector(2 downto 0);
        io_dBus_r_valid : in std_logic;
        io_dBus_r_ready : out std_logic;
        io_dBus_r_payload_data : in std_logic_vector(31 downto 0);
        io_dBus_r_payload_id : in unsigned(0 downto 0);
        io_dBus_r_payload_resp : in std_logic_vector(1 downto 0);
        io_dBus_r_payload_last : in std_logic
    );
end component;

-------------------------------------------------------------------
-- Peripherals
-------------------------------------------------------------------

 component gpio is
    PORT (
       signal clock_in              : IN STD_LOGIC;
       signal reset_in              : IN STD_LOGIC;

       signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
       signal apb_penable           : IN STD_LOGIC;
       signal apb_pready            : OUT STD_LOGIC;
       signal apb_pwrite            : IN STD_LOGIC;
       signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
       signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
       signal apb_pslverror         : OUT STD_LOGIC;

       signal led_out               : out std_Logic_vector(3 downto 0);
       signal button_in             : in std_logic_vector(3 downto 0)       
    );
end component;

component UART is
	generic (
		BAUD_RATE : positive
	);
	Port ( 
		signal clock_in          : in std_logic;
		signal reset_in          : in std_logic;
		signal uart_rx_in        : in std_logic;
		signal uart_tx_out       : out std_logic;

		signal apb_paddr         : IN STD_LOGIC_VECTOR(19 downto 0);
		signal apb_penable       : IN STD_LOGIC;
		signal apb_pready        : OUT STD_LOGIC;
		signal apb_pwrite        : IN STD_LOGIC;
		signal apb_pwdata        : IN STD_LOGIC_VECTOR(31 downto 0);
		signal apb_prdata        : OUT STD_LOGIC_VECTOR(31 downto 0);
		signal apb_pslverror     : OUT STD_LOGIC
	);
end component;

component TIME is
    PORT (
       signal clock_in              : IN STD_LOGIC;
       signal reset_in              : IN STD_LOGIC;

       signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
       signal apb_penable           : IN STD_LOGIC;
       signal apb_pready            : OUT STD_LOGIC;
       signal apb_pwrite            : IN STD_LOGIC;
       signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
       signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
       signal apb_pslverror         : OUT STD_LOGIC     
    );
 end component;

--------------------------------------------------------------------
-- Platform porting layers
---------------------------------------------------------------------

COMPONENT DPRAM IS
   GENERIC(
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT(
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        clock     : IN STD_LOGIC;
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT DPRAM_DUAL_CLOCK IS
   GENERIC(
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT(
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        clock_a   : IN STD_LOGIC;
        clock_b   : IN STD_LOGIC;
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT DPRAM_BE IS
   GENERIC(
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT(
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        byteena_a : IN STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
        clock0    : IN STD_LOGIC ;
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;


COMPONENT SPRAM IS
   GENERIC (
       numwords_a                      : NATURAL;
       widthad_a                       : NATURAL;
       width_a                         : NATURAL
    );
    PORT (
       address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
       clock0      : IN STD_LOGIC ;
       data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
       wren_a      : IN STD_LOGIC ;
       q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT SPRAM_BE IS
   GENERIC (
       numwords_a                      : NATURAL;
       widthad_a                       : NATURAL;
       width_a                         : NATURAL
    );
    PORT (
       address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
       byteena_a   : IN STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
       clock0      : IN STD_LOGIC ;
       data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
       wren_a      : IN STD_LOGIC ;
       q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
    );
END COMPONENT;

COMPONENT CCD_SYNC
   generic 
   (
      WIDTH  : natural
   );
   port 
   (
      SIGNAL reset_in    : in std_logic;
      SIGNAL inclock_in  : in std_logic;
      SIGNAL outclock_in : in std_logic;
      SIGNAL input_in    : in std_logic_vector(WIDTH-1 downto 0);
      SIGNAL output_out  : out std_logic_vector(WIDTH-1 downto 0)
   );
end component;

--- For simulation ---

component mem64 is
   port(   
      SDRAM_clk       :IN STD_LOGIC;
      SDRAM_reset     :IN STD_LOGIC;
      SDRAM_araddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      SDRAM_arburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_arlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      SDRAM_arready   :OUT STD_LOGIC;
      SDRAM_arsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      SDRAM_arvalid   :IN STD_LOGIC;
      SDRAM_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      SDRAM_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      SDRAM_awready   :OUT STD_LOGIC;
      SDRAM_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      SDRAM_awvalid   :IN STD_LOGIC;
      SDRAM_bready    :IN STD_LOGIC;
      SDRAM_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_bvalid    :OUT STD_LOGIC;
      SDRAM_rdata     :OUT STD_LOGIC_VECTOR(63 downto 0);
      SDRAM_rlast     :OUT STD_LOGIC;
      SDRAM_rready    :IN STD_LOGIC;
      SDRAM_rresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_rvalid    :OUT STD_LOGIC;
      SDRAM_wdata     :IN STD_LOGIC_VECTOR(63 downto 0);
      SDRAM_wlast     :IN STD_LOGIC;
      SDRAM_wready    :OUT STD_LOGIC;
      SDRAM_wstrb     :IN STD_LOGIC_VECTOR(7 downto 0);
      SDRAM_wvalid    :IN STD_LOGIC
   );
end component;

component mem32 is
   port(   
      SDRAM_clk       :IN STD_LOGIC;
      SDRAM_reset     :IN STD_LOGIC;
      SDRAM_araddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      SDRAM_arburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_arlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      SDRAM_arready   :OUT STD_LOGIC;
      SDRAM_arsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      SDRAM_arvalid   :IN STD_LOGIC;
      SDRAM_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      SDRAM_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      SDRAM_awready   :OUT STD_LOGIC;
      SDRAM_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      SDRAM_awvalid   :IN STD_LOGIC;
      SDRAM_bready    :IN STD_LOGIC;
      SDRAM_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_bvalid    :OUT STD_LOGIC;
      SDRAM_rdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
      SDRAM_rlast     :OUT STD_LOGIC;
      SDRAM_rready    :IN STD_LOGIC;
      SDRAM_rresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      SDRAM_rvalid    :OUT STD_LOGIC;
      SDRAM_wdata     :IN STD_LOGIC_VECTOR(31 downto 0);
      SDRAM_wlast     :IN STD_LOGIC;
      SDRAM_wready    :OUT STD_LOGIC;
      SDRAM_wstrb     :IN STD_LOGIC_VECTOR(3 downto 0);
      SDRAM_wvalid    :IN STD_LOGIC
   );
end component;

END;

