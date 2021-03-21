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

--------
-- This is the top component for ztachip
--------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY ztachip IS
    port(   
	        hclock_in                   : IN STD_LOGIC;
			hreset_in					: IN STD_LOGIC;
            pclock_in                   : IN STD_LOGIC;
			preset_in					: IN STD_LOGIC;
            mclock_in                   : IN STD_LOGIC;
            mreset_in                   : IN STD_LOGIC;                        
            dclock_in                   : IN STD_LOGIC;
            dreset_in                   : IN STD_LOGIC;                        
            
			avalon_bus_addr_in          : IN std_logic_vector(avalon_bus_width_c-1 downto 0);
            avalon_bus_write_in         : IN std_logic;
            avalon_bus_writedata_in     : IN std_logic_vector(host_width_c-1 downto 0);
            avalon_bus_readdata_out     : OUT std_logic_vector(host_width_c-1 downto 0);
            avalon_bus_wait_request_out : OUT std_logic;
            avalon_bus_read_in          : IN std_logic;

            cell_ddr_0_addr_out           : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            cell_ddr_0_burstlen_out       : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
            cell_ddr_0_burstbegin_out     : OUT std_logic;
            cell_ddr_0_readdatavalid_in   : IN std_logic;
            cell_ddr_0_write_out          : OUT std_logic;
            cell_ddr_0_read_out           : OUT std_logic;
            cell_ddr_0_writedata_out      : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
            cell_ddr_0_byteenable_out     : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0);
            cell_ddr_0_readdata_in        : IN std_logic_vector(ddr_data_width_c-1 downto 0);
            cell_ddr_0_wait_request_in    : IN std_logic;            

            cell_ddr_1_addr_out           : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            cell_ddr_1_burstlen_out       : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
            cell_ddr_1_burstbegin_out     : OUT std_logic;
            cell_ddr_1_readdatavalid_in   : IN std_logic;
            cell_ddr_1_write_out          : OUT std_logic;
            cell_ddr_1_read_out           : OUT std_logic;
            cell_ddr_1_writedata_out      : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
            cell_ddr_1_byteenable_out     : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0);
            cell_ddr_1_readdata_in        : IN std_logic_vector(ddr_data_width_c-1 downto 0);
            cell_ddr_1_wait_request_in    : IN std_logic;  

            -- Indication
            SIGNAL indication_avail_out : OUT STD_LOGIC
            
            );
END ztachip;

ARCHITECTURE ztachip_behavior of ztachip IS 

COMPONENT dcfifo
	GENERIC (
		intended_device_family  : STRING;
		lpm_numwords            : NATURAL;
		lpm_showahead           : STRING;
		lpm_type                : STRING;
		lpm_width               : NATURAL;
		lpm_widthu              : NATURAL;
		overflow_checking       : STRING;
		rdsync_delaypipe        : NATURAL;
		underflow_checking      : STRING;
		use_eab                 : STRING;
		wrsync_delaypipe        : NATURAL
	);
	PORT (
			data	: IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
			rdclk	: IN STD_LOGIC;
			rdreq	: IN STD_LOGIC;
			wrclk	: IN STD_LOGIC;
			wrreq	: IN STD_LOGIC;
            wrusedw : OUT STD_LOGIC_VECTOR(lpm_widthu-1 downto 0);
			q	    : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
			rdempty	: OUT STD_LOGIC;
			wrfull	: OUT STD_LOGIC 
	);
END COMPONENT;

-- Bus signals for MCLOCK domain
SIGNAL m_config_wren: STD_LOGIC;
SIGNAL m_config_rden: STD_LOGIC;
-- Avalon bus signal cloked for MCLOCK domain
SIGNAL m_avalon_bus_address:std_logic_vector(avalon_bus_width_c-1 downto 0);
SIGNAL m_avalon_bus_write:std_logic;
SIGNAL m_avalon_bus_writedata:std_logic_vector(host_width_c-1 downto 0);
SIGNAL m_avalon_bus_readdata:std_logic_vector(host_width_c-1 downto 0);
SIGNAL m_avalon_bus_readdatavalid:std_logic;
SIGNAL m_avalon_bus_read:std_logic;
-- Program instruction space
SIGNAL m_mcode_write:STD_LOGIC;
SIGNAL m_mdata_write:STD_LOGIC;
SIGNAL m_avalon_bus_page:avalon_bus_page_t;
SIGNAL m_avalon_bus_addr:STD_LOGIC_VECTOR(avalon_page_width_c-1 downto 0);
SIGNAL m_page_is_mcode : STD_LOGIC;
SIGNAL m_page_is_mdata : STD_LOGIC;
SIGNAL m_page_is_config: STD_LOGIC;

--- Bus signals for PCLOCK domain
-- Bus signals for bus access
SIGNAL p_config_wren: STD_LOGIC;
SIGNAL p_config_rden: STD_LOGIC;
-- Avalon bus signal cloked for MCLOCK domain
SIGNAL p_avalon_bus_address:std_logic_vector(avalon_bus_width_c-1 downto 0);
SIGNAL p_avalon_bus_write:std_logic;
SIGNAL p_avalon_bus_writedata:std_logic_vector(host_width_c-1 downto 0);
SIGNAL p_avalon_bus_readdata:std_logic_vector(host_width_c-1 downto 0);
SIGNAL p_avalon_bus_readdatavalid:std_logic;
SIGNAL p_avalon_bus_read:std_logic;
-- Program instruction space
SIGNAL p_mcode_write:STD_LOGIC;
SIGNAL p_mdata_write:STD_LOGIC;
SIGNAL p_avalon_bus_page:avalon_bus_page_t;
SIGNAL p_avalon_bus_addr:STD_LOGIC_VECTOR(avalon_page_width_c-1 downto 0);
SIGNAL p_page_is_mcode : STD_LOGIC;
SIGNAL p_page_is_mdata : STD_LOGIC;
SIGNAL p_page_is_config: STD_LOGIC;


SIGNAL avalon_bus_wait_request:std_logic;

SIGNAL msgq_readdatavalid:std_logic;
SIGNAL sys_config_readdatavalid:std_logic;

-- Task completion signals
SIGNAL pcore_busy:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL busy:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL pcore_read_busy:STD_LOGIC;
SIGNAL pcore_write_busy:STD_LOGIC;
SIGNAL ready:STD_LOGIC;

