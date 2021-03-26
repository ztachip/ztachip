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

ENTITY sram IS
    GENERIC(
        DEPTH : integer
        );
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        -- DP interface
        
        SIGNAL dp_rd_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
        SIGNAL dp_wr_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);        
        SIGNAL dp_write_in          : IN STD_LOGIC;
        SIGNAL dp_write_vector_in   : IN dp_vector_t;
        SIGNAL dp_read_in           : IN STD_LOGIC;
        SIGNAL dp_read_vector_in    : IN dp_vector_t;
        SIGNAL dp_read_gen_valid_in : IN STD_LOGIC;
        SIGNAL dp_writedata_in      : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdatavalid_out : OUT STD_LOGIC;
        SIGNAL dp_readdata_out      : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0)
    );
END sram;

ARCHITECTURE behavior OF sram IS

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
 
SIGNAL q:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL q_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL rden_r:STD_LOGIC;
SIGNAL rden_rr:STD_LOGIC;
SIGNAL rden_rrr:STD_LOGIC;
SIGNAL rd_vector_r:STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
SIGNAL rd_vector_rr:STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
SIGNAL rd_vector_rrr:STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
SIGNAL valid:STD_LOGIC;
SIGNAL dp_wr_addr:STD_LOGIC_VECTOR(DEPTH-ddr_vector_depth_c-1 downto 0);
SIGNAL dp_rd_addr:STD_LOGIC_VECTOR(DEPTH-ddr_vector_depth_c-1 downto 0);
SIGNAL rd_addr_r:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL rd_addr_rr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL rd_addr_rrr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL byteena:STD_LOGIC_VECTOR(ddr_data_byte_width_c-1 downto 0);
SIGNAL dp_writedata:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL wr_addr_r:STD_LOGIC_VECTOR(DEPTH-ddr_vector_depth_c-1 downto 0);
SIGNAL byteena_r:STD_LOGIC_VECTOR(ddr_data_byte_width_c-1 downto 0);
SIGNAL writedata_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL wren_r:std_logic;
SIGNAL dp_readdata_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL dp_readdatavalid:STD_LOGIC;
SIGNAL dp_readdatavalid_r:STD_LOGIC;

attribute dont_merge : boolean;
attribute dont_merge of rden_r : SIGNAL is true;
attribute dont_merge of rd_vector_r : SIGNAL is true;
attribute dont_merge of rd_addr_r : SIGNAL is true;
attribute dont_merge of writedata_r : SIGNAL is true;
attribute dont_merge of wren_r : SIGNAL is true;
attribute dont_merge of wr_addr_r : SIGNAL is true;
attribute preserve : boolean;
attribute preserve of dp_readdatavalid_r : SIGNAL is true;
attribute preserve of dp_readdata_r : SIGNAL is true;

BEGIN

valid <= dp_read_in and dp_read_gen_valid_in;
dp_readdata_out <= dp_readdata_r when dp_readdatavalid_r='1' else (others=>'Z');
dp_readdatavalid_out <= dp_readdatavalid_r;
delay_i1: delay generic map(DEPTH => read_latency_sram_c-1) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>valid,out_out=>dp_readdatavalid,enable_in=>'1');
dp_wr_addr <= dp_wr_addr_in(DEPTH-1 downto ddr_vector_depth_c);
dp_rd_addr <= dp_rd_addr_in(DEPTH-1 downto ddr_vector_depth_c);

process(dp_wr_addr_in,dp_write_vector_in,dp_writedata_in)
begin
if unsigned(dp_write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,dp_write_vector_in'length) then
    case dp_wr_addr_in(ddr_vector_depth_c-1 downto ddr_vector_depth_c-1) is
        when "0"=>
            byteena(1*ddr_data_byte_width_c/2-1 downto 0*ddr_data_byte_width_c/2) <= (others=>'1');
            byteena(2*ddr_data_byte_width_c/2-1 downto 1*ddr_data_byte_width_c/2) <= (others=>'0');
        when others=>
            byteena(1*ddr_data_byte_width_c/2-1 downto 0*ddr_data_byte_width_c/2) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/2-1 downto 1*ddr_data_byte_width_c/2) <= (others=>'1');
    end case;
    dp_writedata <= dp_writedata_in(ddr_data_width_c/2-1 downto 0) & 
                    dp_writedata_in(ddr_data_width_c/2-1 downto 0);
