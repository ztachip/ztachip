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
--- Implements RAM block 
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY mcore_ram IS
    PORT(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        SIGNAL address_in       : IN STD_LOGIC_VECTOR(mcore_ram_depth_c-1 DOWNTO 0);
        SIGNAL read_data_out    : OUT mregister_t;
        SIGNAL write_data_in    : IN mregister_t;
        SIGNAL write_ena_in     : IN STD_LOGIC;
        SIGNAL write_byteena_in : IN STD_LOGIC_VECTOR(mregister_byte_width_c-1 downto 0);
        SIGNAL read_ena_in      : IN STD_LOGIC
    );
END mcore_ram;

ARCHITECTURE behaviour OF mcore_ram IS

COMPONENT altsyncram
GENERIC (
    byte_size                       : NATURAL;
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
        address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        byteena_a   : IN STD_LOGIC_VECTOR (width_byteena_a-1 DOWNTO 0);
        clock0      : IN STD_LOGIC ;
        data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        wren_a      : IN STD_LOGIC ;
        q_a         : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
);
END COMPONENT;
BEGIN

ram_i : altsyncram
GENERIC MAP (
    byte_size => 8,
    clock_enable_input_a => "BYPASS",
    clock_enable_output_a => "BYPASS",
    intended_device_family => "Cyclone V",
    lpm_hint => "ENABLE_RUNTIME_MOD=NO",
    lpm_type => "altsyncram",
    numwords_a => mcore_ram_size_c,
    operation_mode => "SINGLE_PORT",
    outdata_aclr_a => "NONE",
    outdata_reg_a => "UNREGISTERED",
    power_up_uninitialized => "FALSE",
    read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
    widthad_a => mcore_ram_depth_c,
    width_a => mregister_width_c,
    width_byteena_a => mregister_byte_width_c
)
PORT MAP (
    address_a => address_in,
    byteena_a => write_byteena_in,
    clock0 => clock_in,
    data_a => write_data_in,
    wren_a => write_ena_in,
    q_a => read_data_out
);

END behaviour;