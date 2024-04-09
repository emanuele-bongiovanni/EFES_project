library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SAR_ADC is
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
end SAR_ADC;


architecture struct of SAR_ADC is


                --COMONENTS

    component SAR_CU is
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            start           : in std_logic;
            count_zero      : in std_logic;
    
            init            : out std_logic;        --init in pratica è il reset di mask e counter
            mask_shift      : out std_logic;
            data_en         : out std_logic;
            count_en        : out std_logic;
            final_en        : out std_logic
        );
    end component;

    component SAR_DP is
        generic(
            NBIT        : integer := 8
        );
        Port (
            clk             : in std_logic; 
            rst             : in std_logic;
            from_comp       : in std_logic;
            init            : in std_logic;
            final_value_en  : in std_logic;
            mask_shift      : in std_logic;
            counter_en      : in std_logic;
            data_en         : in std_logic;
    
            count_zero      : out std_logic;
            final_value     : out std_logic_vector(NBIT -1 downto 0);
            to_dac          : out std_logic_vector(NBIT -1 downto 0)
        );
    end component;


            --SIGNALS

    signal init_s           : std_logic;
    signal mask_shift_s     : std_logic;
    signal data_en_s        : std_logic;
    signal count_en_s       : std_logic;
    signal final_en_s       : std_logic;
    signal count_zero_s     : std_logic;
    


    begin


        sar: SAR_DP generic map (NBIT)
        port map (
            clk =>  clk,
            rst => rst,
            from_comp =>  comparator,
            init =>  init_s,
            final_value_en =>  final_en_s,
            mask_shift =>  mask_shift_s,
            counter_en =>  count_en_s,
            data_en =>  data_en_s,
            count_zero =>  count_zero_s,
            final_value =>  digital_out,
            to_dac =>  to_dac
        );

        control_unit: SAR_CU
        port map (
            clk =>  clk,
            rst =>  rst,
            start =>  start,
            count_zero =>  count_zero_s,
            init =>  init_s,
            mask_shift =>  mask_shift_s,
            data_en =>  data_en_s,
            count_en =>  count_en_s,
            final_en =>  final_en_s            
        );




end struct;