library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity jk_ff is
port (J, K, clk, preset, reset, E:in std_logic;
Q, Qbar:out std_logic);
end entity jk_ff;

architecture struct of jk_ff is
signal inter:std_logic:='0';
signal Jk: std_logic_vector(1 downto 0);
begin
Jk(1) <= J;
Jk(0) <= K;
jkprocess: process (J,K,inter,Jk(1 downto 0),clk, preset, reset, E)

begin

if E = '1' then

if(preset='1')then
inter <= '1';
elsif (reset='1')then
inter <= '0';
elsif (clk'event and (clk='1')) then

if (Jk = "00") then
inter <= inter;
elsif (Jk = "01") then
inter <= '0';
elsif (Jk = "10") then
inter <= '1';
else
inter <= not inter;
end if;

end if;

elsif E = '0' then
inter <= inter;
end if;

end process jkprocess;

Q <= inter;
Qbar <= not inter;

end struct;