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
-- This module is implementing the instruction fetching stage for the pcore unit
-- This implements the round robin scheduling scheme amoung the tid_max_c hardware thread
-- This entity communicates with decoder and dispatcher stages.
-- Instruction fetching is done via ROM interface
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.ztachip_pkg.all;
use work.config.all;

ENTITY instr_fetch IS 
   PORT(    
        SIGNAL clock_in                           : IN STD_LOGIC;
        SIGNAL reset_in                           : IN STD_LOGIC;

        -- Interface to instruction decoder stage

        SIGNAL instruction_mu_out                 : OUT STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_imu_out                : OUT STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
        SIGNAL instruction_mu_valid_out           : OUT STD_LOGIC;
        SIGNAL instruction_imu_valid_out          : OUT STD_LOGIC;
        SIGNAL instruction_vm_out                 : OUT STD_LOGIC;
        SIGNAL instruction_data_model_out         : OUT dp_data_model_t;
        SIGNAL instruction_tid_out                : OUT tid_t;
        SIGNAL instruction_tid_valid_out          : OUT STD_LOGIC; 
        SIGNAL instruction_pre_tid_out            : OUT tid_t;  -- TID value for next clock                                        
        SIGNAL instruction_pre_tid_valid_out      : OUT STD_LOGIC;  -- TID value for next clock                                        
        SIGNAL instruction_pre_pre_tid_out        : OUT tid_t;  -- TID value for next clock                                        
        SIGNAL instruction_pre_pre_tid_valid_out  : OUT STD_LOGIC; -- Tid valid for next clock
        SIGNAL instruction_pre_pre_vm_out         : OUT STD_LOGIC;
        SIGNAL instruction_pre_pre_data_model_out : OUT dp_data_model_t;
        SIGNAL instruction_pcore_enable_out       : OUT STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
        SIGNAL instruction_pre_iregister_auto_out : OUT iregister_auto_t;

        -- Interface with ROM for instruction fetching

        SIGNAL rom_addr_out                       : OUT STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);  -- ROM Address of next instruction
        SIGNAL rom_addr_plus_2_out                : OUT STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);  -- ROM Address of next instruction+1
        SIGNAL rom_data_in                        : IN STD_LOGIC_VECTOR (instruction_width_c-1 DOWNTO 0);  -- ROM data for fetched instruction
            
        -- Ready indication. Indicates which threads are available for new execution

        SIGNAL busy_out                           : OUT STD_LOGIC_VECTOR(1 downto 0);
        SIGNAL ready_out                          : OUT STD_LOGIC;

        -- To start a thread 

        SIGNAL task_start_addr_in                 : IN instruction_addr_t;    -- Address to start execution
        SIGNAL task_in                            : IN STD_LOGIC;
        SIGNAL task_pcore_max_in                  : IN pcore_t;
        SIGNAL task_vm_in                         : IN STD_LOGIC;
        SIGNAL task_lockstep_in                   : IN STD_LOGIC;
        SIGNAL task_tid_mask_in                   : IN tid_mask_t;
        SIGNAL task_iregister_auto_in             : IN iregister_auto_t;
        SIGNAL task_data_model_in                 : IN dp_data_model_t;

        -- Result from IALU
        SIGNAL i_y_neg_in                         : IN STD_LOGIC;
        SIGNAL i_y_zero_in                        : IN STD_LOGIC
        );
END instr_fetch;

ARCHITECTURE behavior OF instr_fetch IS
    
-- Signals/register used for thread control
    
