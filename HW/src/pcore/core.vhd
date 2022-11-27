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
------------------------------------------------------------------------------

-------
--- This is the top level of PCORE processor array
-------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.config.all;
use work.ztachip_pkg.all;

ENTITY core IS
   PORT(SIGNAL clock_in                 : IN STD_LOGIC;
        SIGNAL clock_x2_in              : IN STD_LOGIC;
        SIGNAL reset_in                 : IN STD_LOGIC;
       
        -- DP interface
       
        SIGNAL dp_rd_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_rd_fork_in            : IN dp_fork_t;  
        SIGNAL dp_rd_addr_mode_in       : IN STD_LOGIC;
        SIGNAL dp_wr_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
        SIGNAL dp_wr_fork_in            : IN dp_fork_t;    
        SIGNAL dp_wr_addr_mode_in       : IN STD_LOGIC;
        SIGNAL dp_wr_mcast_in           : IN mcast_t;        
        SIGNAL dp_write_in              : IN STD_LOGIC;
        SIGNAL dp_write_data_flow_in    : IN data_flow_t;
        SIGNAL dp_write_data_type_in    : IN dp_data_type_t;
        SIGNAL dp_write_data_model_in   : IN dp_data_model_t;
        SIGNAL dp_write_gen_valid_in    : IN STD_LOGIC;
        SIGNAL dp_write_vector_in       : IN dp_vector_t;
        SIGNAL dp_write_stream_in       : IN std_logic;
        SIGNAL dp_write_stream_id_in    : IN stream_id_t;
        SIGNAL dp_write_scatter_in      : IN scatter_t;
        SIGNAL dp_write_wait_out        : OUT STD_LOGIC;
        SIGNAL dp_read_gen_valid_in     : IN STD_LOGIC;
        SIGNAL dp_read_in               : IN STD_LOGIC;
        SIGNAL dp_read_data_flow_in     : IN data_flow_t;
        SIGNAL dp_read_stream_in        : IN STD_LOGIC;
        SIGNAL dp_read_stream_id_in     : IN stream_id_t;
        SIGNAL dp_read_data_type_in     : IN dp_data_type_t;
        SIGNAL dp_read_data_model_in    : IN dp_data_model_t;
        SIGNAL dp_read_vector_in        : IN dp_vector_t;
        SIGNAL dp_read_scatter_in       : IN scatter_t;
        SIGNAL dp_read_wait_out         : OUT STD_LOGIC;
        SIGNAL dp_writedata_in          : IN std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL dp_readdatavalid_out     : OUT STD_LOGIC;
        SIGNAL dp_read_gen_valid_out    : OUT STD_LOGIC;
        SIGNAL dp_readdata_out          : OUT std_logic_vector(ddr_data_width_c-1 downto 0);
        SIGNAL dp_readdata_vm_out       : OUT STD_LOGIC;
       
        -- Task control
       
        SIGNAL task_start_addr_in       : IN instruction_addr_t;
        SIGNAL task_in                  : IN STD_LOGIC;
        SIGNAL task_vm_in               : IN STD_LOGIC;
        SIGNAL task_pcore_in            : IN pcore_t;
        SIGNAL task_lockstep_in         : IN STD_LOGIC;
        SIGNAL task_tid_mask_in         : IN tid_mask_t;
        SIGNAL task_iregister_auto_in   : IN iregister_auto_t;
        SIGNAL task_data_model_in       : IN dp_data_model_t;

        SIGNAL busy_out                 : OUT STD_LOGIC_VECTOR(1 downto 0);
        SIGNAL ready_out                : OUT STD_LOGIC
    );
END core;

ARCHITECTURE core_behavior of core IS 

constant cid_gen_max_c:integer:=((pid_gen_max_c+pid_max_c-1)/pid_max_c);

SIGNAL dp_write_vector_r:dp_vector_t;
SIGNAL dp_write_vector_rr:dp_vector_t;
SIGNAL dp_write_vector_rrr:dp_vector_t;
SIGNAL dp_write_vector_rrrr:dp_vector_t;
SIGNAL dp_write_vector_rrrrr:dp_vector_t;

SIGNAL dp_write_scatter_r:scatter_t;
SIGNAL dp_write_scatter_rr:scatter_t;
SIGNAL dp_write_scatter_rrr:scatter_t;
SIGNAL dp_write_scatter_rrrr:scatter_t;
SIGNAL dp_write_scatter_rrrrr:scatter_t;

SIGNAL dp_wr_vm_r:STD_LOGIC;
SIGNAL dp_wr_vm_rr:STD_LOGIC;
SIGNAL dp_wr_vm_rrr:STD_LOGIC;
SIGNAL dp_wr_vm_rrrr:STD_LOGIC;
SIGNAL dp_wr_vm_rrrrr:STD_LOGIC;

SIGNAL dp_code_r:STD_LOGIC;
SIGNAL dp_code_rr:STD_LOGIC;
SIGNAL dp_code_rrr:STD_LOGIC;
SIGNAL dp_code_rrrr:STD_LOGIC;
SIGNAL dp_code_rrrrr:STD_LOGIC;

SIGNAL dp_config_r:STD_LOGIC;
SIGNAL dp_config_rr:STD_LOGIC;
SIGNAL dp_config_rrr:STD_LOGIC;
SIGNAL dp_config_rrrr:STD_LOGIC;
SIGNAL dp_config_rrrrr:STD_LOGIC;

SIGNAL dp_wr_addr_r:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_rr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_rrr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_rrrr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_rrrrr:std_logic_vector(local_bus_width_c-1 downto 0);

SIGNAL dp_wr_addr_step_r:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_step_rr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_step_rrr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_step_rrrr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_step_rrrrr:std_logic_vector(local_bus_width_c-1 downto 0);

SIGNAL dp_wr_share_r:std_logic;
SIGNAL dp_wr_share_rr:std_logic;
SIGNAL dp_wr_share_rrr:std_logic;
SIGNAL dp_wr_share_rrrr:std_logic;
SIGNAL dp_wr_share_rrrrr:std_logic;

SIGNAL dp_write_r:STD_LOGIC;
SIGNAL dp_write_rr:STD_LOGIC;
SIGNAL dp_write_rrr:STD_LOGIC;
SIGNAL dp_write_rrrr:STD_LOGIC;
SIGNAL dp_write_rrrrr:STD_LOGIC;

SIGNAL dp_write_gen_valid_r:STD_LOGIC;
SIGNAL dp_write_gen_valid_rr:STD_LOGIC;
SIGNAL dp_write_gen_valid_rrr:STD_LOGIC;
SIGNAL dp_write_gen_valid_rrrr:STD_LOGIC;
SIGNAL dp_write_gen_valid_rrrrr:STD_LOGIC;