elsif unsigned(dp_write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,dp_write_vector_in'length) then
    case dp_wr_addr_in(ddr_vector_depth_c-1 downto ddr_vector_depth_c-2) is
        when "00"=>
            byteena(1*ddr_data_byte_width_c/4-1 downto 0*ddr_data_byte_width_c/4) <= (others=>'1');
            byteena(2*ddr_data_byte_width_c/4-1 downto 1*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/4-1 downto 2*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/4-1 downto 3*ddr_data_byte_width_c/4) <= (others=>'0');
        when "01"=>
            byteena(1*ddr_data_byte_width_c/4-1 downto 0*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/4-1 downto 1*ddr_data_byte_width_c/4) <= (others=>'1');
            byteena(3*ddr_data_byte_width_c/4-1 downto 2*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/4-1 downto 3*ddr_data_byte_width_c/4) <= (others=>'0');
        when "10"=>
            byteena(1*ddr_data_byte_width_c/4-1 downto 0*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/4-1 downto 1*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/4-1 downto 2*ddr_data_byte_width_c/4) <= (others=>'1');
            byteena(4*ddr_data_byte_width_c/4-1 downto 3*ddr_data_byte_width_c/4) <= (others=>'0');
        when others=>
            byteena(1*ddr_data_byte_width_c/4-1 downto 0*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/4-1 downto 1*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/4-1 downto 2*ddr_data_byte_width_c/4) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/4-1 downto 3*ddr_data_byte_width_c/4) <= (others=>'1');
    end case;
    dp_writedata <= dp_writedata_in(ddr_data_width_c/4-1 downto 0) & 
                    dp_writedata_in(ddr_data_width_c/4-1 downto 0) & 
                    dp_writedata_in(ddr_data_width_c/4-1 downto 0) & 
                    dp_writedata_in(ddr_data_width_c/4-1 downto 0);
elsif unsigned(dp_write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,dp_write_vector_in'length) then
    case dp_wr_addr_in(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
        when "000"=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'1');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'0');
        when "001"=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'1');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'0');
        when "010"=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'1');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'0');
        when "011"=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'1');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'0');
        when "100"=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'1');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'0');
        when "101"=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'1');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'0');
        when "110"=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'1');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'0');
        when others=>
            byteena(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8) <= (others=>'0');
            byteena(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8) <= (others=>'1');
    end case;
    dp_writedata <= dp_writedata_in(ddr_data_width_c/8-1 downto 0) & 
                    dp_writedata_in(ddr_data_width_c/8-1 downto 0) & 
                    dp_writedata_in(ddr_data_width_c/8-1 downto 0) & 
                    dp_writedata_in(ddr_data_width_c/8-1 downto 0) &
                    dp_writedata_in(ddr_data_width_c/8-1 downto 0) &
                    dp_writedata_in(ddr_data_width_c/8-1 downto 0) &
                    dp_writedata_in(ddr_data_width_c/8-1 downto 0) &
                    dp_writedata_in(ddr_data_width_c/8-1 downto 0);
