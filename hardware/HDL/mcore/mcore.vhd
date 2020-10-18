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
-- This is top component for MCORE processor
-- MCORE processor is based on MIPS architecture which is a 5 stage pipeline
-- architecture
-- MIPS-I architecture is chosen for its simplicity and the availability of compiler
-- tool (GNU)
-- Refer to http://en.wikipedia.org/wiki/MIPS_instruction_set for more information
-- MIPS-I instruction is supported in this implementation
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;

ENTITY mcore IS
    PORT(
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        SIGNAL sreset_in            : IN STD_LOGIC;
        -- IO interface
        SIGNAL io_wren_out          : OUT STD_LOGIC;
        SIGNAL io_rden_out          : OUT STD_LOGIC;
        SIGNAL io_addr_out          : OUT STD_LOGIC_VECTOR(io_depth_c-1 downto 0);
        SIGNAL io_readdata_in       : IN STD_LOGIC_VECTOR(mregister_width_c-1 downto 0);
        SIGNAL io_writedata_out     : OUT STD_LOGIC_VECTOR(mregister_width_c-1 downto 0);
        SIGNAL io_byteena_out       : OUT STD_LOGIC_VECTOR(mregister_byte_width_c-1 downto 0);
        SIGNAL io_waitrequest_in    : IN STD_LOGIC;
        -- Programming interface for TEXT and DATA segments.
        SIGNAL prog_text_ena_in     : IN STD_LOGIC;
        SIGNAL prog_text_addr_in    : IN STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
        SIGNAL prog_text_data_in    : IN STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);
        SIGNAL prog_data_ena_in     : IN STD_LOGIC;
        SIGNAL prog_data_addr_in    : IN STD_LOGIC_VECTOR(mcore_ram_depth_c-1 downto 0);
        SIGNAL prog_data_data_in    : IN mregister_t
    );
END mcore;

ARCHITECTURE behaviour OF mcore IS
SIGNAL rega_ena:STD_LOGIC;
SIGNAL regb_ena:STD_LOGIC;
SIGNAL reg_read_a_addr:mcore_regno_t;
SIGNAL reg_read_b_addr:mcore_regno_t;
SIGNAL reg_read_a_data:mregister_t;
SIGNAL reg_read_b_data:mregister_t;
SIGNAL reg_write_ena:STD_LOGIC;
SIGNAL reg_write_addr:mcore_regno_t;
SIGNAL reg_write_data:mregister_t;
SIGNAL rom_addr:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 DOWNTO 0);
SIGNAL rom_data:STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);

SIGNAL mem_addr:STD_LOGIC_VECTOR(mcore_mem_depth_c-1 DOWNTO 0);
SIGNAL mem_readdata:mregister_t;
SIGNAL mem_write_data:mregister_t;
SIGNAL mem_write_ena:STD_LOGIC;
SIGNAL mem_read_ena:STD_LOGIC;
SIGNAL mem_byteena:STD_LOGIC_VECTOR(mregister_byte_width_c-1 downto 0);

SIGNAL ram_addr:STD_LOGIC_VECTOR(mcore_ram_depth_c-1 DOWNTO 0);
SIGNAL ram_readdata:mregister_t;
SIGNAL ram_write_data:mregister_t;
SIGNAL ram_write_ena:STD_LOGIC;
SIGNAL ram_read_ena:STD_LOGIC;
SIGNAL ram_byteena:STD_LOGIC_VECTOR(mregister_byte_width_c-1 downto 0);

