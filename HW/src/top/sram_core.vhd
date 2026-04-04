------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Author: Vuong Nguyen
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
use work.ztachip_pkg.all;

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
         SIGNAL dp_write_wait_out       : OUT STD_LOGIC;
         SIGNAL dp_write_vector_in      : IN dp_vector_t;
         SIGNAL dp_read_in              : IN STD_LOGIC;
         SIGNAL dp_read_wait_out        : OUT STD_LOGIC;
         SIGNAL dp_read_vm_in           : IN STD_LOGIC;
         SIGNAL dp_read_vector_in       : IN dp_vector_t;
         SIGNAL dp_read_gen_valid_in    : IN STD_LOGIC;
         SIGNAL dp_writedata_in         : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
         SIGNAL dp_readdatavalid_out    : OUT STD_LOGIC;
         SIGNAL dp_readdatavalid_vm_out : OUT STD_LOGIC;
         SIGNAL dp_readdata_out         : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);

         -- FPU interface
         
         SIGNAL fpu_rd_addr_in           : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
         SIGNAL fpu_wr_addr_in           : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
         SIGNAL fpu_write_in             : IN STD_LOGIC;
         SIGNAL fpu_write_wait_out       : OUT STD_LOGIC;
         SIGNAL fpu_read_in              : IN STD_LOGIC;
         SIGNAL fpu_read_wait_out        : OUT STD_LOGIC;
         SIGNAL fpu_writedata_in         : IN STD_LOGIC_VECTOR(fpu_data_width_c-1 DOWNTO 0);
         SIGNAL fpu_writebe_in           : IN STD_LOGIC_VECTOR(fpu_data_width_c/8-1 DOWNTO 0);
         SIGNAL fpu_readdatavalid_out    : OUT STD_LOGIC;
         SIGNAL fpu_readdata_out         : OUT STD_LOGIC_VECTOR(fpu_data_width_c-1 DOWNTO 0);

         -- AXI interface for RISCV to access
         SIGNAL axislave_araddr_in      : IN STD_LOGIC_VECTOR(31 downto 0);
         SIGNAL axislave_arburst_in     : IN STD_LOGIC_VECTOR(1 downto 0);
         SIGNAL axislave_arlen_in       : IN STD_LOGIC_VECTOR(7 downto 0);
         SIGNAL axislave_arready_out    : OUT STD_LOGIC;
         SIGNAL axislave_arsize_in      : IN STD_LOGIC_VECTOR(2 downto 0);
         SIGNAL axislave_arvalid_in     : IN STD_LOGIC;
         SIGNAL axislave_rdata_out      : OUT STD_LOGIC_VECTOR(31 downto 0);
         SIGNAL axislave_rlast_out      : OUT STD_LOGIC;
         SIGNAL axislave_rready_in      : IN STD_LOGIC;
         SIGNAL axislave_rresp_out      : OUT STD_LOGIC_VECTOR(1 downto 0);
         SIGNAL axislave_rvalid_out     : OUT STD_LOGIC
    );
END sram_core;

ARCHITECTURE behavior OF sram_core IS

type SOURCE is (SOURCE_NONE,SOURCE_AXI,SOURCE_DP,SOURCE_FPU);

SIGNAL sram_write:STD_LOGIC_VECTOR(sram_num_bank_c-1 downto 0);
SIGNAL sram_read:STD_LOGIC_VECTOR(sram_num_bank_c-1 downto 0);
SIGNAL sram_readdatavalid:STD_LOGIC_VECTOR(sram_num_bank_c-1 downto 0);
SIGNAL sram_readdata_0:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 DOWNTO 0);
SIGNAL sram_readdata_1:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 DOWNTO 0);

SIGNAL dp_read_vm_r:STD_LOGIC;
SIGNAL dp_read_vm_rr:STD_LOGIC;
SIGNAL dp_read_vm_rrr:STD_LOGIC;
SIGNAL dp_read_vm_rrrr:STD_LOGIC;

SIGNAL read_source_0_r:SOURCE;
SIGNAL read_source_0_rr:SOURCE;
SIGNAL read_source_0_rrr:SOURCE;
SIGNAL read_source_0_rrrr:SOURCE;

SIGNAL read_source_1_r:SOURCE;
SIGNAL read_source_1_rr:SOURCE;
SIGNAL read_source_1_rrr:SOURCE;
SIGNAL read_source_1_rrrr:SOURCE;

