library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
   generic(
     DBIT: integer := 8;      -- # data bits
     SB_TICK: integer := 32;  -- # ticks for stop bits (1 stop bit)
     DVSR: integer := 162;    -- baud rate divisor 
     DVSR_BIT: integer := 8   -- bits of DVSR
   );
   port(
      clk    : in std_logic;
      reset  : in std_logic;
		send	 : in std_logic;
		received: in std_logic;
		tx_data: in std_logic_vector (7 downto 0);
		rx_reg : out std_logic_vector (7 downto 0);
      rx     : in std_logic;
      tx     : out std_logic
   );
end uart;

architecture str_arch of uart is
   signal tick      : std_logic;
   signal fin_rx    : std_logic;
   signal rx_data   : std_logic_vector(7 downto 0);
   signal fin_tx    : std_logic;
   signal tx_start  : std_logic := '0';
   --signal tx_data   : std_logic_vector(7 downto 0);
	
	signal send_reg : std_logic;
	signal received_reg : std_logic;
	signal rx_internal_reg   : std_logic_vector(7 downto 0);
	
	
begin

	
   baud_gen_unit: entity work.mod_m_counter(arch)
      generic map(M => DVSR, N => DVSR_BIT)
      port map(clk => clk, reset => reset, q => open, max_tick => tick);

   uart_rx_unit: entity work.uart_rx(arch)
      generic map(DBIT => DBIT, SB_TICK => SB_TICK)
      port map(clk => clk, reset => reset, rx => rx,
               s_tick => tick, fin_rx => fin_rx, dout => rx_data);

   uart_tx_unit: entity work.uart_tx(arch)
      generic map(DBIT => DBIT, SB_TICK => SB_TICK)
      port map(clk => clk, reset => reset,
               tx_start => tx_start,
               s_tick => tick,
               din => tx_data,
               fin_tx => fin_tx,
               tx => tx);

   send_proc: process(clk, reset)
   begin
   if rising_edge(clk) then
		send_reg <= send;
		if reset = '1' then
			tx_start <= '0';
		elsif send = '0' and send_reg = '1' then
			tx_start <= '1';
		else
			tx_start <= '0';
		end if;
	end if;
   end process;
	
	 received_proc: process(clk, reset)
   begin
   if rising_edge(clk) then
		received_reg <= received;
		if reset = '1' then
			rx_internal_reg <= (others => '0'); 
		elsif fin_rx = '1' then
			rx_internal_reg <= rx_data;
		elsif received = '0' and received_reg = '1' then
			rx_internal_reg <= (others => '0');
		end if;
	end if;
   end process;
	
	rx_reg <= rx_internal_reg;
end str_arch;