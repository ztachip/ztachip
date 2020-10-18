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
-- Implement register file with 2 read port and 1 write port
-- Every write operations are performed on 2 RAM bank.
-- Each read port is assigned to a RAM bank
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY register_bank IS
   PORT( 
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;

        SIGNAL rd_en_in        : IN STD_LOGIC;
        SIGNAL rd_en_vm_in     : IN STD_LOGIC;
        SIGNAL rd_en_out       : OUT STD_LOGIC;
        SIGNAL rd_x1_vector_in : IN STD_LOGIC;
        SIGNAL rd_x1_addr_in   : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 1
        SIGNAL rd_x2_vector_in : IN STD_LOGIC;
        SIGNAL rd_x2_addr_in   : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 2
        SIGNAL rd_x1_data_out  : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 1
        SIGNAL rd_x2_data_out  : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 2

        SIGNAL wr_en_in        : IN STD_LOGIC; -- Write enable
        SIGNAL wr_en_vm_in     : IN STD_LOGIC; -- Write enable
        SIGNAL wr_vector_in    : IN STD_LOGIC;
        SIGNAL wr_addr_in      : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Write address
        SIGNAL wr_data_in      : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Write value
        SIGNAL wr_lane_in      : IN STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);

        -- DP interface
        SIGNAL dp_rd_vector_in    : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_in   : IN scatter_t;
        SIGNAL dp_rd_scatter_cnt_in: IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_vector_in: IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_gen_valid_in : IN STD_LOGIC;
        SIGNAL dp_rd_data_flow_in : IN data_flow_t;
        SIGNAL dp_rd_data_type_in : IN dp_data_type_t;
        SIGNAL dp_rd_stream_in    : IN std_logic;
        SIGNAL dp_rd_stream_id_in : stream_id_t;
        SIGNAL dp_rd_addr_in      : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_vector_in    : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_wr_addr_in      : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_write_in        : IN STD_LOGIC;
        SIGNAL dp_write_vm_in     : IN STD_LOGIC;
        SIGNAL dp_read_in         : IN STD_LOGIC;
        SIGNAL dp_read_vm_in      : IN STD_LOGIC;
        SIGNAL dp_writedata_in    : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out    : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readena_out     : OUT STD_LOGIC;
        SIGNAL dp_read_vector_out : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_vaddr_out  : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_scatter_out     : OUT scatter_t;
        SIGNAL dp_read_scatter_cnt_out : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_scatter_vector_out : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_gen_valid_out : OUT STD_LOGIC;
        SIGNAL dp_read_data_flow_out : OUT data_flow_t;
        SIGNAL dp_read_data_type_out : OUT dp_data_type_t;
        SIGNAL dp_read_stream_out    : OUT std_logic; 
        SIGNAL dp_read_stream_id_out : OUT stream_id_t
        );
END register_bank;

ARCHITECTURE behavior OF register_bank IS

SIGNAL rd_en_vm1:STD_LOGIC;
SIGNAL rd_en_vm2:STD_LOGIC;
SIGNAL wr_en_vm1:STD_LOGIC; -- Write enable
SIGNAL wr_en_vm2:STD_LOGIC; -- Write enable
SIGNAL dp_read_vm1:STD_LOGIC;
SIGNAL dp_read_vm2:STD_LOGIC;
SIGNAL dp_write_vm1:STD_LOGIC;
SIGNAL dp_write_vm2:STD_LOGIC;
SIGNAL dp_readena_vm1:STD_LOGIC;
SIGNAL dp_readena_vm2:STD_LOGIC;
SIGNAL dp_read_vector_vm1:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vector_vm2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vaddr_vm1:std_logic_vector(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vaddr_vm2:std_logic_vector(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_gen_valid_vm1:STD_LOGIC;
SIGNAL dp_read_gen_valid_vm2:STD_LOGIC;
SIGNAL dp_read_data_flow_vm1:data_flow_t;
SIGNAL dp_read_data_flow_vm2:data_flow_t;
SIGNAL dp_read_stream_vm1:std_logic;
SIGNAL dp_read_stream_vm2:std_logic;
SIGNAL dp_read_stream_id_vm1:stream_id_t;
SIGNAL dp_read_stream_id_vm2:stream_id_t;
SIGNAL dp_read_data_type_vm1:dp_data_type_t;
SIGNAL dp_read_data_type_vm2:dp_data_type_t;
SIGNAL rd_en1_vm1:STD_LOGIC;
SIGNAL rd_en1_vm2:STD_LOGIC;
SIGNAL dp_readdata_vm1:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0);
SIGNAL dp_readdata_vm2:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0);
SIGNAL rd_x1_data1_vm1:STD_LOGIC_VECTOR(vregister_width_c-1 downto 0); 
SIGNAL rd_x2_data1_vm1:STD_LOGIC_VECTOR(vregister_width_c-1 downto 0); 
SIGNAL rd_x1_data1_vm2:STD_LOGIC_VECTOR(vregister_width_c-1 downto 0); 
SIGNAL rd_x2_data1_vm2:STD_LOGIC_VECTOR(vregister_width_c-1 downto 0); 
SIGNAL rd_enable1_vm1:STD_LOGIC;
SIGNAL rd_enable1_vm2:STD_LOGIC;
SIGNAL dp_read_scatter_vm1:scatter_t;
SIGNAL dp_read_scatter_cnt_vm1:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_scatter_vector_vm1:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_scatter_vm2:scatter_t;
SIGNAL dp_read_scatter_cnt_vm2:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_scatter_vector_vm2:unsigned(ddr_vector_depth_c-1 downto 0);

