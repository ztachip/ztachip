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

----------
-- RAM block to hold integer registers of PCORE
-- All integer registers of a thread are concatenated and stored as a single
-- entry in this RAM block
-----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY ram3 IS
    GENERIC (
        DEPTH:integer;
        WIDTH:integer
        );
    PORT (
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        -- PORT 1
        SIGNAL data1_in         : IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
        SIGNAL rdaddress1_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wraddress1_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wrbyteena1_in    : IN STD_LOGIC_VECTOR(WIDTH/8-1 DOWNTO 0);
        SIGNAL wren1_in         : IN STD_LOGIC;
        SIGNAL rden1_in         : IN STD_LOGIC;
        SIGNAL q1_out           : OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0)
    );
END ram3;

ARCHITECTURE behavior OF ram3 IS

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

altsyncram_i : altsyncram
    GENERIC MAP (
        address_aclr_b => "NONE",
        address_reg_b => "CLOCK0",
        byte_size => 8,
        clock_enable_input_a => "BYPASS",
        clock_enable_input_b => "BYPASS",
        clock_enable_output_b => "BYPASS",
        intended_device_family => "Cyclone V",
        lpm_type => "altsyncram",
        numwords_a => 2**DEPTH,
        numwords_b => 2**DEPTH,
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => DEPTH,
        widthad_b => DEPTH,
        width_a => WIDTH,
        width_b => WIDTH,
        width_byteena_a => WIDTH/8
    )
    PORT MAP (
        address_a => wraddress1_in,
        byteena_a => wrbyteena1_in,
        clock0 => clock_in,
        data_a => data1_in,
        q_b    =>q1_out,
        wren_a => wren1_in,
        address_b => rdaddress1_in
    );
    
END behavior;
