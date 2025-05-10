----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2025 12:42:35 PM
-- Design Name: 
-- Module Name: debouncer - Behavioral
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

entity debouncer is
  port(
    clk        : in  std_logic;    -- your board's system clock
    raw_clk   : in  std_logic;    -- raw "step" button input
    raw_reset  : in  std_logic;    -- raw "reset" button input
    clk_pulse : out std_logic;    -- one-cycle pulse per press
    reset_pulse: out std_logic     -- one-cycle pulse per press
  );
end debouncer;

architecture Behavioral of debouncer is
  -- first, two-stage synchronizers
  signal s0_step, s1_step : std_logic := '0';
  signal s0_rst,  s1_rst  : std_logic := '0';

  -- 3-bit shift registers for debouncing
  signal sr_step : std_logic_vector(2 downto 0) := (others => '0');
  signal sr_rst  : std_logic_vector(2 downto 0) := (others => '0');

  -- debounced levels
  signal db_step : std_logic := '0';
  signal db_rst  : std_logic := '0';

  -- previous debounced levels for edge detection
  signal prev_step, prev_rst : std_logic := '0';
begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- 1) Synchronize
      s0_step <= raw_clk;
      s1_step <= s0_step;
      s0_rst  <= raw_reset;
      s1_rst  <= s0_rst;

      -- 2) Shift-in for simple debounce
      sr_step <= sr_step(1 downto 0) & s1_step;
      sr_rst  <= sr_rst(1 downto 0)  & s1_rst;

      -- 3) Update debounced levels when stable
      if sr_step = "111" then
        db_step <= '1';
      elsif sr_step = "000" then
        db_step <= '0';
      end if;

      if sr_rst = "111" then
        db_rst <= '1';
      elsif sr_rst = "000" then
        db_rst <= '0';
      end if;

      -- 4) Generate one-cycle pulses on rising edge
      if (db_step = '1' and prev_step = '0') then
        clk_pulse <= '1';
      else
        clk_pulse <= '0';
      end if;

      if (db_rst = '1' and prev_rst = '0') then
        reset_pulse <= '1';
      else
        reset_pulse <= '0';
      end if;

      -- 5) Remember last state
      prev_step <= db_step;
      prev_rst  <= db_rst;
    end if;
  end process;

end architecture;