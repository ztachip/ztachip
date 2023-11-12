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
--                  TOP COMPONENT DECLARATION
----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE std.textio.all;
USE ieee.std_logic_textio.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity main is
   port(   
      signal reset_in:in std_logic;
      signal clk_main:in std_logic;
      signal clk_x2_main:in std_logic;
      signal led_out:out std_logic_vector(3 downto 0)
   );
end main;

---
-- This top level component for simulatio
---

architecture rtl of main is

signal SDRAM_araddr:std_logic_vector(31 downto 0);
signal SDRAM_arburst:std_logic_vector(1 downto 0);
signal SDRAM_arlen:std_logic_vector(7 downto 0);
signal SDRAM_arready:std_logic;
signal SDRAM_arsize:std_logic_vector(2 downto 0);
signal SDRAM_arvalid:std_logic;
signal SDRAM_awaddr:std_logic_vector(31 downto 0);
signal SDRAM_awburst:std_logic_vector(1 downto 0);
signal SDRAM_awlen:std_logic_vector(7 downto 0);
signal SDRAM_awready:std_logic;
signal SDRAM_awsize:std_logic_vector(2 downto 0);
signal SDRAM_awvalid:std_logic;
signal SDRAM_bready:std_logic;
signal SDRAM_bresp:std_logic_vector(1 downto 0);
signal SDRAM_bvalid:std_logic;
signal SDRAM_rdata:std_logic_vector(63 downto 0);
signal SDRAM_rlast:std_logic;
signal SDRAM_rready:std_logic;
signal SDRAM_rresp:std_logic_vector(1 downto 0);
signal SDRAM_rvalid:std_logic;
signal SDRAM_wdata:std_logic_vector(63 downto 0);
signal SDRAM_wlast:std_logic;
signal SDRAM_wready:std_logic;
signal SDRAM_wstrb:std_logic_vector(7 downto 0);
signal SDRAM_wvalid:std_logic;

signal araddr:std_logic_vector(31 downto 0);
signal arburst:std_logic_vector(1 downto 0);
signal arlen:std_logic_vector(7 downto 0);
signal arready:std_logic;
signal arsize:std_logic_vector(2 downto 0);
signal arvalid:std_logic;
signal awaddr:std_logic_vector(31 downto 0);
signal awburst:std_logic_vector(1 downto 0);
signal awlen:std_logic_vector(7 downto 0);
signal awready:std_logic;
signal awsize:std_logic_vector(2 downto 0);
signal awvalid:std_logic;
signal bready:std_logic;
signal bresp:std_logic_vector(1 downto 0);
signal bvalid:std_logic;
signal rdata:std_logic_vector(63 downto 0);
signal rlast:std_logic;
signal rready:std_logic;
signal rresp:std_logic_vector(1 downto 0);
signal rvalid:std_logic;
signal wdata:std_logic_vector(63 downto 0);
signal wlast:std_logic;
signal wready:std_logic;
signal wstrb:std_logic_vector(7 downto 0);
signal wvalid:std_logic;

signal VIDEO_tdata:std_logic_vector(31 downto 0);
signal VIDEO_tlast:std_logic;
signal VIDEO_tready:std_logic;
signal VIDEO_tvalid:std_Logic;

signal camera_tdata:std_logic_vector(31 downto 0);
signal camera_tlast:std_logic;
signal camera_tready:std_logic;
signal camera_tuser:std_logic_vector(0 downto 0);
signal camera_tvalid:std_logic;

signal read_addr_r:unsigned(31 downto 0);
signal read_len_r:unsigned(7 downto 0);
signal read_size_r:std_logic_vector(2 downto 0);
signal read_busy_r:std_logic;

signal write_addr_r:unsigned(31 downto 0);
signal write_len_r:unsigned(7 downto 0);
signal write_size_r:std_logic_vector(2 downto 0);
signal write_busy_r:std_logic;

signal led:std_logic_vector(3 downto 0);

constant RAM_BYTE_WIDTH:integer:=8;

type RamType is array(0 to 8000) of std_logic_vector(RAM_BYTE_WIDTH*8-1 downto 0);

--
-- Initialize RAM memory with content from HEX file
--

