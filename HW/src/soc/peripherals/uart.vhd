---------------------------------------------------------------------------
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
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config.all;
use work.ztachip_pkg.all;

entity UART is
   generic (
      BAUD_RATE : positive;
      CLOCK_FREQUENCY : positive
   );
   Port ( 
      signal clock_in              : IN  std_logic;
      signal reset_in              : IN  std_logic;
      signal uart_rx_in            : IN  std_logic;
      signal uart_tx_out           : OUT  std_logic;

      signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
      signal apb_penable           : IN STD_LOGIC;
      signal apb_pready            : OUT STD_LOGIC;
      signal apb_pwrite            : IN STD_LOGIC;
      signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
      signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
      signal apb_pslverror         : OUT STD_LOGIC
      );
end UART;

architecture Behavioral of UART is

   constant FIFO_DEPTH:integer:=5;

   constant TICKS_PER_BIT : integer := CLOCK_FREQUENCY / BAUD_RATE;
   -- RX
   signal rx_clk_count_r : integer range 0 to TICKS_PER_BIT - 1 := 0;
   type t_RX_State is (IDLE, WAITING_FOR_START, WAITING_FOR_BITS, WAITING_FOR_END);
   signal rx_state_r : t_RX_State := IDLE;
   signal rx_bit_index_r : integer range 0 to 7 := 0;
   signal rx_byte_r : std_logic_vector(7 downto 0) := (others => '0');
	
   -- TX
   signal tx_clk_count_r : integer range 0 to TICKS_PER_BIT - 1 := 0;
   type t_TX_State is (IDLE, START_BIT, WRITING_BITS, WRITING_END_BIT);
   signal tx_state_r : t_TX_State := IDLE;
   signal last_tx_state_r : t_TX_State := IDLE;
   signal tx_byte_r : std_logic_vector (7 downto 0) := (others => '0');
   signal tx_bit_index_r : integer range 0 to 7 := 0;

   -- TXFIFO
   signal txfifo_write:std_logic_vector(7 downto 0);
   signal txfifo_wr:std_logic;
   signal txfifo_rd:std_logic;
   signal txfifo_q:std_logic_vector(7 downto 0);
   signal txfifo_wused:std_logic_vector(FIFO_DEPTH-1 downto 0);
   signal txfifo_empty:std_logic;
   signal txfifo_full:std_logic;
   signal txfifo_ravail:std_logic_vector(FIFO_DEPTH-1 downto 0);

   -- RXFIFO
   signal rxfifo_write:std_logic_vector(7 downto 0);
   signal rxfifo_wr:std_logic;
   signal rxfifo_rd:std_logic;
   signal rxfifo_q:std_logic_vector(7 downto 0);
   signal rxfifo_wused:std_logic_vector(FIFO_DEPTH-1 downto 0);
   signal rxfifo_empty:std_logic;
   signal rxfifo_full:std_logic;
   signal rxfifo_ravail:std_logic_vector(FIFO_DEPTH-1 downto 0);

   signal match_read:std_logic;
   signal match_read_avail:std_logic;
   signal match_write:std_logic;
   signal match_write_avail:std_logic;
   signal match:std_logic;

   signal byte_received_r :std_logic:='0';
   signal RX_r:std_logic:='1';
   signal RX_rr:std_logic:='1';
   signal RX_rrr:std_logic:='1';
   signal TX_r:std_logic:='1';
begin

match_read <= apb_penable when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_uart_read_c,apb_addr_len_c))) else '0';

match_read_avail <= apb_penable when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_uart_read_avail_c,apb_addr_len_c))) else '0';

match_write <= apb_penable when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_uart_write_c,apb_addr_len_c))) else '0';

match_write_avail <= apb_penable when (apb_paddr(apb_addr_len_c-1 downto 0)=std_logic_vector(to_unsigned(apb_uart_write_avail_c,apb_addr_len_c))) else '0';

match <= match_read or match_read_avail or match_write or match_write_avail;

apb_pready <= '1' when (match='1') else 'Z';

apb_pslverror <= '1' when (match='1') else 'Z';

txfifo_write <= apb_pwdata(7 downto 0);

txfifo_wr <= '1' when (match_write='1' and txfifo_full='0') else '0';

txfifo_rd <= '1' when (last_tx_state_r=IDLE and tx_state_r /= IDLE) else '0'; 

rxfifo_write <= rx_byte_r;

rxfifo_wr <= '1' when (byte_received_r='1' and rxfifo_full='0') else '0';

rxfifo_rd <= '1' when (match_read='1' and rxfifo_empty='0') else '0';

uart_tx_out <= TX_r;

process (match_read,match_read_avail,match_write_avail,rxfifo_q,rxfifo_ravail,txfifo_wused)
begin
if(match_read='1') then
   apb_prdata(31 downto 8) <= (others=>'0');
   apb_prdata(7 downto 0) <= rxfifo_q;
