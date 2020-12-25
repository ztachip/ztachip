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

-------
-- TOP component for ztachip running IN simulation
-------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;
LIBRARY altera_mf;
USE altera_mf.all;

entity testbench is
    port(
        signal clock_in                     : IN std_logic;
        signal clock_x2_in                  : IN std_logic;
        signal reset_in                     : IN std_logic;

        SIGNAL avalon_bus_addr_in           : IN STD_LOGIC_VECTOR(avalon_bus_width_c-1 DOWNTO 0);
        SIGNAL avalon_bus_write_in          : IN STD_LOGIC;
        SIGNAL avalon_bus_read_in           : IN STD_LOGIC;
        SIGNAL avalon_bus_writedata_in      : IN STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL avalon_bus_readdata_out      : OUT STD_LOGIC_VECTOR(host_width_c-1 DOWNTO 0);
        SIGNAL avalon_bus_wait_request_out  : OUT STD_LOGIC;

        SIGNAL ddr_addr_in                  : IN std_logic_vector(ddr_bus_width_c-1 downto 0);
        SIGNAL ddr_read_in                  : IN std_logic;
        SIGNAL ddr_readdata_out             : OUT std_logic_vector(data_width_c-1 downto 0);
        SIGNAL ddr_write_in                 : IN std_logic;
        SIGNAL ddr_writedata_in             : IN std_logic_vector(data_width_c-1 downto 0)
    );
end testbench;

architecture testbench_behaviour of testbench is
constant DEPTH:integer:=14;
SIGNAL cell_ddr_0_addr: std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL cell_ddr_0_write :std_logic;
SIGNAL cell_ddr_0_write2 :std_logic;
SIGNAL cell_ddr_0_read :std_logic;
SIGNAL cell_ddr_1_read :std_logic;
SIGNAL cell_ddr_2_read :std_logic;
SIGNAL cell_ddr_0_writedata :std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_0_byteenable:std_logic_vector(ddr_data_byte_width_c-1 downto 0);
SIGNAL cell_ddr_0_readdata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_0_readdata_delay:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_0_wait_request:std_logic;
SIGNAL cell_ddr_0_burstlen: unsigned(ddr_burstlen_width_c-1 downto 0);
SIGNAL cell_ddr_0_burstbegin: std_logic;
SIGNAL cell_ddr_0_readdatavalid: std_logic;
SIGNAL cell_ddr_0_readdatavalid_delay: std_logic;

signal address3:std_logic_vector(DEPTH-1 downto 0);
SIGNAL cell_ddr_1_write :std_logic;
SIGNAL cell_ddr_1_writedata :std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_1_byteenable:std_logic_vector(ddr_data_byte_width_c-1 downto 0);
SIGNAL cell_ddr_1_addr: std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL cell_ddr_1_readdata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_1_readdata_delay:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_1_readdatavalid: std_logic;
SIGNAL cell_ddr_1_readdatavalid_delay: std_logic;
SIGNAL cell_ddr_1_wait_request:std_logic;
SIGNAL cell_ddr_1_burstlen: unsigned(ddr_burstlen_width_c-1 downto 0);
SIGNAL cell_ddr_1_burstbegin: std_logic;

SIGNAL cell_ddr_2_addr: std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL cell_ddr_2_readdata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_2_readdata_delay:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL cell_ddr_2_readdatavalid: std_logic;
SIGNAL cell_ddr_2_readdatavalid_delay: std_logic;
SIGNAL cell_ddr_2_burstlen: unsigned(ddr_burstlen_width_c-1 downto 0);
SIGNAL cell_ddr_2_burstbegin: std_logic;
SIGNAL cell_ddr_2_write :std_logic;

SIGNAL burstbegin1:std_logic;
signal burstlen1_r:unsigned(ddr_burstlen_width_c-1 downto 0);
signal address1_r:std_logic_vector(DEPTH-1 downto 0);

SIGNAL burstbegin2:std_logic;
signal burstlen2_r:unsigned(ddr_burstlen_width_c-1 downto 0);
signal address2_r:std_logic_vector(DEPTH-1 downto 0);


