library ieee;
use ieee.std_logic_1164.all;
use work.mypackage.all;


entity datapath is
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
end entity datapath;

architecture beh of datapath is

                    -- COMPONENTS

    --proximity sensor module
    component PROX_SENSOR_ELEM is
        port (
            clk                 : in std_logic;
            reset               : in std_logic;
            echo                : in std_logic;
            start               : in std_logic;
            trigger             : out std_logic;
            done                : out std_logic;
            result              : out std_logic_vector(31 downto 0)        
        );
    end component;

    --analog to digital converter (connected to photo-resistance) module
    component SAR_ADC_ELEM is
        generic(
            NBIT        : integer := 8
        );
        Port (
            clk             : in STD_LOGIC;
            rst             : in STD_LOGIC;       
            start           : in STD_LOGIC;          
            comparator      : in STD_LOGIC; 
            to_dac          : out STD_LOGIC_VECTOR(NBIT - 1 downto 0); 
            digital_out     : out STD_LOGIC_VECTOR(NBIT - 1 downto 0); 
            done            : out STD_LOGIC            
        );
    end component;

    --pwm generator module for motor speed control 
    component PWM_ELEM is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            duty_cycle  : in std_logic_vector(2 downto 0);
            pwm_out     : out std_logic
        );
    end component;

    --spi interface module for comm with NUCLEO board
    component SPI_INTERFACE_ELEM is
        generic(
            CPOL        : std_logic := '0';
            NBIT        : integer := PACKET_DIM
        );
        port (
                --lato master
            sclk         : in std_logic;
            mosi        : in std_logic;
            miso        : out std_logic;
            sel         : in std_logic;  
                --lato-periferica
            data_in     : in std_logic_vector(NBIT-1 downto 0);
            data_out    : out std_logic_vector(NBIT-1 downto 0);
            readable    : out std_logic
        );
    end component;

    --counters to be used for wait of controller process
    --thery are actually the same component, just with different resetting values
    --this is an attempt to actually get to change the behaviour of the manouvre for the movement without breaking everything
    component distance_counter is
        Port (
            clk         : in std_logic;
            rst         : in std_logic;
            enable      : in std_logic;
            zero        : out std_logic                   
        );
    end component;

    component light_counter is
        Port (
            clk         : in std_logic;
            rst         : in std_logic;
            enable      : in std_logic;
            zero        : out std_logic                   
        );
    end component;

    component motor_counter is
        Port (
            clk         : in std_logic;
            rst         : in std_logic;
            enable      : in std_logic;
            zero        : out std_logic                   
        );
    end component;
    


    begin

        proximity_sensor: PROX_SENSOR_ELEM port map (
            clk                 => clk,
            reset               => reset,
            echo                => echo_ext,
            start               => start_distance_int,
            trigger             => trigger_ext,
            done                => end_dist_meas_int,
            result              => measured_distance_int
        );

        sar_adc: SAR_ADC_ELEM port map (
            clk                 => clk,
            rst                 => reset,
            start               => start_light_int,
            comparator          => comparator_ext,
            to_dac              => to_dac_ext,
            digital_out         => measured_light_int,
            done                => end_light_meas_int
        );

        pwm: PWM_ELEM port map (
            clk                 => clk,
            rst                 => reset,
            duty_cycle          => speed_dc_int,
            pwm_out             => pwm_motor_en_ext
        );

        spi_interface: SPI_INTERFACE_ELEM port map (
            sclk                => master_clk_ext,
            mosi                => mosi_ext,
            miso                => miso_ext,
            sel                 => master_sel_ext,
            data_in             => data_to_send_int,
            data_out            => data_from_master_int,
            readable            => data_readable_int
        );

        --Counters for CU

        dist_counter: distance_counter 
        port map (
            clk                 => clk, 
            rst                 => dist_counter_reset_int,
            enable              => dist_counter_en_int,
            zero                => dist_counter_zero_int
        );

        l_counter: light_counter
        port map (
            clk                 => clk, 
            rst                 => light_counter_reset_int,
            enable              => light_counter_en_int,
            zero                => light_counter_zero_int
        );

        mtr_counter: motor_counter
        port map (
            clk                 => clk, 
            rst                 => motor_counter_reset_int,
            enable              => motor_counter_en_int,
            zero                => motor_counter_zero_int
        );




end beh;