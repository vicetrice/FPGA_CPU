library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM_4Kx16 is
    Port ( address : in  std_logic_vector(11 downto 0); -- 12-bit address (4K words)
           data_out : out std_logic_vector(15 downto 0)); -- 16-bit output
end ROM_4Kx16;

architecture Behavioral of ROM_4Kx16 is
    type ROM_Array is array (0 to 4095) of std_logic_vector(15 downto 0);
    constant ROM : ROM_Array := (
																	-- ROM content --
												-- LAYOUT (SEE CONTROL_UNIT FOR NUMBER INFO) --
												 -- 16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1| --
            --ADD IMM8
            16#000# => X"4088", 
		    16#001# => X"4089", 
		    16#002# => X"0022", 
		    16#003# => X"0218", 
		    16#004# => X"1004",

            --SUB IMM8
            16#100# => X"4088",
            16#101# => X"4089",
            16#102# => X"0022",
            16#103# => X"0218",
            16#104# => X"1004",

            --NAND IMM8
            16#200# => X"4088",
            16#201# => X"4089",
            16#202# => X"0022",
            16#203# => X"0218",
            16#204# => X"1004",

            --SBB IMM8
            16#300# => X"4088",
            16#301# => X"4089",
            16#302# => X"0022",
            16#303# => X"0218",
            16#304# => X"1004",

            --XOR IMM8
            16#400# => X"4088",
            16#401# => X"4089",
            16#402# => X"0022",
            16#403# => X"0218",
            16#404# => X"1004",

            --NOR IMM8
            16#500# => X"4088",
            16#501# => X"4089",
            16#502# => X"0022",
            16#503# => X"0218",
            16#504# => X"1004",

            --ADC IMM8
            16#A00# => X"4088",
            16#A01# => X"4089",
            16#A02# => X"0022",
            16#A03# => X"0218",
            16#A04# => X"1004",

            --SHL IMM8
            16#C00# => X"4088",
            16#C01# => X"4089",
            16#C02# => X"0022",
            16#C03# => X"0218",
            16#C04# => X"1004",

            --SHR IMM8
            16#D00# => X"4088",
            16#D01# => X"4089",
            16#D02# => X"0022",
            16#D03# => X"0218",
            16#D04# => X"1004",

        -- ...
        others => x"0000"  -- Default values
    );
begin
    process (address)
    begin
        data_out <= ROM(to_integer(unsigned(address)));
    end process;
end Behavioral;
