library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity display_decoder is
  port(
    reset    : in  std_logic;                     -- active-high reset
    dis_val  : in  std_logic_vector(15 downto 0); -- result to display
    dis_en   : in  std_logic;                     -- display-enable
    digit_lo : out std_logic_vector(3 downto 0);  -- ones digit
    digit_hi : out std_logic_vector(3 downto 0)   -- tens digit or sign/blank
  );
end entity;

architecture Behavioral of display_decoder is
  signal val_s : signed(7 downto 0);
begin

  -- Interpret low 8 bits of dis_val as two's-complement signed
  val_s <= signed(dis_val(7 downto 0));

  process(reset, dis_en, val_s)
    variable v   : integer;
    variable av  : integer;
    variable t   : unsigned(3 downto 0);
    variable o   : unsigned(3 downto 0);
  begin
    if reset = '1' or dis_en = '0' then
      -- blank both digits
      digit_hi <= "1111";
      digit_lo <= "1111";

    else
      v  := to_integer(val_s);
      av := abs(v);

      if av < 10 then
        -- single-digit case
        if v < 0 then
          t := to_unsigned(10, 4);    -- "1010" = negative sign
        else
          t := to_unsigned(15, 4);    -- "1111" = blank
        end if;
        o := to_unsigned(av, 4);     -- ones digit

      else
        -- two-digit case, drop sign
        t := to_unsigned((av / 10) mod 10, 4);
        o := to_unsigned(av mod 10, 4);
      end if;

      digit_hi <= std_logic_vector(t);
      digit_lo <= std_logic_vector(o);
    end if;
  end process;
end architecture;