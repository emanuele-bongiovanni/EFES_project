library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SAR_ADC is
    generic (
        RESOLUTION : integer := 8  -- ADC resolution (bits)
    );
    Port (
        clk             : in STD_LOGIC;            
        start           : in STD_LOGIC;          
        comparator      : in STD_LOGIC; 
        digital_out     : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0);  
        done            : out STD_LOGIC            
    );
end SAR_ADC;

architecture Behavioral of SAR_ADC is
    constant CLOCK_PERIOD : time := 10 ns;  -- Clock period (to be adjusted)

    signal counter                  : std_logic_vector(2 downto 0); 
    signal result_reg               : std_logic_vector(RESOLUTION - 1 downto 0);  
    signal decoder_out              : std_logic_vector(RESOLUTION - 1 downto 0);
   -- signal mux_out                  : std_logic_vector(RESOLUTION - 1 downto 0);  
    signal or_out                   : std_logic_vector(RESOLUTION - 1 downto 0);

    component reg1bit is
        Port ( clk      : in  STD_LOGIC;
               reset    : in  STD_LOGIC;
               d        : in  STD_LOGIC;
               q        : out  STD_LOGIC);
    end component;

    component decoder is
        Port ( 
            inp             : in std_logic;
            sel             : in std_logic_vector (2 downto 0);
            outp            : out std_logic_vector (7 downto 0)
        );
    end component;

    component mux is
        Port ( a : in  STD_LOGIC;
               b : in  STD_LOGIC;
               sel : in  STD_LOGIC;
               y : out  STD_LOGIC);
    end component;
    
begin

    --comparator decoder
    comparator_decoder: decoder port map (
        inp => comparator,
        sel => counter,
        outp => decoder_out
    );


    --or loop generate
    or_loop: for i in 0 to RESOLUTION - 1 generate
        or_out(i) <= decoder_out(i) or result_reg(i);
    end generate;

    --result reg loop generate
    result_reg_loop: for i in 0 to RESOLUTION - 1 generate
        reg_i: reg1bit port map (
            clk => clk,
            reset => start,
            d => or_out(i),
            q => result_reg(i)
        );
    end generate;



    process(clk)
    begin
        if rising_edge(clk) then
            if start = '1' then 
                counter <= (others => '1');  
                done <= '0';
            elsif counter = "000" then
                done <= '1';
            else
                counter <= std_logic_vector(unsigned(counter) - 1);
            end if;
        end if;
    end process;

    -- Output digital result
    digital_out <= result_reg;

end Behavioral;
