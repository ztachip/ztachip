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
-- Provides cross clock domain bridge for AXI write interface 
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

entity axi_resize_write is
   generic (
      MASTER_DATA_WIDTH  : integer:=128;
      SLAVE_DATA_WIDTH   : integer:=32;
      FIFO_DEPTH         : integer:=4;
      FIFO_DATA_DEPTH    : integer:=4;
      CCD                : boolean:=TRUE
   );
   port 
   (
      clock_in                    : in std_logic;
      reset_in                    : in std_logic;

      -- Slace port
      axislave_clock_in           : IN std_logic;
      axislave_awaddr_in          : IN axi_awaddr_t;
      axislave_awlen_in           : IN axi_awlen_t;
      axislave_awvalid_in         : IN axi_awvalid_t;
      axislave_wvalid_in          : IN axi_wvalid_t;
      axislave_wdata_in           : IN STD_LOGIC_VECTOR(SLAVE_DATA_WIDTH-1 downto 0);
      axislave_wlast_in           : IN axi_wlast_t;
      axislave_wstrb_in           : IN STD_LOGIC_VECTOR((SLAVE_DATA_WIDTH/8)-1 downto 0);
      axislave_awready_out        : OUT axi_awready_t;
      axislave_wready_out         : OUT axi_wready_t;
      axislave_bresp_out          : OUT axi_bresp_t;
      axislave_bid_out            : OUT axi_bid_t;
      axislave_bvalid_out         : OUT axi_bvalid_t;
      axislave_awburst_in         : IN axi_awburst_t;
      axislave_awcache_in         : IN axi_awcache_t;
      axislave_awid_in            : IN axi_awid_t;
      axislave_awlock_in          : IN axi_awlock_t;
      axislave_awprot_in          : IN axi_awprot_t;
      axislave_awqos_in           : IN axi_awqos_t;
      axislave_awsize_in          : IN axi_awsize_t;
      axislave_bready_in          : IN axi_bready_t;
      
      -- Master port #1
      aximaster_clock_in          : IN std_logic;
      aximaster_awaddr_out        : OUT axi_awaddr_t;
      aximaster_awlen_out         : OUT axi_awlen_t;
      aximaster_awvalid_out       : OUT axi_awvalid_t;
      aximaster_wvalid_out        : OUT axi_wvalid_t;
      aximaster_wdata_out         : OUT STD_LOGIC_VECTOR(MASTER_DATA_WIDTH-1 downto 0);
      aximaster_wlast_out         : OUT axi_wlast_t;
      aximaster_wstrb_out         : OUT STD_LOGIC_VECTOR((MASTER_DATA_WIDTH/8)-1 downto 0);
      aximaster_awready_in        : IN axi_awready_t;
      aximaster_wready_in         : IN axi_wready_t;
      aximaster_bresp_in          : IN axi_bresp_t;
      aximaster_bid_in            : IN axi_bid_t;
      aximaster_bvalid_in         : IN axi_bvalid_t;
      aximaster_awburst_out       : OUT axi_awburst_t;
      aximaster_awcache_out       : OUT axi_awcache_t;
      aximaster_awid_out          : OUT axi_awid_t;
      aximaster_awlock_out        : OUT axi_awlock_t;
      aximaster_awprot_out        : OUT axi_awprot_t;
      aximaster_awqos_out         : OUT axi_awqos_t;
      aximaster_awsize_out        : OUT axi_awsize_t;
      aximaster_bready_out        : OUT axi_bready_t
   );
end axi_resize_write;

architecture rtl of axi_resize_write is

-- Record to hold AXIWRITE command signals
type axiwrite_cmd_rec_t is
record
   awaddr:axi_awaddr_t;
   awlen:axi_awlen_t;
   awburst:axi_awburst_t;
   awcache:axi_awcache_t;
   awid:axi_awid_t;
   awlock:axi_awlock_t;
   awprot:axi_awprot_t;
   awqos:axi_awqos_t;
   awsize:axi_awsize_t;
end record;

-- Flat buffer to hold axiwrite_cmd_rec_t
constant axiwrite_cmd_len_c:integer:=axi_awaddr_t'length+
                                     axi_awlen_t'length+
                                     axi_awburst_t'length+
                                     axi_awcache_t'length+
                                     axi_awid_t'length+
                                     axi_awlock_t'length+
                                     axi_awprot_t'length+
                                     axi_awqos_t'length+
                                     axi_awsize_t'length;
