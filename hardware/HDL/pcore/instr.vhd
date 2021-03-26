------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except IN compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to IN writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
------------------------------------------------------------------------------

-------
--- Implement PCORE instruction dispatcher
--- There is just one instruction dispatcher since all PCORES are executing in
--- lock step.
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.config.all;
use work.hpc_pkg.all;


ENTITY instr IS
    port(   clock_in                           : IN STD_LOGIC;
            reset_in                           : IN STD_LOGIC;

            -- DP interface
            
            SIGNAL dp_code_in                  : IN STD_LOGIC;
            SIGNAL dp_config_in                : IN STD_LOGIC;
            SIGNAL dp_wr_addr_in               : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);  
            SIGNAL dp_write_in                 : IN STD_LOGIC;
            SIGNAL dp_writedata_in             : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);

            -- Busy status
            
            SIGNAL busy_out                    : OUT STD_LOGIC_VECTOR(1 downto 0);
            SIGNAL ready_out                   : OUT STD_LOGIC;

            -- Instruction interface

            SIGNAL instruction_mu_out          : OUT STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
            SIGNAL instruction_imu_out         : OUT STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
            SIGNAL instruction_mu_valid_out    : OUT STD_LOGIC;
            SIGNAL instruction_imu_valid_out   : OUT STD_LOGIC;
            SIGNAL vm_out                      : OUT STD_LOGIC;
            SIGNAL data_model_out              : OUT dp_data_model_t;
            SIGNAL enable_out                  : OUT STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
            SIGNAL tid_out                     : OUT tid_t;
            SIGNAL tid_valid1_out              : OUT STD_LOGIC;
            SIGNAL pre_tid_out                 : OUT tid_t;
            SIGNAL pre_tid_valid1_out          : OUT STD_LOGIC;
            SIGNAL pre_pre_tid_out             : OUT tid_t;
            SIGNAL pre_pre_tid_valid1_out      : OUT STD_LOGIC;
            SIGNAL pre_pre_vm_out              : OUT STD_LOGIC;
            SIGNAL pre_pre_data_model_out      : OUT dp_data_model_t;
            SIGNAL pre_iregister_auto_out      : OUT iregister_auto_t;
            SIGNAL i_y_neg_in                  : IN STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
            SIGNAL i_y_zero_in                 : IN STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0)
            );
END instr;

ARCHITECTURE instr_behaviour of instr IS 

SIGNAL rom_addr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL rom_addr_plus_2:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL rom_data:STD_LOGIC_VECTOR (instruction_width_c-1 DOWNTO 0);

SIGNAL instruction:STD_LOGIC_VECTOR(instruction_width_c/2-1 downto 0);
SIGNAL instruction_write:STD_LOGIC;
SIGNAL instruction_write_r:STD_LOGIC;
SIGNAL instruction_addr_r:STD_LOGIC_VECTOR(instruction_depth_c-1 downto 0);
SIGNAL instruction_r:STD_LOGIC_VECTOR(instruction_width_c/2-1 downto 0);

-- Task control interface

SIGNAL task_start_addr_r:instruction_addr_t;
SIGNAL task_r:STD_LOGIC;
SIGNAL task_pcore_max_r:pcore_t;
SIGNAL task_vm_r:STD_LOGIC;
SIGNAL task_lockstep_r:STD_LOGIC;
SIGNAL task_data_model_r:dp_data_model_t;
SIGNAL task_tid_mask_r:tid_mask_t;
SIGNAL task_iregister_auto_r:iregister_auto_t;
SIGNAL instruction_mu:STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_imu:STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_mu_valid:STD_LOGIC;
SIGNAL instruction_imu_valid:STD_LOGIC;
SIGNAL vm:STD_LOGIC;
SIGNAL tid:tid_t;
SIGNAL tid_valid1:STD_LOGIC;
SIGNAL pre_tid:tid_t;
SIGNAL pre_tid_valid1:STD_LOGIC;
SIGNAL pre_pre_tid:tid_t;
SIGNAL pre_pre_tid_valid1:STD_LOGIC;
SIGNAL pcore_enable:STD_LOGIC_VECTOR(pid_gen_max_c-1 DOWNTO 0);
SIGNAL pre_pre_vm:STD_LOGIC;
SIGNAL pre_iregister_auto:iregister_auto_t;

