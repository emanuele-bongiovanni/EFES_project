library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity start_counter is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        enable      : in std_logic;
        zero        : out std_logic                   
    );
end start_counter;


architecture beh of start_counter is

    signal value    : integer;

    begin

        count: process(clk, rst)
        begin
            if (rst = '1') then
                value <= 2200;                  --avendo una frequenza di 200KHz, quindi un periodo di 5 ns, per avere il segnale di trigger di 10 us bisogna aspettare 2000 cicli; aspettiamo 2200 per sicurezza
                zero <= '0';  
            elsif( rising_edge(clk) and enable = '1') then
                value  <= value-1;
                if (value = 0) then
                    zero <= '1';
                end if;
            end if;

        end process;

end beh;