----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2025 05:53:26 PM
-- Design Name: 
-- Module Name: adder_16bit - Structural
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

entity adder_16bit is
  port(
    A         : in  std_logic_vector(15 downto 0);
    B         : in  std_logic_vector(15 downto 0);
    sum       : out std_logic_vector(15 downto 0);
    carry_out : out std_logic
  );
end adder_16bit;

architecture Structural of adder_16bit is
  component adder_subtractor_8bit is
    port(
      A         : in  std_logic_vector(7 downto 0);
      B         : in  std_logic_vector(7 downto 0);
      sub       : in  std_logic;
      sum       : out std_logic_vector(7 downto 0);
      carry_out : out std_logic
    );
  end component;

  signal c_low  : std_logic;
begin
  -- low 8 bits addition (sub='0')
  LOW: adder_subtractor_8bit
    port map(
      A         => A(7 downto 0),
      B         => B(7 downto 0),
      sub       => '0',
      sum       => sum(7 downto 0),
      carry_out => c_low
    );

  -- high 8 bits addition (carry_in tied to 0 for pure addition)
  HIGH: adder_subtractor_8bit
    port map(
      A         => A(15 downto 8),
      B         => B(15 downto 8),
      sub       => '0',
      sum       => sum(15 downto 8),
      carry_out => carry_out
    );
end Structural;
