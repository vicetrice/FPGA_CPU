LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CPU IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : in STD_LOGIC;
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
		STAT_OUT: OUT STD_LOGIC_VECTOR(7 downto 0); --SOLO TEST
		AUX_REG_ADDR_OUT: OUT STD_LOGIC_VECTOR(15 downto 0) --SOLO TEST

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
			ADDR_SEL: OUT STD_LOGIC;--18: SELECT WHICH DIRECTION USE FOR ADDRESS BUS: 0: IP, 1:SP
			LOAD_AUX_ADDR_REG: OUT STD_LOGIC; --19: IF 1: LOAD THE ADDRESS AUX REG
			AUX_ADDR_SEL_IN: OUT STD_LOGIC; --20: SELECT FROM WHICH PATH LOAD THE AUX ADDR REG, 0: REGISTER, 1:INTERNAL_DATA_BUS
			

			-- SPECIAL OUTS --
			OPCODE_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4-bit opcode output
			REG_SEL_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3-bit register select output
			RST_SYNC: OUT STD_LOGIC;

			--TESTS!!!!!!!!!!!!!!!!!!!!!!!!!!!
			ROM_ADDR_OUT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
			-- INS --
			CLK : IN STD_LOGIC;
			INSTRUCTION : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			ZFLAG: in STD_LOGIC;
			READY : IN STD_LOGIC;
			RST: in STD_LOGIC
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
		 port(
        REG_SEL: in STD_LOGIC_VECTOR(2 downto 0); -- REGISTER SELECT FOR DATA BUS
        REG_SEL2: in STD_LOGIC_VECTOR(2 downto 0); -- REGISTER SELECT FOR ADDR LATCH
        DATA_OUT_BUS: out STD_LOGIC_VECTOR(7 downto 0);
		  DATA_IN_BUS: in STD_LOGIC_VECTOR(7 downto 0);
		  ADDR_REG_OUT_BUS: out STD_LOGIC_VECTOR(15 downto 0);
		  INC_DEC: in STD_LOGIC;
		  INC_DEC_EN: IN STD_LOGIC;
        READ_REG: in STD_LOGIC;  -- READ SIGNAL
        WRITE_REG: in STD_LOGIC; -- WRITE SIGNAL
        BYTE_SEL: in STD_LOGIC; -- 0 = LSB, 1 = MSB
		  CLK: in STD_LOGIC;
		  RST: in STD_LOGIC
    );
	END COMPONENT;

	FOR ALL : REG_ARRAY USE ENTITY work.REG_array(Behavioral);

	-- SPECIAL REGISTERS
	SIGNAL ACC_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL T_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL FG_REG : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL SEL_SYNC : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
	SIGNAL PREV_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL AUX_ADDR_REG: STD_LOGIC_VECTOR( 15 downto 0) := (others => '0');
	SIGNAL LSB_ADDR_REG_DATA_BUS: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

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
	SIGNAL ADDR_SEL: STD_LOGIC;--18: SELECT WHICH DIRECTION USE FOR ADDRESS BUS: 0: IP, 1:SP
	SIGNAL LOAD_AUX_ADDR_REG: STD_LOGIC; --19: IF 1: LOAD THE ADDRESS AUX REG
	SIGNAL AUX_ADDR_SEL_IN: STD_LOGIC; --20: SELECT FROM WHICH PATH LOAD THE AUX ADDR REG, 0: REGISTER, 1:INTERNAL_DATA_BUS


	--SPECIAL SIGNALS
	SIGNAL OPCODE_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL REG_SEL_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL FG_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ADDR_REG_OUT_BUS : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL REG_SEL2: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL RST_SYNC:  STD_LOGIC;


	SIGNAL ALU_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL REG_OUTS : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL READ_REG : STD_LOGIC;

	
BEGIN
	----------------------------------------------------------------- SPECIAL REGISTERS -----------------------------------------------------------------

	ADDRESS_REG_AUX : PROCESS (CLK)
