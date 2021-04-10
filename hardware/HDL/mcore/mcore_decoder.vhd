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

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;

----------
-- Implements DECODER stage of the MIPS-I pipeline. For more info, refer to 
-- http://en.wikipedia.org/wiki/MIPS_instruction_set 
-- Decode instructions
-- Fetch register values required for instructions
-- Process JUMP/BRANCH instructions
----------

ENTITY mcore_decoder IS
    PORT(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        -- Input from FETCH stage
        SIGNAL instruction_in   : IN STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);
        SIGNAL pseudo_in        : IN mcore_decoder_pseudo_t;
        SIGNAL pc_in            : IN STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);

        SIGNAL rega_addr_in     : IN mcore_regno_t; 
        SIGNAL regb_addr_in     : IN mcore_regno_t;
        SIGNAL rega_ena_in      : IN STD_LOGIC; 
        SIGNAL regb_ena_in      : IN STD_LOGIC;

        -- Output to EXE stage
        SIGNAL x_out            : OUT mregister_t;
        SIGNAL y_out            : OUT mregister_t;
        SIGNAL z_out            : OUT mregister_t;
        SIGNAL shamt_out        : OUT mcore_shamt_t;
        SIGNAL z_addr_out       : OUT mcore_regno_t;
        SIGNAL opcode_out       : OUT mcore_alu_funct_t;
        SIGNAL pseudo_out       : OUT mcore_exe_pseudo_t;
        SIGNAL mem_opcode_out   : OUT mcore_mem_funct_t;
        SIGNAL load_out         : OUT STD_LOGIC;
        SIGNAL store_out        : OUT STD_LOGIC;
        SIGNAL wb_out           : OUT STD_LOGIC;
        -- Feedback to FETCH stage
        SIGNAL jump_out         : OUT STD_LOGIC;
        SIGNAL jump_addr_out    : OUT STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
        -- Interface to register file
        SIGNAL rega_addr_out    : OUT mcore_regno_t; 
        SIGNAL regb_addr_out    : OUT mcore_regno_t;
        SIGNAL rega_ena_out     : OUT STD_LOGIC; 
        SIGNAL regb_ena_out     : OUT STD_LOGIC;
        SIGNAL rega_in          : IN mregister_t;
        SIGNAL regb_in          : IN mregister_t;
        -- LOAD LO/HI request
        SIGNAL load_exe2_out    : OUT STD_LOGIC;
        -- STALL request
        SIGNAL stall_in         : IN STD_LOGIC;
        SIGNAL freeze_in        : IN STD_LOGIC
    );
END mcore_decoder;

ARCHITECTURE behaviour OF mcore_decoder IS
SIGNAL i_opcode:mcore_opcode_t;
SIGNAL i_rs:mcore_regno_t;
SIGNAL i_rt:mcore_regno_t;
SIGNAL i_rd:mcore_regno_t;
SIGNAL i_shamt:mcore_shamt_t;
SIGNAL i_funct:mcore_funct_t;
SIGNAL i_imm:mcore_imm_t;
SIGNAL i_address:mcore_address_t;
SIGNAL imm:mregister_t;
SIGNAL x:mregister_t;
SIGNAL y:mregister_t;
SIGNAL z:mregister_t;
SIGNAL z_addr:mcore_regno_t;
SIGNAL opcode:mcore_alu_funct_t;
SIGNAL pseudo:mcore_exe_pseudo_t;
SIGNAL pseudo_r:mcore_exe_pseudo_t;
SIGNAL mem_opcode:mcore_mem_funct_t;
SIGNAL load:STD_LOGIC;
SIGNAL store:STD_LOGIC;
SIGNAL wb:STD_LOGIC;
SIGNAL jump_oc:mcore_opcode_t;
SIGNAL jump_oc2:mcore_regno_t;
SIGNAL jump:STD_LOGIC;
SIGNAL jump_addr:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL jump_base:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL x_r:mregister_t;
SIGNAL y_r:mregister_t;
SIGNAL z_r:mregister_t;
SIGNAL z_addr_r:mcore_regno_t;
SIGNAL opcode_r:mcore_alu_funct_t;
SIGNAL mem_opcode_r:mcore_mem_funct_t;
SIGNAL load_r:STD_LOGIC;
SIGNAL store_r:STD_LOGIC;
SIGNAL wb_r:STD_LOGIC;
SIGNAL jump_addr_r:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL next_pc:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL next_next_pc:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL jump_x_r:mregister_t;
SIGNAL jump_y_r:mregister_t;
SIGNAL jump_oc_r:std_logic_vector(2 downto 0);
SIGNAL shamt_r:mcore_shamt_t;
SIGNAL x_equal_y:STD_LOGIC;
SIGNAL x_equal_zero:STD_LOGIC;

