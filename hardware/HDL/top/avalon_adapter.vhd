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
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY avalon_adapter IS
   PORT( 
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        SIGNAL ddr_addr_in             : IN std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_burstlen_in         : IN unsigned(ddr_burstlen_width_c-1 downto 0);
        SIGNAL ddr_burstbegin_in       : IN std_logic;
        SIGNAL ddr_readdatavalid_out   : OUT std_logic;
        SIGNAL ddr_write_in            : IN std_logic;
        SIGNAL ddr_read_in             : IN std_logic;
        SIGNAL ddr_writedata_in        : IN std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL ddr_byteenable_in       : IN std_logic_vector(ddr_data_byte_width_c-1 downto 0);
        SIGNAL ddr_readdata_out        : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL ddr_wait_request_out    : OUT std_logic;

        SIGNAL avalon_addr_out         : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL avalon_burstlen_out     : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
        SIGNAL avalon_burstbegin_out   : OUT std_logic;
        SIGNAL avalon_readdatavalid_in : IN std_logic;
        SIGNAL avalon_write_out        : OUT std_logic;
        SIGNAL avalon_read_out         : OUT std_logic;
        SIGNAL avalon_writedata_out    : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL avalon_byteenable_out   : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0);
        SIGNAL avalon_readdata_in      : IN std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL avalon_wait_request_in  : IN std_logic
    );
END avalon_adapter;

ARCHITECTURE behaviour of avalon_adapter IS

SIGNAL avalon_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL avalon_burstlen_r:unsigned(ddr_burstlen_width_c-1 downto 0);
SIGNAL avalon_burstbegin_r:std_logic;
SIGNAL avalon_burstbegin_rr:std_logic;
SIGNAL avalon_wait_request_r:std_logic;
SIGNAL avalon_write_r:std_logic;
SIGNAL avalon_read_r:std_logic;
SIGNAL avalon_writedata_r:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL avalon_byteenable_r:std_logic_vector(ddr_data_byte_width_c-1 downto 0);
SIGNAL busy:std_logic;
SIGNAL pending_burstbegin_r:std_logic;
BEGIN

avalon_addr_out <= avalon_addr_r;
avalon_burstlen_out <= avalon_burstlen_r;
avalon_burstbegin_out <= '0' when (avalon_burstbegin_rr='1' and avalon_wait_request_r='1') else avalon_burstbegin_r;
avalon_write_out <= avalon_write_r;
avalon_read_out <= avalon_read_r;
avalon_writedata_out <= avalon_writedata_r;
avalon_byteenable_out <= avalon_byteenable_r;

ddr_readdatavalid_out <= avalon_readdatavalid_in;
ddr_readdata_out <= avalon_readdata_in;
ddr_wait_request_out <= ((ddr_read_in or ddr_write_in) and busy);

busy <= ((avalon_write_r or avalon_read_r) and avalon_wait_request_in);

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       avalon_addr_r <= (others=>'0');
       avalon_burstlen_r <= (others=>'0');
       avalon_burstbegin_r <= '0';
       avalon_burstbegin_rr <= '0';
       avalon_write_r <= '0';
       avalon_read_r <= '0';
       avalon_writedata_r <= (others=>'0');
       avalon_byteenable_r <= (others=>'0');
       avalon_wait_request_r <= '0';
       pending_burstbegin_r <= '0';
    else
        if clock_in'event and clock_in='1' then
           avalon_burstbegin_rr <= avalon_burstbegin_r;
           avalon_wait_request_r <= avalon_wait_request_in;
           if busy='0' then
              avalon_addr_r <= ddr_addr_in;
              avalon_burstlen_r <= ddr_burstlen_in;
              if( ddr_burstlen_in = to_unsigned(0,ddr_burstlen_in'length)) then
                 avalon_write_r <= '0';
                 avalon_read_r <= '0';
                 avalon_burstbegin_r <= '0';
              else
                 avalon_write_r <= ddr_write_in;
                 avalon_read_r <= ddr_read_in;
                 avalon_burstbegin_r <= ddr_burstbegin_in or pending_burstbegin_r;
              end if;
              avalon_writedata_r <= ddr_writedata_in;
              avalon_byteenable_r <= ddr_byteenable_in;
              pending_burstbegin_r <= '0';
           elsif ddr_burstbegin_in='1' and (ddr_burstlen_in /= to_unsigned(0,ddr_burstlen_in'length)) then
              pending_burstbegin_r <= '1';
           end if;
        end if;
    end if;
end process;

END behaviour;
