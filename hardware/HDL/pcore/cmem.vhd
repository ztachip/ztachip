
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
-- Description:
-- Implement constant memory bank
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY cmem IS
   PORT( 
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;

        SIGNAL wr_en_in         : IN STD_LOGIC;
        SIGNAL wr_addr_in       : IN STD_LOGIC_VECTOR(constant_depth_c-1 downto 0);
        SIGNAL wr_data_in       : IN STD_LOGIC_VECTOR(register_width_c-1 downto 0);

        SIGNAL rd_addr_in       : IN STD_LOGIC_VECTOR(constant_depth_c-1 downto 0);
        SIGNAL rd_data_out      : OUT STD_LOGIC_VECTOR(register_width_c-1 downto 0)
        );
END cmem;

ARCHITECTURE behavior OF cmem IS
SIGNAL address:STD_LOGIC_VECTOR(constant_depth_c-1 downto 0);
BEGIN

address <= wr_addr_in when (wr_en_in='1') else rd_addr_in;

altsyncram_component : altsyncram
GENERIC MAP (
        clock_enable_input_a => "BYPASS",
        clock_enable_output_a => "BYPASS",
        intended_device_family => "Cyclone V",
        lpm_hint => "ENABLE_RUNTIME_MOD=NO",
        lpm_type => "altsyncram",
        numwords_a => (2**constant_depth_c),
        operation_mode => "SINGLE_PORT",
        outdata_aclr_a => "NONE",
        outdata_reg_a => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_port_a => "DONT_CARE",
        widthad_a => constant_depth_c,
        width_a => register_width_c,
        width_byteena_a => 1
    )
    PORT MAP (
        address_a => address,
        clock0 => clock_in,
        data_a => wr_data_in,
        wren_a => wr_en_in,
        q_a => rd_data_out
    );

END behavior;

