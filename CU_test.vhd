library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Control_Unit is
end tb_Control_Unit;

architecture behavior of tb_Control_Unit is

    -- Component declaration of the Control Unit
    component Control_Unit
        port(
            REG_ARR_REN: out STD_LOGIC;
            REG_ARR_WEN: out STD_LOGIC;
            ACC_REN: out STD_LOGIC;
            ACC_WEN: out STD_LOGIC;
            TREG_EN: out STD_LOGIC;
            ALU_OE: out STD_LOGIC;
            IP_INC_DEC: out STD_LOGIC;
            IP_EN: out STD_LOGIC;
            RAM_REN: out STD_LOGIC;
            RAM_WEN: out STD_LOGIC;
            BYTE_SEL: out STD_LOGIC;
            OPCODE_OUT: out STD_LOGIC_VECTOR(3 downto 0);
            REG_SEL_OUT: out STD_LOGIC_VECTOR(2 downto 0);
						COUNTER_MICRO_TEST: out STD_LOGIC_VECTOR(11 downto 0); --BORRAR DESPUES SOLO PARA TESTS!!!!!!!!!!!!!!
            CLK: in STD_LOGIC;
            INSTRUCTION: in STD_LOGIC_VECTOR(7 downto 0);
            READY: in STD_LOGIC
        );
    end component;

    -- Signals to drive the Control Unit
    signal REG_ARR_REN: STD_LOGIC;
    signal REG_ARR_WEN: STD_LOGIC;
    signal ACC_REN: STD_LOGIC;
    signal ACC_WEN: STD_LOGIC;
    signal TREG_EN: STD_LOGIC;
    signal ALU_OE: STD_LOGIC;
    signal IP_INC_DEC: STD_LOGIC;
    signal IP_EN: STD_LOGIC;
    signal RAM_REN: STD_LOGIC;
    signal RAM_WEN: STD_LOGIC;
    signal BYTE_SEL: STD_LOGIC;
    signal OPCODE_OUT: STD_LOGIC_VECTOR(3 downto 0);
    signal REG_SEL_OUT: STD_LOGIC_VECTOR(2 downto 0);
    signal CLK: STD_LOGIC := '0';  -- Clock signal
    signal INSTRUCTION: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');  -- Default instruction
    signal READY: STD_LOGIC := '0';  -- Default value for READY signal
	 signal COUNTER_MICRO_TEST: STD_LOGIC_VECTOR(11 downto 0); --BORRAR DESPUES SOLO PARA TESTS!!!!!!!!!!!!!!


    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Control Unit
    uut: Control_Unit
        port map(
            REG_ARR_REN => REG_ARR_REN,
            REG_ARR_WEN => REG_ARR_WEN,
            ACC_REN => ACC_REN,
            ACC_WEN => ACC_WEN,
            TREG_EN => TREG_EN,
            ALU_OE => ALU_OE,
            IP_INC_DEC => IP_INC_DEC,
            IP_EN => IP_EN,
            RAM_REN => RAM_REN,
            RAM_WEN => RAM_WEN,
            BYTE_SEL => BYTE_SEL,
            OPCODE_OUT => OPCODE_OUT,
				COUNTER_MICRO_TEST => COUNTER_MICRO_TEST,
            REG_SEL_OUT => REG_SEL_OUT,
            CLK => CLK,
            INSTRUCTION => INSTRUCTION,
            READY => READY
        );

    -- Clock process (toggle every 10 ns)
    CLK_PROCESS: process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Test process
    TEST_PROC: process
    begin
        -- Test Case 1: Set initial instruction and READY
        INSTRUCTION <= "00000001"; -- Example instruction
        READY <= '1';  -- Indicate that the control unit is ready
        wait for CLK_PERIOD;

        -- Test Case 2: Change instruction and assert READY, also see if IR_EN works
        INSTRUCTION <= "00010010"; -- Another instruction
        READY <= '1';  -- Continue with READY
        wait for CLK_PERIOD;

        -- Test Case 3: De-assert READY and check behavior, also see if MIC_RST works
        READY <= '0';  -- Set READY to '0' to see how the unit behaves
        INSTRUCTION <= "00110011"; -- Another example instruction
        wait for CLK_PERIOD;

        -- Test Case 4: Reassert READY
        READY <= '1';  -- Reassert READY
        INSTRUCTION <= "01010101"; -- Another example instruction
        wait for CLK_PERIOD;

        -- Finish the simulation
        wait;
    end process;

end behavior;