subtype axiwrite_cmd_fifo_t is std_logic_vector(axiwrite_cmd_len_c-1 downto 0);

-- Record to hold AXIWRITE DATA signals
type axiwrite_data_rec_t is
record
   wdata:std_logic_vector(SLAVE_DATA_WIDTH-1 downto 0);
   wlast:axi_wlast_t;
   wstrb:std_logic_vector((SLAVE_DATA_WIDTH/8)-1 downto 0);
end record;

constant axiwrite_data_len_c:integer:=SLAVE_DATA_WIDTH+
                                      1+
                                      (SLAVE_DATA_WIDTH/8);

-- Flat buffer to hold axiread_cmd_rec_t
subtype axiwrite_data_fifo_t is std_logic_vector(axiwrite_data_len_c-1 downto 0);

-- Record to hold AXIWRITE response signals
type axiwrite_resp_rec_t is
record
   bresp:axi_bresp_t;
   bid:axi_bid_t;
end record;

constant axiwrite_resp_len_c:integer:=axi_bresp_t'length+axi_bid_t'length;

-- Flat buffer to hold axiwrite_resp_rec_t
subtype axiwrite_resp_fifo_t is std_logic_vector(axiwrite_resp_len_c-1 downto 0);


-- Signal declaration
signal axislave_cmd_rec_read:axiwrite_cmd_rec_t;
signal axislave_cmd_rec_write:axiwrite_cmd_rec_t;
signal axislave_cmd_fifo_read:axiwrite_cmd_fifo_t;
signal axislave_cmd_fifo_write:axiwrite_cmd_fifo_t;
signal axislave_cmd_fifo_full:std_logic;
signal axislave_cmd_fifo_empty:std_logic;
signal axislave_cmd_fifo_wr:std_logic;
signal axislave_cmd_fifo_rd:std_logic;
signal axislave_data_rec_read:axiwrite_data_rec_t;
signal axislave_data_rec_write:axiwrite_data_rec_t;
signal axislave_data_fifo_read:axiwrite_data_fifo_t;
signal axislave_data_fifo_write:axiwrite_data_fifo_t;
signal axislave_data_fifo_full:std_logic;
signal axislave_data_fifo_empty:std_logic;
signal axislave_data_fifo_wr:std_logic;
signal axislave_data_fifo_rd:std_logic;
signal axislave_resp_rec_read:axiwrite_resp_rec_t;
signal axislave_resp_rec_write:axiwrite_resp_rec_t;
signal axislave_resp_fifo_read:axiwrite_resp_fifo_t;
signal axislave_resp_fifo_write:axiwrite_resp_fifo_t;
signal axislave_resp_fifo_full:std_logic;
signal axislave_resp_fifo_empty:std_logic;
signal axislave_resp_fifo_wr:std_logic;
signal axislave_resp_fifo_rd:std_logic;

signal awaddr:axi_awaddr_t;
signal awlen:axi_awlen_t;
signal awvalid:std_logic;
signal wvalid:std_logic;
signal wlast:std_logic;
signal wdata:std_logic_vector(MASTER_DATA_WIDTH-1 downto 0);
signal wstrb:STD_LOGIC_VECTOR((MASTER_DATA_WIDTH/8)-1 downto 0);
signal step_r:unsigned(7 downto 0);
signal in_progress_r:std_logic;
signal in_progress_awaddr_r:axi_awaddr_t;
signal in_progress_awlen_r:axi_awlen_t;
signal wdata_r:std_logic_vector(MASTER_DATA_WIDTH-1 downto 0);
signal wstrb_r:std_logic_vector((MASTER_DATA_WIDTH)/8-1 downto 0);

constant MASTER_DATA_BYTE_WIDTH:integer:=MASTER_DATA_WIDTH/8;

constant MASTER_DATA_BYTE_WIDTH_L:integer:=log2(MASTER_DATA_BYTE_WIDTH);

constant SLAVE_DATA_BYTE_WIDTH:integer:=SLAVE_DATA_WIDTH/8;

constant SLAVE_DATA_BYTE_WIDTH_L:integer:=log2(SLAVE_DATA_BYTE_WIDTH);

constant SCALE_FACTOR:integer:=(MASTER_DATA_WIDTH/SLAVE_DATA_WIDTH);

constant SCALE_FACTOR_L:integer:=log2(SCALE_FACTOR);

-- Function to pack axiread_cmd_rec_t to flat buffer

