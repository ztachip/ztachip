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
-- This component implements second stage of the FPU pipeline
-- Implement aggregate functions
-- Implement these functions
--     SUM(x(i)): Summation of all input data, only 1 value produced
--     MAX(x(i)): Max value of all input data, only 1 value produced
--     MAX_GROUP(x(i)) : Max for a group of input, N/group_size number of values are produced
--
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY falu2 IS
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
        SIGNAL A_floor              : IN STD_LOGIC;
        SIGNAL A_abs                : IN STD_LOGIC;
        SIGNAL B_in                 : IN fp32_t;
        SIGNAL C_in                 : IN fp32_t;
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
END falu2;

ARCHITECTURE behavior OF falu2 IS

constant MUL_LATENCY:integer:=4;

constant ADD_LATENCY:integer:=4;

constant MAX_LATENCY:integer:=2;

constant SUM_LATENCY:integer:=ADD_LATENCY;

constant LATENCY:integer:=(2*MUL_LATENCY+ADD_LATENCY)+1; -- Computing_stage_delay+output_stage_delay

SIGNAL B:fp32_t;
SIGNAL opcode_delay:fpu_opcode_t;
SIGNAL output_r:fp32_t;
SIGNAL B_r:fp32_t;

SIGNAL step_sum_delay:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL output_ena_delay:std_logic;
SIGNAL output_ena_r:std_logic;

SIGNAL B_sum2:fp32_t;
SIGNAL B_sum2_r:fp32_t;
SIGNAL B_sum2_rr:fp32_t;
SIGNAL B_sum2_rrr:fp32_t;
SIGNAL B_sum2_rrrr:fp32_t;
SIGNAL B_sum1:fp32_t;
SIGNAL B_sum1_r:fp32_t;
SIGNAL B_sum1_rr:fp32_t;
SIGNAL B_sum3_r:fp32_t;
SIGNAL B_sum3_rr:fp32_t;
SIGNAL B_sum3_rrr:fp32_t;
SIGNAL B_sum3_rrrr:fp32_t;
SIGNAL B_sum3:fp32_t;
SIGNAL sum_x1:fp32_t;
SIGNAL sum_init_delay:fp32_t;

SIGNAL B2:fp32_t;
SIGNAL B_max:fp32_t;
SIGNAL B_maxdelay:fp32_t;
SIGNAL B_max2:fp32_t;
SIGNAL end_max_group:std_logic;
SIGNAL end_max_group_delay:std_logic;
SIGNAL B1_max:fp32_t;
SIGNAL B2_max:fp32_t;

SIGNAL opcode_r:fpu_opcode_t;
SIGNAL opcode_rr:fpu_opcode_t;
SIGNAL opcode_rrr:fpu_opcode_t;
SIGNAL C_r:fp32_t;
SIGNAL C_rr:fp32_t;
SIGNAL C_rrr:fp32_t;
SIGNAL step_r:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL step_rr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL step_rrr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL A_abs_r:STD_LOGIC;
SIGNAL A_abs_rr:STD_LOGIC;
SIGNAL A_abs_rrr:STD_LOGIC;

BEGIN

B <= B_in when (input_ena_in='1') else (others=>'0');

output_out <= output_r;

output_ena_out <= output_ena_r;

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        B_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            B_r <= B;
        end if;
    end if;
