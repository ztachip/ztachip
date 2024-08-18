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

entity camera is
   Port ( clk_in      : in STD_LOGIC;
          SIOC        : out STD_LOGIC;
          SIOD        : out STD_LOGIC;
          RESET       : out STD_LOGIC;
          PWDN        : out STD_LOGIC;
          XCLK        : out STD_LOGIC;
           
          CAMERA_PCLK : in std_logic;           
          CAMERA_D    : in std_logic_vector(7 downto 0);
          CAMERA_VS   : in std_logic;
          CAMERA_RS   : in std_logic;
          tdata_out   : out std_logic_vector(31 downto 0);
          tlast_out   : out std_logic;
          tready_in   : in std_logic;
          tuser_out   : out std_logic_vector(0 downto 0);
          tvalid_out  : out std_logic
);
end camera;

architecture Behavioral of camera is
   signal sys_clk : std_logic := '0';
   signal finished : std_logic := '0';
   signal taken : std_logic := '0';
   signal send : std_logic;
   signal divider : unsigned (7 downto 0) := "00000001";
   signal busy_sr : std_logic_vector(31 downto 0) := (others => '0');
   signal data_sr : std_logic_vector(31 downto 0) := (others => '1');
   signal sreg : std_logic_vector(15 downto 0);
   signal address : std_logic_vector(7 downto 0) := (others => '0');
   constant camera_address : std_logic_vector(7 downto 0) := x"42"; -- 42";
   signal tdata : std_logic_vector(31 downto 0);
   signal tdata_r : std_logic_vector(31 downto 0);
   signal tvalid : std_logic;
   signal camera_d_r : std_logic_vector(7 downto 0):=(others=>'0');
   signal pixel_x : unsigned(15 downto 0):=(others=>'0');
   signal d : std_logic_vector(15 downto 0);
   signal go : std_logic:='0';
   signal count_r : unsigned(1 downto 0):=(others=>'0');
   signal countdown_r: unsigned(17 downto 0):=(others=>'1');
   signal ready_r : std_logic:='0';
   signal tlast: std_logic;
   signal CAMERA_VS_r: std_logic:='0';
   signal row_r:unsigned(9 downto 0):=(others=>'0');
