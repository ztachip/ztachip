-- pselect_f.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- *************************************************************************
-- **                                                                     **
-- ** DISCLAIMER OF LIABILITY                                             **
-- **                                                                     **
-- ** This text/file contains proprietary, confidential                   **
-- ** information of Xilinx, Inc., is distributed under                   **
-- ** license from Xilinx, Inc., and may be used, copied                  **
-- ** and/or disclosed only pursuant to the terms of a valid              **
-- ** license agreement with Xilinx, Inc. Xilinx hereby                   **
-- ** grants you a license to use this text/file solely for               **
-- ** design, simulation, implementation and creation of                  **
-- ** design files limited to Xilinx devices or technologies.             **
-- ** Use with non-Xilinx devices or technologies is expressly            **
-- ** prohibited and immediately terminates your license unless           **
-- ** covered by a separate agreement.                                    **
-- **                                                                     **
-- ** Xilinx is providing this design, code, or information               **
-- ** "as-is" solely for use in developing programs and                   **
-- ** solutions for Xilinx devices, with no obligation on the             **
-- ** part of Xilinx to provide support. By providing this design,        **
-- ** code, or information as one possible implementation of              **
-- ** this feature, application or standard, Xilinx is making no          **
-- ** representation that this implementation is free from any            **
-- ** claims of infringement. You are responsible for obtaining           **
-- ** any rights you may require for your implementation.                 **
-- ** Xilinx expressly disclaims any warranty whatsoever with             **
-- ** respect to the adequacy of the implementation, including            **
-- ** but not limited to any warranties or representations that this      **
-- ** implementation is free from claims of infringement, implied         **
-- ** warranties of merchantability or fitness for a particular           **
-- ** purpose.                                                            **
-- **                                                                     **
-- ** Xilinx products are not intended for use in life support            **
-- ** appliances, devices, or systems. Use in such applications is        **
-- ** expressly prohibited.                                               **
-- **                                                                     **
-- ** Any modifications that are made to the Source Code are              **
-- ** done at the user’s sole risk and will be unsupported.               **
-- ** The Xilinx Support Hotline does not have access to source           **
-- ** code and therefore cannot answer specific questions related         **
-- ** to source HDL. The Xilinx Hotline support of original source        **
-- ** code IP shall only address issues and questions related             **
-- ** to the standard Netlist version of the core (and thus               **
-- ** indirectly, the original core source).                              **
-- **                                                                     **
-- ** Copyright (c) 2008-2010 Xilinx, Inc. All rights reserved.           **
-- **                                                                     **
-- ** This copyright and support notice must be retained as part          **
-- ** of this text at all times.                                          **
-- **                                                                     **
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        pselect_f.vhd
--
-- Description:
--                  (Note: At least as early as I.31, XST implements a carry-
--                   chain structure for most decoders when these are coded in
--                   inferrable VHLD. An example of such code can be seen
--                   below in the "INFERRED_GEN" Generate Statement.
--
--                   ->  New code should not need to instantiate pselect-type
--                       components.
--
--                   ->  Existing code can be ported to Virtex5 and later by
--                       replacing pselect instances by pselect_f instances.
--                       As long as the C_FAMILY parameter is not included
--                       in the Generic Map, an inferred implementation
--                       will result.
--
--                   ->  If the designer wishes to force an explicit carry-
--                       chain implementation, pselect_f can be used with
--                       the C_FAMILY parameter set to the target
--                       Xilinx FPGA family.
--                  )
--
--                  Parameterizeable peripheral select (address decode).
--                  AValid qualifier comes in on Carry In at bottom
--                  of carry chain.
--
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_com"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.all;


-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Generics:
--          C_AB            -- number of address bits to decode
--          C_AW            -- width of address bus
--          C_BAR           -- base address of peripheral (peripheral select
--                             is asserted when the C_AB most significant
--                             address bits match the C_AB most significant
--                             C_BAR bits
-- Definition of Ports:
--          A               -- address input
--          AValid          -- address qualifier
--          CS              -- peripheral select
-------------------------------------------------------------------------------

entity pselect_f is

  generic (
    C_AB     : integer := 9;
    C_AW     : integer := 32;
    C_BAR    : std_logic_vector;
    C_FAMILY : string := "nofamily"
    );
  port (
    A        : in   std_logic_vector(0 to C_AW-1);
    AValid   : in   std_logic;
    CS       : out  std_logic
    );

end entity pselect_f;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of pselect_f is

  component MUXCY is
    port (
      O  : out std_logic;
      CI : in  std_logic;
      DI : in  std_logic;
      S  : in  std_logic
    );
  end component MUXCY;


  -----------------------------------------------------------------------------
  -- C_BAR may not be indexed from 0 and may not be ascending;
  -- BAR recasts C_BAR to have these properties.
  -----------------------------------------------------------------------------
  constant BAR          : std_logic_vector(0 to C_BAR'length-1) := C_BAR;

  type bo2sl_type is array (boolean) of std_logic;
  constant bo2sl  : bo2sl_type := (false => '0', true => '1');
 
  function min(i, j: integer) return integer is
  begin
      if i<j then return i; else return j; end if;
  end;

begin

  ------------------------------------------------------------------------------
  -- Check that the generics are valid.
  ------------------------------------------------------------------------------
  -- synthesis translate_off
     assert (C_AB <= C_BAR'length) and (C_AB <= C_AW)
     report "pselect_f generic error: " &
            "(C_AB <= C_BAR'length) and (C_AB <= C_AW)" &
            " does not hold."
     severity failure;
  -- synthesis translate_on


  ------------------------------------------------------------------------------
  -- Build a behavioral decoder
  ------------------------------------------------------------------------------
  
    XST_WA:if C_AB > 0 generate
      CS  <= AValid when A(0 to C_AB-1) = BAR (64-C_AW to 64-C_AW+C_AB-1) else
             '0' ;
    end generate XST_WA;
    
    PASS_ON_GEN:if C_AB = 0 generate
      CS  <= AValid ;
    end generate PASS_ON_GEN;
    


end imp;




-------------------------------------------------------------------------------
-- counter_f - entity/architecture pair
-------------------------------------------------------------------------------
--
-- *************************************************************************
-- **                                                                     **
-- ** DISCLAIMER OF LIABILITY                                             **
-- **                                                                     **
-- ** This text/file contains proprietary, confidential                   **
-- ** information of Xilinx, Inc., is distributed under                   **
-- ** license from Xilinx, Inc., and may be used, copied                  **
-- ** and/or disclosed only pursuant to the terms of a valid              **
-- ** license agreement with Xilinx, Inc. Xilinx hereby                   **
-- ** grants you a license to use this text/file solely for               **
-- ** design, simulation, implementation and creation of                  **
-- ** design files limited to Xilinx devices or technologies.             **
-- ** Use with non-Xilinx devices or technologies is expressly            **
-- ** prohibited and immediately terminates your license unless           **
-- ** covered by a separate agreement.                                    **
-- **                                                                     **
-- ** Xilinx is providing this design, code, or information               **
-- ** "as-is" solely for use in developing programs and                   **
-- ** solutions for Xilinx devices, with no obligation on the             **
-- ** part of Xilinx to provide support. By providing this design,        **
-- ** code, or information as one possible implementation of              **
-- ** this feature, application or standard, Xilinx is making no          **
-- ** representation that this implementation is free from any            **
-- ** claims of infringement. You are responsible for obtaining           **
-- ** any rights you may require for your implementation.                 **
-- ** Xilinx expressly disclaims any warranty whatsoever with             **
-- ** respect to the adequacy of the implementation, including            **
-- ** but not limited to any warranties or representations that this      **
-- ** implementation is free from claims of infringement, implied         **
-- ** warranties of merchantability or fitness for a particular           **
-- ** purpose.                                                            **
-- **                                                                     **
-- ** Xilinx products are not intended for use in life support            **
-- ** appliances, devices, or systems. Use in such applications is        **
-- ** expressly prohibited.                                               **
-- **                                                                     **
-- ** Any modifications that are made to the Source Code are              **
-- ** done at the user’s sole risk and will be unsupported.               **
-- ** The Xilinx Support Hotline does not have access to source           **
-- ** code and therefore cannot answer specific questions related         **
-- ** to source HDL. The Xilinx Hotline support of original source        **
-- ** code IP shall only address issues and questions related             **
-- ** to the standard Netlist version of the core (and thus               **
-- ** indirectly, the original core source).                              **
-- **                                                                     **
-- ** Copyright (c) 2006-2010 Xilinx, Inc. All rights reserved.           **
-- **                                                                     **
-- ** This copyright and support notice must be retained as part          **
-- ** of this text at all times.                                          **
-- **                                                                     **
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        counter_f.vhd
--
-- Description:     Implements a parameterizable N-bit counter_f
--                      Up/Down Counter
--                      Count Enable
--                      Parallel Load
--                      Synchronous Reset
--                      The structural implementation has incremental cost
--                      of one LUT per bit.
--                      Precedence of operations when simultaneous:
--                        reset, load, count
--
--                  A default inferred-RTL implementation is provided and
--                  is used if the user explicitly specifies C_FAMILY=nofamily
--                  or ommits C_FAMILY (allowing it to default to nofamily).
--                  The default implementation is also used
--                  if needed primitives are not available in FPGAs of the
--                  type given by C_FAMILY.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_com"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.unsigned;
use IEEE.numeric_std."+";
use IEEE.numeric_std."-";

library unisim;
use unisim.all;

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity counter_f is
    generic(
            C_NUM_BITS : integer := 9;
            C_FAMILY   : string := "nofamily"
           );

    port(
         Clk           : in  std_logic;
         Rst           : in  std_logic;
         Load_In       : in  std_logic_vector(C_NUM_BITS - 1 downto 0);
         Count_Enable  : in  std_logic;
         Count_Load    : in  std_logic;
         Count_Down    : in  std_logic;
         Count_Out     : out std_logic_vector(C_NUM_BITS - 1 downto 0);
         Carry_Out     : out std_logic
        );
end entity counter_f;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of counter_f is

    ---------------------------------------------------------------------
    -- Component declarations
    ---------------------------------------------------------------------  
    component MUXCY_L is
      port (
        DI : in  std_logic;
        CI : in  std_logic;
        S  : in  std_logic;
        LO : out std_logic);
    end component MUXCY_L;

    component XORCY is
      port (
        LI : in  std_logic;
        CI : in  std_logic;
        O  : out std_logic);
    end component XORCY;

    component FDRE is
      port (
        Q  : out std_logic;
        C  : in  std_logic;
        CE : in  std_logic;
        D  : in  std_logic;
        R  : in  std_logic
      );
    end component FDRE;
        signal icount_out    : unsigned(C_NUM_BITS downto 0);
        signal icount_out_x  : unsigned(C_NUM_BITS downto 0);
        signal load_in_x     : unsigned(C_NUM_BITS downto 0);

    ---------------------------------------------------------------------
    -- Constant declarations
    ---------------------------------------------------------------------
---------------------------------------------------------------------
-- Begin architecture
---------------------------------------------------------------------
begin
    ---------------------------------------------------------------------
    -- Generate Inferred code
    ---------------------------------------------------------------------
    --INFERRED_GEN : if USE_INFERRED generate



        load_in_x    <= unsigned('0' & Load_In);

        -- Mask out carry position to retain legacy self-clear on next enable.
 --        icount_out_x <= ('0' & icount_out(C_NUM_BITS-1 downto 0)); -- Echeck WA
         icount_out_x <= unsigned('0' & std_logic_vector(icount_out(C_NUM_BITS-1 downto 0)));

        -----------------------------------------------------------------
        -- Process to generate counter with - synchronous reset, load,
        -- counter enable, count down / up features.
        -----------------------------------------------------------------
        CNTR_PROC : process(Clk)
        begin
            if Clk'event and Clk = '1' then
                if Rst = '1' then
                    icount_out <= (others => '0');
                elsif Count_Load = '1' then
                    icount_out <= load_in_x;
                elsif Count_Down = '1'  and Count_Enable = '1' then
                    icount_out <= icount_out_x - 1;
                elsif Count_Enable = '1' then
                    icount_out <= icount_out_x + 1;
                end if;
            end if;
        end process CNTR_PROC;

        Carry_Out <= icount_out(C_NUM_BITS);
        Count_Out <= std_logic_vector(icount_out(C_NUM_BITS-1 downto 0));



end architecture imp;
---------------------------------------------------------------
-- End of file counter_f.vhd
---------------------------------------------------------------


-------------------------------------------------------------------------------
-- psel_decoder.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2009-2012 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ****************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        psel_decoder.vhd
-- Version:         v1.01a
-- Description:     This module generates the PSEL signal for selecting
--                  different slaves.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.CONV_INTEGER;
library axi_apb_bridge_v3_0_17;
use axi_apb_bridge_v3_0_17.pselect_f;


entity psel_decoder is
  generic (
    C_FAMILY               : string                    := "virtex7";

    C_S_AXI_ADDR_WIDTH     : integer range 1 to 64    := 32;
    C_APB_NUM_SLAVES       : integer range 1 to 16     := 4;

    C_S_AXI_RNG1_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG1_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG2_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG2_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG3_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG3_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG4_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG4_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG5_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG5_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG6_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG6_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG7_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG7_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG8_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG8_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG9_BASEADDR  : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG9_HIGHADDR  : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG10_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG10_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG11_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG11_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG12_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG12_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG13_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG13_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG14_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG14_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG15_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG15_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";

    C_S_AXI_RNG16_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG16_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000"

    );
  port (
    Address           : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    addr_is_valid     : in std_logic;
    sl_pselect        : out std_logic_vector(C_APB_NUM_SLAVES-1 downto 0)
    );

end entity psel_decoder;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of psel_decoder is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
-- Function declaration
-- This function generates the number of address bits to be compared depending
-- upon the selected base and high addresses.
-------------------------------------------------------------------------------

    function Get_Addr_Bits (x : std_logic_vector(0 to 63);
                            y : std_logic_vector(0 to 63);
                            a : integer
                           )
             return integer is
        variable addr_nor : std_logic_vector(0 to 63);
        begin
            addr_nor := x xor y;
            for i in 0 to 63 loop
                if addr_nor(i)='1' then
                    return (i-(64-a));
                end if;
            end loop;
    -- coverage off
            return(a);
    -- coverage on
    end function Get_Addr_Bits;
-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 1
-- ****************************************************************************

    GEN_1_ADDR_RANGES : if C_APB_NUM_SLAVES = 1 generate

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals - As one slave is used select is always
 -- high
-------------------------------------------------------------------------------

        sl_pselect(0)  <= addr_is_valid;

    end generate GEN_1_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 2
-- ****************************************************************************

    GEN_2_ADDR_RANGES : if C_APB_NUM_SLAVES = 2 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

    end generate GEN_2_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 3
-- ****************************************************************************

    GEN_3_ADDR_RANGES : if C_APB_NUM_SLAVES = 3 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range3 & addr_hit_range2 & addr_hit_range1 ;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

    end generate GEN_3_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 4
-- ****************************************************************************

    GEN_4_ADDR_RANGES : if C_APB_NUM_SLAVES = 4 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range4 & addr_hit_range3 &
                        addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

    end generate GEN_4_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 5
-- ****************************************************************************

    GEN_5_ADDR_RANGES : if C_APB_NUM_SLAVES = 5 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

    end generate GEN_5_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 6
-- ****************************************************************************

    GEN_6_ADDR_RANGES : if C_APB_NUM_SLAVES = 6 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );
    end generate GEN_6_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 7
-- ****************************************************************************

    GEN_7_ADDR_RANGES : if C_APB_NUM_SLAVES = 7 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

    end generate GEN_7_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 8
-- ****************************************************************************

    GEN_8_ADDR_RANGES : if C_APB_NUM_SLAVES = 8 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );

    end generate GEN_8_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 9
-- ****************************************************************************

    GEN_9_ADDR_RANGES : if C_APB_NUM_SLAVES = 9 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

    end generate GEN_9_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 10
-- ****************************************************************************

    GEN_10_ADDR_RANGES : if C_APB_NUM_SLAVES = 10 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

    end generate GEN_10_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 11
-- ****************************************************************************

    GEN_11_ADDR_RANGES : if C_APB_NUM_SLAVES = 11 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range11 & addr_hit_range10 &
                    addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );

    end generate GEN_11_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 12
