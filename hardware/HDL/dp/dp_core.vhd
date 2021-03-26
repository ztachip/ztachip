
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

-- This is the top module for DP (data-plane) processor.


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;

ENTITY dp_core IS
    port(
            SIGNAL clock_in                         : in STD_LOGIC;
            SIGNAL reset_in                         : in STD_LOGIC;
            SIGNAL mclock_in                        : in STD_LOGIC;
            SIGNAL mreset_in                        : in STD_LOGIC;
            
            -- Bus interface for configuration        

            SIGNAL bus_addr_in                      : IN register_addr_t;
            SIGNAL bus_write_in                     : IN STD_LOGIC;
            SIGNAL bus_read_in                      : IN STD_LOGIC;
            SIGNAL bus_writedata_in                 : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
            SIGNAL bus_readdata_out                 : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
            SIGNAL bus_waitrequest_out              : OUT STD_LOGIC;            

            -- Bus interface for read master 1

            SIGNAL readmaster1_addr_out             : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
            SIGNAL readmaster1_fork_out             : OUT dp_fork_t;
            SIGNAL readmaster1_addr_mode_out        : OUT STD_LOGIC;
            SIGNAL readmaster1_cs_out               : OUT STD_LOGIC;
            SIGNAL readmaster1_read_out             : OUT STD_LOGIC;
            SIGNAL readmaster1_read_vm_out          : OUT STD_LOGIC;
            SIGNAL readmaster1_read_data_flow_out   : OUT data_flow_t;
            SIGNAL readmaster1_read_stream_out      : OUT std_logic;
            SIGNAL readmaster1_read_stream_id_out   : OUT stream_id_t;
            SIGNAL readmaster1_read_vector_out      : OUT dp_vector_t;
            SIGNAL readmaster1_read_scatter_out     : OUT scatter_t;
            SIGNAL readmaster1_readdatavalid_in     : IN STD_LOGIC;
            SIGNAL readmaster1_readdatavalid_vm_in  : IN STD_LOGIC;
            SIGNAL readmaster1_readdata_in          : IN STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL readmaster1_wait_request_in      : IN STD_LOGIC;
            SIGNAL readmaster1_burstlen_out         : OUT burstlen_t;
            SIGNAL readmaster1_bus_id_out           : OUT dp_bus_id_t;
            SIGNAL readmaster1_data_type_out        : OUT dp_data_type_t;
            SIGNAL readmaster1_data_model_out       : OUT dp_data_model_t;

            -- Bus interface for write master 1

            SIGNAL writemaster1_addr_out            : OUT STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
            SIGNAL writemaster1_fork_out            : OUT dp_fork_t;
            SIGNAL writemaster1_addr_mode_out       : OUT STD_LOGIC;
            SIGNAL writemaster1_vm_out              : OUT STD_LOGIC;
            SIGNAL writemaster1_mcast_out           : OUT mcast_t;
            SIGNAL writemaster1_cs_out              : OUT STD_LOGIC;
            SIGNAL writemaster1_write_out           : OUT STD_LOGIC;
            SIGNAL writemaster1_write_data_flow_out : OUT data_flow_t;
            SIGNAL writemaster1_write_vector_out    : OUT dp_vector_t;
            SIGNAL writemaster1_write_stream_out    : OUT std_logic;
            SIGNAL writemaster1_write_stream_id_out : OUT stream_id_t; 
            SIGNAL writemaster1_write_scatter_out   : OUT scatter_t;
            SIGNAL writemaster1_writedata_out       : OUT STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL writemaster1_wait_request_in     : IN STD_LOGIC;
            SIGNAL writemaster1_burstlen_out        : OUT burstlen_t;
            SIGNAL writemaster1_bus_id_out          : OUT dp_bus_id_t;
            SIGNAL writemaster1_data_type_out       : OUT dp_data_type_t;
            SIGNAL writemaster1_data_model_out      : OUT dp_data_model_t;
            SIGNAL writemaster1_thread_out          : OUT dp_thread_t;
            SIGNAL writemaster1_counter_in          : IN dp_counters_t(1 DOWNTO 0);

            -- Bus interface for read master 2
            
            SIGNAL readmaster2_addr_out             : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
            SIGNAL readmaster2_fork_out             : OUT std_logic_vector(fork_sram_c-1 downto 0);
            SIGNAL readmaster2_cs_out               : OUT STD_LOGIC;
            SIGNAL readmaster2_read_out             : OUT STD_LOGIC;
            SIGNAL readmaster2_read_vm_out          : OUT STD_LOGIC;
            SIGNAL readmaster2_read_vector_out      : OUT dp_vector_t;
            SIGNAL readmaster2_read_scatter_out     : OUT scatter_t;
            SIGNAL readmaster2_readdatavalid_in     : IN STD_LOGIC;
            SIGNAL readmaster2_readdatavalid_vm_in  : IN STD_LOGIC;
            SIGNAL readmaster2_readdata_in          : IN STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL readmaster2_wait_request_in      : IN STD_LOGIC;
            SIGNAL readmaster2_burstlen_out         : OUT burstlen_t;
            SIGNAL readmaster2_bus_id_out           : OUT dp_bus_id_t;

            -- Bus interface for write master 2
            
            SIGNAL writemaster2_addr_out            : OUT STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
            SIGNAL writemaster2_fork_out            : OUT std_logic_vector(fork_sram_c-1 downto 0);
            SIGNAL writemaster2_cs_out              : OUT STD_LOGIC;
            SIGNAL writemaster2_write_out           : OUT STD_LOGIC;
            SIGNAL writemaster2_vm_out              : OUT STD_LOGIC;
            SIGNAL writemaster2_write_vector_out    : OUT dp_vector_t;
            SIGNAL writemaster2_write_scatter_out   : OUT scatter_t;
            SIGNAL writemaster2_writedata_out       : OUT STD_LOGIC_VECTOR(fork_sram_c*ddr_data_width_c-1 DOWNTO 0);
            SIGNAL writemaster2_wait_request_in     : IN STD_LOGIC;
            SIGNAL writemaster2_burstlen_out        : OUT burstlen_t;
            SIGNAL writemaster2_bus_id_out          : OUT dp_bus_id_t;
            SIGNAL writemaster2_thread_out          : OUT dp_thread_t;
            SIGNAL writemaster2_counter_in          : IN dp_counters_t(1 downto 0);

            -- Bus interface for read master 3
            
            SIGNAL readmaster3_addr_out             : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
            SIGNAL readmaster3_cs_out               : OUT STD_LOGIC;
            SIGNAL readmaster3_read_out             : OUT STD_LOGIC;
            SIGNAL readmaster3_read_vm_out          : OUT STD_LOGIC;
            SIGNAL readmaster3_read_vector_out      : OUT dp_vector_t;
            SIGNAL readmaster3_read_scatter_out     : OUT scatter_t;
            SIGNAL readmaster3_read_start_out       : OUT unsigned(ddr_vector_depth_c downto 0);
            SIGNAL readmaster3_read_end_out         : OUT vectors_t(fork_ddr_c-1 downto 0);
            SIGNAL readmaster3_readdatavalid_in     : IN STD_LOGIC;
            SIGNAL readmaster3_readdatavalid_vm_in  : IN STD_LOGIC;
            SIGNAL readmaster3_readdata_in          : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
            SIGNAL readmaster3_wait_request_in      : IN STD_LOGIC;
            SIGNAL readmaster3_burstlen_out         : OUT burstlen_t;
            SIGNAL readmaster3_bus_id_out           : OUT dp_bus_id_t;
            SIGNAL readmaster3_filler_data_out      : OUT STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

            -- Bus interface for write master 3
            
            SIGNAL writemaster3_addr_out            : OUT STD_LOGIC_VECTOR(dp_full_addr_width_c-1 downto 0);
            SIGNAL writemaster3_cs_out              : OUT STD_LOGIC;
            SIGNAL writemaster3_write_out           : OUT STD_LOGIC;
            SIGNAL writemaster3_vm_out              : OUT STD_LOGIC;
            SIGNAL writemaster3_write_vector_out    : OUT dp_vector_t;
            SIGNAL writemaster3_write_scatter_out   : OUT scatter_t;
            SIGNAL writemaster3_write_end_out       : OUT vectors_t(fork_ddr_c-1 downto 0);
            SIGNAL writemaster3_writedata_out       : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
            SIGNAL writemaster3_wait_request_in     : IN STD_LOGIC;
            SIGNAL writemaster3_burstlen_out        : OUT burstlen_t;
            SIGNAL writemaster3_burstlen2_out       : OUT burstlen2_t;
            SIGNAL writemaster3_burstlen3_out       : OUT burstlen_t;
            SIGNAL writemaster3_bus_id_out          : OUT dp_bus_id_t;
            SIGNAL writemaster3_thread_out          : OUT dp_thread_t;
            SIGNAL writemaster3_counter_in          : IN dp_counter_t;
            SIGNAL writemaster3_filler_data_out     : OUT STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);


            -- Task control
            
            SIGNAL task_start_addr_out              : OUT instruction_addr_t;
            SIGNAL task_out                         : OUT STD_LOGIC;
            SIGNAL task_vm_out                      : OUT STD_LOGIC;
            SIGNAL task_pcore_out                   : OUT pcore_t;
            SIGNAL task_lockstep_out                : OUT STD_LOGIC;
            SIGNAL task_tid_mask_out                : OUT tid_mask_t;
            SIGNAL task_iregister_auto_out          : OUT iregister_auto_t;
            SIGNAL task_data_model_out              : OUT dp_data_model_t;
 
            SIGNAL task_busy_in                     : IN STD_LOGIC_VECTOR(1 downto 0);
            SIGNAL task_ready_in                    : IN STD_LOGIC;
            SIGNAL task_busy_out                    : OUT STD_LOGIC_VECTOR(1 downto 0);

            -- BAR info
            SIGNAL bar_in                           : IN dp_addrs_t(dp_bus_id_max_c-1 downto 0);

            -- Indication
            SIGNAL indication_avail_out             : OUT STD_LOGIC
    );
