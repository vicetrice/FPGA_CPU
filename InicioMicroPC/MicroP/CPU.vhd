LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CPU IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		READY : IN STD_LOGIC;
		DATA_BUS_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_BUS_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_BUS_IN_EXTERN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		EXTERN_READ : OUT STD_LOGIC;
		EXTERN_WRITE : OUT STD_LOGIC;
		ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		ROM_ADDR_OUT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		ALU_OUT_EXT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		REG_SEL_OUT_CPU : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		STAT_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --SOLO TEST
		AUX_REG_ADDR_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) --SOLO TEST

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
		-- 110: ALU

		--MULTIPLEX ADDR_REG_OUT_BUS SIGNAL
		-- 00: IP
		-- 01: SP
		-- 10: LSB IR (IT ONLY PICK THE REG_SEL BITS OF IR LSB)
		-- 11: MSB IR (IT ONLY PICK THE REG_SEL BITS OF IR MSB)
		PORT (
			-- CONTROL SIGNAL OUT --
			--1: Instruction register WE
			REN_0 : OUT STD_LOGIC; -- 2:   (used to multiplex reading)
			REG_ARR_WEN : OUT STD_LOGIC; -- 3: Register Array write enable  
			REN_1 : OUT STD_LOGIC; -- 4: Accumulator read enable  (used to multiplex reading)
			ACC_WEN : OUT STD_LOGIC; -- 5: Accumulator write enable  
			TREG_EN : OUT STD_LOGIC; -- 6: Temporary Register enable  
			IR_REG_SEL_BYTE : OUT STD_LOGIC; -- 7: IR_REG_SEL_BYTE
			INC_DEC_EN : OUT STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
			FINAL_ADDR_SEL : OUT STD_LOGIC; -- 9: SELECT FROM WHERE IS THE FINAL ADDRESS COMING: 0: REGISTER, 1:AUX ADDR REG.
			REN_2 : OUT STD_LOGIC; -- 10:  (used to multiplex reading)
			RAM_WEN : OUT STD_LOGIC; -- 11: RAM write enable  
			BYTE_SEL : OUT STD_LOGIC; -- 12: BYTE SELECT  
			--13: MIC RST
			FG_WEN : OUT STD_LOGIC; --14: FG_WEN
			INC_DEC : OUT STD_LOGIC; --15: SELECT IF INC OR DEC 1:INC , 0: DEC
			FG_SEL_IN : OUT STD_LOGIC; --16: SELECT FROM WHERE TO WRITE IN THE FG REGISTER. 0: ALU, 1: INTERNAL BUS
			ADDR_SEL_0 : OUT STD_LOGIC;--18: MUX ADDR_REG_OUT_BUS SIGNAL
			LOAD_AUX_ADDR_REG : OUT STD_LOGIC; --19: IF 1: LOAD THE ADDRESS AUX REG
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
			REG_SEL : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- REGISTER SELECT FOR DATA BUS
			REG_SEL2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- REGISTER SELECT FOR ADDR LATCH
			DATA_OUT_BUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DATA_IN_BUS : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			ADDR_REG_OUT_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			INC_DEC : IN STD_LOGIC;
			INC_DEC_EN : IN STD_LOGIC;
			READ_REG : IN STD_LOGIC; -- READ SIGNAL
			WRITE_REG : IN STD_LOGIC; -- WRITE SIGNAL
			BYTE_SEL : IN STD_LOGIC; -- 0 = LSB, 1 = MSB
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC
		);
	END COMPONENT;

	FOR ALL : REG_ARRAY USE ENTITY work.REG_array(Behavioral);

	-- SPECIAL REGISTERS
	SIGNAL ACC_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL T_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL FG_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL SEL_SYNC : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
	SIGNAL PREV_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL AUX_ADDR_REG : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL LSB_ADDR_REG_DATA_BUS : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

	-- CONTROL SIGNALS

	SIGNAL REN_0 : STD_LOGIC; -- 2:  (used to multiplex reading)
	SIGNAL REG_ARR_WEN : STD_LOGIC; -- 3: Register Array write enable  
	SIGNAL REN_1 : STD_LOGIC; -- 4: (used to multiplex reading)
	SIGNAL ACC_WEN : STD_LOGIC; -- 5: Accumulator write enable  
	SIGNAL TREG_EN : STD_LOGIC; -- 6: Temporary Register enable  
	SIGNAL IR_REG_SEL_BYTE : STD_LOGIC; -- 7: IR_REG_SEL_BYTE  
	SIGNAL INC_DEC_EN : STD_LOGIC; -- 8: Instruction Pointer increment/decrement control  
	SIGNAL FINAL_ADDR_SEL : STD_LOGIC; -- 9: SELECT FROM WHERE IS THE FINAL ADDRESS COMING: 0: REGISTER, 1:AUX ADDR REG.
	SIGNAL REN_2 : STD_LOGIC; -- 10: (used to multiplex reading)
	SIGNAL RAM_WEN : STD_LOGIC; -- 11: RAM write enable  
	SIGNAL BYTE_SEL : STD_LOGIC; -- 12: BYTE SELECT  
	SIGNAL FG_WEN : STD_LOGIC; --14: FG_WEN
	SIGNAL INC_DEC : STD_LOGIC; --15: SELECT IF INC OR DEC 1:INC , 0: DEC
	SIGNAL FG_SEL_IN : STD_LOGIC; --16: SELECT FROM WHERE TO WRITE IN THE FG REGISTER. 0: ALU, 1: INTERNAL BUS
	SIGNAL ADDR_SEL_0 : STD_LOGIC;--18: MUX ADDR_REG_OUT_BUS SIGNAL
	SIGNAL LOAD_AUX_ADDR_REG : STD_LOGIC; --19: IF 1: LOAD THE ADDRESS AUX REG
	SIGNAL AUX_ADDR_SEL_IN : STD_LOGIC; --20: SELECT FROM WHICH PATH LOAD THE AUX ADDR REG, 0: REGISTER, 1:INTERNAL_DATA_BUS
	SIGNAL ADDR_SEL_1 : STD_LOGIC; --21: MUX ADDR_REG_OUT_BUS SIGNAL
	--SPECIAL SIGNALS
	SIGNAL OPCODE_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL REG_SEL_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL FG_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ADDR_REG_OUT_BUS : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL REG_SEL2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL RST_SYNC : STD_LOGIC;
	SIGNAL REG_SEL_OUT_MSB : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL REG_SEL_OUT_LSB : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL ALU_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL REG_OUTS : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL READ_REG : STD_LOGIC;
