library ieee;
use ieee.std_logic_1164.all;


entity PHOTO_test is
    port (
        -- CLOCK
        CLOCK_50     :  in std_logic;
        -- SEG7
        HEX0_N : out std_logic_vector(6 downto 0);
        HEX1_N : out std_logic_vector(6 downto 0);
        --HEX2_N : out std_logic_vector(6 downto 0);
        --HEX3_N : out std_logic_vector(6 downto 0);

        -- KEY_N
        KEY_N : in std_logic_vector(3 downto 0);
        -- LED
        LEDR : out std_logic_vector(9 downto 0);
        -- SW
        SW : in std_logic_vector(9 downto 0);
        -- GPIO_0
        GPIO_0 : inout std_logic_vector(35 downto 0);
        GPIO_1 : inout std_logic_vector(35 downto 0);

        -- VGA
        VGA_BLANK_N : out std_logic;
        VGA_CLK     : out std_logic;
        --VGA_HS      : out std_logic;
        VGA_R       : out std_logic_vector(7 downto 0);
        VGA_B       : out std_logic_vector(7 downto 0);

        VGA_SYNC_N  : out std_logic
    );
end PHOTO_test;


architecture test of PHOTO_test is

    component clk_div is
        port (
            clk_in          : in std_logic;
            reset           : in std_logic;
            clk_out         : out std_logic
        );
    end component;

    component SAR_ADC is
        generic(
            NBIT        : integer := 8
        );
        Port (
            clk             : in STD_LOGIC;
            rst             : in STD_LOGIC;       
            start           : in STD_LOGIC;          
            comparator      : in STD_LOGIC; 
            to_dac          : out STD_LOGIC_VECTOR(NBIT - 1 downto 0); 
            digital_out     : out STD_LOGIC_VECTOR(NBIT - 1 downto 0); 
            done            : out STD_LOGIC            
        );
    end component;

    component hexdisp7seg is
        port (
            datain: in std_logic_vector(3 downto 0);
            seg7:  out std_logic_vector(6 downto 0)
        );
    end component;

    signal comparator_to_sar         : std_logic;
    signal sar_to_dac                : std_logic_vector(7 downto 0);
    signal result                       : std_logic_vector(7 downto 0);
    signal sar_out                      : std_logic_vector(7 downto 0);
    signal start_button                 : std_logic;
    signal reset_button                 : std_logic;
    signal start                        : std_logic;
    signal reset                        : std_logic;
    signal clock_sar                    : std_logic;

    signal start_f1                     : std_logic;
    signal start_f2                     : std_logic;
    
    signal fin                          : std_logic;

    begin

        start_button <= not KEY_N(0);           --il pulsante di start è il tasto key0
        reset_button <= not KEY_N(1);
        --start_button <= GPIO_0(29);
        comparator_to_sar <= GPIO_0(0);     --il segnale di comparazione è il bit zero di GPIO_0
        
        VGA_CLK <= CLOCK_50;                --il clock della VGA è il clock a 50MHz
        VGA_R <= sar_to_dac;            --il segnale rosso della VGA è il segnale di uscita del DAC
        VGA_SYNC_N <= '0';                  
        VGA_BLANK_N <= '1';                 


        --osservazioni
        --GPIO_0(35) <= clock_sar;
        --GPIO_0(29) <= start;
        --GPIO_0(34) <= fin;

        GPIO_0(35 downto 28) <= sar_to_dac;
       -- GPIO_1(35 downto 28) <= sar_out;
       GPIO_1(35) <= start_button;


        clk_divisor: clk_div port map (
            clk_in => CLOCK_50,
            reset => reset_button,
            clk_out => clock_sar
        );

        ADC : SAR_ADC
        port map (
            clk             => clock_sar,
            rst             => reset_button,
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

        -- h2 : hexdisp7seg
        -- port map (
        --     datain          => SW(3 downto 0),
        --     seg7            => HEX2_N
        -- );

        -- h3 : hexdisp7seg
        -- port map (
        --     datain          => SW(7 downto 4),
        --     seg7            => HEX3_N
        -- );

   

        upd: process (fin)
        begin
            if (fin = '1') then
                result <= sar_out;
            end if;
        end process;
        
        -- start_reset: process (reset_button, fin, clock_sar)
        -- begin
        --     if reset_button = '1' then
        --         start <=  '0';
        --         start_f1 <= '0';
        --         start_f2 <= '0';
            
        --     elsif rising_edge(clock_sar) then
        --         if (start_button = '1' and start_f1 = '0') then
        --             start <= '1';
        --             start_f1 <= '1';
        --             start_f2 <= '1';
        --         elsif start_f2 = '1' then
        --             start <= '0';
        --             start_f2 <= '1';
        --         end if;

        --     end if ;
            
        -- end process;


end test;