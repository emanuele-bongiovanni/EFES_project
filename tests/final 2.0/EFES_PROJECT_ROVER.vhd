library ieee;
use ieee.std_logic_1164.all;
use work.mypackage.all;


entity EFES_PROJECT_ROVER is
    port (
         -- CLOCK
         CLOCK_50  : in std_logic;

         -- SEG7
         HEX0_N : out std_logic_vector(6 downto 0);
         HEX1_N : out std_logic_vector(6 downto 0);
         HEX2_N : out std_logic_vector(6 downto 0);
         HEX3_N : out std_logic_vector(6 downto 0);
        -- HEX4_N : out std_logic_vector(6 downto 0);
        -- HEX5_N : out std_logic_vector(6 downto 0);
 
         -- KEY_N
         KEY_N : in std_logic_vector(3 downto 0);
 
         -- LED
         LEDR : out std_logic_vector(9 downto 0);
 
         -- SW
         SW : in std_logic_vector(9 downto 0);
 
         -- VGA
         VGA_BLANK_N : out std_logic;
         VGA_CLK     : out std_logic;
         VGA_R       : out std_logic_vector(7 downto 0);
         VGA_SYNC_N  : out std_logic;
 
         -- GPIO_0
         GPIO_0 : inout std_logic_vector(35 downto 0);
 
         -- GPIO_1
         GPIO_1 : inout std_logic_vector(35 downto 0)
    );
end entity;


