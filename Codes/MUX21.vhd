library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity MUX_2 is 
port (S: in std_logic;
      A: in std_logic_vector(1 downto 0);
      Y: out std_logic);
end entity MUX_2;

architecture Struct of MUX_2 is 
signal Sc, Z0, Z1 : std_logic;
begin
  -- component instances
  NOT1: INVERTER port map (A => S, Y => Sc);
  AND1: AND_2 port map (A => Sc, B => A(0), Y => Z0);
  AND2: AND_2 port map (A => S, B => A(1), Y => Z1);
  OR1: OR_2 port map (A => Z1, B => Z0, Y => Y);
  end Struct;