library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SAR_DP is
    generic(
        NBIT        : integer := 8;
    );
    Port (
        clk             : in std_logic; 
        rst             : in std_logic;   
        from_comp       : in std_logic;
        start           : in std_logic;
        final_value_en  : in std_logic;
        mask_shift      : in std_logic;
        data_enable     : in std_logic;

        count_zero      : out std_logic;
        final_value     : out std_logic_vector(NBIT -1 downto 0);
        to_dac          : out std_logic_vector(NBIT -1 downto 0);
    );
end SAR_DP;


architecture struct of SAR_DP is

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

    component mask_reg is
        generic(
            NBIT:       integer := 8
        );
        port (
            clk:        in std_logic;
            rst:        in std_logic;
            start:      in std_logic;
            shift:      in std_logic;
            d_out:      out std_logic_vector(NBIT-1 downto 0)    
        );
    end component;

    component counter is
        generic(
            NBIT        : integer := 8;
        );
        Port (
            clk         : in std_logic;
            rst         : in std_logic;
            start       : in std_logic;
            zero        : out std_logic                   
        );
    end component;


    signal mask_value           : std_logic_vector(NBIT-1 downto 0);
    signal updated_value        : std_logic_vector(NBIT-1 downto 0);
    signal current_value        : std_logic_vector(NBIT-1 downto 0);
    signal comp_value           : std_logic_vector(NBIT-1 downto 0);

    begin


        mask : mask_reg generic map(NBIT) 
        port map(
            clk => clk,
            rst => rst,
            start => start,
            shift => mask_shift,
            d_out => mask_value
        );

        data_reg : register_Nbit generic map(NBIT)
        port map(
            clk => clk,
            rst => rst,
            enable => data_enable,
            inp => updated_value,
            outp => current_value
        );

        count: counter generic map (NBIT)
        port map (
            clk => clk,
            rst => rst,
            start => start,
            zero => count_zero
        );

        data_update_and : for i in NBIT-1 downto 0 generate
            comp_value(i) <= mask_value(i) and from_comp;       --in questo modo si crea un vettore che ha tutti zeri e o zero o uno nella posizione attuale della maschera
        end generate;

        updated_value <= comp_value or current_value;           --il vettore viene usato per aggiornare il valore attuale
        to_dac <= mask_value or current_value                   -- il valore attuale, con la maschera, viene inviato al dac per la nuova valutazione


        final_value : register_Nbit generic map(NBIT)
        port map(
            clk => clk,
            rst => rst,
            enable => final_value_en,
            inp => current_value,           --da verificare
            outp => final_value
        );

end struct;