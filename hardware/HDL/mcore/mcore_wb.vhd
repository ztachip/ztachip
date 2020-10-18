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

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;

------
-- Implement write-back stage of MIPS pipeline
-- Refer to http://en.wikipedia.org/wiki/MIPS_instruction_set for more information
-- on MIPS pipeline
--

ENTITY mcore_wb IS
    PORT(
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- Input from MEM stage
        SIGNAL wb_addr_in           : IN mcore_regno_t;
        SIGNAL wb_data_in           : IN mregister_t;
        SIGNAL wb_ena_in            : IN STD_LOGIC;
        -- Interface to register file
        SIGNAL reg_wren_out         :OUT STD_LOGIC;
        SIGNAL reg_write_addr_out   :OUT mcore_regno_t;
        SIGNAL reg_write_data_out   :OUT mregister_t
    );
END mcore_wb;

ARCHITECTURE behaviour OF mcore_wb IS
BEGIN
reg_write_addr_out <= wb_addr_in;
reg_write_data_out <= wb_data_in;
reg_wren_out <= wb_ena_in;
END behaviour;
