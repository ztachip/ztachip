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

-------
-- This module executes all the multi-stage operations: multiplication and division
-- Results are stored in HI and LO registers 
-------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY lpm;
USE lpm.all;

ENTITY mcore_exe2 IS
    PORT(
        SIGNAL clock_in     : IN STD_LOGIC;
        SIGNAL reset_in     : IN STD_LOGIC;
        SIGNAL opcode_in    : IN mcore_alu_funct_t;
        SIGNAL req_in       : IN STD_LOGIC;
        SIGNAL x_in         : IN mregister_t;
        SIGNAL y_in         : IN mregister_t;
        SIGNAL LO_out       : OUT mregister_t;
        SIGNAL HI_out       : OUT mregister_t;
        SIGNAL busy_out     : OUT STD_LOGIC
    );
END mcore_exe2;

ARCHITECTURE behaviour OF mcore_exe2 IS

COMPONENT lpm_mult
GENERIC (
    lpm_hint            : STRING;
    lpm_pipeline        : NATURAL;
    lpm_representation  : STRING;
    lpm_type            : STRING;
    lpm_widtha          : NATURAL;
    lpm_widthb          : NATURAL;
    lpm_widthp          : NATURAL
);
PORT (
        clock    : IN STD_LOGIC ;
        dataa    : IN STD_LOGIC_VECTOR (lpm_widtha-1 DOWNTO 0);
        datab    : IN STD_LOGIC_VECTOR (lpm_widthb-1 DOWNTO 0);
        result   : OUT STD_LOGIC_VECTOR (lpm_widthp-1 DOWNTO 0)
);
END COMPONENT;

COMPONENT lpm_divide
GENERIC (
    lpm_drepresentation : STRING;
    lpm_hint            : STRING;
    lpm_nrepresentation : STRING;
    lpm_pipeline        : NATURAL;
    lpm_type            : STRING;
    lpm_widthd          : NATURAL;
    lpm_widthn          : NATURAL
);
PORT (
        clock    : IN STD_LOGIC;
        remain   : OUT STD_LOGIC_VECTOR (lpm_widthd-1 DOWNTO 0);
        denom    : IN STD_LOGIC_VECTOR (lpm_widthd-1 DOWNTO 0);
        numer    : IN STD_LOGIC_VECTOR (lpm_widthn-1 DOWNTO 0);
        quotient : OUT STD_LOGIC_VECTOR (lpm_widthn-1 DOWNTO 0)
);
END COMPONENT;

SIGNAL LO_r:mregister_t;
SIGNAL HI_r:mregister_t;
SIGNAL mul:STD_LOGIC;
SIGNAL mul_delay:STD_LOGIC;
SIGNAL div:STD_LOGIC;
SIGNAL div_delay:STD_LOGIC;
SIGNAL result_mul:STD_LOGIC_VECTOR(mregister_width_c*2+1 downto 0);
-- WARNING Can only handle max latency=7
SIGNAL busy_count_r:unsigned(5 downto 0);
SIGNAL clear_mul:STD_LOGIC;
SIGNAL clear_div:STD_LOGIC;
SIGNAL div_remain:STD_LOGIC_VECTOR(mregister_width_c downto 0);
SIGNAL div_quotient:STD_LOGIC_VECTOR(mregister_width_c downto 0);
SIGNAL x_mul_r:STD_LOGIC_VECTOR(mregister_width_c downto 0);
SIGNAL y_mul_r:STD_LOGIC_VECTOR(mregister_width_c downto 0);
SIGNAL x_div_r:STD_LOGIC_VECTOR(mregister_width_c downto 0);
SIGNAL y_div_r:STD_LOGIC_VECTOR(mregister_width_c downto 0);
constant MULT_LATENCY:integer:=3;
constant DIV_LATENCY:integer:=33; 
BEGIN

