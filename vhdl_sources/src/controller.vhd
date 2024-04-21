library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypackage.all;

entity controller is
    port(
        clk                         : in std_logic;
        rst                         : in std_logic;

        end_dist_meas_int           : in std_logic;                                 --new distance available
        measured_distance_int       : in std_logic_vector(31 downto 0);             --measured distance (used also externally)
        measured_light_int          : in std_logic_vector(NBIT - 1 downto 0);       --measured light
        end_light_meas_int          : in std_logic;                                 --new light measure available
        data_from_master_int        : in std_logic_vector(NBIT-1 downto 0);         --data arriving from master
        data_readable_int           : in std_logic;                                 --spi data readable
        dist_counter_zero_int       : in std_logic;                                 --end counter for distance
        light_counter_zero_int      : in std_logic;                                 --end counter for light
        motor_counter_zero_int      : in std_logic;                                 --end counter for motor turn


        motor_r                     : out std_logic_vector(1 downto 0);             -- right motor control
        motor_l                     : out std_logic_vector(1 downto 0);             -- left motor control 
        start_distance_int          : out std_logic;                                --start new distance measure
        start_light_int             : out std_logic;                                --start new light measure
        speed_dc_int                : out std_logic_vector(2 downto 0);             --duty cycle for speed setting
        data_to_send_int            : out std_logic_vector(NBIT-1 downto 0);        --data to be sent to master
        dist_counter_en_int         : out std_logic;                                --start counter for distance
        dist_counter_reset_int      : out std_logic;                                --reset counter for distance
        light_counter_en_int        : out std_logic;                                --start counter for light
        light_counter_reset_int     : out std_logic;                                --reset counter for light
        motor_counter_en_int        : out std_logic;                                --start counter for motor turn
        motor_counter_reset_int     : out std_logic                                --reset counter for motor turn  
    );  
end controller;


