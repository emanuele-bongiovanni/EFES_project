library ieee;
use ieee.std_logic_1164.all;


entity SPI_test is
    port (
         -- CLOCK
         CLOCK_50  : in std_logic;
 
         -- SEG7
         HEX0_N : out std_logic_vector(6 downto 0);
         HEX1_N : out std_logic_vector(6 downto 0);
         HEX2_N : out std_logic_vector(6 downto 0);
         HEX3_N : out std_logic_vector(6 downto 0);
         HEX4_N : out std_logic_vector(6 downto 0);
         HEX5_N : out std_logic_vector(6 downto 0);
 
 
         -- KEY_N
         KEY_N : in std_logic_vector(3 downto 0);
 
         -- LED
         LEDR : out std_logic_vector(9 downto 0);
 
         -- SW
         SW : in std_logic_vector(9 downto 0);
 
         -- GPIO_0
         GPIO_0 : inout std_logic_vector(35 downto 0);
         GPIO_1 : inout std_logic_vector(35 downto 0)
    );
end SPI_test;


architecture test of SPI_test is



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
            readable    : out std_logic;

            --test
            internal_out: out std_logic_vector(NBIT-1 downto 0)
        );
    end component;

    component clk_div is
        port (
            clk_in          : in std_logic;
            reset           : in std_logic;
            clk_out         : out std_logic
        );
    end component;

    component hexdisp7seg is
        port (
            datain: in std_logic_vector(3 downto 0);
            seg7:  out std_logic_vector(6 downto 0)
        );
    end component;

    signal sclk_s           : std_logic;
    signal mosi_s           : std_logic;
    signal miso_s           : std_logic;
    signal sel_s            : std_logic;
    signal data_in_s        : std_logic_vector(7 downto 0);
    signal data_out_s       : std_logic_vector(7 downto 0);
    signal readable_s       : std_logic;

    signal internal_out_s       : std_logic_vector(7 downto 0);


    


begin

    --data_in_s <= SW(7 downto 0);

    sclk_s <= GPIO_0(0);
    GPIO_0(1) <= miso_s;
    mosi_s <= GPIO_0(2);
    sel_s <= GPIO_0(3);


    GPIO_1(7 downto 0) <= data_out_s;
    GPIO_1(35) <= readable_s;


    slave: spi_interface port map (        
        sclk => sclk_s,
        mosi => mosi_s,
        miso => miso_s,
        sel => sel_s,
        data_in => data_in_s,
        data_out => data_out_s,
        readable => readable_s,
        internal_out => internal_out_s
    );



    h0 : hexdisp7seg
    port map (
        datain          => data_out_s(3 downto 0),
        seg7            => HEX0_N
    );

    h1 : hexdisp7seg
    port map (
        datain          => data_out_s(7 downto 4),
        seg7            => HEX1_N
    );

    h2 : hexdisp7seg
    port map (
        datain          => data_in_s(3 downto 0),
        seg7            => HEX2_N
    );

    h3 : hexdisp7seg
    port map (
        datain          => data_in_s(7 downto 4),
        seg7            => HEX3_N
    );

    process (data_out_s)
    begin
        --if readable_s = '1' then
            if(data_out_s = "00101010") then
                data_in_s <= "11110000";
            elsif (data_out_s = "00111000") then
                data_in_s <= "00001111";
            else
                data_in_s <= (others => '0') ;
            end if;
        --end if ;
        
            
        
    end process;
    

end architecture;