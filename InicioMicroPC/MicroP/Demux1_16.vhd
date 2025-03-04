library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Demux1_16 is
    port(
        AIN  : in  STD_LOGIC;                -- Entrada única
        CTRL : in  STD_LOGIC_VECTOR(3 downto 0);  -- Control de selección
        BOUT : out STD_LOGIC_VECTOR(15 downto 0)  -- Salida de 16 líneas
    );
end Demux1_16;

architecture Behavioral of Demux1_16 is
begin
    process(AIN, CTRL)
    begin
			BOUT <= "0000000000000000";
        if AIN = '1' then
            -- Asignación de salida basada en CTRL cuando AIN = 1
            case CTRL is
                when "0000" => BOUT <= "0000000000000001";
                when "0001" => BOUT <= "0000000000000010";
                when "0010" => BOUT <= "0000000000000100";
                when "0011" => BOUT <= "0000000000001000";
                when "0100" => BOUT <= "0000000000010000";
                when "0101" => BOUT <= "0000000000100000";
                when "0110" => BOUT <= "0000000001000000";
                when "0111" => BOUT <= "0000000010000000";
                when "1000" => BOUT <= "0000000100000000";
                when "1001" => BOUT <= "0000001000000000";
                when "1010" => BOUT <= "0000010000000000";
                when "1011" => BOUT <= "0000100000000000";
                when "1100" => BOUT <= "0001000000000000";
                when "1101" => BOUT <= "0010000000000000";
                when "1110" => BOUT <= "0100000000000000";
                when others => BOUT <= "1000000000000000";
            end case;
        end if;
    end process;
end Behavioral;
