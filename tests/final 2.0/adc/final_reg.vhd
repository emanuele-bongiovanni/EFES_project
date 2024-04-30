library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity final_reg is
    generic(
        NBIT    : integer := 8
    );
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        enable  : in std_logic;
        inp     : in std_logic_vector(NBIT -1 downto 0);
        outp    : out std_logic_vector(NBIT -1 downto 0)
    );
end final_reg;


architecture beh of final_reg is

    begin
        process(clk, rst)
        begin
            if(rst = '1') then
                outp <= (others => '0');
            elsif(enable = '1') then        --è un oggetto particolare: voglio che lo store dipenda solo dal suo enable
                outp <= inp;                -- in questo modo la lettura precedente è disponibile fino alla fine della successiva
            end if;
        end process;

end beh;
