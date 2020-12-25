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
-- This component simulates DDR memory for testbench environment
-- There are 2 ports. One is for read/write access to ZTACHIP
-- And one is for accessing from signal-tap
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY ramtest IS
    GENERIC (
        DEPTH:integer;
        WIDTH:integer
        );
    PORT (
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL clock_x2_in      : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        -- PORT 1
        SIGNAL data1_in         : IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
        SIGNAL rdaddress1_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wraddress1_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wren1_in         : IN STD_LOGIC;
        SIGNAL wrbyteenable1_in : IN STD_LOGIC_VECTOR(WIDTH/8-1 DOWNTO 0);
        SIGNAL q1_out           : OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
        -- PORT 2
        SIGNAL data2_in         : IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
        SIGNAL rdaddress2_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wraddress2_in    : IN STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
        SIGNAL wren2_in         : IN STD_LOGIC;
        SIGNAL wrbyteenable2_in : IN STD_LOGIC_VECTOR(WIDTH/8-1 DOWNTO 0);
        SIGNAL q2_out           : OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0)
    );
END ramtest;

ARCHITECTURE behavior OF ramtest IS
SIGNAL sel_r:STD_LOGIC;
SIGNAL rdaddress2_r:STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
SIGNAL wraddress2_r:STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
SIGNAL data2_r:STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
SIGNAL wren2_r:STD_LOGIC;
SIGNAL wrbyteenable2_r:STD_LOGIC_VECTOR(WIDTH/8-1 DOWNTO 0);
SIGNAL rdaddress:STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
SIGNAL wraddress:STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
SIGNAL data:STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
SIGNAL wren:STD_LOGIC;
SIGNAL q:STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
SIGNAL q_r:STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
SIGNAL q1_r:STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
SIGNAL q2_r:STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
SIGNAL byteena:STD_LOGIC_VECTOR(ddr_data_byte_width_c-1 DOWNTO 0);
attribute dont_merge : boolean;
attribute dont_merge of sel_r : SIGNAL is true;

COMPONENT altsyncram
GENERIC (
        address_aclr_b              : STRING;
        address_reg_b               : STRING;
        clock_enable_input_a        : STRING;
        clock_enable_input_b        : STRING;
        clock_enable_output_b       : STRING;
        intended_device_family      : STRING;
        lpm_type                    : STRING;
        numwords_a                  : NATURAL;
        numwords_b                  : NATURAL;
        operation_mode              : STRING;
        outdata_aclr_b              : STRING;
        outdata_reg_b               : STRING;
        power_up_uninitialized      : STRING;
        read_during_write_mode_mixed_ports: STRING;
        widthad_a                   : NATURAL;
        widthad_b                   : NATURAL;
        width_a                     : NATURAL;
        width_b                     : NATURAL;
        width_byteena_a             : NATURAL
    );
    PORT (
            address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
            byteena_a : IN STD_LOGIC_VECTOR (width_byteena_a-1 DOWNTO 0);
            clock0    : IN STD_LOGIC ;
            data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
            q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
            wren_a    : IN STD_LOGIC ;
            address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;
BEGIN

rdaddress <= rdaddress1_in when sel_r='0' else rdaddress2_r;
q1_out <= q1_r;
q2_out <= q2_r;

wraddress <= wraddress1_in when sel_r='0' else wraddress2_r;
data <= data1_in when sel_r='0' else data2_r;
wren <= wren1_in when sel_r='0' else wren2_r;
byteena <= wrbyteenable1_in when sel_r='0' else wrbyteenable2_r;

process(clock_x2_in,reset_in)
begin
    if reset_in='0' then
        sel_r <= '1';
        q_r <= (others=>'0');    
        rdaddress2_r <= (others=>'0');
        wraddress2_r <= (others=>'0');
        data2_r <= (others=>'0');
        wren2_r <= '0';
        wrbyteenable2_r <= (others=>'0');
    else
        if clock_x2_in'event and clock_x2_in='1' then
            sel_r <= not sel_r;
            q_r <= q;
            if sel_r='0' then
                rdaddress2_r <= rdaddress2_in;
                wraddress2_r <= wraddress2_in;
                data2_r <= data2_in;
                wren2_r <= wren2_in;
                wrbyteenable2_r <= wrbyteenable2_in;
            end if;
        end if;
    end if;
end process;

process(clock_in,reset_in)
begin
    if reset_in='0' then
        q1_r <= (others=>'0');
        q2_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            q1_r <= q_r;
            q2_r <= q;                                    
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
        numwords_a => 2**DEPTH,
        numwords_b => 2**DEPTH,
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => DEPTH,
        widthad_b => DEPTH,
        width_a => WIDTH,
        width_b => WIDTH,
        width_byteena_a => WIDTH/8
    )
    PORT MAP (
        address_a => wraddress,
        byteena_a => byteena,
        clock0 => clock_x2_in,
        data_a => data,
        wren_a => wren,
        address_b => rdaddress,
        q_b => q
    );
END behavior;
