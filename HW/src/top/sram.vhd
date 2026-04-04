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

--------
-- Implement SRAM block
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

ENTITY sram IS
    GENERIC(
        DEPTH : integer
        );
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        -- DP interface
        
        SIGNAL dp_rd_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
        SIGNAL dp_wr_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);        
        SIGNAL dp_write_in          : IN STD_LOGIC;
        SIGNAL dp_write_vector_in   : IN std_logic_vector(ddr_vector_depth_c+1-1 downto 0);
        SIGNAL dp_read_in           : IN STD_LOGIC;
        SIGNAL dp_read_vector_in    : IN std_logic_vector(ddr_vector_depth_c+1-1 downto 0);
        SIGNAL dp_read_gen_valid_in : IN STD_LOGIC;
        SIGNAL dp_writedata_in      : IN STD_LOGIC_VECTOR(2*ddr_data_width_c-1 DOWNTO 0);
        SIGNAL dp_writebe_in        : IN STD_LOGIC_VECTOR(2*ddr_data_byte_width_c-1 DOWNTO 0);
        SIGNAL dp_readdatavalid_out : OUT STD_LOGIC;
        SIGNAL dp_readdata_out      : OUT STD_LOGIC_VECTOR(2*ddr_data_width_c-1 DOWNTO 0)
    );
END sram;

ARCHITECTURE behavior OF sram IS

COMPONENT altsyncram
GENERIC (
        address_aclr_b                      : STRING;
        address_reg_b                       : STRING;
        clock_enable_input_a                : STRING;
        clock_enable_input_b                : STRING;
        clock_enable_output_b               : STRING;
        intended_device_family              : STRING;
        lpm_type                            : STRING;
        numwords_a                          : NATURAL;
        numwords_b                          : NATURAL;
        operation_mode                      : STRING;
        outdata_aclr_b                      : STRING;
        outdata_reg_b                       : STRING;
        power_up_uninitialized              : STRING;
        read_during_write_mode_mixed_ports  : STRING;
        widthad_a                           : NATURAL;
        widthad_b                           : NATURAL;
        width_a                             : NATURAL;
        width_b                             : NATURAL;
        width_byteena_a                     : NATURAL
    );
    PORT (
            address_a   : IN STD_LOGIC_VECTOR (widthad_a-1 DOWNTO 0);
            byteena_a   : IN STD_LOGIC_VECTOR (width_byteena_a-1 DOWNTO 0);
            clock0      : IN STD_LOGIC ;
            data_a      : IN STD_LOGIC_VECTOR (width_a-1 DOWNTO 0);
            q_b         : OUT STD_LOGIC_VECTOR (width_b-1 DOWNTO 0);
            wren_a      : IN STD_LOGIC ;
            address_b   : IN STD_LOGIC_VECTOR (widthad_b-1 DOWNTO 0)
    );
END COMPONENT;

--constant DDR_VECTOR_WIDTH:integer:=3;

constant DDR_VECTOR_WIDTH:integer:=4;

constant DDR_DATA_BYTE_WIDTH:integer:=(2**DDR_VECTOR_WIDTH);

constant DDR_DATA_WIDTH:integer:=8*(2**DDR_VECTOR_WIDTH);

SIGNAL q:STD_LOGIC_VECTOR(DDR_DATA_WIDTH-1 downto 0);
SIGNAL q_r:STD_LOGIC_VECTOR(DDR_DATA_WIDTH-1 downto 0);
SIGNAL rden_r:STD_LOGIC;
SIGNAL rden_rr:STD_LOGIC;
SIGNAL rden_rrr:STD_LOGIC;
SIGNAL rd_vector_r:STD_LOGIC_VECTOR(DDR_VECTOR_WIDTH-1 downto 0);
SIGNAL rd_vector_rr:STD_LOGIC_VECTOR(DDR_VECTOR_WIDTH-1 downto 0);
SIGNAL rd_vector_rrr:STD_LOGIC_VECTOR(DDR_VECTOR_WIDTH-1 downto 0);
SIGNAL valid:STD_LOGIC;
SIGNAL dp_wr_addr:STD_LOGIC_VECTOR(DEPTH-DDR_VECTOR_WIDTH-1 downto 0);
SIGNAL dp_rd_addr:STD_LOGIC_VECTOR(DEPTH-DDR_VECTOR_WIDTH-1 downto 0);
SIGNAL rd_addr_r:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL rd_addr_rr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL rd_addr_rrr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL byteena:STD_LOGIC_VECTOR(DDR_DATA_BYTE_WIDTH-1 downto 0);
SIGNAL dp_writedata:STD_LOGIC_VECTOR(DDR_DATA_WIDTH-1 DOWNTO 0);
SIGNAL wr_addr_r:STD_LOGIC_VECTOR(DEPTH-DDR_VECTOR_WIDTH-1 downto 0);
SIGNAL byteena_r:STD_LOGIC_VECTOR(DDR_DATA_BYTE_WIDTH-1 downto 0);
SIGNAL writedata_r:STD_LOGIC_VECTOR(DDR_DATA_WIDTH-1 DOWNTO 0);
SIGNAL wren_r:std_logic;
SIGNAL dp_readdata_r:STD_LOGIC_VECTOR(DDR_DATA_WIDTH-1 DOWNTO 0);
SIGNAL dp_readdatavalid:STD_LOGIC;
SIGNAL dp_readdatavalid_r:STD_LOGIC;

