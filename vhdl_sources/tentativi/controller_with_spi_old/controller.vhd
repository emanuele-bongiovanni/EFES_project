library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypackage.all;

entity controller is
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        sensor_in       : in std_logic_vector(RESOLUTION - 1 downto 0);
        sensor_done     : in std_logic;
        sense_start     : out std_logic;
        motor_1         : out std_logic;
        motor_2         : out std_logic        
    );  
end controller;

architecture rtl of controller is

    type state_type is (reset, idle, run, sense, turn, turn_s1, turn_s2);
    signal state, next_state    : state_type;
    signal turning              : std_logic;
    signal random               : std_logic_vector(3 downto 0);
    signal counter              : std_logic_vector(3 downto 0); -- la dimensione del contatore va modificata
    signal count_value          : integer;
    signal count_start          : std_logic;
    signal count_end            : std_logic;
    signal count_res            : std_logic;




begin

    comb:   process(clk, rst)
        begin
            if rst = '1' then
                state <= reset;
            elsif rising_edge(clk) then
                random <= std_logic_vector(unsigned(random) + 1);
                state <= next_state;
            end if;
    end process comb;

--   per ora motor 1 e 2 sono 0 per motore fermo, 1 per avanti, -1 per indietro
    control:    process(state, sensor_done)
        begin
        
            next_state <= idle;
            count_res <= '0';

            case state is
                when reset =>
                    motor_1 <= '0';
                    motor_2 <= '0';
                    next_state <= idle;
                    
                when idle =>
                    motor_1 <= '0';
                    motor_2 <= '0';
                    next_state <= run;

                when run =>
                    motor_1 <= '1';
                    motor_2 <= '1';
                    count_start <= '1';
                    count_value <= SENSING_CNT;
                    if count_end = '1' then     --TODO: differenziare i timer
                        count_res <= '1';
                        count_start <= '0';
                        sense_start <= '1';
                        next_state <= sense;
                    else
                        next_state <= run;
                    end if;

                when sense =>
                    sense_start <= '0';     --il sensing inizia nel run
                    if sensor_done = '1' then
                        if sensor_in > THRESHOLD_VALUE then  --TODO: definire valore di soglia
                            next_state <= turn;
                        else
                            next_state <= run;
                        end if;
                    end if ;

                when turn =>    --fermo per tot
                    motor_1 <= '0';
                    motor_2 <= '0';
                    count_start <= '1';
                    count_value <= TURNING_CNT;
                    if count_end = '1' then
                        count_res <= '1';
                        count_start <= '0';
                        next_state <= turn_s1;
                    else
                        next_state <= turn;
                    end if;

                when turn_s1 =>     --indietro per tot
                    motor_1 <= '-1';
                    motor_2 <= '-1';
                    count_start <= '1';
                    count_value <= TURNING_CNT;
                    if count_end = '1' then
                        count_res <= '1';
                        count_start <= '0';
                        next_state <= turn_s2;
                    else
                        next_state <= turn_s1;
                    end if;

                when turn_s2 =>     --destra o sinistra
                        if(random[0] = '1') then
                            motor_1 <= '1';
                            motor_2 <= '-1';
                        else
                            motor_1 <= '-1';
                            motor_2 <= '1';
                        end if;
                        count_start <= '1';
                        count_value <= TURNING_CNT;
                        if count_end = '1' then
                            count_res <= '1';
                            count_start <= '0';
                            next_state <= run;
                        else
                            next_state <= turn_s2;
                        end if;

                when others =>
                    motor_1 <= '0';
                    motor_2 <= '0';
                    next_state <= idle;

                    
            end case;
    end process control;


    count:    process(clk, rst, count_res, count_start)
        begin
            if (rst = '1' or count_res = '1') then
                counter <= (others => '0');
                count_end <= '0';
            elsif rising_edge(clk) then
                if count_start = '1' then
                    counter <= std_logic_vector(unsigned(counter) + 1);
                end if;
                if to_integer(unsigned(counter)) = count_value then
                    count_end <= '1';
                end if;
            end if;
    end process count;









end architecture rtl;