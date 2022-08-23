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
----------
-- This module implements simple dual-port ram for Altera
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY DPRAM IS
   GENERIC (
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL
    );
    PORT (
        address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        clock0    : IN STD_LOGIC ;
        data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
        wren_a    : IN STD_LOGIC ;
        address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END DPRAM;

architecture zta_dpram_behaviour of DPRAM is

COMPONENT altsyncram
GENERIC (
        address_aclr_b          : STRING;
        address_reg_b           : STRING;
        clock_enable_input_a    : STRING;
        clock_enable_input_b    : STRING;
        clock_enable_output_b   : STRING;
        intended_device_family  : STRING;
        ram_block_type          : STRING;
        lpm_type                : STRING;
        numwords_a              : NATURAL;
        numwords_b              : NATURAL;
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

begin

dpram_i : altsyncram
    GENERIC MAP (
        address_aclr_b => "NONE",
        address_reg_b => "CLOCK0",
        clock_enable_input_a => "BYPASS",
        clock_enable_input_b => "BYPASS",
        clock_enable_output_b => "BYPASS",
        intended_device_family => "Cyclone V",
        ram_block_type => "M10K",
        lpm_type => "altsyncram",
        numwords_a => numwords_a,
        numwords_b => numwords_b,
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => widthad_a,
        widthad_b => widthad_b,
        width_a => width_a,
        width_b => width_b,
        width_byteena_a => 1
    )
    PORT MAP (
        address_a => address_a,
        clock0 => clock0,
        data_a => data_a,
        wren_a => wren_a,
        address_b => address_b,
        q_b => q_b
    );

end zta_dpram_behaviour;
