library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 16 I/O ports from 0xFFF0 to 0xFFFF
-- 1:17 DEMUX based on addr
-- 0xFFF0 used for UART TX REGISTER
-- 0xFFF1 used for UART RX REGISTER
-- 0xFFF2 used for simplex COM between CPU and UART being CPU the tx and UART the rx 
-- 0xFFF3 to 0xFFFF unused, could be used to implement GPIO registers
entity addr_decoder is
    Port (
        address_bus : in  std_logic_vector(15 downto 0);
        cpu_write   : in  std_logic;
		  cpu_read: in std_logic;
        mem_or_port_mux_sel : out std_logic;
        port_write_line     : out std_logic_vector(15 downto 0);
		  port_read_line     : out std_logic_vector(15 downto 0);
        mem_write_line      : out std_logic;
		  mem_read_line      : out std_logic
    );
end addr_decoder;

architecture Behavioral of addr_decoder is
    
begin

    process(cpu_write, address_bus,cpu_read)
			variable index   : integer range 0 to 15;
        begin
        port_write_line <= (others => '0');
		  port_read_line <= (others => '0');
		  mem_write_line <= '0';
		  mem_read_line <= '0';
		  
        if address_bus(15 downto 4) = x"FFF" then
            mem_or_port_mux_sel <= '1';
            index := to_integer(unsigned(address_bus(3 downto 0)));
            port_write_line(index) <= cpu_write;
				port_read_line(index) <= cpu_read;
        else
            mem_or_port_mux_sel <= '0';
            mem_write_line <= cpu_write;
				mem_read_line <= cpu_read;
        end if;

       
    end process;

end Behavioral;
