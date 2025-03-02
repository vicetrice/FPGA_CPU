LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CPU IS
	PORT (
		CLK : IN STD_LOGIC;
		READY : IN STD_LOGIC;
		DATA_BUS_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_BUS_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_BUS_IN_EXTERN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		EXTERN_READ: out STD_LOGIC;
		EXTERN_WRITE: out STD_LOGIC;
		ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END CPU;

ARCHITECTURE Behavioral OF CPU IS
	------------------------------------------------------------- CU
	COMPONENT Control_Unit

		-- DEMULTIPLEX read signals:
		-- 000: NOP
		-- 001: REGISTERS
		-- 010: RAM
		-- 011: ACC
		-- 100: FLAGS
		-- 101: PC
		PORT (
			-- CONTROL SIGNAL OUT --
			--1: Instruction register WE
			REN_0 : OUT STD_LOGIC; -- 2: Register Array read enable  (used to demultiplex reading)
			REG_ARR_WEN : OUT STD_LOGIC; -- 3: Register Array write enable  
			REN_1 : OUT STD_LOGIC; -- 4: Accumulator read enable  (used to demultiplex reading)
			ACC_WEN : OUT STD_LOGIC; -- 5: Accumulator write enable  
			TREG_EN : OUT STD_LOGIC; -- 6: Temporary Register enable  
			ALU_OE : OUT STD_LOGIC; -- 7: ALU output enable  
			INC_DEC_EN : OUT STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
			IP_WEN : OUT STD_LOGIC; -- 9: Instruction Pointer Write enable  
			REN_2 : OUT STD_LOGIC; -- 10: RAM read enable  (used to demultiplex reading)
			RAM_WEN : OUT STD_LOGIC; -- 11: RAM write enable  
			BYTE_SEL : OUT STD_LOGIC; -- 12: BYTE SELECT  
			--13: MIC RST
			FG_WEN : OUT STD_LOGIC; --14: FG_WEN

			-- SPECIAL OUTS --
			OPCODE_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit opcode output
			REG_SEL_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3-bit register select output

			-- INS --
			CLK : IN STD_LOGIC;
			INSTRUCTION : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			--STATUS_REG: in STD_LOGIC_VECTOR(7 downto 0);
			READY : IN STD_LOGIC
		);
	END COMPONENT;

	------------------------------------- ALU
	COMPONENT ALU
		PORT (
			A : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			B : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			opcode : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			StatIn : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			Result : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			StatOut : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;

	------------------------------------------------------- REGISTER ARRAY

	COMPONENT Reg_array
		PORT (
			REG_SEL : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- REGISTER SELECT
			DATA_OUT_BUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_IN_BUS : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			READ_REG : IN STD_LOGIC; -- READ SIGNAL
			WRITE_REG : IN STD_LOGIC; -- WRITE SIGNAL
			BYTE_SEL : IN STD_LOGIC; -- 0 = LSB, 1 = MSB
			INC_DEC_REG_EN : IN STD_LOGIC;
			CLK : IN STD_LOGIC
		);
	END COMPONENT;

	-- SPECIAL REGISTERS
	SIGNAL ACC_REG : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL IP_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL T_REG : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL FG_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

	-- CONTROL SIGNALS

	SIGNAL REN_0 : STD_LOGIC; -- 2:  (used to demultiplex reading)
	SIGNAL REG_ARR_WEN : STD_LOGIC; -- 3: Register Array write enable  
	SIGNAL REN_1 : STD_LOGIC; -- 4: (used to demultiplex reading)
	SIGNAL ACC_WEN : STD_LOGIC; -- 5: Accumulator write enable  
	SIGNAL TREG_EN : STD_LOGIC; -- 6: Temporary Register enable  
	SIGNAL ALU_OE : STD_LOGIC; -- 7: ALU output enable  
	SIGNAL INC_DEC_EN : STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
	SIGNAL IP_WEN : STD_LOGIC; -- 9: Instruction Pointer Write enable  
	SIGNAL REN_2 : STD_LOGIC; -- 10: (used to demultiplex reading)
	SIGNAL RAM_WEN : STD_LOGIC; -- 11: RAM write enable  
	SIGNAL BYTE_SEL : STD_LOGIC; -- 12: BYTE SELECT  
	SIGNAL FG_WEN : STD_LOGIC; --14: FG_WEN

	--SPECIAL SIGNALS
	SIGNAL OPCODE_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL REG_SEL_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL FG_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL ALU_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL REG_OUTS: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL READ_REG: STD_LOGIC;
	
BEGIN
	----------------------------------------------------------------- SPECIAL REGISTERS -----------------------------------------------------------------

	IP : PROCESS (CLK)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN

		IF rising_edge(CLK) THEN
			sel := REN_2 & REN_1 & REN_0;
			IF IP_WEN = '1' AND sel /= "101" THEN
				IF BYTE_SEL = '1' THEN
					IP_reg(15 DOWNTO 8) <= DATA_BUS_IN;
				ELSE
					IP_reg(7 DOWNTO 0) <= DATA_BUS_IN;
				END IF;
			ELSE
				IF INC_DEC_EN = '1' THEN
					IF IP_WEN = '1' AND sel = "101" THEN
						IP_reg <= STD_LOGIC_VECTOR(unsigned(IP_reg) + 1);
					ELSIF IP_WEN = '0' AND sel /= "101" THEN
						IP_reg <= STD_LOGIC_VECTOR(unsigned(IP_reg) - 1);
					END IF;
				END IF;
			END IF;
		
		END IF;

	END PROCESS;

	ACCM : PROCESS (CLK)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		IF rising_edge(CLK) THEN
			sel := REN_2 & REN_1 & REN_0;
			IF ACC_WEN = '1' AND sel /= "011" THEN
				ACC_REG <= DATA_BUS_IN;
			END IF;

		END IF;

	END PROCESS;

	TREG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF TREG_EN = '1' THEN
				T_REG <= DATA_BUS_IN;
			END IF;
		END IF;

	END PROCESS;

	FG : PROCESS (CLK)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		IF rising_edge(CLK) THEN
			sel := REN_2 & REN_1 & REN_0;
			IF FG_WEN = '1' AND sel /= "100" THEN
				FG_REG <= DATA_BUS_IN;
			ELSE
				FG_REG <= FG_OUT;
			END IF;

		END IF;
	END PROCESS;

	----------------------------------------------------------------------------------------------------------------------------------
	MUX_DATA_OUT : PROCESS (REN_0, REN_1, REN_2, ACC_REG, IP_reg, FG_REG, ALU_OUT,REG_OUTS,DATA_BUS_IN_EXTERN)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		sel := REN_2 & REN_1 & REN_0;
		CASE sel IS
			WHEN "001" =>
				DATA_BUS_OUT <= REG_OUTS;
			WHEN "011" =>
				DATA_BUS_OUT <= ACC_REG;
			WHEN "100" =>
				DATA_BUS_OUT <= FG_REG;
			WHEN "101" =>
				DATA_BUS_OUT <= IP_reg(7 DOWNTO 0);
			WHEN "010" =>
				DATA_BUS_OUT <= DATA_BUS_IN_EXTERN;
			WHEN OTHERS =>
				DATA_BUS_OUT <= (others => '1');
		END CASE;
	END PROCESS;

	------------------------------------ COMPONENTS ------------------------------------
	CU : Control_Unit PORT MAP(
		REN_0 => REN_0,
		REG_ARR_WEN => REG_ARR_WEN,
		REN_1 => REN_1,
		ACC_WEN => ACC_WEN,
		TREG_EN => TREG_EN,
		ALU_OE => ALU_OE,
		INC_DEC_EN => INC_DEC_EN,
		IP_WEN => IP_WEN,
		REN_2 => REN_2,
		RAM_WEN => RAM_WEN,
		BYTE_SEL => BYTE_SEL,
		FG_WEN => FG_WEN,
		OPCODE_OUT => OPCODE_OUT,
		REG_SEL_OUT => REG_SEL_OUT,

		CLK => CLK,
		INSTRUCTION => DATA_BUS_IN,
		--STATUS_REG		=> STATUS_REG,
		READY => READY
	);

	ArithLU : ALU PORT MAP(
		A => ACC_REG,
		B => T_REG,
		opcode => OPCODE_OUT,
		StatIn => FG_REG,
		Result => ALU_OUT,
		StatOut => FG_OUT
	);

	REGISTERS: REG_ARRAY PORT map (
			REG_SEL 		=> 	REG_SEL_OUT, 
			DATA_OUT_BUS 	=> REG_OUTS, 
			DATA_IN_BUS 	=> DATA_BUS_IN, 
			READ_REG 		=> READ_REG, 
			WRITE_REG 		=> REG_ARR_WEN, 
			BYTE_SEL 		=> BYTE_SEL, 
			INC_DEC_REG_EN 	=> INC_DEC_EN, 
			CLK 			=> CLK
		);	

	READ_REG <= '1' when (REN_2 & REN_1 & REN_0) = STD_LOGIC_VECTOR(to_unsigned(1, 3)) else '0';
	EXTERN_READ <= '1' when (REN_2 & REN_1 & REN_0) = STD_LOGIC_VECTOR(to_unsigned(2, 3)) and RAM_WEN = '0' else '0';
	EXTERN_WRITE <= '1' when (REN_2 & REN_1 & REN_0) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)) and RAM_WEN = '1' else '0';
	ADDRESS_BUS <= IP_REG;
	
END Behavioral;