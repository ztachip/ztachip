// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Fri Jul 29 00:06:54 2022
// Host        : LAPTOP-RM6TVNC2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top crossbar_axi_apb_bridge_0_0 -prefix
//               crossbar_axi_apb_bridge_0_0_ crossbar_axi_apb_bridge_0_0_sim_netlist.v
// Design      : crossbar_axi_apb_bridge_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module crossbar_axi_apb_bridge_0_0_apb_mif
   (PENABLE_i_reg_0,
    m_apb_pwrite,
    RRESP_1_i,
    \FSM_onehot_apb_wr_rd_cs_reg[2]_0 ,
    PSEL_i,
    m_apb_paddr,
    m_apb_pwdata,
    \PWDATA_i_reg[0]_0 ,
    s_axi_aclk,
    PWRITE_i_reg_0,
    apb_wr_request,
    m_apb_pready,
    m_apb_pslverr,
    RRESP_1_i_reg,
    D,
    \PWDATA_i_reg[31]_0 );
  output PENABLE_i_reg_0;
  output m_apb_pwrite;
  output RRESP_1_i;
  output \FSM_onehot_apb_wr_rd_cs_reg[2]_0 ;
  output PSEL_i;
  output [31:0]m_apb_paddr;
  output [31:0]m_apb_pwdata;
  input \PWDATA_i_reg[0]_0 ;
  input s_axi_aclk;
  input PWRITE_i_reg_0;
  input apb_wr_request;
  input [0:0]m_apb_pready;
  input [0:0]m_apb_pslverr;
  input RRESP_1_i_reg;
  input [31:0]D;
  input [31:0]\PWDATA_i_reg[31]_0 ;

  wire [31:0]D;
  wire \FSM_onehot_apb_wr_rd_cs[0]_i_1_n_0 ;
  wire \FSM_onehot_apb_wr_rd_cs[1]_i_1_n_0 ;
  wire \FSM_onehot_apb_wr_rd_cs[2]_i_1_n_0 ;
  wire \FSM_onehot_apb_wr_rd_cs_reg[2]_0 ;
  wire \FSM_onehot_apb_wr_rd_cs_reg_n_0_[0] ;
  wire \FSM_onehot_apb_wr_rd_cs_reg_n_0_[1] ;
  wire PENABLE_i_reg_0;
  wire PSEL_i;
  wire \PWDATA_i[31]_i_1_n_0 ;
  wire \PWDATA_i_reg[0]_0 ;
  wire [31:0]\PWDATA_i_reg[31]_0 ;
  wire PWRITE_i_reg_0;
  wire RRESP_1_i;
  wire RRESP_1_i_reg;
  wire apb_penable_sm;
  wire apb_wr_request;
  wire [31:0]m_apb_paddr;
  wire [0:0]m_apb_pready;
  wire [0:0]m_apb_pslverr;
  wire [31:0]m_apb_pwdata;
  wire m_apb_pwrite;
  wire s_axi_aclk;

  LUT5 #(
    .INIT(32'hFF00FC44)) 
    \FSM_onehot_apb_wr_rd_cs[0]_i_1 
       (.I0(PWRITE_i_reg_0),
        .I1(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[0] ),
        .I2(m_apb_pready),
        .I3(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .I4(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[1] ),
        .O(\FSM_onehot_apb_wr_rd_cs[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hCCCCC888)) 
    \FSM_onehot_apb_wr_rd_cs[1]_i_1 
       (.I0(PWRITE_i_reg_0),
        .I1(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[0] ),
        .I2(m_apb_pready),
        .I3(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .I4(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[1] ),
        .O(\FSM_onehot_apb_wr_rd_cs[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hFFFF0700)) 
    \FSM_onehot_apb_wr_rd_cs[2]_i_1 
       (.I0(PWRITE_i_reg_0),
        .I1(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[0] ),
        .I2(m_apb_pready),
        .I3(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .I4(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[1] ),
        .O(\FSM_onehot_apb_wr_rd_cs[2]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "apb_idle:001,apb_setup:010,apb_access:100," *) 
  FDSE #(
    .INIT(1'b1)) 
    \FSM_onehot_apb_wr_rd_cs_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\FSM_onehot_apb_wr_rd_cs[0]_i_1_n_0 ),
        .Q(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[0] ),
        .S(\PWDATA_i_reg[0]_0 ));
  (* FSM_ENCODED_STATES = "apb_idle:001,apb_setup:010,apb_access:100," *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_apb_wr_rd_cs_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\FSM_onehot_apb_wr_rd_cs[1]_i_1_n_0 ),
        .Q(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[1] ),
        .R(\PWDATA_i_reg[0]_0 ));
  (* FSM_ENCODED_STATES = "apb_idle:001,apb_setup:010,apb_access:100," *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_apb_wr_rd_cs_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\FSM_onehot_apb_wr_rd_cs[2]_i_1_n_0 ),
        .Q(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .R(\PWDATA_i_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hFFF2F2F2)) 
    \GEN_1_SELECT_SLAVE.M_APB_PSEL_i[0]_i_1 
       (.I0(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .I1(m_apb_pready),
        .I2(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[1] ),
        .I3(PWRITE_i_reg_0),
        .I4(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[0] ),
        .O(PSEL_i));
  FDRE \PADDR_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[0]),
        .Q(m_apb_paddr[0]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[10] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[10]),
        .Q(m_apb_paddr[10]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[11] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[11]),
        .Q(m_apb_paddr[11]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[12] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[12]),
        .Q(m_apb_paddr[12]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[13] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[13]),
        .Q(m_apb_paddr[13]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[14] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[14]),
        .Q(m_apb_paddr[14]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[15] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[15]),
        .Q(m_apb_paddr[15]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[16] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[16]),
        .Q(m_apb_paddr[16]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[17] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[17]),
        .Q(m_apb_paddr[17]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[18] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[18]),
        .Q(m_apb_paddr[18]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[19] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[19]),
        .Q(m_apb_paddr[19]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[1]),
        .Q(m_apb_paddr[1]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[20] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[20]),
        .Q(m_apb_paddr[20]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[21] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[21]),
        .Q(m_apb_paddr[21]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[22] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[22]),
        .Q(m_apb_paddr[22]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[23] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[23]),
        .Q(m_apb_paddr[23]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[24] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[24]),
        .Q(m_apb_paddr[24]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[25] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[25]),
        .Q(m_apb_paddr[25]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[26] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[26]),
        .Q(m_apb_paddr[26]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[27] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[27]),
        .Q(m_apb_paddr[27]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[28] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[28]),
        .Q(m_apb_paddr[28]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[29] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[29]),
        .Q(m_apb_paddr[29]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[2]),
        .Q(m_apb_paddr[2]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[30] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[30]),
        .Q(m_apb_paddr[30]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[31] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[31]),
        .Q(m_apb_paddr[31]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[3] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[3]),
        .Q(m_apb_paddr[3]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[4] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[4]),
        .Q(m_apb_paddr[4]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[5] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[5]),
        .Q(m_apb_paddr[5]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[6] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[6]),
        .Q(m_apb_paddr[6]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[7] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[7]),
        .Q(m_apb_paddr[7]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[8] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[8]),
        .Q(m_apb_paddr[8]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PADDR_i_reg[9] 
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(D[9]),
        .Q(m_apb_paddr[9]),
        .R(\PWDATA_i_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hBA)) 
    PENABLE_i_i_1
       (.I0(\FSM_onehot_apb_wr_rd_cs_reg_n_0_[1] ),
        .I1(m_apb_pready),
        .I2(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .O(apb_penable_sm));
  FDRE PENABLE_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(apb_penable_sm),
        .Q(PENABLE_i_reg_0),
        .R(\PWDATA_i_reg[0]_0 ));
  LUT3 #(
    .INIT(8'hF8)) 
    \PWDATA_i[31]_i_1 
       (.I0(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .I1(m_apb_pready),
        .I2(apb_wr_request),
        .O(\PWDATA_i[31]_i_1_n_0 ));
  FDRE \PWDATA_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [0]),
        .Q(m_apb_pwdata[0]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[10] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [10]),
        .Q(m_apb_pwdata[10]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[11] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [11]),
        .Q(m_apb_pwdata[11]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[12] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [12]),
        .Q(m_apb_pwdata[12]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[13] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [13]),
        .Q(m_apb_pwdata[13]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[14] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [14]),
        .Q(m_apb_pwdata[14]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[15] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [15]),
        .Q(m_apb_pwdata[15]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[16] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [16]),
        .Q(m_apb_pwdata[16]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[17] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [17]),
        .Q(m_apb_pwdata[17]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[18] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [18]),
        .Q(m_apb_pwdata[18]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[19] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [19]),
        .Q(m_apb_pwdata[19]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [1]),
        .Q(m_apb_pwdata[1]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[20] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [20]),
        .Q(m_apb_pwdata[20]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[21] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [21]),
        .Q(m_apb_pwdata[21]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[22] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [22]),
        .Q(m_apb_pwdata[22]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[23] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [23]),
        .Q(m_apb_pwdata[23]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[24] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [24]),
        .Q(m_apb_pwdata[24]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[25] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [25]),
        .Q(m_apb_pwdata[25]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[26] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [26]),
        .Q(m_apb_pwdata[26]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[27] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [27]),
        .Q(m_apb_pwdata[27]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[28] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [28]),
        .Q(m_apb_pwdata[28]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[29] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [29]),
        .Q(m_apb_pwdata[29]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [2]),
        .Q(m_apb_pwdata[2]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[30] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [30]),
        .Q(m_apb_pwdata[30]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[31] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [31]),
        .Q(m_apb_pwdata[31]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[3] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [3]),
        .Q(m_apb_pwdata[3]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[4] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [4]),
        .Q(m_apb_pwdata[4]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[5] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [5]),
        .Q(m_apb_pwdata[5]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[6] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [6]),
        .Q(m_apb_pwdata[6]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[7] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [7]),
        .Q(m_apb_pwdata[7]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[8] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [8]),
        .Q(m_apb_pwdata[8]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE \PWDATA_i_reg[9] 
       (.C(s_axi_aclk),
        .CE(\PWDATA_i[31]_i_1_n_0 ),
        .D(\PWDATA_i_reg[31]_0 [9]),
        .Q(m_apb_pwdata[9]),
        .R(\PWDATA_i_reg[0]_0 ));
  FDRE PWRITE_i_reg
       (.C(s_axi_aclk),
        .CE(PWRITE_i_reg_0),
        .D(apb_wr_request),
        .Q(m_apb_pwrite),
        .R(\PWDATA_i_reg[0]_0 ));
  LUT4 #(
    .INIT(16'h8000)) 
    RRESP_1_i_i_1
       (.I0(m_apb_pready),
        .I1(\FSM_onehot_apb_wr_rd_cs_reg[2]_0 ),
        .I2(m_apb_pslverr),
        .I3(RRESP_1_i_reg),
        .O(RRESP_1_i));
endmodule

(* C_APB_NUM_SLAVES = "1" *) (* C_BASEADDR = "64'b0000000000000000000000000000000011110100000000000000000000000000" *) (* C_DPHASE_TIMEOUT = "0" *) 
(* C_FAMILY = "artix7" *) (* C_HIGHADDR = "64'b0000000000000000000000000000000011110100000000001111111111111111" *) (* C_INSTANCE = "axi_apb_bridge_inst" *) 
(* C_M_APB_ADDR_WIDTH = "32" *) (* C_M_APB_DATA_WIDTH = "32" *) (* C_M_APB_PROTOCOL = "apb3" *) 
(* C_S_AXI_ADDR_WIDTH = "32" *) (* C_S_AXI_DATA_WIDTH = "32" *) (* C_S_AXI_RNG10_BASEADDR = "64'b0000000000000000000000000000000010010000000000000000000000000000" *) 
(* C_S_AXI_RNG10_HIGHADDR = "64'b0000000000000000000000000000000010011111111111111111111111111111" *) (* C_S_AXI_RNG11_BASEADDR = "64'b0000000000000000000000000000000010100000000000000000000000000000" *) (* C_S_AXI_RNG11_HIGHADDR = "64'b0000000000000000000000000000000010101111111111111111111111111111" *) 
(* C_S_AXI_RNG12_BASEADDR = "64'b0000000000000000000000000000000010110000000000000000000000000000" *) (* C_S_AXI_RNG12_HIGHADDR = "64'b0000000000000000000000000000000010111111111111111111111111111111" *) (* C_S_AXI_RNG13_BASEADDR = "64'b0000000000000000000000000000000011000000000000000000000000000000" *) 
(* C_S_AXI_RNG13_HIGHADDR = "64'b0000000000000000000000000000000011001111111111111111111111111111" *) (* C_S_AXI_RNG14_BASEADDR = "64'b0000000000000000000000000000000011010000000000000000000000000000" *) (* C_S_AXI_RNG14_HIGHADDR = "64'b0000000000000000000000000000000011011111111111111111111111111111" *) 
(* C_S_AXI_RNG15_BASEADDR = "64'b0000000000000000000000000000000011100000000000000000000000000000" *) (* C_S_AXI_RNG15_HIGHADDR = "64'b0000000000000000000000000000000011101111111111111111111111111111" *) (* C_S_AXI_RNG16_BASEADDR = "64'b0000000000000000000000000000000011110000000000000000000000000000" *) 
(* C_S_AXI_RNG16_HIGHADDR = "64'b0000000000000000000000000000000011111111111111111111111111111111" *) (* C_S_AXI_RNG2_BASEADDR = "64'b0000000000000000000000000000000000010000000000000000000000000000" *) (* C_S_AXI_RNG2_HIGHADDR = "64'b0000000000000000000000000000000000011111111111111111111111111111" *) 
(* C_S_AXI_RNG3_BASEADDR = "64'b0000000000000000000000000000000000100000000000000000000000000000" *) (* C_S_AXI_RNG3_HIGHADDR = "64'b0000000000000000000000000000000000101111111111111111111111111111" *) (* C_S_AXI_RNG4_BASEADDR = "64'b0000000000000000000000000000000000110000000000000000000000000000" *) 
(* C_S_AXI_RNG4_HIGHADDR = "64'b0000000000000000000000000000000000111111111111111111111111111111" *) (* C_S_AXI_RNG5_BASEADDR = "64'b0000000000000000000000000000000001000000000000000000000000000000" *) (* C_S_AXI_RNG5_HIGHADDR = "64'b0000000000000000000000000000000001001111111111111111111111111111" *) 
(* C_S_AXI_RNG6_BASEADDR = "64'b0000000000000000000000000000000001010000000000000000000000000000" *) (* C_S_AXI_RNG6_HIGHADDR = "64'b0000000000000000000000000000000001011111111111111111111111111111" *) (* C_S_AXI_RNG7_BASEADDR = "64'b0000000000000000000000000000000001100000000000000000000000000000" *) 
(* C_S_AXI_RNG7_HIGHADDR = "64'b0000000000000000000000000000000001101111111111111111111111111111" *) (* C_S_AXI_RNG8_BASEADDR = "64'b0000000000000000000000000000000001110000000000000000000000000000" *) (* C_S_AXI_RNG8_HIGHADDR = "64'b0000000000000000000000000000000001111111111111111111111111111111" *) 
(* C_S_AXI_RNG9_BASEADDR = "64'b0000000000000000000000000000000010000000000000000000000000000000" *) (* C_S_AXI_RNG9_HIGHADDR = "64'b0000000000000000000000000000000010001111111111111111111111111111" *) (* downgradeipidentifiedwarnings = "yes" *) 
module crossbar_axi_apb_bridge_0_0_axi_apb_bridge
   (s_axi_aclk,
    s_axi_aresetn,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_araddr,
    s_axi_arprot,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_rready,
    m_apb_paddr,
    m_apb_psel,
    m_apb_penable,
    m_apb_pwrite,
    m_apb_pwdata,
    m_apb_pready,
    m_apb_prdata,
    m_apb_prdata2,
    m_apb_prdata3,
    m_apb_prdata4,
    m_apb_prdata5,
    m_apb_prdata6,
    m_apb_prdata7,
    m_apb_prdata8,
    m_apb_prdata9,
    m_apb_prdata10,
    m_apb_prdata11,
    m_apb_prdata12,
    m_apb_prdata13,
    m_apb_prdata14,
    m_apb_prdata15,
    m_apb_prdata16,
    m_apb_pslverr,
    m_apb_pprot,
    m_apb_pstrb);
  input s_axi_aclk;
  input s_axi_aresetn;
  input [31:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  input s_axi_awvalid;
  output s_axi_awready;
  input [31:0]s_axi_wdata;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;
  output s_axi_wready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_bready;
  input [31:0]s_axi_araddr;
  input [2:0]s_axi_arprot;
  input s_axi_arvalid;
  output s_axi_arready;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input s_axi_rready;
  output [31:0]m_apb_paddr;
  output [0:0]m_apb_psel;
  output m_apb_penable;
  output m_apb_pwrite;
  output [31:0]m_apb_pwdata;
  input [0:0]m_apb_pready;
  input [31:0]m_apb_prdata;
  input [31:0]m_apb_prdata2;
  input [31:0]m_apb_prdata3;
  input [31:0]m_apb_prdata4;
  input [31:0]m_apb_prdata5;
  input [31:0]m_apb_prdata6;
  input [31:0]m_apb_prdata7;
  input [31:0]m_apb_prdata8;
  input [31:0]m_apb_prdata9;
  input [31:0]m_apb_prdata10;
  input [31:0]m_apb_prdata11;
  input [31:0]m_apb_prdata12;
  input [31:0]m_apb_prdata13;
  input [31:0]m_apb_prdata14;
  input [31:0]m_apb_prdata15;
  input [31:0]m_apb_prdata16;
  input [0:0]m_apb_pslverr;
  output [2:0]m_apb_pprot;
  output [3:0]m_apb_pstrb;

  wire \<const0> ;
  wire APB_MASTER_IF_MODULE_n_3;
  wire AXILITE_SLAVE_IF_MODULE_n_1;
  wire AXILITE_SLAVE_IF_MODULE_n_10;
  wire AXILITE_SLAVE_IF_MODULE_n_11;
  wire AXILITE_SLAVE_IF_MODULE_n_12;
  wire AXILITE_SLAVE_IF_MODULE_n_13;
  wire AXILITE_SLAVE_IF_MODULE_n_14;
  wire AXILITE_SLAVE_IF_MODULE_n_15;
  wire AXILITE_SLAVE_IF_MODULE_n_16;
  wire AXILITE_SLAVE_IF_MODULE_n_17;
  wire AXILITE_SLAVE_IF_MODULE_n_18;
  wire AXILITE_SLAVE_IF_MODULE_n_19;
  wire AXILITE_SLAVE_IF_MODULE_n_20;
  wire AXILITE_SLAVE_IF_MODULE_n_21;
  wire AXILITE_SLAVE_IF_MODULE_n_22;
  wire AXILITE_SLAVE_IF_MODULE_n_23;
  wire AXILITE_SLAVE_IF_MODULE_n_24;
  wire AXILITE_SLAVE_IF_MODULE_n_25;
  wire AXILITE_SLAVE_IF_MODULE_n_26;
  wire AXILITE_SLAVE_IF_MODULE_n_27;
  wire AXILITE_SLAVE_IF_MODULE_n_28;
  wire AXILITE_SLAVE_IF_MODULE_n_29;
  wire AXILITE_SLAVE_IF_MODULE_n_30;
  wire AXILITE_SLAVE_IF_MODULE_n_31;
  wire AXILITE_SLAVE_IF_MODULE_n_32;
  wire AXILITE_SLAVE_IF_MODULE_n_33;
  wire AXILITE_SLAVE_IF_MODULE_n_34;
  wire AXILITE_SLAVE_IF_MODULE_n_35;
  wire AXILITE_SLAVE_IF_MODULE_n_36;
  wire AXILITE_SLAVE_IF_MODULE_n_37;
  wire AXILITE_SLAVE_IF_MODULE_n_38;
  wire AXILITE_SLAVE_IF_MODULE_n_39;
  wire AXILITE_SLAVE_IF_MODULE_n_40;
  wire AXILITE_SLAVE_IF_MODULE_n_41;
  wire AXILITE_SLAVE_IF_MODULE_n_42;
  wire AXILITE_SLAVE_IF_MODULE_n_43;
  wire AXILITE_SLAVE_IF_MODULE_n_44;
  wire AXILITE_SLAVE_IF_MODULE_n_45;
  wire AXILITE_SLAVE_IF_MODULE_n_46;
  wire AXILITE_SLAVE_IF_MODULE_n_47;
  wire AXILITE_SLAVE_IF_MODULE_n_48;
  wire AXILITE_SLAVE_IF_MODULE_n_49;
  wire AXILITE_SLAVE_IF_MODULE_n_50;
  wire AXILITE_SLAVE_IF_MODULE_n_51;
  wire AXILITE_SLAVE_IF_MODULE_n_52;
  wire AXILITE_SLAVE_IF_MODULE_n_53;
  wire AXILITE_SLAVE_IF_MODULE_n_54;
  wire AXILITE_SLAVE_IF_MODULE_n_55;
  wire AXILITE_SLAVE_IF_MODULE_n_56;
  wire AXILITE_SLAVE_IF_MODULE_n_57;
  wire AXILITE_SLAVE_IF_MODULE_n_58;
  wire AXILITE_SLAVE_IF_MODULE_n_59;
  wire AXILITE_SLAVE_IF_MODULE_n_60;
  wire AXILITE_SLAVE_IF_MODULE_n_61;
  wire AXILITE_SLAVE_IF_MODULE_n_62;
  wire AXILITE_SLAVE_IF_MODULE_n_63;
  wire AXILITE_SLAVE_IF_MODULE_n_64;
  wire AXILITE_SLAVE_IF_MODULE_n_65;
  wire AXILITE_SLAVE_IF_MODULE_n_66;
  wire AXILITE_SLAVE_IF_MODULE_n_67;
  wire AXILITE_SLAVE_IF_MODULE_n_68;
  wire AXILITE_SLAVE_IF_MODULE_n_69;
  wire AXILITE_SLAVE_IF_MODULE_n_70;
  wire AXILITE_SLAVE_IF_MODULE_n_71;
  wire AXILITE_SLAVE_IF_MODULE_n_72;
  wire AXILITE_SLAVE_IF_MODULE_n_73;
  wire AXILITE_SLAVE_IF_MODULE_n_74;
  wire AXILITE_SLAVE_IF_MODULE_n_9;
  wire PSEL_i;
  wire RRESP_1_i;
  wire apb_wr_request;
  wire [31:0]m_apb_paddr;
  wire m_apb_penable;
  wire [31:0]m_apb_prdata;
  wire [0:0]m_apb_pready;
  wire [0:0]m_apb_psel;
  wire [0:0]m_apb_pslverr;
  wire [31:0]m_apb_pwdata;
  wire m_apb_pwrite;
  wire s_axi_aclk;
  wire [31:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [31:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire [1:1]\^s_axi_bresp ;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire s_axi_rready;
  wire [1:1]\^s_axi_rresp ;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready;
  wire s_axi_wvalid;

  assign m_apb_pprot[2] = \<const0> ;
  assign m_apb_pprot[1] = \<const0> ;
  assign m_apb_pprot[0] = \<const0> ;
  assign m_apb_pstrb[3] = \<const0> ;
  assign m_apb_pstrb[2] = \<const0> ;
  assign m_apb_pstrb[1] = \<const0> ;
  assign m_apb_pstrb[0] = \<const0> ;
  assign s_axi_bresp[1] = \^s_axi_bresp [1];
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_rresp[1] = \^s_axi_rresp [1];
  assign s_axi_rresp[0] = \<const0> ;
  crossbar_axi_apb_bridge_0_0_apb_mif APB_MASTER_IF_MODULE
       (.D({AXILITE_SLAVE_IF_MODULE_n_10,AXILITE_SLAVE_IF_MODULE_n_11,AXILITE_SLAVE_IF_MODULE_n_12,AXILITE_SLAVE_IF_MODULE_n_13,AXILITE_SLAVE_IF_MODULE_n_14,AXILITE_SLAVE_IF_MODULE_n_15,AXILITE_SLAVE_IF_MODULE_n_16,AXILITE_SLAVE_IF_MODULE_n_17,AXILITE_SLAVE_IF_MODULE_n_18,AXILITE_SLAVE_IF_MODULE_n_19,AXILITE_SLAVE_IF_MODULE_n_20,AXILITE_SLAVE_IF_MODULE_n_21,AXILITE_SLAVE_IF_MODULE_n_22,AXILITE_SLAVE_IF_MODULE_n_23,AXILITE_SLAVE_IF_MODULE_n_24,AXILITE_SLAVE_IF_MODULE_n_25,AXILITE_SLAVE_IF_MODULE_n_26,AXILITE_SLAVE_IF_MODULE_n_27,AXILITE_SLAVE_IF_MODULE_n_28,AXILITE_SLAVE_IF_MODULE_n_29,AXILITE_SLAVE_IF_MODULE_n_30,AXILITE_SLAVE_IF_MODULE_n_31,AXILITE_SLAVE_IF_MODULE_n_32,AXILITE_SLAVE_IF_MODULE_n_33,AXILITE_SLAVE_IF_MODULE_n_34,AXILITE_SLAVE_IF_MODULE_n_35,AXILITE_SLAVE_IF_MODULE_n_36,AXILITE_SLAVE_IF_MODULE_n_37,AXILITE_SLAVE_IF_MODULE_n_38,AXILITE_SLAVE_IF_MODULE_n_39,AXILITE_SLAVE_IF_MODULE_n_40,AXILITE_SLAVE_IF_MODULE_n_41}),
        .\FSM_onehot_apb_wr_rd_cs_reg[2]_0 (APB_MASTER_IF_MODULE_n_3),
        .PENABLE_i_reg_0(m_apb_penable),
        .PSEL_i(PSEL_i),
        .\PWDATA_i_reg[0]_0 (AXILITE_SLAVE_IF_MODULE_n_1),
        .\PWDATA_i_reg[31]_0 ({AXILITE_SLAVE_IF_MODULE_n_42,AXILITE_SLAVE_IF_MODULE_n_43,AXILITE_SLAVE_IF_MODULE_n_44,AXILITE_SLAVE_IF_MODULE_n_45,AXILITE_SLAVE_IF_MODULE_n_46,AXILITE_SLAVE_IF_MODULE_n_47,AXILITE_SLAVE_IF_MODULE_n_48,AXILITE_SLAVE_IF_MODULE_n_49,AXILITE_SLAVE_IF_MODULE_n_50,AXILITE_SLAVE_IF_MODULE_n_51,AXILITE_SLAVE_IF_MODULE_n_52,AXILITE_SLAVE_IF_MODULE_n_53,AXILITE_SLAVE_IF_MODULE_n_54,AXILITE_SLAVE_IF_MODULE_n_55,AXILITE_SLAVE_IF_MODULE_n_56,AXILITE_SLAVE_IF_MODULE_n_57,AXILITE_SLAVE_IF_MODULE_n_58,AXILITE_SLAVE_IF_MODULE_n_59,AXILITE_SLAVE_IF_MODULE_n_60,AXILITE_SLAVE_IF_MODULE_n_61,AXILITE_SLAVE_IF_MODULE_n_62,AXILITE_SLAVE_IF_MODULE_n_63,AXILITE_SLAVE_IF_MODULE_n_64,AXILITE_SLAVE_IF_MODULE_n_65,AXILITE_SLAVE_IF_MODULE_n_66,AXILITE_SLAVE_IF_MODULE_n_67,AXILITE_SLAVE_IF_MODULE_n_68,AXILITE_SLAVE_IF_MODULE_n_69,AXILITE_SLAVE_IF_MODULE_n_70,AXILITE_SLAVE_IF_MODULE_n_71,AXILITE_SLAVE_IF_MODULE_n_72,AXILITE_SLAVE_IF_MODULE_n_73}),
        .PWRITE_i_reg_0(AXILITE_SLAVE_IF_MODULE_n_74),
        .RRESP_1_i(RRESP_1_i),
        .RRESP_1_i_reg(AXILITE_SLAVE_IF_MODULE_n_9),
        .apb_wr_request(apb_wr_request),
        .m_apb_paddr(m_apb_paddr),
        .m_apb_pready(m_apb_pready),
        .m_apb_pslverr(m_apb_pslverr),
        .m_apb_pwdata(m_apb_pwdata),
        .m_apb_pwrite(m_apb_pwrite),
        .s_axi_aclk(s_axi_aclk));
  crossbar_axi_apb_bridge_0_0_axilite_sif AXILITE_SLAVE_IF_MODULE
       (.BRESP_1_i_reg_0(APB_MASTER_IF_MODULE_n_3),
        .D({AXILITE_SLAVE_IF_MODULE_n_10,AXILITE_SLAVE_IF_MODULE_n_11,AXILITE_SLAVE_IF_MODULE_n_12,AXILITE_SLAVE_IF_MODULE_n_13,AXILITE_SLAVE_IF_MODULE_n_14,AXILITE_SLAVE_IF_MODULE_n_15,AXILITE_SLAVE_IF_MODULE_n_16,AXILITE_SLAVE_IF_MODULE_n_17,AXILITE_SLAVE_IF_MODULE_n_18,AXILITE_SLAVE_IF_MODULE_n_19,AXILITE_SLAVE_IF_MODULE_n_20,AXILITE_SLAVE_IF_MODULE_n_21,AXILITE_SLAVE_IF_MODULE_n_22,AXILITE_SLAVE_IF_MODULE_n_23,AXILITE_SLAVE_IF_MODULE_n_24,AXILITE_SLAVE_IF_MODULE_n_25,AXILITE_SLAVE_IF_MODULE_n_26,AXILITE_SLAVE_IF_MODULE_n_27,AXILITE_SLAVE_IF_MODULE_n_28,AXILITE_SLAVE_IF_MODULE_n_29,AXILITE_SLAVE_IF_MODULE_n_30,AXILITE_SLAVE_IF_MODULE_n_31,AXILITE_SLAVE_IF_MODULE_n_32,AXILITE_SLAVE_IF_MODULE_n_33,AXILITE_SLAVE_IF_MODULE_n_34,AXILITE_SLAVE_IF_MODULE_n_35,AXILITE_SLAVE_IF_MODULE_n_36,AXILITE_SLAVE_IF_MODULE_n_37,AXILITE_SLAVE_IF_MODULE_n_38,AXILITE_SLAVE_IF_MODULE_n_39,AXILITE_SLAVE_IF_MODULE_n_40,AXILITE_SLAVE_IF_MODULE_n_41}),
        .\FSM_sequential_axi_wr_rd_cs_reg[0]_0 (AXILITE_SLAVE_IF_MODULE_n_74),
        .\FSM_sequential_axi_wr_rd_cs_reg[1]_0 (m_apb_penable),
        .PENABLE_i_reg(AXILITE_SLAVE_IF_MODULE_n_9),
        .RRESP_1_i(RRESP_1_i),
        .apb_wr_request(apb_wr_request),
        .m_apb_prdata(m_apb_prdata),
        .m_apb_pready(m_apb_pready),
        .m_apb_pslverr(m_apb_pslverr),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_aresetn_0(AXILITE_SLAVE_IF_MODULE_n_1),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(\^s_axi_bresp ),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(\^s_axi_rresp ),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .\s_axi_wdata[31] ({AXILITE_SLAVE_IF_MODULE_n_42,AXILITE_SLAVE_IF_MODULE_n_43,AXILITE_SLAVE_IF_MODULE_n_44,AXILITE_SLAVE_IF_MODULE_n_45,AXILITE_SLAVE_IF_MODULE_n_46,AXILITE_SLAVE_IF_MODULE_n_47,AXILITE_SLAVE_IF_MODULE_n_48,AXILITE_SLAVE_IF_MODULE_n_49,AXILITE_SLAVE_IF_MODULE_n_50,AXILITE_SLAVE_IF_MODULE_n_51,AXILITE_SLAVE_IF_MODULE_n_52,AXILITE_SLAVE_IF_MODULE_n_53,AXILITE_SLAVE_IF_MODULE_n_54,AXILITE_SLAVE_IF_MODULE_n_55,AXILITE_SLAVE_IF_MODULE_n_56,AXILITE_SLAVE_IF_MODULE_n_57,AXILITE_SLAVE_IF_MODULE_n_58,AXILITE_SLAVE_IF_MODULE_n_59,AXILITE_SLAVE_IF_MODULE_n_60,AXILITE_SLAVE_IF_MODULE_n_61,AXILITE_SLAVE_IF_MODULE_n_62,AXILITE_SLAVE_IF_MODULE_n_63,AXILITE_SLAVE_IF_MODULE_n_64,AXILITE_SLAVE_IF_MODULE_n_65,AXILITE_SLAVE_IF_MODULE_n_66,AXILITE_SLAVE_IF_MODULE_n_67,AXILITE_SLAVE_IF_MODULE_n_68,AXILITE_SLAVE_IF_MODULE_n_69,AXILITE_SLAVE_IF_MODULE_n_70,AXILITE_SLAVE_IF_MODULE_n_71,AXILITE_SLAVE_IF_MODULE_n_72,AXILITE_SLAVE_IF_MODULE_n_73}),
        .s_axi_wready(s_axi_wready),
        .s_axi_wvalid(s_axi_wvalid));
  GND GND
       (.G(\<const0> ));
  crossbar_axi_apb_bridge_0_0_multiplexor MULTIPLEXOR_MODULE
       (.\GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0 (AXILITE_SLAVE_IF_MODULE_n_1),
        .PSEL_i(PSEL_i),
        .m_apb_psel(m_apb_psel),
        .s_axi_aclk(s_axi_aclk));
endmodule

module crossbar_axi_apb_bridge_0_0_axilite_sif
   (s_axi_awready,
    s_axi_aresetn_0,
    s_axi_wready,
    apb_wr_request,
    s_axi_bvalid,
    s_axi_arready,
    s_axi_rvalid,
    s_axi_rresp,
    s_axi_bresp,
    PENABLE_i_reg,
    D,
    \s_axi_wdata[31] ,
    \FSM_sequential_axi_wr_rd_cs_reg[0]_0 ,
    s_axi_rdata,
    s_axi_aclk,
    RRESP_1_i,
    \FSM_sequential_axi_wr_rd_cs_reg[1]_0 ,
    m_apb_pready,
    s_axi_rready,
    s_axi_bready,
    s_axi_arvalid,
    s_axi_awvalid,
    s_axi_wvalid,
    BRESP_1_i_reg_0,
    m_apb_prdata,
    s_axi_awaddr,
    s_axi_araddr,
    s_axi_wdata,
    s_axi_aresetn,
    m_apb_pslverr);
  output s_axi_awready;
  output s_axi_aresetn_0;
  output s_axi_wready;
  output apb_wr_request;
  output s_axi_bvalid;
  output s_axi_arready;
  output s_axi_rvalid;
  output [0:0]s_axi_rresp;
  output [0:0]s_axi_bresp;
  output PENABLE_i_reg;
  output [31:0]D;
  output [31:0]\s_axi_wdata[31] ;
  output \FSM_sequential_axi_wr_rd_cs_reg[0]_0 ;
  output [31:0]s_axi_rdata;
  input s_axi_aclk;
  input RRESP_1_i;
  input \FSM_sequential_axi_wr_rd_cs_reg[1]_0 ;
  input [0:0]m_apb_pready;
  input s_axi_rready;
  input s_axi_bready;
  input s_axi_arvalid;
  input s_axi_awvalid;
  input s_axi_wvalid;
  input BRESP_1_i_reg_0;
  input [31:0]m_apb_prdata;
  input [31:0]s_axi_awaddr;
  input [31:0]s_axi_araddr;
  input [31:0]s_axi_wdata;
  input s_axi_aresetn;
  input [0:0]m_apb_pslverr;

  wire BRESP_1_i_i_1_n_0;
  wire BRESP_1_i_i_2_n_0;
  wire BRESP_1_i_reg_0;
  wire BVALID_sm;
  wire [31:0]D;
  wire \FSM_sequential_axi_wr_rd_cs[0]_i_1_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[0]_i_2_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[0]_i_3_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[1]_i_1_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[2]_i_1_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[2]_i_3_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[2]_i_4_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0 ;
  wire \FSM_sequential_axi_wr_rd_cs_reg[0]_0 ;
  wire \FSM_sequential_axi_wr_rd_cs_reg[1]_0 ;
  wire \PADDR_i[31]_i_3_n_0 ;
  wire \PADDR_i[31]_i_4_n_0 ;
  wire PENABLE_i_reg;
  wire RRESP_1_i;
  wire RVALID_sm;
  wire \S_AXI_RDATA[31]_i_1_n_0 ;
  wire WREADY_i_i_2_n_0;
  wire [31:0]address_i;
  wire \address_i[0]_i_1_n_0 ;
  wire \address_i[10]_i_1_n_0 ;
  wire \address_i[11]_i_1_n_0 ;
  wire \address_i[12]_i_1_n_0 ;
  wire \address_i[13]_i_1_n_0 ;
  wire \address_i[14]_i_1_n_0 ;
  wire \address_i[15]_i_1_n_0 ;
  wire \address_i[16]_i_1_n_0 ;
  wire \address_i[17]_i_1_n_0 ;
  wire \address_i[18]_i_1_n_0 ;
  wire \address_i[19]_i_1_n_0 ;
  wire \address_i[1]_i_1_n_0 ;
  wire \address_i[20]_i_1_n_0 ;
  wire \address_i[21]_i_1_n_0 ;
  wire \address_i[22]_i_1_n_0 ;
  wire \address_i[23]_i_1_n_0 ;
  wire \address_i[24]_i_1_n_0 ;
  wire \address_i[25]_i_1_n_0 ;
  wire \address_i[26]_i_1_n_0 ;
  wire \address_i[27]_i_1_n_0 ;
  wire \address_i[28]_i_1_n_0 ;
  wire \address_i[29]_i_1_n_0 ;
  wire \address_i[2]_i_1_n_0 ;
  wire \address_i[30]_i_1_n_0 ;
  wire \address_i[31]_i_1_n_0 ;
  wire \address_i[31]_i_2_n_0 ;
  wire \address_i[3]_i_1_n_0 ;
  wire \address_i[4]_i_1_n_0 ;
  wire \address_i[5]_i_1_n_0 ;
  wire \address_i[6]_i_1_n_0 ;
  wire \address_i[7]_i_1_n_0 ;
  wire \address_i[8]_i_1_n_0 ;
  wire \address_i[9]_i_1_n_0 ;
  wire apb_rd_request;
  wire apb_wr_request;
  wire [2:0]axi_wr_rd_cs;
  wire [31:0]m_apb_prdata;
  wire [0:0]m_apb_pready;
  wire [0:0]m_apb_pslverr;
  wire [31:0]p_2_in;
  wire s_axi_aclk;
  wire [31:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire s_axi_aresetn_0;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [31:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire [0:0]s_axi_bresp;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire s_axi_rready;
  wire [0:0]s_axi_rresp;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire [31:0]\s_axi_wdata[31] ;
  wire s_axi_wready;
  wire s_axi_wvalid;
  wire waddr_ready_sm;

  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    ARREADY_i_i_1
       (.I0(axi_wr_rd_cs[1]),
        .I1(s_axi_arvalid),
        .I2(axi_wr_rd_cs[2]),
        .I3(axi_wr_rd_cs[0]),
        .O(apb_rd_request));
  FDRE ARREADY_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(apb_rd_request),
        .Q(s_axi_arready),
        .R(s_axi_aresetn_0));
  LUT1 #(
    .INIT(2'h1)) 
    AWREADY_i_i_1
       (.I0(s_axi_aresetn),
        .O(s_axi_aresetn_0));
  LUT6 #(
    .INIT(64'h0000880200000002)) 
    AWREADY_i_i_2
       (.I0(s_axi_awvalid),
        .I1(axi_wr_rd_cs[1]),
        .I2(s_axi_arvalid),
        .I3(axi_wr_rd_cs[0]),
        .I4(axi_wr_rd_cs[2]),
        .I5(s_axi_rready),
        .O(waddr_ready_sm));
  FDRE AWREADY_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(waddr_ready_sm),
        .Q(s_axi_awready),
        .R(s_axi_aresetn_0));
  LUT6 #(
    .INIT(64'h808000FF80800000)) 
    BRESP_1_i_i_1
       (.I0(m_apb_pready),
        .I1(BRESP_1_i_reg_0),
        .I2(m_apb_pslverr),
        .I3(s_axi_bready),
        .I4(BRESP_1_i_i_2_n_0),
        .I5(s_axi_bresp),
        .O(BRESP_1_i_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT5 #(
    .INIT(32'h20000000)) 
    BRESP_1_i_i_2
       (.I0(axi_wr_rd_cs[2]),
        .I1(axi_wr_rd_cs[0]),
        .I2(axi_wr_rd_cs[1]),
        .I3(m_apb_pready),
        .I4(\FSM_sequential_axi_wr_rd_cs_reg[1]_0 ),
        .O(BRESP_1_i_i_2_n_0));
  FDRE BRESP_1_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(BRESP_1_i_i_1_n_0),
        .Q(s_axi_bresp),
        .R(s_axi_aresetn_0));
  LUT6 #(
    .INIT(64'h0F88000000000000)) 
    BVALID_i_i_1
       (.I0(\FSM_sequential_axi_wr_rd_cs_reg[1]_0 ),
        .I1(m_apb_pready),
        .I2(s_axi_bready),
        .I3(axi_wr_rd_cs[0]),
        .I4(axi_wr_rd_cs[1]),
        .I5(axi_wr_rd_cs[2]),
        .O(BVALID_sm));
  FDRE BVALID_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(BVALID_sm),
        .Q(s_axi_bvalid),
        .R(s_axi_aresetn_0));
  LUT6 #(
    .INIT(64'h0022FFFF0F0F0000)) 
    \FSM_sequential_axi_wr_rd_cs[0]_i_1 
       (.I0(s_axi_awvalid),
        .I1(\FSM_sequential_axi_wr_rd_cs[0]_i_2_n_0 ),
        .I2(\FSM_sequential_axi_wr_rd_cs[0]_i_3_n_0 ),
        .I3(s_axi_wvalid),
        .I4(\FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0 ),
        .I5(axi_wr_rd_cs[0]),
        .O(\FSM_sequential_axi_wr_rd_cs[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \FSM_sequential_axi_wr_rd_cs[0]_i_2 
       (.I0(axi_wr_rd_cs[2]),
        .I1(axi_wr_rd_cs[1]),
        .O(\FSM_sequential_axi_wr_rd_cs[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000FFFF40)) 
    \FSM_sequential_axi_wr_rd_cs[0]_i_3 
       (.I0(s_axi_arvalid),
        .I1(s_axi_awvalid),
        .I2(s_axi_wvalid),
        .I3(axi_wr_rd_cs[1]),
        .I4(axi_wr_rd_cs[2]),
        .I5(\FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0 ),
        .O(\FSM_sequential_axi_wr_rd_cs[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h3222FFFFEEEE0000)) 
    \FSM_sequential_axi_wr_rd_cs[1]_i_1 
       (.I0(axi_wr_rd_cs[2]),
        .I1(axi_wr_rd_cs[0]),
        .I2(m_apb_pready),
        .I3(\FSM_sequential_axi_wr_rd_cs_reg[1]_0 ),
        .I4(\FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0 ),
        .I5(axi_wr_rd_cs[1]),
        .O(\FSM_sequential_axi_wr_rd_cs[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7777FFFF89010000)) 
    \FSM_sequential_axi_wr_rd_cs[2]_i_1 
       (.I0(axi_wr_rd_cs[0]),
        .I1(axi_wr_rd_cs[1]),
        .I2(s_axi_arvalid),
        .I3(s_axi_awvalid),
        .I4(\FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0 ),
        .I5(axi_wr_rd_cs[2]),
        .O(\FSM_sequential_axi_wr_rd_cs[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAFAFFFFFAAAAFFFE)) 
    \FSM_sequential_axi_wr_rd_cs[2]_i_2 
       (.I0(\FSM_sequential_axi_wr_rd_cs[2]_i_3_n_0 ),
        .I1(s_axi_arvalid),
        .I2(axi_wr_rd_cs[0]),
        .I3(s_axi_awvalid),
        .I4(\FSM_sequential_axi_wr_rd_cs[2]_i_4_n_0 ),
        .I5(\FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0 ),
        .O(\FSM_sequential_axi_wr_rd_cs[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBC8C3030B0803030)) 
    \FSM_sequential_axi_wr_rd_cs[2]_i_3 
       (.I0(s_axi_bready),
        .I1(axi_wr_rd_cs[1]),
        .I2(axi_wr_rd_cs[2]),
        .I3(s_axi_wvalid),
        .I4(axi_wr_rd_cs[0]),
        .I5(s_axi_rready),
        .O(\FSM_sequential_axi_wr_rd_cs[2]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \FSM_sequential_axi_wr_rd_cs[2]_i_4 
       (.I0(axi_wr_rd_cs[1]),
        .I1(axi_wr_rd_cs[2]),
        .O(\FSM_sequential_axi_wr_rd_cs[2]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'h80)) 
    \FSM_sequential_axi_wr_rd_cs[2]_i_5 
       (.I0(axi_wr_rd_cs[1]),
        .I1(m_apb_pready),
        .I2(\FSM_sequential_axi_wr_rd_cs_reg[1]_0 ),
        .O(\FSM_sequential_axi_wr_rd_cs[2]_i_5_n_0 ));
  (* FSM_ENCODED_STATES = "write:110,wr_resp:111,read:010,read_wait:001,rd_resp:011,write_wait:100,axi_idle:000,write_w_wait:101" *) 
  FDRE \FSM_sequential_axi_wr_rd_cs_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_axi_wr_rd_cs[0]_i_1_n_0 ),
        .Q(axi_wr_rd_cs[0]),
        .R(s_axi_aresetn_0));
  (* FSM_ENCODED_STATES = "write:110,wr_resp:111,read:010,read_wait:001,rd_resp:011,write_wait:100,axi_idle:000,write_w_wait:101" *) 
  FDRE \FSM_sequential_axi_wr_rd_cs_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_axi_wr_rd_cs[1]_i_1_n_0 ),
        .Q(axi_wr_rd_cs[1]),
        .R(s_axi_aresetn_0));
  (* FSM_ENCODED_STATES = "write:110,wr_resp:111,read:010,read_wait:001,rd_resp:011,write_wait:100,axi_idle:000,write_w_wait:101" *) 
  FDRE \FSM_sequential_axi_wr_rd_cs_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\FSM_sequential_axi_wr_rd_cs[2]_i_1_n_0 ),
        .Q(axi_wr_rd_cs[2]),
        .R(s_axi_aresetn_0));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[0]_i_1 
       (.I0(s_axi_awaddr[0]),
        .I1(waddr_ready_sm),
        .I2(address_i[0]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[0]),
        .O(D[0]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[10]_i_1 
       (.I0(s_axi_awaddr[10]),
        .I1(waddr_ready_sm),
        .I2(address_i[10]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[10]),
        .O(D[10]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[11]_i_1 
       (.I0(s_axi_awaddr[11]),
        .I1(waddr_ready_sm),
        .I2(address_i[11]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[11]),
        .O(D[11]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[12]_i_1 
       (.I0(s_axi_awaddr[12]),
        .I1(waddr_ready_sm),
        .I2(address_i[12]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[12]),
        .O(D[12]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[13]_i_1 
       (.I0(s_axi_awaddr[13]),
        .I1(waddr_ready_sm),
        .I2(address_i[13]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[13]),
        .O(D[13]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[14]_i_1 
       (.I0(s_axi_awaddr[14]),
        .I1(waddr_ready_sm),
        .I2(address_i[14]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[14]),
        .O(D[14]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[15]_i_1 
       (.I0(s_axi_awaddr[15]),
        .I1(waddr_ready_sm),
        .I2(address_i[15]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[15]),
        .O(D[15]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[16]_i_1 
       (.I0(s_axi_awaddr[16]),
        .I1(waddr_ready_sm),
        .I2(address_i[16]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[16]),
        .O(D[16]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[17]_i_1 
       (.I0(s_axi_awaddr[17]),
        .I1(waddr_ready_sm),
        .I2(address_i[17]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[17]),
        .O(D[17]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[18]_i_1 
       (.I0(s_axi_awaddr[18]),
        .I1(waddr_ready_sm),
        .I2(address_i[18]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[18]),
        .O(D[18]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[19]_i_1 
       (.I0(s_axi_awaddr[19]),
        .I1(waddr_ready_sm),
        .I2(address_i[19]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[19]),
        .O(D[19]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[1]_i_1 
       (.I0(s_axi_awaddr[1]),
        .I1(waddr_ready_sm),
        .I2(address_i[1]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[1]),
        .O(D[1]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[20]_i_1 
       (.I0(s_axi_awaddr[20]),
        .I1(waddr_ready_sm),
        .I2(address_i[20]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[20]),
        .O(D[20]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[21]_i_1 
       (.I0(s_axi_awaddr[21]),
        .I1(waddr_ready_sm),
        .I2(address_i[21]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[21]),
        .O(D[21]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[22]_i_1 
       (.I0(s_axi_awaddr[22]),
        .I1(waddr_ready_sm),
        .I2(address_i[22]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[22]),
        .O(D[22]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[23]_i_1 
       (.I0(s_axi_awaddr[23]),
        .I1(waddr_ready_sm),
        .I2(address_i[23]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[23]),
        .O(D[23]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[24]_i_1 
       (.I0(s_axi_awaddr[24]),
        .I1(waddr_ready_sm),
        .I2(address_i[24]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[24]),
        .O(D[24]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[25]_i_1 
       (.I0(s_axi_awaddr[25]),
        .I1(waddr_ready_sm),
        .I2(address_i[25]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[25]),
        .O(D[25]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[26]_i_1 
       (.I0(s_axi_awaddr[26]),
        .I1(waddr_ready_sm),
        .I2(address_i[26]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[26]),
        .O(D[26]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[27]_i_1 
       (.I0(s_axi_awaddr[27]),
        .I1(waddr_ready_sm),
        .I2(address_i[27]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[27]),
        .O(D[27]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[28]_i_1 
       (.I0(s_axi_awaddr[28]),
        .I1(waddr_ready_sm),
        .I2(address_i[28]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[28]),
        .O(D[28]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[29]_i_1 
       (.I0(s_axi_awaddr[29]),
        .I1(waddr_ready_sm),
        .I2(address_i[29]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[29]),
        .O(D[29]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[2]_i_1 
       (.I0(s_axi_awaddr[2]),
        .I1(waddr_ready_sm),
        .I2(address_i[2]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[2]),
        .O(D[2]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[30]_i_1 
       (.I0(s_axi_awaddr[30]),
        .I1(waddr_ready_sm),
        .I2(address_i[30]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[30]),
        .O(D[30]));
  LUT6 #(
    .INIT(64'h80F08080FFFFFFFF)) 
    \PADDR_i[31]_i_1 
       (.I0(\PADDR_i[31]_i_3_n_0 ),
        .I1(axi_wr_rd_cs[0]),
        .I2(s_axi_wvalid),
        .I3(WREADY_i_i_2_n_0),
        .I4(s_axi_awvalid),
        .I5(\PADDR_i[31]_i_4_n_0 ),
        .O(\FSM_sequential_axi_wr_rd_cs_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[31]_i_2 
       (.I0(s_axi_awaddr[31]),
        .I1(waddr_ready_sm),
        .I2(address_i[31]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[31]),
        .O(D[31]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \PADDR_i[31]_i_3 
       (.I0(axi_wr_rd_cs[2]),
        .I1(axi_wr_rd_cs[1]),
        .O(\PADDR_i[31]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'hFFEF)) 
    \PADDR_i[31]_i_4 
       (.I0(axi_wr_rd_cs[0]),
        .I1(axi_wr_rd_cs[2]),
        .I2(s_axi_arvalid),
        .I3(axi_wr_rd_cs[1]),
        .O(\PADDR_i[31]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[3]_i_1 
       (.I0(s_axi_awaddr[3]),
        .I1(waddr_ready_sm),
        .I2(address_i[3]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[3]),
        .O(D[3]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[4]_i_1 
       (.I0(s_axi_awaddr[4]),
        .I1(waddr_ready_sm),
        .I2(address_i[4]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[4]),
        .O(D[4]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[5]_i_1 
       (.I0(s_axi_awaddr[5]),
        .I1(waddr_ready_sm),
        .I2(address_i[5]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[5]),
        .O(D[5]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[6]_i_1 
       (.I0(s_axi_awaddr[6]),
        .I1(waddr_ready_sm),
        .I2(address_i[6]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[6]),
        .O(D[6]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[7]_i_1 
       (.I0(s_axi_awaddr[7]),
        .I1(waddr_ready_sm),
        .I2(address_i[7]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[7]),
        .O(D[7]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[8]_i_1 
       (.I0(s_axi_awaddr[8]),
        .I1(waddr_ready_sm),
        .I2(address_i[8]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[8]),
        .O(D[8]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \PADDR_i[9]_i_1 
       (.I0(s_axi_awaddr[9]),
        .I1(waddr_ready_sm),
        .I2(address_i[9]),
        .I3(apb_wr_request),
        .I4(s_axi_araddr[9]),
        .O(D[9]));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[0]_i_1 
       (.I0(s_axi_wdata[0]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [0]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[10]_i_1 
       (.I0(s_axi_wdata[10]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [10]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[11]_i_1 
       (.I0(s_axi_wdata[11]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [11]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[12]_i_1 
       (.I0(s_axi_wdata[12]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [12]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[13]_i_1 
       (.I0(s_axi_wdata[13]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [13]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[14]_i_1 
       (.I0(s_axi_wdata[14]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [14]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[15]_i_1 
       (.I0(s_axi_wdata[15]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [15]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[16]_i_1 
       (.I0(s_axi_wdata[16]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [16]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[17]_i_1 
       (.I0(s_axi_wdata[17]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [17]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[18]_i_1 
       (.I0(s_axi_wdata[18]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [18]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[19]_i_1 
       (.I0(s_axi_wdata[19]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [19]));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[1]_i_1 
       (.I0(s_axi_wdata[1]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [1]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[20]_i_1 
       (.I0(s_axi_wdata[20]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [20]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[21]_i_1 
       (.I0(s_axi_wdata[21]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [21]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[22]_i_1 
       (.I0(s_axi_wdata[22]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [22]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[23]_i_1 
       (.I0(s_axi_wdata[23]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [23]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[24]_i_1 
       (.I0(s_axi_wdata[24]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [24]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[25]_i_1 
       (.I0(s_axi_wdata[25]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [25]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[26]_i_1 
       (.I0(s_axi_wdata[26]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [26]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[27]_i_1 
       (.I0(s_axi_wdata[27]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [27]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[28]_i_1 
       (.I0(s_axi_wdata[28]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [28]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[29]_i_1 
       (.I0(s_axi_wdata[29]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [29]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[2]_i_1 
       (.I0(s_axi_wdata[2]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [2]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[30]_i_1 
       (.I0(s_axi_wdata[30]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [30]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[31]_i_2 
       (.I0(s_axi_wdata[31]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [31]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[3]_i_1 
       (.I0(s_axi_wdata[3]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [3]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[4]_i_1 
       (.I0(s_axi_wdata[4]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [4]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[5]_i_1 
       (.I0(s_axi_wdata[5]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [5]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[6]_i_1 
       (.I0(s_axi_wdata[6]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [6]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[7]_i_1 
       (.I0(s_axi_wdata[7]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [7]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[8]_i_1 
       (.I0(s_axi_wdata[8]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [8]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \PWDATA_i[9]_i_1 
       (.I0(s_axi_wdata[9]),
        .I1(apb_wr_request),
        .O(\s_axi_wdata[31] [9]));
  FDRE RRESP_1_i_reg
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(RRESP_1_i),
        .Q(s_axi_rresp),
        .R(s_axi_aresetn_0));
  LUT6 #(
    .INIT(64'h00000F8800000000)) 
    RVALID_i_i_1
       (.I0(\FSM_sequential_axi_wr_rd_cs_reg[1]_0 ),
        .I1(m_apb_pready),
        .I2(s_axi_rready),
        .I3(axi_wr_rd_cs[0]),
        .I4(axi_wr_rd_cs[2]),
        .I5(axi_wr_rd_cs[1]),
        .O(RVALID_sm));
  FDRE RVALID_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(RVALID_sm),
        .Q(s_axi_rvalid),
        .R(s_axi_aresetn_0));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[0]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[0]),
        .O(p_2_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[10]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[10]),
        .O(p_2_in[10]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[11]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[11]),
        .O(p_2_in[11]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[12]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[12]),
        .O(p_2_in[12]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[13]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[13]),
        .O(p_2_in[13]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[14]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[14]),
        .O(p_2_in[14]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[15]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[15]),
        .O(p_2_in[15]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[16]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[16]),
        .O(p_2_in[16]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[17]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[17]),
        .O(p_2_in[17]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[18]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[18]),
        .O(p_2_in[18]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[19]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[19]),
        .O(p_2_in[19]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[1]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[1]),
        .O(p_2_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[20]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[20]),
        .O(p_2_in[20]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[21]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[21]),
        .O(p_2_in[21]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[22]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[22]),
        .O(p_2_in[22]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[23]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[23]),
        .O(p_2_in[23]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[24]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[24]),
        .O(p_2_in[24]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[25]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[25]),
        .O(p_2_in[25]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[26]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[26]),
        .O(p_2_in[26]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[27]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[27]),
        .O(p_2_in[27]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[28]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[28]),
        .O(p_2_in[28]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[29]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[29]),
        .O(p_2_in[29]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[2]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[2]),
        .O(p_2_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[30]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[30]),
        .O(p_2_in[30]));
  LUT6 #(
    .INIT(64'hABAAAAAAAAAAAAAA)) 
    \S_AXI_RDATA[31]_i_1 
       (.I0(s_axi_rready),
        .I1(axi_wr_rd_cs[2]),
        .I2(axi_wr_rd_cs[0]),
        .I3(axi_wr_rd_cs[1]),
        .I4(m_apb_pready),
        .I5(\FSM_sequential_axi_wr_rd_cs_reg[1]_0 ),
        .O(\S_AXI_RDATA[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[31]_i_2 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[31]),
        .O(p_2_in[31]));
  LUT5 #(
    .INIT(32'h00000080)) 
    \S_AXI_RDATA[31]_i_3 
       (.I0(\FSM_sequential_axi_wr_rd_cs_reg[1]_0 ),
        .I1(m_apb_pready),
        .I2(axi_wr_rd_cs[1]),
        .I3(axi_wr_rd_cs[0]),
        .I4(axi_wr_rd_cs[2]),
        .O(PENABLE_i_reg));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[3]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[3]),
        .O(p_2_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[4]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[4]),
        .O(p_2_in[4]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[5]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[5]),
        .O(p_2_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[6]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[6]),
        .O(p_2_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[7]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[7]),
        .O(p_2_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[8]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[8]),
        .O(p_2_in[8]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \S_AXI_RDATA[9]_i_1 
       (.I0(PENABLE_i_reg),
        .I1(m_apb_pready),
        .I2(BRESP_1_i_reg_0),
        .I3(m_apb_prdata[9]),
        .O(p_2_in[9]));
  FDRE \S_AXI_RDATA_reg[0] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[0]),
        .Q(s_axi_rdata[0]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[10] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[10]),
        .Q(s_axi_rdata[10]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[11] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[11]),
        .Q(s_axi_rdata[11]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[12] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[12]),
        .Q(s_axi_rdata[12]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[13] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[13]),
        .Q(s_axi_rdata[13]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[14] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[14]),
        .Q(s_axi_rdata[14]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[15] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[15]),
        .Q(s_axi_rdata[15]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[16] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[16]),
        .Q(s_axi_rdata[16]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[17] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[17]),
        .Q(s_axi_rdata[17]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[18] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[18]),
        .Q(s_axi_rdata[18]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[19] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[19]),
        .Q(s_axi_rdata[19]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[1] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[1]),
        .Q(s_axi_rdata[1]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[20] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[20]),
        .Q(s_axi_rdata[20]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[21] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[21]),
        .Q(s_axi_rdata[21]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[22] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[22]),
        .Q(s_axi_rdata[22]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[23] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[23]),
        .Q(s_axi_rdata[23]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[24] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[24]),
        .Q(s_axi_rdata[24]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[25] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[25]),
        .Q(s_axi_rdata[25]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[26] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[26]),
        .Q(s_axi_rdata[26]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[27] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[27]),
        .Q(s_axi_rdata[27]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[28] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[28]),
        .Q(s_axi_rdata[28]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[29] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[29]),
        .Q(s_axi_rdata[29]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[2] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[2]),
        .Q(s_axi_rdata[2]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[30] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[30]),
        .Q(s_axi_rdata[30]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[31] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[31]),
        .Q(s_axi_rdata[31]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[3] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[3]),
        .Q(s_axi_rdata[3]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[4] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[4]),
        .Q(s_axi_rdata[4]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[5] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[5]),
        .Q(s_axi_rdata[5]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[6] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[6]),
        .Q(s_axi_rdata[6]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[7] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[7]),
        .Q(s_axi_rdata[7]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[8] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[8]),
        .Q(s_axi_rdata[8]),
        .R(s_axi_aresetn_0));
  FDRE \S_AXI_RDATA_reg[9] 
       (.C(s_axi_aclk),
        .CE(\S_AXI_RDATA[31]_i_1_n_0 ),
        .D(p_2_in[9]),
        .Q(s_axi_rdata[9]),
        .R(s_axi_aresetn_0));
  LUT6 #(
    .INIT(64'h20202020F0202020)) 
    WREADY_i_i_1
       (.I0(s_axi_awvalid),
        .I1(WREADY_i_i_2_n_0),
        .I2(s_axi_wvalid),
        .I3(axi_wr_rd_cs[0]),
        .I4(axi_wr_rd_cs[2]),
        .I5(axi_wr_rd_cs[1]),
        .O(apb_wr_request));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'hDFDFFFFC)) 
    WREADY_i_i_2
       (.I0(s_axi_rready),
        .I1(axi_wr_rd_cs[2]),
        .I2(axi_wr_rd_cs[0]),
        .I3(s_axi_arvalid),
        .I4(axi_wr_rd_cs[1]),
        .O(WREADY_i_i_2_n_0));
  FDRE WREADY_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(apb_wr_request),
        .Q(s_axi_wready),
        .R(s_axi_aresetn_0));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[0]_i_1 
       (.I0(s_axi_awaddr[0]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[0]),
        .O(\address_i[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[10]_i_1 
       (.I0(s_axi_awaddr[10]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[10]),
        .O(\address_i[10]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[11]_i_1 
       (.I0(s_axi_awaddr[11]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[11]),
        .O(\address_i[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[12]_i_1 
       (.I0(s_axi_awaddr[12]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[12]),
        .O(\address_i[12]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[13]_i_1 
       (.I0(s_axi_awaddr[13]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[13]),
        .O(\address_i[13]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[14]_i_1 
       (.I0(s_axi_awaddr[14]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[14]),
        .O(\address_i[14]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[15]_i_1 
       (.I0(s_axi_awaddr[15]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[15]),
        .O(\address_i[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[16]_i_1 
       (.I0(s_axi_awaddr[16]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[16]),
        .O(\address_i[16]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[17]_i_1 
       (.I0(s_axi_awaddr[17]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[17]),
        .O(\address_i[17]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[18]_i_1 
       (.I0(s_axi_awaddr[18]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[18]),
        .O(\address_i[18]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[19]_i_1 
       (.I0(s_axi_awaddr[19]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[19]),
        .O(\address_i[19]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[1]_i_1 
       (.I0(s_axi_awaddr[1]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[1]),
        .O(\address_i[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[20]_i_1 
       (.I0(s_axi_awaddr[20]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[20]),
        .O(\address_i[20]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[21]_i_1 
       (.I0(s_axi_awaddr[21]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[21]),
        .O(\address_i[21]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[22]_i_1 
       (.I0(s_axi_awaddr[22]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[22]),
        .O(\address_i[22]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[23]_i_1 
       (.I0(s_axi_awaddr[23]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[23]),
        .O(\address_i[23]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[24]_i_1 
       (.I0(s_axi_awaddr[24]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[24]),
        .O(\address_i[24]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[25]_i_1 
       (.I0(s_axi_awaddr[25]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[25]),
        .O(\address_i[25]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[26]_i_1 
       (.I0(s_axi_awaddr[26]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[26]),
        .O(\address_i[26]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[27]_i_1 
       (.I0(s_axi_awaddr[27]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[27]),
        .O(\address_i[27]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[28]_i_1 
       (.I0(s_axi_awaddr[28]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[28]),
        .O(\address_i[28]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[29]_i_1 
       (.I0(s_axi_awaddr[29]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[29]),
        .O(\address_i[29]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[2]_i_1 
       (.I0(s_axi_awaddr[2]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[2]),
        .O(\address_i[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[30]_i_1 
       (.I0(s_axi_awaddr[30]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[30]),
        .O(\address_i[30]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000808000000F0C)) 
    \address_i[31]_i_1 
       (.I0(s_axi_rready),
        .I1(s_axi_awvalid),
        .I2(axi_wr_rd_cs[1]),
        .I3(s_axi_arvalid),
        .I4(axi_wr_rd_cs[2]),
        .I5(axi_wr_rd_cs[0]),
        .O(\address_i[31]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[31]_i_2 
       (.I0(s_axi_awaddr[31]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[31]),
        .O(\address_i[31]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[3]_i_1 
       (.I0(s_axi_awaddr[3]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[3]),
        .O(\address_i[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[4]_i_1 
       (.I0(s_axi_awaddr[4]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[4]),
        .O(\address_i[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[5]_i_1 
       (.I0(s_axi_awaddr[5]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[5]),
        .O(\address_i[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[6]_i_1 
       (.I0(s_axi_awaddr[6]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[6]),
        .O(\address_i[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[7]_i_1 
       (.I0(s_axi_awaddr[7]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[7]),
        .O(\address_i[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[8]_i_1 
       (.I0(s_axi_awaddr[8]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[8]),
        .O(\address_i[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \address_i[9]_i_1 
       (.I0(s_axi_awaddr[9]),
        .I1(waddr_ready_sm),
        .I2(s_axi_araddr[9]),
        .O(\address_i[9]_i_1_n_0 ));
  FDRE \address_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[0]_i_1_n_0 ),
        .Q(address_i[0]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[10] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[10]_i_1_n_0 ),
        .Q(address_i[10]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[11] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[11]_i_1_n_0 ),
        .Q(address_i[11]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[12] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[12]_i_1_n_0 ),
        .Q(address_i[12]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[13] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[13]_i_1_n_0 ),
        .Q(address_i[13]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[14] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[14]_i_1_n_0 ),
        .Q(address_i[14]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[15] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[15]_i_1_n_0 ),
        .Q(address_i[15]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[16] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[16]_i_1_n_0 ),
        .Q(address_i[16]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[17] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[17]_i_1_n_0 ),
        .Q(address_i[17]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[18] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[18]_i_1_n_0 ),
        .Q(address_i[18]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[19] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[19]_i_1_n_0 ),
        .Q(address_i[19]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[1]_i_1_n_0 ),
        .Q(address_i[1]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[20] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[20]_i_1_n_0 ),
        .Q(address_i[20]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[21] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[21]_i_1_n_0 ),
        .Q(address_i[21]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[22] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[22]_i_1_n_0 ),
        .Q(address_i[22]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[23] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[23]_i_1_n_0 ),
        .Q(address_i[23]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[24] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[24]_i_1_n_0 ),
        .Q(address_i[24]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[25] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[25]_i_1_n_0 ),
        .Q(address_i[25]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[26] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[26]_i_1_n_0 ),
        .Q(address_i[26]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[27] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[27]_i_1_n_0 ),
        .Q(address_i[27]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[28] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[28]_i_1_n_0 ),
        .Q(address_i[28]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[29] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[29]_i_1_n_0 ),
        .Q(address_i[29]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[2]_i_1_n_0 ),
        .Q(address_i[2]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[30] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[30]_i_1_n_0 ),
        .Q(address_i[30]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[31] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[31]_i_2_n_0 ),
        .Q(address_i[31]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[3] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[3]_i_1_n_0 ),
        .Q(address_i[3]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[4] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[4]_i_1_n_0 ),
        .Q(address_i[4]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[5] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[5]_i_1_n_0 ),
        .Q(address_i[5]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[6] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[6]_i_1_n_0 ),
        .Q(address_i[6]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[7] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[7]_i_1_n_0 ),
        .Q(address_i[7]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[8] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[8]_i_1_n_0 ),
        .Q(address_i[8]),
        .R(s_axi_aresetn_0));
  FDRE \address_i_reg[9] 
       (.C(s_axi_aclk),
        .CE(\address_i[31]_i_1_n_0 ),
        .D(\address_i[9]_i_1_n_0 ),
        .Q(address_i[9]),
        .R(s_axi_aresetn_0));
endmodule

(* CHECK_LICENSE_TYPE = "crossbar_axi_apb_bridge_0_0,axi_apb_bridge,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "axi_apb_bridge,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module crossbar_axi_apb_bridge_0_0
   (s_axi_aclk,
    s_axi_aresetn,
    s_axi_awaddr,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_araddr,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_rready,
    m_apb_paddr,
    m_apb_psel,
    m_apb_penable,
    m_apb_pwrite,
    m_apb_pwdata,
    m_apb_pready,
    m_apb_prdata,
    m_apb_pslverr);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 ACLK CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF AXI4_LITE:APB_M:APB_M2:APB_M3:APB_M4:APB_M5:APB_M6:APB_M7:APB_M8:APB_M9:APB_M10:APB_M11:APB_M12:APB_M13:APB_M14:APB_M15:APB_M16, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 166000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN crossbar_CLOCK, INSERT_VIP 0" *) input s_axi_aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 ARESETN RST" *) (* x_interface_parameter = "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_axi_aresetn;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE AWADDR" *) (* x_interface_parameter = "XIL_INTERFACENAME AXI4_LITE, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 166000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 64, NUM_WRITE_OUTSTANDING 64, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN crossbar_CLOCK, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [31:0]s_axi_awaddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE AWVALID" *) input s_axi_awvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE AWREADY" *) output s_axi_awready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE WDATA" *) input [31:0]s_axi_wdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE WVALID" *) input s_axi_wvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE WREADY" *) output s_axi_wready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE BRESP" *) output [1:0]s_axi_bresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE BVALID" *) output s_axi_bvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE BREADY" *) input s_axi_bready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE ARADDR" *) input [31:0]s_axi_araddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE ARVALID" *) input s_axi_arvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE ARREADY" *) output s_axi_arready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE RDATA" *) output [31:0]s_axi_rdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE RRESP" *) output [1:0]s_axi_rresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE RVALID" *) output s_axi_rvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4_LITE RREADY" *) input s_axi_rready;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PADDR" *) output [31:0]m_apb_paddr;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PSEL" *) output [0:0]m_apb_psel;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PENABLE" *) output m_apb_penable;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PWRITE" *) output m_apb_pwrite;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PWDATA" *) output [31:0]m_apb_pwdata;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PREADY" *) input [0:0]m_apb_pready;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PRDATA" *) input [31:0]m_apb_prdata;
  (* x_interface_info = "xilinx.com:interface:apb:1.0 APB_M PSLVERR" *) input [0:0]m_apb_pslverr;

  wire \<const0> ;
  wire [31:0]m_apb_paddr;
  wire m_apb_penable;
  wire [31:0]m_apb_prdata;
  wire [0:0]m_apb_pready;
  wire [0:0]m_apb_psel;
  wire [0:0]m_apb_pslverr;
  wire [31:0]m_apb_pwdata;
  wire m_apb_pwrite;
  wire s_axi_aclk;
  wire [31:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [31:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire [1:1]\^s_axi_bresp ;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire s_axi_rready;
  wire [1:1]\^s_axi_rresp ;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready;
  wire s_axi_wvalid;
  wire [2:0]NLW_U0_m_apb_pprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_apb_pstrb_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  assign s_axi_bresp[1] = \^s_axi_bresp [1];
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_rresp[1] = \^s_axi_rresp [1];
  assign s_axi_rresp[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_APB_NUM_SLAVES = "1" *) 
  (* C_BASEADDR = "64'b0000000000000000000000000000000011110100000000000000000000000000" *) 
  (* C_DPHASE_TIMEOUT = "0" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HIGHADDR = "64'b0000000000000000000000000000000011110100000000001111111111111111" *) 
  (* C_INSTANCE = "axi_apb_bridge_inst" *) 
  (* C_M_APB_ADDR_WIDTH = "32" *) 
  (* C_M_APB_DATA_WIDTH = "32" *) 
  (* C_M_APB_PROTOCOL = "apb3" *) 
  (* C_S_AXI_ADDR_WIDTH = "32" *) 
  (* C_S_AXI_DATA_WIDTH = "32" *) 
  (* C_S_AXI_RNG10_BASEADDR = "64'b0000000000000000000000000000000010010000000000000000000000000000" *) 
  (* C_S_AXI_RNG10_HIGHADDR = "64'b0000000000000000000000000000000010011111111111111111111111111111" *) 
  (* C_S_AXI_RNG11_BASEADDR = "64'b0000000000000000000000000000000010100000000000000000000000000000" *) 
  (* C_S_AXI_RNG11_HIGHADDR = "64'b0000000000000000000000000000000010101111111111111111111111111111" *) 
  (* C_S_AXI_RNG12_BASEADDR = "64'b0000000000000000000000000000000010110000000000000000000000000000" *) 
  (* C_S_AXI_RNG12_HIGHADDR = "64'b0000000000000000000000000000000010111111111111111111111111111111" *) 
  (* C_S_AXI_RNG13_BASEADDR = "64'b0000000000000000000000000000000011000000000000000000000000000000" *) 
  (* C_S_AXI_RNG13_HIGHADDR = "64'b0000000000000000000000000000000011001111111111111111111111111111" *) 
  (* C_S_AXI_RNG14_BASEADDR = "64'b0000000000000000000000000000000011010000000000000000000000000000" *) 
  (* C_S_AXI_RNG14_HIGHADDR = "64'b0000000000000000000000000000000011011111111111111111111111111111" *) 
  (* C_S_AXI_RNG15_BASEADDR = "64'b0000000000000000000000000000000011100000000000000000000000000000" *) 
  (* C_S_AXI_RNG15_HIGHADDR = "64'b0000000000000000000000000000000011101111111111111111111111111111" *) 
  (* C_S_AXI_RNG16_BASEADDR = "64'b0000000000000000000000000000000011110000000000000000000000000000" *) 
  (* C_S_AXI_RNG16_HIGHADDR = "64'b0000000000000000000000000000000011111111111111111111111111111111" *) 
  (* C_S_AXI_RNG2_BASEADDR = "64'b0000000000000000000000000000000000010000000000000000000000000000" *) 
  (* C_S_AXI_RNG2_HIGHADDR = "64'b0000000000000000000000000000000000011111111111111111111111111111" *) 
  (* C_S_AXI_RNG3_BASEADDR = "64'b0000000000000000000000000000000000100000000000000000000000000000" *) 
  (* C_S_AXI_RNG3_HIGHADDR = "64'b0000000000000000000000000000000000101111111111111111111111111111" *) 
  (* C_S_AXI_RNG4_BASEADDR = "64'b0000000000000000000000000000000000110000000000000000000000000000" *) 
  (* C_S_AXI_RNG4_HIGHADDR = "64'b0000000000000000000000000000000000111111111111111111111111111111" *) 
  (* C_S_AXI_RNG5_BASEADDR = "64'b0000000000000000000000000000000001000000000000000000000000000000" *) 
  (* C_S_AXI_RNG5_HIGHADDR = "64'b0000000000000000000000000000000001001111111111111111111111111111" *) 
  (* C_S_AXI_RNG6_BASEADDR = "64'b0000000000000000000000000000000001010000000000000000000000000000" *) 
  (* C_S_AXI_RNG6_HIGHADDR = "64'b0000000000000000000000000000000001011111111111111111111111111111" *) 
  (* C_S_AXI_RNG7_BASEADDR = "64'b0000000000000000000000000000000001100000000000000000000000000000" *) 
  (* C_S_AXI_RNG7_HIGHADDR = "64'b0000000000000000000000000000000001101111111111111111111111111111" *) 
  (* C_S_AXI_RNG8_BASEADDR = "64'b0000000000000000000000000000000001110000000000000000000000000000" *) 
  (* C_S_AXI_RNG8_HIGHADDR = "64'b0000000000000000000000000000000001111111111111111111111111111111" *) 
  (* C_S_AXI_RNG9_BASEADDR = "64'b0000000000000000000000000000000010000000000000000000000000000000" *) 
  (* C_S_AXI_RNG9_HIGHADDR = "64'b0000000000000000000000000000000010001111111111111111111111111111" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  crossbar_axi_apb_bridge_0_0_axi_apb_bridge U0
       (.m_apb_paddr(m_apb_paddr),
        .m_apb_penable(m_apb_penable),
        .m_apb_pprot(NLW_U0_m_apb_pprot_UNCONNECTED[2:0]),
        .m_apb_prdata(m_apb_prdata),
        .m_apb_prdata10({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata11({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata12({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata13({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata14({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata15({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata16({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata2({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata3({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata4({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata5({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata6({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata7({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata8({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_prdata9({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_apb_pready(m_apb_pready),
        .m_apb_psel(m_apb_psel),
        .m_apb_pslverr(m_apb_pslverr),
        .m_apb_pstrb(NLW_U0_m_apb_pstrb_UNCONNECTED[3:0]),
        .m_apb_pwdata(m_apb_pwdata),
        .m_apb_pwrite(m_apb_pwrite),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp({\^s_axi_bresp ,NLW_U0_s_axi_bresp_UNCONNECTED[0]}),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp({\^s_axi_rresp ,NLW_U0_s_axi_rresp_UNCONNECTED[0]}),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

module crossbar_axi_apb_bridge_0_0_multiplexor
   (m_apb_psel,
    \GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0 ,
    PSEL_i,
    s_axi_aclk);
  output [0:0]m_apb_psel;
  input \GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0 ;
  input PSEL_i;
  input s_axi_aclk;

  wire \GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0 ;
  wire PSEL_i;
  wire [0:0]m_apb_psel;
  wire s_axi_aclk;

  FDRE \GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(PSEL_i),
        .Q(m_apb_psel),
        .R(\GEN_1_SELECT_SLAVE.M_APB_PSEL_i_reg[0]_0 ));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
