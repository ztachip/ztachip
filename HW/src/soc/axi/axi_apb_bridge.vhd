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
-- AXI to APB bridge
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity axi_apb_bridge is
    port 
    (
        clock_in                   : in std_logic;
        reset_in                   : in std_logic;
     
        -- Slave read interface
        
        axislave_araddr_in         : IN axi_araddr_t;
        axislave_arlen_in          : IN axi_arlen_t;
        axislave_arvalid_in        : IN axi_arvalid_t;
        axislave_arid_in           : IN axi_arid_t;
        axislave_arlock_in         : IN axi_arlock_t;
        axislave_arcache_in        : IN axi_arcache_t;
        axislave_arprot_in         : IN axi_arprot_t;
        axislave_arqos_in          : IN axi_arqos_t;
        axislave_rid_out           : OUT axi_rid_t;         
        axislave_rvalid_out        : OUT axi_rvalid_t;
        axislave_rlast_out         : OUT axi_rlast_t;
        axislave_rdata_out         : OUT axi_rdata_t;
        axislave_rresp_out         : OUT axi_rresp_t;
        axislave_arready_out       : OUT axi_arready_t;
        axislave_rready_in         : IN axi_rready_t;
        axislave_arburst_in        : IN axi_arburst_t;
        axislave_arsize_in         : IN axi_arsize_t;
        
        -- Slave write interface
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
        
        -- APB interface
        apb_paddr_out              : OUT STD_LOGIC_VECTOR(19 downto 0);
        apb_penable_out            : OUT STD_LOGIC;
        apb_pready_in              : IN STD_LOGIC;
        apb_pwrite_out             : OUT STD_LOGIC;
        apb_pwdata_out             : OUT STD_LOGIC_VECTOR(31 downto 0);
        apb_prdata_in              : IN STD_LOGIC_VECTOR(31 downto 0);
        apb_pslverror_in           : IN STD_LOGIC
    );
end axi_apb_bridge;

architecture rtl of axi_apb_bridge is

SIGNAL wcmd_write:STD_LOGIC;
SIGNAL wcmd_read:STD_LOGIC;
SIGNAL wcmd_write_rec:STD_LOGIC_VECTOR(axi_awaddr_t'length+axi_awid_t'length-1 DOWNTO 0);
SIGNAL wcmd_read_rec:STD_LOGIC_VECTOR(axi_awaddr_t'length+axi_awid_t'length-1 DOWNTO 0);
SIGNAL wcmd_empty:STD_LOGIC;
SIGNAL wcmd_full:STD_LOGIC;


