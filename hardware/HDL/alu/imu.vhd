---------------------------------------------------------------------------
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
---------------------------------------------------------------------------

------
-- This is the ALU init for vector operation
-- Each of this component is responsible for one lane of the vector operation
----


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;
LIBRARY lpm;
USE lpm.all;

--------------------------------------------------------------------------------
-- Integer implemtation of ALU
--                  +----------+
--        X1 ------>|          |
--                  |          |
--        X2 -->|   |MULTIPLIER|   +--------+
--         1 -->|-->|          |-->|        |
--     ACCUM +->|   +----------+   | ADDER  |
--           |                     |        |---> Y
--           +-------------------->|        |
--                                 +--------+
--------------------------------------------------------------------------------

ENTITY mu_adder IS
    PORT
    (
        clock_in        : IN STD_LOGIC;
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
END mu_adder;

ARCHITECTURE behavior OF mu_adder IS

SIGNAL add_sub:STD_LOGIC;
SIGNAL add_sub_r:STD_LOGIC;
SIGNAL y_add:STD_LOGIC_VECTOR (accumulator_width_c-1 DOWNTO 0);
SIGNAL y_add_r:STD_LOGIC_VECTOR (accumulator_width_c-1 DOWNTO 0);
SIGNAL y_mul:STD_LOGIC_VECTOR (2*register_width_c-1 DOWNTO 0);
SIGNAL negative:STD_LOGIC;
SIGNAL zero:STD_LOGIC;
SIGNAL y_r:STD_LOGIC_VECTOR(accumulator_width_c-1 DOWNTO 0);
SIGNAL y2_r:STD_LOGIC;
SIGNAL y3_r:STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);

-- XREG

signal xreg_r:STD_LOGIC_VECTOR(accumulator_width_c-1 downto 0);
signal xreg_rr:STD_LOGIC_VECTOR(accumulator_width_c-1 downto 0);
signal xreg_rrr:STD_LOGIC_VECTOR(accumulator_width_c-1 downto 0);
signal xreg_rrrr:STD_LOGIC_VECTOR(accumulator_width_c-1 downto 0);

-- MU OPCODE

signal mu_opcode_r:mu_opcode_t;
signal mu_opcode_rr:mu_opcode_t;
signal mu_opcode_rrr:mu_opcode_t;
signal mu_opcode_rrrr:mu_opcode_t;
signal mu_opcode_rrrrr:mu_opcode_t;
signal mu_opcode_rrrrrr:mu_opcode_t;

signal mul_x2_r:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
signal x1_r:STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
signal x2_r:STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);
signal x_scalar_r:STD_LOGIC_VECTOR (register_width_c-1 DOWNTO 0);

-- SHIFT operation

constant shift_width_depth_c:integer:=2;
constant shift_width_c:integer:=accumulator_width_c;
constant accumulator_extra_width_c:integer:=accumulator_width_c-2*register_width_c;

signal y_shift:STD_LOGIC_VECTOR(shift_width_c-1 downto 0);
signal y_shift_r:STD_LOGIC_VECTOR(shift_width_c-1 downto 0);
signal x_shift:STD_LOGIC_VECTOR(shift_width_c-1 downto 0);
signal shift_distance_r:std_logic_vector(shift_width_depth_c-1 downto 0);
signal shift_distance_rr:std_logic_vector(shift_width_depth_c-1 downto 0);
signal shift_distance_rrr:std_logic_vector(shift_width_depth_c-1 downto 0);
signal shift_distance_rrrr:std_logic_vector(shift_width_depth_c-1 downto 0);
signal shift_direction_r:std_logic; -- 1 for right shift; 0 for left shift
signal shift_direction_rr:std_logic; -- 1 for right shift; 0 for left shift
signal shift_direction_rrr:std_logic; -- 1 for right shift; 0 for left shift
signal shift_direction_rrrr:std_logic; -- 1 for right shift; 0 for left shift
signal y_mul_ext:std_logic_vector(accumulator_width_c-2*register_width_c-1 downto 0);
signal add_x1:std_logic_vector(accumulator_width_c-1 downto 0);

