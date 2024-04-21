library ieee;
use ieee.std_logic_1164.all;


entity MOTOR_PWM_test is
    port (
         -- CLOCK
         CLOCK_50  : in std_logic;

         -- SEG7
         HEX0_N : out std_logic_vector(6 downto 0);

         -- KEY_N
         KEY_N : in std_logic_vector(3 downto 0);
 
         -- SW
         SW : in std_logic_vector(9 downto 0);
 
         -- GPIO_0
         GPIO_0 : inout std_logic_vector(35 downto 0)
    );
end MOTOR_PWM_test;

architecture test of MOTOR_PWM_test is

    component PWM_module is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            duty_cycle  : in std_logic_vector(2 downto 0);
            pwm_out     : out std_logic
        );
    end component;

    component clk_div is
        port (
            clk_in          : in std_logic;
            reset           : in std_logic;
            clk_out         : out std_logic
        );
    end component;

    signal motor1_in1       : std_logic;
    signal motor1_in2       : std_logic;
    signal reset_button     : std_logic;
    signal clock_slow       : std_logic;
    signal en_pwm           : std_logic;
    

    begin

        motor1_in1 <= SW(0);
        GPIO_0(0) <= motor1_in1;

        motor1_in2 <= SW(1);
        GPIO_0(1) <= motor1_in2;

        GPIO_0(2) <= en_pwm;

        reset_button <= not KEY_N(0);


        clk_divisor: clk_div port map (
            clk_in => CLOCK_50,
            reset => reset_button,
            clk_out => clock_slow
        );

        PWM: PWM_module port map (
            clk => clock_slow,
            rst => reset_button,
            duty_cycle => SW(4 downto 2),
            pwm_out => en_pwm            
        );

end test;