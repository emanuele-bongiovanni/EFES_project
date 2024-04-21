library ieee;
use ieee.std_logic_1164.all;


entity DE1 is
    port (
         -- CLOCK
         CLOCK_50  : in std_logic;
         CLOCK2_50 : in std_logic;
         CLOCK3_50 : in std_logic;
         CLOCK4_50 : in std_logic;
 
 
         -- SEG7
         HEX0_N : out std_logic_vector(6 downto 0);
         HEX1_N : out std_logic_vector(6 downto 0);
         HEX2_N : out std_logic_vector(6 downto 0);
         HEX3_N : out std_logic_vector(6 downto 0);
         HEX4_N : out std_logic_vector(6 downto 0);
         HEX5_N : out std_logic_vector(6 downto 0);
 
         -- IR
         IRDA_RXD : in  std_logic;
         IRDA_TXD : out std_logic;
 
         -- KEY_N
         KEY_N : in std_logic_vector(3 downto 0);
 
         -- LED
         LEDR : out std_logic_vector(9 downto 0);
 
         -- PS2
         PS2_CLK  : inout std_logic;
         PS2_CLK2 : inout std_logic;
         PS2_DAT  : inout std_logic;
         PS2_DAT2 : inout std_logic;
 
         -- SW
         SW : in std_logic_vector(9 downto 0);
 
         -- Video-In
         TD_CLK27   : inout std_logic;
         TD_DATA    : out   std_logic_vector(7 downto 0);
         TD_HS      : out   std_logic;
         TD_RESET_N : out   std_logic;
         TD_VS      : out   std_logic;
 
         -- VGA
         VGA_B       : out std_logic_vector(7 downto 0);
         VGA_BLANK_N : out std_logic;
         VGA_CLK     : out std_logic;
         VGA_G       : out std_logic_vector(7 downto 0);
         VGA_HS      : out std_logic;
         VGA_R       : out std_logic_vector(7 downto 0);
         VGA_SYNC_N  : out std_logic;
         VGA_VS      : out std_logic;
 
         -- GPIO_0
         GPIO_0 : inout std_logic_vector(35 downto 0);
 
         -- GPIO_1
         GPIO_1 : inout std_logic_vector(35 downto 0)
    );
end DE1;