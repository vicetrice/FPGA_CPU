----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:57:34 08/31/2025 
-- Design Name: 
-- Module Name:    gpio_module - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gpio_module is
port
(
	clk: in std_logic;
	reset: in std_logic;
	we_dir_reg: in std_logic;
	we_o_reg: in std_logic;
	dir_reg_in: in std_logic_vector(7 downto 0);
	o_reg_in: in std_logic_vector(7 downto 0);
	dir_reg_out: out std_logic_vector(7 downto 0);
	o_reg_out: out std_logic_vector(7 downto 0);
	i_reg_in: in std_logic_vector(7 downto 0);
	i_reg_out: out std_logic_vector(7 downto 0)
);
end gpio_module;

architecture Behavioral of gpio_module is
	begin

	dir_reg: process(clk)
	begin
	if rising_edge(clk) then
	
		if reset = '1' then
		dir_reg_out <= (others => '0');
		elsif we_dir_reg = '1' then
			dir_reg_out <= dir_reg_in;
		end if;
	end if;
	end process;
	
	o_reg: process(clk)
	begin
	if rising_edge(clk) then
	
		if reset = '1' then
			o_reg_out <= (others => '0');
		elsif we_o_reg = '1' then
			o_reg_out <= o_reg_in;
		end if;
	end if;
	end process;
	
	i_reg: process(clk)
	begin
	if rising_edge(clk) then
	
		if reset = '1' then
			i_reg_out <= (others => '0');
		else
			i_reg_out <= i_reg_in;
		end if;
	end if;
	end process;


end Behavioral;

