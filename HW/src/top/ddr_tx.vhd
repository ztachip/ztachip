------------------------------------------------------------------------------
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

-------
-- This component interfaces with DDR using avalon burst access mode in TX mode
-------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY ddr_tx IS
    port(
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;
       
        -- Bus interface for write master to DDR

        SIGNAL write_addr_in            : IN STD_LOGIC_VECTOR(dp_full_addr_width_c-1 DOWNTO 0);
        SIGNAL write_cs_in              : IN STD_LOGIC;
        SIGNAL write_in                 : IN STD_LOGIC;
        SIGNAL write_vector_in          : IN dp_vector_t;   
        SIGNAL write_end_in             : IN vector_t;
        SIGNAL write_data_in            : IN STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL write_wait_request_out   : OUT STD_LOGIC;
        SIGNAL write_burstlen_in        : IN burstlen_t;
        SIGNAL write_burstlen2_in       : IN burstlen2_t;
        SIGNAL write_burstlen3_in       : IN burstlen_t;

        SIGNAL ddr_awaddr_out           : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_awlen_out            : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
        SIGNAL ddr_awvalid_out          : OUT std_logic;
        SIGNAL ddr_waddr_out            : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_wvalid_out           : OUT std_logic;
        SIGNAL ddr_wdata_out            : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL ddr_wlast_out            : OUT std_logic;
        SIGNAL ddr_wbe_out              : OUT std_logic_vector(ddr_data_byte_width_c-1 downto 0);
        SIGNAL ddr_awready_in           : IN std_logic;
        SIGNAL ddr_wready_in            : IN std_logic;
        SIGNAL ddr_bresp_in             : IN std_logic;
        
        SIGNAL ddr_awburst_out          : OUT std_logic_vector(1 downto 0);
        SIGNAL ddr_awcache_out          : OUT std_logic_vector(3 downto 0);
        SIGNAL ddr_awid_out             : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_awlock_out           : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_awprot_out           : OUT std_logic_vector(2 downto 0);
        SIGNAL ddr_awqos_out            : OUT std_logic_vector(3 downto 0);
        SIGNAL ddr_awsize_out           : OUT std_logic_vector(2 downto 0);
        SIGNAL ddr_bready_out           : OUT std_logic;   
        
        SIGNAL ddr_tx_busy_out          : OUT std_logic
        );
END ddr_tx;

ARCHITECTURE ddr_tx_behavior of ddr_tx IS 

----
-- DDR write command to be sent to async FIFO before going to external bus
-- We would like to go through async FIFO since external bus is in a different clock domain
-- ddr_write_cmt_t is the write request format that get pushed to the async FIFO
-- Also define corresponding pack/unpack function for this record
------

type ddr_write_cmd_t is
record
   burstbegin:std_logic; -- Begin of burst
   burstlen:burstlen_t;  -- Burst length
   addr:std_logic_vector(ddr_bus_width_c-1 downto 0); -- Destination memory address
   byteena:std_logic_vector(ddr_data_byte_width_c-1 downto 0); -- Associated byteEnable with this write
   last:std_logic;
end record;

signal dummy1:ddr_write_cmd_t;

constant ddr_write_cmd_length_c:integer:=(1+
                                          dummy1.burstlen'length+
                                          dummy1.addr'length+
                                          dummy1.byteena'length+
                                          1);
 
subtype ddr_write_cmd_flat_t is std_logic_vector(ddr_write_cmd_length_c-1 downto 0);

---
-- Packet DDR write command into FIFO record
---

