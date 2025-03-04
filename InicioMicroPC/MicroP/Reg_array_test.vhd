LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_Reg_array IS
END tb_Reg_array;

ARCHITECTURE behavior OF tb_Reg_array IS
    -- Signals for connecting to the Reg_array entity
    SIGNAL REG_SEL: STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register selector
    SIGNAL DATA_OUT_BUS: STD_LOGIC_VECTOR(7 DOWNTO 0); -- Output data bus
    SIGNAL DATA_IN_BUS: STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input data bus
    SIGNAL READ_REG: STD_LOGIC;  -- Read signal
    SIGNAL WRITE_REG: STD_LOGIC; -- Write signal
    SIGNAL BYTE_SEL: STD_LOGIC; -- 0 = LSB, 1 = MSB
    SIGNAL CLK: STD_LOGIC := '0'; -- Clock signal

    -- Reg_array component
    COMPONENT Reg_array
        PORT(
            REG_SEL: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            DATA_OUT_BUS: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            DATA_IN_BUS: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            READ_REG: IN STD_LOGIC;
            WRITE_REG: IN STD_LOGIC;
            BYTE_SEL: IN STD_LOGIC;
            CLK: IN STD_LOGIC
        );
    END COMPONENT;

    FOR ALL: Reg_array USE ENTITY work.Reg_array(Behavioral2);
    
BEGIN
    -- Instantiating the Reg_array component
    uut: Reg_array PORT MAP(
        REG_SEL => REG_SEL,
        DATA_OUT_BUS => DATA_OUT_BUS,
        DATA_IN_BUS => DATA_IN_BUS,
        READ_REG => READ_REG,
        WRITE_REG => WRITE_REG,
        BYTE_SEL => BYTE_SEL,
        CLK => CLK
    );

    -- Clock generation process
    clock_process: PROCESS
    BEGIN
        CLK <= '0';
        WAIT FOR 10 ns;
        CLK <= '1';
        WAIT FOR 10 ns;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Signal initialization
        REG_SEL <= "111"; -- Select register 7
        WRITE_REG <= '0'; 
        READ_REG <= '0';  
        BYTE_SEL <= '0';  
        DATA_IN_BUS <= (others => '0');

        -- Wait for clock cycle
        WAIT FOR 20 ns;

        -- Write to LSB of register 7
        WRITE_REG <= '1';
        DATA_IN_BUS <= "10101010"; -- 0xAA
        WAIT FOR 20 ns;
        WRITE_REG <= '0';

        -- Read LSB of register 7
        READ_REG <= '1';
        WAIT FOR 20 ns;
        READ_REG <= '0';

        -- Write to MSB of register 7
        BYTE_SEL <= '1';  
        WRITE_REG <= '1';
        DATA_IN_BUS <= "11001100"; -- 0xCC
        WAIT FOR 20 ns;
        WRITE_REG <= '0';

        -- Read MSB of register 7
        READ_REG <= '1';
        WAIT FOR 20 ns;
        READ_REG <= '0';

        -- Read LSB again
        READ_REG <= '1';
        BYTE_SEL <= '0';
        WAIT FOR 20 ns;
        READ_REG <= '0';

        -- Write to register 6
        REG_SEL <= "110"; 
        WRITE_REG <= '1';
        DATA_IN_BUS <= X"BB"; 
        WAIT FOR 20 ns;
        WRITE_REG <= '0';

        -- Write to MSB of register 6
        BYTE_SEL <= '1';
        WRITE_REG <= '1';
        DATA_IN_BUS <= X"FF";
        WAIT FOR 20 ns;
        WRITE_REG <= '0';

        -- Read register 6
        READ_REG <= '1';
		  BYTE_SEL <= '0';
        WAIT FOR 20 ns;
		  
        -- Read register 6
        READ_REG <= '1';
		  BYTE_SEL <= '1';
        WAIT FOR 20 ns;

        -- Stop simulation
        WAIT;
    END PROCESS;

END behavior;
