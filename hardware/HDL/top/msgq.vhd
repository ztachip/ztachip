------------------------------------------------------------------------------
-- Copyright [2014] [Ztachip Technologies Inc]
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

--------
-- This module implements message queue between MCORE and host 
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY msgq IS
    port(
        SIGNAL hclock_in               : IN STD_LOGIC;
        SIGNAL mclock_in               : IN STD_LOGIC;
        SIGNAL reset_in                : IN STD_LOGIC;
        SIGNAL sreset_in               : IN STD_LOGIC;
        
        -- Interface with host
        
        SIGNAL host_addr_in            : IN register_addr_t;
        SIGNAL host_write_in           : IN STD_LOGIC;
        SIGNAL host_read_in            : IN STD_LOGIC;
        SIGNAL host_writedata_in       : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL host_readdata_out       : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL host_readdatavalid_out  : OUT STD_LOGIC;
        SIGNAL host_msg_avail_out      : OUT STD_LOGIC;
        
        -- Interface with MCORE
        
        SIGNAL mcore_addr_in           : register_addr_t;
        SIGNAL mcore_write_in          : IN STD_LOGIC;
        SIGNAL mcore_read_in           : IN STD_LOGIC;
        SIGNAL mcore_writedata_in      : IN STD_LOGIC_VECTOR(mregister_width_c-1 DOWNTO 0);
        SIGNAL mcore_readdata_out      : OUT STD_LOGIC_VECTOR(mregister_width_c-1 DOWNTO 0)
        );        
END msgq;

ARCHITECTURE msgq_behaviour of msgq is

COMPONENT dcfifo
   GENERIC (
        intended_device_family  : STRING;
        lpm_numwords            : NATURAL;
        lpm_showahead           : STRING;
        lpm_type                : STRING;
        lpm_width               : NATURAL;
        lpm_widthu              : NATURAL;
        overflow_checking       : STRING;
        rdsync_delaypipe        : NATURAL;
        read_aclr_synch         : STRING;
        underflow_checking      : STRING;
        use_eab                 : STRING;
        write_aclr_synch        : STRING;
        wrsync_delaypipe        : NATURAL
        );
   PORT (
         aclr    : IN STD_LOGIC;
         data    : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
         rdclk   : IN STD_LOGIC;
         rdreq   : IN STD_LOGIC;
         wrclk   : IN STD_LOGIC;
         wrreq   : IN STD_LOGIC;
         q       : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
         rdempty : OUT STD_LOGIC;
         rdusedw : OUT STD_LOGIC_VECTOR (lpm_widthu-1 DOWNTO 0);
         wrfull  : OUT STD_LOGIC;
         wrusedw : OUT STD_LOGIC_VECTOR (lpm_widthu-1 DOWNTO 0)
   );
END COMPONENT;

SIGNAL reset:STD_LOGIC;

SIGNAL host_regno:register_t;

SIGNAL mcore_regno:register_t;

SIGNAL host_regno2:unsigned(0 downto 0);

SIGNAL mcore_regno2:unsigned(0 downto 0);

subtype msgq_in_depth_sz_t is std_logic_vector(msgq_in_depth_c-1 downto 0); -- mcore register datatype

type msgq_in_depth_szs_t is array(natural range <>) of msgq_in_depth_sz_t; -- array of mcore registers

-- INBOX signal: host send messages to mcore

SIGNAL in_rdusedw:msgq_in_depth_szs_t(msgq_in_num_c-1 downto 0);
SIGNAL in_wrusedw:msgq_in_depth_szs_t(msgq_in_num_c-1 downto 0);
SIGNAL in_q:mregisters_t(msgq_in_num_c-1 downto 0);
SIGNAL in_empty:std_logic_vector(msgq_in_num_c-1 downto 0);
SIGNAL in_wreq:std_logic_vector(msgq_in_num_c-1 downto 0);
SIGNAL in_rdreq:std_logic_vector(msgq_in_num_c-1 downto 0);

-- OUTBOX signal: mcore send messages to host.