BEGIN
	----------------------------------------------------------------- SPECIAL REGISTERS -----------------------------------------------------------------

	ADDRESS_REG_AUX : PROCESS (CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF RST_SYNC = '1' THEN
				AUX_ADDR_REG <= X"0000"; --IP START VALUE AFTER RST_SYNC
			ELSE
				IF LOAD_AUX_ADDR_REG = '1' THEN
					IF AUX_ADDR_SEL_IN = '1' THEN
						AUX_ADDR_REG <= (DATA_BUS_IN & LSB_ADDR_REG_DATA_BUS);
					ELSE
						AUX_ADDR_REG <= ADDR_REG_OUT_BUS;
					END IF;
				ELSIF INC_DEC_EN = '1' AND READ_REG = REG_ARR_WEN THEN
					IF INC_DEC = '1' THEN
						AUX_ADDR_REG <= STD_LOGIC_VECTOR(unsigned(AUX_ADDR_REG) + 1);
					ELSE
						AUX_ADDR_REG <= STD_LOGIC_VECTOR(unsigned(AUX_ADDR_REG) - 1);
					END IF;

				END IF;
			END IF;
		END IF;
	END PROCESS;

	ACCM : PROCESS (CLK)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		IF rising_edge(CLK) THEN
			IF RST_SYNC = '1' THEN
				ACC_REG <= (OTHERS => '0');
			ELSE
				IF ACC_WEN = '1' THEN
					sel := REN_2 & REN_1 & REN_0;
					IF sel /= "011" THEN
						ACC_REG <= DATA_BUS_IN;
					END IF;
				END IF;
			END IF;
		END IF;

	END PROCESS;

	TREG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF RST_SYNC = '1' THEN
				T_REG <= (OTHERS => '0');
			ELSE
				IF TREG_EN = '1' THEN
					T_REG <= DATA_BUS_IN;
				END IF;
			END IF;
		END IF;

	END PROCESS;

	FG : PROCESS (CLK)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		IF rising_edge(CLK) THEN

			IF RST_SYNC = '1' THEN
				FG_REG <= (OTHERS => '0');
			ELSE
				IF FG_WEN = '1' THEN
					sel := REN_2 & REN_1 & REN_0;
					IF sel /= "100" THEN
						IF FG_SEL_IN = '1' THEN
							FG_REG <= DATA_BUS_IN;
						ELSE
							FG_REG <= FG_OUT;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	SYNC_REG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF RST_SYNC = '1' THEN
				SEL_SYNC <= (OTHERS => '0');
			ELSE
				SEL_SYNC <= (REN_2 & REN_1 & REN_0);
			END IF;
		END IF;
	END PROCESS;
	PREV_OUT_REG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF RST_SYNC = '1' THEN
				PREV_OUT <= (OTHERS => '0');
			ELSE

				PREV_OUT <= DATA_BUS_IN;
			END IF;
		END IF;
	END PROCESS;

	LSB_AUX_ADDR_REG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			LSB_ADDR_REG_DATA_BUS <= DATA_BUS_IN;
		END IF;

	END PROCESS;

	------------------------------------------------------------ MULTIPLEXERS ---------------------------------------------
	MUX_DATA_OUT : PROCESS (SEL_SYNC, ACC_REG, FG_REG, REG_OUTS, DATA_BUS_IN_EXTERN, ALU_OUT, PREV_OUT, BYTE_SEL)
	BEGIN
		CASE SEL_SYNC IS
			WHEN "001" =>
				DATA_BUS_OUT <= REG_OUTS;
			WHEN "011" =>
				DATA_BUS_OUT <= ACC_REG;
			WHEN "100" =>
				DATA_BUS_OUT <= FG_REG;
			WHEN "010" =>
				DATA_BUS_OUT <= DATA_BUS_IN_EXTERN;
			WHEN "110" =>
				DATA_BUS_OUT <= ALU_OUT;
			WHEN OTHERS =>
				DATA_BUS_OUT <= PREV_OUT;
		END CASE;
	END PROCESS;

	MUX_FOR_ADDR : PROCESS (ADDR_SEL_0, ADDR_SEL_1, REG_SEL_OUT_LSB, REG_SEL_OUT_MSB)
		VARIABLE sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
	BEGIN
		sel := (ADDR_SEL_1 & ADDR_SEL_0);
		CASE sel IS
			WHEN "01" =>
				REG_SEL2 <= "111"; --0x7 SP
			WHEN "10" =>
				REG_SEL2 <= REG_SEL_OUT_LSB;
			WHEN "11" =>
				REG_SEL2 <= REG_SEL_OUT_MSB;
			WHEN OTHERS =>
				REG_SEL2 <= "110"; --0x6 IP
		END CASE;
	END PROCESS;

	MUX_FINAL_ADDR_BUS : PROCESS (FINAL_ADDR_SEL, AUX_ADDR_REG, ADDR_REG_OUT_BUS)
	BEGIN
		CASE FINAL_ADDR_SEL IS
			WHEN '1' =>
				ADDRESS_BUS <= AUX_ADDR_REG;
			WHEN OTHERS =>
				ADDRESS_BUS <= ADDR_REG_OUT_BUS;
		END CASE;
	END PROCESS;
	------------------------------------ COMPONENTS ------------------------------------
	CU : Control_Unit PORT MAP(
		REN_0 => REN_0,
		REG_ARR_WEN => REG_ARR_WEN,
		REN_1 => REN_1,
		ACC_WEN => ACC_WEN,
		TREG_EN => TREG_EN,
		IR_REG_SEL_BYTE => IR_REG_SEL_BYTE,
		INC_DEC_EN => INC_DEC_EN,
		FINAL_ADDR_SEL => FINAL_ADDR_SEL,
		REN_2 => REN_2,
		RAM_WEN => RAM_WEN,
		BYTE_SEL => BYTE_SEL,
		FG_WEN => FG_WEN,
		INC_DEC => INC_DEC,
		FG_SEL_IN => FG_SEL_IN,
		ADDR_SEL_0 => ADDR_SEL_0,
		LOAD_AUX_ADDR_REG => LOAD_AUX_ADDR_REG,
		AUX_ADDR_SEL_IN => AUX_ADDR_SEL_IN,
		ADDR_SEL_1 => ADDR_SEL_1,

		OPCODE_OUT => OPCODE_OUT,
		REG_SEL_OUT => REG_SEL_OUT,
		RST_SYNC => RST_SYNC,
		REG_SEL_OUT_MSB => REG_SEL_OUT_MSB,
		REG_SEL_OUT_LSB => REG_SEL_OUT_LSB,

		ROM_ADDR_OUT => ROM_ADDR_OUT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		CLK => CLK,
		INSTRUCTION => DATA_BUS_IN,

		ZFLAG => FG_REG(0),
		READY => READY,
		RST => RST
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
		REG_SEL2 => REG_SEL2,
		REG_SEL => REG_SEL_OUT,
		DATA_OUT_BUS => REG_OUTS,
		DATA_IN_BUS => DATA_BUS_IN,
		ADDR_REG_OUT_BUS => ADDR_REG_OUT_BUS,
		INC_DEC => INC_DEC,
		INC_DEC_EN => INC_DEC_EN,
		READ_REG => READ_REG,
		WRITE_REG => REG_ARR_WEN,
		BYTE_SEL => BYTE_SEL,
		CLK => CLK,
		RST => RST_SYNC
	);

	------------------------------------ SPECIAL COMBINATIONAL LOGIC ----------------------------------------

	READ_REG <= '1' WHEN (REN_2 & REN_1 & REN_0) = STD_LOGIC_VECTOR(to_unsigned(1, 3)) ELSE
		'0';
	EXTERN_READ <= '1' WHEN (REN_2 & REN_1 & REN_0) = STD_LOGIC_VECTOR(to_unsigned(2, 3)) AND RAM_WEN = '0' ELSE
		'0';
	EXTERN_WRITE <= RAM_WEN;

	ALU_OUT_EXT <= ALU_OUT; --SOLO TESTTTTTSSSTTSTTTST
	STAT_OUT <= FG_REG; --SOLO TESSTSTSTT;
	REG_SEL_OUT_CPU <= REG_SEL_OUT;--SOLO TESSTSTSTT;
	AUX_REG_ADDR_OUT <= AUX_ADDR_REG; --SOLO TESTTTT;

END Behavioral;