-- ****************************************************************************

    GEN_12_ADDR_RANGES : if C_APB_NUM_SLAVES = 12 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range12 & addr_hit_range11 &
                    addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2& addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );


    end generate GEN_12_ADDR_RANGES;
-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 13
-- ****************************************************************************

    GEN_13_ADDR_RANGES : if C_APB_NUM_SLAVES = 13 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range13 & addr_hit_range12 &
                    addr_hit_range11 & addr_hit_range10 &
                    addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

    end generate GEN_13_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 14
-- ****************************************************************************

    GEN_14_ADDR_RANGES : if C_APB_NUM_SLAVES = 14 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG14      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG14_BASEADDR, C_S_AXI_RNG14_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;
        signal addr_hit_range14 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range14 & addr_hit_range13 &
                    addr_hit_range12 & addr_hit_range11 &
                    addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 14
-------------------------------------------------------------------------------

          RANGE14_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG14,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG14_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range14    -- [out]
              );

    end generate GEN_14_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 15
-- ****************************************************************************

    GEN_15_ADDR_RANGES : if C_APB_NUM_SLAVES = 15 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG14      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG14_BASEADDR, C_S_AXI_RNG14_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG15      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG15_BASEADDR, C_S_AXI_RNG15_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;
        signal addr_hit_range14 : std_logic;
        signal addr_hit_range15 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range15 & addr_hit_range14 &
                    addr_hit_range13 & addr_hit_range12 &
                    addr_hit_range11 & addr_hit_range10 &
                    addr_hit_range9 & addr_hit_range8 &
                    addr_hit_range7 & addr_hit_range6 &
                    addr_hit_range5 & addr_hit_range4 &
                    addr_hit_range3 & addr_hit_range2 &
                    addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 14
-------------------------------------------------------------------------------

          RANGE14_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG14,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG14_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range14    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 15
-------------------------------------------------------------------------------

          RANGE15_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG15,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG15_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range15    -- [out]
              );


    end generate GEN_15_ADDR_RANGES;

-- ****************************************************************************
-- Address decoding logic when C_APB_NUM_SLAVES = 16
-- ****************************************************************************

    GEN_16_ADDR_RANGES : if C_APB_NUM_SLAVES = 16 generate

        constant DECODE_BITS_RNG1      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG1_BASEADDR, C_S_AXI_RNG1_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG2      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG2_BASEADDR, C_S_AXI_RNG2_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG3      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG3_BASEADDR, C_S_AXI_RNG3_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG4      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG4_BASEADDR, C_S_AXI_RNG4_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG5      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG5_BASEADDR, C_S_AXI_RNG5_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG6      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG6_BASEADDR, C_S_AXI_RNG6_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG7      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG7_BASEADDR, C_S_AXI_RNG7_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG8      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG8_BASEADDR, C_S_AXI_RNG8_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG9      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG9_BASEADDR, C_S_AXI_RNG9_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG10      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG10_BASEADDR, C_S_AXI_RNG10_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG11      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG11_BASEADDR, C_S_AXI_RNG11_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG12      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG12_BASEADDR, C_S_AXI_RNG12_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG13      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG13_BASEADDR, C_S_AXI_RNG13_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG14      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG14_BASEADDR, C_S_AXI_RNG14_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG15      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG15_BASEADDR, C_S_AXI_RNG15_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        constant DECODE_BITS_RNG16      : integer :=
                 Get_Addr_Bits(C_S_AXI_RNG16_BASEADDR, C_S_AXI_RNG16_HIGHADDR, C_S_AXI_ADDR_WIDTH);
        signal addr_hit_range1 : std_logic;
        signal addr_hit_range2 : std_logic;
        signal addr_hit_range3 : std_logic;
        signal addr_hit_range4 : std_logic;
        signal addr_hit_range5 : std_logic;
        signal addr_hit_range6 : std_logic;
        signal addr_hit_range7 : std_logic;
        signal addr_hit_range8 : std_logic;
        signal addr_hit_range9 : std_logic;
        signal addr_hit_range10 : std_logic;
        signal addr_hit_range11 : std_logic;
        signal addr_hit_range12 : std_logic;
        signal addr_hit_range13 : std_logic;
        signal addr_hit_range14 : std_logic;
        signal addr_hit_range15 : std_logic;
        signal addr_hit_range16 : std_logic;

    begin

-------------------------------------------------------------------------------
 -- Generation of slave select signal that is used for  assigning the
 -- PREADY, PSLVERR & PRDATA signals
-------------------------------------------------------------------------------

        sl_pselect  <= addr_hit_range16 & addr_hit_range15 &
                    addr_hit_range14 & addr_hit_range13 &
                    addr_hit_range12 & addr_hit_range11 &
                    addr_hit_range10 & addr_hit_range9 &
                    addr_hit_range8 & addr_hit_range7 &
                    addr_hit_range6 & addr_hit_range5 &
                    addr_hit_range4 & addr_hit_range3 &
                    addr_hit_range2 & addr_hit_range1;

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 1
-------------------------------------------------------------------------------

          RANGE1_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG1,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG1_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range1    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 2
-------------------------------------------------------------------------------

          RANGE2_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG2,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG2_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range2    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 3
-------------------------------------------------------------------------------

          RANGE3_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG3,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG3_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range3    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 4
-------------------------------------------------------------------------------

          RANGE4_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG4,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG4_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range4    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 5
-------------------------------------------------------------------------------

          RANGE5_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG5,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG5_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range5    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 6
-------------------------------------------------------------------------------

          RANGE6_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG6,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG6_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range6    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 7
-------------------------------------------------------------------------------

          RANGE7_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG7,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG7_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range7    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 8
-------------------------------------------------------------------------------

          RANGE8_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG8,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG8_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range8    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 9
-------------------------------------------------------------------------------

          RANGE9_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG9,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG9_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range9    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 10
