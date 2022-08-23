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

-------
-- Description:
-- Implement register file 
-- Every write operations are performed on 2 RAM bank.
-- Each read port is assigned to a RAM bank
-- Register file can be accessed by ALU for parameter load/store
-- Register file can also be accessed by DP engine.
-- Register file is divided into 2 independent partitions. Each partition is assigned to a process 
-- The data layout of register file is as followed
--     thread0 privateMem word#0
--     thread1 privateMem word#0
--     :
--     thread15 privateMem word#0
--     thread0 privateMem word#1
--     thread1 privateMem word#1
--     :
--     thread15 privateMem word#1
--     :
--     thread0 privateMem word#N
--     thread1 privateMem word#N
--     :
--     thread15 privateMem word#N
--     :
--     :
--     sharedMem word#N
--     SharedMem word#N-1
--     :
--     SharedMem word#0
-- 
-- Number of private memory words available for each thread is dependent on memory model size of pcore program
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY register_bank IS
   PORT( 
        SIGNAL clock_in                   : IN STD_LOGIC;
        SIGNAL reset_in                   : IN STD_LOGIC;

        SIGNAL rd_en_in                   : IN STD_LOGIC;
        SIGNAL rd_en_vm_in                : IN STD_LOGIC;
        SIGNAL rd_en_out                  : OUT STD_LOGIC;
        SIGNAL rd_x1_vector_in            : IN STD_LOGIC;
        SIGNAL rd_x1_addr_in              : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 1
        SIGNAL rd_x2_vector_in            : IN STD_LOGIC;
        SIGNAL rd_x2_addr_in              : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 2
        SIGNAL rd_x1_data_out             : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 1
        SIGNAL rd_x2_data_out             : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 2

        SIGNAL wr_en_in                   : IN STD_LOGIC; -- Write enable
        SIGNAL wr_en_vm_in                : IN STD_LOGIC; -- Write enable
        SIGNAL wr_vector_in               : IN STD_LOGIC;
        SIGNAL wr_addr_in                 : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Write address
        SIGNAL wr_data_in                 : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Write value
        SIGNAL wr_lane_in                 : IN STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);

        -- DP interface
        SIGNAL dp_rd_vector_in            : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_in           : IN scatter_t;
        SIGNAL dp_rd_scatter_cnt_in       : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_vector_in    : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_gen_valid_in         : IN STD_LOGIC;
        SIGNAL dp_rd_data_flow_in         : IN data_flow_t;
        SIGNAL dp_rd_data_type_in         : IN dp_data_type_t;
        SIGNAL dp_rd_stream_in            : IN std_logic;
        SIGNAL dp_rd_stream_id_in         : stream_id_t;
        SIGNAL dp_rd_addr_in              : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_vector_in            : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_wr_addr_in              : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_write_in                : IN STD_LOGIC;
        SIGNAL dp_write_vm_in             : IN STD_LOGIC;
        SIGNAL dp_read_in                 : IN STD_LOGIC;
        SIGNAL dp_read_vm_in              : IN STD_LOGIC;
        SIGNAL dp_writedata_in            : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out            : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_vm_out         : OUT STD_LOGIC;
        SIGNAL dp_readena_out             : OUT STD_LOGIC;
        SIGNAL dp_read_vector_out         : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_vaddr_out          : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_scatter_out        : OUT scatter_t;
        SIGNAL dp_read_scatter_cnt_out    : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_scatter_vector_out : OUT unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_read_gen_valid_out      : OUT STD_LOGIC;
        SIGNAL dp_read_data_flow_out      : OUT data_flow_t;
        SIGNAL dp_read_data_type_out      : OUT dp_data_type_t;
        SIGNAL dp_read_stream_out         : OUT std_logic; 
        SIGNAL dp_read_stream_id_out      : OUT stream_id_t
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
SIGNAL dp_encode:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL rd_en1_vm1:STD_LOGIC;
SIGNAL rd_en1_vm2:STD_LOGIC;
SIGNAL dp_readdata_vm:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0); 
SIGNAL dp_readdata_vm1:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0);
SIGNAL dp_readdata_vm2:STD_LOGIC_VECTOR(ddrx_data_width_c-1 downto 0);
SIGNAL q1_encode:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL q2_encode:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL rd_x1_data_vm:STD_LOGIC_VECTOR(vregister_width_c-1 downto 0); 
SIGNAL rd_x2_data_vm:STD_LOGIC_VECTOR(vregister_width_c-1 downto 0); 
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

