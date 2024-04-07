library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mask_reg is
    generic(
        NBIT:       integer := 8
    );
    port (
        clk:        in std_logic;
        rst:        in std_logic;
        start:      in std_logic;
        shift:      in std_logic;
        d_out:      out std_logic_vector(NBIT-1 downto 0)    
    );
end mask_reg;


architecture beh of mask_reg is

    signal value        : std_logic_vector(NBIT-1 downto 0);

    begin

        process(clk, rst)
        begin
            if (rst = '1') then
                value <= (others => '0');
            elsif (rising_edge(clk)) then
                if (start = '1') then
                    value(NBIT-1) <= '1';
                    value(NBIT-2 downto 0) <= (others => '0');
                elsif (shift = '1') then
                    value <= '0' & value(NBIT-1 downto 1);                    
                end if ;
            end if ;
        end process;

        d_out <= value;

end beh;