-- Jump instruction pseudo-opcode

subtype jump_pseudo_t is std_logic_vector(2 downto 0);

constant jump_pseudo_none_c                    :jump_pseudo_t:="000";
constant jump_pseudo_beq_c                     :jump_pseudo_t:="001";
constant jump_pseudo_bne_c                     :jump_pseudo_t:="010";
constant jump_pseudo_bgez_bgezal_c             :jump_pseudo_t:="011";
constant jump_pseudo_btlz_bltzal_c             :jump_pseudo_t:="100";
constant jump_pseudo_bgtz_c                    :jump_pseudo_t:="101";
constant jump_pseudo_blez_c                    :jump_pseudo_t:="110";
constant jump_pseudo_unconditional_c           :jump_pseudo_t:="111";

BEGIN

---------
-- Extract all fields defined in MIPS-I instruction set
---------

i_opcode <= instruction_in(mcore_instruction_opcode_hi_c downto mcore_instruction_opcode_lo_c);
i_rs <= instruction_in(mcore_instruction_rs_hi_c downto mcore_instruction_rs_lo_c);
i_rt <= instruction_in(mcore_instruction_rt_hi_c downto mcore_instruction_rt_lo_c);
i_rd <= instruction_in(mcore_instruction_rd_hi_c downto mcore_instruction_rd_lo_c);
i_shamt <= instruction_in(mcore_instruction_shamt_hi_c downto mcore_instruction_shamt_lo_c);
i_funct <= instruction_in(mcore_instruction_funct_hi_c downto mcore_instruction_funct_lo_c);
i_imm <= instruction_in(mcore_instruction_imm_hi_c downto mcore_instruction_imm_lo_c);
i_address <= instruction_in(mcore_instruction_address_hi_c downto mcore_instruction_address_lo_c);

-- Sign extended the IMM field

imm(mcore_imm_t'length-1 downto 0) <= i_imm;
imm(mregister_width_c-1 downto mcore_imm_t'length) <= (others=>imm(mcore_imm_t'length-1));

--------
-- Output to register file for register loading
--------
 
rega_addr_out <= rega_addr_in; 
regb_addr_out <= regb_addr_in;
rega_ena_out <= rega_ena_in; 
regb_ena_out <= regb_ena_in;

--------
-- Output to EXE stage
--------

x_out <= x_r;
y_out <= y_r;
z_out <= z_r;
z_addr_out <= z_addr_r;
opcode_out <= opcode_r;
pseudo_out <= pseudo_r;
mem_opcode_out <= mem_opcode_r;
load_out <= load_r;
store_out <= store_r;
wb_out <= wb_r;
shamt_out <= shamt_r;

-------
-- Calculate next instruction address
-------

