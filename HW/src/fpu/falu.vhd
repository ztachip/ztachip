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

-------------------------------------------------------------------------------
--
-- This is the first state of the falu_core
-- Element wise computing are done at first stage
--
-- Architecture for FPU first stage has the following components 
--    RECIPROCAL_ESTIMATE: Estimate 1/x used as initial estimate for Newton method
--    EXPONENT: Produce 2**x where x is INT8 format.
--    MAC: Implement y=ACCUMULATOR + C*x1*x2
--    FLOOR: Apply floor function to final result
--    ABS: Apply absolute function to final output
--    FLOAT2INT: Convert output in float format to INT8
--
--
--  RECIPROCAL_ESTIMATE---+         +-- FLOOR-------+
--                        |         |               |
--  MAC-------------------+-------->+-- ABS---------+--> OUTPUT
--                        |         |               |
--  EXPONENT--------------+         +-- FLOAT2INT---+
--
---------------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

ENTITY falu IS
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
        SIGNAL output_step_out      : OUT unsigned(sram_depth_c-1 DOWNTO 0);
        SIGNAL output_opcode_out    : OUT fpu_opcode_t;
        SIGNAL output_eof_out       : OUT STD_LOGIC;
        SIGNAL output_last_out      : OUT STD_LOGIC;
        SIGNAL output_last_be_out   : OUT STD_LOGIC_VECTOR(fpu_data_width_c/8-1 downto 0);
        SIGNAL output_fast_out      : OUT STD_LOGIC;
        SIGNAL output_vector_out    : OUT fpu_vector_t;
        SIGNAL output_addr_out      : OUT unsigned(sram_depth_c-1 DOWNTO 0);
        SIGNAL output_precision_out : OUT unsigned(2 downto 0);
        SIGNAL output_out           : OUT fp32_t;
        SIGNAL output_C2_out        : OUT fp32_t
    );
END falu;

ARCHITECTURE behavior OF falu IS

constant RECIPROCAL_LATENCY:integer:=0;

constant INV_SQRT_LATENCY:integer:=0;

constant EXP_LATENCY:integer:=0;

constant MUL_LATENCY:integer:=4;

constant ADD_LATENCY:integer:=4;

constant FLOOR_LATENCY:integer:=0;

constant OUTPUT_LATENCY:integer:=3;

constant LATENCY:integer:=2*MUL_LATENCY+ADD_LATENCY;

SIGNAL X:fp32_t;
SIGNAL Y:fp32_t;
SIGNAL C:fp32_t;
SIGNAL C_delay:fp32_t;
SIGNAL A:fp32_t;
SIGNAL B:fp32_t;
SIGNAL B_delay:fp32_t;
SIGNAL stage1:fp32_t;
SIGNAL stage2:fp32_t;
SIGNAL opcode_delay:fpu_opcode_t;
SIGNAL output_r:fp32_t;

--SIGNAL x1:fp32_t;
SIGNAL step_r:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL step_rr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL step_rrr:unsigned(sram_depth_c-1 DOWNTO 0);
SIGNAL opcode_r:fpu_opcode_t;
SIGNAL opcode_rr:fpu_opcode_t;
SIGNAL opcode_rrr:fpu_opcode_t;
SIGNAL output_ena_delay:std_logic;
SIGNAL output_ena_r:std_logic;
SIGNAL output_precision_delay:unsigned(2 downto 0);
SIGNAL output_floor_delay:std_logic;
SIGNAL output_int_delay:std_logic;
SIGNAL output_abs_delay:std_logic;

SIGNAL output_precision:unsigned(2 downto 0);
SIGNAL output_floor:std_logic;
SIGNAL output_int:std_logic;
SIGNAL output_abs:std_logic;
SIGNAL output:fp32_t;
SIGNAL output_fp2int16:std_logic_vector(15 downto 0);
SIGNAL output_fp_floor:fp32_t;

type RECIPROCAL_LUT_TYPE is array (0 to 7) of STD_LOGIC_VECTOR(5 downto 0);

constant RECIPROCAL_LUT: RECIPROCAL_LUT_TYPE := (
    "111111", 
    "110010", 
    "100110", 
    "011101", 
    "010101", 
    "001111", 
    "001001", 
    "000100"
);

signal reciprocal:fp32_t;

signal reciprocal_delay:fp32_t;

signal inv_sqrt:fp32_t;

signal inv_sqrt_delay:fp32_t;

signal exp:fp32_t;

signal exp_delay:fp32_t;

BEGIN

X <= X_in;

Y <= Y_in;

C <= C_in;

B <= B_in;

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        step_r <= (others=>'0');
        step_rr <= (others=>'0');
        step_rrr <= (others=>'0');
        opcode_r <= (others=>'0');
        opcode_rr <= (others=>'0');
        opcode_rrr <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            step_r <= step_in;
            step_rr <= step_r;
            step_rrr <= step_rr;
            opcode_r <= opcode_in;
            opcode_rr <= opcode_r;
            opcode_rrr <= opcode_rr;
        end if;
    end if;