end process;

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        B_sum1_r <= (others=>'0');
        B_sum1_rr <= (others=>'0');
        B_sum3_r <= (others=>'0');
        B_sum3_rr <= (others=>'0');
        B_sum3_rrr <= (others=>'0');
        B_sum3_rrrr <= (others=>'0');
        B_sum2_r <= (others=>'0');
        B_sum2_rr <= (others=>'0');
        B_sum2_rrr <= (others=>'0'); 
        B_sum2_rrrr <= (others=>'0'); 
        opcode_r <= (others=>'0');
        opcode_rr <= (others=>'0');
        opcode_rrr <= (others=>'0');
        C_r <= (others=>'0');
        C_rr <= (others=>'0');
        C_rrr <= (others=>'0');
        step_r <= (others=>'0');
        step_rr <= (others=>'0');
        step_rrr <= (others=>'0');
        A_abs_r <= '0';
        A_abs_rr <= '0';
        A_abs_rrr <= '0';
    else
        if clock_in'event and clock_in='1' then
            B_sum1_r <= B_sum1;
            B_sum1_rr <= B_sum1_r;
            B_sum2_r <= B_sum2;
            B_sum2_rr <= B_sum2_r;
            B_sum2_rrr <= B_sum2_rr;
            B_sum2_rrrr <= B_sum2_rrr;
            B_sum3_r <= B_sum3;
            B_sum3_rr <= B_sum3_r;
            B_sum3_rrr <= B_sum3_rr;
            B_sum3_rrrr <= B_sum3_rrr;
            opcode_r <= opcode_in;
            opcode_rr <= opcode_r;
            opcode_rrr <= opcode_rr;
            C_r <= C_in;
            C_rr <= C_r;
            C_rrr <= C_rr;
            step_r <= step_in;
            step_rr <= step_r;
            step_rrr <= step_rr;
            A_abs_r <= A_abs;
            A_abs_rr <= A_abs_r;
            A_abs_rrr <= A_abs_rr;
        end if;
    end if;
end process;

-----
-- Implement SUM(B)
-----

sum_1: FP32_ADDSUB
    generic map(
        LATENCY=>SUM_LATENCY
    )
    port map(
        reset_in => reset_in,
        clock_in => clock_in,
        add_sub_in => '0',
        x1_in => B,
        x2_in => B_r,
        y_out => B_sum1
    ); 

sum_2: FP32_ADDSUB
    generic map(
        LATENCY=>SUM_LATENCY
    )
    port map(
        reset_in => reset_in,
        clock_in => clock_in,
        add_sub_in => '0',
        x1_in => B_sum1,
        x2_in => B_sum1_rr,
        y_out => B_sum2
    ); 

sum_x1 <= sum_init_delay when step_sum_delay=0 else B_sum3;

sum_3: FP32_ADDSUB
    generic map(
        LATENCY=>SUM_LATENCY
    )
    port map(
        reset_in => reset_in,
        clock_in => clock_in,
        add_sub_in => '0',
        x1_in => sum_x1,
        x2_in => B_sum2,
        y_out => B_sum3
    ); 

step_sum_delay_i:delayi
    generic map(
        SIZE=>step_in'length,
        DEPTH=>3*SUM_LATENCY-1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>step_in,
        out_out=>step_sum_delay,
        enable_in=>'1'
    );

sum_init_delay_i:delayv
    generic map(
        SIZE=>C_in'length,
        DEPTH=>3*SUM_LATENCY-1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>C_in,
        out_out=>sum_init_delay,
        enable_in=>'1'
    );

-------------------------------------------------------------
-- Process chain1
-- A = MAX(ABS(B))
--------------------------------------------------------------

--x1 <= (others=>'0') when step_in(0)='0' or input_ena_in='0' else B;

B1_max <= B when A_abs='0' else ('0' & B(30 downto 0));

B2_max <= B_r when A_abs='0' else ('0' & B_r(30 downto 0));

