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
    -- 110: ALU

    --MULTIPLEX ADDR_REG_OUT_BUS SIGNAL
    -- 00: IP
    -- 01: SP
    -- 10: LSB IR (IT ONLY PICK THE REG_SEL BITS OF IR LSB)
    -- 11: MSB IR (IT ONLY PICK THE REG_SEL BITS OF IR MSB)
    PORT (
        -- CONTROL SIGNAL OUT --
        --1: Instruction register WE
        REN_0 : OUT STD_LOGIC; -- 2:  (used to multiplex reading)
        REG_ARR_WEN : OUT STD_LOGIC; -- 3: Register Array write enable  
        REN_1 : OUT STD_LOGIC; -- 4:   (used to multiplex reading)
        ACC_WEN : OUT STD_LOGIC; -- 5: Accumulator write enable  
        TREG_EN : OUT STD_LOGIC; -- 6: Temporary Register enable  
        IR_REG_SEL_BYTE : OUT STD_LOGIC; -- 7: Select which byte of the 16-bit IR to use for register selection 0: LSB, 1:MSB.   
        INC_DEC_EN : OUT STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
        FINAL_ADDR_SEL : OUT STD_LOGIC; -- 9: SELECT FROM WHERE IS THE FINAL ADDRESS COMING: 0: REGISTER, 1:AUX ADDR REG.
        REN_2 : OUT STD_LOGIC; -- 10: (used to multiplex reading)
        RAM_WEN : OUT STD_LOGIC; -- 11: RAM write enable  
        BYTE_SEL : OUT STD_LOGIC; -- 12: BYTE SELECT  
        --13: MIC RST
        FG_WEN : OUT STD_LOGIC; --14: FG_WEN
        INC_DEC : OUT STD_LOGIC; --15: SELECT IF INC OR DEC 1:INC , 0: DEC
        FG_SEL_IN : OUT STD_LOGIC; --16: SELECT FROM WHERE TO WRITE IN THE FG REGISTER. 0: ALU, 1: INTERNAL BUS, it works as byte select for reg when ALU op
        --17: BYTE SELECT FOR INSTRUCTION REGISTER
        ADDR_SEL_0 : OUT STD_LOGIC;--18: MUX ADDR_REG_OUT_BUS SIGNAL
        LOAD_AUX_ADDR_REG : OUT STD_LOGIC; --19: IF 1: LOAD THE AUX ADDRESS REGISTER 
        AUX_ADDR_SEL_IN : OUT STD_LOGIC; --20: SELECT FROM WHICH PATH LOAD THE AUX ADDR REG, 0: REGISTER, 1:INTERNAL_DATA_BUS
        ADDR_SEL_1 : OUT STD_LOGIC; --21: MUX ADDR_REG_OUT_BUS SIGNAL

        -- SPECIAL OUTS --
        OPCODE_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit opcode output
        REG_SEL_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3-bit register select output
        RST_SYNC : OUT STD_LOGIC;
        REG_SEL_OUT_MSB : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        REG_SEL_OUT_LSB : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        --TESTS!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ROM_ADDR_OUT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!

        -- INS --
        CLK : IN STD_LOGIC;
        INSTRUCTION : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        ZFLAG : IN STD_LOGIC;
        READY : IN STD_LOGIC;
        RST : IN STD_LOGIC
    );
END Control_Unit;

ARCHITECTURE Behavioral OF Control_Unit IS

    -- Declaration of ROM component
    COMPONENT ROM_512x24
        PORT (
            address : IN STD_LOGIC_VECTOR(8 DOWNTO 0); -- 12-bit address (4K words)
            data_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0) -- 16-bit output
        );
    END COMPONENT;

    FOR ALL : ROM_512x24 USE ENTITY work.ROM_512x24;

    -- Internal signals
    SIGNAL addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0'); -- Address signal for ROM
    SIGNAL MIC : unsigned(3 DOWNTO 0) := (OTHERS => '0'); -- Micro Instruction Counter
    SIGNAL instruction_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Instruction register
    SIGNAL CONTROL_OUT : STD_LOGIC_VECTOR(23 DOWNTO 0) := (OTHERS => '0'); -- Control signal output from ROM
    SIGNAL JNZ : STD_LOGIC;
    SIGNAL RST_CYCLES : STD_LOGIC_VECTOR(6 DOWNTO 0);
	 SIGNAL SHR: STD_LOGIC;