signal burstlen_r:unsigned(ddr_burstlen_width_c-1 downto 0);
signal address2:std_logic_vector(DEPTH-1 downto 0);
signal address:std_logic_vector(DEPTH-1 downto 0);
signal address_r:std_logic_vector(DEPTH-1 downto 0);
signal readdatavalid_r:std_logic;
signal readdatavalid_rr:std_logic;
signal read_r:std_logic;
signal read1_r:std_logic;
signal read2_r:std_logic;
signal write_r:std_logic;
signal ddr_wait:std_logic;
signal ddr_wait_r:std_logic;
signal burstbegin:std_logic;
signal burstbegin_r:std_logic;
signal ddr_error_r:std_logic;
signal count_r:unsigned(3 downto 0);
SIGNAL ddr_writedata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL ddr_readdata:std_logic_vector(ddr_data_width_c-1 downto 0);
SIGNAL ddr_addr_r:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL ddr_addr_rr:std_logic_vector(ddr_bus_width_c-1 downto 0);
SIGNAL byteenable2:std_logic_vector(ddr_data_byte_width_c-1 downto 0);
SIGNAL ddr_write:std_logic;
constant ddr_delay_c:integer:=60;

COMPONENT altsyncram
GENERIC (
        address_aclr_b              : STRING;
        address_reg_b               : STRING;
        clock_enable_input_a        : STRING;
        clock_enable_input_b        : STRING;
        clock_enable_output_b       : STRING;
        init_file                   : STRING;
        intended_device_family      : STRING;
        lpm_type                    : STRING;
        numwords_a                  : NATURAL;
        numwords_b                  : NATURAL;
        operation_mode              : STRING;
        outdata_aclr_b              : STRING;
        outdata_reg_b               : STRING;
        power_up_uninitialized      : STRING;
        read_during_write_mode_mixed_ports: STRING;
        widthad_a                   : NATURAL;
        widthad_b                   : NATURAL;
        width_a                     : NATURAL;
        width_b                     : NATURAL;
        width_byteena_a             : NATURAL
    );
    PORT (
            address_a : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
            clock0    : IN STD_LOGIC ;
            data_a    : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
            q_b       : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
            wren_a    : IN STD_LOGIC ;
            address_b : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

begin

ztachip_i: ztachip
    port map(
            pclock_in=>clock_in,
            mclock_in=>clock_in,
            hclock_in=>clock_in,
            dclock_in=>clock_in,
            preset_in=>reset_in, 
			mreset_in=>reset_in,
            hreset_in=>reset_in,
            dreset_in=>reset_in,                         
            avalon_bus_addr_in=>avalon_bus_addr_in,
            avalon_bus_write_in=>avalon_bus_write_in,
            avalon_bus_writedata_in=>avalon_bus_writedata_in,
            avalon_bus_readdata_out=>avalon_bus_readdata_out,
            avalon_bus_wait_request_out=>avalon_bus_wait_request_out,
            avalon_bus_read_in=>avalon_bus_read_in,    
                
            cell_ddr_0_addr_out=>cell_ddr_0_addr,
            cell_ddr_0_burstlen_out => cell_ddr_0_burstlen,
            cell_ddr_0_burstbegin_out => cell_ddr_0_burstbegin,
            cell_ddr_0_readdatavalid_in => cell_ddr_0_readdatavalid_delay,
            cell_ddr_0_write_out=>cell_ddr_0_write,
            cell_ddr_0_read_out=>cell_ddr_0_read,
            cell_ddr_0_writedata_out=>cell_ddr_0_writedata,
            cell_ddr_0_byteenable_out=>cell_ddr_0_byteenable,
            cell_ddr_0_readdata_in=>cell_ddr_0_readdata_delay,
            cell_ddr_0_wait_request_in=>cell_ddr_0_wait_request,

            cell_ddr_1_addr_out=>cell_ddr_1_addr,
            cell_ddr_1_burstlen_out => cell_ddr_1_burstlen,
            cell_ddr_1_burstbegin_out => cell_ddr_1_burstbegin,
            cell_ddr_1_readdatavalid_in => cell_ddr_1_readdatavalid_delay,
            cell_ddr_1_write_out=>cell_ddr_1_write,
            cell_ddr_1_read_out=>cell_ddr_1_read,
            cell_ddr_1_writedata_out=>cell_ddr_1_writedata,
            cell_ddr_1_byteenable_out=>cell_ddr_1_byteenable,
            cell_ddr_1_readdata_in=>cell_ddr_1_readdata_delay,
            cell_ddr_1_wait_request_in=>cell_ddr_1_wait_request,

            -- Indication
            indication_avail_out=>open
            );

cell_ddr_2_write <= '0';
cell_ddr_2_read <= '0';
------
-- Simulate DDR memory
------

cell_ddr_1_readdata <= ddr_readdata;
cell_ddr_0_write2 <= cell_ddr_0_write and (not ddr_wait);
ram2_i0 : ramtest
    GENERIC MAP (
        DEPTH => DEPTH,
        WIDTH => ddr_data_width_c
    )
    PORT MAP (
        clock_in=>clock_in,
        clock_x2_in=>clock_x2_in,
        reset_in=>reset_in,
        -- PORT 1
        data1_in=>cell_ddr_0_writedata,
        rdaddress1_in=>address,               -- Read for DDR bus1
        wraddress1_in=>address,               -- Write for DDR bus1
        wren1_in=>cell_ddr_0_write2,
        wrbyteenable1_in=>cell_ddr_0_byteenable,
        q1_out=>cell_ddr_0_readdata,
        -- PORT 2
        data2_in=>ddr_writedata,              
        rdaddress2_in=>address2,              -- Read for DDR bus2 + host read
        wraddress2_in=>address2,              -- Write for DDR bus2 + host write
        wren2_in=>ddr_write,                  
        wrbyteenable2_in=>byteenable2,
        q2_out=>ddr_readdata
    );


wr_vector_fifo_i: delay generic map(DEPTH =>ddr_delay_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>cell_ddr_0_readdatavalid,out_out=>cell_ddr_0_readdatavalid_delay,enable_in=>'1');

wr_vector_lane_fifo_i: delayv generic map(SIZE=>ddr_data_width_c,DEPTH =>ddr_delay_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>cell_ddr_0_readdata,out_out=>cell_ddr_0_readdata_delay,enable_in=>'1');

wr_vector_fifo_i2: delay generic map(DEPTH =>ddr_delay_c+1) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>cell_ddr_1_readdatavalid,out_out=>cell_ddr_1_readdatavalid_delay,enable_in=>'1');

