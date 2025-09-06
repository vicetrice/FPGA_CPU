--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:21:18 08/02/2025
-- Design Name:   
-- Module Name:   /home/ise/Compartido_XILINX_VM/InicioMicroPC/CPU_UART/CPU_UART_TEST.vhd
-- Project Name:  CPU_UART
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hello_world
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY CPU_UART_TEST IS
END CPU_UART_TEST;
 
ARCHITECTURE behavior OF CPU_UART_TEST IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hello_world
    PORT(
         clk : IN  std_logic;
         rest : IN  std_logic;
         uart_tx : OUT  std_logic;
         uart_rx : IN  std_logic;
			gpio_pin: inout std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rest : std_logic := '0';
   signal uart_rx : std_logic := '0';
	signal gpio_pin: std_logic_vector(7 downto 0);

	

 	--Outputs
   signal uart_tx : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
	constant BIT_TIME : time := 104.17 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: hello_world PORT MAP (
          clk => clk,
          rest => rest,
          uart_tx => uart_tx,
          uart_rx => uart_rx,
			 gpio_pin => gpio_pin
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		gpio_pin <= X"FF";
		rest <= '0';
		uart_rx <= '1';
      -- hold reset state for 100 ns.
      wait for 1000 ns;	

      wait for clk_period*10;
		rest <= '1';

      wait for 2000 us;
		gpio_pin <= X"00";
		
		
		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		
--      wait for 2000 us;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '0';
--		wait for BIT_TIME;
--		
--		uart_rx <= '1';
--		wait for BIT_TIME;
--		
--		
		wait;
		
		
   end process;
	
	


END;
