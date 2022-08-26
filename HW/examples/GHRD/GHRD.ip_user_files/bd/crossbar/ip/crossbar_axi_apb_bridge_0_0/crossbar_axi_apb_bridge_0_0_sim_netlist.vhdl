-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Fri Jul 29 00:06:55 2022
-- Host        : LAPTOP-RM6TVNC2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top crossbar_axi_apb_bridge_0_0 -prefix
--               crossbar_axi_apb_bridge_0_0_ crossbar_axi_apb_bridge_0_0_sim_netlist.vhdl
-- Design      : crossbar_axi_apb_bridge_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity crossbar_axi_apb_bridge_0_0_apb_mif is
  port (
    PENABLE_i_reg_0 : out STD_LOGIC;
    m_apb_pwrite : out STD_LOGIC;
    RRESP_1_i : out STD_LOGIC;
    \FSM_onehot_apb_wr_rd_cs_reg[2]_0\ : out STD_LOGIC;
    PSEL_i : out STD_LOGIC;
    m_apb_paddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_pwdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    \PWDATA_i_reg[0]_0\ : in STD_LOGIC;
    s_axi_aclk : in STD_LOGIC;
    PWRITE_i_reg_0 : in STD_LOGIC;
    apb_wr_request : in STD_LOGIC;
    m_apb_pready : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_apb_pslverr : in STD_LOGIC_VECTOR ( 0 to 0 );
    RRESP_1_i_reg : in STD_LOGIC;
    D : in STD_LOGIC_VECTOR ( 31 downto 0 );
    \PWDATA_i_reg[31]_0\ : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );
end crossbar_axi_apb_bridge_0_0_apb_mif;

architecture STRUCTURE of crossbar_axi_apb_bridge_0_0_apb_mif is
  signal \FSM_onehot_apb_wr_rd_cs[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_apb_wr_rd_cs[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_apb_wr_rd_cs[2]_i_1_n_0\ : STD_LOGIC;
  signal \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\ : STD_LOGIC;
  signal \FSM_onehot_apb_wr_rd_cs_reg_n_0_[0]\ : STD_LOGIC;
  signal \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1]\ : STD_LOGIC;
  signal \PWDATA_i[31]_i_1_n_0\ : STD_LOGIC;
  signal apb_penable_sm : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_onehot_apb_wr_rd_cs[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \FSM_onehot_apb_wr_rd_cs[2]_i_1\ : label is "soft_lutpair0";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_onehot_apb_wr_rd_cs_reg[0]\ : label is "apb_idle:001,apb_setup:010,apb_access:100,";
  attribute FSM_ENCODED_STATES of \FSM_onehot_apb_wr_rd_cs_reg[1]\ : label is "apb_idle:001,apb_setup:010,apb_access:100,";
  attribute FSM_ENCODED_STATES of \FSM_onehot_apb_wr_rd_cs_reg[2]\ : label is "apb_idle:001,apb_setup:010,apb_access:100,";
  attribute SOFT_HLUTNM of \GEN_1_SELECT_SLAVE.M_APB_PSEL_i[0]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of PENABLE_i_i_1 : label is "soft_lutpair1";
begin
  \FSM_onehot_apb_wr_rd_cs_reg[2]_0\ <= \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\;
\FSM_onehot_apb_wr_rd_cs[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FF00FC44"
    )
        port map (
      I0 => PWRITE_i_reg_0,
      I1 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[0]\,
      I2 => m_apb_pready(0),
      I3 => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      I4 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1]\,
      O => \FSM_onehot_apb_wr_rd_cs[0]_i_1_n_0\
    );
\FSM_onehot_apb_wr_rd_cs[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCCCC888"
    )
        port map (
      I0 => PWRITE_i_reg_0,
      I1 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[0]\,
      I2 => m_apb_pready(0),
      I3 => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      I4 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1]\,
      O => \FSM_onehot_apb_wr_rd_cs[1]_i_1_n_0\
    );
\FSM_onehot_apb_wr_rd_cs[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFF0700"
    )
        port map (
      I0 => PWRITE_i_reg_0,
      I1 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[0]\,
      I2 => m_apb_pready(0),
      I3 => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      I4 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1]\,
      O => \FSM_onehot_apb_wr_rd_cs[2]_i_1_n_0\
    );
\FSM_onehot_apb_wr_rd_cs_reg[0]\: unisim.vcomponents.FDSE
    generic map(
      INIT => '1'
    )
        port map (
      C => s_axi_aclk,
      CE => '1',
      D => \FSM_onehot_apb_wr_rd_cs[0]_i_1_n_0\,
      Q => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[0]\,
      S => \PWDATA_i_reg[0]_0\
    );
\FSM_onehot_apb_wr_rd_cs_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_axi_aclk,
      CE => '1',
      D => \FSM_onehot_apb_wr_rd_cs[1]_i_1_n_0\,
      Q => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1]\,
      R => \PWDATA_i_reg[0]_0\
    );
\FSM_onehot_apb_wr_rd_cs_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_axi_aclk,
      CE => '1',
      D => \FSM_onehot_apb_wr_rd_cs[2]_i_1_n_0\,
      Q => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      R => \PWDATA_i_reg[0]_0\
    );
\GEN_1_SELECT_SLAVE.M_APB_PSEL_i[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFF2F2F2"
    )
        port map (
      I0 => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      I1 => m_apb_pready(0),
      I2 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1]\,
      I3 => PWRITE_i_reg_0,
      I4 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[0]\,
      O => PSEL_i
    );
\PADDR_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(0),
      Q => m_apb_paddr(0),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(10),
      Q => m_apb_paddr(10),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(11),
      Q => m_apb_paddr(11),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(12),
      Q => m_apb_paddr(12),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(13),
      Q => m_apb_paddr(13),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(14),
      Q => m_apb_paddr(14),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(15),
      Q => m_apb_paddr(15),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(16),
      Q => m_apb_paddr(16),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(17),
      Q => m_apb_paddr(17),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(18),
      Q => m_apb_paddr(18),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(19),
      Q => m_apb_paddr(19),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(1),
      Q => m_apb_paddr(1),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(20),
      Q => m_apb_paddr(20),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(21),
      Q => m_apb_paddr(21),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(22),
      Q => m_apb_paddr(22),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(23),
      Q => m_apb_paddr(23),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(24),
      Q => m_apb_paddr(24),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(25),
      Q => m_apb_paddr(25),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(26),
      Q => m_apb_paddr(26),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(27),
      Q => m_apb_paddr(27),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(28),
      Q => m_apb_paddr(28),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(29),
      Q => m_apb_paddr(29),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(2),
      Q => m_apb_paddr(2),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(30),
      Q => m_apb_paddr(30),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(31),
      Q => m_apb_paddr(31),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(3),
      Q => m_apb_paddr(3),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(4),
      Q => m_apb_paddr(4),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(5),
      Q => m_apb_paddr(5),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(6),
      Q => m_apb_paddr(6),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(7),
      Q => m_apb_paddr(7),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(8),
      Q => m_apb_paddr(8),
      R => \PWDATA_i_reg[0]_0\
    );
\PADDR_i_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => D(9),
      Q => m_apb_paddr(9),
      R => \PWDATA_i_reg[0]_0\
    );
PENABLE_i_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"BA"
    )
        port map (
      I0 => \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1]\,
      I1 => m_apb_pready(0),
      I2 => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      O => apb_penable_sm
    );
PENABLE_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => apb_penable_sm,
      Q => PENABLE_i_reg_0,
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i[31]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"F8"
    )
        port map (
      I0 => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      I1 => m_apb_pready(0),
      I2 => apb_wr_request,
      O => \PWDATA_i[31]_i_1_n_0\
    );
\PWDATA_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(0),
      Q => m_apb_pwdata(0),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(10),
      Q => m_apb_pwdata(10),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(11),
      Q => m_apb_pwdata(11),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(12),
      Q => m_apb_pwdata(12),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(13),
      Q => m_apb_pwdata(13),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(14),
      Q => m_apb_pwdata(14),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(15),
      Q => m_apb_pwdata(15),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(16),
      Q => m_apb_pwdata(16),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(17),
      Q => m_apb_pwdata(17),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(18),
      Q => m_apb_pwdata(18),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(19),
      Q => m_apb_pwdata(19),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(1),
      Q => m_apb_pwdata(1),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(20),
      Q => m_apb_pwdata(20),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(21),
      Q => m_apb_pwdata(21),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(22),
      Q => m_apb_pwdata(22),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(23),
      Q => m_apb_pwdata(23),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(24),
      Q => m_apb_pwdata(24),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(25),
      Q => m_apb_pwdata(25),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(26),
      Q => m_apb_pwdata(26),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(27),
      Q => m_apb_pwdata(27),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(28),
      Q => m_apb_pwdata(28),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(29),
      Q => m_apb_pwdata(29),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(2),
      Q => m_apb_pwdata(2),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(30),
      Q => m_apb_pwdata(30),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(31),
      Q => m_apb_pwdata(31),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(3),
      Q => m_apb_pwdata(3),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(4),
      Q => m_apb_pwdata(4),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(5),
      Q => m_apb_pwdata(5),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(6),
      Q => m_apb_pwdata(6),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(7),
      Q => m_apb_pwdata(7),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(8),
      Q => m_apb_pwdata(8),
      R => \PWDATA_i_reg[0]_0\
    );
\PWDATA_i_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \PWDATA_i[31]_i_1_n_0\,
      D => \PWDATA_i_reg[31]_0\(9),
      Q => m_apb_pwdata(9),
      R => \PWDATA_i_reg[0]_0\
    );
PWRITE_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => PWRITE_i_reg_0,
      D => apb_wr_request,
      Q => m_apb_pwrite,
      R => \PWDATA_i_reg[0]_0\
    );
RRESP_1_i_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => m_apb_pready(0),
      I1 => \^fsm_onehot_apb_wr_rd_cs_reg[2]_0\,
      I2 => m_apb_pslverr(0),
      I3 => RRESP_1_i_reg,
      O => RRESP_1_i
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity crossbar_axi_apb_bridge_0_0_axilite_sif is
  port (
    s_axi_awready : out STD_LOGIC;
    s_axi_aresetn_0 : out STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    apb_wr_request : out STD_LOGIC;
    s_axi_bvalid : out STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rresp : out STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 0 to 0 );
    PENABLE_i_reg : out STD_LOGIC;
    D : out STD_LOGIC_VECTOR ( 31 downto 0 );
    \s_axi_wdata[31]\ : out STD_LOGIC_VECTOR ( 31 downto 0 );
    \FSM_sequential_axi_wr_rd_cs_reg[0]_0\ : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_aclk : in STD_LOGIC;
    RRESP_1_i : in STD_LOGIC;
    \FSM_sequential_axi_wr_rd_cs_reg[1]_0\ : in STD_LOGIC;
    m_apb_pready : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_rready : in STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_arvalid : in STD_LOGIC;
    s_axi_awvalid : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    BRESP_1_i_reg_0 : in STD_LOGIC;
    m_apb_prdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_aresetn : in STD_LOGIC;
    m_apb_pslverr : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end crossbar_axi_apb_bridge_0_0_axilite_sif;

