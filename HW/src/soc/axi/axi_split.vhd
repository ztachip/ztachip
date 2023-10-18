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
-- Split a AXI master interface into multiple AXI master interfaces based
-- on memory address ranges.
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity axi_split is
   generic (
      NUM_MASTER_PORT     : integer:=3;
      BAR_LO_BIT          : integer_array(2 downto 0);
      BAR_HI_BIT          : integer_array(2 downto 0);
      BAR                 : integer_array(2 downto 0)
   );
   port 
   (
      clock_in               : in std_logic;
      reset_in               : in std_logic;

      -- Slave port
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
      axislave_rdata_out     : OUT axi_rdata_t;
      axislave_rresp_out     : OUT axi_rresp_t;
      axislave_arready_out   : OUT axi_arready_t;
      axislave_rready_in     : IN axi_rready_t;
      axislave_arburst_in    : IN axi_arburst_t;
      axislave_arsize_in     : IN axi_arsize_t;

      axislave_awaddr_in     : IN axi_awaddr_t;
      axislave_awlen_in      : IN axi_awlen_t;
      axislave_awvalid_in    : IN axi_awvalid_t;
      axislave_wvalid_in     : IN axi_wvalid_t;
      axislave_wdata_in      : IN axi_wdata_t;
      axislave_wlast_in      : IN axi_wlast_t;
      axislave_wstrb_in      : IN axi_wstrb_t;
      axislave_awready_out   : OUT axi_awready_t;
      axislave_wready_out    : OUT axi_wready_t;
      axislave_bresp_out     : OUT axi_bresp_t;
      axislave_bid_out       : OUT axi_bid_t;
      axislave_bvalid_out    : OUT axi_bvalid_t;
      axislave_awburst_in    : IN axi_awburst_t;
      axislave_awcache_in    : IN axi_awcache_t;
      axislave_awid_in       : IN axi_awid_t;
      axislave_awlock_in     : IN axi_awlock_t;
      axislave_awprot_in     : IN axi_awprot_t;
      axislave_awqos_in      : IN axi_awqos_t;
      axislave_awsize_in     : IN axi_awsize_t;
      axislave_bready_in     : IN axi_bready_t;
                           
      -- Master port #0
      aximaster0_araddr_out  : OUT axi_araddr_t;
      aximaster0_arlen_out   : OUT axi_arlen_t;
      aximaster0_arvalid_out : OUT axi_arvalid_t;
      aximaster0_arid_out    : OUT axi_arid_t;
      aximaster0_arlock_out  : OUT axi_arlock_t;
      aximaster0_arcache_out : OUT axi_arcache_t;
      aximaster0_arprot_out  : OUT axi_arprot_t;
      aximaster0_arqos_out   : OUT axi_arqos_t;
      aximaster0_rid_in      : IN axi_rid_t;              
      aximaster0_rvalid_in   : IN axi_rvalid_t;
      aximaster0_rlast_in    : IN axi_rlast_t;
      aximaster0_rdata_in    : IN axi_rdata_t;
      aximaster0_rresp_in    : IN axi_rresp_t;
      aximaster0_arready_in  : IN axi_arready_t;
      aximaster0_rready_out  : OUT axi_rready_t;
      aximaster0_arburst_out : OUT axi_arburst_t;
      aximaster0_arsize_out  : OUT axi_arsize_t;

      aximaster0_awaddr_out  : OUT axi_awaddr_t;
      aximaster0_awlen_out   : OUT axi_awlen_t;
      aximaster0_awvalid_out : OUT axi_awvalid_t;
      aximaster0_wvalid_out  : OUT axi_wvalid_t;
      aximaster0_wdata_out   : OUT axi_wdata_t;
      aximaster0_wlast_out   : OUT axi_wlast_t;
      aximaster0_wstrb_out   : OUT axi_wstrb_t;
      aximaster0_awready_in  : IN axi_awready_t;
      aximaster0_wready_in   : IN axi_wready_t;
      aximaster0_bresp_in    : IN axi_bresp_t;
      aximaster0_bid_in      : IN axi_bid_t;
      aximaster0_bvalid_in   : IN axi_bvalid_t;
      aximaster0_awburst_out : OUT axi_awburst_t;
      aximaster0_awcache_out : OUT axi_awcache_t;
      aximaster0_awid_out    : OUT axi_awid_t;
      aximaster0_awlock_out  : OUT axi_awlock_t;
      aximaster0_awprot_out  : OUT axi_awprot_t;
      aximaster0_awqos_out   : OUT axi_awqos_t;
      aximaster0_awsize_out  : OUT axi_awsize_t;
      aximaster0_bready_out  : OUT axi_bready_t;

      -- Master port #1
      aximaster1_araddr_out  : OUT axi_araddr_t;
      aximaster1_arlen_out   : OUT axi_arlen_t;
      aximaster1_arvalid_out : OUT axi_arvalid_t;
      aximaster1_arid_out    : OUT axi_arid_t;
      aximaster1_arlock_out  : OUT axi_arlock_t;
      aximaster1_arcache_out : OUT axi_arcache_t;
      aximaster1_arprot_out  : OUT axi_arprot_t;
      aximaster1_arqos_out   : OUT axi_arqos_t;
      aximaster1_rid_in      : IN axi_rid_t;              
      aximaster1_rvalid_in   : IN axi_rvalid_t;
      aximaster1_rlast_in    : IN axi_rlast_t;
      aximaster1_rdata_in    : IN axi_rdata_t;
      aximaster1_rresp_in    : IN axi_rresp_t;
      aximaster1_arready_in  : IN axi_arready_t;
      aximaster1_rready_out  : OUT axi_rready_t;
      aximaster1_arburst_out : OUT axi_arburst_t;
      aximaster1_arsize_out  : OUT axi_arsize_t;

      aximaster1_awaddr_out  : OUT axi_awaddr_t;
      aximaster1_awlen_out   : OUT axi_awlen_t;
      aximaster1_awvalid_out : OUT axi_awvalid_t;
      aximaster1_wvalid_out  : OUT axi_wvalid_t;
      aximaster1_wdata_out   : OUT axi_wdata_t;
      aximaster1_wlast_out   : OUT axi_wlast_t;
      aximaster1_wstrb_out   : OUT axi_wstrb_t;
      aximaster1_awready_in  : IN axi_awready_t;
      aximaster1_wready_in   : IN axi_wready_t;
      aximaster1_bresp_in    : IN axi_bresp_t;
      aximaster1_bid_in      : IN axi_bid_t;
      aximaster1_bvalid_in   : IN axi_bvalid_t;
      aximaster1_awburst_out : OUT axi_awburst_t;
      aximaster1_awcache_out : OUT axi_awcache_t;
      aximaster1_awid_out    : OUT axi_awid_t;
      aximaster1_awlock_out  : OUT axi_awlock_t;
      aximaster1_awprot_out  : OUT axi_awprot_t;
      aximaster1_awqos_out   : OUT axi_awqos_t;
      aximaster1_awsize_out  : OUT axi_awsize_t;
      aximaster1_bready_out  : OUT axi_bready_t;

      -- Master port #2
      aximaster2_araddr_out  : OUT axi_araddr_t;
      aximaster2_arlen_out   : OUT axi_arlen_t;
      aximaster2_arvalid_out : OUT axi_arvalid_t;
      aximaster2_arid_out    : OUT axi_arid_t;
      aximaster2_arlock_out  : OUT axi_arlock_t;
      aximaster2_arcache_out : OUT axi_arcache_t;
      aximaster2_arprot_out  : OUT axi_arprot_t;
      aximaster2_arqos_out   : OUT axi_arqos_t;
      aximaster2_rid_in      : IN axi_rid_t;              
      aximaster2_rvalid_in   : IN axi_rvalid_t;
      aximaster2_rlast_in    : IN axi_rlast_t;
      aximaster2_rdata_in    : IN axi_rdata_t;
      aximaster2_rresp_in    : IN axi_rresp_t;
      aximaster2_arready_in  : IN axi_arready_t;
      aximaster2_rready_out  : OUT axi_rready_t;
      aximaster2_arburst_out : OUT axi_arburst_t;
      aximaster2_arsize_out  : OUT axi_arsize_t;

      aximaster2_awaddr_out  : OUT axi_awaddr_t;
      aximaster2_awlen_out   : OUT axi_awlen_t;
      aximaster2_awvalid_out : OUT axi_awvalid_t;
      aximaster2_wvalid_out  : OUT axi_wvalid_t;
      aximaster2_wdata_out   : OUT axi_wdata_t;
      aximaster2_wlast_out   : OUT axi_wlast_t;
      aximaster2_wstrb_out   : OUT axi_wstrb_t;
      aximaster2_awready_in  : IN axi_awready_t;
      aximaster2_wready_in   : IN axi_wready_t;
      aximaster2_bresp_in    : IN axi_bresp_t;
      aximaster2_bid_in      : IN axi_bid_t;
      aximaster2_bvalid_in   : IN axi_bvalid_t;
      aximaster2_awburst_out : OUT axi_awburst_t;
      aximaster2_awcache_out : OUT axi_awcache_t;
      aximaster2_awid_out    : OUT axi_awid_t;
      aximaster2_awlock_out  : OUT axi_awlock_t;
      aximaster2_awprot_out  : OUT axi_awprot_t;
      aximaster2_awqos_out   : OUT axi_awqos_t;
      aximaster2_awsize_out  : OUT axi_awsize_t;
      aximaster2_bready_out  : OUT axi_bready_t
   );
