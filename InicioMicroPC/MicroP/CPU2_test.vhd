library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_CPU2 is
end tb_CPU2;

architecture behavior of tb_CPU2 is

    -- Component declaration of CPU2
    component CPU2
        port(
            CLK : in STD_LOGIC;
            READY : in STD_LOGIC;
            DATA_BUS_OUT : out STD_LOGIC_VECTOR(7 downto 0);
            ADDRESS_BUS : out STD_LOGIC_VECTOR(15 downto 0);
            DATA_BUS_IN_EXTERN: in STD_LOGIC_VECTOR(7 downto 0);
            EXTERN_READ: out STD_LOGIC;
            EXTERN_WRITE: out STD_LOGIC
				;
            MIC_OUT: OUT STD_LOGIC_VECTOR(6 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				ALU_OUT_EXT: OUT STD_LOGIC_VECTOR(7 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				STAT_OUT: OUT STD_LOGIC_VECTOR(7 downto 0)  -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!


        );
    end component;

    -- Signals
    signal CLK : STD_LOGIC := '0';
    signal READY : STD_LOGIC := '0';
    signal DATA_BUS_OUT : STD_LOGIC_VECTOR(7 downto 0);
    signal ADDRESS_BUS : STD_LOGIC_VECTOR(15 downto 0);
    signal DATA_BUS_IN_EXTERN : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal EXTERN_READ : STD_LOGIC;
    signal EXTERN_WRITE : STD_LOGIC;
    signal MIC_OUT: STD_LOGIC_VECTOR(6 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
	 SIGNAL ALU_OUT_EXT:  STD_LOGIC_VECTOR(7 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
	 SIGNAL STAT_OUT: STD_LOGIC_VECTOR(7 downto 0);  -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!



    -- Señal auxiliar para sincronización
    signal DATA_BUS_IN_EXTERN_NEXT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instancia de CPU2
    uut: CPU2
        port map (
            CLK => CLK,
            READY => READY,
            DATA_BUS_OUT => DATA_BUS_OUT,
            ADDRESS_BUS => ADDRESS_BUS,
            DATA_BUS_IN_EXTERN => DATA_BUS_IN_EXTERN,
            EXTERN_READ => EXTERN_READ,
            EXTERN_WRITE => EXTERN_WRITE,
           MIC_OUT => MIC_OUT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				ALU_OUT_EXT => ALU_OUT_EXT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				STAT_OUT => STAT_OUT-- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!

		  );

    -- Proceso de generación del reloj
    CLK_PROCESS: process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Proceso de sincronización del bus de datos externo
    SYNC_DATA_BUS: process(CLK)
    begin
        if rising_edge(CLK) then
            DATA_BUS_IN_EXTERN <= DATA_BUS_IN_EXTERN_NEXT;
        end if;
    end process;

    -- Proceso de prueba
    TEST_PROC: process
    begin
        -- Inicialización
        READY <= '1';
        DATA_BUS_IN_EXTERN_NEXT <= X"10";  --instruction SUB

        wait for CLK_PERIOD;
        DATA_BUS_IN_EXTERN_NEXT <= X"02"; --imm8

			--------- TRY READY
		  wait for CLK_PERIOD;
		  ready <= '0';
        --DATA_BUS_IN_EXTERN_NEXT <= X"C0"; --Instruction --SHL
		  
		  wait for CLK_PERIOD * 4;
		  DATA_BUS_IN_EXTERN_NEXT <= X"C0"; --instruction SHL
		  
		  ready <= '1';
		  wait for CLK_PERIOD;
        DATA_BUS_IN_EXTERN_NEXT <= X"A0"; --instruction ADC
		  
		  wait for CLK_PERIOD * 4;
		  DATA_BUS_IN_EXTERN_NEXT <= X"02"; -- SUM 2 to infinite with register 010
		  
		  ready <= '0';
			
		  wait for CLK_PERIOD * 4;
		  
		  ready <= '1';

			
        -- Finalizar simulación
        wait;
    end process;

end behavior;
