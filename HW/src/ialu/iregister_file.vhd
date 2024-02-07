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

--------
-- This module implements register-file to hold integer registers of PCORE
-- There are 8 integer registers for each thread
-- All integer registers for a thread are combined and accessed as a single 
-- long word
----------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY iregister_file IS
   PORT( 
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL clock_x2_in          : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- Interface 1
        SIGNAL rd_en1_in            : IN STD_LOGIC;
        SIGNAL rd_vm_in             : IN STD_LOGIC;
        SIGNAL rd_tid1_in           : IN tid_t;
        SIGNAL rd_data1_out         : OUT iregisters_t(iregister_max_c-1 downto 0);
        SIGNAL rd_lane_out          : OUT iregister_t;
        SIGNAL wr_tid1_in           : IN tid_t;
        SIGNAL wr_en1_in            : IN STD_LOGIC;
        SIGNAL wr_vm_in             : IN STD_LOGIC;
        SIGNAL wr_lane_in           : IN STD_LOGIC;
        SIGNAL wr_addr1_in          : IN iregister_addr_t;
        SIGNAL wr_data1_in          : IN iregister_t
    );
END iregister_file;

ARCHITECTURE behaviour of iregister_file IS

constant byte_width_c:integer:=((iregister_width_c+7)/8); -- Round up to multiple of byte size
constant width_c:integer:=(byte_width_c*8);

SIGNAL q1:std_logic_vector(width_c*(iregister_max_c+1)-1 downto 0);
SIGNAL wrdata1:std_logic_vector(width_c*(iregister_max_c+1)-1 downto 0);
SIGNAL byteena1:std_logic_vector((iregister_max_c+1)*byte_width_c-1 downto 0);
SIGNAL rdaddr1:std_logic_vector(tid_t'length+1-1 downto 0);
SIGNAL wraddr1:std_logic_vector(tid_t'length+1-1 downto 0);
SIGNAL rd_lane_r:iregister_t;

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

rdaddr1 <= rd_vm_in & std_logic_vector(rd_tid1_in);
wraddr1 <= wr_vm_in & std_logic_vector(wr_tid1_in);

---------
-- Transfer data to/from first interface to the DUALPORT RAM block
---------

rd_lane_out <= rd_lane_r;

process(q1)
begin
for I in 0 to iregister_max_c-1 loop
    rd_data1_out(I) <= unsigned(q1(I*width_c+iregister_width_c-1 downto I*width_c));
end loop;
end process;

process(clock_in,reset_in)
begin
if reset_in='0' then
    rd_lane_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        rd_lane_r <= unsigned(not q1(iregister_max_c*width_c+iregister_width_c-1 downto iregister_max_c*width_c));
    end if;
end if;
end process;


-----
-- Generate byteena depending on which registers to be written
-----

process(wr_data1_in,wr_addr1_in,wr_en1_in,wr_lane_in)
begin
for I in 0 to iregister_max_c-1 loop
    wrdata1(I*width_c+iregister_width_c-1 downto I*width_c) <= std_logic_vector(wr_data1_in);
    if I=to_integer(wr_addr1_in) then
       byteena1((I+1)*byte_width_c-1 downto I*byte_width_c)  <= (others=>wr_en1_in);
    else
       byteena1((I+1)*byte_width_c-1 downto I*byte_width_c)  <= (others=>'0');
    end if;
end loop;

wrdata1(iregister_max_c*width_c+iregister_width_c-1 downto iregister_max_c*width_c) <= not std_logic_vector(wr_data1_in);
byteena1((iregister_max_c+1)*byte_width_c-1 downto iregister_max_c*byte_width_c)  <= (others=>wr_lane_in);
end process;

---------
-- Dual port RAM block to hold index registers
---------

iregister_ram_i: iregister_ram
    GENERIC MAP(
        DEPTH => tid_t'length+1,
        WIDTH => width_c*(iregister_max_c+1)
    )
    PORT MAP(
        clock_in => clock_in,
        clock_x2_in => clock_x2_in,
        reset_in => reset_in,
        -- PORT 1
        data1_in => wrdata1,
        rdaddress1_in => rdaddr1,
        wraddress1_in => wraddr1,
        wrbyteena1_in => byteena1,
        wren1_in => '1',    
        rden1_in => rd_en1_in,
        q1_out => q1
    );

END behaviour;
