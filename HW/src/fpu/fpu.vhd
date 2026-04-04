------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Author: Vuong Nguyen
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except IN compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to IN writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
------------------------------------------------------------------------------

--------
--
-- Implement FPU (floating point unit)
-- Has the following functions
--   Accept FPU commands from RISCV 
--   Fetch input data from SRAM
--   Feed input to ALU to perform floating point operations on input data
--   Write results back to SRAM
-- FPU is fully pipeline for both memory and computing operations resulting
-- in 1 operation per cycle (including memory overhead)
-- input can also be vectors. Then it performas VECTOR_WIDTH operations per cycle
--
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

ENTITY fpu IS
    PORT (
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;

        -- Bus interface for configuration        
        SIGNAL bus_waddr_in             : IN register_addr_t;
        SIGNAL bus_raddr_in             : IN register_addr_t;
        SIGNAL bus_write_in             : IN STD_LOGIC;
        SIGNAL bus_read_in              : IN STD_LOGIC;
        SIGNAL bus_writedata_in         : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdata_out         : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdatavalid_out    : OUT STD_LOGIC;
        SIGNAL bus_writewait_out        : OUT STD_LOGIC;
        SIGNAL bus_readwait_out         : OUT STD_LOGIC;

        -- Bus interface to SRAM
        SIGNAL fpu_rd_addr_out          : OUT STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
        SIGNAL fpu_wr_addr_out          : OUT STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
        SIGNAL fpu_write_out            : OUT STD_LOGIC;
        SIGNAL fpu_write_wait_in        : IN STD_LOGIC;
        SIGNAL fpu_read_out             : OUT STD_LOGIC;
        SIGNAL fpu_read_wait_in         : IN STD_LOGIC;
        SIGNAL fpu_writedata_out        : OUT STD_LOGIC_VECTOR(fpu_data_width_c-1 DOWNTO 0);
        SIGNAL fpu_writebe_out          : OUT STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
        SIGNAL fpu_readdatavalid_in     : IN STD_LOGIC;
        SIGNAL fpu_readdata_in          : IN STD_LOGIC_VECTOR(fpu_data_width_c-1 DOWNTO 0);

        SIGNAL fpu_busy_vm_out          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        SIGNAL fpu_exe_in               : IN STD_LOGIC;

        SIGNAL fpu_exe_vm_in            : IN STD_LOGIC;

        SIGNAL fpu_exe_out              : OUT STD_LOGIC
    );
END fpu;

ARCHITECTURE behavior OF fpu IS

-- FPU instruction definition

type fpu_instruction_t is
record
    opcode:fpu_opcode_t;
    A_addr:unsigned(sram_depth_c-1 downto 0);
    B_addr:unsigned(sram_depth_c-1 downto 0);
    C:fp32_t;
    C_addr:unsigned(sram_depth_c-1 downto 0);
    C_by_value:std_logic;
    C_pending:std_logic;
    C2:fp32_t;
    C2_addr:unsigned(sram_depth_c-1 downto 0);
    C2_by_value:std_logic;
    C2_pending:std_logic;
    X_addr:unsigned(sram_depth_c-1 downto 0);
    Y_addr:unsigned(sram_depth_c-1 downto 0);
    CNT:unsigned(sram_depth_c-1 downto 0);
    VECTOR:fpu_vector_t;
    LAST:std_logic;
    LAST_BE:std_logic_vector(fpu_data_width_c/8-1 downto 0);
    FAST:std_logic;
    B_enable:std_logic;
    C_enable:std_logic;
    C2_enable:std_logic;
    X_enable:std_logic;
    Y_enable:std_logic;
    B_by_value:std_logic;
    X_by_value:std_logic;
    Y_by_value:std_logic;
    B:fp32_t;
    X:fp32_t;
    Y:fp32_t;
    A_precision:unsigned(2 downto 0);
    A_int:std_logic;
    A_floor:std_logic;
    A_abs:std_logic;
    B_precision:unsigned(2 downto 0);
    B_int:std_logic;
    X_double:std_logic;
    Y_double:std_logic;
    C_double:std_logic;
    C2_double:std_logic;
    X_type:register2_t;
    Y_type:register2_t;
    B_type:register2_t;
end record;

signal fpu_instruction_r:fpu_instruction_t;

signal fpu_next_instruction_r:fpu_instruction_t;

signal fpu_instruction:fpu_instruction_t;

constant fpu_instruction_len_c:integer:=fpu_instruction_r.opcode'length+
                                        fpu_instruction_r.A_addr'length+
                                        fpu_instruction_r.B_addr'length+
                                        fpu_instruction_r.C'length+
                                        fpu_instruction_r.C_addr'length+
                                        1 + -- fpu_instruction_r.C_by_value'length+
                                        1 + --fpu_instruction_r.C_pending'length+
                                        fpu_instruction_r.C2'length+
                                        fpu_instruction_r.C2_addr'length+
                                        1 + -- fpu_instruction_r.C2_by_value'length+
                                        1 + --fpu_instruction_r.C2_pending'length+
                                        fpu_instruction_r.X_addr'length+
                                        fpu_instruction_r.Y_addr'length+
                                        fpu_instruction_r.CNT'length+
                                        fpu_instruction_r.VECTOR'length+
                                        1+ --fpu_instruction_r.LAST'length 
                                        fpu_instruction_r.LAST_BE'length+ 
                                        1+ --fpu_instruction_r.FAST'length
                                        1+ --fpu_instruction_r.B_enable'length
                                        1+ --fpu_instruction_r.C_enable'length
                                        1+ --fpu_instruction_r.C2_enable'length
                                        1+ --fpu_instruction_r.X_enable'length
                                        1+ --fpu_instruction_r.Y_enable'length
                                        1+ --fpu_instruction_r.B_by_value'length
                                        1+ --fpu_instruction_r.X_by_value'length
                                        1+ --fpu_instruction_r.Y_by_value'length
                                        fpu_instruction_r.B'length+ --fpu_instruction_r.B'length
                                        fpu_instruction_r.X'length+ --fpu_instruction_r.X'length
                                        fpu_instruction_r.Y'length+ --fpu_instruction_r.Y'length  
                                        fpu_instruction_r.A_precision'length+ --fpu_instruction_r.A_precision'length
                                        1+ --fpu_instruction_r.A_int
                                        1+ --fpu_instruction_r.A_floor
                                        1+ --fpu_instruction_r.A_abs
                                        fpu_instruction_r.B_precision'length+ --fpu_instruction_r.B_precision
                                        1+ -- fpu_instruction_r.B_int
                                        1+ --fpu_instruction_r.X_double
                                        1+ --fpu_instruction_r.Y_double
                                        1+ --fpu_instruction_r.C_double
                                        1+ --fpu_instruction_r.C2_double
                                        register2_t'length+ --fpu_instruction_r.X_type
                                        register2_t'length+ --fpu_instruction_r.Y_type
                                        register2_t'length; --fpu_instruction_r.B_type

subtype fpu_instruction_rec_t is std_logic_vector(fpu_instruction_len_c-1 downto 0);

type fpu_instruction_recs_t is array(natural range <>) of fpu_instruction_rec_t;

-- Unpack fp_instruction from FIFO

function unpack_instruction(q_in:fpu_instruction_rec_t) return fpu_instruction_t is  
variable rec_v:fpu_instruction_t;
variable len_v:integer;
begin
    len_v := 0;
    rec_v.opcode := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.opcode'length));
    len_v := len_v + rec_v.opcode'length;
    rec_v.A_addr := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.A_addr'length));
    len_v := len_v + rec_v.A_addr'length;
    rec_v.B_addr := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.B_addr'length));
    len_v := len_v + rec_v.B_addr'length;
    rec_v.C := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.C'length);
    len_v := len_v + rec_v.C'length;
    rec_v.C_addr := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.C_addr'length));
    len_v := len_v + rec_v.C_addr'length;
    rec_v.C_by_value := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.C_pending := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;    
    rec_v.C2 := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.C2'length);
    len_v := len_v + rec_v.C2'length;
    rec_v.C2_addr := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.C2_addr'length));
    len_v := len_v + rec_v.C2_addr'length;
    rec_v.C2_by_value := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.C2_pending := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;    
    rec_v.X_addr := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.X_addr'length));
    len_v := len_v + rec_v.X_addr'length;
    rec_v.Y_addr := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.Y_addr'length));
    len_v := len_v + rec_v.Y_addr'length;
    rec_v.CNT := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.CNT'length));
    len_v := len_v + rec_v.CNT'length;
    rec_v.VECTOR := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.VECTOR'length));
    len_v := len_v + rec_v.VECTOR'length;
    rec_v.LAST := q_in(q_in'length-len_v-1);
    len_v := len_v + 1; 
    rec_v.LAST_BE := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.LAST_BE'length);
    len_v := len_v + rec_v.LAST_BE'length;
    rec_v.FAST := q_in(q_in'length-len_v-1);
    len_v := len_v + 1; 
    rec_v.B_enable := q_in(q_in'length-len_v-1);
    len_v := len_v + 1; 
    rec_v.C_enable := q_in(q_in'length-len_v-1);
    len_v := len_v + 1; 
    rec_v.C2_enable := q_in(q_in'length-len_v-1);
    len_v := len_v + 1; 
    rec_v.X_enable := q_in(q_in'length-len_v-1);
    len_v := len_v + 1; 
    rec_v.Y_enable := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;  
    rec_v.B_by_value := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.X_by_value := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;  
    rec_v.Y_by_value := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;  
    rec_v.B := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.B'length);
    len_v := len_v + rec_v.B'length;
    rec_v.X := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.X'length);
    len_v := len_v + rec_v.X'length;
    rec_v.Y := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.Y'length);
    len_v := len_v + rec_v.Y'length;
    rec_v.A_precision := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.A_precision'length));
    len_v := len_v + rec_v.A_precision'length;
    rec_v.A_int := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.A_floor := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.A_abs := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.B_precision := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.B_precision'length));
    len_v := len_v + rec_v.B_precision'length;
    rec_v.B_int := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.X_double := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.Y_double := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.C_double := q_in(q_in'length-len_v-1);
    len_v := len_v + 1; 
    rec_v.C2_double := q_in(q_in'length-len_v-1);
    len_v := len_v + 1;
    rec_v.X_type := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.X_type'length));
    len_v := len_v + rec_v.X_type'length;
    rec_v.Y_type := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.Y_type'length));
    len_v := len_v + rec_v.Y_type'length;
    rec_v.B_type := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.B_type'length));
    len_v := len_v + rec_v.B_type'length;
    return rec_v;
end unpack_instruction;

-- Pack instruction to FIFO

function pack_instruction(rec_in:fpu_instruction_t;
                        last_in:std_logic;
                        fast_in:std_logic;
                        opcode_in:fpu_opcode_t;
                        floor_in:std_logic;
                        abs_in:std_logic;
                        last_be:std_logic_vector(fpu_data_width_c/8-1 downto 0)) 
                        return fpu_instruction_rec_t is  
variable len_v:integer;
variable q_v:fpu_instruction_rec_t;
begin
   len_v := 0;

   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.opcode'length) := std_logic_vector(opcode_in);
   len_v := len_v + rec_in.opcode'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.A_addr'length) := std_logic_vector(rec_in.A_addr);
   len_v := len_v + rec_in.A_addr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.B_addr'length) := std_logic_vector(rec_in.B_addr);
   len_v := len_v + rec_in.B_addr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.C'length) := std_logic_vector(rec_in.C);
   len_v := len_v + rec_in.C'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.C_addr'length) := std_logic_vector(rec_in.C_addr);
   len_v := len_v + rec_in.C_addr'length;
   q_v(q_v'length-len_v-1) := rec_in.C_by_value;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.C_pending;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.C2'length) := std_logic_vector(rec_in.C2);
   len_v := len_v + rec_in.C2'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.C2_addr'length) := std_logic_vector(rec_in.C2_addr);
   len_v := len_v + rec_in.C2_addr'length;
   q_v(q_v'length-len_v-1) := rec_in.C2_by_value;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.C2_pending;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.X_addr'length) := std_logic_vector(rec_in.X_addr);
   len_v := len_v + rec_in.X_addr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.Y_addr'length) := std_logic_vector(rec_in.Y_addr);
   len_v := len_v + rec_in.Y_addr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.CNT'length) := std_logic_vector(rec_in.CNT);
   len_v := len_v + rec_in.CNT'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.VECTOR'length) := std_logic_vector(rec_in.VECTOR);
   len_v := len_v + rec_in.VECTOR'length;
   q_v(q_v'length-len_v-1) := last_in;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.LAST_BE'length) := last_be;
   len_v := len_v + rec_in.LAST_BE'length;
   q_v(q_v'length-len_v-1) := fast_in;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.B_enable;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.C_enable;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.C2_enable;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.X_enable;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.Y_enable;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.B_by_value;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.X_by_value;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.Y_by_value;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.B'length) := std_logic_vector(rec_in.B);
   len_v := len_v + rec_in.B'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.X'length) := std_logic_vector(rec_in.X);
   len_v := len_v + rec_in.X'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.Y'length) := std_logic_vector(rec_in.Y);
   len_v := len_v + rec_in.Y'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.A_precision'length) := std_logic_vector(rec_in.A_precision);
   len_v := len_v + rec_in.A_precision'length;
   q_v(q_v'length-len_v-1) := rec_in.A_int;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := floor_in;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := abs_in;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.B_precision'length) := std_logic_vector(rec_in.B_precision);
   len_v := len_v + rec_in.B_precision'length;
   q_v(q_v'length-len_v-1) := rec_in.B_int;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.X_double;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.Y_double;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.C_double;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1) := rec_in.C2_double;
   len_v := len_v + 1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.X_type'length) := std_logic_vector(rec_in.X_type);
   len_v := len_v + rec_in.X_type'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.Y_type'length) := std_logic_vector(rec_in.Y_type);
   len_v := len_v + rec_in.Y_type'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.B_type'length) := std_logic_vector(rec_in.B_type);
   len_v := len_v + rec_in.B_type'length;
   return q_v;
