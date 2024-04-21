library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity div_test is
end div_test;


architecture test of div_test is
    
    signal clk_in_s           : std_logic := '0';
    signal clk_out_s           : std_logic;
    signal res           : std_logic;

    component clk_div is
        port (
            clk_in          : in std_logic;
            reset           : in std_logic;
            clk_out         : out std_logic
        );
    end component;

    begin


        clock: process 
        begin
            
            wait for 10 ns;
            clk_in_s <= not clk_in_s; 
                       
        end process clock;

        res <= '0', '1' after 10 ns , '0' after 30 ns;

        div: clk_div port map (
            clk_in => clk_in_s,
            reset => res,
            clk_out => clk_out_s
        );

end test;