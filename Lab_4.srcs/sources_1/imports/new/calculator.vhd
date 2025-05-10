library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity calculator is
    Port ( 
        sw : in std_logic_vector(7 downto 0);
        clk : in STD_LOGIC;
        clk_button : in std_logic;
        reset : in STD_LOGIC;
        seg : out std_logic_vector(6 downto 0);
        cat : out STD_LOGIC);
        
end calculator;
architecture Structural of calculator is

    -- Register Width+
    constant WIDTH : integer := 16;
    
    component debouncer is
      port(
        clk        : in  std_logic;    
        raw_clk   : in  std_logic;    
        raw_reset  : in  std_logic;  
        clk_pulse : out std_logic;   
        reset_pulse: out std_logic    
      );
    end component;
    
    signal debounced_clk : std_logic;
    signal debounced_reset : std_logic;
    
    component instr_register is
      port(
        btn : in  std_logic;                     
        sw_bus   : in  std_logic_vector(7 downto 0);  
        instr    : out std_logic_vector(7 downto 0)   
      );
    end component;
    
    signal instr : std_logic_vector(7 downto 0);

    --Instruction Decoder
    -- Coded
    component Lab3_Decoder is
        Port ( instruction : in std_logic_vector(7 downto 0);
               reset : in std_logic;
               rs : out std_logic_vector(1 downto 0);
               rt : out std_logic_vector(1 downto 0);
               rd : out std_logic_vector(1 downto 0);
               imm : out std_logic_vector(3 downto 0);
               alu_op : out std_logic_vector(1 downto 0);
               WE : out std_logic;
               reg_mux : out std_logic;
               dis_en : out std_logic);
    end component;

    signal rs : std_logic_vector(1 downto 0);
    signal rt : std_logic_vector(1 downto 0);
    signal rd : std_logic_vector(1 downto 0);
    signal imm : std_logic_vector(3 downto 0);
    signal alu_op : std_logic_vector(1 downto 0);
    signal WE : std_logic;
    signal imm_mux_sel : std_logic;
    signal dis_en : std_logic;

    -- Register File
    -- Coded, potential problem with clock cycle and writing?
    component reg_file is
        port ( clk : in std_logic;
               reset : std_logic;
               WE : in  std_logic;
               rs1 : in  std_logic_vector(1 downto 0);
               rs2 : in  std_logic_vector(1 downto 0);
               WS : in  std_logic_vector(1 downto 0);
               wd : in  std_logic_vector(15 downto 0);
               rd1 : out std_logic_vector(15 downto 0);
               rd2 : out std_logic_vector(15 downto 0));
    end component;

    signal r1 : std_logic_vector(15 downto 0);
    signal r2 : std_logic_vector(15 downto 0);

    -- ALU
    -- CJ Coded this
    component alu is
        Port ( A : in  std_logic_vector(15 downto 0);
               B : in  std_logic_vector(15 downto 0);
               op : in  std_logic_vector(1 downto 0);
               cmp_result : out std_logic;
               AopB : out std_logic_vector(15 downto 0));
    end component;

    signal skip_next : std_logic;
    signal write_value : std_logic_vector(15 downto 0);

    -- Sign Extender
    -- Coded
    component sign_extender is
        Port ( imm : in  std_logic_vector(3 downto 0);
               ext_imm : out std_logic_vector(15 downto 0));
    end component;

    signal ext_imm : std_logic_vector(15 downto 0);

    -- Immediate Mux
    -- Coded
    component mux2to1 is
        Port ( 
               A : in  std_logic_vector(15 downto 0);
               B : in  std_logic_vector(15 downto 0);
               sel : in  std_logic;
               Y : out std_logic_vector(15 downto 0));
    end component;

    signal y : std_logic_vector(15 downto 0);

    -- Display Decoder
    -- Not sure what to do about this
    component display_decoder is
        Port (  reset : in std_logic;
                dis_val : in  std_logic_vector(15 downto 0);
                dis_en : in  std_logic;
                digit_lo : out std_logic_vector(3 downto 0); 
                digit_hi : out std_logic_vector(3 downto 0));  
    end component; 
    
    signal digit_lo : std_logic_vector(3 downto 0);
    signal digit_hi : std_logic_vector(3 downto 0);
    
    component KeleherChristian_60hz is
        Port ( clk_in : in STD_LOGIC;
               reset : in STD_LOGIC;
               clk_out : out STD_LOGIC);
    end component;
    
    signal clkdiv_60hz : std_logic;
    
    component KeleherChristian_ssd is
        Port ( sw : in std_logic_vector(3 downto 0);
               seg : out std_logic_vector(6 downto 0) 
               );
    end component;

    component KeleherChristian_ssd_mux is
        Port ( I1 : in STD_LOGIC_VECTOR (3 downto 0);
               I0 : in STD_LOGIC_VECTOR (3 downto 0);
               sel : in STD_LOGIC;
               Y : out std_logic_vector (3 downto 0));
    end component;

    signal ssd_mux_out : std_logic_vector(3 downto 0);
    
    signal blank_req : std_logic := '1';

begin
    
    debounce : debouncer
        port map (
            clk => clk,
            raw_clk => clk_button,
            raw_reset => reset,
            clk_pulse => debounced_clk,
            reset_pulse => debounced_reset
            );
           
    blank_latch : process(debounced_clk, debounced_reset)
    begin
      if debounced_reset = '1' then
        blank_req <= '1';               -- go blank at reset
      elsif rising_edge(debounced_clk) then
        if dis_en = '1' then
          blank_req <= '0';             -- clear blank when you actually DISPLAY
        end if;
      end if;
    end process blank_latch;
            
    instruction: instr_register
        port map (
            btn => debounced_clk,
            sw_bus => sw,
            instr => instr
            );
    
    instr_dec : Lab3_Decoder
        port map ( 
            instruction => instr,
            reset => debounced_reset,
            rs => rs,
            rt => rt,
            rd => rd,
            imm => imm,
            alu_op => alu_op,
            WE => WE,
            reg_mux => imm_mux_sel,
            dis_en => dis_en);
    
    reg : reg_file
        port map ( 
            clk => debounced_clk,
            reset => debounced_reset,
            WE => WE,
            rs1 => rs,
            rs2 => rt,
            WS => rd,
            wd => write_value,
            rd1 => r1,
            rd2 => r2);

    sign_ext : sign_extender
        port map ( 
            imm => imm,
            ext_imm => ext_imm);

    imm_mux : mux2to1
        port map ( 
            A => r1,
            B => ext_imm,
            sel => imm_mux_sel,
            Y => y);

    alu_inst : alu
        port map ( 
            A => y,
            B => r2,
            op => alu_op,
            cmp_result => skip_next,
            AopB => write_value);

    display : display_decoder
        port map ( 
            reset => blank_req,
            dis_val => r1,
            dis_en => dis_en,
            digit_lo => digit_lo,
            digit_hi => digit_hi);
            
    clkdiv : KeleherChristian_60hz
        port map (
            clk_in => clk,
            reset => reset,
            clk_out => clkdiv_60hz
        );
            
    ssd_mux : KeleherChristian_ssd_mux
        port map (
            I0 => digit_lo,
            I1 => digit_hi,
            sel => clkdiv_60hz,
            Y => ssd_mux_out
        );
        
    ssd : KeleherChristian_ssd
        port map (
            sw => ssd_mux_out,
            seg => seg
        );
       
    cat <= clkdiv_60hz;   

end Structural;
