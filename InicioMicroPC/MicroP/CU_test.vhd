library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Control_Unit is
end tb_Control_Unit;

architecture behavior of tb_Control_Unit is

    -- Component declaration of the Control Unit
    component Control_Unit
        port(
            REN_0: out STD_LOGIC;
            REG_ARR_WEN: out STD_LOGIC;
            REN_1: out STD_LOGIC;
            ACC_WEN: out STD_LOGIC;
            TREG_EN: out STD_LOGIC;
            FREE_USE: out STD_LOGIC;
            INC_DEC_EN: out STD_LOGIC;
            IP_WEN: out STD_LOGIC;
            REN_2: out STD_LOGIC;
            RAM_WEN: out STD_LOGIC;
            BYTE_SEL: out STD_LOGIC;
            FG_WEN: out STD_LOGIC;
            INC_DEC: out STD_LOGIC;
            OPCODE_OUT: out STD_LOGIC_VECTOR(3 downto 0);
            REG_SEL_OUT: out STD_LOGIC_VECTOR(2 downto 0);
            CLK: in STD_LOGIC;
            INSTRUCTION: in STD_LOGIC_VECTOR(7 downto 0);
            READY: in STD_LOGIC
        );
    end component;

    -- Signals to drive the Control Unit
    signal REN_0, REG_ARR_WEN, REN_1, ACC_WEN, TREG_EN, FREE_USE: STD_LOGIC;
    signal INC_DEC_EN, IP_WEN, REN_2, RAM_WEN, BYTE_SEL, FG_WEN, INC_DEC: STD_LOGIC;
    signal OPCODE_OUT: STD_LOGIC_VECTOR(3 downto 0);
    signal REG_SEL_OUT: STD_LOGIC_VECTOR(2 downto 0);
    signal CLK: STD_LOGIC := '0';
    signal INSTRUCTION: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal READY: STD_LOGIC := '0';

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Control Unit
    uut: Control_Unit
        port map(
            REN_0 => REN_0,
            REG_ARR_WEN => REG_ARR_WEN,
            REN_1 => REN_1,
            ACC_WEN => ACC_WEN,
            TREG_EN => TREG_EN,
            FREE_USE => FREE_USE,
            INC_DEC_EN => INC_DEC_EN,
            IP_WEN => IP_WEN,
            REN_2 => REN_2,
            RAM_WEN => RAM_WEN,
            BYTE_SEL => BYTE_SEL,
            FG_WEN => FG_WEN,
            INC_DEC => INC_DEC,
            OPCODE_OUT => OPCODE_OUT,
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
        INSTRUCTION <= "00000001";
        READY <= '1';
        wait for CLK_PERIOD;

        -- Test Case 2: Change instruction and assert READY
        INSTRUCTION <= "00010010";
        READY <= '1';
        wait for CLK_PERIOD;

        -- Test Case 3: De-assert READY and check behavior
        READY <= '0';
        INSTRUCTION <= "00110011";
        wait for CLK_PERIOD;

        -- Test Case 4: Reassert READY
        READY <= '1';
        INSTRUCTION <= "01010101";
        wait for CLK_PERIOD;

        -- Finish the simulation
        wait;
    end process;

end behavior;