architecture rtl of controller is

    type DISTANCE_state is (D_RESET, D_IDLE, D_START, D_MEASURING);
    signal curr_state_DIST, next_state_DIST : DISTANCE_state;

    type LIGHT_state is (L_RESET, L_IDLE, L_START, L_MEASURING);
    signal curr_state_LIGHT, next_state_LIGHT : LIGHT_state;

    type MOTOR_state is (M_RESET, M_RUN, M_BACK, M_BACK_R, M_TURN);
    signal curr_state_MOTOR, next_state_MOTOR : MOTOR_state;

    signal current_distance         : std_logic_vector(31 downto 0);
    signal current_light            : std_logic_vector(NBIT - 1 downto 0);
    signal random_direction         : std_logic;
    signal random_generator         : std_logic;

    begin


            --MOTOR CONTROLLER FSM
        MOTOR_state_update: process (clk, reset)
        begin
            if (reset = '1') then
                curr_state_MOTOR <= M_RESET;
                random_generator <= '0';
            elsif (rising_edge(clk)) then
                curr_state_MOTOR <= next_state_MOTOR;
                random_generator <= not random_generator;
            end if ;
        end process;


        MOTOR_CONTROL_fsm: process (curr_state_MOTOR, current_distance, current_light, motor_counter_zero_int)
        begin
            case( curr_state_MOTOR ) is

                --come funziona speed_dc: 000 = velocità massima; 111 = velocità minima
                --come funzionano i motori:
                -- 00 = fermo
                -- 01 = avanti
                -- 10 = indietro
            
                when M_RESET =>
                    motor_r                     <= "00";
                    motor_l                     <= "00";
                    speed_dc_int                <= "000";
                    motor_counter_en_int        <= '0';
                    motor_counter_reset_int     <= '1';

                    next_state_MOTOR            <= M_RUN;

                when M_RUN => 
                    motor_r                     <= "01";        --avanti
                    motor_l                     <= "01";
                    motor_counter_en_int        <= '0';
                    motor_counter_reset_int     <= '1';

                    if to_integer(unsigned(current_distance)) < 20 then     --should be cm
                        next_state_MOTOR <= M_BACK;
                    elsif to_integer(unsigned(current_distance)) < 50 then
                        speed_dc_int <= "001";
                        next_state_MOTOR <= M_RUN;
                    else
                        speed_dc_int <= "000";
                        next_state_MOTOR <= M_RUN;                        
                    end if ;

                when M_BACK => 
                    motor_r                     <= "10";        --indietro
                    motor_l                     <= "10";
                    speed_dc_int                <= "001";
                    motor_counter_en_int        <= '1';
                    motor_counter_reset_int     <= '0';
                    

                    if motor_counter_zero_int = '1' then
                        random_direction <= random_generator;
                        next_state_MOTOR <= M_BACK_R;
                    else
                        next_state_MOTOR <= M_BACK;
                    end if ;
                
                when M_BACK_R => 
                    motor_r                     <= "00";        --stop
                    motor_l                     <= "00";
                    speed_dc_int                <= "001";
                    motor_counter_en_int        <= '0';
                    motor_counter_reset_int     <= '1';

                    next_state_MOTOR            <= M_TURN;

                when M_TURN => 
                    if random_direction = '1' then
                        motor_r                     <= "10";        
                        motor_l                     <= "01";
                    else
                        motor_r                     <= "01";        
                        motor_l                     <= "10";                        
                    end if ;

                    speed_dc_int                <= "001";
                    motor_counter_en_int        <= '1';
                    motor_counter_reset_int     <= '0';

                    if motor_counter_zero_int = '1' then
                        next_state_MOTOR <= M_RUN;
                    else
                        next_state_MOTOR <= M_TURN;
                    end if ;

                when others =>
                    next_state_MOTOR <= M_RESET;
            
            end case ;
            
        end process;




            --PROXIMITY SENSOR FSM

        DISTANCE_state_update: process (clk, reset)
        begin
            if (reset = '1') then
                curr_state_DIST = D_RESET;
            elsif (rising_edge(clk)) then
                curr_state_DIST <= next_state_DIST;
            end if ;
        end process;

        DISTANCE_fsm: process(curr_state_DIST, dist_counter_zero, end_dist_meas_int)
        begin
            case( curr_state_DIST ) is
                
                when D_RESET => 
                    start_distance_int      <= '0';
                    dist_counter_en_int     <= '0';
                    dist_counter_reset_int  <= '1';
                    current_distance        <= (others => '0'); 

                    curr_state_DIST         <= D_IDLE;

                when D_IDLE =>
                    start_distance_int      <= '0';
                    dist_counter_en_int     <= '1';
                    dist_counter_reset_int  <= '0';

                    if (dist_counter_zero_int = '1') then
                        curr_state_DIST <= D_START;
                    else
                        curr_state_DIST <= D_IDLE;
                    end if ;
                
                when D_START => 
                    start_distance_int      <= '1';
                    dist_counter_en_int     <= '0';
                    dist_counter_reset_int  <= '1'; --resettiamo il counter per il prossimo giro

                    curr_state_DIST <= D_MEASURING;

                when D_MEASURING => 
                    start_distance_int      <= '0';
                    dist_counter_en_int     <= '0';
                    dist_counter_reset_int  <= '0';

                    if (end_dist_meas_int = '1') then
                        current_distance <= measured_distance_int;
                        curr_state_DIST <= D_IDLE;
                    else
                        curr_state_DIST <= D_MEASURING;
                    end if ;
                    
                when others =>
                    curr_state_DIST <= D_IDLE;                
            end case ;

        end process;




                --ADC (LIGHT) SENSOR FSM

        LIGHT_state_update: process (clk, reset)
        begin
            if (reset = '1') then
                curr_state_LIGHT = L_RESET;
            elsif (rising_edge(clk)) then
                curr_state_LIGHT <= next_state_LIGHT;
            end if ;
        end process;

        DISTANCE_fsm: process(curr_state_LIGHT, light_counter_zero_int, end_light_meas_int)
        begin
            case( curr_state_LIGHT ) is
                
                when L_RESET => 
                    start_light_int             <= '0';
                    light_counter_en_int        <= '0';
                    light_counter_reset_int     <= '1';
                    current_light               <= (others => '0'); 
                
                    next_state_LIGHT            <= L_IDLE;
                
                when L_IDLE =>
                    start_light_int             <= '0';
                    light_counter_en_int        <= '1';
                    light_counter_reset_int     <= '0';
                
                    if (light_counter_zero_int = '1') then
                        next_state_LIGHT <= L_START;
                    else
                        next_state_LIGHT <= L_IDLE;
                    end if ;
                
                when L_START => 
                    start_light_int             <= '1';
                    light_counter_en_int        <= '0';
                    light_counter_reset_int     <= '1'; --resettiamo il counter per il prossimo giro
                
                    next_state_LIGHT <= L_MEASURING;
                
                when L_MEASURING => 
                    start_light_int             <= '0';
                    light_counter_en_int        <= '0';
                    light_counter_reset_int     <= '0';
                
                    if (end_light_meas_int = '1') then
                        current_light <= measured_light_int;
                        next_state_LIGHT <= L_IDLE;
                    else
                        next_state_LIGHT <= L_MEASURING;
                    end if ;
                    
                when others =>
                    next_state_LIGHT <= L_IDLE;              
            end case ;

        end process;


    

end architecture;









