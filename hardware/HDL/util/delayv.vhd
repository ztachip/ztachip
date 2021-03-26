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
--- Delay a vector by a number of clocks
--------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.hpc_pkg.all;

entity delayv is
    generic(
        SIZE    : integer;
        DEPTH   : integer
    );
    port(
        SIGNAL clock_in     : IN STD_LOGIC;
        SIGNAL reset_in     : IN STD_LOGIC;
        SIGNAL in_in        : IN STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
        SIGNAL out_out      : OUT STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
        SIGNAL enable_in    : IN STD_LOGIC
    );
end delayv;

architecture delay_behaviour of delayv is
type fifo_t is array(natural range <>) of std_logic_vector(SIZE-1 downto 0);
signal fifo_r:fifo_t(DEPTH-1 downto 0);
begin
out_out <= fifo_r(0);
process(reset_in,clock_in)
begin
    if reset_in='0' then
        for I in 0 to DEPTH-1 loop
            fifo_r(I) <= (others=>'0');
        end loop;
    else
        if clock_in'event and clock_in='1' then
            if DEPTH > 1 then
                for I in 0 to DEPTH-2 loop
                    if enable_in='1' then
                        fifo_r(I) <= fifo_r(I+1);
                    end if;
                end loop;
            end if;
            if enable_in='1' then
                fifo_r(DEPTH-1) <= in_in;
            end if;
        end if;
    end if;
end process;
end delay_behaviour;
