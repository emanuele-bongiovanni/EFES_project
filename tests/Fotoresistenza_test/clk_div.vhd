library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clk_div is
    port (
        clk_in          : in std_logic;
        reset           : in std_logic;
        clk_out         : out std_logic
    );
end clk_div;


architecture beh of clk_div is

    signal DIV      : integer;
    signal count    : integer;
    signal internal : std_logic;

    begin

        process(clk_in, reset)
        begin
            if reset = '1' then
                count <= 0;
                DIV <= 250;           --  valore di divisione clock = 200KHz -> T = 5 us
                internal <= '0';
            elsif rising_edge(clk_in) then             
                if count = (DIV -1) then
                    count <= 0;
                    internal <= not internal;    
                else
                    count <= count + 1;   
                end if;
                                        
            end if ;
        end process;

        clk_out <= internal;

end beh;