end axi_split;

architecture rtl of axi_split is

constant M0:integer:=0;
constant M1:integer:=1;
constant M2:integer:=2;

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

SIGNAL aximaster_rids:axi_rids_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_rvalids:axi_rvalids_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_rlasts:axi_rlasts_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_rdatas:axi_rdatas_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_rresps:axi_rresps_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_arreadys:axi_arreadys_t(NUM_MASTER_PORT-1 downto 0);
        
SIGNAL aximaster_awaddrs:axi_awaddrs_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awlens:axi_awlens_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awvalids:axi_awvalids_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_wvalids:axi_wvalids_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_wdatas:axi_wdatas_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_wlasts:axi_wlasts_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_wstrbs:axi_wstrbs_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awbursts:axi_awbursts_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awcaches:axi_awcaches_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awids:axi_awids_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awlocks:axi_awlocks_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awprots:axi_awprots_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awqoss:axi_awqoss_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_awsizes:axi_awsizes_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_breadys:axi_breadys_t(NUM_MASTER_PORT-1 downto 0);        

SIGNAL aximaster_awreadys:axi_awreadys_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_wreadys:axi_wreadys_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_bresps:axi_bresps_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_bids:axi_bids_t(NUM_MASTER_PORT-1 downto 0);
SIGNAL aximaster_bvalids:axi_bvalids_t(NUM_MASTER_PORT-1 downto 0);

