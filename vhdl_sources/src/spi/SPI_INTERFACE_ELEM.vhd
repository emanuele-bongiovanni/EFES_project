library ieee;
use ieee.std_logic_1164.all;

--NOTA: CPHA = 1, CPOL = 0

entity SPI_INTERFACE_ELEM is
    generic(
        CPOL        : std_logic := '0';
        NBIT        : integer := 8
    );
    port (
            --lato master
        sclk         : in std_logic;
        mosi        : in std_logic;
        miso        : out std_logic;
        sel         : in std_logic;  
            --lato-periferica
        data_in     : in std_logic_vector(NBIT-1 downto 0);
        data_out    : out std_logic_vector(NBIT-1 downto 0);
        readable    : out std_logic
    );
end SPI_INTERFACE_ELEM;

architecture beh of SPI_INTERFACE_ELEM is

    signal internal                     : std_logic_vector(NBIT-1 downto 0);
    signal for_out                      : std_logic_vector(NBIT-1 downto 0);
        
    
    begin
        readable <= not sel;


        transmission: process (sclk, data_in, sel)
        begin
            if(sclk'event and sclk = not CPOL) then 
                internal <= internal(NBIT-2 downto 0) & mosi;
                for_out <= internal(NBIT-2 downto 0) & mosi;
            end if;

            if(sclk'event and sclk = CPOL) then 
                miso <= internal(NBIT-1);
            end if;

            if(sel = '0') then   -- periferica non utilizzata
                internal <= data_in;
                data_out <= for_out;
            end if;
        end process;
    

end beh;