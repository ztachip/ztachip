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

entity axi_merge is
   generic (
      R_FIFO_CMD_DEPTH     : integer_array(2 downto 0);
      R_FIFO_DATA_DEPTH    : integer_array(2 downto 0);
      R_FIFO_W_CMD_DEPTH   : integer;
      R_FIFO_W_DATA_DEPTH  : integer;
      W_FIFO_CMD_DEPTH     : integer_array(2 downto 0);
      W_FIFO_DATA_DEPTH    : integer_array(2 downto 0);
      W_FIFO_W_CMD_DEPTH   : integer;
      W_FIFO_W_DATA_DEPTH  : integer
   );
   port 
   (
      clock_in               : in std_logic;
      reset_in               : in std_logic;

      -- wide slave port
      axislavew_clock_in      : IN std_logic;
      axislavew_araddr_in     : IN axi_araddr_t;
      axislavew_arlen_in      : IN axi_arlen_t;
      axislavew_arvalid_in    : IN axi_arvalid_t;     
      axislavew_arid_in       : IN axi_arid_t;
      axislavew_arlock_in     : IN axi_arlock_t;
      axislavew_arcache_in    : IN axi_arcache_t;
      axislavew_arprot_in     : IN axi_arprot_t;
      axislavew_arqos_in      : IN axi_arqos_t;
      axislavew_rid_out       : OUT axi_rid_t;
      axislavew_rvalid_out    : OUT axi_rvalid_t;
      axislavew_rlast_out     : OUT axi_rlast_t;
      axislavew_rdata_out     : OUT axi_rdata64_t;
      axislavew_rresp_out     : OUT axi_rresp_t;
      axislavew_arready_out   : OUT axi_arready_t;
      axislavew_rready_in     : IN axi_rready_t:='0';
      axislavew_arburst_in    : IN axi_arburst_t;
      axislavew_arsize_in     : IN axi_arsize_t;

      axislavew_awaddr_in     : IN axi_awaddr_t;
      axislavew_awlen_in      : IN axi_awlen_t;
      axislavew_awvalid_in    : IN axi_awvalid_t;
      axislavew_wvalid_in     : IN axi_wvalid_t;
      axislavew_wdata_in      : IN axi_wdata64_t;
      axislavew_wlast_in      : IN axi_wlast_t;
      axislavew_wstrb_in      : IN axi_wstrb8_t;
      axislavew_awready_out   : OUT axi_awready_t;
      axislavew_wready_out    : OUT axi_wready_t;
      axislavew_bresp_out     : OUT axi_bresp_t;
      axislavew_bid_out       : OUT axi_bid_t;
      axislavew_bvalid_out    : OUT axi_bvalid_t;
      axislavew_awburst_in    : IN axi_awburst_t;
      axislavew_awcache_in    : IN axi_awcache_t;
      axislavew_awid_in       : IN axi_awid_t;
      axislavew_awlock_in     : IN axi_awlock_t;
      axislavew_awprot_in     : IN axi_awprot_t;
      axislavew_awqos_in      : IN axi_awqos_t;
      axislavew_awsize_in     : IN axi_awsize_t;
      axislavew_bready_in     : IN axi_bready_t;

      -- Slave port #0
      axislave0_clock_in      : IN std_logic;
      axislave0_araddr_in     : IN axi_araddr_t;
      axislave0_arlen_in      : IN axi_arlen_t;
      axislave0_arvalid_in    : IN axi_arvalid_t;     
      axislave0_arid_in       : IN axi_arid_t;
      axislave0_arlock_in     : IN axi_arlock_t;
      axislave0_arcache_in    : IN axi_arcache_t;
      axislave0_arprot_in     : IN axi_arprot_t;
      axislave0_arqos_in      : IN axi_arqos_t;
      axislave0_rid_out       : OUT axi_rid_t;
      axislave0_rvalid_out    : OUT axi_rvalid_t;
      axislave0_rlast_out     : OUT axi_rlast_t;
      axislave0_rdata_out     : OUT axi_rdata_t;
      axislave0_rresp_out     : OUT axi_rresp_t;
      axislave0_arready_out   : OUT axi_arready_t;
      axislave0_rready_in     : IN axi_rready_t;
      axislave0_arburst_in    : IN axi_arburst_t;
      axislave0_arsize_in     : IN axi_arsize_t;
      
      axislave0_awaddr_in         : IN axi_awaddr_t;
      axislave0_awlen_in          : IN axi_awlen_t;
      axislave0_awvalid_in        : IN axi_awvalid_t;
      axislave0_wvalid_in         : IN axi_wvalid_t;
      axislave0_wdata_in          : IN axi_wdata_t;
      axislave0_wlast_in          : IN axi_wlast_t;
      axislave0_wstrb_in          : IN axi_wstrb_t;
      axislave0_awready_out       : OUT axi_awready_t;
      axislave0_wready_out        : OUT axi_wready_t;
      axislave0_bresp_out         : OUT axi_bresp_t;
      axislave0_bid_out           : OUT axi_bid_t;
      axislave0_bvalid_out        : OUT axi_bvalid_t;
      axislave0_awburst_in        : IN axi_awburst_t;
      axislave0_awcache_in        : IN axi_awcache_t;
      axislave0_awid_in           : IN axi_awid_t;
      axislave0_awlock_in         : IN axi_awlock_t;
      axislave0_awprot_in         : IN axi_awprot_t;
      axislave0_awqos_in          : IN axi_awqos_t;
      axislave0_awsize_in         : IN axi_awsize_t;
      axislave0_bready_in         : IN axi_bready_t;

      -- Slave port #1
      axislave1_clock_in      : IN std_logic;
      axislave1_araddr_in     : IN axi_araddr_t;
      axislave1_arlen_in      : IN axi_arlen_t;
      axislave1_arvalid_in    : IN axi_arvalid_t;     
      axislave1_arid_in       : IN axi_arid_t;
      axislave1_arlock_in     : IN axi_arlock_t;
      axislave1_arcache_in    : IN axi_arcache_t;
      axislave1_arprot_in     : IN axi_arprot_t;
      axislave1_arqos_in      : IN axi_arqos_t;
      axislave1_rid_out       : OUT axi_rid_t;
      axislave1_rvalid_out    : OUT axi_rvalid_t;
      axislave1_rlast_out     : OUT axi_rlast_t;
      axislave1_rdata_out     : OUT axi_rdata_t;
      axislave1_rresp_out     : OUT axi_rresp_t;
      axislave1_arready_out   : OUT axi_arready_t;
      axislave1_rready_in     : IN axi_rready_t;
      axislave1_arburst_in    : IN axi_arburst_t;
      axislave1_arsize_in     : IN axi_arsize_t;

      axislave1_awaddr_in         : IN axi_awaddr_t;
      axislave1_awlen_in          : IN axi_awlen_t;
      axislave1_awvalid_in        : IN axi_awvalid_t;
      axislave1_wvalid_in         : IN axi_wvalid_t;
      axislave1_wdata_in          : IN axi_wdata_t;
      axislave1_wlast_in          : IN axi_wlast_t;
      axislave1_wstrb_in          : IN axi_wstrb_t;
      axislave1_awready_out       : OUT axi_awready_t;
      axislave1_wready_out        : OUT axi_wready_t;
      axislave1_bresp_out         : OUT axi_bresp_t;
      axislave1_bid_out           : OUT axi_bid_t;
      axislave1_bvalid_out        : OUT axi_bvalid_t;
      axislave1_awburst_in        : IN axi_awburst_t;
      axislave1_awcache_in        : IN axi_awcache_t;
      axislave1_awid_in           : IN axi_awid_t;
      axislave1_awlock_in         : IN axi_awlock_t;
      axislave1_awprot_in         : IN axi_awprot_t;
      axislave1_awqos_in          : IN axi_awqos_t;
      axislave1_awsize_in         : IN axi_awsize_t;
      axislave1_bready_in         : IN axi_bready_t;

      -- Slave port #2
      axislave2_clock_in      : IN std_logic;
      axislave2_araddr_in     : IN axi_araddr_t;
      axislave2_arlen_in      : IN axi_arlen_t;
      axislave2_arvalid_in    : IN axi_arvalid_t;     
      axislave2_arid_in       : IN axi_arid_t;
      axislave2_arlock_in     : IN axi_arlock_t;
      axislave2_arcache_in    : IN axi_arcache_t;
      axislave2_arprot_in     : IN axi_arprot_t;
      axislave2_arqos_in      : IN axi_arqos_t;
      axislave2_rid_out       : OUT axi_rid_t;
      axislave2_rvalid_out    : OUT axi_rvalid_t;
      axislave2_rlast_out     : OUT axi_rlast_t;
      axislave2_rdata_out     : OUT axi_rdata_t;
      axislave2_rresp_out     : OUT axi_rresp_t;
      axislave2_arready_out   : OUT axi_arready_t;
      axislave2_rready_in     : IN axi_rready_t;
      axislave2_arburst_in    : IN axi_arburst_t;
      axislave2_arsize_in     : IN axi_arsize_t;

      axislave2_awaddr_in         : IN axi_awaddr_t;
      axislave2_awlen_in          : IN axi_awlen_t;
      axislave2_awvalid_in        : IN axi_awvalid_t;
      axislave2_wvalid_in         : IN axi_wvalid_t;
      axislave2_wdata_in          : IN axi_wdata_t;
      axislave2_wlast_in          : IN axi_wlast_t;
      axislave2_wstrb_in          : IN axi_wstrb_t;
      axislave2_awready_out       : OUT axi_awready_t;
      axislave2_wready_out        : OUT axi_wready_t;
      axislave2_bresp_out         : OUT axi_bresp_t;
      axislave2_bid_out           : OUT axi_bid_t;
      axislave2_bvalid_out        : OUT axi_bvalid_t;
      axislave2_awburst_in        : IN axi_awburst_t;
      axislave2_awcache_in        : IN axi_awcache_t;
      axislave2_awid_in           : IN axi_awid_t;
      axislave2_awlock_in         : IN axi_awlock_t;
      axislave2_awprot_in         : IN axi_awprot_t;
      axislave2_awqos_in          : IN axi_awqos_t;
      axislave2_awsize_in         : IN axi_awsize_t;
      axislave2_bready_in         : IN axi_bready_t;
                           
      -- Master port #0
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
      aximaster_rresp_in      : IN axi_rresp_t;
      aximaster_arready_in    : IN axi_arready_t;
      aximaster_rready_out    : OUT axi_rready_t;
      aximaster_arburst_out   : OUT axi_arburst_t;
      aximaster_arsize_out    : OUT axi_arsize_t;
      
      aximaster_awaddr_out         : OUT axi_awaddr_t;
      aximaster_awlen_out          : OUT axi_awlen_t;
      aximaster_awvalid_out        : OUT axi_awvalid_t;
      aximaster_wvalid_out         : OUT axi_wvalid_t;
      aximaster_wdata_out          : OUT axi_wdata64_t;
      aximaster_wlast_out          : OUT axi_wlast_t;
      aximaster_wstrb_out          : OUT axi_wstrb8_t;
      aximaster_awready_in         : IN axi_awready_t;
      aximaster_wready_in          : IN axi_wready_t;
      aximaster_bresp_in           : IN axi_bresp_t;
      aximaster_bid_in             : IN axi_bid_t;
      aximaster_bvalid_in          : IN axi_bvalid_t;
      aximaster_awburst_out        : OUT axi_awburst_t;
      aximaster_awcache_out        : OUT axi_awcache_t;
      aximaster_awid_out           : OUT axi_awid_t;
      aximaster_awlock_out         : OUT axi_awlock_t;
      aximaster_awprot_out         : OUT axi_awprot_t;
      aximaster_awqos_out          : OUT axi_awqos_t;
      aximaster_awsize_out         : OUT axi_awsize_t;
      aximaster_bready_out         : OUT axi_bready_t
   );