SIGNAL out_usedw:std_logic_vector(msgq_out_depth_c-1 downto 0);
SIGNAL out_q:std_logic_vector(mregister_width_c-1 downto 0);
SIGNAL out_empty:std_logic;
SIGNAL out_wreq:std_logic;
SIGNAL out_rdreq:std_logic;

SIGNAL resetn:std_logic;

SIGNAL host_rden_r:STD_LOGIC;
SIGNAL host_addr_r:register_addr_t;
SIGNAL host_write_r:STD_LOGIC;
SIGNAL host_read_r:STD_LOGIC;
SIGNAL host_writedata_r:STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
SIGNAL host_readdata_r:STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);

SIGNAL mcore_rden_r:STD_LOGIC;
SIGNAL mcore_addr_r:register_addr_t;
SIGNAL mcore_write_r:STD_LOGIC;
SIGNAL mcore_read_r:STD_LOGIC;
SIGNAL mcore_writedata_r:STD_LOGIC_VECTOR(mregister_width_c-1 DOWNTO 0);
SIGNAL mcore_readdata_r:STD_LOGIC_VECTOR(mregister_width_c-1 DOWNTO 0);

constant serial_depth_c:integer:=8;
SIGNAL serial_rdreq:STD_LOGIC;
SIGNAL serial_wreq:STD_LOGIC;
SIGNAL serial_empty:STD_LOGIC;
SIGNAL serial_q:STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL serial_rdusedw:STD_LOGIC_VECTOR(serial_depth_c-1 downto 0);
SIGNAL serial_wrusedw:STD_LOGIC_VECTOR(serial_depth_c-1 downto 0);

BEGIN

reset <= (reset_in and sreset_in);

resetn <= not reset;

host_msg_avail_out <= not out_empty;

------ 
-- FIFO to accept messages from host
------

GEN_INBOX:
FOR I IN 0 TO msgq_in_num_c-1 GENERATE
inbox_1_i : dcfifo
   GENERIC MAP (
      intended_device_family => "Cyclone V",
      lpm_numwords => msgq_in_max_c,
      lpm_showahead => "ON",
      lpm_type => "dcfifo",
      lpm_width => mregister_width_c,
      lpm_widthu => msgq_in_depth_c,
      overflow_checking => "ON",
      rdsync_delaypipe => 5,
      read_aclr_synch => "OFF",
      underflow_checking => "ON",
      use_eab => "ON",
      write_aclr_synch => "OFF",
      wrsync_delaypipe => 5
      )
   PORT MAP (
      aclr => resetn,
      data => host_writedata_r(mregister_width_c-1 downto 0),
      rdclk => mclock_in,
      rdreq => in_rdreq(I),
      wrclk => hclock_in,
      wrreq => in_wreq(I),
      q => in_q(I),
      rdempty => in_empty(I),
      rdusedw => in_rdusedw(I),
      wrfull => open,
      wrusedw => in_wrusedw(I)
   );
END GENERATE GEN_INBOX;

------
-- FIFO to send messages to host
------

outbox_i : dcfifo
   GENERIC MAP (
      intended_device_family => "Cyclone V",
      lpm_numwords => msgq_out_max_c,
      lpm_showahead => "ON",
      lpm_type => "dcfifo",
      lpm_width => mregister_width_c,
      lpm_widthu => msgq_out_depth_c,
      overflow_checking => "ON",
      rdsync_delaypipe => 5,
      read_aclr_synch => "OFF",
      underflow_checking => "ON",
      use_eab => "ON",
      write_aclr_synch => "OFF",
      wrsync_delaypipe => 5
   )
   PORT MAP (
      aclr => resetn,
      data => mcore_writedata_r(mregister_width_c-1 downto 0),
      rdclk => hclock_in,
      rdreq => out_rdreq,
      wrclk => mclock_in,
      wrreq => out_wreq,
      q => out_q,
      rdempty => out_empty,
      rdusedw => open,
      wrfull => open,
      wrusedw => out_usedw
   );