next_pc <= std_logic_vector(unsigned(pc_in)+to_unsigned(1,pc_in'length));
next_next_pc <= std_logic_vector(unsigned(pc_in)+to_unsigned(2,pc_in'length));

--------
-- Decode instruction
-- Generate control signals and data for next stage
--------

process(pseudo_in,i_opcode,rega_in,regb_in,i_funct,i_rs,i_rt,i_rd,imm,next_pc,i_address,i_shamt,next_next_pc)
begin
case pseudo_in is
when mcore_decoder_pseudo_load_c=>
     -- LOAD
    opcode <= mcore_alu_funct_add_c;
    mem_opcode <= i_opcode;
    x <= rega_in;
    y <= imm;
    z <= (others=>'0');
    z_addr <= i_rt; 
    load <= '1';
    store <= '0';
    wb <= '1';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');
    load_exe2_out <= '0';    
when mcore_decoder_pseudo_store_c =>
    -- STORE
    opcode <= mcore_alu_funct_add_c;
    mem_opcode <= i_opcode;
    x <= rega_in;
    y <= imm;
    z <= regb_in;
    z_addr <= (others=>'0'); 
    load <= '0';
    store <= '1';
    wb <= '0';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');
    load_exe2_out <= '0';
when mcore_decoder_pseudo_be_c =>
    -- OC|FUNC|RS|RT|C
    -- be C
    opcode <= (others=>'0');
    mem_opcode <= (others=>'0');
    x <= (others=>'0');
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= (others=>'0'); 
    load <= '0';
    store <= '0';
    wb <= '0';
    jump <= '1';
    jump_oc <= i_opcode;
    jump_oc2 <= (others=>'0');
    jump_addr <= imm(jump_addr'length-1 downto 0);
    jump_base <= next_pc;
    load_exe2_out <= '0';
when mcore_decoder_pseudo_bne_c =>
    -- OC|FUNC|RS|RT|C
    -- bne C
    opcode <= (others=>'0');
    mem_opcode <= (others=>'0');
    x <= (others=>'0');
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= (others=>'0'); 
    load <= '0';
    store <= '0';
    wb <= '0';
    jump <= '1';
    jump_oc <= i_opcode;
    jump_oc2 <= (others=>'0');
    jump_addr <= imm(jump_addr'length-1 downto 0);
    jump_base <= next_pc;
    load_exe2_out <= '0';
when mcore_decoder_pseudo_bgx_c =>
    -- BGEZAL|BLTZAL
    if i_rt = "10001" or i_rt="10000" then
        opcode <= mcore_alu_funct_add_c;
        mem_opcode <= (others=>'0');
        x(1 downto 0) <= (others=>'0');
        x(next_next_pc'length+2-1 downto 2) <= next_next_pc;
        x(x'length-1 downto next_pc'length+2) <= (others=>'0'); 
        y <= (others=>'0');
        z <= (others=>'0');
        z_addr <= std_logic_vector(to_unsigned(mcore_num_register_c-1,z_addr'length)); 
        load <= '0';
        store <= '0';
        wb <= '1';
        jump <= '1';
        jump_oc <= i_opcode;
        jump_oc2 <= i_rt;
        jump_addr <= imm(jump_addr'length-1 downto 0);
        jump_base <= next_pc;
        load_exe2_out <= '0';
    else
        -- BGEZ|BGTZ|BLEZ|BLTZ
        opcode <= (others=>'0');
        mem_opcode <= (others=>'0');
        x <= (others=>'0');
        y <= (others=>'0');
        z <= (others=>'0');
        z_addr <= (others=>'0'); 
        load <= '0';
        store <= '0';
        wb <= '0';
        jump <= '1';
        jump_oc <= i_opcode;
        jump_oc2 <= i_rt;
        jump_addr <= imm(jump_addr'length-1 downto 0);
        jump_base <= next_pc;
        load_exe2_out <= '0';
    end if;
when mcore_decoder_pseudo_jalr_c =>
    -- OC|FUNC|RS|RS|C
    -- jalr[$rs]
    opcode <= mcore_alu_funct_add_c;
    mem_opcode <= (others=>'0');
    x(1 downto 0) <= (others=>'0');
    x(next_next_pc'length+2-1 downto 2) <= next_next_pc;
    x(x'length-1 downto next_pc'length+2) <= (others=>'0'); 
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= i_rd; 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '1';
    jump_oc <= i_funct;
    jump_oc2 <= (others=>'0');
    jump_addr <= rega_in(jump_addr'length+2-1 downto 2);
    jump_base <= (others=>'0');
    load_exe2_out <= '0';
when mcore_decoder_pseudo_jal_c =>
    -- OC|FUNC|RS|RT|C
    -- jal
    opcode <= mcore_alu_funct_add_c;
    mem_opcode <= (others=>'0');
    x(1 downto 0) <= (others=>'0');
    x(next_next_pc'length+2-1 downto 2) <= next_next_pc;
    x(x'length-1 downto next_pc'length+2) <= (others=>'0'); 
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= std_logic_vector(to_unsigned(mcore_num_register_c-1,z_addr'length)); 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '1';
    jump_oc <= i_opcode;
    jump_oc2 <= (others=>'0');
    jump_addr <= i_address(jump_addr'length-1 downto 0);
    jump_base <= (others=>'0');
    load_exe2_out <= '0';
when mcore_decoder_pseudo_jump_c =>
    -- JUMP C
    opcode <= (others=>'0');
    mem_opcode <= (others=>'0');
    x <= (others=>'0');
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= (others=>'0'); 
    load <= '0';
    store <= '0';
    wb <= '0';
    jump <= '1';
    jump_oc <= i_opcode;
    jump_oc2 <= (others=>'0');
    jump_addr <= i_address(jump_addr'length-1 downto 0);
    jump_base <= (others=>'0');
    load_exe2_out <= '0';
when mcore_decoder_pseudo_lui_c =>
    -- lui $t,C $t=C<<16
    opcode <= mcore_alu_funct_sll_c; -- Shift left
    mem_opcode <= (others=>'0');
    x <= std_logic_vector(to_unsigned(16,x'length));
    y <= imm;
    z <= (others=>'0');
    z_addr <= i_rt; 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');    
    load_exe2_out <= '0';        
when mcore_decoder_pseudo_shft_c =>
    -- $d = $t << SHAMT
    -- $d = $t >> SHAMT
    -- $d = $t >> SHAMT (SIGN EXTENDED)
    opcode <= i_funct;
    mem_opcode <= (others=>'0');
    x(i_shamt'length-1 downto 0) <= i_shamt;
    x(x'length-1 downto i_shamt'length) <= (others=>'0');
    y <= regb_in;
    z <= (others=>'0');
    z_addr <= i_rd; 
    load <= '0';
    store <= '0';
    if i_rd /= std_logic_vector(to_unsigned(0,mcore_regno_t'length)) then
        wb <= '1';
    else
        wb <= '0'; -- This must be a NOP
    end if;
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');    
    load_exe2_out <= '0';        
when mcore_decoder_pseudo_shft2_c =>
    -- $d = $t << $s
    -- $d = $t >> $s
    -- $d = $t >> $s (SIGN EXTENDED)
    opcode <= i_funct;
    mem_opcode <= (others=>'0');
    x <= rega_in;
    y <= regb_in;
    z <= (others=>'0');
    z_addr <= i_rd; 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');    
    load_exe2_out <= '0';        
when mcore_decoder_pseudo_mfhi_c =>
    -- mfhi
    opcode <= mcore_alu_funct_mfhi_c;
    mem_opcode <= (others=>'0');
    x <= (others=>'0');
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= i_rd; 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');    
    load_exe2_out <= '1';
when mcore_decoder_pseudo_mflo_c =>
    -- mflo
    opcode <= mcore_alu_funct_mflo_c;
    mem_opcode <= (others=>'0');
    x <= (others=>'0');
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= i_rd; 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');
    load_exe2_out <= '1';
when mcore_decoder_pseudo_jr_c =>
    -- OC|FUNC|RS|RS|C
    -- jr[$rs]
    opcode <= (others=>'0');
    mem_opcode <= (others=>'0');
    x <= (others=>'0');
    y <= (others=>'0');
    z <= (others=>'0');
    z_addr <= (others=>'0'); 
    load <= '0';
    store <= '0';
    wb <= '0';
    jump <= '1';
    jump_oc <= i_funct;
    jump_oc2 <= (others=>'0');
    jump_addr <= rega_in(jump_addr'length+2-1 downto 2);
    jump_base <= (others=>'0');
    load_exe2_out <= '0';
--when mcore_decoder_pseudo_syscall_c =>
    -- SYSCALL
--    opcode <= (others=>'0');
--    mem_opcode <= (others=>'0');
--    x <= (others=>'0');
--    y <= (others=>'0');
--    z <= (others=>'0');
--    z_addr <= (others=>'0'); 
--    load <= '0';
--    store <= '0';
--    wb <= '0';
--    jump <= '0';
--    jump_oc <= (others=>'0');
--    jump_oc2 <= (others=>'0');
--    jump_addr <= (others=>'0');
--    jump_base <= (others=>'0');
--    load_exe2_out <= '0';
when mcore_decoder_pseudo_arithmetic_c=>
    -- ARITHMETIC
    -- $rd=$rs op $rt
    opcode <= i_funct;
    mem_opcode <= (others=>'0');
    x <= rega_in;
    y <= regb_in;
    z <= (others=>'0');
    z_addr <= i_rd; 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');
    load_exe2_out <= '0';
when others=>
    -- OC|FUNC|RS|RT|C
    -- $rt=$rs op C
    opcode <= i_opcode;
    mem_opcode <= (others=>'0');
    x <= rega_in;
    if i_opcode=mcore_alu_funct_ori_c or i_opcode=mcore_alu_funct_xori_c or i_opcode=mcore_alu_funct_andi_c then
        y(mregister_width_c/2-1 downto 0) <= imm(mregister_width_c/2-1 downto 0);
        y(mregister_width_c-1 downto mregister_width_c/2) <= (others=>'0');
    else
        y <= imm;
    end if;
    z <= (others=>'0');
    z_addr <= i_rt; 
    load <= '0';
    store <= '0';
    wb <= '1';
    jump <= '0';
    jump_oc <= (others=>'0');
    jump_oc2 <= (others=>'0');
    jump_addr <= (others=>'0');
    jump_base <= (others=>'0');
    load_exe2_out <= '0';    
end case;
end process;

process(opcode)
begin
case opcode is
    when mcore_alu_funct_srlv_c | mcore_alu_funct_srl_c=> 
        pseudo <= mcore_exe_pseudo_srlx_c;
    when mcore_alu_funct_srav_c | mcore_alu_funct_sra_c=> 
        pseudo <= mcore_exe_pseudo_srax_c;
    when mcore_alu_funct_sll_c | mcore_alu_funct_sllv_c=>  
        pseudo <= mcore_exe_pseudo_sllx_c;
    when mcore_alu_funct_slt_c | mcore_alu_funct_slti_c=> 
        pseudo <= mcore_exe_pseudo_sltx_c;
    when mcore_alu_funct_sltu_c | mcore_alu_funct_sltiu_c=> 
        pseudo <= mcore_exe_pseudo_sltxu_c;
    when mcore_alu_funct_add_c | mcore_alu_funct_addi_c =>    
        pseudo <= mcore_exe_pseudo_addx_c;
    when mcore_alu_funct_addu_c | mcore_alu_funct_addiu_c =>
        pseudo <= mcore_exe_pseudo_addxu_c;
    when mcore_alu_funct_sub_c | mcore_alu_funct_subu_c=> 
        pseudo <= mcore_exe_pseudo_subx_c;
    when mcore_alu_funct_and_c|mcore_alu_funct_andi_c=> 
        pseudo <= mcore_exe_pseudo_andx_c;
    when mcore_alu_funct_or_c|mcore_alu_funct_ori_c => 
        pseudo <= mcore_exe_pseudo_orx_c;
    when mcore_alu_funct_xor_c|mcore_alu_funct_xori_c=> 
        pseudo <= mcore_exe_pseudo_xorx_c;
    when mcore_alu_funct_nor_c=>
        pseudo <= mcore_exe_pseudo_nor_c;
    when mcore_alu_funct_mult_c | mcore_alu_funct_multu_c | mcore_alu_funct_div_c | mcore_alu_funct_divu_c =>
        pseudo <= mcore_exe_pseudo_multx_divx_c;
    when mcore_alu_funct_mfhi_c =>
        pseudo <= mcore_exe_pseudo_mfhi_c;
    when mcore_alu_funct_mflo_c =>
        pseudo <= mcore_exe_pseudo_mflo_c;
    when others=>
        pseudo <= mcore_exe_pseudo_nop_c;
end case;
end process;

-------
--- Latch results before output to next stage
-------

process(clock_in,reset_in)    
begin
if reset_in='0' then
    x_r <= (others=>'0');
    y_r <= (others=>'0');
    z_r <= (others=>'0');
    shamt_r <= (others=>'0');
    z_addr_r <= (others=>'0');
    opcode_r <= (others=>'0');
    pseudo_r <= (others=>'0');
    mem_opcode_r <= (others=>'0');
    load_r <= '0';
    store_r <= '0';
    wb_r <= '0';
    jump_addr_r <= (others=>'0');
    jump_x_r <= (others=>'0');
    jump_y_r <= (others=>'0');
    jump_oc_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        if stall_in='0' and freeze_in='0' then
            if jump='0' then
                jump_oc_r <= jump_pseudo_none_c;
            else
                case jump_oc is
                when "000100" =>
                    -- BEQ
                    jump_oc_r <= jump_pseudo_beq_c;
                when "000101" =>
                    -- Process BNE
                    jump_oc_r <= jump_pseudo_bne_c;
                when "000001" =>   -- BGEZ|BGEZAL|BLTZ|BLTZAL
                    if jump_oc2="00001" or jump_oc2="10001" then
                        -- BGEZ|BGEZAL
                        jump_oc_r <= jump_pseudo_bgez_bgezal_c;
                    else
                        -- BLTZ|BLTZAL
                        jump_oc_r <= jump_pseudo_btlz_bltzal_c;
                    end if;
                when "000111" => -- BGTZ 
                    jump_oc_r <= jump_pseudo_bgtz_c;
                when "000110" => -- BLEZ
                    jump_oc_r <= jump_pseudo_blez_c;
                when others=>
                    -- Process JUMP (unconditional)
                    jump_oc_r <= jump_pseudo_unconditional_c;
                end case;
            end if;
            jump_x_r <= rega_in;
            jump_y_r <= regb_in;
            jump_addr_r <= std_logic_vector(signed(jump_addr)+signed(jump_base));
        end if;
        if stall_in='0' and freeze_in='0' then
            -- Push new instruction to DECODER stage
            x_r <= x;
            y_r <= y;
            z_r <= z; 
            shamt_r <= i_shamt;
            z_addr_r <= z_addr;
            opcode_r <= opcode;
            pseudo_r <= pseudo;
            mem_opcode_r <= mem_opcode;
            load_r <= load;
            store_r <= store;
            wb_r <= wb;
        elsif freeze_in='0' then
            -- Insert NOP to DECODER stage
            x_r <= (others=>'0');
            y_r <= (others=>'0');
            z_r <= (others=>'0');
            shamt_r <= (others=>'0');
            z_addr_r <= (others=>'0');
            opcode_r <= (others=>'0');
            pseudo_r <= (others=>'0');
            mem_opcode_r <= (others=>'0');
            load_r <= '0';
            store_r <= '0';
            wb_r <= '0';
        end if;
    end if;
end if;
end process;

---------
-- Process JUMP/BRANCH from previous instruction
---------

x_equal_y <= '1' when (jump_x_r=jump_y_r) else '0';
x_equal_zero <= '1' when (jump_x_r=std_logic_vector(to_unsigned(0,jump_x_r'length))) else '0';
process(jump_addr_r,jump_x_r,jump_y_r,jump_oc_r,x_equal_y,x_equal_zero)
begin
jump_addr_out <= jump_addr_r;
case jump_oc_r is
    when jump_pseudo_none_c => 
        jump_out <= '0';
    when jump_pseudo_beq_c =>
        -- BEQ
        jump_out <= x_equal_y;
    when jump_pseudo_bne_c =>
        -- Process BNE
        jump_out <= not x_equal_y;
    when jump_pseudo_bgez_bgezal_c =>   -- BGEZ|BGEZAL|BLTZ|BLTZAL
            -- BGEZ|BGEZAL
        jump_out <= not jump_x_r(jump_x_r'length-1);
    when jump_pseudo_btlz_bltzal_c =>
            -- BLTZ|BLTZAL
        jump_out <= jump_x_r(jump_x_r'length-1);
    when jump_pseudo_bgtz_c => -- BGTZ 
        jump_out <= (not jump_x_r(jump_x_r'length-1)) and (not x_equal_zero);
    when jump_pseudo_blez_c => -- BLEZ
        jump_out <= jump_x_r(jump_x_r'length-1) or (x_equal_zero);
    when others=>
        -- Process JUMP (unconditional)
        jump_out <= '1';
    end case;
end process;
END behaviour;
