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

------------------------------------------------------------------------------
--
-- FPU architecture has 2 stages in concatenation: stage1 and stage2

-- STAGE1:
-- stage1 implments element-wise computing
--
-- STAGE2:
-- stage2 takes result from stage1 to perform aggregate function of the results
-- of stage1. Aggregate functions include MAX,SUM,GROUP_SUM
-- But if the aggregate functions apply directly to input, then input are fed 
-- directly to stage2, skipping stage1
--
--------------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

ENTITY falu_core IS
    GENERIC (
        INSTANCE:integer
    );
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        SIGNAL step_in              : IN unsigned(sram_depth_c-1 DOWNTO 0);
        SIGNAL opcode_in            : IN fpu_opcode_t;
        SIGNAL input_ena_in         : IN STD_LOGIC;
        SIGNAL input_eof_in         : IN STD_LOGIC;
        SIGNAL input_last_in        : IN STD_LOGIC;
        SIGNAL input_last_be_in     : IN STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
        SIGNAL input_fast_in        : IN STD_LOGIC;
        SIGNAL input_vector_in      : IN fpu_vector_t;
        SIGNAL A_addr               : IN unsigned(sram_depth_c-1 DOWNTO 0);
        SIGNAL A_precision          : IN unsigned(2 downto 0);
        SIGNAL A_int                : IN STD_LOGIC;
        SIGNAL A_floor              : IN STD_LOGIC;
        SIGNAL A_abs                : IN STD_LOGIC;
        SIGNAL B_in                 : IN fp32_t;
        SIGNAL C_in                 : IN fp32_t;
        SIGNAL C2_in                : IN fp32_t;
        SIGNAL X_in                 : IN fp32_t;
        SIGNAL Y_in                 : IN fp32_t;

        SIGNAL output_ena_out       : OUT STD_LOGIC;
        SIGNAL output_opcode_out    : OUT fpu_opcode_t;
        SIGNAL output_eof_out       : OUT STD_LOGIC;
        SIGNAL output_last_out      : OUT STD_LOGIC;
        SIGNAL output_last_be_out   : OUT STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
        SIGNAL output_fast_out      : OUT STD_LOGIC;
        SIGNAL output_vector_out    : OUT fpu_vector_t;
        SIGNAL output_addr_out      : OUT unsigned(sram_depth_c-1 DOWNTO 0);
        SIGNAL output_precision_out : OUT unsigned(2 downto 0);
        SIGNAL output_out           : OUT fp32_t
    );
END falu_core;

ARCHITECTURE behavior OF falu_core IS

SIGNAL alu_output_ena:STD_LOGIC;
SIGNAL alu_output_step:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL alu_output_opcode:fpu_opcode_t;
SIGNAL alu_output_eof:STD_LOGIC;
SIGNAL alu_output_last:STD_LOGIC;
SIGNAL alu_output_last_be:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
SIGNAL alu_output_fast:STD_LOGIC;
SIGNAL alu_output_vector:fpu_vector_t;
SIGNAL alu_output_addr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL alu_output_precision:unsigned(2 downto 0);
SIGNAL alu_output:fp32_t;

SIGNAL alu2_output_ena:STD_LOGIC;
SIGNAL alu2_output_step:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL alu2_output_opcode:fpu_opcode_t;
SIGNAL alu2_output_eof:STD_LOGIC;
SIGNAL alu2_output_last:STD_LOGIC;
SIGNAL alu2_output_last_be:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
SIGNAL alu2_output_fast:STD_LOGIC;
SIGNAL alu2_output_vector:fpu_vector_t;
SIGNAL alu2_output_addr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL alu2_output_precision:unsigned(2 downto 0);
SIGNAL alu2_output:fp32_t;

SIGNAL alu2_step:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL alu2_opcode:fpu_opcode_t;
SIGNAL alu2_ena:STD_LOGIC;
SIGNAL alu2_eof:STD_LOGIC;
SIGNAL alu2_abs:STD_LOGIC;
SIGNAL alu2_last:STD_LOGIC;
SIGNAL alu2_last_be:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
SIGNAL alu2_fast:STD_LOGIC;
SIGNAL alu2_vector:fpu_vector_t;
SIGNAL alu2_addr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL alu2_precision:unsigned(2 downto 0);

SIGNAL alu_output_C2:fp32_t;
SIGNAL alu2_C2:fp32_t;
SIGNAL alu2_B:fp32_t;

SIGNAL alu_step:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL alu_opcode:fpu_opcode_t;
SIGNAL alu_input_ena:STD_LOGIC;
SIGNAL alu_input_eof:STD_LOGIC;
SIGNAL alu_input_last:STD_LOGIC;
SIGNAL alu_input_last_be:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 DOWNTO 0);
SIGNAL alu_input_fast:STD_LOGIC;
SIGNAL alu_input_vector:fpu_vector_t;