end pack_instruction;

----
-- Convert proprietary float format to float32
-- Proprietary format is optimized to transfer int32 value from pcore in 16-bit float format
--     1-bit sign
--     4-bit exponent
--     11-bit mantissa
----

subtype zfp2float_retval_t is std_logic_vector(31 downto 0);
function zfp2float(
        int_in:std_logic_vector(15 downto 0)) 
        return zfp2float_retval_t is
variable float_v:std_logic_vector(31 downto 0);
variable exp_v:std_logic_vector(7 downto 0);
variable mantissa_v:std_logic_vector(fp12_mantissa_width_c-1 downto 0);
begin
   exp_v(fp12_exp_width_c-1 downto 0) := int_in(14 downto 14-fp12_exp_width_c+1);
   exp_v(7 downto fp12_exp_width_c) := (others=>'0');
   mantissa_v := int_in(fp12_mantissa_width_c-1 downto 0);
   if(exp_v=std_logic_vector(to_unsigned(0,exp_v'length))) then
      if(mantissa_v=std_logic_vector(to_unsigned(0,fp12_mantissa_width_c))) then
         float_v := (others=>'0');
      else
         float_v(31) := int_in(15);
         float_v(30 downto 0) := (others=>'0');
         if mantissa_v(10) = '1' then
            float_v(22 downto 13) := mantissa_v(9 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(137,8));
         elsif mantissa_v(9) = '1' then
            float_v(22 downto 14) := mantissa_v(8 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(136,8));
         elsif mantissa_v(8) = '1' then
            float_v(22 downto 15) := mantissa_v(7 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(135,8));
         elsif mantissa_v(7) = '1' then
            float_v(22 downto 16) := mantissa_v(6 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(134,8));
         elsif mantissa_v(6) = '1' then
            float_v(22 downto 17) := mantissa_v(5 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(133,8));
         elsif mantissa_v(5) = '1' then
            float_v(22 downto 18) := mantissa_v(4 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(132,8));
         elsif mantissa_v(4) = '1' then
            float_v(22 downto 19) := mantissa_v(3 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(131,8));
         elsif mantissa_v(3) = '1' then
            float_v(22 downto 20) := mantissa_v(2 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(130,8));
         elsif mantissa_v(2) = '1' then
            float_v(22 downto 21) := mantissa_v(1 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(129,8));
         elsif mantissa_v(1) = '1' then
            float_v(22 downto 22) := mantissa_v(0 downto 0);
            float_v(30 downto 23) := std_logic_vector(to_unsigned(128,8));
         elsif mantissa_v(0) = '1' then
            float_v(30 downto 23) := std_logic_vector(to_unsigned(127,8));
         else
            float_v := (others=>'0');
         end if;
      end if;
   else
      float_v(31) := int_in(15); -- Sign bit
      float_v(30 downto 23) := std_logic_vector(unsigned(exp_v)+to_unsigned(126+fp12_mantissa_width_c,8));
      float_v(22 downto 22-fp12_mantissa_width_c+1) := mantissa_v;
      float_v(22-fp12_mantissa_width_c downto 0) := (others=>'0');
   end if;
   return float_v;
end function zfp2float;

----
-- Convert float16 to float32
----

subtype fp2float_retval_t is std_logic_vector(31 downto 0);
function fp2float(f16 : std_logic_vector(15 downto 0)) return fp2float_retval_t is
variable sign     : std_logic;
variable exp16    : unsigned(4 downto 0);
variable mant16   : std_logic_vector(9 downto 0);
variable exp32    : unsigned(7 downto 0);
variable mant32   : std_logic_vector(22 downto 0);
variable result   : std_logic_vector(31 downto 0);
begin
    -- Extract components
    sign   := f16(15);
    exp16  := unsigned(f16(14 downto 10));
    mant16 := f16(9 downto 0);
    -- Conversion Logic
    if exp16 = 0 then
        -- Handle Zero and Subnormals (flushed to zero here)
        exp32  := (others => '0');
        mant32 := mant16 & "0000000000000";
        sign := '0';
    elsif exp16 = 31 then
        -- Handle Infinity and NaN
        exp32  := (others => '1');
        mant32 := mant16 & "0000000000000"; -- NaN
    else
        -- Normal numbers: Re-bias the exponent
        -- Bias correction: 127 - 15 = 112
        exp32  := resize(exp16,8) + to_unsigned(112,8);
        mant32 := mant16 & "0000000000000";
    end if;
    result := sign & std_logic_vector(exp32) & mant32;
    return result;
end function;

------

constant CMD_FIFO_DEPTH:integer:=8;

SIGNAL cmd_fifo_write:fpu_instruction_recs_t(1 downto 0);
SIGNAL cmd_fifo_we:std_logic_vector(1 downto 0);
SIGNAL cmd_fifo_rd:std_logic_vector(1 downto 0);
SIGNAL cmd_fifo_reads:fpu_instruction_recs_t(1 downto 0);
SIGNAL cmd_fifo_read:fpu_instruction_rec_t;
SIGNAL cmd_fifo_empty:std_logic_vector(1 downto 0);
SIGNAL cmd_fifo_full:std_logic_vector(1 downto 0);

-- Read pending bit mask

constant PARM_MAX:integer:=5;

constant PARM_B:integer:=0; -- Pending read for B

constant PARM_X:integer:=1; -- Pending read for X

constant PARM_Y:integer:=2; -- Pending read for Y

constant PARM_C:integer:=3; -- Pending read for C

constant PARM_C2:integer:=4; -- Pending read for C2

constant CACHE_DEPTH:integer:=4; -- Max prefetch window for parameters

constant MAX_CACHE_LEVEL:integer:=6; -- Should have up to 6 values in cache

SIGNAL wregno:register_t;
SIGNAL wregno2:register2_t;
SIGNAL fpu_set_P:register2_t; -- fpu_set P field
SIGNAL fpu_set_M:register2_t; -- fpu_set M bit
SIGNAL fpu_set_W:register2_t; -- fpu_set W bit
SIGNAL rregno:register_t;
SIGNAL rregno2:register2_t;
SIGNAL rden_r:std_logic;
SIGNAL rresp_r:STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);

SIGNAL A_addr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL C:fp32_t;
SIGNAL C2:fp32_t;

-- Signals to indicate pending read responses

SIGNAL pending_write:STD_LOGIC_VECTOR(PARM_MAX-1 downto 0);
SIGNAL pending_wrreq:STD_LOGIC;
SIGNAL pending_rdreq:STD_LOGIC;
SIGNAL pending_read:STD_LOGIC_VECTOR(PARM_MAX-1 downto 0);
SIGNAL pending_empty:STD_LOGIC;

-- Signal for parameter signals

SIGNAL B_wrreq:STD_LOGIC;
SIGNAL B_rdreq:STD_LOGIC;
SIGNAL B_rdflush:STD_LOGIC;
SIGNAL B:STD_LOGIC_VECTOR(fpu_data_width_c-1 downto 0);
SIGNAL B_wused:std_logic_vector(CACHE_DEPTH-1 downto 0);
SIGNAL B_pending_r:unsigned(CACHE_DEPTH-1 downto 0);
SIGNAL B_empty:STD_LOGIC;
SIGNAL B_avail:unsigned(CACHE_DEPTH-1 downto 0);

SIGNAL X_wrreq:STD_LOGIC;
SIGNAL X_rdreq:STD_LOGIC;
SIGNAL X_rdflush:STD_LOGIC;
SIGNAL X:STD_LOGIC_VECTOR(fpu_data_width_c-1 downto 0);
SIGNAL X_wused:std_logic_vector(CACHE_DEPTH-1 downto 0);
SIGNAL X_pending_r:unsigned(CACHE_DEPTH-1 downto 0);
SIGNAL X_empty:STD_LOGIC;
SIGNAL X_avail:unsigned(CACHE_DEPTH-1 downto 0);

SIGNAL Y_wrreq:STD_LOGIC;
SIGNAL Y_rdreq:STD_LOGIC;
SIGNAL Y_rdflush:STD_LOGIC;
SIGNAL Y:STD_LOGIC_VECTOR(fpu_data_width_c-1 downto 0);
SIGNAL Y_wused:std_logic_vector(CACHE_DEPTH-1 downto 0);
SIGNAL Y_pending_r:unsigned(CACHE_DEPTH-1 downto 0);
SIGNAL Y_empty:STD_LOGIC;
SIGNAL Y_avail:unsigned(CACHE_DEPTH-1 downto 0);

SIGNAL C_wrreq:STD_LOGIC;
SIGNAL C2_wrreq:STD_LOGIC;

SIGNAL exe_x:fp32s_t(fpu_gen_max_c-1 DOWNTO 0);
SIGNAL exe_y:fp32s_t(fpu_gen_max_c-1 DOWNTO 0);
SIGNAL exe_b:fp32s_t(fpu_gen_max_c-1 DOWNTO 0);

SIGNAL running:STD_LOGIC;
SIGNAL step:unsigned(sram_depth_c-1 DOWNTO 0);

SIGNAL running_r:STD_LOGIC;
SIGNAL busy_r:STD_LOGIC;
SIGNAL busy_rr:STD_LOGIC;
SIGNAL busy:STD_LOGIC;
SIGNAL step_r:unsigned(sram_depth_c-1 DOWNTO 0);

SIGNAL ready:STD_LOGIC;
SIGNAL exe:STD_LOGIC;

SIGNAL fpu_write:STD_LOGIC;
SIGNAL fpu_wr_addr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL fpu_wr_precision:unsigned(2 downto 0);
SIGNAL fpu_writedata:fp32s_t(fpu_gen_max_c-1 DOWNTO 0);

SIGNAL writedata_r:std_logic_vector(fpu_data_width_c-1 downto 0);
SIGNAL writebe_r:std_logic_vector(fpu_data_width_c/8-1 downto 0);
SIGNAL writedata:std_logic_vector(fpu_data_width_c-1 downto 0);
SIGNAL writebe:std_logic_vector(fpu_data_width_c/8-1 downto 0);

SIGNAL sram_read_wait:STD_LOGIC;
SIGNAL sram_rd_addr:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
SIGNAL sram_read:STD_LOGIC;
SIGNAL sram_rd_addr_r:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
SIGNAL sram_read_r:STD_LOGIC;


SIGNAL sram_wr_addr:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
SIGNAL sram_write:STD_LOGIC;
SIGNAL sram_writedata:STD_LOGIC_VECTOR(fpu_data_width_c-1 DOWNTO 0);
SIGNAL sram_writebe:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);

SIGNAL sram_wr_addr_r:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
SIGNAL sram_write_r:STD_LOGIC;
SIGNAL sram_writedata_r:STD_LOGIC_VECTOR(fpu_data_width_c-1 DOWNTO 0);
SIGNAL sram_writebe_r:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);

