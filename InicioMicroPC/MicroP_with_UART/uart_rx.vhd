
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart_rx is
   generic(
      DBIT: integer:=8;     -- # data bits
      SB_TICK: integer:=16  -- # ticks for stop bits
   );
   port(
      clk, reset: in std_logic;
      rx: in std_logic; --linea serie de entrada de datos
      s_tick: in std_logic; --pulso que indica fin de cuenta del contador externo
      fin_rx: out std_logic; --pulso generado de 1 ciclo clk que indica final de la recepcin
      dout: out std_logic_vector(7 downto 0) --salida en paralelo de los datos
   );
end uart_rx ;

architecture arch of uart_rx is
   type state_type is (idle, start, data, stop);
   signal estado_act, estado_sig: state_type;
   signal cuenta_act, cuenta_sig: unsigned(4 downto 0); --cuenta contador interno
   signal nbit_act, nbit_sig: unsigned(2 downto 0); --valor actual y siguiente de nmero de datos recibidos
   signal trama_act, trama_sig: std_logic_vector(7 downto 0); --valores actual y siguiente de trama de datos recibida
begin
   -- FSMD state & data registers
   process(clk,reset)
   begin
      if reset='1' then
         estado_act <= idle;
         cuenta_act <= (others=>'0');
         nbit_act <= (others=>'0');
         trama_act <= (others=>'0');
      elsif (clk'event and clk='1') then
         estado_act <= estado_sig;
         cuenta_act <= cuenta_sig;
         nbit_act <= nbit_sig;
         trama_act <= trama_sig;
      end if;
   end process;
   -- next-state logic & data path functional units/routing
   process(estado_act,cuenta_act,nbit_act,trama_act,s_tick,rx)
   begin
      estado_sig <= estado_act;
      cuenta_sig <= cuenta_act;
      nbit_sig <= nbit_act;
      trama_sig <= trama_act;
      fin_rx <='0';
      case estado_act is
         when idle =>

           if rx = '0' then
			  cuenta_sig <= (others => '0');
			  estado_sig <= start;
			  end if; 

         when start =>
			
			if s_tick = '1' then
				if cuenta_act = 15 then
					cuenta_sig <= (others => '0');
					nbit_sig <= (others => '0');
					estado_sig <= data;
				else
					cuenta_sig <= cuenta_act + 1;
				end if;
			
			end if;

            ---completar estado inicio de trama

         when data =>
			
			if s_tick = '1' then
				if cuenta_act = 31 then
					cuenta_sig <= (others => '0');
					trama_sig <= rx & trama_act(7 downto 1);
					if nbit_act = to_unsigned(DBIT - 1,3) then
						estado_sig <= stop;
					else
						nbit_sig <= nbit_act + 1;
					end if;
				else
					cuenta_sig <= cuenta_act + 1;
				end if;
			
			end if;

             -- completar estado que recoge los bits recibidos

         when stop =>
			
				if s_tick = '1' then
				
					if cuenta_act = to_unsigned(SB_TICK -1,5) then
						fin_rx <= '1';
						estado_sig <= idle;
					else
						cuenta_sig <= cuenta_act + 1;
					end if;
				end if;

            --completar estado de fin de trama            

      end case;
   end process;
   dout <= trama_act;
end arch;