-- Interface to DP1 read port 1
SIGNAL pcore_read_addr: STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL pcore_read_fork: dp_fork_t;
SIGNAL pcore_read_addr_mode: STD_LOGIC;
SIGNAL pcore_read_enable: STD_LOGIC;
SIGNAL pcore_read_gen_valid:STD_LOGIC;
SIGNAL pcore_read_data: STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
SIGNAL pcore_readdata_vm:STD_LOGIC;
SIGNAL pcore_read_data_valid: STD_LOGIC;
SIGNAL pcore_read_data_valid2: STD_LOGIC;
SIGNAL pcore_read_gen_valid2:STD_LOGIC;

-- Interface to DP1 write port 1
SIGNAL pcore_write_addr: STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL pcore_write_fork: dp_fork_t;
SIGNAL pcore_write_addr_mode: STD_LOGIC;
SIGNAL pcore_mcast:mcast_t;
SIGNAL pcore_write_enable: STD_LOGIC;
SIGNAL pcore_write_gen_valid:STD_LOGIC;
SIGNAL pcore_write_data: STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);

-- Interface to DP1 read port 2
SIGNAL sram_read_addr: STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
SIGNAL sram_read_fork: dp_fork_t;
SIGNAL sram_read_enable: STD_LOGIC;
SIGNAL sram_read_vector: dp_vector_t;
SIGNAL sram_read_gen_valid: STD_LOGIC;
SIGNAL sram_read_data: STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
SIGNAL sram_read_data_valid: STD_LOGIC;
SIGNAL sram_readdata_vm:STD_LOGIC;
SIGNAL sram_read_vm:STD_LOGIC;

-- Interface to DP1 write port 2
SIGNAL sram_write_addr: STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
SIGNAL sram_write_fork: dp_fork_t;
SIGNAL sram_write_enable: STD_LOGIC;
SIGNAL sram_write_vector: dp_vector_t;
SIGNAL sram_write_data: STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);

-- Interface to DP1 read port 3
SIGNAL ddr_read_addr: std_logic_vector(dp_addr_width_c-1 downto 0);
SIGNAL ddr_read_enable: STD_LOGIC;
SIGNAL ddr_read_enable_2:STD_LOGIC;
SIGNAL ddr_read_wait: STD_LOGIC;
SIGNAL ddr_read_wait_2:STD_LOGIC;
SIGNAL ddr_read_data: STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL ddr_read_data_valid: STD_LOGIC;
SIGNAL ddr_read_burstlen: burstlen_t;
SIGNAL ddr_read_filler_data: STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

-- Interface to DP1 write port 3
SIGNAL ddr_write_addr: std_logic_vector(dp_addr_width_c-1 downto 0);
SIGNAL ddr_write_enable: STD_LOGIC;
SIGNAL ddr_write_enable_2:STD_LOGIC;
SIGNAL ddr_write_wait: STD_LOGIC;
SIGNAL ddr_write_wait_2:STD_LOGIC;
SIGNAL ddr_write_data: STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL ddr_write_burstlen: burstlen_t;
SIGNAL ddr_write_burstlen2: burstlen2_t;
SIGNAL ddr_write_burstlen3: burstlen_t;

SIGNAL ddr_data_ready:STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
SIGNAL ddr_data_wait:STD_LOGIC_VECTOR(fork_max_c-1 downto 0);

SIGNAL ddr_write_end:vectors_t(fork_ddr_c-1 downto 0);

SIGNAL ddr_read_vm:STD_LOGIC;
SIGNAL ddr_readdata_vm:STD_LOGIC;

-- Task control
SIGNAL task_start_addr:instruction_addr_t;
SIGNAL task:STD_LOGIC;
SIGNAL task_vm:STD_LOGIC;
SIGNAL task_pcore:pcore_t;

SIGNAL bar:dp_addrs_t(dp_bus_id_max_c-1 downto 0);

-- Write counter
SIGNAL pcore_write_counter_r:dp_counters_t(1 DOWNTO 0);
SIGNAL sram_write_counter_r:dp_counters_t(1 DOWNTO 0);
SIGNAL ddr_write_counter_r:dp_counter_t;

SIGNAL register_rden:STD_LOGIC;
SIGNAL mcore_wren:STD_LOGIC;
SIGNAL mcore_rden:STD_LOGIC;
SIGNAL mcore_register_wren:STD_LOGIC;
SIGNAL mcore_register_rden:STD_LOGIC;
SIGNAL mcore_register_rden_r:STD_LOGIC;
SIGNAL mcore_addr:STD_LOGIC_VECTOR(io_depth_c-1 downto 0);
SIGNAL mcore_readdata_r:STD_LOGIC_VECTOR(host_width_c-1 downto 0);
SIGNAL mcore_writedata:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL mcore_io_bank:mcore_io_bank_t;

SIGNAL register_readdata:STD_LOGIC_VECTOR(host_width_c-1 downto 0);

SIGNAL sreset:STD_LOGIC;

SIGNAL mcore_waitrequest:STD_LOGIC;
SIGNAL mcore_register_waitrequest:STD_LOGIC;
SIGNAL mcore_register_waitrequest_r:STD_LOGIC;
SIGNAL mcore_register_waitrequest_rr:STD_LOGIC;

SIGNAL dp_sram_read_fork:dp_fork_t;
SIGNAL dp_sram_read_wait:STD_LOGIC;
SIGNAL dp_sram_write_fork:dp_fork_t;
SIGNAL dp_sram_write_wait:STD_LOGIC;
SIGNAL dp_sram_write_enable:STD_LOGIC;
SIGNAL dp_sram_write_vector:dp_vector_t;
SIGNAL dp_sram_write_addr:STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
SIGNAL dp_sram_write_data:STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 downto 0);
SIGNAL dp_sram_write_page:dp_bus2_page_t;
SIGNAL dp_sram_write_vm:STD_LOGIC;

SIGNAL dp_pcore_read_wait:STD_LOGIC;
SIGNAL dp_pcore_write_wait:STD_LOGIC;
SIGNAL dp_pcore_write_addr: STD_LOGIC_VECTOR(local_bus_width_c-1 downto 0);
SIGNAL dp_pcore_write_fork:dp_fork_t;
SIGNAL dp_pcore_write_data: STD_LOGIC_VECTOR(fork_max_c*ddr_data_width_c-1 DOWNTO 0);
SIGNAL dp_pcore_write_enable:STD_LOGIC;
SIGNAL dp_pcore_write_vm:STD_LOGIC;
SIGNAL dp_pcore_read_vm:STD_LOGIC;

