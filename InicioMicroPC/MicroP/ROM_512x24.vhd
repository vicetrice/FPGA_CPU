library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ROM_512x24 is
    Port ( address : in  std_logic_vector(8 downto 0); -- 12-bit address (4K words)
           data_out : out std_logic_vector(23 downto 0)); -- 16-bit output
end ROM_512x24;

architecture Behavioral of ROM_512x24 is
    type ROM_Array is array (0 to 511) of std_logic_vector(23 downto 0);
    constant ROM : ROM_Array := (
																	-- ROM content --
												-- LAYOUT (SEE CONTROL_UNIT FOR NUMBER INFO) --
																		-- BITS --
									-- 24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1| --
            --ALU IMM8 MICROCODE
            8#000# => X"004088", --FETCH
				8#001# => X"004089", --DECODE
				8#002# => X"000022", --EXC
				8#003# => X"000218", --EXC
				8#004# => X"003014", --SAVE
				
				--ALU REG MICROCODE
				8#020# => X"004088", --FETCH
				8#021# => X"004089", --DECODE
				8#022# => X"010003", --EXC
				8#023# => X"000052", --EXC
				8#024# => X"000228", --EXC
				8#025# => X"003014", --SAVE
				
				--MOV IMM8 MICROCODE
				8#040# => X"004088", --FETCH
				8#041# => X"004089", --DECODE
				8#042# => X"001004", --SAVE & EXC
				
				--MOV REG MICROCODE WITH DST IN FIRST BYTE
--				16#30# => X"004088", --FETCH
--				16#31# => X"004089", --DECODE
--				16#32# => X"010001", --EXC
--				16#33# => X"000042", --EXC
--				16#34# => X"00508C", --SAVE

				--MOV REG MICROCODE WITH SRC IN FIRST BYTE
				8#060# => X"004088", --FETCH
				8#061# => X"004089", --DECODE
				8#062# => X"010003", --EXC
				8#063# => X"001044", --SAVE
				
				--JNZ/LDA IMM8 MICROCODE
				8#100# => X"004088", --FETCH
				8#101# => X"004089", --DECODE
				8#102# => X"004198", --EXC
				8#103# => X"00090E", --EXC/SAVE
				8#104# => X"000104", --EXC/SAVE
				8#105# => X"041100", --EXC/SAVE
				
					--JNZ/LDA REG MICROCODE
				8#120# => X"004088", --FETCH
				8#121# => X"004089", --DECODE
				8#122# => X"010103", --EXC
				8#123# => X"000912", --EXC
				8#124# => X"00094E", --EXC/SAVE
				8#125# => X"000144", --EXC/SAVE
				8#126# => X"041100", --EXC/SAVE
				
				--RST MICROCODE (SAME AS LDA BUT IT WILL USE THE AUX ADDR REG)
				8#760# => X"004188", --FETCH
				8#761# => X"004189", --DECODE
				8#762# => X"004198", --EXC
				8#763# => X"00090E", --EXC/SAVE
				8#764# => X"000104", --EXC/SAVE
				8#765# => X"041100", --EXC/SAVE
				--8#766# => X"028400", --ONLY FOR THE XST TO BE HAPPY, CAN BE ERASED AFTER PUSH/POP OP ARE IMPLEMENTED


				
				
				
        -- ...
        others => x"000000"  -- Default values
    );
begin
    process (address)
    begin
        data_out <= ROM(to_integer(unsigned(address)));
    end process;
end Behavioral;