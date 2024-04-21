library ieee;
use ieee.std_logic_1164.all;


entity PROXIMITY_test is
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
 
         -- SW
         SW : in std_logic_vector(9 downto 0);
 
         -- GPIO_0
         GPIO_0 : inout std_logic_vector(35 downto 0)
 
    );
end PROXIMITY_test;


architecture test of PROXIMITY_test is


    component prox_sensor is
        port (
            clk                     : in std_logic;
            reset                   : in std_logic;
            echo                    : in std_logic;
            new_measure             : in std_logic;
            start_count_zero        : in std_logic; 
            measure_value           : in std_logic_vector(20 downto 0);
    
    
            init_start              : out std_logic;        -- reset dello start counter
            start_en                : out std_logic;        -- enable di start counter
            init_measure            : out std_logic;        --reset del counter measure
            measure_en              : out std_logic;        --enable del counter measure
            trigger                 : out std_logic;
    
            terminated              : out std_logic;
            distance                : out std_logic_vector(31 downto 0)
        );
    end component;

    component measure_counter is
        Port (
            clk         : in std_logic;
            rst         : in std_logic;
            enable      : in std_logic;
            value_out   : out std_logic_vector(20 downto 0)              
        );
    end component;

    
    component start_counter is
        Port (
            clk         : in std_logic;
            rst         : in std_logic;
            enable      : in std_logic;
            zero        : out std_logic                   
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

    component register_Nbit is
        generic(
            NBIT    : integer := 8
        );
        port(
            clk     : in std_logic;
            rst     : in std_logic;
            enable  : in std_logic;
            inp     : in std_logic_vector(NBIT -1 downto 0);
            outp    : out std_logic_vector(NBIT -1 downto 0)
        );
    end component;

    signal slow_clock                   : std_logic;
    signal start_button                 : std_logic;
    signal reset_button                 : std_logic;
    signal start                        : std_logic;
    signal start_f1                        : std_logic;
    signal start_f2                        : std_logic;

    signal result                       : std_logic_vector(31 downto 0);

    signal terminated_s                 : std_logic;
    signal echo_s                     : std_logic;
    signal new_measure_s              : std_logic;
    signal start_count_zero_s         : std_logic;
    signal measure_value_s            : std_logic_vector(20 downto 0);
    signal init_start_s               : std_logic;
    signal start_en_s                 : std_logic;
    signal init_measure_s             : std_logic;
    signal measure_en_s               : std_logic;
    signal trigger_s                  : std_logic;
    signal distance_s                 : std_logic_vector(31 downto 0);

    begin



        start_button <= not KEY_N(0);           --il pulsante di start è il tasto key0
        reset_button <= not KEY_N(1);


        GPIO_0(0) <= trigger_s;
        echo_s <= GPIO_0(1);
        GPIO_0(35) <= slow_clock;




        clk_divisor: clk_div port map (
            clk_in => CLOCK_50,
            reset => reset_button,
            clk_out => slow_clock
        );

        sensor: prox_sensor port map (
            clk => slow_clock,
            reset => reset_button,
            echo => echo_s,
            new_measure => start,
            start_count_zero => start_count_zero_s,
            measure_value => measure_value_s,
            init_start => init_start_s,
            start_en => start_en_s,
            init_measure => init_measure_s,
            measure_en => measure_en_s,
            trigger => trigger_s,
            terminated => terminated_s,
            distance => distance_s
        );

        measure: measure_counter port map (
            clk => slow_clock,
            rst => init_measure_s,
            enable => measure_en_s,
            value_out => measure_value_s
        );

        start_count: start_counter port map (
            clk => slow_clock,
            rst => init_start_s,
            enable => start_en_s,
            zero => start_count_zero_s
        );

        out_reg: register_Nbit generic map (32) 
        port map (
            clk => slow_clock,
            rst => reset_button,
            enable => terminated_s,
            inp => distance_s,
            outp => result
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

        h2 : hexdisp7seg
        port map (
            datain          => result(11 downto 8),
            seg7            => HEX2_N
        );

        h3 : hexdisp7seg
        port map (
            datain          => result(15 downto 12),
            seg7            => HEX3_N
        );

        h4 : hexdisp7seg
        port map (
            datain          => result(19 downto 16),
            seg7            => HEX4_N
        );

        h5 : hexdisp7seg
        port map (
            datain          => result(23 downto 20),
            seg7            => HEX5_N
        );


        
        
        start_reset: process (reset_button, terminated_s, slow_clock)
        begin
            if reset_button = '1' then
                start <=  '0';
                start_f1 <= '0';
                start_f2 <= '0';
            
            elsif rising_edge(slow_clock) then
                if (start_button = '1' and start_f1 = '0') then
                    start <= '1';
                    start_f1 <= '1';
                    start_f2 <= '1';
                elsif start_f2 = '1' then
                    start <= '0';
                    start_f2 <= '1';
                end if;
                    

                
            end if ;
            
        end process;



    end test;