SIGNAL dp_pcore_read_addr:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_pcore_read_fork:dp_fork_t;
SIGNAL dp_pcore_read_addr_mode: STD_LOGIC;
SIGNAL dp_sram_read_addr: STD_LOGIC_VECTOR(dp_bus2_addr_width_c-1 DOWNTO 0);
SIGNAL dp_pcore_read_enable:STD_LOGIC;
SIGNAL dp_sram_read_enable:STD_LOGIC;
SIGNAL dp_sram_read_vector:dp_vector_t;

SIGNAL pcore_read_wait:STD_LOGIC;
SIGNAL pcore_write_wait:STD_LOGIC;

SIGNAL pcore_read_vector:dp_vector_t;
SIGNAL pcore_write_vector:dp_vector_t;
SIGNAL pcore_write_stream:std_logic;
SIGNAL pcore_write_stream_id:stream_id_t;
SIGNAL pcore_read_data_flow:data_flow_t;
SIGNAL pcore_read_stream:std_logic;
SIGNAL pcore_read_stream_id:stream_id_t;
SIGNAL pcore_write_data_flow:data_flow_t;
SIGNAL pcore_read_data_type:dp_data_type_t;
SIGNAL pcore_read_data_model:dp_data_model_t;
SIGNAL pcore_write_data_type:dp_data_type_t;
SIGNAL pcore_write_data_model:dp_data_model_t;
SIGNAL dp_pcore_read_vector:dp_vector_t;
SIGNAL dp_pcore_write_vector:dp_vector_t;
SIGNAL dp_pcore_write_stream:std_logic;
SIGNAL dp_pcore_write_stream_id:stream_id_t;
SIGNAL ddr_read_vector:dp_vector_t;
SIGNAL ddr_write_vector:dp_vector_t;
SIGNAL dp_pcore_read_data_flow:data_flow_t;
SIGNAL dp_pcore_read_stream:std_logic;
SIGNAL dp_pcore_write_data_flow:data_flow_t;
SIGNAL dp_pcore_read_data_type:dp_data_type_t;
SIGNAL dp_pcore_read_data_model:dp_data_model_t;
SIGNAL dp_pcore_write_data_type:dp_data_type_t;
SIGNAL dp_pcore_write_data_model:dp_data_model_t;

SIGNAL pcore_read_scatter:scatter_t;
SIGNAL pcore_write_scatter:scatter_t;

SIGNAL pcore_read_scatter2:scatter_t;
SIGNAL pcore_write_scatter2:scatter_t;

SIGNAL task_lockstep:STD_LOGIC;
SIGNAL task_tid_mask:tid_mask_t;
SIGNAL task_iregister_auto:iregister_auto_t;
SIGNAL task_data_model:dp_data_model_t;

SIGNAL ddr_read_start:unsigned(ddr_vector_depth_c downto 0);
SIGNAL ddr_read_end:vectors_t(fork_ddr_c-1 downto 0);

SIGNAL cell_ddr_0_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL cell_ddr_0_burstlen:unsigned(ddr_burstlen_width_c-1 downto 0);
SIGNAL cell_ddr_0_burstbegin:std_logic;
SIGNAL cell_ddr_0_readdatavalid:std_logic;
SIGNAL cell_ddr_0_write:std_logic;
SIGNAL cell_ddr_0_read:std_logic;
SIGNAL cell_ddr_0_writedata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_0_byteenable:std_logic_vector(ddr_data_byte_width_c-1 downto 0);
SIGNAL cell_ddr_0_readdata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_0_wait_request:std_logic;  

SIGNAL cell_ddr_1_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL cell_ddr_1_burstlen:unsigned(ddr_burstlen_width_c-1 downto 0);
SIGNAL cell_ddr_1_burstbegin:std_logic;
SIGNAL cell_ddr_1_readdatavalid:std_logic;
SIGNAL cell_ddr_1_write:std_logic;
SIGNAL cell_ddr_1_read:std_logic;
SIGNAL cell_ddr_1_writedata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_1_byteenable:std_logic_vector(ddr_data_byte_width_c-1 downto 0);
SIGNAL cell_ddr_1_readdata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_1_wait_request:std_logic;  

SIGNAL avalon_bus_readdata_r:std_logic_vector(host_width_c-1 downto 0);
SIGNAL avalon_bus_readdata:std_logic_vector(host_width_c-1 downto 0);

SIGNAL dp_waitrequest:STD_LOGIC;

SIGNAL prog_text_ena:std_logic;
SIGNAL prog_text_data:std_logic_vector(mcore_instruction_width_c-1 downto 0);
SIGNAL prog_text_addr:std_logic_vector(mcore_instruction_depth_c-1 downto 0);
SIGNAL swdl_wait:std_logic;
SIGNAL swdl_write_enable:std_logic;
BEGIN



-- Bus signals for MCLOCK domain

