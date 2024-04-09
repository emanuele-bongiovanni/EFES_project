library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counter is
    generic(
        NBIT        : integer := 8;
    );
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        start       : in std_logic;
        zero        : out std_logic                   
    );
end counter;


architecture beh of counter is

    signal value    : integer;
    signal going    : std_logic;

    begin

        count: process(clk, rst)
        begin
            if (rst = '1') then
                value <= 0;
                going <= '0';
                zero <= '0';  
            elsif( rising_edge(clk) )
                if (start = '1') then
                    going  <= '1';
                    value  <= NBIT;
                else
                    value  <= value-1;
                end if;

                if (value = 0) then
                    zero <= '1';
                    going <= '0';
                end if;
            end if;

        end process;

end beh;