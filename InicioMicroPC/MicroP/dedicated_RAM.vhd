library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_64Kx8 is
    Port (
        clk     : in  std_logic;                           -- Reloj
        we      : in  std_logic;                           -- Habilitación de escritura
        address : in  std_logic_vector(15 downto 0);       -- Dirección de memoria (64K posiciones)
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
	 --		equivalent in C until direction 0xEF12, while (1) is at the end
	 -- do {++Reg1; }while ( Reg1 != 0x07) Reg1;
	 -- Reg1 = Reg1 << 1;
	 -- Reg1 = Reg1 >> 1;
	 -- while(1); 
	 
	 16#0000# => X"B6", --/*
	 16#0001# => X"FA", -- 
	 16#0002# => X"EE", -- LDA IP ,0xEEFB*/
	 
	 
	 
	 
	 --16#0003# => X"9A", --JNZ TO DIRECTION IN REG 2 (SRC REG2 encoded in this byte)
	 --16#0004# => X"9E", -- PC (DST)
    
	 16#EEFA# => X"61", --/*
	 16#EEFB# => X"07", --MOV R1, 0x07*/
	 
	 16#EEFC# => X"60", --/*
 	 16#EEFD# => X"00", -- MOV R0, 0x00*/
	 
	 16#EEFE# => X"80", --/*STR  [0x0004], R0 
	 16#EEFF# => X"04", --LSB
	 16#EF00# => X"00", --MSB*/
	 
	 
	 16#EF01# => X"00", --/*
	 16#EF02# => X"01", --ADD R0, 0x01*/ 
	
	 16#EF03# => X"28", -- /*
    16#EF04# => X"29", -- CMP R0, R1*/
	 
	 16#EF05# => X"96", -- /* JNZ 0xEF01
	 16#EF06# => X"FE", -- LSB
	 16#EF07# => X"EE", -- MSB*/

	 16#EF08# => X"B2", --/*LDA R2, 0x0004
	 16#EF09# => X"04", --LSB 
	 16#EF0A# => X"00", --MSB*/
	 
	 16#EF0B# => X"88", --/*
	 16#EF0C# => X"8A", --STR [R2], R0 */
	 
	 16#EF0D# => X"C0", --/*SHL R0
	 16#EF0E# => X"00", --PADDING BYTE*/
	 
	 16#EF0F# => X"88", --/*
	 16#EF10# => X"8A", --STR [R2], R0 */
	 
	 16#EF11# => X"C8", --/*SHR R0
	 16#EF12# => X"00", --PADDING BYTE*/
	 
	 16#EF13# => X"88", --/*	 
	 16#EF14# => X"8A", --STR [R2], R0*/
	 
	 16#EF15# => X"FB", --/*POPF R3
	 16#EF16# => X"00", --PADDING BYTE*/
	 
	 16#EF17# => X"8B", --/*
	 16#EF18# => X"8A", --STR [R2], R3*/
	 
	 16#EF19# => X"D0", --/*PUSHF 0xDD (REG SEL BITS DOESN'T MATTER)
	 16#EF1A# => X"DD", -- */
	 
	 16#EF1B# => X"FB", --/*POPF R3
	 16#EF1C# => X"00", --PADDING BYTE*/
	 
	 16#EF1D# => X"8B", --/* 
	 16#EF1E# => X"8A", --STR [R2], R3 */
	 
	 16#EF1F# => X"D8", --/*PUSHF R0 
	 16#EF20# => X"00", --PADDING BYTE*/ 
	 
	 16#EF21# => X"FB", --/*POPF R3
	 16#EF22# => X"00", --PADDING BYTE*/
	 
	 16#EF23# => X"8B", --/*STR [R2], R3 
	 16#EF24# => X"8A", -- */
	 
	 16#EF25# => X"74", --/*LDR R4, [0x0004]
	 16#EF26# => X"04", --LSB
	 16#EF27# => X"00", --MSB*/
	 
	 16#EF28# => X"04", --/*ADD R4, 0x01
	 16#EF29# => X"01", -- */
	 
	 16#EF2A# => X"8C", --/*STR [R2], R4 
	 16#EF2B# => X"8A", --*/
	 
	 16#EF2C# => X"7A", --/*LDR R5, [R2]
	 16#EF2D# => X"7D", -- */
	 
	 16#EF2E# => X"05", --/*ADD R5, 0x01
	 16#EF2F# => X"01", --*/
	 
	 16#EF30# => X"8D", --/*STR [R2], R5 
	 16#EF31# => X"8A", -- */
	 
	 16#EF32# => X"B6", --/*JMP 0xEF32
	 16#EF33# => X"32", --LSB
	 16#EF34# => X"EF", --MSB (inf loop)*/
	 
	 


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



	 
	 others => (others => '0'));  -- Inicialización en ceros
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
