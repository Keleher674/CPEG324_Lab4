library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg_file is
    port ( clk : in std_logic;
           reset : in std_logic;
           WE : in  std_logic;
           rs1 : in  std_logic_vector(1 downto 0);
           rs2 : in  std_logic_vector(1 downto 0);
           WS : in  std_logic_vector(1 downto 0);
           wd : in  std_logic_vector(15 downto 0);
           rd1 : out std_logic_vector(15 downto 0);
           rd2 : out std_logic_vector(15 downto 0));
end reg_file;

architecture Behavioral of reg_file is

component reg
    generic (
        WIDTH : natural := 16  -- Default width is 16 bits, can be overridden at instantiation.
    );
    port(	
        I:	in std_logic_vector (WIDTH-1 downto 0); -- for loading
        clock:		in std_logic; -- rising-edge triggering 
        enable:		in std_logic; -- 0: don't do anything; 1: reg is enabled
        reset: in std_logic;
        O:	out std_logic_vector(WIDTH-1 downto 0) -- output the current register content. 
    );
    end component;

-- Declare the registers
type reg_array is array (0 to 3) of std_logic_vector(15 downto 0);
signal reg_outputs : reg_array;
signal reg_enable : std_logic_vector(3 downto 0);

begin

reg_enable(0) <= WE and (WS(0) XNOR '0') and (WS(1) XNOR '0');
reg_enable(1) <= WE and (WS(0) XNOR '1') and (WS(1) XNOR '0');
reg_enable(2) <= WE and (WS(0) XNOR '0') and (WS(1) XNOR '1');
reg_enable(3) <= WE and (WS(0) XNOR '1') and (WS(1) XNOR '1');

    gen_regs: for i in 0 to 3 generate
        reg_inst: reg
        port map (
            I => wd,
            clock => clk,
            enable => reg_enable(i),
            reset => reset,
            O => reg_outputs(i)
        );
    end generate;

    -- Assign rd1 and rd2 outputs based on rs1 and rs2 inputs
    rd1 <= reg_outputs(to_integer(unsigned(rs1)));
    rd2 <= reg_outputs(to_integer(unsigned(rs2)));

end Behavioral;