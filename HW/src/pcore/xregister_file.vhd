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

-----
-- This component is used to store/retrieve integer results from MU. These integer
-- values are normally result from a vector comparison operation.
-- Also store/retrieve accumulator registers.
-----

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY xregister_file IS
    PORT(
        -- Global signal
        SIGNAL clock_in               : IN STD_LOGIC;
        SIGNAL reset_in               : IN STD_LOGIC;    

        -- Flag enable input for MU

        SIGNAL write_result_vector_in : IN STD_LOGIC;
        SIGNAL write_result_lane_in   : IN STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);
        SIGNAL write_addr_in          : IN xreg_addr_t;
        SIGNAL write_vm_in            : IN STD_LOGIC;
        SIGNAL write_result_ena_in    : IN STD_LOGIC;
        SIGNAL write_xreg_ena_in      : IN STD_LOGIC;
        SIGNAL write_data_in          : IN STD_LOGIC_VECTOR(vaccumulator_width_c-1 downto 0);
        SIGNAL write_result_in        : IN STD_LOGIC_VECTOR(vector_width_c-1 downto 0);

        -- Stored flag
        SIGNAL read_addr_in           : IN xreg_addr_t;
        SIGNAL read_vm_in             : IN STD_LOGIC;
        SIGNAL read_result_out        : OUT iregister_t;
        SIGNAL read_xreg_out          : OUT STD_LOGIC_VECTOR(vaccumulator_width_c-1 downto 0)

    );
END xregister_file;

ARCHITECTURE behavior OF xregister_file IS

constant iregister_byte_width_c:integer:=((iregister_width_c+7)/8);
constant xreg_byte_width_c:integer:=((vaccumulator_width_c+7)/8);
constant byte_width_c:integer:=(iregister_byte_width_c+xreg_byte_width_c);
constant width_c:integer:=(byte_width_c*8);

SIGNAL write_ena:STD_LOGIC;
SIGNAL wrdata:STD_LOGIC_VECTOR(width_c-1 downto 0);
SIGNAL q:STD_LOGIC_VECTOR(width_c-1 downto 0);
SIGNAL wraddr:STD_LOGIC_VECTOR(1+xreg_depth_c-1 downto 0);
SIGNAL rdaddr:STD_LOGIC_VECTOR(1+xreg_depth_c-1 downto 0);
SIGNAL byteena:STD_LOGIC_VECTOR(byte_width_c-1 downto 0);
SIGNAL iregister:iregister_t;
SIGNAL read_xreg_r:STD_LOGIC_VECTOR(vaccumulator_width_c-1 downto 0);

COMPONENT altsyncram
GENERIC (
        address_aclr_b                  : STRING;
        address_reg_b                   : STRING;
        clock_enable_input_a            : STRING;
        clock_enable_input_b            : STRING;
        clock_enable_output_b           : STRING;
        intended_device_family          : STRING;
        lpm_type                        : STRING;
        numwords_a                      : NATURAL;
        numwords_b                      : NATURAL;
        operation_mode                  : STRING;
        outdata_aclr_b                  : STRING;
        outdata_reg_b                   : STRING;
        power_up_uninitialized          : STRING;
        read_during_write_mode_mixed_ports: STRING;
        widthad_a                       : NATURAL;
        widthad_b                       : NATURAL;
        width_a                         : NATURAL;
        width_b                         : NATURAL;
        width_byteena_a                 : NATURAL
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

write_ena <= (write_result_ena_in or write_xreg_ena_in);

wrdata(vaccumulator_width_c-1 downto 0) <= std_logic_vector(write_data_in);

byteena(xreg_byte_width_c-1 downto 0) <= (others=>write_xreg_ena_in);

byteena(iregister_byte_width_c+xreg_byte_width_c-1 downto xreg_byte_width_c) <= (others=>write_result_ena_in);

read_result_out <= unsigned(q(iregister_width_c+xreg_byte_width_c*8-1 downto xreg_byte_width_c*8));

read_xreg_out <= read_xreg_r;

wraddr <= write_vm_in & std_logic_vector(write_addr_in);

rdaddr <= read_vm_in & std_logic_vector(read_addr_in);

process(clock_in,reset_in)
begin
    if reset_in = '0' then
       read_xreg_r <= (others=>'0');
    else
       if clock_in'event and clock_in='1' then
          read_xreg_r <= q(vaccumulator_width_c-1 downto 0);
       end if;
    end if;
end process;

process(write_result_vector_in,write_result_in,write_data_in,write_result_lane_in)
begin

if write_result_vector_in='1' then
    iregister(7 downto 0) <= (write_result_in(7) and write_result_lane_in(7)) & 
                             (write_result_in(6) and write_result_lane_in(6)) & 
                             (write_result_in(5) and write_result_lane_in(5)) & 
                             (write_result_in(4) and write_result_lane_in(4)) & 
                             (write_result_in(3) and write_result_lane_in(3)) & 
                             (write_result_in(2) and write_result_lane_in(2)) & 
                             (write_result_in(1) and write_result_lane_in(1)) & 
                             (write_result_in(0) and write_result_lane_in(0));
   iregister(iregister_width_c-1 downto 8) <= (others=>'0');
else
   iregister(iregister'length-1 downto 1) <= unsigned(write_data_in(iregister'length-1 downto 1));
   iregister(0) <= write_result_in(0);
end if;
end process;

wrdata(vaccumulator_width_c+iregister_width_c-1 downto vaccumulator_width_c) <= std_logic_vector(iregister); 

altsyncram_i : DPRAM_BE
   GENERIC MAP (
        numwords_a=>2**(xreg_depth_c+1),
        numwords_b=>2**(xreg_depth_c+1),
        widthad_a=>xreg_depth_c+1,
        widthad_b=>xreg_depth_c+1,
        width_a=>width_c,
        width_b=>width_c
    )
    PORT MAP (
        address_a => wraddr,
        byteena_a => byteena,
        clock0 => clock_in,
        data_a => wrdata,
        wren_a => write_ena,
        address_b => rdaddr,
        q_b => q
    );
END behavior;
