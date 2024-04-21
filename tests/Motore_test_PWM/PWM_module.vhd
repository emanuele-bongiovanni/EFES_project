library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- il clk di input è a 200 kHz; la frequenza del segnale di PWM dovrà essere attorno a 25 kHz (ipotesi da commutation frequency del datasheet)
--un conuter da 8, divide 200 k in 25 k; 
--per selezionare il valore del counter (duty cycle), sono sufficenti 3 bit (log8)


entity PWM_module is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        duty_cycle  : in std_logic_vector(2 downto 0);
        pwm_out     : out std_logic
    );
end PWM_module;

architecture beh of PWM_module is

    signal period   : integer;
    signal clk_cnt  : integer;

    begin

        period <= 8;

        CLK_CNT_PROC : process(clk)
        begin
            if rst = '1' then
                clk_cnt <= 0;
            elsif rising_edge(clk) then
                if clk_cnt < period-1 then
                    clk_cnt <= clk_cnt + 1;
                else
                    clk_cnt <= 0;
                end if ;  
            end if;
        end process;


        PWM_PROC : process(clk)
        begin
            if rst = '1' then
                pwm_out <= '0';
            elsif rising_edge(clk) then
                pwm_out <= '0';
                if clk_cnt >= to_integer(unsigned(duty_cycle)) then
                    pwm_out <= '1';
                end if ;
            
                
            end if;
        end process;
end beh;