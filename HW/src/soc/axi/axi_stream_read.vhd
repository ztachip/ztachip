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

-----------------------------------------------------------------------------
-- Engine for streaming from DDR to AXI-stream read interface
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity axi_stream_read is
   generic (
      READ_BUF_DEPTH       : integer:=4;
      READ_STREAM_DEPTH    : integer:=9;
      READ_PAGE_SIZE       : integer:=64;
      READ_MAX_PENDING     : integer:=4
   );
   port 
   (
      signal clock_in          : IN std_logic;
      signal reset_in          : IN std_logic;
      
      -- DDR write bus
      
      ddr_araddr_out           : OUT axi_araddr_t;
      ddr_arlen_out            : OUT axi_arlen_t;
      ddr_arvalid_out          : OUT axi_arvalid_t;
      ddr_arid_out             : OUT axi_arid_t;
      ddr_arlock_out           : OUT axi_arlock_t;
      ddr_arcache_out          : OUT axi_arcache_t;
      ddr_arprot_out           : OUT axi_arprot_t;
      ddr_arqos_out            : OUT axi_arqos_t;
      ddr_rid_in               : IN axi_rid_t;
      ddr_rvalid_in            : IN axi_rvalid_t;
      ddr_rlast_in             : IN axi_rlast_t;
      ddr_rdata_in             : IN STD_LOGIC_VECTOR(31 downto 0);
      ddr_rresp_in             : IN axi_rresp_t;
      ddr_arready_in           : IN axi_arready_t;
      ddr_rready_out           : OUT axi_rready_t;
      ddr_arburst_out          : OUT axi_arburst_t;
      ddr_arsize_out           : OUT axi_arsize_t;
      
      -- Streaming write bus (camera->DDR)

      signal s_rclk_in         : in std_logic;
      signal s_rdata_out       : out std_logic_vector(31 downto 0);
      signal s_rready_in       : in std_logic;
      signal s_rvalid_out      : out std_logic;
      signal s_rlast_out       : out std_logic;
      
      -- APB bus signal

      signal apb_paddr          : IN STD_LOGIC_VECTOR(19 downto 0);
      signal apb_penable        : IN STD_LOGIC;
      signal apb_pready         : OUT STD_LOGIC;
      signal apb_pwrite         : IN STD_LOGIC;
      signal apb_pwdata         : IN STD_LOGIC_VECTOR(31 downto 0);
      signal apb_prdata         : OUT STD_LOGIC_VECTOR(31 downto 0);
      signal apb_pslverror      : OUT STD_LOGIC
   );
end axi_stream_read;

architecture rtl of axi_stream_read is

signal read_fifo_empty:std_logic;
signal read_fifo_full:std_logic;
signal read_fifo_rd:std_logic;
signal read_fifo_wr:std_logic;
signal read_size_r:unsigned(23 downto 0); 
signal ddr_araddr_r:axi_awaddr_t;
signal ready_r:std_logic;
signal in_progress_r:std_logic;
signal s_rcurr_r:unsigned(READ_BUF_DEPTH-1 downto 0);
signal s_rcurr_next:unsigned(READ_BUF_DEPTH-1 downto 0);
signal ddr_arvalid:std_logic;
signal ddr_rready:std_logic;
signal s_rbuf_r :axi_awaddrs_t(2**READ_BUF_DEPTH-1 downto 0);
signal apb_rvdma_enable_match:std_logic;
signal apb_rvdma_buf0_match:std_logic;
signal apb_rvdma_buf1_match:std_logic;
signal apb_rvdma_buf2_match:std_logic;
signal apb_rvdma_buf3_match:std_logic;
signal apb_rvdma_get_curr_match:std_logic;
signal apb_match:std_logic;
signal s_ready_r:std_logic;
signal read_fifo_write:std_logic_vector(32 downto 0);
signal read_fifo_read:std_logic_vector(32 downto 0);
signal rlast_r:std_logic;
constant stride_c:integer:=4*READ_MAX_PENDING;
begin

--s_rcurr_next <= s_rcurr_r+to_unsigned(1,s_rcurr_r'length);

s_rcurr_next <= s_rcurr_r;
    
apb_rvdma_enable_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_rvdma_enable_c,apb_addr_len_c)))
                          else '0';

apb_rvdma_buf0_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_rvdma_buf0_c,apb_addr_len_c)))
                          else '0';
                          
apb_rvdma_buf1_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_rvdma_buf1_c,apb_addr_len_c)))
                          else '0';
                          
apb_rvdma_buf2_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_rvdma_buf2_c,apb_addr_len_c)))
                          else '0';
    
apb_rvdma_buf3_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_rvdma_buf3_c,apb_addr_len_c)))
                          else '0';

apb_rvdma_get_curr_match <= '1' when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_rvdma_get_curr_c,apb_addr_len_c)))
                          else '0';
                          
apb_match <= '1' when (apb_rvdma_enable_match='1' or apb_rvdma_buf0_match='1' or
                       apb_rvdma_buf1_match='1' or apb_rvdma_buf2_match='1' or
                       apb_rvdma_buf3_match='1' or apb_rvdma_get_curr_match='1')
                       else
                       '0'; 
                  