END dp_core;


ARCHITECTURE dp_core_behaviour of dp_core is
SIGNAL task_busy:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL task_ready:STD_LOGIC;
SIGNAL task:STD_LOGIC;
SIGNAL task_pending:STD_LOGIC;
SIGNAL task_pcore:pcore_t;
SIGNAL task_lockstep:STD_LOGIC;
SIGNAL task_tid_mask:tid_mask_t;
SIGNAL task_iregister_auto:iregister_auto_t;
SIGNAL task_data_model:dp_data_model_t;
SIGNAL task_start_addr: instruction_addr_t;
SIGNAL task_vm:STD_LOGIC;
SIGNAL task_pcore_r:pcore_t;
SIGNAL task_lockstep_r:STD_LOGIC;
SIGNAL task_tid_mask_r:tid_mask_t;
SIGNAL task_iregister_auto_r:iregister_auto_t;
SIGNAL task_data_model_r:dp_data_model_t;
SIGNAL task_start_addr_r: instruction_addr_t;
SIGNAL task_r: STD_LOGIC;
SIGNAL task_rr: STD_LOGIC;
SIGNAL task_rrr: STD_LOGIC;
SIGNAL task_rrrr: STD_LOGIC;
SIGNAL task_rrrrr: STD_LOGIC;
SIGNAL task_rrrrrr: STD_LOGIC;
SIGNAL task_rrrrrrr: STD_LOGIC;
SIGNAL task_rrrrrrrr: STD_LOGIC;
SIGNAL task_vm_r: STD_LOGIC;
SIGNAL task_vm_rr: STD_LOGIC;
SIGNAL task_vm_rrr: STD_LOGIC;
SIGNAL task_vm_rrrr: STD_LOGIC;
SIGNAL task_vm_rrrrr: STD_LOGIC;
SIGNAL task_vm_rrrrrr: STD_LOGIC;
SIGNAL task_vm_rrrrrrr: STD_LOGIC;
SIGNAL task_vm_rrrrrrrr: STD_LOGIC;
SIGNAL task_busy_r:STD_LOGIC;
SIGNAL task_1_busy_r:STD_LOGIC;
SIGNAL task_0_busy_r:STD_LOGIC;
BEGIN