SIGNAL y_neg:STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
SIGNAL y_zero:STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
SIGNAL y_neg_all:STD_LOGIC;
SIGNAL y_zero_all:STD_LOGIC;

SIGNAL dp_code_in_r:STD_LOGIC;
SIGNAL dp_config_in_r:STD_LOGIC;
SIGNAL dp_wr_addr_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);  
SIGNAL dp_write_in_r:STD_LOGIC;
SIGNAL dp_writedata_in_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);

attribute preserve : boolean;
attribute dont_merge : boolean;

attribute preserve of dp_code_in_r : SIGNAL is true;
attribute preserve of dp_config_in_r : SIGNAL is true;
attribute preserve of dp_wr_addr_in_r : SIGNAL is true;
attribute preserve of dp_write_in_r : SIGNAL is true;
attribute preserve of dp_writedata_in_r : SIGNAL is true;

attribute dont_merge of dp_code_in_r : SIGNAL is true;
attribute dont_merge of dp_config_in_r : SIGNAL is true;
attribute dont_merge of dp_wr_addr_in_r : SIGNAL is true;
attribute dont_merge of dp_write_in_r : SIGNAL is true;
attribute dont_merge of dp_writedata_in_r : SIGNAL is true;

BEGIN

------
-- Instantiate ROM for code space
------

