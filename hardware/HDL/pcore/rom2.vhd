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

------
-- This component implements code space for PCORE
-- Because it runs on x2 clock and each ROM entries contain 2 instructions, 
-- therefore it can retrieve 4 instructions per clock
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY rom2 IS
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        SIGNAL rdaddress_in         : IN STD_LOGIC_VECTOR (instruction_depth_c-1 DOWNTO 0);
        SIGNAL rdaddress_plus_2_in  : IN STD_LOGIC_VECTOR (instruction_depth_c-1 DOWNTO 0);
        SIGNAL instruction_out      : OUT STD_LOGIC_VECTOR (instruction_width_c-1 DOWNTO 0);
        SIGNAL wren_in              : IN STD_LOGIC;
        SIGNAL wraddress_in         : IN STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
        SIGNAL wrdata_in            : IN STD_LOGIC_VECTOR(instruction_width_c/2-1 DOWNTO 0)
    );
END rom2;

ARCHITECTURE behavior OF rom2 IS
COMPONENT altsyncram
GENERIC (
    clock_enable_input_a            : STRING;
    clock_enable_output_a           : STRING;
    intended_device_family          : STRING;
    lpm_hint                        : STRING;
    lpm_type                        : STRING;
    numwords_a                      : NATURAL;
    operation_mode                  : STRING;
    outdata_aclr_a                  : STRING;
    outdata_reg_a                   : STRING;
    power_up_uninitialized          : STRING;
    read_during_write_mode_port_a   : STRING;
    widthad_a                       : NATURAL;
    width_a                         : NATURAL;
    width_byteena_a                 : NATURAL
);
PORT (
    aclr0       : IN STD_LOGIC ;
    address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
    byteena_a   : IN STD_LOGIC_VECTOR (width_byteena_a-1 DOWNTO 0);
    clock0      : IN STD_LOGIC ;
    data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
    wren_a      : IN STD_LOGIC ;
    q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
);
END COMPONENT;
SIGNAL address:STD_LOGIC_VECTOR (instruction_actual_depth_c-2 DOWNTO 0);
SIGNAL q:STD_LOGIC_VECTOR (instruction_width_c-1 DOWNTO 0);
SIGNAL q1_r:STD_LOGIC_VECTOR (instruction_width_c-1 DOWNTO 0);

constant byteena_width_c:integer:=(instruction_width_c/8);
SIGNAL byteena:STD_LOGIC_VECTOR(byteena_width_c-1 downto 0);
BEGIN

instruction_out <= q;

process(wren_in,wraddress_in,rdaddress_in)
begin
if wren_in='1' then
    address <= wraddress_in(instruction_actual_depth_c-1 downto 1);
    byteena(byteena_width_c-1 downto byteena_width_c/2) <= (others=>(not wraddress_in(0)));
    byteena(byteena_width_c/2-1 downto 0) <= (others=>(wraddress_in(0)));
else
    address <= rdaddress_in(instruction_actual_depth_c-1 downto 1);
    byteena <= (others=>'0');
end if;
end process;

------
-- Instantiate ROM block
-------

ram_i : altsyncram
    GENERIC MAP (
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => 2**(instruction_actual_depth_c-1),
        operation_mode => "SINGLE_PORT",
        outdata_aclr_a => "CLEAR0",
        outdata_reg_a => "UNREGISTERED",
        power_up_uninitialized => "TRUE",
        read_during_write_mode_port_a => "DONT_CARE",
        widthad_a => instruction_actual_depth_c-1,
        width_a => instruction_width_c,
        width_byteena_a => byteena_width_c
    )
    PORT MAP (
        aclr0 => '0',
        address_a => address,
        byteena_a => byteena,
        clock0 => clock_in,
        data_a(instruction_width_c-1 downto instruction_width_c/2) => wrdata_in,
        data_a(instruction_width_c/2-1 downto 0) => wrdata_in,
        wren_a => wren_in,
        q_a => q
    );

END behavior;