elsif(match_read_avail='1') then
   apb_prdata(31 downto FIFO_DEPTH) <= (others=>'0');
   apb_prdata(FIFO_DEPTH-1 downto 0) <= rxfifo_ravail;
elsif(match_write_avail='1') then
   apb_prdata(31 downto FIFO_DEPTH) <= (others=>'0');
   apb_prdata(FIFO_DEPTH-1 downto 0) <= not(txfifo_wused);
else
   apb_prdata <= (others=>'Z');
end if;
end process;

txfifo_i:scfifo
	generic map 
	(
      DATA_WIDTH=>8,
      FIFO_DEPTH=>5,
      LOOKAHEAD=>TRUE
	)
	port map 
	(
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>txfifo_write,
      write_in=>txfifo_wr,
      read_in=>txfifo_rd,
      q_out=>txfifo_q,
      ravail_out=>txfifo_ravail,
      wused_out=>txfifo_wused,
      empty_out=>txfifo_empty,
      full_out=>txfifo_full,
      almost_full_out=>open
	);

rxfifo_i:scfifo
	generic map 
	(
      DATA_WIDTH=>8,
      FIFO_DEPTH=>5,
      LOOKAHEAD=>TRUE
	)
	port map 
	(
      clock_in=>clock_in,
      reset_in=>reset_in,
      data_in=>rxfifo_write,
      write_in=>rxfifo_wr,
      read_in=>rxfifo_rd,
      q_out=>rxfifo_q,
      ravail_out=>rxfifo_ravail,
      wused_out=>rxfifo_wused,
      empty_out=>rxfifo_empty,
      full_out=>rxfifo_full,
      almost_full_out=>open
	);

p_RX : process (clock_in)
begin
   if rising_edge(clock_in) then
      RX_r <= uart_rx_in;
      RX_rr <= RX_r;
      RX_rrr <= RX_rr;
      -- Waiting for RX to be equal '0' to start waiting for the start bit
      if RX_rrr = '0' and rx_state_r = IDLE then
         rx_state_r <= WAITING_FOR_START;
         rx_clk_count_r <= TICKS_PER_BIT / 2;
         rx_bit_index_r <= 0;
      end if;
		
      if rx_state_r = IDLE then
         byte_received_r <= '0';
      end if;
      if rx_state_r /= IDLE then
			if rx_clk_count_r = TICKS_PER_BIT - 1 then -- Check if middle of bit
            case rx_state_r is
               when WAITING_FOR_START =>
                  if RX_rrr = '0' then
                     rx_state_r <= WAITING_FOR_BITS;
                  else
                     rx_state_r <= IDLE;
                  end if;
					when WAITING_FOR_BITS =>
                  rx_byte_r(rx_bit_index_r) <= RX_rrr;
                  if rx_bit_index_r = 7 then
                     rx_state_r <= WAITING_FOR_END;
                     rx_bit_index_r <= 0;
                  else
                     rx_bit_index_r <= rx_bit_index_r + 1;
                  end if;
					when WAITING_FOR_END =>
                  byte_received_r <= '1';
                  rx_byte_r <= rx_byte_r;
                  rx_state_r <= IDLE;				
					when others =>
						rx_state_r <= IDLE;		
				end case;
				rx_clk_count_r <= 0;
			else
            rx_clk_count_r <= rx_clk_count_r + 1;
			end if;
      end if;
   end if;
end process p_RX;
	
p_TX : process (clock_in)
begin
   if rising_edge(clock_in) then			
      if tx_clk_count_r = TICKS_PER_BIT - 1 then
         tx_clk_count_r <= 0;
      else
         tx_clk_count_r <= tx_clk_count_r + 1;
      end if;
      last_tx_state_r <= tx_state_r;
      if tx_clk_count_r = 0 then	
         case tx_state_r is
            when IDLE =>
               if txfifo_empty = '0' then
                  tx_byte_r <= txfifo_q;
                  tx_bit_index_r <= 0;
                  tx_state_r <= START_BIT;
               else
                  TX_r <= '1';
               end if;
					when START_BIT =>
                  TX_r <= '0';
                  tx_state_r <= WRITING_BITS;
					when WRITING_BITS =>
                  TX_r <= tx_byte_r(tx_bit_index_r);
                  if tx_bit_index_r = 7 then
                     tx_state_r <= WRITING_END_BIT;
                  else
                     tx_bit_index_r <= tx_bit_index_r + 1;
                  end if;
					when WRITING_END_BIT =>
                  TX_r <= '1';
                  tx_state_r <= IDLE;
					when others =>
                  tx_state_r <= IDLE;
         end case;
      end if;
   end if;
end process p_TX;
end Behavioral;