impure function InitRamFromFile (RamFileName : in string) return RamType is
variable ram_v : RamType;
file cmdfile: TEXT;
variable line_in:Line;
variable curraddr_v:integer;
variable baseaddr_v:integer;
variable SC_v:character;
variable LEN_v:std_logic_vector(7 downto 0);
variable ADDR_v:std_logic_vector(15 downto 0);
variable TYPE_v:std_logic_vector(7 downto 0);
variable DATA_v:std_logic_vector(7 downto 0);
variable CHECKSUM_v:std_logic_vector(7 downto 0);
variable wordpos_v:integer;
variable bytepos_v:integer;
variable baddr16_v:std_logic_vector(15 downto 0);
variable baddr32_v:std_logic_vector(31 downto 0);
begin
   baseaddr_v := 0;
   ram_v := (others=>(others=>'0'));
   FILE_OPEN(cmdfile,RamFileName,READ_MODE);
   loop
      if endfile(cmdfile) then
         return ram_v;
      end if;
      readline(cmdfile,line_in);
      read(line_in,SC_v);
      hread(line_in,LEN_v);
      hread(line_in,ADDR_v);
      hread(line_in,TYPE_v);
      case to_integer(unsigned(TYPE_v)) is
         when 0 => -- DATA
            curraddr_v := baseaddr_v+to_integer(unsigned(ADDR_v));
            for I in 0 to to_integer(unsigned(LEN_v))-1 loop
               hread(line_in,DATA_v);
               bytepos_v := (curraddr_v mod RAM_BYTE_WIDTH);
               wordpos_v := (curraddr_v / RAM_BYTE_WIDTH);
               ram_v(wordpos_v)(8*(bytepos_v+1)-1 downto 8*bytepos_v) := DATA_v;
               curraddr_v := curraddr_v+1;
            end loop;
            hread(line_in,CHECKSUM_v);
         when 1 => -- EOF
            return ram_v;
         when 2 => -- Extended Segment Address
            hread(line_in,baddr16_v);
            baseaddr_v := to_integer(unsigned(baddr16_v))*16;
         when 3 => -- Start Segment Address           
         when 4 => -- Extended linear address
            hread(line_in,baddr16_v);
            baseaddr_v := to_integer(unsigned(baddr16_v))*65536; 
         when 5 => -- Start linear address
            hread(line_in,baddr32_v);
            baseaddr_v := to_integer(unsigned(baddr32_v)); 
         when others =>
      end case;
   end loop;
   return ram_v;
end function;

signal RAM : RamType := InitRamFromFile("ztachip_sim.hex");

begin

led_out <= led;
VIDEO_tready <= '0';
camera_tdata <= (others=>'0');
camera_tlast <= '0';
camera_tuser <= (others=>'0');
camera_tvalid <= '0';

soc_base_inst: soc_base 
   GENERIC MAP(
      SIMULATION=>TRUE
   )
   PORT MAP(

      clk_main=>clk_main,
      clk_x2_main=>clk_x2_main,
      clk_reset=>reset_in,

      led=>led,
      pushbutton=>(others=>'0'),

      UART_TXD=>open,
      UART_RXD=>'0',

      VIDEO_clk=>clk_main,  
      VIDEO_tdata=>VIDEO_tdata,
      VIDEO_tready=>VIDEO_tready,
      VIDEO_tvalid=>VIDEO_tvalid,
      VIDEO_tlast=>VIDEO_tlast,

      camera_clk=>clk_main,
      camera_tdata=>camera_tdata,
      camera_tlast=>camera_tlast,
      camera_tready=>camera_tready,
      camera_tvalid=>camera_tvalid,

      SDRAM_clk=>clk_main,
      SDRAM_araddr=>SDRAM_araddr,
      SDRAM_arburst=>SDRAM_arburst,
      SDRAM_arlen=>SDRAM_arlen,
      SDRAM_arready=>SDRAM_arready,
      SDRAM_arsize=>SDRAM_arsize,
      SDRAM_arvalid=>SDRAM_arvalid,
      SDRAM_awaddr=>SDRAM_awaddr,
      SDRAM_awburst=>SDRAM_awburst,
      SDRAM_awlen=>SDRAM_awlen,
      SDRAM_awready=>SDRAM_awready,
      SDRAM_awsize=>SDRAM_awsize,
      SDRAM_awvalid=>SDRAM_awvalid,
      SDRAM_bready=>SDRAM_bready,
      SDRAM_bresp=>SDRAM_bresp,
      SDRAM_bvalid=>SDRAM_bvalid,
      SDRAM_rdata=>SDRAM_rdata,
      SDRAM_rlast=>SDRAM_rlast,
      SDRAM_rready=>SDRAM_rready,
      SDRAM_rresp=>SDRAM_rresp,
      SDRAM_rvalid=>SDRAM_rvalid,
      SDRAM_wdata=>SDRAM_wdata,
      SDRAM_wlast=>SDRAM_wlast,
      SDRAM_wready=>SDRAM_wready,
      SDRAM_wstrb=>SDRAM_wstrb,
      SDRAM_wvalid=>SDRAM_wvalid
   );

