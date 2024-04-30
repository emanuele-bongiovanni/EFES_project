library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

package mypackage is

    constant DISTANCE_COUNT             : integer := 200;       --con un periodo di 5 us, dovrebbe essere una lettura ogni 1 ms
    constant LIGHT_COUNT                : integer := 100000;    --con un periodo di 5 us, dovrebbe essere una lettura ogni 500 ms
    constant MOTOR_COUNT                : integer := 200000;    --stabilito per tentativi
    constant NBIT                       : integer := 8;
    constant HIGH_SPEED_THR             : integer := 35;    --luce diretta
    constant MID_SPEED_THR              : integer := 150;   --luce ambientale
    constant LOW_SPEED_THR              : integer := 210;   --ombra
    constant DISTANCE_REQUEST           : integer := 42;
    constant LIGHT_REQUEST              : integer := 84;
    constant PACKET_DIM                 : integer := 8;
    
   

end package mypackage;