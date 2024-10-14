library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity MUX_8 is 
port (S: in std_logic_vector(2 downto 0);
      A: in std_logic_vector(7 downto 0);
      Y: out std_logic);
end entity MUX_8;

architecture Struct of MUX_8 is 
signal Z: std_logic_vector(3 downto 0);
signal V: std_logic_vector(1 downto 0);

component MUX_2 is 
port (S: in std_logic;
      A: in std_logic_vector(1 downto 0);
      Y: out std_logic);
end component MUX_2;

begin

  -- component instances
MUX1: MUX_2 port map (A => A(7 downto 6), S => S(0), Y => Z(3));
MUX2: MUX_2 port map (A => A(5 downto 4), S => S(0), Y => Z(2));
MUX3: MUX_2 port map (A => A(3 downto 2), S => S(0), Y => Z(1));
MUX4: MUX_2 port map (A => A(1 downto 0), S => S(0), Y => Z(0));
MUX5: MUX_2 port map (A(1) => Z(3), A(0) => Z(2), S => S(1), Y => V(1));
MUX6: MUX_2 port map (A(1) => Z(1), A(0) => Z(0), S => S(1), Y => V(0));
MUX7: MUX_2 port map (A(1) => V(1), A(0) => V(0), S => S(2), Y => Y);

end struct;