----
-- Simulate external memory 
----

axi_read_inst: axi_read 
   GENERIC MAP (
      DATA_WIDTH=>RAM_BYTE_WIDTH*8,
      FIFO_DEPTH=>6,
      FIFO_DATA_DEPTH=>6
   )
   PORT MAP
   (
      clock_in=>clk_main,
      reset_in=>reset_in,

      axislave_clock_in=>clk_main,
      axislave_araddr_in=>SDRAM_araddr,
      axislave_arlen_in=>SDRAM_arlen,
      axislave_arvalid_in=>SDRAM_arvalid,
      axislave_arid_in=>(others=>'0'),
      axislave_arlock_in=>(others=>'0'),
      axislave_arcache_in=>(others=>'0'),
      axislave_arprot_in=>(others=>'0'),
      axislave_arqos_in=>(others=>'0'),
      axislave_rid_out=>open,     
      axislave_rvalid_out=>SDRAM_rvalid,
      axislave_rlast_out=>SDRAM_rlast,
      axislave_rdata_out=>SDRAM_rdata,
      axislave_rresp_out=>SDRAM_rresp,
      axislave_arready_out=>SDRAM_arready,
      axislave_rready_in=>SDRAM_rready,
      axislave_arburst_in=>SDRAM_arburst,
      axislave_arsize_in=>SDRAM_arsize,

      aximaster_clock_in=>clk_main,
      aximaster_araddr_out=>araddr,
      aximaster_arlen_out=>arlen,
      aximaster_arvalid_out=>arvalid,
      aximaster_arid_out=>open,
      aximaster_arlock_out=>open,
      aximaster_arcache_out=>open,
      aximaster_arprot_out=>open,
      aximaster_arqos_out=>open,
      aximaster_rid_in=>(others=>'0'),
      aximaster_rvalid_in=>rvalid,
      aximaster_rlast_in=>rlast,
      aximaster_rdata_in=>rdata,
      aximaster_rresp_in=>rresp,
      aximaster_arready_in=>arready,
      aximaster_rready_out=>rready,
      aximaster_arburst_out=>arburst,
      aximaster_arsize_out=>arsize
   );

axi_write_inst: axi_write
   generic map (
      DATA_WIDTH=>RAM_BYTE_WIDTH*8,
      FIFO_DEPTH=>6,
      FIFO_DATA_DEPTH=>6
   )
   port map
   (
      clock_in=>clk_main,
      reset_in=>reset_in,

      axislave_clock_in=>clk_main,
      axislave_awaddr_in=>SDRAM_awaddr,
      axislave_awlen_in=>SDRAM_awlen,
      axislave_awvalid_in=>SDRAM_awvalid,
      axislave_wvalid_in=>SDRAM_wvalid,
      axislave_wdata_in=>SDRAM_wdata,
      axislave_wlast_in=>SDRAM_wlast,
      axislave_wstrb_in=>SDRAM_wstrb,
      axislave_awready_out=>SDRAM_awready,
      axislave_wready_out=>SDRAM_wready,
      axislave_bresp_out=>SDRAM_bresp,
      axislave_bid_out=>open,
      axislave_bvalid_out=>SDRAM_bvalid,
      axislave_awburst_in=>SDRAM_awburst,
      axislave_awcache_in=>(others=>'0'),
      axislave_awid_in=>(others=>'0'),
      axislave_awlock_in=>(others=>'0'),
      axislave_awprot_in=>(others=>'0'),
      axislave_awqos_in=>(others=>'0'),
      axislave_awsize_in=>SDRAM_awsize,
      axislave_bready_in=>SDRAM_bready,

      aximaster_clock_in=>clk_main,
      aximaster_awaddr_out=>awaddr,
      aximaster_awlen_out=>awlen,
      aximaster_awvalid_out=>awvalid,
      aximaster_wvalid_out=>wvalid,
      aximaster_wdata_out=>wdata,
      aximaster_wlast_out=>wlast,
      aximaster_wstrb_out=>wstrb,
      aximaster_awready_in=>awready,
      aximaster_wready_in=>wready,
      aximaster_bresp_in=>bresp,
      aximaster_bid_in=>(others=>'0'),
      aximaster_bvalid_in=>bvalid,
      aximaster_awburst_out=>awburst,
      aximaster_awcache_out=>open,
      aximaster_awid_out=>open,
      aximaster_awlock_out=>open,
      aximaster_awprot_out=>open,
      aximaster_awqos_out=>open,
      aximaster_awsize_out=>awsize,
      aximaster_bready_out=>bready
   );


