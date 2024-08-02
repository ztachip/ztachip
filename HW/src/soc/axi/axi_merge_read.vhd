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
-- Bridge multiple AXI slave read interfaces into 1 AXI master read interface
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity axi_merge_read is
   generic (
      NUM_SLAVE_PORT     : integer:=3;
      FIFO_CMD_DEPTH     : integer_array(2 downto 0);
      FIFO_DATA_DEPTH    : integer_array(2 downto 0);
      FIFO_W_CMD_DEPTH   : integer;
      FIFO_W_DATA_DEPTH  : integer
   );
   port 
   (
      clock_in               : in std_logic;
      reset_in               : in std_logic;

      -- wide slave port
      axislavew_clock_in      : IN std_logic;
      axislavew_araddr_in     : IN axi_araddr_t:=(others=>'0');
      axislavew_arlen_in      : IN axi_arlen_t:=(others=>'0');
      axislavew_arvalid_in    : IN axi_arvalid_t:='0';     
      axislavew_arid_in       : IN axi_arid_t:=(others=>'0');
      axislavew_arlock_in     : IN axi_arlock_t:=(others=>'0');
      axislavew_arcache_in    : IN axi_arcache_t:=(others=>'0');
      axislavew_arprot_in     : IN axi_arprot_t:=(others=>'0');
      axislavew_arqos_in      : IN axi_arqos_t:=(others=>'0');
      axislavew_rid_out       : OUT axi_rid_t:=(others=>'0');
      axislavew_rvalid_out    : OUT axi_rvalid_t;
      axislavew_rlast_out     : OUT axi_rlast_t;
      axislavew_rdata_out     : OUT axi_rdata64_t;
      axislavew_rresp_out     : OUT axi_rresp_t;
      axislavew_arready_out   : OUT axi_arready_t;
      axislavew_rready_in     : IN axi_rready_t:='0';
      axislavew_arburst_in    : IN axi_arburst_t:=(others=>'0');
      axislavew_arsize_in     : IN axi_arsize_t:=(others=>'0');

      -- Slave port
      axislave_clocks_in      : IN std_logic_vector(MAX_SLAVE_PORT-1 downto 0);
      axislave_araddrs_in     : IN axi_araddrs_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_arlens_in      : IN axi_arlens_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_arvalids_in    : IN axi_arvalids_t(MAX_SLAVE_PORT-1 downto 0):=(others=>'0');     
      axislave_arids_in       : IN axi_arids_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_arlocks_in     : IN axi_arlocks_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_arcaches_in    : IN axi_arcaches_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_arprots_in     : IN axi_arprots_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_arqoss_in      : IN axi_arqoss_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_rids_out       : OUT axi_rids_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_rvalids_out    : OUT axi_rvalids_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_rlasts_out     : OUT axi_rlasts_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_rdatas_out     : OUT axi_rdata64s_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_rresps_out     : OUT axi_rresps_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_arreadys_out   : OUT axi_arreadys_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_rreadys_in     : IN axi_rreadys_t(MAX_SLAVE_PORT-1 downto 0):=(others=>'0');
      axislave_arbursts_in    : IN axi_arbursts_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      axislave_arsizes_in     : IN axi_arsizes_t(MAX_SLAVE_PORT-1 downto 0):=(others=>(others=>'0'));
      
      -- Master port 
      aximaster_araddr_out    : OUT axi_araddr_t;
      aximaster_arlen_out     : OUT axi_arlen_t;
      aximaster_arvalid_out   : OUT axi_arvalid_t;
      aximaster_arid_out      : OUT axi_arid_t;
      aximaster_arlock_out    : OUT axi_arlock_t;
      aximaster_arcache_out   : OUT axi_arcache_t;
      aximaster_arprot_out    : OUT axi_arprot_t;
      aximaster_arqos_out     : OUT axi_arqos_t;
      aximaster_rid_in        : IN axi_rid_t;              
      aximaster_rvalid_in     : IN axi_rvalid_t;
      aximaster_rlast_in      : IN axi_rlast_t;
      aximaster_rdata_in      : IN axi_rdata64_t;
      aximaster_rdata_mask_out: OUT std_logic_vector(1 downto 0);
      aximaster_rresp_in      : IN axi_rresp_t;
      aximaster_arready_in    : IN axi_arready_t;
      aximaster_rready_out   : OUT axi_rready_t;
      aximaster_arburst_out  : OUT axi_arburst_t;
      aximaster_arsize_out   : OUT axi_arsize_t
   );
