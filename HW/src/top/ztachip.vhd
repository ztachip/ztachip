------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Author: Vuong Nguyen
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
use work.ztachip_pkg.all;

ENTITY ztachip IS
    port(   
            clock_in                      : IN STD_LOGIC;
            clock_x2_in                   : IN STD_LOGIC;
            reset_in                      : IN STD_LOGIC;                      

            axi_araddr_out                : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            axi_arlen_out                 : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
            axi_arvalid_out               : OUT std_logic;
            axi_rvalid_in                 : IN std_logic;
            axi_rlast_in                  : IN std_logic;
            axi_rdata_in                  : IN std_logic_vector(ddr_data_width_c-1 downto 0);
            axi_arready_in                : IN std_logic;
            axi_rready_out                : OUT std_logic;         
            axi_arburst_out               : OUT std_logic_vector(1 downto 0);
            axi_arcache_out               : OUT std_logic_vector(3 downto 0);
            axi_arid_out                  : OUT std_logic_vector(0 downto 0);
            axi_arlock_out                : OUT std_logic_vector(0 downto 0);
            axi_arprot_out                : OUT std_logic_vector(2 downto 0);
            axi_arqos_out                 : OUT std_logic_vector(3 downto 0); 
            axi_arsize_out                : OUT std_logic_vector(2 downto 0);
            
            axi_awaddr_out                : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            axi_awlen_out                 : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
            axi_awvalid_out               : OUT std_logic;
            axi_waddr_out                 : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
            axi_wvalid_out                : OUT std_logic;
            axi_wdata_out                 : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
            axi_wlast_out                 : OUT std_logic;
            axi_wbe_out                   : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0);
            axi_awready_in                : IN std_logic;
            axi_wready_in                 : IN std_logic;
            axi_bresp_in                  : IN std_logic;
            axi_awburst_out               : OUT std_logic_vector(1 downto 0);
            axi_awcache_out               : OUT std_logic_vector(3 downto 0);
            axi_awid_out                  : OUT std_logic_vector(0 downto 0);
            axi_awlock_out                : OUT std_logic_vector(0 downto 0);
            axi_awprot_out                : OUT std_logic_vector(2 downto 0);
            axi_awqos_out                 : OUT std_logic_vector(3 downto 0);
            axi_awsize_out                : OUT std_logic_vector(2 downto 0);
            axi_bready_out                : OUT std_logic;
   
            -- Host interface 

            axilite_araddr_in             : IN std_logic_vector(io_depth_c-1 downto 0);
            axilite_arvalid_in            : IN std_logic;
            axilite_arready_out           : OUT std_logic;
            axilite_rvalid_out            : OUT std_logic;
            axilite_rlast_out             : OUT std_logic;
            axilite_rdata_out             : OUT std_logic_vector(host_width_c-1 downto 0);
            axilite_rready_in             : IN std_logic; 
            axilite_rresp_out             : OUT std_logic_vector(1 downto 0);

            axilite_awaddr_in             : IN std_logic_vector(io_depth_c-1 downto 0);
            axilite_awvalid_in            : IN std_logic;
            axilite_wvalid_in             : IN std_logic;
            axilite_wdata_in              : IN std_logic_vector(host_width_c-1 downto 0);
            axilite_awready_out           : OUT std_logic;
            axilite_wready_out            : OUT std_logic;
            axilite_bvalid_out            : OUT std_logic;
            axilite_bready_in             : IN std_logic;
            axilite_bresp_out             : OUT std_logic_vector(1 downto 0)
            );
END ztachip;

ARCHITECTURE ztachip_behavior of ztachip IS 

-- Host interface

SIGNAL host_waddr:STD_LOGIC_VECTOR(io_depth_c-1 downto 0);
SIGNAL host_raddr:STD_LOGIC_VECTOR(io_depth_c-1 downto 0);
SIGNAL host_wren:STD_LOGIC;  
SIGNAL host_rden:STD_LOGIC;      
SIGNAL host_writedata:STD_LOGIC_VECTOR(host_width_c-1 downto 0);    
SIGNAL host_readdata:STD_LOGIC_VECTOR(host_width_c-1 downto 0);
SIGNAL host_readdatavalid:STD_LOGIC;
SIGNAL host_writewait:STD_LOGIC;
SIGNAL host_readwait:STD_LOGIC;

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

SIGNAL ddr_read_addr: std_logic_vector(dp_full_addr_width_c-1 downto 0);
SIGNAL ddr_read_enable: STD_LOGIC;
SIGNAL ddr_read_enable_2:STD_LOGIC;
SIGNAL ddr_read_wait: STD_LOGIC;
SIGNAL ddr_read_wait_2:STD_LOGIC;
SIGNAL ddr_read_data: STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL ddr_read_data_valid: STD_LOGIC;
SIGNAL ddr_read_burstlen: burstlen_t;
SIGNAL ddr_read_filler_data: STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

-- Interface to DP1 write port 3

SIGNAL ddr_write_addr: std_logic_vector(dp_full_addr_width_c-1 downto 0);
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

SIGNAL dp_waitrequest:STD_LOGIC;
SIGNAL ddr_tx_busy:STD_LOGIC;
BEGIN


bar(dp_bus_id_register_c) <= (others=>'0');
bar(dp_bus_id_sram_c) <= (others=>'0');
bar(dp_bus_id_ddr_c)(dp_addr_width_c-1) <= '0';
bar(dp_bus_id_ddr_c)(dp_addr_width_c-2 downto 0) <= (others=>'0');

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