SIGNAL dp_wr_mcast_r:mcast_t:=(others=>'1');
SIGNAL dp_wr_mcast_rr:mcast_t:=(others=>'1');
SIGNAL dp_wr_mcast_rrr:mcast_t:=(others=>'1');
SIGNAL dp_wr_mcast_rrrr:mcast_t:=(others=>'1');
SIGNAL dp_wr_mcast_rrrrr:mcast_t:=(others=>'1');

SIGNAL dp_writedata_r:dp_datax_t;
SIGNAL dp_writedata_rr:dp_datax_t;
SIGNAL dp_writedata_rrr:dp_datax_t;
SIGNAL dp_writedata_rrrr:dp_datax_t;
SIGNAL dp_writedata_rrrrr:dp_datax_t;

SIGNAL writedata2:dp_datax_t;

SIGNAL dp_stream_read_req_r:unsigned(7 downto 0);
SIGNAL dp_stream_read_done_r:unsigned(7 downto 0);

SIGNAL dp_read_vector_r:dp_vector_t;
SIGNAL dp_read_scatter_r:scatter_t;
SIGNAL dp_read_data_flow_r:data_flow_t;
SIGNAL dp_read_data_flow2_r:data_flow_t;
SIGNAL dp_read_data_flow2_rr:data_flow_t;
SIGNAL dp_read_data_flow2_rrr:data_flow_t;
SIGNAL dp_read_data_flow2_rrrr:data_flow_t;
SIGNAL dp_read_data_flow2_rrrrr:data_flow_t;
SIGNAL dp_read_data_type_r:dp_data_type_t;
SIGNAL dp_read_data_type2_r:dp_data_type_t;
SIGNAL dp_read_data_type2_rr:dp_data_type_t;
SIGNAL dp_read_data_type2_rrr:dp_data_type_t;
SIGNAL dp_read_data_type2_rrrr:dp_data_type_t;
SIGNAL dp_read_data_type2_rrrrr:dp_data_type_t;
SIGNAL dp_read_stream_r:STD_LOGIC;
SIGNAL dp_read_stream_id_r:stream_id_t;
SIGNAL dp_read_stream_id2_r:stream_id_t;
SIGNAL dp_rd_vm:STD_LOGIC;
SIGNAL dp_wr_vm:STD_LOGIC;
SIGNAL dp_rd_vm_r:STD_LOGIC;
SIGNAL dp_rd_share:std_logic;
SIGNAL dp_wr_share:std_logic;
SIGNAL dp_rd_addr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_rd_addr_step:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr_step:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_rd_addr2:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_wr_addr2:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL busy:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL ready:STD_LOGIC;
SIGNAL busy_r:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL ready_r:STD_LOGIC;
SIGNAL dp_irec_r:STD_LOGIC;
SIGNAL dp_wr_spe:STD_LOGIC;
SIGNAL dp_wr_pcore_program:STD_LOGIC;
SIGNAL dp_rd_addr_r:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_rd_addr_step_r:std_logic_vector(local_bus_width_c-1 downto 0);
SIGNAL dp_rd_share_r:std_logic;
SIGNAL dp_read_r:STD_LOGIC;
SIGNAL dp_read_gen_valid_r:STD_LOGIC;
SIGNAL dp_rd_page2:page2_t;
SIGNAL dp_wr_page2:page2_t;
SIGNAL writedata:dp_datax_t;
SIGNAL dp_readdatavalid:STD_LOGIC;
SIGNAL dp_readdatavalidv:STD_LOGIC_VECTOR(cid_gen_max_c-1 downto 0);
SIGNAL dp_read_gen_valid:STD_LOGIC;
SIGNAL dp_readdata_vm:STD_LOGIC;
SIGNAL dp_readdata_vm_r:STD_LOGIC;
SIGNAL dp_readdata_vm_rr:STD_LOGIC;
SIGNAL dp_readdata_vm_rrr:STD_LOGIC;
SIGNAL dp_readdata_vm_rrrr:STD_LOGIC;
SIGNAL dp_readdata_vm_rrrrr:STD_LOGIC;
SIGNAL dp_readdata_vm_rrrrrr:STD_LOGIC;
SIGNAL dp_read_data_flow:data_flow_t;
SIGNAL dp_read_data_type:dp_data_type_t;
SIGNAL dp_read_stream:STD_LOGIC;
SIGNAL dp_read_stream_id:stream_id_t;
SIGNAL dp_readdata:dp_datax_t;
SIGNAL dp_readdata2:dp_datax_t;
SIGNAL dp_readdatavalid2_r:STD_LOGIC;
SIGNAL dp_readdatavalid2_rr:STD_LOGIC;
SIGNAL dp_readdatavalid2_rrr:STD_LOGIC;
SIGNAL dp_readdatavalid2_rrrr:STD_LOGIC;
SIGNAL dp_readdatavalid2_rrrrr:STD_LOGIC;
SIGNAL dp_readdatavalid2_rrrrrr:STD_LOGIC;
SIGNAL dp_read_gen_valid2_r:STD_LOGIC;
SIGNAL dp_read_gen_valid2_rr:STD_LOGIC;
SIGNAL dp_read_gen_valid2_rrr:STD_LOGIC;
SIGNAL dp_read_gen_valid2_rrrr:STD_LOGIC;
SIGNAL dp_read_gen_valid2_rrrrr:STD_LOGIC;
SIGNAL dp_read_gen_valid2_rrrrrr:STD_LOGIC;
SIGNAL dp_read_stream2_r:STD_LOGIC;
SIGNAL dp_read_stream2_rr:STD_LOGIC;
SIGNAL dp_read_stream2_rrr:STD_LOGIC;
SIGNAL dp_read_stream2_rrrr:STD_LOGIC;
SIGNAL dp_read_stream2_rrrrr:STD_LOGIC;
SIGNAL dp_read_stream2_rrrrrr:STD_LOGIC;
SIGNAL dp_readdata2_r:dp_datax_t;
SIGNAL dp_readdata2_rr:dp_datax_t;
SIGNAL dp_readdata2_rrr:dp_datax_t;
SIGNAL dp_readdata2_rrrr:dp_datax_t;
SIGNAL dp_readdata2_rrrrr:dp_datax_t;
SIGNAL dp_readdata2_rrrrrr:dp_datax_t;

SIGNAL stream_read_id:stream_id_t;
SIGNAL stream_read_input:dp_datax_t;
SIGNAL stream_read_output:dp_datax_t;

SIGNAL stream_write_id:stream_id_t;
SIGNAL stream_write_input:dp_datax_t;
SIGNAL stream_write_output:dp_datax_t;

SIGNAL dp_read_vector:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vaddr:STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);

--- Stream variables

SIGNAL output:dp_datax_t;
SIGNAL stream_output_r:dp_data_t;

SIGNAL spe_wr:STD_LOGIC;
SIGNAL spe_addr:std_logic_vector(stream_lookup_depth_c-1 downto 0);
SIGNAL spe_data:std_logic_vector(2*register_width_c-1 downto 0);

