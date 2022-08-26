-- (c) Copyright 1995-2022 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:axi_apb_bridge:3.0
-- IP Revision: 17

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY axi_apb_bridge_v3_0_17;
USE axi_apb_bridge_v3_0_17.axi_apb_bridge;

ENTITY crossbar_axi_apb_bridge_0_0 IS
  PORT (
    s_axi_aclk : IN STD_LOGIC;
    s_axi_aresetn : IN STD_LOGIC;
    s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    m_apb_paddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_apb_psel : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_apb_penable : OUT STD_LOGIC;
    m_apb_pwrite : OUT STD_LOGIC;
    m_apb_pwdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_apb_pready : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_apb_prdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_apb_pslverr : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END crossbar_axi_apb_bridge_0_0;

ARCHITECTURE crossbar_axi_apb_bridge_0_0_arch OF crossbar_axi_apb_bridge_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF crossbar_axi_apb_bridge_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT axi_apb_bridge IS
    GENERIC (
      C_FAMILY : STRING;
      C_INSTANCE : STRING;
      C_S_AXI_ADDR_WIDTH : INTEGER;
      C_S_AXI_DATA_WIDTH : INTEGER;
      C_M_APB_ADDR_WIDTH : INTEGER;
      C_M_APB_DATA_WIDTH : INTEGER;
      C_APB_NUM_SLAVES : INTEGER;
      C_M_APB_PROTOCOL : STRING;
      C_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG2_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG2_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG3_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG3_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG4_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG4_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG5_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG5_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG6_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG6_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG7_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG7_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG8_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG8_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG9_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG9_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG10_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG10_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG11_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG11_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG12_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG12_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG13_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG13_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG14_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG14_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG15_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG15_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG16_BASEADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_S_AXI_RNG16_HIGHADDR : STD_LOGIC_VECTOR(0 TO 63);
      C_DPHASE_TIMEOUT : INTEGER
    );
    PORT (
      s_axi_aclk : IN STD_LOGIC;
      s_axi_aresetn : IN STD_LOGIC;
      s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_awvalid : IN STD_LOGIC;
      s_axi_awready : OUT STD_LOGIC;
      s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_wvalid : IN STD_LOGIC;
      s_axi_wready : OUT STD_LOGIC;
      s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_bvalid : OUT STD_LOGIC;
      s_axi_bready : IN STD_LOGIC;
      s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_arvalid : IN STD_LOGIC;
      s_axi_arready : OUT STD_LOGIC;
      s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_rvalid : OUT STD_LOGIC;
      s_axi_rready : IN STD_LOGIC;
      m_apb_paddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_psel : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_apb_penable : OUT STD_LOGIC;
      m_apb_pwrite : OUT STD_LOGIC;
      m_apb_pwdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_pready : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_apb_prdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata6 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata7 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata8 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata9 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata10 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata11 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata12 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata13 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata14 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata15 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_prdata16 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_apb_pslverr : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_apb_pprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_apb_pstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  END COMPONENT axi_apb_bridge;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF crossbar_axi_apb_bridge_0_0_arch: ARCHITECTURE IS "axi_apb_bridge,Vivado 2020.2";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF crossbar_axi_apb_bridge_0_0_arch : ARCHITECTURE IS "crossbar_axi_apb_bridge_0_0,axi_apb_bridge,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF crossbar_axi_apb_bridge_0_0_arch: ARCHITECTURE IS "crossbar_axi_apb_bridge_0_0,axi_apb_bridge,{x_ipProduct=Vivado 2020.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=axi_apb_bridge,x_ipVersion=3.0,x_ipCoreRevision=17,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_FAMILY=artix7,C_INSTANCE=axi_apb_bridge_inst,C_S_AXI_ADDR_WIDTH=32,C_S_AXI_DATA_WIDTH=32,C_M_APB_ADDR_WIDTH=32,C_M_APB_DATA_WIDTH=32,C_APB_NUM_SLAVES=1,C_M_APB_PROTOCOL=apb3,C_BASEADDR=0x00000000F4000000,C_HIGHADDR=0x00000000F400FFFF,C_S_AXI_RNG2_BASEADDR=0x0000000010000000,C_S_AXI_RNG2_" & 
"HIGHADDR=0x000000001FFFFFFF,C_S_AXI_RNG3_BASEADDR=0x0000000020000000,C_S_AXI_RNG3_HIGHADDR=0x000000002FFFFFFF,C_S_AXI_RNG4_BASEADDR=0x0000000030000000,C_S_AXI_RNG4_HIGHADDR=0x000000003FFFFFFF,C_S_AXI_RNG5_BASEADDR=0x0000000040000000,C_S_AXI_RNG5_HIGHADDR=0x000000004FFFFFFF,C_S_AXI_RNG6_BASEADDR=0x0000000050000000,C_S_AXI_RNG6_HIGHADDR=0x000000005FFFFFFF,C_S_AXI_RNG7_BASEADDR=0x0000000060000000,C_S_AXI_RNG7_HIGHADDR=0x000000006FFFFFFF,C_S_AXI_RNG8_BASEADDR=0x0000000070000000,C_S_AXI_RNG8_HIGHADDR" & 
"=0x000000007FFFFFFF,C_S_AXI_RNG9_BASEADDR=0x0000000080000000,C_S_AXI_RNG9_HIGHADDR=0x000000008FFFFFFF,C_S_AXI_RNG10_BASEADDR=0x0000000090000000,C_S_AXI_RNG10_HIGHADDR=0x000000009FFFFFFF,C_S_AXI_RNG11_BASEADDR=0x00000000A0000000,C_S_AXI_RNG11_HIGHADDR=0x00000000AFFFFFFF,C_S_AXI_RNG12_BASEADDR=0x00000000B0000000,C_S_AXI_RNG12_HIGHADDR=0x00000000BFFFFFFF,C_S_AXI_RNG13_BASEADDR=0x00000000C0000000,C_S_AXI_RNG13_HIGHADDR=0x00000000CFFFFFFF,C_S_AXI_RNG14_BASEADDR=0x00000000D0000000,C_S_AXI_RNG14_HIGHAD" & 
"DR=0x00000000DFFFFFFF,C_S_AXI_RNG15_BASEADDR=0x00000000E0000000,C_S_AXI_RNG15_HIGHADDR=0x00000000EFFFFFFF,C_S_AXI_RNG16_BASEADDR=0x00000000F0000000,C_S_AXI_RNG16_HIGHADDR=0x00000000FFFFFFFF,C_DPHASE_TIMEOUT=0}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_pslverr: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PSLVERR";
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_prdata: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PRDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_pready: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_pwdata: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PWDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_pwrite: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PWRITE";
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_penable: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PENABLE";
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_psel: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PSEL";
  ATTRIBUTE X_INTERFACE_INFO OF m_apb_paddr: SIGNAL IS "xilinx.com:interface:apb:1.0 APB_M PADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE AWVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_awaddr: SIGNAL IS "XIL_INTERFACENAME AXI4_LITE, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 166000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 64, NUM_WRITE_OUTSTANDING 64, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN crossbar_CLOCK, NUM_READ_THREADS 1, NUM_WRITE_THREAD" & 
"S 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4_LITE AWADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_aresetn: SIGNAL IS "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 ARESETN RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_aclk: SIGNAL IS "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF AXI4_LITE:APB_M:APB_M2:APB_M3:APB_M4:APB_M5:APB_M6:APB_M7:APB_M8:APB_M9:APB_M10:APB_M11:APB_M12:APB_M13:APB_M14:APB_M15:APB_M16, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 166000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN crossbar_CLOCK, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 ACLK CLK";
BEGIN
  U0 : axi_apb_bridge
    GENERIC MAP (
      C_FAMILY => "artix7",
      C_INSTANCE => "axi_apb_bridge_inst",
      C_S_AXI_ADDR_WIDTH => 32,
      C_S_AXI_DATA_WIDTH => 32,
      C_M_APB_ADDR_WIDTH => 32,
      C_M_APB_DATA_WIDTH => 32,
      C_APB_NUM_SLAVES => 1,
      C_M_APB_PROTOCOL => "apb3",
      C_BASEADDR => X"00000000F4000000",
      C_HIGHADDR => X"00000000F400FFFF",
      C_S_AXI_RNG2_BASEADDR => X"0000000010000000",
      C_S_AXI_RNG2_HIGHADDR => X"000000001FFFFFFF",
      C_S_AXI_RNG3_BASEADDR => X"0000000020000000",
      C_S_AXI_RNG3_HIGHADDR => X"000000002FFFFFFF",
      C_S_AXI_RNG4_BASEADDR => X"0000000030000000",
      C_S_AXI_RNG4_HIGHADDR => X"000000003FFFFFFF",
      C_S_AXI_RNG5_BASEADDR => X"0000000040000000",
      C_S_AXI_RNG5_HIGHADDR => X"000000004FFFFFFF",
      C_S_AXI_RNG6_BASEADDR => X"0000000050000000",
      C_S_AXI_RNG6_HIGHADDR => X"000000005FFFFFFF",
      C_S_AXI_RNG7_BASEADDR => X"0000000060000000",
      C_S_AXI_RNG7_HIGHADDR => X"000000006FFFFFFF",
      C_S_AXI_RNG8_BASEADDR => X"0000000070000000",
      C_S_AXI_RNG8_HIGHADDR => X"000000007FFFFFFF",
      C_S_AXI_RNG9_BASEADDR => X"0000000080000000",
      C_S_AXI_RNG9_HIGHADDR => X"000000008FFFFFFF",
      C_S_AXI_RNG10_BASEADDR => X"0000000090000000",
      C_S_AXI_RNG10_HIGHADDR => X"000000009FFFFFFF",
      C_S_AXI_RNG11_BASEADDR => X"00000000A0000000",
      C_S_AXI_RNG11_HIGHADDR => X"00000000AFFFFFFF",
      C_S_AXI_RNG12_BASEADDR => X"00000000B0000000",
      C_S_AXI_RNG12_HIGHADDR => X"00000000BFFFFFFF",
      C_S_AXI_RNG13_BASEADDR => X"00000000C0000000",
      C_S_AXI_RNG13_HIGHADDR => X"00000000CFFFFFFF",
      C_S_AXI_RNG14_BASEADDR => X"00000000D0000000",
      C_S_AXI_RNG14_HIGHADDR => X"00000000DFFFFFFF",
      C_S_AXI_RNG15_BASEADDR => X"00000000E0000000",
      C_S_AXI_RNG15_HIGHADDR => X"00000000EFFFFFFF",
      C_S_AXI_RNG16_BASEADDR => X"00000000F0000000",
      C_S_AXI_RNG16_HIGHADDR => X"00000000FFFFFFFF",
      C_DPHASE_TIMEOUT => 0
    )
    PORT MAP (
      s_axi_aclk => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_awaddr => s_axi_awaddr,
      s_axi_awprot => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 3)),
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata => s_axi_wdata,
      s_axi_wstrb => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 4)),
      s_axi_wvalid => s_axi_wvalid,
      s_axi_wready => s_axi_wready,
      s_axi_bresp => s_axi_bresp,
      s_axi_bvalid => s_axi_bvalid,
      s_axi_bready => s_axi_bready,
      s_axi_araddr => s_axi_araddr,
      s_axi_arprot => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 3)),
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rdata => s_axi_rdata,
      s_axi_rresp => s_axi_rresp,
      s_axi_rvalid => s_axi_rvalid,
      s_axi_rready => s_axi_rready,
      m_apb_paddr => m_apb_paddr,
      m_apb_psel => m_apb_psel,
      m_apb_penable => m_apb_penable,
      m_apb_pwrite => m_apb_pwrite,
      m_apb_pwdata => m_apb_pwdata,
      m_apb_pready => m_apb_pready,
      m_apb_prdata => m_apb_prdata,
      m_apb_prdata2 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata3 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata4 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata5 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata6 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata7 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata8 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata9 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata10 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata11 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata12 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata13 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata14 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata15 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_prdata16 => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 32)),
      m_apb_pslverr => m_apb_pslverr
    );
END crossbar_axi_apb_bridge_0_0_arch;
