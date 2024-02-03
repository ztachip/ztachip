---------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
--
-- Author: Vuong Nguyen
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except IN compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to IN writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
------------------------------------------------------------------------------
----------------------------------------------------------------------------
-- This module implements TCM (Tighly coupling memory)
-- It serves as L2 cache for RISCV
----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE std.textio.all;
USE ieee.std_logic_textio.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity TCM is
   generic(
      RAM_DEPTH:integer
   );
   port(   
      TCM_clk       :IN STD_LOGIC;
      TCM_clk_x2    :IN STD_LOGIC;
      TCM_reset     :IN STD_LOGIC;

      TCM_araddr1   :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_arburst1  :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_arlen1    :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_arready1  :OUT STD_LOGIC;
      TCM_arsize1   :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_arvalid1  :IN STD_LOGIC;
      TCM_rdata1    :OUT STD_LOGIC_VECTOR(31 downto 0);
      TCM_rlast1    :OUT STD_LOGIC;
      TCM_rready1   :IN STD_LOGIC;
      TCM_rresp1    :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_rvalid1   :OUT STD_LOGIC;

      TCM_araddr2   :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_arburst2  :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_arlen2    :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_arready2  :OUT STD_LOGIC;
      TCM_arsize2   :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_arvalid2  :IN STD_LOGIC;
      TCM_rdata2    :OUT STD_LOGIC_VECTOR(31 downto 0);
      TCM_rlast2    :OUT STD_LOGIC;
      TCM_rready2   :IN STD_LOGIC;
      TCM_rresp2    :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_rvalid2   :OUT STD_LOGIC;

      TCM_awaddr    :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_awburst   :IN STD_LOGIC_VECTOR(1 downto 0);
      TCM_awlen     :IN STD_LOGIC_VECTOR(7 downto 0);
      TCM_awready   :OUT STD_LOGIC;
      TCM_awsize    :IN STD_LOGIC_VECTOR(2 downto 0);
      TCM_awvalid   :IN STD_LOGIC;
      TCM_bready    :IN STD_LOGIC;
      TCM_bresp     :OUT STD_LOGIC_VECTOR(1 downto 0);
      TCM_bvalid    :OUT STD_LOGIC;
      TCM_wdata     :IN STD_LOGIC_VECTOR(31 downto 0);
      TCM_wlast     :IN STD_LOGIC;
      TCM_wready    :OUT STD_LOGIC;
      TCM_wstrb     :IN STD_LOGIC_VECTOR(3 downto 0);
      TCM_wvalid    :IN STD_LOGIC
   );
end TCM;

---
-- This top level component for simulatio
---

architecture rtl of TCM is

signal ram_q1:std_logic_vector(31 downto 0);
signal ram_raddr1:std_logic_vector(RAM_DEPTH-3 downto 0);
signal ram_q2:std_logic_vector(31 downto 0);
signal ram_raddr2:std_logic_vector(RAM_DEPTH-3 downto 0);
signal ram_waddr:std_logic_vector(RAM_DEPTH-3 downto 0);
signal ram_wdata:std_logic_vector(31 downto 0);
signal ram_wren:std_logic;
signal ram_be:std_logic_vector(3 downto 0);

begin

--ram1_i:DPRAM_BE
--   GENERIC MAP (
--        numwords_a=>2**(RAM_DEPTH-2),
--        numwords_b=>2**(RAM_DEPTH-2),
--        widthad_a=>RAM_DEPTH-2,
--        widthad_b=>RAM_DEPTH-2,
--        width_a=>32,
--        width_b=>32
--    )
--    PORT MAP (
--        address_a=>ram_waddr,
--        byteena_a=>ram_be,
--        clock0=>TCM_clk,
--        data_a=>ram_wdata,
--        q_b=>ram_q1,
--        wren_a=>ram_wren,
--        address_b=>ram_raddr1
--    );
--
--ram2_i:DPRAM_BE
--   GENERIC MAP (
--        numwords_a=>2**(RAM_DEPTH-2),
--        numwords_b=>2**(RAM_DEPTH-2),
--        widthad_a=>RAM_DEPTH-2,
--        widthad_b=>RAM_DEPTH-2,
--        width_a=>32,
--        width_b=>32
--    )
--    PORT MAP (
--        address_a=>ram_waddr,
--        byteena_a=>ram_be,
--        clock0=>TCM_clk,
--        data_a=>ram_wdata,
--        q_b=>ram_q2,
--        wren_a=>ram_wren,
--        address_b=>ram_raddr2
--    );

