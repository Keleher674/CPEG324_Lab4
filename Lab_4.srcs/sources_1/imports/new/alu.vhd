----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 01:54:34 PM
-- Design Name: 
-- Module Name: alu - Combinational
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    port (
        A          : in  std_logic_vector(15 downto 0);  
        B          : in  std_logic_vector(15 downto 0);  
        op     : in  std_logic_vector(1 downto 0);   
        cmp_result : out std_logic;-- '1' means skip next instr
        AopB     : out std_logic_vector(15 downto 0)
    );
end alu;

architecture Combinational of alu is
  component adder_16bit is
    port(
      A         : in  std_logic_vector(15 downto 0);
      B         : in  std_logic_vector(15 downto 0);
      sum       : out std_logic_vector(15 downto 0);
      carry_out : out std_logic
    );
  end component;

  signal sum16   : std_logic_vector(15 downto 0);
  signal carry16 : std_logic;
  
begin
  -- 1) ADD path: instantiate adder16 with sub='0'
  ADD_PATH: adder_16bit
    port map(
      A         => A,
      B         => B,
      sum       => sum16,
      carry_out => carry16
    );

  -- 2) Compare path: purely combinational process
  CMP_PROC: process(A, B, op)
    variable a_low_signed : signed(7 downto 0);
    variable b_low_signed : signed(7 downto 0);
  begin
    cmp_result <= '0';
    if op = "11" then
      a_low_signed := signed(A(7 downto 0));
      b_low_signed := signed(B(7 downto 0));
      if a_low_signed > b_low_signed then
        cmp_result <= '0';  -- don't skip
      else
        cmp_result <= '1';  -- skip next instr
      end if;
    end if;
  end process CMP_PROC;

  -- 3) Result mux: choose among Add, Swap, Load, default=0
  MUX_PROC: process(sum16, A, op)
  begin
    case op is
      when "00" =>  -- ADD
        AopB <= sum16;

      when "01" =>  -- SWAP halves of A
        AopB <= A(7 downto 0) & A(15 downto 8);

      when "10" =>  -- LOAD: forward full A (already sign-extended)
        AopB <= A;

      when others =>  -- Compare or illegal ? drive zero (compare only uses cmp_result)
        AopB <= (others => '0');
    end case;
  end process MUX_PROC;

end Combinational;