architecture STRUCTURE of crossbar_axi_apb_bridge_0_0_axilite_sif is
  signal BRESP_1_i_i_1_n_0 : STD_LOGIC;
  signal BRESP_1_i_i_2_n_0 : STD_LOGIC;
  signal BVALID_sm : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[0]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[0]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[2]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[2]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[2]_i_4_n_0\ : STD_LOGIC;
  signal \FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0\ : STD_LOGIC;
  signal \PADDR_i[31]_i_3_n_0\ : STD_LOGIC;
  signal \PADDR_i[31]_i_4_n_0\ : STD_LOGIC;
  signal \^penable_i_reg\ : STD_LOGIC;
  signal RVALID_sm : STD_LOGIC;
  signal \S_AXI_RDATA[31]_i_1_n_0\ : STD_LOGIC;
  signal WREADY_i_i_2_n_0 : STD_LOGIC;
  signal address_i : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \address_i[0]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[10]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[11]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[12]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[13]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[14]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[15]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[16]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[17]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[18]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[19]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[1]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[20]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[21]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[22]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[23]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[24]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[25]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[26]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[27]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[28]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[29]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[2]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[30]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[31]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[31]_i_2_n_0\ : STD_LOGIC;
  signal \address_i[3]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[4]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[5]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[6]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[7]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[8]_i_1_n_0\ : STD_LOGIC;
  signal \address_i[9]_i_1_n_0\ : STD_LOGIC;
  signal apb_rd_request : STD_LOGIC;
  signal \^apb_wr_request\ : STD_LOGIC;
  signal axi_wr_rd_cs : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal p_2_in : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^s_axi_aresetn_0\ : STD_LOGIC;
  signal \^s_axi_bresp\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal waddr_ready_sm : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of ARREADY_i_i_1 : label is "soft_lutpair52";
  attribute SOFT_HLUTNM of BRESP_1_i_i_2 : label is "soft_lutpair35";
  attribute SOFT_HLUTNM of \FSM_sequential_axi_wr_rd_cs[0]_i_2\ : label is "soft_lutpair69";
  attribute SOFT_HLUTNM of \FSM_sequential_axi_wr_rd_cs[2]_i_4\ : label is "soft_lutpair69";
  attribute SOFT_HLUTNM of \FSM_sequential_axi_wr_rd_cs[2]_i_5\ : label is "soft_lutpair35";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_sequential_axi_wr_rd_cs_reg[0]\ : label is "write:110,wr_resp:111,read:010,read_wait:001,rd_resp:011,write_wait:100,axi_idle:000,write_w_wait:101";
  attribute FSM_ENCODED_STATES of \FSM_sequential_axi_wr_rd_cs_reg[1]\ : label is "write:110,wr_resp:111,read:010,read_wait:001,rd_resp:011,write_wait:100,axi_idle:000,write_w_wait:101";
  attribute FSM_ENCODED_STATES of \FSM_sequential_axi_wr_rd_cs_reg[2]\ : label is "write:110,wr_resp:111,read:010,read_wait:001,rd_resp:011,write_wait:100,axi_idle:000,write_w_wait:101";
  attribute SOFT_HLUTNM of \PADDR_i[0]_i_1\ : label is "soft_lutpair34";
  attribute SOFT_HLUTNM of \PADDR_i[10]_i_1\ : label is "soft_lutpair24";
  attribute SOFT_HLUTNM of \PADDR_i[11]_i_1\ : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of \PADDR_i[12]_i_1\ : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of \PADDR_i[13]_i_1\ : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of \PADDR_i[14]_i_1\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \PADDR_i[15]_i_1\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \PADDR_i[16]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \PADDR_i[17]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \PADDR_i[18]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \PADDR_i[19]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \PADDR_i[1]_i_1\ : label is "soft_lutpair33";
  attribute SOFT_HLUTNM of \PADDR_i[20]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \PADDR_i[21]_i_1\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \PADDR_i[22]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \PADDR_i[23]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \PADDR_i[24]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \PADDR_i[25]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \PADDR_i[26]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \PADDR_i[27]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \PADDR_i[28]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \PADDR_i[29]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \PADDR_i[2]_i_1\ : label is "soft_lutpair32";
  attribute SOFT_HLUTNM of \PADDR_i[30]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \PADDR_i[31]_i_2\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \PADDR_i[31]_i_3\ : label is "soft_lutpair52";
  attribute SOFT_HLUTNM of \PADDR_i[31]_i_4\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \PADDR_i[3]_i_1\ : label is "soft_lutpair31";
  attribute SOFT_HLUTNM of \PADDR_i[4]_i_1\ : label is "soft_lutpair30";
  attribute SOFT_HLUTNM of \PADDR_i[5]_i_1\ : label is "soft_lutpair29";
  attribute SOFT_HLUTNM of \PADDR_i[6]_i_1\ : label is "soft_lutpair28";
  attribute SOFT_HLUTNM of \PADDR_i[7]_i_1\ : label is "soft_lutpair27";
  attribute SOFT_HLUTNM of \PADDR_i[8]_i_1\ : label is "soft_lutpair26";
  attribute SOFT_HLUTNM of \PADDR_i[9]_i_1\ : label is "soft_lutpair25";
  attribute SOFT_HLUTNM of \PWDATA_i[0]_i_1\ : label is "soft_lutpair68";
  attribute SOFT_HLUTNM of \PWDATA_i[10]_i_1\ : label is "soft_lutpair63";
  attribute SOFT_HLUTNM of \PWDATA_i[11]_i_1\ : label is "soft_lutpair63";
  attribute SOFT_HLUTNM of \PWDATA_i[12]_i_1\ : label is "soft_lutpair62";
  attribute SOFT_HLUTNM of \PWDATA_i[13]_i_1\ : label is "soft_lutpair62";
  attribute SOFT_HLUTNM of \PWDATA_i[14]_i_1\ : label is "soft_lutpair61";
  attribute SOFT_HLUTNM of \PWDATA_i[15]_i_1\ : label is "soft_lutpair61";
  attribute SOFT_HLUTNM of \PWDATA_i[16]_i_1\ : label is "soft_lutpair60";
  attribute SOFT_HLUTNM of \PWDATA_i[17]_i_1\ : label is "soft_lutpair60";
  attribute SOFT_HLUTNM of \PWDATA_i[18]_i_1\ : label is "soft_lutpair59";
  attribute SOFT_HLUTNM of \PWDATA_i[19]_i_1\ : label is "soft_lutpair59";
  attribute SOFT_HLUTNM of \PWDATA_i[1]_i_1\ : label is "soft_lutpair68";
  attribute SOFT_HLUTNM of \PWDATA_i[20]_i_1\ : label is "soft_lutpair58";
  attribute SOFT_HLUTNM of \PWDATA_i[21]_i_1\ : label is "soft_lutpair58";
  attribute SOFT_HLUTNM of \PWDATA_i[22]_i_1\ : label is "soft_lutpair57";
  attribute SOFT_HLUTNM of \PWDATA_i[23]_i_1\ : label is "soft_lutpair57";
  attribute SOFT_HLUTNM of \PWDATA_i[24]_i_1\ : label is "soft_lutpair56";
  attribute SOFT_HLUTNM of \PWDATA_i[25]_i_1\ : label is "soft_lutpair56";
  attribute SOFT_HLUTNM of \PWDATA_i[26]_i_1\ : label is "soft_lutpair55";
  attribute SOFT_HLUTNM of \PWDATA_i[27]_i_1\ : label is "soft_lutpair55";
  attribute SOFT_HLUTNM of \PWDATA_i[28]_i_1\ : label is "soft_lutpair54";
  attribute SOFT_HLUTNM of \PWDATA_i[29]_i_1\ : label is "soft_lutpair54";
  attribute SOFT_HLUTNM of \PWDATA_i[2]_i_1\ : label is "soft_lutpair67";
  attribute SOFT_HLUTNM of \PWDATA_i[30]_i_1\ : label is "soft_lutpair53";
  attribute SOFT_HLUTNM of \PWDATA_i[31]_i_2\ : label is "soft_lutpair53";
  attribute SOFT_HLUTNM of \PWDATA_i[3]_i_1\ : label is "soft_lutpair67";
  attribute SOFT_HLUTNM of \PWDATA_i[4]_i_1\ : label is "soft_lutpair66";
  attribute SOFT_HLUTNM of \PWDATA_i[5]_i_1\ : label is "soft_lutpair66";
  attribute SOFT_HLUTNM of \PWDATA_i[6]_i_1\ : label is "soft_lutpair65";
  attribute SOFT_HLUTNM of \PWDATA_i[7]_i_1\ : label is "soft_lutpair65";
  attribute SOFT_HLUTNM of \PWDATA_i[8]_i_1\ : label is "soft_lutpair64";
  attribute SOFT_HLUTNM of \PWDATA_i[9]_i_1\ : label is "soft_lutpair64";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[0]_i_1\ : label is "soft_lutpair36";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[10]_i_1\ : label is "soft_lutpair41";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[11]_i_1\ : label is "soft_lutpair41";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[12]_i_1\ : label is "soft_lutpair42";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[13]_i_1\ : label is "soft_lutpair42";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[14]_i_1\ : label is "soft_lutpair43";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[15]_i_1\ : label is "soft_lutpair43";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[16]_i_1\ : label is "soft_lutpair44";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[17]_i_1\ : label is "soft_lutpair44";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[18]_i_1\ : label is "soft_lutpair45";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[19]_i_1\ : label is "soft_lutpair45";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[1]_i_1\ : label is "soft_lutpair36";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[20]_i_1\ : label is "soft_lutpair46";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[21]_i_1\ : label is "soft_lutpair46";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[22]_i_1\ : label is "soft_lutpair47";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[23]_i_1\ : label is "soft_lutpair47";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[24]_i_1\ : label is "soft_lutpair48";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[25]_i_1\ : label is "soft_lutpair48";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[26]_i_1\ : label is "soft_lutpair49";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[27]_i_1\ : label is "soft_lutpair49";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[28]_i_1\ : label is "soft_lutpair50";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[29]_i_1\ : label is "soft_lutpair50";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[2]_i_1\ : label is "soft_lutpair37";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[30]_i_1\ : label is "soft_lutpair51";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[31]_i_2\ : label is "soft_lutpair51";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[3]_i_1\ : label is "soft_lutpair37";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[4]_i_1\ : label is "soft_lutpair38";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[5]_i_1\ : label is "soft_lutpair38";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[6]_i_1\ : label is "soft_lutpair39";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[7]_i_1\ : label is "soft_lutpair39";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[8]_i_1\ : label is "soft_lutpair40";
  attribute SOFT_HLUTNM of \S_AXI_RDATA[9]_i_1\ : label is "soft_lutpair40";
  attribute SOFT_HLUTNM of WREADY_i_i_2 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \address_i[0]_i_1\ : label is "soft_lutpair34";
  attribute SOFT_HLUTNM of \address_i[10]_i_1\ : label is "soft_lutpair24";
  attribute SOFT_HLUTNM of \address_i[11]_i_1\ : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of \address_i[12]_i_1\ : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of \address_i[13]_i_1\ : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of \address_i[14]_i_1\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \address_i[15]_i_1\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \address_i[16]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \address_i[17]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \address_i[18]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \address_i[19]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \address_i[1]_i_1\ : label is "soft_lutpair33";
  attribute SOFT_HLUTNM of \address_i[20]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \address_i[21]_i_1\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \address_i[22]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \address_i[23]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \address_i[24]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \address_i[25]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \address_i[26]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \address_i[27]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \address_i[28]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \address_i[29]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \address_i[2]_i_1\ : label is "soft_lutpair32";
  attribute SOFT_HLUTNM of \address_i[30]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \address_i[31]_i_2\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \address_i[3]_i_1\ : label is "soft_lutpair31";
  attribute SOFT_HLUTNM of \address_i[4]_i_1\ : label is "soft_lutpair30";
  attribute SOFT_HLUTNM of \address_i[5]_i_1\ : label is "soft_lutpair29";
  attribute SOFT_HLUTNM of \address_i[6]_i_1\ : label is "soft_lutpair28";
  attribute SOFT_HLUTNM of \address_i[7]_i_1\ : label is "soft_lutpair27";
  attribute SOFT_HLUTNM of \address_i[8]_i_1\ : label is "soft_lutpair26";
  attribute SOFT_HLUTNM of \address_i[9]_i_1\ : label is "soft_lutpair25";
