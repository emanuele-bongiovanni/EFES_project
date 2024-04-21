library ieee;
use ieee.std_logic_1164.all;


entity MOTOR_test is
    port (
         -- CLOCK
         CLOCK_50  : in std_logic; 
 
         -- SEG7
         HEX0_N : out std_logic_vector(6 downto 0);
         HEX1_N : out std_logic_vector(6 downto 0);

         -- KEY_N
         KEY_N : in std_logic_vector(3 downto 0);
 
         -- LED
         LEDR : out std_logic_vector(9 downto 0);
 
         -- SW
         SW : in std_logic_vector(9 downto 0);
 
         -- GPIO_0
         GPIO_0 : inout std_logic_vector(35 downto 0)
    );
end MOTOR_test;

architecture test of MOTOR_test is


    signal motor1_in1       : std_logic;
    signal motor1_in2       : std_logic;
    signal motor2_in1       : std_logic;
    signal motor2_in2       : std_logic;
    signal motor1_en        : std_logic;
    signal motor2_en        : std_logic;



    begin

        motor1_in1 <= SW(0);
        GPIO_0(0) <= motor1_in1;

        motor1_in2 <= SW(1);
        GPIO_0(1) <= motor1_in2;
        
        motor2_in1 <= SW(2);
        GPIO_0(2) <= motor2_in1;
        
        motor2_in2 <= SW(3);
        GPIO_0(3) <= motor2_in2;
        
        motor1_en <= SW(4);
        GPIO_0(4) <= motor1_en;
        
        motor2_en <= SW(5);
        GPIO_0(5) <= motor2_en;
        


end test;

