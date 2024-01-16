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
-- AXI crossbar
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity axi_split_read is
   generic (
      NUM_MASTER_PORT     : integer:=4;
      NUM_MASTER_PORT_USED: integer:=4;
      BAR_LO_BIT          : integer_array(3 downto 0);
      BAR_HI_BIT          : integer_array(3 downto 0);
      BAR                 : integer_array(3 downto 0)
   );
   port 
   (
      clock_in                : in std_logic;
      reset_in                : in std_logic;
               
      -- Slave port 
      axislave_araddr_in      : IN axi_araddr_t;
      axislave_arlen_in       : IN axi_arlen_t;
      axislave_arvalid_in     : IN axi_arvalid_t;
      axislave_arid_in        : IN axi_arid_t;
      axislave_arlock_in      : IN axi_arlock_t;
      axislave_arcache_in     : IN axi_arcache_t;
      axislave_arprot_in      : IN axi_arprot_t;
      axislave_arqos_in       : IN axi_arqos_t;
      axislave_rid_out        : OUT axi_rid_t;          
      axislave_rvalid_out     : OUT axi_rvalid_t;
      axislave_rlast_out      : OUT axi_rlast_t;
      axislave_rdata_out      : OUT axi_rdata_t;
      axislave_rresp_out      : OUT axi_rresp_t;
      axislave_arready_out    : OUT axi_arready_t;
      axislave_rready_in      : IN axi_rready_t;
      axislave_arburst_in     : IN axi_arburst_t;
      axislave_arsize_in      : IN axi_arsize_t;

      -- Master ports
      aximaster_araddrs_out   : OUT axi_araddrs_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arlens_out    : OUT axi_arlens_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arvalids_out  : OUT axi_arvalids_t(NUM_MASTER_PORT-1 downto 0);    
      aximaster_arids_out     : OUT axi_arids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arlocks_out   : OUT axi_arlocks_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arcaches_out  : OUT axi_arcaches_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arprots_out   : OUT axi_arprots_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arqoss_out    : OUT axi_arqoss_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_rids_in       : IN axi_rids_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_rvalids_in    : IN axi_rvalids_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_rlasts_in     : IN axi_rlasts_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_rdatas_in     : IN axi_rdatas_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_rresps_in     : IN axi_rresps_t(NUM_MASTER_PORT-1 downto 0):=(others=>(others=>'0'));
      aximaster_arreadys_in   : IN axi_arreadys_t(NUM_MASTER_PORT-1 downto 0):=(others=>'0');
      aximaster_rreadys_out   : OUT axi_rreadys_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arbursts_out  : OUT axi_arbursts_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_arsizes_out   : OUT axi_arsizes_t(NUM_MASTER_PORT-1 downto 0)
   );
end axi_split_read;

architecture rtl of axi_split_read is

SIGNAL rid:axi_rid_t;              
SIGNAL rvalid:axi_rvalid_t;
SIGNAL rlast:axi_rlast_t;
SIGNAL rdata:axi_rdata_t;
SIGNAL rresp:axi_rresp_t;
SIGNAL arready:axi_arready_t;

SIGNAL axislave_araddr:axi_araddr_t;
SIGNAL axislave_arlen:axi_arlen_t;
SIGNAL axislave_arvalid:axi_arvalid_t;
SIGNAL axislave_arid:axi_arid_t;
SIGNAL axislave_arlock:axi_arlock_t;
SIGNAL axislave_arcache:axi_arcache_t;
SIGNAL axislave_arprot:axi_arprot_t;
SIGNAL axislave_arqos:axi_arqos_t;
SIGNAL axislave_rid:axi_rid_t;          
SIGNAL axislave_rvalid:axi_rvalid_t;
SIGNAL axislave_rlast:axi_rlast_t;
SIGNAL axislave_rdata:axi_rdata_t;
SIGNAL axislave_rresp:axi_rresp_t;
SIGNAL axislave_arready:axi_arready_t;
SIGNAL axislave_rready:axi_rready_t;
SIGNAL axislave_arburst:axi_arburst_t;
SIGNAL axislave_arsize:axi_arsize_t;

