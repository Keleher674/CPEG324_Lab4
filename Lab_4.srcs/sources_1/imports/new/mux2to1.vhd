library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2to1 is
    generic ( 
        WIDTH : natural := 16
        );
    Port ( A : in  std_logic_vector(WIDTH-1 downto 0);
           B : in  std_logic_vector(WIDTH-1 downto 0);
           sel : in  std_logic;
           Y : out  std_logic_vector(WIDTH-1 downto 0));
end mux2to1;

architecture Behavioral of mux2to1 is
begin
    with sel select
        Y <= B when '1',
             A when others;
end Behavioral;