wr_vector_lane_fifo_i2: delayv generic map(SIZE=>ddr_data_width_c,DEPTH =>ddr_delay_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>cell_ddr_1_readdata,out_out=>cell_ddr_1_readdata_delay,enable_in=>'1');

wr_vector_fifo_i3: delay generic map(DEPTH =>ddr_delay_c+1) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>cell_ddr_2_readdatavalid,out_out=>cell_ddr_2_readdatavalid_delay,enable_in=>'1');

wr_vector_lane_fifo_i3: delayv generic map(SIZE=>ddr_data_width_c,DEPTH =>ddr_delay_c) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>cell_ddr_2_readdata,out_out=>cell_ddr_2_readdata_delay,enable_in=>'1');


-------
-- Simulate DDR memory access
-------

burstbegin <= cell_ddr_0_burstbegin when not(burstbegin_r='1' and ddr_wait_r='1') else burstbegin_r;

burstbegin1 <= cell_ddr_1_burstbegin;

burstbegin2 <= cell_ddr_2_burstbegin;


-- Second port of RAM block is shareed between host access and second DDR read stream.
-- Therefore it's important not to access DDR block from host while code is running...

process(address3,cell_ddr_1_write,cell_ddr_1_read,ddr_wait,cell_ddr_1_byteenable,cell_ddr_1_writedata,
        ddr_write_in,ddr_addr_in,ddr_writedata_in,read1_r)
begin
if cell_ddr_1_write='1' or (cell_ddr_1_read='1' or read1_r='1')  then
   address2 <= address3;
   ddr_write <= cell_ddr_1_write and (not ddr_wait);
   byteenable2 <= cell_ddr_1_byteenable;
   ddr_writedata <= cell_ddr_1_writedata;