function pack_cmd(rec_in:axiwrite_cmd_rec_t) return axiwrite_cmd_fifo_t is
variable len_v:integer;
variable q_v:axiwrite_cmd_fifo_t;
begin
   len_v := 0;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awaddr'length) := std_logic_vector(rec_in.awaddr);
   len_v := len_v + rec_in.awaddr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awlen'length) := std_logic_vector(rec_in.awlen);
   len_v := len_v + rec_in.awlen'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awburst'length) := std_logic_vector(rec_in.awburst);
   len_v := len_v + rec_in.awburst'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awcache'length) := std_logic_vector(rec_in.awcache);
   len_v := len_v + rec_in.awcache'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awid'length) := std_logic_vector(rec_in.awid);
   len_v := len_v + rec_in.awid'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awlock'length) := std_logic_vector(rec_in.awlock);
   len_v := len_v + rec_in.awlock'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awprot'length) := std_logic_vector(rec_in.awprot);
   len_v := len_v + rec_in.awprot'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awqos'length) := std_logic_vector(rec_in.awqos);
   len_v := len_v + rec_in.awqos'length;   
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.awsize'length) := std_logic_vector(rec_in.awsize);
   len_v := len_v + rec_in.awsize'length;
   return q_v;
end function pack_cmd;

-- Function to unpack flat buffer to axiread_cmd_rec_t

function unpack_cmd(q_in:axiwrite_cmd_fifo_t) return axiwrite_cmd_rec_t is
variable len_v:integer;
variable rec_v:axiwrite_cmd_rec_t;
begin
   len_v := 0;
   rec_v.awaddr := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awaddr'length);
   len_v := len_v + rec_v.awaddr'length;
   rec_v.awlen := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awlen'length);
   len_v := len_v + rec_v.awlen'length;  
   rec_v.awburst := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awburst'length);
   len_v := len_v + rec_v.awburst'length;  
   rec_v.awcache := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awcache'length);
   len_v := len_v + rec_v.awcache'length;  
   rec_v.awid := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awid'length);
   len_v := len_v + rec_v.awid'length;  
   rec_v.awlock := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awlock'length);
   len_v := len_v + rec_v.awlock'length;  
   rec_v.awprot := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awprot'length);
   len_v := len_v + rec_v.awprot'length;  
   rec_v.awqos := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awqos'length);
   len_v := len_v + rec_v.awqos'length;   
   rec_v.awsize := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.awsize'length);
   len_v := len_v + rec_v.awsize'length;
   return rec_v;  
end function unpack_cmd;

-- Function to pack axiwrite_data_rec_t to flat buffer

