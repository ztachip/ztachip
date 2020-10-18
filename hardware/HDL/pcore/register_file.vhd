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
-- Description:
-- Implement register file with 2 read port and 1 write port
-- Every write operations are performed on 2 RAM bank.
-- Each read port is assigned to a RAM bank
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY register_file IS
   PORT( 
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;

        SIGNAL rd_en_in        : IN STD_LOGIC;
        SIGNAL rd_en_out       : OUT STD_LOGIC;
        SIGNAL rd_x1_vector_in : IN STD_LOGIC;
        SIGNAL rd_x1_addr_in   : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 1
        SIGNAL rd_x2_vector_in : IN STD_LOGIC;
        SIGNAL rd_x2_addr_in   : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Read address of port 2
        SIGNAL rd_x1_data_out  : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 1
        SIGNAL rd_x2_data_out  : OUT STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Read value returned to port 2

        SIGNAL wr_en_in        : IN STD_LOGIC; -- Write enable
        SIGNAL wr_vector_in    : IN STD_LOGIC;
        SIGNAL wr_addr_in      : IN STD_LOGIC_VECTOR(register_file_depth_c-1 DOWNTO 0); -- Write address
        SIGNAL wr_data_in      : IN STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); -- Write value
        SIGNAL wr_lane_in      : IN STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);

        -- DP interface
        SIGNAL dp_rd_vector_in    : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_in   : IN scatter_t;
        SIGNAL dp_rd_scatter_cnt_in: IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_scatter_vector_in: IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_rd_gen_valid_in : IN STD_LOGIC;
        SIGNAL dp_rd_data_flow_in : IN data_flow_t;
        SIGNAL dp_rd_data_type_in : IN dp_data_type_t;
        SIGNAL dp_rd_stream_in    : IN std_logic;
        SIGNAL dp_rd_stream_id_in : stream_id_t;
        SIGNAL dp_rd_addr_in      : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_vector_in    : IN unsigned(ddr_vector_depth_c-1 downto 0);
        SIGNAL dp_wr_addr_in      : IN STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
        SIGNAL dp_write_in        : IN STD_LOGIC;
        SIGNAL dp_read_in         : IN STD_LOGIC;
        SIGNAL dp_writedata_in    : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readdata_out    : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
        SIGNAL dp_readena_out     : OUT STD_LOGIC
        );
END register_file;

ARCHITECTURE behavior OF register_file IS

constant lane_byte_width_c:integer:=(register_width_c+7)/8;
constant byte_width_c:integer:=(lane_byte_width_c*vector_width_c);
constant ram_register_width_c:integer:=(lane_byte_width_c*8);

constant DEPTH:integer:=register_file_depth_c-vector_depth_c;
constant WIDTH:integer:=(ram_register_width_c*vector_width_c);

constant ACTUAL_DEPTH:integer:=register_actual_file_depth_c-vector_depth_c;

SIGNAL wr_lane:STD_LOGIC_VECTOR(vector_width_c-1 DOWNTO 0);
SIGNAL rd_x1_addr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL rd_x2_addr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL wr_addr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL wr_data:STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0); 
SIGNAL wr_data2:STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
SIGNAL wr_en:STD_LOGIC;
SIGNAL rd_en_r:STD_LOGIC;
SIGNAL rd_en_rr:STD_LOGIC;
SIGNAL q1:STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
SIGNAL q2:STD_LOGIC_VECTOR(vregister_width_c-1 DOWNTO 0);
SIGNAL dp_rd_en_r:STD_LOGIC;
SIGNAL dp_rd_en_rr:STD_LOGIC;
SIGNAL wr_vaddr:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);

SIGNAL wr_vector:unsigned(vector_depth_c-1 downto 0);
SIGNAL byteena:STD_LOGIC_VECTOR(byte_width_c-1 downto 0);

SIGNAL dp_rd_addr:STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_addr:STD_LOGIC_VECTOR(bus_width_c-1 DOWNTO 0);

SIGNAL dp_writedata:STD_LOGIC_VECTOR(register_width_c*ddr_vector_width_c-1 DOWNTO 0);

