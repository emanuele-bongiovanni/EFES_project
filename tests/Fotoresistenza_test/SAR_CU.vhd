library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity SAR_CU is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        start           : in std_logic;
        count_zero      : in std_logic;

        init            : out std_logic;        --init in pratica è il reset di mask e counter
        mask_shift      : out std_logic;
        data_en         : out std_logic;
        count_en        : out std_logic;
        final_en        : out std_logic;
        done            : out std_logic
    );
end SAR_CU;


architecture fsm of SAR_CU is

    type SAR_state is (RESET, IDLE, SAMPLING, UPDATE);
    signal curr_state, next_state       : SAR_state;



    begin

        seq_update: process(clk, rst)
        begin
            if (rst = '1') then
                curr_state <= RESET;    
            elsif(rising_edge(clk)) then
                curr_state <= next_state;
            end if ;
        end process seq_update;
        
        comb_fsm: process(curr_state, start, count_zero)
        begin
            case( curr_state ) is
            
                when RESET =>
                    init <= '1';
                    mask_shift <= '0';
                    data_en <= '0';
                    count_en <= '0';
                    final_en <= '0';
                    done <= '0';

                    next_state <= IDLE;

                when IDLE =>
                    init <= '1';            -- in idle si tiene init attivo, in modo che mask e counter siano sempre pronti a partire
                    mask_shift <= '0';
                    data_en <= '0';
                    count_en <= '0';
                    final_en <= '0';        --done viene riazzerato durante sampling
                    

                    if start = '1' then
                        next_state <= SAMPLING;
                    else
                        next_state <= IDLE;
                    end if ;

                when SAMPLING =>
                    init <= '0';
                    mask_shift <= '1';
                    data_en <= '1';
                    count_en <= '1';
                    final_en <= '0';
                    done <= '0';


                    if count_zero = '1' then
                        next_state <= UPDATE;
                    else
                        next_state <= SAMPLING;
                    end if ;

                when UPDATE =>
                    init <= '0';
                    mask_shift <= '0';
                    data_en <= '0';
                    count_en <= '0';
                    final_en <= '1';
                    done <= '1';

                    next_state <= IDLE;

            
                when others =>
                    next_state <= IDLE;
            
            end case ;


        end process comb_fsm;




end fsm;