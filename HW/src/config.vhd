---------------------------------------------------
-- This file is generated from parsing config.xml
---------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
package config is

-- Matrix configuration parameters 

--LARGE VERSION
constant pid_gen_max_c: integer:=8;

--SMALL VERSION
--constant pid_gen_max_c: integer:=4;

--Minimum depth of memory block allowed by FPGA
--If required memory depth <= (min_mem_depth_c/2) then words are stored in 
--2 consecutive words but running in x2 clock speed.
--This will improve memory utilization at cost of slower Fmax.
--Set this to zero to disable this memory resource optimization
 
constant min_mem_depth_c:integer:=512;

--constant min_mem_depth_c:integer:=0;

end;
