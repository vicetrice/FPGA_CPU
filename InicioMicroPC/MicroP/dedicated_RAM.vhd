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
    signal RAM : RAM_Array := (
	 
	 --PROGRAM
	 16#0000# =>  X"10",-- SUB TO REG 0 INST (IMM8)
	 16#0001# =>  X"02",-- IMM, VAL = 0x02
	 
	 16#0002# =>  X"C0",-- SHL REG 0 INST
	 16#0003# =>  X"00",-- NOT USED
	 
	 16#0004# =>  X"A9",-- ADC TO REG 1 INST (REG)
	 16#0005# =>  X"A8",-- REG 2
	 
	 16#0006# =>  X"62",-- MOV TO REG 2 (IMM8)
	 16#0007# =>  X"0F",-- IMM, VAL = 0x0F
	 
	 16#0008# =>  X"0B",-- ADD TO REG 3 INST (REG)
	 16#0009# =>  X"0A",-- REG 2
	 
	 16#000A# => X"6C", --MOV TO REG 4 INST (REG)
	 16#000B# => X"6B", --REG 3
	 
	 16#000C# => X"04", --ADD TO REG 4 INST (IMM8)
	 16#000D# => X"00", --IMM, VAL = 0x00


	 
	 others => (others => '0'));  -- Inicialización en ceros
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
