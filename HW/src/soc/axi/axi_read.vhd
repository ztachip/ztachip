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
-- Provides cross clock domain bridge for AXI read interface 
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

entity axi_read is
   generic (
      DATA_WIDTH      : integer:=32;
      FIFO_DEPTH      : integer:=4;
      FIFO_DATA_DEPTH : integer:=4;
      CCD             : boolean:=TRUE      
   );
   port 
   (
      clock_in               : in std_logic;
      reset_in               : in std_logic;

      -- Slace port
      axislave_clock_in      : IN std_logic;
      axislave_araddr_in     : IN axi_araddr_t;
      axislave_arlen_in      : IN axi_arlen_t;
      axislave_arvalid_in    : IN axi_arvalid_t;
      axislave_arid_in       : IN axi_arid_t;
      axislave_arlock_in     : IN axi_arlock_t;
      axislave_arcache_in    : IN axi_arcache_t;
      axislave_arprot_in     : IN axi_arprot_t;
      axislave_arqos_in      : IN axi_arqos_t;
      axislave_rid_out       : OUT axi_rid_t;         
      axislave_rvalid_out    : OUT axi_rvalid_t;
      axislave_rlast_out     : OUT axi_rlast_t;
      axislave_rdata_out     : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
      axislave_rresp_out     : OUT axi_rresp_t;
      axislave_arready_out   : OUT axi_arready_t;
      axislave_rready_in     : IN axi_rready_t;
      axislave_arburst_in    : IN axi_arburst_t;
      axislave_arsize_in     : IN axi_arsize_t;

      -- Master port #1
      aximaster_clock_in     : IN std_logic;
      aximaster_araddr_out   : OUT axi_araddr_t;
      aximaster_arlen_out    : OUT axi_arlen_t;
      aximaster_arvalid_out  : OUT axi_arvalid_t;
      aximaster_arid_out     : OUT axi_arid_t;
      aximaster_arlock_out   : OUT axi_arlock_t;
      aximaster_arcache_out  : OUT axi_arcache_t;
      aximaster_arprot_out   : OUT axi_arprot_t;
      aximaster_arqos_out    : OUT axi_arqos_t;
      aximaster_rid_in       : IN axi_rid_t;
      aximaster_rvalid_in    : IN axi_rvalid_t;
      aximaster_rlast_in     : IN axi_rlast_t;
      aximaster_rdata_in     : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
      aximaster_rresp_in     : IN axi_rresp_t;
      aximaster_arready_in   : IN axi_arready_t;
      aximaster_rready_out   : OUT axi_rready_t;
      aximaster_arburst_out  : OUT axi_arburst_t;
      aximaster_arsize_out   : OUT axi_arsize_t
   );
end axi_read;

architecture rtl of axi_read is

-- Record to hold AXIREAD command signals
type axiread_cmd_rec_t is
record
   araddr:axi_araddr_t; -- Address
   arlen:axi_arlen_t; -- Burst length
   arid:axi_arid_t;
   arlock:axi_arlock_t;
   arcache:axi_arcache_t;
   arprot:axi_arprot_t;
   arqos:axi_arqos_t;
   arburst:axi_arburst_t;
   arsize:axi_arsize_t;
end record;

-- Flat buffer to hold axiread_cmd_rec_t
constant axiread_cmd_fifo_length_c:integer:= 
                                             axi_araddr_t'length+
                                             axi_arlen_t'length+
                                             axi_arid_t'length+
                                             axi_arlock_t'length+
                                             axi_arcache_t'length+
                                             axi_arprot_t'length+
                                             axi_arqos_t'length+
                                             axi_arburst_t'length+
                                             axi_arsize_t'length;

subtype axiread_cmd_fifo_t is std_logic_vector(axiread_cmd_fifo_length_c-1 downto 0);

-- Record to hold AXIREAD response signals
type axiread_resp_rec_t is
record
   rlast:axi_rlast_t;
   rid:axi_rid_t;
   rdata:std_logic_vector(DATA_WIDTH-1 downto 0);
   rresp:axi_rresp_t;
end record;

-- Flat buffer to hold axiread_resp_rec_t
constant axiread_resp_fifo_length_c:integer:=1+
                                             axi_rid_t'length+
                                             DATA_WIDTH+
                                             axi_rresp_t'length; 

subtype axiread_resp_fifo_t is std_logic_vector(axiread_resp_fifo_length_c-1 downto 0);

-- Signal declaration
signal axislave_cmd_rec_read:axiread_cmd_rec_t;
signal axislave_cmd_rec_write:axiread_cmd_rec_t;
signal axislave_cmd_fifo_read:axiread_cmd_fifo_t;
signal axislave_cmd_fifo_write:axiread_cmd_fifo_t;
signal axislave_cmd_fifo_full:std_logic;
signal axislave_cmd_fifo_empty:std_logic;
signal axislave_cmd_fifo_wr:std_logic;
signal axislave_cmd_fifo_rd:std_logic;
signal axislave_resp_rec_read:axiread_resp_rec_t;
signal axislave_resp_rec_write:axiread_resp_rec_t;
signal axislave_resp_fifo_read:axiread_resp_fifo_t;
signal axislave_resp_fifo_write:axiread_resp_fifo_t;
signal axislave_resp_fifo_full:std_logic;
signal axislave_resp_fifo_empty:std_logic;
signal axislave_resp_fifo_wr:std_logic;
signal axislave_resp_fifo_rd:std_logic;

