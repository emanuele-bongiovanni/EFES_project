library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity measure_counter is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        enable      : in std_logic;
        value_out   : out std_logic_vector(20 downto 0)           
    );
end measure_counter;


architecture beh of measure_counter is

    signal value    : std_logic_vector(20 downto 0);

    begin

        count: process(clk, rst)
        begin
            if (rst = '1') then
                value <= (others => '0');
            elsif( rising_edge(clk) and enable = '1') then
                    value  <= std_logic_vector(unsigned(value) + 1);
            end if;

        end process;

        value_out <= value;

end beh;