SIGNAL wdata_write_rec:STD_LOGIC_VECTOR(axi_wdata_t'length-1 DOWNTO 0);
SIGNAL wdata_write:STD_LOGIC;
SIGNAL wdata_read:STD_LOGIC;
SIGNAL wdata_read_rec:STD_LOGIC_VECTOR(axi_wdata_t'length-1 DOWNTO 0);
SIGNAL wdata_empty:STD_LOGIC;
SIGNAL wdata_full:STD_LOGIC;

SIGNAL wresp_write_rec:std_logic_vector(axi_bid_t'length-1 downto 0);
SIGNAL wresp_write:STD_LOGIC;
SIGNAL wresp_read:STD_LOGIC;
SIGNAL wresp_read_rec:std_logic_vector(axi_bid_t'length-1 downto 0);
SIGNAL wresp_empty:STD_LOGIC;
SIGNAL wresp_full:STD_LOGIC;


SIGNAL rcmd_write:STD_LOGIC;
SIGNAL rcmd_read:STD_LOGIC;
SIGNAL rcmd_read_rec:STD_LOGIC_VECTOR(axi_araddr_t'length+axi_arid_t'length-1 DOWNTO 0);
SIGNAL rcmd_write_rec:STD_LOGIC_VECTOR(axi_araddr_t'length+axi_arid_t'length-1 DOWNTO 0);
SIGNAL rcmd_empty:STD_LOGIC;
SIGNAL rcmd_full:STD_LOGIC;

SIGNAL rresp_write_rec:STD_LOGIC_VECTOR(axi_rdata_t'length+axi_rid_t'length-1 downto 0);
SIGNAL rresp_write:STD_LOGIC;
SIGNAL rresp_read:STD_LOGIC;
SIGNAL rresp_read_rec:STD_LOGIC_VECTOR(axi_rdata_t'length+axi_rid_t'length-1 downto 0);
SIGNAL rresp_empty:STD_LOGIC;
SIGNAL rresp_full:STD_LOGIC;

SIGNAL write_in_progress_r:STD_LOGIC;
SIGNAL read_in_progress_r:STD_LOGIC;
SIGNAL write_in_progress:STD_LOGIC;
SIGNAL read_in_progress:STD_LOGIC;

SIGNAL paddr_r:STD_LOGIC_VECTOR(19 downto 0);
SIGNAL paddr:STD_LOGIC_VECTOR(19 downto 0);

constant FIFO_DEPTH:integer:=3;

begin

-- FIFO to latch write commands

wcmd_i:scfifo
    generic map
    (
       DATA_WIDTH=>wcmd_write_rec'length,
       FIFO_DEPTH=>FIFO_DEPTH,
       LOOKAHEAD=>TRUE
    )
    port map
    (
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>wcmd_write_rec,
        write_in=>wcmd_write,
        read_in=>wcmd_read,
        q_out=>wcmd_read_rec,
        empty_out=>wcmd_empty,
        full_out=>wcmd_full,
        ravail_out=>open,
        wused_out=>open,
        almost_full_out=>open
    );

-- FIFO to latch write data

wdata_i:scfifo
    generic map
    (
       DATA_WIDTH=>wdata_write_rec'length,
       FIFO_DEPTH=>FIFO_DEPTH,
       LOOKAHEAD=>TRUE
    )
    port map
    (
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>wdata_write_rec,
        write_in=>wdata_write,
        read_in=>wdata_read,
        q_out=>wdata_read_rec,
        empty_out=>wdata_empty,
        full_out=>wdata_full,
        ravail_out=>open,
        wused_out=>open,
        almost_full_out=>open
    );

-- FIFO to latch write response

wresp_i:scfifo
    generic map
    (
       DATA_WIDTH=>wresp_write_rec'length,
       FIFO_DEPTH=>FIFO_DEPTH,
       LOOKAHEAD=>TRUE
    )
    port map
    (
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>wresp_write_rec,
        write_in=>wresp_write,
        read_in=>wresp_read,
        q_out=>wresp_read_rec,
        empty_out=>wresp_empty,
        full_out=>wresp_full,
        ravail_out=>open,
        wused_out=>open,
        almost_full_out=>open
    );

-- FIFO to latch read command

rcmd_i:scfifo
    generic map
    (
       DATA_WIDTH=>rcmd_write_rec'length,
       FIFO_DEPTH=>FIFO_DEPTH,
       LOOKAHEAD=>TRUE
    )
    port map
    (
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>rcmd_write_rec,
        write_in=>rcmd_write,
        read_in=>rcmd_read,
        q_out=>rcmd_read_rec,
        empty_out=>rcmd_empty,
        full_out=>rcmd_full,
        ravail_out=>open,
        wused_out=>open,
        almost_full_out=>open
    );

-- FIFO to latch read response

rresp_i:scfifo
    generic map
    (
       DATA_WIDTH=>rresp_write_rec'length,
       FIFO_DEPTH=>FIFO_DEPTH,
       LOOKAHEAD=>TRUE
    )
    port map
    (
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>rresp_write_rec,
        write_in=>rresp_write,
        read_in=>rresp_read,
        q_out=>rresp_read_rec,
        empty_out=>rresp_empty,
        full_out=>rresp_full,
        ravail_out=>open,
        wused_out=>open,
        almost_full_out=>open
    );

-- Interface to AXI bus

-- Latch in new write request
wcmd_write_rec <= axislave_awid_in & axislave_awaddr_in;
wcmd_write <= '1' when (axislave_awvalid_in='1' and wcmd_full='0') else '0';
axislave_awready_out <= not wcmd_full;

-- Latch in new read request
rcmd_write_rec <= axislave_arid_in & axislave_araddr_in;
rcmd_write <= '1' when (axislave_arvalid_in='1' and rcmd_full='0') else '0';
axislave_arready_out <= not rcmd_full;
    
-- Latch in new write data
wdata_write_rec <= axislave_wdata_in;
wdata_write <= '1' when (axislave_wvalid_in='1' and wdata_full='0') else '0';
axislave_wready_out <= not wdata_full;

-- Send out write response
axislave_bid_out <= wresp_read_rec;
axislave_bresp_out <= (others=>'0');
axislave_bvalid_out <= not wresp_empty;
wresp_read <= '1' when (axislave_bready_in='1' and wresp_empty='0') else '0';

-- Send out read response
axislave_rdata_out <= rresp_read_rec(axi_rdata_t'length-1 downto 0);
axislave_rid_out <= rresp_read_rec(rresp_read_rec'length-1 downto axislave_rdata_out'length);
axislave_rvalid_out <= not rresp_empty;
axislave_rlast_out <= '1';
axislave_rresp_out <= (others=>'0');
rresp_read <= axislave_rready_in and (not rresp_empty);

-- APB signals 

apb_paddr_out <= paddr_r;

apb_pwrite_out <=  write_in_progress_r;

apb_penable_out <= write_in_progress_r or read_in_progress_r;

apb_pwdata_out <= wdata_read_rec(axi_wdata_t'length-1 downto 0);

-- Latch read response from APB

rresp_write_rec(rresp_write_rec'length-1 downto axi_rdata_t'length) <= rcmd_read_rec(rcmd_read_rec'length-1 downto axi_araddr_t'length);

rresp_write_rec(axi_rdata_t'length-1 downto 0) <= apb_prdata_in;

-- Latch write response

wresp_write_rec <= wcmd_read_rec(wcmd_read_rec'length-1 downto axi_awaddr_t'length);


process(write_in_progress_r,apb_pready_in,read_in_progress_r,
        rcmd_empty,rresp_full,wcmd_empty,wdata_empty,wresp_full,
        paddr_r,rcmd_read_rec,wcmd_read_rec)
begin
    write_in_progress <= write_in_progress_r;
    read_in_progress <= read_in_progress_r;
    wdata_read <= '0';
    wcmd_read <= '0';
    rcmd_read <= '0';
    wresp_write <= '0';
    rresp_write <= '0';
    paddr <= paddr_r;
    -- Forward AXI requests to APB
    if(write_in_progress_r='1') then
        if(apb_pready_in='1') then
            write_in_progress <= '0';
            wdata_read <= '1';
            wcmd_read <= '1';
            wresp_write <= '1';
        end if;
    elsif(read_in_progress_r='1') then
        if(apb_pready_in='1') then
            read_in_progress <= '0';
            rcmd_read <= '1';
            rresp_write <= '1';
        end if;
    else
        if rcmd_empty='0' and rresp_full='0' then
            read_in_progress <= '1';
            paddr <= rcmd_read_rec(apb_paddr_out'length-1 downto 0); 
        elsif wcmd_empty='0' and wdata_empty='0' and wresp_full='0' then
            write_in_progress <= '1';
            paddr <= wcmd_read_rec(apb_paddr_out'length-1 downto 0);
        end if;
    end if;
end process;


process(clock_in,reset_in)
begin
   if reset_in = '0' then
      read_in_progress_r <= '0';
      write_in_progress_r <= '0';  
      paddr_r <= (others=>'0');    
   else
      if rising_edge(clock_in) then  
         read_in_progress_r <= read_in_progress;
         write_in_progress_r <= write_in_progress;
         paddr_r <= paddr;
      end if;
   end if;
end process;
    
end rtl;