signal aximaster_rid_r:axi_rid_t;
signal aximaster_rvalid_r:axi_rvalid_t;
signal aximaster_rlast_r:axi_rlast_t;
signal aximaster_rdata_r:STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
signal aximaster_rresp_r:axi_rresp_t;
signal aximaster_rready:std_logic;

-- Function to pack axiread_cmd_rec_t to flat buffer

function pack_cmd(rec_in:axiread_cmd_rec_t) return axiread_cmd_fifo_t is
variable len_v:integer;
variable q_v:axiread_cmd_fifo_t;
begin
   len_v := 0;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.araddr'length) := std_logic_vector(rec_in.araddr);
   len_v := len_v + rec_in.araddr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arlen'length) := std_logic_vector(rec_in.arlen);
   len_v := len_v + rec_in.arlen'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arid'length) := std_logic_vector(rec_in.arid);
   len_v := len_v + rec_in.arid'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arlock'length) := std_logic_vector(rec_in.arlock);
   len_v := len_v + rec_in.arlock'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arcache'length) := std_logic_vector(rec_in.arcache);
   len_v := len_v + rec_in.arcache'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arprot'length) := std_logic_vector(rec_in.arprot);
   len_v := len_v + rec_in.arprot'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arqos'length) := std_logic_vector(rec_in.arqos);
   len_v := len_v + rec_in.arqos'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arburst'length) := std_logic_vector(rec_in.arburst);
   len_v := len_v + rec_in.arburst'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.arsize'length) := std_logic_vector(rec_in.arsize);
   len_v := len_v + rec_in.arsize'length;
   return q_v;
end function pack_cmd;

-- Function to unpack flat buffer to axiread_cmd_rec_t

function unpack_cmd(q_in:axiread_cmd_fifo_t) return axiread_cmd_rec_t is
variable len_v:integer;
variable rec_v:axiread_cmd_rec_t;
begin
   len_v := 0;
   rec_v.araddr := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.araddr'length);
   len_v := len_v + rec_v.araddr'length;
   rec_v.arlen := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arlen'length);
   len_v := len_v + rec_v.arlen'length;  
   rec_v.arid := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arid'length);
   len_v := len_v + rec_v.arid'length;  
   rec_v.arlock := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arlock'length);
   len_v := len_v + rec_v.arlock'length;  
   rec_v.arcache := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arcache'length);
   len_v := len_v + rec_v.arcache'length;  
   rec_v.arprot := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arprot'length);
   len_v := len_v + rec_v.arprot'length;  
   rec_v.arqos := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arqos'length);
   len_v := len_v + rec_v.arqos'length;    
   rec_v.arburst := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arburst'length);
   len_v := len_v + rec_v.arburst'length;
   rec_v.arsize := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.arsize'length);
   len_v := len_v + rec_v.arsize'length;  
   return rec_v;  
end function unpack_cmd;

-- Function to pack axiread_resp_rec_t to flat buffer

function pack_resp(rec_in:axiread_resp_rec_t) return axiread_resp_fifo_t is
variable len_v:integer;
variable q_v:axiread_resp_fifo_t;
begin
   len_v := 0;
   q_v(q_v'length-len_v-1) := rec_in.rlast;
   len_v := len_v+1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.rid'length) := std_logic_vector(rec_in.rid);
   len_v := len_v + rec_in.rid'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.rdata'length) := std_logic_vector(rec_in.rdata);
   len_v := len_v + rec_in.rdata'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.rresp'length) := std_logic_vector(rec_in.rresp);
   len_v := len_v + rec_in.rresp'length;
   return q_v;
end function pack_resp;

-- Function to unpack flat buffer to axiread_resp_rec_t

