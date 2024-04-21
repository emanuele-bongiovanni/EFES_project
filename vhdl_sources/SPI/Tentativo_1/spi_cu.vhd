library ieee;
use ieee.std_logic_1164.all;

--NOTA: CPHA = 1, CPOL = 0

entity spi_cu is
    port (
        clk_master              : in std_logic;
        count_end               : in std_logic;

        in_value_reg_en         : out std_logic;        --attivo in IDLE
        out_value_reg_en        : out std_logic;        --attivo in IDLE
        shift_reg_en            : out std_logic;        --enable per il caricamento di valori dentro da IN_VALUE, attivo nell'IDLE; nel running, avviene lo scambio
        count_init              : out std_logic;
        shift_en                : out std_logic;  
    );
end spi_cu;

architecture beh of spi_cu is
    
    type state_type is (IDLE, RUNNING);
    signal curr_state, next_state       : state_type;

    begin

        comb: process (clk_master)
        begin
            if rising_edge(clk_master) then
                curr_state <= next_state;
            end if;

        end process comb;

        seq: process (curr_state)
        begin
            case curr_state is
                when IDLE =>
                    next_state <= RUNNING;
                    in_value_reg_en => '1';
                    out_value_reg_en => '1';
                    shift_reg_en => '1';
                    count_init => '1';

                when RUNNING =>
                    in_value_reg_en => '1';
                    out_value_reg_en => '1';
                    shift_reg_en => '1';
                    count_init => '1';


                when others =>
                    

            end case;
        end process seq;


end beh;