begin

   RESET <= not countdown_r(countdown_r'length-1);
   
   PWDN  <= '0';
   
   XCLK  <= sys_clk;
   
   send <= (not finished) and ready_r;

   -----------------------------
   --- ov7670_rgisters to program 
   -----------------------------
   
   with sreg select finished  <= '1' when x"FFFF", '0' when others;

   process(clk_in)
   begin
      if rising_edge(clk_in) then
         if countdown_r /= to_unsigned(0,countdown_r'length) then
            countdown_r <= countdown_r-1;
         else
            ready_r <= '1';
         end if;
         if taken = '1' then
            address <= std_logic_vector(unsigned(address)+1);
         end if;
         case address is
            when x"00" => sreg <= x"1280"; -- COM7   Reset
            when x"01" => sreg <= x"1280"; -- COM7   Reset
            when x"02" => sreg <= x"1204"; -- COM7   Size & RGB output
            when x"03" => sreg <= x"1100"; -- CLKRC  Prescaler - Fin/(1+1)
            when x"04" => sreg <= x"0C00"; -- COM3   Lots of stuff, enable scaling, all others off
            when x"05" => sreg <= x"3E00"; -- COM14  PCLK scaling off
            when x"06" => sreg <= x"8C00"; -- RGB444 Set RGB format
            when x"07" => sreg <= x"0400"; -- COM1   no CCIR601
            when x"08" => sreg <= x"40F0"; -- COM15  Full 0-255 output, RGB 555
            when x"09" => sreg <= x"3a04"; -- TSLB   Set UV ordering,  do not auto-RESET window
            when x"0A" => sreg <= x"1438"; -- COM9  - AGC Celling
            when x"0B" => sreg <= x"4f40"; --x"4fb3"; -- MTX1  - colour conversion matrix
            when x"0C" => sreg <= x"5034"; --x"50b3"; -- MTX2  - colour conversion matrix
            when x"0D" => sreg <= x"510C"; --x"5100"; -- MTX3  - colour conversion matrix
            when x"0E" => sreg <= x"5217"; --x"523d"; -- MTX4  - colour conversion matrix
            when x"0F" => sreg <= x"5329"; --x"53a7"; -- MTX5  - colour conversion matrix
            when x"10" => sreg <= x"5440"; --x"54e4"; -- MTX6  - colour conversion matrix
            when x"11" => sreg <= x"581e"; --x"589e"; -- MTXS  - Matrix sign and auto contrast
            when x"12" => sreg <= x"3dc0"; -- COM13 - Turn on GAMMA and UV Auto adjust
            when x"13" => sreg <= x"1100"; -- CLKRC  Prescaler - Fin/(1+1)
            when x"14" => sreg <= x"1711"; -- HSTART HREF start (high 8 bits)
            when x"15" => sreg <= x"1861"; -- HSTOP  HREF stop (high 8 bits)
            when x"16" => sreg <= x"32A4"; -- HREF   Edge offset and low 3 bits of HSTART and HSTOP
            when x"17" => sreg <= x"1903"; -- VSTART VSYNC start (high 8 bits)
            when x"18" => sreg <= x"1A7b"; -- VSTOP  VSYNC stop (high 8 bits)
            when x"19" => sreg <= x"030a"; -- VREF   VSYNC low two bits
            when x"1A" => sreg <= x"0e61"; -- COM5(0x0E) 0x61
            when x"1B" => sreg <= x"0f4b"; -- COM6(0x0F) 0x4B
            when x"1C" => sreg <= x"1602"; --
            when x"1D" => sreg <= x"1e37"; -- MVFP (0x1E) 0x07  -- FLIP AND MIRROR IMAGE 0x3x
            when x"1E" => sreg <= x"2102";
            when x"1F" => sreg <= x"2291";
            when x"20" => sreg <= x"2907";
            when x"21" => sreg <= x"330b";
            when x"22" => sreg <= x"350b";
            when x"23" => sreg <= x"371d";
            when x"24" => sreg <= x"3871";
            when x"25" => sreg <= x"392a";
            when x"26" => sreg <= x"3c78"; -- COM12 (0x3C) 0x78
            when x"27" => sreg <= x"4d40";
            when x"28" => sreg <= x"4e20";
            when x"29" => sreg <= x"6900"; -- GFIX (0x69) 0x00
            when x"2A" => sreg <= x"6b4a";
            when x"2B" => sreg <= x"7410";
            when x"2C" => sreg <= x"8d4f";
            when x"2D" => sreg <= x"8e00";
            when x"2E" => sreg <= x"8f00";
            when x"2F" => sreg <= x"9000";
            when x"30" => sreg <= x"9100";
            when x"31" => sreg <= x"9600";
            when x"32" => sreg <= x"9a00";
            when x"33" => sreg <= x"b084";
            when x"34" => sreg <= x"b10c";
            when x"35" => sreg <= x"b20e";
            when x"36" => sreg <= x"b382";
            when x"37" => sreg <= x"b80a";
            when others => sreg <= x"ffff";
         end case;
      end if;
   end process;     

   --------------------------        
   -- Driving I2C bus 
   --------------------------
         
   process(busy_sr, data_sr(31))
   begin
      if busy_sr(11 downto 10) = "10" or
         busy_sr(20 downto 19) = "10" or
         busy_sr(29 downto 28) = "10"  then
         SIOD <= 'Z';
      else
         SIOD <= data_sr(31);
      end if;
   end process;

   process(clk_in)
   begin
      if rising_edge(clk_in) then
         taken <= '0';
         if busy_sr(31) = '0' then
            SIOC <= '1';
            if send = '1' then
               if divider = "00000000" then
                  data_sr <= "100" &   camera_address & '0'  &   sreg(15 downto 8) & '0' & sreg(7 downto 0) & '0' & "01";
                  busy_sr <= "111" & "111111111" & "111111111" & "111111111" & "11";
                  taken <= '1';
               else
                  divider <= divider+1; -- this only happens on powerup
               end if;
            end if;
         else
            case busy_sr(32-1 downto 32-3) & busy_sr(2 downto 0) is
               when "111"&"111" => -- start seq #1
                  case divider(7 downto 6) is
                     when "00"   => SIOC <= '1';
                     when "01"   => SIOC <= '1';
                     when "10"   => SIOC <= '1';
                     when others => SIOC <= '1';
                  end case;
               when "111"&"110" => -- start seq #2
                  case divider(7 downto 6) is
                     when "00"   => SIOC <= '1';
                     when "01"   => SIOC <= '1';
                     when "10"   => SIOC <= '1';
                     when others => SIOC <= '1';
                  end case;
               when "111"&"100" => -- start seq #3
                  case divider(7 downto 6) is
                     when "00"   => SIOC <= '0';
                     when "01"   => SIOC <= '0';
                     when "10"   => SIOC <= '0';
                     when others => SIOC <= '0';
                  end case;
               when "110"&"000" => -- end seq #1
                  case divider(7 downto 6) is
                     when "00"   => SIOC <= '0';
                     when "01"   => SIOC <= '1';
                     when "10"   => SIOC <= '1';
                     when others => SIOC <= '1';
                  end case;
               when "100"&"000" => -- end seq #2
                  case divider(7 downto 6) is
                     when "00"   => SIOC <= '1';
                     when "01"   => SIOC <= '1';
                     when "10"   => SIOC <= '1';
                     when others => SIOC <= '1';
                  end case;
               when "000"&"000" => -- Idle
                  case divider(7 downto 6) is
                     when "00"   => SIOC <= '1';
                     when "01"   => SIOC <= '1';
                     when "10"   => SIOC <= '1';
                     when others => SIOC <= '1';
                  end case;
               when others      =>
                  case divider(7 downto 6) is
                     when "00"   => SIOC <= '0';
                     when "01"   => SIOC <= '1';
                     when "10"   => SIOC <= '1';
                     when others => SIOC <= '0';
                  end case;
            end case;

            if divider = "11111111" then
               busy_sr <= busy_sr(32-2 downto 0) & '0';
               data_sr <= data_sr(32-2 downto 0) & '1';
               divider <= (others => '0');
            else
               divider <= divider+1;
            end if;
         end if;
      end if;
   end process;
       
   tlast_out <= tlast;
   
   tlast <= '1' when (pixel_x=to_unsigned(1279,pixel_x'length)) and
                     (row_r = to_unsigned(479,row_r'length))
                     else '0';

   tvalid <= (CAMERA_RS and pixel_x(0) and go);

   tuser_out(0) <= '0';
   
   tvalid_out <= '1' when ((tvalid='1') and (count_r /= to_unsigned(0,count_r'length))) else '0';
 
   ----------------------
   -- Transfer a 24 bit pixel data into 32-bit stream
   ----------------------
   
   d <= (camera_d_r & CAMERA_D);
   tdata(3 downto 0) <= (others=>'0');
   tdata(7 downto 4) <= d(14 downto 11);
   tdata(11 downto 8) <= (others=>'0');
   tdata(15 downto 12) <= d(4 downto 1);
   tdata(19 downto 16) <= (others=>'0');
   tdata(23 downto 20) <= d(9 downto 6);
   tdata(31 downto 24) <= (others=>'0');
   
   process(tdata,count_r)
   begin
      case count_r is
         when "00" =>
            tdata_out(31 downto 24) <= (others=>'0');
            tdata_out(23 downto 16) <= (others=>'0');
            tdata_out(15 downto 8) <= (others=>'0');
            tdata_out(7 downto 0) <= (others=>'0');
         when "01" =>
            tdata_out(31 downto 24) <= tdata(23 downto 16);
            tdata_out(23 downto 16) <= tdata_r(7 downto 0);
            tdata_out(15 downto 8) <= tdata_r(15 downto 8);
            tdata_out(7 downto 0) <= tdata_r(23 downto 16);
         when "10" =>
            tdata_out(31 downto 24) <= tdata(15 downto 8);
            tdata_out(23 downto 16) <= tdata(23 downto 16);
            tdata_out(15 downto 8) <= tdata_r(7 downto 0);
            tdata_out(7 downto 0) <= tdata_r(15 downto 8);
         when others=>
            tdata_out(31 downto 24) <= tdata(7 downto 0);
            tdata_out(23 downto 16) <= tdata(15 downto 8);
            tdata_out(15 downto 8) <= tdata(23 downto 16);
            tdata_out(7 downto 0) <= tdata_r(7 downto 0);
      end case;
   end process;

 
   process(CAMERA_PCLK)
   begin       
      if rising_edge(CAMERA_PCLK) then
         if(go='0' and CAMERA_VS_r='0' and CAMERA_VS='1' and tready_in='1' and finished='1') then
            go <='1';
            row_r <= (others=>'0');
         end if;
         if(CAMERA_VS='1' and CAMERA_VS_r='0' and go='1') then
            if(row_r < to_unsigned(479,row_r'length)) then
               row_r <= row_r+to_unsigned(1,row_r'length);
            else 
               row_r <= (others=>'0');
            end if;
         end if;
         if(go='1') then
            if(CAMERA_RS='1') then
               pixel_x <= pixel_x+1;
               camera_d_r <= CAMERA_D;
               if(tvalid='1') then
                  tdata_r <= tdata;
                  count_r <= count_r+1;
               end if;    
            else
               pixel_x <= (others=>'0');
               count_r <= (others=>'0');
            end if;
         end if;
         CAMERA_VS_r <= CAMERA_VS;      
      end if;
   end process;
   
   process(clk_in)
   begin
      if rising_edge(clk_in) then
         sys_clk <= not sys_clk;
      end if;
   end process;
   
end Behavioral;