-------------------------------------------------------------------------------

          RANGE10_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG10,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG10_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range10    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 11
-------------------------------------------------------------------------------

          RANGE11_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG11,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG11_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range11    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 12
-------------------------------------------------------------------------------

          RANGE12_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG12,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG12_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range12    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 13
-------------------------------------------------------------------------------

          RANGE13_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG13,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG13_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range13    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 14
-------------------------------------------------------------------------------

          RANGE14_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG14,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG14_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range14    -- [out]
              );
-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 15
-------------------------------------------------------------------------------

          RANGE15_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG15,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG15_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range15    -- [out]
              );

-------------------------------------------------------------------------------
 -- Instantiate the basic address decoder pselect_f from proc_common
 -- library v4_0 for Range 16
-------------------------------------------------------------------------------

          RANGE16_SELECT: entity axi_apb_bridge_v3_0_17.pselect_f
              generic map
              (
                  C_AB     => DECODE_BITS_RNG16,
                  C_AW     => C_S_AXI_ADDR_WIDTH,
                  C_BAR    => C_S_AXI_RNG16_BASEADDR,
                  C_FAMILY => C_FAMILY
              )
              port map
              (
                  A        => Address,           -- [in]
                  AValid   => addr_is_valid,     -- [in]
                  CS       => addr_hit_range16    -- [out]
              );

    end generate GEN_16_ADDR_RANGES;

end architecture RTL;


-------------------------------------------------------------------------------
-- multiplexor.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2009-2012 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ****************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        multiplexor.vhd
-- Version:         v1.01a
-- Description:     The multiplexor module multiplexes APB signals from
--                  different APB slaves depending on the selected APB slave.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
library IEEE;
use     IEEE.std_logic_1164.all;
use     IEEE.std_logic_unsigned.all;
use     IEEE.numeric_std.all;

entity multiplexor is
  generic (

    C_M_APB_DATA_WIDTH  : integer range 32 to 32   := 32;
    C_APB_NUM_SLAVES    : integer range 1 to 16    := 4
        );

  port (
    M_APB_PCLK          : in std_logic;
    M_APB_PRESETN       : in std_logic;
    M_APB_PREADY        : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    M_APB_PRDATA1       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA2       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA3       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA4       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA5       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA6       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA7       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA8       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA9       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA10      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA11      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA12      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA13      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA14      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA15      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PRDATA16      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PSLVERR       : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    M_APB_PSEL          : out std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    PSEL_i              : in  std_logic;
    apb_pslverr         : out std_logic;
    apb_pready          : out std_logic;
    apb_prdata          : out std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    sl_pselect          : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0)
    );

end entity multiplexor;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of multiplexor is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

     signal M_APB_PSEL_i : std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);

begin

     M_APB_PSEL <= M_APB_PSEL_i;

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 1
-- ****************************************************************************

    GEN_1_SELECT_SLAVE : if C_APB_NUM_SLAVES = 1 generate
    begin

-------------------------------------------------------------------------------
 -- PSLVERR, PREADY, PRDATA are directly assigned as only one slave is on APB
-------------------------------------------------------------------------------

         apb_pslverr <= M_APB_PSLVERR(0);
         apb_pready <= M_APB_PREADY(0);
         apb_prdata <= M_APB_PRDATA1;

-------------------------------------------------------------------------------
 -- Slave select signal is assigned after decoding the address
