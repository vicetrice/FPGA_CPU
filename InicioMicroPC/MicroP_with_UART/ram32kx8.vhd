library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM_32Kx8 is
    Port (
        clk     : in  std_logic;                           -- Reloj
        we      : in  std_logic;                           -- Habilitacin de escritura
        address : in  std_logic_vector(14 downto 0);       -- Direccin de memoria (64K posiciones)
		  address2 : in  std_logic_vector(14 downto 0);      -- ONLY READ ADDRESS
		  data_out2: out std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
		  data_in : in std_logic_vector(7 downto 0)      
    );
end RAM_32Kx8;

architecture Behavioral of RAM_32Kx8 is
    type RAM_Array is array (0 to 32767) of std_logic_vector(7 downto 0);
    signal RAM : RAM_Array := (
--	 
--	 --			PROGRAM
--	 --		equivalent in C until direction 0xEF12, while (1) is at the end
--	 -- do {++Reg1; }while ( Reg1 != 0x07) Reg1;
--	 -- Reg1 = Reg1 << 1;
--	 -- Reg1 = Reg1 >> 1;
--	 -- while(1); 
--	 
--	 16#0000# => X"B6", --/*
--	 16#0001# => X"FA", -- 
--	 16#0002# => X"EE", -- LEA IP ,[0xEEFB]*/
	
--	16#000# => X"B6", --/*
--	16#001# => X"BB",	--
--	16#002# => X"00",	-- LEA IP, [0x00BB]*/
--	
--	16#0BB# => X"60", --/*
--	16#0BC# => X"31", -- MOV R0, 0x31*/
--	
--	16#0BD# => X"80", --/*STR  [0xFFF0], R0 
--	16#0BE# => X"F0", --LSB
--	16#0BF# => X"FF", --MSB*/
--	
--	16#0C0# => X"B6", --/*JMP 0x00C8
--	16#0C1# => X"BD", --LSB
--	16#0C2# => X"00", --MSB (inf loop)*/
--	
--	16#0C0# => X"71", --/*LDR R1, [0xFFF1]
--	16#0C1# => X"F1", --LSB
--	16#0C2# => X"FF", --MSB*/
--	
--	16#0C3# => X"28", -- /*
--   --16#0C4# => X"29", -- CMP R0,R1*/
	
	--16#0C5# => X"96", -- /* JNZ 0x00C0
	--16#0C6# => X"C0", -- LSB
	--16#0C7# => X"00", -- MSB*/
	
--	16#0C8# => X"B6", --/*JMP 0x00C8
--	16#0C9# => X"C8", --LSB
--	16#0CA# => X"00", --MSB (inf loop)*/
	
	
	
	
	
	
	
	
	
--	 
--	 
--	 
--	 
--	 --16#0003# => X"9A", --JNZ TO DIRECTION IN REG 2 (SRC REG2 encoded in this byte)
--	 --16#0004# => X"9E", -- PC (DST)
--    
--	 16#EEFA# => X"61", --/*
--	 16#EEFB# => X"07", --MOV R1, 0x07*/
--	 
--	 16#EEFC# => X"60", --/*
-- 	 16#EEFD# => X"00", -- MOV R0, 0x00*/
--	 
--	 16#EEFE# => X"80", --/*STR  [0x0004], R0 
--	 16#EEFF# => X"04", --LSB
--	 16#EF00# => X"00", --MSB*/
--	 
--	 
--	 16#EF01# => X"00", --/*
--	 16#EF02# => X"01", --ADD R0, 0x01*/ 
--	
--	 16#EF03# => X"28", -- /*
--    16#EF04# => X"29", -- CMP R0, R1*/
--	 
--	 16#EF05# => X"96", -- /* JNZ 0xEF01
--	 16#EF06# => X"FE", -- LSB
--	 16#EF07# => X"EE", -- MSB*/
--
--	 16#EF08# => X"B2", --/*LEA R2, [0x0004]
--	 16#EF09# => X"04", --LSB 
--	 16#EF0A# => X"00", --MSB*/
--	 
--	 16#EF0B# => X"88", --/*
--	 16#EF0C# => X"8A", --STR [R2], R0 */
--	 
--	 16#EF0D# => X"C0", --/*SHL R0
--	 16#EF0E# => X"00", --PADDING BYTE*/
--	 
--	 16#EF0F# => X"88", --/*
--	 16#EF10# => X"8A", --STR [R2], R0 */
--	 
--	 16#EF11# => X"C8", --/*SHR R0
--	 16#EF12# => X"00", --PADDING BYTE*/
--	 
--	 16#EF13# => X"88", --/*	 
--	 16#EF14# => X"8A", --STR [R2], R0*/
--	 
--	 16#EF15# => X"FB", --/*POPF R3
--	 16#EF16# => X"00", --PADDING BYTE*/
--	 
--	 16#EF17# => X"8B", --/*
--	 16#EF18# => X"8A", --STR [R2], R3*/
--	 
--	 16#EF19# => X"D0", --/*PUSHF 0xDD (REG SEL BITS DOESN'T MATTER)
--	 16#EF1A# => X"DD", -- */
--	 
--	 16#EF1B# => X"FB", --/*POPF R3
--	 16#EF1C# => X"00", --PADDING BYTE*/
--	 
--	 16#EF1D# => X"8B", --/* 
--	 16#EF1E# => X"8A", --STR [R2], R3 */
--	 
--	 16#EF1F# => X"D8", --/*PUSHF R0 
--	 16#EF20# => X"00", --PADDING BYTE*/ 
--	 
--	 16#EF21# => X"FB", --/*POPF R3
--	 16#EF22# => X"00", --PADDING BYTE*/
--	 
--	 16#EF23# => X"8B", --/*STR [R2], R3 
--	 16#EF24# => X"8A", -- */
--	 
--	 16#EF25# => X"74", --/*LDR R4, [0x0004]
--	 16#EF26# => X"04", --LSB
--	 16#EF27# => X"00", --MSB*/
--	 
--	 16#EF28# => X"04", --/*ADD R4, 0x01
--	 16#EF29# => X"01", -- */
--	 
--	 16#EF2A# => X"8C", --/*STR [R2], R4 
--	 16#EF2B# => X"8A", --*/
--	 
--	 16#EF2C# => X"7A", --/*LDR R5, [R2]
--	 16#EF2D# => X"7D", -- */
--	 
--	 16#EF2E# => X"05", --/*ADD R5, 0x01
--	 16#EF2F# => X"01", --*/
--	 
--	 16#EF30# => X"8D", --/*STR [R2], R5 
--	 16#EF31# => X"8A", -- */
--	 
--	 16#EF32# => X"B7", --/*LEA SP, 0xA9A8
--	 16#EF33# => X"A8", --
--	 16#EF34# => X"A9", --*/
--	 
--	 16#EF35# => X"E0", --/*PUSH 0x99
--	 16#EF36# => X"99", --*/
--	 
--	 16#EF37# => X"F5", --/*POP R5
--	 16#EF38# => X"00", --PADDING BYTE*/
--	 
--	 16#EF39# => X"05", --/*ADD R5, 0x04
--	 16#EF3A# => X"04", --*/
--	 
--	 16#EF3B# => X"ED", --/*PUSH R5
--	 16#EF3C# => X"00", --PADDING BYTE*/
--	 
--	 16#EF3D# => X"F4", --/*POP R4
--	 16#EF3E# => X"00", --PADDING BYTE*/
--	 
--	 16#EF3F# => X"8C", --/*STR [R2], R4 
--	 16#EF40# => X"8A", -- */
--	 
--	 16#EF41# => X"8F", --/*STR [R2], SP 
--	 16#EF42# => X"8A", -- */
--	 
--	 16#EF43# => X"B6", --/*JMP 0xEF43
--	 16#EF44# => X"43", --LSB
--	 16#EF45# => X"EF", --MSB (inf loop)*/
--	 
	 


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

--    -- Programa para enviar "Hola mundo" por UART esperando confirmación 0xAC
--		
--	 16#000# => X"B6", --/*
--	 16#001# => X"00", -- 
--	 16#002# => X"01", -- LEA IP ,[0x0100]*/	
--		
--    16#100# => X"B2", -- LEA R2, 0x00BB
--    16#101# => X"BB",
--    16#102# => X"00",
--
--    16#103# => X"7A", -- LOOP SEND: LDR R0, [R2]
--    16#104# => X"78",
--
--    16#105# => X"20", -- CMP R0, 0x00
--    16#106# => X"00",
--
--    16#107# => X"96", -- JNZ CONTINUE (salta a 0x010D)
--    16#108# => X"0D",
--    16#109# => X"01",
--	 
--	 16#10A# => X"B6", -- JMP END (0x0120)
--    16#10B# => X"20",
--    16#10C# => X"01",
--
--    16#10D# => X"80", -- CONTINUE: STR [0xFFF0], R0
--    16#10E# => X"F0",
--    16#10F# => X"FF",
--
--    16#110# => X"71", -- WAIT_CONFIRM: LDR R1, [0xFFF1]
--    16#111# => X"F1",
--    16#112# => X"FF",
--
--    16#113# => X"21", -- CMP R1, 0x23
--    16#114# => X"31",
--
--    16#115# => X"96", -- JNZ WAIT_CONFIRM (salta a 0x0110)
--    16#116# => X"10",
--    16#117# => X"01",
--	 
--	 16#118# => X"80", -- STR [0xFFF1], R0 ( Wiritng to UART RX reg works to confirm the message is received to UART)
--    16#119# => X"F1",
--    16#11A# => X"FF",
--	 
--    16#11B# => X"02", -- ADD R2, 0x01
--    16#11C# => X"01",
--
--    16#11D# => X"B6", -- JMP LOOP_SEND (0x0103)
--    16#11E# => X"03",
--    16#11F# => X"01",
--
--    16#120# => X"B6", -- END: JMP END (loop infinito)
--    16#121# => X"20",
--    16#122# => X"01",
--
--
--    -- Cadena "Hola mundo" en 0x00BB
--    16#0BB# => X"48", -- 'H'
--    16#0BC# => X"6F", -- 'o'
--    16#0BD# => X"6C", -- 'l'
--    16#0BE# => X"61", -- 'a'
--    16#0BF# => X"20", -- ' '
--    16#0C0# => X"6D", -- 'm'
--    16#0C1# => X"75", -- 'u'
--    16#0C2# => X"6E", -- 'n'
--    16#0C3# => X"64", -- 'd'
--    16#0C4# => X"6F", -- 'o'
--    16#0C5# => X"00",  -- null terminator

-- Programa para enviar "Hola mundo" por UART esperando confirmación 0xAC
		
	 16#000# => X"B6", --/*
	 16#001# => X"F0", -- 
	 16#002# => X"00", -- LEA IP ,[0x00F3]*/	
	 
	 
	 
	 16#0F0# => X"63",-- MOV R3, 0x04 
	 16#0F1# => X"04",
	 
	 16#0F2# => X"83", -- STR [0xFFF2], R3 (SET GPIO'S TO INPUT OR OUTPUT)
    16#0F3# => X"F2",
    16#0F4# => X"FF",
	 
	 16#0F5# => X"83", -- STR [0xFFF3], R3 ( SET GPIO 3 TO '1')
    16#0F6# => X"F3",
    16#0F7# => X"FF",
	
    16#0F8# => X"B2", -- LEA R2, 0x00BB
    16#0F9# => X"BB",
    16#0FA# => X"00",
	 
	 16#0FB# => X"71", -- READ_GPIO_RX: LDR R1, [0xFFF4] (from GPIO)
    16#0FC# => X"F4",
    16#0FD# => X"FF",
	 
	 
	 16#0FE# => X"21", -- CMP R1, 0x05 (KEY 2 PRESSED)
    16#0FF# => X"05",
	 
	 
	 
	 16#100# => X"96", -- JNZ READ_GPIO_RX
    16#101# => X"FB",
    16#102# => X"00",

    16#103# => X"7A", -- LDR R0, [R2]
    16#104# => X"78",

    16#105# => X"20", -- CMP R0, 0x00
    16#106# => X"00",

    16#107# => X"96", -- JNZ CONTINUE (salta a 0x010D)
    16#108# => X"0D",
    16#109# => X"01",
	 
	 16#10A# => X"B6", -- JMP NEAR_END (0x0120)
    16#10B# => X"20",
    16#10C# => X"01",

    16#10D# => X"80", -- CONTINUE: STR [0xFFF0], R0
    16#10E# => X"F0",
    16#10F# => X"FF",

    16#110# => X"71", -- WAIT_CONFIRM: LDR R1, [0xFFF4] (from GPIO)
    16#111# => X"F4",
    16#112# => X"FF",

    16#113# => X"21", -- CMP R1, 0x06 (KEY 1 PRESSED)
    16#114# => X"06",

    16#115# => X"96", -- JNZ WAIT_CONFIRM (salta a 0x0110)
    16#116# => X"10",
    16#117# => X"01",
	 
	 16#118# => X"80", -- STR [0xFFF1], R0 ( Wiritng to UART RX reg works to confirm the message is received to UART)
    16#119# => X"F1",
    16#11A# => X"FF",
	 
    16#11B# => X"02", -- ADD R2, 0x01
    16#11C# => X"01",

    16#11D# => X"B6", -- JMP READ_GPIO_RX (0x00FB)
    16#11E# => X"FB",
    16#11F# => X"00",

	 16#120# => X"63",-- NEAR_END: MOV R3, 0x04 
	 16#121# => X"00",

	 16#122# => X"83", -- STR [0xFFF3], R3 (SET GPIO 3 to '0')
    16#123# => X"F3",
    16#124# => X"FF",
	 
    16#125# => X"B6", -- END: JMP END (loop infinito)
    16#126# => X"25",
    16#127# => X"01",


    -- Cadena "Hola mundo" en 0x00BB
    16#0BB# => X"48", -- 'H'
    16#0BC# => X"6F", -- 'o'
    16#0BD# => X"6C", -- 'l'
    16#0BE# => X"61", -- 'a'
    16#0BF# => X"20", -- ' '
    16#0C0# => X"6D", -- 'm'
    16#0C1# => X"75", -- 'u'
    16#0C2# => X"6E", -- 'n'
    16#0C3# => X"64", -- 'd'
    16#0C4# => X"6F", -- 'o'
    16#0C5# => X"00",  -- null terminator







	 
	 others => (others => '0'));  -- Inicializacin en ceros
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
