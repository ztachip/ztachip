------------------------------------------------------------------------------
--  Copyright [2014] [Ztachip Technologies Inc]
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

-------
-- Stream processor
-- Input vector is transformed to output vector based on lookup table and interpolation 
-- coefficient
-------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY stream IS
   PORT(SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        SIGNAL stream_id_in         : IN stream_id_t;
        SIGNAL input_in             : IN STD_LOGIC_VECTOR(register_width_c-1 downto 0);
        SIGNAL output_out           : OUT STD_LOGIC_VECTOR(register_width_c-1 downto 0);

        -- Host configuration
        
        SIGNAL config_in            : IN STD_LOGIC;
        SIGNAL config_reg_in        : IN std_logic_vector(stream_lookup_depth_c-1 downto 0);
        SIGNAL config_data_in       : IN std_logic_vector(2*register_width_c-1 downto 0)
    );
END stream;

ARCHITECTURE stream_behavior of stream IS 

COMPONENT altsyncram
GENERIC (
    byte_size                       : NATURAL;
    clock_enable_input_a            : STRING;
    clock_enable_output_a           : STRING;
    intended_device_family          : STRING;
    lpm_hint                        : STRING;
    lpm_type                        : STRING;
    numwords_a                      : NATURAL;
    operation_mode                  : STRING;
    outdata_aclr_a                  : STRING;
    outdata_reg_a                   : STRING;
    power_up_uninitialized          : STRING;
    read_during_write_mode_port_a   : STRING;
    widthad_a                       : NATURAL;
    width_a                         : NATURAL
);
PORT (
        address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
        clock0      : IN STD_LOGIC ;
        data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
        wren_a      : IN STD_LOGIC ;
        q_a         : OUT STD_LOGIC_VECTOR (width_a-1 DOWNTO 0)
);
END COMPONENT;

constant stream_lookup_depth2_c:integer:=(stream_lookup_depth_c-stream_id_t'length);
SIGNAL stream_id_r:stream_id_t;
SIGNAL input_r:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL waddr_r:STD_LOGIC_VECTOR(stream_lookup_depth_c-1 downto 0);
SIGNAL input:STD_LOGIC_VECTOR(stream_lookup_depth_c-1 downto 0);
SIGNAL address:STD_LOGIC_VECTOR(stream_lookup_depth_c-1 downto 0);
SIGNAL writedata:STD_LOGIC_VECTOR(2*register_width_c-1 downto 0);
SIGNAL writedata_r:STD_LOGIC_VECTOR(2*register_width_c-1 downto 0);
SIGNAL y_mul:STD_LOGIC_VECTOR(2*register_width_c-1 downto 0);
SIGNAL y_mul_r:STD_LOGIC_VECTOR(2*register_width_c-1 downto 0);
SIGNAL wena_r:STD_LOGIC;
SIGNAL readdata2_r:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL readdata_lookup:STD_LOGIC_VECTOR(2*register_width_c-1 downto 0);
SIGNAL readdata:STD_LOGIC_VECTOR(2*register_width_c-1 downto 0);
SIGNAL readdata_r:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL readdata_rr:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL readdata_rrr:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL remainder:STD_LOGIC_VECTOR(register_width_c-stream_lookup_depth2_c-1 downto 0);
SIGNAL remainder_r:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL remainder_rr:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL remainder_rrr:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL output:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL output_r:STD_LOGIC_VECTOR(register_width_c-1 downto 0);
SIGNAL y_mul_inc:unsigned(register_width_c+1-1 downto 0);
SIGNAL y_mul_round:std_logic_vector(register_width_c-1 downto 0);
begin

lookup_i:SPRAM
   GENERIC MAP (
       numwords_a=>2**(stream_lookup_depth_c),
       widthad_a=>stream_lookup_depth_c,
       width_a=>2*register_width_c
    )
    PORT MAP (
       address_a=>address,
       clock0=>clock_in,
       data_a=>writedata,
       wren_a=>wena_r,
       q_a=>readdata_lookup
    );

mul_i:multiplier
	generic map
	(
        DATA_WIDTH=>register_width_c,
        REGISTER_OUTPUT=>FALSE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        x_in=>readdata2_r,
        y_in=>remainder_rr,   
        z_out=>y_mul
	);

y_mul_inc <= unsigned(y_mul_r(register_width_c-stream_lookup_depth2_c+register_width_c-1 downto register_width_c-stream_lookup_depth2_c-1))+
            to_unsigned(1,register_width_c+1);

y_mul_round <= std_logic_vector(y_mul_inc(y_mul_inc'length-1 downto 1));

adder_i : adder
   generic map
   (
      DATA_WIDTH=>register_width_c
   )
   port map 
   (
      x_in=>y_mul_round,
      y_in =>readdata_rr,
      add_sub_in=> '1',
      z_out=>output
   );

output_out <= output_r;

input <= std_logic_vector(stream_id_in) & input_in(register_width_c-1 downto register_width_c-stream_lookup_depth2_c);

address <= waddr_r when wena_r='1' else input;

remainder <= input_in(register_width_c-stream_lookup_depth2_c-1 downto 0);

writedata <= writedata_r;


--------
-- Result is from lookup or RELU
--------

process(stream_id_r,readdata_lookup,input_r)
begin
readdata <= readdata_lookup;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       waddr_r <= (others=>'0');
       writedata_r <= (others=>'0');
       wena_r <= '0';
       remainder_r <= (others=>'0');
       remainder_rr <= (others=>'0');
       remainder_rrr <= (others=>'0');
       readdata2_r <= (others=>'0');
       readdata_r <= (others=>'0');
       readdata_rr <= (others=>'0');
       readdata_rrr <= (others=>'0');
       y_mul_r <= (others=>'0');
       output_r <= (others=>'0');
       stream_id_r <= (others=>'0');
       input_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            stream_id_r <= stream_id_in;
            input_r <= input_in;
            y_mul_r <= y_mul;
            output_r <= output;
            remainder_r(remainder'length-1 downto 0) <= remainder;
            remainder_r(register_width_c-1 downto remainder'length) <= (others=>'0');
            remainder_rr <= remainder_r;
            remainder_rrr <= remainder_rr;
            readdata2_r <= readdata(register_width_c-1 downto 0);
            readdata_r <= readdata(2*register_width_c-1 downto register_width_c);
            readdata_rr <= readdata_r;
            readdata_rrr <= readdata_rr;
            if config_in='1' then
                waddr_r <= config_reg_in;
                wena_r <= '1';
                writedata_r <= config_data_in(2*register_width_c-1 downto 0);
            else
               wena_r <= '0';
            end if;
        end if;
    end if;
end process;


END stream_behavior;















