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
-- Perform arbitration among many requests
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ztachip_pkg.all;

entity arbiter is
    generic(
        NUM_SIGNALS     : integer;
        PRIORITY_BASED  : boolean
        );
    port(
        SIGNAL clock_in         : IN STD_LOGIC;
        SIGNAL reset_in         : IN STD_LOGIC;
        SIGNAL req_in           : IN STD_LOGIC_VECTOR(NUM_SIGNALS-1 downto 0);
        SIGNAL gnt_out          : OUT STD_LOGIC_VECTOR(NUM_SIGNALS-1 downto 0);
        SIGNAL gnt_valid_out    : OUT STD_LOGIC
        );
end arbiter;
            
architecture arbiter_behaviour of arbiter is
signal gnt_r:std_logic_vector(NUM_SIGNALS-1 downto 0);
signal gnt:std_logic_vector(NUM_SIGNALS-1 downto 0);
signal gnt1:std_logic_vector(NUM_SIGNALS-1 downto 0);
signal gnt2:std_logic_vector(NUM_SIGNALS-1 downto 0);
signal req:std_logic_vector(NUM_SIGNALS-1 downto 0);
begin

--gnt2 <= req_in and std_logic_vector(unsigned(not(req_in))+1);
--gnt_out <= gnt2;
--gnt_valid_out <= '0' when gnt2=std_logic_vector(to_unsigned(0,NUM_SIGNALS)) else '1';

---------
--- Perform round-robin arbitration
---------

assert NUM_SIGNALS=16 report "Invalid arbiter parameter" severity note;

gnt <= req_in and std_logic_vector(-signed(req_in));
req <= req_in and gnt_r;
gnt1 <= req and std_logic_vector(-signed(req));
gnt2 <= gnt1 when req /= std_logic_vector(to_unsigned(0,req'length)) else gnt;
gnt_out <= gnt2;
gnt_valid_out <= '0' when req_in=std_logic_vector(to_unsigned(0,NUM_SIGNALS)) else '1';

---------
-- Perform round-robin arbitration
---------

process(reset_in,clock_in)
variable no_grant_v:std_logic_vector(NUM_SIGNALS-1 downto 0);
begin
    if reset_in = '0' then
        gnt_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            no_grant_v := (others=>'0');
            if req_in /= no_grant_v then
                gnt_r <= (not (std_logic_vector(unsigned(gnt2) - 1) or gnt2));
            end if;
        end if;
    end if;
end process;

end arbiter_behaviour;
