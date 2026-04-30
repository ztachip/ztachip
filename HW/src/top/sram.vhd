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
        DEPTH : integer;
        SRAM_VECTOR_DEPTH:integer
        );
    PORT (
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;

        -- DP interface
        
        SIGNAL dp_rd_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
        SIGNAL dp_wr_addr_in        : IN STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);        
        SIGNAL dp_write_in          : IN STD_LOGIC;
        SIGNAL dp_write_vector_in   : IN std_logic_vector(SRAM_VECTOR_DEPTH-1 downto 0);
        SIGNAL dp_read_in           : IN STD_LOGIC;
        SIGNAL dp_read_vector_in    : IN std_logic_vector(SRAM_VECTOR_DEPTH-1 downto 0);
        SIGNAL dp_read_gen_valid_in : IN STD_LOGIC;
        SIGNAL dp_writedata_in      : IN STD_LOGIC_VECTOR((8*(2**SRAM_VECTOR_DEPTH))-1 DOWNTO 0);
        SIGNAL dp_writebe_in        : IN STD_LOGIC_VECTOR((2**SRAM_VECTOR_DEPTH)-1 DOWNTO 0);
        SIGNAL dp_readdatavalid_out : OUT STD_LOGIC;
        SIGNAL dp_readdata_out      : OUT STD_LOGIC_VECTOR((8*(2**SRAM_VECTOR_DEPTH))-1 DOWNTO 0)
    );
END sram;

ARCHITECTURE behavior OF sram IS

constant SRAM_DATA_BYTE_WIDTH:integer:=(2**SRAM_VECTOR_DEPTH);

constant SRAM_DATA_WIDTH:integer:=8*(2**SRAM_VECTOR_DEPTH);

SIGNAL q:STD_LOGIC_VECTOR(SRAM_DATA_WIDTH-1 downto 0);
SIGNAL q_r:STD_LOGIC_VECTOR(SRAM_DATA_WIDTH-1 downto 0);
SIGNAL rden_r:STD_LOGIC;
SIGNAL rden_rr:STD_LOGIC;
SIGNAL rden_rrr:STD_LOGIC;
SIGNAL rd_vector_r:STD_LOGIC_VECTOR(SRAM_VECTOR_DEPTH-1 downto 0);
SIGNAL rd_vector_rr:STD_LOGIC_VECTOR(SRAM_VECTOR_DEPTH-1 downto 0);
SIGNAL rd_vector_rrr:STD_LOGIC_VECTOR(SRAM_VECTOR_DEPTH-1 downto 0);
SIGNAL valid:STD_LOGIC;
SIGNAL dp_wr_addr:STD_LOGIC_VECTOR(DEPTH-SRAM_VECTOR_DEPTH-1 downto 0);
SIGNAL dp_rd_addr:STD_LOGIC_VECTOR(DEPTH-SRAM_VECTOR_DEPTH-1 downto 0);
SIGNAL rd_addr_r:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL rd_addr_rr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL rd_addr_rrr:STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0);
SIGNAL byteena:STD_LOGIC_VECTOR(SRAM_DATA_BYTE_WIDTH-1 downto 0);
SIGNAL dp_writedata:STD_LOGIC_VECTOR(SRAM_DATA_WIDTH-1 DOWNTO 0);
SIGNAL wr_addr_r:STD_LOGIC_VECTOR(DEPTH-SRAM_VECTOR_DEPTH-1 downto 0);
SIGNAL byteena_r:STD_LOGIC_VECTOR(SRAM_DATA_BYTE_WIDTH-1 downto 0);
SIGNAL writedata_r:STD_LOGIC_VECTOR(SRAM_DATA_WIDTH-1 DOWNTO 0);
SIGNAL wren_r:std_logic;
SIGNAL dp_readdata_r:STD_LOGIC_VECTOR(SRAM_DATA_WIDTH-1 DOWNTO 0);
SIGNAL dp_readdatavalid:STD_LOGIC;
SIGNAL dp_readdatavalid_r:STD_LOGIC;

BEGIN

valid <= dp_read_in and dp_read_gen_valid_in;
dp_readdata_out <= dp_readdata_r when dp_readdatavalid_r='1' else (others=>'Z');
dp_readdatavalid_out <= dp_readdatavalid_r;
delay_i1: delay generic map(DEPTH => read_latency_sram_c-1) 
            port map(clock_in => clock_in,reset_in => reset_in,in_in=>valid,out_out=>dp_readdatavalid,enable_in=>'1');
