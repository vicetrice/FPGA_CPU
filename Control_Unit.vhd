library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit is

    -- DEMULTIPLEX read signals:
    -- 000: NOP
    -- 001: REGISTERS
    -- 010: RAM
    -- 011: ACC
    -- 100: FLAGS
    -- 101: PC
    port(
        -- CONTROL SIGNAL OUT --
													--1: Instruction register WE
        REN_0: out STD_LOGIC;          -- 2: Register Array read enable  (used to demultiplex reading)
        REG_ARR_WEN: out STD_LOGIC;    -- 3: Register Array write enable  
        REN_1: out STD_LOGIC;          -- 4: Accumulator read enable  (used to demultiplex reading)
        ACC_WEN: out STD_LOGIC;        -- 5: Accumulator write enable  
        TREG_EN: out STD_LOGIC;        -- 6: Temporary Register enable  
        ALU_OE: out STD_LOGIC;         -- 7: ALU output enable  
        INC_DEC_EN: out STD_LOGIC;     -- 8: Instruction Pointer increment/decrement control  
        IP_WEN: out STD_LOGIC;          -- 9: Instruction Pointer Write enable  
        REN_2: out STD_LOGIC;          -- 10: RAM read enable  (used to demultiplex reading)
        RAM_WEN: out STD_LOGIC;        -- 11: RAM write enable  
        BYTE_SEL: out STD_LOGIC;       -- 12: BYTE SELECT  
													--13: MIC RST
		 FG_WEN: out STD_LOGIC;				--14: FG_WEN

        -- SPECIAL OUTS --
        OPCODE_OUT: out STD_LOGIC_VECTOR(3 downto 0);  -- 4-bit opcode output
        REG_SEL_OUT: out STD_LOGIC_VECTOR(2 downto 0);  -- 3-bit register select output

        -- INS --
        CLK: in STD_LOGIC;
        INSTRUCTION: in STD_LOGIC_VECTOR(7 downto 0);
        --STATUS_REG: in STD_LOGIC_VECTOR(7 downto 0);
        READY: in STD_LOGIC
    );
end Control_Unit;

architecture Behavioral of Control_Unit is

    -- Declaration of ROM component
    component ROM_4Kx16
        Port ( 
            address : in  std_logic_vector(11 downto 0);  -- 12-bit address (4K words)
            data_out : out std_logic_vector(15 downto 0)  -- 16-bit output
        );
    end component;

    for all: ROM_4Kx16 use entity work.ROM_4Kx16;

    -- Internal signals
    signal addr: STD_LOGIC_VECTOR(11 downto 0);    -- Address signal for ROM
    signal MIC: unsigned(6 downto 0) := (others => '0');  -- Micro Instruction Counter
    signal instruction_reg: STD_LOGIC_VECTOR(7 downto 0);  -- Instruction register
    signal CONTROL_OUT: STD_LOGIC_VECTOR(15 downto 0);    -- Control signal output from ROM
begin

    -- Instruction Register process (Store the instruction in the instruction register)
    INST_REG: process(CLK)
    begin
        if rising_edge(CLK) then
		  if CONTROL_OUT(0) = '1' then
            instruction_reg <= INSTRUCTION;  -- Store incoming instruction
			end if;
        end if;
    end process;

    -- Micro Instruction Counter process
    MI_COUNT: process(CLK, READY)
    begin
        if rising_edge(CLK) and READY = '1' then
            if CONTROL_OUT(12) = '0' then  -- If bit 12 of CONTROL_OUT is '0'
                MIC <= MIC + 1;  -- Increment the micro instruction counter
            else
                MIC <= (others => '0');  -- Reset MIC to zero if bit 12 of CONTROL_OUT is '1'
            end if;
        end if;
    end process;

    -- Control logic process to generate the address and control signals
    CL: process(instruction_reg, MIC)
        variable opcode: STD_LOGIC_VECTOR(3 downto 0);
        variable imm_or_reg: STD_LOGIC;
		  variable reg_sel: STD_LOGIC_VECTOR(2 downto 0);
       
    begin
        -- Extract opcode, immediate or register bit, and register selection from the instruction
        opcode := instruction_reg(7 downto 4);
        imm_or_reg := instruction_reg(3);
		  reg_sel := instruction_reg(2 downto 0);
       
        
        -- Construct the address for the microcode ROM
        -- Concatenate opcode, imm_or_reg, and MIC to form the address (12 bits)
        if (opcode = X"0" or opcode = X"1" or opcode = X"2" or opcode = X"3" or
            opcode = X"4" or opcode = X"5" or opcode = X"A" or opcode = X"C" or opcode = X"D") then
            addr <= opcode & imm_or_reg & std_logic_vector(MIC);  -- Address formed by opcode, imm_or_reg, and MIC
        else
            addr <= reg_sel & "000000000"  ;  -- Set address to 0 in case opcode is not recognized
        end if;

        -- Assign values to output signals
        OPCODE_OUT <= opcode;
		  REG_SEL_OUT <= reg_sel;
    end process;
	 

    -- ROM instantiation and connection
    U0: ROM_4Kx16 port map(addr, CONTROL_OUT);

    -- Assign control signals based on the ROM output
    REN_0      <= CONTROL_OUT(1);   -- Register Array Read Enable
    REG_ARR_WEN <= CONTROL_OUT(2);  -- Register Array Write Enable
    REN_1      <= CONTROL_OUT(3);   -- Accumulator Read Enable
    ACC_WEN    <= CONTROL_OUT(4);   -- Accumulator Write Enable
    TREG_EN    <= CONTROL_OUT(5);   -- Temporary Register Enable
    ALU_OE     <= CONTROL_OUT(6);   -- ALU Output Enable
    INC_DEC_EN <= CONTROL_OUT(7);   -- Instruction Pointer Increment/Decrement
    IP_WEN      <= CONTROL_OUT(8);   -- Instruction Pointer Enable
    REN_2      <= CONTROL_OUT(9);   -- RAM Read Enable
    RAM_WEN    <= CONTROL_OUT(10);  -- RAM Write Enable
    BYTE_SEL   <= CONTROL_OUT(11);  -- Byte Select
	 FG_WEN 		<= CONTROL_OUT(13);  --FG register WE;

end Behavioral;
