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
-- This module performs data processing for data before written to DDR memory space
-- This is processed as stream processor
-- Currently supports float to integer conversion. This concept is to be expanded 
-- later to perform general stream processing
-------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;

ENTITY dp_out_converter IS
    port(
        SIGNAL clock_in                         : IN STD_LOGIC;
        SIGNAL reset_in                         : IN STD_LOGIC;
        -- Interface with the sinker
        SIGNAL sinker_write_addr_in             : IN STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);
        SIGNAL sinker_write_data_flow_in        : IN data_flow_t;
        SIGNAL sinker_write_vector_in           : IN dp_vector_t;
        SIGNAL sinker_write_scatter_in          : IN STD_LOGIC;
        SIGNAL sinker_write_cs_in               : IN STD_LOGIC;
        SIGNAL sinker_write_in                  : IN STD_LOGIC;
        SIGNAL sinker_write_data_in             : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL sinker_write_wait_request_out    : OUT STD_LOGIC;
        SIGNAL sinker_write_burstlen_in         : IN burstlen_t;
        SIGNAL sinker_write_bus_id_in           : IN dp_bus_id_t;
        SIGNAL sinker_write_data_type_in        : IN dp_data_type_t;
        SIGNAL sinker_write_thread_in           : IN dp_thread_t;

        -- Interface with external bus
        SIGNAL bus_write_addr_out               : OUT STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);
        SIGNAL bus_write_data_flow_out          : OUT data_flow_t;
        SIGNAL bus_write_vector_out             : OUT dp_vector_t;
        SIGNAL bus_write_scatter_out            : OUT STD_LOGIC;
        SIGNAL bus_write_cs_out                 : OUT STD_LOGIC;
        SIGNAL bus_write_out                    : OUT STD_LOGIC;
        SIGNAL bus_write_data_out               : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL bus_write_wait_request_in        : IN STD_LOGIC;
        SIGNAL bus_write_burstlen_out           : OUT burstlen_t;
        SIGNAL bus_write_bus_id_out             : OUT dp_bus_id_t;
        SIGNAL bus_write_data_type_out          : OUT dp_data_type_t;
        SIGNAL bus_write_thread_out             : OUT dp_thread_t
        );
END dp_out_converter;

ARCHITECTURE dp_out_converter_behaviour of dp_out_converter IS
SIGNAL bus_write_addr:STD_LOGIC_VECTOR(dp_addr_width_c-1 DOWNTO 0);
SIGNAL bus_write_cs:STD_LOGIC;
SIGNAL bus_write:STD_LOGIC;
SIGNAL bus_write_data_transparent:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL bus_write_burstlen:burstlen_t;
SIGNAL bus_write_thread:dp_thread_t;
SIGNAL enable:STD_LOGIC;
SIGNAL data_type:dp_data_type_t;
SIGNAL bus_write_bus_id:dp_bus_id_t;

begin

-------
-- Output
------

bus_write_addr_out <= bus_write_addr;
bus_write_cs_out <= bus_write_cs;
bus_write_out <= bus_write;
bus_write_data_out <= bus_write_data_transparent;
bus_write_burstlen_out <= bus_write_burstlen;
bus_write_bus_id_out <= bus_write_bus_id;
bus_write_data_type_out <= data_type;
bus_write_thread_out <= bus_write_thread;

sinker_write_wait_request_out <= '1' when (sinker_write_in='1' and enable='0') else '0';

enable <= '0' when (bus_write='1' and bus_write_wait_request_in='1') else '1';

delay1_i: delayv generic map(SIZE=>dp_addr_width_c,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_addr_in,out_out=>bus_write_addr,enable_in=>enable);

delay2_i: delay generic map(DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_cs_in,out_out=>bus_write_cs,enable_in=>enable);

delay3_i: delay generic map(DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_in,out_out=>bus_write,enable_in=>enable);

delay4_i: delayv generic map(SIZE=>ddr_data_width_c,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_data_in,out_out=>bus_write_data_transparent,enable_in=>enable);

delay5_i: delayi generic map(SIZE=>burstlen_t'length,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_burstlen_in,out_out=>bus_write_burstlen,enable_in=>enable);

delay6_i: delayi generic map(SIZE=>dp_bus_id_t'length,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_bus_id_in,out_out=>bus_write_bus_id,enable_in=>enable);

delay7_i: delayi generic map(SIZE=>dp_data_type_t'length,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_data_type_in,out_out=>data_type,enable_in=>enable);

delay8_i: delayi generic map(SIZE=>dp_thread_t'length,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_thread_in,out_out=>bus_write_thread,enable_in=>enable);

delay9_i: delayv generic map(SIZE=>ddr_vector_depth_c,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_vector_in,out_out=>bus_write_vector_out,enable_in=>enable);

delay10_i: delay generic map(DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_scatter_in,out_out=>bus_write_scatter_out,enable_in=>enable);

delay11_i: delayv generic map(SIZE=>data_flow_t'length,DEPTH =>convert_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>sinker_write_data_flow_in,out_out=>bus_write_data_flow_out,enable_in=>enable);


end dp_out_converter_behaviour;