function pack_ddr_write_cmd(rec_in: ddr_write_cmd_t) return ddr_write_cmd_flat_t is
   variable len_v:integer;
   variable q_v:ddr_write_cmd_flat_t;
   begin
   len_v := 0;
   q_v(q_v'length-len_v-1) := rec_in.burstbegin;
   len_v := len_v+1;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burstlen'length) := std_logic_vector(rec_in.burstlen);
   len_v := len_v+rec_in.burstlen'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.addr'length) := rec_in.addr;
   len_v := len_v+rec_in.addr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.byteena'length) := rec_in.byteena;
   len_v := len_v+rec_in.byteena'length;
   q_v(q_v'length-len_v-1) := rec_in.last;
   len_v := len_v+1;
   return q_v;
end function pack_ddr_write_cmd;

---
-- Unpacket DDR write command from FIFO record
----

function unpack_ddr_write_cmd(q_in: ddr_write_cmd_flat_t) return ddr_write_cmd_t is
   variable len_v:integer;
   variable rec_v:ddr_write_cmd_t;
   begin
   len_v := 0;
   rec_v.burstbegin := q_in(q_in'length-len_v-1);
   len_v := len_v+1;
   rec_v.burstlen := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burstlen'length));
   len_v := len_v+rec_v.burstlen'length;
   rec_v.addr := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.addr'length);
   len_v := len_v+rec_v.addr'length;
   rec_v.byteena := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.byteena'length);
   len_v := len_v+rec_v.byteena'length;
   rec_v.last := q_in(q_in'length-len_v-1);
   len_v := len_v+1;
   return rec_v;
end function unpack_ddr_write_cmd;


---- Constants
----
constant write_data_fifo_depth_c:integer:=4;
constant write_data_fifo_size_c:integer:=(2**write_data_fifo_depth_c);

constant all_ones_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_ones2_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_zeros_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'0');
constant all_zeros2_c:std_logic_vector(ddr_data_byte_width_c-1 downto 0):=(others=>'0');
constant all_zeros3_c:std_logic_vector(ddr_bus_width_c-1 downto 0):=(others=>'0');

SIGNAL write_burstlen_r:burstlen_t;
SIGNAL next_write_burstlen:burstlen_t;
SIGNAL burstbegin:std_logic;
SIGNAL wrburstbegin:STD_LOGIC;
SIGNAL wrburstbegin_r:STD_LOGIC;

SIGNAL write2:STD_LOGIC;

SIGNAL ddr_write:STD_LOGIC;
SIGNAL byteenable:STD_LOGIC_VECTOR(2*ddr_data_byte_width_c-1 downto 0);
SIGNAL ddr_write_cmd:ddr_write_cmd_t;
SIGNAL write_data_write:ddr_write_cmd_t;
SIGNAL write_data_write_r:ddr_write_cmd_t;
SIGNAL wdata:STD_LOGIC_VECTOR(ddr_write_cmd_length_c+ddr_data_width_c-1 downto 0);
SIGNAL write_data_write_ena:STD_LOGIC;
SIGNAL write_data_write_ena_r:STD_LOGIC;
SIGNAL write_data_write_ena_rr:STD_LOGIC;
SIGNAL write_data_write_ena_rrr:STD_LOGIC;
SIGNAL write_data_write_ena_rrrr:STD_LOGIC;
SIGNAL write_data_read_ena:STD_LOGIC;
SIGNAL write_data_read_empty:STD_LOGIC;
SIGNAL write_data_read_empty_r:STD_LOGIC;
SIGNAL write_data_write_full:STD_LOGIC;
SIGNAL write_data_write_full_r:STD_LOGIC;
SIGNAL write_data_write_usedw:std_logic_vector(write_data_fifo_depth_c-1 downto 0);
SIGNAL write_data_read:STD_LOGIC_VECTOR(ddr_write_cmd_length_c+ddr_data_width_c-1 downto 0);
SIGNAL write_burst_write_ena:std_logic;
SIGNAL write_burst_write:std_logic_vector(burstlen_t'length+ddr_bus_width_c-1 downto 0);
SIGNAL write_burst_read_ena:std_logic;
SIGNAL write_burstlen:burstlen_t;
SIGNAL write_burstbegin:std_logic;
SIGNAL write_ddr_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL write_data:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 downto 0);
SIGNAL write_data_r:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 downto 0);
SIGNAL write_data_2_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL byteenable_r:STD_LOGIC_VECTOR(2*ddr_data_byte_width_c-1 downto 0);
SIGNAL beginburst_r:STD_LOGIC;
SIGNAL wr_ddr_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL write_next_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL wr_ddr_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL wr_ddr_burstlen:burstlen_t;
SIGNAL wr_ddr_burstlen_r:burstlen_t;
SIGNAL write_burstlen2:burstlen_t;
SIGNAL write_burstlen3:burstlen_t;

SIGNAL w_x1:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_x2:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_x4:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_x8:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);

