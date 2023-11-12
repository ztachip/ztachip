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
-- Split a AXI master write interface into multiple AXI master write interfaces 
-- based on memory address ranges.
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity axi_split_write is
   generic (
      NUM_MASTER_PORT     : integer:=3;
      BAR_LO_BIT          : integer_array(2 downto 0);
      BAR_HI_BIT          : integer_array(2 downto 0);
      BAR                 : integer_array(2 downto 0)
   );
   port 
   (
      clock_in                   : in std_logic;
      reset_in                   : in std_logic;
            
      axislave_awaddr_in         : IN axi_awaddr_t;
      axislave_awlen_in          : IN axi_awlen_t;
      axislave_awvalid_in        : IN axi_awvalid_t;
      axislave_wvalid_in         : IN axi_wvalid_t;
      axislave_wdata_in          : IN axi_wdata_t;
      axislave_wlast_in          : IN axi_wlast_t;
      axislave_wstrb_in          : IN axi_wstrb_t;
      axislave_awready_out       : OUT axi_awready_t;
      axislave_wready_out        : OUT axi_wready_t;
      axislave_bresp_out         : OUT axi_bresp_t;
      axislave_bid_out           : OUT axi_bid_t;
      axislave_bvalid_out        : OUT axi_bvalid_t;
      axislave_awburst_in        : IN axi_awburst_t;
      axislave_awcache_in        : IN axi_awcache_t;
      axislave_awid_in           : IN axi_awid_t;
      axislave_awlock_in         : IN axi_awlock_t;
      axislave_awprot_in         : IN axi_awprot_t;
      axislave_awqos_in          : IN axi_awqos_t;
      axislave_awsize_in         : IN axi_awsize_t;
      axislave_bready_in         : IN axi_bready_t;

      -- Slave port
      aximaster_awaddrs_out      : OUT axi_awaddrs_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awlens_out       : OUT axi_awlens_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awvalids_out     : OUT axi_awvalids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wvalids_out      : OUT axi_wvalids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wdatas_out       : OUT axi_wdatas_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wlasts_out       : OUT axi_wlasts_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wstrbs_out       : OUT axi_wstrbs_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awreadys_in      : IN axi_awreadys_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_wreadys_in       : IN axi_wreadys_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_bresps_in        : IN axi_bresps_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_bids_in          : IN axi_bids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_bvalids_in       : IN axi_bvalids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awbursts_out     : OUT axi_awbursts_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awcaches_out     : OUT axi_awcaches_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awids_out        : OUT axi_awids_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awlocks_out      : OUT axi_awlocks_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awprots_out      : OUT axi_awprots_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awqoss_out       : OUT axi_awqoss_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_awsizes_out      : OUT axi_awsizes_t(NUM_MASTER_PORT-1 downto 0);
      aximaster_breadys_out      : OUT axi_breadys_t(NUM_MASTER_PORT-1 downto 0)        
   );
end axi_split_write;

architecture rtl of axi_split_write is
SIGNAL axislave_awready:axi_awready_t;
SIGNAL axislave_wready:axi_wready_t;
SIGNAL axislave_bresp:axi_bresp_t;
SIGNAL axislave_bid:axi_bid_t;
SIGNAL axislave_bvalid:axi_bvalid_t;
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
 
SIGNAL pending_write:STD_LOGIC;
SIGNAL pending_write_rec:STD_LOGIC_VECTOR(NUM_MASTER_PORT-1 DOWNTO 0);

SIGNAL pending_resp_read:STD_LOGIC;
SIGNAL pending_resp_read_rec:STD_LOGIC_VECTOR(NUM_MASTER_PORT-1 DOWNTO 0);
SIGNAL pending_resp_read_empty:STD_LOGIC;
SIGNAL pending_resp_write_full:STD_LOGIC;

SIGNAL pending_data_read:STD_LOGIC;
SIGNAL pending_data_read_rec:STD_LOGIC_VECTOR(NUM_MASTER_PORT-1 DOWNTO 0);
SIGNAL pending_data_read_empty:STD_LOGIC;
SIGNAL pending_data_write_full:STD_LOGIC;

SIGNAL axislave_bresp_r:axi_bresp_t;
SIGNAL axislave_bid_r:axi_bid_t;
SIGNAL axislave_bvalid_r:axi_bvalid_t;

SIGNAL axislave_bready:STD_LOGIC;

