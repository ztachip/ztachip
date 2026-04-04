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
-- FPU operates in vector mode
-- Results from each vector unit for aggregate functions (SUM/MAX) are combined here
---
--------------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

ENTITY falu_vector IS
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
        SIGNAL B_in                 : IN fp32s_t(fpu_gen_max_c-1 downto 0);
        SIGNAL C_in                 : IN fp32_t;
        SIGNAL C2_in                : IN fp32_t;
        SIGNAL X_in                 : IN fp32s_t(fpu_gen_max_c-1 downto 0);
        SIGNAL Y_in                 : IN fp32s_t(fpu_gen_max_c-1 downto 0);

        SIGNAL output_ena_out       : OUT STD_LOGIC;
        SIGNAL output_opcode_out    : OUT fpu_opcode_t;
        SIGNAL output_eof_out       : OUT STD_LOGIC;
        SIGNAL output_last_out      : OUT STD_LOGIC;
        SIGNAL output_last_be_out   : OUT STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
        SIGNAL output_fast_out      : OUT STD_LOGIC;
        SIGNAL output_vector_out    : OUT fpu_vector_t;
        SIGNAL output_addr_out      : OUT unsigned(sram_depth_c-1 DOWNTO 0);
        SIGNAL output_precision_out : OUT unsigned(2 downto 0);
        SIGNAL output_out           : OUT fp32s_t(fpu_gen_max_c-1 downto 0)
    );
END falu_vector;

ARCHITECTURE behavior OF falu_vector IS
constant AGGREGATE_LATENCY:integer:=4; -- This is the max latency of all aggregate functions
constant SUM_LATENCY:integer:=4;
constant MAX_LATENCY:integer:=2;
SIGNAL output_ena:STD_LOGIC;
SIGNAL output_opcode:fpu_opcode_t;
SIGNAL output_opcode_delay:fpu_opcode_t;
SIGNAL output_eof:STD_LOGIC;
SIGNAL output_last:STD_LOGIC;
SIGNAL output_last_be:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
SIGNAL output_fast:STD_LOGIC;
SIGNAL output_vector:fpu_vector_t;
SIGNAL output_addr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL output_precision:unsigned(2 downto 0);
SIGNAL output:fp32s_t(fpu_gen_max_c-1 downto 0);
SIGNAL output_delay:fp32s_t(fpu_gen_max_c-1 downto 0);
SIGNAL output_vector_delay:fpu_vector_t;
SIGNAL sum:fp32_t;
SIGNAL max:fp32_t;
SIGNAL C2:fp32s_t(fpu_gen_max_c-1 downto 0);
SIGNAL output_last_be_delay:STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
SIGNAL step:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL C:fp32_t;
BEGIN

output_opcode_out <= output_opcode_delay;

output_vector_out <= (others=>'0') when (output_opcode_delay=register2_fpu_exe_fma_c or
                                        output_opcode_delay=register2_fpu_exe_sum_c or
                                        output_opcode_delay=register2_fpu_exe_max_c or
                                        output_opcode_delay=register2_fpu_exe_group_max_c)
                                    else
                                        output_vector_delay;

