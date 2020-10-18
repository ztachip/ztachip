---------------------------------------------------------------------------
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
---------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

--------------
-- Interface ztachip with qsys
-- Forward clock/reset signals from qsys to ztachip top component
-- Connect ztachip to avalon slave bus for register access from host
-- Connect ztachip to avalon master bus for DDR read/write access
--------------

ENTITY bridge IS
    port(   
	        SIGNAL hclock_in            : IN STD_LOGIC;
			SIGNAL hreset_in			: IN STD_LOGIC;
            SIGNAL pclock_in            : IN STD_LOGIC;
			SIGNAL preset_in			: IN STD_LOGIC;
            SIGNAL mclock_in            : IN STD_LOGIC;
            SIGNAL mreset_in            : IN STD_LOGIC; 
            SIGNAL dclock_in            : IN STD_LOGIC;
            SIGNAL dreset_in            : IN STD_LOGIC; 
			                      
            -- Avalon slave Bus interface
            SIGNAL avs_s0_chipselect    : IN std_logic;
            SIGNAL avs_s0_waitrequest   : OUT std_logic;
            SIGNAL avs_s0_read          : IN std_logic;
            SIGNAL avs_s0_readdata      : OUT std_logic_vector(31 downto 0);
            SIGNAL avs_s0_write         : IN std_logic;
            SIGNAL avs_s0_writedata     : IN std_logic_vector(31 downto 0);
            SIGNAL avs_s0_address       : IN std_logic_vector(16 downto 0);
            -- Avalon master bus interface #0
            SIGNAL avm_m0_address       : OUT std_logic_vector(31 downto 0);
            SIGNAL avm_m0_burstcount    : OUT std_logic_vector(2 downto 0);
            SIGNAL avm_m0_read          : OUT std_logic;
            SIGNAL avm_m0_readdata      : IN std_logic_vector(63 downto 0);
            SIGNAL avm_m0_readdatavalid : IN std_logic;
            SIGNAL avm_m0_waitrequest   : IN std_logic;
            SIGNAL avm_m0_write         : OUT std_logic;
            SIGNAL avm_m0_writedata     : OUT std_logic_vector(63 downto 0);
            SIGNAL avm_m0_byteenable    : OUT std_logic_vector(7 downto 0);
            SIGNAL avm_m0_response      : IN std_logic_vector(1 downto 0);
            SIGNAL avm_m0_writeresponsevalid: IN std_logic;

            -- Avalon master bus interface #1
            SIGNAL avm_m1_address       : OUT std_logic_vector(31 downto 0);
            SIGNAL avm_m1_burstcount    : OUT std_logic_vector(2 downto 0);
            SIGNAL avm_m1_read          : OUT std_logic;
            SIGNAL avm_m1_readdata      : IN std_logic_vector(63 downto 0);
            SIGNAL avm_m1_readdatavalid : IN std_logic;
            SIGNAL avm_m1_waitrequest   : IN std_logic;
            SIGNAL avm_m1_write         : OUT std_logic;
            SIGNAL avm_m1_writedata     : OUT std_logic_vector(63 downto 0);
            SIGNAL avm_m1_byteenable    : OUT std_logic_vector(7 downto 0);
            SIGNAL avm_m1_response      : IN std_logic_vector(1 downto 0);
            SIGNAL avm_m1_writeresponsevalid: IN std_logic;

            -- Avalon master bus interface #1
            SIGNAL avm_m2_address       : OUT std_logic_vector(31 downto 0);
            SIGNAL avm_m2_burstcount    : OUT std_logic_vector(2 downto 0);
            SIGNAL avm_m2_read          : OUT std_logic;
            SIGNAL avm_m2_readdata      : IN std_logic_vector(63 downto 0);
            SIGNAL avm_m2_readdatavalid : IN std_logic;
            SIGNAL avm_m2_waitrequest   : IN std_logic;
            SIGNAL avm_m2_write         : OUT std_logic;
            SIGNAL avm_m2_writedata     : OUT std_logic_vector(63 downto 0);
            SIGNAL avm_m2_byteenable    : OUT std_logic_vector(7 downto 0);
            SIGNAL avm_m2_response      : IN std_logic_vector(1 downto 0);
            SIGNAL avm_m2_writeresponsevalid: IN std_logic;

            SIGNAL interrupt_sender_irq : OUT std_logic
            );
END bridge;

ARCHITECTURE bridge_behaviour of bridge IS 

