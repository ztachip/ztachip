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
-- This module implements clock crossing between host interface bus and mcore/pcore
-- clock domain
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY avalon_lw_adapter IS
    port(
        SIGNAL hclock_in              : IN STD_LOGIC;
        SIGNAL mclock_in              : IN STD_LOGIC;
        SIGNAL pclock_in              : IN STD_LOGIC;
        SIGNAL hreset_in              : IN STD_LOGIC;
        SIGNAL mreset_in              : IN STD_LOGIC;
        SIGNAL preset_in              : IN STD_LOGIC;
        
        -- Interface with host
        
        SIGNAL host_addr_in           : IN std_logic_vector(avalon_bus_width_c-1 downto 0);
        SIGNAL host_write_in          : IN STD_LOGIC;
        SIGNAL host_read_in           : IN STD_LOGIC;
        SIGNAL host_writedata_in      : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL host_readdata_out      : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL host_waitrequest_out   : OUT STD_LOGIC;
        
        -- Interface with MCORE
        
        SIGNAL m_addr_out             : OUT std_logic_vector(avalon_bus_width_c-1 downto 0);
        SIGNAL m_write_out            : OUT STD_LOGIC;
        SIGNAL m_read_out             : OUT STD_LOGIC;
        SIGNAL m_writedata_out        : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL m_readdata_in          : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL m_readdatavalid_in     : IN STD_LOGIC;
        
        -- Interface with PCLOCK
        
        SIGNAL p_addr_out             : OUT std_logic_vector(avalon_bus_width_c-1 downto 0);
        SIGNAL p_write_out            : OUT STD_LOGIC;
        SIGNAL p_read_out             : OUT STD_LOGIC;
        SIGNAL p_writedata_out        : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL p_readdata_in          : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL p_readdatavalid_in     : IN STD_LOGIC
        );        
END avalon_lw_adapter;

ARCHITECTURE avalon_lw_adapter_behaviour of avalon_lw_adapter is

SIGNAL read:std_logic;
SIGNAL write:std_logic;
SIGNAL ready1:std_logic;
SIGNAL ready2:std_logic;
SIGNAL readdata1:std_logic_vector(host_width_c-1 DOWNTO 0);
SIGNAL readdatavalid1:std_logic;
SIGNAL readdata2:std_logic_vector(host_width_c-1 DOWNTO 0);
SIGNAL readdatavalid2:std_logic;
SIGNAL readdata_r:std_logic_vector(host_width_c-1 DOWNTO 0);
SIGNAL readdatavalid_r:std_logic;
SIGNAL waitresponse:std_logic;
SIGNAL waitresponse_r:std_logic;
BEGIN

----
-- FIFO for data flow from avalon bus to ztachip internal
---

host_readdata_out <= readdata_r when readdatavalid_r='1' else (others=>'Z');

avalon_lw_i0 : avalon_lw
    PORT MAP (
       hclock_in => hclock_in,
       clock_in => mclock_in,
       hreset_in => hreset_in,
       reset_in => mreset_in,
    
       -- Interface with host
    
       host_addr_in => host_addr_in,
       host_write_in => write,
       host_read_in => read,
       host_writedata_in => host_writedata_in,
       host_readdata_out => readdata1,
       host_readdatavalid_out => readdatavalid1,
       host_ready_out => ready1,
    
       -- Interface with MCORE
    
       addr_out => m_addr_out,
       write_out => m_write_out,
       read_out => m_read_out,
       writedata_out => m_writedata_out,
       readdata_in => m_readdata_in,
       readdatavalid_in => m_readdatavalid_in
       );

avalon_lw_i1 : avalon_lw
   PORT MAP (
       hclock_in => hclock_in,
       clock_in => pclock_in,
       hreset_in => hreset_in,
       reset_in => preset_in,
   
       -- Interface with host
   
       host_addr_in => host_addr_in,
       host_write_in => write,
       host_read_in => read,
       host_writedata_in => host_writedata_in,
       host_readdata_out => readdata2,
       host_readdatavalid_out => readdatavalid2,
       host_ready_out => ready2,
   
       -- Interface with MCORE
   
       addr_out => p_addr_out,
       write_out => p_write_out,
       read_out => p_read_out,
       writedata_out => p_writedata_out,
       readdata_in => p_readdata_in,
       readdatavalid_in => p_readdatavalid_in
       );

process(waitresponse_r,ready1,ready2,host_read_in,host_write_in,readdatavalid1,readdatavalid2)
begin
if waitresponse_r='0' then
   -- idle state. Ready to take new bus commands
   if ready1='0' or ready2='0' then
      host_waitrequest_out <= (host_read_in or host_write_in);
      waitresponse <= '0';
      read <= '0';
      write <= '0';
   else
      if host_read_in='1' then
         host_waitrequest_out <= '1';
         waitresponse <= '1';
         read <= '1';
         write <= '0';
      elsif host_write_in='1' then
         host_waitrequest_out <= '0';
         waitresponse <= '0';
         read <= '0';
         write <= '1';
      else
         host_waitrequest_out <= '0';
         waitresponse <= '0';
         read <= '0';
         write <= '0';
      end if;
   end if;
else
   read <= '0';
   write <= '0';
   if readdatavalid1='1' or readdatavalid2='1' then
      host_waitrequest_out <= '0';
      waitresponse <= '0';
   else
      host_waitrequest_out <= '1';
      waitresponse <= '1';
   end if;
end if;
end process;

process(hclock_in,hreset_in)
begin
   if hreset_in = '0' then
      waitresponse_r <= '0';
      readdata_r <= (others=>'0');
      readdatavalid_r <= '0';
   else
      if hclock_in'event and hclock_in='1' then
         waitresponse_r <= waitresponse;
         if readdatavalid1='1' then
            readdata_r <= readdata1;
         else
            readdata_r <= readdata2;
         end if;
         readdatavalid_r <= readdatavalid1 or readdatavalid2;
      end if;
   end if;
end process;

END avalon_lw_adapter_behaviour;