SIGNAL w_mask1:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask2:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask3:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask4:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask5:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask6:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask7:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);
SIGNAL w_mask8:STD_LOGIC_VECTOR(ddr_data_byte_width_c/8-1 DOWNTO 0);

SIGNAL write_piggyback:STD_LOGIC;
SIGNAL write_complete:STD_LOGIC;
SIGNAL write_over_complete:STD_LOGIC;
SIGNAL write_flush_r:STD_LOGIC;
SIGNAL write_can_piggyback_r:STD_LOGIC;

SIGNAL write_request_r:unsigned(4+ddr_max_write_pend_depth_c-1 downto 0);
SIGNAL write_complete_r:unsigned(4+ddr_max_write_pend_depth_c-1 downto 0);
SIGNAL write_burst_remain_r:burstlen_t;

SIGNAL full3:std_logic;
SIGNAL full3_r:std_logic;

SIGNAL ddr_wvalid_r:std_logic;
SIGNAL awvalid_sent_r:std_logic;
SIGNAL ddr_byteenable_r:std_logic_vector(ddr_data_byte_width_c-1 downto 0);
SIGNAL ddr_waddr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL ddr_wdata_r:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL ddr_wlast_r:std_logic;
   
SIGNAL write_last_count_down_r:burstlen_t;
SIGNAL write_last_count_down:burstlen_t;

attribute noprune: boolean; 
attribute noprune of full3_r: signal is true;

BEGIN

write_data_fifo_i:scfifo
	generic map 
	(
		DATA_WIDTH=>ddr_write_cmd_length_c+ddr_data_width_c,
		FIFO_DEPTH=>write_data_fifo_depth_c,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
		clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>wdata,
        write_in=>write_data_write_ena_r,
        read_in=>write_data_read_ena,
        q_out=>write_data_read,
        ravail_out=>open,
        wused_out=>write_data_write_usedw,
        empty_out=>write_data_read_empty,
        full_out=>full3,
        almost_full_out=>open
	);


-- Burst cycle...

ddr_awvalid_out <= write_burstbegin and (not awvalid_sent_r);

ddr_awaddr_out <= write_ddr_addr;

ddr_awlen_out <= write_burstlen(ddr_burstlen_width_c-1 downto 0);

-- Data cycle...

ddr_wvalid_out <= ddr_wvalid_r;

ddr_waddr_out <= ddr_waddr_r;

ddr_wdata_out <= ddr_wdata_r;

ddr_wbe_out <= ddr_byteenable_r;

ddr_wlast_out <= ddr_wlast_r;

ddr_awburst_out <= "01"; 

ddr_awcache_out <= "0011";

ddr_awid_out <= "0";

ddr_awlock_out <= "0";

ddr_awprot_out <= "000";

ddr_awqos_out <= "0000";

ddr_bready_out <= '1';

ddr_awsize_out <= "011";


-- Condition to move to next transaction...

write_data_read_ena <= '1' when (ddr_write='1') and 
                                (ddr_wvalid_r='0' or ddr_wready_in='1') and 
                                (ddr_awready_in='1' or write_burstbegin='0' or awvalid_sent_r='1')
                        else '0';


process(reset_in,clock_in)
begin
   if reset_in = '0' then
      ddr_wvalid_r <= '0';
      awvalid_sent_r <= '0';
      ddr_byteenable_r <= (others=>'0');
      ddr_waddr_r <= (others=>'0');
      ddr_wdata_r <= (others=>'0');
      ddr_wlast_r <= '0';
   else
      if clock_in'event and clock_in='1' then
         if write_data_read_ena='1' then
            ddr_waddr_r <= write_ddr_addr;
            ddr_wdata_r <= write_data_read(ddr_data_width_c-1 downto 0);
            ddr_wvalid_r <= '1';
            awvalid_sent_r <= '0';
            ddr_byteenable_r <= ddr_write_cmd.byteena;
            ddr_wlast_r <= ddr_write_cmd.last;
         else 
            if ddr_wready_in='1' then
               ddr_wvalid_r <= '0';
            end if;
            if write_burstbegin='1' and ddr_awready_in='1' then
               awvalid_sent_r <= '1';
            end if; 
         end if;
      end if;
   end if;