SIGNAL aximaster_araddrs:axi_araddrs_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arlens:axi_arlens_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arvalids:axi_arvalids_t(NUM_MASTER_PORT-1 downto 0);     
SIGNAL aximaster_arids:axi_arids_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arlocks:axi_arlocks_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arcaches:axi_arcaches_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arprots:axi_arprots_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arqoss:axi_arqoss_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_rreadys:axi_rreadys_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arbursts:axi_arbursts_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arsizes:axi_arsizes_t(NUM_MASTER_PORT-1 downto 0);  

SIGNAL pending_read:STD_LOGIC;
SIGNAL pending_write:STD_LOGIC;
SIGNAL pending_read_rec:STD_LOGIC_VECTOR(NUM_MASTER_PORT-1 DOWNTO 0);
SIGNAL pending_write_rec:STD_LOGIC_VECTOR(NUM_MASTER_PORT-1 DOWNTO 0);
SIGNAL pending_read_empty:STD_LOGIC;
SIGNAL pending_write_full:STD_LOGIC;

SIGNAL rready:std_logic;
SIGNAL axislave_rid_r:axi_rid_t;          
SIGNAL axislave_rvalid_r:axi_rvalid_t;
SIGNAL axislave_rlast_r:axi_rlast_t;
SIGNAL axislave_rdata_r:axi_rdata_t;
SIGNAL axislave_rresp_r:axi_rresp_t;

constant M0:integer:=0;
constant M1:integer:=1;
constant M2:integer:=2;
constant M3:integer:=3;

begin

axislave_rid <= axislave_rid_r;     
axislave_rvalid <= axislave_rvalid_r;
axislave_rlast <= axislave_rlast_r;
axislave_rdata <= axislave_rdata_r;
axislave_rresp <= axislave_rresp_r;
axislave_arready <= arready;

aximaster_araddrs_out <= aximaster_araddrs;
aximaster_arlens_out <= aximaster_arlens;
aximaster_arvalids_out <= aximaster_arvalids;
aximaster_arids_out <= aximaster_arids;
aximaster_arlocks_out <= aximaster_arlocks;
aximaster_arcaches_out <= aximaster_arcaches;
aximaster_arprots_out <= aximaster_arprots;
aximaster_arqoss_out <= aximaster_arqoss;
aximaster_rreadys_out <= aximaster_rreadys;
aximaster_arbursts_out <= aximaster_arbursts;
aximaster_arsizes_out <= aximaster_arsizes;

pending_read <= rvalid and rlast and rready; 

read_ifc_i:axi_read
   generic map (
      DATA_WIDTH=>32,
      FIFO_DEPTH=>5,
      FIFO_DATA_DEPTH=>5,
      CCD=>FALSE    
   )
   port map 
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      axislave_clock_in=>clock_in,
      axislave_araddr_in=>axislave_araddr_in,
      axislave_arlen_in=>axislave_arlen_in,
      axislave_arvalid_in=>axislave_arvalid_in,
      axislave_arid_in=>axislave_arid_in,
      axislave_arlock_in=>axislave_arlock_in,
      axislave_arcache_in=>axislave_arcache_in,
      axislave_arprot_in=>axislave_arprot_in,
      axislave_arqos_in=>axislave_arqos_in,
      axislave_rid_out=>axislave_rid_out,    
      axislave_rvalid_out=>axislave_rvalid_out,
      axislave_rlast_out=>axislave_rlast_out,
      axislave_rdata_out=>axislave_rdata_out,
      axislave_rresp_out=>axislave_rresp_out,
      axislave_arready_out=>axislave_arready_out,
      axislave_rready_in=>axislave_rready_in,
      axislave_arburst_in=>axislave_arburst_in,
      axislave_arsize_in=>axislave_arsize_in,

      aximaster_clock_in=>clock_in,
      aximaster_araddr_out=>axislave_araddr,
      aximaster_arlen_out=>axislave_arlen,
      aximaster_arvalid_out=>axislave_arvalid,
      aximaster_arid_out=>axislave_arid,
      aximaster_arlock_out=>axislave_arlock,
      aximaster_arcache_out=>axislave_arcache,
      aximaster_arprot_out=>axislave_arprot,
      aximaster_arqos_out=>axislave_arqos,
      aximaster_rid_in=>axislave_rid,
      aximaster_rvalid_in=>axislave_rvalid,
      aximaster_rlast_in=>axislave_rlast,
      aximaster_rdata_in=>axislave_rdata,
      aximaster_rresp_in=>axislave_rresp,
      aximaster_arready_in=>axislave_arready,
      aximaster_rready_out=>axislave_rready,
      aximaster_arburst_out=>axislave_arburst,
      aximaster_arsize_out=>axislave_arsize
   );

