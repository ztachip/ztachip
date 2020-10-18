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

-----
-- Implement MCORE ROM for code space
-----

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY mcore_rom IS
    PORT(
        SIGNAL clock_in     : IN STD_LOGIC;
        SIGNAL reset_in     : IN STD_LOGIC;
        -- Output to ROM
        SIGNAL rom_addr_in  : IN STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
        SIGNAL rom_data_out : OUT STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);
        -- Programming ROM interface
        SIGNAL prog_ena_in  : IN STD_LOGIC;
        SIGNAL prog_addr_in : IN STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
        SIGNAL prog_data_in : IN STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0)
    );
END mcore_rom;

ARCHITECTURE behaviour OF mcore_rom IS


COMPONENT altsyncram
GENERIC (
        address_aclr_b          : STRING;
        address_reg_b           : STRING;
        clock_enable_input_a    : STRING;
        clock_enable_input_b    : STRING;
        clock_enable_output_b   : STRING;
        intended_device_family  : STRING;
        lpm_type                : STRING;
        numwords_a              : NATURAL;
        numwords_b              : NATURAL;
		ram_block_type          : STRING;
        operation_mode          : STRING;
        outdata_aclr_b          : STRING;
        outdata_reg_b           : STRING;
        power_up_uninitialized  : STRING;
        read_during_write_mode_mixed_ports : STRING;
        widthad_a               : NATURAL;
        widthad_b               : NATURAL;
        width_a                 : NATURAL;
        width_b                 : NATURAL;
        width_byteena_a         : NATURAL
    );
    PORT (
        address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        clock0      : IN STD_LOGIC ;
        data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b         : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a      : IN STD_LOGIC ;
        address_b   : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;


BEGIN

romi_i : altsyncram
    GENERIC MAP (
        address_aclr_b => "NONE",
        address_reg_b => "CLOCK0",
        clock_enable_input_a => "BYPASS",
        clock_enable_input_b => "BYPASS",
        clock_enable_output_b => "BYPASS",
        intended_device_family => "Cyclone V",
		ram_block_type => "M10K",
        lpm_type => "altsyncram",
        numwords_a => (2**mcore_actual_instruction_depth_c),
        numwords_b => (2**mcore_actual_instruction_depth_c),
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => mcore_actual_instruction_depth_c,
        widthad_b => mcore_actual_instruction_depth_c,
        width_a => mcore_instruction_width_c,
        width_b => mcore_instruction_width_c,
        width_byteena_a => 1
    )
    PORT MAP (
        address_a => prog_addr_in(mcore_actual_instruction_depth_c-1 downto 0),
        clock0 => clock_in,
        data_a => prog_data_in,
        wren_a => prog_ena_in,
        address_b => rom_addr_in(mcore_actual_instruction_depth_c-1 downto 0),
        q_b => rom_data_out
    );


END behaviour;

