library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;   -- for signed and resize

entity sign_extender is
    Port (
        imm     : in  std_logic_vector(3 downto 0);
        ext_imm : out std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of sign_extender is
    signal imm_s : signed(3 downto 0);
    signal ext_s : signed(15 downto 0);
begin

    -- reinterpret the 4-bit vector as a signed value
    imm_s <= signed(imm);

    -- resize does the sign-extension for you
    ext_s <= resize(imm_s, 16);

    -- cast back to std_logic_vector
    ext_imm <= std_logic_vector(ext_s);

end architecture Behavioral;