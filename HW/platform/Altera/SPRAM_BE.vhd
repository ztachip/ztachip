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
-- This module implements single-port ram with byte-enable for Altera
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY SPRAM_BE IS
   GENERIC (
       numwords_a                      : NATURAL;
       widthad_a                       : NATURAL;
       width_a                         : NATURAL
    );
    PORT (
       address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
       byteena_a   : IN STD_LOGIC_VECTOR (width_a/8-1 DOWNTO 0);
       clock0      : IN STD_LOGIC ;
       data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
       wren_a      : IN STD_LOGIC ;
       q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
    );
END SPRAM_BE;

architecture zta_spram_be_behaviour of SPRAM_BE is

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
        q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
);
END COMPONENT;

begin

ram_i : altsyncram
GENERIC MAP (
    byte_size => 8,
    clock_enable_input_a => "BYPASS",
    clock_enable_output_a => "BYPASS",
    intended_device_family => "Cyclone V",
    lpm_hint => "ENABLE_RUNTIME_MOD=NO",
    lpm_type => "altsyncram",
    numwords_a => numwords_a,
    operation_mode => "SINGLE_PORT",
    outdata_aclr_a => "NONE",
    outdata_reg_a => "UNREGISTERED",
    power_up_uninitialized => "FALSE",
    read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
    widthad_a => widthad_a,
    width_a => width_a,
    width_byteena_a => width_a/8
)
PORT MAP (
    address_a => address_a,
    byteena_a => byteena_a,
    clock0 => clock0,
    data_a => data_a,
    wren_a => wren_a,
    q_a => q_a
);

end zta_spram_be_behaviour;