architecture top of EFES_PROJECT_ROVER is

    component controller is
        port(
            clk                         : in std_logic;
            rst                         : in std_logic;
    
            end_dist_meas_int           : in std_logic;                                 --new distance available
            measured_distance_int       : in std_logic_vector(31 downto 0);             --measured distance (used also externally)
            measured_light_int          : in std_logic_vector(NBIT - 1 downto 0);       --measured light
            end_light_meas_int          : in std_logic;                                 --new light measure available
            data_from_master_int        : in std_logic_vector(PACKET_DIM-1 downto 0);         --data arriving from master
            data_readable_int           : in std_logic;                                 --spi data readable
            dist_counter_zero_int       : in std_logic;                                 --end counter for distance
            light_counter_zero_int      : in std_logic;                                 --end counter for light
            motor_counter_zero_int      : in std_logic;                                 --end counter for motor turn
    
    
            motor_r                     : out std_logic_vector(1 downto 0);             -- right motor control
            motor_l                     : out std_logic_vector(1 downto 0);             -- left motor control 
            start_distance_int          : out std_logic;                                --start new distance measure
            start_light_int             : out std_logic;                                --start new light measure
            speed_dc_int                : out std_logic_vector(2 downto 0);             --duty cycle for speed setting
            data_to_send_int            : out std_logic_vector(PACKET_DIM-1 downto 0);        --data to be sent to master
            dist_counter_en_int         : out std_logic;                                --start counter for distance
            dist_counter_reset_int      : out std_logic;                                --reset counter for distance
            light_counter_en_int        : out std_logic;                                --start counter for light
            light_counter_reset_int     : out std_logic;                                --reset counter for light
            motor_counter_en_int        : out std_logic;                                --start counter for motor turn
            motor_counter_reset_int     : out std_logic                                --reset counter for motor turn  
        );  
    end component;

    component datapath is
        port(
            clk                     : in std_logic;
            reset                   : in std_logic;
    
            --signal for internal use (Controller)
            start_distance_int      : in std_logic;                             --start new distance measure
            start_light_int         : in std_logic;                             --start new light measure
            speed_dc_int            : in std_logic_vector(2 downto 0);          --duty cycle for speed setting
            data_to_send_int        : in std_logic_vector(PACKET_DIM-1 downto 0);     --data to be sent to master
            dist_counter_en_int     : in std_logic;                                --start counter for distance
            dist_counter_reset_int  : in std_logic;
            light_counter_en_int    : in std_logic;                                --start counter for light
            light_counter_reset_int : in std_logic;                                --reset counter for light
            motor_counter_en_int    : in std_logic;                                --start counter for motor turn
            motor_counter_reset_int : in std_logic;                                --reset counter for motor turn
            
            end_dist_meas_int       : out std_logic;                            --new distance available
            measured_distance_int   : out std_logic_vector(31 downto 0);        --measured distance (used also externally)
            measured_light_int      : out std_logic_vector(NBIT - 1 downto 0);  --measured light
            end_light_meas_int      : out std_logic;                            --new light measure available
            data_from_master_int    : out std_logic_vector(PACKET_DIM-1 downto 0);    --data arriving from master
            data_readable_int       : out std_logic;                            --spi data readable
            dist_counter_zero_int   : out std_logic;                                 --end counter for distance
            light_counter_zero_int  : out std_logic;                                 --end counter for light
            motor_counter_zero_int  : out std_logic;                                 --end counter for motor turn
    
            --signal for external use
            echo_ext                : in std_logic;                             --signal returned by prox sensor
            comparator_ext          : in std_logic;                             --comparison signal for adc
            master_clk_ext          : in std_logic;                             --master clock for spi
            mosi_ext                : in std_logic;                             --mosi signal from master
            master_sel_ext          : in std_logic;                             --master chip select signal
            trigger_ext             : out std_logic;                            --signal sent to prox sensor to start measure
            to_dac_ext              : out std_logic_vector(NBIT - 1 downto 0);  --vector for DE1 digital to analog converter
            pwm_motor_en_ext        : out std_logic;                            --enable PWM signal for motor
            miso_ext                : out std_logic                            --miso signal to master
        );
    end component;

    component clk_div is
        port (
            clk_in          : in std_logic;
            reset           : in std_logic;
            clk_out         : out std_logic
        );
    end component;

    component hexdisp7seg is
        port (
            datain: in std_logic_vector(3 downto 0);
            seg7:  out std_logic_vector(6 downto 0)
        );
    end component;

    --SIGNALS


    signal end_dist_meas_int_s              : std_logic;
    signal measured_distance_int_s          : std_logic_vector(31 downto 0);
    signal measured_light_int_s             : std_logic_vector(NBIT - 1 downto 0);
    signal end_light_meas_int_s             : std_logic;
    signal data_from_master_int_s           : std_logic_vector(PACKET_DIM-1 downto 0);
    signal data_readable_int_s              : std_logic;
    signal dist_counter_zero_int_s          : std_logic;
    signal light_counter_zero_int_s         : std_logic;
    signal motor_counter_zero_int_s         : std_logic;
    signal motor_r_s                        : std_logic_vector(1 downto 0);
    signal motor_l_s                        : std_logic_vector(1 downto 0);
    signal start_distance_int_s             : std_logic;
    signal start_light_int_s                : std_logic;
    signal speed_dc_int_s                   : std_logic_vector(2 downto 0);
    signal data_to_send_int_s               : std_logic_vector(PACKET_DIM-1 downto 0); 
    signal dist_counter_en_int_s            : std_logic;
    signal dist_counter_reset_int_s         : std_logic;
    signal light_counter_en_int_s           : std_logic;
    signal light_counter_reset_int_s        : std_logic;
    signal motor_counter_en_int_s           : std_logic;
    signal motor_counter_reset_int_s        : std_logic;
    signal clock_5u                         : std_logic;
    signal reset_button                     : std_logic;
    signal echo_ext_s                       : std_logic;
    signal comparator_ext_s                 : std_logic;
    signal master_clk_ext_s                 : std_logic;
    signal mosi_ext_s                       : std_logic;
    signal master_sel_ext_s                 : std_logic;
    signal trigger_ext_s                    : std_logic;
    signal to_dac_ext_s                     : std_logic_vector(NBIT - 1 downto 0);
    signal pwm_motor_en_ext_s               : std_logic;
    signal miso_ext_s                       : std_logic;
    signal motor_enable                     : std_logic;

  --  signal result                           : std_logic_vector(3 downto 0);