end axi_merge_read;

architecture rtl of axi_merge_read is
constant S0:integer:=0;
constant S1:integer:=1;
constant S2:integer:=2;
constant SW:integer:=3;

SIGNAL slave_araddrs:axi_araddrs_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arlens:axi_arlens_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arvalids:axi_arvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arids:axi_arids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arlocks:axi_arlocks_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arcaches:axi_arcaches_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arprots:axi_arprots_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arqoss:axi_arqoss_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_rids:axi_rids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_rvalids:axi_rvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_rlasts:axi_rlasts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_rdatas:axi_rdata64s_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_rresps:axi_rresps_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arreadys:axi_arreadys_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_rreadys:axi_rreadys_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arbursts:axi_arbursts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_arsizes:axi_arsizes_t(MAX_SLAVE_PORT-1 downto 0);

-- Slave with wide-bus

SIGNAL slavew_araddr:axi_araddr_t;
SIGNAL slavew_arlen:axi_arlen_t;
SIGNAL slavew_arvalid:axi_arvalid_t;
SIGNAL slavew_arid:axi_arid_t;
SIGNAL slavew_arlock:axi_arlock_t;
SIGNAL slavew_arcache:axi_arcache_t;
SIGNAL slavew_arprot:axi_arprot_t;
SIGNAL slavew_arqos:axi_arqos_t;
SIGNAL slavew_rid:axi_rid_t;
SIGNAL slavew_rvalid:axi_rvalid_t;
SIGNAL slavew_rlast:axi_rlast_t;
SIGNAL slavew_rdata:axi_rdata64_t;
SIGNAL slavew_rresp:axi_rresp_t;
SIGNAL slavew_arready:axi_arready_t;
SIGNAL slavew_rready:axi_rready_t;
SIGNAL slavew_arburst:axi_arburst_t;
SIGNAL slavew_arsize:axi_arsize_t;

SIGNAL master_araddr:axi_araddr_t;
SIGNAL master_arlen:axi_arlen_t;
SIGNAL master_arvalid:axi_arvalid_t;
SIGNAL master_arid:axi_arid_t;
SIGNAL master_arlock:axi_arlock_t;
SIGNAL master_arcache:axi_arcache_t;
SIGNAL master_arprot:axi_arprot_t;
SIGNAL master_arqos:axi_arqos_t;
SIGNAL master_rid:axi_rid_t;
SIGNAL master_rvalid:axi_rvalid_t;
SIGNAL master_rlast:axi_rlast_t;
SIGNAL master_rdata:axi_rdata64_t;
SIGNAL master_rresp:axi_rresp_t;
SIGNAL master_arready:axi_arready_t;
SIGNAL master_rready:axi_rready_t;
SIGNAL master_arburst:axi_arburst_t;
SIGNAL master_arsize:axi_arsize_t;

SIGNAL pend_master_we:std_logic;
SIGNAL pend_master_rd:std_logic;
SIGNAL pend_master_rvalid:std_logic;
SIGNAL pend_master_full:std_logic;
SIGNAL pend_master_empty:std_logic;
SIGNAL pend_master_read:std_logic_vector(MAX_SLAVE_PORT+1 downto 0);
SIGNAL pend_master_write:std_logic_vector(MAX_SLAVE_PORT+1 downto 0);