attribute dont_merge : boolean;
attribute dont_merge of add_sub_r : SIGNAL is true;
attribute dont_merge of x1_r : SIGNAL is true;
attribute dont_merge of x2_r : SIGNAL is true;

attribute preserve : boolean;
attribute preserve of add_sub_r : SIGNAL is true;
attribute preserve of x1_r : SIGNAL is true;
attribute preserve of x2_r : SIGNAL is true;


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
    clock    : IN STD_LOGIC;
    dataa    : IN STD_LOGIC_VECTOR (lpm_widtha-1 DOWNTO 0);
    datab    : IN STD_LOGIC_VECTOR (lpm_widthb-1 DOWNTO 0);
    result   : OUT STD_LOGIC_VECTOR (lpm_widthp-1 DOWNTO 0)
);
END COMPONENT;

COMPONENT lpm_add_sub
GENERIC (
         lpm_direction       : STRING;
         lpm_hint            : STRING;
         lpm_representation  : STRING;
         lpm_type            : STRING;
         lpm_width           : NATURAL
);
PORT (
         add_sub             : IN STD_LOGIC ;
         dataa               : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
         datab               : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
         result              : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0)
);
END COMPONENT;

COMPONENT lpm_clshift
   GENERIC (
      lpm_shifttype          : STRING;
      lpm_type               : STRING;
      lpm_width              : NATURAL;
      lpm_widthdist          : NATURAL
   );
   PORT (
      data	 : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
      direction	 : IN STD_LOGIC ;
      distance	 : IN STD_LOGIC_VECTOR (lpm_widthdist-1 DOWNTO 0);
      result	 : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0)
   );
END COMPONENT;

-------
-- Perform capping if result is saturated
------

subtype saturation_retval_t is STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);
function saturation(
        input_in:std_logic_vector(accumulator_width_c-1 downto 0))
        return saturation_retval_t is
variable output_v:std_logic_vector(register_width_c-1 downto 0);
constant all_zeros_c:std_logic_vector(accumulator_width_c-register_width_c+1-1 downto 0):=(others=>'0');
constant all_ones_c:std_logic_vector(accumulator_width_c-register_width_c+1-1 downto 0):=(others=>'1');
begin
   if input_in(accumulator_width_c-1)='0' then
      -- This is a positive number
      if input_in(accumulator_width_c-1 downto register_width_c-1)=all_zeros_c then
         output_v := input_in(register_width_c-1 downto 0);
      else
         output_v := std_logic_vector(to_unsigned(2**(register_width_c-1)-1,register_width_c)); -- Max positive nymber
      end if;
   else
      if input_in(accumulator_width_c-1 downto register_width_c-1)=all_ones_c then
         output_v := input_in(register_width_c-1 downto 0);
      else
         output_v := std_logic_vector(to_unsigned(2**(register_width_c-1),register_width_c)); -- Smallest number
      end if;
   end if;
return output_v;
end function saturation;

BEGIN

-----------
-- Process conditional opcode, based on result of a SUBTRACTION
-----------

negative <= y_shift_r(accumulator_width_c-1);

zero <= '1' when y_shift_r=std_logic_vector(to_unsigned(0,accumulator_width_c)) else '0';

y_out <= y_r;

y2_out <= y2_r;

y3_out <= y3_r;

----
-- Perform comparison operation
---

process(reset_in,clock_in)
begin
   if reset_in = '0' then
      y_r <= (others=>'0');
      y2_r <= '0';
      y3_r <= (others=>'0');
   else
   if clock_in'event and clock_in='1' then
   case mu_opcode_rrrr is
      when mu_opcode_cmp_lt_c =>
         y2_r <= (negative and (not zero));
      when mu_opcode_cmp_le_c =>
         y2_r <= (negative or zero);
      when mu_opcode_cmp_gt_c =>
         y2_r <= ((not negative) and (not zero));
      when mu_opcode_cmp_ge_c =>
         y2_r <= ((not negative) or zero);
      when mu_opcode_cmp_eq_c =>
         y2_r <= zero;
      when mu_opcode_cmp_ne_c =>
         y2_r <= not zero;
      when others=>
         y2_r <= y_shift_r(0);
   end case;

   if(y_shift_r(31 downto 23)= "011111111") then
      -- Cap it to lowest allowed values
      y_r <= "01111111100000000000000000000000";
   elsif(y_shift_r(31 downto 23)="100000000") then
      -- Cap it to highest allowed value
      y_r <= "10000000100000000000000000000000";
   else
      y_r <= y_shift_r;
   end if;

   y3_r <= saturation(y_shift_r);

   end if;
   end if;
