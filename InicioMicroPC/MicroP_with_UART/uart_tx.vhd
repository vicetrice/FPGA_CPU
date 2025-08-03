-- Listing 7.3
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart_tx is
   generic(
      DBIT: integer:=8;     -- # data bits
      SB_TICK: integer:=16  -- # ticks for stop bits
   );
   port(
      clk, reset: in std_logic;
      tx_start: in std_logic; -- Al poner a '1' se inicia la transmisin
      s_tick: in std_logic;
      din: in std_logic_vector(7 downto 0); --dato a transmitir
      fin_tx: out std_logic; --Pulso que indica final de transmisin
      tx: out std_logic
   );
end uart_tx ;

architecture arch of uart_tx is
   type state_type is (idle, start, data, stop);
   signal estado_act, estado_sig: state_type;
   signal cuenta_act, cuenta_sig: unsigned(4 downto 0);
   signal nbit_act, nbit_sig: unsigned(2 downto 0);
   signal trama_act, trama_sig: std_logic_vector(7 downto 0);
   signal tx_act, tx_sig: std_logic;
begin
   -- FSMD state & data registers
   process(clk,reset)
   begin
      if reset='1' then
         estado_act <= idle;
         cuenta_act <= (others=>'0');
         nbit_act <= (others=>'0');
         trama_act <= (others=>'0');
         tx_act <= '1';
      elsif (clk'event and clk='1') then
         estado_act <= estado_sig;
         cuenta_act <= cuenta_sig;
         nbit_act <= nbit_sig;
         trama_act <= trama_sig;
         tx_act <= tx_sig;
      end if;
   end process;
   -- next-state logic & data path functional units/routing
   process(estado_act,cuenta_act,nbit_act,trama_act,s_tick,
           tx_act,tx_start,din)
   begin
      estado_sig <= estado_act;
      cuenta_sig <= cuenta_act;
      nbit_sig <= nbit_act;
      trama_sig <= trama_act;
      tx_sig <= tx_act ;
      fin_tx <= '0';
      case estado_act is
         when idle =>

            --completar estado de reposo de transmisin 
					if tx_start = '1' then
					cuenta_sig <= (others => '0');
					estado_sig <= start;
					trama_sig <= din;
					tx_sig <= '0';
					end if;

         when start =>
				
				if s_tick = '1' then
					if cuenta_act = 31 then
						cuenta_sig <= (others => '0');
						nbit_sig <= (others =>'0');
						tx_sig <= trama_act(0);
						trama_sig <= '1' & trama_act(7 downto 1); 
						estado_sig <= data;
					else
						cuenta_sig <= cuenta_act + 1;
					end if;
				end if;

            --completar estado de inicio de transmisin            

         when data =>
				if s_tick = '1' then
					if cuenta_act = 31 then
						cuenta_sig <= (others => '0');
						tx_sig <= trama_act(0);
						trama_sig <= '1' & trama_act(7 downto 1);
						if nbit_act = to_unsigned(DBIT - 1,3) then
							estado_sig <= stop;
						else
							nbit_sig <= nbit_act + 1;
						end if;
					else
						cuenta_sig <= cuenta_act + 1;
					end if;
				end if;
            --completar estado de transmisin de datos            

         when stop =>
				if s_tick = '1' then
				
					if cuenta_act = to_unsigned(SB_TICK -1,5) then
						fin_tx <= '1';
						estado_sig <= idle;
					else
						cuenta_sig <= cuenta_act + 1;
					end if;
				end if;

            --completar estado de parada de transmisin            

      end case;
   end process;
   tx <= tx_act;
end arch;
