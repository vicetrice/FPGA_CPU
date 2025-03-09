-------------------------------------------------------------------------------
-- 
-- Ejercicio numero		1
-- Fichero:			HEX7SEG.vhd
-- Descripcion:			Covertidor Hexadecimal a 7 segmentos.
--                              Modulo puramente combinacional
-- Fecha:			17 de Otubre de 2007
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity HEX7SEG is

port(H3,H2,H1,H0: in STD_LOGIC;
     A,B,C,D,E,F,G: out STD_LOGIC );
end HEX7SEG;

architecture F of HEX7SEG is
  signal HEX: STD_LOGIC_VECTOR(3 downto 0);
  signal LED: STD_LOGIC_VECTOR(6 downto 0);
  
  
  
begin

  HEX <= (H3,H2,H1,H0);
  with HEX select
  LED<= "1111001" when "0001",	--1
        "0100100" when "0010",	--2
        "0110000" when "0011",	--3
        "0011001" when "0100",	--4
        "0010010" when "0101",	--5
        "0000010" when "0110",	--6
        "1111000" when "0111",	--7
        "0000000" when "1000",	--8
        "0010000" when "1001",	--9
        "0001000" when "1010",	--A
        "0000011" when "1011",	--b
        "1000110" when "1100",	--C
        "0100001" when "1101",	--d
        "0000110" when "1110",	--E
        "0001110" when "1111",	--F
        "1000000" when others;	--0
  (G,F,E,D,C,B,A) <= LED;

end;