SIGNAL read_addr_0:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
SIGNAL read_source_0:SOURCE;
SIGNAL read_vector_0:std_logic_vector(ddr_vector_depth_c+1-1 downto 0);
SIGNAL read_gen_valid_0:STD_LOGIC;
SIGNAL read_vm_0:STD_LOGIC;

SIGNAL read_addr_1:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
SIGNAL read_source_1:SOURCE;
SIGNAL read_vector_1:std_logic_vector(ddr_vector_depth_c+1-1 downto 0);
SIGNAL read_gen_valid_1:STD_LOGIC;
SIGNAL read_vm_1:STD_LOGIC;

SIGNAL write_addr_0:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
SIGNAL write_source_0:SOURCE;
SIGNAL write_vector_0:std_logic_vector(ddr_vector_depth_c+1-1 downto 0);
SIGNAL writedata_0:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 DOWNTO 0);
SIGNAL writebe_0:STD_LOGIC_VECTOR(2*ddr_data_width_c/8-1 DOWNTO 0);

SIGNAL write_addr_1:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);        
SIGNAL write_source_1:SOURCE;
SIGNAL write_vector_1:std_logic_vector(ddr_vector_depth_c+1-1 downto 0);
SIGNAL writedata_1:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 DOWNTO 0);
SIGNAL writebe_1:STD_LOGIC_VECTOR(2*ddr_data_width_c/8-1 DOWNTO 0);

SIGNAL axi_read:STD_LOGIC;
SIGNAL axi_rd_addr:STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
SIGNAL axi_readdata:STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL axi_readdatavalid:STD_LOGIC;
BEGIN

dp_read_wait_out <= '1' when (dp_read_in='1') and (read_source_0/=SOURCE_DP) and (read_source_1/=SOURCE_DP) else '0';

fpu_read_wait_out <= '1' when (fpu_read_in='1') and (read_source_0/=SOURCE_FPU) and (read_source_1/=SOURCE_FPU) else '0';

dp_write_wait_out <= '1' when (dp_write_in='1') and (write_source_0/=SOURCE_DP) and (write_source_1/=SOURCE_DP) else '0';

fpu_write_wait_out <= '1' when (fpu_write_in='1') and (write_source_0/=SOURCE_FPU) and (write_source_1/=SOURCE_FPU) else '0';

-- Muxing read request

process(axi_read,axi_rd_addr,
         fpu_read_in,fpu_rd_addr_in,
         dp_read_in,dp_rd_addr_in,dp_read_vector_in,
         dp_read_gen_valid_in,dp_read_vm_in)