component ztachip IS
    port(   
	        hclock_in                   : IN STD_LOGIC;
			hreset_in					: IN STD_LOGIC;
            pclock_in                   : IN STD_LOGIC;
			preset_in					: IN STD_LOGIC;
            mclock_in                   : IN STD_LOGIC;
            mreset_in                   : IN STD_LOGIC; 
            dclock_in                   : IN STD_LOGIC;
            dreset_in                   : IN STD_LOGIC; 
			                      
            avalon_bus_addr_in          : IN std_logic_vector(16 downto 0);
            avalon_bus_write_in         : IN std_logic;
            avalon_bus_writedata_in     : IN std_logic_vector(31 downto 0);
            avalon_bus_readdata_out     : OUT std_logic_vector(31 downto 0);
            avalon_bus_wait_request_out : OUT std_logic;
            avalon_bus_read_in          : IN std_logic;        

            cell_ddr_0_addr_out           : OUT std_logic_vector(31 downto 0);
            cell_ddr_0_burstlen_out       : OUT unsigned(2 downto 0);
            cell_ddr_0_burstbegin_out     : OUT std_logic;
            cell_ddr_0_readdatavalid_in   : IN std_logic;
            cell_ddr_0_write_out          : OUT std_logic;
            cell_ddr_0_read_out           : OUT std_logic;
            cell_ddr_0_writedata_out      : OUT std_logic_vector(63 downto 0);
            cell_ddr_0_byteenable_out     : OUT std_logic_vector(7 downto 0);
            cell_ddr_0_readdata_in        : IN std_logic_vector(63 downto 0);
            cell_ddr_0_wait_request_in    : IN std_logic;

            cell_ddr_1_addr_out           : OUT std_logic_vector(31 downto 0);
            cell_ddr_1_burstlen_out       : OUT unsigned(2 downto 0);
            cell_ddr_1_burstbegin_out     : OUT std_logic;
            cell_ddr_1_readdatavalid_in   : IN std_logic;
            cell_ddr_1_write_out          : OUT std_logic;
            cell_ddr_1_read_out           : OUT std_logic;
            cell_ddr_1_writedata_out      : OUT std_logic_vector(63 downto 0);
            cell_ddr_1_byteenable_out     : OUT std_logic_vector(7 downto 0);
            cell_ddr_1_readdata_in        : IN std_logic_vector(63 downto 0);
            cell_ddr_1_wait_request_in    : IN std_logic;

            -- Indication
            SIGNAL indication_avail_out : OUT std_logic
            );
END component;

SIGNAL burstlen_0:unsigned(2 downto 0);
SIGNAL burstlen_1:unsigned(2 downto 0);
SIGNAL burstlen_2:unsigned(2 downto 0);
BEGIN

avm_m0_burstcount <= std_logic_vector(burstlen_0);
avm_m1_burstcount <= std_logic_vector(burstlen_1);


avm_m2_address <= (others=>'0');
avm_m2_burstcount <= (others=>'0');
avm_m2_read <= '0';
avm_m2_write <= '0';
avm_m2_writedata <= (others=>'0');
avm_m2_byteenable <= (others=>'0');


ztachip_i: ztachip
    port map(
	        hclock_in => hclock_in,
			hreset_in => hreset_in,
            pclock_in => pclock_in,
			preset_in => preset_in,
            mclock_in => mclock_in,
            mreset_in => mreset_in, 
            dclock_in => dclock_in,
            dreset_in => dreset_in, 
                                    
            avalon_bus_addr_in=>avs_s0_address(16 downto 0),
            avalon_bus_write_in=>avs_s0_write,
            avalon_bus_writedata_in=>avs_s0_writedata,
            avalon_bus_readdata_out=>avs_s0_readdata,
            avalon_bus_wait_request_out=>avs_s0_waitrequest,
            avalon_bus_read_in=>avs_s0_read,
                    
            cell_ddr_0_addr_out=>avm_m0_address,
            cell_ddr_0_burstlen_out => burstlen_0,
            cell_ddr_0_burstbegin_out => open,
            cell_ddr_0_readdatavalid_in => avm_m0_readdatavalid,
            cell_ddr_0_write_out=>avm_m0_write,
            cell_ddr_0_read_out=>avm_m0_read,
            cell_ddr_0_writedata_out=>avm_m0_writedata,
            cell_ddr_0_byteenable_out=>avm_m0_byteenable,
            cell_ddr_0_readdata_in=>avm_m0_readdata,
            cell_ddr_0_wait_request_in=>avm_m0_waitrequest,

            cell_ddr_1_addr_out=>avm_m1_address,
            cell_ddr_1_burstlen_out => burstlen_1,
            cell_ddr_1_burstbegin_out => open,
            cell_ddr_1_readdatavalid_in => avm_m1_readdatavalid,
            cell_ddr_1_write_out=>avm_m1_write,
            cell_ddr_1_read_out=>avm_m1_read,
            cell_ddr_1_writedata_out=>avm_m1_writedata,
            cell_ddr_1_byteenable_out=>avm_m1_byteenable,
            cell_ddr_1_readdata_in=>avm_m1_readdata,
            cell_ddr_1_wait_request_in=>avm_m1_waitrequest,

            -- Indication
            indication_avail_out=>interrupt_sender_irq
            );

END bridge_behaviour;