end process;

mul_i : lpm_mult
    GENERIC MAP (
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=5",
        lpm_pipeline => 1,
        lpm_representation => "SIGNED",
        lpm_type => "LPM_MULT",
        lpm_widtha => register_width_c,
        lpm_widthb => register_width_c,
        lpm_widthp => 2*register_width_c
    )
    PORT MAP (
        clock => clock_in,
        dataa => x2_r,
        datab => mul_x2_r,
        result => y_mul
    );

adder_i : LPM_ADD_SUB
    GENERIC MAP (
        lpm_direction => "UNUSED",
        lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
        lpm_representation => "SIGNED",
        lpm_type => "LPM_ADD_SUB",
        lpm_width => accumulator_width_c
        )
    PORT MAP (
        add_sub => add_sub_r,
        dataa => xreg_rr,
        datab => add_x1,
        result => y_add
    );

-----
-- Perform right shift with sign extension
-----

LPM_CLSHIFT_component : LPM_CLSHIFT
   GENERIC MAP (
      lpm_shifttype => "ARITHMETIC",
      lpm_type => "LPM_CLSHIFT",
      lpm_width => shift_width_c,
      lpm_widthdist => shift_width_depth_c
   )
   PORT MAP (
      data => y_add_r,
      direction => shift_direction_rr,
      distance => shift_distance_rr,
      result => y_shift
   );