SIGNAL jump:STD_LOGIC;
SIGNAL jump_addr:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL instruction_fetch:STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);
SIGNAL instruction_pseudo:mcore_decoder_pseudo_t;
SIGNAL x_decoder:mregister_t;
SIGNAL y_decoder:mregister_t;
SIGNAL z_decoder:mregister_t;
SIGNAL z_addr_decoder:mcore_regno_t;
SIGNAL opcode_decoder:mcore_alu_funct_t;
SIGNAL pseudo_decoder:mcore_exe_pseudo_t;
SIGNAL load_decoder:STD_LOGIC;
SIGNAL store_decoder:STD_LOGIC;
SIGNAL wb_decoder:STD_LOGIC;
SIGNAL result_exe:mregister_t;
SIGNAL z_exe:mregister_t;
SIGNAL z_addr_exe:mcore_regno_t;
SIGNAL load_exe:STD_LOGIC;
SIGNAL store_exe:STD_LOGIC;
SIGNAL wb_exe:STD_LOGIC;
SIGNAL wb_ena_mem:STD_LOGIC;
SIGNAL wb_addr_mem:mcore_regno_t;
SIGNAL wb_data_mem:mregister_t;
SIGNAL wb_byteena:STD_LOGIC_VECTOR(mregister_byte_width_c-1 downto 0);
SIGNAL hazard_data_exe:mregister_t;
SIGNAL hazard_addr_exe:mcore_regno_t;
SIGNAL hazard_ena_exe:STD_LOGIC;
SIGNAL hazard_data_mem:mregister_t;
SIGNAL hazard_addr_mem:mcore_regno_t;
SIGNAL hazard_ena_mem:STD_LOGIC;
SIGNAL stall_addr_exe:mcore_regno_t;
SIGNAL stall_ena_exe:STD_LOGIC;
SIGNAL stall_addr_mem:mcore_regno_t;
SIGNAL stall_ena_mem:STD_LOGIC;
SIGNAL stall:STD_LOGIC;
SIGNAL freeze:STD_LOGIC;
SIGNAL pc_fetch:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL shamt:mcore_shamt_t;
SIGNAL mem_opcode_decoder:mcore_mem_funct_t;
SIGNAL mem_opcode_exe:mcore_mem_funct_t;
SIGNAL io:STD_LOGIC;
SIGNAL io_r:STD_LOGIC;
SIGNAL rega_addr_fetch:mcore_regno_t; 
SIGNAL regb_addr_fetch:mcore_regno_t;
SIGNAL rega_ena_fetch:STD_LOGIC;
SIGNAL regb_ena_fetch:STD_LOGIC;
SIGNAL exe2_opcode:mcore_alu_funct_t;
SIGNAL exe2_req_exe:STD_LOGIC;
SIGNAL exe2_x:mregister_t;
SIGNAL exe2_y:mregister_t;
SIGNAL LO:mregister_t;
SIGNAL HI:mregister_t;
SIGNAL exe2_busy:STD_LOGIC;
SIGNAL load_exe2:STD_LOGIC;
SIGNAL mcore_reset:STD_LOGIC;
-- Programming register
SIGNAL prog_text_ena_r:STD_LOGIC;
SIGNAL prog_text_addr_r:STD_LOGIC_VECTOR(mcore_instruction_depth_c-1 downto 0);
SIGNAL prog_text_data_r:STD_LOGIC_VECTOR(mcore_instruction_width_c-1 downto 0);
SIGNAL prog_data_ena_r:STD_LOGIC;
SIGNAL prog_data_addr_r:STD_LOGIC_VECTOR(mcore_ram_depth_c-1 downto 0);
SIGNAL prog_data_data_r:mregister_t;

attribute dont_merge : boolean;
attribute dont_merge of prog_text_ena_r : SIGNAL is true;        
attribute dont_merge of prog_text_addr_r : SIGNAL is true;
attribute dont_merge of prog_text_data_r : SIGNAL is true;
attribute dont_merge of prog_data_ena_r : SIGNAL is true;
attribute dont_merge of prog_data_addr_r : SIGNAL is true;
attribute dont_merge of prog_data_data_r : SIGNAL is true;
BEGIN

mcore_reset <= reset_in and sreset_in;