end_max_group <= '1' when ((std_logic_vector(step_in) and C_in(step_in'length-1 downto 0))=C_in(step_in'length-1 downto 0)) else '0';

end_max_group_delay_i:delay
    generic map(
        DEPTH=>LATENCY-1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>end_max_group,
        out_out=>end_max_group_delay,
        enable_in=>'1'
    );

max_i0:fpmax
    generic map(
        LATENCY=>2
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        x1_in=>B1_max,
        x2_in=>B2_max,
        y_out=>B_max
    );

process(opcode_rrr,step_rrr,B_max2,C_rrr,A_abs_rrr)
begin
    if(opcode_rrr=register2_fpu_exe_max_c) then
        -- Find total max
        if(step_rrr/=to_unsigned(0,step_rrr'length)) then
            B2 <= B_max2;
        else
            B2 <= C_rrr;
        end if;
    else
        -- Find max in a group
        if((std_logic_vector(step_rrr) and C_rrr(step_r'length-1 downto 0)) /= std_logic_vector(to_unsigned(0,step_r'length))) then
            B2 <= B_max2;
        else
            if(A_abs_rrr='1') then
                B2 <= (others=>'0'); -- This is a very small FP32 number
            else
                B2 <= "11111111011111111111111111111111"; -- This is a very small FP32 number
            end if;
        end if;
    end if;
end process;

max_i1:fpmax
    generic map(
        LATENCY=>2
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        x1_in=>B_max,
        x2_in=>B2,
        y_out=>B_max2
    );

B_max_delay_i:delayv
    generic map(
        SIZE=>fp32_t'length,
        DEPTH=>LATENCY-1-2*MAX_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>B_max2,
        out_out=>B_maxdelay,
        enable_in=>'1'
    );


-------------------------------------------------------------
-- Relay input signal to output 
-- These are passthrough signals required by falu_core to 
-- be able to intepret to output meaning
-------------------------------------------------------------

opcode_delay_i:delayi
    generic map(
        SIZE=>fpu_opcode_t'length,
        DEPTH=>LATENCY-1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>opcode_in,
        out_out=>opcode_delay,
        enable_in=>'1'
    );

delay_i:delay
    generic map(
        DEPTH=>LATENCY-1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_ena_in,
        out_out=>output_ena_delay,
        enable_in=>'1'
    );

delay2_i:delayi
    generic map(
        SIZE=>sram_depth_c,
        DEPTH=>LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>A_addr,
        out_out=>output_addr_out,
        enable_in=>'1'
    );

delay_A_precision_i:delayi
    generic map(
        SIZE=>A_precision'length,
        DEPTH=>LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>A_precision,
        out_out=>output_precision_out,
        enable_in=>'1'
    );

delay3_i:delay
    generic map(
        DEPTH=>LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_eof_in,
        out_out=>output_eof_out,
        enable_in=>'1'
    );

delay4_i:delay
    generic map(
        DEPTH=>LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_last_in,
        out_out=>output_last_out,
        enable_in=>'1'
    );

delay5_i:delay
    generic map(
        DEPTH=>LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_fast_in,
        out_out=>output_fast_out,
        enable_in=>'1'
    );

delay6_i:delayi
    generic map(
        SIZE=>fpu_vector_t'length,
        DEPTH=>LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_vector_in,
        out_out=>output_vector_out,
        enable_in=>'1'
    );

delay7_i:delayv
    generic map(
        DEPTH=>LATENCY,
        SIZE=>fpu_data_width_c/8
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_last_be_in,
        out_out=>output_last_be_out,
        enable_in=>'1'
    );

delay8_i:delayi
    generic map(
        DEPTH=>LATENCY,
        SIZE=>opcode_in'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>opcode_in,
        out_out=>output_opcode_out,
        enable_in=>'1'
    );


-----------------------------------------------
-- Output stage
-- Register output for better timing 
-----------------------------------------------

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        output_r <= (others=>'0');
        output_ena_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            if(opcode_delay=register2_fpu_exe_sum_c or
                  opcode_delay=register2_fpu_exe_fma_c) then
                output_ena_r <= output_ena_delay;
                output_r <= B_sum3;
            elsif(opcode_delay=register2_fpu_exe_group_max_c) then
                if(end_max_group_delay='1') then
                    output_ena_r <= output_ena_delay;
                    output_r <= B_maxdelay;
                else
                    output_ena_r <= '0';
                    output_r <= (others=>'0');
                end if;
            elsif(opcode_delay=register2_fpu_exe_max_c) then
                output_ena_r <= output_ena_delay;
                output_r <= B_maxdelay;
            else
                output_ena_r <= '0';
                output_r <= (others=>'0');
            end if;
        end if;
    end if;
end process;

END behavior;
