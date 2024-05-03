library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_2 is
    Port ( S : in  STD_LOGIC;
           I : in  STD_LOGIC_VECTOR (1 downto 0);
           Y : out STD_LOGIC);
end MUX_2;

architecture BHV of MUX_2 is
begin
    process (S, I)
    begin
        if S = '0' then
            Y <= I(0);
        else
            Y <= I(1);
        end if;
    end process;
end BHV;