function pack_data(rec_in:axiwrite_data_rec_t) return axiwrite_data_fifo_t is
variable len_v:integer;
variable q_v:axiwrite_data_fifo_t;
begin
   len_v := 0;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.wdata'length) := std_logic_vector(rec_in.wdata);  
   len_v := len_v + rec_in.wdata'length;
   q_v(q_v'length-len_v-1) := rec_in.wlast;
   len_v := len_v+1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.wstrb'length) := std_logic_vector(rec_in.wstrb);  
   len_v := len_v + rec_in.wstrb'length;
   return q_v;
end function pack_data;

-- Function to unpack flat buffer to axiread_cmd_rec_t

function unpack_data(q_in:axiwrite_data_fifo_t) return axiwrite_data_rec_t is
variable len_v:integer;
variable rec_v:axiwrite_data_rec_t;
begin
   len_v := 0;
   rec_v.wdata := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.wdata'length);
   len_v := len_v + rec_v.wdata'length;
   rec_v.wlast := q_in(q_in'length-len_v-1);
   len_v := len_v + 1;    
   rec_v.wstrb := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.wstrb'length);
   len_v := len_v + rec_v.wstrb'length;
   return rec_v;  
end function unpack_data;

-- Function to pack axiwrite_resp_rec_t to flat buffer

function pack_resp(rec_in:axiwrite_resp_rec_t) return axiwrite_resp_fifo_t is
variable len_v:integer;
variable q_v:axiwrite_resp_fifo_t;
begin
   len_v := 0;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.bresp'length) := std_logic_vector(rec_in.bresp);  
   len_v := len_v + rec_in.bresp'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.bid'length) := std_logic_vector(rec_in.bid);  
   len_v := len_v + rec_in.bid'length;
   return q_v;
end function pack_resp;

-- Function to unpack flat buffer to axiwrite_resp_rec_t

function unpack_resp(q_in:axiwrite_resp_fifo_t) return axiwrite_resp_rec_t is
variable len_v:integer;
variable rec_v:axiwrite_resp_rec_t;
begin
   len_v := 0;
   rec_v.bresp := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.bresp'length);
   len_v := len_v + rec_v.bresp'length;
   rec_v.bid := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.bid'length);
   len_v := len_v + rec_v.bid'length;
   return rec_v;
end function unpack_resp;

begin

-- Set output signals for slave port
axislave_awready_out <= (not axislave_cmd_fifo_full);
axislave_wready_out <= (not axislave_data_fifo_full);
axislave_bresp_out <= axislave_resp_rec_read.bresp;
axislave_bid_out <= axislave_resp_rec_read.bid;
axislave_bvalid_out <= not axislave_resp_fifo_empty;

awvalid <= (not axislave_cmd_fifo_empty) and (not in_progress_r);
awaddr <= axislave_cmd_rec_read.awaddr;
awlen <= axislave_cmd_rec_read.awlen;
--wvalid <= (not axislave_data_fifo_empty) and (in_progress_r);
--wlast <= axislave_data_rec_read.wlast;
--wdata <= axislave_data_rec_read.wdata;
--wstrb <= axislave_data_rec_read.wstrb;

-- Set output signals for master port
aximaster_awaddr_out <= awaddr(awaddr'length-1 downto MASTER_DATA_BYTE_WIDTH_L) & std_logic_vector(to_unsigned(0,MASTER_DATA_BYTE_WIDTH_L));
aximaster_awlen_out <= awlen;
aximaster_awvalid_out <= awvalid;
aximaster_wvalid_out <= wvalid;
aximaster_wdata_out <= wdata;
aximaster_wlast_out <= wlast;
aximaster_wstrb_out <= wstrb;
aximaster_awburst_out <= axislave_cmd_rec_read.awburst;
aximaster_awcache_out <= axislave_cmd_rec_read.awcache;
aximaster_awid_out <= axislave_cmd_rec_read.awid;
aximaster_awlock_out <= axislave_cmd_rec_read.awlock;
aximaster_awprot_out <= axislave_cmd_rec_read.awprot;
aximaster_awqos_out <= axislave_cmd_rec_read.awqos;
--aximaster_awsize_out <= axislave_cmd_rec_read.awsize;
aximaster_awsize_out <= std_logic_vector(to_unsigned(log2(exmem_data_width_c/8),aximaster_awsize_out'length));
aximaster_bready_out <= not axislave_resp_fifo_full;

-- Set input to slave_cmd_fifo

process(axislave_awaddr_in,axislave_awlen_in,axislave_awburst_in,axislave_awcache_in,
         axislave_awid_in,axislave_awlock_in,axislave_awprot_in,
         axislave_awqos_in,axislave_awsize_in)
variable awlen_v:axi_awlen_t;
begin
   awlen_v := std_logic_vector(to_unsigned(0,SCALE_FACTOR_L)) & axislave_awlen_in(axislave_awlen_in'length-1 downto SCALE_FACTOR_L);
   if((unsigned('0' & axislave_awlen_in(SCALE_FACTOR_L-1 downto 0))+unsigned('0' & axislave_awaddr_in(SLAVE_DATA_BYTE_WIDTH_L+SCALE_FACTOR_L-1 downto SLAVE_DATA_BYTE_WIDTH_L))) > to_unsigned(SCALE_FACTOR-1,SCALE_FACTOR_L+1)) then
      awlen_v := std_logic_vector(unsigned(awlen_v) + to_unsigned(1,awlen_v'length));
   end if;
   axislave_cmd_rec_write.awaddr <= axislave_awaddr_in;
   axislave_cmd_rec_write.awlen <= awlen_v;
   axislave_cmd_rec_write.awburst <= axislave_awburst_in;
   axislave_cmd_rec_write.awcache <= axislave_awcache_in;
   axislave_cmd_rec_write.awid <= axislave_awid_in;
   axislave_cmd_rec_write.awlock <= axislave_awlock_in;
   axislave_cmd_rec_write.awprot <= axislave_awprot_in;
   axislave_cmd_rec_write.awqos <= axislave_awqos_in;
   axislave_cmd_rec_write.awsize <= axislave_awsize_in;
end process;

-- Set input to slave_data_fifo
axislave_data_rec_write.wdata <= axislave_wdata_in;
axislave_data_rec_write.wlast <= axislave_wlast_in;
axislave_data_rec_write.wstrb <= axislave_wstrb_in;

-- Set input to master resp_fifo
axislave_resp_rec_write.bresp <= aximaster_bresp_in;
axislave_resp_rec_write.bid <= aximaster_bid_in;

-- slave_cmd_fifo read/write
axislave_cmd_fifo_wr <= (axislave_awvalid_in) and (not axislave_cmd_fifo_full);
axislave_cmd_fifo_rd <= awvalid and (aximaster_awready_in);

-- slave_data_fifo read/write
axislave_data_fifo_wr <= (axislave_wvalid_in) and (not axislave_data_fifo_full);
--axislave_data_fifo_rd <= wvalid and (aximaster_wready_in);

-- slave_resp_fifo read/write
axislave_resp_fifo_wr <= (aximaster_bvalid_in) and (not axislave_resp_fifo_full);
axislave_resp_fifo_rd <= (axislave_bready_in) and (not axislave_resp_fifo_empty);

-- Pack and unpack record to/from fifo
        
axislave_cmd_rec_read <= unpack_cmd(axislave_cmd_fifo_read);
axislave_cmd_fifo_write <= pack_cmd(axislave_cmd_rec_write);

axislave_data_rec_read <= unpack_data(axislave_data_fifo_read);
axislave_data_fifo_write <= pack_data(axislave_data_rec_write);

axislave_resp_rec_read <= unpack_resp(axislave_resp_fifo_read);
axislave_resp_fifo_write <= pack_resp(axislave_resp_rec_write);

-- FIFO for slave port command signals

GEN1_CCD:if CCD=TRUE generate	
slave_cmd_fifo:afifo2
   generic map
   (
      DATA_WIDTH=>axiwrite_cmd_fifo_t'length,
      FIFO_DEPTH=>FIFO_DEPTH
   )
   port map
   (
      rclock_in=>clock_in,
      wclock_in=>axislave_clock_in,
      reset_in=>reset_in,
      data_in=>axislave_cmd_fifo_write,
      write_in=>axislave_cmd_fifo_wr,
      read_in=>axislave_cmd_fifo_rd,
      q_out=>axislave_cmd_fifo_read,
      empty_out=>axislave_cmd_fifo_empty,
      full_out=>axislave_cmd_fifo_full
   );
end generate GEN1_CCD;

GEN1:if CCD=FALSE generate	
slave_cmd_fifo:scfifo
   generic map
   (
      DATA_WIDTH=>axiwrite_cmd_fifo_t'length,
      FIFO_DEPTH=>FIFO_DEPTH,
      LOOKAHEAD=>TRUE
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>axislave_cmd_fifo_write,
      write_in=>axislave_cmd_fifo_wr,
      read_in=>axislave_cmd_fifo_rd,
      q_out=>axislave_cmd_fifo_read,
      empty_out=>axislave_cmd_fifo_empty,
      full_out=>axislave_cmd_fifo_full,
      ravail_out=>open,
      wused_out=>open,
      almost_full_out=>open
   );
end generate GEN1;

GEN2_CCD:if CCD=TRUE generate	        
slave_data_fifo:afifo2
   generic map
   (
      DATA_WIDTH=>axiwrite_data_fifo_t'length,
      FIFO_DEPTH=>FIFO_DATA_DEPTH
   )
   port map
   (
      rclock_in=>clock_in,
      wclock_in=>axislave_clock_in,
      reset_in=>reset_in,
      data_in=>axislave_data_fifo_write,
      write_in=>axislave_data_fifo_wr,
      read_in=>axislave_data_fifo_rd,
      q_out=>axislave_data_fifo_read,
      empty_out=>axislave_data_fifo_empty,
      full_out=>axislave_data_fifo_full
   );
end generate GEN2_CCD;

GEN2:if CCD=FALSE generate
slave_data_fifo:scfifo
   generic map
   (
      DATA_WIDTH=>axiwrite_data_fifo_t'length,
      FIFO_DEPTH=>FIFO_DATA_DEPTH,
      LOOKAHEAD=>TRUE
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>axislave_data_fifo_write,
      write_in=>axislave_data_fifo_wr,
      read_in=>axislave_data_fifo_rd,
      q_out=>axislave_data_fifo_read,
      empty_out=>axislave_data_fifo_empty,
      full_out=>axislave_data_fifo_full,
      ravail_out=>open,
      wused_out=>open,
      almost_full_out=>open
   );
end generate GEN2;

GEN3_CCD:if CCD=TRUE generate
slave_resp_fifo:afifo2
   generic map
   (
      DATA_WIDTH=>axiwrite_resp_fifo_t'length,
      FIFO_DEPTH=>FIFO_DEPTH
   )
   port map
   (
      rclock_in=>axislave_clock_in,
      wclock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>axislave_resp_fifo_write,
      write_in=>axislave_resp_fifo_wr,
      read_in=>axislave_resp_fifo_rd,
      q_out=>axislave_resp_fifo_read,
      empty_out=>axislave_resp_fifo_empty,
      full_out=>axislave_resp_fifo_full
   );
end generate GEN3_CCD;

GEN3:if CCD=FALSE generate
slave_resp_fifo:scfifo
   generic map
   (
      DATA_WIDTH=>axiwrite_resp_fifo_t'length,
      FIFO_DEPTH=>FIFO_DEPTH,
      LOOKAHEAD=>TRUE
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>axislave_resp_fifo_write,
      write_in=>axislave_resp_fifo_wr,
      read_in=>axislave_resp_fifo_rd,
      q_out=>axislave_resp_fifo_read,
      empty_out=>axislave_resp_fifo_empty,
      full_out=>axislave_resp_fifo_full,
      ravail_out=>open,
      wused_out=>open,
      almost_full_out=>open
   );
end generate GEN3;        


process(aximaster_clock_in,reset_in)
begin
   if reset_in = '0' then
      in_progress_r <= '0';
      in_progress_awaddr_r <= (others=>'0');
      in_progress_awlen_r <= (others=>'0');
      step_r <= (others=>'0');
      wstrb_r <= (others=>'0');
      wdata_r <= (others=>'0');
   else
      if rising_edge(aximaster_clock_in) then 
         if(axislave_cmd_fifo_rd='1') then
            -- Just submit a new write request
            in_progress_r <= '1';
            in_progress_awaddr_r <= awaddr;
            in_progress_awlen_r <= awlen;
         end if;
         if(axislave_data_fifo_rd='1') then
            if(wlast='1') then
               in_progress_r <= '0';
               step_r <= (others=>'0');
            else
               step_r <= step_r + to_unsigned(1,step_r'length);
            end if;
            if(wvalid='1') then
               wstrb_r <= (others=>'0');
               wdata_r <= (others=>'0');
            else
               wstrb_r <= wstrb;
               wdata_r <= wdata;
            end if;
         end if;
      end if;
   end if;
end process;

process(wdata_r,wstrb_r,axislave_data_fifo_empty,in_progress_r,step_r,
         in_progress_awaddr_r,axislave_data_rec_read,aximaster_wready_in,wvalid)
variable step_v:unsigned(SCALE_FACTOR_L-1 downto 0);
begin
   wdata <= wdata_r;
   wstrb <= wstrb_r;
   if(axislave_data_fifo_empty='0' and in_progress_r='1') then
      -- Transfer data to master
      step_v := step_r(SCALE_FACTOR_L-1 downto 0) + unsigned(in_progress_awaddr_r(SLAVE_DATA_BYTE_WIDTH_L+SCALE_FACTOR_L-1 downto SLAVE_DATA_BYTE_WIDTH_L));
      wlast <= axislave_data_rec_read.wlast;
      for I in 0 to SCALE_FACTOR-1 loop
         if(step_v=to_unsigned(I,step_v'length)) then
            wdata((I+1)*SLAVE_DATA_WIDTH-1 downto I*SLAVE_DATA_WIDTH) <= axislave_data_rec_read.wdata(SLAVE_DATA_WIDTH-1 downto 0);
            wstrb(((I+1)*SLAVE_DATA_WIDTH)/8-1 downto (I*SLAVE_DATA_WIDTH)/8) <= axislave_data_rec_read.wstrb((SLAVE_DATA_WIDTH/8)-1 downto 0);
            exit;
         end if;
      end loop;
      if(step_v=to_unsigned(SCALE_FACTOR-1,step_v'length)) then
         wvalid <= '1';
         axislave_data_fifo_rd <= aximaster_wready_in;
      elsif (axislave_data_rec_read.wlast='1') then
         wvalid <= '1';
         axislave_data_fifo_rd <= aximaster_wready_in;
      else
         wvalid <= '0';
         axislave_data_fifo_rd <= '1';
      end if;
   else
      wvalid <= '0';
      wlast <= '0';
      axislave_data_fifo_rd <= '0';
   end if;
end process;

end rtl;