serial_i : dcfifo
   GENERIC MAP(
      intended_device_family => "Cyclone V",
      lpm_numwords => (2**serial_depth_c-1),
      lpm_showahead => "ON",
      lpm_type => "dcfifo",
      lpm_width => 8,
      lpm_widthu => serial_depth_c,
      overflow_checking => "ON",
      rdsync_delaypipe => 5,
      read_aclr_synch => "OFF",
      underflow_checking => "ON",
      use_eab => "ON",
      write_aclr_synch => "OFF",
      wrsync_delaypipe => 5
   )
   PORT MAP (
      aclr => resetn,
      data => mcore_writedata_r(7 downto 0),
      rdclk => hclock_in,
      rdreq => serial_rdreq,
      wrclk => mclock_in,
      wrreq => serial_wreq,
      q => serial_q,
      rdempty => serial_empty,
      rdusedw => serial_rdusedw,
      wrfull => open,
      wrusedw => serial_wrusedw
   );

host_regno <= unsigned(host_addr_r(register_t'length-1 downto 0));
host_regno2 <= unsigned(host_addr_r(host_regno2'length+register_t'length-1 downto register_t'length));
mcore_regno <= unsigned(mcore_addr_r(register_t'length-1 downto 0));
mcore_regno2 <= unsigned(mcore_addr_r(host_regno2'length+register_t'length-1 downto register_t'length));
host_readdata_out <= host_readdata_r when host_rden_r='1' else (others=>'Z');
host_readdatavalid_out <= host_rden_r;
mcore_readdata_out <= mcore_readdata_r when mcore_rden_r='1' else (others=>'Z');
in_wreq(0) <= '1' when host_write_r='1' and host_regno=to_unsigned(register_msgq_write_c,register_t'length) and to_integer(host_regno2)=0 else '0';
in_wreq(1) <= '1' when host_write_r='1' and host_regno=to_unsigned(register_msgq_write_c,register_t'length) and to_integer(host_regno2)=1 else '0';
in_rdreq(0) <= '1' when mcore_read_r='1' and mcore_regno=(register_msgq_read_c) and to_integer(mcore_regno2)=0 else '0';
in_rdreq(1) <= '1' when mcore_read_r='1' and mcore_regno=(register_msgq_read_c) and to_integer(mcore_regno2)=1 else '0';
out_wreq <= '1' when mcore_write_r='1' and mcore_regno=to_unsigned(register_msgq_write_c,register_t'length) else '0';
out_rdreq <= '1' when host_read_r='1' and host_regno=(register_msgq_read_c) else '0';
serial_rdreq <= '1' when host_read_r='1' and host_regno=(register_serial_read_c) else '0';
serial_wreq <= '1' when mcore_write_r='1' and mcore_regno=to_unsigned(register_serial_write_c,register_t'length) else '0';

process(reset_in,hclock_in)
begin
    if reset_in='0' then
        host_addr_r <= (others=>'0');
        host_write_r <= '0';
        host_read_r <= '0';
        host_writedata_r <= (others=>'0');
    else
        if hclock_in'event and hclock_in='1' then
            host_addr_r <= host_addr_in;
            host_write_r <= host_write_in;
            host_read_r <= host_read_in;
            host_writedata_r <= host_writedata_in;
        end if;
    end if;
end process;

process(reset_in,mclock_in)
begin
    if reset_in='0' then
        mcore_addr_r <= (others=>'0');
        mcore_write_r <= '0';
        mcore_read_r <= '0';
        mcore_writedata_r <= (others=>'0');
    else
        if mclock_in'event and mclock_in='1' then
            mcore_addr_r <= mcore_addr_in;
            mcore_write_r <= mcore_write_in;
            mcore_read_r <= mcore_read_in;
            mcore_writedata_r <= mcore_writedata_in;
        end if;
    end if;
end process;

------
-- Process read request from host and mcore
------

process(reset_in,hclock_in)
variable temp_v:std_logic_vector(msgq_in_depth_c-1 downto 0);
variable temp2_v:std_logic_vector(serial_depth_c-1 downto 0);
begin
    if reset_in='0' then
        host_rden_r <= '0';
        host_readdata_r <= (others=>'0');
    else
        if hclock_in'event and hclock_in='1' then
            if host_read_r='1' then
                case to_integer(host_regno) is
                    when register_msgq_read_c =>
                        -- Read message from the queue
                        host_readdata_r <= out_q;
                        host_rden_r <= '1';
                    when register_serial_read_c =>
                        -- Read message from the queue
                        host_readdata_r(7 downto 0) <= serial_q;
                        host_readdata_r(host_width_c-1 downto 8) <= (others=>'0');
                        host_rden_r <= '1';
                    when register_msgq_read_avail_c =>
                        -- Read number of messages available in the queue
                        host_readdata_r(out_usedw'length-1 downto 0) <= out_usedw;
                        host_readdata_r(host_readdata_r'length-1 downto out_usedw'length) <= (others=>'0');
                        host_rden_r <= '1';
                    when register_msgq_write_avail_c =>
                        -- Read number of free slots available to send messages
                        temp_v := not(std_logic_vector(in_wrusedw(to_integer(host_regno2))));
                        host_readdata_r(temp_v'length-1 downto 0) <= temp_v;
                        host_readdata_r(host_readdata_r'length-1 downto temp_v'length) <= (others=>'0');
                        host_rden_r <= '1';
                    when register_serial_read_avail_c =>
                        temp2_v := std_logic_vector(serial_rdusedw);
                        host_readdata_r(temp2_v'length-1 downto 0) <= temp2_v;
                        host_readdata_r(host_readdata_r'length-1 downto temp2_v'length) <= (others=>'0');
                        host_rden_r <= '1';
                    when others=>
                        host_readdata_r <= (others=>'0');
                        host_rden_r <= '0';
                end case;
            else
                host_rden_r <= '0';
            end if;
        end if;
    end if;
end process;


process(reset_in,mclock_in)
variable temp_v:std_logic_vector(msgq_in_depth_c-1 downto 0);
variable temp2_v:std_logic_vector(serial_depth_c-1 downto 0);
begin
    if reset_in='0' then
        mcore_rden_r <= '0';
        mcore_readdata_r <= (others=>'0');
    else
        if mclock_in'event and mclock_in='1' then
            if mcore_read_r='1' then
                case to_integer(mcore_regno) is
                    when register_msgq_read_c =>
                        -- Read message from queue
                        mcore_readdata_r <= in_q(to_integer(mcore_regno2));
                        mcore_rden_r <= '1';
                    when register_msgq_read_avail_c =>
                        -- Read number of messages available to be read from queue
                        mcore_readdata_r(in_rdusedw(0)'length-1 downto 0) <= in_rdusedw(to_integer(mcore_regno2));
                        mcore_readdata_r(mcore_readdata_r'length-1 downto in_rdusedw(0)'length) <= (others=>'0');
                        mcore_rden_r <= '1';
                    when register_msgq_write_avail_c =>
                        -- Read number of free slots available to send messages to queue
                        temp_v := not(std_logic_vector(out_usedw));
                        mcore_readdata_r(temp_v'length-1 downto 0) <= temp_v;
                        mcore_readdata_r(mcore_readdata_r'length-1 downto temp_v'length) <= (others=>'0');
                        mcore_rden_r <= '1';
                    when register_serial_write_avail_c =>
                        -- Read number of free slots available to send messages to queue
                        temp2_v := not(std_logic_vector(serial_wrusedw));
                        mcore_readdata_r(temp2_v'length-1 downto 0) <= temp2_v;
                        mcore_readdata_r(mcore_readdata_r'length-1 downto temp2_v'length) <= (others=>'0');
                        mcore_rden_r <= '1';
                    when others=>
                        mcore_readdata_r <= (others=>'0');
                        mcore_rden_r <= '0';
                end case;
            else
                mcore_rden_r <= '0';
            end if;
        end if;
    end if;
end process;

END msgq_behaviour;