BEGIN

rd_en_vm1 <= rd_en_in and (not rd_en_vm_in);
rd_en_vm2 <= rd_en_in and (rd_en_vm_in);

wr_en_vm1 <= wr_en_in and (not wr_en_vm_in);
wr_en_vm2 <= wr_en_in and wr_en_vm_in;

dp_read_vm1 <= dp_read_in and (not dp_read_vm_in);
dp_read_vm2 <= dp_read_in and (dp_read_vm_in)
dp_write_vm1 <= dp_write_in and (not dp_write_vm_in);
dp_write_vm2 <= dp_write_in and (dp_write_vm_in);

rd_en_out <= rd_enable1_vm1 or rd_enable1_vm2;
rd_x1_data_out <= rd_x1_data1_vm1 when rd_enable1_vm1='1' else rd_x1_data1_vm2; 
rd_x2_data_out <= rd_x2_data1_vm1 when rd_enable1_vm1='1' else rd_x2_data1_vm2; 
dp_readdata_out <= dp_readdata_vm1 when dp_readena_vm1='1' else dp_readdata_vm2;
dp_readena_out <= dp_readena_vm1 or dp_readena_vm2;

dp_read_vector_out <= dp_read_vector_vm1 when dp_readena_vm1='1' else dp_read_vector_vm2,
dp_read_vaddr_out <= dp_read_vaddr_vm1 when dp_readena_vm1='1' dp_read_vaddr_vm2,
dp_read_scatter_out <= dp_read_scatter_vm1 when dp_readena_vm1='1' dp_read_scatter_vm2,
dp_read_scatter_cnt_out <= dp_read_scatter_cnt_vm1 when dp_readena_vm1='1' dp_read_scatter_cnt_vm2,
dp_read_scatter_vector_out <= dp_read_scatter_vector_vm1 when dp_readena_vm1='1' dp_read_scatter_vector_vm2,
dp_read_gen_valid_out <= dp_read_gen_valid_vm1 when dp_readena_vm1='1' dp_read_gen_valid_vm2,
dp_read_data_flow_out <= dp_read_data_flow_vm1 when dp_readena_vm1='1' dp_read_data_flow_vm2,
dp_read_data_type_out <= dp_read_data_type_vm1 when dp_readena_vm1='1' dp_read_data_type_vm2,
dp_read_stream_out <= dp_read_stream_vm1 when dp_readena_vm1='1' dp_read_stream_vm2,
dp_read_stream_id_out <= dp_read_stream_id_vm1 when dp_readena_vm1='1' dp_read_stream_id_vm2


