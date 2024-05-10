library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity d_ff is
port (D, clk, preset, reset, E:in std_logic;
Q, Qbar:out std_logic);
end entity d_ff;

architecture struct of d_ff is

component jk_ff is 
port (J, K, clk, preset, reset, E:in std_logic;
Q, Qbar:out std_logic);
end component jk_ff;

signal inter:std_logic;

begin

invert: INVERTER port map (A => D, Y => inter);
JKFF1: jk_ff port map (J => D, K => inter, clk => clk, preset => preset, reset => reset, E => E, Q => Q, Qbar => Qbar);

end struct;