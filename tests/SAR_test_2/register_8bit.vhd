library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity register_8bit is
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        inp     : in std_logic_vector(7 downto 0);
        outp    : out std_logic_vector(7 downto 0)
    );
end register_8bit;


architecture beh of register_8bit is

    begin
        process(clk, rst)
        begin
            if(rising_edge(clk)) then
                if rst = '1' then
                    outp <= (others => '0');
                else
                    outp <= inp;
                end if ;
            end if;
        end process;

end beh;