SIGNAL dp_rd_data_flow_r:data_flow_t;
SIGNAL dp_rd_data_type_r:dp_data_type_t;
SIGNAL dp_rd_stream_r:std_logic;
SIGNAL dp_rd_stream_id_r:stream_id_t;
SIGNAL dp_rd_gen_valid_r:STD_LOGIC;
SIGNAL dp_rd_scatter_r:scatter_t;
SIGNAL dp_rd_scatter_cnt_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_rd_scatter_vector_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_rd_vaddr_r:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);
SIGNAL dp_rd_vector_r:unsigned(vector_depth_c-1 downto 0);

SIGNAL dp_rd_data_flow_rr:data_flow_t;
SIGNAL dp_rd_data_type_rr:dp_data_type_t;
SIGNAL dp_rd_stream_rr:std_logic;
SIGNAL dp_rd_stream_id_rr:stream_id_t;
SIGNAL dp_rd_gen_valid_rr:STD_LOGIC;
SIGNAL dp_rd_scatter_rr:scatter_t;
SIGNAL dp_rd_scatter_cnt_rr:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_rd_scatter_vector_rr:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_rd_vaddr_rr:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);
SIGNAL dp_rd_vector_rr:unsigned(vector_depth_c-1 downto 0);

SIGNAL rd_x1_vector_r:STD_LOGIC;
SIGNAL rd_x1_vector_rr:STD_LOGIC;
SIGNAL rd_x1_vaddr_r:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);
SIGNAL rd_x1_vaddr_rr:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);
SIGNAL rd_x2_vector_r:STD_LOGIC;
SIGNAL rd_x2_vector_rr:STD_LOGIC;
SIGNAL rd_x2_vaddr_r:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);
SIGNAL rd_x2_vaddr_rr:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);

BEGIN

rd_en_vm1 <= rd_en_in and (not rd_en_vm_in);
rd_en_vm2 <= rd_en_in and (rd_en_vm_in);

wr_en_vm1 <= wr_en_in and (not wr_en_vm_in);
wr_en_vm2 <= wr_en_in and wr_en_vm_in;

dp_read_vm1 <= dp_read_in and (not dp_read_vm_in);
dp_read_vm2 <= dp_read_in and (dp_read_vm_in);
dp_write_vm1 <= dp_write_in and (not dp_write_vm_in);
dp_write_vm2 <= dp_write_in and (dp_write_vm_in);


dp_readdata_out(dp_readdata_out'length-1 downto register_width_c) <= dp_readdata_vm(dp_readdata_out'length-1 downto register_width_c);
dp_readdata_out(register_width_c-1 downto 0) <= dp_encode;
dp_readdata_vm_out <= '0' when dp_readena_vm1='1' else '1';

rd_en_out <= rd_enable1_vm1 or rd_enable1_vm2;

-- 
-- ALU X1 and X2 read output
---

process(rd_x1_vector_rr,rd_x1_data_vm,q1_encode,rd_x2_vector_rr,rd_x2_data_vm,q2_encode)
begin
   if rd_x1_vector_rr/='0' then
      rd_x1_data_out <= rd_x1_data_vm; -- This is a vector read
   else
      rd_x1_data_out <= q1_encode & -- This is a non-vector read 
                        q1_encode &
                        q1_encode &
                        q1_encode &
                        q1_encode &
                        q1_encode &
                        q1_encode &
                        q1_encode;
   end if;
   if rd_x2_vector_rr/='0' then
      rd_x2_data_out <= rd_x2_data_vm; -- This is vector read
   else 
      rd_x2_data_out <= q2_encode &  -- This is a non-vector read
                        q2_encode &
                        q2_encode &
                        q2_encode &
                        q2_encode &
                        q2_encode &
                        q2_encode &
                        q2_encode;
   end if;
end process;