task_out <= task_r;
task_start_addr_out <= task_start_addr_r;
task_pcore_out <= task_pcore_r;
task_lockstep_out <= task_lockstep_r;
task_tid_mask_out <= task_tid_mask_r;
task_iregister_auto_out <= task_iregister_auto_r;
task_data_model_out <= task_data_model_r;
task_vm_out <= task_vm_r;
task_busy_out <= task_busy;

dp0_i: dp
    generic map(
        DP_THREAD_ID=>0,
        DP_READMASTER1_BURST_MODE=>'0',
        DP_WRITEMASTER1_BURST_MODE=>'0',
        DP_READMASTER2_BURST_MODE=>'0',
        DP_WRITEMASTER2_BURST_MODE=>'0',
        DP_READMASTER3_BURST_MODE=>'1',
        DP_WRITEMASTER3_BURST_MODE=>'1'
    )
    port map(
        clock_in=>clock_in,
        mclock_in=>mclock_in,
        reset_in=>reset_in,        
        mreset_in=>mreset_in,   
		        
        -- Configuration bus
        
        bus_addr_in=>bus_addr_in,
        bus_write_in=>bus_write_in,
        bus_read_in=>bus_read_in,
        bus_writedata_in=>bus_writedata_in,
        bus_readdata_out=>bus_readdata_out,
        bus_waitrequest_out=>bus_waitrequest_out,

        -- Bus interface for read master to PCORE
        
        readmaster1_addr_out=>readmaster1_addr_out,
        readmaster1_fork_out=>readmaster1_fork_out,
        readmaster1_addr_mode_out=>readmaster1_addr_mode_out,
        readmaster1_cs_out=>readmaster1_cs_out,
        readmaster1_read_out=>readmaster1_read_out,
        readmaster1_read_vm_out=>readmaster1_read_vm_out,
        readmaster1_read_data_flow_out=>readmaster1_read_data_flow_out,
        readmaster1_read_stream_out=>readmaster1_read_stream_out,
        readmaster1_read_stream_id_out=>readmaster1_read_stream_id_out,
        readmaster1_read_vector_out=>readmaster1_read_vector_out,
        readmaster1_read_scatter_out=>readmaster1_read_scatter_out,
        readmaster1_readdatavalid_in=>readmaster1_readdatavalid_in,
        readmaster1_readdatavalid_vm_in=>readmaster1_readdatavalid_vm_in,
        readmaster1_readdata_in=>readmaster1_readdata_in,
        readmaster1_wait_request_in=>readmaster1_wait_request_in,
        readmaster1_burstlen_out=>readmaster1_burstlen_out,
        readmaster1_bus_id_out=>readmaster1_bus_id_out,
        readmaster1_data_type_out=>readmaster1_data_type_out,
        readmaster1_data_model_out=>readmaster1_data_model_out,
        
        -- Bus interface for write master to PCORE
        
        writemaster1_addr_out=>writemaster1_addr_out,
        writemaster1_fork_out=>writemaster1_fork_out,
        writemaster1_addr_mode_out=>writemaster1_addr_mode_out,
        writemaster1_vm_out=>writemaster1_vm_out,
        writemaster1_mcast_out=>writemaster1_mcast_out,
        writemaster1_cs_out=>writemaster1_cs_out,
        writemaster1_write_out=>writemaster1_write_out,
        writemaster1_write_data_flow_out=>writemaster1_write_data_flow_out,
        writemaster1_write_vector_out=>writemaster1_write_vector_out,
        writemaster1_write_stream_out=>writemaster1_write_stream_out,
        writemaster1_write_stream_id_out=>writemaster1_write_stream_id_out,
        writemaster1_write_scatter_out=>writemaster1_write_scatter_out,
        writemaster1_writedata_out=>writemaster1_writedata_out,
        writemaster1_wait_request_in=>writemaster1_wait_request_in,
        writemaster1_burstlen_out=>writemaster1_burstlen_out,
        writemaster1_bus_id_out=>writemaster1_bus_id_out,
        writemaster1_data_type_out=>writemaster1_data_type_out,
        writemaster1_data_model_out=>writemaster1_data_model_out,
        writemaster1_thread_out=>writemaster1_thread_out,
        writemaster1_counter_in=>writemaster1_counter_in,
        
        -- Bus interface for read master to SRAM
        
        readmaster2_addr_out=>readmaster2_addr_out,
        readmaster2_fork_out=>readmaster2_fork_out,
        readmaster2_cs_out=>readmaster2_cs_out,
        readmaster2_read_out=>readmaster2_read_out,
        readmaster2_read_vm_out=>readmaster2_read_vm_out,
        readmaster2_read_vector_out=>readmaster2_read_vector_out,
        readmaster2_read_scatter_out=>readmaster2_read_scatter_out,
        readmaster2_readdatavalid_in=>readmaster2_readdatavalid_in,
        readmaster2_readdatavalid_vm_in=>readmaster2_readdatavalid_vm_in,
        readmaster2_readdata_in=>readmaster2_readdata_in,
        readmaster2_wait_request_in=>readmaster2_wait_request_in,
        readmaster2_burstlen_out=>readmaster2_burstlen_out,
        readmaster2_bus_id_out=>readmaster2_bus_id_out,
        
        -- Bus interface for write master to SRAM
        
        writemaster2_addr_out=>writemaster2_addr_out,
        writemaster2_fork_out=>writemaster2_fork_out,
        writemaster2_cs_out=>writemaster2_cs_out,
        writemaster2_write_out=>writemaster2_write_out,
        writemaster2_vm_out=>writemaster2_vm_out,
        writemaster2_write_vector_out=>writemaster2_write_vector_out,
        writemaster2_write_scatter_out=>writemaster2_write_scatter_out,
        writemaster2_writedata_out=>writemaster2_writedata_out,
        writemaster2_wait_request_in=>writemaster2_wait_request_in,
        writemaster2_burstlen_out=>writemaster2_burstlen_out,
        writemaster2_bus_id_out=>writemaster2_bus_id_out,
        writemaster2_thread_out=>writemaster2_thread_out,
        writemaster2_counter_in=>writemaster2_counter_in,
        
        -- Bus interface for read master to DDR
        
        readmaster3_addr_out=>readmaster3_addr_out,
        readmaster3_cs_out=>readmaster3_cs_out,
        readmaster3_read_out=>readmaster3_read_out,
        readmaster3_read_vm_out=>readmaster3_read_vm_out,
        readmaster3_read_vector_out=>readmaster3_read_vector_out,
        readmaster3_read_scatter_out=>readmaster3_read_scatter_out,
        readmaster3_read_start_out=>readmaster3_read_start_out,
        readmaster3_read_end_out=>readmaster3_read_end_out,
        readmaster3_readdatavalid_in=>readmaster3_readdatavalid_in,
        readmaster3_readdatavalid_vm_in=>readmaster3_readdatavalid_vm_in,
        readmaster3_readdata_in=>readmaster3_readdata_in,
        readmaster3_wait_request_in=>readmaster3_wait_request_in,
        readmaster3_burstlen_out=>readmaster3_burstlen_out,
        readmaster3_bus_id_out=>readmaster3_bus_id_out,
        readmaster3_filler_data_out=>readmaster3_filler_data_out,
        
        -- Bus interface for write master to DDR
        
        writemaster3_addr_out=>writemaster3_addr_out,
        writemaster3_cs_out=>writemaster3_cs_out,
        writemaster3_write_out=>writemaster3_write_out,
        writemaster3_vm_out=>writemaster3_vm_out,
        writemaster3_write_vector_out=>writemaster3_write_vector_out,
        writemaster3_write_scatter_out=>writemaster3_write_scatter_out,
        writemaster3_write_end_out=>writemaster3_write_end_out,
        writemaster3_writedata_out=>writemaster3_writedata_out,
        writemaster3_wait_request_in=>writemaster3_wait_request_in,
        writemaster3_burstlen_out=>writemaster3_burstlen_out,
        writemaster3_burstlen2_out=>writemaster3_burstlen2_out,
        writemaster3_burstlen3_out=>writemaster3_burstlen3_out,
        writemaster3_bus_id_out=>writemaster3_bus_id_out,
        writemaster3_thread_out=>writemaster3_thread_out,
        writemaster3_counter_in=>writemaster3_counter_in,

        -- Task control
        
        task_start_addr_out=>task_start_addr,
        task_out=>task,
        task_pending_out=>task_pending,
        task_vm_out=>task_vm,
        task_pcore_out=>task_pcore,
        task_lockstep_out=>task_lockstep,
        task_tid_mask_out=>task_tid_mask,
        task_iregister_auto_out=>task_iregister_auto,
        task_data_model_out=>task_data_model,
        task_busy_in=>task_busy,
        task_ready_in=>task_ready,

        -- BAR

        bar_in=>bar_in,

        indication_avail_out => indication_avail_out
    );


