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

-----
-- Implement the MEM stage of the MIPS pipeline.
-- Refer to http://en.wikipedia.org/wiki/MIPS_instruction_set for more information
-- on MIPS pipeline
-----

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;

ENTITY mcore_mem IS
    PORT(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        --- Input from EXE stage
        SIGNAL result_in        : IN mregister_t;
        SIGNAL z_in             : IN mregister_t;
        SIGNAL z_addr_in        : IN mcore_regno_t;
        SIGNAL mem_opcode_in    : IN mcore_mem_funct_t;
        SIGNAL load_in          : IN STD_LOGIC;
        SIGNAL store_in         : IN STD_LOGIC;
        SIGNAL wb_in            : IN STD_LOGIC;
        -- Output to memory 
        SIGNAL mem_wren_out     : OUT STD_LOGIC;
        SIGNAL mem_rden_out     : OUT STD_LOGIC;
        SIGNAL mem_addr_out     : OUT STD_LOGIC_VECTOR(mcore_mem_depth_c-1 downto 0);
        SIGNAL mem_readdata_in  : IN mregister_t;
        SIGNAL mem_writedata_out: OUT mregister_t;
        SIGNAL mem_byteena_out  : OUT STD_LOGIC_VECTOR(mregister_byte_width_c-1 downto 0);
        -- Output to next stage
        SIGNAL wb_addr_out      : OUT mcore_regno_t;
        SIGNAL wb_data_out      : OUT mregister_t;
        SIGNAL wb_ena_out       : OUT STD_LOGIC;
        -- HARZARD
        SIGNAL hazard_data_out  : OUT mregister_t;
        SIGNAL hazard_addr_out  : OUT mcore_regno_t;
        SIGNAL hazard_ena_out   : OUT STD_LOGIC;

        SIGNAL stall_addr_out   : OUT mcore_regno_t;
        SIGNAL stall_ena_out    : OUT STD_LOGIC;

        SIGNAL freeze_in        : IN STD_LOGIC
    );
END mcore_mem;

ARCHITECTURE behaviour OF mcore_mem IS
SIGNAL z_addr_r:mcore_regno_t;
SIGNAL z_r:mregister_t;
SIGNAL store_r:STD_LOGIC;
SIGNAL load_r:STD_LOGIC;
SIGNAL wb_r:STD_LOGIC;
SIGNAL result_r:mregister_t;
SIGNAL mem_opcode_r:mcore_mem_funct_t;
--SIGNAL data:mregister_t;
SIGNAL mem_addr_r:STD_LOGIC_VECTOR(1 downto 0);
BEGIN

-- Produce stall signals...
stall_addr_out <= z_addr_in;
stall_ena_out <= wb_in and load_in;

-- Produce harzard signals....
hazard_data_out <= result_in;
hazard_addr_out <= z_addr_in;
hazard_ena_out <= wb_in and (not load_in);

-- Output to MEM unit
mem_addr_out <= result_in(mcore_mem_depth_c+1 downto 2);
mem_wren_out <= store_in;
mem_rden_out <= load_in;

-- Output to WRITEBACK stage
--data <= result_r when load_r='0' else mem_readdata_in;
wb_addr_out <= z_addr_r;
wb_ena_out <= wb_r;

---------
-- Realign memory read data before storing to register
-- Perform 32bit/16bit/8bit translation
---------
process(mem_opcode_r,result_r,mem_readdata_in,mem_addr_r)
begin
case mem_opcode_r is
    when mcore_mem_funct_lw_c=> -- load word
        -- Take the whole 32 bit value
        wb_data_out <= mem_readdata_in;
    when mcore_mem_funct_lhw_c=>
        if mem_addr_r(1)='0' then
            -- Take upper 16 bit value and then sign extended
            wb_data_out(15 downto 0) <= mem_readdata_in(31 downto 16);
            wb_data_out(31 downto 16) <= (others=>mem_readdata_in(31));
        else
            -- Take lower 16 bite and then sign extended
            wb_data_out(15 downto 0) <= mem_readdata_in(15 downto 0);
            wb_data_out(31 downto 16) <= (others=>mem_readdata_in(15));
        end if;
    when mcore_mem_funct_lhwu_c=>
        if mem_addr_r(1)='0' then
            -- Take upper 16 bit value and then sign extended
            wb_data_out(15 downto 0) <= mem_readdata_in(31 downto 16);
            wb_data_out(31 downto 16) <= (others=>'0');
        else
            -- Take lower 16 but value with no sign 
            wb_data_out(15 downto 0) <= mem_readdata_in(15 downto 0);
            wb_data_out(31 downto 16) <= (others=>'0');
        end if;
    when mcore_mem_funct_lb_c=>
        if mem_addr_r="11" then
            -- Take first byte and then sign extended
            wb_data_out(7 downto 0) <= mem_readdata_in(7 downto 0);
            wb_data_out(31 downto 8) <= (others=>mem_readdata_in(7));
        elsif mem_addr_r="10" then
            -- Take second byte and then sign extended
            wb_data_out(7 downto 0) <= mem_readdata_in(15 downto 8);
            wb_data_out(31 downto 8) <= (others=>mem_readdata_in(15));
        elsif mem_addr_r="01" then
            -- Take third byte and then sign extended
            wb_data_out(7 downto 0) <= mem_readdata_in(23 downto 16);
            wb_data_out(31 downto 8) <= (others=>mem_readdata_in(23));
        else
            -- Take fourth byte and then sign extended
            wb_data_out(7 downto 0) <= mem_readdata_in(31 downto 24);
            wb_data_out(31 downto 8) <= (others=>mem_readdata_in(31));
        end if;
    when mcore_mem_funct_lbu_c =>
        if mem_addr_r="11" then
            -- Take first byte and set to zero the reset
            wb_data_out(7 downto 0) <= mem_readdata_in(7 downto 0);
            wb_data_out(31 downto 8) <= (others=>'0');
        elsif mem_addr_r="10" then
            -- Take second byte and set to zero the reset
            wb_data_out(7 downto 0) <= mem_readdata_in(15 downto 8);
            wb_data_out(31 downto 8) <= (others=>'0');
        elsif mem_addr_r="01" then
            -- Take third byte and set to zero the reset
            wb_data_out(7 downto 0) <= mem_readdata_in(23 downto 16);
            wb_data_out(31 downto 8) <= (others=>'0');
        else
            -- Take fourth byte and set to zero the reset
            wb_data_out(7 downto 0) <= mem_readdata_in(31 downto 24);
            wb_data_out(31 downto 8) <= (others=>'0');
        end if;
    when others=>
        wb_data_out <= result_r;
