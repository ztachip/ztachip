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
-- This module implements the EXE stage of the MIPS pipeline.
-- Refer to http://en.wikipedia.org/wiki/MIPS_instruction_set for
-- more information
-- Only single cycle operations are processed at this stage.
-- Multiple cycle such as multiplication and divide are performed by mcore_exe2
-- stage
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY lpm;
USE lpm.all;

ENTITY mcore_exe IS
    PORT(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;

        SIGNAL x_in             : IN mregister_t;
        SIGNAL y_in             : IN mregister_t;
        SIGNAL z_in             : IN mregister_t;
        SIGNAL shamt_in         : IN mcore_shamt_t;
        SIGNAL z_addr_in        : IN mcore_regno_t;
        SIGNAL opcode_in        : IN mcore_alu_funct_t;
        SIGNAL pseudo_in        : IN mcore_exe_pseudo_t;
        SIGNAL mem_opcode_in    : IN mcore_mem_funct_t;
        SIGNAL load_in          : IN STD_LOGIC;
        SIGNAL store_in         : IN STD_LOGIC;
        SIGNAL wb_in            : IN STD_LOGIC;
        SIGNAL result_out       : OUT mregister_t;
        SIGNAL z_out            : OUT mregister_t;
        SIGNAL z_addr_out       : OUT mcore_regno_t;
        SIGNAL mem_opcode_out   : OUT mcore_mem_funct_t;
        SIGNAL load_out         : OUT STD_LOGIC;
        SIGNAL store_out        : OUT STD_LOGIC;

        SIGNAL wb_out           : OUT STD_LOGIC;

        SIGNAL hazard_data_out  : OUT mregister_t;
        SIGNAL hazard_addr_out  : OUT mcore_regno_t;
        SIGNAL hazard_ena_out   : OUT STD_LOGIC;

        SIGNAL stall_addr_out   : OUT mcore_regno_t;
        SIGNAL stall_ena_out    : OUT STD_LOGIC;

        SIGNAL exe2_opcode_out  : OUT mcore_alu_funct_t;
        SIGNAL exe2_req_out     : OUT STD_LOGIC;
        SIGNAL exe2_x_out       : OUT mregister_t;
        SIGNAL exe2_y_out       : OUT mregister_t;

        SIGNAL LO_in            : IN mregister_t;
        SIGNAL HI_in            : IN mregister_t;

        SIGNAL freeze_in        : IN STD_LOGIC
    );
END mcore_exe;

ARCHITECTURE behaviour OF mcore_exe IS
SIGNAL result:mregister_t;
SIGNAL result_r:mregister_t;
SIGNAL z_r:mregister_t;
SIGNAL z_addr_r:mcore_regno_t;
SIGNAL mem_opcode_r:mcore_mem_funct_t;
SIGNAL load_r:STD_LOGIC;
SIGNAL store_r:STD_LOGIC;
SIGNAL wb_r:STD_LOGIC;
SIGNAL result_add:mregister_t;
SIGNAL result_sub:mregister_t;
SIGNAL result_shift_left:mregister_t;
SIGNAL result_shift_right:mregister_t;
SIGNAL result_shift_right_sign:mregister_t;
SIGNAL result_lt:STD_LOGIC;
SIGNAL result_ltu:STD_LOGIC;
SIGNAL exe2_req:STD_LOGIC;

COMPONENT lpm_compare
GENERIC (
    lpm_representation  : STRING;
    lpm_type            : STRING;
    lpm_width           : NATURAL
);
PORT (
    alb    : OUT STD_LOGIC;
    dataa  : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
    datab  : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0)
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
    dataa    : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
    datab    : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
    result   : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0)
);
END COMPONENT;