begin
  PENABLE_i_reg <= \^penable_i_reg\;
  apb_wr_request <= \^apb_wr_request\;
  s_axi_aresetn_0 <= \^s_axi_aresetn_0\;
  s_axi_bresp(0) <= \^s_axi_bresp\(0);
ARREADY_i_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0004"
    )
        port map (
      I0 => axi_wr_rd_cs(1),
      I1 => s_axi_arvalid,
      I2 => axi_wr_rd_cs(2),
      I3 => axi_wr_rd_cs(0),
      O => apb_rd_request
    );
ARREADY_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => apb_rd_request,
      Q => s_axi_arready,
      R => \^s_axi_aresetn_0\
    );
AWREADY_i_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => s_axi_aresetn,
      O => \^s_axi_aresetn_0\
    );
AWREADY_i_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000880200000002"
    )
        port map (
      I0 => s_axi_awvalid,
      I1 => axi_wr_rd_cs(1),
      I2 => s_axi_arvalid,
      I3 => axi_wr_rd_cs(0),
      I4 => axi_wr_rd_cs(2),
      I5 => s_axi_rready,
      O => waddr_ready_sm
    );
AWREADY_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => waddr_ready_sm,
      Q => s_axi_awready,
      R => \^s_axi_aresetn_0\
    );
BRESP_1_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"808000FF80800000"
    )
        port map (
      I0 => m_apb_pready(0),
      I1 => BRESP_1_i_reg_0,
      I2 => m_apb_pslverr(0),
      I3 => s_axi_bready,
      I4 => BRESP_1_i_i_2_n_0,
      I5 => \^s_axi_bresp\(0),
      O => BRESP_1_i_i_1_n_0
    );
BRESP_1_i_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"20000000"
    )
        port map (
      I0 => axi_wr_rd_cs(2),
      I1 => axi_wr_rd_cs(0),
      I2 => axi_wr_rd_cs(1),
      I3 => m_apb_pready(0),
      I4 => \FSM_sequential_axi_wr_rd_cs_reg[1]_0\,
      O => BRESP_1_i_i_2_n_0
    );
BRESP_1_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => BRESP_1_i_i_1_n_0,
      Q => \^s_axi_bresp\(0),
      R => \^s_axi_aresetn_0\
    );
BVALID_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0F88000000000000"
    )
        port map (
      I0 => \FSM_sequential_axi_wr_rd_cs_reg[1]_0\,
      I1 => m_apb_pready(0),
      I2 => s_axi_bready,
      I3 => axi_wr_rd_cs(0),
      I4 => axi_wr_rd_cs(1),
      I5 => axi_wr_rd_cs(2),
      O => BVALID_sm
    );
BVALID_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => BVALID_sm,
      Q => s_axi_bvalid,
      R => \^s_axi_aresetn_0\
    );
\FSM_sequential_axi_wr_rd_cs[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0022FFFF0F0F0000"
    )
        port map (
      I0 => s_axi_awvalid,
      I1 => \FSM_sequential_axi_wr_rd_cs[0]_i_2_n_0\,
      I2 => \FSM_sequential_axi_wr_rd_cs[0]_i_3_n_0\,
      I3 => s_axi_wvalid,
      I4 => \FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0\,
      I5 => axi_wr_rd_cs(0),
      O => \FSM_sequential_axi_wr_rd_cs[0]_i_1_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[0]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => axi_wr_rd_cs(2),
      I1 => axi_wr_rd_cs(1),
      O => \FSM_sequential_axi_wr_rd_cs[0]_i_2_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[0]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000FFFF40"
    )
        port map (
      I0 => s_axi_arvalid,
      I1 => s_axi_awvalid,
      I2 => s_axi_wvalid,
      I3 => axi_wr_rd_cs(1),
      I4 => axi_wr_rd_cs(2),
      I5 => \FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0\,
      O => \FSM_sequential_axi_wr_rd_cs[0]_i_3_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"3222FFFFEEEE0000"
    )
        port map (
      I0 => axi_wr_rd_cs(2),
      I1 => axi_wr_rd_cs(0),
      I2 => m_apb_pready(0),
      I3 => \FSM_sequential_axi_wr_rd_cs_reg[1]_0\,
      I4 => \FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0\,
      I5 => axi_wr_rd_cs(1),
      O => \FSM_sequential_axi_wr_rd_cs[1]_i_1_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7777FFFF89010000"
    )
        port map (
      I0 => axi_wr_rd_cs(0),
      I1 => axi_wr_rd_cs(1),
      I2 => s_axi_arvalid,
      I3 => s_axi_awvalid,
      I4 => \FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0\,
      I5 => axi_wr_rd_cs(2),
      O => \FSM_sequential_axi_wr_rd_cs[2]_i_1_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFAFFFFFAAAAFFFE"
    )
        port map (
      I0 => \FSM_sequential_axi_wr_rd_cs[2]_i_3_n_0\,
      I1 => s_axi_arvalid,
      I2 => axi_wr_rd_cs(0),
      I3 => s_axi_awvalid,
      I4 => \FSM_sequential_axi_wr_rd_cs[2]_i_4_n_0\,
      I5 => \FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0\,
      O => \FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[2]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"BC8C3030B0803030"
    )
        port map (
      I0 => s_axi_bready,
      I1 => axi_wr_rd_cs(1),
      I2 => axi_wr_rd_cs(2),
      I3 => s_axi_wvalid,
      I4 => axi_wr_rd_cs(0),
      I5 => s_axi_rready,
      O => \FSM_sequential_axi_wr_rd_cs[2]_i_3_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[2]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => axi_wr_rd_cs(1),
      I1 => axi_wr_rd_cs(2),
      O => \FSM_sequential_axi_wr_rd_cs[2]_i_4_n_0\
    );
\FSM_sequential_axi_wr_rd_cs[2]_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => axi_wr_rd_cs(1),
      I1 => m_apb_pready(0),
      I2 => \FSM_sequential_axi_wr_rd_cs_reg[1]_0\,
      O => \FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0\
    );
\FSM_sequential_axi_wr_rd_cs_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => \FSM_sequential_axi_wr_rd_cs[0]_i_1_n_0\,
      Q => axi_wr_rd_cs(0),
      R => \^s_axi_aresetn_0\
    );
\FSM_sequential_axi_wr_rd_cs_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => \FSM_sequential_axi_wr_rd_cs[1]_i_1_n_0\,
      Q => axi_wr_rd_cs(1),
      R => \^s_axi_aresetn_0\
    );
\FSM_sequential_axi_wr_rd_cs_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => \FSM_sequential_axi_wr_rd_cs[2]_i_1_n_0\,
      Q => axi_wr_rd_cs(2),
      R => \^s_axi_aresetn_0\
    );
\PADDR_i[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(0),
      I1 => waddr_ready_sm,
      I2 => address_i(0),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(0),
      O => D(0)
    );
\PADDR_i[10]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(10),
      I1 => waddr_ready_sm,
      I2 => address_i(10),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(10),
      O => D(10)
    );
\PADDR_i[11]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(11),
      I1 => waddr_ready_sm,
      I2 => address_i(11),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(11),
      O => D(11)
    );
\PADDR_i[12]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(12),
      I1 => waddr_ready_sm,
      I2 => address_i(12),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(12),
      O => D(12)
    );
\PADDR_i[13]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(13),
      I1 => waddr_ready_sm,
      I2 => address_i(13),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(13),
      O => D(13)
    );
\PADDR_i[14]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(14),
      I1 => waddr_ready_sm,
      I2 => address_i(14),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(14),
      O => D(14)
    );
\PADDR_i[15]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(15),
      I1 => waddr_ready_sm,
      I2 => address_i(15),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(15),
      O => D(15)
    );
\PADDR_i[16]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(16),
      I1 => waddr_ready_sm,
      I2 => address_i(16),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(16),
      O => D(16)
    );
\PADDR_i[17]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(17),
      I1 => waddr_ready_sm,
      I2 => address_i(17),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(17),
      O => D(17)
    );
\PADDR_i[18]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(18),
      I1 => waddr_ready_sm,
      I2 => address_i(18),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(18),
      O => D(18)
    );
\PADDR_i[19]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(19),
      I1 => waddr_ready_sm,
      I2 => address_i(19),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(19),
      O => D(19)
    );
\PADDR_i[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(1),
      I1 => waddr_ready_sm,
      I2 => address_i(1),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(1),
      O => D(1)
    );
\PADDR_i[20]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(20),
      I1 => waddr_ready_sm,
      I2 => address_i(20),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(20),
      O => D(20)
    );
\PADDR_i[21]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(21),
      I1 => waddr_ready_sm,
      I2 => address_i(21),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(21),
      O => D(21)
    );
\PADDR_i[22]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(22),
      I1 => waddr_ready_sm,
      I2 => address_i(22),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(22),
      O => D(22)
    );
\PADDR_i[23]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(23),
      I1 => waddr_ready_sm,
      I2 => address_i(23),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(23),
      O => D(23)
    );
\PADDR_i[24]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(24),
      I1 => waddr_ready_sm,
      I2 => address_i(24),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(24),
      O => D(24)
    );
\PADDR_i[25]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(25),
      I1 => waddr_ready_sm,
      I2 => address_i(25),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(25),
      O => D(25)
    );
\PADDR_i[26]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(26),
      I1 => waddr_ready_sm,
      I2 => address_i(26),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(26),
      O => D(26)
    );
\PADDR_i[27]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(27),
      I1 => waddr_ready_sm,
      I2 => address_i(27),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(27),
      O => D(27)
    );