SIGNAL step_r:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL opcode_r:fpu_opcode_t;
SIGNAL input_ena_r:STD_LOGIC;
SIGNAL input_eof_r:STD_LOGIC;
SIGNAL input_last_r:STD_LOGIC;
SIGNAL input_last_be_r:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 DOWNTO 0);
SIGNAL input_fast_r:STD_LOGIC;
SIGNAL input_vector_r:fpu_vector_t;
SIGNAL A_addr_r:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL A_precision_r:unsigned(2 downto 0);
SIGNAL A_int_r:STD_LOGIC;
SIGNAL A_floor_r:STD_LOGIC;
SIGNAL A_abs_r:STD_LOGIC;
SIGNAL B_r:fp32_t;
SIGNAL C_r:fp32_t;
SIGNAL C2_r:fp32_t;
SIGNAL X_r:fp32_t;
SIGNAL Y_r:fp32_t;

BEGIN

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        step_r <= (others=>'0');
        opcode_r <= (others=>'0');
        input_ena_r <= '0';
        input_eof_r <= '0';
        input_last_r <= '0';
        input_last_be_r <= (others=>'0');
        input_fast_r <= '0';
        input_vector_r <= (others=>'0');
        A_addr_r <= (others=>'0');
        A_precision_r <= (others=>'0');
        A_floor_r <= '0';
        A_abs_r <= '0';
        A_int_r <= '0';
        B_r <= (others=>'0');
        C_r <= (others=>'0');
        C2_r <= (others=>'0');
        X_r <= (others=>'0');
        Y_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            step_r <= step_in;
            opcode_r <= opcode_in;
            input_ena_r <= input_ena_in;
            input_eof_r <= input_eof_in;
            input_last_r <= input_last_in;
            input_last_be_r <= input_last_be_in;
            input_fast_r <= input_fast_in;
            input_vector_r <= input_vector_in;
            A_addr_r <= A_addr;
            A_precision_r <= A_precision;
            A_floor_r <= A_floor;
            A_abs_r <= A_abs;
            A_int_r <= A_int;
            B_r <= B_in;
            C_r <= C_in;
            C2_r <= C2_in;
            X_r <= X_in;
            Y_r <= Y_in;
        end if;
    end if;
end process;

process(input_ena_r,B_r,alu_output,
        step_r,opcode_r,input_eof_r,input_last_be_r,
        input_last_r,input_fast_r,input_vector_r,A_addr_r,A_precision_r,
        alu_output_step,alu_output_ena,
        alu_output_eof,alu_output_opcode,alu_output_last,alu_output_last_be,alu_output_fast,alu_output_vector,
        alu_output_addr,alu_output_precision )
begin
if(input_ena_r='1' and 
    (opcode_r=register2_fpu_exe_sum_c or opcode_r=register2_fpu_exe_max_c or opcode_r=register2_fpu_exe_group_max_c)) then
    alu_step <= (others=>'0');
    alu_opcode <= (others=>'0');
    alu_input_ena <= '0';
    alu_input_eof <= '0';
    alu_input_last <= '0';
    alu_input_last_be <= (others=>'0');
    alu_input_fast <= '0';
    alu_input_vector <= (others=>'0');
else
    alu_step <= step_r;
    alu_opcode <= opcode_r;
    alu_input_ena <= input_ena_r;
    alu_input_eof <= input_eof_r;
    alu_input_last <= input_last_r;
    alu_input_last_be <= input_last_be_r;
    alu_input_fast <= input_fast_r;
    alu_input_vector <= input_vector_r;
end if;

if(input_ena_r='1' and 
    (opcode_r=register2_fpu_exe_sum_c or opcode_r=register2_fpu_exe_max_c or opcode_r=register2_fpu_exe_group_max_c)) then
    alu2_step <= step_r;
    alu2_opcode <= opcode_r;
    alu2_ena <= input_ena_r;
    alu2_eof <= input_eof_r;
    alu2_abs <= A_abs_r;
    alu2_last <= input_last_r;
    alu2_last_be <= input_last_be_r;
    alu2_fast <= input_fast_r;
    alu2_vector <= input_vector_r;
    alu2_addr <= A_addr_r;
    alu2_precision <= A_precision_r;
    alu2_C2 <= C_r;
    alu2_B <= B_r;
elsif(alu_output_ena='1' and alu_output_opcode=register2_fpu_exe_fma_c) then
    alu2_step <= alu_output_step;
    alu2_opcode <= alu_output_opcode;
    alu2_ena <= alu_output_ena;
    alu2_eof <= alu_output_eof;
    alu2_abs <= '0';
    alu2_last <= alu_output_last;
    alu2_last_be <= alu_output_last_be;
    alu2_fast <= alu_output_fast;
    alu2_vector <= alu_output_vector;
    alu2_addr <= alu_output_addr;
    alu2_precision <= alu_output_precision;
    alu2_C2 <= alu_output_C2;
    alu2_B <= alu_output;
else
    alu2_step <= (others=>'0');
    alu2_opcode <= (others=>'0');
    alu2_ena <= '0';
    alu2_eof <= '0';
    alu2_abs <= '0';
    alu2_last <= '0';
    alu2_last_be <= (others=>'0');
    alu2_fast <= '0';
    alu2_vector <= (others=>'0');
    alu2_addr <= (others=>'0');
    alu2_precision <= (others=>'0');
    alu2_C2 <= (others=>'0');
    alu2_B <= (others=>'0');
