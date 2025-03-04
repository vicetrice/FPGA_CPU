LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Control_Unit IS

    -- MULTIPLEX read signals:
    -- 000: NOP
    -- 001: REGISTERS
    -- 010: RAM
    -- 011: ACC
    -- 100: FLAGS
    -- 101: PC
    -- 110: ALU
    PORT (
        -- CONTROL SIGNAL OUT --
        --1: Instruction register WE
        REN_0 : OUT STD_LOGIC; -- 2:  (used to multiplex reading)
        REG_ARR_WEN : OUT STD_LOGIC; -- 3: Register Array write enable  
        REN_1 : OUT STD_LOGIC; -- 4:   (used to multiplex reading)
        ACC_WEN : OUT STD_LOGIC; -- 5: Accumulator write enable  
        TREG_EN : OUT STD_LOGIC; -- 6: Temporary Register enable  
        FREE_USE : OUT STD_LOGIC; -- 7: FREE_USE   
        INC_DEC_EN : OUT STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
        IP_WEN : OUT STD_LOGIC; -- 9: Instruction Pointer Write enable  
        REN_2 : OUT STD_LOGIC; -- 10: (used to multiplex reading)
        RAM_WEN : OUT STD_LOGIC; -- 11: RAM write enable  
        BYTE_SEL : OUT STD_LOGIC; -- 12: BYTE SELECT  
        --13: MIC RST
        FG_WEN : OUT STD_LOGIC; --14: FG_WEN
		  INC_DEC: OUT STD_LOGIC;		--15: SELECT IF INC OR DEC 1:INC , 0: DEC

        -- SPECIAL OUTS --
        OPCODE_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit opcode output
        REG_SEL_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3-bit register select output
		  
		  --TESTS!!!!!!!!!!!!!!!!!!!!!!!!!!!
		  MIC_OUT: OUT STD_LOGIC_VECTOR(6 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!

        -- INS --
        CLK : IN STD_LOGIC;
        INSTRUCTION : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        --STATUS_REG: in STD_LOGIC_VECTOR(7 downto 0);
        READY : IN STD_LOGIC
    );
END Control_Unit;

ARCHITECTURE Behavioral OF Control_Unit IS

    -- Declaration of ROM component
    COMPONENT ROM_4Kx16
        PORT (
            address : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- 12-bit address (4K words)
            data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- 16-bit output
        );
    END COMPONENT;

    FOR ALL : ROM_4Kx16 USE ENTITY work.ROM_4Kx16;

    -- Internal signals
    SIGNAL addr : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0') ; -- Address signal for ROM
    SIGNAL MIC : unsigned(6 DOWNTO 0) := (OTHERS => '0'); -- Micro Instruction Counter
    SIGNAL instruction_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Instruction register
    SIGNAL CONTROL_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Control signal output from ROM
BEGIN

    -- Instruction Register process (Store the instruction in the instruction register)
    INST_REG : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF CONTROL_OUT(0) = '1' THEN
                instruction_reg <= INSTRUCTION; -- Store incoming instruction
            END IF;
        END IF;
    END PROCESS;

    -- Micro Instruction Counter process
    MI_COUNT : PROCESS (CLK, READY)
    BEGIN
        IF rising_edge(CLK) AND READY = '1' THEN
            IF CONTROL_OUT(12) = '0' THEN -- If bit 12 of CONTROL_OUT is '0'
                MIC <= MIC + 1; -- Increment the micro instruction counter
            ELSE
                MIC <= (OTHERS => '0'); -- Reset MIC to zero if bit 12 of CONTROL_OUT is '1'
            END IF;
        END IF;
    END PROCESS;

    -- Control logic process to generate the address and control signals
    CL : PROCESS (instruction_reg, MIC)
        VARIABLE opcode : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE imm_or_reg : STD_LOGIC;
        VARIABLE reg_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);

    BEGIN
        -- Extract opcode, immediate or register bit, and register selection from the instruction
        opcode := instruction_reg(7 DOWNTO 4);
        imm_or_reg := instruction_reg(3);
        reg_sel := instruction_reg(2 DOWNTO 0);
        -- Construct the address for the microcode ROM
        -- Concatenate opcode, imm_or_reg, and MIC to form the address (12 bits)
        IF (opcode = X"0" OR opcode = X"1" OR opcode = X"2" OR opcode = X"3" OR
            opcode = X"4" OR opcode = X"5" OR opcode = X"A" OR opcode = X"C" OR opcode = X"D") THEN
            addr <= opcode & imm_or_reg & STD_LOGIC_VECTOR(MIC); -- Address formed by opcode, imm_or_reg, and MIC
        ELSE
            addr <= reg_sel & "000000000"; -- Set address to 0 in case opcode is not recognized
        END IF;

        -- Assign values to output signals
        OPCODE_OUT <= opcode;
        REG_SEL_OUT <= reg_sel;
    END PROCESS;
    -- ROM instantiation and connection
    U0 : ROM_4Kx16 PORT MAP(addr, CONTROL_OUT);

    -- Assign control signals based on the ROM output
    REN_0 <= CONTROL_OUT(1); -- multiplex read
    REG_ARR_WEN <= CONTROL_OUT(2); -- Register Array Write Enable
    REN_1 <= CONTROL_OUT(3); -- multiplex read
    ACC_WEN <= CONTROL_OUT(4); -- Accumulator Write Enable
    TREG_EN <= CONTROL_OUT(5); -- Temporary Register Enable
    FREE_USE <= CONTROL_OUT(6); -- FREE_USE 
    INC_DEC_EN <= CONTROL_OUT(7) when READY = '1' else '0'; -- Instruction Pointer Increment/Decrement
    IP_WEN <= CONTROL_OUT(8); -- Instruction Pointer Enable
    REN_2 <= CONTROL_OUT(9); -- multiplex read
    RAM_WEN <= CONTROL_OUT(10); -- RAM Write Enable
    BYTE_SEL <= CONTROL_OUT(11); -- Byte Select
    FG_WEN <= CONTROL_OUT(13); --FG register WE;
	 INC_DEC <= CONTROL_OUT(14); --SELECT IF INC OR DEC 1:INC , 0: DEC
	 
	 MIC_OUT <= STD_LOGIC_VECTOR(MIC); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!


END Behavioral;