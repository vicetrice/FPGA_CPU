library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Reg_array is
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
end Reg_array;

architecture Behavioral of Reg_array is
	--8 REG OF 16 BITS
    type reg_array_type is array (0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
    signal registers: reg_array_type := (others => (others => '0'));

begin



    WR_RD: process(CLK)
    begin
        if rising_edge(CLK) then
           --WRITE
				if RST = '1' then
				registers <= (others => (others => '0'));
				
				else

				

            if WRITE_REG = '1' and READ_REG = '0' then
                if BYTE_SEL = '0' then
                    registers(to_integer(unsigned(REG_SEL)))(7 downto 0) <= DATA_IN_BUS;
                else
                    registers(to_integer(unsigned(REG_SEL)))(15 downto 8) <= DATA_IN_BUS;
                end if;
				--READ
				elsif READ_REG = '1' and WRITE_REG = '0' then
                --READING THE BYTE
                if BYTE_SEL = '0' then
                    DATA_OUT_BUS <= registers(to_integer(unsigned(REG_SEL)))(7 downto 0);
                else
                    DATA_OUT_BUS <= registers(to_integer(unsigned(REG_SEL)))(15 downto 8);
                end if;	
				else
				IF INC_DEC_EN = '1' THEN
					IF INC_DEC = '1' THEN
						registers(to_integer(unsigned(REG_SEL2))) <= STD_LOGIC_VECTOR(unsigned(registers(to_integer(unsigned(REG_SEL2)))) + 1) ;
					ELSE
						registers(to_integer(unsigned(REG_SEL2))) <= STD_LOGIC_VECTOR(unsigned(registers(to_integer(unsigned(REG_SEL2)))) - 1) ;

					END IF;
				END IF;
				
            end if;
			
				end if;
        end if;
		  

    end process;
	 		  					ADDR_REG_OUT_BUS<= registers(to_integer(unsigned(REG_SEL2)));				

	 
end Behavioral;

--architecture Behavioral2 of Reg_array is
--	--16 REG OF 8 BITS
--    type reg_array_type is array (0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
--    signal registers: reg_array_type := (others => (others => '0'));
--	
--begin
--
--    WR_RD: process(CLK)
--	 variable sel: STD_LOGIC_VECTOR(3 downto 0);
--    begin
--        if rising_edge(CLK) then
--			sel := BYTE_SEL & REG_SEL;
--           --WRITE
--            if WRITE_REG = '1' and READ_REG = '0' then
--              
--                    registers(to_integer(unsigned(sel))) <= DATA_IN_BUS;
--				--READ
--				elsif READ_REG = '1' and WRITE_REG = '0' then
--                    DATA_OUT_BUS <= registers(to_integer(unsigned(sel)));
--				end if;
--        end if;
--    end process;
--	 
--	 process(CLK)
--	 variable sel: STD_LOGIC_VECTOR(3 downto 0);
--    begin
--        if rising_edge(CLK) then
--			sel := BYTE_SEL & REG_SEL;
--			DATA_OUT2_BUS <= registers(to_integer(unsigned(sel) + 1)) & registers(to_integer(unsigned(sel) + 2)) ;				
--        end if;
--    end process;
--	 
--end Behavioral2;
--
--
