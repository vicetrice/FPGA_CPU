----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:36:45 03/02/2025 
-- Design Name: 
-- Module Name:    CPU2 - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;


entity CPU2 is
PORT (
		CLK : IN STD_LOGIC;
		RST: in STD_LOGIC;
		READY : IN STD_LOGIC;
		DATA_BUS_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DATA_BUS_IN_EXTERN: in STD_LOGIC_VECTOR(7 downto 0);
		EXTERN_READ: out STD_LOGIC;
		EXTERN_WRITE: out STD_LOGIC;
		
				ROM_ADDR_OUT: OUT STD_LOGIC_VECTOR(8 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				ALU_OUT_EXT: OUT STD_LOGIC_VECTOR(7 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				STAT_OUT: OUT STD_LOGIC_VECTOR(7 downto 0);  -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				REG_SEL_OUT_CPU : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
				AUX_REG_ADDR_OUT: OUT STD_LOGIC_VECTOR(15 downto 0) --SOLO TEST




	);
end CPU2;

architecture Behavioral of CPU2 is
component CPU 
PORT (
		CLK : IN STD_LOGIC;
		RST: in STD_LOGIC;
		READY : IN STD_LOGIC;
		DATA_BUS_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_BUS_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DATA_BUS_IN_EXTERN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		EXTERN_READ: out STD_LOGIC;
		EXTERN_WRITE: out STD_LOGIC;
		ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		
		
		ROM_ADDR_OUT: OUT STD_LOGIC_VECTOR(8 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		ALU_OUT_EXT: OUT STD_LOGIC_VECTOR(7 downto 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		STAT_OUT: OUT STD_LOGIC_VECTOR(7 downto 0);  -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		REG_SEL_OUT_CPU : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
		AUX_REG_ADDR_OUT: OUT STD_LOGIC_VECTOR(15 downto 0) --SOLO TEST



	);
end component;
signal internal_BUS_in: STD_LOGIC_VECTOR(7 downto 0);
signal internal_BUS_OUT: STD_LOGIC_VECTOR(7 downto 0);

begin

CentralPU: CPU port map(
			CLK => CLK,
			RST => RST,
			READY => READY,
			DATA_BUS_OUT => internal_BUS_OUT,
			DATA_BUS_IN => internal_BUS_in,
			DATA_BUS_IN_EXTERN => DATA_BUS_IN_EXTERN,
			extern_read => extern_read,
			extern_write => extern_write,
			ADDRESS_BUS => ADDRESS_BUS
			,
			ROM_ADDR_OUT  => ROM_ADDR_OUT,-- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
			ALU_OUT_EXT => ALU_OUT_EXT, -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
			STAT_OUT => STAT_OUT,   -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
			REG_SEL_OUT_CPU => REG_SEL_OUT_CPU,  -- USAR SOLO PARA TESTS!!!!!!!!!!!!!!!!!!!
			AUX_REG_ADDR_OUT => AUX_REG_ADDR_OUT --SOLO TEST


			

);
internal_BUS_in <= internal_BUS_OUT; 
DATA_BUS_OUT <= internal_BUS_OUT;
end Behavioral;