SIGNAL curr:std_logic_vector(MAX_SLAVE_PORT downto 0);
SIGNAL curr_r:std_logic_vector(MAX_SLAVE_PORT downto 0);

SIGNAL req:std_logic_vector(NUM_SLAVE_PORT+1-1 downto 0);
SIGNAL gnt:std_logic_vector(NUM_SLAVE_PORT+1-1 downto 0);
SIGNAL gnt_valid:std_logic;
SIGNAL align_r:std_logic;

constant max_read_pending_c:integer:=128;

constant read_pending_depth_c:integer:=8;

SIGNAL congest:std_logic;

SIGNAL master_rdata_mask:std_logic_vector(1 downto 0);

begin

aximaster_araddr_out <= master_araddr;
aximaster_arlen_out <= master_arlen;
aximaster_arvalid_out <= master_arvalid and (not congest);
aximaster_arid_out <= master_arid;
aximaster_arlock_out <= master_arlock;
aximaster_arcache_out <= master_arcache;
aximaster_arprot_out <= master_arprot;
aximaster_arqos_out <= master_arqos;
master_rid <= aximaster_rid_in;       
master_rvalid <= aximaster_rvalid_in;
master_rlast <= aximaster_rlast_in;
master_rdata <= aximaster_rdata_in;
master_rresp <= aximaster_rresp_in;
master_arready <= aximaster_arready_in and (not congest);
aximaster_rready_out <= master_rready;
aximaster_arburst_out <= master_arburst;
aximaster_arsize_out <= master_arsize;
aximaster_rdata_mask_out <= master_rdata_mask;

congest <= '1' when (pend_master_full='1' or aximaster_arready_in='0') else '0';

GEN_SLAVE:
FOR I in 0 to MAX_SLAVE_PORT-1 GENERATE
slave_i: axi_read
   generic map(
      DATA_WIDTH=>64,
      FIFO_DEPTH=>FIFO_CMD_DEPTH(I),
      FIFO_DATA_DEPTH=>FIFO_DATA_DEPTH(I)
   )
   port map(
      clock_in=>clock_in,
      reset_in=>reset_in,

      axislave_clock_in=>axislave_clocks_in(I),
      axislave_araddr_in=>axislave_araddrs_in(I),
      axislave_arlen_in=>axislave_arlens_in(I),
      axislave_arvalid_in=>axislave_arvalids_in(I),
      axislave_arid_in=>axislave_arids_in(I),
      axislave_arlock_in=>axislave_arlocks_in(I),
      axislave_arcache_in=>axislave_arcaches_in(I),
      axislave_arprot_in=>axislave_arprots_in(I),
      axislave_arqos_in=>axislave_arqoss_in(I),
      axislave_rid_out=>axislave_rids_out(I), 
      axislave_rvalid_out=>axislave_rvalids_out(I),
      axislave_rlast_out=>axislave_rlasts_out(I),
      axislave_rdata_out=>axislave_rdatas_out(I),
      axislave_rresp_out=>axislave_rresps_out(I),
      axislave_arready_out=>axislave_arreadys_out(I),
      axislave_rready_in=>axislave_rreadys_in(I),
      axislave_arburst_in=>axislave_arbursts_in(I),
      axislave_arsize_in=>axislave_arsizes_in(I),
         
      aximaster_clock_in=>clock_in,
      aximaster_araddr_out=>slave_araddrs(I),
      aximaster_arlen_out=>slave_arlens(I),
      aximaster_arvalid_out=>slave_arvalids(I),
      aximaster_arid_out=>slave_arids(I),
      aximaster_arlock_out=>slave_arlocks(I),
      aximaster_arcache_out=>slave_arcaches(I),
      aximaster_arprot_out=>slave_arprots(I),
      aximaster_arqos_out=>slave_arqoss(I),
      aximaster_rid_in=>slave_rids(I),
      aximaster_rvalid_in=>slave_rvalids(I),
      aximaster_rlast_in=>slave_rlasts(I),
      aximaster_rdata_in=>slave_rdatas(I),
      aximaster_rresp_in=>slave_rresps(I),
      aximaster_arready_in=>slave_arreadys(I),
      aximaster_rready_out=>slave_rreadys(I),
      aximaster_arburst_out=>slave_arbursts(I),
      aximaster_arsize_out=>slave_arsizes(I)
   );
