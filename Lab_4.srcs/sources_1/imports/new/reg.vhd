library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
  generic (
    WIDTH : natural := 16
  );
  port(
    I      : in  std_logic_vector(WIDTH-1 downto 0);
    clock  : in  std_logic;
    enable : in  std_logic;
    reset  : in  std_logic;                     
    O      : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture behav of reg is
  signal temp : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
begin

  process(clock, reset)
  begin
    if reset = '1' then
      temp <= (others => '0');
    elsif rising_edge(clock) then
      if enable = '1' then
        temp <= I;
      end if;
    end if;
  end process;

  O <= temp;
end architecture;