-------------------------------------------------------------------------------

        PSEL_1_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i(0) <= PSEL_i;
                end if;
            end if;
        end process PSEL_1_PROCESS;

    end generate GEN_1_SELECT_SLAVE;

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 2
-- ****************************************************************************

    GEN_2_SELECT_SLAVE : if C_APB_NUM_SLAVES = 2 generate

        signal pselect_i     : std_logic_vector(1 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_2_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is                        
                        when "10" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "01" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_2_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_2_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "01" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_2_SL_SIGNALS;

    end generate GEN_2_SELECT_SLAVE;

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 3
-- ****************************************************************************

    GEN_3_SELECT_SLAVE : if C_APB_NUM_SLAVES = 3 generate

        signal pselect_i     : std_logic_vector(2 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_3_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_3_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_3_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_3_SL_SIGNALS;

    end generate GEN_3_SELECT_SLAVE;

-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 4
-- ****************************************************************************

    GEN_4_SELECT_SLAVE : if C_APB_NUM_SLAVES = 4 generate

        signal pselect_i     : std_logic_vector(3 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_4_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "1000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_4_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_4_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_4_SL_SIGNALS;

    end generate GEN_4_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 5
-- ****************************************************************************

    GEN_5_SELECT_SLAVE : if C_APB_NUM_SLAVES = 5 generate

        signal pselect_i     : std_logic_vector(4 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_5_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "10000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "01000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_5_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_5_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "01000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_5_SL_SIGNALS;

    end generate GEN_5_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 6
-- ****************************************************************************

    GEN_6_SELECT_SLAVE : if C_APB_NUM_SLAVES = 6 generate

        signal pselect_i     : std_logic_vector(5 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_6_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_6_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_6_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_6_SL_SIGNALS;

    end generate GEN_6_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 7
-- ****************************************************************************

    GEN_7_SELECT_SLAVE : if C_APB_NUM_SLAVES = 7 generate

        signal pselect_i     : std_logic_vector(6 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_7_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "1000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_7_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_7_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_7_SL_SIGNALS;

    end generate GEN_7_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 8
-- ****************************************************************************

    GEN_8_SELECT_SLAVE : if C_APB_NUM_SLAVES = 8 generate

        signal pselect_i     : std_logic_vector(7 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_8_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "10000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "01000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "00100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "00010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "00001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_8_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_8_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "01000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "00100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "00010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "00001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_8_SL_SIGNALS;

    end generate GEN_8_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 9
-- ****************************************************************************

    GEN_9_SELECT_SLAVE : if C_APB_NUM_SLAVES = 9 generate

        signal pselect_i     : std_logic_vector(8 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_9_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_9_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_9_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_9_SL_SIGNALS;

    end generate GEN_9_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 10
-- ****************************************************************************

    GEN_10_SELECT_SLAVE : if C_APB_NUM_SLAVES = 10 generate

        signal pselect_i     : std_logic_vector(9 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_10_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "1000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "0100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "0010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "0001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_10_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_10_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "0100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "0010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "0001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_10_SL_SIGNALS;

    end generate GEN_10_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 11
-- ****************************************************************************

    GEN_11_SELECT_SLAVE : if C_APB_NUM_SLAVES = 11 generate

        signal pselect_i     : std_logic_vector(10 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_11_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "10000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "01000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "00100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "00010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "00001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "00000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "00000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "00000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_11_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_11_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "01000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "00100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "00010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "00001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "00000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "00000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "00000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_11_SL_SIGNALS;

    end generate GEN_11_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 12
-- ****************************************************************************

    GEN_12_SELECT_SLAVE : if C_APB_NUM_SLAVES = 12 generate

        signal pselect_i     : std_logic_vector(11 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_12_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_12_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_12_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_12_SL_SIGNALS;

    end generate GEN_12_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 13
-- ****************************************************************************

    GEN_13_SELECT_SLAVE : if C_APB_NUM_SLAVES = 13 generate

        signal pselect_i     : std_logic_vector(12 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_13_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                   M_APB_PSEL_i <= (others => '0');
                   case pselect_i is
                        when "1000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "0100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "0010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "0001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "0000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "0000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "0000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_13_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_13_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "0100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "0010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "0001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "0000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "0000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "0000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_13_SL_SIGNALS;

    end generate GEN_13_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 14
-- ****************************************************************************

    GEN_14_SELECT_SLAVE : if C_APB_NUM_SLAVES = 14 generate

        signal pselect_i     : std_logic_vector(13 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_14_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "10000000000000" =>
                            M_APB_PSEL_i(13) <= PSEL_i;
                        when "01000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "00100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "00010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "00001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "00000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "00000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "00000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "00000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "00000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "00000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "00000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "00000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "00000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_14_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_14_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA14,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "10000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(13);
                    apb_pready <= M_APB_PREADY(13);
                    apb_prdata <= M_APB_PRDATA14;
                when "01000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "00100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "00010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "00001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "00000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "00000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "00000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "00000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "00000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "00000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "00000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "00000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "00000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_14_SL_SIGNALS;

    end generate GEN_14_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 15
-- ****************************************************************************

    GEN_15_SELECT_SLAVE : if C_APB_NUM_SLAVES = 15 generate

        signal pselect_i     : std_logic_vector(14 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_15_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others => '0');
                    case pselect_i is
                        when "100000000000000" =>
                            M_APB_PSEL_i(14) <= PSEL_i;
                        when "010000000000000" =>
                            M_APB_PSEL_i(13) <= PSEL_i;
                        when "001000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "000100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "000010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "000001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "000000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "000000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "000000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "000000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "000000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "000000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "000000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "000000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "000000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others => '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_15_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_15_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA15,
                                    M_APB_PRDATA14,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "100000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(14);
                    apb_pready <= M_APB_PREADY(14);
                    apb_prdata <= M_APB_PRDATA15;
                when "010000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(13);
                    apb_pready <= M_APB_PREADY(13);
                    apb_prdata <= M_APB_PRDATA14;
                when "001000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "000100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "000010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "000001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "000000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "000000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "000000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "000000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "000000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "000000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "000000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "000000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "000000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_15_SL_SIGNALS;

    end generate GEN_15_SELECT_SLAVE;
-- ****************************************************************************
-- Multiplexing logic when C_APB_NUM_SLAVES = 16
-- ****************************************************************************

    GEN_16_SELECT_SLAVE : if C_APB_NUM_SLAVES = 16 generate

        signal pselect_i     : std_logic_vector(15 downto 0);

    begin

-------------------------------------------------------------------------------
 -- pselect_i assignment.
-------------------------------------------------------------------------------
      
        pselect_i <= sl_pselect;

-------------------------------------------------------------------------------
 -- Process for the generation of PSEL depending on the selected slave.
-------------------------------------------------------------------------------
        PSEL_16_PROCESS : process (M_APB_PCLK ) is
        begin
            if (M_APB_PCLK'event and M_APB_PCLK = '1') then
                if (M_APB_PRESETN = '0') then
                    M_APB_PSEL_i <= (others => '0');
                else
                    M_APB_PSEL_i <= (others=> '0');
                    case pselect_i is
                        when "1000000000000000" =>
                            M_APB_PSEL_i(15) <= PSEL_i;
                        when "0100000000000000" =>
                            M_APB_PSEL_i(14) <= PSEL_i;
                        when "0010000000000000" =>
                            M_APB_PSEL_i(13) <= PSEL_i;
                        when "0001000000000000" =>
                            M_APB_PSEL_i(12) <= PSEL_i;
                        when "0000100000000000" =>
                            M_APB_PSEL_i(11) <= PSEL_i;
                        when "0000010000000000" =>
                            M_APB_PSEL_i(10) <= PSEL_i;
                        when "0000001000000000" =>
                            M_APB_PSEL_i(9) <= PSEL_i;
                        when "0000000100000000" =>
                            M_APB_PSEL_i(8) <= PSEL_i;
                        when "0000000010000000" =>
                            M_APB_PSEL_i(7) <= PSEL_i;
                        when "0000000001000000" =>
                            M_APB_PSEL_i(6) <= PSEL_i;
                        when "0000000000100000" =>
                            M_APB_PSEL_i(5) <= PSEL_i;
                        when "0000000000010000" =>
                            M_APB_PSEL_i(4) <= PSEL_i;
                        when "0000000000001000" =>
                            M_APB_PSEL_i(3) <= PSEL_i;
                        when "0000000000000100" =>
                            M_APB_PSEL_i(2) <= PSEL_i;
                        when "0000000000000010" =>
                            M_APB_PSEL_i(1) <= PSEL_i;
                        when "0000000000000001" =>
                            M_APB_PSEL_i(0) <= PSEL_i;
                    -- coverage off
                       when others =>
                            M_APB_PSEL_i <= (others=> '0');
                    -- coverage on
                    end case;
                end if;
            end if;
        end process PSEL_16_PROCESS;

-------------------------------------------------------------------------------
 -- Combo for the generation of PSLVERR, PREADY, PRDATA depending on the
 -- selected slave.
-------------------------------------------------------------------------------
        MUX_16_SL_SIGNALS : process (pselect_i,
                                    M_APB_PSLVERR,
                                    M_APB_PREADY,
                                    M_APB_PRDATA16,
                                    M_APB_PRDATA15,
                                    M_APB_PRDATA14,
                                    M_APB_PRDATA13,
                                    M_APB_PRDATA12,
                                    M_APB_PRDATA11,
                                    M_APB_PRDATA10,
                                    M_APB_PRDATA9,
                                    M_APB_PRDATA8,
                                    M_APB_PRDATA7,
                                    M_APB_PRDATA6,
                                    M_APB_PRDATA5,
                                    M_APB_PRDATA4,
                                    M_APB_PRDATA3,
                                    M_APB_PRDATA2,
                                    M_APB_PRDATA1) is
        begin
            case pselect_i is
                when "1000000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(15);
                    apb_pready <= M_APB_PREADY(15);
                    apb_prdata <= M_APB_PRDATA16;
                when "0100000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(14);
                    apb_pready <= M_APB_PREADY(14);
                    apb_prdata <= M_APB_PRDATA15;
                when "0010000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(13);
                    apb_pready <= M_APB_PREADY(13);
                    apb_prdata <= M_APB_PRDATA14;
                when "0001000000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(12);
                    apb_pready <= M_APB_PREADY(12);
                    apb_prdata <= M_APB_PRDATA13;
                when "0000100000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(11);
                    apb_pready <= M_APB_PREADY(11);
                    apb_prdata <= M_APB_PRDATA12;
                when "0000010000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(10);
                    apb_pready <= M_APB_PREADY(10);
                    apb_prdata <= M_APB_PRDATA11;
                when "0000001000000000" =>
                    apb_pslverr <= M_APB_PSLVERR(9);
                    apb_pready <= M_APB_PREADY(9);
                    apb_prdata <= M_APB_PRDATA10;
                when "0000000100000000" =>
                    apb_pslverr <= M_APB_PSLVERR(8);
                    apb_pready <= M_APB_PREADY(8);
                    apb_prdata <= M_APB_PRDATA9;
                when "0000000010000000" =>
                    apb_pslverr <= M_APB_PSLVERR(7);
                    apb_pready <= M_APB_PREADY(7);
                    apb_prdata <= M_APB_PRDATA8;
                when "0000000001000000" =>
                    apb_pslverr <= M_APB_PSLVERR(6);
                    apb_pready <= M_APB_PREADY(6);
                    apb_prdata <= M_APB_PRDATA7;
                when "0000000000100000" =>
                    apb_pslverr <= M_APB_PSLVERR(5);
                    apb_pready <= M_APB_PREADY(5);
                    apb_prdata <= M_APB_PRDATA6;
                when "0000000000010000" =>
                    apb_pslverr <= M_APB_PSLVERR(4);
                    apb_pready <= M_APB_PREADY(4);
                    apb_prdata <= M_APB_PRDATA5;
                when "0000000000001000" =>
                    apb_pslverr <= M_APB_PSLVERR(3);
                    apb_pready <= M_APB_PREADY(3);
                    apb_prdata <= M_APB_PRDATA4;
                when "0000000000000100" =>
                    apb_pslverr <= M_APB_PSLVERR(2);
                    apb_pready <= M_APB_PREADY(2);
                    apb_prdata <= M_APB_PRDATA3;
                when "0000000000000010" =>
                    apb_pslverr <= M_APB_PSLVERR(1);
                    apb_pready <= M_APB_PREADY(1);
                    apb_prdata <= M_APB_PRDATA2;
                when "0000000000000001" =>
                    apb_pslverr <= M_APB_PSLVERR(0);
                    apb_pready <= M_APB_PREADY(0);
                    apb_prdata <= M_APB_PRDATA1;
            -- coverage off
               when others =>
                    apb_pslverr <= '0';
                    apb_pready <= '0';
                    apb_prdata <= (others => '0');
            -- coverage on
            end case;
        end process MUX_16_SL_SIGNALS;

    end generate GEN_16_SELECT_SLAVE;
end architecture RTL;


-------------------------------------------------------------------------------
-- axilite_slif.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2009-2012 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ****************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        axilite_slif.vhd
-- Version:         v1.01a
-- Description:     The AXI4-Lite Slave Interface module provides a
--                  bi-directional slave interface to the AXI. The AXI data
--                  bus width is always fixed to 32-bits. When both write and
--                  read transfers are simultaneously requested on AXI4-Lite,
--                  read requestis given more priority than write request.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library lib_pkg_v1_0_2;
use lib_pkg_v1_0_2.lib_pkg.clog2;
library axi_apb_bridge_v3_0_17;
use axi_apb_bridge_v3_0_17.counter_f;

entity axilite_sif is
  generic (
    C_FAMILY              : string                   := "virtex7";
    C_S_AXI_ADDR_WIDTH    : integer range 1 to 64   := 32;
    C_S_AXI_DATA_WIDTH    : integer range 32 to 32   := 32;
    C_DPHASE_TIMEOUT      : integer range 0 to 256   := 0;
    C_M_APB_PROTOCOL      : string                   := "apb3"
    );
  port (
  -- AXI Signals
    S_AXI_ACLK       : in  std_logic;
    S_AXI_ARESETN    : in  std_logic;

    S_AXI_AWADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT     : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID    : in  std_logic;
    S_AXI_AWREADY    : out std_logic;
    S_AXI_WVALID     : in  std_logic;
    S_AXI_WREADY     : out std_logic;
    S_AXI_BRESP      : out std_logic_vector(1 downto 0);
    S_AXI_BVALID     : out std_logic;
    S_AXI_BREADY     : in  std_logic;

    S_AXI_ARADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID    : in  std_logic;
    S_AXI_ARREADY    : out std_logic;
    S_AXI_RDATA      : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP      : out std_logic_vector(1 downto 0);
    S_AXI_RVALID     : out std_logic;
    S_AXI_RREADY     : in  std_logic;

  -- Signals from other modules
    axi_awprot       : out  std_logic_vector(2 downto 0);
    address          : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    apb_rd_request   : out std_logic;
    apb_wr_request   : out std_logic;
    dphase_timeout   : out std_logic;
    apb_pready       : in  std_logic;
    apb_enable       : in  std_logic;
    slv_err_resp     : in  std_logic;
    rd_data          : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)
    );

end entity axilite_sif;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axilite_sif is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

-------------------------------------------------------------------------------
-- This function generates the number of address bits to be compared depending
-- upon the selected base and high addresses.
-------------------------------------------------------------------------------

    type  AXI_SM_TYPE is (AXI_IDLE,
                          WRITE,
                          WRITE_W_WAIT,
                          WRITE_WAIT,
                          WR_RESP,
                          READ,
                          READ_WAIT,
                          RD_RESP);

-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

    signal axi_wr_rd_ns   : AXI_SM_TYPE;
    signal axi_wr_rd_cs   : AXI_SM_TYPE;

    signal ARREADY_i      : std_logic;
    signal WREADY_i       : std_logic;
    signal AWREADY_i      : std_logic;
    signal BVALID_i       : std_logic;
    signal BRESP_1_i      : std_logic;
    signal RVALID_i       : std_logic;
    signal RRESP_1_i      : std_logic;

    signal write_ready_sm : std_logic;
    signal waddr_ready_sm : std_logic;
    signal arready_sm     : std_logic;
    signal BVALID_sm      : std_logic;
    signal RVALID_sm      : std_logic;

    signal load_cntr      : std_logic;
    signal data_timeout   : std_logic;
    signal both_valids    : std_logic;
    signal address_i      : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal send_rd        : std_logic;
    signal send_wr_resp   : std_logic;
    signal cntr_enable    : std_logic;
    signal wr_request     : std_logic;
    signal rd_request     : std_logic;
    
-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- I/O signal assignments
-------------------------------------------------------------------------------

    S_AXI_AWREADY         <= AWREADY_i;

    S_AXI_WREADY          <= WREADY_i;

    S_AXI_BRESP(0)        <= '0';
    S_AXI_BRESP(1)        <= BRESP_1_i;
    S_AXI_BVALID          <= BVALID_i;

    S_AXI_ARREADY         <= ARREADY_i;

    S_AXI_RRESP(0)        <= '0';
    S_AXI_RRESP(1)        <= RRESP_1_i;
    S_AXI_RVALID          <= RVALID_i;

-------------------------------------------------------------------------------
-- Data phase timeout to APB, read and write request assignments
-------------------------------------------------------------------------------

    dphase_timeout <= data_timeout;
    apb_rd_request <= rd_request;
    apb_wr_request <= wr_request;

-------------------------------------------------------------------------------
-- Address generation for generating slave select
-------------------------------------------------------------------------------

   ADDR_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             address_i <= (others => '0');
          else
             if (waddr_ready_sm = '1') then
                   address_i <= S_AXI_AWADDR;
             elsif (rd_request = '1') then
                   address_i <= S_AXI_ARADDR;
             end if;
          end if;
      end if;
   end process ADDR_REG;

-------------------------------------------------------------------------------
-- Address assignment for saving one cycle
-------------------------------------------------------------------------------

    address <= S_AXI_ARADDR when rd_request = '1' else
               S_AXI_AWADDR when waddr_ready_sm = '1' else
               address_i;

-- ****************************************************************************
-- This generate is used when APB3 is selected
-- ****************************************************************************

    GEN_APB3_WRITE_PROT : if C_M_APB_PROTOCOL = "apb3" generate

       axi_awprot <= (others => '0');

    end generate GEN_APB3_WRITE_PROT; 
-- ****************************************************************************
-- This generate is used when APB4 is selected
-- ****************************************************************************

    GEN_APB4_WRITE_PROT : if C_M_APB_PROTOCOL = "apb4" generate

            signal awprot : std_logic_vector(2 downto 0);
    begin
  
-------------------------------------------------------------------------------
-- Write PROT generation for APB
-------------------------------------------------------------------------------

        axi_awprot <= S_AXI_AWPROT when both_valids = '1' else awprot; 
    
-- ****************************************************************************
-- This process is used for registering the AXI protection when a write 
-- is requested. 
-- ****************************************************************************

       AXI_WRITE_PROT_REG : process(S_AXI_ACLK) is
       begin
          if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
              if (S_AXI_ARESETN = '0') then
                 awprot <= (others => '0');
              else
                 if (waddr_ready_sm = '1') then
                       awprot <= S_AXI_AWPROT;
                 end if;
              end if;
          end if;
       end process AXI_WRITE_PROT_REG;
   
   end generate GEN_APB4_WRITE_PROT;

-- ****************************************************************************
-- This process is used for registering the APB read data that needs to be
-- sent on AXI
-- ****************************************************************************

    RD_RESP_REG : process(S_AXI_ACLK) is
    begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             RRESP_1_i <= '0';
          else
             if (send_rd = '1') then
                 RRESP_1_i <= slv_err_resp;
             elsif (S_AXI_RREADY = '1') then
                 RRESP_1_i <= '0';
             end if;
          end if;
      end if;
   end process RD_RESP_REG;

-- ****************************************************************************
-- This process is used for registering Read response
-- ****************************************************************************

    RD_DATA_REG : process(S_AXI_ACLK) is
    begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             S_AXI_RDATA <= (others => '0');
          else
             if (send_rd = '1') then
                 S_AXI_RDATA <= rd_data;
             elsif (S_AXI_RREADY = '1') then
                 S_AXI_RDATA <= (others => '0');
             end if;
          end if;
      end if;
   end process RD_DATA_REG;

-- ****************************************************************************
-- This process is used for registering Write response
-- ****************************************************************************

   WR_RESP_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             BRESP_1_i <= '0';
          else
             if (send_wr_resp = '1') then
                 BRESP_1_i <= slv_err_resp;
             elsif (S_AXI_BREADY = '1') then
                 BRESP_1_i <= '0';
             end if;
          end if;
      end if;
   end process WR_RESP_REG;

-------------------------------------------------------------------------------
-- FSM
-------------------------------------------------------------------------------
-- ****************************************************************************
-- AXI Write Read State Machine -- START
-- ****************************************************************************

   AXI_WR_RD_SM   : process (axi_wr_rd_cs,
                             S_AXI_AWVALID,
                             S_AXI_WVALID,
                             S_AXI_BREADY,
                             S_AXI_ARVALID,
                             S_AXI_RREADY,
                             apb_pready,
                             apb_enable,
                             data_timeout
                             ) is
   begin

      axi_wr_rd_ns <= axi_wr_rd_cs;
      write_ready_sm <= '0';
      waddr_ready_sm <= '0';
      wr_request <= '0';
      rd_request <= '0';
      BVALID_sm <= '0';
      RVALID_sm <= '0';
      arready_sm <= '0';
      load_cntr <= '0';
      both_valids <= '0';
      send_rd <= '0';
      send_wr_resp <= '0';
      cntr_enable <= '0';

      case axi_wr_rd_cs is

           when AXI_IDLE =>
                if (S_AXI_ARVALID = '1') then
                     rd_request <= '1';
                     load_cntr <= '1';
                     arready_sm <= '1';
                     axi_wr_rd_ns <= READ_WAIT;
                elsif(S_AXI_AWVALID = '1' and
                      S_AXI_WVALID = '1') then
                     write_ready_sm <= '1';
                     waddr_ready_sm <= '1';
                     wr_request <= '1';
                     both_valids <= '1';
                     load_cntr <= '1';
                     axi_wr_rd_ns <= WRITE_WAIT;
                elsif(S_AXI_AWVALID = '1') then
                     waddr_ready_sm <= '1';
                     axi_wr_rd_ns <= WRITE_W_WAIT;
                end if;

           when WRITE_WAIT =>
                cntr_enable <= '1';
                axi_wr_rd_ns <= WRITE;

           when WRITE_W_WAIT =>
                if(S_AXI_WVALID = '1') then
                     write_ready_sm <= '1';
                     wr_request <= '1';
                     load_cntr <= '1';
                     axi_wr_rd_ns <= WRITE;
                end if;

           when WRITE =>
                cntr_enable <= '1';
                if((apb_pready = '1' and apb_enable = '1') or data_timeout = '1') then
                     cntr_enable <= '0';
                     send_wr_resp <= '1';
                     BVALID_sm <= '1';
                     axi_wr_rd_ns <= WR_RESP;
                end if;

           when WR_RESP =>
                if (S_AXI_BREADY = '1') then
                    axi_wr_rd_ns <= AXI_IDLE;
                else
                    BVALID_sm <= '1';
                end if;

           when READ_WAIT =>
                cntr_enable <= '1';
                axi_wr_rd_ns <= READ;

           when READ =>
                cntr_enable <= '1';
                if((apb_pready = '1' and apb_enable = '1') or data_timeout = '1') then
                     cntr_enable <= '0';
                     RVALID_sm <= '1';
                     send_rd <= '1';
                     axi_wr_rd_ns <= RD_RESP;
                end if;

           when RD_RESP =>                
                if(S_AXI_RREADY = '1') then
                     if(S_AXI_AWVALID = '1' and
                        S_AXI_WVALID = '1') then
                          write_ready_sm <= '1';
                          waddr_ready_sm <= '1';
                          wr_request <= '1';
                          load_cntr <= '1';
                          both_valids <= '1';
                          axi_wr_rd_ns <= WRITE_WAIT;
                     elsif(S_AXI_AWVALID = '1') then
                          waddr_ready_sm <= '1';
                          axi_wr_rd_ns <= WRITE_W_WAIT;
                     else
                          axi_wr_rd_ns <= AXI_IDLE;
                     end if;
                else
                     RVALID_sm <= '1';
                end if;

          -- coverage off
           when others =>
                axi_wr_rd_ns <= AXI_IDLE;
          -- coverage on

       end case;

   end process AXI_WR_RD_SM;

-------------------------------------------------------------------------------
-- Registering the signals generated from the AXI_WR_RD_SM state machine
-------------------------------------------------------------------------------

   AXI_WR_DATA_SM_REG : process(S_AXI_ACLK) is
   begin
      if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
         if (S_AXI_ARESETN = '0') then
             axi_wr_rd_cs <= AXI_IDLE;
             ARREADY_i <= '0';
             WREADY_i <= '0';
             AWREADY_i <= '0';
             BVALID_i <= '0';
             RVALID_i <= '0';
         else
             axi_wr_rd_cs <= axi_wr_rd_ns;
             WREADY_i <= write_ready_sm;
             AWREADY_i <= waddr_ready_sm;
             ARREADY_i <= arready_sm;
             BVALID_i <= BVALID_sm;
             RVALID_i <= RVALID_sm;
         end if;
      end if;
   end process AXI_WR_DATA_SM_REG;
   
   -------------------------------------------------------------------------------
   -- This implements the dataphase watchdog timeout function. The counter is
   -- allowed to count down when an active APB operation is ongoing. A data 
   -- acknowledge from the target address space forces the counter to reload.
   -- When the APB is not responding and not generating apb_ready within the
   -- number of clock cycles mentioned in C_DPHASE_TIMEOUT, AXI generates
   -- ready so that AXI is not hung.
   ------------------------------------------------------------------------------- 
    
   DATA_PHASE_WDT : if (C_DPHASE_TIMEOUT /= 0) generate
    
    
       constant TIMEOUT_VALUE_TO_USE : integer := C_DPHASE_TIMEOUT;
       constant COUNTER_WIDTH        : Integer := clog2(TIMEOUT_VALUE_TO_USE);
       constant DPTO_LD_VALUE        : std_logic_vector(COUNTER_WIDTH-1 downto 0)
                                     := std_logic_vector(to_unsigned
                                        (TIMEOUT_VALUE_TO_USE-1,COUNTER_WIDTH));
       signal timeout_i              : std_logic;
       signal cntr_start             : std_logic;
       signal cntr_rst               : std_logic;
    
   begin
          
   
-- ****************************************************************************
-- This process is used for generating the counter enable
-- ****************************************************************************

   WR_RESP_REG : process(S_AXI_ACLK) is
   begin
       if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
          if (S_AXI_ARESETN = '0') then
             cntr_start <= '0';
          else
             if (load_cntr = '1') then
                 cntr_start <= '1';
             elsif (timeout_i = '1') then
                 cntr_start <= '0';
             end if;
          end if;
      end if;
   end process WR_RESP_REG;
   
   cntr_rst <= not S_AXI_ARESETN or timeout_i;
   
-- ****************************************************************************
-- Instantiation of counter from proc_common
-- ****************************************************************************

      I_DPTO_COUNTER : entity axi_apb_bridge_v3_0_17.counter_f
         generic map(
           C_NUM_BITS    =>  COUNTER_WIDTH,
           C_FAMILY      =>  C_FAMILY
             )
         port map(
           Clk           =>  S_AXI_ACLK,
           Rst           =>  cntr_rst,
           Load_In       =>  DPTO_LD_VALUE,
           Count_Enable  =>  cntr_enable,
           Count_Load    =>  load_cntr,
           Count_Down    =>  '1',
           Count_Out     =>  open,
           Carry_Out     =>  timeout_i
           );
       
-- ****************************************************************************
-- This process is used for registering data_timeout
-- ****************************************************************************

       REG_TIMEOUT : process(S_AXI_ACLK)
       begin
           if(S_AXI_ACLK'EVENT and S_AXI_ACLK='1')then
               if(S_AXI_ARESETN='0')then
                   data_timeout <= '0';
               else
                   if (data_timeout = '1') then
                       data_timeout <= '0';
                   elsif (timeout_i = '1' and apb_pready = '0') then
                       data_timeout <= '1';
                   end if;
               end if;
           end if;
       end process REG_TIMEOUT;
       
   end generate DATA_PHASE_WDT;
   
-- ****************************************************************************
-- No logic when C_DPHASE_TIMEOUT = 0
-- ****************************************************************************

   NO_DATA_PHASE_WDT : if (C_DPHASE_TIMEOUT = 0) generate
   begin
        data_timeout <= '0';
   end generate NO_DATA_PHASE_WDT;

end architecture RTL;


-------------------------------------------------------------------------------
-- apb_mif.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2009-2012 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ****************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        apb_mif.vhd
-- Version:         v1.01a
-- Description:     The APB Master Interface module provides a bi-directional
--                  APB master interface on the APB. This interface can be APB3
--                  or APB4 that supports M_APB_PSTRB and M_APB_PPROT signals.
--                  The APB data bus width is always fixed to 32-bits.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010   Initial version
-- ^^^^^^^
-- ~~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity apb_mif is
  generic (
    C_M_APB_ADDR_WIDTH   : integer range 1 to 64   := 32;
    C_M_APB_DATA_WIDTH   : integer range 32 to 32   := 32;
    C_S_AXI_DATA_WIDTH   : integer range 32 to 32   := 32;
    C_APB_NUM_SLAVES     : integer range 1 to 16    := 4;
    C_M_APB_PROTOCOL     : string                   := "apb3"

    );
  port (

  -- APB Signals
    M_APB_PCLK       : in std_logic;
    M_APB_PRESETN    : in std_logic;

    M_APB_PADDR      : out std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);
    M_APB_PENABLE    : out std_logic;
    M_APB_PWRITE     : out std_logic;
    M_APB_PWDATA     : out std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    M_APB_PSTRB      : out std_logic_vector
                           ((C_M_APB_DATA_WIDTH/8)-1 downto 0);
    M_APB_PPROT      : out std_logic_vector(2 downto 0);

  -- Signals from other modules
    apb_pslverr      : in  std_logic;
    apb_pready       : in  std_logic;
    apb_rd_request   : in  std_logic;
    apb_wr_request   : in  std_logic;
    dphase_timeout   : in  std_logic;
    apb_prdata       : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    rd_data          : out std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    slv_err_resp     : out std_logic;
    PSEL_i           : out std_logic;
    address          : in  std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);
    axi_awprot       : in  std_logic_vector(2 downto 0);

  -- AXI Signals
    S_AXI_WDATA      : in  std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB      : in  std_logic_vector
                           ((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_ARADDR     : in  std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT     : in  std_logic_vector(2 downto 0)
    );

end entity apb_mif;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of apb_mif is

-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";

    type  APB_SM_TYPE is (APB_IDLE,
                          APB_SETUP,
                          APB_ACCESS
                         );

-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------

    signal apb_wr_rd_ns   : APB_SM_TYPE;
    signal apb_wr_rd_cs   : APB_SM_TYPE;

    signal PENABLE_i      : std_logic;
    signal PWRITE_i       : std_logic;
    signal PWDATA_i       : std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    signal PADDR_i        : std_logic_vector(C_M_APB_ADDR_WIDTH-1 downto 0);

    signal apb_penable_sm : std_logic;
    signal drive_wr_0s    : std_logic;
    signal apb_psel_sm    : std_logic;

begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- APB I/O signal assignments
-------------------------------------------------------------------------------

    M_APB_PADDR           <= PADDR_i;
    M_APB_PENABLE         <= PENABLE_i;
    M_APB_PWRITE          <= PWRITE_i;
    M_APB_PWDATA          <= PWDATA_i;

-------------------------------------------------------------------------------
-- Internal signal assignments
-------------------------------------------------------------------------------

    PSEL_i <= apb_psel_sm;

-- ****************************************************************************
-- This process is used for registering the APB address when a write or a read
-- is requested. To reduce the power consumption the APB_PADDR signal is not
-- changed until a read is requested.
-- ****************************************************************************

   APB_ADDR_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
          if (M_APB_PRESETN = '0') then
             PADDR_i <= (others => '0');
          else
             if (apb_wr_request = '1') then
                   PADDR_i <= address;
             elsif (apb_rd_request = '1') then
                   PADDR_i <= S_AXI_ARADDR;
             end if;
          end if;
      end if;
   end process APB_ADDR_REG;

-- ****************************************************************************
-- This process is used for registering the APB write signal when a write is
-- requested. To reduce the power consumption the APB_PWRITE signal is not
-- changed until a read is requested.
-- ****************************************************************************

   APB_WRITE_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
          if (M_APB_PRESETN = '0') then
             PWRITE_i <= '0';
          else
             if (apb_wr_request = '1') then
                   PWRITE_i <= '1';
             elsif (apb_rd_request = '1') then
                   PWRITE_i <= '0';
             end if;
          end if;
      end if;
   end process APB_WRITE_REG;

-- ****************************************************************************
-- This process is used for registering the APB write data when a write is
-- requested.
-- ****************************************************************************

   APB_WR_DATA_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
          if (M_APB_PRESETN = '0') then
             PWDATA_i <= (others => '0');
          else
             if (apb_wr_request = '1') then
                   PWDATA_i <= S_AXI_WDATA;
             elsif (drive_wr_0s = '1') then
                   PWDATA_i <= (others => '0');
             end if;
          end if;
      end if;
   end process APB_WR_DATA_REG;


-- ****************************************************************************
-- This generate is used when APB3 is selected
-- ****************************************************************************

    GEN_APB3_STRBS_PROT : if C_M_APB_PROTOCOL = "apb3" generate
        M_APB_PSTRB          <= (others => '1');
        M_APB_PPROT          <= (others => '0');
    end generate GEN_APB3_STRBS_PROT;
-- ****************************************************************************
-- This generate is used when APB4 is selected
-- ****************************************************************************

    GEN_APB4_STRBS_PROT : if C_M_APB_PROTOCOL = "apb4" generate

            signal PSTRB_i        : std_logic_vector
                                    ((C_M_APB_DATA_WIDTH/8)-1 downto 0);
            signal PPROT_i         : std_logic_vector(2 downto 0);
    begin

-------------------------------------------------------------------------------
-- APB STRB/PROT signal assignments
-------------------------------------------------------------------------------

        M_APB_PSTRB          <= PSTRB_i;
        M_APB_PPROT          <= PPROT_i;

-- ****************************************************************************
-- This process is used for registering the APB write strobes when a write is
-- requested.
-- ****************************************************************************

       APB_WR_STRB_REG : process(M_APB_PCLK) is
       begin
          if (M_APB_PCLK'event and M_APB_PCLK = '1') then
              if (M_APB_PRESETN = '0') then
                 PSTRB_i <= (others => '0');
              else
                 if (apb_wr_request = '1') then
                       PSTRB_i <= S_AXI_WSTRB;
                 elsif (drive_wr_0s = '1') then
                       PSTRB_i <= (others => '0');
                 end if;
              end if;
          end if;
       end process APB_WR_STRB_REG;

-- ****************************************************************************
-- This process is used for driving the APB PROT when a write or a read
-- is requested. To reduce the power consumption the APB_PPROT signal is not
-- changed until a read is requested.
-- ****************************************************************************

       APB_PROT_REG : process(M_APB_PCLK) is
       begin
          if (M_APB_PCLK'event and M_APB_PCLK = '1') then
              if (M_APB_PRESETN = '0') then
                 PPROT_i <= (others => '0');
              else
                 if (apb_wr_request = '1') then
                       PPROT_i <= axi_awprot;
                 elsif (apb_rd_request = '1') then
                       PPROT_i <= S_AXI_ARPROT;
                 end if;
              end if;
          end if;
       end process APB_PROT_REG;

   end generate GEN_APB4_STRBS_PROT;

-- ****************************************************************************
-- APB State Machine -- START
-- ****************************************************************************

   APB_WR_RD_SM   : process (apb_wr_rd_cs,
                             apb_wr_request,
                             apb_rd_request,
                             apb_pslverr,
                             apb_pready,
                             apb_prdata,
                             dphase_timeout
                            ) is
   begin

     apb_wr_rd_ns <= apb_wr_rd_cs;
     apb_penable_sm <= '0';
     rd_data <= (others => '0');
     slv_err_resp <= '0';
     drive_wr_0s <= '0';
     apb_psel_sm <= '0';

      case apb_wr_rd_cs is

           when APB_IDLE =>
                if(apb_wr_request = '1' or
                   apb_rd_request = '1') then
                     apb_psel_sm <= '1';
                     apb_wr_rd_ns <= APB_SETUP;
                end if;

           when APB_SETUP =>
                     apb_psel_sm <= '1';
                     apb_penable_sm <= '1';
                     apb_wr_rd_ns <= APB_ACCESS;

           when APB_ACCESS =>
                if(apb_pready = '1') then
                     drive_wr_0s <= '1';
                     slv_err_resp <= apb_pslverr;
                     rd_data <= apb_prdata;
                     apb_wr_rd_ns <= APB_IDLE;
                elsif (dphase_timeout = '1') then
                     drive_wr_0s  <= '1';
                     slv_err_resp <= '1';    --Added error response when timeout
                     apb_wr_rd_ns <= APB_IDLE;
                else
                     apb_psel_sm <= '1';
                     apb_penable_sm <= '1';
                end if;
                
          -- coverage off
            when others =>
                apb_wr_rd_ns <= APB_IDLE;
          -- coverage on

       end case;

   end process APB_WR_RD_SM;

-------------------------------------------------------------------------------
-- Registering the signals generated from the APB state machine
-------------------------------------------------------------------------------

   APB_WR_RD_SM_REG : process(M_APB_PCLK) is
   begin
      if (M_APB_PCLK'event and M_APB_PCLK = '1') then
         if (M_APB_PRESETN = '0') then
           apb_wr_rd_cs <= APB_IDLE;
           PENABLE_i <= '0';
         else
           apb_wr_rd_cs <= apb_wr_rd_ns;
           PENABLE_i <= apb_penable_sm;
         end if;
      end if;
   end process APB_WR_RD_SM_REG;

end architecture RTL;


-------------------------------------------------------------------------------
-- axi_apb_bridge.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2009-2012 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ****************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        axi_apb_bridge.vhd
-- Version:         v1.01a
-- Description:     The AXI to APB Bridge module translates AXI
--                  transactions into APB transactions. It functions as a
--                  AXI slave on the AXI port and an APB master on
--                  the APB interface.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Author:      USM
-- History:
--   USM      07/30/2010   Initial version
-- ^^^^^^^
--   NLR      01/05/2012   Added the multiple slave support in RTL
-- ~~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library axi_apb_bridge_v3_0_17;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
--
-- Definition of Generics
--
-- System Parameters
--
--  C_FAMILY                 -- FPGA Family for which the axi_apb_bridge is
--                           -- targeted
--  C_INSTANCE               -- Instance name of the axi_apb_bridge in the
--                           -- system
-- AXI Parameters
--
--  C_S_AXI_ADDR_WIDTH       -- Width of the AXI address bus (in bits)
--                              fixed to 32
--  C_S_AXI_DATA_WIDTH       -- Width of the AXI data bus (in bits)
--                              fixed to 32
--  C_BASEADDR               -- AXI Low address for address range 1
--  C_HIGHADDR               -- AXI high address for address range 1
--  C_S_AXI_RNG2_BASEADDR    -- AXI low address for address range 2    
--  C_S_AXI_RNG2_HIGHADDR    -- AXI high address for address range 2
--  C_S_AXI_RNG3_BASEADDR    -- AXI low address for address range 3 
--  C_S_AXI_RNG3_HIGHADDR    -- AXI high address for address range 3 
--  C_S_AXI_RNG4_BASEADDR    -- AXI low address for address range 4 
--  C_S_AXI_RNG4_HIGHADDR    -- AXI high address for address range 4 
--  C_S_AXI_RNG5_BASEADDR    -- AXI low address for address range 5 
--  C_S_AXI_RNG5_HIGHADDR    -- AXI high address for address range 5 
--  C_S_AXI_RNG6_BASEADDR    -- AXI low address for address range 6 
--  C_S_AXI_RNG6_HIGHADDR    -- AXI high address for address range 6 
--  C_S_AXI_RNG7_BASEADDR    -- AXI low address for address range 7  
--  C_S_AXI_RNG7_HIGHADDR    -- AXI high address for address range 7 
--  C_S_AXI_RNG8_BASEADDR    -- AXI low address for address range 8 
--  C_S_AXI_RNG8_HIGHADDR    -- AXI high address for address range 8 
--  C_S_AXI_RNG9_BASEADDR    -- AXI low address for address range 9 
--  C_S_AXI_RNG9_HIGHADDR    -- AXI high address for address range 9 
--  C_S_AXI_RNG10_BASEADDR   -- AXI low address for address range 10 
--  C_S_AXI_RNG10_HIGHADDR   -- AXI high address for address range 10 
--  C_S_AXI_RNG11_BASEADDR   -- AXI low address for address range 11 
--  C_S_AXI_RNG11_HIGHADDR   -- AXI high address for address range 11 
--  C_S_AXI_RNG12_BASEADDR   -- AXI low address for address range 12
--  C_S_AXI_RNG12_HIGHADDR   -- AXI high address for address range 12
--  C_S_AXI_RNG13_BASEADDR   -- AXI low address for address range 13 
--  C_S_AXI_RNG13_HIGHADDR   -- AXI high address for address range 13 
--  C_S_AXI_RNG14_BASEADDR   -- AXI low address for address range 14 
--  C_S_AXI_RNG14_HIGHADDR   -- AXI high address for address range 14 
--  C_S_AXI_RNG15_BASEADDR   -- AXI low address for address range 15 
--  C_S_AXI_RNG15_HIGHADDR   -- AXI high address for address range 15 
--  C_S_AXI_RNG16_BASEADDR   -- AXI low address for address range 16 
--  C_S_AXI_RNG16_HIGHADDR   -- AXI high address for address range 16 
--
-- APB Parameters
--
--  C_M_APB_ADDR_WIDTH       -- Width of the APB address bus (in bits)
--                              fixed to 32
--  C_M_APB_DATA_WIDTH       -- Width of the APB data bus (in bits)
--                              fixed to 32
--  C_APB_NUM_SLAVES         -- The number of APB slaves
--  C_M_APB_PROTOCOL         -- The type of APB interface APB3/APB4
--
-- Core Parameters
--
--  C_DPHASE_TIMEOUT         -- Data phase time out value
--
-- Definition of Ports
--
-- System signals
--
--  s_axi_aclk               -- AXI Clock
--  s_axi_aresetn            -- AXI Reset Signal - active low
--
-- AXI Write address channel signals
--  s_axi_awaddr             -- Write address bus - The write address bus gives
--                              the address of the first transfer in a write
--                              burst transaction - fixed to 32
--  s_axi_awprot             -- Protection type - This signal indicates the
--                              normal, privileged, or secure protection level
--                              of the transaction and whether the transaction
--                              is a data access or an instruction access
--  s_axi_awvalid            -- Write address valid - This signal indicates
--                              that valid write address & control information
--                              are available
--  s_axi_awready            -- Write address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals
--
-- AXI Write data channel signals
--
--  s_axi_wdata              -- Write data bus - fixed to 32
--  s_axi_wstrb              -- Write strobes - These signals indicates which
--                              byte lanes to update in memory
--  s_axi_wvalid             -- Write valid - This signal indicates that valid
--                              write data and strobes are available
--  s_axi_wready             -- Write ready - This signal indicates that the
--                              slave can accept the write data
-- AXI Write response channel signals
--
--  s_axi_bresp              -- Write response - This signal indicates the
--                              status of the write transaction
--  s_axi_bvalid             -- Write response valid - This signal indicates
--                              that a valid write response is available
--  s_axi_bready             -- Response ready - This signal indicates that
--                              the master can accept the response information
--
-- AXI Read address channel signals
--
--  s_axi_araddr             -- Read address - The read address bus gives the
--                              initial address of a read burst transaction
--  s_axi_arprot             -- Protection type - This signal provides
--                              protection unit information for the transaction
--  s_axi_arvalid            -- Read address valid - This signal indicates,
--                              when HIGH, that the read address and control
--                              information is valid and will remain stable
--                              until the address acknowledge signal,ARREADY,
--                              is high.
--  s_axi_arready            -- Read address ready - This signal indicates
--                              that the slave is ready to accept an address
--                              and associated control signals:
--
-- AXI Read data channel signals
--
--  s_axi_rdata              -- Read data bus - fixed to 32
--  s_axi_rresp              -- Read response - This signal indicates the
--                              status of the read transfer
--  s_axi_rvalid             -- Read valid - This signal indicates that the
--                              required read data is available and the read
--                              transfer can complete
--  s_axi_rready             -- Read ready - This signal indicates that the
--                              master can accept the read data and response
--                              information
-- APB signals
--  m_apb_pclk               -- APB Clock
--  m_apb_presetn            -- APB Reset Signal - active low
--  m_apb_paddr              -- APB address bus
--  m_apb_psel               -- Slave select signal
--  m_apb_penable            -- Enable signal indicates that the second and
--                              sub-sequent cycles of an APB transfer
--  m_apb_pwrite             -- Direction indicates an APB write access when
--                              high and an APB read access when low
--  m_apb_pwdata             -- APB write data
--  m_apb_pready             -- Ready, the APB slave uses this signal to
--                              extend an APB transfer
--  m_apb_prdata1            -- APB read data driven by slave 1
--  m_apb_prdata2            -- APB read data driven by slave 2
--  m_apb_prdata3            -- APB read data driven by slave 3
--  m_apb_prdata4            -- APB read data driven by slave 4
--  m_apb_prdata5            -- APB read data driven by slave 5
--  m_apb_prdata6            -- APB read data driven by slave 6
--  m_apb_prdata7            -- APB read data driven by slave 7
--  m_apb_prdata8            -- APB read data driven by slave 8
--  m_apb_prdata9            -- APB read data driven by slave 9
--  m_apb_prdata10           -- APB read data driven by slave 10
--  m_apb_prdata11           -- APB read data driven by slave 11
--  m_apb_prdata12           -- APB read data driven by slave 12
--  m_apb_prdata13           -- APB read data driven by slave 13
--  m_apb_prdata14           -- APB read data driven by slave 14
--  m_apb_prdata15           -- APB read data driven by slave 15
--  m_apb_prdata16           -- APB read data driven by slave 16
--  m_apb_pslverr            -- This signal indicates transfer failure
--  M_APB_PPROT              -- This signal indicates the normal,
--                              privileged, or secure protection level of the
--                              transaction and whether the transaction is a
--                              data access or an instruction access. Driven
--                              when APB4 is selected.
--  M_APB_PSTRB              -- Write strobes. This signal indicates which
--                              byte lanes to update during a write transfer.
--                              Write strobes must not be active during a
--                              read transfer.Driven when APB4 is selected.
-------------------------------------------------------------------------------
-- Generics & Signals Description
-------------------------------------------------------------------------------

entity axi_apb_bridge is
  generic (
    C_FAMILY              : string                    := "virtex7";
    C_INSTANCE            : string                    := "axi_apb_bridge_inst";

    C_S_AXI_ADDR_WIDTH    : integer range 1 to 64    := 32;
    C_S_AXI_DATA_WIDTH    : integer range 32 to 32    := 32;

    C_M_APB_ADDR_WIDTH    : integer range 1 to 64    := 32;
    C_M_APB_DATA_WIDTH    : integer range 32 to 32    := 32;
    C_APB_NUM_SLAVES      : integer range 1 to 16     := 4;
    C_M_APB_PROTOCOL      : string                    := "apb3";

    C_BASEADDR            : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_HIGHADDR            : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG2_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG2_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG3_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG3_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG4_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG4_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG5_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG5_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG6_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG6_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG7_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG7_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG8_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG8_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG9_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG9_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG10_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG10_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG11_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG11_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG12_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG12_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG13_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG13_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG14_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG14_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG15_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG15_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_S_AXI_RNG16_BASEADDR : std_logic_vector(0 to 63) := X"FFFFFFFFFFFFFFFF";
    C_S_AXI_RNG16_HIGHADDR : std_logic_vector(0 to 63) := X"0000000000000000";
    C_DPHASE_TIMEOUT      : integer range 0 to 256    := 0
    );
  port (
  -- AXI signals
    s_axi_aclk         : in  std_logic;
    s_axi_aresetn      : in  std_logic;

    s_axi_awaddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awprot       : in  std_logic_vector(2 downto 0);
    s_axi_awvalid      : in  std_logic;
    s_axi_awready      : out std_logic;
    s_axi_wdata        : in  std_logic_vector(31 downto 0);
    s_axi_wstrb        : in  std_logic_vector
                             (3 downto 0);
    s_axi_wvalid       : in  std_logic;
    s_axi_wready       : out std_logic;
    s_axi_bresp        : out std_logic_vector(1 downto 0);
    s_axi_bvalid       : out std_logic;
    s_axi_bready       : in  std_logic;

    s_axi_araddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arprot       : in  std_logic_vector(2 downto 0);
    s_axi_arvalid      : in  std_logic;
    s_axi_arready      : out std_logic;
    s_axi_rdata        : out std_logic_vector(31 downto 0);
    s_axi_rresp        : out std_logic_vector(1 downto 0);
    s_axi_rvalid       : out std_logic;
    s_axi_rready       : in  std_logic;

-- APB signals
    m_apb_paddr        : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    m_apb_psel         : out std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    m_apb_penable      : out std_logic;
    m_apb_pwrite       : out std_logic;
    m_apb_pwdata       : out std_logic_vector(31 downto 0);
    m_apb_pready       : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    m_apb_prdata       : in  std_logic_vector(31 downto 0);
    m_apb_prdata2      : in  std_logic_vector(31 downto 0);
    m_apb_prdata3      : in  std_logic_vector(31 downto 0);
    m_apb_prdata4      : in  std_logic_vector(31 downto 0);
    m_apb_prdata5      : in  std_logic_vector(31 downto 0);
    m_apb_prdata6      : in  std_logic_vector(31 downto 0);
    m_apb_prdata7      : in  std_logic_vector(31 downto 0);
    m_apb_prdata8      : in  std_logic_vector(31 downto 0);
    m_apb_prdata9      : in  std_logic_vector(31 downto 0);
    m_apb_prdata10     : in  std_logic_vector(31 downto 0);
    m_apb_prdata11     : in  std_logic_vector(31 downto 0);
    m_apb_prdata12     : in  std_logic_vector(31 downto 0);
    m_apb_prdata13     : in  std_logic_vector(31 downto 0);
    m_apb_prdata14     : in  std_logic_vector(31 downto 0);
    m_apb_prdata15     : in  std_logic_vector(31 downto 0);
    m_apb_prdata16     : in  std_logic_vector(31 downto 0);
    m_apb_pslverr      : in  std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    m_apb_pprot        : out std_logic_vector(2 downto 0);
    m_apb_pstrb        : out std_logic_vector
                             (3 downto 0)
    );

end entity axi_apb_bridge;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture RTL of axi_apb_bridge is
-------------------------------------------------------------------------------
-- PRAGMAS
-------------------------------------------------------------------------------

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of RTL : architecture is "yes";



-------------------------------------------------------------------------------
 -- Signal declarations
-------------------------------------------------------------------------------

    signal Address        : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal sl_pselect     : std_logic_vector(C_APB_NUM_SLAVES-1 downto 0);
    signal apb_pslverr    : std_logic;
    signal apb_pready     : std_logic;
    signal apb_enable     : std_logic;
    signal apb_prdata     : std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    signal apb_rd_request : std_logic;
    signal apb_wr_request : std_logic;
    signal rd_data        : std_logic_vector(C_M_APB_DATA_WIDTH-1 downto 0);
    signal slv_err_resp   : std_logic;
    signal PSEL_i         : std_logic;
    signal axi_awprot     : std_logic_vector(2 downto 0);
    signal dphase_timeout : std_logic;    
    
begin

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
    
-------------------------------------------------------------------------------
-- APB clock and reset assignments
-------------------------------------------------------------------------------

    --m_apb_pclk <= s_axi_aclk;
    
    --m_apb_presetn <= s_axi_aresetn;

-------------------------------------------------------------------------------
 -- Instantiate the address decoder as APB is shared
-------------------------------------------------------------------------------

        PSEL_DECODER_MODULE : entity axi_apb_bridge_v3_0_17.psel_decoder
        generic map
        (
         C_FAMILY                         => C_FAMILY,
         C_S_AXI_ADDR_WIDTH               => C_S_AXI_ADDR_WIDTH,
         C_APB_NUM_SLAVES                 => C_APB_NUM_SLAVES,
         C_S_AXI_RNG1_BASEADDR            => C_BASEADDR,
         C_S_AXI_RNG1_HIGHADDR            => C_HIGHADDR,
         C_S_AXI_RNG2_BASEADDR            => C_S_AXI_RNG2_BASEADDR,
         C_S_AXI_RNG2_HIGHADDR            => C_S_AXI_RNG2_HIGHADDR,
         C_S_AXI_RNG3_BASEADDR            => C_S_AXI_RNG3_BASEADDR,
         C_S_AXI_RNG3_HIGHADDR            => C_S_AXI_RNG3_HIGHADDR,
         C_S_AXI_RNG4_BASEADDR            => C_S_AXI_RNG4_BASEADDR,
         C_S_AXI_RNG4_HIGHADDR            => C_S_AXI_RNG4_HIGHADDR,
         C_S_AXI_RNG5_BASEADDR            => C_S_AXI_RNG5_BASEADDR,
         C_S_AXI_RNG5_HIGHADDR            => C_S_AXI_RNG5_HIGHADDR,
         C_S_AXI_RNG6_BASEADDR            => C_S_AXI_RNG6_BASEADDR,
         C_S_AXI_RNG6_HIGHADDR            => C_S_AXI_RNG6_HIGHADDR,
         C_S_AXI_RNG7_BASEADDR            => C_S_AXI_RNG7_BASEADDR,
         C_S_AXI_RNG7_HIGHADDR            => C_S_AXI_RNG7_HIGHADDR,
         C_S_AXI_RNG8_BASEADDR            => C_S_AXI_RNG8_BASEADDR,
         C_S_AXI_RNG8_HIGHADDR            => C_S_AXI_RNG8_HIGHADDR,
         C_S_AXI_RNG9_BASEADDR            => C_S_AXI_RNG9_BASEADDR,
         C_S_AXI_RNG9_HIGHADDR            => C_S_AXI_RNG9_HIGHADDR,
         C_S_AXI_RNG10_BASEADDR           => C_S_AXI_RNG10_BASEADDR,
         C_S_AXI_RNG10_HIGHADDR           => C_S_AXI_RNG10_HIGHADDR,
         C_S_AXI_RNG11_BASEADDR           => C_S_AXI_RNG11_BASEADDR,
         C_S_AXI_RNG11_HIGHADDR           => C_S_AXI_RNG11_HIGHADDR,
         C_S_AXI_RNG12_BASEADDR           => C_S_AXI_RNG12_BASEADDR,
         C_S_AXI_RNG12_HIGHADDR           => C_S_AXI_RNG12_HIGHADDR,
         C_S_AXI_RNG13_BASEADDR           => C_S_AXI_RNG13_BASEADDR,
         C_S_AXI_RNG13_HIGHADDR           => C_S_AXI_RNG13_HIGHADDR,
         C_S_AXI_RNG14_BASEADDR           => C_S_AXI_RNG14_BASEADDR,
         C_S_AXI_RNG14_HIGHADDR           => C_S_AXI_RNG14_HIGHADDR,
         C_S_AXI_RNG15_BASEADDR           => C_S_AXI_RNG15_BASEADDR,
         C_S_AXI_RNG15_HIGHADDR           => C_S_AXI_RNG15_HIGHADDR,
         C_S_AXI_RNG16_BASEADDR           => C_S_AXI_RNG16_BASEADDR,
         C_S_AXI_RNG16_HIGHADDR           => C_S_AXI_RNG16_HIGHADDR
        )
        port map
        (
         Address                          => address,
         addr_is_valid                    => '1',
         sl_pselect                       => sl_pselect
        );
-------------------------------------------------------------------------------
 -- Instantiate the Multiplexor as APB is shared
-------------------------------------------------------------------------------

        MULTIPLEXOR_MODULE : entity axi_apb_bridge_v3_0_17.multiplexor
        generic map
        (
         C_M_APB_DATA_WIDTH               => C_M_APB_DATA_WIDTH,
         C_APB_NUM_SLAVES                 => C_APB_NUM_SLAVES
        )
        port map
        (
         M_APB_PCLK                       => s_axi_aclk,
         M_APB_PRESETN                    => s_axi_aresetn,
         M_APB_PREADY                     => m_apb_pready,
         M_APB_PRDATA1                    => m_apb_prdata,
         M_APB_PRDATA2                    => m_apb_prdata2,
         M_APB_PRDATA3                    => m_apb_prdata3,
         M_APB_PRDATA4                    => m_apb_prdata4,
         M_APB_PRDATA5                    => m_apb_prdata5,
         M_APB_PRDATA6                    => m_apb_prdata6,
         M_APB_PRDATA7                    => m_apb_prdata7,
         M_APB_PRDATA8                    => m_apb_prdata8,
         M_APB_PRDATA9                    => m_apb_prdata9,
         M_APB_PRDATA10                   => m_apb_prdata10,
         M_APB_PRDATA11                   => m_apb_prdata11,
         M_APB_PRDATA12                   => m_apb_prdata12,
         M_APB_PRDATA13                   => m_apb_prdata13,
         M_APB_PRDATA14                   => m_apb_prdata14,
         M_APB_PRDATA15                   => m_apb_prdata15,
         M_APB_PRDATA16                   => m_apb_prdata16,
         M_APB_PSLVERR                    => m_apb_pslverr,
         M_APB_PSEL                       => m_apb_psel,
         PSEL_i                           => PSEL_i,
         apb_pslverr                      => apb_pslverr,
         apb_pready                       => apb_pready,
         apb_prdata                       => apb_prdata,
         sl_pselect                       => sl_pselect
        );

-------------------------------------------------------------------------------
 -- Instantiate the AXI Lite Slave Interface module
-------------------------------------------------------------------------------

        AXILITE_SLAVE_IF_MODULE : entity axi_apb_bridge_v3_0_17.axilite_sif
        generic map
        (
         C_FAMILY                         => C_FAMILY,
         C_S_AXI_ADDR_WIDTH               => C_S_AXI_ADDR_WIDTH,
         C_S_AXI_DATA_WIDTH               => C_S_AXI_DATA_WIDTH,
         C_DPHASE_TIMEOUT                 => C_DPHASE_TIMEOUT,
         C_M_APB_PROTOCOL                 => C_M_APB_PROTOCOL
        )
        port map
        (
         S_AXI_ACLK                       => s_axi_aclk,
         S_AXI_ARESETN                    => s_axi_aresetn,

         S_AXI_AWADDR                     => s_axi_awaddr,
         S_AXI_AWPROT                      => s_axi_awprot,
         S_AXI_AWVALID                    => s_axi_awvalid,
         S_AXI_AWREADY                    => s_axi_awready,
         S_AXI_WVALID                     => s_axi_wvalid,
         S_AXI_WREADY                     => s_axi_wready,
         S_AXI_BRESP                      => s_axi_bresp,
         S_AXI_BVALID                     => s_axi_bvalid,
         S_AXI_BREADY                     => s_axi_bready,

         S_AXI_ARADDR                     => s_axi_araddr,
         S_AXI_ARVALID                    => s_axi_arvalid,
         S_AXI_ARREADY                    => s_axi_arready,
         S_AXI_RDATA                      => s_axi_rdata,
         S_AXI_RRESP                      => s_axi_rresp,
         S_AXI_RVALID                     => s_axi_rvalid,
         S_AXI_RREADY                     => s_axi_rready,
         axi_awprot                       => axi_awprot,
         address                          => address,
         apb_rd_request                   => apb_rd_request,
         apb_wr_request                   => apb_wr_request,
         dphase_timeout                   => dphase_timeout,
         apb_pready                       => apb_pready,
         apb_enable                       => apb_enable,
         slv_err_resp                     => slv_err_resp,
         rd_data                          => rd_data
        );

-------------------------------------------------------------------------------
 -- Instantiate the APB Master Interface module
-------------------------------------------------------------------------------

        APB_MASTER_IF_MODULE : entity axi_apb_bridge_v3_0_17.apb_mif
        generic map
        (
         C_M_APB_ADDR_WIDTH               => C_M_APB_ADDR_WIDTH,
         C_M_APB_DATA_WIDTH               => C_M_APB_DATA_WIDTH,
         C_S_AXI_DATA_WIDTH               => C_S_AXI_DATA_WIDTH,
         C_APB_NUM_SLAVES                 => C_APB_NUM_SLAVES,
         C_M_APB_PROTOCOL                 => C_M_APB_PROTOCOL
        )
        port map
        (
         M_APB_PCLK                       => s_axi_aclk,
         M_APB_PRESETN                    => s_axi_aresetn,

         M_APB_PADDR                      => m_apb_paddr,
         M_APB_PENABLE                    => apb_enable, --m_apb_penable,
         M_APB_PWRITE                     => m_apb_pwrite,
         M_APB_PWDATA                     => m_apb_pwdata,
         M_APB_PSTRB                      => m_apb_pstrb,
         M_APB_PPROT                      => m_apb_pprot,
         apb_pslverr                      => apb_pslverr,
         apb_pready                       => apb_pready,
         apb_rd_request                   => apb_rd_request,
         apb_wr_request                   => apb_wr_request,
         dphase_timeout                   => dphase_timeout,
         apb_prdata                       => apb_prdata,
         rd_data                          => rd_data,
         slv_err_resp                     => slv_err_resp,
         PSEL_i                           => PSEL_i,
         address                          => address,
         axi_awprot                       => axi_awprot,
         S_AXI_WDATA                      => s_axi_wdata,
         S_AXI_WSTRB                      => s_axi_wstrb,
         S_AXI_ARADDR                     => s_axi_araddr,
         S_AXI_ARPROT                     => s_axi_arprot
        );

         m_apb_penable <= apb_enable;

end architecture RTL;