dp_readena_out <= dp_readena_vm1 or dp_readena_vm2;
dp_read_vector_out <= dp_rd_vector_rr;
dp_read_vaddr_out <= dp_rd_vaddr_rr;
dp_read_scatter_out <= dp_rd_scatter_rr;
dp_read_scatter_cnt_out <= dp_rd_scatter_cnt_rr;
dp_read_scatter_vector_out <= dp_rd_scatter_vector_rr;
dp_read_gen_valid_out <= dp_rd_gen_valid_rr;
dp_read_data_flow_out <= dp_rd_data_flow_rr;
dp_read_data_type_out <= dp_rd_data_type_rr;
dp_read_stream_out <= dp_rd_stream_rr;
dp_read_stream_id_out <= dp_rd_stream_id_rr;

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        dp_rd_vaddr_r <= (others=>'0');
        dp_rd_vector_r <= (others=>'0');
        dp_rd_data_flow_r <= (others=>'0');
        dp_rd_data_type_r <= (others=>'0');
        dp_rd_stream_r <= '0';
        dp_rd_stream_id_r <= (others=>'0');
        dp_rd_gen_valid_r <= '0';
        dp_rd_scatter_r <= (others=>'0');
        dp_rd_scatter_cnt_r <= (others=>'0');
        dp_rd_scatter_vector_r <= (others=>'0');

        dp_rd_vaddr_rr <= (others=>'0');
        dp_rd_vector_rr <= (others=>'0');
        dp_rd_data_flow_rr <= (others=>'0');
        dp_rd_data_type_rr <= (others=>'0');
        dp_rd_stream_rr <= '0';
        dp_rd_stream_id_rr <= (others=>'0');
        dp_rd_gen_valid_rr <= '0';
        dp_rd_scatter_rr <= (others=>'0');
        dp_rd_scatter_cnt_rr <= (others=>'0');
        dp_rd_scatter_vector_rr <= (others=>'0');

        rd_x1_vector_r <= '0';
        rd_x1_vector_rr <= '0';
        rd_x1_vaddr_r <= (others=>'0');
        rd_x1_vaddr_rr <= (others=>'0');
        rd_x2_vector_r <= '0';
        rd_x2_vector_rr <= '0';
        rd_x2_vaddr_r <= (others=>'0');
        rd_x2_vaddr_rr <= (others=>'0');
        dp_rd_vector_r <= (others=>'0');
        dp_rd_vaddr_r <= (others=>'0');
    else
       if clock_in'event and clock_in='1' then
          dp_rd_gen_valid_r <= dp_rd_gen_valid_in;
          dp_rd_data_flow_r <= dp_rd_data_flow_in;
          dp_rd_data_type_r <= dp_rd_data_type_in;
          dp_rd_stream_r <= dp_rd_stream_in;
          dp_rd_stream_id_r <= dp_rd_stream_id_in;
          dp_rd_scatter_r <= dp_rd_scatter_in;
          dp_rd_scatter_cnt_r <= dp_rd_scatter_cnt_in;
          dp_rd_scatter_vector_r <= dp_rd_scatter_vector_in;
          dp_rd_vaddr_r <= dp_rd_addr_in(vector_depth_c-1 downto 0);
          dp_rd_vector_r <= dp_rd_vector_in;

          dp_rd_gen_valid_rr <= dp_rd_gen_valid_r;
          dp_rd_data_flow_rr <= dp_rd_data_flow_r;
          dp_rd_data_type_rr <= dp_rd_data_type_r;
          dp_rd_stream_rr <= dp_rd_stream_r;
          dp_rd_stream_id_rr <= dp_rd_stream_id_r;
          dp_rd_scatter_rr <= dp_rd_scatter_r;
          dp_rd_scatter_cnt_rr <= dp_rd_scatter_cnt_r;
          dp_rd_scatter_vector_rr <= dp_rd_scatter_vector_r;
          dp_rd_vaddr_rr <= dp_rd_vaddr_r;
          dp_rd_vector_rr <= dp_rd_vector_r;

          rd_x1_vector_r <= rd_x1_vector_in;
          rd_x1_vector_rr <= rd_x1_vector_r;
          rd_x1_vaddr_r <= rd_x1_addr_in(vector_depth_c-1 downto 0);
          rd_x1_vaddr_rr <= rd_x1_vaddr_r;
          rd_x2_vector_r <= rd_x2_vector_in;
          rd_x2_vector_rr <= rd_x2_vector_r;
          rd_x2_vaddr_r <= rd_x2_addr_in(vector_depth_c-1 downto 0);
          rd_x2_vaddr_rr <= rd_x2_vaddr_r;
          dp_rd_vector_r <= dp_rd_vector_in;
          dp_rd_vaddr_r <= dp_rd_addr_in(vector_depth_c-1 downto 0);
       end if;
    end if;
end process;