pending_fifo:scfifo
   generic map
   (
      DATA_WIDTH=>NUM_MASTER_PORT,
      FIFO_DEPTH=>8,
      LOOKAHEAD=>TRUE
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>pending_write_rec,
      write_in=>pending_write,
      read_in=>pending_read,
      q_out=>pending_read_rec,
      empty_out=>pending_read_empty,
      full_out=>pending_write_full,
      ravail_out=>open,
      wused_out=>open,
      almost_full_out=>open
   );

process(pending_write_full,axislave_arvalid,axislave_araddr,aximaster_arreadys_in,
         pending_read_empty,pending_read_rec,aximaster_rids_in,
         aximaster_rvalids_in,aximaster_rlasts_in,aximaster_rdatas_in,
         aximaster_rresps_in,rready,
         axislave_arlen,axislave_arid,axislave_arlock,
         axislave_arcache,axislave_arprot,axislave_arqos,axislave_arburst,
         axislave_arsize)

begin

-- Route request to correct masters

pending_write <= '0';
pending_write_rec <= (others=>'0');
aximaster_arvalids <= (others=>'0');
arready <= '1';
if(pending_write_full='1') then
   arready <= '0';
elsif(axislave_arvalid='1') then
   if((M0 < NUM_MASTER_PORT_USED) and
      axislave_araddr(BAR_HI_BIT(M0) downto BAR_LO_BIT(M0))=std_logic_vector(to_unsigned(BAR(M0),BAR_HI_BIT(M0)-BAR_LO_BIT(M0)+1))) then
      aximaster_arvalids(M0) <= '1';
      pending_write_rec(M0) <= '1';
      pending_write <= aximaster_arreadys_in(M0);
      arready <= aximaster_arreadys_in(M0);
   elsif((M1 < NUM_MASTER_PORT_USED) and
         axislave_araddr(BAR_HI_BIT(M1) downto BAR_LO_BIT(M1))=std_logic_vector(to_unsigned(BAR(M1),BAR_HI_BIT(M1)-BAR_LO_BIT(M1)+1))) then 
      aximaster_arvalids(M1) <= '1';
      pending_write_rec(M1) <= '1';
      pending_write <= aximaster_arreadys_in(M1);
      arready <= aximaster_arreadys_in(M1);
   elsif((M2 < NUM_MASTER_PORT_USED) and
      axislave_araddr(BAR_HI_BIT(M2) downto BAR_LO_BIT(M2))=std_logic_vector(to_unsigned(BAR(M2),BAR_HI_BIT(M2)-BAR_LO_BIT(M2)+1))) then 
      aximaster_arvalids(M2) <= '1';
      pending_write_rec(M2) <= '1';
      pending_write <= aximaster_arreadys_in(M2);
      arready <= aximaster_arreadys_in(M2);
   elsif((M3 < NUM_MASTER_PORT_USED) and
      axislave_araddr(BAR_HI_BIT(M3) downto BAR_LO_BIT(M3))=std_logic_vector(to_unsigned(BAR(M3),BAR_HI_BIT(M3)-BAR_LO_BIT(M3)+1))) then 
      aximaster_arvalids(M3) <= '1';
      pending_write_rec(M3) <= '1';
      pending_write <= aximaster_arreadys_in(M3);
      arready <= aximaster_arreadys_in(M3);
   end if;
