library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit is
port(
		-- CONTROL SIGNAL OUT --
		--1: IR_WEN
		REG_ARR_REN: out STD_LOGIC; -- 2: Register Array read enable  
		REG_ARR_WEN: out STD_LOGIC; -- 3: Register Array write enable  
		ACC_REN: out STD_LOGIC;     -- 4: Accumulator read enable  
		ACC_WEN: out STD_LOGIC;     -- 5: Accumulator write enable  
		TREG_EN: out STD_LOGIC;     -- 6: Temporary Register enable  
		ALU_OE: out STD_LOGIC;      -- 7: ALU output enable  
		IP_INC_DEC: out STD_LOGIC;  -- 8: Instruction Pointer increment/decrement control  
		IP_EN: out STD_LOGIC;       -- 9: Instruction Pointer enable  
		RAM_REN: out STD_LOGIC;     -- 10: RAM read enable  
		RAM_WEN: out STD_LOGIC;     -- 11: RAM write enable  
		BYTE_SEL: out STD_LOGIC;    -- 12: BYTE SELECT  
		--13: MIC RST
		

		-- SPECIAL OUTS --
		OPCODE_OUT: out STD_LOGIC_VECTOR(3 downto 0);
		REG_SEL_OUT: out STD_LOGIC_VECTOR(2 downto 0);
		--COUNTER_MICRO_TEST: out STD_LOGIC_VECTOR(11 downto 0); --BORRAR DESPUES SOLO PARA TESTS!!!!!!!!!!!!!!
		
		-- INS --
		CLK: in STD_LOGIC;
		INSTRUCTION: in STD_LOGIC_VECTOR(7 downto 0);
		READY: in STD_LOGIC
);
end Control_Unit;

architecture Behavioral of Control_Unit is

component ROM_4Kx16
	Port ( 
		address : in  std_logic_vector(11 downto 0);  -- 12-bit address (4K words)
		data_out : out std_logic_vector(15 downto 0)  -- 16-bit output
	);
end component;

-- Internal signals
signal addr: STD_LOGIC_VECTOR(11 downto 0);
signal MIC: unsigned(6 downto 0) := (others => '0');  -- MIC as Micro Instruction Counter
signal instruction_reg: STD_LOGIC_VECTOR(7 downto 0);
signal CONTROL_OUT: STD_LOGIC_VECTOR(15 downto 0);

begin
	
	
	INST_REG: process(CLK, CONTROL_OUT(0))
	begin
	if rising_edge(CLK) and CONTROL_OUT(0) = '1' then
				instruction_reg <= INSTRUCTION; 
	end if;
	end process;
	
	MI_COUNT:process(CLK, READY)
	begin
	
			if rising_edge(CLK) and READY = '1' then
				if CONTROL_OUT(12) /= '1' then  
					MIC <= MIC + 1;  -- Increment MIC
				else
					MIC <= (others => '0'); 
				end if;
			end if;
	
	end process;
	
	CL: process(instruction_reg, MIC)
		variable opcode: STD_LOGIC_VECTOR(3 downto 0);
		variable imm_or_reg: STD_LOGIC;
		variable reg_sel: STD_LOGIC_VECTOR(2 downto 0);
	begin
				
		

			-- Extract opcode and other fields from the instruction register
			opcode := instruction_reg(7 downto 4);
			imm_or_reg := instruction_reg(3);
			reg_sel := instruction_reg(2 downto 0);
			  
			-- Construct the address for the microcode ROM
			-- Convert the opcode (std_logic_vector) to natural type (integer) and then to unsigned
			if (opcode = X"0" or opcode = X"1" or opcode = X"2" or opcode = X"3" or
				opcode = X"4" or opcode = X"5" or opcode = X"A" or opcode = X"C" or opcode = X"D") then
				-- Concatenate opcode, imm_or_reg, and MIC to form the address (12 bits)
				addr <= opcode & imm_or_reg & std_logic_vector(MIC);
			else
				addr <= (others => '0');
			end if;
			  
			-- Assign values to output signals
			REG_SEL_OUT <= reg_sel;
			OPCODE_OUT <= opcode;
			
		
	end process;

	--COUNTER_MICRO_TEST <= addr; --BORRAR DESPUES SOLO PARA TESTS!!!!!!!!!!!!!!!
	-- Map the ROM with the generated address
	U0: ROM_4Kx16 port map(addr, CONTROL_OUT);

	-- Assign control signals based on the ROM output
	REG_ARR_REN <= CONTROL_OUT(1);
	REG_ARR_WEN <= CONTROL_OUT(2);
	ACC_REN     <= CONTROL_OUT(3);
	ACC_WEN     <= CONTROL_OUT(4);
	TREG_EN     <= CONTROL_OUT(5);
	ALU_OE      <= CONTROL_OUT(6);
	IP_INC_DEC  <= CONTROL_OUT(7);
	IP_EN       <= CONTROL_OUT(8);
	RAM_REN     <= CONTROL_OUT(9);
	RAM_WEN     <= CONTROL_OUT(10);
	BYTE_SEL    <= CONTROL_OUT(11);

end Behavioral;