begin

aximaster0_araddr_out <= aximaster_araddrs(M0);
aximaster0_arlen_out <= aximaster_arlens(M0);
aximaster0_arvalid_out <= aximaster_arvalids(M0);   
aximaster0_arid_out <= aximaster_arids(M0);
aximaster0_arlock_out <= aximaster_arlocks(M0);
aximaster0_arcache_out <= aximaster_arcaches(M0);
aximaster0_arprot_out <= aximaster_arprots(M0);
aximaster0_arqos_out <= aximaster_arqoss(M0);
aximaster0_rready_out <= aximaster_rreadys(M0);
aximaster0_arburst_out <= aximaster_arbursts(M0);
aximaster0_arsize_out <= aximaster_arsizes(M0);
aximaster_rids(M0) <= aximaster0_rid_in;
aximaster_rvalids(M0) <= aximaster0_rvalid_in;
aximaster_rlasts(M0) <= aximaster0_rlast_in;
aximaster_rdatas(M0) <= aximaster0_rdata_in;
aximaster_rresps(M0) <= aximaster0_rresp_in;
aximaster_arreadys(M0) <= aximaster0_arready_in;     
aximaster0_awaddr_out <= aximaster_awaddrs(M0); 
aximaster0_awlen_out <= aximaster_awlens(M0);
aximaster0_awvalid_out <= aximaster_awvalids(M0);
aximaster0_wvalid_out <= aximaster_wvalids(M0);
aximaster0_wdata_out <= aximaster_wdatas(M0);
aximaster0_wlast_out <= aximaster_wlasts(M0);
aximaster0_wstrb_out <= aximaster_wstrbs(M0);
aximaster0_awburst_out <= aximaster_awbursts(M0);
aximaster0_awcache_out <= aximaster_awcaches(M0);
aximaster0_awid_out <= aximaster_awids(M0);
aximaster0_awlock_out <= aximaster_awlocks(M0);
aximaster0_awprot_out <= aximaster_awprots(M0);
aximaster0_awqos_out <= aximaster_awqoss(M0);
aximaster0_awsize_out <=aximaster_awsizes(M0);
aximaster0_bready_out <= aximaster_breadys(M0);
aximaster_awreadys(M0) <= aximaster0_awready_in; 
aximaster_wreadys(M0) <= aximaster0_wready_in; 
aximaster_bresps(M0) <= aximaster0_bresp_in; 
aximaster_bids(M0) <= aximaster0_bid_in; 
aximaster_bvalids(M0) <= aximaster0_bvalid_in; 