arready <= '1' when read_busy_r='0' or 
                     (read_busy_r='1' and rready='1' and 
                     read_len_r=to_unsigned(0,read_len_r'length))
               else '0';

rvalid <= read_busy_r;

rlast <= '1' when read_busy_r='1' and read_len_r=to_unsigned(0,read_len_r'length) else '0';

rresp <= (others=>'0');

awready <= '1' when (write_busy_r='0') or 
                     (write_busy_r='1' and wready='1' and wvalid='1' and 
                     write_len_r=to_unsigned(0,write_len_r'length))
               else '0';

wready <= write_busy_r and bready;

bvalid <= (wready and wvalid);

bresp <= (others=>'0');

process(read_size_r,RAM,read_addr_r)
begin
   if(read_size_r="011") then
      rdata <= RAM(to_integer(read_addr_r)/8);
   else
      if(read_addr_r(2)='1') then
         rdata(31 downto 0) <= RAM(to_integer(read_addr_r)/8)(63 downto 32);
         rdata(63 downto 32) <= RAM(to_integer(read_addr_r)/8)(63 downto 32);
      else
         rdata(31 downto 0) <= RAM(to_integer(read_addr_r)/8)(31 downto 0);
         rdata(63 downto 32) <= RAM(to_integer(read_addr_r)/8)(31 downto 0);
      end if;
   end if;
end process;

process(clk_main,reset_in)
begin
if reset_in = '0' then
   read_addr_r <= (others=>'0');
   read_len_r <= (others=>'0');
   read_size_r <= (others=>'0');
   read_busy_r <= '0';
   write_addr_r <= (others=>'0');
   write_len_r <= (others=>'0');
   write_size_r <= (others=>'0');
   write_busy_r <= '0';
else
   if clk_main'event and clk_main='1' then
      if(read_busy_r='1') then
         if(rready='1') then
            if(read_len_r=to_unsigned(0,read_len_r'length)) then
               read_addr_r <= unsigned(araddr);
               read_len_r <= unsigned(arlen);
               read_size_r <= arsize;
               read_busy_r <= arvalid;
            else
               if(read_size_r="011") then
                  read_addr_r <= read_addr_r+to_unsigned(8,read_addr_r'length);
                  read_len_r <= read_len_r-to_unsigned(1,read_len_r'length);
               else
                  read_addr_r <= read_addr_r+to_unsigned(4,read_addr_r'length);
                  read_len_r <= read_len_r-to_unsigned(1,read_len_r'length);
               end if;
            end if;
         end if;
      else
         read_addr_r <= unsigned(araddr);
         read_len_r <= unsigned(arlen);
         read_size_r <= arsize;
         read_busy_r <= arvalid;
      end if;

      if(write_busy_r='1') then
         if(wready='1' and wvalid='1') then
            if(write_len_r=to_unsigned(0,write_len_r'length)) then
               write_addr_r <= unsigned(awaddr);
               write_len_r <= unsigned(awlen);
               write_size_r <= awsize;
               write_busy_r <= awvalid;
            else
               if(write_size_r="011") then
                  write_addr_r <= write_addr_r+to_unsigned(8,write_addr_r'length);
                  write_len_r <= write_len_r-to_unsigned(1,write_len_r'length);
               else
                  write_addr_r <= write_addr_r+to_unsigned(4,write_addr_r'length);
                  write_len_r <= write_len_r-to_unsigned(1,write_len_r'length);
               end if;
            end if;
            if(write_size_r="011") then
               for I in 0 to (RAM_BYTE_WIDTH-1) loop
                  if(wstrb(I)='1') then
                     RAM(to_integer(write_addr_r)/8)((8*(I+1)-1) downto 8*I) <= wdata((8*(I+1)-1) downto 8*I);
                  end if;
               end loop;
            else
               if(write_addr_r(2)='0') then
                  for I in 0 to 3 loop
                     if(wstrb(I)='1') then
                        RAM(to_integer(write_addr_r)/8)((8*(I+1)-1) downto 8*I) <= wdata((8*(I+1)-1) downto 8*I);
                     end if;
                  end loop;
               else
                  for I in 0 to 3 loop
                     if(wstrb(4+I)='1') then
                        RAM(to_integer(write_addr_r)/8)((8*(I+4+1)-1) downto 8*(I+4)) <= wdata((8*((I+4)+1)-1) downto 8*(I+4));
                     end if;
                  end loop;
               end if;
            end if;
         end if;
      else
         write_addr_r <= unsigned(awaddr);
         write_len_r <= unsigned(awlen);
         write_size_r <= awsize;
         write_busy_r <= awvalid;
      end if;
   end if;
end if;

end process;

end rtl;
