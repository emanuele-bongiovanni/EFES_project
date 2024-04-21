library ieee;
use ieee.std_logic_1164.all;
use work.mypackage.all;


entity PROX_SENSOR_ELEM is
    port (
        clk                 : in std_logic;
        reset               : in std_logic;
        echo                : in std_logic;
        start               : in std_logic;
        trigger             : out std_logic;
        done:               : out std_logic;
        result              : out std_logic_vector(31 downto 0)        
    );
end entity;


architecture struct_box of PROX_SENSOR_ELEM is

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



    signal new_measure_s        : std_logic;   
    signal start_count_zero_s   : std_logic;       
    signal measure_value_s      : std_logic_vector(20 downto 0);    
    signal init_start_s         : std_logic;
    signal start_en_s           : std_logic;
    signal init_measure_s       : std_logic;   
    signal measure_en_s         : std_logic;
    signal trigger_s            : std_logic;
    signal terminated_s         : std_logic;
    signal distance_s           : std_logic_vector(31 downto 0);

    
begin


    done <= terminated_s;

    sensor: prox_sensor port map (
            clk                 => clk,
            reset               => reset,
            echo                => echo,
            new_measure         => start,
            start_count_zero    => start_count_zero_s,
            measure_value       => measure_value_s,
            init_start          => init_start_s,
            start_en            => start_en_s,
            init_measure        => init_measure_s,
            measure_en          => measure_en_s,
            trigger             => trigger,
            terminated          => terminated_s,
            distance            => distance_s
        );

        measure: measure_counter port map (
            clk                 => clk,
            rst                 => init_measure_s,
            enable              => measure_en_s,
            value_out           => measure_value_s
        );

        start_count: start_counter port map (
            clk                 => clk,
            rst                 => init_start_s,
            enable              => start_en_s,
            zero                => start_count_zero_s
        );

        out_reg: register_Nbit generic map (32) 
        port map (
            clk                 => clk,
            rst                 => reset,
            enable              => terminated_s,
            inp                 => distance_s,
            outp                => result
        );

    

end architecture;