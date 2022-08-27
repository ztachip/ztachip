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
-- This component interfaces with DDR RX 
-------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY ddr_rx IS
    port(
        SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;

        -- Bus interface for read2 master to DDR

        SIGNAL read_addr_in             : IN STD_LOGIC_VECTOR(dp_full_addr_width_c-1 DOWNTO 0);
        SIGNAL read_cs_in               : IN STD_LOGIC;
        SIGNAL read_in                  : IN STD_LOGIC;
        SIGNAL read_vm_in               : IN STD_LOGIC;
        SIGNAL read_vector_in           : IN dp_vector_t;
        SIGNAL read_fork_in             : IN STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
        SIGNAL read_start_in            : unsigned(ddr_vector_depth_c downto 0);
        SIGNAL read_end_in              : unsigned(ddr_vector_depth_c downto 0);
        SIGNAL read_data_ready_out      : OUT STD_LOGIC;
        SIGNAL read_fork_out            : OUT STD_LOGIC_VECTOR(fork_max_c-1 downto 0);
        SIGNAL read_data_wait_in        : IN STD_LOGIC;
        SIGNAL read_data_valid_out      : OUT STD_LOGIC;
        SIGNAL read_data_valid_vm_out   : OUT STD_LOGIC;
        SIGNAL read_data_out            : OUT STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
        SIGNAL read_wait_request_out    : OUT STD_LOGIC;
        SIGNAL read_burstlen_in         : IN burstlen_t;
        SIGNAL read_filler_data_in      : IN STD_LOGIC_VECTOR(2*data_width_c-1 downto 0);

       
        SIGNAL ddr_araddr_out           : OUT std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_arlen_out            : OUT unsigned(ddr_burstlen_width_c-1 downto 0);
        SIGNAL ddr_arvalid_out          : OUT std_logic;
        SIGNAL ddr_rvalid_in            : IN std_logic;
        SIGNAL ddr_rlast_in             : IN std_logic;
        SIGNAL ddr_rdata_in             : IN std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL ddr_arready_in           : IN std_logic;
        SIGNAL ddr_rready_out           : OUT std_logic;
        
        SIGNAL ddr_arburst_out          : OUT std_logic_vector(1 downto 0);
        SIGNAL ddr_arcache_out          : OUT std_logic_vector(3 downto 0);
        SIGNAL ddr_arid_out             : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_arlock_out           : OUT std_logic_vector(0 downto 0);
        SIGNAL ddr_arprot_out           : OUT std_logic_vector(2 downto 0);
        SIGNAL ddr_arqos_out            : OUT std_logic_vector(3 downto 0); 
        SIGNAL ddr_arsize_out           : OUT std_logic_vector(2 downto 0)
        );
END ddr_rx;

ARCHITECTURE ddr_rx_behavior of ddr_rx IS 

----
-- DDR read command to be sent to async FIFO before going to external bus
-- We would like to go through async FIFO since external bus is in a different clock domain
-- ddr_read_cmd_t is the read request format that get pushed to the async FIFO
-- Also define corresponding pack/unpack function for this record
------

type ddr_read_cmd_t is
record
   addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
   burstlen:unsigned(ddr_burstlen_width_c-1 downto 0);
   read:std_logic;
   burstbegin:std_logic;
end record;

signal dummy2:ddr_read_cmd_t;

constant ddr_read_cmd_length_c:integer:=( dummy2.addr'length+ -- ddr_read_cmd_t.addr
                                          dummy2.burstlen'length+ -- ddr_read_cmd_t.burstlen
                                          1+ -- ddr_read_cmd_t.read
                                          1 -- ddr_read_cmd_t.burstbegin
                                          );

subtype ddr_read_cmd_flat_t is std_logic_vector(ddr_read_cmd_length_c-1 downto 0);

------
-- Pack read command to fifo record
-----