io <= mem_addr(mem_addr'length-1);

freeze <= (mem_write_ena or mem_read_ena) and io and io_waitrequest_in;

ram_addr <= mem_addr(ram_addr'length-1 downto 0) when prog_data_ena_r='0' else prog_data_addr_r;
ram_write_data <= mem_write_data when prog_data_ena_r='0' else prog_data_data_r;
ram_write_ena <= (mem_write_ena and (not io)) or prog_data_ena_r;
ram_read_ena <= mem_read_ena and (not io);
ram_byteena <= mem_byteena when prog_data_ena_r='0' else (others=>'1');

io_addr_out <= mem_addr(io_addr_out'length-1 downto 0);
io_writedata_out <= mem_write_data;
io_wren_out <= mem_write_ena and io;
io_rden_out <= mem_read_ena and io;
io_byteena_out <= mem_byteena;

mem_readdata <= ram_readdata when (io_r='0') else io_readdata_in;

process(clock_in,reset_in)
begin
if reset_in='0' then
    prog_text_ena_r <= '0';
    prog_text_addr_r <= (others=>'0');
    prog_text_data_r <= (others=>'0');
    prog_data_ena_r <= '0';
    prog_data_addr_r <= (others=>'0');
    prog_data_data_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        prog_text_ena_r <= prog_text_ena_in;
        prog_text_addr_r <= prog_text_addr_in;
        prog_text_data_r <= prog_text_data_in;
        prog_data_ena_r <= prog_data_ena_in;
        prog_data_addr_r <= prog_data_addr_in;
        prog_data_data_r <= prog_data_data_in;
    end if;
end if;
end process;

process(clock_in,mcore_reset)
begin
if mcore_reset='0' then
    io_r <= '0';
else
    if clock_in'event and clock_in='1' then
        io_r <= io;
    end if;
end if;
end process;

-------
-- Stall the processor when there is a conflict between register access and
-- registers are still updating in the pipeline
-------

process(rega_ena,stall_addr_mem,regb_ena,stall_addr_exe,reg_read_a_addr,reg_read_b_addr,stall_ena_exe,stall_ena_mem,load_exe2,exe2_busy)
begin
    if (rega_ena='1' and stall_addr_exe=reg_read_a_addr and stall_ena_exe='1' ) or
        (rega_ena='1' and stall_addr_mem=reg_read_a_addr and stall_ena_mem='1') or
        (regb_ena='1' and stall_addr_exe=reg_read_b_addr and stall_ena_exe='1' ) or
        (regb_ena='1' and stall_addr_mem=reg_read_b_addr and stall_ena_mem='1') or
        (load_exe2='1' and exe2_busy='1')  then
        stall <= '1';
    else
        stall <= '0';
    end if;
end process;

--------
-- Instantiate REGISTER FILE
--------

register_i:mcore_register
    PORT MAP(
        clock_in=>clock_in,
        reset_in=>mcore_reset,
        reada_addr_in=>reg_read_a_addr,
        readb_addr_in=>reg_read_b_addr,
        reada_data_out=>reg_read_a_data,
        readb_data_out=>reg_read_b_data,
        wren_in=>reg_write_ena,
        write_addr_in=>reg_write_addr,
        write_data_in=>reg_write_data,

        hazard1_data_in=>hazard_data_exe,
        hazard1_addr_in=>hazard_addr_exe,
        hazard1_ena_in=>hazard_ena_exe,

        hazard2_data_in=>hazard_data_mem,
        hazard2_addr_in=>hazard_addr_mem,
        hazard2_ena_in=>hazard_ena_mem
    );

-------
--- Instantiate ROM for code memory space
-------

rom_i: mcore_rom
    PORT MAP(
        clock_in => clock_in,
        reset_in => reset_in,
        -- Output to ROM
        rom_addr_in => rom_addr,
        rom_data_out => rom_data,
        -- Programming ROM interface
        prog_ena_in => prog_text_ena_r,
        prog_addr_in => prog_text_addr_r,
        prog_data_in => prog_text_data_r

    );

--------
--- Instantiate RAM
--------

ram_i: mcore_ram
    PORT MAP(
        clock_in => clock_in,
        reset_in => reset_in,
        address_in => ram_addr,
        read_data_out => ram_readdata,
        write_data_in => ram_write_data,
        write_ena_in => ram_write_ena,
        write_byteena_in => ram_byteena,
        read_ena_in => ram_read_ena
    );

-------
-- Instantiate FETCH stage
-------

fetch_i: mcore_fetch
    PORT MAP(
        clock_in => clock_in,
        reset_in => mcore_reset,
        instruction_out => instruction_fetch,
        pseudo_out => instruction_pseudo,
        pc_out => pc_fetch,

        rega_addr_out => rega_addr_fetch, 
        regb_addr_out => regb_addr_fetch,
        rega_ena_out => rega_ena_fetch, 
        regb_ena_out => regb_ena_fetch,

        rom_addr_out => rom_addr,
        rom_data_in => rom_data,
        jump_in => jump,
        jump_addr_in => jump_addr,
        stall_in=>stall,
        freeze_in => freeze
    );

-------
-- Instantiate DECODER stage
-------

decoder_i:mcore_decoder
    PORT MAP(
        clock_in=>clock_in,
        reset_in=>mcore_reset,
        instruction_in=>instruction_fetch,
        pseudo_in => instruction_pseudo,
        pc_in=>pc_fetch,

        rega_addr_in => rega_addr_fetch, 
        regb_addr_in => regb_addr_fetch,
        rega_ena_in => rega_ena_fetch, 
        regb_ena_in => regb_ena_fetch,

        x_out=>x_decoder,
        y_out=>y_decoder,
        z_out=>z_decoder,
        shamt_out=>shamt,
        z_addr_out=>z_addr_decoder,
        opcode_out=>opcode_decoder,
        pseudo_out=>pseudo_decoder,
        mem_opcode_out=>mem_opcode_decoder,
        load_out=>load_decoder,
        store_out=>store_decoder,
        wb_out=>wb_decoder,
        jump_out=>jump,
        jump_addr_out=>jump_addr,
        rega_addr_out=>reg_read_a_addr,
        regb_addr_out=>reg_read_b_addr,
        rega_ena_out=>rega_ena,
        regb_ena_out=>regb_ena,
        rega_in=>reg_read_a_data,
        regb_in=>reg_read_b_data,
        load_exe2_out=>load_exe2,
        stall_in=>stall,
        freeze_in => freeze
    );

------
-- Instantiate EXE state
------

exe_i:mcore_exe
    PORT MAP (
        clock_in=>clock_in,
        reset_in=>mcore_reset,
        x_in=>x_decoder,
        y_in=>y_decoder,
        z_in=>z_decoder,
        shamt_in=>shamt,
        z_addr_in=>z_addr_decoder,
        opcode_in=>opcode_decoder,
        pseudo_in=>pseudo_decoder,
        mem_opcode_in=>mem_opcode_decoder,
        load_in=>load_decoder,
        store_in=>store_decoder,
        wb_in=>wb_decoder,
        result_out=>result_exe,
        z_out=>z_exe,
        z_addr_out=>z_addr_exe,
        mem_opcode_out=>mem_opcode_exe,
        load_out=>load_exe,
        store_out=>store_exe,
        wb_out=>wb_exe,
        hazard_data_out=>hazard_data_exe,
        hazard_addr_out=>hazard_addr_exe,
        hazard_ena_out=>hazard_ena_exe,
        stall_addr_out=>stall_addr_exe,
        stall_ena_out=>stall_ena_exe,
        exe2_opcode_out=>exe2_opcode,
        exe2_req_out=>exe2_req_exe,
        exe2_x_out=>exe2_x,
        exe2_y_out=>exe2_y,
        LO_in => LO,
        HI_in => HI,
        freeze_in => freeze
    );

-----------
-- Instantiate EXE
-- This stage performs long operation such as divide/multiply 
-----------

exe2_i:mcore_exe2
    PORT MAP(
        clock_in=>clock_in,
        reset_in=>mcore_reset,
        opcode_in=>exe2_opcode,
        req_in=>exe2_req_exe,
        x_in=>exe2_x,
        y_in=>exe2_y,
        LO_out=>LO,
        HI_out=>HI,
        busy_out=>exe2_busy
    );

--------
-- Instantiate MEM stage
--------

mem_i:mcore_mem
    PORT MAP(
        clock_in=>clock_in,
        reset_in=>mcore_reset,
        result_in=>result_exe,
        z_in=>z_exe,
        z_addr_in=>z_addr_exe,
        mem_opcode_in=>mem_opcode_exe,
        load_in=>load_exe,
        store_in=>store_exe,
        wb_in=>wb_exe,
        mem_wren_out=>mem_write_ena,
        mem_rden_out=>mem_read_ena,
        mem_addr_out=>mem_addr,
        mem_readdata_in=>mem_readdata,
        mem_writedata_out=>mem_write_data,
        mem_byteena_out=>mem_byteena,

        wb_addr_out=>wb_addr_mem,
        wb_data_out=>wb_data_mem,
        wb_ena_out=>wb_ena_mem,
        
        hazard_data_out=>hazard_data_mem,
        hazard_addr_out=>hazard_addr_mem,
        hazard_ena_out=>hazard_ena_mem,
        stall_addr_out=>stall_addr_mem,
        stall_ena_out=>stall_ena_mem,
        freeze_in => freeze
    );

---------
-- Instantiate Write-back stage
---------

wb_i:mcore_wb
    PORT MAP(
        clock_in=>clock_in,
        reset_in=>mcore_reset,
        wb_addr_in=>wb_addr_mem,
        wb_data_in=>wb_data_mem,
        wb_ena_in=>wb_ena_mem,
        reg_wren_out=>reg_write_ena,
        reg_write_addr_out=>reg_write_addr,
        reg_write_data_out=>reg_write_data
    );

END behaviour;
