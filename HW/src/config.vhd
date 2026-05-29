------------------------------------------------------
--
--
-- ********************* IMPORTANT *********************
--
--
-- 
-- This file contains tunable parameters for ztachip
-- SW/src/config.h must also be updated to match changes
-- in hardware configuration parameters
-- 
--
------------------------------------------------------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
package config is

-----------------------------------------------------------
-- configure number of PCOREs
-- Choose appropriate size that fits your targeted FPGA
-- ztachip supported 2 sizes below
-------------------------------------------------------------

--constant NUM_PCORE: integer:=8; --LARGE VERSION

constant NUM_PCORE: integer:=4; --SMALL VERSION

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
-- Specify data width to external memory via a DDR controller
-- ztachip accesses external memory via DDR controller's AXI bus
-- ztachip supports 64-bit or 128-bit AXI bus width for 
-- external memory access
---------------------------------------------------------------

--constant exmem_data_width_c:integer:=64;

constant exmem_data_width_c:integer:=128;

---------------------------------------------------------------
-- Main clock speed
---------------------------------------------------------------

constant main_clock_c:integer:=125000000;


---------------------------------------------------------------
-- Internal bus width (in bytes) to connect SCRATCH/PCORE/DDR to 
-- DP engine
-- Internal bus width = (2**INTERNAL_BUS_LOG2_WIDTH) bytes
---------------------------------------------------------------

constant INTERNAL_BUS_LOG2_WIDTH:integer:=4;

---------------------------------------------------------------
-- Enable/disable FPU. This option is required to run LLM models
----------------------------------------------------------------
 
constant FPU_ENABLED:boolean:=TRUE;

--constant FPU_ENABLED:boolean:=FALSE;

---------------------------------------------------------------
-- FPU operates in vector mode
-- FPU_vector_width = 2**FPU_VECTOR_LOG2_WIDTH
---------------------------------------------------------------

constant FPU_VECTOR_LOG2_WIDTH:integer:=1;

----------------------------------------------------------------
-- Bus width (in bytes) for FPU to fetch/write data to/from SCRATCH
-- memory space.
-- Width of FPU bus=2**FPU_BUS_LOG2_WIDTH bytes
-- FPU bus width must be =internal_bus_width or =2*internal_bus_width
------------------------------------------------------------------

constant FPU_BUS_LOG2_WIDTH :integer:=4;

--constant FPU_BUS_LOG2_WIDTH :integer:=3;

---------------------------------------------------------------
-- Max tensor size in log2
-- Max tensor size = 2**MAX_TENSOR_LOG2_SIZE
---------------------------------------------------------------

--constant MAX_TENSOR_LOG2_SIZE: integer:=24;

constant MAX_TENSOR_LOG2_SIZE: integer:=26;

end;
