library ieee;
use ieee.std_logic_1164.all;

--NOTA: CPHA = 1, CPOL = 0

entity spi_interface is
    port (
            --lato master
        clk         : in std_logic;
        mosi        : in std_logic;
        miso        : out std_logic;
        sel         : in std_logic;   --non è detto che serva 
            --lato-periferica
        data_in     : in std_logic_vector(7 downto 0);
        data_out    : out std_logic_vector(7 downto 0);
    );
end spi_interface;

architecture beh of spi_interface is
    
    type state_type is (idle, transfer, finish);
    signal curr_state, next_state       : state_type;
    signal transfer_reg                 : std_logic_vector(7 downto 0);
    signal data_in_reg                  : std_logic_vector(7 downto 0);
    signal data_out_reg                 : std_logic_vector(7 downto 0);
    signal start                        : std_logic;
    signal transfer_init                : std_logic;
    signal count                        : std_logic_vector(2 downto 0);
    


    begin

        comb: process (clk)
        begin
            if rising_edge(clk) then
                curr_state <= next_state;
                data_out <= data_out_reg;
                data_in_reg <= data_in;
            end if;

        end process comb;

        seq: process (curr_state)
        begin
            case curr_state is
                when idle =>
                    if sel = '0' then
                        next_state <= transfer;
                        transfer_reg <= data_in_reg;
                        count <= "000";
                    else
                        next_state <= idle;
                    end if;
                    
                when transfer =>
                    count <= std_logic_vector(unsigned(count) + 1);
                    if count = "111" then
                        next_state <= finish;
                        transfer_init <= '0';
                    else
                        next_state <= transfer;
                        transfer_init <= '1';
                    end if;
                    
                when finish =>
                    next_state <= idle;
                    data_out_reg <= transfer_reg;

                    
            end case;
        end process seq;

        transfer: process (clk)
        begin
            if rising_edge(clk) then
                if transfer_init = '1' then
                    miso <= transfer_reg(7);
                    transfer_reg <= transfer_reg(6 downto 0) & mosi;                
                end if;
            end if;
        end process transfer;

end beh;