m_avalon_bus_page <= unsigned(m_avalon_bus_address(avalon_bus_width_c-1 downto avalon_bus_width_c-avalon_bus_page_t'length));
m_avalon_bus_addr <= m_avalon_bus_address(avalon_page_width_c-1 downto 0);
m_page_is_mcode <= '1' when (m_avalon_bus_page=avalon_bus_page_mcode_c) else '0';
m_page_is_mdata <= '1' when (m_avalon_bus_page=avalon_bus_page_mdata_c) else '0';
m_page_is_config <= '1' when (m_avalon_bus_page=avalon_bus_page_config_c) else '0';

m_mcode_write <= m_avalon_bus_write and m_page_is_mcode;
m_mdata_write <= m_avalon_bus_write and m_page_is_mdata;

m_config_wren <= m_avalon_bus_write and m_page_is_config;
m_config_rden <= m_avalon_bus_read and m_page_is_config;


-- Bus signals for PCLOCK domain

p_avalon_bus_page <= unsigned(p_avalon_bus_address(avalon_bus_width_c-1 downto avalon_bus_width_c-avalon_bus_page_t'length));
p_avalon_bus_addr <= p_avalon_bus_address(avalon_page_width_c-1 downto 0);
p_page_is_mcode <= '1' when (p_avalon_bus_page=avalon_bus_page_mcode_c) else '0';
p_page_is_mdata <= '1' when (p_avalon_bus_page=avalon_bus_page_mdata_c) else '0';
p_page_is_config <= '1' when (p_avalon_bus_page=avalon_bus_page_config_c) else '0';

p_mcode_write <= p_avalon_bus_write and p_page_is_mcode;
p_mdata_write <= p_avalon_bus_write and p_page_is_mdata;

p_config_wren <= p_avalon_bus_write and p_page_is_config;
p_config_rden <= p_avalon_bus_read and p_page_is_config;


bar(dp_bus_id_register_c) <= (others=>'0');
bar(dp_bus_id_sram_c) <= (others=>'0');
bar(dp_bus_id_ddr_c)(dp_addr_width_c-1) <= '0';
bar(dp_bus_id_ddr_c)(dp_addr_width_c-2 downto 0) <= (others=>'0');

-- MCORE read/write enable signal
mcore_io_bank <= mcore_addr(io_depth_c-1 downto io_depth_c-mcore_io_bank_t'length);
mcore_register_rden <= '1' when (mcore_rden='1' and mcore_io_bank=mcore_io_bank_register_c) else '0';
mcore_register_wren <= '1' when (mcore_wren='1' and mcore_io_bank=mcore_io_bank_register_c) else '0';

-- PCORE read signals
pcore_read_addr <= dp_pcore_read_addr;
pcore_read_addr_mode <= dp_pcore_read_addr_mode;
pcore_read_enable <= dp_pcore_read_enable and (not pcore_read_busy); 
pcore_read_vector <= dp_pcore_read_vector;
pcore_read_data_flow <= dp_pcore_read_data_flow; 
pcore_read_stream <= dp_pcore_read_stream;
pcore_read_data_type <= dp_pcore_read_data_type; 
pcore_read_data_model <= dp_pcore_read_data_model;
pcore_read_scatter2 <= pcore_read_scatter;
pcore_read_gen_valid <= '1';
pcore_read_fork <= dp_pcore_read_fork;

-- SRAM read signals
sram_read_addr <= dp_sram_read_addr(sram_depth_c-1 downto 0);
sram_read_enable <= dp_sram_read_enable;
sram_read_vector <= dp_sram_read_vector;
sram_read_gen_valid <= '1';
sram_read_fork <= dp_sram_read_fork;

-- Control register read signals
register_rden <= '1' when mcore_register_rden='1' and mcore_register_waitrequest_r='0' else '0';

-- Generate waitrequest to DP when there is a conflict with MCORE while accessing SRAM
dp_sram_read_wait <= '0';
dp_sram_write_wait <= swdl_wait and swdl_write_enable;

-- Generate waitrequest to DP when there is a conflict with MCORE while accessing PCORE
pcore_read_busy <= dp_pcore_read_enable and (((not dp_pcore_read_vm) and pcore_busy(0)) or (dp_pcore_read_vm and pcore_busy(1)));
pcore_write_busy <= dp_pcore_write_enable and (((not dp_pcore_write_vm) and pcore_busy(0)) or (dp_pcore_write_vm and pcore_busy(1)));

dp_pcore_read_wait <= pcore_read_busy or pcore_read_wait;
dp_pcore_write_wait <= pcore_write_busy or pcore_write_wait;

-- MUX writedata to SRAM. Source can be from DP or MCORE
sram_write_data <= dp_sram_write_data;
sram_write_addr <= dp_sram_write_addr(sram_depth_c-1 downto 0);
sram_write_enable <= '1' when (dp_sram_write_enable='1' and dp_sram_write_page=dp_bus2_page_sram_c) else '0';
sram_write_vector <= dp_sram_write_vector;
sram_write_fork <= dp_sram_write_fork;

-- swdl Stream write 
swdl_write_enable <= '1' when (dp_sram_write_enable='1' and dp_sram_write_page=dp_bus2_page_mcore_code_c) else '0';

-- MUX writedata to PCORE. Source can be from DP or MCORE
pcore_write_addr <= dp_pcore_write_addr;
pcore_write_fork <= dp_pcore_write_fork;
pcore_write_data <= dp_pcore_write_data;
pcore_write_enable <= dp_pcore_write_enable and (not pcore_write_busy);
pcore_write_data_flow <= dp_pcore_write_data_flow;
pcore_write_data_type <= dp_pcore_write_data_type;
pcore_write_data_model <= dp_pcore_write_data_model;
pcore_write_vector <= dp_pcore_write_vector;
pcore_write_stream <= dp_pcore_write_stream;
pcore_write_stream_id <= dp_pcore_write_stream_id;
pcore_write_scatter2 <= pcore_write_scatter;
pcore_write_gen_valid <= '1';

-- SRAM write page
dp_sram_write_page <= dp_sram_write_addr(dp_sram_write_addr'length-1 downto dp_sram_write_addr'length-dp_bus2_page_t'length);


-- Generate waitrequest to MCORE
mcore_waitrequest <= mcore_register_waitrequest or dp_waitrequest;

pcore_read_data_valid2 <= pcore_read_data_valid and pcore_read_gen_valid2;

avalon_bus_readdata_out <= avalon_bus_readdata_r;

m_avalon_bus_readdatavalid <= msgq_readdatavalid or sys_config_readdatavalid;

-- Generate MCORE wait request for control register access. Need 1 wait state
mcore_register_waitrequest <= '1' when (mcore_register_rden='1' and (mcore_register_waitrequest_r='0' or mcore_register_waitrequest_rr='0'))  else '0';
process(mreset_in,mclock_in)
begin
    if mreset_in = '0' then
        mcore_register_waitrequest_r <= '0';
        mcore_register_waitrequest_rr <= '0';
    else
        if mclock_in'event and mclock_in='1' then
            mcore_register_waitrequest_rr <= mcore_register_waitrequest_r;
            mcore_register_waitrequest_r <= mcore_register_waitrequest;
        end if;
    end if;
end process;

-- MUX returned read value to MCORE. 
-- MCORE returned read data can be from REGISTER,SRAM or PCORE
process(mreset_in,mclock_in)
begin
if mreset_in='0' then
    mcore_readdata_r <= (others=>'0');
else
    if mclock_in'event and mclock_in='1' then
        mcore_readdata_r <= register_readdata;
    end if;
end if;
end process;

process(hreset_in,hclock_in)
begin
if hreset_in='0' then
    avalon_bus_readdata_r <= (others=>'0');
else
    if hclock_in'event and hclock_in='1' then
        avalon_bus_readdata_r <= avalon_bus_readdata;
    end if;
end if;
end process;

process(mreset_in,mclock_in)
begin
    if mreset_in = '0' then
        mcore_register_rden_r <= '0';
    else
        if mclock_in'event and mclock_in='1' then
            mcore_register_rden_r <= mcore_register_rden;
        end if;
    end if;
end process;

------
-- Update write pending count to each bus
------
 
process(preset_in,pclock_in)
variable vm_v:integer;
variable sram_vm_v:integer;
begin
    if preset_in = '0' then
        pcore_write_counter_r <= (others=>(others=>'0'));
        sram_write_counter_r <= (others=>(others=>'0'));
        ddr_write_counter_r <= (others=>'0');
    else
        if pclock_in'event and pclock_in='1' then
            if dp_pcore_write_enable='1' and dp_pcore_write_wait='0' then
				if dp_pcore_write_vm='0' then
					vm_v:=0;
				else
					vm_v:=1;
				end if;
                if dp_pcore_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,ddr_vector_depth_c)) then
                   pcore_write_counter_r(vm_v) <= pcore_write_counter_r(vm_v)+(ddr_vector_width_c/4);
                elsif dp_pcore_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,ddr_vector_depth_c)) then
                   pcore_write_counter_r(vm_v) <= pcore_write_counter_r(vm_v)+(ddr_vector_width_c/2);
                elsif dp_pcore_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,ddr_vector_depth_c)) then
                   pcore_write_counter_r(vm_v) <= pcore_write_counter_r(vm_v)+(ddr_vector_width_c);
                else
                   pcore_write_counter_r(vm_v) <= pcore_write_counter_r(vm_v)+1;
                end if;
            end if;
            if dp_sram_write_enable='1' and dp_sram_write_wait='0' then
				if dp_sram_write_vm='0' then
					sram_vm_v:=0;
				else
					sram_vm_v:=1;
				end if;
                if dp_sram_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,ddr_vector_depth_c)) then
                   sram_write_counter_r(sram_vm_v) <= sram_write_counter_r(sram_vm_v)+(ddr_vector_width_c/4);
                elsif dp_sram_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,ddr_vector_depth_c)) then
                   sram_write_counter_r(sram_vm_v) <= sram_write_counter_r(sram_vm_v)+(ddr_vector_width_c/2);
                elsif dp_sram_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,ddr_vector_depth_c)) then
                   sram_write_counter_r(sram_vm_v) <= sram_write_counter_r(sram_vm_v)+(ddr_vector_width_c);
                else
                   sram_write_counter_r(sram_vm_v) <= sram_write_counter_r(sram_vm_v)+1;
                end if;
            end if;
            if ddr_write_enable='1' and ddr_write_wait_2='0' then
                if ddr_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/4-1,ddr_vector_depth_c)) then
                   ddr_write_counter_r <= ddr_write_counter_r+(ddr_vector_width_c/4);
                elsif ddr_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,ddr_vector_depth_c)) then
                   ddr_write_counter_r <= ddr_write_counter_r+(ddr_vector_width_c/2);
                elsif ddr_write_vector=std_logic_vector(to_unsigned(ddr_vector_width_c-1,ddr_vector_depth_c)) then
                   ddr_write_counter_r <= ddr_write_counter_r+(ddr_vector_width_c);
                else
                   ddr_write_counter_r <= ddr_write_counter_r+1;
                end if;
            end if;
        end if;
    end if;