aximaster1_araddr_out <= aximaster_araddrs(M1);
aximaster1_arlen_out <= aximaster_arlens(M1);
aximaster1_arvalid_out <= aximaster_arvalids(M1);   
aximaster1_arid_out <= aximaster_arids(M1);
aximaster1_arlock_out <= aximaster_arlocks(M1);
aximaster1_arcache_out <= aximaster_arcaches(M1);
aximaster1_arprot_out <= aximaster_arprots(M1);
aximaster1_arqos_out <= aximaster_arqoss(M1);
aximaster1_rready_out <= aximaster_rreadys(M1);
aximaster1_arburst_out <= aximaster_arbursts(M1);
aximaster1_arsize_out <= aximaster_arsizes(M1);
aximaster_rids(M1) <= aximaster1_rid_in;
aximaster_rvalids(M1) <= aximaster1_rvalid_in;
aximaster_rlasts(M1) <= aximaster1_rlast_in;
aximaster_rdatas(M1) <= aximaster1_rdata_in;
aximaster_rresps(M1) <= aximaster1_rresp_in;
aximaster_arreadys(M1) <= aximaster1_arready_in;     
aximaster1_awaddr_out <= aximaster_awaddrs(M1); 
aximaster1_awlen_out <= aximaster_awlens(M1);
aximaster1_awvalid_out <= aximaster_awvalids(M1);
aximaster1_wvalid_out <= aximaster_wvalids(M1);
aximaster1_wdata_out <= aximaster_wdatas(M1);
aximaster1_wlast_out <= aximaster_wlasts(M1);
aximaster1_wstrb_out <= aximaster_wstrbs(M1);
aximaster1_awburst_out <= aximaster_awbursts(M1);
aximaster1_awcache_out <= aximaster_awcaches(M1);
aximaster1_awid_out <= aximaster_awids(M1);
aximaster1_awlock_out <= aximaster_awlocks(M1);
aximaster1_awprot_out <= aximaster_awprots(M1);
aximaster1_awqos_out <= aximaster_awqoss(M1);
aximaster1_awsize_out <=aximaster_awsizes(M1);
aximaster1_bready_out <= aximaster_breadys(M1);
aximaster_awreadys(M1) <= aximaster1_awready_in; 
aximaster_wreadys(M1) <= aximaster1_wready_in; 
aximaster_bresps(M1) <= aximaster1_bresp_in; 
aximaster_bids(M1) <= aximaster1_bid_in; 
aximaster_bvalids(M1) <= aximaster1_bvalid_in; 

aximaster2_araddr_out <= aximaster_araddrs(M2);
aximaster2_arlen_out <= aximaster_arlens(M2);
aximaster2_arvalid_out <= aximaster_arvalids(M2);   
aximaster2_arid_out <= aximaster_arids(M2);
aximaster2_arlock_out <= aximaster_arlocks(M2);
aximaster2_arcache_out <= aximaster_arcaches(M2);
aximaster2_arprot_out <= aximaster_arprots(M2);
aximaster2_arqos_out <= aximaster_arqoss(M2);
aximaster2_rready_out <= aximaster_rreadys(M2);
aximaster2_arburst_out <= aximaster_arbursts(M2);
aximaster2_arsize_out <= aximaster_arsizes(M2);
aximaster_rids(M2) <= aximaster2_rid_in;
aximaster_rvalids(M2) <= aximaster2_rvalid_in;
aximaster_rlasts(M2) <= aximaster2_rlast_in;
aximaster_rdatas(M2) <= aximaster2_rdata_in;
aximaster_rresps(M2) <= aximaster2_rresp_in;
aximaster_arreadys(M2) <= aximaster2_arready_in;     
aximaster2_awaddr_out <= aximaster_awaddrs(M2); 
aximaster2_awlen_out <= aximaster_awlens(M2);
aximaster2_awvalid_out <= aximaster_awvalids(M2);
aximaster2_wvalid_out <= aximaster_wvalids(M2);
aximaster2_wdata_out <= aximaster_wdatas(M2);
aximaster2_wlast_out <= aximaster_wlasts(M2);
aximaster2_wstrb_out <= aximaster_wstrbs(M2);
aximaster2_awburst_out <= aximaster_awbursts(M2);
aximaster2_awcache_out <= aximaster_awcaches(M2);
aximaster2_awid_out <= aximaster_awids(M2);
aximaster2_awlock_out <= aximaster_awlocks(M2);
aximaster2_awprot_out <= aximaster_awprots(M2);
aximaster2_awqos_out <= aximaster_awqoss(M2);
aximaster2_awsize_out <=aximaster_awsizes(M2);
aximaster2_bready_out <= aximaster_breadys(M2);
aximaster_awreadys(M2) <= aximaster2_awready_in; 
aximaster_wreadys(M2) <= aximaster2_wready_in; 
aximaster_bresps(M2) <= aximaster2_bresp_in; 
aximaster_bids(M2) <= aximaster2_bid_in; 
aximaster_bvalids(M2) <= aximaster2_bvalid_in; 

