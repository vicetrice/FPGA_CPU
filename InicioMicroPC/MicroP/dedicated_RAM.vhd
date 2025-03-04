library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_64Kx8 is
    Port (
        clk     : in  std_logic;                           -- Reloj
        we      : in  std_logic;                           -- Habilitación de escritura
        re      : in  std_logic;                           -- Habilitación de lectura
        address : in  std_logic_vector(15 downto 0);       -- Dirección de memoria (64K posiciones)
        data_out : out std_logic_vector(7 downto 0);    
		  data_in : in std_logic_vector(7 downto 0)      
    );
end RAM_64Kx8;

architecture Behavioral of RAM_64Kx8 is
    type RAM_Array is array (0 to 65535) of std_logic_vector(7 downto 0);
    signal RAM : RAM_Array := (others => (others => '0'));  -- Inicialización en ceros
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if we = '1' and re = '0' then
                RAM(to_integer(unsigned(address))) <= data_in;
            elsif re = '1' and we = '0' then
                data_out <= RAM(to_integer(unsigned(address)));
				end if;
        end if;
    end process;

end Behavioral;
