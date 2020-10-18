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
-- Implement the FETCH stage of the MIPS pipeline.
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
LIBRARY altera_mf;
USE altera_mf.all;

-------------
-- FETCH stage
-- Retrieve instruction from ROM
-- Do some preliminary decoding to speed up DECODER stage. In particular, decode register address
-- to be fetched in the DECODER stage
-- Process JUMP and flush second instruction after a JUMP inorder to remain compatible with MIPS I
--------------
ENTITY mcore_fetch IS
    PORT(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        -- Output instruction to next stage
        SIGNAL instruction_out  : OUT STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);
        SIGNAL pseudo_out       : OUT mcore_decoder_pseudo_t;
        SIGNAL pc_out           : OUT STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
        
        SIGNAL rega_addr_out    : OUT mcore_regno_t; 
        SIGNAL regb_addr_out    : OUT mcore_regno_t;
        SIGNAL rega_ena_out     : OUT STD_LOGIC; 
        SIGNAL regb_ena_out     : OUT STD_LOGIC;

        -- Output to ROM
        SIGNAL rom_addr_out     : OUT STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
        SIGNAL rom_data_in      : IN STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);
        -- Input from decoder stage to jump to new address....
        SIGNAL jump_in          : IN STD_LOGIC;
        SIGNAL jump_addr_in     : IN STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
        -- STALL
        SIGNAL stall_in         : IN STD_LOGIC;
        SIGNAL freeze_in        : IN STD_LOGIC
    );
END mcore_fetch;

ARCHITECTURE behaviour OF mcore_fetch IS
SIGNAL pc_r:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL next_pc:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL rom_data_r:mregister_t;
SIGNAL rom_addr:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL rom_addr_r:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL i_opcode:mcore_opcode_t;
SIGNAL i_rs:mcore_regno_t;
SIGNAL i_rt:mcore_regno_t;
SIGNAL i_funct:mcore_funct_t;
SIGNAL pseudo_r:mcore_decoder_pseudo_t;
SIGNAL rega_addr_r:mcore_regno_t;
SIGNAL rega_ena_r:STD_LOGIC;
SIGNAL regb_addr_r:mcore_regno_t;
SIGNAL regb_ena_r:STD_LOGIC;
SIGNAL rega_addr:mcore_regno_t;
SIGNAL rega_ena:STD_LOGIC;
SIGNAL regb_addr:mcore_regno_t;
SIGNAL regb_ena:STD_LOGIC;
SIGNAL pseudo:mcore_decoder_pseudo_t;
BEGIN

------
-- Output signals
------

rom_addr_out <= rom_addr;
instruction_out <= rom_data_r;
pseudo_out <= pseudo_r;
pc_out <= rom_addr_r;
rega_addr_out <= rega_addr_r;
rega_ena_out <= rega_ena_r;
regb_addr_out <= regb_addr_r;
regb_ena_out <= regb_ena_r;

-----------
-- Decode the parameter fields for the instruction
-- Decode which registers are required for next instruction, DECODER stage
-- can immediately try to fetch the register values. Hence better performance
------------

i_opcode <= rom_data_in(mcore_instruction_opcode_hi_c downto mcore_instruction_opcode_lo_c);
i_rs <= rom_data_in(mcore_instruction_rs_hi_c downto mcore_instruction_rs_lo_c);
i_rt <= rom_data_in(mcore_instruction_rt_hi_c downto mcore_instruction_rt_lo_c);
i_funct <= rom_data_in(mcore_instruction_funct_hi_c downto mcore_instruction_funct_lo_c);

process(i_opcode,i_rs,i_rt,i_funct)
begin
case i_opcode is
when "100011"|"100001"|"100101"|"100000"|"100100"=>
    -- LOAD
    rega_addr <= i_rs;
    rega_ena <= '1';
    regb_addr <= (others=>'0');
    regb_ena <= '0';
    pseudo <= mcore_decoder_pseudo_load_c;
when "101011"|"101001"|"101000" =>
    -- STORE
    rega_addr <= i_rs;
    rega_ena <= '1';
    regb_addr <= i_rt;
    regb_ena <= '1';
    pseudo <= mcore_decoder_pseudo_store_c;
when "000100" =>
    -- be C
    rega_addr <= i_rs;
    rega_ena <= '1';
    regb_addr <= i_rt;
    regb_ena <= '1';
    pseudo <= mcore_decoder_pseudo_be_c;
when "000101" =>
    -- bne C
    rega_addr <= i_rs;
    rega_ena <= '1';
    regb_addr <= i_rt;
    regb_ena <= '1';
    pseudo <= mcore_decoder_pseudo_bne_c;
when "000001" |  -- BGEZ|BGEZAL|BLTZ|BLTZAL 
     "000111" | -- BGTZ 
     "000110" => -- BLEZ 
    rega_addr <= i_rs;
    rega_ena <= '1';
    regb_addr <= (others=>'0');
    regb_ena <= '0';
    pseudo <= mcore_decoder_pseudo_bgx_c;
