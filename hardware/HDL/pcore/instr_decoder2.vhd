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
-- Implement PCORE decoder stage
-- PCORE instruction has a VLIW format.
-- Each Instruction is composed of
--    MU operations: Vector perations for ALU
--    IMU operation: Scalar operations for scalar ALU unit
--    CONTROL: jump instruction based on condition after IMU operation 
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;

ENTITY instr_decoder2 IS
    GENERIC(
        CID : integer;
        PID : integer
    );
    PORT(
        -- Global signal
        SIGNAL clock_in                         : IN STD_LOGIC;
        SIGNAL reset_in                         : IN STD_LOGIC;    
        
        -- Signal received from previous stage
        SIGNAL instruction_mu_in                : IN STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0); -- instruction to dispatch
        SIGNAL instruction_imu_in               : IN STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0); -- instruction to dispatch
        SIGNAL instruction_mu_valid_in          : IN STD_LOGIC;
        SIGNAL instruction_imu_valid_in         : IN STD_LOGIC;
        SIGNAL instruction_tid_in               : IN tid_t;
        SIGNAL instruction_tid_valid_in         : IN STD_LOGIC;
        SIGNAL instruction_vm_in                : IN STD_LOGIC;
        SIGNAL instruction_data_model_in        : IN dp_data_model_t;
        SIGNAL instruction_pre_pre_vm_in        : IN STD_LOGIC;
        SIGNAL instruction_pre_pre_data_model_in: IN dp_data_model_t;
        SIGNAL instruction_pre_tid_in           : IN tid_t;
        SIGNAL instruction_pre_tid_valid_in     : IN STD_LOGIC;
        SIGNAL instruction_pre_pre_tid_in       : IN tid_t;
        SIGNAL instruction_pre_pre_tid_valid_in : IN STD_LOGIC;
        SIGNAL instruction_pre_iregister_auto_in: IN iregister_auto_t;

        -- Signal send to next stage
        SIGNAL opcode1_out                      : OUT STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
        SIGNAL en1_out                          : OUT STD_LOGIC;
  
        SIGNAL instruction_tid_out              : OUT tid_t;

        -- Flag
        SIGNAL xreg1_out                        : OUT STD_LOGIC;
        SIGNAL flag1_out                        : OUT STD_LOGIC;
        SIGNAL wren_out                         : OUT STD_LOGIC;

        SIGNAL vm_out                           : OUT STD_LOGIC;

        -- X,Y,Z parameters
        SIGNAL x1_addr1_out                     : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL x2_addr1_out                     : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL y_addr1_out                      : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        
        -- Vector mode
        SIGNAL x1_vector_out                    : OUT STD_LOGIC;
        SIGNAL x2_vector_out                    : OUT STD_LOGIC;
        SIGNAL y_vector_out                     : OUT STD_LOGIC;
        SIGNAL vector_lane_out                  : OUT STD_LOGIC_VECTOR(vector_width_c-1 downto 0);

        -- Constant parameters

        SIGNAL x1_c1_en_out                     : OUT STD_LOGIC;
        SIGNAL x1_c1_out                        : OUT STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);

        -- IREGISTER
        SIGNAL i_rd_en_out                      : OUT STD_LOGIC;
        SIGNAL i_rd_vm_out                      : OUT STD_LOGIC;
        SIGNAL i_rd_tid_out                     : OUT tid_t;
        SIGNAL i_rd_data_in                     : IN iregisters_t(iregister_max_c-1 downto 0);
        SIGNAL i_wr_tid_out                     : OUT tid_t;
        SIGNAL i_wr_en_out                      : OUT STD_LOGIC;
        SIGNAL i_wr_vm_out                      : OUT STD_LOGIC;
        SIGNAL i_wr_addr_out                    : OUT iregister_addr_t;
        SIGNAL i_wr_data_out                    : OUT iregister_t;

        -- LANE
        SIGNAL lane_in                          : IN iregister_t;
        SIGNAL wr_lane_out                      : OUT STD_LOGIC;

        -- IALU
        SIGNAL i_opcode_out                     : OUT STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
        SIGNAL i_x1_out                         : OUT iregister_t;
        SIGNAL i_x2_out                         : OUT iregister_t;
        SIGNAL i_y_in                           : IN iregister_t;

        -- RESULT
        SIGNAL result_waddr_out                 : OUT STD_LOGIC_VECTOR(xreg_depth_c-1 downto 0);
        SIGNAL result_raddr_out                 : OUT STD_LOGIC_VECTOR(xreg_depth_c-1 downto 0);
        SIGNAL result_vm_out                    : OUT STD_LOGIC;
        SIGNAL result_in                        : IN iregister_t
    );
END instr_decoder2;

ARCHITECTURE behavior OF instr_decoder2 IS

-------
--- Instruction decoding 
-------

