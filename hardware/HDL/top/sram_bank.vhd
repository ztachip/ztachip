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

ENTITY sram_bank IS
    GENERIC(
        DEPTH       : integer
        );
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- DP interface
        SIGNAL wr_addr_in           : IN STD_LOGIC_VECTOR(DEPTH-1 downto 0);
        SIGNAL byteena_in           : IN STD_LOGIC_VECTOR(ddr_data_byte_width_c-1 downto 0);
        SIGNAL writedata_in         : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL wren_in              : IN STD_LOGIC;
        SIGNAL rden_in              : IN STD_LOGIC;
        SIGNAL rd_addr_in           : IN STD_LOGIC_VECTOR(DEPTH-1 downto 0);
        SIGNAL readdata_out         : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0)
    );
END sram_bank;

ARCHITECTURE behavior OF sram_bank IS

SIGNAL wr_addr_r:STD_LOGIC_VECTOR(DEPTH-1 downto 0);
SIGNAL byteena_r:STD_LOGIC_VECTOR(ddr_data_byte_width_c-1 downto 0);
SIGNAL writedata_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL wren_r:STD_LOGIC;
SIGNAL rden_r:STD_LOGIC;
SIGNAL rden_rr:STD_LOGIC;
SIGNAL rd_addr_r:STD_LOGIC_VECTOR(DEPTH-1 downto 0);
SIGNAL q:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL q_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);

attribute dont_merge : boolean;
attribute dont_merge of wr_addr_r : SIGNAL is true;
attribute dont_merge of byteena_r : SIGNAL is true;
attribute dont_merge of writedata_r : SIGNAL is true;
attribute dont_merge of wren_r : SIGNAL is true;
attribute dont_merge of rden_r : SIGNAL is true;
attribute dont_merge of rden_rr : SIGNAL is true;
attribute dont_merge of rd_addr_r : SIGNAL is true;

attribute preserve : boolean;
attribute preserve of wr_addr_r : SIGNAL is true;
attribute preserve of byteena_r : SIGNAL is true;
attribute preserve of writedata_r : SIGNAL is true;
attribute preserve of wren_r : SIGNAL is true;
attribute preserve of rden_r : SIGNAL is true;
attribute preserve of rden_rr : SIGNAL is true;
attribute preserve of rd_addr_r : SIGNAL is true;

COMPONENT altsyncram
GENERIC (
        address_aclr_b                      : STRING;
        address_reg_b                       : STRING;
        clock_enable_input_a                : STRING;
        clock_enable_input_b                : STRING;
        clock_enable_output_b               : STRING;
        intended_device_family              : STRING;
        lpm_type                            : STRING;
        numwords_a                          : NATURAL;
        numwords_b                          : NATURAL;
        operation_mode                      : STRING;
        outdata_aclr_b                      : STRING;
        outdata_reg_b                       : STRING;
        power_up_uninitialized              : STRING;
        read_during_write_mode_mixed_ports  : STRING;
        widthad_a                           : NATURAL;
        widthad_b                           : NATURAL;
        width_a                             : NATURAL;
        width_b                             : NATURAL;
        width_byteena_a                     : NATURAL
    );
    PORT (
            address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
            byteena_a   : IN STD_LOGIC_VECTOR (width_byteena_a-1 DOWNTO 0);
            clock0      : IN STD_LOGIC ;
            data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
            q_b         : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
            wren_a      : IN STD_LOGIC ;
            address_b   : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

BEGIN

readdata_out <= q_r when rden_rr='1' else (others=>'Z');

process(reset_in,clock_in)
begin
   if reset_in = '0' then
      wr_addr_r <= (others=>'0');
      byteena_r <= (others=>'0');
      writedata_r <= (others=>'0');
      wren_r <= '0';
      rd_addr_r <= (others=>'0');
      rden_r <= '0';
      rden_rr <= '0';
      q_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         wr_addr_r <= wr_addr_in;
         byteena_r <= byteena_in;
         writedata_r <= writedata_in;
         wren_r <= wren_in;
         rd_addr_r <= rd_addr_in;
         rden_r <= rden_in;
         rden_rr <= rden_r;
         q_r <= q;
      end if;
   end if;
end process;

altsyncram_i : altsyncram
    GENERIC MAP (
        address_aclr_b => "NONE",
        address_reg_b => "CLOCK0",
        clock_enable_input_a => "BYPASS",
        clock_enable_input_b => "BYPASS",
        clock_enable_output_b => "BYPASS",
        intended_device_family => "Cyclone V",
        lpm_type => "altsyncram",
        numwords_a => 2**(DEPTH),
        numwords_b => 2**(DEPTH),
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => DEPTH,
        widthad_b => DEPTH,
        width_a => ddr_data_width_c,
        width_b => ddr_data_width_c,
        width_byteena_a => ddr_data_byte_width_c
    )
    PORT MAP (
        address_a => wr_addr_r,
        byteena_a => byteena_r,
        clock0 => clock_in,
        data_a => writedata_r,
        wren_a => wren_r,
        address_b => rd_addr_r,
        q_b => q
    );

END behavior;
