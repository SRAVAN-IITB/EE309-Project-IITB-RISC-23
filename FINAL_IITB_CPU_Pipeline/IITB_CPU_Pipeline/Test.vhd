library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity Test is
port (clk, reset:in std_logic;
Values :out std_logic_vector(2 downto 0));
end entity Test;

architecture struct of Test is

component d_ff is 
port (D, clk, preset, reset, E:in std_logic;
Q, Qbar:out std_logic);
end component d_ff;

component three_bit_sync_up is
port (clk, reset:in std_logic;
Count:out std_logic_vector(2 downto 0);
CountBar:out std_logic_vector(2 downto 0);
enable: in std_logic);
end component three_bit_sync_up;

signal V:std_logic_vector(2 downto 0);
signal Num, NumBar:std_logic_vector(2 downto 0);

begin

TBSU: three_bit_sync_up port map (clk => clk, reset => reset, Count => Num, CountBar => NumBar, enable => '1');
DFF1: d_ff port map (D => Num(2), clk => clk, preset => '0', reset => reset, E => '1', Q => Values(2), Qbar => V(0));
DFF2: d_ff port map (D => Num(1), clk => clk, preset => '0', reset => reset, E => '1', Q => Values(1), Qbar => V(1));
DFF3: d_ff port map (D => Num(0), clk => clk, preset => '0', reset => reset, E => '1', Q => Values(0), Qbar => V(2));

end struct;