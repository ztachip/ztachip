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
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
   PORT (
      signal clk_in        : in  std_logic;
      signal tdata_in      : in  std_logic_vector(31 downto 0);
      signal tready_out    : out std_logic;  
      signal tvalid_in     : in  std_logic;
      signal tlast_in      : in  std_logic;
       
      signal VGA_HS_O_out  : out std_logic;
      signal VGA_VS_O_out  : out std_logic;
      signal VGA_R_out     : out std_logic_vector(3 downto 0);
      signal VGA_B_out     : out std_logic_vector(3 downto 0);
      signal VGA_G_out     : out std_logic_vector(3 downto 0)
    );
 end vga;
  
architecture Behavioral of vga is  
signal tdata_r:std_logic_vector(31 downto 0);
signal vcount_r:unsigned(15 downto 0):=(others=>'0');
signal hcount_r:unsigned(15 downto 0):=(others=>'0');
signal pixel_valid_x:std_logic;
signal pixel_valid_y:std_logic;
signal go:std_logic:='0';
signal count_r:unsigned(1 downto 0):=(others=>'0');
signal pixel_valid:std_logic;
signal pause_r:std_logic:='0';
signal tready:std_logic;

signal VGA_HS_O_r:std_logic;
signal VGA_VS_O_r:std_logic;
signal VGA_R_r:std_logic_vector(3 downto 0);
signal VGA_B_r:std_logic_vector(3 downto 0);
signal VGA_G_r:std_logic_vector(3 downto 0);

signal VGA_HS_O:std_logic;
signal VGA_VS_O:std_logic;
signal VGA_R:std_logic_vector(3 downto 0);
signal VGA_B:std_logic_vector(3 downto 0);
signal VGA_G:std_logic_vector(3 downto 0);

------
-- VGA frame structure for 640x480
------

constant FRAME_WIDTH:integer:=640;
constant FRAME_HEIGHT:integer:=480;
constant H_FP:integer:=48; -- H front porch width (pixels)
constant H_BP:integer:=16; -- H front porch width (pixels)
constant H_PW:integer:=96; -- H sync pulse width (pixels)
constant H_MAX:integer:=800; -- H total period (pixels)
constant V_FP:integer:=33; -- V front porch width (lines)
constant V_BP:integer:=10; -- V front porch width (lines)
constant V_PW:integer:=2; -- V sync pulse width (lines)
constant V_MAX:integer:=525; -- V total period (lines)

begin

VGA_HS_O_out <= VGA_HS_O_r;

VGA_VS_O_out <= VGA_VS_O_r;

VGA_R_out <= VGA_R_r;

VGA_B_out <= VGA_B_r;

VGA_G_out <= VGA_G_r;

VGA_HS_O <= '0' when (hcount_r >= to_unsigned(H_MAX-H_PW,hcount_r'length)) else '1';

VGA_VS_O <= '0' when (vcount_r >= to_unsigned(V_MAX-V_PW,vcount_r'length)) else '1';

pixel_valid_x <= '1' when ((hcount_r >= to_unsigned(H_FP,hcount_r'length)) and (hcount_r < to_unsigned(H_FP+FRAME_WIDTH,hcount_r'length))) else '0';

pixel_valid_y <= '1' when ((vcount_r >= to_unsigned(V_FP,vcount_r'length)) and (vcount_r < to_unsigned(V_FP+FRAME_HEIGHT,vcount_r'length))) else '0';

pixel_valid <= (pixel_valid_x and pixel_valid_y);

tready_out <= tready;

--tready <= '1' when ((pause_r='0') and (tvalid_in='1') and (pixel_valid='1') and (count_r < to_unsigned(3,count_r'length))) else '0';

tready <= '1' when ((tvalid_in='1') and (pixel_valid='1') and (count_r < to_unsigned(3,count_r'length))) else '0';


--------
-- Transfer 32-bit stream data to 24 bit pixel value
--------

process(pixel_valid,count_r,tdata_in,tdata_r)
begin
   if(pixel_valid='0') then
      VGA_G <= (others=>'0');
      VGA_B <= (others=>'0');
      VGA_R <= (others=>'0');
   else
      case count_r is
         when "00" =>
            VGA_G <= tdata_in(7 downto 4);
            VGA_B <= tdata_in(15 downto 12);
            VGA_R <= tdata_in(23 downto 20);
         when "01" =>
            VGA_G <= tdata_r(31 downto 28);
            VGA_B <= tdata_in(7 downto 4);
            VGA_R <= tdata_in(15 downto 12);
         when "10" =>
            VGA_G <= tdata_r(23 downto 20);
            VGA_B <= tdata_r(31 downto 28);
            VGA_R <= tdata_in(7 downto 4);
         when others=>
            VGA_G <= tdata_r(15 downto 12);
            VGA_B <= tdata_r(23 downto 20);
            VGA_R <= tdata_r(31 downto 28);
      end case;
   end if;
end process;
 
process(clk_in)
begin
   if rising_edge(clk_in) then
      if(tvalid_in='1') then
         go <= '1';
      end if;
      if(go='1') then  
         if(pixel_valid='1') then 
            tdata_r <= tdata_in;
            count_r <= count_r+1;
            if(tready='1' and tlast_in='1') then
               pause_r <= '1';
            end if;
         end if;
         if (hcount_r=(H_MAX-1)) then 
            hcount_r <= (others=>'0');
            if (vcount_r=to_unsigned(V_MAX-1,vcount_r'length)) then
               vcount_r <= (others=>'0');
               pause_r <= '0';
               count_r <= (others=>'0');
            else
               vcount_r <= vcount_r+1;
            end if;
         else
            hcount_r <= hcount_r+1;
         end if;
      end if;
      VGA_HS_O_r <= VGA_HS_O;
      VGA_VS_O_r <= VGA_VS_O;
      VGA_R_r <= VGA_R;
      VGA_B_r <= VGA_B;
      VGA_G_r <= VGA_G;
   end if;
end process;

end Behavioral;