function pack_ddr_read_cmd(rec_in: ddr_read_cmd_t) return ddr_read_cmd_flat_t is
   variable len_v:integer;
   variable q_v:ddr_read_cmd_flat_t;
   begin
   len_v:=0;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.addr'length) := rec_in.addr;
   len_v := len_v+rec_in.addr'length;
   q_v(q_v'length-len_v-1 downto q_v'length-len_v-rec_in.burstlen'length) := std_logic_vector(rec_in.burstlen-1);
   len_v := len_v+rec_in.burstlen'length;
   q_v(q_v'length-len_v-1) := rec_in.read;
   len_v := len_v+1;
   q_v(q_v'length-len_v-1) := rec_in.burstbegin;
   len_v := len_v+1;
   return q_v;
end function pack_ddr_read_cmd;

----
-- Unpack read command from FIFO record
----

function unpack_ddr_read_cmd(q_in: ddr_read_cmd_flat_t) return ddr_read_cmd_t is
   variable len_v:integer;
   variable rec_v:ddr_read_cmd_t;
   begin
   len_v := 0;
   rec_v.addr := q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.addr'length);
   len_v := len_v+rec_v.addr'length;
   rec_v.burstlen := unsigned(q_in(q_in'length-len_v-1 downto q_in'length-len_v-rec_v.burstlen'length));
   len_v := len_v+rec_v.burstlen'length;
   rec_v.read := q_in(q_in'length-len_v-1);
   len_v := len_v+1;
   rec_v.burstbegin := q_in(q_in'length-len_v-1);
   len_v := len_v+1;
   return rec_v;
end function unpack_ddr_read_cmd;

---- Constants
----
constant read_record_fifo_depth_c:integer:=6;
constant read_record_fifo_size_c:integer:=(2**read_record_fifo_depth_c);

constant all_ones_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_ones2_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_zeros_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'0');
constant all_zeros2_c:std_logic_vector(ddr_data_byte_width_c-1 downto 0):=(others=>'0');
constant all_zeros3_c:std_logic_vector(ddr_bus_width_c-1 downto 0):=(others=>'0');

subtype read_record_t is std_logic_vector((ddr_vector_depth_c+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+3+fork_max_c+1+2*data_width_c)-1 downto 0);

SIGNAL read_burstlen_r:burstlen_t;
SIGNAL next_read_burstlen:burstlen_t;
SIGNAL burstbegin:std_logic;
SIGNAL read_data_valid:STD_LOGIC;

SIGNAL read_record_write:read_record_t;
SIGNAL read_record_write_r:read_record_t;
SIGNAL read_record_write_ena:STD_LOGIC;
SIGNAL read_record_write_ena_r:STD_LOGIC;
SIGNAL read_record_write_ena_rr:STD_LOGIC;
SIGNAL read_record_write_ena_rrr:STD_LOGIC;
SIGNAL read_record_read_ena:STD_LOGIC;
SIGNAL read_record_read_empty:STD_LOGIC;
SIGNAL read_record_read_empty_r:STD_LOGIC:='1';
SIGNAL read_record_read_full:STD_LOGIC;
SIGNAL read_record_read_full_r:STD_LOGIC;
SIGNAL read_record_read:read_record_t;

SIGNAL read_data_read_ena:STD_LOGIC;
SIGNAL read_data_read_ena_2:STD_LOGIC;
SIGNAL read_data_read_empty:STD_LOGIC;
SIGNAL read_data_read:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL read_wait_request:std_logic;

SIGNAL read_data_read_r:std_logic_vector(2*ddr_data_width_c-1 downto 0);
SIGNAL read_data_read_valid_r:std_logic_vector(1 downto 0);

SIGNAL read2:STD_LOGIC;

SIGNAL ddr_read:STD_LOGIC;

SIGNAL beginburst_r:STD_LOGIC;
SIGNAL rd_ddr_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL rd_ddr_burstlen:burstlen_t;
SIGNAL read_data_ready:std_logic;

SIGNAL read_burstlen2:burstlen_t;
SIGNAL read_burstlen3:burstlen_t;
SIGNAL read_addr:STD_LOGIC_VECTOR(dp_full_addr_width_c-1 DOWNTO 0);

SIGNAL read_piggyback:STD_LOGIC;
SIGNAL read_piggyback_r:STD_LOGIC;

SIGNAL read_data:STD_LOGIC_VECTOR(ddr_data_width_c-1 DOWNTO 0);
SIGNAL read_pause_r:STD_LOGIC;
SIGNAL read_pause_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL read_pause_burstlen_r:unsigned(ddr_burstlen_width_c-1 downto 0);

SIGNAL read_fifo_read_ena:std_logic;
SIGNAL read_fifo_read_empty:std_logic;
SIGNAL read_fifo_write_ena:std_logic;
SIGNAL read_fifo_write_full:std_logic;
SIGNAL read_fifo_write:ddr_read_cmd_t;
SIGNAL read_fifo_read:ddr_read_cmd_t;
SIGNAL read_fifo_write_flat:std_logic_vector(ddr_read_cmd_length_c-1 downto 0);
SIGNAL read_fifo_read_flat:std_logic_vector(ddr_read_cmd_length_c-1 downto 0);

-- read pending counter needs to have large range than actual max value in order
-- to handle wrap around arithmetic

SIGNAL read_complete_r:unsigned(4+ddr_max_read_pend_depth_c-1 downto 0);
SIGNAL read_request_r:unsigned(4+ddr_max_read_pend_depth_c-1 downto 0);
SIGNAL read_pending_full_r:std_logic;

SIGNAL read_transaction_complete_r:unsigned(4+ddr_max_read_transaction_pend_depth_c-1 downto 0);
SIGNAL read_transaction_request_r:unsigned(4+ddr_max_read_transaction_pend_depth_c-1 downto 0);


BEGIN

-----
-- read data from DDR bus are first registered to a FIFO
-- This FIFO is asynchronous to handle different clock domain
-----

read_data_fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>ddr_data_width_c,
        FIFO_DEPTH=>ddr_max_read_pend_depth_c,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>ddr_rdata_in,
        write_in=>ddr_rvalid_in,
        read_in=>read_data_read_ena_2,
        q_out=>read_data_read,
        ravail_out=>open,
        wused_out=>open,
        empty_out=>read_data_read_empty,
        full_out=>open,
        almost_full_out=>open
	);


read_fifo_read_ena <= '1' when ((read_fifo_read_empty='0') and ddr_arready_in='1') else '0';

read_fifo_write_ena <= '1' when read_fifo_write.read='1' and read_fifo_write_full='0' else '0'; 

-----
-- FIFO to hold read request to external DDR bus
-- This FIFO is asynchronous to handle different clock domain
----

ddr_rx_fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>ddr_read_cmd_length_c,
        FIFO_DEPTH=>ddr_rx_fifo_depth,
        LOOKAHEAD=>TRUE
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>read_fifo_write_flat,
        write_in=>read_fifo_write_ena,
        read_in=>read_fifo_read_ena,
        q_out=>read_fifo_read_flat,
        ravail_out=>open,
        wused_out=>open,
        empty_out=>read_fifo_read_empty,
        full_out=>read_fifo_write_full,
        almost_full_out=>open
	);

read_fifo_read <= unpack_ddr_read_cmd(read_fifo_read_flat);

read_fifo_write_flat <= pack_ddr_read_cmd(read_fifo_write);

--------
-- Pack DDR read request to send to async FIFO
------
process(read_pause_r,read_pause_addr_r,read_pause_burstlen_r,ddr_read,rd_ddr_addr,rd_ddr_burstlen,burstbegin)
   variable addr_v:std_logic_vector(ddr_bus_width_c-1 downto 0);
   variable burstlen_v:unsigned(ddr_burstlen_width_c-1 downto 0);
   variable read_v:std_logic;
   variable burstbegin_v:std_logic;
   begin
   if read_pause_r='1' then
      addr_v := read_pause_addr_r;
      burstlen_v := read_pause_burstlen_r;
      read_v :='1';
   else
      addr_v := rd_ddr_addr;
      burstlen_v := rd_ddr_burstlen(ddr_burstlen_width_c-1 downto 0);
      read_v := ddr_read;
   end if;
   burstbegin_v := (burstbegin and ddr_read);
   read_fifo_write.addr <= addr_v;
   read_fifo_write.burstlen <= burstlen_v;
   read_fifo_write.read <= read_v;
   read_fifo_write.burstbegin <= burstbegin_v;
end process;

ddr_arid_out <= "0";

ddr_arburst_out <= "01";

ddr_arcache_out <= "0011";

ddr_arlock_out <= "0";

ddr_arprot_out <= "000";

ddr_arqos_out <= "0000";

ddr_arsize_out <= "011";

process(read_fifo_read,read_fifo_read_empty,read_pause_r,read_pause_addr_r,read_pause_burstlen_r,ddr_read,rd_ddr_addr,rd_ddr_burstlen,burstbegin)
begin
   -- Unpack DDR read requests from async FIFO and forward the request to external DDR bus
   ddr_araddr_out <= read_fifo_read.addr;
   ddr_arlen_out <= read_fifo_read.burstlen;
   ddr_arvalid_out <= read_fifo_read.burstbegin and (not read_fifo_read_empty);
   ddr_rready_out <= '1';
end process;

-----
---- FIFO for DDR read access
-----

read_record_fifo_i:scfifo
	generic map 
	(
        DATA_WIDTH=>read_record_t'length,
        FIFO_DEPTH=>read_record_fifo_depth_c,
        LOOKAHEAD=>TRUE,
        ALMOST_FULL=>read_record_fifo_size_c-ddr_max_burstlen_c-5
	)
	port map 
	(
        clock_in=>clock_in,
        reset_in=>reset_in,
        data_in=>read_record_write_r,
        write_in=>read_record_write_ena_r,
        read_in=>read_record_read_ena,
        q_out=>read_record_read,
        ravail_out=>open,
        wused_out=>open,
        empty_out=>read_record_read_empty,
        full_out=>open,
        almost_full_out=>read_record_read_full
	);


read_addr <= read_addr_in;

-- Transfer received data back to application....

read_data_ready_out <= read_data_ready;
read_data_valid_vm_out <= read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2+fork_max_c+1-1);
read_fork_out <= read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2+fork_max_c-1 downto ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2);
read_data_ready <= (read_data_read_valid_r(1) and (read_data_read_valid_r(0) or (not read_record_read((ddr_vector_depth_c+1+ddr_vector_depth_c))))) and (not read_record_read_empty);
read_data_valid <= read_data_ready and (not read_data_wait_in);
read_record_read_ena <= read_data_valid;
read_data_valid_out <= read_data_valid;
read_data_read_ena <= '1' when 
                  read_data_valid='1' and 
                  (
                  read_record_read(ddr_vector_depth_c)='1' or  -- end of burst
                  read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c)='1' or  -- access spread over burst boundary
                  read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+1)='1' -- Read end of the burst word
                  ) 
                  else '0';

