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

------
-- Perform system configuration/control via register access from host
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;


ENTITY sys_config IS
    port(   
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;    
        SIGNAL bus_addr_in          : IN register_addr_t;
        SIGNAL bus_write_in         : IN STD_LOGIC;
        SIGNAL bus_read_in          : IN STD_LOGIC;
        SIGNAL bus_writedata_in     : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdata_out     : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL bus_readdatavalid_out: OUT STD_LOGIC;

        -- Generate soft reset
        SIGNAL sreset_out           : OUT STD_LOGIC
        );
END sys_config;

ARCHITECTURE sys_config_behaviour of sys_config IS 
SIGNAL wregno: unsigned(register_t'length-1 downto 0);
SIGNAL sreset_r:STD_LOGIC;
BEGIN

wregno <= unsigned(bus_addr_in(register_t'length-1 downto 0));

bus_readdata_out <= (others=>'Z');

bus_readdatavalid_out <= '0';
sreset_out <= sreset_r;
 
---------
--- Process register access from host
----------

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        sreset_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            if bus_write_in='1' then
                if wregno=to_unsigned(register_soft_reset_c,wregno'length) then
                    -- Perform softreset
                    sreset_r <= bus_writedata_in(0);
                end if;
            end if;
        end if;
    end if;
end process;
END sys_config_behaviour;