LO_out <= LO_r;
HI_out <= HI_r;
busy_out <= '1' when (req_in='1' or (busy_count_r /= to_unsigned(0,busy_count_r'length))) else '0';

delay_i1: delay2 generic map(DEPTH => MULT_LATENCY+1) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>mul,out_out=>mul_delay,enable_in=>'1',clear_in=>clear_mul);
delay_i2: delay2 generic map(DEPTH => DIV_LATENCY+1) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>div,out_out=>div_delay,enable_in=>'1',clear_in=>clear_div);

mul <= '1' when (req_in='1' and (opcode_in=mcore_alu_funct_mult_c or opcode_in=mcore_alu_funct_multu_c))  else '0';
div <= '1' when (req_in='1' and (opcode_in=mcore_alu_funct_div_c or opcode_in=mcore_alu_funct_divu_c)) else '0';

clear_mul <= '1' when (div='1') else '0';
clear_div <= '1' when (mul='1') else '0';

--------
-- Instantiate multiplier
-------

mult_i : lpm_mult
    GENERIC MAP (
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=5",
        lpm_pipeline => MULT_LATENCY,
        lpm_representation => "SIGNED",
        lpm_type => "LPM_MULT",
        lpm_widtha => mregister_width_c+1,
        lpm_widthb => mregister_width_c+1,
        lpm_widthp => 2*mregister_width_c+2
    )
    PORT MAP (
        clock => clock_in,
        dataa => x_mul_r,
        datab => y_mul_r,
        result => result_mul
    );

------
-- Instantiate divider
------

div_i : LPM_DIVIDE
    GENERIC MAP (
        lpm_drepresentation => "SIGNED",
        lpm_hint => "LPM_REMAINDERPOSITIVE=FALSE",
        lpm_nrepresentation => "SIGNED",
        lpm_pipeline => DIV_LATENCY,
        lpm_type => "LPM_DIVIDE",
        lpm_widthd => mregister_width_c+1,
        lpm_widthn => mregister_width_c+1
    )
    PORT MAP (
        clock => clock_in,
        denom => y_div_r,
        numer => x_div_r,
        remain => div_remain,
        quotient => div_quotient
    );

-------
-- Latch results from mutiplier/divider to LO/HI registers
-------

process(clock_in,reset_in)
begin
if reset_in='0' then
    LO_r <= (others=>'0');
    HI_r <= (others=>'0');
    busy_count_r <= (others=>'0');
    x_mul_r <= (others=>'0');
    y_mul_r <= (others=>'0');
    x_div_r <= (others=>'0');
    y_div_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        if mul_delay='1' then
            -- Result is ready from Multiplier. Latch the result
            LO_r <= result_mul(mregister_width_c-1 downto 0);
            HI_r <= result_mul(2*mregister_width_c-1 downto mregister_width_c);
        elsif div_delay='1' then
            -- Result is ready from Divider. Latch the result
            LO_r <= div_quotient(mregister_width_c-1 downto 0);
            HI_r <= div_remain(mregister_width_c-1 downto 0);
        end if;
        if mul='1' then
            -- Reset count down counter to wait for multiplier's result
            busy_count_r <= to_unsigned(MULT_LATENCY,busy_count_r'length);
        elsif div='1' then
            -- Reset count down counter to wait for divider's result
            busy_count_r <= to_unsigned(DIV_LATENCY,busy_count_r'length);
        else 
            if( busy_count_r /= to_unsigned(0,busy_count_r'length)) then
                -- Decrement countdownt counter
                busy_count_r <= busy_count_r-1;
            end if;
        end if;
        if req_in='1' then 
            if opcode_in=mcore_alu_funct_mult_c or opcode_in=mcore_alu_funct_div_c then
                -- Sign extended for SIGN operation
                x_mul_r(mregister_width_c) <= x_in(mregister_width_c-1);
                y_mul_r(mregister_width_c) <= y_in(mregister_width_c-1);
                x_div_r(mregister_width_c) <= x_in(mregister_width_c-1);
                y_div_r(mregister_width_c) <= y_in(mregister_width_c-1);
            else
                -- Zero the MSB for UNSIGN operation
                x_mul_r(mregister_width_c) <= '0';
                y_mul_r(mregister_width_c) <= '0';
                x_div_r(mregister_width_c) <= '0';
                y_div_r(mregister_width_c) <= '0';
            end if;
            x_mul_r(mregister_width_c-1 downto 0) <= x_in;
            y_mul_r(mregister_width_c-1 downto 0) <= y_in;
            x_div_r(mregister_width_c-1 downto 0) <= x_in;
            y_div_r(mregister_width_c-1 downto 0) <= y_in;
        else
            x_mul_r(mregister_width_c-1 downto 0) <= (others=>'0');
            y_mul_r(mregister_width_c-1 downto 0) <= (others=>'0');
            x_div_r(mregister_width_c-1 downto 0) <= (others=>'0');
            y_div_r(mregister_width_c-1 downto 0) <= (others=>'0');
        end if;
    end if;
end if;
end process;
END behaviour;