end process;


-------
-- Instantiate message queue for mcore and host to communicate with each other
------

msgq_i : msgq
    port map(
        hclock_in => mclock_in,
        mclock_in => mclock_in,
        reset_in => mreset_in,
        sreset_in => sreset,
        -- Interface with host
        host_addr_in => m_avalon_bus_addr(register_addr_t'length-1 downto 0),
        host_write_in => m_config_wren,
        host_read_in => m_config_rden,
        host_writedata_in => m_avalon_bus_writedata,
        host_readdata_out => m_avalon_bus_readdata,
        host_readdatavalid_out=>msgq_readdatavalid,
        host_msg_avail_out=>indication_avail_out,

        -- Interface with MCORE
        mcore_addr_in => mcore_addr(register_addr_t'length-1 downto 0),
        mcore_write_in => mcore_register_wren,
        mcore_read_in => register_rden,
        mcore_writedata_in => mcore_writedata(host_width_c-1 downto 0),
        mcore_readdata_out => register_readdata(host_width_c-1 downto 0)
        );

-------
-- Instantiate SRAM block
-------

sram_i: sram_core
    port map(
        clock_in => pclock_in,
        reset_in => preset_in,
        -- DP interface
        dp_rd_addr_in => sram_read_addr,
        dp_wr_addr_in => sram_write_addr,    
        dp_rd_fork_in => sram_read_fork,
        dp_wr_fork_in => sram_write_fork,    
        dp_write_in => sram_write_enable,
        dp_write_vector_in => sram_write_vector,
        dp_read_in => sram_read_enable,
        dp_read_vm_in => sram_read_vm,
        dp_read_vector_in => sram_read_vector,
        dp_read_gen_valid_in => sram_read_gen_valid,
        dp_writedata_in => sram_write_data,
		dp_readdatavalid_out => sram_read_data_valid,
        dp_readdatavalid_vm_out => sram_readdata_vm,
        dp_readdata_out => sram_read_data);

p_avalon_bus_readdata <= (others=>'0');
p_avalon_bus_readdatavalid <= '0';

avalon_lw_adapter_i: avalon_lw_adapter
    port map(
        mclock_in => mclock_in,
        pclock_in => pclock_in,
        hclock_in => hclock_in,
        mreset_in => mreset_in,
        preset_in => preset_in,
        hreset_in => hreset_in,
        -- Interface with host clock domain
        host_addr_in => avalon_bus_addr_in,
        host_write_in => avalon_bus_write_in,
        host_read_in => avalon_bus_read_in,
        host_writedata_in => avalon_bus_writedata_in,
        host_readdata_out => avalon_bus_readdata,
        host_waitrequest_out => avalon_bus_wait_request_out,
        -- Interface with MCLK clock domain
        m_addr_out => m_avalon_bus_address,
        m_write_out => m_avalon_bus_write,
        m_read_out => m_avalon_bus_read,
        m_writedata_out => m_avalon_bus_writedata,
        m_readdata_in => m_avalon_bus_readdata,
        m_readdatavalid_in => m_avalon_bus_readdatavalid,
        -- Interface with PCLOCK clock domain
        p_addr_out => p_avalon_bus_address,
        p_write_out => p_avalon_bus_write,
        p_read_out => p_avalon_bus_read,
        p_writedata_out => p_avalon_bus_writedata,
        p_readdata_in => p_avalon_bus_readdata,
        p_readdatavalid_in => p_avalon_bus_readdatavalid
        );        

avalon_adapter_i: avalon_adapter
    port map( 
        clock_in => dclock_in,
        reset_in => dreset_in,
        ddr_addr_in=>cell_ddr_0_addr,
        ddr_burstlen_in=>cell_ddr_0_burstlen,
        ddr_burstbegin_in=>cell_ddr_0_burstbegin,
        ddr_readdatavalid_out=>cell_ddr_0_readdatavalid,
        ddr_write_in=>cell_ddr_0_write,
        ddr_read_in=>cell_ddr_0_read,
        ddr_writedata_in=>cell_ddr_0_writedata,
        ddr_byteenable_in=>cell_ddr_0_byteenable,
        ddr_readdata_out=>cell_ddr_0_readdata,
        ddr_wait_request_out=>cell_ddr_0_wait_request,

        avalon_addr_out =>cell_ddr_0_addr_out,
        avalon_burstlen_out =>cell_ddr_0_burstlen_out,
        avalon_burstbegin_out =>cell_ddr_0_burstbegin_out,
        avalon_readdatavalid_in =>cell_ddr_0_readdatavalid_in,
        avalon_write_out =>cell_ddr_0_write_out,
        avalon_read_out =>cell_ddr_0_read_out,
        avalon_writedata_out =>cell_ddr_0_writedata_out,
        avalon_byteenable_out =>cell_ddr_0_byteenable_out,
        avalon_readdata_in =>cell_ddr_0_readdata_in,
        avalon_wait_request_in =>cell_ddr_0_wait_request_in
    );

avalon_adapter_i2: avalon_adapter
    port map( 
        clock_in => dclock_in,
        reset_in => dreset_in,

        ddr_addr_in=>cell_ddr_1_addr,
        ddr_burstlen_in=>cell_ddr_1_burstlen,
        ddr_burstbegin_in=>cell_ddr_1_burstbegin,
        ddr_readdatavalid_out=>cell_ddr_1_readdatavalid,
        ddr_write_in=>cell_ddr_1_write,
        ddr_read_in=>cell_ddr_1_read,
        ddr_writedata_in=>cell_ddr_1_writedata,
        ddr_byteenable_in=>cell_ddr_1_byteenable,
        ddr_readdata_out=>cell_ddr_1_readdata,
        ddr_wait_request_out=>cell_ddr_1_wait_request,

        avalon_addr_out =>cell_ddr_1_addr_out,
        avalon_burstlen_out =>cell_ddr_1_burstlen_out,
        avalon_burstbegin_out =>cell_ddr_1_burstbegin_out,
        avalon_readdatavalid_in =>cell_ddr_1_readdatavalid_in,
        avalon_write_out =>cell_ddr_1_write_out,
        avalon_read_out =>cell_ddr_1_read_out,
        avalon_writedata_out =>cell_ddr_1_writedata_out,
        avalon_byteenable_out =>cell_ddr_1_byteenable_out,
        avalon_readdata_in =>cell_ddr_1_readdata_in,
        avalon_wait_request_in =>cell_ddr_1_wait_request_in
    );


---------
-- Instantiate DDR interface
---------

-- Muxing DDR read....

ddr_read_wait_2 <= ddr_read_wait and ddr_read_enable;
ddr_read_enable_2 <= '1' when (ddr_read_enable='1') and (ddr_read_wait='0') else '0';

-- Muxing DDR write ....

ddr_write_wait_2 <= ddr_write_wait and ddr_write_enable;
ddr_write_enable_2 <= '1' when (ddr_write_enable='1') and (ddr_write_wait='0') else '0';

process(ddr_data_ready)
begin
if ddr_data_ready(0)='0' then
   ddr_data_wait <= (others=>'1');
else
   ddr_data_wait <= (others=>'0');
end if;
end process;

ddr_rx_i: ddr_rx
    port map(
        clock_in=>pclock_in,
        reset_in=>preset_in,
        dclock_in=>dclock_in,
        dreset_in=>dreset_in,

        read_addr_in=>ddr_read_addr,
        read_cs_in=>ddr_read_enable_2,
        read_in=>ddr_read_enable_2,
        read_vm_in=>ddr_read_vm,
        read_vector_in=>ddr_read_vector,
        read_fork_in=>(others=>'0'),
        read_start_in=>ddr_read_start,
        read_end_in=>ddr_read_end(0),
        read_data_ready_out=>ddr_data_ready(0),
        read_fork_out=>open,
        read_data_wait_in=>ddr_data_wait(0),
        read_filler_data_in=>ddr_read_filler_data,

		read_data_valid_out=>ddr_read_data_valid,
        read_data_valid_vm_out=>ddr_readdata_vm,
        read_data_out=>ddr_read_data,
        read_wait_request_out=>ddr_read_wait,
        read_burstlen_in=>ddr_read_burstlen,

        ddr_addr_out=>cell_ddr_0_addr,
        ddr_burstlen_out=>cell_ddr_0_burstlen,
        ddr_burstbegin_out=>cell_ddr_0_burstbegin,
        ddr_readdatavalid_in=>cell_ddr_0_readdatavalid,
        ddr_read_out=>cell_ddr_0_read,
        ddr_readdata_in=>cell_ddr_0_readdata,
        ddr_wait_request_in=>cell_ddr_0_wait_request
        );

cell_ddr_0_write <= '0';
cell_ddr_0_writedata <= (others=>'0');
cell_ddr_0_byteenable <= (others=>'0');


ddr_tx_i: ddr_tx
    port map(
        clock_in=>pclock_in,
        reset_in=>preset_in,
        dclock_in=>dclock_in,
        dreset_in=>dreset_in,

        write_addr_in=>ddr_write_addr,
        write_cs_in=>ddr_write_enable_2,
        write_in=>ddr_write_enable_2,
        write_vector_in=>ddr_write_vector,
        write_end_in=>ddr_write_end(0),
        write_data_in=>ddr_write_data,
        write_wait_request_out=>ddr_write_wait,
        write_burstlen_in=>ddr_write_burstlen,
        write_burstlen2_in=>ddr_write_burstlen2,
        write_burstlen3_in=>ddr_write_burstlen3,

        ddr_addr_out=>cell_ddr_1_addr,
        ddr_burstlen_out=>cell_ddr_1_burstlen,
        ddr_burstbegin_out=>cell_ddr_1_burstbegin,
        ddr_write_out=>cell_ddr_1_write,
        ddr_writedata_out=>cell_ddr_1_writedata,
        ddr_byteenable_out=>cell_ddr_1_byteenable,
        ddr_wait_request_in=>cell_ddr_1_wait_request
        );

cell_ddr_1_read <= '0';

--------
-- Instantiate data plane processor
--------

dp_1_i: dp_core
    port map(
        clock_in=>pclock_in,
        reset_in=>preset_in,   
        mclock_in=>mclock_in,
        mreset_in=>mreset_in,               
        -- Configuration bus
        bus_addr_in=>mcore_addr(register_addr_t'length-1 downto 0),
        bus_write_in=>mcore_register_wren,
        bus_read_in=>register_rden,
        bus_writedata_in=>mcore_writedata(host_width_c-1 downto 0),
        bus_readdata_out=>register_readdata(host_width_c-1 downto 0),
        bus_waitrequest_out=>dp_waitrequest,

        -- Bus interface for read master to PCORE
        readmaster1_addr_out=>dp_pcore_read_addr,
        readmaster1_fork_out=>dp_pcore_read_fork,
        readmaster1_addr_mode_out=>dp_pcore_read_addr_mode,
        readmaster1_cs_out=>open,
        readmaster1_read_out=>dp_pcore_read_enable,
        readmaster1_read_vm_out=>dp_pcore_read_vm,
        readmaster1_read_data_flow_out=>dp_pcore_read_data_flow,
        readmaster1_read_stream_out=>dp_pcore_read_stream,
        readmaster1_read_stream_id_out=>pcore_read_stream_id,
        readmaster1_read_vector_out=>dp_pcore_read_vector,
        readmaster1_read_scatter_out=>pcore_read_scatter,
		readmaster1_readdatavalid_in => pcore_read_data_valid2,
        readmaster1_readdatavalid_vm_in=>pcore_readdata_vm,
        readmaster1_readdata_in=>pcore_read_data,
        readmaster1_wait_request_in=>dp_pcore_read_wait,
        readmaster1_burstlen_out=>open,
        readmaster1_bus_id_out=>open,
        readmaster1_data_type_out=>dp_pcore_read_data_type,
        readmaster1_data_model_out=>dp_pcore_read_data_model,

        -- Bus interface for write master to PCORE
        writemaster1_addr_out=>dp_pcore_write_addr,
        writemaster1_fork_out=>dp_pcore_write_fork,
        writemaster1_addr_mode_out=>pcore_write_addr_mode,
        writemaster1_vm_out=>dp_pcore_write_vm,
        writemaster1_mcast_out=>pcore_mcast,
        writemaster1_cs_out=>open,
        writemaster1_write_out=>dp_pcore_write_enable,
        writemaster1_write_data_flow_out=>dp_pcore_write_data_flow,
        writemaster1_write_vector_out=>dp_pcore_write_vector,
        writemaster1_write_stream_out=>dp_pcore_write_stream,
        writemaster1_write_stream_id_out=>dp_pcore_write_stream_id,
        writemaster1_write_scatter_out=>pcore_write_scatter,
        writemaster1_writedata_out=>dp_pcore_write_data,
        writemaster1_wait_request_in=>dp_pcore_write_wait,
        writemaster1_burstlen_out=>open,
        writemaster1_bus_id_out=>open,
        writemaster1_data_type_out=>dp_pcore_write_data_type,
		writemaster1_data_model_out=>dp_pcore_write_data_model,
        writemaster1_thread_out=>open,
        writemaster1_counter_in=>pcore_write_counter_r,

        -- Bus interface for read master to SRAM
        readmaster2_addr_out=>dp_sram_read_addr,
        readmaster2_fork_out=>dp_sram_read_fork(fork_sram_c-1 downto 0),
        readmaster2_cs_out=>open,
        readmaster2_read_out=>dp_sram_read_enable,
        readmaster2_read_vm_out=>sram_read_vm,
        readmaster2_read_vector_out=>dp_sram_read_vector,
        readmaster2_read_scatter_out=>open,
		readmaster2_readdatavalid_in => sram_read_data_valid,
        readmaster2_readdatavalid_vm_in=> sram_readdata_vm,
        readmaster2_readdata_in=>sram_read_data(fork_sram_c*ddr_data_width_c-1 downto 0),
        readmaster2_wait_request_in=>dp_sram_read_wait,
        readmaster2_burstlen_out=>open,
        readmaster2_bus_id_out=>open,

        -- Bus interface for write master to SRAM
        writemaster2_addr_out=>dp_sram_write_addr,
        writemaster2_fork_out=>dp_sram_write_fork(fork_sram_c-1 downto 0),
        writemaster2_cs_out=>open,
        writemaster2_write_out=>dp_sram_write_enable,
        writemaster2_vm_out=>dp_sram_write_vm,
        writemaster2_write_vector_out=>dp_sram_write_vector,
        writemaster2_write_scatter_out=>open,
        writemaster2_writedata_out=>dp_sram_write_data(fork_sram_c*ddr_data_width_c-1 downto 0),
        writemaster2_wait_request_in=>dp_sram_write_wait,
        writemaster2_burstlen_out=>open,
        writemaster2_bus_id_out=>open,
        writemaster2_thread_out=>open,
        writemaster2_counter_in=>sram_write_counter_r,

        -- Bus interface for read master to DDR
        readmaster3_addr_out=>ddr_read_addr,
        readmaster3_cs_out=>open,
        readmaster3_read_out=>ddr_read_enable,
        readmaster3_read_vm_out=>ddr_read_vm,
        readmaster3_read_vector_out=>ddr_read_vector,
        readmaster3_read_scatter_out=>open,
        readmaster3_read_start_out=>ddr_read_start,
        readmaster3_read_end_out=>ddr_read_end,
		readmaster3_readdatavalid_in => ddr_read_data_valid,
		readmaster3_readdatavalid_vm_in => ddr_readdata_vm, 
        readmaster3_readdata_in=>ddr_read_data,
        readmaster3_wait_request_in=>ddr_read_wait_2,
        readmaster3_burstlen_out=>ddr_read_burstlen,
        readmaster3_bus_id_out=>open,
        readmaster3_filler_data_out=>ddr_read_filler_data,

        -- Bus interface for write master to DDR
        writemaster3_addr_out=>ddr_write_addr,
        writemaster3_cs_out=>open,
        writemaster3_write_out=>ddr_write_enable,
        writemaster3_vm_out=>open,
        writemaster3_write_vector_out=>ddr_write_vector,
        writemaster3_write_scatter_out=>open,
        writemaster3_write_end_out=>ddr_write_end,
        writemaster3_writedata_out=>ddr_write_data,
        writemaster3_wait_request_in=>ddr_write_wait_2,
        writemaster3_burstlen_out=>ddr_write_burstlen,
        writemaster3_burstlen2_out=>ddr_write_burstlen2,
        writemaster3_burstlen3_out=>ddr_write_burstlen3,
        writemaster3_bus_id_out=>open,
        writemaster3_thread_out=>open,
        writemaster3_counter_in=>ddr_write_counter_r,

        -- Task control
        task_start_addr_out=>task_start_addr,
        task_out=>task,
        task_vm_out=>task_vm,
        task_pcore_out=>task_pcore,
        task_lockstep_out=>task_lockstep,
        task_tid_mask_out=>task_tid_mask,
        task_iregister_auto_out=>task_iregister_auto,
		task_data_model_out=>task_data_model,
        task_busy_in=>busy,
        task_ready_in=>ready,
        task_busy_out=>pcore_busy,


        -- BAR

        bar_in=>bar,

        indication_avail_out => open
    );


---------
-- Instantiate system configurator
---------

sys_config_i: sys_config
    port map(
            clock_in => mclock_in,
            reset_in => mreset_in,
            bus_addr_in => m_avalon_bus_addr(register_addr_t'length-1 downto 0),
            bus_write_in => m_config_wren,
            bus_read_in => m_config_rden,
            bus_writedata_in => m_avalon_bus_writedata,
            bus_readdata_out => m_avalon_bus_readdata,
            bus_readdatavalid_out => sys_config_readdatavalid,
            sreset_out => sreset
    );

----------
-- Instantiate PCORE arrays
----------
    
core_i: core 
   port map(
		clock_in => pclock_in,
        reset_in => preset_in,

        -- DP interface
        dp_rd_addr_in => pcore_read_addr,
        dp_rd_fork_in => pcore_read_fork,
        dp_rd_addr_mode_in => pcore_read_addr_mode,
        dp_wr_addr_in => pcore_write_addr,
        dp_wr_fork_in => pcore_write_fork,
        dp_wr_addr_mode_in => pcore_write_addr_mode,
        dp_wr_mcast_in => pcore_mcast,
        dp_write_in => pcore_write_enable,
        dp_write_wait_out => pcore_write_wait,
        dp_write_gen_valid_in => pcore_write_gen_valid,
        dp_read_in => pcore_read_enable,
        dp_read_data_flow_in => pcore_read_data_flow,
        dp_read_stream_in => pcore_read_stream,
        dp_read_stream_id_in => pcore_read_stream_id,
        dp_read_data_type_in => pcore_read_data_type,
		dp_read_data_model_in => pcore_read_data_model,
        dp_read_vector_in => pcore_read_vector,
        dp_read_scatter_in => pcore_read_scatter2,
        dp_read_gen_valid_in => pcore_read_gen_valid,
        dp_read_wait_out => pcore_read_wait,
        dp_writedata_in => pcore_write_data,
        dp_write_data_flow_in => pcore_write_data_flow,
        dp_write_data_type_in => pcore_write_data_type,	
		dp_write_data_model_in => pcore_write_data_model,
        dp_write_vector_in => pcore_write_vector,
        dp_write_stream_in => pcore_write_stream,
        dp_write_stream_id_in => pcore_write_stream_id,
        dp_write_scatter_in => pcore_write_scatter2,
        dp_readdatavalid_out=> pcore_read_data_valid,
        dp_read_gen_valid_out=> pcore_read_gen_valid2,
        dp_readdata_out => pcore_read_data,
        dp_readdata_vm_out=>pcore_readdata_vm,
        -- Task control
        task_start_addr_in => task_start_addr,
        task_in => task,
        task_vm_in => task_vm,
        task_pcore_in => task_pcore,
        task_lockstep_in => task_lockstep,
        task_tid_mask_in => task_tid_mask,
        task_iregister_auto_in => task_iregister_auto,
		task_data_model_in => task_data_model,

        busy_out => busy,
        ready_out => ready,

        -- Configuration commands
        config_in => p_config_wren,
        config_reg_in => p_avalon_bus_addr(register_addr_t'length-1 downto 0),
        config_data_in => p_avalon_bus_writedata
    );


---------
--- Instantiate MCORE processor
---------

mcore_writedata(mcore_writedata'length-1 downto host_width_c) <= (others=>'0');


swdl_i: swdl
    port map(
       mclock_in => mclock_in,
       mreset_in => mreset_in,
       pclock_in => pclock_in,
       preset_in => preset_in,

       mcore_addr_in => mcore_addr(register_addr_t'length-1 downto 0),
       mcore_read_in => register_rden,
       mcore_write_in => mcore_register_wren,
       mcore_readdata_out => register_readdata(host_width_c-1 downto 0),

       -- SWDL directly from host 
       host_write_in => m_mcode_write,
       host_writedata_in => m_avalon_bus_writedata,
       host_write_addr_in => m_avalon_bus_addr,
       
       -- SWDL from DDR streaming
	   stream_write_addr_in => dp_sram_write_addr,
       stream_write_data_in => dp_sram_write_data(ddr_data_width_c-1 downto 0),
       stream_write_enable_in => swdl_write_enable,
       stream_wait_out => swdl_wait,

       prog_text_ena_out => prog_text_ena,
       prog_text_data_out => prog_text_data,
       prog_text_addr_out => prog_text_addr
        ); 

mcore_i:mcore
    PORT MAP(
        clock_in=>mclock_in,
        reset_in=>mreset_in,
        sreset_in=>sreset,
        -- IO interface
        io_wren_out=>mcore_wren,
        io_rden_out=>mcore_rden,
        io_addr_out=>mcore_addr,
        io_readdata_in=>mcore_readdata_r,
        io_writedata_out=>mcore_writedata(host_width_c-1 downto 0),
        io_byteena_out=>open,
        io_waitrequest_in=>mcore_waitrequest,
        prog_text_ena_in=>prog_text_ena,
        prog_text_addr_in=>prog_text_addr,
        prog_text_data_in=>prog_text_data,
        prog_data_ena_in=>m_mdata_write,
        prog_data_addr_in=>m_avalon_bus_addr(mcore_ram_depth_c-1 downto 0),
        prog_data_data_in=>m_avalon_bus_writedata
    );

END ztachip_behavior;
