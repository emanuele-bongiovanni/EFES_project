library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mypackage.all;

entity SAR_ADC is
    Port (
        clk             : in STD_LOGIC;            
        start           : in STD_LOGIC;          
        comparator      : in STD_LOGIC; 
        to_dac          : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
        digital_out     : out STD_LOGIC_VECTOR(RESOLUTION - 1 downto 0); 
        done            : out STD_LOGIC     
    );
end SAR_ADC;


architecture beh of SAR_ADC is

    type SAR_state is (IDLE, STARTING, EVALUATE, UPDATE, FIN);
    signal curr_state, next_state       : SAR_state;
    signal pos                          : integer;
    signal result                       : std_logic_vector(RESOLUTION -1 downto 0);
    signal mask                         : std_logic_vector(RESOLUTION -1 downto 0);

    begin

        computation_fsm: process(curr_state)
        begin
            next_state <= IDLE;
            case( curr_state ) is

                when IDLE =>

                    next_state <= STARTING;            --per evitare problemi con la durata del segnale di start, questi non è inserito nelle s. list
                                                    --invece, lo stato rimbalza costantemente tra IDLE e START e verifica in quest'ultimo il valore di start
                
                when STARTING =>

                    if (start = '1') then
                        pos <= RESOLUTION - 1; --7
                        result <= (others => '0');
                        mask <= "10000000";
                        next_state <= EVALUATE;
                        done <= '0';                --WARNING: RESETTARE DONE QUI, SIGNIFICA CHE FINCHE' NON VIENE FATTA PARTIRE UNA NUOVA MISURAZIONE, IL SEGNALE SARA' ALTO
                                                    --VERIFICARE CHE SIA IL BEHAVIOUR VOLUTO                        

                    else
                        next_state <= IDLE;
                    end if ;

                when EVALUATE =>

                    if (pos >= 0) then
                        to_dac <= result or mask;                       --al dac viene mandato l'or tra la maschera, contenente un 1 sul valore attuale da comparare, e i valori precedentemente calcolati
                        mask <= '0' & mask(RESOLUTION - 1 downto 1);    --l'1 dell maschera viene shiftato verso destra, per essere pronto per la successiva operazione
                        next_state <= UPDATE;
                    else
                        next_state <= FIN;
                    end if ;

                when UPDATE =>

                    result(pos) <= comparator;          --NB: COMPARATOR DEVE TORNARE 1 SE TO_DAC E' MINORE DEL VALORE, 0 SE E' MAGGIORE
                    pos <= pos - 1;                     --la posizione è decrementata
                    next_state <= EVALUATE;

                when FIN =>

                    done <= '1';
                    digital_out <= result;
                    next_state <= IDLE;

                when others =>

                    next_state <= IDLE;
          
            end case ;

        end process computation_fsm;


        combinational: process(clk)
        begin
            if rising_edge(clk) then
                
                    curr_state <= next_state;

            end if;
        end process combinational;



end beh;