when "000011" =>
    -- jal
    rega_addr <= (others=>'0');
    rega_ena <= '0';
    regb_addr <= (others=>'0');
    regb_ena <= '0';
    pseudo <= mcore_decoder_pseudo_jal_c;
when "000010" =>
    -- JUMP C
    rega_addr <= (others=>'0');
    rega_ena <= '0';
    regb_addr <= (others=>'0');
    regb_ena <= '0';
    pseudo <= mcore_decoder_pseudo_jump_c;
when "001111" =>
    rega_addr <= (others=>'0');
    rega_ena <= '0';
    regb_addr <= (others=>'0');
    regb_ena <= '0';            
    pseudo <= mcore_decoder_pseudo_lui_c;
when "000000" =>
    if i_funct="000000" or i_funct="000010" or i_funct="000011" then
        -- $d = $t << SHAMT
        -- $d = $t >> SHAMT
        -- $d = $t >> SHAMT (SIGN EXTENDED)
        rega_addr <= (others=>'0');
        rega_ena <= '0';
        regb_addr <= i_rt;
        regb_ena <= '1';        
        pseudo <= mcore_decoder_pseudo_shft_c;
    elsif i_funct="000100" or i_funct="000110" or i_funct="000111" then
        -- $d = $t << $s
        -- $d = $t >> $s
        -- $d = $t >> $s (SIGN EXTENDED)
        rega_addr <= i_rs;
        rega_ena <= '1';
        regb_addr <= i_rt;
        regb_ena <= '1';
        pseudo <= mcore_decoder_pseudo_shft2_c;
    elsif i_funct="010000" then
        -- mfhi (Load HI)
        rega_addr <= (others=>'0');
        rega_ena <= '0';
        regb_addr <= (others=>'0');
        regb_ena <= '0';
        pseudo <= mcore_decoder_pseudo_mfhi_c;
    elsif i_funct="010010" then
        --mflo (Load LO)
        rega_addr <= (others=>'0');
        rega_ena <= '0';
        regb_addr <= (others=>'0');
        regb_ena <= '0';    
        pseudo <= mcore_decoder_pseudo_mflo_c;
    elsif i_funct="001000" then
        -- jr[$rs]
        rega_addr <= i_rs;
        rega_ena <= '1';
        regb_addr <= (others=>'0');
        regb_ena <= '0';
        pseudo <= mcore_decoder_pseudo_jr_c;
    elsif i_funct="001001" then
        -- jalr[$rs]
        rega_addr <= i_rs;
        rega_ena <= '1';
        regb_addr <= (others=>'0');
        regb_ena <= '0';
        pseudo <= mcore_decoder_pseudo_jalr_c;
--    elsif i_funct="001100" then
--        -- SYSCALL
--        rega_addr <= (others=>'0');
--        rega_ena <= '0';
--        regb_addr <= (others=>'0');
--        regb_ena <= '0';
--        pseudo <= mcore_decoder_pseudo_syscall_c;
    else
        -- ARITHMETIC
        -- $rd=$rs op $rt
        rega_addr <= i_rs;
        rega_ena <= '1';
        regb_addr <= i_rt;
        regb_ena <= '1';
        pseudo <= mcore_decoder_pseudo_arithmetic_c;
    end if;    
when others=>
    -- ARITHMETIC IMMEDIATE
    -- $rt=$rs op C
    rega_addr <= i_rs;
    rega_ena <= '1';
    regb_addr <= (others=>'0');
    regb_ena <= '0';
    pseudo <= mcore_decoder_pseudo_arithmetic_imm_c;
end case;
end process;


----------
-- Latch in the next instuction for DECODE stage
-- Move to next instruction if there is no JUMP condition
-- Otherwise goto the JUMP address
----------

next_pc <= std_logic_vector(unsigned(pc_r)+1);

process(freeze_in,stall_in,pc_r,jump_in,next_pc,jump_addr_in)
begin
if freeze_in='0' and stall_in='0' then
    if jump_in='0' then
        rom_addr <= next_pc;
    else
        rom_addr <= jump_addr_in;
    end if;
else
    rom_addr <= pc_r;
end if;
end process;

process(clock_in,reset_in)    
begin
if reset_in='0' then
    pc_r <= (others=>'0');
    rom_data_r <= (others=>'0');
    rom_addr_r <= (others=>'0');
    rega_addr_r <= (others=>'0');
    rega_ena_r <= '0';
    regb_addr_r <= (others=>'0');
    regb_ena_r <= '0';
    pseudo_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        if freeze_in='0' and stall_in='0' then
            pc_r <= rom_addr;
            rom_addr_r <= pc_r;
            if jump_in='0' then
                rom_data_r <= rom_data_in;
                rega_addr_r <= rega_addr;
                rega_ena_r <= rega_ena;
                regb_addr_r <= regb_addr;
                regb_ena_r <= regb_ena;
                pseudo_r <= pseudo;
            else
                rom_data_r <= (others=>'0');
                rega_addr_r <= (others=>'0');
                rega_ena_r <= '0';
                regb_addr_r <= (others=>'0');
                regb_ena_r <= '0';
                pseudo_r <= (others=>'0');
            end if;
        end if;    
    end if;
end if;
end process;
END behaviour;