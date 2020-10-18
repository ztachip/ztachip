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

--------
-- This module implements register-file to hold integer registers of PCORE
-- There are 8 integer registers for each thread
-- All integer registers for a thread are combined and accessed as a single 
-- long word
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY stack IS
   PORT( 
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- Interface 1
        SIGNAL rd_en1_in            : IN STD_LOGIC;
        SIGNAL rd_tid1_in           : IN tid_t;
        SIGNAL rd_stack_out         : OUT STD_LOGIC_VECTOR(register_depth_c-1 downto 0);
        SIGNAL rd_stack_level_out   : OUT stack_t;
        SIGNAL rd_ra_out            : OUT STD_LOGIC_VECTOR(instruction_depth_c-1 downto 0);
        SIGNAL wr_tid1_in           : IN tid_t;
        SIGNAL wr_push_in           : IN STD_LOGIC;
        SIGNAL wr_stack_in          : IN STD_LOGIC_VECTOR(register_depth_c-1 downto 0);
        SIGNAL wr_ra_in             : IN STD_LOGIC_VECTOR(instruction_depth_c-1 downto 0); 
        SIGNAL wr_pop_in            : IN STD_LOGIC
    );
END stack;

ARCHITECTURE behaviour of stack IS

SIGNAL stack_r:stacks_t(tid_max_c-1 downto 0);
SIGNAL wr_stack:stack_t;

constant stack_byte_width_c:integer:=((register_depth_c+instruction_depth_c+7)/8);
constant stack_width_c:integer:=(stack_byte_width_c*8);

SIGNAL q1:std_logic_vector(stack_width_c-1 downto 0);
SIGNAL wrdata1:std_logic_vector(stack_width_c-1 downto 0);
SIGNAL byteena1:std_logic_vector(stack_byte_width_c-1 downto 0);
SIGNAL rdaddr1:std_logic_vector(tid_t'length+stack_t'length-1 downto 0);
SIGNAL wraddr1:std_logic_vector(tid_t'length+stack_t'length-1 downto 0);
SIGNAL stack_level_r:stack_t;
SIGNAL stack_level_rr:stack_t;
SIGNAL rd_stack_r:STD_LOGIC_VECTOR(register_depth_c-1 downto 0);
SIGNAL rd_ra_r:STD_LOGIC_VECTOR(instruction_depth_c-1 downto 0);
SIGNAL wr_push_r:STD_LOGIC;
SIGNAL wr_pop_r:STD_LOGIC;

attribute dont_merge : boolean;
attribute dont_merge of wr_push_r : SIGNAL is true;
attribute dont_merge of wr_pop_r : SIGNAL is true;


COMPONENT altsyncram
GENERIC (
    address_aclr_b                      : STRING;
    address_reg_b                       : STRING;
    byte_size                           : NATURAL;
    clock_enable_input_a                : STRING;
    clock_enable_input_b                : STRING;
    clock_enable_output_b               : STRING;
    intended_device_family              : STRING;
    lpm_type                            : STRING;
    numwords_a                          : NATURAL;
    numwords_b                          : NATURAL;
    operation_mode                      : STRING;
    outdata_aclr_b                      : STRING;
    outdata_reg_b                       : STRING;
    power_up_uninitialized              : STRING;
    read_during_write_mode_mixed_ports  : STRING;
    widthad_a                           : NATURAL;
    widthad_b                           : NATURAL;
    width_a                             : NATURAL;
    width_b                             : NATURAL;
    width_byteena_a                     : NATURAL
);
PORT (
    address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
    byteena_a   : IN STD_LOGIC_VECTOR (width_byteena_a-1 DOWNTO 0);
    clock0      : IN STD_LOGIC ;
    data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
    q_b         : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
    wren_a      : IN STD_LOGIC ;
    address_b   : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
);
END COMPONENT;

BEGIN

rdaddr1 <= std_logic_vector(stack_r(to_integer(rd_tid1_in))) & std_logic_vector(rd_tid1_in);
wraddr1 <= std_logic_vector(wr_stack) & std_logic_vector(wr_tid1_in);

---------
-- Transfer data to/from first interface to the DUALPORT RAM block
---------

rd_stack_level_out <= stack_level_rr;
rd_stack_out <= q1(register_depth_c-1 downto 0);
rd_ra_out <= rd_ra_r;


process(clock_in,reset_in)
begin
if reset_in='0' then
    rd_stack_r <= (others=>'0');
    rd_ra_r <= (others=>'0');
    wr_push_r <= '0';
    wr_pop_r <= '0';
else
    if clock_in'event and clock_in='1' then
        wr_push_r <= wr_push_in;
        wr_pop_r <= wr_pop_in;
        rd_stack_r <= q1(register_depth_c-1 downto 0);
        rd_ra_r <= q1(register_depth_c+instruction_depth_c-1 downto register_depth_c);
    end if;
end if;
end process;

-- Update stack depth....

process(wr_push_r,wr_pop_r,stack_r,wr_tid1_in)
variable stack_v:stack_t;
begin
    stack_v := stack_r(to_integer(wr_tid1_in));
    if wr_push_r='1' then
        wr_stack <= stack_v+1;
    elsif wr_pop_r='1' then
        wr_stack <= stack_v-1;
    else
        wr_stack <= stack_v;
    end if;
end process;

process(clock_in,reset_in)
begin
if reset_in='0' then
    stack_r <= (others=>(others=>'0'));
    stack_level_r <= (others=>'0');
    stack_level_rr <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        stack_r(to_integer(wr_tid1_in)) <= wr_stack;
        stack_level_r <= stack_r(to_integer(rd_tid1_in));
        stack_level_rr <= stack_level_r;
    end if;
end if;
end process;

-----
-- Generate byteena depending on which registers to be written
-----

process(wr_ra_in,wr_stack_in,wr_push_r)
begin

wrdata1(instruction_depth_c+register_depth_c-1 downto 0) <= (wr_ra_in & wr_stack_in);
byteena1(stack_byte_width_c-1 downto 0) <= (others=>wr_push_r);
end process;

---------
-- Dual port RAM block to hold index registers
---------

ram3_i: ram3
    GENERIC MAP(
        DEPTH => stack_t'length+tid_t'length,
        WIDTH => stack_width_c
    )
    PORT MAP(
        clock_in => clock_in,
        reset_in => reset_in,
        -- PORT 1
        data1_in => wrdata1,
        rdaddress1_in => rdaddr1,
        wraddress1_in => wraddr1,
        wrbyteena1_in => byteena1,
        wren1_in => '1',    
        rden1_in => rd_en1_in,
        q1_out => q1
    );

END behaviour;