END GENERATE GEN_SLAVE;

slavew_i: axi_read
   generic map(
      DATA_WIDTH=>64,
      FIFO_DEPTH=>FIFO_W_CMD_DEPTH,
      FIFO_DATA_DEPTH=>FIFO_W_DATA_DEPTH
   )
   port map(
      clock_in=>clock_in,
      reset_in=>reset_in,

      axislave_clock_in=>axislavew_clock_in,
      axislave_araddr_in=>axislavew_araddr_in,
      axislave_arlen_in=>axislavew_arlen_in,
      axislave_arvalid_in=>axislavew_arvalid_in,
      axislave_arid_in=>axislavew_arid_in,
      axislave_arlock_in=>axislavew_arlock_in,
      axislave_arcache_in=>axislavew_arcache_in,
      axislave_arprot_in=>axislavew_arprot_in,
      axislave_arqos_in=>axislavew_arqos_in,
      axislave_rid_out=>axislavew_rid_out, 
      axislave_rvalid_out=>axislavew_rvalid_out,
      axislave_rlast_out=>axislavew_rlast_out,
      axislave_rdata_out=>axislavew_rdata_out,
      axislave_rresp_out=>axislavew_rresp_out,
      axislave_arready_out=>axislavew_arready_out,
      axislave_rready_in=>axislavew_rready_in,
      axislave_arburst_in=>axislavew_arburst_in,
      axislave_arsize_in=>axislavew_arsize_in,
         
      aximaster_clock_in=>clock_in,
      aximaster_araddr_out=>slavew_araddr,
      aximaster_arlen_out=>slavew_arlen,
      aximaster_arvalid_out=>slavew_arvalid,
      aximaster_arid_out=>slavew_arid,
      aximaster_arlock_out=>slavew_arlock,
      aximaster_arcache_out=>slavew_arcache,
      aximaster_arprot_out=>slavew_arprot,
      aximaster_arqos_out=>slavew_arqos,
      aximaster_rid_in=>slavew_rid,
      aximaster_rvalid_in=>slavew_rvalid,
      aximaster_rlast_in=>slavew_rlast,
      aximaster_rdata_in=>slavew_rdata,
      aximaster_rresp_in=>slavew_rresp,
      aximaster_arready_in=>slavew_arready,
      aximaster_rready_out=>slavew_rready,
      aximaster_arburst_out=>slavew_arburst,
      aximaster_arsize_out=>slavew_arsize
   );
   
-- Pending fifo at master port

pend_master_fifo_i:scfifo
   generic map 
   (
      DATA_WIDTH=>NUM_SLAVE_PORT+2,
      FIFO_DEPTH=>8,
      LOOKAHEAD=>TRUE
   )
   port map 
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>pend_master_write,
      write_in=>pend_master_we,
      read_in=>pend_master_rd,
      q_out=>pend_master_read,
      ravail_out=>open,
      wused_out=>open,
      empty_out=>pend_master_empty,
      full_out=>pend_master_full,
      almost_full_out=>open
   );

--arbiter_i: arbiter
--    generic map(
--        NUM_SIGNALS=>NUM_SLAVE_PORT+1,
--        PRIORITY_BASED=>TRUE
--        )
--    port map(
--        clock_in=>clock_in,
--        reset_in=>reset_in,
--        req_in=>req,
--        gnt_out=>gnt,
--        gnt_valid_out=>gnt_valid
--        );