instruction <= dp_writedata_in_r(instruction'length-1 downto 0);

instruction_write <= '1' when (dp_write_in_r='1' and dp_code_in_r='1' ) else '0';

y_neg_all <= '0' when i_y_neg_in=std_logic_vector(to_unsigned(0,pid_gen_max_c)) else '1';

y_zero_all <= '0' when i_y_zero_in=std_logic_vector(to_unsigned(0,pid_gen_max_c)) else '1';

rom_i: rom2 port map(clock_in=>clock_in,
                    reset_in=>reset_in,
                    rdaddress_in=>rom_addr,
                    rdaddress_plus_2_in=>rom_addr_plus_2,
                    instruction_out=>rom_data,
                    wren_in=>instruction_write_r,
                    wraddress_in=>instruction_addr_r,
                    wrdata_in=>instruction_r
                    );

instr_fetch_i: instr_fetch port map(clock_in=>clock_in,
                                    reset_in=>reset_in,
                                    instruction_mu_out => instruction_mu_out,
                                    instruction_imu_out => instruction_imu_out,
                                    instruction_mu_valid_out => instruction_mu_valid_out,
                                    instruction_imu_valid_out => instruction_imu_valid_out,
                                    instruction_vm_out=>vm_out,
											instruction_data_model_out=>data_model_out,
                                    instruction_tid_out =>tid_out,
                                    instruction_tid_valid_out =>tid_valid1_out,

                                    instruction_pre_tid_out =>pre_tid_out,
                                    instruction_pre_tid_valid_out =>pre_tid_valid1_out,
                                    instruction_pre_pre_tid_out =>pre_pre_tid_out,
                                    instruction_pre_pre_tid_valid_out =>pre_pre_tid_valid1_out,

                                    instruction_pre_pre_vm_out => pre_pre_vm_out,
                                    instruction_pre_pre_data_model_out => pre_pre_data_model_out,

                                    instruction_pre_iregister_auto_out => pre_iregister_auto_out,

                                    instruction_pcore_enable_out => enable_out,

                                    i_y_neg_in => y_neg_all,
                                    i_y_zero_in => y_zero_all,

                                    rom_addr_out=>rom_addr,
                                    rom_addr_plus_2_out=>rom_addr_plus_2,
                                    rom_data_in=>rom_data,

                                    busy_out=>busy_out,
                                    ready_out=>ready_out,
                                    task_start_addr_in=>task_start_addr_r,
                                    task_in=>task_r,
                                    task_pcore_max_in=>task_pcore_max_r,
                                    task_vm_in=>task_vm_r,
                                    task_lockstep_in=>task_lockstep_r,
                                    task_tid_mask_in=>task_tid_mask_r,
                                    task_iregister_auto_in=>task_iregister_auto_r,											task_data_model_in=>task_data_model_r
                                    );

process(clock_in,reset_in)
begin
    if reset_in='0' then
        instruction_write_r <= '0';
        instruction_addr_r <= (others=>'0');
        instruction_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
           instruction_write_r <= instruction_write;
           instruction_addr_r <= dp_wr_addr_in_r(instruction_depth_c-1 downto 0);
           instruction_r <= instruction;
        end if;
    end if;
end process;

-----
-- MUX read access between process0 and process1
------

process(clock_in,reset_in)
variable lockstep_v:STD_LOGIC;
variable task_data_model_v:dp_data_model_t;
variable task_pcore_v:pcore_t;
variable dp_config_reg_v:dp_config_reg_t; 
variable tid_mask_v:tid_mask_t;
variable iregister_auto_v:iregister_auto_t;
variable data_model_v:dp_data_model_t;
variable pos_v:integer;
begin
    if reset_in='0' then 
       task_start_addr_r <= (others=>'0');
       task_vm_r <= '0';
       task_r <= '0';
       task_pcore_max_r <= (others=>'0');
       task_lockstep_r <= '0';
       task_tid_mask_r <= (others=>'1');
       task_iregister_auto_r <= (others=>'0');
       task_data_model_r <= (others=>'0');
       dp_code_in_r <= '0';
       dp_config_in_r <= '0';
       dp_wr_addr_in_r <= (others=>'0');  
       dp_write_in_r <= '0';
       dp_writedata_in_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then

           dp_code_in_r <= dp_code_in;
           dp_config_in_r <= dp_config_in;
           dp_wr_addr_in_r <= dp_wr_addr_in;  
           dp_write_in_r <= dp_write_in;
           dp_writedata_in_r <= dp_writedata_in;

           dp_config_reg_v := unsigned(dp_wr_addr_in_r(dp_config_reg_t'length-1 downto 0));
           pos_v:=0;
           task_start_addr_r <= dp_writedata_in_r(pos_v+task_start_addr_r'length-1 downto pos_v);
           pos_v:=pos_v+task_start_addr_r'length;
           task_pcore_v := unsigned(dp_writedata_in_r(pos_v+pcore_t'length-1 downto pos_v));
           pos_v:=pos_v+pcore_t'length;
           lockstep_v := dp_writedata_in_r(pos_v);
           pos_v:=pos_v+1;
           tid_mask_v := dp_writedata_in_r(pos_v+tid_mask_v'length-1 downto pos_v);
           pos_v:=pos_v+tid_mask_v'length;
           iregister_auto_v := unsigned(dp_writedata_in_r(pos_v+iregister_auto_v'length-1 downto pos_v));
           pos_v:=pos_v+iregister_auto_v'length;
           data_model_v := dp_writedata_in_r(pos_v+data_model_v'length-1 downto pos_v);

           if dp_config_reg_v=dp_config_reg_exe_vm1_c then
              task_vm_r <= '0';
           else 
              task_vm_r <= '1';
           end if;
           if (dp_write_in_r='1' and dp_config_in_r='1' and ((dp_config_reg_v=dp_config_reg_exe_vm1_c) or (dp_config_reg_v=dp_config_reg_exe_vm2_c))) then
              task_r <= '1';
              task_pcore_max_r <= task_pcore_v(pcore_t'length-1 downto 0);
              task_lockstep_r <= lockstep_v;
              task_tid_mask_r <= tid_mask_v;
              task_iregister_auto_r <= iregister_auto_v;
              task_data_model_r <= data_model_v;
           else
              task_r <= '0';
              task_pcore_max_r <=(others=>'0');
              task_lockstep_r <= '0';
              task_tid_mask_r <= (others=>'1');
              task_iregister_auto_r <= (others=>'0');
              task_data_model_r <= (others=>'0');
           end if;
        end if;
    end if;
end process;


END instr_behaviour;