SIGNAL instruction_tid_r: tid_t;
SIGNAL instruction_tid_rr:tid_t;
SIGNAL instruction_tid_rrr:tid_t;
SIGNAL instruction_tid_rrrr:tid_t;
SIGNAL instruction_tid_rrrrr:tid_t;
SIGNAL instruction_tid_rrrrrr:tid_t;
SIGNAL instruction_tid_rrrrrrr:tid_t;
SIGNAL got_imu:STD_LOGIC;
SIGNAL got_imu_r:STD_LOGIC;
SIGNAL got_imu_rr:STD_LOGIC;
SIGNAL lane_r:iregister_t;
SIGNAL lane_rr:iregister_t;
SIGNAL imu_lane_valid_r:STD_LOGIC;
SIGNAL imu_lane_valid_rr:STD_LOGIC;
SIGNAL imu_lane_valid_rrr:STD_LOGIC;
SIGNAL imu_lane_valid_rrrr:STD_LOGIC;
SIGNAL imu_lane_valid_rrrrr:STD_LOGIC;

--------
--- MU variables
--------

SIGNAL mu_opcode1: STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL mu_en1_r:STD_LOGIC;
SIGNAL mu_vm_r:STD_LOGIC;
SIGNAL mu_xreg1:STD_LOGIC;
SIGNAL mu_xreg1_r:STD_LOGIC;
SIGNAL mu_flag1:STD_LOGIC;
SIGNAL mu_flag1_r:STD_LOGIC;
SIGNAL mu_wren:STD_LOGIC;
SIGNAL mu_wren_r:STD_LOGIC;
SIGNAL mu_x1_c1_en:STD_LOGIC;
SIGNAL mu_x1_c1_en_r:STD_LOGIC;
SIGNAL mu_x1_c1_r:STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);
SIGNAL mu_x1_parm1:STD_LOGIC_VECTOR(mu_instruction_x1_width_c-1 DOWNTO 0);
SIGNAL mu_x2_parm1:STD_LOGIC_VECTOR(mu_instruction_x2_width_c-1 DOWNTO 0);
SIGNAL mu_x3_parm1:STD_LOGIC_VECTOR(mu_instruction_x2_width_c-1 DOWNTO 0);
SIGNAL mu_y_parm1:STD_LOGIC_VECTOR(mu_instruction_x1_width_c-1 DOWNTO 0);
SIGNAL mu_x1_attr1:register_attr_t;
SIGNAL mu_x2_attr1:register_attr_t;
SIGNAL mu_x3_attr1:register_attr_t;
SIGNAL mu_y_attr1:register_attr_t;
SIGNAL mu_x1_vector:STD_LOGIC;
SIGNAL mu_x2_vector:STD_LOGIC;
SIGNAL mu_x3_vector:STD_LOGIC;
SIGNAL mu_y_vector:STD_LOGIC;
SIGNAL mu_x1_vector_r:STD_LOGIC;
SIGNAL mu_x2_vector_r:STD_LOGIC;
SIGNAL mu_y_vector_r:STD_LOGIC;

SIGNAL mu_opcode1_r:STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL mu_x1_addr1_r:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL mu_x2_addr1_r:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL mu_y_addr1_r:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL mu_x1_addr1:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL mu_x2_addr1:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL mu_x3_addr1:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL mu_y_addr1:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);

SIGNAL vm_r:STD_LOGIC;
SIGNAL vm_rr:STD_LOGIC;
SIGNAL vm_rrr:STD_LOGIC;
SIGNAL vm_rrrr:STD_LOGIC;
SIGNAL vm_rrrrr:STD_LOGIC;
SIGNAL vm_rrrrrr:STD_LOGIC;
SIGNAL vm_rrrrrrr:STD_LOGIC;

----------
---- IMU variables 
----------

