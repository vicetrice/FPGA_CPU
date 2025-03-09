library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ROM_256x24 is
    Port ( address : in  std_logic_vector(7 downto 0); -- 12-bit address (4K words)
           data_out : out std_logic_vector(23 downto 0)); -- 16-bit output
end ROM_256x24;

architecture Behavioral of ROM_256x24 is
    type ROM_Array is array (0 to 255) of std_logic_vector(23 downto 0);
    constant ROM : ROM_Array := (
																	-- ROM content --
												-- LAYOUT (SEE CONTROL_UNIT FOR NUMBER INFO) --
																		-- BITS --
									-- 24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1| --
            --ALU IMM8 MICROCODE
            16#00# => X"004088", --FETCH
				16#01# => X"004089", --DECODE
				16#02# => X"000022", --EXC
				16#03# => X"000218", --EXC
				16#04# => X"003014", --SAVE
				
				--ALU REG MICROCODE
				16#10# => X"004088", --FETCH
				16#11# => X"004089", --DECODE
				16#12# => X"010003", --EXC
				16#13# => X"000052", --EXC
				16#14# => X"000228", --EXC
				16#15# => X"003014", --SAVE
				
				--MOV IMM8 MICROCODE
				16#20# => X"004088", --FETCH
				16#21# => X"004089", --DECODE
				16#22# => X"001004", --SAVE & EXC
				
				--MOV REG MICROCODE WITH DST IN FIRST BYTE
--				16#30# => X"004088", --FETCH
--				16#31# => X"004089", --DECODE
--				16#32# => X"010001", --EXC
--				16#33# => X"000042", --EXC
--				16#34# => X"00508C", --SAVE

				--MOV REG MICROCODE WITH SRC IN FIRST BYTE
				16#30# => X"004088", --FETCH
				16#31# => X"004089", --DECODE
				16#32# => X"010003", --EXC
				16#33# => X"001044", --SAVE
				
				--JNZ IMM8 MICROCODE
				16#40# => X"004088", --FETCH
				16#41# => X"004089", --DECODE
				16#42# => X"004098", --DECODE
				16#43# => X"00090E", --DECODE
				16#44# => X"000104", --DECODE
				16#45# => X"001000", --SECURITY CYCLE FOR LATCH
				
				
				
				
        -- ...
        others => x"000000"  -- Default values
    );
begin
    process (address)
    begin
        data_out <= ROM(to_integer(unsigned(address)));
    end process;
end Behavioral;
