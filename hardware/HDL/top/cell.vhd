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

------
-- A cell contains 4 pcores
------

library std;
use std.standard.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
--library output_files;
use work.config.all;
use work.hpc_pkg.all;


ENTITY cell IS
    generic (
        CID:integer
        );
    port(   clock_in                        : IN STD_LOGIC;
            reset_in                        : IN STD_LOGIC;
            -- DP interface
            SIGNAL dp_rd_vm_in              : IN STD_LOGIC;
            SIGNAL dp_wr_vm_in              : IN STD_LOGIC;
            SIGNAL dp_code_in               : IN STD_LOGIC;
            SIGNAL dp_rd_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
            SIGNAL dp_rd_addr_step_in       : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
            SIGNAL dp_rd_fork_in            : IN STD_LOGIC;
            SIGNAL dp_rd_share_in           : IN STD_LOGIC;
            SIGNAL dp_wr_addr_in            : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);  
            SIGNAL dp_wr_addr_step_in       : IN STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);  
            SIGNAL dp_wr_fork_in            : IN STD_LOGIC;
            SIGNAL dp_wr_share_in           : IN STD_LOGIC;          
            SIGNAL dp_wr_mcast_in           : IN mcast_t;
            SIGNAL dp_write_in              : IN STD_LOGIC;
            SIGNAL dp_write_gen_valid_in    : IN STD_LOGIC;
            SIGNAL dp_write_vector_in       : IN dp_vector_t;
            SIGNAL dp_write_scatter_in      : IN scatter_t;
            SIGNAL dp_read_in               : IN STD_LOGIC;
            SIGNAL dp_read_vector_in        : IN dp_vector_t;
            SIGNAL dp_read_scatter_in       : IN scatter_t;
            SIGNAL dp_read_gen_valid_in     : IN STD_LOGIC;
            SIGNAL dp_read_data_flow_in     : IN data_flow_t;
            SIGNAL dp_read_data_type_in     : IN dp_data_type_t;
            SIGNAL dp_read_stream_in        : IN STD_LOGIC;
            SIGNAL dp_read_stream_id_in     : IN stream_id_t;
            SIGNAL dp_writedata_in          : IN STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
            SIGNAL dp_readdata_out          : OUT STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
            SIGNAL dp_readdata_vm_out       : OUT STD_LOGIC;
            SIGNAL dp_read_vector_out       : OUT unsigned(ddr_vector_depth_c-1 downto 0);
            SIGNAL dp_read_vaddr_out        : OUT STD_LOGIC_VECTOR(ddr_vector_depth_c-1 downto 0);
            SIGNAL dp_readdata_valid_out    : OUT STD_LOGIC;
            SIGNAL dp_read_gen_valid_out    : OUT STD_LOGIC;
            SIGNAL dp_read_data_flow_out    : OUT data_flow_t;
            SIGNAL dp_read_data_type_out    : OUT dp_data_type_t;
            SIGNAL dp_read_stream_out       : OUT STD_LOGIC;
            SIGNAL dp_read_stream_id_out    : OUT stream_id_t;
            SIGNAL dp_config_in             : IN STD_LOGIC;

            -- Instruction interface

            SIGNAL instruction_mu_in        : IN STD_LOGIC_VECTOR(mu_instruction_width_c-1 DOWNTO 0);
            SIGNAL instruction_imu_in       : IN STD_LOGIC_VECTOR(imu_instruction_width_c-1 DOWNTO 0);
            SIGNAL instruction_mu_valid_in  : IN STD_LOGIC;
            SIGNAL instruction_imu_valid_in : IN STD_LOGIC;
            SIGNAL vm_in                    : IN STD_LOGIC;
            SIGNAL data_model_in            : IN dp_data_model_t;
            SIGNAL enable_in                : IN STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
            SIGNAL tid_in                   : IN tid_t;
            SIGNAL tid_valid1_in            : IN STD_LOGIC;
            SIGNAL pre_tid_in               : IN tid_t;
            SIGNAL pre_tid_valid1_in        : IN STD_LOGIC;
            SIGNAL pre_pre_tid_in           : IN tid_t;
            SIGNAL pre_pre_tid_valid1_in    : IN STD_LOGIC;
            SIGNAL pre_pre_vm_in            : IN STD_LOGIC;
            SIGNAL pre_pre_data_model_in    : IN dp_data_model_t;
            SIGNAL pre_iregister_auto_in    : IN iregister_auto_t;
            SIGNAL i_y_neg_out              : OUT STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
            SIGNAL i_y_zero_out             : OUT STD_LOGIC_VECTOR(pid_max_c-1 downto 0)
            );
