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

-------
-- Implement MCORE register file
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;

ENTITY mcore_register IS
    PORT(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        -- READ interface
        SIGNAL reada_addr_in    : IN mcore_regno_t;
        SIGNAL readb_addr_in    : IN mcore_regno_t;
        SIGNAL reada_data_out   : OUT mregister_t;
        SIGNAL readb_data_out   : OUT mregister_t;
        -- WRITE interface
        SIGNAL wren_in          : IN STD_LOGIC;
        SIGNAL write_addr_in    : IN mcore_regno_t;
        SIGNAL write_data_in    : IN mregister_t;

        SIGNAL hazard1_data_in  : IN mregister_t;
        SIGNAL hazard1_addr_in  : IN mcore_regno_t;
        SIGNAL hazard1_ena_in   : IN STD_LOGIC;

        SIGNAL hazard2_data_in  : IN mregister_t;
        SIGNAL hazard2_addr_in  : IN mcore_regno_t;
        SIGNAL hazard2_ena_in   : IN STD_LOGIC
    );
END mcore_register;

ARCHITECTURE behaviour OF mcore_register IS
SIGNAL registers_r:mregisters_t(mcore_num_register_c-1 downto 0);
SIGNAL rega:mregister_t;
SIGNAL regb:mregister_t;
BEGIN

rega <= registers_r(to_integer(unsigned(reada_addr_in)));
regb <= registers_r(to_integer(unsigned(readb_addr_in)));

------
-- Check for harzard conflicts 
-- Harzard occurs when there is a newer updates of register values
-- down the MIPS pipeline.
-- When this happens, use the newer register values from harzard 
-- detection 
------

process(reada_addr_in,hazard1_ena_in,hazard1_addr_in,hazard1_data_in,
        hazard2_ena_in,hazard2_addr_in,
        wren_in,write_addr_in,registers_r,write_data_in,
        hazard2_data_in,readb_addr_in,rega,regb)
begin
if hazard1_ena_in='1' and hazard1_addr_in=reada_addr_in then
    reada_data_out <= hazard1_data_in;
elsif hazard2_ena_in='1' and hazard2_addr_in=reada_addr_in then
    reada_data_out <= hazard2_data_in;
elsif ((wren_in='1') and (write_addr_in=reada_addr_in)) then
    reada_data_out <= write_data_in;
else
    reada_data_out <= rega;
end if;
if hazard1_ena_in='1' and hazard1_addr_in=readb_addr_in then
   readb_data_out <= hazard1_data_in;
elsif hazard2_ena_in='1' and hazard2_addr_in=readb_addr_in then
    readb_data_out <= hazard2_data_in;
elsif ((wren_in='1') and (write_addr_in=readb_addr_in)) then
    readb_data_out <= write_data_in;
else
    readb_data_out <= regb;
end if;
end process;

process(clock_in,reset_in)    
begin
if reset_in='0' then
    registers_r <= (others=>(others=>'0'));
else
    if clock_in'event and clock_in='1' then
        if wren_in='1' then
            registers_r(to_integer(unsigned(write_addr_in))) <= write_data_in;
        end if;
    end if;
end if;
end process;
END behaviour;

