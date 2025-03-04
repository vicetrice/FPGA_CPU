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
		EXTERN_READ : OUT STD_LOGIC;
		EXTERN_WRITE : OUT STD_LOGIC;
		ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)--;
		--MIC_OUT: OUT STD_LOGIC_VECTOR(6 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		--ALU_OUT_EXT: OUT STD_LOGIC_VECTOR(7 downto 0) -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!

	);
END CPU;

ARCHITECTURE Behavioral OF CPU IS
	------------------------------------------------------------- CU
	COMPONENT Control_Unit

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
			REN_0 : OUT STD_LOGIC; -- 2:   (used to multiplex reading)
			REG_ARR_WEN : OUT STD_LOGIC; -- 3: Register Array write enable  
			REN_1 : OUT STD_LOGIC; -- 4: Accumulator read enable  (used to multiplex reading)
			ACC_WEN : OUT STD_LOGIC; -- 5: Accumulator write enable  
			TREG_EN : OUT STD_LOGIC; -- 6: Temporary Register enable  
			FREE_USE : OUT STD_LOGIC; -- 7: FREE_USE  
			INC_DEC_EN : OUT STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
			IP_WEN : OUT STD_LOGIC; -- 9: Instruction Pointer Write enable  
			REN_2 : OUT STD_LOGIC; -- 10:  (used to multiplex reading)
			RAM_WEN : OUT STD_LOGIC; -- 11: RAM write enable  
			BYTE_SEL : OUT STD_LOGIC; -- 12: BYTE SELECT  
			--13: MIC RST
			FG_WEN : OUT STD_LOGIC; --14: FG_WEN
			INC_DEC: OUT STD_LOGIC;		--SELECT IF INC OR DEC 1:INC , 0: DEC
			

			

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
			CLK : IN STD_LOGIC
		);
	END COMPONENT;
	
	for all: REG_ARRAY use entity work.REG_array(Behavioral2); 

	-- SPECIAL REGISTERS
	SIGNAL ACC_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
	SIGNAL IP_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL T_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
	SIGNAL FG_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL SEL_SYNC: STD_LOGIC_VECTOR(2 downto 0) := (OTHERS => '0');

	-- CONTROL SIGNALS

	SIGNAL REN_0 : STD_LOGIC; -- 2:  (used to multiplex reading)
	SIGNAL REG_ARR_WEN : STD_LOGIC; -- 3: Register Array write enable  
	SIGNAL REN_1 : STD_LOGIC; -- 4: (used to multiplex reading)
	SIGNAL ACC_WEN : STD_LOGIC; -- 5: Accumulator write enable  
	SIGNAL TREG_EN : STD_LOGIC; -- 6: Temporary Register enable  
	SIGNAL FREE_USE : STD_LOGIC; -- 7: FREE_USE  
	SIGNAL INC_DEC_EN : STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
	SIGNAL IP_WEN : STD_LOGIC; -- 9: Instruction Pointer Write enable  
	SIGNAL REN_2 : STD_LOGIC; -- 10: (used to multiplex reading)
	SIGNAL RAM_WEN : STD_LOGIC; -- 11: RAM write enable  
	SIGNAL BYTE_SEL : STD_LOGIC; -- 12: BYTE SELECT  
	SIGNAL FG_WEN : STD_LOGIC; --14: FG_WEN
	SIGNAL INC_DEC: STD_LOGIC;		--15: SELECT IF INC OR DEC 1:INC , 0: DEC


	--SPECIAL SIGNALS
	SIGNAL OPCODE_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL REG_SEL_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL FG_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL ALU_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL REG_OUTS : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL READ_REG : STD_LOGIC;

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
					IF INC_DEC = '1' THEN
						IP_reg <= STD_LOGIC_VECTOR(unsigned(IP_reg) + 1);
					ELSE
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
	
	
	SEL_SYNC_REG: process(CLK) 
	begin 
	if rising_edge(CLK) then
		SEL_SYNC <= (REN_2 & REN_1 & REN_0);
	end if;
	end process;

	----------------------------------------------------------------------------------------------------------------------------------
	MUX_DATA_OUT : PROCESS (SEL_SYNC, ACC_REG, IP_reg, FG_REG, ALU_OUT, REG_OUTS, DATA_BUS_IN_EXTERN, ALU_OUT)
	BEGIN
		CASE SEL_SYNC IS
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
			WHEN "110" =>
				DATA_BUS_OUT <= ALU_OUT;
			WHEN OTHERS =>
				DATA_BUS_OUT <= (OTHERS => '1');
		END CASE;
	END PROCESS;

	------------------------------------ COMPONENTS ------------------------------------
	CU : Control_Unit PORT MAP(
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
		INC_DEC => INC_DEC,		--SELECT IF INC OR DEC 1:INC , 0: DEC

		OPCODE_OUT => OPCODE_OUT,
		REG_SEL_OUT => REG_SEL_OUT,
		
		--MIC_OUT => MIC_OUT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!


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

	REGISTERS : REG_ARRAY PORT MAP(
		REG_SEL => REG_SEL_OUT,
		DATA_OUT_BUS => REG_OUTS,
		DATA_IN_BUS => DATA_BUS_IN,
		READ_REG => READ_REG,
		WRITE_REG => REG_ARR_WEN,
		BYTE_SEL => BYTE_SEL,
		CLK => CLK
	);

	READ_REG <= '1' WHEN (REN_2 & REN_1 & REN_0) = STD_LOGIC_VECTOR(to_unsigned(1, 3)) ELSE
		'0';
	EXTERN_READ <= '1' WHEN (REN_2 & REN_1 & REN_0) = STD_LOGIC_VECTOR(to_unsigned(2, 3)) AND RAM_WEN = '0' ELSE
		'0';
	EXTERN_WRITE <= '1' WHEN (REN_2 & REN_1 & REN_0) /= STD_LOGIC_VECTOR(to_unsigned(2, 3)) AND RAM_WEN = '1' ELSE
		'0';
	ADDRESS_BUS <= IP_REG;
	--ALU_OUT_EXT <= ALU_OUT; --SOLO TESTTTTTSSSTTSTTTST

END Behavioral;