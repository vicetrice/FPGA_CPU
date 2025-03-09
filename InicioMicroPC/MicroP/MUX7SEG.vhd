

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;



entity MUX7SEG is
  port( CLK, RST: in STD_LOGIC;
			D5: in STD_LOGIC_VECTOR(3 downto 0);
			D4: in STD_LOGIC_VECTOR(3 downto 0);
			D3: in STD_LOGIC_VECTOR(3 downto 0);
			D2: in STD_LOGIC_VECTOR(3 downto 0);
			D1: in STD_LOGIC_VECTOR(3 downto 0);
			D0: in STD_LOGIC_VECTOR(3 downto 0);
        CAT: out STD_LOGIC_VECTOR(6 downto 0);
        AN5,AN4,AN3,AN2,AN1,AN0: out STD_LOGIC );
end MUX7SEG;

architecture MIXTA of MUX7SEG is 

component HEX7SEG
  port(H3,H2,H1,H0: in STD_LOGIC;
       A,B,C,D,E,F,G: out STD_LOGIC );
end  component;

  signal AN: STD_LOGIC_VECTOR (5 downto 0);
  signal H: STD_LOGIC_VECTOR (3 downto 0);
  signal CNT: INTEGER;
  for DEC: HEX7SEG use entity WORK.HEX7SEG(F);
 


  
    
  
begin
  DEC: HEX7SEG port map ( H(3), H(2), H(1), H(0),
                          CAT(0), CAT(1), CAT(2), CAT(3), CAT(4), CAT(5), CAT(6) );

  process
  begin
    wait until CLK'EVENT and CLK='1';
    if RST='1' then
      AN <= "111110"; CNT <=5000 ;
    else
      CNT <= CNT - 1;
      if CNT = 0 then
        AN <= AN(4 downto 0) & AN(5);
        CNT <= 5000;
      end if;
    end if;
  end process;
  
  H <= D0 when AN="111110" else
       D1 when AN="111101" else
       D2 when AN="111011" else
       D3 when AN="110111" else
		 D4 when AN="101111" else
       D5 when AN="011111" else
       "XXXX";
		 
  AN5 <= AN(5);AN4 <= AN(4);AN3 <= AN(3); AN2 <= AN(2); AN1 <= AN(1); AN0 <= AN(0);
  
  
end;