process(opcode_in,input_vector_in,step_in,C_in)
begin
    if(opcode_in=register2_fpu_exe_group_max_c) then
        if(input_vector_in /= to_unsigned(0,input_vector_in'length)) then
            step(step'length-1 downto step'length-fpu_gen_depth_c) <= (others=>'0');
            step(step'length-1-fpu_gen_depth_c downto 0) <= step_in(step_in'length-1 downto fpu_gen_depth_c);
            C(C'length-1 downto C'length-fpu_gen_depth_c) <= (others=>'0');
            C(C'length-1-fpu_gen_depth_c downto 0) <= C_in(C_in'length-1 downto fpu_gen_depth_c);
        else
            step <= step_in;
            C <= C_in;
        end if;
    else
        step <= step_in;
        C <= C_in;
    end if;
end process;

GEN_FPU:
FOR I IN 0 TO fpu_gen_max_c-1 GENERATE
falu_core_i : falu_core
    GENERIC MAP(
        INSTANCE => I
    )
    PORT MAP(
        clock_in => clock_in,
        reset_in => reset_in,
        step_in => step,
        opcode_in => opcode_in,
        input_ena_in => input_ena_in,
        input_eof_in => input_eof_in,
        input_last_in => input_last_in,
        input_last_be_in => input_last_be_in,
        input_fast_in => input_fast_in,
        input_vector_in => input_vector_in,
        A_addr => A_addr,
        A_precision => A_precision,
        A_int => A_int,
        A_floor => A_floor,
        A_abs => A_abs,
        B_in => B_in(I),
        C_in => C,
        C2_in => C2(I),
        X_in => X_in(I),
        Y_in => Y_in(I),
        output_ena_out => output_ena,
        output_opcode_out => output_opcode,
        output_addr_out => output_addr,
        output_precision_out => output_precision,
        output_out => output(I),
        output_eof_out => output_eof,
        output_last_out => output_last,
        output_last_be_out => output_last_be,
        output_fast_out => output_fast,
        output_vector_out => output_vector
    );
END GENERATE GEN_FPU;

delay1_i:delay
    generic map(
        DEPTH=>AGGREGATE_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_ena,
        out_out=>output_ena_out,
        enable_in=>'1'
    );

delay2_i:delay
    generic map(
        DEPTH=>AGGREGATE_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_eof,
        out_out=>output_eof_out,
        enable_in=>'1'
    );

delay3_i:delay
    generic map(
        DEPTH=>AGGREGATE_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_last,
        out_out=>output_last_out,
        enable_in=>'1'
    );

delay4_i:delayv
    generic map(
        DEPTH=>AGGREGATE_LATENCY,
        SIZE=>fpu_data_width_c/8
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_last_be,
        out_out=>output_last_be_delay,
        enable_in=>'1'
    );

delay5_i:delay
    generic map(
        DEPTH=>AGGREGATE_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_fast,
        out_out=>output_fast_out,
        enable_in=>'1'
    );

delay6_i:delayi
    generic map(
        DEPTH=>AGGREGATE_LATENCY,
        SIZE=>fpu_vector_t'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_vector,
        out_out=>output_vector_delay,
        enable_in=>'1'
    );

delay7_i:delayi
    generic map(
        DEPTH=>AGGREGATE_LATENCY,
        SIZE=>sram_depth_c
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_addr,
        out_out=>output_addr_out,
        enable_in=>'1'
    );

delay8_i:delayi
    generic map(
        DEPTH=>AGGREGATE_LATENCY,
        SIZE=>output_precision_out'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_precision,
        out_out=>output_precision_out,
        enable_in=>'1'
    );

GEN_DELAY:
FOR I in 0 to fpu_gen_max_c-1 GENERATE
delay9_i:delayv
    generic map(
        DEPTH=>AGGREGATE_LATENCY,
        SIZE=>fp32_t'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output(I),
        out_out=>output_delay(I),
        enable_in=>'1'
    );
END GENERATE GEN_DELAY;

delay10_i:delayi
    generic map(
        DEPTH=>AGGREGATE_LATENCY,
        SIZE=>fpu_opcode_t'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_opcode,
        out_out=>output_opcode_delay,
        enable_in=>'1'
    );

stage_3: FP32_ADDSUB
    generic map(
        LATENCY=>AGGREGATE_LATENCY
    )
    port map(
        reset_in => reset_in,
        clock_in => clock_in,
        add_sub_in => '0', -- Do addition
        x1_in => output(0),
        x2_in => output(1),
        y_out => sum
    ); 

max_i:fpmax
    generic map(
        LATENCY=>AGGREGATE_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        x1_in=>output(0),
        x2_in=>output(1),
        y_out=>max
    );

process(output_opcode_delay,sum,output_delay,output_last_be_delay)
begin
if((output_opcode_delay=register2_fpu_exe_fma_c or output_opcode_delay=register2_fpu_exe_sum_c) 
    and output_vector_delay/=0) then
    FOR I in 0 to fpu_gen_max_c-1 LOOP
        output_out(I) <= sum;
    END LOOP;
    output_last_be_out <= (others=>'1');
elsif((output_opcode_delay=register2_fpu_exe_max_c or output_opcode_delay=register2_fpu_exe_group_max_c) 
    and output_vector_delay/=0) then
    FOR I in 0 to fpu_gen_max_c-1 LOOP
        output_out(I) <= max;
    END LOOP;
    output_last_be_out <= (others=>'1');
else
    output_out <= output_delay; 
    output_last_be_out <= output_last_be_delay;
end if;
end process;

process(C2_in)
begin
C2(0) <= C2_in;
FOR I in 1 to fpu_gen_max_c-1 LOOP
    C2(I) <= (others=>'0');
END LOOP;
end process;

END behavior;
