----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 01:07:41 PM
-- Design Name: 
-- Module Name: Lab3_Decoder - Behavioral
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

entity Lab3_Decoder is
    Port (
        reset         : in std_logic;
        instruction   : in  std_logic_vector(7 downto 0);
        rs            : out std_logic_vector(1 downto 0);
        rt            : out std_logic_vector(1 downto 0);
        rd            : out std_logic_vector(1 downto 0);
        imm           : out std_logic_vector(3 downto 0);
        alu_op        : out std_logic_vector(1 downto 0);
        WE            : out std_logic;
        reg_mux   : out std_logic;
        dis_en        : out std_logic
    );
end Lab3_Decoder;

architecture Behavioral of Lab3_Decoder is
begin
  decode_process: process(instruction, reset)
  begin
    -- if reset asserted, force everything to "off"
    if reset = '1' then
      rs      <= (others => '0');
      rt      <= (others => '0');
      rd      <= (others => '0');
      imm     <= (others => '0');
      alu_op  <= (others => '0');
      WE      <= '0';
      reg_mux <= '0';
      dis_en  <= '0';

    else
      -- default all outputs to zero
      rs      <= (others => '0');
      rt      <= (others => '0');
      rd      <= (others => '0');
      imm     <= (others => '0');
      alu_op  <= (others => '0');
      WE      <= '0';
      reg_mux <= '0';
      dis_en  <= '0';

      -- decode
      if instruction(7 downto 6) = "00" then
        -- Load
        rd      <= instruction(5 downto 4);
        imm     <= instruction(3 downto 0);
        alu_op  <= "10";
        WE      <= '1';
        reg_mux <= '1';

      elsif instruction(7 downto 6) = "01" then
        -- Add
        rd      <= instruction(5 downto 4);
        rs      <= instruction(3 downto 2);
        rt      <= instruction(1 downto 0);
        alu_op  <= "00";
        WE      <= '1';

      elsif instruction(7 downto 4) = "1100" then
        -- Swap
        rs      <= instruction(3 downto 2);
        rd      <= instruction(3 downto 2);
        alu_op  <= "01";
        WE      <= '1';

      elsif instruction(7 downto 4) = "1101" then
        -- Display
        rs     <= instruction(3 downto 2);
        dis_en <= '1';

      elsif instruction(7 downto 4) = "1110" then
        -- Compare
        rs     <= instruction(3 downto 2);
        rt     <= instruction(1 downto 0);
        alu_op <= "11";

      end if;
    end if;
  end process;
end Behavioral;