SIGNAL axislave_wvalid_r:axi_wvalid_t;
SIGNAL axislave_wdata_r:axi_wdata_t;
SIGNAL axislave_wlast_r:axi_wlast_t;
SIGNAL axislave_wstrb_r:axi_wstrb_t;

constant M0:integer:=0;
constant M1:integer:=1;
constant M2:integer:=2;

begin

axislave_awready_out <= axislave_awready;
axislave_wready_out <= (not axislave_wvalid_r) or axislave_wready;
axislave_bresp_out <= axislave_bresp_r;
axislave_bid_out <= axislave_bid_r;
axislave_bvalid_out <= axislave_bvalid_r;
aximaster_awaddrs_out <= aximaster_awaddrs;
aximaster_awlens_out <= aximaster_awlens;
aximaster_awvalids_out <= aximaster_awvalids;
aximaster_wvalids_out <= aximaster_wvalids;
aximaster_wdatas_out <= aximaster_wdatas;
aximaster_wlasts_out <= aximaster_wlasts;
aximaster_wstrbs_out <= aximaster_wstrbs;
aximaster_awbursts_out <= aximaster_awbursts;
aximaster_awcaches_out <= aximaster_awcaches;
aximaster_awids_out <= aximaster_awids;
aximaster_awlocks_out <= aximaster_awlocks;
aximaster_awprots_out <= aximaster_awprots;
aximaster_awqoss_out <= aximaster_awqoss;
aximaster_awsizes_out <= aximaster_awsizes;
aximaster_breadys_out <= aximaster_breadys;

pending_resp_read <= axislave_bvalid and axislave_bready; 

pending_data_read <= axislave_wvalid_r and axislave_wlast_r and axislave_wready; 

pending_resp_fifo:scfifo
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
      read_in=>pending_resp_read,
      q_out=>pending_resp_read_rec,
      empty_out=>pending_resp_read_empty,
      full_out=>pending_resp_write_full,
      ravail_out=>open,
      wused_out=>open,
      almost_full_out=>open
   );

pending_data_fifo:scfifo
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
      read_in=>pending_data_read,
      q_out=>pending_data_read_rec,
      empty_out=>pending_data_read_empty,
      full_out=>pending_data_write_full,
      ravail_out=>open,
      wused_out=>open,
      almost_full_out=>open
   );
    
process(pending_resp_write_full,pending_data_write_full,
   axislave_awvalid_in,axislave_awaddr_in,aximaster_awreadys_in,
   pending_resp_read_empty,pending_resp_read_rec,aximaster_bids_in,
   aximaster_bvalids_in,
   aximaster_bresps_in,axislave_bready,
   axislave_awlen_in,axislave_awid_in,axislave_awlock_in,
   axislave_awcache_in,axislave_awprot_in,axislave_awqos_in,axislave_awburst_in,
   axislave_awsize_in,
   pending_data_read_empty,pending_data_read_rec,axislave_wvalid_r,
   axislave_wdata_r,axislave_wlast_r,axislave_wstrb_r,aximaster_wreadys_in)

