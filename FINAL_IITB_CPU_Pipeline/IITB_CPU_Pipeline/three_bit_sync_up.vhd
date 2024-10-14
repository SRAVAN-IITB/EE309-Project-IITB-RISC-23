library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity three_bit_sync_up is
port (clk, reset:in std_logic;
Count:out std_logic_vector(2 downto 0);
CountBar:out std_logic_vector(2 downto 0);
enable: in std_logic);
end entity three_bit_sync_up;

architecture struct of three_bit_sync_up is

component d_ff is 
port (D, clk, preset, reset, E:in std_logic;
Q, Qbar:out std_logic);
end component d_ff;

signal T,V:std_logic_vector(2 downto 0);
signal W:std_logic_vector(2 downto 0);

begin

DFF1: d_ff port map (D => V(0), clk => clk, preset => '0', reset => reset, E => enable, Q => T(0), Qbar => V(0));
XOR1: XOR_2 port map (A => T(0), B => T(1), Y => W(0));
DFF2: d_ff port map (D => W(0), clk => clk, preset => '0', reset => reset, E => enable, Q => T(1), Qbar => V(1));
AND1: AND_2 port map (A => T(0), B => T(1), Y => W(1));
XOR2: XOR_2 port map (A => W(1), B => T(2), Y => W(2));
DFF3: d_ff port map (D => W(2), clk => clk, preset => '0', reset => reset, E => enable, Q => T(2), Qbar => V(2));

Count <= T;
CountBar <= V;

end struct;