SIGNAL dp_core_write:STD_LOGIC;
SIGNAL dp_core_write_wait_r:STD_LOGIC;
SIGNAL dp_core_write_wait:STD_LOGIC;
SIGNAL dp_core_read:STD_LOGIC;
SIGNAL dp_core_read_wait_r:STD_LOGIC;

SIGNAL dp_write_stream_r:STD_LOGIC;
SIGNAL dp_write_stream_rr:STD_LOGIC;
SIGNAL dp_write_stream_rrr:STD_LOGIC;
SIGNAL dp_write_stream_rrrr:STD_LOGIC;
SIGNAL dp_write_stream_rrrrr:STD_LOGIC;
SIGNAL dp_write_stream_id_r:stream_id_t;

subtype regno_t is unsigned(register_depth_c-1 downto 0);
constant all_zeros_c:std_logic_vector(ddr_vector_depth_c-1 downto 0):=(others=>'0');

SIGNAL instruction_mu:STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_imu:STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
SIGNAL instruction_mu_valid:STD_LOGIC;
SIGNAL instruction_imu_valid:STD_LOGIC;
SIGNAL vm:STD_LOGIC;
SIGNAL data_model:dp_data_model_t;
SIGNAL enable:STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
SIGNAL tid:tid_t;
SIGNAL tid_valid1:STD_LOGIC;
SIGNAL pre_tid:tid_t;
SIGNAL pre_tid_valid1:STD_LOGIC;
SIGNAL pre_pre_tid:tid_t;
SIGNAL pre_pre_tid_valid1:STD_LOGIC;
SIGNAL pre_pre_vm:STD_LOGIC;
SIGNAL pre_pre_data_model:dp_data_model_t;
SIGNAL pre_iregister_auto:iregister_auto_t;
SIGNAL i_y_neg:STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);
SIGNAL i_y_zero:STD_LOGIC_VECTOR(pid_gen_max_c-1 downto 0);

---
-- Convert from short integer to integer
---

subtype short2int_retval_t is std_logic_vector(register_width_c-1 downto 0);
function short2int(
        short_in:std_logic_vector(data_width_c-1 downto 0)) 
        return short2int_retval_t is
variable int_v:std_logic_vector(register_width_c-1 downto 0);
begin
   int_v(data_width_c-1 downto 0) := short_in;
   int_v(register_width_c-1 downto data_width_c) := (others=>short_in(data_width_c-1));
return int_v;
end function short2int;

---
-- Convert from unsigned short integer to integer
---

subtype ushort2int_retval_t is std_logic_vector(register_width_c-1 downto 0);
function ushort2int(
        ushort_in:std_logic_vector(data_width_c-1 downto 0)) 
        return ushort2int_retval_t is
variable int_v:std_logic_vector(register_width_c-1 downto 0);
begin
   int_v(data_width_c-1 downto 0) := ushort_in;
   int_v(register_width_c-1 downto data_width_c) := (others=>'0');
   return int_v;
end function ushort2int;

---
-- Convert from integer to short integer
----

subtype int2short_retval_t is std_logic_vector(data_width_c-1 downto 0);
function int2short(
        int_in:std_logic_vector(register_width_c-1 downto 0)) 
        return int2short_retval_t is
variable short_v:std_logic_vector(data_width_c-1 downto 0);
begin
   short_v := int_in(data_width_c-1 downto 0);
   return short_v;
end function int2short;

begin

spe_wr <= dp_write_in and dp_wr_spe;
spe_addr <= dp_wr_addr2(stream_lookup_depth_c downto 1);
spe_data <= dp_writedata_in(register_width_c+data_width_c*2-1 downto data_width_c*2) & dp_writedata_in(register_width_c-1 downto 0);

stream_read_id <= dp_read_stream_id2_r;
stream_write_id <= dp_write_stream_id_r;

stream_read_input <= dp_readdata2_r; -- Stream processor only works with single CID access only
stream_write_input <= dp_writedata_r; -- Stream processor only works with single CID access only

--
-- Instantiate array of stream processors for data read from PCORE array
-- There is one stream processor per vector lane
---

GEN_STREAM:
FOR I in 0 to ddr_vector_width_c-1 GENERATE
stream_i: stream
   PORT MAP(clock_in =>clock_in,
            reset_in =>reset_in,
            stream_id_in => stream_read_id,
            input_in => stream_read_input((I+1)*register_width_c-1 downto I*register_width_c),
            output_out =>stream_read_output((I+1)*register_width_c-1 downto I*register_width_c),
            config_in => spe_wr,
            config_reg_in => spe_addr,
            config_data_in => spe_data
           );
END GENERATE GEN_STREAM;
--stream_read_output <= (others=>'0');


--
-- Instantiate array of stream processors for data write to PCORE array
-- There is one stream processor per vector lane
---

GEN_STREAM_1:
FOR I in 0 to ddr_vector_width_c-1 GENERATE
stream_i1: stream
   PORT MAP(clock_in =>clock_in,
            reset_in =>reset_in,
            stream_id_in => stream_write_id,
            input_in => stream_write_input((I+1)*register_width_c-1 downto I*register_width_c),
            output_out =>stream_write_output((I+1)*register_width_c-1 downto I*register_width_c),
            config_in => spe_wr,
            config_reg_in => spe_addr,
            config_data_in => spe_data
           );
END GENERATE GEN_STREAM_1;
--stream_write_output <= (others=>'0');

------
-- Combine all process busy signals from all the cells
------

process(dp_readdatavalidv)
variable valid_v:STD_LOGIC;
begin
   valid_v := '0';
   for I in 0 to cid_gen_max_c-1 loop
      valid_v := valid_v or dp_readdatavalidv(I);
   end loop;
   dp_readdatavalid <= valid_v;
end process;

dp_rd_addr2 <= dp_rd_addr_in;
dp_wr_addr2 <= dp_wr_addr_in;

dp_write_wait_out <= task_in or dp_core_write_wait;
dp_read_wait_out <= dp_core_read_wait_r;

busy_out <= busy_r;
ready_out <= ready_r;

dp_readdatavalid_out <= dp_readdatavalid2_rrrrrr;
dp_read_gen_valid_out <= dp_read_gen_valid2_rrrrrr;
dp_readdata_vm_out <= dp_readdata_vm_rrrrrr;

dp_readdata_out(ddr_data_width_c-1 DOWNTO 0) <= stream_output_r;

output <= stream_read_output when dp_read_stream2_rrrrr='1' else dp_readdata2_rrrrr;

dp_core_write_wait <= '1' when (dp_core_write_wait_r='1' or ((dp_stream_read_req_r /= dp_stream_read_done_r) and dp_write_stream_in='1')) else '0';
dp_core_write <= dp_write_in and (not dp_wr_spe) and (not dp_core_write_wait);
dp_core_read <= dp_read_in and (not dp_core_read_wait_r);