begin

   -- Route write request to correct masters

   pending_write <= '0';
   pending_write_rec <= (others=>'0');
   aximaster_awvalids <= (others=>'0');
   axislave_awready <= '1';
   if(pending_resp_write_full='1' or pending_data_write_full='1') then
      axislave_awready <= '0';
   elsif(axislave_awvalid_in='1') then
      if(axislave_awaddr_in(BAR_HI_BIT(M0) downto BAR_LO_BIT(M0))=std_logic_vector(to_unsigned(BAR(M0),BAR_HI_BIT(M0)-BAR_LO_BIT(M0)+1))) then
         aximaster_awvalids(M0) <= '1';
         pending_write_rec(M0) <= '1';
         pending_write <= aximaster_awreadys_in(M0);
         axislave_awready <= aximaster_awreadys_in(M0);
      elsif(axislave_awaddr_in(BAR_HI_BIT(M1) downto BAR_LO_BIT(M1))=std_logic_vector(to_unsigned(BAR(M1),BAR_HI_BIT(M1)-BAR_LO_BIT(M1)+1))) then
         aximaster_awvalids(M1) <= '1';
         pending_write_rec(M1) <= '1';
         pending_write <= aximaster_awreadys_in(M1);
         axislave_awready <= aximaster_awreadys_in(M1);
      elsif(axislave_awaddr_in(BAR_HI_BIT(M2) downto BAR_LO_BIT(M2))=std_logic_vector(to_unsigned(BAR(M2),BAR_HI_BIT(M2)-BAR_LO_BIT(M2)+1))) then
         aximaster_awvalids(M2) <= '1';
         pending_write_rec(M2) <= '1';
         pending_write <= aximaster_awreadys_in(M2);
         axislave_awready <= aximaster_awreadys_in(M2);
      end if;
   end if;

   -- Route read response from correct masters

   axislave_bid <= (others=>'0') ;     
   axislave_bvalid <= '0';
   axislave_bresp <= (others=>'0');
   aximaster_breadys <= (others=>'0');
   if(pending_resp_read_empty='0' and pending_resp_read_rec(M0)='1') then
      axislave_bid <= aximaster_bids_in(M0);      
      axislave_bvalid <= aximaster_bvalids_in(M0);
      axislave_bresp <= aximaster_bresps_in(M0);
      aximaster_breadys(M0) <= axislave_bready;
   elsif(pending_resp_read_empty='0' and pending_resp_read_rec(M1)='1') then
      axislave_bid <= aximaster_bids_in(M1);      
      axislave_bvalid <= aximaster_bvalids_in(M1);
      axislave_bresp <= aximaster_bresps_in(M1);
      aximaster_breadys(M1) <= axislave_bready;
   elsif(pending_resp_read_empty='0' and pending_resp_read_rec(M2)='1') then
      axislave_bid <= aximaster_bids_in(M2);      
      axislave_bvalid <= aximaster_bvalids_in(M2);
      axislave_bresp <= aximaster_bresps_in(M2);
      aximaster_breadys(M2) <= axislave_bready;
   end if;

   -- Route data transfer to correct masters

   aximaster_wvalids <= (others=>'0');
   axislave_wready <= '0';
   if(pending_data_read_empty='0' and pending_data_read_rec(M0)='1') then
      aximaster_wvalids(M0) <= axislave_wvalid_r;    
      axislave_wready <= aximaster_wreadys_in(M0); 
   elsif(pending_data_read_empty='0' and pending_data_read_rec(M1)='1') then
      aximaster_wvalids(M1) <= axislave_wvalid_r;  
      axislave_wready <= aximaster_wreadys_in(M1);   
   elsif(pending_data_read_empty='0' and pending_data_read_rec(M2)='1') then
      aximaster_wvalids(M2) <= axislave_wvalid_r;  
      axislave_wready <= aximaster_wreadys_in(M2);
   end if;

   FOR I IN 0 TO NUM_MASTER_PORT-1 LOOP
      aximaster_wdatas(I) <= axislave_wdata_r;
      aximaster_wlasts(I) <= axislave_wlast_r;
      aximaster_wstrbs(I) <= axislave_wstrb_r;  
   end loop;

   -- Route common slave signals to all master ports

   FOR I IN 0 TO NUM_MASTER_PORT-1 LOOP
      aximaster_awaddrs(I) <= axislave_awaddr_in;
      aximaster_awlens(I) <= axislave_awlen_in;
      aximaster_awids(I) <= axislave_awid_in;
      aximaster_awlocks(I) <= axislave_awlock_in;
      aximaster_awcaches(I) <= axislave_awcache_in;
      aximaster_awprots(I) <= axislave_awprot_in;
      aximaster_awqoss(I) <= axislave_awqos_in;
      aximaster_awbursts(I) <= axislave_awburst_in;
      aximaster_awsizes(I) <= axislave_awsize_in;
   END LOOP;
end process;

axislave_bready <= (not axislave_bvalid_r) or axislave_bready_in;

process(clock_in,reset_in)
begin
   if reset_in = '0' then
      axislave_bresp_r <= (others=>'0');
      axislave_bid_r <= (others=>'0');
      axislave_bvalid_r <= '0';     
      axislave_wvalid_r <= '0';
      axislave_wdata_r <= (others=>'0');
      axislave_wlast_r <= '0';
      axislave_wstrb_r <= (others=>'0'); 
   else
      if rising_edge(clock_in) then  
         if(axislave_bready='1') then
            axislave_bresp_r <= axislave_bresp;
            axislave_bid_r <= axislave_bid;
            axislave_bvalid_r <= axislave_bvalid;
         end if;
         if(axislave_wvalid_r='0' or axislave_wready='1') then
            axislave_wvalid_r <= axislave_wvalid_in;
            axislave_wdata_r <= axislave_wdata_in;
            axislave_wlast_r <= axislave_wlast_in;
            axislave_wstrb_r <= axislave_wstrb_in;
         end if;
      end if;
   end if;
end process;
end rtl;
