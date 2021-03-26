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
-- Implement SRAM block
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY sram_core IS
    PORT (
        SIGNAL clock_in                : IN STD_LOGIC;
        SIGNAL reset_in                : IN STD_LOGIC;

        -- DP interface
        
        SIGNAL dp_rd_addr_in           : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
        SIGNAL dp_wr_addr_in           : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
        SIGNAL dp_rd_fork_in           : IN dp_fork_t;
        SIGNAL dp_wr_fork_in           : IN dp_fork_t;
        SIGNAL dp_write_in             : IN STD_LOGIC;
        SIGNAL dp_write_vector_in      : IN dp_vector_t;
        SIGNAL dp_read_in              : IN STD_LOGIC;
        SIGNAL dp_read_vm_in           : IN STD_LOGIC;
        SIGNAL dp_read_vector_in       : IN dp_vector_t;
        SIGNAL dp_read_gen_valid_in    : IN STD_LOGIC;
        SIGNAL dp_writedata_in         : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdatavalid_out    : OUT STD_LOGIC;
        SIGNAL dp_readdatavalid_vm_out : OUT STD_LOGIC;
        SIGNAL dp_readdata_out         : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0)
    );
END sram_core;

ARCHITECTURE behavior OF sram_core IS
SIGNAL write:STD_LOGIC_VECTOR(sram_num_bank_c-1 downto 0);
SIGNAL read:STD_LOGIC_VECTOR(sram_num_bank_c-1 downto 0);
SIGNAL writedata:dp_data_t;
SIGNAL readdatavalid:STD_LOGIC_VECTOR(sram_num_bank_c-1 downto 0);
SIGNAL readdata:dp_datas_t(sram_num_bank_c-1 downto 0);
SIGNAL vm_r:STD_LOGIC;
SIGNAL vm_rr:STD_LOGIC;
SIGNAL vm_rrr:STD_LOGIC;
SIGNAL vm_rrrr:STD_LOGIC;
BEGIN

dp_readdatavalid_out <= '0' when readdatavalid=std_logic_vector(to_unsigned(0,sram_num_bank_c)) else '1';

-- MUX write access to the bank

process(dp_wr_addr_in,dp_writedata_in,dp_write_in)
begin
   -- This is single access
   case dp_wr_addr_in(sram_depth_c-1 downto sram_bank_depth_c) is
      when "0" => 
         write(0) <= dp_write_in;
         write(1) <= '0';
         writedata <= dp_writedata_in(ddr_data_width_c-1 downto 0);
      when others=>
         write(0) <= '0';
         write(1) <= dp_write_in;
         writedata <= dp_writedata_in(ddr_data_width_c-1 downto 0);
   end case;
end process;

-- MUX read access to the bank

process(dp_rd_addr_in,dp_read_in)
begin
   case dp_rd_addr_in(sram_depth_c-1 downto sram_bank_depth_c) is
      when "0" => 
         read(0) <= dp_read_in;
         read(1) <= '0';
      when others=>
         read(0) <= '0';
         read(1) <= dp_read_in;
   end case;
end process;

-- MUX read access

process(readdatavalid,readdata)
begin
if readdatavalid(0)='1' then
   dp_readdata_out(ddr_data_width_c-1 downto 0) <= readdata(0);
else
   dp_readdata_out(ddr_data_width_c-1 downto 0) <= readdata(1);
end if;
dp_readdatavalid_vm_out <= vm_rrrr;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       vm_r <= '0';
       vm_rr <= '0';
       vm_rrr <= '0';
       vm_rrrr <= '0';
    else
        if clock_in'event and clock_in='1' then
           vm_r <= dp_read_vm_in;
           vm_rr <= vm_r;
           vm_rrr <= vm_rr;
           vm_rrrr <= vm_rrr;
        end if;
    end if;
end process;

GEN_SRAM:
FOR I in 0 to sram_num_bank_c-1 GENERATE
sram_i : sram
    GENERIC MAP(
        DEPTH=>sram_bank_depth_c
        )
    PORT MAP (
        clock_in => clock_in,
        reset_in => reset_in,
        dp_rd_addr_in => dp_rd_addr_in(sram_bank_depth_c-1 downto 0),
        dp_wr_addr_in => dp_wr_addr_in(sram_bank_depth_c-1 downto 0),
        dp_write_in => write(I),
        dp_write_vector_in=>dp_write_vector_in,
        dp_read_in=>read(I),
        dp_read_vector_in=>dp_read_vector_in,
        dp_read_gen_valid_in=>dp_read_gen_valid_in,
        dp_writedata_in=>writedata,
        dp_readdatavalid_out=>readdatavalid(I),
        dp_readdata_out => readdata(I)
    );
END GENERATE GEN_SRAM;

END behavior;