BEGIN
    RST_ROUTINE : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF RST = '1' THEN

                RST_CYCLES <= (OTHERS => '1');
            ELSE
                RST_CYCLES <= '0' & RST_CYCLES(6 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;
    -- Instruction Register process (Store the instruction in the instruction register)
    INST_REG_MSB : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF (RST_CYCLES(6) = '1') THEN
                instruction_reg(15 DOWNTO 8) <= (OTHERS => '0'); -- LSB
            ELSIF CONTROL_OUT(0) = '1' AND CONTROL_OUT(16) = '1' THEN
                instruction_reg(15 DOWNTO 8) <= INSTRUCTION; -- MSB

            END IF;
        END IF;
    END PROCESS;

    INST_REG_LSB : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF (RST_CYCLES(6) = '1') THEN
                instruction_reg(7 DOWNTO 0) <= (OTHERS => '0'); -- LSB

            ELSIF CONTROL_OUT(0) = '1' AND CONTROL_OUT(16) = '0' THEN
                instruction_reg(7 DOWNTO 0) <= INSTRUCTION; -- LSB

            END IF;
        END IF;
    END PROCESS;

    -- Micro Instruction Counter process
    MI_COUNT : PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN

            IF RST_CYCLES(6) = '1' THEN
                MIC <= (OTHERS => '0');
            ELSE
                IF (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3))) THEN
                    IF CONTROL_OUT(12) = '0' THEN -- If bit 12 of CONTROL_OUT is '0'
                        MIC <= MIC + 1; -- Increment the micro instruction counter
                    ELSE
                        MIC <= to_unsigned(0, 4);
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Control logic process to generate the address and control signals

    CL : PROCESS (instruction_reg, MIC, RST_CYCLES)
        VARIABLE opcode : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE imm_or_reg : STD_LOGIC;
        --VARIABLE reg_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);

    BEGIN
        -- Extract opcode, immediate or register bit, and register selection from the instruction
        -- Construct the address for the microcode ROM
        -- Concatenate opcode, imm_or_reg, and MIC to form the address (12 bits)

        opcode := instruction_reg(7 DOWNTO 4);
        imm_or_reg := instruction_reg(3);

        --reg_sel := instruction_reg(2 DOWNTO 0);

        JNZ <= '0';
		  SHR <= '0';
        IF RST_CYCLES(0) = '1' THEN
            addr <= "11111" & STD_LOGIC_VECTOR(MIC);
        ELSE
            CASE opcode IS
                WHEN X"6" =>
                    addr <= "0001" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --MOV OP
                WHEN X"9" =>
                    addr <= "0010" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --JNZ OP
                    JNZ <= '1';
                WHEN X"B" =>
                    addr <= "0010" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --LEA OP
                WHEN X"8" =>
                    addr <= "0011" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --STR OP
					 WHEN X"C" =>
							addr <= "0000" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --SHL/SHR OP
							SHR <= imm_or_reg;
					 WHEN X"2" => 
							addr <= "0100" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --CMP OP
					 WHEN X"F" =>
							addr <= "0101" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --POP/POPF OP
					 WHEN X"D" =>
							addr <= "0110" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --PUSHF OP
					 WHEN X"7" =>
							addr <= "0111" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --LDR OP
					 WHEN X"E" =>
							addr <= "1000" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --PUSH OP					 
                WHEN OTHERS =>
                    addr <= "0000" & imm_or_reg & STD_LOGIC_VECTOR(MIC); --ALU OP (EXCEPT CMP)

            END CASE;
        END IF;

        -- Assign values to output signals
    END PROCESS;
    PROCESS (CONTROL_OUT(6), instruction_reg,SHR)
        VARIABLE opcode : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE reg_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    BEGIN

        IF CONTROL_OUT(6) = '0' THEN
            opcode := instruction_reg(7 DOWNTO 4);
            reg_sel := instruction_reg(2 DOWNTO 0);
        ELSE
            opcode := instruction_reg(15 DOWNTO 12);
            reg_sel := instruction_reg(10 DOWNTO 8);
        END IF;

        OPCODE_OUT <= opcode or (STD_LOGIC_VECTOR(to_unsigned(0,3)) & SHR);
        REG_SEL_OUT <= reg_sel;

    END PROCESS;
    REG_SEL_OUT_LSB <= instruction_reg(2 DOWNTO 0);
    REG_SEL_OUT_MSB <= instruction_reg(10 DOWNTO 8);

    -- ROM instantiation and connection
    U0 : ROM_512x24 PORT MAP(addr, CONTROL_OUT);
    REN_0 <= CONTROL_OUT(1)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; -- multiplex read

    REG_ARR_WEN <= CONTROL_OUT(2)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        AND (ZFLAG = '0' OR JNZ /= '1')
        ELSE
        '0'; -- Register Array Write Enable

    REN_1 <= CONTROL_OUT(3)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; -- multiplex read

    ACC_WEN <= CONTROL_OUT(4)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        AND (ZFLAG = '0' OR JNZ /= '1')
        ELSE
        '0'; -- Accumulator Write Enable

    TREG_EN <= CONTROL_OUT(5)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        AND (ZFLAG = '0' OR JNZ /= '1')
        ELSE
        '0'; -- Temporary Register Enable

    IR_REG_SEL_BYTE <= CONTROL_OUT(6)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; -- IR_REG_SEL_BYTE 

    INC_DEC_EN <= CONTROL_OUT(7)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; -- Instruction Pointer Increment/Decrement

    FINAL_ADDR_SEL <= CONTROL_OUT(8)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; -- Instruction Pointer Enable

    REN_2 <= CONTROL_OUT(9)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; -- multiplex read

    RAM_WEN <= CONTROL_OUT(10)
        WHEN ((CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        AND (ZFLAG = '0' OR JNZ /= '1')
        ELSE
        '0'; -- RAM Write Enable

    BYTE_SEL <= CONTROL_OUT(11)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; -- Byte Select

    FG_WEN <= CONTROL_OUT(13)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        AND (ZFLAG = '0' OR JNZ /= '1')
        ELSE
        '0'; --FG register WE;

    INC_DEC <= CONTROL_OUT(14)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; --SELECT IF INC OR DEC 1:INC , 0: DEC

    FG_SEL_IN <= CONTROL_OUT(15)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0'; --SELECT FROM WHERE TO WRITE IN THE FG REGISTER. 0: ALU, 1: INTERNAL BUS

    ADDR_SEL_0 <= CONTROL_OUT(17)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0';

    LOAD_AUX_ADDR_REG <= CONTROL_OUT(18)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0';

    AUX_ADDR_SEL_IN <= CONTROL_OUT(19)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0';

    ADDR_SEL_1 <= CONTROL_OUT(20)
        WHEN (READY /= '0' OR (CONTROL_OUT(9) & CONTROL_OUT(3) & CONTROL_OUT(1)) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)))
        ELSE
        '0';

    ROM_ADDR_OUT <= addr; -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
    RST_SYNC <= RST_CYCLES(6);
END Behavioral;