begin
   read_source_0 <= SOURCE_NONE;
   read_addr_0 <= (others=>'0');
   read_vector_0 <= (others=>'0');
   read_gen_valid_0 <= '0';
   read_vm_0 <= '0';

   read_source_1 <= SOURCE_NONE;
   read_addr_1 <= (others=>'0');
   read_vector_1 <= (others=>'0');
   read_gen_valid_1 <= '0';
   read_vm_1 <= '0';

   if(dp_read_in='1') then
      if(dp_rd_addr_in(sram_depth_c-1)='0') then
         read_source_0 <= SOURCE_DP;
         read_addr_0 <= dp_rd_addr_in;
         read_vector_0 <= "0" & dp_read_vector_in;
         read_gen_valid_0 <= dp_read_gen_valid_in;
         read_vm_0 <= dp_read_vm_in;
      else
         read_source_1 <= SOURCE_DP;
         read_addr_1 <= dp_rd_addr_in;
         read_vector_1 <= "0" & dp_read_vector_in;
         read_gen_valid_1 <= dp_read_gen_valid_in;
         read_vm_1 <= dp_read_vm_in;
      end if;
   end if;

   if(fpu_read_in='1') then
      if(fpu_rd_addr_in(sram_depth_c-1)='0') then
         read_source_0 <= SOURCE_FPU;
         read_addr_0 <= fpu_rd_addr_in;
         read_vector_0 <= (others=>'1');
         read_gen_valid_0 <= '1';
         read_vm_0 <= '0'; 
      else
         read_source_1 <= SOURCE_FPU;
         read_addr_1 <= fpu_rd_addr_in;
         read_vector_1 <= (others=>'1');
         read_gen_valid_1 <= '1';
         read_vm_1 <= '0';
      end if;
   end if;

   if(axi_read='1') then
      if(axi_rd_addr(sram_depth_c-1)='0') then
         read_source_0 <= SOURCE_AXI;
         read_addr_0 <= axi_rd_addr;
         read_vector_0 <= "0" & std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,dp_vector_t'length));
         read_gen_valid_0 <= '1';
         read_vm_0 <= '0';
      else
         read_source_1 <= SOURCE_AXI;
         read_addr_1 <= axi_rd_addr;
         read_vector_1 <= "0" & std_logic_vector(to_unsigned(ddr_vector_width_c/2-1,dp_vector_t'length));
         read_gen_valid_1 <= '1';
         read_vm_1 <= '0';
      end if;
   end if;
end process;

-- Muxing write requests

process(dp_wr_addr_in,dp_write_in,dp_write_vector_in,dp_writedata_in,
      fpu_write_in,fpu_wr_addr_in,fpu_writedata_in,fpu_writebe_in)
begin
   write_addr_0 <= (others=>'0');        
   write_source_0 <= SOURCE_NONE;
   write_vector_0 <= (others=>'0');
   writedata_0 <= (others=>'0');
   writebe_0 <= (others=>'0');
   write_addr_1 <= (others=>'0');        
   write_source_1 <= SOURCE_NONE;
   write_vector_1 <= (others=>'0');
   writedata_1 <= (others=>'0');
   writebe_1 <= (others=>'0');

   if(dp_write_in='1') then
      if(dp_wr_addr_in(sram_depth_c-1)='0') then
         write_addr_0 <= dp_wr_addr_in;        
         write_source_0 <= SOURCE_DP;
         write_vector_0 <= "0" & dp_write_vector_in;
         writedata_0 <= dp_writedata_in & dp_writedata_in;
         writebe_0 <= (others=>'1');
      else
         write_addr_1 <= dp_wr_addr_in;        
         write_source_1 <= SOURCE_DP;
         write_vector_1 <= "0" & dp_write_vector_in;
         writedata_1 <= dp_writedata_in & dp_writedata_in;
         writebe_1 <= (others=>'1');
      end if;
   end if;
   if(fpu_write_in='1') then
      if(fpu_wr_addr_in(sram_depth_c-1)='0') then
         write_addr_0 <= fpu_wr_addr_in;        
         write_source_0 <= SOURCE_FPU;
         write_vector_0 <= (others=>'1');
         writedata_0 <= fpu_writedata_in;
         writebe_0 <= fpu_writebe_in;
      else
         write_addr_1 <= fpu_wr_addr_in;        
         write_source_1 <= SOURCE_FPU;
         write_vector_1 <= (others=>'1');
         writedata_1 <= fpu_writedata_in;
         writebe_1 <= fpu_writebe_in;
      end if;
   end if;
end process;

-- MUX sram_write access to the bank

process(write_source_0,write_source_1)
begin
   if(write_source_0 = SOURCE_NONE) then
      sram_write(0) <= '0';
   else
      sram_write(0) <= '1';
   end if;
   if(write_source_1 = SOURCE_NONE) then
      sram_write(1) <= '0';
   else
      sram_write(1) <= '1';
   end if;
end process;

-- MUX sram_read access to the bank

process(read_source_0,read_source_1)
begin
   if(read_source_0 = SOURCE_NONE) then
      sram_read(0) <= '0';
   else
      sram_read(0) <= '1';
   end if;
   if(read_source_1 = SOURCE_NONE) then
      sram_read(1) <= '0';
   else
      sram_read(1) <= '1';
   end if;
end process;

-- MUX read access response

process(sram_readdatavalid,sram_readdata_0,sram_readdata_1,dp_read_vm_rrrr,read_source_0_rrrr,read_source_1_rrrr)
begin
   dp_readdatavalid_vm_out <= dp_read_vm_rrrr;
   if(read_source_0_rrrr=SOURCE_DP) then
      dp_readdatavalid_out <= '1';
      dp_readdata_out(ddr_data_width_c-1 downto 0) <= sram_readdata_0(ddr_data_width_c-1 downto 0);
   elsif (read_source_1_rrrr=SOURCE_DP) then
      dp_readdatavalid_out <= '1';
      dp_readdata_out(ddr_data_width_c-1 downto 0) <= sram_readdata_1(ddr_data_width_c-1 downto 0);
   else
      dp_readdatavalid_out <= '0';
      dp_readdata_out <= (others=>'0');
   end if;

   if(read_source_0_rrrr=SOURCE_AXI) then
      axi_readdatavalid <= '1';
      axi_readdata <= sram_readdata_0(31 downto 0);
   elsif(read_source_1_rrrr=SOURCE_AXI) then
      axi_readdatavalid <= '1';
      axi_readdata <= sram_readdata_1(31 downto 0);
   else
      axi_readdatavalid <= '0';
      axi_readdata <= (others=>'0');
   end if;

   if(read_source_0_rrrr=SOURCE_FPU) then
      fpu_readdatavalid_out <= '1';
      fpu_readdata_out <= sram_readdata_0;
   elsif(read_source_1_rrrr=SOURCE_FPU) then
      fpu_readdatavalid_out <= '1';
      fpu_readdata_out <= sram_readdata_1;
   else
      fpu_readdatavalid_out <= '0';   
      fpu_readdata_out <= (others=>'0');
   end if;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       dp_read_vm_r <= '0';
       dp_read_vm_rr <= '0';
       dp_read_vm_rrr <= '0';
       dp_read_vm_rrrr <= '0';

       read_source_0_r <= SOURCE_NONE;
       read_source_0_rr <= SOURCE_NONE;
       read_source_0_rrr <= SOURCE_NONE;
       read_source_0_rrrr <= SOURCE_NONE;

       read_source_1_r <= SOURCE_NONE;
       read_source_1_rr <= SOURCE_NONE;
       read_source_1_rrr <= SOURCE_NONE;
       read_source_1_rrrr <= SOURCE_NONE;
    else
        if clock_in'event and clock_in='1' then
           dp_read_vm_r <= dp_read_vm_in;
           dp_read_vm_rr <= dp_read_vm_r;
           dp_read_vm_rrr <= dp_read_vm_rr;
           dp_read_vm_rrrr <= dp_read_vm_rrr;

           read_source_0_r <= read_source_0;
           read_source_0_rr <= read_source_0_r;
           read_source_0_rrr <= read_source_0_rr;
           read_source_0_rrrr <= read_source_0_rrr;

           read_source_1_r <= read_source_1;
           read_source_1_rr <= read_source_1_r;
           read_source_1_rrr <= read_source_1_rr;
           read_source_1_rrrr <= read_source_1_rrr;
        end if;
    end if;
end process;

axi_ifc_i: axi_ram_read
   generic map(
      RAM_DEPTH=>sram_depth_c,
      RAM_LATENCY=>4
   )
   port map(   
      axislave_clock_in => clock_in,
      axislave_reset_in => reset_in,
      axislave_araddr_in => axislave_araddr_in,
      axislave_arburst_in => axislave_arburst_in,
      axislave_arlen_in => axislave_arlen_in,
      axislave_arready_out => axislave_arready_out,
      axislave_arsize_in => axislave_arsize_in,
      axislave_arvalid_in => axislave_arvalid_in,
      axislave_rdata_out => axislave_rdata_out,
      axislave_rlast_out => axislave_rlast_out,
      axislave_rready_in => axislave_rready_in,
      axislave_rresp_out => axislave_rresp_out,
      axislave_rvalid_out => axislave_rvalid_out,

      ram_q_in => axi_readdata,
      ram_raddr_out => axi_rd_addr,
      ram_read_out => axi_read
   );


sram_0_i : sram
   GENERIC MAP(
      DEPTH=>sram_bank_depth_c
   )
   PORT MAP (
      clock_in => clock_in,
      reset_in => reset_in,
      dp_rd_addr_in => read_addr_0(sram_bank_depth_c-1 downto 0),
      dp_wr_addr_in => write_addr_0(sram_bank_depth_c-1 downto 0),
      dp_write_in => sram_write(0),
      dp_write_vector_in=>write_vector_0,
      dp_read_in=>sram_read(0),
      dp_read_vector_in=>read_vector_0,
      dp_read_gen_valid_in=>read_gen_valid_0,
      dp_writedata_in=>writedata_0,
      dp_writebe_in=>writebe_0,
      dp_readdatavalid_out=>sram_readdatavalid(0),
      dp_readdata_out => sram_readdata_0
   );

sram_1_i : sram
   GENERIC MAP(
      DEPTH=>sram_bank_depth_c
   )
   PORT MAP (
      clock_in => clock_in,
      reset_in => reset_in,
      dp_rd_addr_in => read_addr_1(sram_bank_depth_c-1 downto 0),
      dp_wr_addr_in => write_addr_1(sram_bank_depth_c-1 downto 0),
      dp_write_in => sram_write(1),
      dp_write_vector_in=>write_vector_1,
      dp_read_in=>sram_read(1),
      dp_read_vector_in=>read_vector_1,
      dp_read_gen_valid_in=>read_gen_valid_1,
      dp_writedata_in=>writedata_1,
      dp_writebe_in=>writebe_1,
      dp_readdatavalid_out=>sram_readdatavalid(1),
      dp_readdata_out => sram_readdata_1
   );

END behavior;