end process;

-------------------------------------------------------------
-- Delay input signals for output stage or final output
-- These are pass through signals for falu_core to interpret 
-- the output meaning
-------------------------------------------------------------

opcode_delay_i:delayi
    generic map(
        SIZE=>fpu_opcode_t'length,
        DEPTH=>LATENCY
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
        DEPTH=>LATENCY
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
        DEPTH=>LATENCY+OUTPUT_LATENCY+1
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
        DEPTH=>LATENCY+1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>A_precision,
        out_out=>output_precision_delay,
        enable_in=>'1'
    );

delay_A_floor_i:delay
    generic map(
        DEPTH=>LATENCY+1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>A_floor,
        out_out=>output_floor_delay,
        enable_in=>'1'
    );

delay_A_int_i:delay
    generic map(
        DEPTH=>LATENCY+1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>A_int,
        out_out=>output_int_delay,
        enable_in=>'1'
    );
    
delay_A_abs_i:delay
    generic map(
        DEPTH=>LATENCY+1
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>A_abs,
        out_out=>output_abs_delay,
        enable_in=>'1'
    );

delay3_i:delay
    generic map(
        DEPTH=>LATENCY+OUTPUT_LATENCY+1
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
        DEPTH=>LATENCY+OUTPUT_LATENCY+1
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
        DEPTH=>LATENCY+OUTPUT_LATENCY+1
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
        DEPTH=>LATENCY+OUTPUT_LATENCY+1,
        SIZE=>opcode_in'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>opcode_in,
        out_out=>output_opcode_out,
        enable_in=>'1'
    );

delay7_i:delayi
    generic map(
        DEPTH=>LATENCY+OUTPUT_LATENCY+1,
        SIZE=>step_in'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>step_in,
        out_out=>output_step_out,
        enable_in=>'1'
    );

delay8_i:delayv
    generic map(
        DEPTH=>LATENCY+OUTPUT_LATENCY+1,
        SIZE=>C2_in'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>C2_in,
        out_out=>output_C2_out,
        enable_in=>'1'
    );

delay9_i:delayi
    generic map(
        DEPTH=>LATENCY+OUTPUT_LATENCY+1,
        SIZE=>fpu_vector_t'length
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_vector_in,
        out_out=>output_vector_out,
        enable_in=>'1'
    );

delay10_i:delayv
    generic map(
        DEPTH=>LATENCY+OUTPUT_LATENCY+1,
        SIZE=>fpu_data_width_c/8
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>input_last_be_in,
        out_out=>output_last_be_out,
        enable_in=>'1'
    );

-------------------------------------------------------------
-- Process chain to approximate reciprocal
-------------------------------------------------------------

process(B)
variable exponent_v:unsigned(7 downto 0);
variable index_v:unsigned(2 downto 0);
variable approx_v:std_logic_vector(5 downto 0);
begin
exponent_v := unsigned(B(30 downto 23));
index_v := unsigned(B(22 downto 20));
approx_v := RECIPROCAL_LUT(to_integer(index_v));
if(unsigned(B)=0 or exponent_v >= 254) then
   reciprocal <= "01111111100000000000000000000000"; -- inf
else
   reciprocal <= B(31) & std_logic_vector(253-exponent_v) & approx_v & "00000000000000000";
end if;
end process;

reciprocal_delay_i:delayv
    generic map(
        SIZE=>fp32_t'length,
        DEPTH=>LATENCY-RECIPROCAL_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>reciprocal,
        out_out=>reciprocal_delay,
        enable_in=>'1'
    );


-------------------------------------------------------------
-- Process chain to approximate inverse square root
-------------------------------------------------------------