end if;
end process;

process(alu2_output_ena,alu2_output_eof,alu2_output_opcode,alu2_output_last,alu2_output_last_be,
        alu2_output_fast,alu2_output_vector,alu2_output_addr,alu2_output_precision,
        alu2_output,alu_output_ena,alu_output_eof,alu_output_opcode,
        alu_output_last,alu_output_last_be,alu_output_fast,alu_output_vector,alu_output_addr,
        alu_output_precision,alu_output)
begin
if(INSTANCE=0) then
    if(alu2_output_ena='1') then
        output_ena_out <= alu2_output_ena;
        output_eof_out <= alu2_output_eof;
        output_opcode_out <= alu2_output_opcode;
        output_last_out <= alu2_output_last;
        output_last_be_out <= alu2_output_last_be;
        output_fast_out <= alu2_output_fast;
        output_vector_out <= alu2_output_vector;
        output_addr_out <= alu2_output_addr;
        output_precision_out <= alu2_output_precision;
    elsif(alu_output_ena='1' and alu_output_opcode /= register2_fpu_exe_fma_c) then
        output_ena_out <= alu_output_ena;
        output_eof_out <= alu_output_eof;
        output_opcode_out <= alu_output_opcode;
        output_last_out <= alu_output_last;
        output_last_be_out <= alu_output_last_be;
        output_fast_out <= alu_output_fast;
        output_vector_out <= alu_output_vector;
        output_addr_out <= alu_output_addr;
        output_precision_out <= alu_output_precision;
    else
        output_ena_out <= '0';
        output_eof_out <= '0';
        output_opcode_out <= (others=>'0');
        output_last_out <= '0';
        output_last_be_out <= (others=>'0');
        output_fast_out <= '0';
        output_vector_out <= (others=>'0');
        output_addr_out <= (others=>'0');
        output_precision_out <= (others=>'0');
    end if;
else
    -- This FPU is just part of a FPU vector.
    output_ena_out <= 'Z';
    output_eof_out <= 'Z';
    output_opcode_out <= (others=>'Z');
    output_last_out <= 'Z';
    output_last_be_out <= (others=>'Z');
    output_fast_out <= 'Z';
    output_vector_out <= (others=>'Z');
    output_addr_out <= (others=>'Z');
    output_precision_out <= (others=>'Z');
end if;

if(alu2_output_ena='1') then
    output_out <= alu2_output;
elsif(alu_output_ena='1' and alu_output_opcode /= register2_fpu_exe_fma_c) then
    output_out <= alu_output;
else
    output_out <= (others=>'0');
end if;

end process;

-----
-- stage1
----

falu_i: falu
    port map(
        clock_in => clock_in,
        reset_in => reset_in,
        step_in => alu_step,
        opcode_in => alu_opcode,
        input_ena_in => alu_input_ena,
        input_eof_in => alu_input_eof,
        input_last_in => alu_input_last,
        input_last_be_in => alu_input_last_be,
        input_fast_in => alu_input_fast,
        input_vector_in => alu_input_vector,
        A_addr => A_addr_r,
        A_precision => A_precision_r,
		A_int => A_int_r,
        A_floor => A_floor_r,
        A_abs => A_abs_r,
        B_in => B_r,
        C_in => C_r,
        C2_in => C2_r,
        X_in => X_r,
        Y_in => Y_r,
        output_ena_out => alu_output_ena,
        output_step_out => alu_output_step,
        output_opcode_out => alu_output_opcode,
        output_eof_out => alu_output_eof,
        output_last_out => alu_output_last,
        output_last_be_out => alu_output_last_be,
        output_fast_out => alu_output_fast,
        output_vector_out => alu_output_vector,
        output_addr_out => alu_output_addr,
        output_precision_out => alu_output_precision,
        output_out => alu_output,
        output_C2_out => alu_output_C2
    );

----
-- stage2
-----

falu2_i: falu2
    port map(
        clock_in => clock_in,
        reset_in => reset_in,
        step_in => alu2_step,
        opcode_in => alu2_opcode,
        input_ena_in => alu2_ena,
        input_eof_in => alu2_eof,
        input_last_in => alu2_last,
        input_last_be_in => alu2_last_be,
        input_fast_in => alu2_fast,
        input_vector_in => alu2_vector,
        A_addr => alu2_addr,
        A_precision => alu2_precision,
        A_floor => '0',
        A_abs => alu2_abs,
        B_in => alu2_B,
        C_in => alu2_C2,
        X_in => (others=>'0'),
        Y_in => (others=>'0'),
        output_ena_out => alu2_output_ena,
        output_eof_out => alu2_output_eof,
        output_opcode_out => alu2_output_opcode,
        output_last_out => alu2_output_last,
        output_last_be_out => alu2_output_last_be,
        output_fast_out => alu2_output_fast,
        output_vector_out => alu2_output_vector,
        output_addr_out => alu2_output_addr,
        output_precision_out => alu2_output_precision,
        output_out => alu2_output
    );

END behavior;
