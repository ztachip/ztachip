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
    addr:std_logic_vector(ddr_bus_width_c-1 downto 0); -- Destination memory address
    byteena:std_logic_vector(ddr_data_byte_width_c-1 downto 0); -- Associated byteEnable with this write
    last:std_logic;
end record;

subtype byteenable_t is std_logic_vector(ddr_data_byte_width_c/8-1 DOWNTO 0);
type byteenables_t is array(natural range <>) of byteenable_t;

---- Constants
----

constant all_ones_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_ones2_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'1');
constant all_zeros_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'0');
constant all_zeros2_c:std_logic_vector(ddr_data_byte_width_c-1 downto 0):=(others=>'0');
constant all_zeros3_c:std_logic_vector(ddr_bus_width_c-1 downto 0):=(others=>'0');

SIGNAL write2:STD_LOGIC;

SIGNAL ddr_write:STD_LOGIC;
SIGNAL byteenable:STD_LOGIC_VECTOR(2*ddr_data_byte_width_c-1 downto 0);
SIGNAL write_data_write_r:ddr_write_cmd_t;
SIGNAL write_data_write:ddr_write_cmd_t;
SIGNAL write_data_write_ena:STD_LOGIC;
SIGNAL write_data_write_ena_r:STD_LOGIC;
SIGNAL write_data_write_ena_rr:STD_LOGIC;
SIGNAL write_data_write_ena_rrr:STD_LOGIC;
SIGNAL write_burst_write_ena:std_logic;
SIGNAL write_burst_write:std_logic_vector(burstlen_t'length+ddr_bus_width_c-1 downto 0);
SIGNAL write_burst_read_ena:std_logic;
SIGNAL write_data:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 downto 0);
SIGNAL write_data_r:STD_LOGIC_VECTOR(2*ddr_data_width_c-1 downto 0);
SIGNAL write_data_2_r:STD_LOGIC_VECTOR(ddr_data_width_c-1 downto 0);
SIGNAL byteenable_r:STD_LOGIC_VECTOR(2*ddr_data_byte_width_c-1 downto 0);
SIGNAL beginburst_r:STD_LOGIC;
SIGNAL wr_ddr_addr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL write_next_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);

SIGNAL w_mask:STD_LOGIC_VECTOR(ddr_vector_width_c-1 downto 0);

SIGNAL write_complete:STD_LOGIC;
SIGNAL write_over_complete:STD_LOGIC;
SIGNAL write_flush_r:STD_LOGIC;

SIGNAL write_request_r:unsigned(4+ddr_max_write_pend_depth_c-1 downto 0);
SIGNAL write_complete_r:unsigned(4+ddr_max_write_pend_depth_c-1 downto 0);

SIGNAL ready:STD_LOGIC;
SIGNAL hold:STD_LOGIC;
SIGNAL awvalid:STD_LOGIC;
SIGNAL awlen_r:unsigned(ddr_burstlen_width_c-1 downto 0);
SIGNAL awaddr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);

constant ddr_block_size_c:integer:=8;

BEGIN


-- Unpack write commands from FIFO 

ready <= ddr_awready_in and ddr_wready_in;

hold <= write_data_write_ena_r and (not ready);  

ddr_write <= write_data_write_ena_r and ready;

-- Write commands

ddr_awvalid_out <= awvalid;

ddr_awaddr_out <= write_data_write_r.addr when awlen_r=0 else awaddr_r;

ddr_awlen_out <= awlen_r;

-- Data cycle...

ddr_wvalid_out <= ddr_write;

ddr_waddr_out <= write_data_write_r.addr;

ddr_wdata_out <= write_data_2_r;

ddr_wbe_out <= write_data_write_r.byteena;

ddr_wlast_out <= awvalid;

ddr_awburst_out <= "01"; 

ddr_awcache_out <= "0011";

ddr_awid_out <= "0";

ddr_awlock_out <= "0";

ddr_awprot_out <= "000";

ddr_awqos_out <= "0000";

ddr_bready_out <= '1';