SIGNAL eof:STD_LOGIC;

SIGNAL fpu_eof:STD_LOGIC;

SIGNAL fpu_last:STD_LOGIC;

SIGNAL fpu_last_be:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);

SIGNAL fpu_fast:STD_LOGIC;

SIGNAL fpu_vector:fpu_vector_t;

SIGNAL halt_r:STD_LOGIC:='1';

SIGNAL halt:STD_LOGIC;

SIGNAL fpu_readdatavalid_r:STD_LOGIC;

SIGNAL fpu_readdatavalid_rr:STD_LOGIC;

SIGNAL vm_r:STD_LOGIC;

SIGNAL fpu_vm_r:STD_LOGIC;

SIGNAL fpu_exe_r:STD_LOGIC;

SIGNAL fpu_exe_rr:STD_LOGIC;

SIGNAL page_vm:unsigned(sram_depth_c-1 DOWNTO 0);

signal page_vm0_r:std_logic_vector(sram_depth_c-1 DOWNTO 0);

signal page_vm1_r:std_logic_vector(sram_depth_c-1 DOWNTO 0);

signal write_flush_r:std_logic;

signal fpu_exe_pending_r:std_logic_vector(1 downto 0);

signal fpu_busy_vm_r:std_logic_vector(1 downto 0);

signal full:std_logic;

BEGIN

full <= cmd_fifo_full(0) or cmd_fifo_full(1);

fpu_exe_out <= exe;

busy <= (busy_r or busy_rr or fpu_exe_r or fpu_exe_rr);

fpu_busy_vm_out <= fpu_busy_vm_r;

bus_readdata_out <= rresp_r when rden_r='1' else (others=>'Z');

bus_readdatavalid_out <= rden_r;

