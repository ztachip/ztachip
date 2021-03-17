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
-- This module issues read requests to retrieve register values
-- Write requests are also issued when results become available
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;

ENTITY instr_dispatch2 IS
    PORT(
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        SIGNAL opcode_in            : IN STD_LOGIC_VECTOR(mu_instruction_oc_width_c-1 DOWNTO 0);
        SIGNAL instruction_tid_in   : IN tid_t;
        SIGNAL xreg_in              : IN STD_LOGIC;
        SIGNAL flag_in              : IN STD_LOGIC;
        SIGNAL wren_in              : IN STD_LOGIC;

        SIGNAL en_in                : IN STD_LOGIC;

        SIGNAL vm_in                : IN STD_LOGIC;

        SIGNAL x1_addr1_in          : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL x2_addr1_in          : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL y_addr1_in           : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
        SIGNAL result_addr1_in      : IN STD_LOGIC_VECTOR(xreg_depth_c-1 downto 0);

        SIGNAL x1_vector_in         : IN STD_LOGIC;
        SIGNAL x2_vector_in         : IN STD_LOGIC;
        SIGNAL y_vector_in          : IN STD_LOGIC;
        SIGNAL vector_lane_in       : IN STD_LOGIC_VECTOR(vector_width_c-1 downto 0);

        SIGNAL x1_c1_en_in          : IN STD_LOGIC;
        SIGNAL x1_c1_in             : IN STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);


        SIGNAL rd_en_out            : OUT STD_LOGIC;     
        SIGNAL rd_vm_out            : OUT STD_LOGIC;   
        SIGNAL rd_x1_addr_out       : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Address for X1 register
        SIGNAL rd_x2_addr_out       : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Address for X2 register
        SIGNAL rd_x1_data_in        : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);  -- Value of X1 register
        SIGNAL rd_x2_data_in        : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Value of X2 register

        SIGNAL rd_x1_vector_out     : OUT STD_LOGIC;
        SIGNAL rd_x2_vector_out     : OUT STD_LOGIC;

        SIGNAL wr_xreg_out          : OUT STD_LOGIC;
        SIGNAL wr_flag_out          : OUT STD_LOGIC;
        SIGNAL wr_en_out            : OUT STD_LOGIC; -- Enable write 
        SIGNAL wr_vm_out            : OUT STD_LOGIC;
        SIGNAL wr_vector_out        : OUT STD_LOGIC;
        SIGNAL wr_addr_out          : OUT STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); 
        SIGNAL wr_result_addr_out   : OUT STD_LOGIC_VECTOR(xreg_depth_c-1 downto 0);

        SIGNAL wr_data_out          : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
        SIGNAL wr_lane_out          : OUT STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);

        SIGNAL mu_x1_out            : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
        SIGNAL mu_x2_out            : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
        SIGNAL mu_x_scalar_out      : OUT STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);
        SIGNAL mu_opcode_out        : OUT mu_opcode_t;
        SIGNAL mu_tid_out           : OUT tid_t;
        SIGNAL mu_y_in              : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0)
       );
END instr_dispatch2;

ARCHITECTURE behavior OF instr_dispatch2 IS
SIGNAL mu_req:STD_LOGIC;
SIGNAL mu_opcode_r:mu_opcode_t;
SIGNAL mu_opcode_rr:mu_opcode_t;
SIGNAL mu_tid_r:tid_t;
SIGNAL mu_tid_rr:tid_t;
SIGNAL wr_en_delay:STD_LOGIC;
SIGNAL wr_en_delay_r:STD_LOGIC;
SIGNAL wr_xreg_delay:STD_LOGIC;
SIGNAL wr_xreg_delay_r:STD_LOGIC;
SIGNAL wr_flag_delay:STD_LOGIC;
SIGNAL wr_flag_delay_r:STD_LOGIC;
SIGNAL wr_vm_delay:STD_LOGIC;
SIGNAL wr_vm_delay_r:STD_LOGIC;
SIGNAL wr_addr_delay:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL wr_addr_delay_r:STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0);
SIGNAL wr_result_addr_delay:std_logic_vector(xreg_depth_c-1 downto 0);
SIGNAL wr_result_addr_delay_r:std_logic_vector(xreg_depth_c-1 downto 0);
SIGNAL vector_lane_delay:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL vector_lane_delay_r:STD_LOGIC_VECTOR(vector_width_c-1 downto 0);
SIGNAL wr_vector_delay:STD_LOGIC;
SIGNAL wr_vector_delay_r:STD_LOGIC;
SIGNAL wr_en:STD_LOGIC;
SIGNAL wr_xreg:STD_LOGIC;
SIGNAL wr_flag:STD_LOGIC;
SIGNAL wr_vm:STD_LOGIC;
SIGNAL x1_c1_en_r:STD_LOGIC;
SIGNAL x1_c1_en_rr:STD_LOGIC;
SIGNAL x1_c1_r:STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);
SIGNAL x1_c1_rr:STD_LOGIC_VECTOR(register_width_c-1 DOWNTO 0);
SIGNAL y_vector:STD_LOGIC;
attribute preserve : boolean;
attribute preserve of wr_en_delay_r : SIGNAL is true;
attribute preserve of wr_result_addr_delay_r : SIGNAL is true;
attribute preserve of wr_xreg_delay_r: SIGNAL is true;
attribute preserve of wr_vm_delay_r: SIGNAL is true;
attribute preserve of wr_vector_delay_r: SIGNAL is true;
attribute preserve of vector_lane_delay_r: SIGNAL is true;
attribute preserve of wr_addr_delay_r: SIGNAL is true;
attribute preserve of wr_flag_delay_r: SIGNAL is true;
BEGIN