--
-- Do data format conversion for stream output
----

process(reset_in,clock_in)
begin
    if reset_in = '0' then
       stream_output_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            if dp_read_data_flow2_rrrrr=std_logic_vector(to_unsigned(data_flow_direct_c,data_flow_t'length)) then
               for I in 0 to ddr_vector_width_c-1 loop
                  stream_output_r((I+1)*data_width_c-1 downto I*data_width_c) <= int2short(output((I+1)*register_width_c-1 downto I*register_width_c));
               end loop;
            else
               for I in 0 to ddr_vector_width_c/2-1 loop
                  stream_output_r((2*I+2)*data_width_c-1 downto (2*I+0)*data_width_c) <= std_logic_vector(resize(signed(output((I+1)*register_width_c-1 downto (I+0)*register_width_c)),data_width_c*2));
               end loop;
            end if;
      end if;
   end if;
end process;

process(dp_read_vector,dp_read_vaddr,dp_readdata)
begin
if unsigned(dp_read_vector)=to_unsigned(vector_width_c/2-1,dp_read_vector'length) then
   case dp_read_vaddr(vector_depth_c-1 downto 2) is
      when "0"=>
         dp_readdata2(4*register_width_c-1 downto 0) <= dp_readdata(4*register_width_c-1 downto 0*register_width_c);
      when others=>
         dp_readdata2(4*register_width_c-1 downto 0) <= dp_readdata(8*register_width_c-1 downto 4*register_width_c);
   end case;
   dp_readdata2(dp_readdata2'length-1 downto 4*register_width_c) <= (others=>'0');
elsif unsigned(dp_read_vector)=to_unsigned(vector_width_c/4-1,dp_read_vector'length) then
   case dp_read_vaddr(vector_depth_c-1 downto 1) is
      when "00"=>
         dp_readdata2(2*register_width_c-1 downto 0) <= dp_readdata(2*register_width_c-1 downto 0*register_width_c);
      when "01"=>
         dp_readdata2(2*register_width_c-1 downto 0) <= dp_readdata(4*register_width_c-1 downto 2*register_width_c);
      when "10"=>
         dp_readdata2(2*register_width_c-1 downto 0) <= dp_readdata(6*register_width_c-1 downto 4*register_width_c);
      when others=>
         dp_readdata2(2*register_width_c-1 downto 0) <= dp_readdata(8*register_width_c-1 downto 6*register_width_c);
   end case;
   dp_readdata2(dp_readdata2'length-1 downto 2*register_width_c) <= (others=>'0');
else
   dp_readdata2 <= dp_readdata;
end if;
end process;


process(reset_in,clock_in)
begin
    if reset_in = '0' then
       dp_readdatavalid2_r <= '0';
       dp_readdatavalid2_rr <= '0';
       dp_readdatavalid2_rrr <= '0';
       dp_readdatavalid2_rrrr <= '0';
       dp_readdatavalid2_rrrrr <= '0';
       dp_readdatavalid2_rrrrrr <= '0';

       dp_read_gen_valid2_r <= '0';
       dp_read_gen_valid2_rr <= '0';
       dp_read_gen_valid2_rrr <= '0';
       dp_read_gen_valid2_rrrr <= '0';
       dp_read_gen_valid2_rrrrr <= '0';
       dp_read_gen_valid2_rrrrrr <= '0';

       dp_read_stream2_r <= '0';
       dp_read_stream2_rr <= '0';
       dp_read_stream2_rrr <= '0';
       dp_read_stream2_rrrr <= '0';
       dp_read_stream2_rrrrr <= '0';
       dp_read_stream2_rrrrrr <= '0';

       dp_readdata2_r <= (others=>'0');
       dp_readdata2_rr <= (others=>'0');
       dp_readdata2_rrr <= (others=>'0');
       dp_readdata2_rrrr <= (others=>'0');
       dp_readdata2_rrrrr <= (others=>'0');
       dp_readdata2_rrrrrr <= (others=>'0');

       dp_readdata_vm_r <= '0';
       dp_readdata_vm_rr <= '0';
       dp_readdata_vm_rrr <= '0';
       dp_readdata_vm_rrrr <= '0';
       dp_readdata_vm_rrrrr <= '0';
       dp_readdata_vm_rrrrrr <= '0';

       dp_read_stream_id2_r <= (others=>'0');
       dp_stream_read_done_r <= (others=>'0');
    else
       if clock_in'event and clock_in='1' then
          if dp_readdatavalid='1' and dp_read_gen_valid='1' then
             dp_read_stream2_r <= dp_read_stream;
          else
             dp_read_stream2_r <= '0';
          end if;
          dp_read_stream_id2_r <= dp_read_stream_id;

          if dp_read_stream2_r='1' then
             dp_stream_read_done_r <= dp_stream_read_done_r+1;
          end if;

          dp_readdatavalid2_r        <= dp_readdatavalid;
          dp_readdatavalid2_rr       <= dp_readdatavalid2_r;
          dp_readdatavalid2_rrr      <= dp_readdatavalid2_rr;
          dp_readdatavalid2_rrrr     <= dp_readdatavalid2_rrr;
          dp_readdatavalid2_rrrrr    <= dp_readdatavalid2_rrrr;
          dp_readdatavalid2_rrrrrr    <= dp_readdatavalid2_rrrrr;

          dp_read_gen_valid2_r        <= dp_read_gen_valid;
          dp_read_gen_valid2_rr       <= dp_read_gen_valid2_r;
          dp_read_gen_valid2_rrr      <= dp_read_gen_valid2_rr;
          dp_read_gen_valid2_rrrr     <= dp_read_gen_valid2_rrr;
          dp_read_gen_valid2_rrrrr    <= dp_read_gen_valid2_rrrr;
          dp_read_gen_valid2_rrrrrr   <= dp_read_gen_valid2_rrrrr;

          dp_readdata_vm_r        <= dp_readdata_vm;
          dp_readdata_vm_rr       <= dp_readdata_vm_r;
          dp_readdata_vm_rrr      <= dp_readdata_vm_rr;
          dp_readdata_vm_rrrr     <= dp_readdata_vm_rrr;
          dp_readdata_vm_rrrrr    <= dp_readdata_vm_rrrr;
          dp_readdata_vm_rrrrrr   <= dp_readdata_vm_rrrrr;

          dp_read_stream2_rr          <= dp_read_stream2_r;
          dp_read_stream2_rrr         <= dp_read_stream2_rr;
          dp_read_stream2_rrrr        <= dp_read_stream2_rrr;
          dp_read_stream2_rrrrr       <= dp_read_stream2_rrrr;
          dp_read_stream2_rrrrrr       <= dp_read_stream2_rrrrr;

          dp_readdata2_r           <= dp_readdata2;     
          dp_readdata2_rr          <= dp_readdata2_r;
          dp_readdata2_rrr         <= dp_readdata2_rr;
          dp_readdata2_rrrr        <= dp_readdata2_rrr;
          dp_readdata2_rrrrr       <= dp_readdata2_rrrr;
          dp_readdata2_rrrrrr       <= dp_readdata2_rrrrr;

       end if;
    end if;
end process;

--
-- Do data formatting for data input to stream processors
---

process(dp_write_data_flow_in,dp_writedata_in,dp_write_data_type_in)
begin
if dp_write_data_flow_in=std_logic_vector(to_unsigned(data_flow_direct_c,data_flow_t'length)) then
   -- Each 8-bit data lane from DP bus is sent to a data lane in PCORE
   if dp_write_data_type_in=dp_data_type_integer_c then
      for I in 0 to ddr_vector_width_c-1 loop
         writedata((I+1)*register_width_c-1 downto I*register_width_c) <= short2int(dp_writedata_in((I+1)*data_width_c-1 downto I*data_width_c));
      end loop;
   else
      for I in 0 to ddr_vector_width_c-1 loop
         writedata((I+1)*register_width_c-1 downto I*register_width_c) <= ushort2int(dp_writedata_in((I+1)*data_width_c-1 downto I*data_width_c));
      end loop;
   end if;
else
  -- Each 16-bit data lane from DP bus is sent to a data lane in PCORE
  for I in 0 to ddr_vector_width_c/2-1 loop
     writedata((I+1)*register_width_c-1 downto I*register_width_c) <= std_logic_vector(resize(signed(dp_writedata_in((2*I+2)*data_width_c-1 downto (2*I+0)*data_width_c)),register_width_c));
  end loop;
  for I in ddr_vector_width_c/2 to ddr_vector_width_c-1 loop
     writedata((I+1)*register_width_c-1 downto I*register_width_c) <= (others=>'0');
  end loop;
end if;
end process;

--------
--- Latch in memory access
--- We need to latch to improve routability at the expense of increased bus access latency
--------

process(clock_in,reset_in)
variable pos_v:integer;
begin
    if reset_in = '0' then
        busy_r <= (others=>'0');
        ready_r <= '0';
        dp_rd_vm_r <= '0';
        dp_rd_addr_r <= (others=>'0');
        dp_rd_addr_step_r <= (others=>'0');
        dp_rd_share_r <= '0';
        dp_read_r <= '0';
        dp_read_gen_valid_r <= '0';
        dp_read_data_flow_r <= (others=>'0');
        dp_read_data_flow2_r <= (others=>'0');
        dp_read_data_flow2_rr <= (others=>'0');
        dp_read_data_flow2_rrr <= (others=>'0');
        dp_read_data_flow2_rrrr <= (others=>'0');
        dp_read_data_flow2_rrrrr <= (others=>'0');
        dp_read_data_type_r <= (others=>'0');
        dp_read_data_type2_r <= (others=>'0');
        dp_read_data_type2_rr <= (others=>'0');
        dp_read_data_type2_rrr <= (others=>'0');
        dp_read_data_type2_rrrr <= (others=>'0');
        dp_read_data_type2_rrrrr <= (others=>'0');
        dp_read_stream_r <= '0';
        dp_read_stream_id_r <= (others=>'0');
        dp_read_vector_r <= (others=>'0');
        dp_read_scatter_r <= (others=>'0');
        dp_write_stream_id_r <= (others=>'0');

        dp_write_stream_r <= '0';
        dp_write_stream_rr <= '0';
        dp_write_stream_rrr <= '0';
        dp_write_stream_rrrr <= '0';
        dp_write_stream_rrrrr <= '0';

        dp_wr_vm_r <= '0';
        dp_wr_vm_rr <= '0';
        dp_wr_vm_rrr <= '0';
        dp_wr_vm_rrrr <= '0';
        dp_wr_vm_rrrrr <= '0';

        dp_code_r <= '0';
        dp_code_rr <= '0';
        dp_code_rrr <= '0';
        dp_code_rrrr <= '0';
        dp_code_rrrrr <= '0';

        dp_wr_addr_r <= (others=>'0');
        dp_wr_addr_rr <= (others=>'0');
        dp_wr_addr_rrr <= (others=>'0');
        dp_wr_addr_rrrr <= (others=>'0');
        dp_wr_addr_rrrrr <= (others=>'0');

        dp_wr_addr_step_r <= (others=>'0');
        dp_wr_addr_step_rr <= (others=>'0');
        dp_wr_addr_step_rrr <= (others=>'0');
        dp_wr_addr_step_rrrr <= (others=>'0');
        dp_wr_addr_step_rrrrr <= (others=>'0');

        dp_wr_share_r <= '0';
        dp_wr_share_rr <= '0';
        dp_wr_share_rrr <= '0';
        dp_wr_share_rrrr <= '0';
        dp_wr_share_rrrrr <= '0';

        dp_wr_mcast_r <= (others=>'1');
        dp_wr_mcast_rr <= (others=>'1');
        dp_wr_mcast_rrr <= (others=>'1');
        dp_wr_mcast_rrrr <= (others=>'1');
        dp_wr_mcast_rrrrr <= (others=>'1');

        dp_write_r <= '0';
        dp_write_rr <= '0';
        dp_write_rrr <= '0';
        dp_write_rrrr <= '0';
        dp_write_rrrrr <= '0';

        dp_write_vector_r <= (others=>'0');
        dp_write_vector_rr <= (others=>'0');
        dp_write_vector_rrr <= (others=>'0');
        dp_write_vector_rrrr <= (others=>'0');
        dp_write_vector_rrrrr <= (others=>'0');

        dp_write_scatter_r <= (others=>'0');
        dp_write_scatter_rr <= (others=>'0');
        dp_write_scatter_rrr <= (others=>'0');
        dp_write_scatter_rrrr <= (others=>'0');
        dp_write_scatter_rrrrr <= (others=>'0');

        dp_writedata_r <= (others=>'0');
        dp_writedata_rr <= (others=>'0');
        dp_writedata_rrr <= (others=>'0');
        dp_writedata_rrrr <= (others=>'0');
        dp_writedata_rrrrr <= (others=>'0');

        dp_write_gen_valid_r <= '0';
        dp_write_gen_valid_rr <= '0';
        dp_write_gen_valid_rrr <= '0';
        dp_write_gen_valid_rrrr <= '0';
        dp_write_gen_valid_rrrrr <= '0';

        dp_config_r <= '0';
        dp_config_rr <= '0';
        dp_config_rrr <= '0';
        dp_config_rrrr <= '0';
        dp_config_rrrrr <= '0';

        dp_stream_read_req_r <= (others=>'0');
        
        dp_core_write_wait_r <= '0';
        dp_core_read_wait_r <= '0';
     else
        if clock_in'event and clock_in='1' then
            busy_r <= busy;
            ready_r <= ready;

            dp_rd_vm_r <= dp_rd_vm;
            dp_rd_addr_r <= dp_rd_addr;
            dp_rd_addr_step_r <= dp_rd_addr_step;
            dp_rd_share_r <= dp_rd_share;
            
            if (pid_gen_max_c < vector_width_c) and dp_core_read='1' and dp_read_scatter_in/=scatter_none_c then
               dp_core_read_wait_r <= '1';
            else
               dp_core_read_wait_r <= '0';
            end if;
            if dp_core_read='1' and dp_read_stream_in='1' then
               dp_stream_read_req_r <=  dp_stream_read_req_r+1;
            end if;

            dp_read_r <= dp_core_read;
            dp_read_gen_valid_r <= dp_read_gen_valid_in;
            dp_read_vector_r <= dp_read_vector_in;
            dp_read_scatter_r <= dp_read_scatter_in;
            dp_read_data_flow_r <= dp_read_data_flow_in;
            dp_read_data_type_r <= dp_read_data_type_in;

            dp_read_data_flow2_r <= dp_read_data_flow;
            dp_read_data_flow2_rr <= dp_read_data_flow2_r;
            dp_read_data_flow2_rrr <= dp_read_data_flow2_rr;
            dp_read_data_flow2_rrrr <= dp_read_data_flow2_rrr;
            dp_read_data_flow2_rrrrr <= dp_read_data_flow2_rrrr;

            dp_read_data_type2_r <= dp_read_data_type;
            dp_read_data_type2_rr <= dp_read_data_type2_r;
            dp_read_data_type2_rrr <= dp_read_data_type2_rr;
            dp_read_data_type2_rrrr <= dp_read_data_type2_rrr;
            dp_read_data_type2_rrrrr <= dp_read_data_type2_rrrr;

            dp_read_stream_r <= dp_read_stream_in;
            dp_read_stream_id_r <= dp_read_stream_id_in;

            if task_in='1' then
                dp_core_write_wait_r <= '0';
                dp_write_r <= '1';
                dp_wr_share_r <= '0';
                dp_write_gen_valid_r <= '0';
                if task_vm_in='0' then
                    dp_wr_addr_r(dp_config_reg_t'length-1 downto 0) <= std_logic_vector(dp_config_reg_exe_vm1_c);
                else
                    dp_wr_addr_r(dp_config_reg_t'length-1 downto 0) <= std_logic_vector(dp_config_reg_exe_vm2_c);
                end if;
                pos_v := 0;
                dp_writedata_r(pos_v+task_start_addr_in'length-1 downto pos_v) <= task_start_addr_in;
                pos_v := pos_v+task_start_addr_in'length;
                dp_writedata_r(pos_v+pcore_t'length-1 downto pos_v) <= std_logic_vector(task_pcore_in);
                pos_v := pos_v+pcore_t'length;
                dp_writedata_r(pos_v) <= task_lockstep_in;
                pos_v := pos_v+1;
                dp_writedata_r(pos_v+task_tid_mask_in'length-1 downto pos_v) <= std_logic_vector(task_tid_mask_in);
                pos_v := pos_v+task_tid_mask_in'length;
                dp_writedata_r(pos_v+iregister_auto_t'length-1 downto pos_v) <= std_logic_vector(task_iregister_auto_in);
                pos_v := pos_v+iregister_auto_t'length;
                dp_writedata_r(pos_v+task_data_model_in'length-1 downto pos_v) <= std_logic_vector(task_data_model_in);
                pos_v := pos_v+task_data_model_in'length;
                dp_writedata_r(dp_writedata_r'length-1 downto pos_v) <= (others=>'0');

                dp_code_r <= '0';
                dp_config_r <= '1';
                dp_wr_mcast_r <= (others=>'1');
                dp_wr_vm_r <= '0';
                dp_write_vector_r <= (others=>'0');
                dp_write_scatter_r <= (others=>'0');
                dp_write_stream_r <= '0';
                dp_write_stream_id_r <= (others=>'0');
            elsif dp_write_in='1' and dp_wr_pcore_program='1' then
                dp_core_write_wait_r <= '0';
                dp_write_r <= '1';
                dp_write_gen_valid_r <= '0';
                dp_wr_addr_r(instruction_depth_c-1 downto 0) <= dp_wr_addr_in(instruction_depth_c+1 downto 2);
                dp_wr_addr_r(dp_wr_addr_r'length-1 downto instruction_depth_c) <= (others=>'0');
                dp_writedata_r(host_width_c-1 downto 0) <= dp_writedata_in(2*host_width_c-1 downto host_width_c);
                dp_writedata_r(2*host_width_c-1 downto host_width_c) <= dp_writedata_in(host_width_c-1 downto 0);
                dp_wr_share_r <= '0';
                dp_code_r <= '1';
                dp_config_r <= '0';
                dp_wr_mcast_r <= (others=>'1');
                dp_wr_vm_r <= '0';
                dp_write_vector_r <= (others=>'0');
                dp_write_scatter_r <= (others=>'0');
                dp_write_stream_r <= '0';
                dp_write_stream_id_r <= (others=>'0');
            else
                if (pid_gen_max_c < vector_width_c) and dp_core_write='1' and dp_write_scatter_in/=scatter_none_c then
                  dp_core_write_wait_r <= '1';
                else
                  dp_core_write_wait_r <= '0';
                end if;
                dp_write_r <= dp_core_write;
                dp_write_gen_valid_r <= dp_write_gen_valid_in;
                dp_wr_addr_r <= dp_wr_addr;
                dp_wr_addr_step_r <= dp_wr_addr_step;
                dp_wr_share_r <= dp_wr_share;
                if unsigned(dp_write_vector_in)=to_unsigned(vector_width_c/8-1,dp_write_vector_in'length) then
                   dp_writedata_r <= writedata(register_width_c-1 downto 0) & 
                                     writedata(register_width_c-1 downto 0) & 
                                     writedata(register_width_c-1 downto 0) & 
                                     writedata(register_width_c-1 downto 0) & 
                                     writedata(register_width_c-1 downto 0) & 
                                     writedata(register_width_c-1 downto 0) & 
                                     writedata(register_width_c-1 downto 0) & 
                                     writedata(register_width_c-1 downto 0);
                elsif unsigned(dp_write_vector_in)=to_unsigned(vector_width_c/4-1,dp_write_vector_in'length) then
                   dp_writedata_r <= writedata(2*register_width_c-1 downto 0) & 
                                     writedata(2*register_width_c-1 downto 0) & 
                                     writedata(2*register_width_c-1 downto 0) & 
                                     writedata(2*register_width_c-1 downto 0);
                elsif unsigned(dp_write_vector_in)=to_unsigned(vector_width_c/2-1,dp_write_vector_in'length) then
                   dp_writedata_r <= writedata(4*register_width_c-1 downto 0) & 
                                     writedata(4*register_width_c-1 downto 0); 
                else
                   dp_writedata_r <= writedata;
                end if;
                dp_code_r <= '0';
                dp_config_r <= '0';
                dp_wr_mcast_r <= dp_wr_mcast_in;
                dp_wr_vm_r <= dp_wr_vm;
                dp_write_vector_r <= dp_write_vector_in;
                dp_write_scatter_r <= dp_write_scatter_in;
                dp_write_stream_r <= dp_write_stream_in;
                dp_write_stream_id_r <= dp_write_stream_id_in;
            end if;
        
            dp_write_stream_rr <= dp_write_stream_r;
            dp_write_stream_rrr <= dp_write_stream_rr;
            dp_write_stream_rrrr <= dp_write_stream_rrr;
            dp_write_stream_rrrrr <= dp_write_stream_rrrr;

            dp_wr_vm_rr <= dp_wr_vm_r;
            dp_wr_vm_rrr <= dp_wr_vm_rr;
            dp_wr_vm_rrrr <= dp_wr_vm_rrr;
            dp_wr_vm_rrrrr <= dp_wr_vm_rrrr;

            dp_code_rr <= dp_code_r;
            dp_code_rrr <= dp_code_rr;
            dp_code_rrrr <= dp_code_rrr;
            dp_code_rrrrr <= dp_code_rrrr;

            dp_wr_addr_rr <= dp_wr_addr_r;
            dp_wr_addr_rrr <= dp_wr_addr_rr;
            dp_wr_addr_rrrr <= dp_wr_addr_rrr;
            dp_wr_addr_rrrrr <= dp_wr_addr_rrrr;

            dp_wr_addr_step_rr <= dp_wr_addr_step_r;
            dp_wr_addr_step_rrr <= dp_wr_addr_step_rr;
            dp_wr_addr_step_rrrr <= dp_wr_addr_step_rrr;
            dp_wr_addr_step_rrrrr <= dp_wr_addr_step_rrrr;

            dp_wr_share_rr <= dp_wr_share_r;
            dp_wr_share_rrr <= dp_wr_share_rr;
            dp_wr_share_rrrr <= dp_wr_share_rrr;
            dp_wr_share_rrrrr <= dp_wr_share_rrrr;

            dp_wr_mcast_rr <= dp_wr_mcast_r;
            dp_wr_mcast_rrr <= dp_wr_mcast_rr;
            dp_wr_mcast_rrrr <= dp_wr_mcast_rrr;
            dp_wr_mcast_rrrrr <= dp_wr_mcast_rrrr;

            dp_write_rr <= dp_write_r;
            dp_write_rrr <= dp_write_rr;
            dp_write_rrrr <= dp_write_rrr;
            dp_write_rrrrr <= dp_write_rrrr;

            dp_write_gen_valid_rr <= dp_write_gen_valid_r;
            dp_write_gen_valid_rrr <= dp_write_gen_valid_rr;
            dp_write_gen_valid_rrrr <= dp_write_gen_valid_rrr;
            dp_write_gen_valid_rrrrr <= dp_write_gen_valid_rrrr;

            dp_write_vector_rr <= dp_write_vector_r;
            dp_write_vector_rrr <= dp_write_vector_rr;
            dp_write_vector_rrrr <= dp_write_vector_rrr;
            dp_write_vector_rrrrr <= dp_write_vector_rrrr;

            dp_write_scatter_rr <= dp_write_scatter_r;
            dp_write_scatter_rrr <= dp_write_scatter_rr;
            dp_write_scatter_rrrr <= dp_write_scatter_rrr;
            dp_write_scatter_rrrrr <= dp_write_scatter_rrrr;

            dp_writedata_rr <= dp_writedata_r;
            dp_writedata_rrr <= dp_writedata_rr;
            dp_writedata_rrrr <= dp_writedata_rrr;
            dp_writedata_rrrrr <= dp_writedata_rrrr;

            dp_config_rr <= dp_config_r;
            dp_config_rrr <= dp_config_rr;
            dp_config_rrrr <= dp_config_rrr;
            dp_config_rrrrr <= dp_config_rrrr;
		end if;
    end if;
end process;

-------
-- Translate address and convert to direct format
-------

dp_rd_page2 <= unsigned(dp_rd_addr2(local_bus_width_c-2 downto local_bus_width_c-page2_t'length-1));

dp_wr_page2 <= unsigned(dp_wr_addr2(local_bus_width_c-2 downto local_bus_width_c-page2_t'length-1));

dp_rd_share <= '0' when (dp_rd_page2=page2_register_c) else '1';

dp_wr_spe <= '1' when (dp_wr_page2=page2_spe_register_c) else '0';

dp_wr_pcore_program <= '1' when (dp_wr_page2=page2_pcore_program_c) else '0';

dp_wr_share <= '0' when (dp_wr_page2=page2_register_c) else '1';

dp_rd_vm <= dp_rd_addr2(local_bus_width_c-1);

dp_wr_vm <= dp_wr_addr2(local_bus_width_c-1);

--
-- Write address calculation
----

process(dp_wr_addr2,dp_wr_page2,dp_write_data_model_in)
begin
if (dp_wr_page2=page2_register_c) then
   if dp_write_data_model_in="00" then
      dp_wr_addr <= dp_wr_addr2(local_bus_width_c-1 downto register_depth_c+tid_t'length) & 
                    dp_wr_addr2(register_depth_c-1 downto vector_depth_c) & 
                    dp_wr_addr2(register_depth_c+tid_t'length-1 downto register_depth_c) & 
                    dp_wr_addr2(vector_depth_c-1 downto 0);
      dp_wr_addr_step <= std_logic_vector(to_unsigned(vector_width_c*tid_max_c,dp_wr_addr_step'length));
   else
      dp_wr_addr <= dp_wr_addr2(local_bus_width_c-1 downto register_depth_c+tid_t'length) & 
                    "0" & 
                    dp_wr_addr2(register_depth_c-1 downto vector_depth_c) & 
                    dp_wr_addr2(register_depth_c+tid_t'length-1-1 downto register_depth_c) & 
                    dp_wr_addr2(vector_depth_c-1 downto 0);
      dp_wr_addr_step <= std_logic_vector(to_unsigned(vector_width_c*(tid_max_c/2),dp_wr_addr_step'length));
   end if;
else
   dp_wr_addr <= dp_wr_addr2(local_bus_width_c-1 downto register_depth_c+tid_t'length) & 
                (not dp_wr_addr2(register_depth_c+tid_t'length-1 downto vector_depth_c)) & 
                 dp_wr_addr2(vector_depth_c-1 downto 0);
   dp_wr_addr_step <= (others=>'0');
end if;
end process;

---
-- Read address calculation
---

process(dp_rd_addr2,dp_rd_page2,dp_read_data_model_in)
begin
if (dp_rd_page2=page2_register_c) then
   if dp_read_data_model_in="00" then
      dp_rd_addr <= dp_rd_addr2(local_bus_width_c-1 downto register_depth_c+tid_t'length) & 
                    dp_rd_addr2(register_depth_c-1 downto vector_depth_c) & 
                    dp_rd_addr2(register_depth_c+tid_t'length-1 downto register_depth_c) & 
                    dp_rd_addr2(vector_depth_c-1 downto 0);
      dp_rd_addr_step <= std_logic_vector(to_unsigned(vector_width_c*tid_max_c,dp_rd_addr_step'length));
   else
      dp_rd_addr <= dp_rd_addr2(local_bus_width_c-1 downto register_depth_c+tid_t'length) & 
                    "0" & 
                    dp_rd_addr2(register_depth_c-1 downto vector_depth_c) &
                    dp_rd_addr2(register_depth_c+tid_t'length-1-1 downto register_depth_c) & 
                    dp_rd_addr2(vector_depth_c-1 downto 0);
      dp_rd_addr_step <= std_logic_vector(to_unsigned(vector_width_c*(tid_max_c/2),dp_rd_addr_step'length));
   end if;
else
   dp_rd_addr <= dp_rd_addr2(local_bus_width_c-1 downto register_depth_c+tid_t'length) & 
                 (not dp_rd_addr2(register_depth_c+tid_t'length-1 downto vector_depth_c)) & 
   dp_rd_addr2(vector_depth_c-1 downto 0);
   dp_rd_addr_step <= (others=>'0');
end if;
end process;

---
-- Instantiate instruction fetcher/decoder
----

instr_i: instr
    port map(   
            clock_in => clock_in,
            reset_in => reset_in,
   
            -- DP interface
   
            dp_code_in => dp_code_r,
            dp_config_in => dp_config_r,
            dp_wr_addr_in => dp_wr_addr_r,  
            dp_write_in => dp_write_r,
            dp_writedata_in => dp_writedata_r,
   
            -- Busy status
   
            busy_out => busy,
            ready_out => ready,

            -- Instruction interface
            instruction_mu_out => instruction_mu,
            instruction_imu_out => instruction_imu,
            instruction_mu_valid_out => instruction_mu_valid,
            instruction_imu_valid_out => instruction_imu_valid,
            vm_out => vm,
            data_model_out => data_model,
            enable_out => enable,
            tid_out => tid,
            tid_valid1_out => tid_valid1,
            pre_tid_out  => pre_tid,
            pre_tid_valid1_out => pre_tid_valid1,
            pre_pre_tid_out => pre_pre_tid,
            pre_pre_tid_valid1_out => pre_pre_tid_valid1,
            pre_pre_vm_out => pre_pre_vm,
            pre_pre_data_model_out => pre_pre_data_model,
            pre_iregister_auto_out => pre_iregister_auto,
            i_y_neg_in  => i_y_neg,
            i_y_zero_in => i_y_zero
            );


writedata2 <= dp_writedata_rrrrr when dp_write_stream_rrrrr='0' else stream_write_output;

---
-- Instantiate array of PCOREs
----

GEN_CELL:
FOR I IN 0 TO cid_gen_max_c-1 GENERATE
cell_i: cell
    generic map(
            CID => I
            )
    port map(    
            clock_in => clock_in,
            clock_x2_in => clock_X2_in,
            reset_in => reset_in,

            dp_rd_vm_in => dp_rd_vm_r,
            dp_wr_vm_in => dp_wr_vm_rrrrr,
            dp_code_in => dp_code_rrrrr,
            dp_rd_addr_in => dp_rd_addr_r,
            dp_rd_addr_step_in => dp_rd_addr_step_r,
            dp_rd_fork_in => '0',
            dp_rd_share_in => dp_rd_share_r,
            dp_wr_addr_in => dp_wr_addr_rrrrr,
            dp_wr_addr_step_in => dp_wr_addr_step_rrrrr,
            dp_wr_fork_in => '0',
            dp_wr_share_in => dp_wr_share_rrrrr,
            dp_wr_mcast_in => dp_wr_mcast_rrrrr,
            dp_write_in => dp_write_rrrrr,
            dp_write_gen_valid_in => dp_write_gen_valid_rrrrr,
            dp_write_vector_in => dp_write_vector_rrrrr,
            dp_write_scatter_in => dp_write_scatter_rrrrr,
            dp_read_in => dp_read_r,
            dp_read_gen_valid_in => dp_read_gen_valid_r,
            dp_read_data_flow_in => dp_read_data_flow_r,
            dp_read_data_type_in => dp_read_data_type_r,
            dp_read_vector_in => dp_read_vector_r,
            dp_read_scatter_in => dp_read_scatter_r,
            dp_read_stream_in => dp_read_stream_r,
            dp_read_stream_id_in => dp_read_stream_id_r,
            dp_writedata_in => writedata2,
            dp_readdata_out => dp_readdata,
            dp_readdata_vm_out=>dp_readdata_vm,
            dp_read_vector_out => dp_read_vector,
            dp_read_vaddr_out => dp_read_vaddr,
            dp_readdata_valid_out => dp_readdatavalidv(I),
            dp_read_gen_valid_out => dp_read_gen_valid,
            dp_read_data_flow_out=> dp_read_data_flow,
            dp_read_data_type_out=> dp_read_data_type,
            dp_read_stream_out=>dp_read_stream,
            dp_read_stream_id_out=>dp_read_stream_id,
            dp_config_in => dp_config_rrrrr,

            -- Instruction interface

            instruction_mu_in => instruction_mu,
            instruction_imu_in => instruction_imu,
            instruction_mu_valid_in => instruction_mu_valid,
            instruction_imu_valid_in => instruction_imu_valid,
            vm_in => vm,
            data_model_in => data_model,
            enable_in => enable((I+1)*pid_max_c-1 downto (I*pid_max_c)),
            tid_in => tid,
            tid_valid1_in => tid_valid1,
            pre_tid_in  => pre_tid,
            pre_tid_valid1_in => pre_tid_valid1,
            pre_pre_tid_in => pre_pre_tid,
            pre_pre_tid_valid1_in => pre_pre_tid_valid1,
            pre_pre_vm_in => pre_pre_vm,
            pre_pre_data_model_in => pre_pre_data_model,
            pre_iregister_auto_in => pre_iregister_auto,
            i_y_neg_out  => i_y_neg((I+1)*pid_max_c-1 downto (I*pid_max_c)),
            i_y_zero_out => i_y_zero((I+1)*pid_max_c-1 downto (I*pid_max_c))

            );
END GENERATE GEN_CELL;


END core_behavior;
