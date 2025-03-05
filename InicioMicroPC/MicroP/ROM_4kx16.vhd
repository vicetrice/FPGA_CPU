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
																		-- BITS --
												 -- 16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1| --
            --ALU IMM8 MICROCODE
            16#000# => X"4088", 
				16#001# => X"4089", 
				16#002# => X"0022", 
				16#003# => X"0218", 
				16#004# => X"709C",
        -- ...
        others => x"0000"  -- Default values
    );
begin
    process (address)
    begin
        data_out <= ROM(to_integer(unsigned(address)));
    end process;
end Behavioral;