ddr_awsize_out <= std_logic_vector(to_unsigned(ddr_vector_depth_c,ddr_awsize_out'length));


-- Condition to move to next transaction...

ddr_tx_busy_out <= '0' when ((write_request_r=write_complete_r) and (write_data_write_ena_r='0') and (write_data_write_ena_rr='0') and (write_data_write_ena_rrr='0')) else '1';

-- Would the current transmit request complete the current word.
write_complete <= '1' when ((unsigned('0' & write_addr_in(ddr_vector_depth_c-1 downto 0))+unsigned('0' & write_vector_in)+to_unsigned(1,ddr_vector_depth_c+1))>=to_unsigned(ddr_vector_width_c,ddr_vector_depth_c+1))
                      else '0';

-- Would the current transmit request spilled over to next word?
write_over_complete <= '1' when ((unsigned('0' & write_addr_in(ddr_vector_depth_c-1 downto 0))+unsigned('0' & write_vector_in)+to_unsigned(1,ddr_vector_depth_c+1))>to_unsigned(ddr_vector_width_c,ddr_vector_depth_c+1))
                           else '0';

write_data_write_ena <= '1' when (((write2='1' and 
                                 ((write_burstlen_in=to_unsigned(1,write_burstlen_in'length)) or write_complete='1')) 
                                 or
                                 (write_flush_r='1')) and
                                 (hold='0'))
                                 else '0';

write2 <= write_in when (hold='0' and
                        write_burstlen_in /= to_unsigned(0,burstlen_t'length) and
                        write_flush_r='0') 
                        else '0';

write_wait_request_out <= '1' when ((hold='1') or (write_flush_r='1')) else '0';

awvalid <= '1' when (ddr_write='1' and (write_data_write_r.last='1' or awlen_r >= to_unsigned(ddr_block_size_c-1,awlen_r'length))) else '0'; 

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        awlen_r <= (others=>'0');
        awaddr_r <= (others=>'0');
        write_request_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            if ddr_write='1' and awlen_r=0 then
                 awaddr_r <= write_data_write_r.addr;
            end if;
            if awvalid='1' then
                awlen_r <= (others=>'0');
                write_request_r <= write_request_r+1;
            elsif(ddr_write='1') then
                awlen_r <= awlen_r+1;
            end if;
        end if;
    end if;
end process;

----
-- Create new write request
----

process(write_flush_r,byteenable,wr_ddr_addr,write_next_addr_r,write_addr_in)
begin
    if write_flush_r='0' then
        write_data_write.addr <= wr_ddr_addr;
        write_data_write.byteena <= byteenable(ddr_data_byte_width_c-1 downto 0);
        if write_burstlen_in = to_unsigned(1,write_addr_in'length) then
            write_data_write.last <= '1'; 
        else
            write_data_write.last <= '0'; 
        end if;        
    else
        write_data_write.addr <= write_next_addr_r;
        write_data_write.byteena <= byteenable(ddr_data_byte_width_c-1 downto 0);  
        write_data_write.last <= '1';     
    end if;
end process;


process(write_vector_in,write_addr_in)
variable ddr_addr_v:std_logic_vector(ddr_bus_width_c-1 downto 0);
   begin
   ddr_addr_v(ddr_bus_width_c-1 downto dp_full_addr_width_c+data_byte_width_depth_c) := (others=>'0');
   ddr_addr_v(dp_full_addr_width_c+data_byte_width_depth_c-1 downto ddr_vector_depth_c+data_byte_width_depth_c) := write_addr_in(dp_full_addr_width_c-1 downto ddr_vector_depth_c);
   ddr_addr_v(ddr_vector_depth_c+data_byte_width_depth_c-1 downto 0) := (others=>'0');
   wr_ddr_addr <= std_logic_vector(unsigned(ddr_addr_v));
end process;

process(reset_in,clock_in)
begin
   if reset_in = '0' then
      write_data_write_ena_r <= '0';
      write_data_write_ena_rr <= '0';
      write_data_write_ena_rrr <= '0';
      write_next_addr_r <= (others=>'0');
      write_flush_r <= '0';
      write_complete_r <= (others=>'0');
   else
      if clock_in'event and clock_in='1' then
         if(hold='0') then
            -- Commit next transaction
            write_data_write_ena_r <= write_data_write_ena;
         end if;
        write_data_write_ena_rr <= write_data_write_ena_r;
        write_data_write_ena_rrr <= write_data_write_ena_rr;
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
            write_next_addr_r <= std_logic_vector(unsigned(wr_ddr_addr)+to_unsigned(2**(ddr_vector_depth_c+data_byte_width_depth_c),write_next_addr_r'length));
         end if;
         if ddr_bresp_in='1' then
            write_complete_r <= write_complete_r+1;
         end if;           
      end if;
   end if;
end process;

process(write_end_in,write_vector_in)
begin
    if(write_end_in >= to_unsigned(1,vector_t'length)) then
        w_mask(0) <= '1';
    else
        w_mask(0) <= '0';
    end if;
    FOR I in 1 to ddr_vector_width_c-1 LOOP
        w_mask(I) <= '0';
        FOR J in 1 to ddr_vector_depth_c loop
            if (I >= 2**(ddr_vector_depth_c-J)) then
                w_mask(I) <= write_vector_in(ddr_vector_depth_c-J);
                exit;
            end if;
        end loop;
        if(write_end_in < to_unsigned(I+1,vector_t'length)) then
            w_mask(I) <= '0';
        end if;
    END LOOP;
end process;

---
-- Generate byteenable mask
----

process(write2,write_vector_in,write_addr_in,write_data_r,write_data_in,byteenable_r,w_mask)
variable i_v:integer;
begin
if(write2='1') then
    i_v := to_integer(unsigned(write_addr_in(ddr_vector_depth_c-1 downto 0)));
    byteenable <= byteenable_r;
    byteenable(ddr_vector_width_c+i_v-1 downto i_v)  <= w_mask or byteenable_r(ddr_vector_width_c+i_v-1 downto i_v);
else
    byteenable <= byteenable_r;
end if;
end process;

process(write_data_r,write2,write_addr_in,write_data_in,write_vector_in)
variable I:integer;
begin
write_data <= write_data_r;
if(write2='1') then
    FOR I in 0 to ddr_vector_width_c-1 LOOP
        if(I=to_integer(unsigned(write_addr_in(ddr_vector_depth_c-1 downto 0)))) then
            FOR J in 0 to ddr_vector_depth_c LOOP
                if unsigned(write_vector_in)=to_unsigned(2**J-1,write_vector_in'length) then
                    write_data(ddr_data_width_c/(2**(ddr_vector_depth_c-J))+I*data_width_c-1 downto I*data_width_c) <= write_data_in(ddr_data_width_c/(2**(ddr_vector_depth_c-J))-1 downto 0);
                    exit;
                end if;
            END LOOP;
            exit;
        end if;
    END LOOP;
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in = '0' then
   byteenable_r <= (others=>'0');
   write_data_r <= (others=>'0');
   write_data_2_r <= (others=>'0');
   write_data_write_r <= ((others=>'0'),(others=>'0'),'0');
else
    if clock_in'event and clock_in='1' then
       if(write_data_write_ena='1') then
         byteenable_r(ddr_data_byte_width_c-1 downto 0) <= byteenable(2*ddr_data_byte_width_c-1 downto ddr_data_byte_width_c);
         byteenable_r(2*ddr_data_byte_width_c-1 downto ddr_data_byte_width_c) <= (others=>'0');
         write_data_r(ddr_data_width_c-1 downto 0) <= write_data(2*ddr_data_width_c-1 downto ddr_data_width_c);
         write_data_2_r <= write_data(ddr_data_width_c-1 downto 0);
         write_data_write_r <= write_data_write;
       elsif write2='1' then
          write_data_r <= write_data;
          byteenable_r <= byteenable;
       end if;
    end if;
end if;
end process;

END ddr_tx_behavior;