end axi_merge;

architecture rtl of axi_merge is

constant MAX_SLAVE_PORT:integer:=3;

SIGNAL axislave_clocks:std_logic_vector(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_araddrs:axi_araddrs_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arlens:axi_arlens_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arvalids:axi_arvalids_t(MAX_SLAVE_PORT-1 downto 0);     
SIGNAL axislave_arids:axi_arids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arlocks:axi_arlocks_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arcaches:axi_arcaches_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arprots:axi_arprots_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arqoss:axi_arqoss_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_rids:axi_rids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_rreadys:axi_rreadys_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arbursts:axi_arbursts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arsizes:axi_arsizes_t(MAX_SLAVE_PORT-1 downto 0);

SIGNAL aximaster_rvalid:axi_rvalid_t;
SIGNAL aximaster_rlast:axi_rlast_t;
SIGNAL aximaster_rdata:axi_rdata64_t;
SIGNAL aximaster_rresp:axi_rresp_t;
SIGNAL aximaster_arready:axi_arready_t;

SIGNAL axislave_rvalids:axi_rvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_rlasts:axi_rlasts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_rdatas:axi_rdatas_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_rresps:axi_rresps_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_arreadys:axi_arreadys_t(MAX_SLAVE_PORT-1 downto 0);

SIGNAL aximaster_araddr:axi_araddr_t;
SIGNAL aximaster_arlen:axi_arlen_t;
SIGNAL aximaster_arvalid:axi_arvalid_t;
SIGNAL aximaster_arid:axi_arid_t;
SIGNAL aximaster_arlock:axi_arlock_t;
SIGNAL aximaster_arcache:axi_arcache_t;
SIGNAL aximaster_arprot:axi_arprot_t;
SIGNAL aximaster_arqos:axi_arqos_t;
SIGNAL aximaster_rid:axi_rid_t;              
SIGNAL aximaster_rready:axi_rready_t;
SIGNAL aximaster_arburst:axi_arburst_t;
SIGNAL aximaster_arsize:axi_arsize_t;

SIGNAL axislave_awaddrs:axi_awaddrs_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awlens:axi_awlens_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awvalids:axi_awvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_wvalids:axi_wvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_wdatas:axi_wdatas_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_wlasts:axi_wlasts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_wstrbs:axi_wstrbs_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awreadys:axi_awreadys_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_wreadys:axi_wreadys_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_bresps:axi_bresps_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_bids:axi_bids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_bvalids:axi_bvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awbursts:axi_awbursts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awcaches:axi_awcaches_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awids:axi_awids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awlocks:axi_awlocks_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awprots:axi_awprots_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awqoss:axi_awqoss_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_awsizes:axi_awsizes_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL axislave_breadys:axi_breadys_t(MAX_SLAVE_PORT-1 downto 0);

begin

axislave0_rvalid_out <= axislave_rvalids(0);
axislave0_rid_out <= axislave_rids(0);
axislave0_rlast_out <= axislave_rlasts(0);
axislave0_rdata_out <= axislave_rdatas(0);
axislave0_rresp_out <= axislave_rresps(0);
axislave0_arready_out <= axislave_arreadys(0);

axislave1_rvalid_out <= axislave_rvalids(1);
axislave1_rid_out <= axislave_rids(1);
axislave1_rlast_out <= axislave_rlasts(1);
axislave1_rdata_out <= axislave_rdatas(1);
axislave1_rresp_out <= axislave_rresps(1);
axislave1_arready_out <= axislave_arreadys(1);

axislave2_rvalid_out <= axislave_rvalids(2);
axislave2_rid_out <= axislave_rids(2);
axislave2_rlast_out <= axislave_rlasts(2);
axislave2_rdata_out <= axislave_rdatas(2);
axislave2_rresp_out <= axislave_rresps(2);
axislave2_arready_out <= axislave_arreadys(2);

aximaster_araddr_out <= aximaster_araddr;
aximaster_arlen_out <= aximaster_arlen;
aximaster_arvalid_out <= aximaster_arvalid;
aximaster_arid_out <= aximaster_arid;
aximaster_arlock_out <= aximaster_arlock;
aximaster_arcache_out <= aximaster_arcache;
aximaster_arprot_out <= aximaster_arprot;
aximaster_arqos_out <= aximaster_arqos;              
aximaster_rready_out <= aximaster_rready;
aximaster_arburst_out <= aximaster_arburst;
aximaster_arsize_out <= aximaster_arsize;

axislave_clocks(0) <= axislave0_clock_in;
axislave_araddrs(0) <= axislave0_araddr_in;
axislave_arlens(0) <= axislave0_arlen_in;
axislave_arvalids(0) <= axislave0_arvalid_in;    
axislave_arids(0) <= axislave0_arid_in;
axislave_arlocks(0) <= axislave0_arlock_in;
axislave_arcaches(0) <= axislave0_arcache_in;
axislave_arprots(0) <= axislave0_arprot_in;
axislave_arqoss(0) <= axislave0_arqos_in;
axislave_rreadys(0) <= axislave0_rready_in;
axislave_arbursts(0) <= axislave0_arburst_in;
axislave_arsizes(0) <= axislave0_arsize_in;

axislave_clocks(1) <= axislave1_clock_in;
axislave_araddrs(1) <= axislave1_araddr_in;
axislave_arlens(1) <= axislave1_arlen_in;
axislave_arvalids(1) <= axislave1_arvalid_in;    
axislave_arids(1) <= axislave1_arid_in;
axislave_arlocks(1) <= axislave1_arlock_in;
axislave_arcaches(1) <= axislave1_arcache_in;
axislave_arprots(1) <= axislave1_arprot_in;
axislave_arqoss(1) <= axislave1_arqos_in;
axislave_rreadys(1) <= axislave1_rready_in;
axislave_arbursts(1) <= axislave1_arburst_in;
axislave_arsizes(1) <= axislave1_arsize_in;

axislave_clocks(2) <= axislave2_clock_in;
axislave_araddrs(2) <= axislave2_araddr_in;
axislave_arlens(2) <= axislave2_arlen_in;
axislave_arvalids(2) <= axislave2_arvalid_in;    
axislave_arids(2) <= axislave2_arid_in;
axislave_arlocks(2) <= axislave2_arlock_in;
axislave_arcaches(2) <= axislave2_arcache_in;
axislave_arprots(2) <= axislave2_arprot_in;
axislave_arqoss(2) <= axislave2_arqos_in;
axislave_rreadys(2) <= axislave2_rready_in;
axislave_arbursts(2) <= axislave2_arburst_in;
axislave_arsizes(2) <= axislave2_arsize_in;

aximaster_rvalid <= aximaster_rvalid_in;
aximaster_rid <= aximaster_rid_in;
aximaster_rlast <= aximaster_rlast_in;
aximaster_rdata <= aximaster_rdata_in;
aximaster_rresp <= aximaster_rresp_in;
aximaster_arready <= aximaster_arready_in;

axislave_awaddrs(0) <= axislave0_awaddr_in;
axislave_awlens(0) <= axislave0_awlen_in;
axislave_awvalids(0) <= axislave0_awvalid_in;
axislave_wvalids(0) <= axislave0_wvalid_in;
axislave_wdatas(0) <= axislave0_wdata_in;
axislave_wlasts(0) <= axislave0_wlast_in;
axislave_wstrbs(0) <= axislave0_wstrb_in;
axislave_awbursts(0) <= axislave0_awburst_in;
axislave_awcaches(0) <= axislave0_awcache_in;
axislave_awids(0) <= axislave0_awid_in;
axislave_awlocks(0) <= axislave0_awlock_in;
axislave_awprots(0) <= axislave0_awprot_in;
axislave_awqoss(0) <= axislave0_awqos_in;
axislave_awsizes(0) <= axislave0_awsize_in;
axislave_breadys(0) <= axislave0_bready_in;

axislave0_awready_out <= axislave_awreadys(0);
axislave0_wready_out <= axislave_wreadys(0);
axislave0_bresp_out <= axislave_bresps(0);
axislave0_bid_out <= axislave_bids(0);
axislave0_bvalid_out <= axislave_bvalids(0);
   
axislave_awaddrs(1) <= axislave1_awaddr_in;
axislave_awlens(1) <= axislave1_awlen_in;
axislave_awvalids(1) <= axislave1_awvalid_in;
axislave_wvalids(1) <= axislave1_wvalid_in;
axislave_wdatas(1) <= axislave1_wdata_in;
axislave_wlasts(1) <= axislave1_wlast_in;
axislave_wstrbs(1) <= axislave1_wstrb_in;
axislave_awbursts(1) <= axislave1_awburst_in;
axislave_awcaches(1) <= axislave1_awcache_in;
axislave_awids(1) <= axislave1_awid_in;
axislave_awlocks(1) <= axislave1_awlock_in;
axislave_awprots(1) <= axislave1_awprot_in;
axislave_awqoss(1) <= axislave1_awqos_in;
axislave_awsizes(1) <= axislave1_awsize_in;
axislave_breadys(1) <= axislave1_bready_in;

axislave1_awready_out <= axislave_awreadys(1);
axislave1_wready_out <= axislave_wreadys(1);
axislave1_bresp_out <= axislave_bresps(1);
axislave1_bid_out <= axislave_bids(1);
axislave1_bvalid_out <= axislave_bvalids(1);     

axislave_awaddrs(2) <= axislave2_awaddr_in;
axislave_awlens(2) <= axislave2_awlen_in;
axislave_awvalids(2) <= axislave2_awvalid_in;
axislave_wvalids(2) <= axislave2_wvalid_in;
axislave_wdatas(2) <= axislave2_wdata_in;
axislave_wlasts(2) <= axislave2_wlast_in;
axislave_wstrbs(2) <= axislave2_wstrb_in;
axislave_awbursts(2) <= axislave2_awburst_in;
axislave_awcaches(2) <= axislave2_awcache_in;
axislave_awids(2) <= axislave2_awid_in;
axislave_awlocks(2) <= axislave2_awlock_in;
axislave_awprots(2) <= axislave2_awprot_in;
axislave_awqoss(2) <= axislave2_awqos_in;
axislave_awsizes(2) <= axislave2_awsize_in;
axislave_breadys(2) <= axislave2_bready_in;

axislave2_awready_out <= axislave_awreadys(2);
axislave2_wready_out <= axislave_wreadys(2);
axislave2_bresp_out <= axislave_bresps(2);
axislave2_bid_out <= axislave_bids(2);
axislave2_bvalid_out <= axislave_bvalids(2);  

axi_merge_read_i: axi_merge_read
   generic map
   (
      FIFO_CMD_DEPTH=>R_FIFO_CMD_DEPTH,
      FIFO_DATA_DEPTH=>R_FIFO_DATA_DEPTH,
      FIFO_W_CMD_DEPTH=>R_FIFO_W_CMD_DEPTH,
      FIFO_W_DATA_DEPTH=>R_FIFO_W_DATA_DEPTH
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      -- wide slave port
      axislavew_clock_in=>axislavew_clock_in,
      axislavew_araddr_in=>axislavew_araddr_in,
      axislavew_arlen_in=>axislavew_arlen_in,
      axislavew_arvalid_in=>axislavew_arvalid_in,   
      axislavew_arid_in=>axislavew_arid_in,
      axislavew_arlock_in=>axislavew_arlock_in,
      axislavew_arcache_in=>axislavew_arcache_in,
      axislavew_arprot_in=>axislavew_arprot_in,
      axislavew_arqos_in=>axislavew_arqos_in,
      axislavew_rid_out=>axislavew_rid_out,
      axislavew_rvalid_out=>axislavew_rvalid_out,
      axislavew_rlast_out=>axislavew_rlast_out,
      axislavew_rdata_out=>axislavew_rdata_out,
      axislavew_rresp_out=>axislavew_rresp_out,
      axislavew_arready_out=>axislavew_arready_out,
      axislavew_rready_in=>axislavew_rready_in,
      axislavew_arburst_in=>axislavew_arburst_in,
      axislavew_arsize_in=>axislavew_arsize_in,
      
      -- Slace port
      axislave_clocks_in=>axislave_clocks,
      axislave_araddrs_in=>axislave_araddrs,
      axislave_arlens_in =>axislave_arlens,
      axislave_arvalids_in=>axislave_arvalids,
      axislave_arids_in=>axislave_arids,
      axislave_arlocks_in=>axislave_arlocks,
      axislave_arcaches_in =>axislave_arcaches,
      axislave_arprots_in =>axislave_arprots,
      axislave_arqoss_in=>axislave_arqoss,
      axislave_rids_out=>axislave_rids,
      axislave_rvalids_out=>axislave_rvalids,
      axislave_rlasts_out=>axislave_rlasts,
      axislave_rdatas_out=>axislave_rdatas,
      axislave_arreadys_out=>axislave_arreadys,
      axislave_rreadys_in=>axislave_rreadys,
      axislave_rresps_out=>axislave_rresps,
      axislave_arbursts_in=>axislave_arbursts,
      axislave_arsizes_in=>axislave_arsizes,
      
      -- Master port #1
      aximaster_araddr_out=>aximaster_araddr,
      aximaster_arlen_out =>aximaster_arlen,
      aximaster_arvalid_out=>aximaster_arvalid,
      aximaster_arid_out=>aximaster_arid,
      aximaster_arlock_out=>aximaster_arlock,
      aximaster_arcache_out =>aximaster_arcache,  
      aximaster_arprot_out =>aximaster_arprot,    
      aximaster_arqos_out=>aximaster_arqos, 
      aximaster_rid_in=>aximaster_rid, 
      aximaster_rresp_in=>aximaster_rresp,
      aximaster_rvalid_in =>aximaster_rvalid,
      aximaster_rlast_in=>aximaster_rlast,
      aximaster_rdata_in =>aximaster_rdata,
      aximaster_arready_in =>aximaster_arready,
      aximaster_rready_out=>aximaster_rready, 
      aximaster_arburst_out=>aximaster_arburst,
      aximaster_arsize_out=>aximaster_arsize
   );

axi_merge_write_i:axi_merge_write
   generic map
   (
      NUM_SLAVE_PORT=>3,
      FIFO_CMD_DEPTH=>W_FIFO_CMD_DEPTH,
      FIFO_DATA_DEPTH=>W_FIFO_DATA_DEPTH,
      FIFO_W_CMD_DEPTH=>W_FIFO_W_CMD_DEPTH,
      FIFO_W_DATA_DEPTH=>W_FIFO_W_DATA_DEPTH
   )
   port map 
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      
      axislavew_clock_in=>axislavew_clock_in,
      axislavew_awaddr_in=>axislavew_awaddr_in,
      axislavew_awlen_in=>axislavew_awlen_in,
      axislavew_awvalid_in=>axislavew_awvalid_in,
      axislavew_wvalid_in=>axislavew_wvalid_in,
      axislavew_wdata_in=>axislavew_wdata_in,
      axislavew_wlast_in=>axislavew_wlast_in,
      axislavew_wstrb_in=>axislavew_wstrb_in,
      axislavew_awready_out=>axislavew_awready_out,
      axislavew_wready_out=>axislavew_wready_out,
      axislavew_bresp_out =>axislavew_bresp_out,
      axislavew_bid_out=>axislavew_bid_out,
      axislavew_bvalid_out=>axislavew_bvalid_out,
      axislavew_awburst_in=>axislavew_awburst_in,
      axislavew_awcache_in=>axislavew_awcache_in,
      axislavew_awid_in=>axislavew_awid_in,
      axislavew_awlock_in=>axislavew_awlock_in,
      axislavew_awprot_in=>axislavew_awprot_in,
      axislavew_awqos_in=>axislavew_awqos_in,
      axislavew_awsize_in=>axislavew_awsize_in,
      axislavew_bready_in=>axislavew_bready_in,

      axislave_clocks_in =>axislave_clocks,
      axislave_awaddrs_in=>axislave_awaddrs,
      axislave_awlens_in =>axislave_awlens,
      axislave_awvalids_in =>axislave_awvalids,
      axislave_wvalids_in =>axislave_wvalids,
      axislave_wdatas_in=>axislave_wdatas,
      axislave_wlasts_in=>axislave_wlasts,
      axislave_wstrbs_in=>axislave_wstrbs,
      axislave_awreadys_out=>axislave_awreadys,
      axislave_wreadys_out=>axislave_wreadys,
      axislave_bresps_out=>axislave_bresps,
      axislave_bids_out=>axislave_bids,
      axislave_bvalids_out =>axislave_bvalids,
      axislave_awbursts_in=>axislave_awbursts,
      axislave_awcaches_in=>axislave_awcaches,
      axislave_awids_in=>axislave_awids,
      axislave_awlocks_in=>axislave_awlocks,
      axislave_awprots_in=>axislave_awprots,
      axislave_awqoss_in=>axislave_awqoss,
      axislave_awsizes_in=>axislave_awsizes,
      axislave_breadys_in=>axislave_breadys,
      
      aximaster_awaddr_out=>aximaster_awaddr_out,
      aximaster_awlen_out=>aximaster_awlen_out,
      aximaster_awvalid_out=>aximaster_awvalid_out,
      aximaster_wvalid_out=>aximaster_wvalid_out,
      aximaster_wdata_out=>aximaster_wdata_out,
      aximaster_wlast_out=>aximaster_wlast_out,
      aximaster_wstrb_out=>aximaster_wstrb_out,
      aximaster_awready_in=>aximaster_awready_in,
      aximaster_wready_in=>aximaster_wready_in,
      aximaster_bresp_in =>aximaster_bresp_in,
      aximaster_bid_in =>aximaster_bid_in,
      aximaster_bvalid_in=>aximaster_bvalid_in,
      aximaster_awburst_out=>aximaster_awburst_out,
      aximaster_awcache_out=>aximaster_awcache_out,
      aximaster_awid_out=>aximaster_awid_out,
      aximaster_awlock_out=>aximaster_awlock_out,
      aximaster_awprot_out=>aximaster_awprot_out,
      aximaster_awqos_out=>aximaster_awqos_out,
      aximaster_awsize_out=>aximaster_awsize_out,
      aximaster_bready_out=>aximaster_bready_out
   );
end rtl;