type pc_t IS ARRAY(0 TO tid_max_c-1) OF STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL pc_r:pc_t; -- Thread program counter
SIGNAL busy_r:STD_LOGIC_VECTOR(tid_max_c-1 DOWNTO 0); -- Thread read state (registered)
SIGNAL vm_r:STD_LOGIC_VECTOR(tid_max_c-1 DOWNTO 0);
SIGNAL vm_rr:STD_LOGIC_VECTOR(tid_max_c-1 DOWNTO 0);
SIGNAL data_model_r:dp_data_models_t(tid_max_c-1 downto 0);
SIGNAL data_model_rr:dp_data_models_t(tid_max_c-1 downto 0);
SIGNAL iregister_auto_r:iregister_autos_t(tid_max_c-1 downto 0);
SIGNAL iregister_auto_rr:iregister_autos_t(tid_max_c-1 downto 0);
SIGNAL instruction_tid_r:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_rr:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_rrr:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_rrrr:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_rrrrr:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_rrrrrr:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_rrrrrrr:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_rrrrrrrr:tid_t; -- TID to send to decoder stage
SIGNAL instruction_tid_valid_r:STD_LOGIC;
SIGNAL tid:std_logic_vector(tid_max_c-1 downto 0); -- TID in ROM requesting stage
SIGNAL tid_delay:std_logic_vector(tid_max_c-1 downto 0); -- TID in ROM requesting stage
SIGNAL tid_r:std_logic_vector(tid_max_c-1 downto 0); -- TID in ROM requesting stage
SIGNAL tid_valid_r:STD_LOGIC;
SIGNAL tid_rr:std_logic_vector(tid_max_c-1 downto 0); -- TID in ROM reading stage
SIGNAL tid_valid_rr:STD_LOGIC;
SIGNAL tid_valid_rrr:STD_LOGIC;
SIGNAL tid_rrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in decoding stage
SIGNAL tid_rrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage
SIGNAL tid_rrrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage
SIGNAL tid_rrrrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage
SIGNAL tid_rrrrrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage        
SIGNAL tid_rrrrrrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage        
SIGNAL tid_rrrrrrrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage        
SIGNAL tid_rrrrrrrrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage        
SIGNAL tid_rrrrrrrrrrr:std_logic_vector(tid_max_c-1 downto 0); -- TID in execution stage        
SIGNAL tid2_r:tid_t;
SIGNAL tid2_rr:tid_t;
SIGNAL tid2_rrr:tid_t;

-- Signals/registers used to do instruction fetching 
    
SIGNAL rom_addr: STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0); -- Address of instruction to be fetched (calculate)
SIGNAL rom_addr_r: STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0); -- Address of instruction to be fetched (registed)
SIGNAL rom_addr_rr: STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0); -- Address of instruction to be fetched (registed)
    
-- Signals/Registers used to calculate thread delay
   
type delays_t IS ARRAY(0 to tid_max_c-1) OF STD_LOGIC;
SIGNAL delay_r:delays_t; -- Instruction delay (registered)

-- Task list
SIGNAL busy1:STD_LOGIC_VECTOR(0 to tid_max_c-1); -- Thread ready state (calculate)
SIGNAL busy2:STD_LOGIC_VECTOR(1 downto 0); -- Thread ready state (calculate)
SIGNAL busy2_r:STD_LOGIC_VECTOR(1 downto 0); -- Thread ready state (calculate)
    
-- Signals/registers used by thread scheduler

SIGNAL avail:STD_LOGIC_VECTOR(tid_max_c-1 DOWNTO 0);
SIGNAL avail_r:STD_LOGIC_VECTOR(tid_max_c-1 DOWNTO 0);    
SIGNAL next_tid:std_logic_vector(tid_max_c-1 downto 0); -- Next TID table (calculate)
SIGNAL next_tid2:tid_t;
SIGNAL next_tid_valid:STD_LOGIC;

SIGNAL instruction_mu_r:STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_imu_r:STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_mu_valid_r:std_logic;
SIGNAL instruction_imu_valid_r:std_logic;
SIGNAL instruction_tid:tid_t;
SIGNAL instruction_tid_valid:STD_LOGIC; 
SIGNAL instruction_pre_tid:tid_t;
SIGNAL instruction_pre_tid_valid:STD_LOGIC;                                    
SIGNAL instruction_pre_pre_tid:tid_t;                                       
SIGNAL instruction_pre_pre_tid_valid:STD_LOGIC;

SIGNAL task_start_addr_r:instruction_addr_t;
SIGNAL task_pcore_max_r:pcore_t;
SIGNAL task_pcore_curr_r:pcore_t;
SIGNAL task_tid_mask_r:STD_LOGIC_VECTOR(tid_max_c-1 downto 0):=(others=>'1');
SIGNAL task_tid_mask:STD_LOGIC_VECTOR(tid_max_c-1 downto 0);
SIGNAL task_lockstep_r:STD_LOGIC;
SIGNAL task_mask_r:STD_LOGIC_VECTOR(tid_max_c-1 downto 0);
SIGNAL task_vm_r:STD_LOGIC;
SIGNAL task_iregister_auto_r:iregister_auto_t;
SIGNAL task2_data_model_r:dp_data_model_t;

SIGNAL mu_instruction:STD_LOGIC_VECTOR (mu_instruction_width_c-1 DOWNTO 0);
SIGNAL imu_instruction:STD_LOGIC_VECTOR (imu_instruction_width_c-1 DOWNTO 0);
SIGNAL ctrl_instruction:STD_LOGIC_VECTOR (ctrl_instruction_width_c-1 DOWNTO 0);
   
------------  
-- CONTROL variables
------------

