library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_contador is
end tb_contador;

architecture test of tb_contador is
    signal clk   : STD_LOGIC := '0';
    signal rst   : STD_LOGIC := '0';
    signal count : STD_LOGIC_VECTOR(3 downto 0);

    -- Instancia del contador
    component contador
        Port ( clk   : in  STD_LOGIC;
               rst   : in  STD_LOGIC;
               count : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

begin
    -- Conectar señales
    uut: contador port map (clk => clk, rst => rst, count => count);

    -- Generador de reloj (simulación indefinida hasta detener manualmente)
    clk_process: process
    begin
			rst <= '1';  -- Aplicar reset
			wait for 20 ns;
			rst <= '0';  -- Quitar reset
        while now < 1000 ns loop  -- Ejecutar el reloj por 500 ns
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
        -- Finalizar la simulación
        assert false report "Testbench finalizado" severity failure;
    end process;


end test;
