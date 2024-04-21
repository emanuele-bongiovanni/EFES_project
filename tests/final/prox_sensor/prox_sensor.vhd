library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;



entity prox_sensor is
    port (
        clk                     : in std_logic;
        reset                   : in std_logic;
        echo                    : in std_logic;
        new_measure             : in std_logic;
        start_count_zero        : in std_logic; 
        measure_value           : in std_logic_vector(20 downto 0);


        init_start              : out std_logic;        -- reset dello start counter
        start_en                : out std_logic;        -- enable di start counter
        init_measure            : out std_logic;        --reset del counter measure
        measure_en              : out std_logic;        --enable del counter measure
        trigger                 : out std_logic;

        terminated              : out std_logic;
        distance                : out std_logic_vector(31 downto 0)
    );
end entity;

architecture beh of prox_sensor is

    type sens_state is (RES, IDLE, STARTING, WAITING_ECHO, MEASURING, FIN_1, FIN_2 );
    signal curr_state, next_state   : sens_state;
    signal dist_value               : std_logic_vector(41 downto 0);


    begin

        update_state: process (clk, reset)
        begin
            if(reset = '1') then
                curr_state <= RES;
            elsif(rising_edge(clk)) then
                curr_state <= next_state;
            end if;
            
        end process;


        sense_fsm: process(curr_state,echo, new_measure, start_count_zero, measure_value)
        begin
            case( curr_state ) is

                when RES => 
                    distance <= (others => '0') ;
                    next_state <= IDLE;
            
                when IDLE =>

                    init_start <= '1';
                    start_en <= '0';
                    init_measure <= '0';
                    measure_en <= '0';
                    trigger <= '0';

                    if new_measure = '1' then
                        next_state <= STARTING;
                    else
                        next_state <= IDLE;
                    end if ;


                when STARTING => 

                    terminated <= '0';
                    init_start <= '0';
                    start_en <= '1';
                    init_measure <= '0';
                    measure_en <= '0';
                    trigger <= '1';

                    --next_state <= WAITING_ECHO;
                    if start_count_zero = '1' then
                        next_state <= WAITING_ECHO;
                    else
                        next_state <= STARTING;
                    end if ;


                when WAITING_ECHO => 

                    terminated <= '0';
                    init_start <= '0';
                    start_en <= '0';
                    init_measure <= '1';
                    measure_en <= '0';
                    trigger <= '0';

                    if echo = '1' then
                        next_state <= MEASURING;
                    else
                        next_state <= WAITING_ECHO;
                    end if ;

                
                when MEASURING => 

                    terminated <= '0';
                    init_start <= '0';
                    start_en <= '0';
                    init_measure <= '0';
                    measure_en <= '1';
                    trigger <= '0';

                    if echo = '0' or measure_value = "111111111111111111110" then
                        next_state <= FIN_1;
                    else
                        next_state <= MEASURING;
                    end if ;


                when FIN_1 =>

                    terminated <= '0';
                    init_start <= '0';
                    start_en <= '0';
                    init_measure <= '0';
                    measure_en <= '0';
                    trigger <= '0'; 
                    --(5 / 1000 * 343 / 2) = 343/400 circa = 439/512 (2^9)

                    --dist_value <= std_logic_vector(unsigned(measure_value) * 439); 
                    --prova
                    dist_value <= std_logic_vector(unsigned(measure_value) * 449); --divisione extra
                    
                    next_state <= FIN_2;
                
                when FIN_2 =>

                    terminated <= '1';
                    init_start <= '0';
                    start_en <= '0';
                    init_measure <= '0';
                    measure_en <= '0';
                    trigger <= '0'; 
                    --(5 / 1000000 * 343 / 2) = 343/400000 circa = 450/2^19

                    --distance <= dist_value(41 downto 10);        -- da 0 a 8 non li prendiamo per la divisione, prendiamo tutti i più alti 
                    --approx 3
                    distance <= '0' & dist_value(41 downto 11);
                    
                    next_state <= IDLE;
            
                when others =>
                    next_state <= IDLE;
            
            end case ;

        end process;





end beh;