dp_readdata_vm  <= dp_readdata_vm1 when dp_readena_vm1='1' else dp_readdata_vm2;

--
-- Single (non-vector read) selection for DP (DataProcessor) access
---

process(dp_rd_vector_rr,dp_readdata_vm,dp_rd_vaddr_rr)
variable t:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
begin
case dp_rd_vaddr_rr is
   when "000"=>
      dp_encode <= dp_readdata_vm(1*register_width_c-1 downto 0*register_width_c);
   when "001"=>
      dp_encode <= dp_readdata_vm(2*register_width_c-1 downto 1*register_width_c);
   when "010"=>
      dp_encode <= dp_readdata_vm(3*register_width_c-1 downto 2*register_width_c);
   when "011"=>
      dp_encode <= dp_readdata_vm(4*register_width_c-1 downto 3*register_width_c);
   when "100"=>
      dp_encode <= dp_readdata_vm(5*register_width_c-1 downto 4*register_width_c);
   when "101"=>
      dp_encode <= dp_readdata_vm(6*register_width_c-1 downto 5*register_width_c);
   when "110"=>
      dp_encode <= dp_readdata_vm(7*register_width_c-1 downto 6*register_width_c);
   when others=>
      dp_encode <= dp_readdata_vm(8*register_width_c-1 downto 7*register_width_c);
end case;
end process;


rd_x1_data_vm <= rd_x1_data1_vm1 when rd_enable1_vm1='1' else rd_x1_data1_vm2; 

--
-- Single (non-vector read) selection for ALU X1 read access
---

process(rd_x1_vector_r,rd_x1_data_vm,rd_x1_vaddr_rr)
variable t:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
begin
case rd_x1_vaddr_rr is
   when "000"=>
      q1_encode <= rd_x1_data_vm(1*register_width_c-1 downto 0*register_width_c);
   when "001"=>
      q1_encode <= rd_x1_data_vm(2*register_width_c-1 downto 1*register_width_c);
   when "010"=>
      q1_encode <= rd_x1_data_vm(3*register_width_c-1 downto 2*register_width_c);
   when "011"=>
      q1_encode <= rd_x1_data_vm(4*register_width_c-1 downto 3*register_width_c);
   when "100"=>
      q1_encode <= rd_x1_data_vm(5*register_width_c-1 downto 4*register_width_c);
   when "101"=>
      q1_encode <= rd_x1_data_vm(6*register_width_c-1 downto 5*register_width_c);
   when "110"=>
      q1_encode <= rd_x1_data_vm(7*register_width_c-1 downto 6*register_width_c);
   when others=>
      q1_encode <= rd_x1_data_vm(8*register_width_c-1 downto 7*register_width_c);
end case;
end process;


rd_x2_data_vm <= rd_x2_data1_vm1 when rd_enable1_vm1='1' else rd_x2_data1_vm2; 

--
-- Single (non-vector read) selection for ALU X2 read access
---

process(rd_x2_vector_r,rd_x2_data_vm,rd_x2_vaddr_rr)
variable t:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
begin
case rd_x2_vaddr_rr is
   when "000"=>
      q2_encode <= rd_x2_data_vm(1*register_width_c-1 downto 0*register_width_c);
   when "001"=>
      q2_encode <= rd_x2_data_vm(2*register_width_c-1 downto 1*register_width_c);
   when "010"=>
      q2_encode <= rd_x2_data_vm(3*register_width_c-1 downto 2*register_width_c);
   when "011"=>
      q2_encode <= rd_x2_data_vm(4*register_width_c-1 downto 3*register_width_c);
   when "100"=>
      q2_encode <= rd_x2_data_vm(5*register_width_c-1 downto 4*register_width_c);
   when "101"=>
      q2_encode <= rd_x2_data_vm(6*register_width_c-1 downto 5*register_width_c);
   when "110"=>
      q2_encode <= rd_x2_data_vm(7*register_width_c-1 downto 6*register_width_c);
   when others=>
      q2_encode <= rd_x2_data_vm(8*register_width_c-1 downto 7*register_width_c);
end case;
end process;

-------
-- Instantiate register file for process#0
-------

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
                
                                wr_en_in => wr_en_vm1,
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
                                dp_readena_out => dp_readena_vm1
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
                
                                wr_en_in => wr_en_vm2,
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
                                dp_readena_out => dp_readena_vm2
                                );


END behavior;