function unpack_resp(q_in:axiread_resp_fifo_t) return axiread_resp_rec_t is
variable len_v:integer;
variable rec_v:axiread_resp_rec_t;
begin
   len_v := 0;
   rec_v.rlast := q_in(q_in'length-len_v-1);
   len_v := len_v + 1;
   rec_v.rid := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.rid'length);
   len_v := len_v + rec_v.rid'length;
   rec_v.rdata := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.rdata'length);
   len_v := len_v + rec_v.rdata'length;
   rec_v.rresp := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.rresp'length);
   len_v := len_v + rec_v.rresp'length;
   return rec_v;   
end function unpack_resp;

begin

-- Set output signals for slave port
axislave_rvalid_out <= (not axislave_resp_fifo_empty);
axislave_rid_out <= axislave_resp_rec_read.rid;
axislave_rlast_out <= axislave_resp_rec_read.rlast;
axislave_rdata_out <= axislave_resp_rec_read.rdata;
axislave_rresp_out <= axislave_resp_rec_read.rresp;
axislave_arready_out <= (not axislave_cmd_fifo_full);

-- Set output signals for master port
aximaster_araddr_out <= axislave_cmd_rec_read.araddr;
aximaster_arlen_out <= axislave_cmd_rec_read.arlen;
aximaster_arvalid_out <= (not axislave_cmd_fifo_empty);
aximaster_rready_out <= aximaster_rready;
aximaster_arid_out <= axislave_cmd_rec_read.arid;
aximaster_arlock_out <= axislave_cmd_rec_read.arlock;
aximaster_arcache_out <= axislave_cmd_rec_read.arcache;
aximaster_arprot_out <= axislave_cmd_rec_read.arprot;
aximaster_arqos_out <= axislave_cmd_rec_read.arqos;
aximaster_arburst_out <= axislave_cmd_rec_read.arburst;
aximaster_arsize_out <= axislave_cmd_rec_read.arsize;

-- Set input to slave_cmd_fifo
axislave_cmd_rec_write.araddr <= axislave_araddr_in; 
axislave_cmd_rec_write.arlen <= axislave_arlen_in;
axislave_cmd_rec_write.arid <= axislave_arid_in;
axislave_cmd_rec_write.arlock <= axislave_arlock_in;
axislave_cmd_rec_write.arcache <= axislave_arcache_in;
axislave_cmd_rec_write.arprot <= axislave_arprot_in;
axislave_cmd_rec_write.arqos <= axislave_arqos_in;
axislave_cmd_rec_write.arburst <= axislave_arburst_in;
axislave_cmd_rec_write.arsize <= axislave_arsize_in;

-- Set input to master resp_fifo
axislave_resp_rec_write.rid <= aximaster_rid_r;
axislave_resp_rec_write.rlast <= aximaster_rlast_r;
axislave_resp_rec_write.rdata <= aximaster_rdata_r;
axislave_resp_rec_write.rresp <= aximaster_rresp_r;

-- slave_cmd_fifo read/write
axislave_cmd_fifo_wr <= (axislave_arvalid_in) and (not axislave_cmd_fifo_full);
axislave_cmd_fifo_rd <= (aximaster_arready_in) and (not axislave_cmd_fifo_empty);

-- slave_resp_fifo read/write
axislave_resp_fifo_wr <= (aximaster_rvalid_r) and (not axislave_resp_fifo_full);
axislave_resp_fifo_rd <= (axislave_rready_in) and (not axislave_resp_fifo_empty);

-- Pack and unpack record to/from fifo
        
axislave_cmd_rec_read <= unpack_cmd(axislave_cmd_fifo_read);
axislave_cmd_fifo_write <= pack_cmd(axislave_cmd_rec_write);

axislave_resp_rec_read <= unpack_resp(axislave_resp_fifo_read);
axislave_resp_fifo_write <= pack_resp(axislave_resp_rec_write);

-- FIFO for slave port command signals

GEN1_CCD:IF CCD=TRUE GENERATE
slave_cmd_fifo:afifo
   generic map
   (
      DATA_WIDTH=>axiread_cmd_fifo_t'length,
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

GEN1:IF CCD=FALSE GENERATE
slave_cmd_fifo:scfifo
   generic map
   (
      DATA_WIDTH=>axiread_cmd_fifo_t'length,
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

-- FIFO for slave port response signals

GEN2_CCD:if CCD=TRUE generate
slave_resp_fifo:afifo
   generic map
   (
      DATA_WIDTH=>axiread_resp_fifo_t'length,
      FIFO_DEPTH=>FIFO_DATA_DEPTH
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
end generate GEN2_CCD;

GEN2:if CCD=FALSE generate
slave_resp_fifo:scfifo
   generic map
   (
      DATA_WIDTH=>axiread_resp_fifo_t'length,
      FIFO_DEPTH=>FIFO_DATA_DEPTH,
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
end generate GEN2;

aximaster_rready <= '1' when (aximaster_rvalid_r='0') or (axislave_resp_fifo_full='0') else '0';

process(aximaster_clock_in,reset_in)
begin
-- TODO wrong reset for aximaster_clock_in
   if reset_in = '0' then
      aximaster_rid_r <= (others=>'0');
      aximaster_rvalid_r <= '0';
      aximaster_rlast_r <= '0';
      aximaster_rdata_r <= (others=>'0');
      aximaster_rresp_r <= (others=>'0');
   else
      if rising_edge(aximaster_clock_in) then 
         if(aximaster_rready='1') then
            aximaster_rid_r <= aximaster_rid_in;
            aximaster_rvalid_r <= aximaster_rvalid_in;
            aximaster_rlast_r <= aximaster_rlast_in;
            aximaster_rdata_r <= aximaster_rdata_in;
            aximaster_rresp_r <= aximaster_rresp_in;
         end if;
      end if;
   end if;
end process;

end rtl;