BEGIN
    if RISING_EDGE(CLK) then
        if RST_SYNC = '1' then
            AUX_ADDR_REG <= X"0000"; --IP START VALUE AFTER RST_SYNC
        else
				if LOAD_AUX_ADDR_REG = '1' then
					if AUX_ADDR_SEL_IN = '1' then 
							AUX_ADDR_REG <= (DATA_BUS_IN & LSB_ADDR_REG_DATA_BUS);				
					ELSE
							AUX_ADDR_REG <= ADDR_REG_OUT_BUS;
					end IF;
							
						
            elsif INC_DEC_EN = '1' and READ_REG = REG_ARR_WEN  then
                if INC_DEC = '1' then
                    AUX_ADDR_REG <= STD_LOGIC_VECTOR(unsigned(AUX_ADDR_REG) + 1);
                else
                    AUX_ADDR_REG <= STD_LOGIC_VECTOR(unsigned(AUX_ADDR_REG) - 1);
                end if;
            
            end if;
        end if;
    end if;
END PROCESS;
	
	ACCM : PROCESS (CLK)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		IF rising_edge(CLK) THEN
			if RST_SYNC = '1' then
				ACC_REG <= (others => '0');
			else
			if ACC_WEN = '1' then 
			sel := REN_2 & REN_1 & REN_0;
			IF sel /= "011" THEN
				ACC_REG <= DATA_BUS_IN;
			END IF;
			end if;
			end if;
		END IF;

	END PROCESS;

	TREG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
				if RST_SYNC = '1' then
					T_REG <= (others => '0');
				else
				if TREG_EN = '1' then
					T_REG <= DATA_BUS_IN;
				end if;
				end if;
		END IF;

	END PROCESS;

	FG : PROCESS (CLK)
		VARIABLE sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		IF rising_edge(CLK)  THEN
		
		if RST_SYNC = '1' then
				FG_REG <= (others => '0');
		else
			if FG_WEN = '1' then
			sel := REN_2 & REN_1 & REN_0;
				IF sel /= "100" THEN
					if FG_SEL_IN = '1' then
					FG_REG <= DATA_BUS_IN;
					ELSE
					FG_REG <= FG_OUT;
					end if;
				END IF;
			end if;
		end if;
		END IF;
	END PROCESS;
	SYNC_REG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
		if RST_SYNC = '1' then
			SEL_SYNC <= (others => '0');
		else
			SEL_SYNC <= (REN_2 & REN_1 & REN_0);
		end if;
		END IF;
	END PROCESS;
	

	PREV_OUT_REG : PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			if RST_SYNC = '1' then
				PREV_OUT <= (others => '0');
			else
			
			PREV_OUT <= DATA_BUS_IN;
			end if;
		END IF;
	END PROCESS;
	
	LSB_AUX_ADDR_REG: PROCESS(CLK)
	BEGIN
		IF rising_edge(CLK) then
		LSB_ADDR_REG_DATA_BUS <= DATA_BUS_IN;
		end if;
	
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
	
	MUX_FOR_ADDR: PROCESS(ADDR_SEL)
	begin
		case ADDR_SEL IS
		when '1' =>
			REG_SEL2 <= "111"; --0x7 SP
		when others =>
			REG_SEL2 <= "110"; --0x6 IP
		end case;
	end process;
	
	MUX_FINAL_ADDR_BUS: PROCESS(FINAL_ADDR_SEL,AUX_ADDR_REG,ADDR_REG_OUT_BUS)
	begin
		case FINAL_ADDR_SEL IS
		when '1' =>
			ADDRESS_BUS <= AUX_ADDR_REG; 
		when others =>
			ADDRESS_BUS <= ADDR_REG_OUT_BUS ; 
		end case;
	end process;
	
	
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
		ADDR_SEL => ADDR_SEL,
		LOAD_AUX_ADDR_REG => LOAD_AUX_ADDR_REG,
		AUX_ADDR_SEL_IN => AUX_ADDR_SEL_IN,


		
		OPCODE_OUT => OPCODE_OUT,
		REG_SEL_OUT => REG_SEL_OUT,
		RST_SYNC => RST_SYNC,
		
		ROM_ADDR_OUT => ROM_ADDR_OUT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		CLK => CLK,
		INSTRUCTION => DATA_BUS_IN,

		ZFLAG		=> FG_REG(0),
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
	REG_SEL_OUT_CPU<= REG_SEL_OUT ;--SOLO TESSTSTSTT;
	AUX_REG_ADDR_OUT <= AUX_ADDR_REG; --SOLO TESTTTT;

END Behavioral;