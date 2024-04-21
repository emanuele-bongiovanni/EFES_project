library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_test is
end PWM_test;

architecture test of PWM_test is

    component PWM_module is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            duty_cycle  : in std_logic_vector(2 downto 0);
            pwm_out     : out std_logic
        );
    end component;

    signal bits         : integer := 8;
    signal clk_count    : integer := 10;
    signal clk_s        : std_logic := '0';
    signal rst_s        : std_logic := '0';
    signal dt_s         : std_logic_vector (2 downto 0);
    signal pwm_out_s    : std_logic := '0';
    


    begin

        clk_process: process
        begin
            wait for 2.5 ns;
            clk_s <= not clk_s;
            
        end process;

        dt_s <= "011";

        pwm: PWM_module port map (
            clk => clk_s,
            rst => rst_s,
            duty_cycle => dt_s,
            pwm_out => pwm_out_s
        );

        rst_s <= '0', '1' after 5 ns, '0' after 10 ns;

end test;