-- Block read if write transaction is in progress.

read_wait_request <= '1' when (read_record_read_full_r='1') or read_pause_r='1' else '0';

read2 <= read_in when (read_wait_request='0') else '0';

read_wait_request_out <= read_wait_request;

-- Only allow write if read operation are all flushed...

burstbegin <= '1' when (read2='1' and read_burstlen_r=to_unsigned(0,burstlen_t'length)) else '0';

ddr_read <= '1' when (burstbegin='1' and read2='1') else '0';

------------------
-- Align burstlen to address boundary
------------------

process(read_burstlen_in,read_vector_in,read_addr)
   variable burstlen_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable addr_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp3_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp4_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp5_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   variable temp6_v:unsigned(burstlen_t'length+ddr_vector_depth_c downto 0);
   begin

   burstlen_v := resize(read_burstlen_in,burstlen_v'length);
   addr_v := resize(unsigned(read_addr(ddr_vector_depth_c-1 downto 0)),addr_v'length);
   if unsigned(read_vector_in)=to_unsigned(1,ddr_vector_depth_c) then 
      if burstlen_v > to_unsigned((ddr_vector_width_c/2)*(ddr_max_burstlen_c-1),burstlen_v'length) then
         burstlen_v := to_unsigned((ddr_vector_width_c/2)*(ddr_max_burstlen_c-1),burstlen_v'length);
      end if;
      temp_v := burstlen_v sll 1;
   elsif unsigned(read_vector_in)=to_unsigned(3,ddr_vector_depth_c) then
      if burstlen_v > to_unsigned((ddr_vector_width_c/4)*(ddr_max_burstlen_c-1),burstlen_v'length) then
         burstlen_v := to_unsigned((ddr_vector_width_c/4)*(ddr_max_burstlen_c-1),burstlen_v'length);
      end if;
      temp_v := burstlen_v sll 2;
   elsif unsigned(read_vector_in)=to_unsigned(7,ddr_vector_depth_c) then -- vsize=1
      if burstlen_v > to_unsigned((ddr_vector_width_c/8)*(ddr_max_burstlen_c-1),burstlen_v'length) then
         burstlen_v := to_unsigned((ddr_vector_width_c/8)*(ddr_max_burstlen_c-1),burstlen_v'length);
      end if;
      temp_v := burstlen_v sll 3;
   else
      if burstlen_v > to_unsigned(ddr_vector_width_c*(ddr_max_burstlen_c-1),burstlen_v'length) then
         burstlen_v := to_unsigned(ddr_vector_width_c*(ddr_max_burstlen_c-1),burstlen_v'length);
      end if;
      temp_v := burstlen_v;
   end if;
   temp3_v := temp_v+addr_v+to_unsigned(ddr_vector_width_c-1,temp3_v'length);
   temp4_v := temp3_v srl ddr_vector_depth_c;
   read_burstlen3 <= resize(temp4_v,read_burstlen3'length);
   read_burstlen2 <= resize(burstlen_v,read_burstlen2'length);
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       read_pause_r <= '0';
       read_pause_burstlen_r <= (others=>'0');
       read_pause_addr_r <= (others=>'0');
       read_record_read_full_r <= '0';
    else
        if clock_in'event and clock_in='1' then
           read_record_read_full_r <= read_record_read_full or read_pending_full_r;
           if burstbegin='1' and read_fifo_write_full='1' and ddr_read='1' then
              read_pause_r <= '1';
              read_pause_burstlen_r <= rd_ddr_burstlen(ddr_burstlen_width_c-1 downto 0);
              read_pause_addr_r <= rd_ddr_addr;
           elsif read_fifo_write_full='0' then
              read_pause_r <= '0';
           end if;
        end if;
    end if;
end process;

--
-- Transfer read data to the outside
-- start_v is used to zero out beginning of data. For example when start_v=-1 then first byte will be zapped to zero
-- end_v is used to zero out end of data. For example when end_v=4 then only byte#0->byte#3 are kept and byte#4->byte#7 are zapped to zero
-- This is useful since in AI application, read address are not work alined and convolutional neural network also has padding option
-- in the reading of feature map. For example when feature map padding is 1, then we do a read at address-1 but with start_v=-1 then
-- the padding byte will be set to zero.
-- end_v is useful to enable wide vector read even when address and length of the read are not multiple of bus width...
 
process(read_record_read,read_data)
   variable start_v:signed(ddr_vector_depth_c downto 0);
   variable end_v:unsigned(ddr_vector_depth_c downto 0);
   variable pos_v:integer;
   variable filler_v:std_logic_vector(2*data_width_c-1 downto 0);
   begin

   start_v := signed(read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+2-1 downto ddr_vector_depth_c+1+ddr_vector_depth_c+2));
   end_v := unsigned(read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2-1 downto ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+2));
   pos_v := ddr_vector_depth_c+1+ddr_vector_depth_c+ddr_vector_depth_c+1+ddr_vector_depth_c+1+2+fork_max_c+1;
   filler_v := read_record_read(pos_v+filler_v'length-1 downto pos_v);
   FOR I in 0 to ddr_vector_width_c-1 LOOP
      if start_v+to_signed(I,ddr_vector_depth_c+1) >= 0 and
         end_v > to_unsigned(I,ddr_vector_depth_c+1) then
         read_data_out(data_width_c*(I+1)-1 downto data_width_c*I) <= read_data(data_width_c*(I+1)-1 downto data_width_c*I);
      else
         if (I rem 2)=0 then
            read_data_out(data_width_c*(I+1)-1 downto data_width_c*I) <= filler_v(data_width_c-1 downto 0);
         else
            read_data_out(data_width_c*(I+1)-1 downto data_width_c*I) <= filler_v(2*data_width_c-1 downto data_width_c);
         end if;
      end if;
   end loop;
end process;

------------------
--- Record read2 transaction and then save in fifo
-------------------

process(read_record_read,read_data_read_r)
begin
    case read_record_read(ddr_vector_depth_c-1 downto ddr_vector_depth_c-3) is
        when "000"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(8*ddr_data_width_c/8-1 downto 0*ddr_data_width_c/8);
        when "001"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(9*ddr_data_width_c/8-1 downto 1*ddr_data_width_c/8);
        when "010"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(10*ddr_data_width_c/8-1 downto 2*ddr_data_width_c/8);
        when "011"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(11*ddr_data_width_c/8-1 downto 3*ddr_data_width_c/8);
        when "100"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(12*ddr_data_width_c/8-1 downto 4*ddr_data_width_c/8);
        when "101"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(13*ddr_data_width_c/8-1 downto 5*ddr_data_width_c/8);
        when "110"=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(14*ddr_data_width_c/8-1 downto 6*ddr_data_width_c/8);
        when others=>
            read_data(ddr_data_width_c-1 downto 0) <= read_data_read_r(15*ddr_data_width_c/8-1 downto 7*ddr_data_width_c/8);
    end case;
end process;


process(next_read_burstlen,read_burstlen_in,read_addr,read2,read_wait_request,read_vector_in,read_start_in,read_end_in,read_fork_in,read_vm_in)
variable temp_v:unsigned(ddr_vector_depth_c downto 0);
variable end_of_burst_v:std_logic;
variable spread_v:std_logic;
variable end_of_word_v:std_logic;
variable pos_v:integer;
begin
   read_record_write(ddr_vector_depth_c-1 downto 0) <= read_addr(ddr_vector_depth_c-1 downto 0); -- Read address
   if(next_read_burstlen=to_unsigned(0,burstlen_t'length)) then  -- Is this end of burst
      end_of_burst_v := '1';
   else
      end_of_burst_v := '0';
   end if;
   temp_v:=resize(unsigned(read_addr(ddr_vector_depth_c-1 downto 0)),ddr_vector_depth_c+1)+
           resize(unsigned(read_vector_in),ddr_vector_depth_c+1);
   read_record_write(ddr_vector_depth_c+1+ddr_vector_depth_c-1 downto ddr_vector_depth_c+1) <= read_vector_in; -- Vector length
   spread_v := temp_v(ddr_vector_depth_c); -- Does it spread into next word?

   if (unsigned(read_addr(ddr_vector_depth_c-1 downto 0))+unsigned(read_vector_in)=unsigned(all_ones_c)) then -- Reach end of word ?
      end_of_word_v := '1';
   else
      end_of_word_v := '0';
   end if;

   if end_of_burst_v='0' then
      read_record_write(ddr_vector_depth_c) <= '0';
      read_piggyback <= '0';
   else
      if read_burstlen_in > to_unsigned(1,burstlen_t'length) then
         -- Next read a is continuity read....
         -- Check if we can reuse the left over from current burst
         if spread_v='1' or end_of_word_v='0' then
            read_record_write(ddr_vector_depth_c) <= '0'; -- Not done. To be continue since there is some left over for next read
            read_piggyback <= '1';
         else
            read_record_write(ddr_vector_depth_c) <= '1'; -- Done bit. Advance to next read word received 
            read_piggyback <= '0';
         end if;
      else
         read_record_write(ddr_vector_depth_c) <= '1'; -- Done bit. Advance to next read word received 
         read_piggyback <= '0';
      end if;
   end if;
   pos_v := ddr_vector_depth_c+1+ddr_vector_depth_c;
   read_record_write(pos_v) <= spread_v;
   pos_v := pos_v+1;
   read_record_write(pos_v) <= end_of_word_v;
   pos_v := pos_v+1;
   read_record_write(pos_v+read_start_in'length-1 downto pos_v) <= std_logic_vector(read_start_in);
   pos_v := pos_v+read_start_in'length;
   read_record_write(pos_v+read_end_in'length-1 downto pos_v) <= std_logic_vector(read_end_in);
   pos_v := pos_v+read_end_in'length;
   read_record_write(pos_v+read_fork_in'length-1 downto pos_v) <= read_fork_in;
   pos_v := pos_v+read_fork_in'length;
   read_record_write(pos_v) <= read_vm_in;
   pos_v := pos_v+1;
   read_record_write(pos_v+read_filler_data_in'length-1 downto pos_v) <= read_filler_data_in;
   pos_v := pos_v+read_filler_data_in'length;
   read_record_write_ena <= read2 and (not read_wait_request);

end process;


-------
--- Calculate burst address and count
-------

process(read2,read_addr,read_burstlen2,read_burstlen3,read_vector_in,read_piggyback_r)
variable ddr_addr_v:std_logic_vector(ddr_bus_width_c-1 downto 0);
begin
   ddr_addr_v(ddr_bus_width_c-1 downto dp_full_addr_width_c+data_byte_width_depth_c) := (others=>'0');
   ddr_addr_v(dp_full_addr_width_c+data_byte_width_depth_c-1 downto ddr_vector_depth_c+data_byte_width_depth_c) := read_addr(dp_full_addr_width_c-1 downto ddr_vector_depth_c);
   ddr_addr_v(ddr_vector_depth_c+data_byte_width_depth_c-1 downto 0) := (others=>'0');
   if read_piggyback_r='0' then
      rd_ddr_burstlen <= unsigned(read_burstlen3);
      rd_ddr_addr <= std_logic_vector(unsigned(ddr_addr_v));
   else
      rd_ddr_burstlen <= unsigned(read_burstlen3)-to_unsigned(1,read_burstlen3'length);
      rd_ddr_addr <= std_logic_vector(unsigned(ddr_addr_v) + to_unsigned(ddr_data_width_c/8,rd_ddr_addr'length));    
   end if;
end process;


------------------
-- Calculate next burstlen after current transaction
------------------

process(read2,read_burstlen_r,read_wait_request,read_burstlen2)
begin

if read2='1' then
   if read_burstlen_r=to_unsigned(0,burstlen_t'length) then
      if read_wait_request='0' then
         next_read_burstlen <= read_burstlen2-1;
      else
         next_read_burstlen <= read_burstlen_r;
      end if;
   else
      if read_wait_request='0' then
         next_read_burstlen <= read_burstlen_r-1;
      else
         next_read_burstlen <= read_burstlen_r;
      end if;
   end if;
else
   next_read_burstlen <= read_burstlen_r;
end if;

end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        read_burstlen_r <= (others=>'0');
        read_piggyback_r <= '0';
        read_record_write_r <= (others=>'0');
        read_record_write_ena_r <= '0';
        read_record_write_ena_rr <= '0';
        read_record_write_ena_rrr <= '0';
        read_record_read_empty_r <= '1';
    else
        if clock_in'event and clock_in='1' then
            read_record_read_empty_r <= read_record_read_empty;
            read_record_write_r <= read_record_write;
            read_record_write_ena_r <= read_record_write_ena;
            read_record_write_ena_rr <= read_record_write_ena_r;
            read_record_write_ena_rrr <= read_record_write_ena_rr;
            read_burstlen_r <= next_read_burstlen;
            if read_record_write_ena='1' then
               read_piggyback_r <= read_piggyback;
            end if;
        end if;
    end if;
end process;


read_data_read_ena_2 <= (not read_data_read_empty) when read_data_read_ena='1' or read_data_read_valid_r(1)='0' or read_data_read_valid_r(0)='0' else '0';

process(reset_in,clock_in)
begin
if reset_in = '0' then
   read_data_read_r <= (others=>'0');
   read_data_read_valid_r <= (others=>'0');
   read_complete_r <= (others=>'0');
   read_request_r <= (others=>'0');   
   read_pending_full_r <= '0';
   read_transaction_request_r <= (others=>'0');
   read_transaction_complete_r <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
       -- Concatenate consecutive read inorder to read data that are spread between
       -- burst boundaries

       if(read_data_read_ena_2='1') then
          read_complete_r <= read_complete_r+to_unsigned(1,read_complete_r'length);
       end if;
       if read_fifo_write_ena='1' then
          read_request_r <= read_request_r+resize(read_fifo_write.burstlen,read_request_r'length);
       end if;
       -- Also make sure not too many read transaction pending
       if read_fifo_write_ena='1' then
          read_transaction_request_r <= read_transaction_request_r+to_unsigned(1,read_transaction_request_r'length);
       end if;
       if ddr_rvalid_in='1' and ddr_rlast_in='1' then
          read_transaction_complete_r <= read_transaction_complete_r+to_unsigned(1,read_transaction_complete_r'length);
       end if;
       if ((signed(read_request_r)-signed(read_complete_r)) >= to_signed(ddr_max_read_pend_c-ddr_max_burstlen_c-4,read_complete_r'length)) or
          ((signed(read_transaction_request_r)-signed(read_transaction_complete_r)) >= to_signed(ddr_max_read_transaction_pend_c-1,read_transaction_complete_r'length))
       then
          read_pending_full_r <= '1';
       else
          read_pending_full_r <= '0';
       end if;
       if read_data_read_ena='1' then
          if read_record_read(ddr_vector_depth_c)='1' and read_record_read(ddr_vector_depth_c+1+ddr_vector_depth_c)='1' then
             -- Flush next word if this is end of burst and this access spread to next word...
             read_data_read_valid_r(1) <= '0';
             read_data_read_valid_r(0) <= not read_data_read_empty;
             read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
          else 
             -- Advance to next word
             read_data_read_r(ddr_data_width_c-1 downto 0) <= read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c);
             read_data_read_valid_r(1) <= read_data_read_valid_r(0);
             read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
             read_data_read_valid_r(0) <= not read_data_read_empty;
          end if;
       else
          if read_data_read_valid_r(1)='0' then
             read_data_read_r(ddr_data_width_c-1 downto 0) <= read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c);
             read_data_read_valid_r(1) <= read_data_read_valid_r(0);
             read_data_read_valid_r(0) <= not read_data_read_empty;
             read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
          elsif read_data_read_valid_r(0)='0' then
             read_data_read_valid_r(0) <= not read_data_read_empty;
             read_data_read_r(2*ddr_data_width_c-1 downto ddr_data_width_c) <= read_data_read;
          end if;
       end if;
    end if;
end if;
end process;

END ddr_rx_behavior;
