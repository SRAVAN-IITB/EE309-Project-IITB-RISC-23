library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity MUX_4 is 
port (S: in std_logic_vector(1 downto 0);
      A: in std_logic_vector(3 downto 0);
      Y: out std_logic);
end entity MUX_4;

architecture Struct of MUX_4 is 
signal Z: std_logic_vector(1 downto 0);

component MUX_2 is 
port (S: in std_logic;
      A: in std_logic_vector(1 downto 0);
      Y: out std_logic);
end component MUX_2;

begin
  -- component instances
MUX1: MUX_2 port map (A => A(3 downto 2), S => S(0), Y => Z(1));
MUX2: MUX_2 port map (A => A(1 downto 0), S => S(0), Y => Z(0));
MUX3: MUX_2 port map (A(1) => Z(1), A(0) => Z(0), S => S(1), Y => Y);
end struct;