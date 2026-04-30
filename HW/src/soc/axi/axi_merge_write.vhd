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
-- Bridge multiple AXI slave write interfaces into 1 AXI master crossbar_write interface
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

entity axi_merge_write is
   generic (
      NUM_SLAVE_PORT     : integer:=3;
      FIFO_CMD_DEPTH     : integer_array(2 downto 0);
      FIFO_DATA_DEPTH    : integer_array(2 downto 0);
      FIFO_W_CMD_DEPTH   : integer;
      FIFO_W_DATA_DEPTH  : integer
   );
   port 
   (
      clock_in                     : in std_logic;
      reset_in                     : in std_logic;
      
      -- Wide slave port
      
      axislavew_awaddr_in          : IN axi_awaddr_t;
      axislavew_awlen_in           : IN axi_awlen_t;
      axislavew_awvalid_in         : IN axi_awvalid_t;
      axislavew_wvalid_in          : IN axi_wvalid_t;
      axislavew_wdata_in           : IN axi_wdata_t(ddr_data_width_c-1 downto 0);
      axislavew_wlast_in           : IN axi_wlast_t;
      axislavew_wstrb_in           : IN axi_wstrb_t(ddr_data_byte_width_c-1 downto 0);
      axislavew_awready_out        : OUT axi_awready_t;
      axislavew_wready_out         : OUT axi_wready_t;
      axislavew_bresp_out          : OUT axi_bresp_t;
      axislavew_bid_out            : OUT axi_bid_t;
      axislavew_bvalid_out         : OUT axi_bvalid_t;
      axislavew_awburst_in         : IN axi_awburst_t;
      axislavew_awcache_in         : IN axi_awcache_t;
      axislavew_awid_in            : IN axi_awid_t;
      axislavew_awlock_in          : IN axi_awlock_t;
      axislavew_awprot_in          : IN axi_awprot_t;
      axislavew_awqos_in           : IN axi_awqos_t;
      axislavew_awsize_in          : IN axi_awsize_t;
      axislavew_bready_in          : IN axi_bready_t;
      
      -- Slave port
      axislave_awaddrs_in          : IN axi_awaddrs_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awlens_in           : IN axi_awlens_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awvalids_in         : IN axi_awvalids_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_wvalids_in          : IN axi_wvalids_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_wdatas_in           : IN axi_wdata64s_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_wlasts_in           : IN axi_wlasts_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_wstrbs_in           : IN axi_wstrb8s_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awreadys_out        : OUT axi_awreadys_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_wreadys_out         : OUT axi_wreadys_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_bresps_out          : OUT axi_bresps_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_bids_out            : OUT axi_bids_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_bvalids_out         : OUT axi_bvalids_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awbursts_in         : IN axi_awbursts_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awcaches_in         : IN axi_awcaches_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awids_in            : IN axi_awids_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awlocks_in          : IN axi_awlocks_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awprots_in          : IN axi_awprots_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awqoss_in           : IN axi_awqoss_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_awsizes_in          : IN axi_awsizes_t(MAX_SLAVE_PORT-1 downto 0);
      axislave_breadys_in          : IN axi_breadys_t(MAX_SLAVE_PORT-1 downto 0);
      
      aximaster_awaddr_out         : OUT axi_awaddr_t;
      aximaster_awlen_out          : OUT axi_awlen_t;
      aximaster_awvalid_out        : OUT axi_awvalid_t;
      aximaster_wvalid_out         : OUT axi_wvalid_t;
      aximaster_wdata_out          : OUT axi_wdata_t(exmem_data_width_c-1 downto 0);
      aximaster_wdata_mask_out     : OUT std_logic_vector(1 downto 0);
      aximaster_wlast_out          : OUT axi_wlast_t;
      aximaster_wstrb_out          : OUT axi_wstrb_t(exmem_data_width_c/8-1 downto 0);
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
end axi_merge_write;

architecture rtl of axi_merge_write is
constant S0:integer:=0;
constant S1:integer:=1;
constant S2:integer:=2;
constant SW:integer:=3;

SIGNAL slave_awaddrs:axi_awaddrs_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awlens:axi_awlens_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awvalids:axi_awvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_wvalids:axi_wvalids_t(MAX_SLAVE_PORT-1 downto 0);

SIGNAL slave_wdatas_S0:axi_wdata_t(exmem_data_width_c-1 downto 0);
SIGNAL slave_wdatas_S1:axi_wdata_t(exmem_data_width_c-1 downto 0);
SIGNAL slave_wdatas_S2:axi_wdata_t(exmem_data_width_c-1 downto 0);

SIGNAL slave_wlasts:axi_wlasts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_wstrbs_S0:axi_wstrb_t(exmem_data_width_c/8-1 downto 0);
SIGNAL slave_wstrbs_S1:axi_wstrb_t(exmem_data_width_c/8-1 downto 0);
SIGNAL slave_wstrbs_S2:axi_wstrb_t(exmem_data_width_c/8-1 downto 0);

SIGNAL slave_awreadys:axi_awreadys_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_wreadys:axi_wreadys_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_bresps:axi_bresps_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_bids:axi_bids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_bvalids:axi_bvalids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awbursts:axi_awbursts_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awcaches:axi_awcaches_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awids:axi_awids_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awlocks:axi_awlocks_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awprots:axi_awprots_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awqoss:axi_awqoss_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_awsizes:axi_awsizes_t(MAX_SLAVE_PORT-1 downto 0);
SIGNAL slave_breadys:axi_breadys_t(MAX_SLAVE_PORT-1 downto 0);

SIGNAL slavew_awaddr:axi_awaddr_t;
SIGNAL slavew_awlen:axi_awlen_t;
SIGNAL slavew_awvalid:axi_awvalid_t;
SIGNAL slavew_wvalid:axi_wvalid_t;
SIGNAL slavew_wdata:axi_wdata_t(exmem_data_width_c-1 downto 0);
SIGNAL slavew_wlast:axi_wlast_t;
SIGNAL slavew_wstrb:axi_wstrb_t(exmem_data_width_c/8-1 downto 0);
SIGNAL slavew_awready:axi_awready_t;
SIGNAL slavew_wready:axi_wready_t;
SIGNAL slavew_bresp:axi_bresp_t;
SIGNAL slavew_bid:axi_bid_t;
SIGNAL slavew_bvalid:axi_bvalid_t;
SIGNAL slavew_awburst:axi_awburst_t;
SIGNAL slavew_awcache:axi_awcache_t;
SIGNAL slavew_awid:axi_awid_t;
SIGNAL slavew_awlock:axi_awlock_t;
SIGNAL slavew_awprot:axi_awprot_t;
SIGNAL slavew_awqos:axi_awqos_t;
SIGNAL slavew_awsize:axi_awsize_t;
SIGNAL slavew_bready:axi_bready_t;

SIGNAL master_awaddr:axi_awaddr_t;
SIGNAL master_awlen:axi_awlen_t;
SIGNAL master_awvalid:axi_awvalid_t;
SIGNAL master_wvalid:axi_wvalid_t;
SIGNAL master_wdata:axi_wdata_t(exmem_data_width_c-1 downto 0);
SIGNAL master_wdata_mask:std_logic_vector(1 downto 0);
SIGNAL master_wlast:axi_wlast_t;
SIGNAL master_wstrb:axi_wstrb_t(exmem_data_width_c/8-1 downto 0);
SIGNAL master_awready:axi_awready_t;
SIGNAL master_wready:axi_wready_t;
SIGNAL master_bresp:axi_bresp_t;
SIGNAL master_bid:axi_bid_t;
SIGNAL master_bvalid:axi_bvalid_t;
SIGNAL master_awburst:axi_awburst_t;
SIGNAL master_awcache:axi_awcache_t;
SIGNAL master_awid:axi_awid_t;
SIGNAL master_awlock:axi_awlock_t;
SIGNAL master_awprot:axi_awprot_t;
SIGNAL master_awqos:axi_awqos_t;
SIGNAL master_awsize:axi_awsize_t;
SIGNAL master_bready:axi_bready_t;

SIGNAL pend_master_we:std_logic;
SIGNAL pend_master_rd:std_logic;
SIGNAL pend_master_full:std_logic;
SIGNAL pend_master_empty:std_logic;
SIGNAL pend_master_read:std_logic_vector(MAX_SLAVE_PORT downto 0);
SIGNAL pend_master_write:std_logic_vector(MAX_SLAVE_PORT downto 0);

SIGNAL pend_data_we:std_logic;
SIGNAL pend_data_rd:std_logic;
SIGNAL pend_data_full:std_logic;
SIGNAL pend_data_empty:std_logic;
SIGNAL pend_data_read:std_logic_vector(MAX_SLAVE_PORT+2 downto 0);
SIGNAL pend_data_write:std_logic_vector(MAX_SLAVE_PORT+2 downto 0);

SIGNAL curr:std_logic_vector(MAX_SLAVE_PORT downto 0);
SIGNAL curr_r:std_logic_vector(MAX_SLAVE_PORT downto 0);

SIGNAL req:std_logic_vector(NUM_SLAVE_PORT+1-1 downto 0);
SIGNAL gnt:std_logic_vector(NUM_SLAVE_PORT+1-1 downto 0);
SIGNAL gnt_valid:std_logic;
SIGNAL congest:std_logic;
constant zero_slave_c:std_logic_vector(MAX_SLAVE_PORT downto 0):=(others=>'0');

SIGNAL align_r:unsigned(1 downto 0);

begin

congest <= pend_master_full or pend_data_full or (not aximaster_awready_in);
aximaster_awaddr_out <= master_awaddr;
aximaster_awlen_out <= master_awlen;
aximaster_awvalid_out <= master_awvalid and (not congest);
aximaster_wvalid_out <= master_wvalid;
aximaster_wdata_out <= master_wdata;
aximaster_wdata_mask_out <= master_wdata_mask;
aximaster_wlast_out <= master_wlast;
aximaster_wstrb_out <= master_wstrb;
master_awready <= aximaster_awready_in and (not congest);
master_wready <= aximaster_wready_in;
master_bresp <= aximaster_bresp_in;
master_bid <= aximaster_bid_in;
master_bvalid <= aximaster_bvalid_in;
aximaster_awburst_out <= master_awburst;
aximaster_awcache_out <= master_awcache;
aximaster_awid_out <= master_awid;
aximaster_awlock_out <= master_awlock;
aximaster_awprot_out <= master_awprot;
aximaster_awqos_out <= master_awqos;
aximaster_awsize_out <= master_awsize;
aximaster_bready_out <= master_bready;
   
GEN1_RESIZE:IF ddr_data_width_c < exmem_data_width_c GENERATE
slavew_i: axi_resize_write
   generic map(
      CCD => FALSE, 
      SLAVE_DATA_WIDTH=>ddr_data_width_c,
      MASTER_DATA_WIDTH=>exmem_data_width_c,
      FIFO_DEPTH=>FIFO_W_CMD_DEPTH,
      FIFO_DATA_DEPTH=>FIFO_W_DATA_DEPTH
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      -- Slace port
      axislave_clock_in=>clock_in,
      axislave_awaddr_in=>axislavew_awaddr_in,
      axislave_awlen_in=>axislavew_awlen_in,
      axislave_awvalid_in=>axislavew_awvalid_in,
      axislave_wvalid_in=>axislavew_wvalid_in,
      axislave_wdata_in=>axislavew_wdata_in,
      axislave_wlast_in=>axislavew_wlast_in,
      axislave_wstrb_in=>axislavew_wstrb_in,
      axislave_awready_out=>axislavew_awready_out,
      axislave_wready_out=>axislavew_wready_out,
      axislave_bresp_out=>axislavew_bresp_out,
      axislave_bid_out=>axislavew_bid_out,
      axislave_bvalid_out=>axislavew_bvalid_out,
      axislave_awburst_in=>axislavew_awburst_in,
      axislave_awcache_in=>axislavew_awcache_in,
      axislave_awid_in=>axislavew_awid_in,
      axislave_awlock_in=>axislavew_awlock_in,
      axislave_awprot_in=>axislavew_awprot_in,
      axislave_awqos_in=>axislavew_awqos_in,
      axislave_awsize_in=>axislavew_awsize_in,
      axislave_bready_in=>axislavew_bready_in,

      -- Master port #1
      aximaster_clock_in=>clock_in,
      aximaster_awaddr_out=>slavew_awaddr,
      aximaster_awlen_out=>slavew_awlen,
      aximaster_awvalid_out=>slavew_awvalid,
      aximaster_wvalid_out=>slavew_wvalid,
      aximaster_wdata_out=>slavew_wdata,
      aximaster_wlast_out=>slavew_wlast,
      aximaster_wstrb_out=>slavew_wstrb,
      aximaster_awready_in=>slavew_awready,
      aximaster_wready_in=>slavew_wready,
      aximaster_bresp_in=>slavew_bresp,
      aximaster_bid_in=>slavew_bid,
      aximaster_bvalid_in=>slavew_bvalid,
      aximaster_awburst_out=>slavew_awburst,
      aximaster_awcache_out=>slavew_awcache,
      aximaster_awid_out=>slavew_awid,
      aximaster_awlock_out=>slavew_awlock,
      aximaster_awprot_out=>slavew_awprot,
      aximaster_awqos_out=>slavew_awqos,
      aximaster_awsize_out=>slavew_awsize,
      aximaster_bready_out=>slavew_bready
   );
end generate GEN1_RESIZE;   

GEN1_NO_RESIZE:IF ddr_data_width_c = exmem_data_width_c GENERATE
slavew_i: axi_write
   generic map(
      CCD => FALSE, 
      DATA_WIDTH=>ddr_data_width_c,
      FIFO_DEPTH=>FIFO_W_CMD_DEPTH,
      FIFO_DATA_DEPTH=>FIFO_W_DATA_DEPTH
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      -- Slace port
      axislave_clock_in=>clock_in,
      axislave_awaddr_in=>axislavew_awaddr_in,
      axislave_awlen_in=>axislavew_awlen_in,
      axislave_awvalid_in=>axislavew_awvalid_in,
      axislave_wvalid_in=>axislavew_wvalid_in,
      axislave_wdata_in=>axislavew_wdata_in,
      axislave_wlast_in=>axislavew_wlast_in,
      axislave_wstrb_in=>axislavew_wstrb_in,
      axislave_awready_out=>axislavew_awready_out,
      axislave_wready_out=>axislavew_wready_out,
      axislave_bresp_out=>axislavew_bresp_out,
      axislave_bid_out=>axislavew_bid_out,
      axislave_bvalid_out=>axislavew_bvalid_out,
      axislave_awburst_in=>axislavew_awburst_in,
      axislave_awcache_in=>axislavew_awcache_in,
      axislave_awid_in=>axislavew_awid_in,
      axislave_awlock_in=>axislavew_awlock_in,
      axislave_awprot_in=>axislavew_awprot_in,
      axislave_awqos_in=>axislavew_awqos_in,
      axislave_awsize_in=>axislavew_awsize_in,
      axislave_bready_in=>axislavew_bready_in,

      -- Master port #1
      aximaster_clock_in=>clock_in,
      aximaster_awaddr_out=>slavew_awaddr,
      aximaster_awlen_out=>slavew_awlen,
      aximaster_awvalid_out=>slavew_awvalid,
      aximaster_wvalid_out=>slavew_wvalid,
      aximaster_wdata_out=>slavew_wdata,
      aximaster_wlast_out=>slavew_wlast,
      aximaster_wstrb_out=>slavew_wstrb,
      aximaster_awready_in=>slavew_awready,
      aximaster_wready_in=>slavew_wready,
      aximaster_bresp_in=>slavew_bresp,
      aximaster_bid_in=>slavew_bid,
      aximaster_bvalid_in=>slavew_bvalid,
      aximaster_awburst_out=>slavew_awburst,
      aximaster_awcache_out=>slavew_awcache,
      aximaster_awid_out=>slavew_awid,
      aximaster_awlock_out=>slavew_awlock,
      aximaster_awprot_out=>slavew_awprot,
      aximaster_awqos_out=>slavew_awqos,
      aximaster_awsize_out=>slavew_awsize,
      aximaster_bready_out=>slavew_bready
   );
end generate GEN1_NO_RESIZE;  

GEN_SLAVE_RESIZE:IF 64 < exmem_data_width_c GENERATE
slave_i0: axi_resize_write
   generic map(
      CCD => FALSE, 
      SLAVE_DATA_WIDTH=>64,
      MASTER_DATA_WIDTH=>exmem_data_width_c,
      FIFO_DEPTH=>FIFO_CMD_DEPTH(0),
      FIFO_DATA_DEPTH=>FIFO_DATA_DEPTH(0)
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      -- Slace port
      axislave_clock_in=>clock_in,
      axislave_awaddr_in=>axislave_awaddrs_in(0),
      axislave_awlen_in=>axislave_awlens_in(0),
      axislave_awvalid_in=>axislave_awvalids_in(0),
      axislave_wvalid_in=>axislave_wvalids_in(0),
      axislave_wdata_in=>axislave_wdatas_in(0),
      axislave_wlast_in=>axislave_wlasts_in(0),
      axislave_wstrb_in=>axislave_wstrbs_in(0),
      axislave_awready_out=>axislave_awreadys_out(0),
      axislave_wready_out=>axislave_wreadys_out(0),
      axislave_bresp_out=>axislave_bresps_out(0),
      axislave_bid_out=>axislave_bids_out(0),
      axislave_bvalid_out=>axislave_bvalids_out(0),
      axislave_awburst_in=>axislave_awbursts_in(0),
      axislave_awcache_in=>axislave_awcaches_in(0),
      axislave_awid_in=>axislave_awids_in(0),
      axislave_awlock_in=>axislave_awlocks_in(0),
      axislave_awprot_in=>axislave_awprots_in(0),
      axislave_awqos_in=>axislave_awqoss_in(0),
      axislave_awsize_in=>axislave_awsizes_in(0),
      axislave_bready_in=>axislave_breadys_in(0),
      
      -- Master port #1
      aximaster_clock_in=>clock_in,
      aximaster_awaddr_out=>slave_awaddrs(0),
      aximaster_awlen_out=>slave_awlens(0),
      aximaster_awvalid_out=>slave_awvalids(0),
      aximaster_wvalid_out=>slave_wvalids(0),
      aximaster_wdata_out=>slave_wdatas_S0,
      aximaster_wlast_out=>slave_wlasts(0),
      aximaster_wstrb_out=>slave_wstrbs_S0,
      aximaster_awready_in=>slave_awreadys(0),
      aximaster_wready_in=>slave_wreadys(0),
      aximaster_bresp_in=>slave_bresps(0),
      aximaster_bid_in=>slave_bids(0),
      aximaster_bvalid_in=>slave_bvalids(0),
      aximaster_awburst_out=>slave_awbursts(0),
      aximaster_awcache_out=>slave_awcaches(0),
      aximaster_awid_out=>slave_awids(0),
      aximaster_awlock_out=>slave_awlocks(0),
      aximaster_awprot_out=>slave_awprots(0),
      aximaster_awqos_out=>slave_awqoss(0),
      aximaster_awsize_out=>slave_awsizes(0),
      aximaster_bready_out=>slave_breadys(0)
   );
end generate GEN_SLAVE_RESIZE;

GEN_SLAVE_NO_RESIZE:IF 64 = exmem_data_width_c GENERATE
slave_i0: axi_write
   generic map(
      CCD => FALSE, 
      DATA_WIDTH=>64,
      FIFO_DEPTH=>FIFO_CMD_DEPTH(0),
      FIFO_DATA_DEPTH=>FIFO_DATA_DEPTH(0)
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      -- Slace port
      axislave_clock_in=>clock_in,
      axislave_awaddr_in=>axislave_awaddrs_in(0),
      axislave_awlen_in=>axislave_awlens_in(0),
      axislave_awvalid_in=>axislave_awvalids_in(0),
      axislave_wvalid_in=>axislave_wvalids_in(0),
      axislave_wdata_in=>axislave_wdatas_in(0),
      axislave_wlast_in=>axislave_wlasts_in(0),
      axislave_wstrb_in=>axislave_wstrbs_in(0),
      axislave_awready_out=>axislave_awreadys_out(0),
      axislave_wready_out=>axislave_wreadys_out(0),
      axislave_bresp_out=>axislave_bresps_out(0),
      axislave_bid_out=>axislave_bids_out(0),
      axislave_bvalid_out=>axislave_bvalids_out(0),
      axislave_awburst_in=>axislave_awbursts_in(0),
      axislave_awcache_in=>axislave_awcaches_in(0),
      axislave_awid_in=>axislave_awids_in(0),
      axislave_awlock_in=>axislave_awlocks_in(0),
      axislave_awprot_in=>axislave_awprots_in(0),
      axislave_awqos_in=>axislave_awqoss_in(0),
      axislave_awsize_in=>axislave_awsizes_in(0),
      axislave_bready_in=>axislave_breadys_in(0),
      
      -- Master port #1
      aximaster_clock_in=>clock_in,
      aximaster_awaddr_out=>slave_awaddrs(0),
      aximaster_awlen_out=>slave_awlens(0),
      aximaster_awvalid_out=>slave_awvalids(0),
      aximaster_wvalid_out=>slave_wvalids(0),
      aximaster_wdata_out=>slave_wdatas_S0,
      aximaster_wlast_out=>slave_wlasts(0),
      aximaster_wstrb_out=>slave_wstrbs_S0,
      aximaster_awready_in=>slave_awreadys(0),
      aximaster_wready_in=>slave_wreadys(0),
      aximaster_bresp_in=>slave_bresps(0),
      aximaster_bid_in=>slave_bids(0),
      aximaster_bvalid_in=>slave_bvalids(0),
      aximaster_awburst_out=>slave_awbursts(0),
      aximaster_awcache_out=>slave_awcaches(0),
      aximaster_awid_out=>slave_awids(0),
      aximaster_awlock_out=>slave_awlocks(0),
      aximaster_awprot_out=>slave_awprots(0),
      aximaster_awqos_out=>slave_awqoss(0),
      aximaster_awsize_out=>slave_awsizes(0),
      aximaster_bready_out=>slave_breadys(0)
   );
end generate GEN_SLAVE_NO_RESIZE;

slave_i1: axi_resize_write
   generic map(
      CCD => FALSE, 
      SLAVE_DATA_WIDTH=>32,
      MASTER_DATA_WIDTH=>exmem_data_width_c,
      FIFO_DEPTH=>FIFO_CMD_DEPTH(1),
      FIFO_DATA_DEPTH=>FIFO_DATA_DEPTH(1)
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      -- Slace port
      axislave_clock_in=>clock_in,
      axislave_awaddr_in=>axislave_awaddrs_in(1),
      axislave_awlen_in=>axislave_awlens_in(1),
      axislave_awvalid_in=>axislave_awvalids_in(1),
      axislave_wvalid_in=>axislave_wvalids_in(1),
      axislave_wdata_in=>axislave_wdatas_in(1)(31 downto 0),
      axislave_wlast_in=>axislave_wlasts_in(1),
      axislave_wstrb_in=>axislave_wstrbs_in(1)(3 downto 0),
      axislave_awready_out=>axislave_awreadys_out(1),
      axislave_wready_out=>axislave_wreadys_out(1),
      axislave_bresp_out=>axislave_bresps_out(1),
      axislave_bid_out=>axislave_bids_out(1),
      axislave_bvalid_out=>axislave_bvalids_out(1),
      axislave_awburst_in=>axislave_awbursts_in(1),
      axislave_awcache_in=>axislave_awcaches_in(1),
      axislave_awid_in=>axislave_awids_in(1),
      axislave_awlock_in=>axislave_awlocks_in(1),
      axislave_awprot_in=>axislave_awprots_in(1),
      axislave_awqos_in=>axislave_awqoss_in(1),
      axislave_awsize_in=>axislave_awsizes_in(1),
      axislave_bready_in=>axislave_breadys_in(1),
      
      -- Master port #1
      aximaster_clock_in=>clock_in,
      aximaster_awaddr_out=>slave_awaddrs(1),
      aximaster_awlen_out=>slave_awlens(1),
      aximaster_awvalid_out=>slave_awvalids(1),
      aximaster_wvalid_out=>slave_wvalids(1),
      aximaster_wdata_out=>slave_wdatas_S1,
      aximaster_wlast_out=>slave_wlasts(1),
      aximaster_wstrb_out=>slave_wstrbs_S1,
      aximaster_awready_in=>slave_awreadys(1),
      aximaster_wready_in=>slave_wreadys(1),
      aximaster_bresp_in=>slave_bresps(1),
      aximaster_bid_in=>slave_bids(1),
      aximaster_bvalid_in=>slave_bvalids(1),
      aximaster_awburst_out=>slave_awbursts(1),
      aximaster_awcache_out=>slave_awcaches(1),
      aximaster_awid_out=>slave_awids(1),
      aximaster_awlock_out=>slave_awlocks(1),
      aximaster_awprot_out=>slave_awprots(1),
      aximaster_awqos_out=>slave_awqoss(1),
      aximaster_awsize_out=>slave_awsizes(1),
      aximaster_bready_out=>slave_breadys(1)
   );

slave_i2: axi_resize_write
   generic map(
      CCD => FALSE, 
      SLAVE_DATA_WIDTH=>32,
      MASTER_DATA_WIDTH=>exmem_data_width_c,
      FIFO_DEPTH=>FIFO_CMD_DEPTH(2),
      FIFO_DATA_DEPTH=>FIFO_DATA_DEPTH(2)
   )
   port map
   (
      clock_in=>clock_in,
      reset_in=>reset_in,

      -- Slace port
      axislave_clock_in=>clock_in,
      axislave_awaddr_in=>axislave_awaddrs_in(2),
      axislave_awlen_in=>axislave_awlens_in(2),
      axislave_awvalid_in=>axislave_awvalids_in(2),
      axislave_wvalid_in=>axislave_wvalids_in(2),
      axislave_wdata_in=>axislave_wdatas_in(2)(31 downto 0),
      axislave_wlast_in=>axislave_wlasts_in(2),
      axislave_wstrb_in=>axislave_wstrbs_in(2)(3 downto 0),
      axislave_awready_out=>axislave_awreadys_out(2),
      axislave_wready_out=>axislave_wreadys_out(2),
      axislave_bresp_out=>axislave_bresps_out(2),
      axislave_bid_out=>axislave_bids_out(2),
      axislave_bvalid_out=>axislave_bvalids_out(2),
      axislave_awburst_in=>axislave_awbursts_in(2),
      axislave_awcache_in=>axislave_awcaches_in(2),
      axislave_awid_in=>axislave_awids_in(2),
      axislave_awlock_in=>axislave_awlocks_in(2),
      axislave_awprot_in=>axislave_awprots_in(2),
      axislave_awqos_in=>axislave_awqoss_in(2),
      axislave_awsize_in=>axislave_awsizes_in(2),
      axislave_bready_in=>axislave_breadys_in(2),
      
      -- Master port #1
      aximaster_clock_in=>clock_in,
      aximaster_awaddr_out=>slave_awaddrs(2),
      aximaster_awlen_out=>slave_awlens(2),
      aximaster_awvalid_out=>slave_awvalids(2),
      aximaster_wvalid_out=>slave_wvalids(2),
      aximaster_wdata_out=>slave_wdatas_S2,
      aximaster_wlast_out=>slave_wlasts(2),
      aximaster_wstrb_out=>slave_wstrbs_S2,
      aximaster_awready_in=>slave_awreadys(2),
      aximaster_wready_in=>slave_wreadys(2),
      aximaster_bresp_in=>slave_bresps(2),
      aximaster_bid_in=>slave_bids(2),
      aximaster_bvalid_in=>slave_bvalids(2),
      aximaster_awburst_out=>slave_awbursts(2),
      aximaster_awcache_out=>slave_awcaches(2),
      aximaster_awid_out=>slave_awids(2),
      aximaster_awlock_out=>slave_awlocks(2),
      aximaster_awprot_out=>slave_awprots(2),
      aximaster_awqos_out=>slave_awqoss(2),
      aximaster_awsize_out=>slave_awsizes(2),
      aximaster_bready_out=>slave_breadys(2)
   );

 
-- Pending fifo to wait for bresp coming back

pend_master_fifo_i:scfifo
   generic map 
   (
      DATA_WIDTH=>NUM_SLAVE_PORT+1,
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

-- Pending fifo to know how to route wdata requests later...

pend_data_fifo_i:scfifo
   generic map 
   (
      DATA_WIDTH=>NUM_SLAVE_PORT+3,
      FIFO_DEPTH=>8,
      LOOKAHEAD=>TRUE
   )
   port map 
   (
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>pend_data_write,
      write_in=>pend_data_we,
      read_in=>pend_data_rd,
      q_out=>pend_data_read,
      ravail_out=>open,
      wused_out=>open,
      empty_out=>pend_data_empty,
      full_out=>pend_data_full,
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

-----
-- Get next slave to have the turn
-----

process(curr_r,slave_awvalids,slavew_awvalid)
begin
   if curr_r/=std_logic_vector(to_unsigned(0,curr_r'length)) then
      req <= (others=>'0');
   else 
      req <= (others=>'0');
      req(S0) <= slave_awvalids(S0);
      req(S1) <= slave_awvalids(S1);
      req(S2) <= slave_awvalids(S2);
      req(SW) <= slavew_awvalid;
   end if;
end process;

----
-- Route write response from master ports to corresponding
-- slave ports
----
    
process(pend_master_empty, pend_master_read,
        master_bresp,master_bid,master_bvalid,slave_breadys,
        slavew_bready)
begin
   master_bready <= '0';
   pend_master_rd <= '0';
   if pend_master_empty='0' and pend_master_read(S0)='1' then
      slave_bvalids(S0) <= master_bvalid;
      slave_bresps(S0) <= master_bresp;
      slave_bids(S0) <= master_bid;
      master_bready <= slave_breadys(S0);
      pend_master_rd <= slave_breadys(S0) and master_bvalid;
   else
      slave_bvalids(S0) <= '0';
      slave_bresps(S0) <= (others=>'0');
      slave_bids(S0) <= (others=>'0');
   end if;

   if pend_master_empty='0' and pend_master_read(S1)='1' then
      slave_bvalids(S1) <= master_bvalid;
      slave_bresps(S1) <= master_bresp;
      slave_bids(S1) <= master_bid;
      master_bready <= slave_breadys(S1);
      pend_master_rd <= slave_breadys(S1) and master_bvalid;
   else
      slave_bvalids(S1) <= '0';
      slave_bresps(S1) <= (others=>'0');
      slave_bids(S1) <= (others=>'0');
   end if;

   if pend_master_empty='0' and pend_master_read(S2)='1' then
      slave_bvalids(S2) <= master_bvalid;
      slave_bresps(S2) <= master_bresp;
      slave_bids(S2) <= master_bid;
      master_bready <= slave_breadys(S2);
      pend_master_rd <= slave_breadys(S2) and master_bvalid;
   else
      slave_bvalids(S2) <= '0';
      slave_bresps(S2) <= (others=>'0');
      slave_bids(S2) <= (others=>'0');
   end if;

   if pend_master_empty='0' and pend_master_read(SW)='1' then
      slavew_bvalid <= master_bvalid;
      slavew_bresp <= master_bresp;
      slavew_bid <= master_bid;
      master_bready <= slavew_bready;
      pend_master_rd <= slavew_bready and master_bvalid;
   else
      slavew_bvalid <= '0';
      slavew_bresp <= (others=>'0');
      slavew_bid <= (others=>'0');
   end if;
end process;

------
-- Forward data transfer from slave to master
-----

process(pend_data_empty,pend_data_read,
        slave_wdatas_S0,slave_wdatas_S1,slave_wdatas_S2,
        slave_wlasts,slave_wvalids,
        slave_wstrbs_S0,slave_wstrbs_S1,slave_wstrbs_S2,
        slavew_wvalid,slavew_wlast,slavew_wdata,
        slavew_wstrb,
        master_wready,master_awready,curr)
variable align_v:unsigned(1 downto 0);
variable align2_v:unsigned(0 downto 0);
begin

   align_v := unsigned(pend_data_read(MAX_SLAVE_PORT+2 downto MAX_SLAVE_PORT+1))+align_r;
   align2_v := unsigned(pend_data_read(MAX_SLAVE_PORT+2 downto MAX_SLAVE_PORT+2))+align_r(0 downto 0);
   slave_wreadys <= (others=>'0');
   slavew_wready <= '0';
   if(pend_data_empty='0' and pend_data_read(S0)='1' and slave_wvalids(S0)='1') then
      master_wlast <= slave_wlasts(S0);
      master_wvalid <= slave_wvalids(S0);   
      master_wdata <= slave_wdatas_S0;
      master_wstrb <= slave_wstrbs_S0;
      master_wdata_mask(0) <= '1';
      master_wdata_mask(1) <= '1';
      slave_wreadys(S0) <= master_wready;
      pend_data_rd <= master_wready and slave_wlasts(S0);
   elsif(pend_data_empty='0' and pend_data_read(S1)='1' and slave_wvalids(S1)='1') then
      master_wlast <= slave_wlasts(S1);
      master_wvalid <= slave_wvalids(S1);
      master_wdata <= slave_wdatas_S1;
      master_wstrb <= slave_wstrbs_S1;
      master_wdata_mask <= (others=>'0');
      slave_wreadys(S1) <= master_wready; 
      pend_data_rd <= master_wready and slave_wlasts(S1); 
   elsif(pend_data_empty='0' and pend_data_read(S2)='1' and slave_wvalids(S2)='1') then
      master_wlast <= slave_wlasts(S2);
      master_wvalid <= slave_wvalids(S2);
      master_wdata <= slave_wdatas_S2;
      master_wstrb <= slave_wstrbs_S2;
      master_wdata_mask <= (others=>'0');
      slave_wreadys(S2) <= master_wready; 
      pend_data_rd <= master_wready and slave_wlasts(S2); 
   elsif(pend_data_empty='0' and pend_data_read(SW)='1' and slavew_wvalid='1') then
      master_wlast <= slavew_wlast;
      master_wvalid <= slavew_wvalid;
      master_wdata <= slavew_wdata;
      master_wstrb <= slavew_wstrb;
      slavew_wready <= master_wready; 
      pend_data_rd <= master_wready and slavew_wlast;
      master_wdata_mask(0) <= '1';
      master_wdata_mask(1) <= '1'; 
   else
      master_wstrb <= (others=>'0');
      master_wdata <= (others=>'0');
      master_wlast <= '0';
      master_wvalid <= '0';
      pend_data_rd <= '0';
      master_wdata_mask(0) <= '0';
      master_wdata_mask(1) <= '0'; 
   end if;
end process;

process(master_awvalid,master_awready,master_awaddr,curr)
begin
   if(master_awvalid='1' and master_awready='1') then
      pend_data_write(MAX_SLAVE_PORT downto 0) <= curr;
      pend_data_write(MAX_SLAVE_PORT+1) <= master_awaddr(2);
      pend_data_write(MAX_SLAVE_PORT+2) <= master_awaddr(3);
      pend_data_we <= '1';
   else
      pend_data_write <= (others=>'0');
      pend_data_we <= '0';
   end if;
end process;

process(clock_in,reset_in)
begin
   if reset_in='0' then
      curr_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         if(master_awvalid='1' and master_awready='0') then
            -- retry again
            curr_r <= curr;
         elsif(master_awvalid='1' and master_awready='1') then
            curr_r <= (others=>'0');
         else
            curr_r <= (others=>'0');
         end if;
      end if;
   end if;
end process;

-- Route read request from slave ports to corresponding
-- master ports

process(slave_awvalids,slave_awaddrs,slave_awlens,slave_awids,slave_awlocks,slave_awcaches,
        slave_awprots,slave_awqoss,slave_awbursts,slave_awsizes,master_awready,
        slavew_awaddr,slavew_awlen,slavew_awid,slavew_awlock,slavew_awcache,
        slavew_awprot,slavew_awqos,slavew_awburst,slavew_awsize,
        curr_r,gnt_valid,gnt)
begin
   slave_awreadys <= (others=>'0');
   slavew_awready <= '0';
   if (curr_r(S0)='1' or (gnt_valid='1' and gnt(S0)='1')) then
      -- Send commands from slave1 to master2    
      master_awaddr <= slave_awaddrs(S0);
      master_awlen <= slave_awlens(S0);
      master_awvalid <= '1';
      master_awid <= slave_awids(S0);
      master_awlock <= slave_awlocks(S0);
      master_awcache <= slave_awcaches(S0);
      master_awprot <= slave_awprots(S0);
      master_awqos <= slave_awqoss(S0);
      master_awburst <= slave_awbursts(S0); 
      master_awsize <= slave_awsizes(S0);
      slave_awreadys(S0) <= master_awready;
      pend_master_write <= std_logic_vector(to_unsigned(2**S0,MAX_SLAVE_PORT+1));
      pend_master_we <= master_awready;
      curr <= (others=>'0');
      curr(S0) <= '1';
   elsif (curr_r(S1)='1' or (gnt_valid='1' and gnt(S1)='1')) then
      -- Send commands from slave1 to master2    
      master_awaddr <= slave_awaddrs(S1);
      master_awlen <= slave_awlens(S1);
      master_awvalid <= '1';
      master_awid <= slave_awids(S1);
      master_awlock <= slave_awlocks(S1);
      master_awcache <= slave_awcaches(S1);
      master_awprot <= slave_awprots(S1);
      master_awqos <= slave_awqoss(S1);
      master_awburst <= slave_awbursts(S1);
      master_awsize <= slave_awsizes(S1);
      slave_awreadys(S1) <= master_awready;
      pend_master_write <= std_logic_vector(to_unsigned(2**S1,MAX_SLAVE_PORT+1));
      pend_master_we <= master_awready;
      curr <= (others=>'0');
      curr(S1) <= '1';
   elsif (curr_r(S2)='1' or (gnt_valid='1' and gnt(S2)='1')) then
      -- Send commands from slave1 to master2    
      master_awaddr <= slave_awaddrs(S2);
      master_awlen <= slave_awlens(S2);
      master_awvalid <= '1';
      master_awid <= slave_awids(S2);
      master_awlock <= slave_awlocks(S2);
      master_awcache <= slave_awcaches(S2);
      master_awprot <= slave_awprots(S2);
      master_awqos <= slave_awqoss(S2);
      master_awburst <= slave_awbursts(S2);
      master_awsize <= slave_awsizes(S2);
      slave_awreadys(S2) <= master_awready;
      pend_master_write <= std_logic_vector(to_unsigned(2**S2,MAX_SLAVE_PORT+1));
      pend_master_we <= master_awready;
      curr <= (others=>'0');
      curr(S2) <= '1';
   elsif (curr_r(SW)='1' or (gnt_valid='1' and gnt(SW)='1')) then
      -- Send commands from slave1 to master2    
      master_awaddr <= slavew_awaddr;
      master_awlen <= slavew_awlen;
      master_awvalid <= '1';
      master_awid <= slavew_awid;
      master_awlock <= slavew_awlock;
      master_awcache <= slavew_awcache;
      master_awprot <= slavew_awprot;
      master_awqos <= slavew_awqos;
      master_awburst <= slavew_awburst;
      master_awsize <= slavew_awsize;
      slavew_awready <= master_awready;
      pend_master_write <= std_logic_vector(to_unsigned(2**SW,MAX_SLAVE_PORT+1));
      pend_master_we <= master_awready;
      curr <= (others=>'0');
      curr(SW) <= '1';
   else
      master_awaddr <= (others=>'0');
      master_awlen <= (others=>'0');
      master_awvalid <= '0';
      master_awid <= (others=>'0');
      master_awlock <= (others=>'0');
      master_awcache <= (others=>'0');
      master_awprot <= (others=>'0');
      master_awqos <= (others=>'0');
      master_awburst <= (others=>'0');
      master_awsize <= (others=>'0');
      pend_master_write <= (others=>'0');
      pend_master_we <= '0';
      curr <= (others=>'0');
   end if;
end process;

process(clock_in,reset_in)
begin
   if reset_in='0' then
      align_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         if pend_data_rd='1' then
            align_r <= (others=>'0');
         elsif(master_wvalid='1' and master_wready='1') then
            align_r <= align_r + to_unsigned(1,align_r'length);
         end if;
      end if;
   end if;
end process;


end rtl;