begin


    process (CLOCK_50)
    begin
        if SW(0) = '0' then
            motor_enable <= pwm_motor_en_ext_s;
        else
            motor_enable <= '0';
        end if ;
        
    end process;

    reset_button            <= not KEY_N(0);
    --motor
    GPIO_1(1 downto 0)      <= motor_l_s;
    GPIO_1(3 downto 2)      <= motor_r_s;
    GPIO_1(4)               <= motor_enable;
    GPIO_1(5)               <= motor_enable;


    --prox
    echo_ext_s              <= GPIO_1(14);
    GPIO_1(15)               <= trigger_ext_s;

    --adc
    comparator_ext_s        <= GPIO_0(0);
    VGA_R                   <= to_dac_ext_s;
    VGA_CLK                 <= CLOCK_50;
    VGA_SYNC_N              <= '0';                  
    VGA_BLANK_N             <= '1';


    --spi
    master_clk_ext_s        <= GPIO_1(35);
    master_sel_ext_s        <= GPIO_1(34);
    mosi_ext_s              <= GPIO_1(33);
    GPIO_1(32)              <= miso_ext_s;


    h0 : hexdisp7seg
    port map (
        datain          => measured_light_int_s(3 downto 0),
        seg7            => HEX0_N
    );
    h1 : hexdisp7seg
    port map (
        datain          => measured_light_int_s(7 downto 4),
        seg7            => HEX1_N
    );


    h2 : hexdisp7seg
    port map (
        datain          => measured_distance_int_s(3 downto 0),
        seg7            => HEX2_N
    );
    h3 : hexdisp7seg
    port map (
        datain          => measured_distance_int_s(7 downto 4),
        seg7            => HEX3_N
    );

    --test counter:

    GPIO_0(35) <= clock_5u;



    CONTROLLER_INSTANCE: controller port map (
        clk                             => clock_5u,
        rst                             => reset_button,
        end_dist_meas_int               => end_dist_meas_int_s,
        measured_distance_int           => measured_distance_int_s,
        measured_light_int              => measured_light_int_s,
        end_light_meas_int              => end_light_meas_int_s,
        data_from_master_int            => data_from_master_int_s,
        data_readable_int               => data_readable_int_s,
        dist_counter_zero_int           => dist_counter_zero_int_s,
        light_counter_zero_int          => light_counter_zero_int_s,
        motor_counter_zero_int          => motor_counter_zero_int_s,
        motor_r                         => motor_r_s,
        motor_l                         => motor_l_s,
        start_distance_int              => start_distance_int_s,
        start_light_int                 => start_light_int_s,
        speed_dc_int                    => speed_dc_int_s,
        data_to_send_int                => data_to_send_int_s,
        dist_counter_en_int             => dist_counter_en_int_s,
        dist_counter_reset_int          => dist_counter_reset_int_s,
        light_counter_en_int            => light_counter_en_int_s,
        light_counter_reset_int         => light_counter_reset_int_s,
        motor_counter_en_int            => motor_counter_en_int_s,
        motor_counter_reset_int         => motor_counter_reset_int_s
    );

    DATAPATH_INSTANCE:  datapath port map (
        clk                             => clock_5u,
        reset                           => reset_button,
        start_distance_int              => start_distance_int_s,
        start_light_int                 => start_light_int_s,
        speed_dc_int                    => speed_dc_int_s,
        data_to_send_int                => data_to_send_int_s,
        dist_counter_en_int             => dist_counter_en_int_s,
        dist_counter_reset_int          => dist_counter_reset_int_s,
        light_counter_en_int            => light_counter_en_int_s,
        light_counter_reset_int         => light_counter_reset_int_s,
        motor_counter_en_int            => motor_counter_en_int_s,
        motor_counter_reset_int         => motor_counter_reset_int_s,
        end_dist_meas_int               => end_dist_meas_int_s,
        measured_distance_int           => measured_distance_int_s,
        measured_light_int              => measured_light_int_s,
        end_light_meas_int              => end_light_meas_int_s,
        data_from_master_int            => data_from_master_int_s,
        data_readable_int               => data_readable_int_s,
        dist_counter_zero_int           => dist_counter_zero_int_s,
        light_counter_zero_int          => light_counter_zero_int_s,
        motor_counter_zero_int          => motor_counter_zero_int_s,
        echo_ext                        => echo_ext_s,
        comparator_ext                  => comparator_ext_s,
        master_clk_ext                  => master_clk_ext_s,
        mosi_ext                        => mosi_ext_s,
        master_sel_ext                  => master_sel_ext_s,
        trigger_ext                     => trigger_ext_s,
        to_dac_ext                      => to_dac_ext_s,
        pwm_motor_en_ext                => pwm_motor_en_ext_s,
        miso_ext                        => miso_ext_s
    );
    
    clk_divisor: clk_div port map (
        clk_in                          => CLOCK_50,
        reset                           => reset_button,
        clk_out                         => clock_5u
    );

end architecture;