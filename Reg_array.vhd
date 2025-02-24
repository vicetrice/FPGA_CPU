library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Reg_array is
    port(
        REG_SEL: in STD_LOGIC_VECTOR(2 downto 0); -- REGISTER SELECT
        DATA_BUS: inout STD_LOGIC_VECTOR(7 downto 0);
        READ_REG: in STD_LOGIC;  -- READ SIGNAL
        WRITE_REG: in STD_LOGIC; -- WRITE SIGNAL
        BYTE_SEL: in STD_LOGIC; -- 0 = LSB, 1 = MSB
		  INC_DEC_REG: in STD_LOGIC_VECTOR(1 downto 0); -- MSb (0 = INC, 1 = DEC), LSb (1 = enable, 0 = disable) only 16b full reg
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
                    registers(to_integer(unsigned(REG_SEL)))(7 downto 0) <= DATA_BUS;
                else
                    registers(to_integer(unsigned(REG_SEL)))(15 downto 8) <= DATA_BUS;
                end if;
				--READ
				elsif READ_REG = '1' and WRITE_REG = '0' then
                --READING THE BYTE
                if BYTE_SEL = '0' then
                    DATA_BUS <= registers(to_integer(unsigned(REG_SEL)))(7 downto 0);
                else
                    DATA_BUS <= registers(to_integer(unsigned(REG_SEL)))(15 downto 8);
                end if;
            else
                --HIGH IMPEDANCE WHEN NOTHING
                DATA_BUS <= (others => 'Z');
					 if INC_DEC_REG(0) = '1' then
							if INC_DEC_REG(1) = '1' then
								registers(to_integer(unsigned(REG_SEL))) <= std_logic_vector(unsigned(registers(to_integer(unsigned(REG_SEL)))) + 1);
							else
								registers(to_integer(unsigned(REG_SEL))) <= std_logic_vector(unsigned(registers(to_integer(unsigned(REG_SEL)))) - 1);
							end if;
					 end if;
            end if;
        end if;
    end process;

    
    INC_DEC: process(CLK)
    begin
        if rising_edge(CLK) then
           
        end if;
    end process;

end Behavioral;
