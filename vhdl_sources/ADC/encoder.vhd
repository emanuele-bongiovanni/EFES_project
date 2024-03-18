library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity decoder is
    Port ( 
        inp             : in std_logic;
        sel             : in std_logic_vector (2 downto 0);
        outp            : out std_logic_vector (7 downto 0)
    );
end decoder;

architecture Behavioral of decoder is

    begin
        process(inp, sel)
        begin
            if inp = '1' then
                case sel is
                    when "000" => outp <= "00000001";
                    when "001" => outp <= "00000010";
                    when "010" => outp <= "00000100";
                    when "011" => outp <= "00001000";
                    when "100" => outp <= "00010000";
                    when "101" => outp <= "00100000";
                    when "110" => outp <= "01000000";
                    when "111" => outp <= "10000000";
                    when others => outp <= "00000000";
                end case;
            else
                outp <= "00000000";
            end if;
        end process;

end Behavioral;