COMPONENT lpm_clshift
GENERIC (
    lpm_shifttype   : STRING;
    lpm_type        : STRING;
    lpm_width       : NATURAL;
    lpm_widthdist   : NATURAL
);
PORT (
    data        : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
    direction   : IN STD_LOGIC ;
    distance    : IN STD_LOGIC_VECTOR (lpm_widthdist-1 DOWNTO 0);
    result      : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0)
);
END COMPONENT;
BEGIN

------
-- Output to Extended ALU (multiplication/division)
------

exe2_opcode_out <= opcode_in;
exe2_req_out <= exe2_req;
exe2_x_out <= x_in;
exe2_y_out <= y_in;

------
-- Output hazard signals
------

hazard_data_out <= result;
hazard_addr_out <= z_addr_in;
hazard_ena_out <= wb_in and (not load_in);

------
-- Output stall signals
------

stall_addr_out <= z_addr_in;
stall_ena_out <= wb_in and load_in;

------
--- Output to next stage
-------

result_out <= result_r;
z_out <= z_r;
z_addr_out <= z_addr_r;
load_out <= load_r;
store_out <= store_r;
wb_out <= wb_r;
mem_opcode_out <= mem_opcode_r;

-------
-- Do addition
-------

add_i : LPM_ADD_SUB
    GENERIC MAP (
        lpm_direction => "ADD",
        lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
        lpm_representation => "UNSIGNED",
        lpm_type => "LPM_ADD_SUB",
        lpm_width => mregister_t'length
    )
    PORT MAP (
        dataa => x_in,
        datab => y_in,
        result => result_add
    );

----
-- Substraction
----

sub_i : LPM_ADD_SUB
    GENERIC MAP (
        lpm_direction => "SUB",
        lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
        lpm_representation => "UNSIGNED",
        lpm_type => "LPM_ADD_SUB",
        lpm_width => mregister_t'length
    )
    PORT MAP (
        dataa => x_in,
        datab => y_in,
        result => result_sub
    );

-----
-- Compared 2 signed integer
-----

compare_signed_i : LPM_COMPARE
    GENERIC MAP (
        lpm_representation => "SIGNED",
        lpm_type => "LPM_COMPARE",
        lpm_width => mregister_width_c
    )
    PORT MAP (
        dataa => x_in,
        datab => y_in,
        alb => result_lt
    );

----
-- Compared 2 unsigned integer
----

compare_usigned_i : LPM_COMPARE
    GENERIC MAP (
        lpm_representation => "UNSIGNED",
        lpm_type => "LPM_COMPARE",
        lpm_width => mregister_width_c
    )
    PORT MAP (
        dataa => x_in,
        datab => y_in,
        alb => result_ltu
    );

----
-- Perform left shift
----

