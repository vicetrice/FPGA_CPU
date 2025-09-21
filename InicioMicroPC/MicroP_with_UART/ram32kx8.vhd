library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.prog_mem.all;

entity RAM_32Kx8 is
    Port (
        clk     : in  std_logic;                           -- Reloj
        we      : in  std_logic;                           -- Habilitacin de escritura
        address : in  std_logic_vector(14 downto 0);       -- Direccin de memoria (64K posiciones)
		  address2 : in  std_logic_vector(14 downto 0);      -- ONLY READ ADDRESS
		  data_out2: out std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
		  data_in : in std_logic_vector(7 downto 0)      
    );
end RAM_32Kx8;

architecture Behavioral of RAM_32Kx8 is 
    signal RAM : RAM_Array := RAM_INIT;
    begin
    process (clk)
    begin
        if rising_edge(clk) then

            if we = '1' then
                RAM(to_integer(unsigned(address))) <= data_in;
				else
					 data_out <= RAM(to_integer(unsigned(address)));
				end if;
            
					data_out2 <= RAM(to_integer(unsigned(address2)));

				
        end if;
		  
		  
    end process;
	
	 

end Behavioral;
