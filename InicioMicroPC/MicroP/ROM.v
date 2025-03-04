library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM is
    Port ( address : in  std_logic_vector(11 downto 0); -- 12-bit address (4K words)
           data_out : out std_logic_vector(15 downto 0)); -- 16-bit output
end ROM;

architecture Behavioral of ROM is
    type ROM_Array is array (0 to 4095) of std_logic_vector(15 downto 0);
    signal ROM : ROM_Array := (
        -- Aquí puedes definir el contenido de la ROM de manera explícita
        0 => x"1234",
        1 => x"5678",
        2 => x"9ABC",
        3 => x"DEF0",
        -- ...
        others => x"0000"  -- Valores por defecto
    );
begin
    data_out <= ROM(to_integer(unsigned(address)));
end Behavioral;
