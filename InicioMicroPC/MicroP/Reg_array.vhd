library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Reg_array is
    port(
        REG_SEL: in STD_LOGIC_VECTOR(2 downto 0); -- REGISTER SELECT
        DATA_OUT_BUS: out STD_LOGIC_VECTOR(7 downto 0);
		  DATA_IN_BUS: in STD_LOGIC_VECTOR(7 downto 0);
        READ_REG: in STD_LOGIC;  -- READ SIGNAL
        WRITE_REG: in STD_LOGIC; -- WRITE SIGNAL
        BYTE_SEL: in STD_LOGIC; -- 0 = LSB, 1 = MSB
		  CLK: in STD_LOGIC
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
            end if;
				
				 
				
        end if;
    end process;
	 
end Behavioral;

architecture Behavioral2 of Reg_array is
	--16 REG OF 8 BITS
    type reg_array_type is array (0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    signal registers: reg_array_type := (others => (others => '0'));
	
begin

    WR_RD: process(CLK)
	 variable sel: STD_LOGIC_VECTOR(3 downto 0);
    begin
        if rising_edge(CLK) then
			sel := BYTE_SEL & REG_SEL;
           --WRITE
            if WRITE_REG = '1' and READ_REG = '0' then
              
                    registers(to_integer(unsigned(sel))) <= DATA_IN_BUS;
				--READ
				elsif READ_REG = '1' and WRITE_REG = '0' then
                    DATA_OUT_BUS <= registers(to_integer(unsigned(sel)));
				end if;
        end if;
    end process;
	 
end Behavioral2;


