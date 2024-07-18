------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Author: Vuong Nguyen
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

----------
-- RAM block to hold integer registers of PCORE
-- All integer registers of a thread are concatenated and stored as a single
-- entry in this RAM block
-----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY iregister_ram IS
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
        SIGNAL wrbyteena1_in    : IN STD_LOGIC_VECTOR(WIDTH/8-1 DOWNTO 0);
        SIGNAL wren1_in         : IN STD_LOGIC;
        SIGNAL rden1_in         : IN STD_LOGIC;
        SIGNAL q1_out           : OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0)
    );
END iregister_ram;

ARCHITECTURE behavior OF iregister_ram IS

SIGNAL data1_r : STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
SIGNAL wraddress1_r : STD_LOGIC_VECTOR (DEPTH-1 DOWNTO 0);
SIGNAL wrbyteena1_r : STD_LOGIC_VECTOR(WIDTH/8-1 DOWNTO 0);
SIGNAL wren1_r : STD_LOGIC;

COMPONENT altsyncram
GENERIC (
    address_aclr_b                      : STRING;
    address_reg_b                       : STRING;
    byte_size                           : NATURAL;
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

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        data1_r <= (others=>'0');
        wraddress1_r <= (others=>'0');
        wrbyteena1_r <= (others=>'0');
        wren1_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            data1_r <= data1_in;
            wraddress1_r <= wraddress1_in;
            wrbyteena1_r <= wrbyteena1_in;
            wren1_r <= wren1_in;
        end if;
    end if;
end process;

altsyncram_i:ramw
   GENERIC MAP (
        numwords_a=>2**DEPTH,
        numwords_b=>2**DEPTH,
        widthad_a=>DEPTH,
        widthad_b=>DEPTH,
        width_a=>WIDTH,
        width_b=>WIDTH
    )
    PORT MAP (
        address_a=>wraddress1_r,
        byteena_a=>wrbyteena1_r,
        clock=>clock_in,
        clock_x2=>clock_x2_in,
        data_a=>data1_r,
        q_b=>q1_out,
        wren_a=>wren1_r,
        address_b=>rdaddress1_in
    );
    
END behavior;
