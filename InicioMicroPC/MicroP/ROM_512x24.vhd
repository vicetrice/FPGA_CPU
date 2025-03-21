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
				
				--JNZ/LEA IMM8 MICROCODE
				8#100# => X"004088", --FETCH
				8#101# => X"004089", --DECODE
				8#102# => X"004198", --EXC
				8#103# => X"00090E", --EXC/SAVE
				8#104# => X"000104", --EXC/SAVE
				8#105# => X"041100", --EXC/SAVE
				
				--JNZ/LEA REG MICROCODE
				8#120# => X"004088", --FETCH
				8#121# => X"004089", --DECODE
				8#122# => X"010103", --EXC
				8#123# => X"000912", --EXC
				8#124# => X"00094E", --EXC/SAVE
				8#125# => X"000144", --EXC/SAVE
				8#126# => X"041100", --EXC/SAVE
				
				--STR IMM8 MICROCODE
				8#140# => X"004088", --FETCH
				8#141# => X"004089", --DECODE
				8#142# => X"004088", --EXC
				8#143# => X"0C0002", --EXC
				8#144# => X"000500", --EXC
				8#145# => X"041000", --EXC
				
				--STR REG MICROCODE
				8#160# => X"004088", --FETCH
				8#161# => X"004089", --DECODE
				8#162# => X"010003", --EXC
				8#163# => X"120400", --EXC
				8#164# => X"001000", --SECURITY CYCLE FOR NO CHANGE RAM
				
				--CMP IMM8 MICROCODE
				8#200# => X"004088", --FETCH
				8#201# => X"004089", --DECODE
				8#202# => X"000022", --EXC
				8#203# => X"000218", --EXC
				8#204# => X"003000", --SAVE
				
				--CMP REG MICROCODE
				8#220# => X"004088", --FETCH
				8#221# => X"004089", --DECODE
				8#222# => X"010003", --EXC
				8#223# => X"000052", --EXC
				8#224# => X"000228", --EXC
				8#225# => X"003000", --SAVE
				
				-- POP MICROCODE
				8#240# => X"004088", --FETCH
				8#241# => X"004089", --DECODE
				8#242# => X"024080", --EXC
				8#243# => X"020008", --EXC
				8#244# => X"041004", --EXC

				-- POPF MICROCODE
				8#260# => X"004088", --FETCH
				8#261# => X"004089", --DECODE
				8#262# => X"000200", --EXC
				8#263# => X"001004", --EXC
				
				-- PUSHF IMM8 MICROCODE
				8#300# => X"004088", --FETCH
				8#301# => X"004089", --DECODE
				8#302# => X"00B000", --EXC
				
				-- PUSHF REG MICROCODE
				8#320# => X"004088", --FETCH
				8#321# => X"004089", --DECODE
				8#322# => X"000002", --EXC
				8#323# => X"00B000", --EXC
				
				--LDR IMM8 MICROCODE
				8#340# => X"004088", --FETCH
				8#341# => X"004089", --DECODE
				8#342# => X"004088", --EXC
				8#343# => X"0C0000", --EXC
				8#344# => X"000108", --EXC
				8#345# => X"041004", --EXC
				
				--LDR REG MICROCODE
				8#360# => X"004088", --FETCH
				8#361# => X"004089", --DECODE
				8#362# => X"110009", --EXC
				8#363# => X"001044", --EXC
				
				--PUSH IMM8 MICROCODE
				8#400# => X"004088", --FETCH
				8#401# => X"004089", --DECODE
				8#402# => X"020480", --EXC
				8#403# => X"041000", --EXC
				
				--PUSH REG MICROCODE
				8#420# => X"004088", --FETCH
				8#421# => X"004089", --DECODE
				8#422# => X"000002", --EXC
				8#423# => X"020480", --EXC
				8#424# => X"041000", --EXC
				
				--RST MICROCODE (SAME AS LEA BUT IT WILL USE THE AUX ADDR REG)
				8#760# => X"004188", --FETCH
				8#761# => X"004189", --DECODE
				8#762# => X"004198", --EXC
				8#763# => X"00090E", --EXC/SAVE
				8#764# => X"000104", --EXC/SAVE
				8#765# => X"041100", --EXC/SAVE
				


				
				
				
        -- ...
        others => x"000000"  -- Default values
    );
begin
    process (address)
    begin
        data_out <= ROM(to_integer(unsigned(address)));
    end process;
end Behavioral;