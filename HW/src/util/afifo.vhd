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
-- Implementing asynchronous FIFO
-- Implementation is based on design as described in
-- http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
-----------------------------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity afifo is
   generic 
   (
        DATA_WIDTH  : natural;
        FIFO_DEPTH  : natural
   );
   port 
   (
        rclock_in       : in std_logic;
        wclock_in       : in std_logic;
        reset_in        : in std_logic;
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_in        : in std_logic;
        read_in         : in std_logic;
        q_out           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        empty_out       : out std_logic;
        full_out        : out std_logic
   );
end afifo;

architecture rtl of afifo is

-- Declare the RAM signal.	
signal q:std_logic_vector(DATA_WIDTH-1 downto 0);
signal raddr:std_logic_vector(FIFO_DEPTH-1 downto 0);
signal waddr_gray_r:std_logic_vector(FIFO_DEPTH downto 0);
signal raddr_gray_r:std_logic_vector(FIFO_DEPTH downto 0);
signal waddr_binary_r:std_logic_vector(FIFO_DEPTH downto 0);
signal raddr_binary_r:std_logic_vector(FIFO_DEPTH downto 0);
signal raddr_gray_next:std_logic_vector(FIFO_DEPTH downto 0);
signal waddr_gray_next:std_logic_vector(FIFO_DEPTH downto 0);
signal raddr_binary_next:std_logic_vector(FIFO_DEPTH downto 0);
signal raddr_binary_prev:std_logic_vector(FIFO_DEPTH downto 0);
signal waddr_binary_next:std_logic_vector(FIFO_DEPTH downto 0);
signal raddr_gray_sync:std_logic_vector(FIFO_DEPTH downto 0);
signal waddr_gray_sync:std_logic_vector(FIFO_DEPTH downto 0);
signal wready_r:std_logic;
signal full_r:std_logic;
signal avail_r:std_logic;

-- Convert binary code to grey code

function bin2gray(signal binary_in:in std_logic_vector(FIFO_DEPTH downto 0)) return std_logic_vector is
begin
   return binary_in(binary_in'length-1) & 
         (binary_in(binary_in'length-2 downto 0) xor 
          binary_in(binary_in'length-1 downto 1));
end bin2gray;

begin

q_out <= q;

empty_out <= not avail_r;

full_out <= full_r;

raddr_binary_next <= std_logic_vector(unsigned(raddr_binary_r)+1);

raddr_binary_prev <= std_logic_vector(unsigned(raddr_binary_r)-1);

raddr_gray_next <= bin2gray(raddr_binary_next);

waddr_binary_next <= std_logic_vector(unsigned(waddr_binary_r)+1);

waddr_gray_next <= bin2gray(waddr_binary_next);

raddr <= raddr_binary_r(FIFO_DEPTH-1 downto 0) when (read_in='0') else raddr_binary_next(FIFO_DEPTH-1 downto 0);

ram_i : DPRAM_DUAL_CLOCK
   generic map
      (
        numwords_a=>2**FIFO_DEPTH,
        numwords_b=>2**FIFO_DEPTH,
        widthad_a=>FIFO_DEPTH,
        widthad_b=>FIFO_DEPTH,
        width_a=>DATA_WIDTH,
        width_b=>DATA_WIDTH
      )
   port map
       (
        address_a => waddr_binary_r(FIFO_DEPTH-1 downto 0),
        address_b => raddr,
        clock_a => wclock_in,
        clock_b => rclock_in,
        data_a => data_in,
        wren_a => write_in,
        q_b => q
      );

-- gray counter cross from write clock domain to read domain
      
sync_i1 : CCD_SYNC
   generic map 
      (
      WIDTH=>FIFO_DEPTH+1      
      )
   port map
      (
      inclock_in =>wclock_in,
      outclock_in => rclock_in,
      reset_in => reset_in,
      input_in => waddr_gray_r,
      output_out => waddr_gray_sync
      );

-- gray counter cross from read domain to write clock domain

sync_i2 : CCD_SYNC
   generic map 
      (
      WIDTH=>FIFO_DEPTH+1      
      )
   port map
      (
      outclock_in => wclock_in,
      inclock_in => rclock_in,
      reset_in => reset_in,
      input_in => raddr_gray_r,
      output_out => raddr_gray_sync
      );

      
process(rclock_in,reset_in)
begin
   if(reset_in='0') then
      raddr_gray_r <= (others=>'0');
      raddr_binary_r <= (others=>'0');
      avail_r <= '0';
   else
      if(rising_edge(rclock_in)) then 
         if read_in='1' then
            raddr_gray_r <= raddr_gray_next;
            raddr_binary_r <= raddr_binary_next;
            if((raddr_gray_next(FIFO_DEPTH)=waddr_gray_sync(FIFO_DEPTH)) and
               (raddr_gray_next(FIFO_DEPTH-2 downto 0)=waddr_gray_sync(FIFO_DEPTH-2 downto 0)) and
               ((raddr_gray_next(FIFO_DEPTH) xor raddr_gray_next(FIFO_DEPTH-1))=(waddr_gray_sync(FIFO_DEPTH) xor waddr_gray_sync(FIFO_DEPTH-1)))) then
               avail_r <= '0';
            else
               avail_r <= '1';
            end if;
         else
            if((raddr_gray_r(FIFO_DEPTH)=waddr_gray_sync(FIFO_DEPTH)) and
               (raddr_gray_r(FIFO_DEPTH-2 downto 0)=waddr_gray_sync(FIFO_DEPTH-2 downto 0)) and
               ((raddr_gray_r(FIFO_DEPTH) xor raddr_gray_r(FIFO_DEPTH-1))=(waddr_gray_sync(FIFO_DEPTH) xor waddr_gray_sync(FIFO_DEPTH-1)))) then
               avail_r <= '0';
            else
               avail_r <= '1';
            end if;
         end if;
      end if;
   end if;
end process;

-- write domain logic

process(wclock_in,reset_in)
begin
   if(reset_in='0') then
      waddr_gray_r <= (others=>'0');
      waddr_binary_r <= (others=>'0');
      wready_r <= '0';
      full_r <= '0';
   else
      if(rising_edge(wclock_in)) then
         wready_r <= '1'; 
         if(write_in = '1') then
            waddr_gray_r <= waddr_gray_next;
            waddr_binary_r <= waddr_binary_next;
            if((raddr_gray_sync(FIFO_DEPTH)/=waddr_gray_next(FIFO_DEPTH)) and
               (raddr_gray_sync(FIFO_DEPTH-2 downto 0)= waddr_gray_next(FIFO_DEPTH-2 downto 0)) and
               ((raddr_gray_sync(FIFO_DEPTH) xor raddr_gray_sync(FIFO_DEPTH-1))=(waddr_gray_next(FIFO_DEPTH) xor waddr_gray_next(FIFO_DEPTH-1)))) then
               full_r <= '1';
            else
               full_r <= '0';
            end if;
         else
            if((raddr_gray_sync(FIFO_DEPTH)/=waddr_gray_r(FIFO_DEPTH)) and
               (raddr_gray_sync(FIFO_DEPTH-2 downto 0)= waddr_gray_r(FIFO_DEPTH-2 downto 0)) and
               ((raddr_gray_sync(FIFO_DEPTH) xor raddr_gray_sync(FIFO_DEPTH-1))=(waddr_gray_r(FIFO_DEPTH) xor waddr_gray_r(FIFO_DEPTH-1)))) then
               full_r <= '1';
            else
               full_r <= '0';
            end if;
         end if; 
      end if;
   end if;
end process;

end rtl;