BEGIN

valid <= dp_read_in and dp_read_gen_valid_in;
dp_readdata_out <= dp_readdata_r when dp_readdatavalid_r='1' else (others=>'Z');
dp_readdatavalid_out <= dp_readdatavalid_r;
delay_i1: delay generic map(DEPTH => read_latency_sram_c-1) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>valid,out_out=>dp_readdatavalid,enable_in=>'1');
dp_wr_addr <= dp_wr_addr_in(DEPTH-1 downto DDR_VECTOR_WIDTH);
dp_rd_addr <= dp_rd_addr_in(DEPTH-1 downto DDR_VECTOR_WIDTH);

process(dp_wr_addr_in,dp_write_vector_in,dp_writedata_in,dp_writebe_in)
begin
byteena <= (others=>'0');
if unsigned(dp_write_vector_in)=to_unsigned(DDR_DATA_BYTE_WIDTH/2-1,dp_write_vector_in'length) then
    FOR I in 0 TO 1 LOOP
        if(to_integer(unsigned(dp_wr_addr_in(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-1)))=I) then
            byteena((I+1)*DDR_DATA_BYTE_WIDTH/2-1 downto I*DDR_DATA_BYTE_WIDTH/2) <= dp_writebe_in(DDR_DATA_BYTE_WIDTH/2-1 downto 0);
            exit;
        end if;
    END LOOP;
    FOR I in 0 TO 1 LOOP
        dp_writedata((I+1)*DDR_DATA_WIDTH/2-1 downto (I)*DDR_DATA_WIDTH/2) <= dp_writedata_in(DDR_DATA_WIDTH/2-1 downto 0);
    END LOOP;
elsif unsigned(dp_write_vector_in)=to_unsigned(DDR_DATA_BYTE_WIDTH/4-1,dp_write_vector_in'length) then
    FOR I in 0 TO 3 LOOP
        if(to_integer(unsigned(dp_wr_addr_in(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-2)))=I) then
            byteena((I+1)*DDR_DATA_BYTE_WIDTH/4-1 downto I*DDR_DATA_BYTE_WIDTH/4) <= dp_writebe_in(DDR_DATA_BYTE_WIDTH/4-1 downto 0);
            exit;
        end if;
    END LOOP;
    FOR I in 0 to 3 LOOP
        dp_writedata((I+1)*DDR_DATA_WIDTH/4-1 downto I*DDR_DATA_WIDTH/4) <= dp_writedata_in(DDR_DATA_WIDTH/4-1 downto 0);
    END LOOP;
elsif unsigned(dp_write_vector_in)=to_unsigned(DDR_DATA_BYTE_WIDTH/8-1,dp_write_vector_in'length) then
    FOR I IN 0 TO 7 LOOP
        if(to_integer(unsigned(dp_wr_addr_in(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-3)))=I) then
            byteena((I+1)*DDR_DATA_BYTE_WIDTH/8-1 downto I*DDR_DATA_BYTE_WIDTH/8) <= dp_writebe_in(DDR_DATA_BYTE_WIDTH/8-1 downto 0);
            exit;
        end if;
    END LOOP;
    FOR I in 0 to 7 LOOP
        dp_writedata((I+1)*DDR_DATA_WIDTH/8-1 downto I*DDR_DATA_WIDTH/8) <= dp_writedata_in(DDR_DATA_WIDTH/8-1 downto 0);
    END LOOP;
elsif unsigned(dp_write_vector_in)=to_unsigned(DDR_DATA_BYTE_WIDTH/16-1,dp_write_vector_in'length) then
    FOR I IN 0 TO 15 LOOP
        if(to_integer(unsigned(dp_wr_addr_in(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-4)))=I) then
            byteena((I+1)*DDR_DATA_BYTE_WIDTH/16-1 downto I*DDR_DATA_BYTE_WIDTH/16) <= dp_writebe_in(DDR_DATA_BYTE_WIDTH/16-1 downto 0);
            exit;
        end if;
    END LOOP;
    FOR I in 0 to 15 LOOP
        dp_writedata((I+1)*DDR_DATA_WIDTH/16-1 downto I*DDR_DATA_WIDTH/16) <= dp_writedata_in(DDR_DATA_WIDTH/16-1 downto 0);
    END LOOP;
else
   byteena <= dp_writebe_in;
   dp_writedata <= dp_writedata_in;
end if;
end process;

process(clock_in,reset_in)
begin
if reset_in='0' then
dp_readdata_r <= (others=>'0');
dp_readdatavalid_r <= '0';
else
if clock_in'event and clock_in='1' then
dp_readdatavalid_r <= dp_readdatavalid;
if rden_rrr='1' then
    if unsigned(rd_vector_rrr)=to_unsigned(DDR_DATA_BYTE_WIDTH/2-1,rd_vector_rrr'length) then
        FOR I in 0 to 1 LOOP
            IF(to_integer(unsigned(rd_addr_rrr(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-1)))=I) THEN
                dp_readdata_r(DDR_DATA_WIDTH/2-1 downto 0) <= q_r((I+1)*DDR_DATA_WIDTH/2-1 downto I*DDR_DATA_WIDTH/2);
                exit;
            end if;
        END LOOP;
        dp_readdata_r(DDR_DATA_WIDTH-1 downto DDR_DATA_WIDTH/2) <= (others=>'0');
    elsif unsigned(rd_vector_rrr)=to_unsigned(DDR_DATA_BYTE_WIDTH/4-1,rd_vector_rrr'length) then
        FOR I in 0 to 3 LOOP
            if(to_integer(unsigned(rd_addr_rrr(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-2)))=I) then
                dp_readdata_r(DDR_DATA_WIDTH/4-1 downto 0) <= q_r((I+1)*DDR_DATA_WIDTH/4-1 downto I*DDR_DATA_WIDTH/4);
                exit;
            end if;
        END LOOP;
        dp_readdata_r(DDR_DATA_WIDTH-1 downto DDR_DATA_WIDTH/4) <= (others=>'0');
    elsif unsigned(rd_vector_rrr)=to_unsigned(DDR_DATA_BYTE_WIDTH/8-1,rd_vector_rrr'length) then
        FOR I in 0 to 7 LOOP
            if(to_integer(unsigned(rd_addr_rrr(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-3)))=I) then
                dp_readdata_r(DDR_DATA_WIDTH/8-1 downto 0) <= q_r((I+1)*DDR_DATA_WIDTH/8-1 downto (I)*DDR_DATA_WIDTH/8);
                exit;
            end if;
        END LOOP;
        dp_readdata_r(DDR_DATA_WIDTH-1 downto DDR_DATA_WIDTH/8) <= (others=>'0');
    elsif unsigned(rd_vector_rrr)=to_unsigned(DDR_DATA_BYTE_WIDTH/16-1,rd_vector_rrr'length) then
        FOR I in 0 to 15 LOOP
            if(to_integer(unsigned(rd_addr_rrr(DDR_VECTOR_WIDTH-1 downto DDR_VECTOR_WIDTH-4)))=I) then
                dp_readdata_r(DDR_DATA_WIDTH/16-1 downto 0) <= q_r((I+1)*DDR_DATA_WIDTH/16-1 downto (I)*DDR_DATA_WIDTH/16);
                exit;
            end if;
        END LOOP;
        dp_readdata_r(DDR_DATA_WIDTH-1 downto DDR_DATA_WIDTH/16) <= (others=>'0');
    else
        dp_readdata_r <= q_r;
    end if;
else
   dp_readdata_r <= (others=>'0');
end if;
end if;
end if;
end process;

process(reset_in,clock_in)
begin
    if reset_in = '0' then
        q_r <= (others=>'0');
        rden_r <= '0';
        rden_rr <= '0';
        rden_rrr <= '0';
        rd_vector_r <= (others=>'0');
        rd_vector_rr <= (others=>'0');
        rd_vector_rrr <= (others=>'0');
        rd_addr_r <= (others=>'0');
        rd_addr_rr <= (others=>'0');
        rd_addr_rrr <= (others=>'0');
        wr_addr_r <= (others=>'0');
        byteena_r <= (others=>'0');
        writedata_r <= (others=>'0');
        wren_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            wr_addr_r <= dp_wr_addr;
            byteena_r <= byteena;
            writedata_r <= dp_writedata;
            wren_r <= dp_write_in;

            rd_vector_rrr <= rd_vector_rr;
            rd_vector_rr <= rd_vector_r;
            rd_vector_r <= dp_read_vector_in;
            rden_rrr <= rden_rr;
            rden_rr <= rden_r;
            rden_r <= dp_read_in;
            rd_addr_r <= dp_rd_addr_in;
            rd_addr_rr <= rd_addr_r;
            rd_addr_rrr <= rd_addr_rr;
            q_r <= q;
        end if;
    end if;
end process;

altsyncram_i : DPRAM_BE
    GENERIC MAP (
        numwords_a=>2**(DEPTH-DDR_VECTOR_WIDTH),
        numwords_b=>2**(DEPTH-DDR_VECTOR_WIDTH),
        widthad_a=>DEPTH-DDR_VECTOR_WIDTH,
        widthad_b=>DEPTH-DDR_VECTOR_WIDTH,
        width_a=>DDR_DATA_WIDTH,
        width_b=>DDR_DATA_WIDTH
    )
    PORT MAP (
        address_a => wr_addr_r,
        byteena_a => byteena_r,
        clock0 => clock_in,
        data_a => writedata_r,
        wren_a => wren_r,
        address_b => rd_addr_r(DEPTH-1 downto DDR_VECTOR_WIDTH),
        q_b => q
    );

END behavior;