\PADDR_i[28]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(28),
      I1 => waddr_ready_sm,
      I2 => address_i(28),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(28),
      O => D(28)
    );
\PADDR_i[29]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(29),
      I1 => waddr_ready_sm,
      I2 => address_i(29),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(29),
      O => D(29)
    );
\PADDR_i[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(2),
      I1 => waddr_ready_sm,
      I2 => address_i(2),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(2),
      O => D(2)
    );
\PADDR_i[30]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(30),
      I1 => waddr_ready_sm,
      I2 => address_i(30),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(30),
      O => D(30)
    );
\PADDR_i[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"80F08080FFFFFFFF"
    )
        port map (
      I0 => \PADDR_i[31]_i_3_n_0\,
      I1 => axi_wr_rd_cs(0),
      I2 => s_axi_wvalid,
      I3 => WREADY_i_i_2_n_0,
      I4 => s_axi_awvalid,
      I5 => \PADDR_i[31]_i_4_n_0\,
      O => \FSM_sequential_axi_wr_rd_cs_reg[0]_0\
    );
\PADDR_i[31]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(31),
      I1 => waddr_ready_sm,
      I2 => address_i(31),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(31),
      O => D(31)
    );
\PADDR_i[31]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => axi_wr_rd_cs(2),
      I1 => axi_wr_rd_cs(1),
      O => \PADDR_i[31]_i_3_n_0\
    );
\PADDR_i[31]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFEF"
    )
        port map (
      I0 => axi_wr_rd_cs(0),
      I1 => axi_wr_rd_cs(2),
      I2 => s_axi_arvalid,
      I3 => axi_wr_rd_cs(1),
      O => \PADDR_i[31]_i_4_n_0\
    );
\PADDR_i[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(3),
      I1 => waddr_ready_sm,
      I2 => address_i(3),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(3),
      O => D(3)
    );
\PADDR_i[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(4),
      I1 => waddr_ready_sm,
      I2 => address_i(4),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(4),
      O => D(4)
    );
\PADDR_i[5]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(5),
      I1 => waddr_ready_sm,
      I2 => address_i(5),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(5),
      O => D(5)
    );
\PADDR_i[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(6),
      I1 => waddr_ready_sm,
      I2 => address_i(6),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(6),
      O => D(6)
    );
\PADDR_i[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(7),
      I1 => waddr_ready_sm,
      I2 => address_i(7),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(7),
      O => D(7)
    );
\PADDR_i[8]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(8),
      I1 => waddr_ready_sm,
      I2 => address_i(8),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(8),
      O => D(8)
    );
\PADDR_i[9]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8FFB800"
    )
        port map (
      I0 => s_axi_awaddr(9),
      I1 => waddr_ready_sm,
      I2 => address_i(9),
      I3 => \^apb_wr_request\,
      I4 => s_axi_araddr(9),
      O => D(9)
    );
\PWDATA_i[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(0),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(0)
    );
\PWDATA_i[10]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(10),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(10)
    );
\PWDATA_i[11]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(11),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(11)
    );
\PWDATA_i[12]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(12),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(12)
    );
\PWDATA_i[13]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(13),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(13)
    );
\PWDATA_i[14]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(14),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(14)
    );
\PWDATA_i[15]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(15),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(15)
    );
\PWDATA_i[16]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(16),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(16)
    );
\PWDATA_i[17]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(17),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(17)
    );
\PWDATA_i[18]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(18),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(18)
    );
\PWDATA_i[19]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(19),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(19)
    );
\PWDATA_i[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(1),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(1)
    );
\PWDATA_i[20]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(20),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(20)
    );
\PWDATA_i[21]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(21),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(21)
    );
\PWDATA_i[22]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(22),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(22)
    );
\PWDATA_i[23]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(23),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(23)
    );
\PWDATA_i[24]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(24),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(24)
    );
\PWDATA_i[25]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(25),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(25)
    );
\PWDATA_i[26]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(26),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(26)
    );
\PWDATA_i[27]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(27),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(27)
    );
\PWDATA_i[28]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(28),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(28)
    );
\PWDATA_i[29]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(29),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(29)
    );
\PWDATA_i[2]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(2),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(2)
    );
\PWDATA_i[30]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(30),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(30)
    );
\PWDATA_i[31]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(31),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(31)
    );
\PWDATA_i[3]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(3),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(3)
    );
\PWDATA_i[4]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(4),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(4)
    );
\PWDATA_i[5]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(5),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(5)
    );
\PWDATA_i[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(6),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(6)
    );
\PWDATA_i[7]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(7),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(7)
    );
\PWDATA_i[8]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(8),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(8)
    );
\PWDATA_i[9]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wdata(9),
      I1 => \^apb_wr_request\,
      O => \s_axi_wdata[31]\(9)
    );
RRESP_1_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => RRESP_1_i,
      Q => s_axi_rresp(0),
      R => \^s_axi_aresetn_0\
    );
RVALID_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000F8800000000"
    )
        port map (
      I0 => \FSM_sequential_axi_wr_rd_cs_reg[1]_0\,
      I1 => m_apb_pready(0),
      I2 => s_axi_rready,
      I3 => axi_wr_rd_cs(0),
      I4 => axi_wr_rd_cs(2),
      I5 => axi_wr_rd_cs(1),
      O => RVALID_sm
    );
RVALID_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => RVALID_sm,
      Q => s_axi_rvalid,
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(0),
      O => p_2_in(0)
    );
\S_AXI_RDATA[10]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(10),
      O => p_2_in(10)
    );
\S_AXI_RDATA[11]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(11),
      O => p_2_in(11)
    );
\S_AXI_RDATA[12]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(12),
      O => p_2_in(12)
    );
\S_AXI_RDATA[13]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(13),
      O => p_2_in(13)
    );
\S_AXI_RDATA[14]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(14),
      O => p_2_in(14)
    );
\S_AXI_RDATA[15]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(15),
      O => p_2_in(15)
    );
\S_AXI_RDATA[16]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(16),
      O => p_2_in(16)
    );
\S_AXI_RDATA[17]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(17),
      O => p_2_in(17)
    );
\S_AXI_RDATA[18]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(18),
      O => p_2_in(18)
    );
\S_AXI_RDATA[19]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(19),
      O => p_2_in(19)
    );
\S_AXI_RDATA[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(1),
      O => p_2_in(1)
    );
\S_AXI_RDATA[20]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(20),
      O => p_2_in(20)
    );
\S_AXI_RDATA[21]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(21),
      O => p_2_in(21)
    );
\S_AXI_RDATA[22]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(22),
      O => p_2_in(22)
    );
\S_AXI_RDATA[23]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(23),
      O => p_2_in(23)
    );
\S_AXI_RDATA[24]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(24),
      O => p_2_in(24)
    );
\S_AXI_RDATA[25]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(25),
      O => p_2_in(25)
    );
\S_AXI_RDATA[26]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(26),
      O => p_2_in(26)
    );
\S_AXI_RDATA[27]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(27),
      O => p_2_in(27)
    );
\S_AXI_RDATA[28]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(28),
      O => p_2_in(28)
    );
\S_AXI_RDATA[29]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(29),
      O => p_2_in(29)
    );
\S_AXI_RDATA[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(2),
      O => p_2_in(2)
    );
\S_AXI_RDATA[30]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(30),
      O => p_2_in(30)
    );
\S_AXI_RDATA[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"ABAAAAAAAAAAAAAA"
    )
        port map (
      I0 => s_axi_rready,
      I1 => axi_wr_rd_cs(2),
      I2 => axi_wr_rd_cs(0),
      I3 => axi_wr_rd_cs(1),
      I4 => m_apb_pready(0),
      I5 => \FSM_sequential_axi_wr_rd_cs_reg[1]_0\,
      O => \S_AXI_RDATA[31]_i_1_n_0\
    );
\S_AXI_RDATA[31]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(31),
      O => p_2_in(31)
    );
\S_AXI_RDATA[31]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000080"
    )
        port map (
      I0 => \FSM_sequential_axi_wr_rd_cs_reg[1]_0\,
      I1 => m_apb_pready(0),
      I2 => axi_wr_rd_cs(1),
      I3 => axi_wr_rd_cs(0),
      I4 => axi_wr_rd_cs(2),
      O => \^penable_i_reg\
    );
\S_AXI_RDATA[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(3),
      O => p_2_in(3)
    );
\S_AXI_RDATA[4]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(4),
      O => p_2_in(4)
    );
\S_AXI_RDATA[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(5),
      O => p_2_in(5)
    );
\S_AXI_RDATA[6]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(6),
      O => p_2_in(6)
    );
\S_AXI_RDATA[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(7),
      O => p_2_in(7)
    );
\S_AXI_RDATA[8]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(8),
      O => p_2_in(8)
    );
\S_AXI_RDATA[9]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^penable_i_reg\,
      I1 => m_apb_pready(0),
      I2 => BRESP_1_i_reg_0,
      I3 => m_apb_prdata(9),
      O => p_2_in(9)
    );
\S_AXI_RDATA_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(0),
      Q => s_axi_rdata(0),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(10),
      Q => s_axi_rdata(10),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(11),
      Q => s_axi_rdata(11),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(12),
      Q => s_axi_rdata(12),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(13),
      Q => s_axi_rdata(13),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(14),
      Q => s_axi_rdata(14),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(15),
      Q => s_axi_rdata(15),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(16),
      Q => s_axi_rdata(16),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(17),
      Q => s_axi_rdata(17),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(18),
      Q => s_axi_rdata(18),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(19),
      Q => s_axi_rdata(19),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(1),
      Q => s_axi_rdata(1),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(20),
      Q => s_axi_rdata(20),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(21),
      Q => s_axi_rdata(21),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(22),
      Q => s_axi_rdata(22),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(23),
      Q => s_axi_rdata(23),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(24),
      Q => s_axi_rdata(24),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(25),
      Q => s_axi_rdata(25),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(26),
      Q => s_axi_rdata(26),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(27),
      Q => s_axi_rdata(27),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(28),
      Q => s_axi_rdata(28),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(29),
      Q => s_axi_rdata(29),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(2),
      Q => s_axi_rdata(2),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(30),
      Q => s_axi_rdata(30),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(31),
      Q => s_axi_rdata(31),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(3),
      Q => s_axi_rdata(3),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(4),
      Q => s_axi_rdata(4),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(5),
      Q => s_axi_rdata(5),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(6),
      Q => s_axi_rdata(6),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(7),
      Q => s_axi_rdata(7),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(8),
      Q => s_axi_rdata(8),
      R => \^s_axi_aresetn_0\
    );
\S_AXI_RDATA_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \S_AXI_RDATA[31]_i_1_n_0\,
      D => p_2_in(9),
      Q => s_axi_rdata(9),
      R => \^s_axi_aresetn_0\
    );
WREADY_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20202020F0202020"
    )
        port map (
      I0 => s_axi_awvalid,
      I1 => WREADY_i_i_2_n_0,
      I2 => s_axi_wvalid,
      I3 => axi_wr_rd_cs(0),
      I4 => axi_wr_rd_cs(2),
      I5 => axi_wr_rd_cs(1),
      O => \^apb_wr_request\
    );
