library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity light_counter is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        enable      : in std_logic;
        zero        : out std_logic                   
    );
end light_counter;


architecture beh of light_counter is

    signal value    : integer;

    begin

        count: process(clk, rst)
        begin
            if (rst = '1') then
                value <= 100000;
                zero <= '0';  
            elsif( rising_edge(clk) and enable = '1') then
                value  <= value-1;
                if (value = 0) then
                    zero <= '1';
                end if;
            end if;

        end process;

end beh;