bus_writewait_out <= '1' when (bus_write_in='1' and full='1' and wregno=to_unsigned(register_fpu_exe_c,register_t'length)) else '0';

bus_readwait_out <= '0';

eof <= not running; -- Last step 

fpu_wr_addr_out <= sram_wr_addr_r;      

fpu_write_out <= sram_write_r;

fpu_writedata_out <= sram_writedata_r;

fpu_writebe_out <= sram_writebe_r;

fpu_rd_addr_out <= sram_rd_addr_r;

fpu_read_out <= sram_read_r;

pending_rdreq <= fpu_readdatavalid_in;

wregno <= unsigned(bus_waddr_in(register_t'length-1 downto 0));

wregno2 <= unsigned(bus_waddr_in(register2_t'length+register_t'length-1 downto register_t'length));

fpu_set_P <= unsigned(bus_waddr_in(register2_t'length+register_t'length-1 downto register_t'length) and register2_fpu_set_P_MASK);

fpu_set_M <= unsigned(bus_waddr_in(register2_t'length+register_t'length-1 downto register_t'length) and register2_fpu_set_M_MASK);

fpu_set_W <= unsigned(bus_waddr_in(register2_t'length+register_t'length-1 downto register_t'length) and register2_fpu_set_W_MASK);

rregno <= unsigned(bus_raddr_in(register_t'length-1 downto 0));

rregno2 <= unsigned(bus_raddr_in(register2_t'length+register_t'length-1 downto register_t'length));

-- Available cache for each parameters

B_avail <= (unsigned(B_wused) + unsigned(B_pending_r)) when (fpu_instruction_r.B_enable='1' and fpu_instruction_r.B_by_value='0') else (others=>'1');

X_avail <= (unsigned(X_wused) + unsigned(X_pending_r)) when (fpu_instruction_r.X_enable='1' and fpu_instruction_r.X_by_value='0') else (others=>'1');

Y_avail <= (unsigned(Y_wused) + unsigned(Y_pending_r)) when (fpu_instruction_r.Y_enable='1' and fpu_instruction_r.Y_by_value='0') else (others=>'1');

ready <= (not running_r) and X_empty and Y_empty and B_empty and pending_empty and (not write_flush_r);

exe <=  running_r and 
        ((not B_empty) or (not fpu_instruction_r.B_enable) or (fpu_instruction_r.B_by_value)) and 
        ((not X_empty) or (not fpu_instruction_r.X_enable) or (fpu_instruction_r.X_by_value)) and 
        ((not Y_empty) or (not fpu_instruction_r.Y_enable) or (fpu_instruction_r.Y_by_value)) and 
        ((fpu_instruction_r.C_by_value) or (not fpu_instruction_r.C_enable)) and
        ((fpu_instruction_r.C2_by_value) or (not fpu_instruction_r.C2_enable));

sram_read_wait <= '0' when (sram_read_r='0' or fpu_read_wait_in='0') else '1';

fpu_instruction <= unpack_instruction(cmd_fifo_read);

page_vm <= unsigned(bus_writedata_in(sram_depth_c-1 downto 0)) + unsigned(page_vm0_r)
        when vm_r='0' 
        else
        unsigned(bus_writedata_in(sram_depth_c-1 downto 0)) + unsigned(page_vm1_r);

---------
-- FIFO to store FPU instructions issued from RISCV to HART0
---------

cmd_fifo_i0:scfifo
	generic map 
	(
        DATA_WIDTH=>fpu_instruction_rec_t'length,
        FIFO_DEPTH=>CMD_FIFO_DEPTH,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>cmd_fifo_write(0),
        write_in=>cmd_fifo_we(0),
        read_in=>cmd_fifo_rd(0),
        q_out=>cmd_fifo_reads(0),
        ravail_out=>open,
        wused_out=>open,
        empty_out=>cmd_fifo_empty(0),
        full_out=>cmd_fifo_full(0),
        almost_full_out=>open
	);

---------
-- FIFO to store FPU instructions issued from RISCV to HART1
---------

cmd_fifo_i1:scfifo
	generic map 
	(
        DATA_WIDTH=>fpu_instruction_rec_t'length,
        FIFO_DEPTH=>CMD_FIFO_DEPTH,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>cmd_fifo_write(1),
        write_in=>cmd_fifo_we(1),
        read_in=>cmd_fifo_rd(1),
        q_out=>cmd_fifo_reads(1),
        ravail_out=>open,
        wused_out=>open,
        empty_out=>cmd_fifo_empty(1),
        full_out=>cmd_fifo_full(1),
        almost_full_out=>open
	);

--------------
-- Floating point ALU
-- ALUs are arranged to process vectors
--------------

falu_vector_i : falu_vector
    PORT MAP(
        clock_in => clock_in,
        reset_in => reset_in,
        step_in => step_r,
        opcode_in => fpu_instruction_r.opcode,
        input_ena_in => exe,
        input_eof_in => eof,
        input_last_in => fpu_instruction_r.LAST,
        input_last_be_in => fpu_instruction_r.LAST_BE,
        input_fast_in => fpu_instruction_r.FAST,
        input_vector_in => fpu_instruction_r.VECTOR,
        A_addr => fpu_instruction_r.A_addr,
        A_precision => fpu_instruction_r.A_precision,
        A_int => fpu_instruction_r.A_int,
        A_floor => fpu_instruction_r.A_floor,
        A_abs => fpu_instruction_r.A_abs,
        B_in => exe_b,
        C_in => fpu_instruction_r.C,
        C2_in => fpu_instruction_r.C2,
        X_in => exe_x,
        Y_in => exe_y,
        output_ena_out => fpu_write,
        output_opcode_out => open,
        output_addr_out => fpu_wr_addr,
        output_precision_out => fpu_wr_precision,
        output_out => fpu_writedata,
        output_eof_out => fpu_eof,
        output_last_out => fpu_last,
        output_last_be_out => fpu_last_be,
        output_fast_out => fpu_fast,
        output_vector_out => fpu_vector
    );

-- FIFO to keep track the read response going to which buffer

read_pending_i:scfifo
	generic map 
	(
        DATA_WIDTH=>PARM_MAX,
        FIFO_DEPTH=>3, -- Dont need more than 8 since sram latency is less than 8
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>pending_write,
        write_in=>pending_wrreq,
        read_in=>pending_rdreq,
        q_out=>pending_read,
        ravail_out=>open,
        wused_out=>open,
        empty_out=>pending_empty,
        full_out=>open,
        almost_full_out=>open
	);

-- B parameter FIFO

B_fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>fpu_data_width_c,
        FIFO_DEPTH=>CACHE_DEPTH,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>fpu_readdata_in,
        write_in=>B_wrreq,
        read_in=>B_rdreq,
        flush_in=>B_rdflush,
        q_out=>B,
        ravail_out=>open,
        wused_out=>B_wused,
        empty_out=>B_empty,
        full_out=>open,
        almost_full_out=>open
	);

-- X parameter FIFO

X_fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>fpu_data_width_c,
        FIFO_DEPTH=>CACHE_DEPTH,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>fpu_readdata_in,
        write_in=>X_wrreq,
        read_in=>X_rdreq,
        flush_in=>X_rdflush,
        q_out=>X,
        ravail_out=>open,
        wused_out=>X_wused,
        empty_out=>X_empty,
        full_out=>open,
        almost_full_out=>open
	);

-- Y parameter FIFO

Y_fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>fpu_data_width_c,
        FIFO_DEPTH=>CACHE_DEPTH,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>fpu_readdata_in,
        write_in=>Y_wrreq,
        read_in=>Y_rdreq,
        flush_in=>Y_rdflush,
        q_out=>Y,
        ravail_out=>open,
        wused_out=>Y_wused,
        empty_out=>Y_empty,
        full_out=>open,
        almost_full_out=>open
	);

-- Command FIFO 

process(fpu_next_instruction_r,bus_writedata_in,wregno2,bus_write_in,wregno,full,
        fpu_vm_r,ready,cmd_fifo_empty,halt_r,cmd_fifo_reads,vm_r)
variable last_be_v:std_logic_vector(fpu_data_width_c/8-1 downto 0);
variable cnt_v:unsigned(fpu_vector_depth_c-2 downto 0);
variable cnt2_v:unsigned(fpu_vector_depth_c-3 downto 0);
begin
if(fpu_next_instruction_r.VECTOR=to_unsigned(0,fpu_next_instruction_r.VECTOR'length)) then
    last_be_v := (others=>'1');
else
    if(fpu_next_instruction_r.A_precision=to_unsigned(2,fpu_next_instruction_r.A_precision'length)) then
        cnt_v := fpu_next_instruction_r.CNT(fpu_vector_depth_c-1-1 downto 0) + fpu_next_instruction_r.A_addr(fpu_vector_depth_c-1 downto 1);
        last_be_v := (others=>'0');
        FOR I in 0 to fpu_vector_width_c/2-1 LOOP
            if(cnt_v=I) then
                if(I=0) then
                    last_be_v := (others=>'1');
                else
                    last_be_v := std_logic_vector(to_unsigned(2**(2*I)-1,last_be_v'length));
                end if;
                exit;
            end if;
        END LOOP;
    else
        cnt2_v := fpu_next_instruction_r.CNT(fpu_vector_depth_c-2-1 downto 0) + fpu_next_instruction_r.A_addr(fpu_vector_depth_c-1 downto 2);
        last_be_v := (others=>'0');
        FOR I in 0 to fpu_vector_width_c/4-1 LOOP
            if(cnt2_v=I) then
                if(I=0) then
                    last_be_v := (others=>'1');
                else
                    last_be_v := std_logic_vector(to_unsigned(2**(4*I)-1,last_be_v'length));
                end if;
                exit;
            end if;
        END LOOP;
    end if;
end if;

if(vm_r='0') then
    cmd_fifo_write(0) <= pack_instruction(fpu_next_instruction_r,bus_writedata_in(0),bus_writedata_in(1),
                                        unsigned(wregno2(fpu_opcode_t'length-1 downto 0)), --fpu_opcode_t
                                        wregno2(fpu_opcode_t'length), --floor
                                        wregno2(fpu_opcode_t'length+1), --abs
                                        last_be_v
                                        );

    if(bus_write_in='1' and wregno=to_unsigned(register_fpu_exe_c,register_t'length) and full='0') then
        cmd_fifo_we(0) <= '1';
    else 
        cmd_fifo_we(0) <= '0'; 
    end if;

    cmd_fifo_write(1) <= (others=>'0');
    cmd_fifo_we(1) <= '0';
else
    cmd_fifo_write(0) <= (others=>'0');
    cmd_fifo_we(0) <= '0';
    
    cmd_fifo_write(1) <= pack_instruction(fpu_next_instruction_r,bus_writedata_in(0),bus_writedata_in(1),
                                        unsigned(wregno2(fpu_opcode_t'length-1 downto 0)), --fpu_opcode_t
                                        wregno2(fpu_opcode_t'length), --floor
                                        wregno2(fpu_opcode_t'length+1), --abs
                                        last_be_v
                                        );
    if(bus_write_in='1' and wregno=to_unsigned(register_fpu_exe_c,register_t'length) and full='0') then
        cmd_fifo_we(1) <= '1';
    else
        cmd_fifo_we(1) <= '0';
    end if;
end if;

if(fpu_vm_r='0') then
    if((ready='1') and (cmd_fifo_empty(0)='0') and (halt_r='0')) then
        cmd_fifo_rd(0) <= '1';
    else
        cmd_fifo_rd(0) <= '0';
    end if;
    
    cmd_fifo_rd(1) <= '0';

    cmd_fifo_read <= cmd_fifo_reads(0);
else
    cmd_fifo_rd(0) <= '0';
    if((ready='1') and (cmd_fifo_empty(1)='0') and (halt_r='0')) then
        cmd_fifo_rd(1) <= '1';
    else
        cmd_fifo_rd(1) <= '0';
    end if;
    cmd_fifo_read <= cmd_fifo_reads(1);
end if;
end process;

----------------
-- Extract x parameters as vector if FPU operates in vector mode
----------------

process(fpu_instruction_r,X,step_r)
variable step_v:unsigned(fpu_vector_depth_c-1 downto 0);
variable x_v:std_logic_vector(15 downto 0);
begin
exe_x <= (others=>(others=>'0'));
if(fpu_instruction_r.X_enable='1') then
    if(fpu_instruction_r.X_by_value='0') then
        if(fpu_instruction_r.X_double='0') then
            step_v := (others=>'0');
            step_v(fpu_vector_depth_c-2 downto 0) := step_r(fpu_vector_depth_c-2 downto 0)+unsigned(fpu_instruction_r.X_addr(fpu_vector_depth_c-1 downto 1));
            FOR I in 0 to fpu_gen_max_c-1 LOOP
                x_v := (others=>'0');
                FOR J in 0 to fpu_vector_width_c/2-1 LOOP
                    if(to_integer(step_v(fpu_vector_depth_c-2 downto 0))=J) then
                        if((16*(J+1)+I*16) <= fpu_data_width_c) then
                            x_v := X((16*(J+1)+I*16)-1 downto (16*J+I*16));
                        end if;
                        exit;
                    end if;
                END LOOP;
                if(fpu_instruction_r.X_type=register2_fpu_set_W_ZFP16) then
                    exe_x(I) <= zfp2float(x_v);
                elsif(fpu_instruction_r.X_type=register2_fpu_set_W_FP16) then
                    exe_x(I) <= fp2float(x_v);
                else
                    exe_x(I) <= x_v & "0000000000000000";
                end if;
            END LOOP;
        else
            step_v := (others=>'0');
            step_v(fpu_vector_depth_c-3 downto 0) := step_r(fpu_vector_depth_c-3 downto 0)+unsigned(fpu_instruction_r.X_addr(fpu_vector_depth_c-1 downto 2));
            FOR I in 0 to fpu_gen_max_c-1 LOOP
                FOR J in 0 to fpu_vector_width_c/4-1 loop
                    if(to_integer(step_v(fpu_vector_depth_c-3 downto 0))=J) then
                        if((32*(J+1)+I*32) <= fpu_data_width_c) then
                            exe_x(I) <= X((32*(J+1)+I*32)-1 downto (32*J+I*32));
                        else
                            exe_x(I) <= (others=>'0');
                        end if;
                        exit;
                    end if;
                end loop;
            END LOOP;
        end if;
    else
        FOR I in 0 to fpu_gen_max_c-1 LOOP
            exe_x(I) <= fpu_instruction_r.X;
        END LOOP;
    end if;
end if;
end process;

----------------
-- Extract Y parameters as vector if FPU operates in vector mode
----------------

process(fpu_instruction_r,Y,step_r)
variable step_v:unsigned(fpu_vector_depth_c-1 downto 0);
variable y_v:std_logic_vector(15 downto 0);
begin
exe_y <= (others=>(others=>'0'));
if(fpu_instruction_r.Y_enable='1') then
    if(fpu_instruction_r.Y_by_value='0') then
        if(fpu_instruction_r.Y_double='0') then
            step_v := (others=>'0');
            step_v(fpu_vector_depth_c-2 downto 0) := step_r(fpu_vector_depth_c-2 downto 0)+unsigned(fpu_instruction_r.Y_addr(fpu_vector_depth_c-1 downto 1));
            FOR I in 0 to fpu_gen_max_c-1 LOOP
                y_v := (others=>'0');
                FOR J in 0 to fpu_vector_width_c/2-1 LOOP
                    if(to_integer(step_v(fpu_vector_depth_c-2 downto 0))=J) then
                        if((16*(J+1)+I*16) <= fpu_data_width_c) then
                            y_v := Y((16*(J+1)+I*16)-1 downto (16*J+I*16));
                        end if;
                        exit;
                    end if;
                END LOOP;
                if(fpu_instruction_r.Y_type=register2_fpu_set_W_ZFP16) then
                    exe_y(I) <= zfp2float(y_v);
                elsif(fpu_instruction_r.Y_type=register2_fpu_set_W_FP16) then
                    exe_y(I) <= fp2float(y_v);
                else
                    exe_y(I) <= y_v & "0000000000000000";
                end if;
            END LOOP;
        else
            step_v := (others=>'0');
            step_v(fpu_vector_depth_c-3 downto 0) := step_r(fpu_vector_depth_c-3 downto 0)+unsigned(fpu_instruction_r.Y_addr(fpu_vector_depth_c-1 downto 2));
            FOR I in 0 to fpu_gen_max_c-1 LOOP
                FOR J in 0 to fpu_vector_width_c/4-1 loop
                    if(to_integer(step_v(fpu_vector_depth_c-3 downto 0))=J) then
                        if((32*(J+1)+I*32) <= fpu_data_width_c) then
                            exe_y(I) <= Y((32*(J+1)+I*32)-1 downto (32*J+I*32));
                        else
                            exe_y(I) <= (others=>'0');
                        end if;
                        exit;
                    end if;
                end loop;
            END LOOP;
        end if;
    else
        FOR I in 0 to fpu_gen_max_c-1 LOOP
            exe_y(I) <= fpu_instruction_r.Y;
        END LOOP;
    end if;
end if;
end process;

----------------
-- Extract B parameters as vector if FPU operates in vector mode
----------------

process(fpu_instruction_r,B,step_r)
variable step_v:unsigned(2 downto 0);
variable b_v:std_logic_vector(15 downto 0);
begin
exe_b <= (others=>(others=>'0'));
if(fpu_instruction_r.B_enable='1') then
    if(fpu_instruction_r.B_by_value='0') then
        if(fpu_instruction_r.B_precision=to_unsigned(2,fpu_instruction_r.B_precision'length)) then
            if(fpu_instruction_r.B_int='0') then
                -- Input is FP16
                step_v := (others=>'0');
                step_v(fpu_vector_depth_c-2 downto 0) := step_r(fpu_vector_depth_c-2 downto 0)+unsigned(fpu_instruction_r.B_addr(fpu_vector_depth_c-1 downto 1));
                FOR I in 0 to fpu_gen_max_c-1 LOOP
                    b_v := (others=>'0');
                    FOR J in 0 to fpu_vector_width_c/2-1 LOOP
                        if(to_integer(step_v(fpu_vector_depth_c-2 downto 0))=J) then
                            if((16*(J+1)+I*16) <= fpu_data_width_c) then
                                b_v := B((16*(J+1)+I*16)-1 downto (16*J+I*16));
                            end if;
                            exit;
                        end if;
                    END LOOP;
                    if(fpu_instruction_r.B_type=register2_fpu_set_W_ZFP16) then
                        exe_b(I) <= zfp2float(b_v);
                    elsif(fpu_instruction_r.B_type=register2_fpu_set_W_FP16) then
                        exe_b(I) <= fp2float(b_v);
                    else
                        exe_b(I) <= b_v & "0000000000000000";
                    end if;
                END LOOP;
            else
                -- Input is INT16
                step_v := (others=>'0');
                step_v(fpu_vector_depth_c-2 downto 0) := step_r(fpu_vector_depth_c-2 downto 0)+unsigned(fpu_instruction_r.B_addr(fpu_vector_depth_c-1 downto 1));
                FOR I in 0 to fpu_gen_max_c-1 LOOP
                    FOR J in 0 to fpu_vector_width_c/2-1 LOOP
                        if(to_integer(step_v(fpu_vector_depth_c-2 downto 0))=J) then
                            if((16*(J+1)+I*16) <= fpu_data_width_c) then
                                exe_b(I)(15 downto 0) <= B((16*(J+1)+I*16)-1 downto (16*J+I*16));
                                exe_b(I)(31 downto 16) <= (others=>B((16*(J+1)+I*16)-1));
                            else
                                exe_b(I) <= (others=>'0');
                            end if;
                            exit;
                        end if;
                    END LOOP;
                END LOOP;
            end if;
        else
            -- Input is FP32
            step_v := (others=>'0');
            step_v(fpu_vector_depth_c-3 downto 0) := step_r(fpu_vector_depth_c-3 downto 0)+unsigned(fpu_instruction_r.B_addr(fpu_vector_depth_c-1 downto 2));
            FOR I in 0 to fpu_gen_max_c-1 LOOP
                FOR J in 0 to fpu_vector_width_c/4-1 loop
                    if(to_integer(step_v(fpu_vector_depth_c-3 downto 0))=J) then
                        if((32*(J+1)+I*32) <= fpu_data_width_c) then
                            exe_b(I) <= B((32*(J+1)+I*32)-1 downto (32*J+I*32));
                        else
                            exe_b(I) <= (others=>'0');
                        end if;
                        exit;
                    end if;
                end loop;
            END LOOP;
        end if;
    else
        FOR I in 0 to fpu_gen_max_c-1 LOOP
            exe_b(I) <= fpu_instruction_r.B;
        END LOOP;
    end if;
end if;
end process;

------
-- Issue read requests to retrieve parameter values
-- Determine which parameters should be prefetched first
------

process(
    sram_read_wait,running_r,
    B_avail,fpu_instruction_r,
    X_avail,
    Y_avail
)
begin
    pending_write <= (others=>'0');
    pending_wrreq <= '0';
    if(sram_read_wait='0') then
        sram_read <= '0';
        sram_rd_addr <= (others=>'0');
    else
        sram_read <= sram_read_r;
        sram_rd_addr <= sram_rd_addr_r;
    end if;
    if(running_r='1' and sram_read_wait='0') then
        if(fpu_instruction_r.C_enable='1' and fpu_instruction_r.C_by_value='0' and fpu_instruction_r.C_pending='0') then
            pending_write(PARM_C) <= not sram_read_wait;
            pending_wrreq <= not sram_read_wait;
            sram_read <= '1';
            sram_rd_addr <= std_logic_vector(fpu_instruction_r.C_addr(sram_depth_c-1 DOWNTO 3)) & "000";
        elsif(fpu_instruction_r.C2_enable='1' and fpu_instruction_r.C2_by_value='0' and fpu_instruction_r.C2_pending='0') then
            pending_write(PARM_C2) <= not sram_read_wait;
            pending_wrreq <= not sram_read_wait;
            sram_read <= '1';
            sram_rd_addr <= std_logic_vector(fpu_instruction_r.C2_addr(sram_depth_c-1 DOWNTO 3)) & "000";
        elsif(fpu_instruction_r.B_enable='1' and (B_avail < X_avail) and (B_avail < Y_avail) and fpu_instruction_r.B_by_value='0') then
            if(B_avail < MAX_CACHE_LEVEL) then
                pending_write(PARM_B) <= not sram_read_wait;
                pending_wrreq <= not sram_read_wait;
                sram_read <= '1';
                sram_rd_addr <= std_logic_vector(fpu_instruction_r.B_addr(sram_depth_c-1 DOWNTO 0));
            end if; 
        elsif(fpu_instruction_r.X_enable='1' and X_avail < Y_avail and fpu_instruction_r.X_by_value='0') then
            if(X_avail < MAX_CACHE_LEVEL) then
                pending_write(PARM_X) <= not sram_read_wait;
                pending_wrreq <= not sram_read_wait;
                sram_read <= '1';
                sram_rd_addr <= std_logic_vector(fpu_instruction_r.X_addr(sram_depth_c-1 DOWNTO 0));
            end if;
        elsif(fpu_instruction_r.Y_enable='1' and fpu_instruction_r.Y_by_value='0') then
            if(Y_avail < MAX_CACHE_LEVEL) then
                pending_write(PARM_Y) <= not sram_read_wait;
                pending_wrreq <= not sram_read_wait;
                sram_read <= '1';
                sram_rd_addr <= std_logic_vector(fpu_instruction_r.Y_addr(sram_depth_c-1 DOWNTO 0));
            end if;
        end if;
    end if;
end process;

-------
-- Getting read data back
-- Forward received data to appropriate FIFO 
-------

process(fpu_readdatavalid_in,pending_read,fpu_instruction_r,fpu_readdata_in)
begin
B_wrreq <= '0';
X_wrreq <= '0';
Y_wrreq <= '0';
C_wrreq <= '0';
C2_wrreq <= '0';
C <= (others=>'0');
C2 <= (others=>'0');
if(fpu_readdatavalid_in='1') then
    if(pending_read(PARM_C)='1') then
        -- Result for C parameter is coming back
        C_wrreq <= '1';
        if(fpu_instruction_r.C_double='0') then
            for I in 0 to fpu_vector_width_c/2-1 loop
                if(to_integer(unsigned(fpu_instruction_r.C_addr(fpu_vector_depth_c-1 downto 1)))=I) then
                    C <= fpu_readdata_in((I+1)*16-1 downto I*16) & "0000000000000000";              
                    exit;
                end if;
            end loop;
        else
            for I in 0 to fpu_vector_width_c/4-1 loop
                if(to_integer(unsigned(fpu_instruction_r.C_addr(fpu_vector_depth_c-1 downto 2)))=I) then
                    C <= fpu_readdata_in((I+1)*32-1 downto I*32);              
                    exit;
                end if;
            end loop;
        end if;
    elsif(pending_read(PARM_C2)='1') then
        -- Result for C2 parameter is coming back
        C2_wrreq <= '1';
        if(fpu_instruction_r.C2_double='0') then
            for I in 0 to fpu_vector_width_c/2-1 loop
                if(to_integer(unsigned(fpu_instruction_r.C2_addr(fpu_vector_depth_c-1 downto 1)))=I) then
                    C2 <= fpu_readdata_in((I+1)*16-1 downto I*16) & "0000000000000000";              
                    exit;
                end if;
            end loop;
        else
            for I in 0 to fpu_vector_width_c/4-1 loop
                if(to_integer(unsigned(fpu_instruction_r.C2_addr(fpu_vector_depth_c-1 downto 2)))=I) then
                    C2 <= fpu_readdata_in((I+1)*32-1 downto I*32);              
                    exit;
                end if;
            end loop;
        end if;
    elsif(pending_read(PARM_B)='1') then
        B_wrreq <= '1';
    elsif(pending_read(PARM_X)='1') then
        X_wrreq <= '1';
    elsif(pending_read(PARM_Y)='1') then
        Y_wrreq <= '1';
    end if;
end if;
end process;

-----
-- Execute commands
-----
process(
    exe,
    halt_r,fpu_exe_r,
    running_r,
    step_r,
    fpu_instruction_r,
    B_empty,X_empty,Y_empty
)
variable step_v:unsigned(fpu_vector_depth_c-1 downto 0);
variable advance_v:unsigned(sram_depth_c-1 downto 0);
variable nstep_v:unsigned(sram_depth_c-1 downto 0);
begin
running <= running_r;
halt <= halt_r and (not fpu_exe_r);
step <= step_r;
B_rdreq <= '0';
X_rdreq <= '0';
Y_rdreq <= '0';
X_rdflush <= '0';
Y_rdflush <= '0';
B_rdflush <= '0';
A_addr <= fpu_instruction_r.A_addr;
if(exe='1') then
    -- TODO This only work for VECTOR=0,1
    if(fpu_instruction_r.VECTOR=to_unsigned(0,fpu_vector_t'length)) then
        nstep_v := step_r+1;
    else
        nstep_v := step_r+fpu_gen_max_c;
    end if;
    if(nstep_v>=fpu_instruction_r.CNT) then
        -- Done...
        running <= '0';
        if(fpu_instruction_r.LAST='1') then
            halt <= '1';
        end if;
    end if;
    step <= nstep_v;
    -- Advance destination address
    if(fpu_instruction_r.opcode=register2_fpu_exe_mac_c or
        fpu_instruction_r.opcode=register2_fpu_exe_reciprocal_c or
        fpu_instruction_r.opcode=register2_fpu_exe_inv_sqrt_c or
        fpu_instruction_r.opcode=register2_fpu_exe_exp_c) then
        advance_v := resize(fpu_instruction_r.A_precision,fpu_instruction_r.A_addr'length);
        if(fpu_instruction_r.VECTOR /= to_unsigned(0,fpu_vector_t'length)) then
            advance_v(advance_v'length-1 downto fpu_gen_depth_c) := advance_v(advance_v'length-fpu_gen_depth_c-1 downto 0);
            advance_v(0) := '0';
        end if;
        A_addr <= fpu_instruction_r.A_addr + advance_v;
    elsif (fpu_instruction_r.opcode=register2_fpu_exe_group_max_c) then
        if(fpu_instruction_r.VECTOR = to_unsigned(0,fpu_vector_t'length)) then
            if((std_logic_vector(step_r) and fpu_instruction_r.C(step_r'length-1 downto 0)) = fpu_instruction_r.C(step_r'length-1 downto 0)) then
                A_addr <= fpu_instruction_r.A_addr + resize(fpu_instruction_r.A_precision,fpu_instruction_r.A_addr'length);
            end if;
        else
            if((std_logic_vector(step_r(step_r'length-1 downto fpu_gen_depth_c)) and fpu_instruction_r.C(step_r'length-1 downto fpu_gen_depth_c)) = fpu_instruction_r.C(step_r'length-1 downto fpu_gen_depth_c)) then
                A_addr <= fpu_instruction_r.A_addr + resize(fpu_instruction_r.A_precision,fpu_instruction_r.A_addr'length);
            end if;
        end if;
    end if;
    if(fpu_instruction_r.X_double='0') then
        step_v := (others=>'0');
        step_v(fpu_vector_depth_c-2 downto 0) := nstep_v(fpu_vector_depth_c-2 downto 0)+unsigned(fpu_instruction_r.X_addr(fpu_vector_depth_c-1 downto 1));
        if(to_integer(step_v(fpu_vector_depth_c-2 downto 0))=0) then
            -- Every 4th step, we fetch new X  parameter
            X_rdreq <= fpu_instruction_r.X_enable and (not fpu_instruction_r.X_by_value);
        end if;
    else
        step_v := (others=>'0');
        step_v(fpu_vector_depth_c-3 downto 0) := nstep_v(fpu_vector_depth_c-3 downto 0)+unsigned(fpu_instruction_r.X_addr(fpu_vector_depth_c-1 downto 2));
        if(to_integer(step_v(fpu_vector_depth_c-3 downto 0))=0) then
            -- Every 4th step, we fetch new X  parameter
            X_rdreq <= fpu_instruction_r.X_enable and (not fpu_instruction_r.X_by_value);
        end if;
    end if;
    if(fpu_instruction_r.Y_double='0') then
        step_v := (others=>'0');
        step_v(fpu_vector_depth_c-2 downto 0) := nstep_v(fpu_vector_depth_c-2 downto 0)+unsigned(fpu_instruction_r.Y_addr(fpu_vector_depth_c-1 downto 1));
        if(to_integer(step_v(fpu_vector_depth_c-2 downto 0))=0) then
            -- Every 4th step, we fetch new Y  parameter
            Y_rdreq <= fpu_instruction_r.Y_enable and (not fpu_instruction_r.Y_by_value);
        end if;
    else
        step_v := (others=>'0');
        step_v(fpu_vector_depth_c-3 downto 0) := nstep_v(fpu_vector_depth_c-3 downto 0)+unsigned(fpu_instruction_r.Y_addr(fpu_vector_depth_c-1 downto 2));
        if(to_integer(step_v(fpu_vector_depth_c-3 downto 0))=0) then
            -- Every 4th step, we fetch new Y  parameter
            Y_rdreq <= fpu_instruction_r.Y_enable and (not fpu_instruction_r.Y_by_value);
        end if;
    end if;
    if(fpu_instruction_r.B_precision=to_unsigned(2,fpu_instruction_r.B_precision'length)) then
        -- This is case of FP16 or INT16
        step_v := (others=>'0');
        step_v(fpu_vector_depth_c-2 downto 0) := nstep_v(fpu_vector_depth_c-2 downto 0)+unsigned(fpu_instruction_r.B_addr(fpu_vector_depth_c-1 downto 1));
        if(to_integer(step_v(fpu_vector_depth_c-2 downto 0))=0) then
            -- Every 2th step, we fetch new B parameter
            B_rdreq <= fpu_instruction_r.B_enable and (not fpu_instruction_r.B_by_value);
        end if;
    else
        -- This is case of FP32
        step_v := (others=>'0');
        step_v(fpu_vector_depth_c-3 downto 0) := nstep_v(fpu_vector_depth_c-3 downto 0)+unsigned(fpu_instruction_r.B_addr(fpu_vector_depth_c-1 downto 2));
        if(to_integer(step_v(fpu_vector_depth_c-3 downto 0))=0) then
            B_rdreq <= fpu_instruction_r.B_enable and (not fpu_instruction_r.B_by_value);
        end if;
    end if;
elsif(running_r='0') then
    -- FPU operation is done. Let empty the FIFO
    X_rdreq <= (not X_empty);
    Y_rdreq <= (not Y_empty);
    B_rdreq <= (not B_empty);
    X_rdflush <= '1';
    Y_rdflush <= '1';
    B_rdflush <= '1';
else
    X_rdreq <= '0';
    Y_rdreq <= '0';
    B_rdreq <= '0';
end if;
end process;

---
-- Write result to SRAM
---

process(fpu_write,fpu_eof,writedata_r,fpu_writedata,fpu_wr_addr,writedata,fpu_wr_precision,fpu_vector)
variable complete_v:std_logic;
begin
    writedata <= writedata_r;
    writebe <= writebe_r;
    if(fpu_write='1') then
        complete_v := '0';
        if(fpu_wr_precision=4) then
            if(fpu_vector=to_unsigned(0,fpu_vector_t'length)) then
                FOR J in 0 to fpu_vector_width_c/4-1 loop
                    if(to_integer(unsigned(fpu_wr_addr(fpu_vector_depth_c-1 downto 2)))=J) then
                        writedata((J+1)*32-1 downto J*32) <= fpu_writedata(0)(31 downto 0);  
                        writebe((J+1)*4-1 downto J*4) <= (others=>'1');
                        if(J=fpu_vector_width_c/4-1) then
                            complete_v := '1';
                        end if;
                        exit;
                    end if;
                end loop;
            else
                FOR I IN 0 TO fpu_gen_max_c-1 LOOP
                    FOR J in 0 to fpu_vector_width_c/8-1 loop
                        if(to_integer(unsigned(fpu_wr_addr(fpu_vector_depth_c-1 downto 2)))=2*J) then
                            writedata(32*(2*J+1)+I*32-1 downto 32*2*J+I*32) <= fpu_writedata(I)(31 downto 0);
                            writebe(4*(2*J+1)+I*4-1 downto 4*2*J+I*4) <= (others=>'1');
                            if(J=fpu_vector_width_c/8-1) then
                                complete_v := '1';
                            end if;
                            exit;
                        end if;
                    end loop;
                END LOOP;
            end if;
        elsif(fpu_wr_precision=2) then
            -- Result is 16-bit, BFLOAT or INT16 expected
            if(fpu_vector=to_unsigned(0,fpu_vector_t'length)) then
                FOR J in 0 to fpu_vector_width_c/2-1 loop
                    if(to_integer(unsigned(fpu_wr_addr(fpu_vector_depth_c-1 downto 1)))=J) then
                        writedata((J+1)*16-1 downto J*16) <= fpu_writedata(0)(31 downto 16);  
                        writebe((J+1)*2-1 downto J*2) <= (others=>'1');
                        if(J=fpu_vector_width_c/2-1) then
                            complete_v := '1';
                        end if;
                        exit;
                    end if;
                end loop;
            else
                FOR I IN 0 TO fpu_gen_max_c-1 LOOP
                    FOR J in 0 to fpu_vector_width_c/4-1 loop
                        if(to_integer(unsigned(fpu_wr_addr(fpu_vector_depth_c-1 downto 1)))=2*J) then
                            writedata(16*(2*J+1)+I*16-1 downto 16*2*J+I*16) <= fpu_writedata(I)(31 downto 16);
                            writebe(2*(2*J+1)+I*2-1 downto 2*2*J+I*2) <= (others=>'1');
                            if(J=fpu_vector_width_c/4-1) then
                                complete_v := '1';
                            end if;
                            exit;
                        end if;
                    end loop;
                END LOOP;
            end if;
        else
            -- Result is 8-bit. INT8 is expected
            if(fpu_vector=to_unsigned(0,fpu_vector_t'length)) then
                FOR J in 0 to fpu_vector_width_c-1 loop
                    if(to_integer(unsigned(fpu_wr_addr(fpu_vector_depth_c-1 downto 0)))=J) then
                        writedata((J+1)*8-1 downto J*8) <= fpu_writedata(0)(7 downto 0);  
                        writebe((J+1)-1 downto J) <= (others=>'1');
                        if(J=fpu_vector_width_c-1) then
                            complete_v := '1';
                        end if;
                        exit;
                    end if;
                end loop;
            else
                FOR I IN 0 to fpu_gen_max_c-1 LOOP
                    FOR J IN 0 to fpu_vector_width_c/2-1 LOOP
                        if(to_integer(unsigned(fpu_wr_addr(fpu_vector_depth_c-1 downto 0)))=2*J) then
                            writedata(8*(2*J+1)+I*8-1 downto 8*2*J+I*8) <= fpu_writedata(I)(7 downto 0);
                            writebe(1*(2*J+1)+I*1-1 downto 1*2*J+I*1) <= (others=>'1');
                            if(J=fpu_vector_width_c/2-1) then
                                complete_v := '1';
                            end if;
                            exit;
                        end if;
                    END LOOP;
                END LOOP;
            end if;
        end if;
        if(fpu_eof='1' or complete_v='1') then
            -- Last ALU response, flush it
            if(writebe=std_logic_vector(to_unsigned(0,writebe'length))) then
                sram_write <= '0';
            else
                sram_write <= '1';
            end if;
            sram_writedata <= writedata;
            if(fpu_eof='1') then
                sram_writebe <= writebe and fpu_last_be;
            else
                sram_writebe <= writebe;
            end if;
            sram_wr_addr <= std_logic_vector(fpu_wr_addr(fpu_wr_addr'length-1 downto fpu_vector_depth_c)) & std_logic_vector(to_unsigned(0,fpu_vector_depth_c));
        else
            -- Save this write request to combine with next write requests
            sram_write <= '0';
            sram_writedata <= (others=>'0');
            sram_writebe <= (others=>'0');
            sram_wr_addr <= (others=>'0');
        end if;
    else
        -- No write to do this time
        sram_write <= '0';
        sram_writedata <= (others=>'0');
        sram_writebe <= (others=>'0');
        sram_wr_addr <= (others=>'0');
    end if;
end process;

------
--- Receive FPU commands from RISCV
--------

process(clock_in,reset_in)
variable busy_v:std_logic;
variable fpu_exe_v:std_logic;
variable fpu_vm_v:std_logic;
variable fpu_exe_pending_v:std_logic_vector(1 downto 0);
begin
    if reset_in = '0' then
        halt_r <= '1';
        rden_r <= '0';
        rresp_r <= (others=>'0');

        fpu_instruction_r.opcode <= (others=>'0');    
        fpu_instruction_r.A_addr <= (others=>'0');
        fpu_instruction_r.B_addr <= (others=>'0');
        fpu_instruction_r.C <= (others=>'0');
        fpu_instruction_r.C_by_value <= '0';
        fpu_instruction_r.C_addr <= (others=>'0');
        fpu_instruction_r.C2 <= (others=>'0');
        fpu_instruction_r.C2_by_value <= '0';
        fpu_instruction_r.C2_addr <= (others=>'0');
        fpu_instruction_r.X_addr <= (others=>'0');
        fpu_instruction_r.Y_addr <= (others=>'0');
        fpu_instruction_r.CNT <= (others=>'0');
        fpu_instruction_r.VECTOR <= (others=>'0');
        fpu_instruction_r.C_pending <= '0';
        fpu_instruction_r.C2_pending <= '0';
        fpu_instruction_r.LAST <= '0';
        fpu_instruction_r.LAST_BE <= (others=>'0');
        fpu_instruction_r.FAST <= '0';
        fpu_instruction_r.B_enable <= '0';
        fpu_instruction_r.C_enable <= '0';
        fpu_instruction_r.C2_enable <= '0';
        fpu_instruction_r.X_enable <= '0';
        fpu_instruction_r.Y_enable <= '0';
        fpu_instruction_r.B_by_value <= '0';
        fpu_instruction_r.X_by_value <= '0';
        fpu_instruction_r.Y_by_value <= '0';
        fpu_instruction_r.B <= (others=>'0');
        fpu_instruction_r.X <= (others=>'0');
        fpu_instruction_r.Y <= (others=>'0');
        fpu_instruction_r.A_precision <= (others=>'0');
        fpu_instruction_r.A_int <= '0';
        fpu_instruction_r.A_floor <= '0';
        fpu_instruction_r.A_abs <= '0';
        fpu_instruction_r.B_precision <= (others=>'0');
        fpu_instruction_r.B_int <= '0';
        fpu_instruction_r.X_double <= '0';
        fpu_instruction_r.Y_double <= '0';
        fpu_instruction_r.C_double <= '0';
        fpu_instruction_r.C2_double <= '0';
        fpu_instruction_r.X_type <= (others=>'0');
        fpu_instruction_r.Y_type <= (others=>'0');
        fpu_instruction_r.B_type <= (others=>'0');

        fpu_next_instruction_r.opcode <= (others=>'0');  
        fpu_next_instruction_r.A_addr <= (others=>'0');
        fpu_next_instruction_r.B_addr <= (others=>'0');
        fpu_next_instruction_r.C <= (others=>'0');
        fpu_next_instruction_r.C_by_value <= '0';
        fpu_next_instruction_r.C_addr <= (others=>'0');
        fpu_next_instruction_r.C2 <= (others=>'0');
        fpu_next_instruction_r.C2_by_value <= '0';
        fpu_next_instruction_r.C2_addr <= (others=>'0');
        fpu_next_instruction_r.X_addr <= (others=>'0');
        fpu_next_instruction_r.Y_addr <= (others=>'0');
        fpu_next_instruction_r.CNT <= (others=>'0');
        fpu_next_instruction_r.VECTOR <= (others=>'0');
        fpu_next_instruction_r.C_pending <= '0';
        fpu_next_instruction_r.C2_pending <= '0';
        fpu_next_instruction_r.LAST <= '0';
        fpu_next_instruction_r.LAST_BE <= (others=>'0');
        fpu_next_instruction_r.FAST <= '0';
        fpu_next_instruction_r.B_enable <= '0';
        fpu_next_instruction_r.C_enable <= '0';
        fpu_next_instruction_r.C2_enable <= '0';
        fpu_next_instruction_r.X_enable <= '0';
        fpu_next_instruction_r.Y_enable <= '0';
        fpu_next_instruction_r.B_by_value <= '0';
        fpu_next_instruction_r.X_by_value <= '0';
        fpu_next_instruction_r.Y_by_value <= '0';
        fpu_next_instruction_r.B <= (others=>'0');
        fpu_next_instruction_r.X <= (others=>'0');  
        fpu_next_instruction_r.Y <= (others=>'0'); 
        fpu_next_instruction_r.A_precision <= (others=>'0');
        fpu_next_instruction_r.A_int <= '0';
        fpu_next_instruction_r.A_floor <= '0';
        fpu_next_instruction_r.A_abs <= '0';
        fpu_next_instruction_r.B_precision <= (others=>'0'); 
        fpu_next_instruction_r.B_int <= '0';
        fpu_next_instruction_r.X_double <= '0';
        fpu_next_instruction_r.Y_double <= '0';
        fpu_next_instruction_r.C_double <= '0';
        fpu_next_instruction_r.C2_double <= '0';
        fpu_next_instruction_r.X_type <= (others=>'0');
        fpu_next_instruction_r.Y_type <= (others=>'0');
        fpu_next_instruction_r.B_type <= (others=>'0');

        B_pending_r <= (others=>'0');
        X_pending_r <= (others=>'0');
        Y_pending_r <= (others=>'0');
        running_r <= '0';
        busy_r <= '0';
        busy_rr <= '0';
        step_r <= (others=>'0');
        writedata_r <= (others=>'0');
        writebe_r <= (others=>'0');
        sram_rd_addr_r <= (others=>'0');
        sram_read_r <= '0';
        sram_wr_addr_r <= (others=>'0');      
        sram_write_r <= '0';
        sram_writedata_r <= (others=>'0');
        sram_writebe_r <= (others=>'0');
        fpu_readdatavalid_r <= '0';
        fpu_readdatavalid_rr <= '0';
        vm_r <= '0';
        fpu_vm_r <= '0';
        fpu_exe_r <= '0';
        fpu_exe_rr <= '0';
        page_vm0_r <= (others=>'0');
        page_vm1_r <= (others=>'0');
        write_flush_r <= '0';
        fpu_exe_pending_r <= (others=>'0');
        fpu_busy_vm_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then

            busy_v := busy_r;
            fpu_exe_v := fpu_exe_r;
            fpu_vm_v := fpu_vm_r;
            fpu_exe_pending_v := fpu_exe_pending_r;

            fpu_readdatavalid_r <= fpu_readdatavalid_in;
            fpu_readdatavalid_rr <= fpu_readdatavalid_r;
            halt_r <= halt;
            running_r <= running;
            step_r <= step;
            sram_rd_addr_r <= sram_rd_addr;
            sram_read_r <= sram_read;
            sram_wr_addr_r <= sram_wr_addr;      
            sram_write_r <= sram_write;
            sram_writedata_r <= sram_writedata;
            sram_writebe_r <= sram_writebe;

            -- Latch in write request so to combine with next write
            -- requests
            if(sram_write='1') then
                writedata_r <= (others=>'0');
                writebe_r <= (others=>'0');
            else
                writedata_r <= writedata;
                writebe_r <= writebe;
            end if;
            if(running_r='1') then
                fpu_instruction_r.A_addr <= A_addr;
            end if;
            if(pending_write(PARM_C)='1') then
                fpu_instruction_r.C_pending <= '1';
                fpu_instruction_r.C_by_value <= '0';
            elsif(C_wrreq='1') then
                fpu_instruction_r.C_pending <= '0';
                fpu_instruction_r.C_by_value <= '1';
                fpu_instruction_r.C <= C;
            end if;
            if(pending_write(PARM_C2)='1') then
                fpu_instruction_r.C2_pending <= '1';
                fpu_instruction_r.C2_by_value <= '0';
            elsif(C2_wrreq='1') then
                fpu_instruction_r.C2_pending <= '0';
                fpu_instruction_r.C2_by_value <= '1';
                fpu_instruction_r.C2 <= C2;
            end if;
            if(B_wrreq = '1' and pending_write(PARM_B)='0') then
                B_pending_r <= B_pending_r-1;
            elsif(pending_write(PARM_B)='1' and B_wrreq='0') then
                B_pending_r <= B_pending_r+1;
            end if;
            if(X_wrreq = '1' and pending_write(PARM_X)='0') then
                X_pending_r <= X_pending_r-1;
            elsif(pending_write(PARM_X)='1' and X_wrreq='0') then
                X_pending_r <= X_pending_r+1;
            end if;
            if(Y_wrreq = '1' and pending_write(PARM_Y)='0') then
                Y_pending_r <= Y_pending_r-1;
            elsif(pending_write(PARM_Y)='1' and Y_wrreq='0') then
                Y_pending_r <= Y_pending_r+1;
            end if;

            if(pending_write(PARM_X)='1') then
                fpu_instruction_r.X_addr <= fpu_instruction_r.X_addr+fpu_data_width_c/8;
            end if;
            if(pending_write(PARM_Y)='1') then
                fpu_instruction_r.Y_addr <= fpu_instruction_r.Y_addr+fpu_data_width_c/8;
            end if;
            if(pending_write(PARM_B)='1') then
                fpu_instruction_r.B_addr <= fpu_instruction_r.B_addr+fpu_data_width_c/8;
            end if;

            -----
            -- Process write commands
            ----

            if(fpu_exe_in='1') then
                if(fpu_exe_vm_in='0') then
                  fpu_exe_pending_v(0) := '1'; 
                else
                  fpu_exe_pending_v(1) := '1'; 
                end if;
            end if;
            if(busy='0') then
                if(fpu_vm_r='0') then
                    if(fpu_exe_pending_r(1)='1') then
                        fpu_exe_v := '1';
                        fpu_vm_v := '1';
                        fpu_exe_pending_v(1) := '0'; 
                    elsif(fpu_exe_pending_r(0)='1') then
                        fpu_exe_v := '1';
                        fpu_vm_v := '0';
                        fpu_exe_pending_v(0) := '0'; 
                    else
                        fpu_exe_v := '0';
                    end if;
                else
                    if(fpu_exe_pending_r(0)='1') then
                        fpu_exe_v := '1';
                        fpu_vm_v := '0';
                        fpu_exe_pending_v(0) := '0'; 
                    elsif(fpu_exe_pending_r(1)='1') then
                        fpu_exe_v := '1';
                        fpu_vm_v := '1';
                        fpu_exe_pending_v(1) := '0'; 
                    else
                        fpu_exe_v := '0';
                    end if;
                end if;
            else
                fpu_exe_v := '0';     
            end if;
            if(bus_write_in='1') then
                if wregno=register_vm_toggle_c then
                    vm_r <= not vm_r;
                end if;
                if wregno=register_fpu_set_mem then
                    if(vm_r='0') then
                        page_vm0_r <= bus_writedata_in(sram_depth_c-1 DOWNTO 0);
                    else
                        page_vm1_r <= bus_writedata_in(sram_depth_c-1 DOWNTO 0);
                    end if;
                end if;
                -- Process write commands
                if(wregno=to_unsigned(register_fpu_set_c,register_t'length)) then
                    if(fpu_set_P=register2_fpu_set_P_A) then
                        fpu_next_instruction_r.A_addr <= page_vm;
                        if(fpu_set_W=register2_fpu_set_W_FP32) then
                            fpu_next_instruction_r.A_precision <= to_unsigned(4,fpu_next_instruction_r.A_precision'length); --FP32
                            fpu_next_instruction_r.A_int <= '0';            
                        elsif(fpu_set_W=register2_fpu_set_W_BFLOAT or 
                              fpu_set_W=register2_fpu_set_W_ZFP16 or
                              fpu_set_W=register2_fpu_set_W_FP16) then
                            fpu_next_instruction_r.A_precision <= to_unsigned(2,fpu_next_instruction_r.A_precision'length); --FP16
                            fpu_next_instruction_r.A_int <= '0';  
                        elsif(fpu_set_W=register2_fpu_set_W_INT16) then
                            fpu_next_instruction_r.A_precision <= to_unsigned(2,fpu_next_instruction_r.A_precision'length); -- INT8
                            fpu_next_instruction_r.A_int <= '1';  
                        else
                            fpu_next_instruction_r.A_precision <= to_unsigned(0,fpu_next_instruction_r.A_precision'length); -- ???
                            fpu_next_instruction_r.A_int <= '0';  
                        end if;
                    elsif(fpu_set_P=register2_fpu_set_P_B) then
                        if(fpu_set_M=register2_fpu_set_M_VALUE) then
                            fpu_next_instruction_r.B_addr <= (others=>'0');
                            if(fpu_set_W=register2_fpu_set_W_BFLOAT ) then
                                fpu_next_instruction_r.B <= bus_writedata_in(bfloat_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_ZFP16 ) then
                                fpu_next_instruction_r.B <= bus_writedata_in(fp12_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_FP16 ) then
                                fpu_next_instruction_r.B <= bus_writedata_in(fp16_t'length-1 downto 0) & "0000000000000000";
                            else
                                fpu_next_instruction_r.B <= bus_writedata_in;
                            end if;
                            fpu_next_instruction_r.B_by_value <= '1';
                        else
                            fpu_next_instruction_r.B_addr <= page_vm;
                            fpu_next_instruction_r.B <= (others=>'0');
                            fpu_next_instruction_r.B_by_value <= '0';
                        end if;
                        if(fpu_set_W=register2_fpu_set_W_INT16) then
                            fpu_next_instruction_r.B_precision <= to_unsigned(2,fpu_next_instruction_r.B_precision'length);                    
                            fpu_next_instruction_r.B_int <= '1';
                        elsif(fpu_set_W=register2_fpu_set_W_BFLOAT or 
                              fpu_set_W=register2_fpu_set_W_ZFP16 or
                              fpu_set_W=register2_fpu_set_W_FP16) then
                            fpu_next_instruction_r.B_precision <= to_unsigned(2,fpu_next_instruction_r.B_precision'length);
                            fpu_next_instruction_r.B_int <= '0';
                        else
                            fpu_next_instruction_r.B_precision <= to_unsigned(4,fpu_next_instruction_r.B_precision'length);
                            fpu_next_instruction_r.B_int <= '0';
                        end if;
                        fpu_next_instruction_r.B_type <= fpu_set_W;
                        fpu_next_instruction_r.B_enable <= '1';
                    elsif(fpu_set_P=register2_fpu_set_P_C) then
                        if(fpu_set_M=register2_fpu_set_M_VALUE) then
                            fpu_next_instruction_r.C_addr <= (others=>'0');
                            if(fpu_set_W=register2_fpu_set_W_BFLOAT) then
                                fpu_next_instruction_r.C <= bus_writedata_in(bfloat_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_ZFP16) then
                                fpu_next_instruction_r.C <= bus_writedata_in(fp12_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_FP16) then
                                fpu_next_instruction_r.C <= bus_writedata_in(fp16_t'length-1 downto 0) & "0000000000000000";
                            else
                                fpu_next_instruction_r.C <= bus_writedata_in(fp32_t'length-1 downto 0);
                            end if;
                            fpu_next_instruction_r.C_by_value <= '1';
                            fpu_next_instruction_r.C_pending <= '0';
                            fpu_next_instruction_r.C_enable <= '1';
                        else
                            fpu_next_instruction_r.C_addr <= page_vm;
                            fpu_next_instruction_r.C <= (others=>'0');
                            fpu_next_instruction_r.C_by_value <= '0';
                            fpu_next_instruction_r.C_pending <= '0';
                            fpu_next_instruction_r.C_enable <= '1';
                        end if;
                        if(fpu_set_W=register2_fpu_set_W_BFLOAT or 
                           fpu_set_W=register2_fpu_set_W_ZFP16 or
                           fpu_set_W=register2_fpu_set_W_FP16) then
                           fpu_next_instruction_r.C_double <= '0';
                        else
                            fpu_next_instruction_r.C_double <= '1';
                        end if;
                    elsif(fpu_set_P=register2_fpu_set_P_C2) then
                        if(fpu_set_M=register2_fpu_set_M_VALUE) then
                            fpu_next_instruction_r.C2_addr <= (others=>'0');
                            if(fpu_set_W=register2_fpu_set_W_BFLOAT) then
                                fpu_next_instruction_r.C2 <= bus_writedata_in(bfloat_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_ZFP16) then
                                fpu_next_instruction_r.C2 <= bus_writedata_in(fp12_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_FP16) then
                                fpu_next_instruction_r.C2 <= bus_writedata_in(fp16_t'length-1 downto 0) & "0000000000000000";
                            else
                                fpu_next_instruction_r.C2 <= bus_writedata_in(fp32_t'length-1 downto 0);
                            end if;
                            fpu_next_instruction_r.C2_by_value <= '1';
                            fpu_next_instruction_r.C2_pending <= '0';
                            fpu_next_instruction_r.C2_enable <= '1';
                        else
                            fpu_next_instruction_r.C2_addr <= page_vm;
                            fpu_next_instruction_r.C2 <= (others=>'0');
                            fpu_next_instruction_r.C2_by_value <= '0';
                            fpu_next_instruction_r.C2_pending <= '0';
                            fpu_next_instruction_r.C2_enable <= '1';
                        end if;
                        if(fpu_set_W=register2_fpu_set_W_BFLOAT or 
                           fpu_set_W=register2_fpu_set_W_ZFP16 or
                           fpu_set_W=register2_fpu_set_W_FP16) then
                            fpu_next_instruction_r.C2_double <= '0';
                        else
                            fpu_next_instruction_r.C2_double <= '1';
                        end if;
                    elsif(fpu_set_P=register2_fpu_set_P_X) then
                        if(fpu_set_M = register2_fpu_set_M_VALUE) then
                            fpu_next_instruction_r.X_addr <= (others=>'0');
                            if(fpu_set_W=register2_fpu_set_W_BFLOAT) then
                                fpu_next_instruction_r.X <= bus_writedata_in(bfloat_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_ZFP16) then
                                fpu_next_instruction_r.X <= bus_writedata_in(fp12_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_FP16) then
                                fpu_next_instruction_r.X <= bus_writedata_in(fp16_t'length-1 downto 0) & "0000000000000000";
                            else
                                fpu_next_instruction_r.X <= bus_writedata_in(fp32_t'length-1 downto 0);
                            end if;
                            fpu_next_instruction_r.X_enable <= '1';
                            fpu_next_instruction_r.X_by_value <= '1';
                        else
                            fpu_next_instruction_r.X_addr <= page_vm;
                            fpu_next_instruction_r.X <= (others=>'0');
                            fpu_next_instruction_r.X_enable <= '1';
                            fpu_next_instruction_r.X_by_value <= '0';
                        end if;
                        if(fpu_set_W = register2_fpu_set_W_BFLOAT or 
                           fpu_set_W = register2_fpu_set_W_ZFP16 or
                           fpu_set_W = register2_fpu_set_W_FP16 ) then
                            fpu_next_instruction_r.X_double <= '0';
                        else
                            fpu_next_instruction_r.X_double <= '1';
                        end if;
                        fpu_next_instruction_r.X_type <= fpu_set_W;
                    elsif(fpu_set_P=register2_fpu_set_P_Y) then
                        if(fpu_set_M = register2_fpu_set_M_VALUE) then
                            fpu_next_instruction_r.Y_addr <= (others=>'0');
                            if(fpu_set_W=register2_fpu_set_W_BFLOAT) then
                                fpu_next_instruction_r.Y <= bus_writedata_in(bfloat_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_ZFP16) then
                                fpu_next_instruction_r.Y <= bus_writedata_in(fp12_t'length-1 downto 0) & "0000000000000000";
                            elsif(fpu_set_W=register2_fpu_set_W_FP16) then
                                fpu_next_instruction_r.Y <= bus_writedata_in(fp16_t'length-1 downto 0) & "0000000000000000";
                            else
                                fpu_next_instruction_r.Y <= bus_writedata_in(fp32_t'length-1 downto 0);
                            end if;
                            fpu_next_instruction_r.Y_enable <= '1';
                            fpu_next_instruction_r.Y_by_value <= '1';
                        else
                            fpu_next_instruction_r.Y_addr <= page_vm;
                            fpu_next_instruction_r.Y <= (others=>'0');
                            fpu_next_instruction_r.Y_enable <= '1';
                            fpu_next_instruction_r.Y_by_value <= '0';
                        end if;
                        fpu_next_instruction_r.Y_type <= fpu_set_W;
                        if(fpu_set_W = register2_fpu_set_W_BFLOAT or 
                          fpu_set_W = register2_fpu_set_W_ZFP16 or
                          fpu_set_W = register2_fpu_set_W_FP16) then
                            fpu_next_instruction_r.Y_double <= '0';
                        else
                            fpu_next_instruction_r.Y_double <= '1';
                        end if;
                    elsif(fpu_set_P=register2_fpu_set_P_CNT) then
                        fpu_next_instruction_r.CNT <= unsigned(bus_writedata_in(sram_depth_c-1 downto 0));
                        fpu_next_instruction_r.VECTOR <= to_unsigned(0,fpu_vector_t'length);
                        fpu_next_instruction_r.LAST_BE <= (others=>'1');
                    elsif(fpu_set_P=register2_fpu_set_P_CNTV) then
                        fpu_next_instruction_r.CNT <= unsigned(bus_writedata_in(sram_depth_c-1 downto 0));
                        fpu_next_instruction_r.VECTOR <= to_unsigned(1,fpu_vector_t'length);
                        fpu_next_instruction_r.LAST_BE <= (others=>'1');
                    end if;
                end if;
            end if;

            if(cmd_fifo_rd/="00") then
                running_r <= '1';
                busy_v := '1';
                step_r <= (others=>'0');
                fpu_instruction_r <= fpu_instruction;
            end if;

            if(exe='1' and eof='1' and (fpu_instruction_r.LAST='1' or fpu_instruction_r.FAST='0')) then
                write_flush_r <= '1';
            elsif(fpu_eof='1' and fpu_write='1' and (fpu_last='1' or fpu_fast='0')) then
                write_flush_r <= '0';
            end if;

            if(cmd_fifo_we/="00") then
                -- Clear for next FPU instruction
                fpu_next_instruction_r.B_enable <= '0';
                fpu_next_instruction_r.C2_enable <= '0';
                fpu_next_instruction_r.C_enable <= '0';
                fpu_next_instruction_r.X_enable <= '0';
                fpu_next_instruction_r.Y_enable <= '0';
            end if;

            if(fpu_write='1' and fpu_eof='1' and fpu_last='1') then
                busy_v := '0';
            end if;

            ------
            -- Process read commands
            ------

            if(bus_read_in='1') then
                -- Process read commands
                if(rregno = to_unsigned(register_fpu_get_status_c,register_t'length)) then
                    rden_r <= '1';
                    rresp_r(rresp_r'length-1 downto 1) <= (others=>'0');
                    rresp_r(0) <= busy_r;
                else
                    rden_r <= '0';
                end if;
            else
                rden_r <= '0';
            end if;
            busy_rr <= busy_r;
            busy_r <= busy_v;
            fpu_exe_rr <= fpu_exe_r;
            fpu_exe_r <= fpu_exe_v;
            fpu_vm_r <= fpu_vm_v;
            fpu_exe_pending_r <= fpu_exe_pending_v;
            fpu_busy_vm_r(0) <= ((busy_v or busy_r or fpu_exe_v or fpu_exe_r) and (not fpu_vm_v)) or fpu_exe_pending_v(0);
            fpu_busy_vm_r(1) <= ((busy_v or busy_r or fpu_exe_v or fpu_exe_r) and (fpu_vm_v)) or fpu_exe_pending_v(1);

        end if;
    end if;
end process;
END behavior;
