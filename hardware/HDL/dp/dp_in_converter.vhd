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
-- This module performs data processing for incoming DDR data
-- This is processed as stream processor
-- Currently supports integer to float conversion. This concept is to be expanded 
-- later to perform general stream processing
-------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;

ENTITY dp_in_converter IS
    generic(
        READ_LATENCY:integer
        );
    port(
        SIGNAL clock_in     : IN STD_LOGIC;
        SIGNAL reset_in     : IN STD_LOGIC;
        SIGNAL valid_in     : IN STD_LOGIC;
        SIGNAL in_in        : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
        SIGNAL data_type_in : IN dp_data_type_t;
        SIGNAL valid_out    : OUT STD_LOGIC;
        SIGNAL out_out      : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0)
        );
END dp_in_converter;

ARCHITECTURE dp_in_converter_behaviour of dp_in_converter IS
SIGNAL data_type:dp_data_type_t;
SIGNAL data_type2:dp_data_type_t;
SIGNAL data_transparent:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
begin

out_out <= data_transparent;

delay_i: delayi generic map(SIZE=>dp_data_type_t'length,DEPTH =>convert_latency_c+READ_LATENCY) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>data_type_in,out_out=>data_type2,enable_in=>'1');
delay_i2: delayv generic map(SIZE=>ddr_data_width_c,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>in_in,out_out=>data_transparent,enable_in=>'1');
delay_i3: delay generic map(DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>valid_in,out_out=>valid_out,enable_in=>'1');

end dp_in_converter_behaviour;

