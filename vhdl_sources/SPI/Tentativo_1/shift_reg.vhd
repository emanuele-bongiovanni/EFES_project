library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity register_Nbit is
    generic(
        NBIT    : integer := 8
    );
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        value_en        : in std_logic;
        shift_en        : in std_logic;
        value_in        : in std_logic_vector(NBIT -1 downto 0);
        inp             : in std_logic;
        outp            : out std_logic
    );
end register_Nbit;


architecture beh of register_Nbit is


    signal internal     : std_logic_vector(NBIT-1 downto 0);

    begin
        process(clk, rst)
        begin
            if(rst = '1') then
                internal <= (others => '0');
            elsif(rising_edge(clk) and enable = '1') then
                outp <= inp;
            end if;
        end process;

end beh;