END cell;

ARCHITECTURE cell_behaviour of cell IS 
SIGNAL dp_readena:STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
SIGNAL dp_read_data_flow:data_flows_t(pid_max_c-1 downto 0);
SIGNAL dp_read_stream:STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
SIGNAL dp_read_stream_id:stream_ids_t(pid_max_c-1 downto 0);
SIGNAL dp_read_data_type:dp_data_types_t(pid_max_c-1 downto 0);
SIGNAL dp_read_gen_valid:STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
SIGNAL dp_readdata: STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
SIGNAL dp_readdata_vm:STD_LOGIC;
SIGNAL dp_readena_r:STD_LOGIC;
SIGNAL dp_readdata_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
SIGNAL dp_readdata_vm_r:STD_LOGIC;
SIGNAL dp_read_gen_valid_r:STD_LOGIC;
SIGNAL dp_read_data_flow_r:data_flow_t;
SIGNAL dp_read_data_type_r:dp_data_type_t;
SIGNAL dp_read_stream_r:std_logic;
SIGNAL dp_read_stream_id_r:stream_id_t;
SIGNAL dp_read_vector:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vector_r:unsigned(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vaddr:std_logic_vector(ddr_vector_depth_c-1 downto 0);
SIGNAL dp_read_vaddr_r:std_logic_vector(ddr_vector_depth_c-1 downto 0);

SIGNAL dp_rd_vm_in_r:STD_LOGIC;        
SIGNAL dp_wr_vm_in_r:STD_LOGIC;
SIGNAL dp_code_in_r:STD_LOGIC;
SIGNAL dp_rd_addr_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_rd_addr_step_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_rd_share_in_r:STD_LOGIC;
SIGNAL dp_wr_addr_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_addr_step_in_r:STD_LOGIC_VECTOR(local_bus_width_c-1 DOWNTO 0);
SIGNAL dp_wr_fork_in_r:STD_LOGIC;
SIGNAL dp_wr_share_in_r:STD_LOGIC;
SIGNAL dp_wr_mcast_in_r:mcast_t;        
SIGNAL dp_write_in_r:STD_LOGIC;
SIGNAL dp_write_gen_valid_in_r:STD_LOGIC;
SIGNAL dp_write_vector_in_r:dp_vector_t;
SIGNAL dp_write_scatter_in_r:scatter_t;
SIGNAL dp_read_in_r:STD_LOGIC;
SIGNAL dp_rd_fork_in_r:STD_LOGIC;
SIGNAL dp_read_vector_in_r:dp_vector_t;
SIGNAL dp_read_scatter_in_r:scatter_t;
SIGNAL dp_read_gen_valid_in_r:STD_LOGIC;
SIGNAL dp_read_data_flow_in_r:data_flow_t;
SIGNAL dp_read_data_type_in_r:dp_data_type_t;
SIGNAL dp_read_stream_in_r:std_logic;
SIGNAL dp_read_stream_id_in_r:stream_id_t;
SIGNAL dp_writedata_in_r:STD_LOGIC_VECTOR(ddrx_data_width_c-1 DOWNTO 0);
SIGNAL dp_config_in_r:STD_LOGIC;

attribute dont_merge : boolean;
attribute dont_merge of dp_readena_r : SIGNAL is true;
attribute dont_merge of dp_readdata_r : SIGNAL is true;
attribute dont_merge of dp_readdata_vm_r : SIGNAL is true;
attribute dont_merge of dp_read_gen_valid_r : SIGNAL is true;
attribute dont_merge of dp_rd_vm_in_r  : SIGNAL is true;
attribute dont_merge of dp_wr_vm_in_r : SIGNAL is true;
attribute dont_merge of dp_code_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_addr_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_addr_step_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_share_in_r : SIGNAL is true;
attribute dont_merge of dp_rd_fork_in_r  : SIGNAL is true;
attribute dont_merge of dp_wr_addr_in_r  : SIGNAL is true;
attribute dont_merge of dp_wr_addr_step_in_r  : SIGNAL is true;
attribute dont_merge of dp_wr_fork_in_r  : SIGNAL is true;
attribute dont_merge of dp_wr_share_in_r : SIGNAL is true;
attribute dont_merge of dp_wr_mcast_in_r : SIGNAL is true;
attribute dont_merge of dp_write_in_r : SIGNAL is true;
attribute dont_merge of dp_write_gen_valid_in_r : SIGNAL is true;
attribute dont_merge of dp_write_vector_in_r  : SIGNAL is true;
attribute dont_merge of dp_write_scatter_in_r : SIGNAL is true;
attribute dont_merge of dp_read_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_vector_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_scatter_in_r : SIGNAL is true;
attribute dont_merge of dp_read_gen_valid_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_data_flow_in_r  : SIGNAL is true;
attribute dont_merge of dp_read_data_type_in_r : SIGNAL is true;
attribute dont_merge of dp_read_stream_in_r : SIGNAL is true;
attribute dont_merge of dp_read_stream_id_in_r : SIGNAL is true;
attribute dont_merge of dp_writedata_in_r : SIGNAL is true;
attribute dont_merge of dp_config_in_r : SIGNAL is true;

attribute preserve : boolean;
attribute preserve of dp_readena_r : SIGNAL is true;
attribute preserve of dp_readdata_r : SIGNAL is true;
attribute preserve of dp_readdata_vm_r : SIGNAL is true;
attribute preserve of dp_read_gen_valid_r : SIGNAL is true;
attribute preserve of dp_rd_vm_in_r  : SIGNAL is true;
attribute preserve of dp_wr_vm_in_r : SIGNAL is true;
attribute preserve of dp_code_in_r : SIGNAL is true;
attribute preserve of dp_rd_addr_in_r : SIGNAL is true;
attribute preserve of dp_rd_fork_in_r  : SIGNAL is true;
attribute preserve of dp_rd_addr_step_in_r : SIGNAL is true;
attribute preserve of dp_rd_share_in_r : SIGNAL is true;
attribute preserve of dp_wr_addr_in_r  : SIGNAL is true;
attribute preserve of dp_wr_addr_step_in_r  : SIGNAL is true;
attribute preserve of dp_wr_fork_in_r  : SIGNAL is true;
attribute preserve of dp_wr_share_in_r : SIGNAL is true;
attribute preserve of dp_wr_mcast_in_r : SIGNAL is true;
attribute preserve of dp_write_in_r : SIGNAL is true;
attribute preserve of dp_write_gen_valid_in_r : SIGNAL is true;
attribute preserve of dp_write_vector_in_r  : SIGNAL is true;
attribute preserve of dp_write_scatter_in_r : SIGNAL is true;
attribute preserve of dp_read_in_r  : SIGNAL is true;
attribute preserve of dp_read_vector_in_r  : SIGNAL is true;
attribute preserve of dp_read_scatter_in_r : SIGNAL is true;
attribute preserve of dp_read_gen_valid_in_r  : SIGNAL is true;
attribute preserve of dp_read_data_flow_in_r  : SIGNAL is true;
attribute preserve of dp_read_data_type_in_r : SIGNAL is true;
attribute preserve of dp_read_stream_in_r : SIGNAL is true;
attribute preserve of dp_read_stream_id_in_r : SIGNAL is true;
attribute preserve of dp_writedata_in_r : SIGNAL is true;
attribute preserve of dp_config_in_r : SIGNAL is true;


BEGIN

dp_readdata_out <= dp_readdata_r;
dp_readdata_vm_out <= dp_readdata_vm_r when dp_readena_r='1' else 'Z';
dp_readdata_valid_out <= dp_readena_r;
dp_read_gen_valid_out <= dp_read_gen_valid_r when dp_readena_r='1' else 'Z';
dp_read_data_flow_out <= dp_read_data_flow_r when dp_readena_r='1' else (others=>'Z');
dp_read_stream_out <= dp_read_stream_r when dp_readena_r='1' else 'Z';
dp_read_stream_id_out <= dp_read_stream_id_r when dp_readena_r='1' else (others=>'Z');
dp_read_data_type_out <= dp_read_data_type_r when dp_readena_r='1' else (others=>'Z');
dp_read_vector_out <= dp_read_vector_r when dp_readena_r='1' else (others=>'Z');
dp_read_vaddr_out <= dp_read_vaddr_r when dp_readena_r='1' else (others=>'Z');

process(clock_in,reset_in)
variable stream_v:std_logic;
variable stream_id_v:stream_id_t;
variable data_flow_v:data_flow_t;
variable data_type_v:dp_data_type_t;
variable dp_read_gen_valid_v:STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
variable allzeros_v:STD_LOGIC_VECTOR(pid_max_c-1 downto 0);
begin
    if reset_in='0' then
        dp_readena_r <= '0';
        dp_readdata_r <= (others=>'0');
        dp_readdata_vm_r <= '0';
        dp_read_gen_valid_r <= '0';
        dp_read_data_flow_r <= (others=>'0');
        dp_read_stream_r <= '0';
        dp_read_stream_id_r <= (others=>'0');
        dp_read_data_type_r <= (others=>'0');
        dp_read_vector_r <= (others=>'0');
        dp_read_vaddr_r <= (others=>'0');
    else
        if clock_in'event and clock_in='1' then
            allzeros_v := (others=>'0');
            if dp_readena = allzeros_v then
                dp_readena_r <= '0';
            else
                dp_readena_r <= '1';
            end if;
            dp_read_gen_valid_v := (dp_readena and dp_read_gen_valid);
            if(dp_read_gen_valid_v = allzeros_v) then
               dp_read_gen_valid_r <= '0';
            else
               dp_read_gen_valid_r <= '1';
            end if;
            dp_readdata_r <= dp_readdata;
            dp_readdata_vm_r <= dp_readdata_vm;

            data_flow_v := (others=>'0');
            for I in 0 to pid_max_c-1 loop
               data_flow_v := data_flow_v or dp_read_data_flow(I);
            end loop;
            dp_read_data_flow_r <= data_flow_v;

            stream_v := '0';
            for I in 0 to pid_max_c-1 loop
               stream_v := stream_v or dp_read_stream(I);
            end loop;
            dp_read_stream_r <= stream_v;

            stream_id_v := (others=>'0');
            for I in 0 to pid_max_c-1 loop
               stream_id_v := unsigned(std_logic_vector(stream_id_v) or std_logic_vector(dp_read_stream_id(I)));
            end loop;
            dp_read_stream_id_r <= stream_id_v;

            data_type_v := (others=>'0');
            for I in 0 to pid_max_c-1 loop
               data_type_v := data_type_v or dp_read_data_type(I);
            end loop;
            dp_read_data_type_r <= data_type_v;

            dp_read_vector_r <= dp_read_vector;
            dp_read_vaddr_r <= dp_read_vaddr;

        end if;
    end if;
end process;


-- Instatiate the PCORES 

GEN_REG:
for I in 0 to pid_max_c-1 GENERATE
GEN1:
if (CID*pid_max_c+I) < pid_gen_max_c generate
pcore_i: pcore 
        generic map(
        CID => CID,
        PID => I
        )
        port map(
        clock_in => clock_in,
        reset_in => reset_in,

        -- Instruction interface

        instruction_mu_in => instruction_mu_in,
        instruction_imu_in => instruction_imu_in,
        instruction_mu_valid_in => instruction_mu_valid_in,
        instruction_imu_valid_in => instruction_imu_valid_in,
        vm_in => vm_in,
        data_model_in => data_model_in,
        enable_in => enable_in(I),
        tid_in => tid_in,
        tid_valid1_in => tid_valid1_in,
        pre_tid_in => pre_tid_in,
        pre_tid_valid1_in => pre_tid_valid1_in,
        pre_pre_tid_in => pre_pre_tid_in,
        pre_pre_tid_valid1_in => pre_pre_tid_valid1_in,
        pre_pre_vm_in => pre_pre_vm_in,
        pre_pre_data_model_in => pre_pre_data_model_in,
        pre_iregister_auto_in => pre_iregister_auto_in,
        i_y_neg_out => i_y_neg_out(I),
        i_y_zero_out => i_y_zero_out(I),
		
        -- DP interface

        dp_rd_vm_in => dp_rd_vm_in_r,
        dp_wr_vm_in => dp_wr_vm_in_r,
        dp_code_in => dp_code_in_r,
        dp_rd_addr_in => dp_rd_addr_in_r,
        dp_rd_addr_step_in => dp_rd_addr_step_in_r,
        dp_rd_share_in => dp_rd_share_in_r,
        dp_rd_fork_in => dp_rd_fork_in_r,    
        dp_wr_addr_in => dp_wr_addr_in_r,
        dp_wr_addr_step_in => dp_wr_addr_step_in_r,
        dp_wr_fork_in => dp_wr_fork_in_r,
        dp_wr_share_in => dp_wr_share_in_r,
        dp_wr_mcast_in => dp_wr_mcast_in_r,            
        dp_write_in => dp_write_in_r,
        dp_write_gen_valid_in => dp_write_gen_valid_in_r,
        dp_write_vector_in => dp_write_vector_in_r,
        dp_write_scatter_in => dp_write_scatter_in_r,
        dp_read_in => dp_read_in_r,
        dp_read_vector_in => dp_read_vector_in_r,
        dp_read_scatter_in => dp_read_scatter_in_r,
        dp_read_gen_valid_in => dp_read_gen_valid_in_r,
        dp_read_data_flow_in => dp_read_data_flow_in_r,
        dp_read_data_type_in => dp_read_data_type_in_r,
        dp_read_stream_in => dp_read_stream_in_r,
        dp_read_stream_id_in => dp_read_stream_id_in_r,
        dp_writedata_in => dp_writedata_in_r,
        dp_readdata_out => dp_readdata,
        dp_readdata_vm_out => dp_readdata_vm,
        dp_readena_out => dp_readena(I),
        dp_read_vector_out => dp_read_vector,
        dp_read_vaddr_out => dp_read_vaddr,
        dp_read_gen_valid_out => dp_read_gen_valid(I),
        dp_read_data_flow_out=> dp_read_data_flow(I),
        dp_read_data_type_out=> dp_read_data_type(I),
        dp_read_stream_out => dp_read_stream(I),
        dp_read_stream_id_out => dp_read_stream_id(I),
        dp_config_in_in => dp_config_in_r
    );
end generate GEN1;
GEN2:
if(CID*pid_max_c+I) >= pid_gen_max_c generate
i_y_neg_out(I) <= '0';
i_y_zero_out(I) <= '0';
dp_readena(I) <= '0';
dp_read_data_flow(I) <= (others=>'0');
dp_read_data_type(I) <= (others=>'0');
dp_read_stream(I) <= '0';
dp_read_stream_id(I) <= (others=>'0');
dp_read_gen_valid(I) <= '0';
end generate GEN2;
end generate GEN_REG;                                            

process(reset_in,clock_in)
begin
if reset_in = '0' then
   dp_rd_vm_in_r <= '0';
   dp_wr_vm_in_r <= '0';
   dp_code_in_r <= '0';
   dp_rd_addr_in_r  <= (others=>'0');
   dp_rd_addr_step_in_r <= (others=>'0');
   dp_rd_share_in_r <= '0';
   dp_rd_fork_in_r <= '0';
   dp_wr_addr_in_r <= (others=>'0');
   dp_wr_addr_step_in_r <= (others=>'0');
   dp_wr_fork_in_r <= '0';
   dp_wr_share_in_r <= '0';
   dp_wr_mcast_in_r <= (others=>'0');
   dp_write_in_r <= '0';
   dp_write_gen_valid_in_r <= '0';
   dp_write_vector_in_r <= (others=>'0');
   dp_write_scatter_in_r <= (others=>'0');
   dp_read_in_r <= '0';
   dp_read_vector_in_r <= (others=>'0');
   dp_read_scatter_in_r <= (others=>'0');
   dp_read_gen_valid_in_r <= '0';
   dp_read_data_flow_in_r <= (others=>'0');
   dp_read_data_type_in_r <= (others=>'0');
   dp_read_stream_in_r  <= '0';
   dp_read_stream_id_in_r <= (others=>'0');
   dp_writedata_in_r <= (others=>'0');
   dp_config_in_r <= '0';
else
   if clock_in'event and clock_in='1' then
      dp_rd_vm_in_r <= dp_rd_vm_in;
      dp_wr_vm_in_r <= dp_wr_vm_in;
      dp_code_in_r <= dp_code_in;
      dp_rd_addr_in_r  <= dp_rd_addr_in;
      dp_rd_addr_step_in_r <= dp_rd_addr_step_in;
      dp_rd_share_in_r <= dp_rd_share_in;
      dp_rd_fork_in_r <= dp_rd_fork_in;
      dp_wr_addr_in_r <= dp_wr_addr_in;
      dp_wr_addr_step_in_r <= dp_wr_addr_step_in;
      dp_wr_fork_in_r <= dp_wr_fork_in;
      dp_wr_share_in_r <= dp_wr_share_in;
      dp_wr_mcast_in_r <= dp_wr_mcast_in;
      dp_write_in_r <= dp_write_in;
      dp_write_gen_valid_in_r <= dp_write_gen_valid_in;
      dp_write_vector_in_r <= dp_write_vector_in;
      dp_write_scatter_in_r <= dp_write_scatter_in;
      dp_read_in_r <= dp_read_in;
      dp_read_vector_in_r <= dp_read_vector_in;
      dp_read_scatter_in_r <= dp_read_scatter_in;
      dp_read_gen_valid_in_r <= dp_read_gen_valid_in;
      dp_read_data_flow_in_r <= dp_read_data_flow_in;
      dp_read_data_type_in_r <= dp_read_data_type_in;
      dp_read_stream_in_r  <= dp_read_stream_in;
      dp_read_stream_id_in_r <= dp_read_stream_id_in;
      dp_writedata_in_r <= dp_writedata_in;
      dp_config_in_r <= dp_config_in;
   end if;
end if;
end process;

END cell_behaviour;