SIGNAL instruction_addr_r:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL instruction_addr_rr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);

SIGNAL got_control_r:STD_LOGIC;
SIGNAL got_control_rr:STD_LOGIC;
SIGNAL got_control_rrr:STD_LOGIC;
SIGNAL got_control_rrrr:STD_LOGIC;
SIGNAL got_control_rrrrr:STD_LOGIC;
SIGNAL got_control_rrrrrr:STD_LOGIC;
SIGNAL got_control_rrrrrrr:STD_LOGIC;
SIGNAL got_control_rrrrrrrr:STD_LOGIC;

SIGNAL ctrl_opcode_r:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL ctrl_goto_addr_r:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);
SIGNAL ctrl_opcode_rr:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL ctrl_goto_addr_rr:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);
SIGNAL ctrl_opcode_rrr:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL ctrl_goto_addr_rrr:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);
SIGNAL ctrl_next_addr_r:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL ctrl_next_addr_rr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL ctrl_next_addr_rrr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL ctrl_next_addr_rrrr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL ctrl_next_addr_rrrrr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL ctrl_next_addr_rrrrrr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
SIGNAL ctrl_ready_r:STD_LOGIC;
SIGNAL ctrl_opcode_rrrr:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL ctrl_opcode_rrrrr:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL ctrl_opcode_rrrrrr:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL ctrl_opcode_rrrrrrr:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);
SIGNAL ctrl_opcode_rrrrrrrr:STD_LOGIC_VECTOR(ctrl_instruction_oc_width_c-1 DOWNTO 0);

SIGNAL ctrl_goto_addr_rrrr:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);
SIGNAL ctrl_goto_addr_rrrrr:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);
SIGNAL ctrl_goto_addr_rrrrrr:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);
SIGNAL ctrl_goto_addr_rrrrrrr:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);
SIGNAL ctrl_goto_addr_rrrrrrrr:STD_LOGIC_VECTOR(ctrl_instruction_goto_addr_width_c-1 downto 0);

SIGNAL ctrl_jump:STD_LOGIC;
SIGNAL ctrl_ret_func:STD_LOGIC;

SIGNAL next_addr:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);   -- Next address from dispatcher stage
SIGNAL ready:STD_LOGIC;                                          -- 0: Continue, 1:Current instruction is the end

SIGNAL instruction_pcore_enable_r:STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
SIGNAL instruction_pcore_enable_rr:STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);

SIGNAL tid_vm:STD_LOGIC;
SIGNAL tid_vm_r:STD_LOGIC;
SIGNAL tid_vm_rr:STD_LOGIC;

SIGNAL task_data_model:dp_data_model_t;
SIGNAL task_data_model_r:dp_data_model_t;
SIGNAL task_data_model_rr:dp_data_model_t;

SIGNAL tid_iregister_auto:iregister_auto_t;
SIGNAL tid_iregister_auto_r:iregister_auto_t;

SIGNAL ready2:STD_LOGIC;

--constant proc_delay_c:integer:=14-pipeline_latency_c-1;
constant proc_delay_c:integer:=11-pipeline_latency_c-1;

-----
-- Generate task mask
-----
subtype gen_task_mask_retval_t is std_logic_vector(tid_max_c-1 downto 0);
function gen_task_mask(tid_mask_in:tid_mask_t)
    return gen_task_mask_retval_t is
variable mask_v:std_logic_vector(tid_max_c-1 downto 0);
begin
case tid_mask_in is
   when "0000" => mask_v:= "0000000000000001";
   when "0001" => mask_v:= "0000000000000011";
   when "0010" => mask_v:= "0000000000000111";
   when "0011" => mask_v:= "0000000000001111";
   when "0100" => mask_v:= "0000000000011111";
   when "0101" => mask_v:= "0000000000111111";
   when "0110" => mask_v:= "0000000001111111";
   when "0111" => mask_v:= "0000000011111111";
   when "1000" => mask_v:= "0000000111111111";
   when "1001" => mask_v:= "0000001111111111";
   when "1010" => mask_v:= "0000011111111111";
   when "1011" => mask_v:= "0000111111111111";
   when "1100" => mask_v:= "0001111111111111";
   when "1101" => mask_v:= "0011111111111111";
   when "1110" => mask_v:= "0111111111111111";
   when others => mask_v:= "1111111111111111";
end case;
return mask_v;
end function gen_task_mask;