wr_en <= '1' when (mu_req='1' and flag_in='0' and wren_in='1') else '0';
wr_flag <= '1' when (mu_req='1' and flag_in='1' and wren_in='1') else '0';
wr_xreg <= '1' when (mu_req='1' and xreg_in='1') else '0';
wr_vm <= vm_in;

y_vector <= (x1_vector_in or x2_vector_in) when wr_flag='1' else y_vector_in; 

wr_vector_fifo_i: delay generic map(DEPTH =>fu_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>y_vector,out_out=>wr_vector_delay,enable_in=>'1');

wr_vector_lane_fifo_i: delayv generic map(SIZE=>vector_width_c,DEPTH =>fu_latency_c-5) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>vector_lane_in,out_out=>vector_lane_delay,enable_in=>'1');

wr_addr_fifo_i: delayv generic map(SIZE=>register_file_depth_c,DEPTH =>fu_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>y_addr1_in,out_out=>wr_addr_delay,enable_in=>'1');

wr_result_addr_fifo_i: delayv generic map(SIZE=>xreg_depth_c,DEPTH =>fu_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>result_addr1_in,out_out=>wr_result_addr_delay,enable_in=>'1');

wr_flag_fifo_i: delay generic map(DEPTH =>fu_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>wr_flag,out_out=>wr_flag_delay,enable_in=>'1');

wr_vm_fifo_i: delay generic map(DEPTH =>fu_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>wr_vm,out_out=>wr_vm_delay,enable_in=>'1');

wr_xreg_fifo_i: delay generic map(DEPTH =>fu_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>wr_xreg,out_out=>wr_xreg_delay,enable_in=>'1');

wr_en_fifo_i: delay generic map(DEPTH =>fu_latency_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>wr_en,out_out=>wr_en_delay,enable_in=>'1');

mu_req <= '0' when opcode_in = std_logic_vector(to_unsigned(0,mu_instruction_oc_width_c)) else '1';

-------
-- Issue read request to retrieve register values
-------

rd_x1_addr_out <= x1_addr1_in;
rd_x2_addr_out <= x2_addr1_in;

rd_x1_vector_out <= x1_vector_in;
rd_x2_vector_out <= x2_vector_in;

------
-- Issue write request to save MU results or accumulator results
------

wr_xreg_out <= wr_xreg_delay_r;
wr_flag_out <= wr_flag_delay_r;
wr_en_out <= wr_en_delay_r;
wr_vm_out <= wr_vm_delay_r;
wr_addr_out <= wr_addr_delay_r;
wr_result_addr_out <= wr_result_addr_delay_r;
wr_vector_out <= wr_vector_delay_r;
wr_data_out <= mu_y_in;
wr_lane_out <= vector_lane_delay_r;

rd_en_out <= en_in;
rd_vm_out <= vm_in;

------
--- Forward read returned values (or constants) to MU units
------
mu_x1_out <= rd_x1_data_in;
mu_x2_out <= rd_x2_data_in;

-- Scalar values is coming from X1 only unless there is a override. The override is from scalar integer source
mu_x_scalar_out <= x1_c1_rr when x1_c1_en_rr='1' else rd_x1_data_in(x1_c1_rr'length-1 downto 0);
mu_opcode_out <= mu_opcode_rr;
mu_tid_out <= mu_tid_rr;

PROCESS(clock_in,reset_in)
BEGIN
    if reset_in='0' then
        x1_c1_en_r <= '0';
        x1_c1_en_rr <= '0';
        x1_c1_r <= (others=>'0');
        x1_c1_rr <= (others=>'0');
        mu_opcode_r <= (others=>'0');
        mu_tid_r <= (others=>'0');
        mu_opcode_rr <= (others=>'0');
        mu_tid_rr <= (others=>'0');
        wr_en_delay_r <= '0';
        wr_result_addr_delay_r <= (others=>'0');
        wr_xreg_delay_r <= '0';
        wr_vm_delay_r <= '0';
        wr_vector_delay_r <= '0';
        vector_lane_delay_r <= (others=>'0');
        wr_addr_delay_r <= (others=>'0');
        wr_flag_delay_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            x1_c1_en_r <= x1_c1_en_in;
            x1_c1_en_rr <= x1_c1_en_r;
            x1_c1_r <= x1_c1_in;
            x1_c1_rr <= x1_c1_r;
            mu_opcode_r <= opcode_in;
            mu_tid_r <= instruction_tid_in;
            mu_opcode_rr <= mu_opcode_r;
            mu_tid_rr <= mu_tid_r;
            wr_en_delay_r <= wr_en_delay;
            wr_result_addr_delay_r <= wr_result_addr_delay;
            wr_xreg_delay_r <= wr_xreg_delay;
            wr_vm_delay_r <= wr_vm_delay;
            wr_vector_delay_r <= wr_vector_delay;
            vector_lane_delay_r <= vector_lane_delay;
            wr_addr_delay_r <= wr_addr_delay;
            wr_flag_delay_r <= wr_flag_delay;
        end if;
    end if;
END PROCESS;

END behavior;