gnt_valid <= '0' when req=std_logic_vector(to_unsigned(0,req'length)) else '1';

process(req)
begin
   gnt <= (others=>'0');
   if(req(S0)='1') then
      gnt(S0)<='1';
   elsif (req(S1)='1') then
      gnt(S1)<='1';
   elsif (req(S2)='1') then
      gnt(S2)<='1';
   elsif (req(SW)='1') then
      gnt(SW)<='1';
   end if;  
end process;

process(curr_r,slave_arvalids,slavew_arvalid)
begin
   req <= (others=>'0');
   if curr_r=std_logic_vector(to_unsigned(0,curr_r'length)) then
      req(S0) <= slave_arvalids(S0);
      req(S1) <= slave_arvalids(S1);
      req(S2) <= slave_arvalids(S2);
      req(SW) <= slavew_arvalid;
   end if;
end process;

-- Route read data response from master ports to corresponding
-- slave ports

process(master_rvalid,pend_master_empty, pend_master_read,
        master_rlast,master_rdata,master_rresp,slave_rreadys,
        master_rid,align_r,slavew_rready)
begin
   master_rready <= '0';
   pend_master_rd <= '0';
   pend_master_rvalid <= '0';
   slave_rdatas(S0) <= master_rdata;
   if pend_master_empty='0' and pend_master_read(S0)='1' then
      slave_rvalids(S0) <= master_rvalid; 
      slave_rids(S0) <= master_rid;
      slave_rlasts(S0) <= master_rlast;      
      slave_rresps(S0) <= master_rresp;
      master_rready <= slave_rreadys(S0);
      pend_master_rd <= slave_rreadys(S0) and master_rlast and master_rvalid;
      pend_master_rvalid <= slave_rreadys(S0) and master_rvalid;
   else
      slave_rvalids(S0) <= '0';
      slave_rids(S0) <= (others=>'0');
      slave_rlasts(S0) <= '0';
      slave_rresps(S0) <= (others=>'0');
   end if;

   if((align_r='0' and pend_master_read(MAX_SLAVE_PORT+1)='0') or
      (align_r='1' and pend_master_read(MAX_SLAVE_PORT+1)='1')) then
      slave_rdatas(S1)(31 downto 0) <= master_rdata(31 downto 0);
      slave_rdatas(S1)(63 downto 32) <= master_rdata(31 downto 0);
   else
      slave_rdatas(S1)(31 downto 0) <= master_rdata(63 downto 32);
      slave_rdatas(S1)(63 downto 32) <= master_rdata(63 downto 32);
   end if; 
   if pend_master_empty='0' and pend_master_read(S1)='1' then
      slave_rvalids(S1) <= master_rvalid;
      slave_rids(S1) <= master_rid;
      slave_rlasts(S1) <= master_rlast;
      slave_rresps(S1) <= master_rresp;
      master_rready <= slave_rreadys(S1);
      pend_master_rd <= slave_rreadys(S1) and master_rlast and master_rvalid;
      pend_master_rvalid <= slave_rreadys(S1) and master_rvalid;
   else
      slave_rvalids(S1) <= '0';
      slave_rids(S1) <= (others=>'0');
      slave_rlasts(S1) <= '0';
      slave_rresps(S1) <= (others=>'0');
   end if;

   if((align_r='0' and pend_master_read(MAX_SLAVE_PORT+1)='0') or
      (align_r='1' and pend_master_read(MAX_SLAVE_PORT+1)='1')) then
      slave_rdatas(S2)(31 downto 0) <= master_rdata(31 downto 0);
      slave_rdatas(S2)(63 downto 32) <= master_rdata(31 downto 0);
   else
      slave_rdatas(S2)(31 downto 0) <= master_rdata(63 downto 32);
      slave_rdatas(S2)(63 downto 32) <= master_rdata(63 downto 32);
   end if;
   if pend_master_empty='0' and pend_master_read(S2)='1' then
      slave_rvalids(S2) <= master_rvalid;
      slave_rids(S2) <= master_rid;
      slave_rlasts(S2) <= master_rlast;       
      slave_rresps(S2) <= master_rresp;
      master_rready <= slave_rreadys(S2);
      pend_master_rd <= slave_rreadys(S2) and master_rlast and master_rvalid;
      pend_master_rvalid <= slave_rreadys(S2) and master_rvalid;
   else
      slave_rvalids(S2) <= '0';
      slave_rids(S2) <= (others=>'0');
      slave_rlasts(S2) <= '0';
      slave_rresps(S2) <= (others=>'0');
   end if;

   slavew_rdata <= master_rdata;
   if pend_master_empty='0' and pend_master_read(SW)='1' then
      slavew_rvalid <= master_rvalid;
      slavew_rid <= master_rid;
      slavew_rlast <= master_rlast;
      slavew_rresp <= master_rresp;
      master_rready <= slavew_rready;
      pend_master_rd <= slavew_rready and master_rlast and master_rvalid;
      pend_master_rvalid <= slavew_rready and master_rvalid;
   else
      slavew_rvalid <= '0';
      slavew_rid <= (others=>'0');
      slavew_rlast <= '0';
      slavew_rresp <= (others=>'0');
   end if;
end process;

process(pend_master_empty,pend_master_read,align_r)
begin
if(pend_master_empty='0') then
   if pend_master_read(SW)='1' or pend_master_read(S0)='1' then
      master_rdata_mask(0) <= '1';
      master_rdata_mask(1) <= '1';
   else
      if((align_r='0' and pend_master_read(MAX_SLAVE_PORT+1)='0') or
         (align_r='1' and pend_master_read(MAX_SLAVE_PORT+1)='1')) then
         master_rdata_mask(0) <= '1';
         master_rdata_mask(1) <= '0';
      else
         master_rdata_mask(0) <= '0';
         master_rdata_mask(1) <= '1';
      end if; 
   end if;
else
   master_rdata_mask(0) <= '0';
   master_rdata_mask(1) <= '0';
end if;
end process;

process(clock_in,reset_in)
begin
   if reset_in='0' then
      curr_r <= (others=>'0');
      align_r <= '0';
   else
      if clock_in'event and clock_in='1' then
         if(master_arvalid='1' and master_arready='0') then
            curr_r <= curr;
         else
            curr_r <= (others=>'0');
         end if;
         if master_rready='1' and master_rvalid='1' then
            if(master_rlast='1') then
               align_r <= '0';
            else   
               align_r <= not align_r;
            end if;
         end if;
      end if;
   end if;
end process;

-- Route read request from slave ports to corresponding
-- master ports

process(slave_arvalids,slave_araddrs,slave_arlens,slave_arids,slave_arlocks,slave_arcaches,
      slave_arprots,slave_arqoss,slave_rids,slave_arbursts,slave_arsizes,master_arready,
      curr_r,gnt_valid,gnt,
      slavew_araddr,slavew_arlen,slavew_arid,slavew_arlock,slavew_arcache,slavew_arprot,
      slavew_arqos,slavew_arburst,slavew_arsize)
begin
   slave_arreadys <= (others=>'0');
   slavew_arready <= '0';
   if (curr_r(S0)='1' or gnt(S0)='1') then
      -- Send commands from slave1 to master2    
      master_araddr <= slave_araddrs(S0);
      master_arlen <= slave_arlens(S0);
      master_arvalid <= '1';
      master_arid <= slave_arids(S0);
      master_arlock <= slave_arlocks(S0);
      master_arcache <= slave_arcaches(S0);
      master_arprot <= slave_arprots(S0);
      master_arqos <= slave_arqoss(S0);
      master_arburst <= slave_arbursts(S0); 
      master_arsize <= slave_arsizes(S0);
      slave_arreadys(S0) <= master_arready;
      pend_master_write(MAX_SLAVE_PORT-1 downto 0) <= std_logic_vector(to_unsigned(2**S0,MAX_SLAVE_PORT));
      pend_master_write(SW) <= '0';
      pend_master_write(MAX_SLAVE_PORT+1) <= slave_araddrs(S0)(2);
      pend_master_we <= master_arready;
      curr <= (others=>'0');
      curr(S0) <= '1';
   elsif (curr_r(S1)='1' or gnt(S1)='1') then
      -- Send commands from slave1 to master2    
      master_araddr <= slave_araddrs(S1);
      master_arlen <= slave_arlens(S1);
      master_arvalid <= '1';
      master_arid <= slave_arids(S1);
      master_arlock <= slave_arlocks(S1);
      master_arcache <= slave_arcaches(S1);
      master_arprot <= slave_arprots(S1);
      master_arqos <= slave_arqoss(S1);
      master_arburst <= slave_arbursts(S1);
      master_arsize <= slave_arsizes(S1);
      slave_arreadys(S1) <= master_arready;
      pend_master_write(MAX_SLAVE_PORT-1 downto 0) <= std_logic_vector(to_unsigned(2**S1,MAX_SLAVE_PORT));
      pend_master_write(SW) <= '0';
      pend_master_write(MAX_SLAVE_PORT+1) <= slave_araddrs(S1)(2);
      pend_master_we <= master_arready;
      curr <= (others=>'0');
      curr(S1) <= '1';
   elsif (curr_r(S2)='1' or gnt(S2)='1') then
      -- Send commands from slave1 to master2    
      master_araddr <= slave_araddrs(S2);
      master_arlen <= slave_arlens(S2);
      master_arvalid <= '1';
      master_arid <= slave_arids(S2);
      master_arlock <= slave_arlocks(S2);
      master_arcache <= slave_arcaches(S2);
      master_arprot <= slave_arprots(S2);
      master_arqos <= slave_arqoss(S2);
      master_arburst <= slave_arbursts(S2);
      master_arsize <= slave_arsizes(S2);
      slave_arreadys(S2) <= master_arready;
      pend_master_write(MAX_SLAVE_PORT-1 downto 0) <= std_logic_vector(to_unsigned(2**S2,MAX_SLAVE_PORT));
      pend_master_write(SW) <= '0';
      pend_master_write(MAX_SLAVE_PORT+1) <= slave_araddrs(S2)(2);
      pend_master_we <= master_arready;
      curr <= (others=>'0');
      curr(S2) <= '1';
   elsif (curr_r(SW)='1' or gnt(SW)='1') then
      -- Send commands from slave1 to master2    
      master_araddr <= slavew_araddr;
      master_arlen <= slavew_arlen;
      master_arvalid <= '1';
      master_arid <= slavew_arid;
      master_arlock <= slavew_arlock;
      master_arcache <= slavew_arcache;
      master_arprot <= slavew_arprot;
      master_arqos <= slavew_arqos;
      master_arburst <= slavew_arburst;
      master_arsize <= slavew_arsize;
      slavew_arready <= master_arready;
      pend_master_write(MAX_SLAVE_PORT-1 downto 0) <= (others=>'0');
      pend_master_write(MAX_SLAVE_PORT) <= '1';
      pend_master_write(MAX_SLAVE_PORT+1) <= '0';
      pend_master_we <= master_arready;
      curr <= (others=>'0');
      curr(SW) <= '1';
   else
      master_araddr <= (others=>'0');
      master_arlen <= (others=>'0');
      master_arvalid <= '0';
      master_arid <= (others=>'0');
      master_arlock <= (others=>'0');
      master_arcache <= (others=>'0');
      master_arprot <= (others=>'0');
      master_arqos <= (others=>'0');
      master_arburst <= (others=>'0');
      master_arsize <= (others=>'0');
      pend_master_write <= (others=>'0');
      pend_master_we <= '0';
      curr <= (others=>'0');
   end if;
end process;

end rtl;
