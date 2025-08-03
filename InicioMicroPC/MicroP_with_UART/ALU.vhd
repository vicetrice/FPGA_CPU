library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port ( A       : in  STD_LOGIC_VECTOR (7 downto 0);  
           B       : in  STD_LOGIC_VECTOR (7 downto 0);  
           opcode  : in  STD_LOGIC_VECTOR (3 downto 0);  
           StatIn  : in  STD_LOGIC_VECTOR (7 downto 0);  
           Result  : out STD_LOGIC_VECTOR (7 downto 0);  
           StatOut : out STD_LOGIC_VECTOR (7 downto 0)
         );
end ALU;

architecture Behavioral of ALU is
begin
    process(A, B, opcode, StatIn)
        variable add_sub : STD_LOGIC_VECTOR(8 downto 0);
        variable Res     : STD_LOGIC_VECTOR(7 downto 0);
		  variable check	 : boolean;
    begin
        -- Valores por defecto
        Result <= "11111111";
        StatOut <= StatIn;
		  
		  check := true;
        case opcode is
            when "0000" =>  -- ADD (A + B)
                add_sub := ('0' & A) + ('0' & B);
                Res := add_sub(7 downto 0);
					 StatOut(1) <= add_sub(8);
                
            when "0001" =>  -- SUB (A - B)
                add_sub := ('0' & A) - ('0' & B);
                Res := add_sub(7 downto 0);
					 StatOut(1) <= add_sub(8);
                
            when "0010" =>  -- CMP (A CMP B)
					 if( A < B) then
					 Res := X"FF";
					 StatOut(3) <= '1';
					 StatOut(2) <= '0';
					 elsif A > B then
					 Res := X"FF";
					 StatOut(3) <= '0';
					 StatOut(2) <= '0';
					 else
					 StatOut(3) <= '0';
					 StatOut(2) <= '1';
					 Res := X"00";
					 end if;


            when "0011" =>  -- SBB (A - B - Carry)
                add_sub := ('0' & A) - ('0' & B) - StatIn(1);
                Res := add_sub(7 downto 0);
					 StatOut(1) <= add_sub(8);
                
            when "0100" =>  -- XOR (A XOR B)
                Res := A xor B;
                
            when "0101" =>  -- NOR (A NOR B)
                Res := A nor B;
                
            when "1010" =>  -- ADC (A + B + Carry)
                add_sub := ('0' & A) + ('0' & B) + StatIn(1);
                Res := add_sub(7 downto 0);
					 StatOut(1) <= add_sub(8);
                
            when "1100" =>  -- SHL (Desplazamiento lógico izquierda)
                Res := A(6 downto 0) & '0';
					 StatOut(1) <= A(7);
						
            when "1101" =>  -- SHR (Desplazamiento lógico derecha)
                Res := '0' & A(7 downto 1);
					 StatOut(1) <= A(0);
                
            when others =>
                Res := "11111111";  -- Valor por defecto
					 check := false;

        end case;
		   
			if(check) then
				if Res = "00000000" then
					StatOut(0) <= '1';
				else 
					StatOut(0) <= '0';
				end if;
			end if;
			
        Result <= Res;
      
    end process;
end Behavioral;