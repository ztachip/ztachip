// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altrea Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:i2c controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Joe Yang          :| 05/07/10  :|      Initial Revision
//   V2.0 :| Joe Yang          :| 12/12/16  :|      Initial Revision
// --------------------------------------------------------------------
module I2C_Controller (
	input  CLOCK,
	input  [23:0]I2C_DATA,	
	input  GO,
	input  RESET,	
	input  W_R,
 	inout  I2C_SDAT,	
	output I2C_SCLK,
	output END,	
	output ACK
);

wire SDAO ; 

assign I2C_SDAT = SDAO?1'bz :0  ; 

I2C_WRITE_WDATA  wrd(
   .RESET_N  ( RESET),
	.PT_CK    ( CLOCK),
	.GO       ( GO   ),
	.END_OK   ( END  ),
	.ACK_OK   ( ACK  ),
	.BYTE_NUM ( 2    ),  //2byte	
	.SDAI     ( I2C_SDAT ),//IN
	.SDAO     ( SDAO     ),//OUT
	.SCLO     ( I2C_SCLK ),	
	.SLAVE_ADDRESS( I2C_DATA[23:16] ),
	.REG_DATA     ( I2C_DATA[15:0]  )	
);	
	
	

endmodule
