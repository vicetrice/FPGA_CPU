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
				RST: in STD_LOGIC;
            READY : in STD_LOGIC;
            DATA_BUS_OUT : out STD_LOGIC_VECTOR(7 downto 0);
            ADDRESS_BUS : out STD_LOGIC_VECTOR(15 downto 0);
            DATA_BUS_IN_EXTERN: in STD_LOGIC_VECTOR(7 downto 0);
            EXTERN_READ: out STD_LOGIC;
            EXTERN_WRITE: out STD_LOGIC
				;
            ROM_ADDR_OUT: OUT STD_LOGIC_VECTOR(8 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				ALU_OUT_EXT: OUT STD_LOGIC_VECTOR(7 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				STAT_OUT: OUT STD_LOGIC_VECTOR(7 downto 0);  -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				REG_SEL_OUT_CPU : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)-- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!


        );
    end component;
	 
	 component RAM_64Kx8 
    Port (
        clk     : in  std_logic;                           -- Reloj
        we      : in  std_logic;                           -- Habilitación de escritura
        re      : in  std_logic;                           -- Habilitación de lectura
        address : in  std_logic_vector(15 downto 0);       -- Dirección de memoria (64K posiciones)
        data_out : out std_logic_vector(7 downto 0);    
		  data_in : in std_logic_vector(7 downto 0)      
    );
	end component;

    -- Signals
    signal CLK : STD_LOGIC := '0';
	 signal RST : STD_LOGIC := '0';
    signal READY : STD_LOGIC := '0';
    signal DATA_BUS_OUT : STD_LOGIC_VECTOR(7 downto 0);
    signal ADDRESS_BUS : STD_LOGIC_VECTOR(15 downto 0);
    signal DATA_BUS_IN_EXTERN : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal EXTERN_READ : STD_LOGIC;
    signal EXTERN_WRITE : STD_LOGIC;
    signal ROM_ADDR_OUT: STD_LOGIC_VECTOR(8 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
	 SIGNAL ALU_OUT_EXT:  STD_LOGIC_VECTOR(7 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
	 SIGNAL STAT_OUT: STD_LOGIC_VECTOR(7 downto 0);  -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
	 signal REG_SEL_OUT_CPU :  STD_LOGIC_VECTOR(2 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!




    -- Señal auxiliar para sincronización
    signal DATA_BUS_IN_EXTERN_NEXT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Clock period
    constant CLK_PERIOD : time := 0.1 ns;

begin
		
		READY <= '1';
		RST <= '0';
		--process
		
		--begin
		--RST <= '1';
		--wait for 10 ns;
		--RST <= '0';
		--wait;
		
		--end process;
		
    -- Instancia de CPU2
    uut: CPU2
        port map (
            CLK => CLK,
				RST => RST,
            READY => READY,
            DATA_BUS_OUT => DATA_BUS_OUT,
            ADDRESS_BUS => ADDRESS_BUS,
            DATA_BUS_IN_EXTERN => DATA_BUS_IN_EXTERN,
            EXTERN_READ => EXTERN_READ,
            EXTERN_WRITE => EXTERN_WRITE,
           ROM_ADDR_OUT => ROM_ADDR_OUT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				ALU_OUT_EXT => ALU_OUT_EXT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				STAT_OUT => STAT_OUT,-- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				REG_SEL_OUT_CPU  => REG_SEL_OUT_CPU-- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!


		  );
		  
	RAM:   RAM_64Kx8 Port  map (
        clk     => CLK,                           -- Reloj
        we      => EXTERN_WRITE,                           -- Habilitación de escritura
        re      => EXTERN_READ,                           -- Habilitación de lectura
        address => ADDRESS_BUS,       -- Dirección de memoria (64K posiciones)
        data_out => DATA_BUS_IN_EXTERN,
		  data_in => DATA_BUS_OUT 
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

--    -- Proceso de sincronización del bus de datos externo
--    SYNC_DATA_BUS: process(CLK)
--    begin
--        if rising_edge(CLK) then
--            DATA_BUS_IN_EXTERN <= DATA_BUS_IN_EXTERN_NEXT;
--        end if;
--    end process;

--    -- Proceso de prueba
--    TEST_PROC: process
--    begin
--        -- Inicialización
--       
----        DATA_BUS_IN_EXTERN_NEXT <= X"10";  --instruction SUB to REG 0
----
----        wait for CLK_PERIOD;
----        DATA_BUS_IN_EXTERN_NEXT <= X"02"; --imm8
----
----			--------- TRY READY
----		  wait for CLK_PERIOD;
----		  ready <= '0';
----        --DATA_BUS_IN_EXTERN_NEXT <= X"C0"; --Instruction SHL
----		  
----		  wait for CLK_PERIOD * 4;
----		  DATA_BUS_IN_EXTERN_NEXT <= X"C0"; --instruction SHL to REG 0
----		  
----		  ready <= '1';
----		  wait for CLK_PERIOD;
----        DATA_BUS_IN_EXTERN_NEXT <= X"A9"; --instruction ADC to reg 001 (dst) with reg 000(src)
----		  
----		  wait for CLK_PERIOD * 4;
----		  DATA_BUS_IN_EXTERN_NEXT <= X"A8";
----		  
--		 
--			
--		 -- wait for CLK_PERIOD * 4;
--		  
--
--			
--        -- Finalizar simulación
--        wait;
--    end process;

end behavior;
