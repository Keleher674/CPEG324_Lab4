----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2025 12:30:33 PM
-- Design Name: 
-- Module Name: instr_register - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instr_register is
  port(
    btn : in  std_logic;                     -- debounced push-button
    sw_bus   : in  std_logic_vector(7 downto 0);  -- the 8 switches
    instr    : out std_logic_vector(7 downto 0)   -- latched instruction
  );
end entity;

architecture Behavioral of instr_register is
  signal ir : std_logic_vector(7 downto 0);
begin

  process(btn)
  begin
    if rising_edge(btn) then
      ir <= sw_bus;
    end if;
  end process;

  instr <= ir;

end architecture;
