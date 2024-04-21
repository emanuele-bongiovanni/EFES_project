library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity prox_test is
end entity;


architecture test of prox_test is

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


    signal clk_s                    : std_logic := '0';
    signal reset_s                  : std_logic:='0';
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


        sensor: prox_sensor port map (
            clk => clk_s,
            reset => reset_s,
            echo => echo_s,
            new_measure => new_measure_s,
            start_count_zero => start_count_zero_s,
            measure_value => measure_value_s,
            init_start => init_start_s,
            start_en => start_en_s,
            init_measure => init_measure_s,
            measure_en => measure_en_s,
            trigger => trigger_s,
            distance => distance_s
        );

        measure: measure_counter port map (
            clk => clk_s,
            rst => init_measure_s,
            enable => measure_en_s,
            value_out => measure_value_s
        );

        start_count: start_counter port map (
            clk => clk_s,
            rst => init_start_s,
            enable => start_en_s,
            zero => start_count_zero_s
        );


        clk_process: process
        begin
                wait for 2.5 ns;
                clk_s <= not clk_s;
            
        end process;

        reset_s <= '0', '1' after 10 ns, '0' after 15 ns;
        new_measure_s <= '0', '1' after 20 ns, '0' after 25 ns;
        echo_s <= '0', '1' after 20 us, '0' after 150 us;


    end test;