dp_wr_addr <= dp_wr_addr_in(DEPTH-1 downto SRAM_VECTOR_DEPTH);
dp_rd_addr <= dp_rd_addr_in(DEPTH-1 downto SRAM_VECTOR_DEPTH);


process(dp_wr_addr_in,dp_write_vector_in,dp_writedata_in,dp_writebe_in)
variable byteena_v:STD_LOGIC_VECTOR(SRAM_DATA_BYTE_WIDTH-1 downto 0);
variable dp_writedata_v:STD_LOGIC_VECTOR(SRAM_DATA_WIDTH-1 DOWNTO 0);
begin
    byteena <= dp_writebe_in;
    dp_writedata <= dp_writedata_in;
    FOR J IN 1 to SRAM_VECTOR_DEPTH LOOP
        if unsigned(dp_write_vector_in)=to_unsigned((SRAM_DATA_BYTE_WIDTH/(2**J))-1,dp_write_vector_in'length) then
            byteena <= (others=>'0');
            FOR I in 0 TO (2**J)-1 LOOP
                if(to_integer(unsigned(dp_wr_addr_in(SRAM_VECTOR_DEPTH-1 downto SRAM_VECTOR_DEPTH-J)))=I) then
                    byteena(((I+1)*(SRAM_DATA_BYTE_WIDTH/(2**J)))-1 downto I*SRAM_DATA_BYTE_WIDTH/(2**J)) <= dp_writebe_in((SRAM_DATA_BYTE_WIDTH/(2**J))-1 downto 0);
                    exit;
                end if;
            END LOOP;
            FOR I in 0 TO (2**J)-1 LOOP
                dp_writedata(((I+1)*SRAM_DATA_WIDTH/(2**J))-1 downto (I)*SRAM_DATA_WIDTH/(2**J)) <= dp_writedata_in((SRAM_DATA_WIDTH/(2**J))-1 downto 0);
            END LOOP;
            exit;
        end if;
    end loop;
end process;

process(clock_in,reset_in)
variable gotit_v:std_logic;
begin
    if reset_in='0' then
        dp_readdata_r <= (others=>'0');
        dp_readdatavalid_r <= '0';
    else
        if clock_in'event and clock_in='1' then
            dp_readdatavalid_r <= dp_readdatavalid;
            if rden_rrr='1' then
                gotit_v := '0';
                FOR J in 1 to SRAM_VECTOR_DEPTH LOOP
                    if unsigned(rd_vector_rrr)=to_unsigned(SRAM_DATA_BYTE_WIDTH/(2**J)-1,rd_vector_rrr'length) then
                        FOR I in 0 to (2**J)-1 LOOP
                            IF(to_integer(unsigned(rd_addr_rrr(SRAM_VECTOR_DEPTH-1 downto SRAM_VECTOR_DEPTH-J)))=I) THEN
                                dp_readdata_r(SRAM_DATA_WIDTH/(2**J)-1 downto 0) <= q_r((I+1)*SRAM_DATA_WIDTH/(2**J)-1 downto I*SRAM_DATA_WIDTH/(2**J));
                                exit;
                            end if;
                        END LOOP;
                        dp_readdata_r(SRAM_DATA_WIDTH-1 downto SRAM_DATA_WIDTH/(2**J)) <= (others=>'0');
                        gotit_v:='1';
                        exit;
                    end if;
                END LOOP;
                if(gotit_v='0') then
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
        numwords_a=>2**(DEPTH-SRAM_VECTOR_DEPTH),
        numwords_b=>2**(DEPTH-SRAM_VECTOR_DEPTH),
        widthad_a=>DEPTH-SRAM_VECTOR_DEPTH,
        widthad_b=>DEPTH-SRAM_VECTOR_DEPTH,
        width_a=>SRAM_DATA_WIDTH,
        width_b=>SRAM_DATA_WIDTH
    )
    PORT MAP (
        address_a => wr_addr_r,
        byteena_a => byteena_r,
        clock0 => clock_in,
        data_a => writedata_r,
        wren_a => wren_r,
        address_b => rd_addr_r(DEPTH-1 downto SRAM_VECTOR_DEPTH),
        q_b => q
    );

END behavior;
