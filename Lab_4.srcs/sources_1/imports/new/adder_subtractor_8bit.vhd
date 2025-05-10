----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2025 05:51:13 PM
-- Design Name: 
-- Module Name: adder_subtractor_8bit - Structural
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

entity adder_subtractor_8bit is
  port(
    A         : in  std_logic_vector(7 downto 0);
    B         : in  std_logic_vector(7 downto 0);
    sub       : in  std_logic;                       -- '0' = add, '1' = subtract
    sum       : out std_logic_vector(7 downto 0);
    carry_out : out std_logic
  );
end adder_subtractor_8bit;

architecture Structural of adder_subtractor_8bit is
  -- Invert B bits when doing subtraction
  signal B_mod : std_logic_vector(7 downto 0);
  -- 9 carry bits for 8-bit ripple
  signal carry : std_logic_vector(8 downto 0);
  
  component full_adder is
    port(
      a    : in  std_logic;
      b    : in  std_logic;
      cin  : in  std_logic;
      sum  : out std_logic;
      cout : out std_logic
    );
  end component;
begin
  -- prepare B_mod
  B_mod <= B xor (B'range => sub);
  -- initial carry = sub (0 for add, 1 for subtract)
  carry(0) <= sub;

  -- instantiate eight 1-bit full adders
  gen_bits : for i in 0 to 7 generate
    FA : full_adder
      port map(
        a    => A(i),
        b    => B_mod(i),
        cin  => carry(i),
        sum  => sum(i),
        cout => carry(i+1)
      );
  end generate gen_bits;

  -- final carry out
  carry_out <= carry(8);
end Structural;