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
        to_dac          : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
        digital_out     : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
        done            : out STD_LOGIC            
    );
end SAR_ADC;


architecture Behavioral of SAR_ADC is

    type sar_state is (idle, evaluate, update, finish);
    signal curr_state, next_state : sar_state;

    signal counter                  : std_logic_vector(2 downto 0);
    signal mask                     : std_logic_vector(RESOLUTION - 1 downto 0); 
    signal result_reg               : std_logic_vector(RESOLUTION - 1 downto 0);  
--    signal decoder_out              : std_logic_vector(RESOLUTION - 1 downto 0);
--    signal or_out                   : std_logic_vector(RESOLUTION - 1 downto 0);



    begin

        comb: process(clk)
        begin
            if rising_edge(clk) then
                    curr_state <= next_state;
            end if;
        end process comb;

        seq: process(curr_state, comparator, start)
        begin
            case curr_state is
                when idle =>
                    if start = '1' then
                        next_state <= evaluate;
                        counter <= (others => '0');
                        result_reg <= (others => '0');
                        mask <= "10000000";
                    else
                        next_state <= idle;
                    end if;
                when evaluate =>
                    if counter = "111" then
                        next_state <= finish;
                    else
                        to_dac <= mask or result_reg;
                        next_state <= update;
                    end if;
                when update =>
                    counter <= std_logic_vector(unsigned(counter) + 1);
                    result_reg <= result_reg or( mask and comparator);
                    mask <= '0' & mask(RESOLUTION - 1 downto 1);
                    next_state <= evaluate;
                when finish =>
                    done <= '1';
                    digital_out <= result_reg;
                    next_state <= idle;
                when others =>
                    next_state <= idle;
            end case;
        end process seq;


end Behavioral;











-- architecture Structural of SAR_ADC is
--     constant CLOCK_PERIOD : time := 10 ns;  -- Clock period (to be adjusted)

--     signal counter                  : std_logic_vector(2 downto 0); 
--     signal result_reg               : std_logic_vector(RESOLUTION - 1 downto 0);  
--     signal decoder_out              : std_logic_vector(RESOLUTION - 1 downto 0);
--    -- signal mux_out                  : std_logic_vector(RESOLUTION - 1 downto 0);  
--     signal or_out                   : std_logic_vector(RESOLUTION - 1 downto 0);

--     component reg1bit is
--         Port ( clk      : in  STD_LOGIC;
--                reset    : in  STD_LOGIC;
--                d        : in  STD_LOGIC;
--                q        : out  STD_LOGIC);
--     end component;

--     component decoder is
--         Port ( 
--             inp             : in std_logic;
--             sel             : in std_logic_vector (2 downto 0);
--             outp            : out std_logic_vector (7 downto 0)
--         );
--     end component;

--     component mux is
--         Port ( a : in  STD_LOGIC;
--                b : in  STD_LOGIC;
--                sel : in  STD_LOGIC;
--                y : out  STD_LOGIC);
--     end component;
    
-- begin

--     --comparator decoder
--     comparator_decoder: decoder port map (
--         inp => comparator,
--         sel => counter,
--         outp => decoder_out
--     );


--     --or loop generate
--     or_loop: for i in 0 to RESOLUTION - 1 generate
--         or_out(i) <= decoder_out(i) or result_reg(i);
--     end generate;

--     --result reg loop generate
--     result_reg_loop: for i in 0 to RESOLUTION - 1 generate
--         reg_i: reg1bit port map (
--             clk => clk,
--             reset => start,
--             d => or_out(i),
--             q => result_reg(i)
--         );
--     end generate;



--     process(clk)
--     begin
--         if rising_edge(clk) then
--             if start = '1' then 
--                 counter <= (others => '1');  
--                 done <= '0';
--             elsif counter = "000" then
--                 done <= '1';
--             else
--                 counter <= std_logic_vector(unsigned(counter) - 1);
--             end if;
--         end if;
--     end process;

--     -- Output digital result
--     digital_out <= result_reg;

-- end Structural;
