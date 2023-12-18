------------------------------------------------------
-- This file contains tunable parameters for ztachip
------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
package config is

-----------------------------------------------------------
-- configure ztachip size
-- Choose appropriate size that fits your targeted FPGA
-- ztachip supported 2 sizes below
-----------------------------------------------------------

--LARGE VERSION
constant pid_gen_max_c: integer:=8;

--SMALL VERSION
--constant pid_gen_max_c: integer:=4;

-----------------------------------------------------------------
-- Memory usage optimization
-- FPGA typically have memory blocks with a minimum depth allowed
-- This will cause memory block waste if the required memory
-- depth is less than the minimum allowed by FPGA
-- Below we Specify minimum depth of memory block allowed by FPGA
-- If required memory depth <= (min_mem_depth_c/2) then words are 
-- stored in 2 consecutive words but running in x2 clock speed.
-- This will improve memory utilization at cost slower Fmax 
-- Set this to zero to disable this memory resource optimization
-----------------------------------------------------------------
 
constant min_mem_depth_c:integer:=512;

--constant min_mem_depth_c:integer:=0;

---------------------------------------------------------------
-- Specify data width to external memory
-- ztachip accesses external memory via AXI bus protocol
-- ztachip supports 32-bit or 64-bit AXI bus width for external
-- memory access
---------------------------------------------------------------

--constant exmem_data_width_c:integer:=32;

constant exmem_data_width_c:integer:=64;

end;