SIGNAL imu_opcode:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL imu_x1_parm:STD_LOGIC_VECTOR(imu_instruction_x1_width_c-1 DOWNTO 0);
SIGNAL imu_x2_parm:STD_LOGIC_VECTOR(imu_instruction_x2_width_c-1 DOWNTO 0);
SIGNAL imu_y_parm:STD_LOGIC_VECTOR(imu_instruction_y_width_c-1 DOWNTO 0);
SIGNAL imu_const:iregister_t;
SIGNAL imu_opcode_r:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL imu_x1_parm_r:STD_LOGIC_VECTOR(imu_instruction_x1_width_c-1 DOWNTO 0);
SIGNAL imu_x2_parm_r:STD_LOGIC_VECTOR(imu_instruction_x2_width_c-1 DOWNTO 0);
SIGNAL imu_y_parm_r:STD_LOGIC_VECTOR(imu_instruction_y_width_c-1 DOWNTO 0);
SIGNAL imu_const_r:iregister_t;
SIGNAL imu_opcode_rr:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL imu_x1_parm_rr:STD_LOGIC_VECTOR(imu_instruction_x1_width_c-1 DOWNTO 0);
SIGNAL imu_x2_parm_rr:STD_LOGIC_VECTOR(imu_instruction_x2_width_c-1 DOWNTO 0);
SIGNAL imu_y_parm_rr:STD_LOGIC_VECTOR(imu_instruction_y_width_c-1 DOWNTO 0);
SIGNAL imu_const_rr:iregister_t;
SIGNAL imu_x1_r:iregister_t;
SIGNAL imu_x2_r:iregister_t;
SIGNAL imu_y_r:unsigned(iregister_addr_t'length-1 downto 0);
SIGNAL imu_y_rr:unsigned(iregister_addr_t'length-1 downto 0);
SIGNAL imu_y_rrr:unsigned(iregister_addr_t'length-1 downto 0);
SIGNAL imu_y_rrrr:unsigned(iregister_addr_t'length-1 downto 0);
SIGNAL imu_y_rrrrr:unsigned(iregister_addr_t'length-1 downto 0);
SIGNAL imu_y_valid_r:STD_LOGIC;
SIGNAL imu_y_valid_rr:STD_LOGIC;
SIGNAL imu_y_valid_rrr:STD_LOGIC;
SIGNAL imu_y_valid_rrrr:STD_LOGIC;
SIGNAL imu_y_valid_rrrrr:STD_LOGIC;
SIGNAL imu_oc_r:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);

--------
-- IREGISTER variables
--------

SIGNAL iregisters_r:iregisters_t(iregister_max_c-1 downto 0);
SIGNAL iregisters_lo:iregisters_t(iregister_max_c/2-1 downto 0);
SIGNAL iregisters_hi:iregisters_t(iregister_max_c/2-1 downto 0);

SIGNAL imu_x1_ireg_r:iregister_t;
SIGNAL imu_x2_ireg_r:iregister_t;
SIGNAL imu_x1_ireg_rr:iregister_t;
SIGNAL imu_x2_ireg_rr:iregister_t;

SIGNAL mu_x1_i0_1:iregister_t;
SIGNAL mu_x2_i0_1:iregister_t;
SIGNAL mu_x3_i0_1:iregister_t;
SIGNAL mu_x1_i1_1:iregister_t;
SIGNAL mu_x2_i1_1:iregister_t;
SIGNAL mu_x3_i1_1:iregister_t;
SIGNAL mu_x1_i2_1:iregister_t;
SIGNAL mu_x2_i2_1:iregister_t;
SIGNAL mu_x1_i2:iregister_t;

SIGNAL mu_y_i0_1:iregister_t;
SIGNAL mu_y_i1_1:iregister_t;


SIGNAL mu_lane_r:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL mu_lane_rr:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL mu_lane_rrr:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL mu_lane_rrrr:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL mu_lane_rrrrr:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL mu_lane_rrrrrr:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);


SIGNAL result_raddr_r:STD_LOGIC_VECTOR(xreg_depth_c-1 downto 0);
SIGNAL result_waddr_r:STD_LOGIC_VECTOR(xreg_depth_c-1 downto 0);
SIGNAL xreg_waddr_r:STD_LOGIC_VECTOR(xreg_depth_c-1 downto 0);

attribute dont_merge : boolean;
attribute dont_merge of imu_oc_r : SIGNAL is true;
attribute dont_merge of imu_x1_r : SIGNAL is true;
attribute dont_merge of imu_x2_r : SIGNAL is true;
attribute dont_merge of xreg_waddr_r : SIGNAL is true;
attribute dont_merge of iregisters_r : SIGNAL is true;

attribute preserve : boolean;
attribute preserve of imu_oc_r : SIGNAL is true;
attribute preserve of imu_x1_r : SIGNAL is true;
attribute preserve of imu_x2_r : SIGNAL is true;
attribute preserve of xreg_waddr_r : SIGNAL is true;
attribute preserve of iregisters_r : SIGNAL is true;

------------ 
-- Process MU parameter attribute
-- MU parameter attributes generate register-file address for each MU parameters
-- Below are different memory access mode
--    11xx  Pointer with index
--    1011  Pointer no index
--    1000  Shared no index
--    1001  Private no index
--    1010  Constant
--    00xx  Share with index
--    01xx  Private with index
--------------

subtype encode_retval_t is std_logic_vector(register_file_depth_c-1 downto 0);
function encode_mu_parm(
        attr_in:register_attr_t;
        parm_in:std_logic_vector(mu_instruction_x1_width_c-1 downto 0);
        tid_in:tid_t;
        i0_in:iregister_t;
        i1_in:iregister_t;
        vector_in:std_logic;
        data_model_in:dp_data_model_t) 
        return encode_retval_t is
variable addr_v:encode_retval_t;
variable offset_v:unsigned(iregister_width_c-1 downto 0);
variable sum_v:unsigned(iregister_width_c-1 downto 0);
variable temp_v:unsigned(iregister_width_c-1 downto 0);
variable i1_v:unsigned(iregister_width_c-1 downto 0);
variable ireg_addr_v:unsigned(iregister_width_c-1 downto 0);
begin

if attr_in(3 downto 2)="11" or attr_in="1011" then
   -- Pointer with or without index. Parameter field is composed of offset and pointer
   offset_v(2 downto 0) := unsigned(parm_in(2 downto 0));
   offset_v(iregister_width_c-1 downto 3) := (others=>'0');
else
   -- Not a pointer. So offset takes the whole parameter field
   if attr_in="1001" or attr_in(3 downto 2)="01" or attr_in="1010" then
      offset_v(parm_in'length-1 downto 0) := unsigned(parm_in);
   else
      offset_v(parm_in'length-1 downto 0) := unsigned(parm_in);
   end if;
   offset_v(iregister_width_c-1 downto parm_in'length) := (others=>'0');
end if;

if vector_in='1' then
   i1_v(i1_in'length-1 downto 3) := i1_in(i1_in'length-4 downto 0);
   i1_v(2) := '0';
   i1_v(1) := '0';
   i1_v(0) := '0'; 
else
   i1_v := i1_in;
end if;

sum_v := i0_in+offset_v;
if vector_in = '1' then
   sum_v(sum_v'length-1 downto 3) := sum_v(sum_v'length-4 downto 0);
   sum_v(2) := '0';
   sum_v(1) := '0';
   sum_v(0) := '0';
end if;

if attr_in="1000" or attr_in(3 downto 2)="00" then
   -- Shared variable access with or without index
   addr_v(register_file_depth_c-1 downto 0) := std_logic_vector(sum_v(register_file_depth_c-1 downto 0));
   addr_v(register_file_depth_c-1 downto vector_depth_c) := (not addr_v(register_file_depth_c-1 downto vector_depth_c));
elsif attr_in="1001" or attr_in(3 downto 2)="01" or attr_in="1010" then
   -- Private with or without index or constant
   if data_model_in="00" then
      addr_v(register_file_depth_c-1 downto vector_depth_c) := std_logic_vector(sum_v(register_depth_c-1 downto vector_depth_c)) & std_logic_vector(tid_in(tid_in'length-1 downto 0));
   else
      addr_v(register_file_depth_c-1 downto vector_depth_c) := "0" & std_logic_vector(sum_v(register_depth_c-1 downto vector_depth_c)) & std_logic_vector(tid_in(tid_in'length-2 downto 0));
   end if;
   addr_v(vector_depth_c-1 downto 0) := std_logic_vector(sum_v(vector_depth_c-1 downto 0));
else
   -- The remain must be pointer access
   ireg_addr_v := i1_v+sum_v;      
   if i1_in(iregister_width_c-1)='1' then
      -- Pointer to shared memory space
      addr_v(register_file_depth_c-1 downto 0) := std_logic_vector(ireg_addr_v(register_file_depth_c-1 downto 0));
      addr_v(register_file_depth_c-1 downto vector_depth_c) := (not addr_v(register_file_depth_c-1 downto vector_depth_c));
   else
      if data_model_in="00" then
         addr_v(register_file_depth_c-1 downto vector_depth_c) := std_logic_vector(ireg_addr_v(register_depth_c-1 downto vector_depth_c)) & std_logic_vector(tid_in(tid_in'length-1 downto 0));
      else
         addr_v(register_file_depth_c-1 downto vector_depth_c) := "0" & std_logic_vector(ireg_addr_v(register_depth_c-1 downto vector_depth_c)) & std_logic_vector(tid_in(tid_in'length-2 downto 0));
      end if;
      addr_v(vector_depth_c-1 downto 0) := std_logic_vector(ireg_addr_v(vector_depth_c-1 downto 0));
   end if;
end if;
return addr_v;
end function encode_mu_parm;

--------------
--- Decode of IALU parameter values
--------------

subtype encode_imu_parm_retval_t is iregister_t;
function encode_imu_parm(
        parm_in:STD_LOGIC_VECTOR(imu_instruction_x1_width_c-1 DOWNTO 0);
        c_in:iregister_t;
        tid_in:tid_t;
        ireg_in:IN iregister_t;
        lane_in:IN iregister_t;
        result_in:IN iregister_t)
        return encode_imu_parm_retval_t is
variable c_v:iregister_t;
begin
case parm_in is
    when imu_instruction_parm_zero_c => -- Zero value
        c_v := (others=>'0');
    when imu_instruction_parm_const_c => -- Constant from IMU instruction constant field
        c_v := c_in; 
    when imu_instruction_parm_tid_c => -- Thread id
        c_v(tid_t'length-1 downto 0) := tid_in(tid_t'length-1 downto 0);
        c_v(iregister_width_c-1 downto tid_t'length) := (others=>'0');
    when imu_instruction_parm_pid_c => -- PID id
        c_v := to_unsigned(CID*pid_max_c+PID,iregister_width_c);
    when imu_instruction_parm_result1_c => -- RESULT register value
        c_v(iregister_t'length-1 downto 0) := unsigned(result_in);
    when imu_instruction_parm_lane_c => -- LANE register value
        c_v := lane_in;
    when others=> 
        c_v := ireg_in; -- value from scalar register bank
end case;
return c_v;
end function encode_imu_parm;

BEGIN

i_rd_en_out <= instruction_pre_pre_tid_valid_in;
i_rd_vm_out <= instruction_pre_pre_vm_in;
i_rd_tid_out <= instruction_pre_pre_tid_in;
i_wr_tid_out <= instruction_tid_rrrrrr;
i_wr_en_out <= imu_y_valid_rrrr;
i_wr_vm_out <= vm_rrrrrr;
i_wr_addr_out <= imu_y_rrrr;
i_wr_data_out <= i_y_in;
-- IALU
i_opcode_out <= imu_oc_r;
i_x1_out <= imu_x1_r;
i_x2_out <= imu_x2_r;
-- LANE control
wr_lane_out <= imu_lane_valid_rrrr;

result_waddr_out <= xreg_waddr_r when mu_xreg1_r='1' else result_waddr_r;
result_raddr_out <= result_raddr_r;
result_vm_out <= vm_r;

mu_xreg1 <= instruction_mu_in(mu_instruction_type_save_c);

-----------------
-- Decode MU instruction
-----------------

mu_opcode1 <= instruction_mu_in(mu_instruction_oc_hi_c DOWNTO mu_instruction_oc_lo_c) when (instruction_mu_valid_in='1') else opcode_null_c;
mu_x1_parm1 <= instruction_mu_in(mu_instruction_x1_hi_c DOWNTO mu_instruction_x1_lo_c);
mu_x2_parm1 <= instruction_mu_in(mu_instruction_x2_hi_c DOWNTO mu_instruction_x2_lo_c);
mu_x3_parm1 <= instruction_mu_in(mu_instruction_x3_hi_c DOWNTO mu_instruction_x3_lo_c);
mu_y_parm1 <= instruction_mu_in(mu_instruction_y_hi_c DOWNTO mu_instruction_y_lo_c);
mu_x1_attr1 <= instruction_mu_in(mu_instruction_x1_attr_hi_c DOWNTO mu_instruction_x1_attr_lo_c);
mu_x2_attr1 <= instruction_mu_in(mu_instruction_x2_attr_hi_c DOWNTO mu_instruction_x2_attr_lo_c);
mu_x3_attr1 <= instruction_mu_in(mu_instruction_x3_attr_hi_c DOWNTO mu_instruction_x3_attr_lo_c);
mu_y_attr1 <= instruction_mu_in(mu_instruction_y_attr_hi_c DOWNTO mu_instruction_y_attr_lo_c);
mu_x1_vector <= instruction_mu_in(mu_instruction_x1_vector_c);
mu_x2_vector <= instruction_mu_in(mu_instruction_x2_vector_c);
mu_x3_vector <= instruction_mu_in(mu_instruction_x3_vector_c);
mu_y_vector <= instruction_mu_in(mu_instruction_y_vector_c);
mu_flag1 <= '1' when (instruction_mu_valid_in='1' and mu_y_attr1="1010" and mu_y_parm1(register_attr_const_result_c)='1') else '0';
mu_wren <= '0' when (mu_y_attr1="1010" and mu_y_parm1(register_attr_const_null_c)='1') or (mu_xreg1='1') else '1';

-- Constant is either constant field from X1 or integer value

mu_x1_c1_en <= '1' when (mu_x1_attr1="1010") else '0';

---------
-- Retrieve integer values used by MU parameter address generation
----------

-- iregister_lo contains integer 
iregisters_lo <= iregisters_r(iregister_max_c/2-1 downto 0);

-- iregister_hi contains pointers
iregisters_hi <= iregisters_r(iregister_max_c-1 downto iregister_max_c/2);

mu_x1_i0_1 <= iregisters_lo(to_integer(unsigned(mu_x1_attr1(1 downto 0)))) when mu_x1_attr1(2)='1' or mu_x1_attr1(3)='0' else (others=>'0'); 
mu_x2_i0_1 <= iregisters_lo(to_integer(unsigned(mu_x2_attr1(1 downto 0)))) when mu_x2_attr1(2)='1' or mu_x2_attr1(3)='0' else (others=>'0'); 
mu_x3_i0_1 <= iregisters_lo(to_integer(unsigned(mu_x3_attr1(1 downto 0)))) when mu_x3_attr1(2)='1' or mu_x3_attr1(3)='0' else (others=>'0'); 

mu_x1_i1_1 <= iregisters_hi(to_integer(unsigned(mu_x1_parm1(4 downto 3))));
mu_x2_i1_1 <= iregisters_hi(to_integer(unsigned(mu_x2_parm1(4 downto 3))));
mu_x3_i1_1 <= (others=>'0');

mu_x1_i2_1 <= iregisters_lo(to_integer(unsigned(mu_x1_parm1(4 downto 3))));
mu_x2_i2_1 <= iregisters_lo(to_integer(unsigned(mu_x2_parm1(4 downto 3))));

mu_y_i0_1 <= iregisters_lo(to_integer(unsigned(mu_y_attr1(1 downto 0)))) when mu_y_attr1(2)='1' or mu_y_attr1(3)='0' else (others=>'0'); 
mu_y_i1_1 <= iregisters_hi(to_integer(unsigned(mu_y_parm1(4 downto 3))));

mu_x1_i2 <= mu_x1_i2_1 when mu_x1_parm1(5)='0' else mu_x1_i1_1;


-- OUTPUT instruction 1
opcode1_out <= mu_opcode1_r;
x1_addr1_out <= mu_x1_addr1_r;
x2_addr1_out <= mu_x2_addr1_r;
y_addr1_out <= mu_y_addr1_r;

x1_vector_out <= mu_x1_vector_r;
x2_vector_out <= mu_x2_vector_r;
y_vector_out <= mu_y_vector_r;
vector_lane_out <= mu_lane_rrrrrr when imu_lane_valid_rrrr='0' else std_logic_vector(i_y_in(vector_lane_out'length-1 downto 0));

en1_out <= mu_en1_r;
vm_out <= mu_vm_r;

flag1_out <= mu_flag1_r;
xreg1_out <= mu_xreg1_r;
wren_out <= mu_wren_r;

x1_c1_en_out <= mu_x1_c1_en_r;
x1_c1_out <= mu_x1_c1_r;

instruction_tid_out <= instruction_tid_r;

process(clock_in,reset_in)
begin
if reset_in='0' then
    instruction_tid_r <= (others=>'0');
    instruction_tid_rr <= (others=>'0');
    instruction_tid_rrr <= (others=>'0');
    instruction_tid_rrrr <= (others=>'0');
    instruction_tid_rrrrr <= (others=>'0');
    instruction_tid_rrrrrr <= (others=>'0');
    instruction_tid_rrrrrrr <= (others=>'0');
    iregisters_r <= (others=>(others=>'0'));
    lane_r <= (others=>'0');
    lane_rr <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        instruction_tid_r <= instruction_tid_in;
        instruction_tid_rr <= instruction_tid_r;
        instruction_tid_rrr <= instruction_tid_rr;
        instruction_tid_rrrr <= instruction_tid_rrr;
        instruction_tid_rrrrr <= instruction_tid_rrrr;
        instruction_tid_rrrrrr <= instruction_tid_rrrrr;
        instruction_tid_rrrrrrr <= instruction_tid_rrrrrr;
        -- Save global integer register values
        -- Global integers are passed to PCOREs at beginning of PCORE execution time.
        iregisters_r(iregister_max_c-1 downto iregister_max_c/2) <= i_rd_data_in(iregister_max_c-1 downto iregister_max_c/2);
        iregisters_r(iregister_max_c/2-max_iregister_auto_c-1 downto 0) <= i_rd_data_in(iregister_max_c/2-max_iregister_auto_c-1 downto 0);
        for I in 0 to max_iregister_auto_c-1 loop
           if instruction_pre_iregister_auto_in(iregister_auto_t'length-max_iregister_auto_c+I)='0' then
              iregisters_r(iregister_max_c/2-I-1) <= i_rd_data_in(iregister_max_c/2-I-1);
           else
              iregisters_r(iregister_max_c/2-I-1) <= instruction_pre_iregister_auto_in((I+1)*iregister_width_c-1 downto I*iregister_width_c);
           end if;
        end loop;
        lane_r <= lane_in;
        lane_rr <= lane_r;
    end if;
end if;
end process;

----------------
-- Decoding integer arithmetic unit (IMU)
-- IMU instruction performs integer arithmetic.
---------------

got_imu <= instruction_imu_valid_in;


imu_opcode <= instruction_imu_in(imu_instruction_oc_hi_c DOWNTO imu_instruction_oc_lo_c);
imu_x1_parm <= instruction_imu_in(imu_instruction_x1_hi_c DOWNTO imu_instruction_x1_lo_c);
imu_x2_parm <= instruction_imu_in(imu_instruction_x2_hi_c DOWNTO imu_instruction_x2_lo_c);
imu_y_parm <= instruction_imu_in(imu_instruction_y_hi_c DOWNTO imu_instruction_y_lo_c);
imu_const <= unsigned(instruction_imu_in(imu_instruction_const_hi_c DOWNTO imu_instruction_const_lo_c));

------------------
-- General format for IMU is Y=X1 OPCODE X2
-- Retrieve all parameters (X1,X2,Y) for IMU opcode
-- Where X1,X2 can be from integer register bank,constant,PID or TID
-----------------

process(clock_in,reset_in)    
variable index:integer;
begin
if reset_in='0' then
    imu_x1_r <= (others=>'0');
    imu_x2_r <= (others=>'0');
    imu_y_r <= (others=>'0');
    imu_y_rr <= (others=>'0');
    imu_y_rrr <= (others=>'0');
    imu_y_rrrr <= (others=>'0');
    imu_y_rrrrr <= (others=>'0');
    imu_y_valid_r <= '0';
    imu_y_valid_rr <= '0';
    imu_y_valid_rrr <= '0';
    imu_y_valid_rrrr <= '0';
    imu_y_valid_rrrrr <= '0';
    imu_oc_r <= (others=>'0');

    imu_opcode_r <= (others=>'0');
    imu_x1_parm_r <= (others=>'0');
    imu_x2_parm_r <= (others=>'0');
    imu_y_parm_r <= (others=>'0');
    imu_const_r <= (others=>'0');
    got_imu_r <= '0';

    imu_lane_valid_r <= '0';
    imu_lane_valid_rr <= '0';
    imu_lane_valid_rrr <= '0';
    imu_lane_valid_rrrr <= '0';
    imu_lane_valid_rrrrr <= '0';

    imu_opcode_rr <= (others=>'0');
    imu_x1_parm_rr <= (others=>'0');
    imu_x2_parm_rr <= (others=>'0');
    imu_y_parm_rr <= (others=>'0');
    imu_const_rr <= (others=>'0');
    imu_x1_ireg_r <= (others=>'0');
    imu_x2_ireg_r <= (others=>'0');
    imu_x1_ireg_rr <= (others=>'0');
    imu_x2_ireg_rr <= (others=>'0');
    got_imu_rr <= '0';
    vm_r <= '0';
    vm_rr <= '0';
    vm_rrr <= '0';
    vm_rrrr <= '0';
    vm_rrrrr <= '0';
    vm_rrrrrr <= '0';
    vm_rrrrrrr <= '0';
else
    if clock_in'event and clock_in='1' then
        -- Latch incoming IMU instructions to pipeline

        imu_opcode_r <= imu_opcode;
        imu_x1_parm_r <= imu_x1_parm;
        imu_x2_parm_r <= imu_x2_parm;
        imu_y_parm_r <= imu_y_parm;
        imu_const_r <= imu_const;
        got_imu_r <= got_imu;

        imu_x1_ireg_r <= iregisters_r(to_integer(unsigned(imu_x1_parm(iregister_depth_c-1 downto 0))));
        imu_x2_ireg_r <= iregisters_r(to_integer(unsigned(imu_x2_parm(iregister_depth_c-1 downto 0))));

        imu_opcode_rr <= imu_opcode_r;
        imu_x1_parm_rr <= imu_x1_parm_r;
        imu_x2_parm_rr <= imu_x2_parm_r;
        imu_y_parm_rr <= imu_y_parm_r;
        imu_x1_ireg_rr <= imu_x1_ireg_r; 
        imu_x2_ireg_rr <= imu_x2_ireg_r;
        imu_const_rr <= imu_const_r;
        got_imu_rr <= got_imu_r;

        vm_r <= instruction_vm_in;
        vm_rr <= vm_r;
        vm_rrr <= vm_rr;
        vm_rrrr <= vm_rrr;
        vm_rrrrr <= vm_rrrr;
        vm_rrrrrr <= vm_rrrrr;
        vm_rrrrrrr <= vm_rrrrrr;

        --- Process the IMU instruction
        if got_imu_rr='1' then
            -- Retrieve X1 parameter
            imu_x1_r <=  encode_imu_parm(imu_x1_parm_rr,imu_const_rr,instruction_tid_rr,imu_x1_ireg_rr,lane_rr,result_in);
            imu_x2_r <= encode_imu_parm(imu_x2_parm_rr,imu_const_rr,instruction_tid_rr,imu_x2_ireg_rr,lane_rr,result_in);
            -- Retrieve Y parameter. The value for Y is the register bank index where the result is stored
            if imu_opcode_rr /= std_logic_vector(to_unsigned(0,imu_opcode_rr'length)) then
                if unsigned(imu_y_parm_rr(imu_y_parm_rr'length-1 downto iregister_addr_t'length))=to_unsigned(0,imu_y_parm_rr'length-iregister_addr_t'length) then
                    imu_y_r <= unsigned(imu_y_parm_rr(iregister_addr_t'length-1 downto 0));
                    imu_y_valid_r <= '1';
                else
                    imu_y_r <= (others=>'0');
                    imu_y_valid_r <= '0';
                end if;
                if imu_y_parm_rr=imu_instruction_parm_lane_c then
                    imu_lane_valid_r <= '1';
                else
                    imu_lane_valid_r <= '0';
                end if;
            else
                imu_y_r <= (others=>'0');
                imu_y_valid_r <= '0';
                imu_lane_valid_r <= '0';
            end if;
            imu_oc_r <= imu_opcode_rr;
        else
            imu_x1_r <= (others=>'0');
            imu_x2_r <= (others=>'0');
            imu_y_r <= (others=>'0');
            imu_y_valid_r <= '0';
            imu_oc_r <= (others=>'0');
            imu_lane_valid_r <= '0';
        end if;

        -- Latch the IMU opcode. The actual execution of the opcode is next clock

        imu_lane_valid_rr <= imu_lane_valid_r;
        imu_lane_valid_rrr <= imu_lane_valid_rr;
        imu_lane_valid_rrrr <= imu_lane_valid_rrr;
        imu_lane_valid_rrrrr <= imu_lane_valid_rrrr;

        imu_y_valid_rr <= imu_y_valid_r;
        imu_y_valid_rrr <= imu_y_valid_rr;
        imu_y_valid_rrrr <= imu_y_valid_rrr;
        imu_y_valid_rrrrr <= imu_y_valid_rrrr;
        imu_y_rr <= imu_y_r;
        imu_y_rrr <= imu_y_rr;
        imu_y_rrrr <= imu_y_rrr;
        imu_y_rrrrr <= imu_y_rrrr;
    end if;
end if;
end process;

------------------
-- Calculate MU parameter address
-- Each MU instruction has 4 parameters
-- Y: Store return value. This can also be accumulator.
-- X1: X1 input parameter
-- X2: X2 input parameter
-- X3: Accumulator input
------------------

mu_x1_addr1 <= encode_mu_parm(mu_x1_attr1,mu_x1_parm1,instruction_tid_in,mu_x1_i0_1,mu_x1_i1_1,mu_x1_vector,instruction_data_model_in);
mu_x2_addr1 <= encode_mu_parm(mu_x2_attr1,mu_x2_parm1,instruction_tid_in,mu_x2_i0_1,mu_x2_i1_1,mu_x2_vector,instruction_data_model_in);
mu_x3_addr1 <= encode_mu_parm(mu_x3_attr1,mu_x3_parm1,instruction_tid_in,mu_x3_i0_1,mu_x3_i1_1,mu_x3_vector,instruction_data_model_in);
mu_y_addr1 <= encode_mu_parm(mu_y_attr1,mu_y_parm1,instruction_tid_in,mu_y_i0_1,mu_y_i1_1,mu_y_vector,instruction_data_model_in);


PROCESS(clock_in,reset_in)
BEGIN
    if reset_in = '0' then
        mu_opcode1_r <= (others=>'0');
        mu_x1_addr1_r <= (others=>'0');
        mu_x2_addr1_r <= (others=>'0');
        mu_y_addr1_r <= (others=>'0');
        mu_x1_vector_r <= '0';
        mu_x2_vector_r <= '0';
        mu_y_vector_r <= '0';
        mu_en1_r <= '0';
        mu_flag1_r <= '0';
        mu_xreg1_r <= '0';
        mu_lane_r <= (others=>'0');
        mu_lane_rr <= (others=>'0');
        mu_lane_rrr <= (others=>'0');
        mu_lane_rrrr <= (others=>'0');
        mu_lane_rrrrr <= (others=>'0');
        mu_lane_rrrrrr <= (others=>'0');
        mu_wren_r <= '0';
        mu_x1_c1_en_r <= '0';
        mu_x1_c1_r <= (others=>'0');
        mu_vm_r <= '0';
        result_raddr_r <= (others=>'0');
        result_waddr_r <= (others=>'0');
        xreg_waddr_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            mu_x1_vector_r <= mu_x1_vector;
            mu_x2_vector_r <= mu_x2_vector;
            mu_y_vector_r <= mu_y_vector;

            mu_x1_c1_en_r <= mu_x1_c1_en;
            mu_x1_c1_r <= std_logic_vector(mu_x1_i2(mu_x1_c1_r'length-1 downto 0));

            if instruction_tid_valid_in='1' then
                -- Decode the instruction
                xreg_waddr_r <= mu_y_addr1(xreg_depth_c+vector_depth_c-1 downto vector_depth_c);
                result_waddr_r <= std_logic_vector(to_unsigned(0,xreg_depth_c-tid_t'length)) & std_logic_vector(instruction_tid_in);
                mu_opcode1_r <= mu_opcode1;
                mu_x1_addr1_r <= mu_x1_addr1(mu_x1_addr1_r'length-1 downto 0);
                mu_x2_addr1_r <= mu_x2_addr1(mu_x2_addr1_r'length-1 downto 0);
                mu_y_addr1_r <= mu_y_addr1(mu_y_addr1_r'length-1 downto 0);
                result_raddr_r <= mu_x3_addr1(xreg_depth_c+vector_depth_c-1 downto vector_depth_c);
                mu_lane_r <= std_logic_vector(lane_in(vector_width_c-1 downto 0));
                mu_en1_r <= '1';
                mu_flag1_r <= mu_flag1;
                mu_xreg1_r <= mu_xreg1;
                mu_wren_r <= mu_wren;
                mu_vm_r <= instruction_vm_in;
            else
                xreg_waddr_r <= (others=>'0');
                result_waddr_r <= (others=>'0');
                result_raddr_r <= (others=>'0');
                mu_en1_r <= '0';
                mu_opcode1_r <= (others=>'0');
                mu_flag1_r <= '0';
                mu_xreg1_r <= '0';
                mu_wren_r <= '0';
                mu_lane_r <= (others=>'0');
                mu_vm_r <= '0';
            end if;
            mu_lane_rr <= mu_lane_r;
            mu_lane_rrr <= mu_lane_rr;
            mu_lane_rrrr <= mu_lane_rrr;
            mu_lane_rrrrr <= mu_lane_rrrr;
            mu_lane_rrrrrr <= mu_lane_rrrrr;
        end if;
    end if;
END PROCESS;
END behavior;
