library ieee;
use ieee.std_logic_1164.all;
use work.mypackage.all;


entity datapath is
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        comparator_in   : in std_logic;
        motor1_out      : out std_logic;
        motor2_out      : out std_logic;
        dac_out         : out std_logic_vector(RESOLUTION - 1 downto 0);
        control         : in std_logic;
        status          : out std_logic;
        data_for_mcu    : out std_logic_vector(RESOLUTION - 1 downto 0);
        
    );
end entity datapath;

architecture beh of datapath is

                    -- COMPONENTS

    component controller is
        port(
            clk             : in std_logic;
            rst             : in std_logic;
            sensor_in       : in std_logic_vector(RESOLUTION - 1 downto 0);
            sensor_done     : in std_logic;
            sense_start     : out std_logic;
            motor_1         : out std_logic;
            motor_2         : out std_logic
        );    
    end component;

    component SAR_ADC is
        Port (
            clk             : in STD_LOGIC;            
            start           : in STD_LOGIC;          
            comparator      : in STD_LOGIC; 
            to_dac          : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
            digital_out     : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
            done            : out STD_LOGIC            
        );
    end component;


                    -- SIGNALS
    signal sensor_in_s              : std_logic_vector(RESOLUTION - 1 downto 0);
    signal sensor_done_s            : std_logic;
    signal sense_start_s            : std_logic;
    

    
                    -- BEGIN



    begin

        --AGGIORNARE CONTROLLER, PER GESTIRE LE RICHIESTE DI DATI DALL'MCU
    controller_inst: controller
        port map(
            clk             => clk,
            rst             => reset,
            sensor_in       => sensor_in_s,
            sensor_done     => sensor_done_s,
            sense_start     => sense_start_s,
            motor_1         => motor1_out,
            motor_2         => motor2_out
        );

    adc_inst: SAR_ADC
        port map(
            clk             => clk,
            start           => sense_start_s,
            comparator      => comparator_in,
            to_dac          => dac_out,
            digital_out     => sensor_in_s,
            done            => sensor_done_s
        );




end beh;