----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date:    17:12:00 08/02/2025 
-- design name: 
-- module name:    hello_world - behavioral 
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
--
-- dependencies: 
--
-- revision: 
-- revision 0.01 - file created
-- additional comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx primitives in this code.
--library unisim;
--use unisim.vcomponents.all;

entity hello_world is
	port
	(
		clk: in std_logic;
		rest: in std_logic;
		uart_tx: out std_logic;
		uart_rx: in std_logic;
		gpio_pin: inout std_logic_vector(7 downto 0)
	
	);
end hello_world;

architecture behavioral of hello_world is

--------------- signals -----------------------------

signal cpu_out_bus:	std_logic_vector (7 downto 0);
signal address: std_logic_vector(15 downto 0);
signal cpu_in_bus: std_logic_vector(7 downto 0);  
signal cpu_write: std_logic;
signal cpu_read: std_logic;
signal rst: std_logic;

signal  mem_or_port_mux_sel: std_logic;
signal port_write_line: std_logic_vector (15 downto 0);
signal port_read_line: std_logic_vector (15 downto 0);

signal mem_write_line : std_logic;
signal mem_read_line : std_logic;


signal ram_data_out_bus: std_logic_vector (7 downto 0);

signal port_mux_out_bus: std_logic_vector (7 downto 0);



--------- I/O REGISTERS -----------------
signal uart_rx_reg: std_logic_vector (7 downto 0);
signal dir_reg_out: std_logic_vector(7 downto 0);
signal o_reg_out: std_logic_vector(7 downto 0);
signal i_reg_out: std_logic_vector(7 downto 0);

------------- SPECIAL REGISTERS -------------
signal port_mux_sel: std_logic_vector (3 downto 0);
signal mem_or_port_mux_sel_sync: std_logic;
      
begin

	rst <= not rest;
	
 -- instancia de la cpu2
  cpu_inst : entity work.cpu2
    port map(
        clk => clk,
        rst => rst,
        ready => '1',
        data_bus_out => cpu_out_bus,
        address_bus => address,
        data_bus_in_extern => cpu_in_bus,  
        extern_read => cpu_read,
        extern_write => cpu_write,
        rom_addr_out => open,
        alu_out_ext => open,
        stat_out => open,
        reg_sel_out_cpu => open
    );
	 
	  addr_decoder_inst: entity work.addr_decoder 
	  port map(
        address_bus => address,
        cpu_write => cpu_write,
		  cpu_read => cpu_read,
        mem_or_port_mux_sel =>  mem_or_port_mux_sel,
        port_write_line     => port_write_line,
		  port_read_line =>  port_read_line,
        mem_write_line      => mem_write_line,
			mem_read_line => mem_read_line
    );
	 
	 ram_inst:  entity work.RAM_32Kx8
	port map(
		clk => clk,
		we => mem_write_line,
		address => address(14 downto 0),
		address2 => (others => '0'),
		data_out2 => open,
		data_out => ram_data_out_bus, 
		data_in => cpu_out_bus
	);
	
	uart : entity work.uart
   generic map(
     DBIT => 8,      -- # data bits
     SB_TICK => 32,  -- # ticks for stop bits (1 stop bit)
     DVSR => 162,    -- baud rate divisor 
     DVSR_BIT => 8   -- bits of DVSR
   )
   port map(
      clk    => clk,
      reset  => rst,
		send	 => port_write_line(0),
		received => port_write_line(1),
		tx_data => cpu_out_bus,
		rx_reg => uart_rx_reg,
      rx     => uart_rx,
      tx     => uart_tx
   );
	
	io_mod_inst:  entity work.gpio_module
	port map(
		clk => clk,
		reset => rst,
		we_dir_reg => port_write_line(2),
		we_o_reg => port_write_line(3),
		dir_reg_in => cpu_out_bus,
		o_reg_in => cpu_out_bus,
		dir_reg_out => dir_reg_out,
		o_reg_out => o_reg_out,
		i_reg_in	=> gpio_pin,
		i_reg_out => i_reg_out
	);
	
	------- MULTIPLEX I/O AND MEM ----------------
	
	MULTIPLEX_1 : process(mem_or_port_mux_sel_sync,ram_data_out_bus,port_mux_out_bus)
	begin
	
		case mem_or_port_mux_sel_sync is
			when '0' => 
			cpu_in_bus <= ram_data_out_bus;		
			when others =>
			cpu_in_bus <= port_mux_out_bus;
		
		end case;
		
	end process;
	
	----------- MULTIPLEX I/O ports -----------------------
	
	MULTIPLEX_2 : process(port_mux_sel,uart_rx_reg,i_reg_out)
	begin
	
		case port_mux_sel is 
			when x"1" => 
			port_mux_out_bus <= uart_rx_reg;	
			when x"4" =>
			port_mux_out_bus <= i_reg_out;
			when others =>
			port_mux_out_bus <= x"00";
		
		end case;
		
	end process;
	
	
	port_mux_sel_reg: process(clk,rst)
	begin
		if rising_edge(clk) then
		port_mux_sel <= address(3 downto 0);
		end if;
	end process;
	
	mem_or_port_mux_sel_sync_reg: process(clk,rst)
	begin
		if rising_edge(clk) then
		mem_or_port_mux_sel_sync <= mem_or_port_mux_sel;
		end if;
	end process;
	
	-------------------------- GPIO PIN CONFIG ------------------
	gpio_pin(0) <= o_reg_out(0) when dir_reg_out(0) = '1' else 'Z';
	gpio_pin(1) <= o_reg_out(1) when dir_reg_out(1) = '1' else 'Z';
	gpio_pin(2) <= o_reg_out(2) when dir_reg_out(2) = '1' else 'Z';
	gpio_pin(3) <= o_reg_out(3) when dir_reg_out(3) = '1' else 'Z';
	gpio_pin(4) <= o_reg_out(4) when dir_reg_out(4) = '1' else 'Z';
	gpio_pin(5) <= o_reg_out(5) when dir_reg_out(5) = '1' else 'Z';
	gpio_pin(6) <= o_reg_out(6) when dir_reg_out(6) = '1' else 'Z';
	gpio_pin(7) <= o_reg_out(7) when dir_reg_out(7) = '1' else 'Z';
	
	
	
	
end behavioral;

