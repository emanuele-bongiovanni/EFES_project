library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity adc_test is
end adc_test;


architecture test of adc_test is

    component SAR_ADC is
        generic (
            RESOLUTION : integer := 8  -- ADC resolution (bits)
        );
        Port (
            clk             : in STD_LOGIC;            
            start           : in STD_LOGIC;          
            comparator      : in STD_LOGIC; 
            to_dac          : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
            digital_out     : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
            done            : out STD_LOGIC            
        );
    end component;

    signal clk              : std_logic := '0';
    signal start_s          : std_logic := '0';
    signal comparator_s     : std_logic := '0';
    signal to_dac_s         : std_logic_vector(7 downto 0);
    signal digital_out_s    : std_logic_vector(7 downto 0);
    signal done_s           : std_logic := '0';

  --  signal prova             : std_logic_vector(7 downto 0) := "01000000";

    signal starting_value   : integer := 12;

    begin

        adc : SAR_ADC
        generic map (
            RESOLUTION => 8
        )
        port map (
            clk             => clk,
            start           => start_s,
            comparator      => comparator_s,
            to_dac          => to_dac_s,
            digital_out     => digital_out_s,
            done            => done_s
        );

        clock: process
        begin
            wait for 10 ns;
            clk <= not clk;
        end process clock;


        start_s <= '0', '1' after 20 ns, '0' after 40 ns;

   --     prova <= prova and '1' after 20 ns, prova and '0' after 40 ns;

        comparator_s <= '1' when starting_value >= to_integer(unsigned(to_dac_s))  else '0';
        









end test;