SIGNAL wr_data2_ram:STD_LOGIC_VECTOR(ram_register_width_c*vector_width_c-1 DOWNTO 0);
SIGNAL q1_ram:STD_LOGIC_VECTOR(ram_register_width_c*vector_width_c-1 DOWNTO 0);
SIGNAL q1_ram_r:STD_LOGIC_VECTOR(ram_register_width_c*vector_width_c-1 DOWNTO 0);
SIGNAL q2_ram:STD_LOGIC_VECTOR(ram_register_width_c*vector_width_c-1 DOWNTO 0);
SIGNAL q2_ram_r:STD_LOGIC_VECTOR(ram_register_width_c*vector_width_c-1 DOWNTO 0);

constant all_zeros_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'0');

COMPONENT altsyncram
GENERIC (
        address_aclr_b          : STRING;
        address_reg_b           : STRING;
        clock_enable_input_a    : STRING;
        clock_enable_input_b    : STRING;
        clock_enable_output_b   : STRING;
        intended_device_family  : STRING;
		ram_block_type          : STRING;
        lpm_type                : STRING;
        numwords_a              : NATURAL;
        numwords_b              : NATURAL;
        operation_mode          : STRING;
        outdata_aclr_b          : STRING;
        outdata_reg_b           : STRING;
        power_up_uninitialized  : STRING;
        read_during_write_mode_mixed_ports : STRING;
        widthad_a               : NATURAL;
        widthad_b               : NATURAL;
        width_a                 : NATURAL;
        width_b                 : NATURAL;
        width_byteena_a         : NATURAL
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

-- Set output signals...
dp_rd_addr <= dp_rd_addr_in;
dp_wr_addr <= dp_wr_addr_in;

dp_readena_out <= dp_rd_en_rr;    

rd_x1_data_out <= q1;

rd_x2_data_out <= q2;

rd_en_out <= rd_en_rr;

wr_en <= '1' when (dp_write_in='1' or wr_en_in='1') else '0';
wr_addr <= wr_addr_in(register_file_depth_c-1 downto vector_depth_c) when (wr_en_in='1') else dp_wr_addr(register_file_depth_c-1 DOWNTO vector_depth_c);

wr_vaddr <= wr_addr_in(vector_depth_c-1 downto 0) when (wr_en_in='1') else dp_wr_addr(vector_depth_c-1 DOWNTO 0);

wr_data <= wr_data_in when (wr_en_in='1') else (dp_writedata);

wr_vector <= (others=>wr_vector_in) when (wr_en_in='1') else resize(dp_wr_vector_in,vector_depth_c);

wr_lane <= wr_lane_in when (wr_en_in='1') else (others=>'1');

-- Set write data ans its byteena

rd_x1_addr <= rd_x1_addr_in(register_file_depth_c-1 downto vector_depth_c);

rd_x2_addr <= rd_x2_addr_in(register_file_depth_c-1 downto vector_depth_c) when (rd_en_in='1') else dp_rd_addr(register_file_depth_c-1 downto vector_depth_c);

dp_writedata <= dp_writedata_in;

dp_readdata_out <= q2;


process(wr_vector,wr_vaddr,wr_lane)
variable mask_v:STD_LOGIC_VECTOR(vector_depth_c-1 downto 0);
begin
if wr_vector=to_unsigned(vector_width_c-1,wr_vector'length) then
   for I in 0 to vector_width_c-1 loop
      byteena((lane_byte_width_c*(I+1)-1) downto lane_byte_width_c*I) <= (others=>(wr_lane(I)));
   end loop;  
else
   mask_v := not std_logic_vector(wr_vector);
   for I in 0 to vector_width_c-1 loop
   if (std_logic_vector(to_unsigned(I,mask_v'length)) and mask_v)=(wr_vaddr and mask_v) then
      byteena((I+1)*lane_byte_width_c-1 downto I*lane_byte_width_c) <= (others=>'1');
   else
      byteena((I+1)*lane_byte_width_c-1 downto I*lane_byte_width_c) <= (others=>'0');
   end if;
   end loop;
end if;
end process;

process(wr_en_in,wr_vector,wr_data,wr_lane,dp_wr_addr,wr_vaddr)
begin
  if unsigned(wr_vector)=to_unsigned(vector_width_c/8-1,wr_vector'length) then
      wr_data2 <= wr_data(register_width_c-1 downto 0) & 
                  wr_data(register_width_c-1 downto 0) & 
                  wr_data(register_width_c-1 downto 0) & 
                  wr_data(register_width_c-1 downto 0) & 
                  wr_data(register_width_c-1 downto 0) & 
                  wr_data(register_width_c-1 downto 0) & 
                  wr_data(register_width_c-1 downto 0) & 
                  wr_data(register_width_c-1 downto 0);
  else
     wr_data2 <= wr_data;
  end if;
end process;

process(clock_in,reset_in)
begin
    if reset_in = '0' then
        rd_en_r <= '0';
		rd_en_rr <= '0';
		q1_ram_r <= (others=>'0');
		q2_ram_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            rd_en_r <= rd_en_in;
			rd_en_rr <= rd_en_r;
			q1_ram_r <= q1_ram;
			q2_ram_r <= q2_ram;
        end if;
    end if;
end process;

process(wr_data2,q1_ram_r,q2_ram_r)
begin    
  for I in 0 to vector_width_c-1 loop
     wr_data2_ram(I*ram_register_width_c+ram_register_width_c-1 downto I*ram_register_width_c+register_width_c) <= (others=>'-');    
     wr_data2_ram(I*ram_register_width_c+register_width_c-1 downto I*ram_register_width_c) <= wr_data2(I*register_width_c+register_width_c-1 downto I*register_width_c);
     q1(I*register_width_c+register_width_c-1 downto I*register_width_c) <= q1_ram_r(I*ram_register_width_c+register_width_c-1 downto I*ram_register_width_c);
     q2(I*register_width_c+register_width_c-1 downto I*register_width_c) <= q2_ram_r(I*ram_register_width_c+register_width_c-1 downto I*ram_register_width_c);
  end loop;
end process;

process(clock_in,reset_in)
begin
    if reset_in='0' then
        dp_rd_en_r <= '0';
		dp_rd_en_rr <= '0';
    else
        if clock_in'event and clock_in='1' then

            -- Access from DP needs to be slowed down by 1 more clock to match
            -- IREGISTER access

            if (dp_read_in='1') then
                dp_rd_en_r <= '1';
            else
                dp_rd_en_r <= '0';
            end if;
			dp_rd_en_rr <= dp_rd_en_r;
        end if;    
    end if;
end process;

----
-- Broadcast write commands to both register banks
-----

ram1_i : altsyncram
    GENERIC MAP (
        address_aclr_b => "NONE",
        address_reg_b => "CLOCK0",
        clock_enable_input_a => "BYPASS",
        clock_enable_input_b => "BYPASS",
        clock_enable_output_b => "BYPASS",
        intended_device_family => "Cyclone V",
		ram_block_type => "M10K",
        lpm_type => "altsyncram",
        numwords_a => 2**ACTUAL_DEPTH,
        numwords_b => 2**ACTUAL_DEPTH,
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => ACTUAL_DEPTH,
        widthad_b => ACTUAL_DEPTH,
        width_a => WIDTH,
        width_b => WIDTH,
        width_byteena_a => byte_width_c
    )
    PORT MAP (
        address_a => wr_addr(ACTUAL_DEPTH-1 downto 0),
        byteena_a => byteena,
        clock0 => clock_in,
        data_a => wr_data2_ram,
        wren_a => wr_en,
        address_b => rd_x1_addr(ACTUAL_DEPTH-1 downto 0),
        q_b => q1_ram
    );


------                                
-- Broadcast write commands to both register banks
-------


ram2_i : altsyncram
    GENERIC MAP (
        address_aclr_b => "NONE",
        address_reg_b => "CLOCK0",
        clock_enable_input_a => "BYPASS",
        clock_enable_input_b => "BYPASS",
        clock_enable_output_b => "BYPASS",
        intended_device_family => "Cyclone V",
		ram_block_type => "M10K",
        lpm_type => "altsyncram",
        numwords_a => 2**ACTUAL_DEPTH,
        numwords_b => 2**ACTUAL_DEPTH,
        operation_mode => "DUAL_PORT",
        outdata_aclr_b => "NONE",
        outdata_reg_b => "UNREGISTERED",
        power_up_uninitialized => "FALSE",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        widthad_a => ACTUAL_DEPTH,
        widthad_b => ACTUAL_DEPTH,
        width_a => WIDTH,
        width_b => WIDTH,
        width_byteena_a => byte_width_c
    )
    PORT MAP (
        address_a => wr_addr(ACTUAL_DEPTH-1 downto 0),
        byteena_a => byteena,
        clock0 => clock_in,
        data_a => wr_data2_ram,
        wren_a => wr_en,
        address_b => rd_x2_addr(ACTUAL_DEPTH-1 downto 0),
        q_b => q2_ram
    );


END behavior;