WREADY_i_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"DFDFFFFC"
    )
        port map (
      I0 => s_axi_rready,
      I1 => axi_wr_rd_cs(2),
      I2 => axi_wr_rd_cs(0),
      I3 => s_axi_arvalid,
      I4 => axi_wr_rd_cs(1),
      O => WREADY_i_i_2_n_0
    );
WREADY_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => \^apb_wr_request\,
      Q => s_axi_wready,
      R => \^s_axi_aresetn_0\
    );
\address_i[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(0),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(0),
      O => \address_i[0]_i_1_n_0\
    );
\address_i[10]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(10),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(10),
      O => \address_i[10]_i_1_n_0\
    );
\address_i[11]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(11),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(11),
      O => \address_i[11]_i_1_n_0\
    );
\address_i[12]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(12),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(12),
      O => \address_i[12]_i_1_n_0\
    );
\address_i[13]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(13),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(13),
      O => \address_i[13]_i_1_n_0\
    );
\address_i[14]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(14),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(14),
      O => \address_i[14]_i_1_n_0\
    );
\address_i[15]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(15),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(15),
      O => \address_i[15]_i_1_n_0\
    );
\address_i[16]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(16),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(16),
      O => \address_i[16]_i_1_n_0\
    );
\address_i[17]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(17),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(17),
      O => \address_i[17]_i_1_n_0\
    );
\address_i[18]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(18),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(18),
      O => \address_i[18]_i_1_n_0\
    );
\address_i[19]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(19),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(19),
      O => \address_i[19]_i_1_n_0\
    );
\address_i[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(1),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(1),
      O => \address_i[1]_i_1_n_0\
    );
\address_i[20]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(20),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(20),
      O => \address_i[20]_i_1_n_0\
    );
\address_i[21]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(21),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(21),
      O => \address_i[21]_i_1_n_0\
    );
\address_i[22]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(22),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(22),
      O => \address_i[22]_i_1_n_0\
    );
\address_i[23]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(23),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(23),
      O => \address_i[23]_i_1_n_0\
    );
\address_i[24]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(24),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(24),
      O => \address_i[24]_i_1_n_0\
    );
\address_i[25]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(25),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(25),
      O => \address_i[25]_i_1_n_0\
    );
\address_i[26]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(26),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(26),
      O => \address_i[26]_i_1_n_0\
    );
\address_i[27]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(27),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(27),
      O => \address_i[27]_i_1_n_0\
    );
\address_i[28]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(28),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(28),
      O => \address_i[28]_i_1_n_0\
    );
\address_i[29]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(29),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(29),
      O => \address_i[29]_i_1_n_0\
    );
\address_i[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(2),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(2),
      O => \address_i[2]_i_1_n_0\
    );
\address_i[30]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(30),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(30),
      O => \address_i[30]_i_1_n_0\
    );
\address_i[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000808000000F0C"
    )
        port map (
      I0 => s_axi_rready,
      I1 => s_axi_awvalid,
      I2 => axi_wr_rd_cs(1),
      I3 => s_axi_arvalid,
      I4 => axi_wr_rd_cs(2),
      I5 => axi_wr_rd_cs(0),
      O => \address_i[31]_i_1_n_0\
    );
\address_i[31]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(31),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(31),
      O => \address_i[31]_i_2_n_0\
    );
\address_i[3]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(3),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(3),
      O => \address_i[3]_i_1_n_0\
    );
\address_i[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(4),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(4),
      O => \address_i[4]_i_1_n_0\
    );
\address_i[5]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(5),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(5),
      O => \address_i[5]_i_1_n_0\
    );
\address_i[6]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(6),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(6),
      O => \address_i[6]_i_1_n_0\
    );
\address_i[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(7),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(7),
      O => \address_i[7]_i_1_n_0\
    );
\address_i[8]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(8),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(8),
      O => \address_i[8]_i_1_n_0\
    );
\address_i[9]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axi_awaddr(9),
      I1 => waddr_ready_sm,
      I2 => s_axi_araddr(9),
      O => \address_i[9]_i_1_n_0\
    );
\address_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[0]_i_1_n_0\,
      Q => address_i(0),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[10]_i_1_n_0\,
      Q => address_i(10),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[11]_i_1_n_0\,
      Q => address_i(11),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[12]_i_1_n_0\,
      Q => address_i(12),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[13]_i_1_n_0\,
      Q => address_i(13),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[14]_i_1_n_0\,
      Q => address_i(14),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[15]_i_1_n_0\,
      Q => address_i(15),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[16]_i_1_n_0\,
      Q => address_i(16),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[17]_i_1_n_0\,
      Q => address_i(17),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[18]_i_1_n_0\,
      Q => address_i(18),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[19]_i_1_n_0\,
      Q => address_i(19),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[1]_i_1_n_0\,
      Q => address_i(1),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[20]_i_1_n_0\,
      Q => address_i(20),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[21]_i_1_n_0\,
      Q => address_i(21),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[22]_i_1_n_0\,
      Q => address_i(22),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[23]_i_1_n_0\,
      Q => address_i(23),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[24]_i_1_n_0\,
      Q => address_i(24),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[25]_i_1_n_0\,
      Q => address_i(25),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[26]_i_1_n_0\,
      Q => address_i(26),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[27]_i_1_n_0\,
      Q => address_i(27),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[28]_i_1_n_0\,
      Q => address_i(28),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[29]_i_1_n_0\,
      Q => address_i(29),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[2]_i_1_n_0\,
      Q => address_i(2),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[30]_i_1_n_0\,
      Q => address_i(30),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[31]_i_2_n_0\,
      Q => address_i(31),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[3]_i_1_n_0\,
      Q => address_i(3),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[4]_i_1_n_0\,
      Q => address_i(4),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[5]_i_1_n_0\,
      Q => address_i(5),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[6]_i_1_n_0\,
      Q => address_i(6),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[7]_i_1_n_0\,
      Q => address_i(7),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[8]_i_1_n_0\,
      Q => address_i(8),
      R => \^s_axi_aresetn_0\
    );
\address_i_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \address_i[31]_i_1_n_0\,
      D => \address_i[9]_i_1_n_0\,
      Q => address_i(9),
      R => \^s_axi_aresetn_0\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity crossbar_axi_apb_bridge_0_0_multiplexor is
  port (
    m_apb_psel : out STD_LOGIC_VECTOR ( 0 to 0 );
    \GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0\ : in STD_LOGIC;
    PSEL_i : in STD_LOGIC;
    s_axi_aclk : in STD_LOGIC
  );
end crossbar_axi_apb_bridge_0_0_multiplexor;

architecture STRUCTURE of crossbar_axi_apb_bridge_0_0_multiplexor is
begin
\GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => PSEL_i,
      Q => m_apb_psel(0),
      R => \GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity crossbar_axi_apb_bridge_0_0_axi_apb_bridge is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    m_apb_paddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_psel : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_apb_penable : out STD_LOGIC;
    m_apb_pwrite : out STD_LOGIC;
    m_apb_pwdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_pready : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_apb_prdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata2 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata3 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata4 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata5 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata6 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata7 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata8 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata9 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata10 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata11 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata12 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata13 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata14 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata15 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_prdata16 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_pslverr : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_apb_pprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_apb_pstrb : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );
  attribute C_APB_NUM_SLAVES : integer;
  attribute C_APB_NUM_SLAVES of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is 1;
  attribute C_BASEADDR : string;
  attribute C_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011110100000000000000000000000000";
  attribute C_DPHASE_TIMEOUT : integer;
  attribute C_DPHASE_TIMEOUT of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is 0;
  attribute C_FAMILY : string;
  attribute C_FAMILY of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "artix7";
  attribute C_HIGHADDR : string;
  attribute C_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011110100000000001111111111111111";
  attribute C_INSTANCE : string;
  attribute C_INSTANCE of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "axi_apb_bridge_inst";
  attribute C_M_APB_ADDR_WIDTH : integer;
  attribute C_M_APB_ADDR_WIDTH of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is 32;
  attribute C_M_APB_DATA_WIDTH : integer;
  attribute C_M_APB_DATA_WIDTH of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is 32;
  attribute C_M_APB_PROTOCOL : string;
  attribute C_M_APB_PROTOCOL of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "apb3";
  attribute C_S_AXI_ADDR_WIDTH : integer;
  attribute C_S_AXI_ADDR_WIDTH of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is 32;
  attribute C_S_AXI_DATA_WIDTH : integer;
  attribute C_S_AXI_DATA_WIDTH of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is 32;
  attribute C_S_AXI_RNG10_BASEADDR : string;
  attribute C_S_AXI_RNG10_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010010000000000000000000000000000";
  attribute C_S_AXI_RNG10_HIGHADDR : string;
  attribute C_S_AXI_RNG10_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010011111111111111111111111111111";
  attribute C_S_AXI_RNG11_BASEADDR : string;
  attribute C_S_AXI_RNG11_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010100000000000000000000000000000";
  attribute C_S_AXI_RNG11_HIGHADDR : string;
  attribute C_S_AXI_RNG11_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010101111111111111111111111111111";
  attribute C_S_AXI_RNG12_BASEADDR : string;
  attribute C_S_AXI_RNG12_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010110000000000000000000000000000";
  attribute C_S_AXI_RNG12_HIGHADDR : string;
  attribute C_S_AXI_RNG12_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010111111111111111111111111111111";
  attribute C_S_AXI_RNG13_BASEADDR : string;
  attribute C_S_AXI_RNG13_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011000000000000000000000000000000";
  attribute C_S_AXI_RNG13_HIGHADDR : string;
  attribute C_S_AXI_RNG13_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011001111111111111111111111111111";
  attribute C_S_AXI_RNG14_BASEADDR : string;
  attribute C_S_AXI_RNG14_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011010000000000000000000000000000";
  attribute C_S_AXI_RNG14_HIGHADDR : string;
  attribute C_S_AXI_RNG14_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011011111111111111111111111111111";
  attribute C_S_AXI_RNG15_BASEADDR : string;
  attribute C_S_AXI_RNG15_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011100000000000000000000000000000";
  attribute C_S_AXI_RNG15_HIGHADDR : string;
  attribute C_S_AXI_RNG15_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011101111111111111111111111111111";
  attribute C_S_AXI_RNG16_BASEADDR : string;
  attribute C_S_AXI_RNG16_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011110000000000000000000000000000";
  attribute C_S_AXI_RNG16_HIGHADDR : string;
  attribute C_S_AXI_RNG16_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000011111111111111111111111111111111";
  attribute C_S_AXI_RNG2_BASEADDR : string;
  attribute C_S_AXI_RNG2_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000000010000000000000000000000000000";
  attribute C_S_AXI_RNG2_HIGHADDR : string;
  attribute C_S_AXI_RNG2_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000000011111111111111111111111111111";
  attribute C_S_AXI_RNG3_BASEADDR : string;
  attribute C_S_AXI_RNG3_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000000100000000000000000000000000000";
  attribute C_S_AXI_RNG3_HIGHADDR : string;
  attribute C_S_AXI_RNG3_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000000101111111111111111111111111111";
  attribute C_S_AXI_RNG4_BASEADDR : string;
  attribute C_S_AXI_RNG4_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000000110000000000000000000000000000";
  attribute C_S_AXI_RNG4_HIGHADDR : string;
  attribute C_S_AXI_RNG4_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000000111111111111111111111111111111";
  attribute C_S_AXI_RNG5_BASEADDR : string;
  attribute C_S_AXI_RNG5_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001000000000000000000000000000000";
  attribute C_S_AXI_RNG5_HIGHADDR : string;
  attribute C_S_AXI_RNG5_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001001111111111111111111111111111";
  attribute C_S_AXI_RNG6_BASEADDR : string;
  attribute C_S_AXI_RNG6_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001010000000000000000000000000000";
  attribute C_S_AXI_RNG6_HIGHADDR : string;
  attribute C_S_AXI_RNG6_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001011111111111111111111111111111";
  attribute C_S_AXI_RNG7_BASEADDR : string;
  attribute C_S_AXI_RNG7_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001100000000000000000000000000000";
  attribute C_S_AXI_RNG7_HIGHADDR : string;
  attribute C_S_AXI_RNG7_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001101111111111111111111111111111";
  attribute C_S_AXI_RNG8_BASEADDR : string;
  attribute C_S_AXI_RNG8_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001110000000000000000000000000000";
  attribute C_S_AXI_RNG8_HIGHADDR : string;
  attribute C_S_AXI_RNG8_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000001111111111111111111111111111111";
  attribute C_S_AXI_RNG9_BASEADDR : string;
  attribute C_S_AXI_RNG9_BASEADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010000000000000000000000000000000";
  attribute C_S_AXI_RNG9_HIGHADDR : string;
  attribute C_S_AXI_RNG9_HIGHADDR of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "64'b0000000000000000000000000000000010001111111111111111111111111111";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of crossbar_axi_apb_bridge_0_0_axi_apb_bridge : entity is "yes";