else
   address2 <= ddr_addr_in(address2'length+data_byte_width_depth_c+ddr_vector_depth_c-1 downto data_byte_width_depth_c+ddr_vector_depth_c);
   ddr_write <= ddr_write_in;
   
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="000" then
      byteenable2(1*data_byte_width_c-1 downto 0*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(1*data_byte_width_c-1 downto 0*data_byte_width_c) <= (others=>'0');
   end if;
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="001" then
      byteenable2(2*data_byte_width_c-1 downto 1*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(2*data_byte_width_c-1 downto 1*data_byte_width_c) <= (others=>'0');
   end if;
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="010" then
      byteenable2(3*data_byte_width_c-1 downto 2*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(3*data_byte_width_c-1 downto 2*data_byte_width_c) <= (others=>'0');
   end if;
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="011" then
      byteenable2(4*data_byte_width_c-1 downto 3*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(4*data_byte_width_c-1 downto 3*data_byte_width_c) <= (others=>'0');
   end if;
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="100" then
      byteenable2(5*data_byte_width_c-1 downto 4*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(5*data_byte_width_c-1 downto 4*data_byte_width_c) <= (others=>'0');
   end if;
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="101" then
      byteenable2(6*data_byte_width_c-1 downto 5*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(6*data_byte_width_c-1 downto 5*data_byte_width_c) <= (others=>'0');
   end if;
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="110" then
      byteenable2(7*data_byte_width_c-1 downto 6*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(7*data_byte_width_c-1 downto 6*data_byte_width_c) <= (others=>'0');
   end if;
   if ddr_addr_in(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c)="111" then
      byteenable2(8*data_byte_width_c-1 downto 7*data_byte_width_c) <= (others=>'1');
   else
      byteenable2(8*data_byte_width_c-1 downto 7*data_byte_width_c) <= (others=>'0');
   end if;

   ddr_writedata <= ddr_writedata_in & ddr_writedata_in & ddr_writedata_in & ddr_writedata_in & ddr_writedata_in & ddr_writedata_in & ddr_writedata_in & ddr_writedata_in;
end if;
end process;

address <= cell_ddr_0_addr(address'length+data_byte_width_depth_c+ddr_vector_depth_c-1 downto data_byte_width_depth_c+ddr_vector_depth_c) when (burstbegin='1' and ddr_wait='0') else address_r;

address3 <= cell_ddr_1_addr(address'length+data_byte_width_depth_c+ddr_vector_depth_c-1 downto data_byte_width_depth_c+ddr_vector_depth_c) when (burstbegin1='1' and ddr_wait='0') else address1_r;


cell_ddr_0_wait_request <= ddr_wait;
cell_ddr_0_readdatavalid <= readdatavalid_r;
cell_ddr_1_wait_request <= ddr_wait;
cell_ddr_1_readdatavalid <= read1_r;
cell_ddr_2_readdatavalid <= read2_r;


--ddr_error <= '1' when burstbegin='1' and burstlen_r /= to_unsigned(0,burstlen_r'length) else '0';
--assert ddr_error='0' report "DDR bus error 1" severity note;

-- INJECT ERROR

--ddr_wait <= '1' when ddr_wait_r='0' and burstbegin='1' else '0';
ddr_wait <= '0';

process(ddr_addr_rr,ddr_readdata)
begin
   case ddr_addr_rr(ddr_vector_depth_c+data_byte_width_depth_c-1 downto data_byte_width_depth_c) is
      when "000" =>
         ddr_readdata_out <= ddr_readdata(1*data_width_c-1 downto 0*data_width_c);
      when "001" =>
         ddr_readdata_out <= ddr_readdata(2*data_width_c-1 downto 1*data_width_c);
      when "010" =>
         ddr_readdata_out <= ddr_readdata(3*data_width_c-1 downto 2*data_width_c);
      when "011" =>
         ddr_readdata_out <= ddr_readdata(4*data_width_c-1 downto 3*data_width_c);
      when "100" =>
         ddr_readdata_out <= ddr_readdata(5*data_width_c-1 downto 4*data_width_c);
      when "101" =>
         ddr_readdata_out <= ddr_readdata(6*data_width_c-1 downto 5*data_width_c);
      when "110" =>
         ddr_readdata_out <= ddr_readdata(7*data_width_c-1 downto 6*data_width_c);
      when others =>
         ddr_readdata_out <= ddr_readdata(8*data_width_c-1 downto 7*data_width_c);
   end case;
end process;

process(clock_in,reset_in)
begin
if reset_in='0' then
   ddr_error_r <= '0';
else
    if clock_in'event and clock_in='1' then
       if (cell_ddr_0_burstbegin='1' and burstlen_r /= to_unsigned(0,burstlen_r'length) and ddr_wait='0') or
          (cell_ddr_0_read='1' and cell_ddr_0_write='1') then
          ddr_error_r <= '1';
          assert false report "DDR bus error 1" severity error;
       end if;
    end if;
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in='0' then
    burstlen_r <= (others=>'0');
    burstlen1_r <= (others=>'0');
    burstlen2_r <= (others=>'0');
    readdatavalid_r <= '0';
    readdatavalid_rr <= '0';
    address_r <= (others=>'0');
    address1_r <= (others=>'0');
    address2_r <= (others=>'0');
    read_r <= '0';
    read1_r <= '0';
    read2_r <= '0';
    write_r <= '0';
	ddr_wait_r <= '0';
	count_r <= (others=>'0');
	burstbegin_r <= '0';
    ddr_addr_r <= (others=>'0');
    ddr_addr_rr <= (others=>'0');
else
    if clock_in'event and clock_in='1' then
        ddr_addr_rr <= ddr_addr_r;
        ddr_addr_r <= ddr_addr_in;
	    burstbegin_r <= burstbegin;
        ddr_wait_r <= ddr_wait;
		count_r <= count_r+1;
        readdatavalid_rr <= readdatavalid_r;
        readdatavalid_r <= read_r;
        if burstbegin='1' and ddr_wait='0' and (cell_ddr_0_read='1' or cell_ddr_0_write='1') and (burstlen_r=to_unsigned(0,burstlen_r'length)) then
            burstlen_r <= cell_ddr_0_burstlen-1;
            address_r <= std_logic_vector(unsigned(cell_ddr_0_addr(address'length+data_byte_width_depth_c+ddr_vector_depth_c-1 downto data_byte_width_depth_c+ddr_vector_depth_c))+1);
            read_r <= cell_ddr_0_read;
            write_r <= cell_ddr_0_write;
        elsif burstlen_r /= to_unsigned(0,burstlen_r'length) then
            if read_r='1' or (cell_ddr_0_write='1' and ddr_wait='0') then
               burstlen_r <= burstlen_r-1;
               address_r <= std_logic_vector(unsigned(address_r)+1);
            end if;
        else
            read_r <= '0';
            write_r <= '0';
        end if;


        if burstbegin1='1' and ddr_wait='0' and (cell_ddr_1_read='1' or cell_ddr_1_write='1') and (burstlen1_r=to_unsigned(0,burstlen_r'length)) then
            burstlen1_r <= cell_ddr_1_burstlen-1;
            address1_r <= std_logic_vector(unsigned(cell_ddr_1_addr(address'length+data_byte_width_depth_c+ddr_vector_depth_c-1 downto data_byte_width_depth_c+ddr_vector_depth_c))+1);
            read1_r <= cell_ddr_1_read;
		elsif burstlen1_r /= to_unsigned(0,burstlen1_r'length) then
            if read1_r='1' or (cell_ddr_1_write='1' and ddr_wait='0')  then
               burstlen1_r <= burstlen1_r-1;
               address1_r <= std_logic_vector(unsigned(address1_r)+1);
            end if;
        else
            read1_r <= '0';
        end if;

        if burstbegin2='1' and ddr_wait='0'  and (cell_ddr_2_read='1' or cell_ddr_2_write='1') and (burstlen2_r=to_unsigned(0,burstlen_r'length)) then
            burstlen2_r <= cell_ddr_2_burstlen-1;
            address2_r <= std_logic_vector(unsigned(cell_ddr_2_addr(address'length+data_byte_width_depth_c+ddr_vector_depth_c-1 downto data_byte_width_depth_c+ddr_vector_depth_c))+1);
            read2_r <= cell_ddr_2_read;
		elsif burstlen2_r /= to_unsigned(0,burstlen2_r'length) then
            if read2_r='1' or (cell_ddr_2_write='1' and ddr_wait='0') then
               burstlen2_r <= burstlen2_r-1;
               address2_r <= std_logic_vector(unsigned(address2_r)+1);
            end if;
        else
            read2_r <= '0';
        end if;

    end if;
end if;
end process;
end testbench_behaviour;
