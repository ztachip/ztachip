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
------------------------------------------------------------------------------

------
-- This module performs integer scalar operation from PCORE
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY ialu IS
    PORT
    (
    SIGNAL clock_in     : IN STD_LOGIC;
    SIGNAL reset_in     : IN STD_LOGIC;
    SIGNAL opcode_in    : IN STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
    SIGNAL x1_in        : IN iregister_t;
    SIGNAL x2_in        : IN iregister_t;
    SIGNAL y_out        : OUT iregister_t;
    SIGNAL y_neg_out    : OUT STD_LOGIC;
    SIGNAL y_zero_out   : OUT STD_LOGIC
    );
END ialu;

ARCHITECTURE behavior OF ialu IS
SIGNAL x1:STD_LOGIC_VECTOR(iregister_width_c-1 downto 0);
SIGNAL x2:STD_LOGIC_VECTOR(iregister_width_c-1 downto 0);
SIGNAL shift_y:STD_LOGIC_VECTOR(iregister_width_c-1 downto 0);
SIGNAL logic_shift_y:STD_LOGIC_VECTOR(iregister_width_c-1 downto 0);
SIGNAL y_r:iregister_t;
SIGNAL y2_r:iregister_t;
SIGNAL y2_rr:iregister_t;
SIGNAL x1_r:iregister_t;
SIGNAL x2_r:iregister_t;
SIGNAL opcode_r:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL opcode_rr:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL opcode_rrr:STD_LOGIC_VECTOR(imu_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL mul_y:STD_LOGIC_VECTOR(2*iregister_width_c-1 downto 0);
SIGNAL mul_x1:STD_LOGIC_VECTOR(iregister_width_c-1 downto 0);
SIGNAL mul_x2:STD_LOGIC_VECTOR(iregister_width_c-1 downto 0);
SIGNAL shr:STD_LOGIC;
constant MULT_LATENCY:integer:=1;

BEGIN

mul_x1 <= std_logic_vector(x1_r);
mul_x2 <= std_logic_vector(x2_r);
x1 <= std_logic_vector(x1_r);
x2 <= std_logic_vector(x2_r); 
shr <= '0' when (opcode_r=imu_opcode_shl_c) else '1';

------
-- Perform integer multiplication
------

mult_i:multiplier
	generic map
	(
        DATA_WIDTH=>iregister_width_c,
        REGISTER_OUTPUT=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        x_in=>mul_x1,
        y_in=>mul_x2,   
        z_out=>mul_y
	);

------
-- Perform bit shift operation
------

shifter_i : barrel_shifter_a
   GENERIC MAP (
      DIST_WIDTH=>iregister_width_log_c,
      DATA_WIDTH=>iregister_width_c
   )
   PORT MAP (      
      direction_in=>shr,
      data_in=>x1,
      distance_in=>x2(iregister_width_log_c-1 downto 0),
      data_out=>shift_y
   );

logic_shifter_i : barrel_shifter_l
   GENERIC MAP (
      DIST_WIDTH=>iregister_width_log_c,
      DATA_WIDTH=>iregister_width_c
   )
   PORT MAP (      
      direction_in=>'1',
      data_in=>x1,
      distance_in=>x2(iregister_width_log_c-1 downto 0),
      data_out=>logic_shift_y
   );

y_out <= y_r;
y_neg_out <= y_r(y_r'length-1);
y_zero_out <= '1' when y_r=to_unsigned(0,iregister_t'length) else '0';

process(clock_in,reset_in)    
begin
if reset_in='0' then
    y_r <= (others=>'0');
    x1_r <= (others=>'0');
    x2_r <= (others=>'0');
    opcode_r <= (others=>'0');
    opcode_rr <= (others=>'0');
    opcode_rrr <= (others=>'0');
    y2_r <= (others=>'0');
    y2_rr <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        x1_r <= x1_in;
        x2_r <= x2_in;
        opcode_r <= opcode_in;
        opcode_rr <= opcode_r;
        opcode_rrr <= opcode_rr;

        y2_rr <= y2_r;
        
        -------
        -- Perform single clock operation
        -------

        case opcode_r is
            when imu_opcode_add_c=> 
                y2_r <= x1_r+x2_r;
            when imu_opcode_sub_c=>
                y2_r <= x1_r-x2_r;
            when imu_opcode_shl_c|imu_opcode_shr_c=>
                y2_r <= unsigned(shift_y);
            when imu_opcode_lshr_c=>
                y2_r <= unsigned(logic_shift_y);
            when imu_opcode_or_c=>
                y2_r <= unsigned(std_logic_vector(x1_r) or std_logic_vector(x2_r));
            when imu_opcode_and_c=>
                y2_r <= unsigned(std_logic_vector(x1_r) and std_logic_vector(x2_r));
            when imu_opcode_xor_c=>
                y2_r <= unsigned(std_logic_vector(x1_r) xor std_logic_vector(x2_r));
            when others=>
                y2_r <= (others=>'0');
        end case;

        --------
        --- Multiplication is multi-clock operation
        --------

        case opcode_rr is
            when imu_opcode_mul_c=>
                y_r <= unsigned(mul_y(iregister_width_c-1 downto 0));
            when others=>
                y_r <= y2_r;
        end case;
    end if;
end if;
end process;
END behavior;