end crossbar_axi_apb_bridge_0_0_axi_apb_bridge;

architecture STRUCTURE of crossbar_axi_apb_bridge_0_0_axi_apb_bridge is
  signal \<const0>\ : STD_LOGIC;
  signal APB_MASTER_IF_MODULE_n_3 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_1 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_10 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_11 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_12 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_13 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_14 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_15 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_16 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_17 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_18 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_19 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_20 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_21 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_22 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_23 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_24 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_25 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_26 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_27 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_28 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_29 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_30 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_31 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_32 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_33 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_34 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_35 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_36 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_37 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_38 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_39 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_40 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_41 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_42 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_43 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_44 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_45 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_46 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_47 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_48 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_49 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_50 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_51 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_52 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_53 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_54 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_55 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_56 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_57 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_58 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_59 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_60 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_61 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_62 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_63 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_64 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_65 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_66 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_67 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_68 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_69 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_70 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_71 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_72 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_73 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_74 : STD_LOGIC;
  signal AXILITE_SLAVE_IF_MODULE_n_9 : STD_LOGIC;
  signal PSEL_i : STD_LOGIC;
  signal RRESP_1_i : STD_LOGIC;
  signal apb_wr_request : STD_LOGIC;
  signal \^m_apb_penable\ : STD_LOGIC;
  signal \^s_axi_bresp\ : STD_LOGIC_VECTOR ( 1 to 1 );
  signal \^s_axi_rresp\ : STD_LOGIC_VECTOR ( 1 to 1 );
begin
  m_apb_penable <= \^m_apb_penable\;
  m_apb_pprot(2) <= \<const0>\;
  m_apb_pprot(1) <= \<const0>\;
  m_apb_pprot(0) <= \<const0>\;
  m_apb_pstrb(3) <= \<const0>\;
  m_apb_pstrb(2) <= \<const0>\;
  m_apb_pstrb(1) <= \<const0>\;
  m_apb_pstrb(0) <= \<const0>\;
  s_axi_bresp(1) <= \^s_axi_bresp\(1);
  s_axi_bresp(0) <= \<const0>\;
  s_axi_rresp(1) <= \^s_axi_rresp\(1);
  s_axi_rresp(0) <= \<const0>\;
APB_MASTER_IF_MODULE: entity work.crossbar_axi_apb_bridge_0_0_apb_mif
     port map (
      D(31) => AXILITE_SLAVE_IF_MODULE_n_10,
      D(30) => AXILITE_SLAVE_IF_MODULE_n_11,
      D(29) => AXILITE_SLAVE_IF_MODULE_n_12,
      D(28) => AXILITE_SLAVE_IF_MODULE_n_13,
      D(27) => AXILITE_SLAVE_IF_MODULE_n_14,
      D(26) => AXILITE_SLAVE_IF_MODULE_n_15,
      D(25) => AXILITE_SLAVE_IF_MODULE_n_16,
      D(24) => AXILITE_SLAVE_IF_MODULE_n_17,
      D(23) => AXILITE_SLAVE_IF_MODULE_n_18,
      D(22) => AXILITE_SLAVE_IF_MODULE_n_19,
      D(21) => AXILITE_SLAVE_IF_MODULE_n_20,
      D(20) => AXILITE_SLAVE_IF_MODULE_n_21,
      D(19) => AXILITE_SLAVE_IF_MODULE_n_22,
      D(18) => AXILITE_SLAVE_IF_MODULE_n_23,
      D(17) => AXILITE_SLAVE_IF_MODULE_n_24,
      D(16) => AXILITE_SLAVE_IF_MODULE_n_25,
      D(15) => AXILITE_SLAVE_IF_MODULE_n_26,
      D(14) => AXILITE_SLAVE_IF_MODULE_n_27,
      D(13) => AXILITE_SLAVE_IF_MODULE_n_28,
      D(12) => AXILITE_SLAVE_IF_MODULE_n_29,
      D(11) => AXILITE_SLAVE_IF_MODULE_n_30,
      D(10) => AXILITE_SLAVE_IF_MODULE_n_31,
      D(9) => AXILITE_SLAVE_IF_MODULE_n_32,
      D(8) => AXILITE_SLAVE_IF_MODULE_n_33,
      D(7) => AXILITE_SLAVE_IF_MODULE_n_34,
      D(6) => AXILITE_SLAVE_IF_MODULE_n_35,
      D(5) => AXILITE_SLAVE_IF_MODULE_n_36,
      D(4) => AXILITE_SLAVE_IF_MODULE_n_37,
      D(3) => AXILITE_SLAVE_IF_MODULE_n_38,
      D(2) => AXILITE_SLAVE_IF_MODULE_n_39,
      D(1) => AXILITE_SLAVE_IF_MODULE_n_40,
      D(0) => AXILITE_SLAVE_IF_MODULE_n_41,
      \FSM_onehot_apb_wr_rd_cs_reg[2]_0\ => APB_MASTER_IF_MODULE_n_3,
      PENABLE_i_reg_0 => \^m_apb_penable\,
      PSEL_i => PSEL_i,
      \PWDATA_i_reg[0]_0\ => AXILITE_SLAVE_IF_MODULE_n_1,
      \PWDATA_i_reg[31]_0\(31) => AXILITE_SLAVE_IF_MODULE_n_42,
      \PWDATA_i_reg[31]_0\(30) => AXILITE_SLAVE_IF_MODULE_n_43,
      \PWDATA_i_reg[31]_0\(29) => AXILITE_SLAVE_IF_MODULE_n_44,
      \PWDATA_i_reg[31]_0\(28) => AXILITE_SLAVE_IF_MODULE_n_45,
      \PWDATA_i_reg[31]_0\(27) => AXILITE_SLAVE_IF_MODULE_n_46,
      \PWDATA_i_reg[31]_0\(26) => AXILITE_SLAVE_IF_MODULE_n_47,
      \PWDATA_i_reg[31]_0\(25) => AXILITE_SLAVE_IF_MODULE_n_48,
      \PWDATA_i_reg[31]_0\(24) => AXILITE_SLAVE_IF_MODULE_n_49,
      \PWDATA_i_reg[31]_0\(23) => AXILITE_SLAVE_IF_MODULE_n_50,
      \PWDATA_i_reg[31]_0\(22) => AXILITE_SLAVE_IF_MODULE_n_51,
      \PWDATA_i_reg[31]_0\(21) => AXILITE_SLAVE_IF_MODULE_n_52,
      \PWDATA_i_reg[31]_0\(20) => AXILITE_SLAVE_IF_MODULE_n_53,
      \PWDATA_i_reg[31]_0\(19) => AXILITE_SLAVE_IF_MODULE_n_54,
      \PWDATA_i_reg[31]_0\(18) => AXILITE_SLAVE_IF_MODULE_n_55,
      \PWDATA_i_reg[31]_0\(17) => AXILITE_SLAVE_IF_MODULE_n_56,
      \PWDATA_i_reg[31]_0\(16) => AXILITE_SLAVE_IF_MODULE_n_57,
      \PWDATA_i_reg[31]_0\(15) => AXILITE_SLAVE_IF_MODULE_n_58,
      \PWDATA_i_reg[31]_0\(14) => AXILITE_SLAVE_IF_MODULE_n_59,
      \PWDATA_i_reg[31]_0\(13) => AXILITE_SLAVE_IF_MODULE_n_60,
      \PWDATA_i_reg[31]_0\(12) => AXILITE_SLAVE_IF_MODULE_n_61,
      \PWDATA_i_reg[31]_0\(11) => AXILITE_SLAVE_IF_MODULE_n_62,
      \PWDATA_i_reg[31]_0\(10) => AXILITE_SLAVE_IF_MODULE_n_63,
      \PWDATA_i_reg[31]_0\(9) => AXILITE_SLAVE_IF_MODULE_n_64,
      \PWDATA_i_reg[31]_0\(8) => AXILITE_SLAVE_IF_MODULE_n_65,
      \PWDATA_i_reg[31]_0\(7) => AXILITE_SLAVE_IF_MODULE_n_66,
      \PWDATA_i_reg[31]_0\(6) => AXILITE_SLAVE_IF_MODULE_n_67,
      \PWDATA_i_reg[31]_0\(5) => AXILITE_SLAVE_IF_MODULE_n_68,
      \PWDATA_i_reg[31]_0\(4) => AXILITE_SLAVE_IF_MODULE_n_69,
      \PWDATA_i_reg[31]_0\(3) => AXILITE_SLAVE_IF_MODULE_n_70,
      \PWDATA_i_reg[31]_0\(2) => AXILITE_SLAVE_IF_MODULE_n_71,
      \PWDATA_i_reg[31]_0\(1) => AXILITE_SLAVE_IF_MODULE_n_72,
      \PWDATA_i_reg[31]_0\(0) => AXILITE_SLAVE_IF_MODULE_n_73,
      PWRITE_i_reg_0 => AXILITE_SLAVE_IF_MODULE_n_74,
      RRESP_1_i => RRESP_1_i,
      RRESP_1_i_reg => AXILITE_SLAVE_IF_MODULE_n_9,
      apb_wr_request => apb_wr_request,
      m_apb_paddr(31 downto 0) => m_apb_paddr(31 downto 0),
      m_apb_pready(0) => m_apb_pready(0),
      m_apb_pslverr(0) => m_apb_pslverr(0),
      m_apb_pwdata(31 downto 0) => m_apb_pwdata(31 downto 0),
      m_apb_pwrite => m_apb_pwrite,
      s_axi_aclk => s_axi_aclk
    );