end process;



ddr_tx_busy_out <= '0' when ((write_request_r=write_complete_r) and (write_data_read_empty='1')) else '0';

wdata <= pack_ddr_write_cmd(write_data_write_r) & write_data_2_r;

ddr_write <= (not write_data_read_empty);

ddr_write_cmd <= unpack_ddr_write_cmd(write_data_read(write_data_read'length-1 downto ddr_data_width_c));

write_burstbegin <= ddr_write and ddr_write_cmd.burstbegin;

write_ddr_addr <= ddr_write_cmd.addr;

write_burstlen <= ddr_write_cmd.burstlen;

write_data_write_full <= '1' when unsigned(write_data_write_usedw) >= to_unsigned(write_data_fifo_size_c-4,write_data_fifo_depth_c) else '0';

-- Check if we can piggyback this write request with the current burst left over.

write_piggyback <= '1' when (write_in='1' and 
                            write_burstlen_in /= to_unsigned(0,burstlen_t'length) and 
                            (write_data_write_full_r='0') and
                            write_burstlen_r=to_unsigned(0,burstlen_t'length) and 
                            write_flush_r='0' and
                            write_can_piggyback_r='1')
                     else '0';

-- Would the current transmit request complete the current word.
write_complete <= '1' when ((unsigned('0' & write_addr_in(ddr_vector_depth_c-1 downto 0))+unsigned('0' & write_vector_in)+to_unsigned(1,ddr_vector_depth_c+1))>=to_unsigned(ddr_vector_width_c,ddr_vector_depth_c+1))
                      else '0';

-- Would the current transmit request spilled over to next word?
write_over_complete <= '1' when ((unsigned('0' & write_addr_in(ddr_vector_depth_c-1 downto 0))+unsigned('0' & write_vector_in)+to_unsigned(1,ddr_vector_depth_c+1))>to_unsigned(ddr_vector_width_c,ddr_vector_depth_c+1))
                           else '0';

write_data_write_ena <= '1' when (((write2='1' and 
                                 ((next_write_burstlen=to_unsigned(0,burstlen_t'length) and write_burstlen_in=to_unsigned(1,write_burstlen_in'length)) or write_complete='1')) 
                                 or
                                 (write_piggyback='1' and (write_burstlen_in=to_unsigned(1,write_burstlen_in'length) or write_complete='1')) or
                                 (write_flush_r='1')) and
                                 (write_data_write_full_r='0'))
                                 else '0';

wrburstbegin <= (burstbegin or wrburstbegin_r);

write2 <= write_in when (write_data_write_full_r='0' and
                        write_burstlen_in /= to_unsigned(0,burstlen_t'length) and
                        write_flush_r='0' and
                        write_piggyback='0') 
                        else '0';

burstbegin <= '1' when (write2='1' and write_burstlen_r=to_unsigned(0,burstlen_t'length)) else '0';

write_wait_request_out <= '1' when ((write_data_write_full_r='1') or (write_flush_r='1')) else '0';

----
-- Create new write request
----

process(write_flush_r,byteenable,wr_ddr_addr,wr_ddr_burstlen,wrburstbegin,write_next_addr_r,write_burstlen_r,write_burst_remain_r,write_last_count_down_r)
begin
   if write_flush_r='0' then
      write_data_write.addr <= wr_ddr_addr;
      write_data_write.byteena <= byteenable(ddr_data_byte_width_c-1 downto 0);
   else
      write_data_write.addr <= write_next_addr_r;
      write_data_write.byteena <= byteenable(ddr_data_byte_width_c-1 downto 0);       
   end if;
   write_data_write.burstbegin <= '1';
   write_data_write.burstlen <= to_unsigned(0,burstlen_t'length);
   write_data_write.last <= '1'; 
   
   -- Track the last transaction 
   
--   if write_data_write.burstbegin='1' then
--      if write_data_write.burstlen=to_unsigned(0,burstlen_t'length) then
--         write_data_write.last <= '1';     
--         write_last_count_down <= to_unsigned(0,burstlen_t'length);
--      else
--         write_data_write.last <= '0';
--         write_last_count_down <= write_data_write.burstlen;
--      end if;
--   else
--      if write_last_count_down_r = to_unsigned(1,burstlen_t'length) then
--         write_data_write.last <= '1';
--         write_last_count_down <= to_unsigned(0,burstlen_t'length);
--      else
--         write_data_write.last <= '0';
--         write_last_count_down <= write_last_count_down_r-1;
--      end if;
--   end if;
   
--   if write_flush_r='0' and wrburstbegin='1' then
--      if wr_ddr_burstlen=to_unsigned(1,write_data_write.burstlen'length) then
--         write_data_write.last <= '1';
--      else
--         write_data_write.last <= '0';
--      end if;
--   else
--      if write_burstlen_r=to_unsigned(1,write_burst_remain_r'length) then
--         write_data_write.last <= '1';
--      else
--         write_data_write.last <= '0';
--      end if;
--   end if;  
end process;

----
-- Find burstlen required for the write request.
------

process(write_vector_in,write_addr_in,write_burstlen_in,write_burstlen2_in,write_burstlen3_in,write_piggyback)
   variable temp2_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp3_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp4_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp5_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp6_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable write_vector_v:unsigned(ddr_vector_depth_c-1 downto 0);
   begin
   write_burstlen2 <= write_burstlen3_in;
   temp2_v := resize(unsigned(write_addr_in(ddr_vector_depth_c-1 downto 0)),temp2_v'length);
   temp3_v := write_burstlen2_in+temp2_v+resize(unsigned(all_ones2_c),temp2_v'length);
   temp4_v := temp3_v srl ddr_vector_depth_c;
   write_burstlen3 <= resize(temp4_v,write_burstlen3'length);
end process;


process(write_addr_in,write_burstlen2,write_burstlen3,
       wrburstbegin_r,wr_ddr_burstlen_r,wr_ddr_addr_r,write_vector_in)
variable write_burstlen_v:std_logic_vector(burstlen_t'length-1 downto 0);
variable ddr_addr_v:std_logic_vector(ddr_bus_width_c-1 downto 0);
   begin
   if wrburstbegin_r='0' then
      ddr_addr_v(ddr_bus_width_c-1 downto dp_full_addr_width_c+data_byte_width_depth_c) := (others=>'0');
      ddr_addr_v(dp_full_addr_width_c+data_byte_width_depth_c-1 downto ddr_vector_depth_c+data_byte_width_depth_c) := write_addr_in(dp_full_addr_width_c-1 downto ddr_vector_depth_c);
      ddr_addr_v(ddr_vector_depth_c+data_byte_width_depth_c-1 downto 0) := (others=>'0');
      wr_ddr_burstlen <= unsigned(write_burstlen3);
      wr_ddr_addr <= std_logic_vector(unsigned(ddr_addr_v));
   else
      wr_ddr_burstlen <= wr_ddr_burstlen_r;
      ddr_addr_v := wr_ddr_addr_r;
      wr_ddr_addr <= ddr_addr_v;
   end if;
end process;

------------------
-- Calculate next burstlen after current transaction
------------------

process(write2,write_burstlen_r,write_burstlen2)
begin
if write2='1' then
   if write_burstlen_r=to_unsigned(0,burstlen_t'length) then
      next_write_burstlen <= write_burstlen2-1;
   else
      next_write_burstlen <= write_burstlen_r-1;
   end if;
else
   next_write_burstlen <= write_burstlen_r;
end if;
end process;

process(reset_in,clock_in)
begin
   if reset_in = '0' then
      write_burstlen_r <= (others=>'0');
      write_data_write_ena_r <= '0';
      write_data_write_ena_rr <= '0';
      write_data_write_ena_rrr <= '0';
      write_data_write_ena_rrrr <= '0';
      write_data_read_empty_r <= '0';
      write_data_write_r <= ('0',(others=>'0'),(others=>'0'),(others=>'0'),'0');
      write_next_addr_r <= (others=>'0');
      write_can_piggyback_r <= '0';
      write_flush_r <= '0';
      write_data_write_full_r <= '0';
      write_request_r <= (others=>'0');
      write_complete_r <= (others=>'0');
      write_burst_remain_r <= (others=>'0');
      full3_r <= '0';
      write_last_count_down_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         full3_r <= full3;
         if write_data_write_ena='1' then
            write_last_count_down_r <=write_last_count_down;
         end if;
         write_burstlen_r <= next_write_burstlen;
         write_data_write_ena_r <= write_data_write_ena;
         write_data_write_ena_rr <= write_data_write_ena_r;
         write_data_write_ena_rrr <= write_data_write_ena_rr;
         write_data_write_ena_rrrr <= write_data_write_ena_rrr;
         write_data_read_empty_r <= write_data_read_empty;
         write_data_write_r <= write_data_write;
         if write_data_write_ena='1' then
            if write_piggyback='1' or write_flush_r='1' then
               write_can_piggyback_r <= '0';
            else
               write_can_piggyback_r <= write_over_complete;
            end if;
         elsif write2='1' then
            write_can_piggyback_r <= '1';
         end if;
         if write_data_write_ena='1' then
            if write_flush_r='0' then
               if write_burstlen_in=to_unsigned(1,burstlen_t'length) and write_over_complete='1' then
                  write_flush_r <= '1';
               else
                  write_flush_r <= '0';
               end if;
            else
               write_flush_r <= '0';
            end if;
         end if;
         if write_data_write_ena='1' then
            if write_data_write.burstbegin='1' then
               write_burst_remain_r <= write_data_write.burstlen;
            else
               write_burst_remain_r <= write_burst_remain_r-1;
            end if;
         end if;
         if write_data_write_ena='1' then
            write_next_addr_r <= std_logic_vector(unsigned(wr_ddr_addr)+to_unsigned(2**(ddr_vector_depth_c+data_byte_width_depth_c),write_next_addr_r'length));
         end if;
         if(write_data_write_ena='1' and write_data_write.burstbegin='1') then
            write_request_r <= write_request_r+1;
         end if;
         if ddr_bresp_in='1' then
            write_complete_r <= write_complete_r+1;
         end if;           
         if  (signed(write_request_r)-signed(write_complete_r) >= to_signed(ddr_max_write_pend_c-1,write_complete_r'length)) or
             (write_data_write_full='1') then
            write_data_write_full_r <= '1';
         else
            write_data_write_full_r <= '0';
         end if;
         
      end if;
   end if;
end process;

process(write_vector_in)
begin
   if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
      w_x1 <= (others=>'1');
      w_x2 <= (others=>'1');
      w_x4 <= (others=>'1');
      w_x8 <= (others=>'0');
   elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then
      w_x1 <= (others=>'1');
      w_x2 <= (others=>'1');
      w_x4 <= (others=>'0');
      w_x8 <= (others=>'0');
   elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
      w_x1 <= (others=>'1');
      w_x2 <= (others=>'0');
      w_x4 <= (others=>'0');
      w_x8 <= (others=>'0');
   else
      w_x1 <= (others=>'1');
      w_x2 <= (others=>'1');
      w_x4 <= (others=>'1');
      w_x8 <= (others=>'1');
   end if;
end process;

w_mask1 <= (others=>'1') when (write_end_in >= to_unsigned(1,vector_t'length)) else (others=>'0');
w_mask2 <= (others=>'1') when (write_end_in >= to_unsigned(2,vector_t'length)) else (others=>'0');
w_mask3 <= (others=>'1') when (write_end_in >= to_unsigned(3,vector_t'length)) else (others=>'0');
w_mask4 <= (others=>'1') when (write_end_in >= to_unsigned(4,vector_t'length)) else (others=>'0');
w_mask5 <= (others=>'1') when (write_end_in >= to_unsigned(5,vector_t'length)) else (others=>'0');
w_mask6 <= (others=>'1') when (write_end_in >= to_unsigned(6,vector_t'length)) else (others=>'0');
w_mask7 <= (others=>'1') when (write_end_in >= to_unsigned(7,vector_t'length)) else (others=>'0');
w_mask8 <= (others=>'1') when (write_end_in >= to_unsigned(8,vector_t'length)) else (others=>'0');

---
-- Generate byteenable mask
----

process(write2,write_piggyback,write_vector_in,write_addr_in,write_data_r,write_data_in,byteenable_r,w_x1,w_x2,w_x4,w_x8,
        w_mask1,w_mask2,w_mask3,w_mask4,w_mask5,w_mask6,w_mask7,w_mask8)
begin
if(write2='1' or write_piggyback='1') then
    case write_addr_in(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
        when "000" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8) <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8) <= byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8) <= byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8)  <= byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= byteenable_r(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1  downto 1*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1  downto 0*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "001" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8) <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8) <= byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8) <= byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8) <= byteenable_r(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1  downto 1*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1  downto 0*ddr_data_byte_width_c/8)  <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "010" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8) <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8)  <= byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8) <= byteenable_r(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1  downto 1*ddr_data_byte_width_c/8)  <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "011" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8) <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8)  <= byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= byteenable_r(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1  downto 2*ddr_data_byte_width_c/8)  <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "100" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8) <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8)  <= byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= byteenable_r(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1  downto 3*ddr_data_byte_width_c/8)  <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "101" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8) <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8)  <= byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8)  <= byteenable_r(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1  downto 4*ddr_data_byte_width_c/8)  <= byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when "110" =>
            byteenable(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8)  <= byteenable_r(16*ddr_data_byte_width_c/8-1 downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1  downto 14*ddr_data_byte_width_c/8)  <= byteenable_r(15*ddr_data_byte_width_c/8-1  downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1  downto 5*ddr_data_byte_width_c/8)  <= byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8) <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
        when others =>
            byteenable(16*ddr_data_byte_width_c/8-1  downto 15*ddr_data_byte_width_c/8)  <= byteenable_r(16*ddr_data_byte_width_c/8-1  downto 15*ddr_data_byte_width_c/8);
            byteenable(15*ddr_data_byte_width_c/8-1  downto 14*ddr_data_byte_width_c/8)  <= (w_mask8 and w_x8) or byteenable_r(15*ddr_data_byte_width_c/8-1 downto 14*ddr_data_byte_width_c/8);
            byteenable(14*ddr_data_byte_width_c/8-1  downto 13*ddr_data_byte_width_c/8)  <= (w_mask7 and w_x8) or byteenable_r(14*ddr_data_byte_width_c/8-1 downto 13*ddr_data_byte_width_c/8);
            byteenable(13*ddr_data_byte_width_c/8-1  downto 12*ddr_data_byte_width_c/8)  <= (w_mask6 and w_x8) or byteenable_r(13*ddr_data_byte_width_c/8-1 downto 12*ddr_data_byte_width_c/8);
            byteenable(12*ddr_data_byte_width_c/8-1  downto 11*ddr_data_byte_width_c/8)  <= (w_mask5 and w_x8) or byteenable_r(12*ddr_data_byte_width_c/8-1 downto 11*ddr_data_byte_width_c/8);
            byteenable(11*ddr_data_byte_width_c/8-1  downto 10*ddr_data_byte_width_c/8)  <= (w_mask4 and w_x4) or byteenable_r(11*ddr_data_byte_width_c/8-1 downto 10*ddr_data_byte_width_c/8);
            byteenable(10*ddr_data_byte_width_c/8-1  downto 9*ddr_data_byte_width_c/8)  <= (w_mask3 and w_x4) or byteenable_r(10*ddr_data_byte_width_c/8-1 downto 9*ddr_data_byte_width_c/8);
            byteenable(9*ddr_data_byte_width_c/8-1  downto 8*ddr_data_byte_width_c/8)  <= (w_mask2 and w_x2) or byteenable_r(9*ddr_data_byte_width_c/8-1 downto 8*ddr_data_byte_width_c/8);
            byteenable(8*ddr_data_byte_width_c/8-1  downto 7*ddr_data_byte_width_c/8)  <= (w_mask1 and w_x1) or byteenable_r(8*ddr_data_byte_width_c/8-1 downto 7*ddr_data_byte_width_c/8);
            byteenable(7*ddr_data_byte_width_c/8-1  downto 6*ddr_data_byte_width_c/8)  <= byteenable_r(7*ddr_data_byte_width_c/8-1 downto 6*ddr_data_byte_width_c/8);
            byteenable(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8) <= byteenable_r(6*ddr_data_byte_width_c/8-1 downto 5*ddr_data_byte_width_c/8);
            byteenable(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8) <= byteenable_r(5*ddr_data_byte_width_c/8-1 downto 4*ddr_data_byte_width_c/8);
            byteenable(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8) <= byteenable_r(4*ddr_data_byte_width_c/8-1 downto 3*ddr_data_byte_width_c/8);
            byteenable(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8) <= byteenable_r(3*ddr_data_byte_width_c/8-1 downto 2*ddr_data_byte_width_c/8);
            byteenable(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8) <= byteenable_r(2*ddr_data_byte_width_c/8-1 downto 1*ddr_data_byte_width_c/8);
            byteenable(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8)  <= byteenable_r(1*ddr_data_byte_width_c/8-1 downto 0*ddr_data_byte_width_c/8);
    end case;
else
   byteenable <= byteenable_r;
end if;
end process;

process(write_data_r,write2,write_piggyback,write_addr_in,write_data_in,write_vector_in)
begin
write_data <= write_data_r;
if(write2='1' or write_piggyback='1') then
    case write_addr_in(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
        when "000" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
                write_data(ddr_data_width_c/8+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
                write_data(ddr_data_width_c/1+0*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "001" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
                write_data(ddr_data_width_c/8+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
                write_data(ddr_data_width_c/1+1*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "010" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+2*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "011" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+3*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "100" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+4*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "101" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+5*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when "110" =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+6*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
        when others =>
            if unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/2-1,write_vector_in'length) then
                write_data(ddr_data_width_c/2+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/2-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/4-1,write_vector_in'length) then 
                write_data(ddr_data_width_c/4+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/4-1 downto 0);
            elsif unsigned(write_vector_in)=to_unsigned(ddr_vector_width_c/8-1,write_vector_in'length) then
               write_data(ddr_data_width_c/8+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/8-1 downto 0);
            else
               write_data(ddr_data_width_c/1+7*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8) <= write_data_in(ddr_data_width_c/1-1 downto 0);
            end if;
    end case;
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in = '0' then
    byteenable_r <= (others=>'0');
    wrburstbegin_r <= '0';
    wr_ddr_addr_r <= (others=>'0');
    wr_ddr_burstlen_r <= (others=>'0');
    write_data_r <= (others=>'0');
    write_data_2_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
       if(write_data_write_ena='1') then
          byteenable_r(ddr_data_byte_width_c-1 downto 0) <= byteenable(2*ddr_data_byte_width_c-1 downto ddr_data_byte_width_c);
          byteenable_r(2*ddr_data_byte_width_c-1 downto ddr_data_byte_width_c) <= (others=>'0');
          write_data_r(ddr_data_width_c-1 downto 0) <= write_data(2*ddr_data_width_c-1 downto ddr_data_width_c);
          write_data_2_r <= write_data(ddr_data_width_c-1 downto 0);
          wrburstbegin_r <= '0';
          wr_ddr_addr_r <= (others=>'0');
          wr_ddr_burstlen_r <= (others=>'0');
       elsif write2='1' or write_piggyback='1' then
          write_data_r <= write_data;
          byteenable_r <= byteenable;
          if(burstbegin='1') then
             wrburstbegin_r <= burstbegin;
             wr_ddr_addr_r <= wr_ddr_addr;
             wr_ddr_burstlen_r <= wr_ddr_burstlen;
          end if;
       end if;
    end if;
end if;
end process;

END ddr_tx_behavior;