left_shift_i : LPM_CLSHIFT
    GENERIC MAP (
        lpm_shifttype => "LOGICAL",
        lpm_type => "LPM_CLSHIFT",
        lpm_width => mregister_width_c,
        lpm_widthdist => mcore_shamt_t'length
    )
    PORT MAP (
        data => y_in,
        direction => '0',
        distance => x_in(mcore_shamt_t'length-1 downto 0),
        result => result_shift_left
    );

----
-- Perform right shift with zero bit insertion
----

right_shift_i : LPM_CLSHIFT
    GENERIC MAP (
        lpm_shifttype => "LOGICAL",
        lpm_type => "LPM_CLSHIFT",
        lpm_width => mregister_width_c,
        lpm_widthdist => mcore_shamt_t'length
    )
    PORT MAP (
        data => y_in,
        direction => '1',
        distance => x_in(mcore_shamt_t'length-1 downto 0),
        result => result_shift_right
    );

-----
-- Perform right shift with sign extension
-----

right_sign_shift_i : LPM_CLSHIFT
    GENERIC MAP (
        lpm_shifttype => "ARITHMETIC",
        lpm_type => "LPM_CLSHIFT",
        lpm_width => mregister_width_c,
        lpm_widthdist => mcore_shamt_t'length
    )
    PORT MAP (
        data => y_in,
        direction => '1',
        distance => x_in(mcore_shamt_t'length-1 downto 0),
        result => result_shift_right_sign
    );

------
-- Perform ALU operation 
------

process(pseudo_in,opcode_in,result_add,result_sub,x_in,y_in,result_lt,shamt_in,result_shift_right,
            result_shift_right_sign,result_shift_left,result_ltu,HI_in,LO_in)
begin
case pseudo_in is
    when mcore_exe_pseudo_srlx_c=> 
        -- R:$d=($s > $t) ZERO INSERT
        exe2_req <= '0';
        result <= result_shift_right;
    when mcore_exe_pseudo_srax_c=> 
        -- R:$d=($s > $t) SIGN EXTENDED
        exe2_req <= '0';
        result <= result_shift_right_sign;
    when mcore_exe_pseudo_sllx_c=>  
        -- R:$d=($s < SHAMT) ZERO INSERT
        exe2_req <= '0';
        result <= result_shift_left;
    when mcore_exe_pseudo_sltx_c=> 
        -- R:$d=($s LT $t) SIGNED
        -- I:$t=($s LT C) SIGNED
        exe2_req <= '0';
        result(mregister_width_c-1 downto 1) <= (others=>'0');
        result(0) <= result_lt;
    when mcore_exe_pseudo_sltxu_c=> 
        -- R:$d=($s LT $t) UNSIGNED
        -- I:$t=($s LT C) UNSIGNED
        exe2_req <= '0';
        result(mregister_width_c-1 downto 1) <= (others=>'0');
        result(0) <= result_ltu;
    when mcore_exe_pseudo_addx_c =>    
        -- R:$d=$s+$t
        -- I:$t=$s+C
        exe2_req <= '0';
        result <= result_add;
    when mcore_exe_pseudo_addxu_c =>
        -- R:$d=$s+$t
        -- I:$t=$s+C
        exe2_req <= '0';
        result <= result_add;
    when mcore_exe_pseudo_subx_c=> 
        -- R:$d=$s-$t
        -- I:$t=$s-C
        exe2_req <= '0';
        result <= result_sub;
    when mcore_exe_pseudo_andx_c=> 
        -- R:$d=$s AND $t
        -- I:$t=$s AND C
        exe2_req <= '0';
        result <= x_in and y_in;
    when mcore_exe_pseudo_orx_c => 
        -- R:$d=$s OR $t
        -- I:$t=$s OR C
        exe2_req <= '0';
        result <= x_in or y_in;
    when mcore_exe_pseudo_xorx_c=> 
        -- R:$d=$s XOR $t
        exe2_req <= '0';
        result <= x_in xor y_in;
    when mcore_exe_pseudo_nor_c=>
        -- R:$d=$s NOR $t
        -- I:$t=$s NOR C
        exe2_req <= '0';
        result <= x_in nor y_in;
    when mcore_exe_pseudo_multx_divx_c =>
        exe2_req <= '1';
        result <= (others=>'0');
    when mcore_exe_pseudo_mfhi_c =>
        exe2_req <= '0';
        result <= HI_in;
    when mcore_exe_pseudo_mflo_c =>
        exe2_req <= '0';
        result <= LO_in;
    when others=>
        exe2_req <= '0';
        result <= (others=>'-');
end case;
end process;

-------
-- Latch to registers for next stage
-------

process(clock_in,reset_in)    
begin
if reset_in='0' then
    result_r <= (others=>'0');
    z_r <= (others=>'0');
    z_addr_r <= (others=>'0');
    load_r <= '0';
    store_r <= '0';
    wb_r <= '0';
    mem_opcode_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        if freeze_in='0' then
            mem_opcode_r <= mem_opcode_in;
            result_r <= result;
            z_r <= z_in;
            z_addr_r <= z_addr_in;
            load_r <= load_in;
            store_r <= store_in;
            wb_r <= wb_in;
        end if;
    end if;
end if;
end process;

END behaviour;
