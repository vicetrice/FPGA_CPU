LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CPU_TB IS
END CPU_TB;

ARCHITECTURE testbench OF CPU_TB IS
    SIGNAL clk       : STD_LOGIC := '0';
    SIGNAL ready     : STD_LOGIC := '1';
    SIGNAL data_bus_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL data_bus_in  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL address_bus  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ram_read  : STD_LOGIC;
    SIGNAL ram_write : STD_LOGIC;
    
    -- Simulación de la RAM como señal
    TYPE RAM_ARRAY IS ARRAY (0 TO 65535) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : RAM_ARRAY := (OTHERS => (OTHERS => '0'));

    COMPONENT CPU
        PORT (
            CLK : IN STD_LOGIC;
            READY : IN STD_LOGIC;
            DATA_BUS_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            DATA_BUS_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            RAM_READ : OUT STD_LOGIC;
            RAM_WRITE : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    -- Instancia de la CPU
    uut: CPU PORT MAP (
        CLK => clk,
        READY => ready,
        DATA_BUS_OUT => data_bus_out,
        DATA_BUS_IN => data_bus_in,
        ADDRESS_BUS => address_bus,
        RAM_READ => ram_read,
        RAM_WRITE => ram_write
    );

    -- Simulación de la RAM
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF ram_write = '1' THEN
                RAM(to_integer(unsigned(address_bus))) <= data_bus_out;
            END IF;
            IF ram_read = '1' THEN
                data_bus_in <= RAM(to_integer(unsigned(address_bus)));
            END IF;
        END IF;
    END PROCESS;

    -- Conexión de la RAM con la CPU
    data_bus_in <= RAM(to_integer(unsigned(address_bus))) WHEN ram_read = '1' ELSE data_bus_out;
    RAM(to_integer(unsigned(address_bus))) <= data_bus_out WHEN ram_write = '1' ELSE RAM(to_integer(unsigned(address_bus)));

    -- Generación del reloj
    PROCESS
    BEGIN
        WAIT FOR 10 ns;
        clk <= NOT clk;
    END PROCESS;
    
    -- Proceso de estímulos
    PROCESS
    BEGIN
        -- Escribir en RAM
        WAIT FOR 20 ns;
        RAM(16#0000#) <= "00001111";
        WAIT FOR 20 ns;
        
        -- Simulación en ejecución
        WAIT FOR 200 ns;
        
        -- Finalizar la simulación
        WAIT;
    END PROCESS;

END testbench;