inv_sqrt <= std_logic_vector(unsigned(std_logic_vector'(x"5F3759DF")) - unsigned('0' & B(31 downto 1)));

inv_sqrt_delay_i:delayv
    generic map(
        SIZE=>fp32_t'length,
        DEPTH=>LATENCY-INV_SQRT_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>inv_sqrt,
        out_out=>inv_sqrt_delay,
        enable_in=>'1'
    );

-------------------------------------------------------------
-- Process chain to exp function
-- A = 2**B where B is INT8 format
-------------------------------------------------------------

process(B)
variable exp_v:signed(15 downto 0);
variable B_v:signed(15 downto 0);
begin
B_v := signed(B(15 downto 0));
if(B_v < to_signed(-126,16)) then
    B_v := to_signed(-126,16);
elsif(B_v > to_signed(127,16)) then
    B_v := to_signed(127,16);
end if;
exp_v := B_v+to_signed(127,16);
exp(31) <= '0'; -- Sign is 0
exp(30 downto 23) <= std_logic_vector(exp_v(7 downto 0));
exp(22 downto 0) <= (others=>'0');
end process;

exp_delay_i:delayv
    generic map(
        SIZE=>fp32_t'length,
        DEPTH=>LATENCY-EXP_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>exp,
        out_out=>exp_delay,
        enable_in=>'1'
    );

-------------------------------------------------------------
-- Process chain2
-- A = B +- C*X*Y
-------------------------------------------------------------

C_delay_i:delayv
    generic map(
        SIZE=>fp32_t'length,
        DEPTH=>MUL_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>C,
        out_out=>C_delay,
        enable_in=>'1'
    );

B_delay_i:delayv
    generic map(
        SIZE=>fp32_t'length,
        DEPTH=>2*MUL_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>B,
        out_out=>B_delay,
        enable_in=>'1'
    );

stage_1: FP32_MUL
    generic map(
        LATENCY=>MUL_LATENCY
    )
    port map(
        reset_in => reset_in,
        clock_in => clock_in,
        x1_in => X,
        x2_in => Y,
        y_out => stage1
    );        

stage_2: FP32_MUL
    generic map(
        LATENCY=>MUL_LATENCY
    )
    port map(
        reset_in => reset_in,
        clock_in => clock_in,
        x1_in => stage1,
        x2_in => C_delay,
        y_out => stage2
    ); 

stage_3: FP32_ADDSUB
    generic map(
        LATENCY=>ADD_LATENCY
    )
    port map(
        reset_in => reset_in,
        clock_in => clock_in,
        add_sub_in => '0', -- Do addition
        x1_in => stage2,
        x2_in => B_delay,
        y_out => A
    ); 

--------------------------------------------------------------
-- Implementing final output stage
--     Conversion float to INT8
--     FLOOR function
--     ABS
---------------------------------------------------------------

output_precision_out <= output_precision;

fp2int12_i: fp2int
   generic map
   (
      WIDTH=>16,
      LATENCY=>OUTPUT_LATENCY
   )
   port map 
   (
      reset_in=>reset_in,
      clock_in=>clock_in,
      x_in=>output_r,
      y_out=>output_fp2int16
   );

fp_floor_i: fp_floor
   generic map
   (
      LATENCY=>OUTPUT_LATENCY
   )
   port map 
   (
      reset_in=>reset_in,
      clock_in=>clock_in,
      input_in=>output_r,
      output_out=>output_fp_floor
   );

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        output_r <= (others=>'0');
        output_ena_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            if(opcode_delay=register2_fpu_exe_mac_c or
                opcode_delay=register2_fpu_exe_fma_c) then
                output_ena_r <= output_ena_delay;
                output_r <= A;
            elsif(opcode_delay=register2_fpu_exe_reciprocal_c) then
                output_ena_r <= output_ena_delay;
                output_r <= reciprocal_delay;
            elsif(opcode_delay=register2_fpu_exe_inv_sqrt_c) then
                output_ena_r <= output_ena_delay;
                output_r <= inv_sqrt_delay;
            elsif(opcode_delay=register2_fpu_exe_exp_c) then
                output_ena_r <= output_ena_delay;
                output_r <= exp_delay;
            else
                output_ena_r <= '0';
                output_r <= (others=>'0');
            end if;
        end if;
    end if;
end process;

process(output_precision,output_floor,output_int,output_fp2int16,output_fp_floor,output_abs,output)
begin
    if(output_int='1') then
        output_out(31 downto 16) <= output_fp2int16;
        output_out(15 downto 0) <= (others=>'0');
    elsif(output_floor='1') then
        output_out <= output_fp_floor;
    else
        output_out <= output;
    end if;
    if(output_abs='1') then
        output_out(output_out'length-1) <= '0';
    end if;
end process;


--------------------------------------------------------
-- Relay input signals from output stage to final output
-- These are pass through signals required by falu_core
-- to intepret the results.
-- But these signals are also processed by output stage
-- So they are delay in 2 stages. This is the second delay
-- stage 
---------------------------------------------------------

output_delay1_i:delayi
    generic map(
        SIZE=>output_precision_delay'length,
        DEPTH=>OUTPUT_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_precision_delay,
        out_out=>output_precision,
        enable_in=>'1'
    );

output_delay2_i:delay
    generic map(
        DEPTH=>OUTPUT_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_ena_r,
        out_out=>output_ena_out,
        enable_in=>'1'
    );

output_delay3_i:delayv
    generic map(
        SIZE=>output_r'length,
        DEPTH=>OUTPUT_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_r,
        out_out=>output,
        enable_in=>'1'
    );

output_delay4_i:delay
    generic map(
        DEPTH=>OUTPUT_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_floor_delay,
        out_out=>output_floor,
        enable_in=>'1'
    );

output_delay5_i:delay
    generic map(
        DEPTH=>OUTPUT_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_abs_delay,
        out_out=>output_abs,
        enable_in=>'1'
    );

output_delay6_i:delay
    generic map(
        DEPTH=>OUTPUT_LATENCY
    )
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,
        in_in=>output_int_delay,
        out_out=>output_int,
        enable_in=>'1'
    );

END behavior;