y_mul_ext <= (others=>y_mul(y_mul'length-1));

add_x1 <= y_mul_ext & y_mul;

process(clock_in,reset_in)
begin
   if reset_in = '0' then
      mul_x2_r <= (others=>'0');
   else
   if clock_in'event and clock_in='1' then
      if mu_opcode_in=mu_opcode_mul_c then
         mul_x2_r <= x1_in;
      elsif mu_opcode_in(fm_oc_hi_c downto fm_oc_lo_c)=mu_opcode_fm_c(fm_oc_hi_c downto fm_oc_lo_c) then
         mul_x2_r <= x1_in;
      elsif mu_opcode_in=mu_opcode_assign_raw_c or
         mu_opcode_in=mu_opcode_assign_c or
         mu_opcode_in=mu_opcode_shl_c or
         mu_opcode_in=mu_opcode_shla_c or
         mu_opcode_in=mu_opcode_shr_c or
         mu_opcode_in=mu_opcode_shra_c then
         mul_x2_r <= (others=>'0');
      else
         mul_x2_r <= std_logic_vector(to_unsigned(1,register_width_c));
      end if;
   end if;
   end if;
end process;


process(clock_in,reset_in)
begin
if reset_in = '0' then
   shift_distance_r <= (others=>'0');
   shift_distance_rr <= (others=>'0');
   shift_distance_rrr <= (others=>'0');
   shift_distance_rrrr <= (others=>'0');
   shift_direction_r <= '0';
   shift_direction_rr <= '0';
   shift_direction_rrr <= '0';
   shift_direction_rrrr <= '0';
else
   if clock_in'event and clock_in='1' then
   if mu_opcode_r=mu_opcode_shra_c or mu_opcode_r=mu_opcode_shla_c or mu_opcode_r=mu_opcode_shr_c or mu_opcode_r=mu_opcode_shl_c then
      -- Shift distance is coming from scalar parameter
      if x_scalar_r(x_scalar_r'length-1)='1' then
         shift_distance_r <= (others=>'0');
      elsif unsigned(x_scalar_r(x_scalar_r'length-1 downto shift_width_depth_c)) /= to_unsigned(0,x_scalar_r'length-shift_width_depth_c) then
         shift_distance_r <= (others=>'1');
      else 
         shift_distance_r <= x_scalar_r(shift_width_depth_c-1 downto 0);
      end if;
   else 
      shift_distance_r <= (others=>'0');
   end if;
   if mu_opcode_r=mu_opcode_shla_c or mu_opcode_r=mu_opcode_shl_c then 
      shift_direction_r <= '0';
   else
      shift_direction_r <= '1';
   end if;
   shift_direction_rr <= shift_direction_r;
   shift_direction_rrr <= shift_direction_rr;
   shift_direction_rrrr <= shift_direction_rrr;
   shift_distance_rr <= shift_distance_r;
   shift_distance_rrr <= shift_distance_rr;
   shift_distance_rrrr <= shift_distance_rrr;
   end if;
end if;
end process;


process(reset_in,clock_in)
begin
    if reset_in = '0' then
        add_sub_r <= '0';

        xreg_r <= (others=>'0');
        xreg_rr <= (others=>'0');        
        xreg_rrr <= (others=>'0');        
        xreg_rrrr <= (others=>'0');        

        mu_opcode_r <= (others=>'0');
        mu_opcode_rr <= (others=>'0');        
        mu_opcode_rrr <= (others=>'0');
        mu_opcode_rrrr <= (others=>'0');
        mu_opcode_rrrrr <= (others=>'0');
        mu_opcode_rrrrrr <= (others=>'0');
 
        x1_r <= (others=>'0');
        x2_r <= (others=>'0');
        x_scalar_r <= (others=>'0');

        y_add_r <= (others=>'0');

        y_shift_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then

            mu_opcode_r <= mu_opcode_in;
            mu_opcode_rr <= mu_opcode_r;
            mu_opcode_rrr <= mu_opcode_rr;
            mu_opcode_rrrr <= mu_opcode_rrr;
            mu_opcode_rrrrr <= mu_opcode_rrrr;
            mu_opcode_rrrrrr <= mu_opcode_rrrrr;

            x1_r <= x1_in;
            x2_r <= x2_in;
            x_scalar_r <= x_scalar_in;
            xreg_r <= xreg_in;                     
            y_add_r <= y_add;
            y_shift_r <= y_shift;
            xreg_rrrr <= xreg_rrr;
            xreg_rrr <= xreg_rr;

            if mu_opcode_r(fm_oc_hi_c downto fm_oc_lo_c)=mu_opcode_fm_c(fm_oc_hi_c downto fm_oc_lo_c) then
               xreg_rr <= xreg_r;
            else
               case mu_opcode_r is
                  when mu_opcode_shl_c|mu_opcode_shr_c =>
                     xreg_rr <= std_logic_vector(resize(signed(x2_r),shift_width_c));
                  when mu_opcode_shla_c|mu_opcode_shra_c =>
                     xreg_rr <= std_logic_vector(resize(signed(xreg_r),shift_width_c));
                  when mu_opcode_mul_c =>
                     xreg_rr <= (others=>'0');
                  when mu_opcode_assign_raw_c|mu_opcode_assign_c=>
                     xreg_rr(register_width_c-1 downto 0) <= x1_r;
                     xreg_rr(accumulator_width_c-1 downto register_width_c) <= (others=>x1_r(register_width_c-1));
                  when others=>
                     xreg_rr(register_width_c-1 downto 0) <= x1_r;
                     xreg_rr(accumulator_width_c-1 downto register_width_c) <= (others=>x1_r(register_width_c-1));
               end case;
            end if;

            if mu_opcode_r(fm_oc_hi_c downto fm_oc_lo_c)=mu_opcode_fm_c(fm_oc_hi_c downto fm_oc_lo_c) then
                add_sub_r <= not mu_opcode_r(fm_neg_c);
            else
                case mu_opcode_r is
                    when mu_opcode_add_c =>
                        add_sub_r <= '1';
                    when mu_opcode_sub_c =>
                        add_sub_r <= '0';
                    when mu_opcode_cmp_lt_c | 
                        mu_opcode_cmp_le_c |
                        mu_opcode_cmp_gt_c |
                        mu_opcode_cmp_ge_c |
                        mu_opcode_cmp_eq_c |
                        mu_opcode_cmp_ne_c =>
                        add_sub_r <= '0';                   
                    when others=>
                        add_sub_r <= '1';
                end case;
            end if;
        end if;
    end if;
end process;
END behavior;