-- Generate waitrequest to DP when there is a conflict with MCORE while accessing SRAM

dp_sram_read_wait <= '0';
dp_sram_write_wait <= '0';

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

pcore_read_data_valid2 <= pcore_read_data_valid and pcore_read_gen_valid2;

------
-- Update write pending count to each bus
------
 
process(reset_in,clock_in)
variable vm_v:integer;
variable sram_vm_v:integer;
begin
    if reset_in = '0' then
        pcore_write_counter_r <= (others=>(others=>'0'));
        sram_write_counter_r <= (others=>(others=>'0'));
        ddr_write_counter_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
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

------
-- Host interface
--------

axilite_i: axilite
   PORT MAP( 
        clock_in=>clock_in,
        reset_in=>reset_in,

        axilite_araddr_in=>axilite_araddr_in,
        axilite_arvalid_in=>axilite_arvalid_in,
        axilite_arready_out=>axilite_arready_out,
        axilite_rvalid_out=>axilite_rvalid_out,
        axilite_rlast_out=>axilite_rlast_out,
        axilite_rdata_out=>axilite_rdata_out,
        axilite_rready_in=>axilite_rready_in,
        axilite_rresp_out=>axilite_rresp_out,   

        axilite_awaddr_in=>axilite_awaddr_in,
        axilite_awvalid_in=>axilite_awvalid_in,
        axilite_wvalid_in=>axilite_wvalid_in,
        axilite_wdata_in=>axilite_wdata_in,
        axilite_awready_out=>axilite_awready_out,
        axilite_wready_out=>axilite_wready_out,
        axilite_bvalid_out=>axilite_bvalid_out,
        axilite_bready_in=>axilite_bready_in,
        axilite_bresp_out=>axilite_bresp_out,   

        bus_waddr_out=>host_waddr,
        bus_raddr_out=>host_raddr,
        bus_write_out=>host_wren,
        bus_read_out=>host_rden,
        bus_writedata_out=>host_writedata,
        bus_readdata_in=>host_readdata,
        bus_readdatavalid_in=>host_readdatavalid,
        bus_writewait_in=>host_writewait,
        bus_readwait_in=>host_readwait
    );

-------
-- Instantiate SRAM block
-------

sram_i: sram_core
    port map(
        clock_in => clock_in,
        reset_in => reset_in,
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

----
-- DDR RX
----

ddr_rx_i: ddr_rx
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,

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

        ddr_araddr_out=>axi_araddr_out,
        ddr_arlen_out=>axi_arlen_out,
        ddr_arvalid_out=>axi_arvalid_out,
        ddr_rvalid_in=>axi_rvalid_in,
        ddr_rlast_in=>axi_rlast_in,
        ddr_rdata_in=>axi_rdata_in,
        ddr_arready_in=>axi_arready_in,
        ddr_rready_out=>axi_rready_out,
        ddr_arburst_out=>axi_arburst_out,
        ddr_arcache_out=>axi_arcache_out,
        ddr_arid_out=>axi_arid_out,
        ddr_arlock_out=>axi_arlock_out,
        ddr_arprot_out=>axi_arprot_out,
        ddr_arqos_out=>axi_arqos_out,
        ddr_arsize_out=>axi_arsize_out
        );

---
-- DDR TX
-----

ddr_tx_i: ddr_tx
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,

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

        ddr_awaddr_out=>axi_awaddr_out,
        ddr_awlen_out=>axi_awlen_out,
        ddr_awvalid_out=>axi_awvalid_out,
        ddr_waddr_out=>axi_waddr_out,
        ddr_wvalid_out=>axi_wvalid_out,
        ddr_wdata_out=>axi_wdata_out,
        ddr_wlast_out=>axi_wlast_out,
        ddr_wbe_out=>axi_wbe_out,
        ddr_awready_in=>axi_awready_in,
        ddr_wready_in=>axi_wready_in,
        ddr_bresp_in=>axi_bresp_in,     
        ddr_awburst_out=>axi_awburst_out,
        ddr_awcache_out=>axi_awcache_out,
        ddr_awid_out=>axi_awid_out,
        ddr_awlock_out=>axi_awlock_out,
        ddr_awprot_out=>axi_awprot_out,
        ddr_awqos_out=>axi_awqos_out,
        ddr_awsize_out=>axi_awsize_out,      
        ddr_bready_out=>axi_bready_out,
                
        ddr_tx_busy_out=>ddr_tx_busy
        );


--------
-- Instantiate data plane processor
--------

dp_1_i: dp_core
    port map(
        clock_in=>clock_in,
        reset_in=>reset_in,                

        -- Configuration bus

        bus_waddr_in=>host_waddr(register_addr_t'length+2-1 downto 2),
        bus_raddr_in=>host_raddr(register_addr_t'length+2-1 downto 2),
        bus_write_in=>host_wren,
        bus_read_in=>host_rden,
        bus_writedata_in=>host_writedata,
        bus_readdata_out=>host_readdata,
        bus_readdatavalid_out=>host_readdatavalid,
        bus_writewait_out=>host_writewait,
        bus_readwait_out=>host_readwait,

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

        indication_avail_out => open,
        
        ddr_tx_busy_in => ddr_tx_busy
    );


----------
-- Instantiate PCORE arrays
----------
    
core_i: core 
   port map(
        clock_in => clock_in,
        clock_x2_in => clock_x2_in,
        reset_in => reset_in,

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
        ready_out => ready
    );

END ztachip_behavior;