else
   byteena <= (others=>'1');
   dp_writedata <= dp_writedata_in;
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in='0' then
dp_readdata_r <= (others=>'0');
dp_readdatavalid_r <= '0';
else
if clock_in'event and clock_in='1' then
dp_readdatavalid_r <= dp_readdatavalid;
if rden_rrr='1' then
    if unsigned(rd_vector_rrr)=to_unsigned(ddr_vector_width_c/2-1,rd_vector_rrr'length) then
        case rd_addr_rrr(ddr_vector_depth_c-1 downto ddr_vector_depth_c-1) is
            when "0"=>
                dp_readdata_r(ddr_data_width_c/2-1 downto 0) <= q_r(ddr_data_width_c/2-1 downto 0);
            when others=>
                dp_readdata_r(ddr_data_width_c/2-1 downto 0) <= q_r(2*ddr_data_width_c/2-1 downto ddr_data_width_c/2);
        end case;
        dp_readdata_r(ddr_data_width_c-1 downto ddr_data_width_c/2) <= (others=>'0');
    elsif unsigned(rd_vector_rrr)=to_unsigned(ddr_vector_width_c/4-1,rd_vector_rrr'length) then
        case rd_addr_rrr(ddr_vector_depth_c-1 downto ddr_vector_depth_c-2) is
            when "00"=>
                dp_readdata_r(ddr_data_width_c/4-1 downto 0) <= q_r(1*ddr_data_width_c/4-1 downto 0*ddr_data_width_c/4);
            when "01"=>
                dp_readdata_r(ddr_data_width_c/4-1 downto 0) <= q_r(2*ddr_data_width_c/4-1 downto 1*ddr_data_width_c/4);
            when "10"=>
                dp_readdata_r(ddr_data_width_c/4-1 downto 0) <= q_r(3*ddr_data_width_c/4-1 downto 2*ddr_data_width_c/4);
            when others=>
                dp_readdata_r(ddr_data_width_c/4-1 downto 0) <= q_r(4*ddr_data_width_c/4-1 downto 3*ddr_data_width_c/4);
        end case;
        dp_readdata_r(ddr_data_width_c-1 downto ddr_data_width_c/4) <= (others=>'0');
    elsif unsigned(rd_vector_rrr)=to_unsigned(ddr_vector_width_c/8-1,rd_vector_rrr'length) then
        case rd_addr_rrr(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
            when "000"=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(1*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8);
            when "001"=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(2*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8);
            when "010"=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(3*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8);
            when "011"=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(4*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8);
            when "100"=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(5*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8);
            when "101"=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(6*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8);
            when "110"=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(7*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8);
            when others=>
                dp_readdata_r(ddr_data_width_c/8-1 downto 0) <= q_r(8*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8);
        end case;
        dp_readdata_r(ddr_data_width_c-1 downto ddr_data_width_c/8) <= (others=>'0');
    else
        dp_readdata_r <= q_r;
    end if;
else
   dp_readdata_r <= (others=>'0');
end if;
end if;
end if;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        q_r <= (others=>'0');
        rden_r <= '0';
        rden_rr <= '0';
        rden_rrr <= '0';
        rd_vector_r <= (others=>'0');
        rd_vector_rr <= (others=>'0');
        rd_vector_rrr <= (others=>'0');
        rd_addr_r <= (others=>'0');
        rd_addr_rr <= (others=>'0');
        rd_addr_rrr <= (others=>'0');
        wr_addr_r <= (others=>'0');
        byteena_r <= (others=>'0');
        writedata_r <= (others=>'0');
        wren_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            wr_addr_r <= dp_wr_addr;
            byteena_r <= byteena;
            writedata_r <= dp_writedata;
            wren_r <= dp_write_in;

            rd_vector_rrr <= rd_vector_rr;
            rd_vector_rr <= rd_vector_r;
            rd_vector_r <= dp_read_vector_in;
            rden_rrr <= rden_rr;
            rden_rr <= rden_r;
            rden_r <= dp_read_in;
            rd_addr_r <= dp_rd_addr_in;
            rd_addr_rr <= rd_addr_r;
            rd_addr_rrr <= rd_addr_rr;
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
        numwords_a => 2**(DEPTH-ddr_vector_depth_c),
        numwords_b => 2**(DEPTH-ddr_vector_depth_c),
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => DEPTH-ddr_vector_depth_c,
        widthad_b => DEPTH-ddr_vector_depth_c,
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
        address_b => rd_addr_r(DEPTH-1 downto ddr_vector_depth_c),
        q_b => q
    );

END behavior;
