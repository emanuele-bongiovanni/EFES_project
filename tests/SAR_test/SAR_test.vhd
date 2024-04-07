library ieee;
use ieee.std_logic_1164.all;


entity SAR_test is
    port (
        -- CLOCK
        CLOCK_50     :  in std_logic;
        -- SEG7
        HEX0_N : out std_logic_vector(6 downto 0);
        HEX1_N : out std_logic_vector(6 downto 0);
        -- KEY_N
        KEY_N : in std_logic_vector(3 downto 0);
        -- LED
        LEDR : out std_logic_vector(9 downto 0);
        -- GPIO_0
        GPIO_0 : inout std_logic_vector(35 downto 0);
        -- VGA
        VGA_BLANK_N : out std_logic;
        VGA_CLK     : out std_logic;
        --VGA_HS      : out std_logic;
        VGA_R       : out std_logic_vector(7 downto 0);
        VGA_SYNC_N  : out std_logic
    );
end SAR_test;


architecture test of SAR_test is


    component SAR_ADC is
        Port (
            clk             : in STD_LOGIC;            
            start           : in STD_LOGIC;          
            comparator      : in STD_LOGIC; 
            to_dac          : out STD_LOGIC_VECTOR(7 downto 0); 
            digital_out     : out STD_LOGIC_VECTOR(7 downto 0); 
            done            : out STD_LOGIC            
        );
    end component;

    component hexdisp7seg is
        port (
            datain: in std_logic_vector(3 downto 0);
            seg7:  out std_logic_vector(6 downto 0)
        );
    end component;

    signal comparator_to_sar        : std_logic;
    signal sar_to_dac               : std_logic_vector(7 downto 0);
    signal result                   : std_logic_vector(7 downto 0);
    signal sar_out                  :  std_logic_vector(7 downto 0);
    signal start_button             : std_logic;
    signal fin                      : std_logic;

    begin

        start_button <= not KEY_N(0);           --il pulsante di start è il tasto key0
        comparator_to_sar <= GPIO_0(0);     --il segnale di comparazione è il bit zero di GPIO_0
        
        VGA_CLK <= CLOCK_50;                --il clock della VGA è il clock a 50MHz
        VGA_R <= sar_to_dac;                --il segnale rosso della VGA è il segnale di uscita del DAC
        VGA_SYNC_N <= '0';                  
        VGA_BLANK_N <= '1';                 

        LEDR(0) <= not KEY_N(0);

        ADC : SAR_ADC
        port map (
            clk             => CLOCK_50,
            start           => start_button,
            comparator      => comparator_to_sar,
            to_dac          => sar_to_dac,
            digital_out     => sar_out,
            done            => fin
        );

        h0 : hexdisp7seg
        port map (
            datain          => result(3 downto 0),
            seg7            => HEX0_N
        );

        h1 : hexdisp7seg
        port map (
            datain          => result(7 downto 4),
            seg7            => HEX1_N
        );

        upd: process (fin)
        begin
            if (fin = '1') then
                result <= sar_out;
            end if;
        end process;


end test;