apb_pready <= '1' when (apb_match='1' and apb_penable='1') else 'Z';

apb_pslverror <= '0' when (apb_match='1' and apb_penable='1') else 'Z';                      
     
apb_prdata(apb_prdata'length-1 downto s_rcurr_r'length) <= 
                                           (others=>'0') 
                                           when 
                                           (apb_rvdma_get_curr_match='1' and apb_penable='1' and apb_pwrite='0') 
                                           else 
                                           (others=>'Z');
                                           
apb_prdata(s_rcurr_r'length-1 downto 0) <= std_logic_vector(s_rcurr_r) 
                                           when 
                                           (apb_rvdma_get_curr_match='1' and apb_penable='1' and apb_pwrite='0') 
                                           else 
                                           (others=>'Z');   
   
read_fifo_write(31 downto 0) <= ddr_rdata_in;

read_fifo_write(32) <= ddr_rlast_in and rlast_r;

s_rdata_out <= read_fifo_read(31 downto 0);

s_rlast_out <= read_fifo_read(32);
       
read_fifo:afifo
   generic map
   (
      DATA_WIDTH=>33,
      FIFO_DEPTH=>READ_STREAM_DEPTH
   )
   port map 
   (
      rclock_in=>s_rclk_in,
      wclock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>read_fifo_write,
      write_in=>read_fifo_wr,
      read_in=>read_fifo_rd,
      q_out=>read_fifo_read,
      empty_out=>read_fifo_empty,
      full_out=>read_fifo_full
   );

ddr_araddr_out <= ddr_araddr_r;
ddr_arvalid <= ddr_arready_in and (not in_progress_r) and ready_r;
ddr_arvalid_out <= ddr_arvalid;
ddr_arlen_out <= std_logic_vector(to_unsigned(stride_c/4-1,ddr_arlen_out'length));
ddr_arsize_out <= "010";
ddr_arburst_out <= "01";
ddr_arcache_out <= (others=>'0');
ddr_arid_out <= (others=>'0');
ddr_arlock_out <= (others=>'0');
ddr_arprot_out <= (others=>'0');
ddr_arqos_out <= (others=>'0');
ddr_rready <= (not read_fifo_full);
ddr_rready_out <= ddr_rready;

read_fifo_wr <= ddr_rvalid_in and ddr_rready; 

s_rvalid_out <= (not read_fifo_empty) and s_ready_r;

read_fifo_rd <= '1' when (read_fifo_empty='0' and s_rready_in='1') else '0';	

process(s_rclk_in,reset_in)
begin
   if reset_in='0' then
      s_ready_r <= '0';
   else
      if s_rclk_in'event and s_rclk_in='1' then
         if(s_ready_r='0') then
            s_ready_r <= read_fifo_full;
         end if;
      end if;
   end if;
end process;

process(clock_in,reset_in)
begin
   if reset_in='0' then
      in_progress_r <= '0';
      rlast_r <= '0';
      ready_r <= '0';
      read_size_r <= (others=>'0');
      ddr_araddr_r <= (others=>'0');
      s_rcurr_r <= (others=>'0');
      s_rbuf_r <= (others=>(others=>'0'));
   else
      if clock_in'event and clock_in='1' then
         if ddr_arvalid='1' then
            if(read_size_r < to_unsigned(READ_PAGE_SIZE-stride_c,read_size_r'length)) then
               read_size_r <= read_size_r + to_unsigned(stride_c,read_size_r'length);
               ddr_araddr_r <= std_logic_vector(unsigned(ddr_araddr_r) + to_unsigned(stride_c,ddr_araddr_r'length));
               rlast_r <= '0';
            else
               read_size_r <= (others=>'0');
               ddr_araddr_r <= s_rbuf_r(to_integer(s_rcurr_next));
               s_rcurr_r <= s_rcurr_next; 
               rlast_r <= '1';
            end if;
            in_progress_r <= '1';
         end if;
         
         if(ddr_rvalid_in='1' and ddr_rlast_in='1' and ddr_rready='1') then
            in_progress_r <= '0';
         end if; 
               
         -- Process APB bus request
         
         if(apb_penable='1') then
            if(apb_rvdma_enable_match='1') then
               ready_r <= apb_pwdata(0);
               if(apb_pwdata(0)='1') then
                  read_size_r <= (others=>'0');
                  s_rcurr_r <= (others=>'0');
                  ddr_araddr_r <= s_rbuf_r(0);
               end if;
            end if;
            if(apb_rvdma_buf0_match='1') then
               s_rbuf_r(0) <= apb_pwdata;
            end if;
            if(apb_rvdma_buf1_match='1') then
               s_rbuf_r(1) <= apb_pwdata;
            end if;
            if(apb_rvdma_buf2_match='1') then
               s_rbuf_r(2) <= apb_pwdata;
            end if;
            if(apb_rvdma_buf3_match='1') then
               s_rbuf_r(3) <= apb_pwdata;
            end if;
         end if;          
      end if;
   end if;
end process;

end rtl;