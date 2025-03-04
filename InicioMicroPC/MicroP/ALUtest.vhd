library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_tb is
end ALU_tb;

architecture behavior of ALU_tb is

    -- Componente de la ALU
    component ALU
        Port ( A        : in  STD_LOGIC_VECTOR (7 downto 0);
               B        : in  STD_LOGIC_VECTOR (7 downto 0);
               opcode   : in  STD_LOGIC_VECTOR (3 downto 0);
               StatIn   : in  STD_LOGIC_VECTOR (7 downto 0);
               Result   : out STD_LOGIC_VECTOR (7 downto 0);
               StatOut  : out STD_LOGIC_VECTOR (7 downto 0)
             );
    end component;

    -- Señales de prueba
    signal A, B            : STD_LOGIC_VECTOR(7 downto 0);
    signal opcode          : STD_LOGIC_VECTOR(3 downto 0);
    signal StatIn          : STD_LOGIC_VECTOR(7 downto 0);
    signal StatOut         : STD_LOGIC_VECTOR(7 downto 0);
    signal Result          : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Instancia de la ALU
    uut: ALU
        port map ( A => A, B => B, opcode => opcode, StatIn => StatIn,
                   Result => Result, StatOut => StatOut );

    -- Proceso de estímulo con aserciones
    stim_proc: process
    begin
        -- Test 1: ADD (A + B)
        A <= "00001111"; B <= "00000001"; opcode <= "0000"; StatIn <= "00000000";
        wait for 10 ns;
        assert Result = "00010000" and StatOut = X"00" report "Test 1 Falló: ADD incorrecto" severity failure;

        -- Test 2: ADC (A + B + Carry)
        opcode <= "1010"; StatIn <= StatOut; wait for 10 ns;
        assert Result = "00010000" and StatOut = X"00" report "Test 2 Falló: ADC incorrecto" severity failure;

        -- Test 3: ADC con Carry (255 + 1 + 0 = 0, carry = 1)
        A <= "11111111"; B <= "00000001";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00000000" and StatOut = X"03"  report "Test 3 Falló: ADC con Carry incorrecto" severity failure;

        -- Test 4: ADC con Carry (15 + 1 + 1 = 17)
        A <= "00001111"; B <= "00000001";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00010001" and StatOut = X"00" report "Test 4 Falló: ADC con Carry incorrecto" severity failure;

        -- Test 5: SUB (15 - 2 = 13)
        A <= "00001111"; B <= "00000010"; opcode <= "0001";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00001101" and StatOut = X"00" report "Test 5 Falló: SUB incorrecto" severity failure;

        -- Test 6: SUBB con Borrow (0 - 1 = 255 con borrow)
        A <= "00000000"; B <= "00000001"; opcode <= "0011";StatIn <= StatOut; wait for 10 ns;
        assert Result = "11111111" and StatOut = X"02" report "Test 6 Falló: SUBB incorrecto" severity failure;

        -- Test 7: SUBB con Borrow (2 - 3 - 1 = 254 con borrow)
        A <= "00000010"; B <= "00000011";StatIn <= StatOut; wait for 10 ns;
        assert Result = "11111110" and StatOut = X"02" report "Test 7 Falló: SUBB incorrecto" severity failure;

        -- Test 8: NAND (10101010 NAND 11001100 = 01010111)
        A <= "10101010"; B <= "11001100"; opcode <= "0010";StatIn <= StatOut; wait for 10 ns;
        assert Result = "01110111" and StatOut = X"02" report "Test 8 Falló: NAND incorrecto" severity failure;

        -- Test 9: XOR (10101010 XOR 11001100 = 01100110)
        opcode <= "0100";StatIn <= StatOut; wait for 10 ns;
        assert Result = "01100110" and StatOut = X"02" report "Test 9 Falló: XOR incorrecto" severity failure;

        -- Test 10: NOR (10101010 NOR 11001100 = 00010001)
        opcode <= "0101";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00010001" and StatOut = X"02" report "Test 10 Falló: NOR incorrecto" severity failure;

        -- Test 11: SHL (0x0F << 1 = 0x1E)
        A <= "00001111"; opcode <= "1100";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00011110" and StatOut = X"00" report "Test 11 Falló: SHL incorrecto" severity failure;

        -- Test 12: SHR (0xF0 >> 1 = 0x78)
        A <= "11110000"; opcode <= "1101";StatIn <= StatOut; wait for 10 ns;
        assert Result = "01111000" and StatOut = X"00" report "Test 12 Falló: SHR incorrecto" severity failure;

        -- Test 13: NAND con todos los bits en 1 (0xFF NAND 0xFF = 0x00)
        A <= "11111111"; B <= "11111111"; opcode <= "0010";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00000000" and StatOut = X"01" report "Test 13 Falló: NAND incorrecto" severity failure;

        -- Test 14: XOR con sí mismo (0xAA XOR 0xAA = 0x00)
        A <= "10101010"; B <= "10101010"; opcode <= "0100";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00000000" and StatOut = X"01" report "Test 14 Falló: XOR incorrecto" severity failure;

        -- Test 15: NOR con todos los bits en 0 (0x00 NOR 0x00 = 0xFF)
        A <= "00000000"; B <= "00000000"; opcode <= "0101";StatIn <= StatOut; wait for 10 ns;
        assert Result = "11111111" and StatOut = X"00" report "Test 15 Falló: NOR incorrecto" severity failure;

        -- Test 16: SHL con 1 en MSB (0x80 << 1 = 0x00 con carry)
        A <= "10000000"; opcode <= "1100";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00000000" and StatOut = X"03" report "Test 16 Falló: SHL incorrecto" severity failure;

        -- Test 17: SHR con 1 en LSB (0x01 >> 1 = 0x00 con carry)
        A <= "00000001"; opcode <= "1101";StatIn <= StatOut; wait for 10 ns;
        assert Result = "00000000" and StatOut = X"03" report "Test 17 Falló: SHR incorrecto" severity failure;

        -- Test 18: Operación inválida (opcode 1111, resultado sin cambios)
        A <= "00001111"; B <= "00001111"; opcode <= "1111";StatIn <= StatOut; wait for 10 ns;
        assert Result = "11111111" and StatOut = X"03" report "Test 18 Falló: Operación inválida incorrecta" severity failure;

        -- Test 19: Operación con StatOut = StatIn
        StatIn <= X"03";StatIn <= StatOut; wait for 10 ns;
        assert StatOut = StatIn report "Test 19 Falló: StatOut incorrecto" severity failure;
			
        -- Test 20: Resultado cero al sumar opuestos (0x55 + 0xAA = 0xFF)
        A <= "01010101"; B <= "10101010"; opcode <= "0000";StatIn <= StatOut; wait for 10 ns;
        assert Result = "11111111" and StatOut = X"00" report "Test 20 Falló: Suma opuestos incorrecta" severity failure;

        -- Fin de pruebas
        report "TODOS LOS TESTS PASARON EXITOSAMENTE";
        wait;
    end process;

end behavior;