end if;

-- Route read response from correct masters

aximaster_rreadys <= (others=>'0');
rid <= (others=>'0') ;     
rvalid <= '0';
rlast <= '0';
rdata <= (others=>'0');
rresp <= (others=>'0');
if((M0 < NUM_MASTER_PORT_USED) and
   pending_read_empty='0' and pending_read_rec(M0)='1') then
   rid <= aximaster_rids_in(M0);      
   rvalid <= aximaster_rvalids_in(M0);
   rlast <= aximaster_rlasts_in(M0);
   rdata <= aximaster_rdatas_in(M0);
   rresp <= aximaster_rresps_in(M0);
   aximaster_rreadys(M0) <= rready;
elsif((M1 < NUM_MASTER_PORT_USED) and
   pending_read_empty='0' and pending_read_rec(M1)='1') then
   rid <= aximaster_rids_in(M1);      
   rvalid <= aximaster_rvalids_in(M1);
   rlast <= aximaster_rlasts_in(M1);
   rdata <= aximaster_rdatas_in(M1);
   rresp <= aximaster_rresps_in(M1);
   aximaster_rreadys(M1) <= rready;
elsif((M2 < NUM_MASTER_PORT_USED) and
   pending_read_empty='0' and pending_read_rec(M2)='1') then
   rid <= aximaster_rids_in(M2);      
   rvalid <= aximaster_rvalids_in(M2);
   rlast <= aximaster_rlasts_in(M2);
   rdata <= aximaster_rdatas_in(M2);
   rresp <= aximaster_rresps_in(M2);
   aximaster_rreadys(M2) <= rready;
elsif((M3 < NUM_MASTER_PORT_USED) and
   pending_read_empty='0' and pending_read_rec(M3)='1') then
   rid <= aximaster_rids_in(M3);      
   rvalid <= aximaster_rvalids_in(M3);
   rlast <= aximaster_rlasts_in(M3);
   rdata <= aximaster_rdatas_in(M3);
   rresp <= aximaster_rresps_in(M3);
   aximaster_rreadys(M3) <= rready;
end if;

-- Route common slave signals to all master ports

FOR I IN 0 TO NUM_MASTER_PORT-1 LOOP
   aximaster_araddrs(I) <= axislave_araddr;
   aximaster_arlens(I) <= axislave_arlen;
   aximaster_arids(I) <= axislave_arid;
   aximaster_arlocks(I) <= axislave_arlock;
   aximaster_arcaches(I) <= axislave_arcache;
   aximaster_arprots(I) <= axislave_arprot;
   aximaster_arqoss(I) <= axislave_arqos;
   aximaster_arbursts(I) <= axislave_arburst;
   aximaster_arsizes(I) <= axislave_arsize;
END LOOP;

end process;

rready <= (not axislave_rvalid_r) or axislave_rready;

process(clock_in,reset_in)
begin
   if reset_in = '0' then
      axislave_rid_r <= (others=>'0');     
      axislave_rvalid_r <= '0';
      axislave_rlast_r <= '0';
      axislave_rdata_r <= (others=>'0');
      axislave_rresp_r <= (others=>'0');     
   else
      if rising_edge(clock_in) then  
         if(rready='1') then
            axislave_rid_r <= rid;     
            axislave_rvalid_r <= rvalid;
            axislave_rlast_r <= rlast;
            axislave_rdata_r <= rdata;
            axislave_rresp_r <= rresp;
         end if;
      end if;
   end if;
end process;

end rtl;