end case;
end process;

---------
-- Generate memory write byte enable.
-- This is required for 16 and 8 bit memory write operation
---------
process(mem_opcode_in,z_in,result_in)
begin
case mem_opcode_in is
    when mcore_mem_funct_sw_c=>
        -- Write 32 bit value
        mem_writedata_out <= z_in;
        mem_byteena_out <= (others=>'1');
    when mcore_mem_funct_sh_c=>
        if result_in(1)='1' then
            -- Write lo 16 bit value
            mem_writedata_out <= z_in;
            -- WARNING Hardcoded to mregister_byte_width_c=4
            mem_byteena_out <= "0011";
        else
            -- Write hi 16 bit value
            mem_writedata_out(31 downto 16) <= z_in(15 downto 0);
            mem_writedata_out(15 downto 0) <= (others=>'0');
            -- WARNING Hardcoded to mregister_byte_width_c=4
            mem_byteena_out <= "1100";
        end if;
    when mcore_mem_funct_sb_c =>
        if result_in(1 downto 0)="11" then
            -- Write first byte 
            mem_writedata_out(7 downto 0) <= z_in(7 downto 0);
            mem_writedata_out(15 downto 8) <= (others=>'0');
            mem_writedata_out(23 downto 16) <= (others=>'0');
            mem_writedata_out(31 downto 24) <= (others=>'0');
            mem_byteena_out <= "0001";
        elsif result_in(1 downto 0)="10" then
            mem_writedata_out(7 downto 0) <= (others=>'0');
            mem_writedata_out(15 downto 8) <= z_in(7 downto 0);
            mem_writedata_out(23 downto 16) <= (others=>'0');
            mem_writedata_out(31 downto 24) <= (others=>'0');
            mem_byteena_out <= "0010";
        elsif result_in(1 downto 0)="01" then
            mem_writedata_out(7 downto 0) <= (others=>'0');
            mem_writedata_out(15 downto 8) <= (others=>'0');
            mem_writedata_out(23 downto 16) <= z_in(7 downto 0);
            mem_writedata_out(31 downto 24) <= (others=>'0');
            mem_byteena_out <= "0100";
        else
            mem_writedata_out(7 downto 0) <= (others=>'0');
            mem_writedata_out(15 downto 8) <= (others=>'0');
            mem_writedata_out(23 downto 16) <= (others=>'0');
            mem_writedata_out(31 downto 24) <= z_in(7 downto 0);
            mem_byteena_out <= "1000";
        end if;
    when others=>
        mem_writedata_out <= (others=>'0');
        mem_byteena_out <= "0000";
end case;
end process;

process(clock_in,reset_in)    
begin
if reset_in='0' then
    mem_opcode_r <= (others=>'0');
    z_addr_r <= (others=>'0');
    z_r <= (others=>'0');
    store_r <= '0';
    load_r <= '0';
    wb_r <= '0';
    result_r <= (others=>'0');
    mem_addr_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        mem_addr_r <= result_in(1 downto 0);
        result_r <= result_in;
        z_addr_r <= z_addr_in;
        z_r <= z_in;
        load_r <= load_in;
        store_r <= store_in;
        wb_r <= wb_in and (not freeze_in);
        mem_opcode_r <= mem_opcode_in;
    end if;
end if;
end process;
END behaviour;