--------
-- Generate process is busy. Since there is a delay between when process is launched and when it is actually
-- is running, we would like to assert task to be busy as soon as task is launched from DP.
---------

-- Generate task busy for process0
task_busy(0) <= '1' when ((task_busy_in(0)='1') or (task_0_busy_r='1'))
                    else
                    '0';

task_busy(1) <= '1' when ((task_busy_in(1)='1') or (task_1_busy_r='1'))
                    else
                    '0';

task_ready   <= '0' when ((task_ready_in='0') or (task_busy_r='1'))
                    else
                    '1';

------------
-- Latch the task launch events in a fifo.
-- This is required to generate task busy signal since it is taking upto
-- 6 clocks until pcore is responding to a task launch request. Meanwhile we
-- need to assert task busy right the way...
-------------

process(clock_in,reset_in)
begin
if reset_in = '0' then
    task_start_addr_r <= (others=>'0');
    task_pcore_r <= (others=>'1');
    task_lockstep_r <= '0';
    task_tid_mask_r <= (others=>'0');
    task_r <= '0';
    task_rr <= '0';
    task_rrr <= '0';
    task_rrrr <= '0';
    task_rrrrr <= '0';
    task_rrrrrr <= '0';
    task_rrrrrrr <= '0';
    task_rrrrrrrr <= '0';
    task_vm_r <= '0';
    task_vm_rr <= '0';
    task_vm_rrr <= '0';
    task_vm_rrrr <= '0';
    task_vm_rrrrr <= '0';
    task_vm_rrrrrr <= '0';
    task_vm_rrrrrrr <= '0';
    task_vm_rrrrrrrr <= '0';
    task_busy_r <= '0';
    task_0_busy_r <= '0';
    task_1_busy_r <= '0';
    task_iregister_auto_r <= (others=>'0');
	task_data_model_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        task_tid_mask_r <= task_tid_mask;
        task_iregister_auto_r <= task_iregister_auto;
		task_data_model_r <= task_data_model;
        task_pcore_r <= task_pcore;
        task_lockstep_r <= task_lockstep;
        task_start_addr_r <= task_start_addr;
        task_r <= task;
        task_rr <= task_r;
        task_rrr <= task_rr;
        task_rrrr <= task_rrr;
        task_rrrrr <= task_rrrr;
        task_rrrrrr <=  task_rrrrr;
        task_rrrrrrr <= task_rrrrrr;
        task_rrrrrrrr <= task_rrrrrrr;

        task_busy_r <= task_rrrrrrrr or 
                       task_rrrrrrr or 
                       task_rrrrrr or
                       task_rrrrr or
                       task_rrrr or
                       task_rrr or
                       task_rr or
                       task_r or
                       task;

        task_0_busy_r <= (task_rrrrrrrr and (not task_vm_rrrrrrrr)) or
	         (task_rrrrrrr and (not task_vm_rrrrrrr)) or
	         (task_rrrrrr and (not task_vm_rrrrrr)) or 
	         (task_rrrrr and (not task_vm_rrrrr)) or
                         (task_rrrr and (not task_vm_rrrr)) or
	         (task_rrr and (not task_vm_rrr)) or
                         (task_rr and (not task_vm_rr)) or
                         (task_r and (not task_vm_r)) or
                         (task and (not task_vm));
						  

        task_1_busy_r <= (task_rrrrrrrr and (task_vm_rrrrrrrr)) or
	         (task_rrrrrrr and (task_vm_rrrrrrr)) or
	         (task_rrrrrr and (task_vm_rrrrrr)) or 
	         (task_rrrrr and (task_vm_rrrrr)) or
                         (task_rrrr and (task_vm_rrrr)) or
                         (task_rrr and (task_vm_rrr)) or
                         (task_rr and (task_vm_rr)) or
                         (task_r and (task_vm_r)) or
                         (task and (task_vm));

        task_vm_r <= task_vm;
        task_vm_rr <= task_vm_r;
        task_vm_rrr <= task_vm_rr;
        task_vm_rrrr <= task_vm_rrr;
        task_vm_rrrrr <= task_vm_rrrr;
        task_vm_rrrrrr <= task_vm_rrrrr;
        task_vm_rrrrrrr <= task_vm_rrrrrr;
        task_vm_rrrrrrrr <= task_vm_rrrrrrr;
    end if;
end if;
end process;

end dp_core_behaviour;