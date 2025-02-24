LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_Reg_array IS
END tb_Reg_array;

ARCHITECTURE behavior OF tb_Reg_array IS
    -- Signals for connecting to the Reg_array entity
    SIGNAL REG_SEL: STD_LOGIC_VECTOR(2 DOWNTO 0); -- Register selector
    SIGNAL DATA_BUS: STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data bus
    SIGNAL READ_REG: STD_LOGIC;  -- Read signal
    SIGNAL WRITE_REG: STD_LOGIC; -- Write signal
    SIGNAL BYTE_SEL: STD_LOGIC; -- 0 = LSB, 1 = MSB
    SIGNAL INC_DEC_REG: STD_LOGIC_VECTOR(1 DOWNTO 0); -- Increment/Decrement control
    SIGNAL CLK: STD_LOGIC := '0'; -- Clock signal

    -- Reg_array component
    COMPONENT Reg_array
        PORT(
            REG_SEL: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            DATA_BUS: INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            READ_REG: IN STD_LOGIC;
            WRITE_REG: IN STD_LOGIC;
            BYTE_SEL: IN STD_LOGIC;
            INC_DEC_REG: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            CLK: IN STD_LOGIC
        );
    END COMPONENT;
    
BEGIN
    -- Instantiating the Reg_array component
    uut: Reg_array PORT MAP(
        REG_SEL => REG_SEL,
        DATA_BUS => DATA_BUS,
        READ_REG => READ_REG,
        WRITE_REG => WRITE_REG,
        BYTE_SEL => BYTE_SEL,
        INC_DEC_REG => INC_DEC_REG,
        CLK => CLK
    );

    -- Clock generation in a concurrent process
    clock_process: PROCESS
    BEGIN
        -- Generating a 10 ns clock
        CLK <= '0';
        WAIT FOR 10 ns;
        CLK <= '1';
        WAIT FOR 10 ns;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Signal initialization
        REG_SEL <= "111"; -- Select register 0
        WRITE_REG <= '0'; -- Do not write initially
        READ_REG <= '0';  -- Do not read initially
        BYTE_SEL <= '0';  -- Select LSB (least significant byte)
        INC_DEC_REG <= "00"; -- Initialize increment/decrement control
        DATA_BUS <= (others => 'Z'); -- Data bus in high impedance

        -- Wait for one clock cycle
        WAIT FOR 20 ns;

        -- Write value to LSB of register 8
        WRITE_REG <= '1'; -- Enable write
        DATA_BUS <= "10101010"; -- Data to write (0xAA)
        WAIT FOR 20 ns;

        -- Disable write and wait one cycle
        WRITE_REG <= '0';
        DATA_BUS <= (others => 'Z'); -- Data bus in high impedance
        WAIT FOR 20 ns;

        -- Read value from LSB of register 0
        READ_REG <= '1'; -- Enable read
        WAIT FOR 20 ns;
        
        -- Disable read and wait
        READ_REG <= '0';
        WAIT FOR 20 ns;

        -- Now test with the MSB:
        -- Change to BYTE_SEL = '1' to select the MSB
        BYTE_SEL <= '1';  -- Select MSB (most significant byte)
        
        -- Write value to MSB of register 0
        WRITE_REG <= '1'; -- Enable write
        DATA_BUS <= "11001100"; -- Data to write (0xCC)
        WAIT FOR 20 ns;

        -- Disable write and wait one cycle
        WRITE_REG <= '0';
        DATA_BUS <= (others => 'Z'); -- Data bus in high impedance
        WAIT FOR 20 ns;

        -- Read value from MSB of register 0
        READ_REG <= '1'; -- Enable read
        WAIT FOR 20 ns;
        
        -- Disable read and wait
        READ_REG <= '0';
        WAIT FOR 20 ns;
        
        -- Increment a register
        INC_DEC_REG <= "11"; -- Increment signal
        WAIT FOR 20 ns;
        
        -- Decrement the register
        INC_DEC_REG <= "10"; -- Decrement signal
        WAIT FOR 20 ns;
        
        -- Read the value again after increment/decrement
        READ_REG <= '1'; -- Enable read
        BYTE_SEL <= '0'; -- Select LSB
        WAIT FOR 20 ns;

        -- Finalization
        WAIT;
    END PROCESS;

END behavior;
