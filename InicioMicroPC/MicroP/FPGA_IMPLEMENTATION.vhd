library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU7SEG is
    Port (
        CLOCK     : in  STD_LOGIC;  -- Reloj de 50MHz
        RST       : in  STD_LOGIC;
        CAT       : out STD_LOGIC_VECTOR(6 downto 0);
        AN5, AN4, AN3, AN2, AN1, AN0 : out STD_LOGIC
    );
end CPU7SEG;

architecture MIXTA of CPU7SEG is
  -- Componente CPU2
  component CPU2
    port(
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        READY : IN STD_LOGIC := '1';
        DATA_BUS_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DATA_BUS_IN_EXTERN: in STD_LOGIC_VECTOR(7 DOWNTO 0);
        EXTERN_READ: out STD_LOGIC;
        EXTERN_WRITE: out STD_LOGIC;
        ROM_ADDR_OUT: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
        ALU_OUT_EXT: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        STAT_OUT: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        REG_SEL_OUT_CPU : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
  end component;

  -- Componente RAM
  component RAM_64Kx8
    port(
        clk     : in  std_logic;
        we      : in  std_logic;
        re      : in  std_logic;
        address : in  std_logic_vector(15 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        data_in : in std_logic_vector(7 downto 0)
    );
  end component;

  -- Componente MUX7SEG
  component MUX7SEG
    port(
        CLK, RST : in STD_LOGIC;
        D5, D4, D3, D2, D1, D0 : in STD_LOGIC_VECTOR(3 downto 0);
        CAT : out STD_LOGIC_VECTOR(6 downto 0);
        AN5, AN4, AN3, AN2, AN1, AN0 : out STD_LOGIC
    );
  end component;  

  for all: MUX7SEG use entity WORK.MUX7SEG(MIXTA);
  for all: RAM_64Kx8 use entity WORK.RAM_64kx8(behavioral);
  for all: CPU2 use entity work.CPU2;

  -- Señales
  signal DATA_BUS : STD_LOGIC_VECTOR(7 downto 0);
  signal ADDRESS : STD_LOGIC_VECTOR(15 downto 0);
  signal RAM_OUT : STD_LOGIC_VECTOR(7 downto 0);
  signal EXTERN_READ: STD_LOGIC; 
  signal EXTERN_WRITE : STD_LOGIC;
  signal RST_AUTO : STD_LOGIC := '0';  -- Reset automático (inicialmente activo)
  signal RST_FINAL : STD_LOGIC;        -- Reset combinado (manual + automático)
  signal CLK_SLOW : STD_LOGIC := '0';
  signal CLOCK_PULSE: STD_LOGIC;

  -- Contador para dividir la frecuencia
  signal CLK_DIV : unsigned(25 downto 0) := (others => '0');

  -- Contador de reset automático (5 segundos)
  signal RESET_COUNTER : unsigned(27 downto 0) := (others => '0');

begin

  -- Generación del reset automático
  process (CLOCK)
  begin
    if rising_edge(CLOCK) then
      if RESET_COUNTER < 250_000_000 then  -- 5 segundos a 50MHz
        RESET_COUNTER <= RESET_COUNTER + 1;
        RST_AUTO <= '0';  -- Mantiene reset activo
      else
        RST_AUTO <= '1';  -- Libera reset
      end if;
    end if;
  end process;

 
  -- Invertir la señal de reset
  process(CLOCK) 
  begin
    if rising_edge(CLOCK) then
      RST_FINAL <= not (RST and RST_AUTO);
    end if;
  end process;


  -- Divisor de frecuencia: 50MHz -> 1Hz
  process (CLOCK)
  begin
    if rising_edge(CLOCK) then
      if CLK_DIV = 49_999_999 then  -- 50M ciclos = 1 Hz
        CLK_DIV <= (others => '0');  -- Reiniciar contador
        CLK_SLOW <= not CLK_SLOW;    -- Invertir la señal
      else
        CLK_DIV <= CLK_DIV + 1;
      end if;
    end if;
  end process;

  -- Instancia de la CPU2
  CPU_INST : CPU2
    port map(
        CLK => CLK_SLOW,
        RST => RST_FINAL,
        READY => '1',
        DATA_BUS_OUT => DATA_BUS,
        ADDRESS_BUS => ADDRESS,
        DATA_BUS_IN_EXTERN => RAM_OUT,  -- Recibe datos de la RAM
        EXTERN_READ => EXTERN_READ,
        EXTERN_WRITE => EXTERN_WRITE,
        ROM_ADDR_OUT => open,
        ALU_OUT_EXT => open,
        STAT_OUT => open,
        REG_SEL_OUT_CPU => open
    );

  -- Instancia de la RAM
  RAM_INST : RAM_64Kx8
    port map(
        clk => CLK_SLOW,
        we => EXTERN_WRITE,  -- Escritura controlada por la CPU
        re => EXTERN_READ,   -- Lectura controlada por la CPU
        address => ADDRESS,
        data_out => RAM_OUT,
        data_in => DATA_BUS  -- Se escriben los datos de la CPU
    );

  -- Instancia de MUX7SEG para la visualización
  MUX7SEG_INST : MUX7SEG
    port map(
        CLK => CLOCK,
        RST => RST_FINAL,
        D5 => ADDRESS(15 downto 12),
        D4 => ADDRESS(11 downto 8),
        D3 => ADDRESS(7 downto 4),
        D2 => ADDRESS(3 downto 0),
        D1 => DATA_BUS(7 downto 4),
        D0 => DATA_BUS(3 downto 0),
        CAT => CAT,
        AN5 => AN5, AN4 => AN4, AN3 => AN3, AN2 => AN2, AN1 => AN1, AN0 => AN0
    );

end MIXTA;