-- Split AXI a master read interfaces into multiple master read interfaces

axi_split_read_i: axi_split_read
   generic map (
      NUM_MASTER_PORT=>NUM_MASTER_PORT,
      BAR_LO_BIT=>BAR_LO_BIT,
      BAR_HI_BIT=>BAR_HI_BIT,
      BAR=>BAR
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      
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

      aximaster_araddrs_out=>aximaster_araddrs,
      aximaster_arlens_out=>aximaster_arlens,
      aximaster_arvalids_out=>aximaster_arvalids, 
      aximaster_arids_out=>aximaster_arids,
      aximaster_arlocks_out=>aximaster_arlocks,
      aximaster_arcaches_out=>aximaster_arcaches,
      aximaster_arprots_out=>aximaster_arprots,
      aximaster_arqoss_out=>aximaster_arqoss,
      aximaster_rids_in=>aximaster_rids,
      aximaster_rvalids_in=>aximaster_rvalids,
      aximaster_rlasts_in=>aximaster_rlasts,
      aximaster_rdatas_in=>aximaster_rdatas,
      aximaster_rresps_in=>aximaster_rresps,
      aximaster_arreadys_in=>aximaster_arreadys,
      aximaster_rreadys_out=>aximaster_rreadys,
      aximaster_arbursts_out=>aximaster_arbursts,
      aximaster_arsizes_out=>aximaster_arsizes
   );

-- Split AXI a master write interface into multiple master write interfaces

axi_split_write_i: axi_split_write
   generic map (
      NUM_MASTER_PORT=>NUM_MASTER_PORT,
      BAR_LO_BIT=>BAR_LO_BIT,
      BAR_HI_BIT=>BAR_HI_BIT,
      BAR=>BAR
   )
   port map 
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      
      axislave_awaddr_in=>axislave_awaddr_in,
      axislave_awlen_in=>axislave_awlen_in,
      axislave_awvalid_in=>axislave_awvalid_in,
      axislave_wvalid_in=>axislave_wvalid_in,
      axislave_wdata_in=>axislave_wdata_in,
      axislave_wlast_in=>axislave_wlast_in,
      axislave_wstrb_in=>axislave_wstrb_in,
      axislave_awready_out=>axislave_awready_out,
      axislave_wready_out=>axislave_wready_out,
      axislave_bresp_out=>axislave_bresp_out,
      axislave_bid_out=>axislave_bid_out,
      axislave_bvalid_out=>axislave_bvalid_out,
      axislave_awburst_in=>axislave_awburst_in,
      axislave_awcache_in=>axislave_awcache_in,
      axislave_awid_in=>axislave_awid_in,
      axislave_awlock_in=>axislave_awlock_in,
      axislave_awprot_in=>axislave_awprot_in,
      axislave_awqos_in=>axislave_awqos_in,
      axislave_awsize_in=>axislave_awsize_in,
      axislave_bready_in=>axislave_bready_in,

      aximaster_awaddrs_out=>aximaster_awaddrs,
      aximaster_awlens_out=>aximaster_awlens,
      aximaster_awvalids_out=>aximaster_awvalids,
      aximaster_wvalids_out=>aximaster_wvalids,
      aximaster_wdatas_out=>aximaster_wdatas,
      aximaster_wlasts_out=>aximaster_wlasts,
      aximaster_wstrbs_out=>aximaster_wstrbs,
      aximaster_awreadys_in=>aximaster_awreadys,
      aximaster_wreadys_in=>aximaster_wreadys,
      aximaster_bresps_in=>aximaster_bresps,
      aximaster_bids_in=>aximaster_bids,
      aximaster_bvalids_in=>aximaster_bvalids,
      aximaster_awbursts_out=>aximaster_awbursts,
      aximaster_awcaches_out=>aximaster_awcaches,
      aximaster_awids_out=>aximaster_awids,
      aximaster_awlocks_out=>aximaster_awlocks,
      aximaster_awprots_out=>aximaster_awprots,
      aximaster_awqoss_out=>aximaster_awqoss,
      aximaster_awsizes_out=>aximaster_awsizes,
      aximaster_breadys_out=>aximaster_breadys     
   );

end rtl;