register_file_i: register_file port map(
                                clock_in =>clock_in,
                                reset_in =>reset_in,
                
                                rd_en_in => rd_en_vm1,
                                rd_en_out => rd_enable1_vm1,
                                rd_x1_vector_in => rd_x1_vector_in,
                                rd_x1_addr_in =>rd_x1_addr_in,
                                rd_x2_vector_in => rd_x2_vector_in,
                                rd_x2_addr_in =>rd_x2_addr_in,
                                rd_x1_data_out =>rd_x1_data1_vm1,
                                rd_x2_data_out =>rd_x2_data1_vm1,
                
                                wr_en_in => wr_en_vm1_in,
                                wr_vector_in => wr_vector_in,
                                wr_addr_in => wr_addr_in,
                                wr_data_in =>wr_data_in,
                                wr_lane_in => wr_lane_in,
                
                                dp_rd_vector_in => dp_rd_vector_in,
                                dp_rd_scatter_in => dp_rd_scatter_in,
                                dp_rd_scatter_cnt_in => dp_rd_scatter_cnt_in,
                                dp_rd_scatter_vector_in => dp_rd_scatter_vector_in,
                                dp_rd_gen_valid_in => dp_rd_gen_valid_in,
                                dp_rd_data_flow_in => dp_rd_data_flow_in,
                                dp_rd_data_type_in => dp_rd_data_type_in,
                                dp_rd_stream_in => dp_rd_stream_in,
                                dp_rd_stream_id_in => dp_rd_stream_id_in,
                                dp_rd_addr_in => dp_rd_addr_in,
                                dp_wr_vector_in => dp_wr_vector_in,
                                dp_wr_addr_in => dp_wr_addr_in,
                                dp_write_in => dp_write_vm1,
                                dp_read_in => dp_read_vm1,
                                dp_writedata_in => dp_writedata_in,

                                dp_readdata_out => dp_readdata_vm1,
                                dp_readena_out => dp_readena_vm1,
                                dp_read_vector_out => dp_read_vector_vm1,
                                dp_read_vaddr_out => dp_read_vaddr_vm1,

                                dp_read_scatter_out => dp_read_scatter_vm1,
                                dp_read_scatter_cnt_out => dp_read_scatter_cnt_vm1,
                                dp_read_scatter_vector_out => dp_read_scatter_vector_vm1,
                                dp_read_gen_valid_out => dp_read_gen_valid_vm1,
                                dp_read_data_flow_out => dp_read_data_flow_vm1,
                                dp_read_data_type_out => dp_read_data_type_vm1,
                                dp_read_stream_out => dp_read_stream_vm1,
                                dp_read_stream_id_out => dp_read_stream_id_vm1
                                );

-------
-- Instantiate register file for process#1
-------

register_file_i2: register_file port map(
                                clock_in =>clock_in,
                                reset_in =>reset_in,
                
                                rd_en_in => rd_en_vm2,
                                rd_en_out => rd_enable1_vm2,
                                rd_x1_vector_in => rd_x1_vector_in,
                                rd_x1_addr_in =>rd_x1_addr_in,
                                rd_x2_vector_in => rd_x2_vector_in,
                                rd_x2_addr_in =>rd_x2_addr_in,
                                rd_x1_data_out =>rd_x1_data1_vm2,
                                rd_x2_data_out =>rd_x2_data1_vm2,
                
                                wr_en_in => wr_en_vm2_in,
                                wr_vector_in => wr_vector_in,
                                wr_addr_in => wr_addr_in,
                                wr_data_in =>wr_data_in,
                                wr_lane_in => wr_lane_in,
                
                                dp_rd_vector_in => dp_rd_vector_in,
                                dp_rd_scatter_in => dp_rd_scatter_in,
                                dp_rd_scatter_cnt_in => dp_rd_scatter_cnt_in,
                                dp_rd_scatter_vector_in => dp_rd_scatter_vector_in,
                                dp_rd_gen_valid_in => dp_rd_gen_valid_in,
                                dp_rd_data_flow_in => dp_rd_data_flow_in,
                                dp_rd_data_type_in => dp_rd_data_type_in,
                                dp_rd_stream_in => dp_rd_stream_in,
                                dp_rd_stream_id_in => dp_rd_stream_id_in,
                                dp_rd_addr_in => dp_rd_addr_in,
                                dp_wr_vector_in => dp_wr_vector_in,
                                dp_wr_addr_in => dp_wr_addr_in,
                                dp_write_in => dp_write_vm2,
                                dp_read_in => dp_read_vm2,
                                dp_writedata_in => dp_writedata_in,

                                dp_readdata_out => dp_readdata_vm2,
                                dp_readena_out => dp_readena_vm2,
                                dp_read_vector_out => dp_read_vector_vm2,
                                dp_read_vaddr_out => dp_read_vaddr_vm2,

                                dp_read_scatter_out => dp_read_scatter_vm2,
                                dp_read_scatter_cnt_out => dp_read_scatter_cnt_vm2,
                                dp_read_scatter_vector_out => dp_read_scatter_vector_vm2,
                                dp_read_gen_valid_out => dp_read_gen_valid_vm2,
                                dp_read_data_flow_out => dp_read_data_flow_vm2,
                                dp_read_data_type_out => dp_read_data_type_vm2,
                                dp_read_stream_out => dp_read_stream_vm2,
                                dp_read_stream_id_out => dp_read_stream_id_vm2
                                );


END behavior;