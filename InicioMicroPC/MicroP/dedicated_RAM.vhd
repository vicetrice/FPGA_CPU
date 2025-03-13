library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_64Kx8 is
    Port (
        clk     : in  std_logic;                           -- Reloj
        we      : in  std_logic;                           -- Habilitaci�n de escritura
        address : in  std_logic_vector(15 downto 0);       -- Direcci�n de memoria (64K posiciones)
		  address2 : in  std_logic_vector(15 downto 0);      -- ONLY READ ADDRESS
		  data_out2: out std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
		  data_in : in std_logic_vector(7 downto 0)      
    );
end RAM_64Kx8;

architecture Behavioral of RAM_64Kx8 is
    type RAM_Array is array (0 to 65535) of std_logic_vector(7 downto 0);
    signal RAM : RAM_Array := (
	 
	 --			PROGRAM
	 --		equivalent in C
	 -- While ( Reg1 != 255) ++Reg1; 
	 
	 16#0000# => X"B6", --LDA TO PC VALUE 0xEEFF (JMP)
	 16#0001# => X"FF", --LSB
	 16#0002# => X"EE", --MSB
	 
	 
	 
	 
	 --16#0003# => X"9A", --JNZ TO DIRECTION IN REG 2 (SRC REG2 encoded in this byte)
	 --16#0004# => X"9E", -- PC (DST)

	 16#EEFF# => X"61", --MOV TO REG 1 VALUE: 255
	 16#EF00# => X"FF",
	 
	 16#EF01# => X"00", --ADD 1 TO REG 0
	 16#EF02# => X"01",
	
	 16#EF03# => X"19",-- SUB TO REG 1 REG 0
    16#EF04# => X"18",
	 
	 16#EF05# => X"96", --JNZ TO IMM16 0xEEEE
	 16#EF06# => X"FF", 
	 16#EF07# => X"EE", 
	 
	 16#EF08# => X"80", --STR VAL REG 0
	 16#EF09# => X"04",--LSB
	 16#EF0A# => X"00", --MSB
	 
	 16#EF0B# => X"B6", --JMP TO IMM16 0xEF0B WHILE(1)
	 16#EF0C# => X"0B", --LSB
	 16#EF0D# => X"EF", --MSB
	 
	 


	 --16#0008# => X"00",

--	 16#0000# => X"61", --MOV TO REG 1 VALUE: 255
--	 16#0001# => X"FF",
--	 
--	 16#0002# => X"00", --ADD 1 TO REG 0
--	 16#0003# => X"01",
--	
--	 16#0004# => X"19",-- SUB TO REG 1 REG 0
--    16#0005# => X"18",
--	 
--	 16#0006# => X"9A", --JNZ TO DIRECTION IN REG 2 (SRC REG1 encoded in this byte)
--	 16#0007# => X"9E", --REG 2
	 
	 
	 
--	 16#0000# =>  X"10",-- SUB TO REG 0 INST (IMM8)
--	 16#0001# =>  X"02",-- IMM, VAL = 0x02
--	 
--	 16#0002# =>  X"C0",-- SHL REG 0 INST
--	 16#0003# =>  X"00",-- NOT USED
--	 
--	 16#0004# =>  X"A9",-- ADC TO REG 1 INST (REG)
--	 16#0005# =>  X"A8",-- REG 2
--	 
--	 16#0006# =>  X"62",-- MOV TO REG 2 (IMM8)
--	 16#0007# =>  X"0F",-- IMM, VAL = 0x0F
--	 
--	 16#0008# =>  X"0B",-- ADD TO REG 3 INST (REG)
--	 16#0009# =>  X"0A",-- REG 2
--	 
--	 16#000A# => X"6B", --MOV TO REG 4 REG 3 VALUE INST (REG)
--	 16#000B# => X"6C", --REG 4 (DST)
--	 
--	 16#000C# => X"06", --ADD TO REG 6 INST (IMM8)
--	 16#000D# => X"00", --IMM, VAL = 0x00
--	 
--	 16#000E# =>  X"1B",-- SUB TO REG 3 INST (REG)
--	 16#000F# =>  X"1B",-- REG 2
--	 
--	 16#0010# => X"96", --JNZ INST (IMM16)
--	 16#0011# => X"06", --IMM8 LSB, VAL = 0x06
--	 16#0012# => X"00", --IMM8 MSB, VAL = 0x00



	 
	 others => (others => '0'));  -- Inicializaci�n en ceros
begin
    process (clk)
    begin
        if rising_edge(clk) then

            if we = '1' then
                RAM(to_integer(unsigned(address))) <= data_in;
				else
					 data_out <= RAM(to_integer(unsigned(address)));
				end if;
            
								data_out2 <= RAM(to_integer(unsigned(address2)));

				
        end if;
		  
		  
    end process;
	
	 

end Behavioral;