ram_i:ram2r1w
   GENERIC MAP (
        numwords_a=>2**(RAM_DEPTH-2),
        numwords_b=>2**(RAM_DEPTH-2),
        widthad_a=>RAM_DEPTH-2,
        widthad_b=>RAM_DEPTH-2,
        width_a=>32,
        width_b=>32
    )
    PORT MAP (
        clock=>TCM_clk,
        clock_x2=>TCM_clk_x2,
        address_a=>ram_waddr,
        byteena_a=>ram_be,
        data_a=>ram_wdata,
        wren_a=>ram_wren,
        address1_b=>ram_raddr1,
        q1_b=>ram_q1,
        address2_b=>ram_raddr2,
        q2_b=>ram_q2
    );

TCM_read1_i:TCM_read
   generic map(
      RAM_DEPTH=>RAM_DEPTH
   )
   port map(   
      TCM_clk=>TCM_clk,
      TCM_reset=>TCM_reset,
      TCM_araddr=>TCM_araddr1,
      TCM_arburst=>TCM_arburst1,
      TCM_arlen=>TCM_arlen1,
      TCM_arready=>TCM_arready1,
      TCM_arsize=>TCM_arsize1,
      TCM_arvalid=>TCM_arvalid1,
      TCM_rdata=>TCM_rdata1,
      TCM_rlast=>TCM_rlast1,
      TCM_rready=>TCM_rready1,
      TCM_rresp=>TCM_rresp1,
      TCM_rvalid=>TCM_rvalid1,

      ram_q=>ram_q1,
      ram_raddr=>ram_raddr1
   );

TCM_read2_i:TCM_read
   generic map(
      RAM_DEPTH=>RAM_DEPTH
   )
   port map(   
      TCM_clk=>TCM_clk,
      TCM_reset=>TCM_reset,
      TCM_araddr=>TCM_araddr2,
      TCM_arburst=>TCM_arburst2,
      TCM_arlen=>TCM_arlen2,
      TCM_arready=>TCM_arready2,
      TCM_arsize=>TCM_arsize2,
      TCM_arvalid=>TCM_arvalid2,
      TCM_rdata=>TCM_rdata2,
      TCM_rlast=>TCM_rlast2,
      TCM_rready=>TCM_rready2,
      TCM_rresp=>TCM_rresp2,
      TCM_rvalid=>TCM_rvalid2,

      ram_q=>ram_q2,
      ram_raddr=>ram_raddr2
   );

TCM_write_i:TCM_write
   generic map(
      RAM_DEPTH=>RAM_DEPTH
   )
   port map(   
      TCM_clk=>TCM_clk,
      TCM_reset=>TCM_reset,

      TCM_awaddr=>TCM_awaddr,
      TCM_awburst=>TCM_awburst,
      TCM_awlen=>TCM_awlen,
      TCM_awready=>TCM_awready,
      TCM_awsize=>TCM_awsize,
      TCM_awvalid=>TCM_awvalid,
      TCM_bready=>TCM_bready,
      TCM_bresp=>TCM_bresp,
      TCM_bvalid=>TCM_bvalid,
      TCM_wdata=>TCM_wdata,
      TCM_wlast=>TCM_wlast,
      TCM_wready=>TCM_wready,
      TCM_wstrb=>TCM_wstrb,
      TCM_wvalid=>TCM_wvalid,

      ram_waddr=>ram_waddr,
      ram_wdata=>ram_wdata,
      ram_wren=>ram_wren,
      ram_be=>ram_be
   );

end rtl;
