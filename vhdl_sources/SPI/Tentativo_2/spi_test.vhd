library ieee;
use ieee.std_logic_1164.all;


entity spi_test is
end entity;


architecture test of spi_test is


    component spi_interface is
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
    end component;

    signal sclk_s           : std_logic;
    signal mosi_s           : std_logic;
    signal miso_s           : std_logic;
    signal sel_s            : std_logic;
    signal data_in_s        : std_logic_vector(7 downto 0);
    signal data_out_s       : std_logic_vector(7 downto 0);
    signal readable_s       : std_logic;

    begin

        slave: spi_interface port map (        
            sclk => sclk_s,
            mosi => mosi_s,
            miso => miso_s,
            sel => sel_s,
            data_in => data_in_s,
            data_out => data_out_s,
            readable => readable_s
        );


        sclk_s <= '0', '1' after 200 ns, '0' after 210 ns, '1' after 220 ns, '0' after 230 ns, '1' after 240 ns,
        '0' after 250 ns, '1' after 260 ns, '0' after 270 ns, '1' after 280 ns, '0' after 290 ns, '1' after 300 ns,
        '0' after 310 ns, '1' after 320 ns, '0' after 330 ns, '1' after 340 ns, '0' after 350 ns;

        sel_s <= '0', '1' after 200 ns, '0' after 350 ns;
        mosi_s <= '0', '1' after 280 ns;

        data_in_s <="00000000", "11110000" after 100 ns, "10101010" after 250 ns;


    end test;