AXILITE_SLAVE_IF_MODULE: entity work.crossbar_axi_apb_bridge_0_0_axilite_sif
     port map (
      BRESP_1_i_reg_0 => APB_MASTER_IF_MODULE_n_3,
      D(31) => AXILITE_SLAVE_IF_MODULE_n_10,
      D(30) => AXILITE_SLAVE_IF_MODULE_n_11,
      D(29) => AXILITE_SLAVE_IF_MODULE_n_12,
      D(28) => AXILITE_SLAVE_IF_MODULE_n_13,
      D(27) => AXILITE_SLAVE_IF_MODULE_n_14,
      D(26) => AXILITE_SLAVE_IF_MODULE_n_15,
      D(25) => AXILITE_SLAVE_IF_MODULE_n_16,
      D(24) => AXILITE_SLAVE_IF_MODULE_n_17,
      D(23) => AXILITE_SLAVE_IF_MODULE_n_18,
      D(22) => AXILITE_SLAVE_IF_MODULE_n_19,
      D(21) => AXILITE_SLAVE_IF_MODULE_n_20,
      D(20) => AXILITE_SLAVE_IF_MODULE_n_21,
      D(19) => AXILITE_SLAVE_IF_MODULE_n_22,
      D(18) => AXILITE_SLAVE_IF_MODULE_n_23,
      D(17) => AXILITE_SLAVE_IF_MODULE_n_24,
      D(16) => AXILITE_SLAVE_IF_MODULE_n_25,
      D(15) => AXILITE_SLAVE_IF_MODULE_n_26,
      D(14) => AXILITE_SLAVE_IF_MODULE_n_27,
      D(13) => AXILITE_SLAVE_IF_MODULE_n_28,
      D(12) => AXILITE_SLAVE_IF_MODULE_n_29,
      D(11) => AXILITE_SLAVE_IF_MODULE_n_30,
      D(10) => AXILITE_SLAVE_IF_MODULE_n_31,
      D(9) => AXILITE_SLAVE_IF_MODULE_n_32,
      D(8) => AXILITE_SLAVE_IF_MODULE_n_33,
      D(7) => AXILITE_SLAVE_IF_MODULE_n_34,
      D(6) => AXILITE_SLAVE_IF_MODULE_n_35,
      D(5) => AXILITE_SLAVE_IF_MODULE_n_36,
      D(4) => AXILITE_SLAVE_IF_MODULE_n_37,
      D(3) => AXILITE_SLAVE_IF_MODULE_n_38,
      D(2) => AXILITE_SLAVE_IF_MODULE_n_39,
      D(1) => AXILITE_SLAVE_IF_MODULE_n_40,
      D(0) => AXILITE_SLAVE_IF_MODULE_n_41,
      \FSM_sequential_axi_wr_rd_cs_reg[0]_0\ => AXILITE_SLAVE_IF_MODULE_n_74,
      \FSM_sequential_axi_wr_rd_cs_reg[1]_0\ => \^m_apb_penable\,
      PENABLE_i_reg => AXILITE_SLAVE_IF_MODULE_n_9,
      RRESP_1_i => RRESP_1_i,
      apb_wr_request => apb_wr_request,
      m_apb_prdata(31 downto 0) => m_apb_prdata(31 downto 0),
      m_apb_pready(0) => m_apb_pready(0),
      m_apb_pslverr(0) => m_apb_pslverr(0),
      s_axi_aclk => s_axi_aclk,
      s_axi_araddr(31 downto 0) => s_axi_araddr(31 downto 0),
      s_axi_aresetn => s_axi_aresetn,
      s_axi_aresetn_0 => AXILITE_SLAVE_IF_MODULE_n_1,
      s_axi_arready => s_axi_arready,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_awaddr(31 downto 0) => s_axi_awaddr(31 downto 0),
      s_axi_awready => s_axi_awready,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_bready => s_axi_bready,
      s_axi_bresp(0) => \^s_axi_bresp\(1),
      s_axi_bvalid => s_axi_bvalid,
      s_axi_rdata(31 downto 0) => s_axi_rdata(31 downto 0),
      s_axi_rready => s_axi_rready,
      s_axi_rresp(0) => \^s_axi_rresp\(1),
      s_axi_rvalid => s_axi_rvalid,
      s_axi_wdata(31 downto 0) => s_axi_wdata(31 downto 0),
      \s_axi_wdata[31]\(31) => AXILITE_SLAVE_IF_MODULE_n_42,
      \s_axi_wdata[31]\(30) => AXILITE_SLAVE_IF_MODULE_n_43,
      \s_axi_wdata[31]\(29) => AXILITE_SLAVE_IF_MODULE_n_44,
      \s_axi_wdata[31]\(28) => AXILITE_SLAVE_IF_MODULE_n_45,
      \s_axi_wdata[31]\(27) => AXILITE_SLAVE_IF_MODULE_n_46,
      \s_axi_wdata[31]\(26) => AXILITE_SLAVE_IF_MODULE_n_47,
      \s_axi_wdata[31]\(25) => AXILITE_SLAVE_IF_MODULE_n_48,
      \s_axi_wdata[31]\(24) => AXILITE_SLAVE_IF_MODULE_n_49,
      \s_axi_wdata[31]\(23) => AXILITE_SLAVE_IF_MODULE_n_50,
      \s_axi_wdata[31]\(22) => AXILITE_SLAVE_IF_MODULE_n_51,
      \s_axi_wdata[31]\(21) => AXILITE_SLAVE_IF_MODULE_n_52,
      \s_axi_wdata[31]\(20) => AXILITE_SLAVE_IF_MODULE_n_53,
      \s_axi_wdata[31]\(19) => AXILITE_SLAVE_IF_MODULE_n_54,
      \s_axi_wdata[31]\(18) => AXILITE_SLAVE_IF_MODULE_n_55,
      \s_axi_wdata[31]\(17) => AXILITE_SLAVE_IF_MODULE_n_56,
      \s_axi_wdata[31]\(16) => AXILITE_SLAVE_IF_MODULE_n_57,
      \s_axi_wdata[31]\(15) => AXILITE_SLAVE_IF_MODULE_n_58,
      \s_axi_wdata[31]\(14) => AXILITE_SLAVE_IF_MODULE_n_59,
      \s_axi_wdata[31]\(13) => AXILITE_SLAVE_IF_MODULE_n_60,
      \s_axi_wdata[31]\(12) => AXILITE_SLAVE_IF_MODULE_n_61,
      \s_axi_wdata[31]\(11) => AXILITE_SLAVE_IF_MODULE_n_62,
      \s_axi_wdata[31]\(10) => AXILITE_SLAVE_IF_MODULE_n_63,
      \s_axi_wdata[31]\(9) => AXILITE_SLAVE_IF_MODULE_n_64,
      \s_axi_wdata[31]\(8) => AXILITE_SLAVE_IF_MODULE_n_65,
      \s_axi_wdata[31]\(7) => AXILITE_SLAVE_IF_MODULE_n_66,
      \s_axi_wdata[31]\(6) => AXILITE_SLAVE_IF_MODULE_n_67,
      \s_axi_wdata[31]\(5) => AXILITE_SLAVE_IF_MODULE_n_68,
      \s_axi_wdata[31]\(4) => AXILITE_SLAVE_IF_MODULE_n_69,
      \s_axi_wdata[31]\(3) => AXILITE_SLAVE_IF_MODULE_n_70,
      \s_axi_wdata[31]\(2) => AXILITE_SLAVE_IF_MODULE_n_71,
      \s_axi_wdata[31]\(1) => AXILITE_SLAVE_IF_MODULE_n_72,
      \s_axi_wdata[31]\(0) => AXILITE_SLAVE_IF_MODULE_n_73,
      s_axi_wready => s_axi_wready,
      s_axi_wvalid => s_axi_wvalid
    );
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
MULTIPLEXOR_MODULE: entity work.crossbar_axi_apb_bridge_0_0_multiplexor
     port map (
      \GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0\ => AXILITE_SLAVE_IF_MODULE_n_1,
      PSEL_i => PSEL_i,
      m_apb_psel(0) => m_apb_psel(0),
      s_axi_aclk => s_axi_aclk
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity crossbar_axi_apb_bridge_0_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    m_apb_paddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_psel : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_apb_penable : out STD_LOGIC;
    m_apb_pwrite : out STD_LOGIC;
    m_apb_pwdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_pready : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_apb_prdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_apb_pslverr : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of crossbar_axi_apb_bridge_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of crossbar_axi_apb_bridge_0_0 : entity is "crossbar_axi_apb_bridge_0_0,axi_apb_bridge,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of crossbar_axi_apb_bridge_0_0 : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of crossbar_axi_apb_bridge_0_0 : entity is "axi_apb_bridge,Vivado 2020.2";
end crossbar_axi_apb_bridge_0_0;

architecture STRUCTURE of crossbar_axi_apb_bridge_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \^s_axi_bresp\ : STD_LOGIC_VECTOR ( 1 to 1 );
  signal \^s_axi_rresp\ : STD_LOGIC_VECTOR ( 1 to 1 );
  signal NLW_U0_m_apb_pprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_U0_m_apb_pstrb_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_U0_s_axi_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_U0_s_axi_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute C_APB_NUM_SLAVES : integer;
  attribute C_APB_NUM_SLAVES of U0 : label is 1;
  attribute C_BASEADDR : string;
  attribute C_BASEADDR of U0 : label is "64'b0000000000000000000000000000000011110100000000000000000000000000";
  attribute C_DPHASE_TIMEOUT : integer;
  attribute C_DPHASE_TIMEOUT of U0 : label is 0;
  attribute C_FAMILY : string;
  attribute C_FAMILY of U0 : label is "artix7";
  attribute C_HIGHADDR : string;
  attribute C_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000011110100000000001111111111111111";
  attribute C_INSTANCE : string;
  attribute C_INSTANCE of U0 : label is "axi_apb_bridge_inst";
  attribute C_M_APB_ADDR_WIDTH : integer;
  attribute C_M_APB_ADDR_WIDTH of U0 : label is 32;
  attribute C_M_APB_DATA_WIDTH : integer;
  attribute C_M_APB_DATA_WIDTH of U0 : label is 32;
  attribute C_M_APB_PROTOCOL : string;
  attribute C_M_APB_PROTOCOL of U0 : label is "apb3";
  attribute C_S_AXI_ADDR_WIDTH : integer;
  attribute C_S_AXI_ADDR_WIDTH of U0 : label is 32;
  attribute C_S_AXI_DATA_WIDTH : integer;
  attribute C_S_AXI_DATA_WIDTH of U0 : label is 32;
  attribute C_S_AXI_RNG10_BASEADDR : string;
  attribute C_S_AXI_RNG10_BASEADDR of U0 : label is "64'b0000000000000000000000000000000010010000000000000000000000000000";
  attribute C_S_AXI_RNG10_HIGHADDR : string;
  attribute C_S_AXI_RNG10_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000010011111111111111111111111111111";
  attribute C_S_AXI_RNG11_BASEADDR : string;
  attribute C_S_AXI_RNG11_BASEADDR of U0 : label is "64'b0000000000000000000000000000000010100000000000000000000000000000";
  attribute C_S_AXI_RNG11_HIGHADDR : string;
  attribute C_S_AXI_RNG11_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000010101111111111111111111111111111";
  attribute C_S_AXI_RNG12_BASEADDR : string;
  attribute C_S_AXI_RNG12_BASEADDR of U0 : label is "64'b0000000000000000000000000000000010110000000000000000000000000000";
  attribute C_S_AXI_RNG12_HIGHADDR : string;
  attribute C_S_AXI_RNG12_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000010111111111111111111111111111111";
  attribute C_S_AXI_RNG13_BASEADDR : string;
  attribute C_S_AXI_RNG13_BASEADDR of U0 : label is "64'b0000000000000000000000000000000011000000000000000000000000000000";
  attribute C_S_AXI_RNG13_HIGHADDR : string;
  attribute C_S_AXI_RNG13_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000011001111111111111111111111111111";
  attribute C_S_AXI_RNG14_BASEADDR : string;
  attribute C_S_AXI_RNG14_BASEADDR of U0 : label is "64'b0000000000000000000000000000000011010000000000000000000000000000";
  attribute C_S_AXI_RNG14_HIGHADDR : string;
  attribute C_S_AXI_RNG14_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000011011111111111111111111111111111";
  attribute C_S_AXI_RNG15_BASEADDR : string;
  attribute C_S_AXI_RNG15_BASEADDR of U0 : label is "64'b0000000000000000000000000000000011100000000000000000000000000000";
  attribute C_S_AXI_RNG15_HIGHADDR : string;
  attribute C_S_AXI_RNG15_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000011101111111111111111111111111111";
  attribute C_S_AXI_RNG16_BASEADDR : string;
  attribute C_S_AXI_RNG16_BASEADDR of U0 : label is "64'b0000000000000000000000000000000011110000000000000000000000000000";
  attribute C_S_AXI_RNG16_HIGHADDR : string;
  attribute C_S_AXI_RNG16_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000011111111111111111111111111111111";
  attribute C_S_AXI_RNG2_BASEADDR : string;
  attribute C_S_AXI_RNG2_BASEADDR of U0 : label is "64'b0000000000000000000000000000000000010000000000000000000000000000";
  attribute C_S_AXI_RNG2_HIGHADDR : string;
  attribute C_S_AXI_RNG2_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000000011111111111111111111111111111";
  attribute C_S_AXI_RNG3_BASEADDR : string;
  attribute C_S_AXI_RNG3_BASEADDR of U0 : label is "64'b0000000000000000000000000000000000100000000000000000000000000000";
  attribute C_S_AXI_RNG3_HIGHADDR : string;
  attribute C_S_AXI_RNG3_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000000101111111111111111111111111111";
  attribute C_S_AXI_RNG4_BASEADDR : string;
  attribute C_S_AXI_RNG4_BASEADDR of U0 : label is "64'b0000000000000000000000000000000000110000000000000000000000000000";
  attribute C_S_AXI_RNG4_HIGHADDR : string;
  attribute C_S_AXI_RNG4_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000000111111111111111111111111111111";
  attribute C_S_AXI_RNG5_BASEADDR : string;
  attribute C_S_AXI_RNG5_BASEADDR of U0 : label is "64'b0000000000000000000000000000000001000000000000000000000000000000";
  attribute C_S_AXI_RNG5_HIGHADDR : string;
  attribute C_S_AXI_RNG5_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000001001111111111111111111111111111";
  attribute C_S_AXI_RNG6_BASEADDR : string;
  attribute C_S_AXI_RNG6_BASEADDR of U0 : label is "64'b0000000000000000000000000000000001010000000000000000000000000000";
  attribute C_S_AXI_RNG6_HIGHADDR : string;
  attribute C_S_AXI_RNG6_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000001011111111111111111111111111111";
  attribute C_S_AXI_RNG7_BASEADDR : string;
  attribute C_S_AXI_RNG7_BASEADDR of U0 : label is "64'b0000000000000000000000000000000001100000000000000000000000000000";
  attribute C_S_AXI_RNG7_HIGHADDR : string;
  attribute C_S_AXI_RNG7_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000001101111111111111111111111111111";
  attribute C_S_AXI_RNG8_BASEADDR : string;
  attribute C_S_AXI_RNG8_BASEADDR of U0 : label is "64'b0000000000000000000000000000000001110000000000000000000000000000";
  attribute C_S_AXI_RNG8_HIGHADDR : string;
  attribute C_S_AXI_RNG8_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000001111111111111111111111111111111";
  attribute C_S_AXI_RNG9_BASEADDR : string;
  attribute C_S_AXI_RNG9_BASEADDR of U0 : label is "64'b0000000000000000000000000000000010000000000000000000000000000000";
  attribute C_S_AXI_RNG9_HIGHADDR : string;
  attribute C_S_AXI_RNG9_HIGHADDR of U0 : label is "64'b0000000000000000000000000000000010001111111111111111111111111111";
  attribute downgradeipidentifiedwarnings of U0 : label is "yes";
  attribute x_interface_info : string;
  attribute x_interface_info of m_apb_penable : signal is "xilinx.com:interface:apb:1.0 APB_M PENABLE";
  attribute x_interface_info of m_apb_pwrite : signal is "xilinx.com:interface:apb:1.0 APB_M PWRITE";
  attribute x_interface_info of s_axi_aclk : signal is "xilinx.com:signal:clock:1.0 ACLK CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of s_axi_aclk : signal is "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF AXI4_LITE:APB_M:APB_M2:APB_M3:APB_M4:APB_M5:APB_M6:APB_M7:APB_M8:APB_M9:APB_M10:APB_M11:APB_M12:APB_M13:APB_M14:APB_M15:APB_M16, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 166000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN crossbar_CLOCK, INSERT_VIP 0";
  attribute x_interface_info of s_axi_aresetn : signal is "xilinx.com:signal:reset:1.0 ARESETN RST";
  attribute x_interface_parameter of s_axi_aresetn : signal is "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute x_interface_info of s_axi_arready : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE ARREADY";
  attribute x_interface_info of s_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE ARVALID";
  attribute x_interface_info of s_axi_awready : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE AWREADY";
  attribute x_interface_info of s_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE AWVALID";
  attribute x_interface_info of s_axi_bready : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE BREADY";
  attribute x_interface_info of s_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE BVALID";
  attribute x_interface_info of s_axi_rready : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE RREADY";
  attribute x_interface_info of s_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE RVALID";
  attribute x_interface_info of s_axi_wready : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE WREADY";
  attribute x_interface_info of s_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE WVALID";
  attribute x_interface_info of m_apb_paddr : signal is "xilinx.com:interface:apb:1.0 APB_M PADDR";
  attribute x_interface_info of m_apb_prdata : signal is "xilinx.com:interface:apb:1.0 APB_M PRDATA";
  attribute x_interface_info of m_apb_pready : signal is "xilinx.com:interface:apb:1.0 APB_M PREADY";
  attribute x_interface_info of m_apb_psel : signal is "xilinx.com:interface:apb:1.0 APB_M PSEL";
  attribute x_interface_info of m_apb_pslverr : signal is "xilinx.com:interface:apb:1.0 APB_M PSLVERR";
  attribute x_interface_info of m_apb_pwdata : signal is "xilinx.com:interface:apb:1.0 APB_M PWDATA";
  attribute x_interface_info of s_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE ARADDR";
  attribute x_interface_info of s_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE AWADDR";
  attribute x_interface_parameter of s_axi_awaddr : signal is "XIL_INTERFACENAME AXI4_LITE, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 166000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 64, NUM_WRITE_OUTSTANDING 64, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN crossbar_CLOCK, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute x_interface_info of s_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE BRESP";
  attribute x_interface_info of s_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE RDATA";
  attribute x_interface_info of s_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE RRESP";
  attribute x_interface_info of s_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 AXI4_LITE WDATA";
begin
  s_axi_bresp(1) <= \^s_axi_bresp\(1);
  s_axi_bresp(0) <= \<const0>\;
  s_axi_rresp(1) <= \^s_axi_rresp\(1);
  s_axi_rresp(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
U0: entity work.crossbar_axi_apb_bridge_0_0_axi_apb_bridge
     port map (
      m_apb_paddr(31 downto 0) => m_apb_paddr(31 downto 0),
      m_apb_penable => m_apb_penable,
      m_apb_pprot(2 downto 0) => NLW_U0_m_apb_pprot_UNCONNECTED(2 downto 0),
      m_apb_prdata(31 downto 0) => m_apb_prdata(31 downto 0),
      m_apb_prdata10(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata11(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata12(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata13(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata14(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata15(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata16(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata2(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata3(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata4(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata5(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata6(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata7(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata8(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_prdata9(31 downto 0) => B"00000000000000000000000000000000",
      m_apb_pready(0) => m_apb_pready(0),
      m_apb_psel(0) => m_apb_psel(0),
      m_apb_pslverr(0) => m_apb_pslverr(0),
      m_apb_pstrb(3 downto 0) => NLW_U0_m_apb_pstrb_UNCONNECTED(3 downto 0),
      m_apb_pwdata(31 downto 0) => m_apb_pwdata(31 downto 0),
      m_apb_pwrite => m_apb_pwrite,
      s_axi_aclk => s_axi_aclk,
      s_axi_araddr(31 downto 0) => s_axi_araddr(31 downto 0),
      s_axi_aresetn => s_axi_aresetn,
      s_axi_arprot(2 downto 0) => B"000",
      s_axi_arready => s_axi_arready,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_awaddr(31 downto 0) => s_axi_awaddr(31 downto 0),
      s_axi_awprot(2 downto 0) => B"000",
      s_axi_awready => s_axi_awready,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_bready => s_axi_bready,
      s_axi_bresp(1) => \^s_axi_bresp\(1),
      s_axi_bresp(0) => NLW_U0_s_axi_bresp_UNCONNECTED(0),
      s_axi_bvalid => s_axi_bvalid,
      s_axi_rdata(31 downto 0) => s_axi_rdata(31 downto 0),
      s_axi_rready => s_axi_rready,
      s_axi_rresp(1) => \^s_axi_rresp\(1),
      s_axi_rresp(0) => NLW_U0_s_axi_rresp_UNCONNECTED(0),
      s_axi_rvalid => s_axi_rvalid,
      s_axi_wdata(31 downto 0) => s_axi_wdata(31 downto 0),
      s_axi_wready => s_axi_wready,
      s_axi_wstrb(3 downto 0) => B"0000",
      s_axi_wvalid => s_axi_wvalid
    );
end STRUCTURE;
