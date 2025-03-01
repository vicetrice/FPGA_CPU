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
			-- 	1|		2|		3|		4|		5|		6|		7|		8|		9|		10|	11|	12|	13|	14|	15|	16|
        0 => X"0001", 
		  1 => X"1001", 
		  2 => X"0001", 
		  3 => X"0001", 
		  4 => X"0000", 
		  256 => X"1001",
        -- ...
        others => x"0000"  -- Default values
    );
begin
    process (address)
    begin
        data_out <= ROM(to_integer(unsigned(address)));
    end process;
end Behavioral;