subtype mask2num_retval_t is unsigned(tid_t'length-1 downto 0);
function mask2num(gnt:std_logic_vector(tid_max_c-1 downto 0))
    return mask2num_retval_t is
variable signo_v:mask2num_retval_t;
begin
    if gnt(7 downto 0) = "00000000" then
       if gnt(11 downto 8)="0000" then
          if gnt(12)='1' then
             signo_v := to_unsigned(12,tid_t'length);
          elsif gnt(13)='1' then
             signo_v := to_unsigned(13,tid_t'length);
          elsif gnt(14)='1' then
             signo_v := to_unsigned(14,tid_t'length);
          else 
             signo_v := to_unsigned(15,tid_t'length);
          end if;
       else
          if gnt(8)='1' then
             signo_v := to_unsigned(8,tid_t'length);
          elsif gnt(9)='1' then
             signo_v := to_unsigned(9,tid_t'length);
          elsif gnt(10)='1' then
             signo_v := to_unsigned(10,tid_t'length);
          else
             signo_v := to_unsigned(11,tid_t'length);
          end if;
       end if;
    else
       if gnt(3 downto 0)="0000" then
          if gnt(4)='1' then
             signo_v := to_unsigned(4,tid_t'length);
          elsif gnt(5)='1' then
             signo_v := to_unsigned(5,tid_t'length);
          elsif gnt(6)='1' then
             signo_v := to_unsigned(6,tid_t'length);
          else
             signo_v := to_unsigned(7,tid_t'length);
          end if;
       else
          if gnt(0)='1' then
             signo_v := to_unsigned(0,tid_t'length);
          elsif gnt(1)='1' then
             signo_v := to_unsigned(1,tid_t'length);
          elsif gnt(2)='1' then
             signo_v := to_unsigned(2,tid_t'length);
          else
             signo_v := to_unsigned(3,tid_t'length);
          end if;
       end if;
    end if;
    return signo_v;
end function mask2num;

BEGIN 

--------
-- Map to output/input signals
--------

instruction_mu_out <= instruction_mu_r;
instruction_mu_valid_out <= instruction_mu_valid_r;
instruction_imu_out <= instruction_imu_r;
instruction_imu_valid_out <= instruction_imu_valid_r;
instruction_tid_out <= tid2_rrr; 
instruction_tid_valid_out <= tid_valid_rrr;
instruction_pre_tid_out <= tid2_rr;
instruction_pre_tid_valid_out <= tid_valid_rr;
instruction_pre_pre_tid_out <= tid2_r;
instruction_pre_pre_tid_valid_out <= tid_valid_r;
instruction_pre_pre_vm_out <= tid_vm;
instruction_pre_pre_data_model_out <= task_data_model;
instruction_pcore_enable_out <= instruction_pcore_enable_rr;
instruction_vm_out <= tid_vm_rr;
instruction_data_model_out <= task_data_model_rr;
instruction_pre_iregister_auto_out <= tid_iregister_auto_r;


instruction_tid <= instruction_tid_r;
instruction_tid_valid <= instruction_tid_valid_r;
instruction_pre_tid <= tid2_rr;
instruction_pre_tid_valid <= tid_valid_rr;
instruction_pre_pre_tid <= tid2_r;
instruction_pre_pre_tid_valid <= tid_valid_r;


tid_iregister_auto <= iregister_auto_rr(to_integer(tid2_r));

tid_vm <= vm_rr(to_integer(tid2_r));

task_data_model <= data_model_rr(to_integer(tid2_r));

rom_addr <= pc_r(to_integer(tid2_r));

rom_addr_out <= rom_addr;

rom_addr_plus_2_out <= std_logic_vector(unsigned(rom_addr)+2);

busy_out(0) <= '1' when busy2_r(0)='1' or (ready2='0' and task_vm_r='0') else '0';

busy_out(1) <= '1' when busy2_r(1)='1' or (ready2='0' and task_vm_r='1') else '0';

ready2 <= '1' when (task_mask_r=std_logic_vector(to_unsigned(0,tid_max_c))) and 
                      ((task_pcore_max_r=task_pcore_curr_r) or (task_lockstep_r='1'))
                      else '0';

ready_out <= ready2;

delay_i: delayv generic map(SIZE=>tid_max_c,DEPTH =>proc_delay_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>tid_rrrrrrrrrrr,out_out=>tid_delay,enable_in=>'1');

----
-- Determine if a thread is still busy
-- A process (vm) is busy if any of its threads are still busy
---

process(busy_r,delay_r,busy1,vm_r,data_model_r)
VARIABLE busy_v:STD_LOGIC_VECTOR(1 downto 0);
begin
    for I in 0 to tid_max_c-1 loop
        if busy_r(I)='0' and delay_r(I)='0' then
            busy1(I) <= '0';
        else
            busy1(I) <= '1';
        end if;
    end loop;
    busy_v := (others=>'0');
    for I in 0 to tid_max_c-1 loop
        busy_v(0) := busy_v(0) or (busy1(I) and (not vm_r(I)));
        busy_v(1) := busy_v(1) or (busy1(I) and (vm_r(I)));
    end loop;
    busy2 <= busy_v;
end process;

-------
-- Latch registers
-------

process(clock_in,reset_in)
begin
    if reset_in='0' then
        instruction_tid_r <= (others=>'0');
        instruction_tid_rr <= (others=>'0');
        instruction_tid_rrr <= (others=>'0');
        instruction_tid_rrrr <= (others=>'0');
        instruction_tid_rrrrr <= (others=>'0');
        instruction_tid_rrrrrr <= (others=>'0');
        instruction_tid_rrrrrrr <= (others=>'0');
        instruction_tid_rrrrrrrr <= (others=>'0');
        instruction_tid_valid_r <= '0';
        busy2_r <= (others=>'0');
        tid_rrrrrrrrrrr <= (others=>'0');
        tid_rrrrrrrrrr <= (others=>'0');
        tid_rrrrrrrrr <= (others=>'0');
        tid_rrrrrrrr <= (others=>'0');
        tid_rrrrrrr <= (others=>'0');
        tid_rrrrrr <= (others=>'0');
        tid_rrrrr <= (others=>'0');
        tid_rrrr <= (others=>'0');
        tid_rrr <= (others=>'0');
        tid_rr <= (others=>'0');
        tid_r <= (others=>'0');
        tid_valid_rrr <= '0';
        tid_valid_rr <= '0';
        tid_valid_r <= '0';
        rom_addr_r <= (others=>'0');
        rom_addr_rr <= (others=>'0');
        tid2_r <= (others=>'0');
        tid2_rr <= (others=>'0');
        tid2_rrr <= (others=>'0');
        instruction_mu_r <= (others=>'0');
        instruction_imu_r <= (others=>'0');
        instruction_mu_valid_r <= '0';
        instruction_imu_valid_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            if tid_valid_rr='1' and mu_instruction(mu_instruction_oc_hi_c downto mu_instruction_oc_lo_c)/=opcode_null_c then
               instruction_mu_valid_r <= '1';
            else
               instruction_mu_valid_r <= '0';
            end if;
            if (tid_valid_rr='1') and imu_instruction(imu_instruction_oc_hi_c downto imu_instruction_oc_lo_c)/=opcode_null_c then
               instruction_imu_valid_r <= '1';
            else
               instruction_imu_valid_r <= '0';
            end if;
            instruction_mu_r <= mu_instruction;
            instruction_imu_r <= imu_instruction;

            rom_addr_rr <= rom_addr_r;
            rom_addr_r <= rom_addr;
            busy2_r <= busy2;
            tid_rrrrrrrrrrr <= tid_rrrrrrrrrr;
            tid_rrrrrrrrrr <= tid_rrrrrrrrr;
            tid_rrrrrrrrr <= tid_rrrrrrrr;
            tid_rrrrrrrr <= tid_rrrrrrr;
            tid_rrrrrrr <=  tid_rrrrrr;
            tid_rrrrrr <= tid_rrrrr;
            tid_rrrrr <= tid_rrrr;
            tid_rrrr <= tid_rrr;
            tid_rrr <= tid_rr;
            tid_rr <= tid_r;
            tid_r <= next_tid;
            tid2_r <= next_tid2;
            tid2_rr <= tid2_r;
            tid2_rrr <= tid2_rr;
            tid_valid_rrr <= tid_valid_rr;
            tid_valid_rr <= tid_valid_r;
            tid_valid_r <= next_tid_valid;
            instruction_tid_r <= tid2_rr;
            instruction_tid_rr <= instruction_tid_r;
            instruction_tid_rrr <= instruction_tid_rr;
            instruction_tid_rrrr <= instruction_tid_rrr;
            instruction_tid_rrrrr <= instruction_tid_rrrr;
            instruction_tid_rrrrrr <= instruction_tid_rrrrr;
            instruction_tid_rrrrrrr <= instruction_tid_rrrrrr;
            instruction_tid_rrrrrrrr <= instruction_tid_rrrrrrr;
            instruction_tid_valid_r <= tid_valid_rr;
        end if;
    end if;
end process;

avail <= (avail_r);

------
--- Using an arbiter to find next available TID to be executed
------

next_tid2 <= mask2num(next_tid);

arbiter_1_i: arbiter generic map(
                        NUM_SIGNALS=>tid_max_c,
                        PRIORITY_BASED=>FALSE
                        )
                    port map(
                        clock_in=>clock_in,
                        reset_in=>reset_in,
                        req_in=>avail,
                        gnt_out=>next_tid,
                        gnt_valid_out=>next_tid_valid);


----- 
-- tid represents which TID is currently in the processing pipeline
-----

tid <= tid_rrrrrrr or tid_rrrrrr or tid_rrrrr or tid_rrrr or tid_rrr or tid_rr or tid_r;

task_tid_mask <= gen_task_mask(task_tid_mask_in);

-------
-- Calculate new values for PC registers.
-------

process(reset_in,clock_in)
variable pc_v:STD_LOGIC_VECTOR(instruction_depth_c-1 DOWNTO 0);
variable busy_v:std_logic;
variable delay_v:std_logic;
variable vm_v:std_logic;
variable data_model_v:dp_data_model_t;
variable latch_iregister_auto_v:std_logic;
begin
    if reset_in='0' then
        task_pcore_max_r <= (others=>'0');
        task_pcore_curr_r <= (others=>'0');
        task_start_addr_r <= (others=>'0');
        task_tid_mask_r <= (others=>'1');
        task_lockstep_r <= '0';
        task_mask_r <= (others=>'0');
        delay_r <= (others=>'0');
        pc_r <= (others=>(others=>'0'));
        busy_r <= (others=>'0');
        avail_r <= (others=>'0');  
        vm_r <= (others=>'0');
        vm_rr <= (others=>'0');
        data_model_r <= (others=>(others=>'0'));
        data_model_rr <= (others=>(others=>'0'));
        task_vm_r <= '0';
        task2_data_model_r <= (others=>'0');
        tid_vm_r <= '0';
        tid_vm_rr <= '0';
        tid_iregister_auto_r <= (others=>'0');
        iregister_auto_r <= (others=>(others=>'0'));
        iregister_auto_rr <= (others=>(others=>'0'));
        task_iregister_auto_r <= (others=>'0');
        task_data_model_r <= (others=>'0');
        task_data_model_rr <= (others=>'0');
    else 
    if clock_in'event and clock_in='1' then
        tid_vm_r <= tid_vm;
        tid_vm_rr <= tid_vm_r;
        task_data_model_r <= task_data_model;
        task_data_model_rr <= task_data_model_r;
        iregister_auto_rr <= iregister_auto_r;
        vm_rr <= vm_r;
        data_model_rr <= data_model_r;
        tid_iregister_auto_r <= tid_iregister_auto;
        if task_in='1' then
            task_start_addr_r <= task_start_addr_in;
            task_pcore_max_r <= task_pcore_max_in;
            task_pcore_curr_r <= (others=>'0');
            task_lockstep_r <= task_lockstep_in;
            task_mask_r <= task_tid_mask;
            task_vm_r <= task_vm_in;
            task_iregister_auto_r <= task_iregister_auto_in;
            task_tid_mask_r <= task_tid_mask;
            task2_data_model_r <= task_data_model_in;
       end if;

       if (task_mask_r=std_logic_vector(to_unsigned(0,tid_max_c)) and 
          (task_pcore_max_r /= task_pcore_curr_r) and 
          task_lockstep_r='0' and
          busy_r=std_logic_vector(to_unsigned(0,tid_max_c))) then
          task_pcore_curr_r <= unsigned(task_pcore_curr_r)+1;
          task_mask_r <= task_tid_mask_r;
       end if;

       FOR I in 0 to tid_max_c-1 LOOP
           if busy_r(I)='0' and task_mask_r(I)='1' and tid_rrrrrrrrrrr(I)='0' then
               -- Launch this thread...
               pc_v := task_start_addr_r;
               busy_v := '1';
               vm_v := task_vm_r;
               data_model_v := task2_data_model_r;
               task_mask_r(I) <= '0';
               if (tid(I)='1') then
                   delay_v := '1';
               elsif tid_delay(I)='1' then
                   delay_v := '0';
               else
                   delay_v := delay_r(I);
               end if;
               latch_iregister_auto_v := '1';
           else
               vm_v := vm_r(I);
               data_model_v := data_model_r(I);
               if tid_rrrrrrrrrrr(I)='1' then
                   -- Reach the end of processing for this TID. 
                   pc_v := next_addr;
                   busy_v := not ready;
                   delay_v := '1';
               else
                   pc_v := pc_r(I);
                   busy_v := busy_r(I);
                   if (tid(I)='1') then
                       delay_v := '1';
                   elsif tid_delay(I)='1' then
                       delay_v := '0';
                   else
                       delay_v := delay_r(I);
                   end if;
               end if;
               latch_iregister_auto_v := '0';
           end if;
           pc_r(I) <= pc_v;
           busy_r(I) <= busy_v;
           delay_r(I) <= delay_v;
           vm_r(I) <= vm_v;
           data_model_r(I) <= data_model_v;
           if latch_iregister_auto_v='1' then
               iregister_auto_r(I) <= task_iregister_auto_r;
           end if;
           if busy_v='1' and delay_v='0' and next_tid(I)='0' then
               avail_r(I) <= '1';
           else
               avail_r(I) <= '0';
           end if;
       end loop;
    end if;
    end if;
end process;


--
-- Instruction opcodes
-- Each instruction can have a vector opcode(mu), scalar opcode(imu) and control opcode
----

mu_instruction <= rom_data_in(rom_data_in'length-1 downto imu_instruction_width_c+ctrl_instruction_width_c);
imu_instruction <= rom_data_in(imu_instruction_width_c+ctrl_instruction_width_c-1 downto ctrl_instruction_width_c);
ctrl_instruction <= rom_data_in(ctrl_instruction_width_c-1 downto 0);

next_addr <= ctrl_next_addr_rrrrrr;
ready <= ctrl_ready_r;

process(clock_in,reset_in)    
variable index:integer;
begin
if reset_in='0' then
    ctrl_next_addr_r <= (others=>'0');
    ctrl_next_addr_rr <= (others=>'0');
    ctrl_next_addr_rrr <= (others=>'0');
    ctrl_next_addr_rrrr <= (others=>'0');
    ctrl_next_addr_rrrrr <= (others=>'0');
    ctrl_next_addr_rrrrrr <= (others=>'0');
    ctrl_ready_r <= '0';
    ctrl_goto_addr_rr <= (others=>'0');
    ctrl_goto_addr_rrr <= (others=>'0');
    ctrl_goto_addr_rrrr <= (others=>'0');
    ctrl_goto_addr_rrrrr <= (others=>'0');
    ctrl_goto_addr_rrrrrr <= (others=>'0');
    ctrl_goto_addr_rrrrrrr <= (others=>'0');
    ctrl_goto_addr_rrrrrrrr <= (others=>'0');
    ctrl_opcode_rr <= (others=>'0');
    ctrl_opcode_rrr <= (others=>'0');
    ctrl_opcode_rrrr <= (others=>'0');
    ctrl_opcode_rrrrr <= (others=>'0');
    ctrl_opcode_rrrrrr <= (others=>'0');
    ctrl_opcode_rrrrrrr <= (others=>'0');
    ctrl_opcode_rrrrrrrr <= (others=>'0');
    got_control_rr <= '0';
    got_control_rrr <= '0';
    got_control_rrrr <= '0';
    got_control_rrrrr <= '0';
    got_control_rrrrrr <= '0';
    got_control_rrrrrrr <= '0';
    got_control_rrrrrrrr <= '0';
else
    if clock_in'event and clock_in='1' then
        if (tid_valid_rr='1') and ctrl_instruction(ctrl_instruction_oc_hi_c DOWNTO ctrl_instruction_oc_lo_c)/=opcode_null_c then
           got_control_r <= '1';
        else
           got_control_r <= '0';
        end if;

        ctrl_opcode_r <= ctrl_instruction(ctrl_instruction_oc_hi_c DOWNTO ctrl_instruction_oc_lo_c);
        ctrl_goto_addr_r <= ctrl_instruction(ctrl_instruction_goto_addr_hi_c DOWNTO ctrl_instruction_goto_addr_lo_c);
        
        got_control_rr <= got_control_r;
        got_control_rrr <= got_control_rr;
        got_control_rrrr <= got_control_rrr;
        got_control_rrrrr <= got_control_rrrr;
        got_control_rrrrrr <= got_control_rrrrr;
        got_control_rrrrrrr <= got_control_rrrrrr;
        got_control_rrrrrrrr <= got_control_rrrrrrr;

        ctrl_opcode_rr <= ctrl_opcode_r;
        ctrl_opcode_rrr <= ctrl_opcode_rr;
        ctrl_opcode_rrrr <= ctrl_opcode_rrr;
        ctrl_opcode_rrrrr <= ctrl_opcode_rrrr;
        ctrl_opcode_rrrrrr <= ctrl_opcode_rrrrr;
        ctrl_opcode_rrrrrrr <= ctrl_opcode_rrrrrr;
        ctrl_opcode_rrrrrrrr <= ctrl_opcode_rrrrrrr;

        ctrl_goto_addr_rr <= ctrl_goto_addr_r;
        ctrl_goto_addr_rrr <= ctrl_goto_addr_rr;
        ctrl_goto_addr_rrrr <= ctrl_goto_addr_rrr;
        ctrl_goto_addr_rrrrr <= ctrl_goto_addr_rrrr;
        ctrl_goto_addr_rrrrrr <= ctrl_goto_addr_rrrrr;
        ctrl_goto_addr_rrrrrrr <= ctrl_goto_addr_rrrrrr;
        ctrl_goto_addr_rrrrrrrr <= ctrl_goto_addr_rrrrrrr;

        ctrl_next_addr_r(instruction_depth_c-1 downto 1) <= std_logic_vector(unsigned(instruction_addr_rr(instruction_depth_c-1 downto 1))+1);
        ctrl_next_addr_r(0) <= '0';
        ctrl_next_addr_rr <= ctrl_next_addr_r;
        ctrl_next_addr_rrr <= ctrl_next_addr_rr;
        ctrl_next_addr_rrrr <= ctrl_next_addr_rrr;
        ctrl_next_addr_rrrrr <= ctrl_next_addr_rrrr;
        if ctrl_ret_func='1' then
            ctrl_next_addr_rrrrrr <= (others=>'0');
        elsif ctrl_jump='1' then
            ctrl_next_addr_rrrrrr <= ctrl_goto_addr_rrrrrrrr(instruction_depth_c-1 downto 0);
        else
            ctrl_next_addr_rrrrrr <= ctrl_next_addr_rrrrr;
        end if;

        if ctrl_opcode_rrrrrrrr=ctrl_opcode_return_c and 
            got_control_rrrrrrrr='1' then
            ctrl_ready_r <= '1';
        else
            ctrl_ready_r <= '0';
        end if;
    end if;
end if;
end process;

-- 
-- Decode control instruction
---

process(ctrl_opcode_rrrrrrrr,got_control_rrrrrrrr,i_y_neg_in,i_y_zero_in)
begin
    if got_control_rrrrrrrr='1' then
        case ctrl_opcode_rrrrrrrr is
            when ctrl_opcode_return_c => 
                ctrl_jump <= '0'; 
                ctrl_ret_func <= '1';
            when ctrl_opcode_jump_lt_c => 
                ctrl_jump <= i_y_neg_in; 
                ctrl_ret_func <= '0';
            when ctrl_opcode_jump_le_c => 
                ctrl_jump <= (i_y_neg_in or i_y_zero_in); 
                ctrl_ret_func <= '0';
            when ctrl_opcode_jump_gt_c => 
                ctrl_jump <= (not i_y_neg_in) and (not i_y_zero_in); 
                ctrl_ret_func <= '0';
            when ctrl_opcode_jump_ge_c => 
                ctrl_jump <= (not i_y_neg_in); 
                ctrl_ret_func <= '0';
            when ctrl_opcode_jump_eq_c => 
                ctrl_jump <= i_y_zero_in; 
                ctrl_ret_func <= '0';
            when ctrl_opcode_jump_ne_c => 
                ctrl_jump <= not i_y_zero_in; 
                ctrl_ret_func <= '0';
            when ctrl_opcode_jump_c => 
                ctrl_jump <= '1'; 
                ctrl_ret_func <= '0';
            when others => 
                ctrl_jump <='0'; 
                ctrl_ret_func <= '0';
        end case;
    else
        ctrl_jump <= '0';
        ctrl_ret_func <= '0';
    end if;
end process;


process(clock_in,reset_in)
begin
if reset_in='0' then
    instruction_addr_r <= (others=>'0');
    instruction_addr_rr <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        instruction_addr_r <= rom_addr_rr;
        instruction_addr_rr <= instruction_addr_r;
    end if;
end if;
end process;

process(reset_in,clock_in)
begin
if reset_in='0' then
   instruction_pcore_enable_r <= (others=>'0');
   instruction_pcore_enable_rr <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
       instruction_pcore_enable_rr <= instruction_pcore_enable_r;
       if task_lockstep_r='0' then
          for I in 0 to pid_gen_max_c-1 loop
             if task_pcore_curr_r=to_unsigned(I,pcore_t'length) then
                instruction_pcore_enable_r(I) <= '1';
             else
                instruction_pcore_enable_r(I) <= '0';
             end if;
          end loop;
       else
          for I in 0 to pid_gen_max_c-1 loop
             if task_pcore_max_r >= to_unsigned(I,pcore_t'length) then
                instruction_pcore_enable_r(I) <= '1';
             else
                instruction_pcore_enable_r(I) <= '0';
             end if;
          end loop;
       end if;
    end if;
end if;

end process;

END behavior; 
