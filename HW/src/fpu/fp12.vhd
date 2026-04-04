------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

---------
-- Convert integer to proprietary FLOAT with 12-bit
-- Fornat is
--    1-bit sign
--    5-bit exponent (unsigned)
--    6-bit mantissa
-- Value of FP12 is (-1)**sign * mantissa * (2**(exponent-1))
-- To convert from FP12 to BFLOAT16
--    BFLOAT.mantissa = FP16.mantissa & '0'
--    BFLOAT.exp = (FP12.exp!=0)?FP12.exp + 126 : 0
------------

ENTITY fp12 IS
    GENERIC (
        INT_WIDTH : integer -- Width of integer to be converted tp float 16bit
    );
    port(
        SIGNAL clock_in    : IN STD_LOGIC;
        SIGNAL reset_in    : IN STD_LOGIC;
        SIGNAL input_in    : IN STD_LOGIC_VECTOR(INT_WIDTH-1 DOWNTO 0);
        SIGNAL output_out  : OUT fp12_t
    );
END fp12;

ARCHITECTURE fp12_behaviour of fp12 is
constant WIDTH:integer:=INT_WIDTH-1;
SIGNAL sign_r:STD_LOGIC;
SIGNAL sign_rr:STD_LOGIC;
SIGNAL sign_rrr:STD_LOGIC;
SIGNAL input_r:STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
SIGNAL input_rr:STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
SIGNAL input_shift:STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
SIGNAL exp:unsigned(fp12_exp_width_c-1 DOWNTO 0);
SIGNAL exp_r:unsigned(fp12_exp_width_c-1 DOWNTO 0);
SIGNAL exp_rr:unsigned(fp12_exp_width_c-1 DOWNTO 0);
SIGNAL shift_left_by:unsigned(fp12_exp_width_c-1 DOWNTO 0);
SIGNAL mantissa:STD_LOGIC_VECTOR(fp12_mantissa_width_c-1 DOWNTO 0);
SIGNAL mantissa_r:STD_LOGIC_VECTOR(fp12_mantissa_width_c-1 DOWNTO 0);
SIGNAL round:STD_LOGIC;
SIGNAL round_r:STD_LOGIC;
BEGIN


shift_left_by <= to_unsigned(WIDTH-fp12_mantissa_width_c+1,exp_r'length)-exp_r;

-- Shift to get the mantissa

shift_i : SHIFT_LEFT_L
   GENERIC MAP (
      DATA_WIDTH=>WIDTH,
      DIST_WIDTH=>fp12_exp_width_c
   )
   PORT MAP (
      data_in=>input_rr,
      distance_in=>shift_left_by,
      data_out=>input_shift
   );

mantissa <= input_shift(input_shift'length-1 downto input_shift'length-fp12_mantissa_width_c);

round <= input_shift(input_shift'length-fp12_mantissa_width_c-1);


process(round_r,mantissa_r,sign_rrr,exp_rr)
begin
    output_out <= sign_rrr & std_logic_vector(exp_rr) & mantissa_r;
end process;

-- Determine exponent by finding leading '1'

process(input_r)
variable pos : integer range 0 to WIDTH;
begin
    -- Iterate through the input from MSB to LSB
    exp <= (others=>'0');
    for i in WIDTH-1 downto fp12_mantissa_width_c loop
        if input_r(i) = '1' then
            exp <= to_unsigned(i-fp12_mantissa_width_c+1,exp'length);  -- Capture the position of the first '1'
            exit;      -- Exit loop after finding the first '1'
        end if;
    end loop;
end process;

-----------
-- Pipeline to convert integer to FP12
-- This takes 3 clock cycles
-----------

process(reset_in,clock_in)
variable input_v:std_logic_vector(INT_WIDTH-1 downto 0);
begin
    if reset_in = '0' then
        sign_r <= '0';
        sign_rr <= '0';
        sign_rrr <= '0';
        input_r <= (others=>'0');
        input_rr <= (others=>'0');
        exp_r <= (others=>'0');
        exp_rr <= (others=>'0');
        mantissa_r <= (others=>'0');
        round_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            -- Stage 1 -- Negate input of it is a negative number
            if(input_in(INT_WIDTH-1)='1') then
                input_v := std_logic_vector(-signed(input_in));
                input_r <= input_v(WIDTH-1 downto 0);
                sign_r <= '1';
            else
                input_r <= input_in(WIDTH-1 downto 0);
                sign_r <= '0';
            end if;

            -- Stage 2: Finding leading 1
            input_rr <= input_r;
            sign_rr <= sign_r;
            exp_r <= exp;

            -- Stage3: barrel shifter
            if(exp_r=0) then
                mantissa_r <= input_rr(mantissa_r'length-1 downto 0);
                round_r <= '0';
            else
                mantissa_r <= mantissa;
                round_r <= round;
            end if;
            sign_rrr <= sign_rr;
            exp_rr <= exp_r;
        end if;
    end if;
end process;

END fp12_behaviour;

