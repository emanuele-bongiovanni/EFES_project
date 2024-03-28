library ieee;
use ieee.std_logic_1164.all;


entity peripheral is 
    port(
        --mcu interface
        clk             : in std_logic;
        sel             : in std_logic;
        control_mcu     : in std_logic;
        MOSI            : in std_logic;
        MISO            : out std_logic;
        status_mcu      : out std_logic;
        --peripheral interface
        control_pher    : out std_logic;
        status_pher     : in std_logic;
        data_pher       : in std_logic_vector(7 downto 0)
    );
end peripheral;

architecture Behavioral of peripheral is

    component spi_interface is
        port (
                --lato master
            clk         : in std_logic;
            mosi        : in std_logic;
            miso        : out std_logic;
            sel         : in std_logic;   --non è detto che serva 
                --lato-periferica
            data_in     : in std_logic_vector(7 downto 0);
            data_out    : out std_logic_vector(7 downto 0);
        );
    end component;


    begin

    spi: spi_interface port map(
        clk => clk,
        mosi => MOSI,
        miso => MISO,
        sel => sel,
        data_in => data_pher,
        --data_out =>   --non escono dati verso la periferica
    );

    control_pher <= control_mcu;
    status_mcu <= status_pher;
    


end Behavioral;