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
-----------------------------------------------------------------------------


library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;
use work.config.all;

---------
-- Track memory updates pending from a FPU operation
-- Determine if there is a write read conflict and read will have to be delayed until
-- writes are committed.
-- Harzard block allows one FPU operation to start without waiting for previous FPU operations
-- to be completed, but read accesses are blocked if there are write pending on the same addresses
------------

ENTITY fpu_hazard IS
    GENERIC (
        JOB         : integer -- Which FPU job that this object is tracking
    );
    port(
        SIGNAL clock_in             : IN STD_LOGIC;
        SIGNAL reset_in             : IN STD_LOGIC;
        -- FPU operations
        SIGNAL input_ena_in         : IN STD_LOGIC;
        SIGNAL eof_in               : IN STD_LOGIC;
        SIGNAL bof_in               : IN STD_LOGIC;
        SIGNAL waddr_in             : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
        SIGNAL job_in               : IN fpu_job_t;
        -- FPU operation write result
        SIGNAL fpu_write_in         : IN STD_LOGIC;
        SIGNAL fpu_eof_in           : IN STD_LOGIC;
        SIGNAL fpu_bof_in           : IN STD_LOGIC;
        SIGNAL fpu_waddr_in         : IN STD_LOGIC_VECTOR(sram_depth_c-1 DOWNTO 0);
        SIGNAL fpu_job_in           : IN fpu_job_t;
        -- Is the current JOB still active
        SIGNAL busy_out             : OUT STD_LOGIC;
        -- Check for hazard read access
        SIGNAL hazard_raddr_in      : IN std_logic_vector(sram_depth_c-1 downto 0);
        SIGNAL hazard_out           : OUT STD_LOGIC
    );
END fpu_hazard;

ARCHITECTURE fpu_hazard_behaviour of fpu_hazard is

SIGNAL startAddr_r:std_logic_vector(sram_depth_c-fpu_vector_depth_c-1 DOWNTO 0);

SIGNAL startAddr_rr:std_logic_vector(sram_depth_c-fpu_vector_depth_c-1 DOWNTO 0);

SIGNAL startAddr_rrr:std_logic_vector(sram_depth_c-fpu_vector_depth_c-1 DOWNTO 0);

SIGNAL endAddr_r:std_logic_vector(sram_depth_c-fpu_vector_depth_c-1 DOWNTO 0);

SIGNAL fpu_waddr:std_logic_vector(sram_depth_c-fpu_vector_depth_c-1 DOWNTO 0);

SIGNAL waddr:std_logic_vector(sram_depth_c-fpu_vector_depth_c-1 DOWNTO 0);

SIGNAL active:std_logic;

SIGNAL active_r:std_logic;

SIGNAL active_rr:std_logic;

SIGNAL active_rrr:std_logic;

SIGNAL match:STD_LOGIC;

SIGNAL fpu_match:STD_LOGIC;

BEGIN

active <= active_r or active_rr or active_rrr;

busy_out <= active;

match <= '1' when input_ena_in='1' and (to_integer(job_in)=JOB) else '0';

fpu_match <= '1' when fpu_write_in='1' and (to_integer(fpu_job_in)=JOB) else '0';

waddr <= waddr_in(waddr_in'length-1 downto fpu_vector_depth_c);

fpu_waddr <= fpu_waddr_in(fpu_waddr_in'length-1 downto fpu_vector_depth_c);

-------
-- Check for raddr is in harzard zone
-- Are there outstanding write to the same address accessed by raddr
-------

process(active,hazard_raddr_in,startAddr_rrr,endAddr_r)
variable raddr_v:std_logic_vector(sram_depth_c-fpu_vector_depth_c-1 downto 0);
begin
    raddr_v := hazard_raddr_in(hazard_raddr_in'length-1 downto fpu_vector_depth_c);
    IF ((active='1') and 
        (unsigned(raddr_v) >= unsigned(startAddr_rrr)) and (unsigned(raddr_v) <= unsigned(endAddr_r))) then
        hazard_out <= '1';
    else
        hazard_out <= '0';
    END IF;
end process;

process(clock_in,reset_in)
variable startAddr_v:STD_LOGIC_VECTOR(sram_depth_c-fpu_vector_depth_c-1 DOWNTO 0);
variable active_v:STD_LOGIC;
variable reset_v:STD_LOGIC;
begin
    if reset_in = '0' then
        startAddr_r <= (others=>'0');
        startAddr_rr <= (others=>'0');
        startAddr_rrr <= (others=>'0');
        endAddr_r <= (others=>'0');
        active_r <= '0';
        active_rr <= '0';
        active_rrr <= '0';
    else
        if clock_in'event and clock_in='1' then
            startAddr_v := startAddr_r;
            active_v := active_r; 
            reset_v := '0';
            if(match='1') then
                if(bof_in='1') then
                    startAddr_v := waddr;
                    endAddr_r <= waddr;
                    active_v := '1';
                    reset_v := '1';
                else
                    endAddr_r <= waddr;
                end if;
            end if;
            if(fpu_match='1') then
                startAddr_v := fpu_waddr;
                if(fpu_eof_in='1') then
                    active_v := '0';
                end if;
            end if;

            startAddr_r <= startAddr_v;
            active_r <= active_v;
            if(reset_v='0') then
                startAddr_rr <= startAddr_r;
                startAddr_rrr <= startAddr_rr;
                active_rr <= active_r;
                active_rrr <= active_rr;
            else
                startAddr_rr <= startAddr_v;
                startAddr_rrr <= startAddr_v;
                active_rr <= active_v;
                active_rrr <= active_v;
            end if;
        end if;
    end if;
end process;

END fpu_hazard_behaviour;

