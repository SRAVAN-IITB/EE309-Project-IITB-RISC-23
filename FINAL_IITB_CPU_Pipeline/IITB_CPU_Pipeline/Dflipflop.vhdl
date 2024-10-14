library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity D_FlipFlop is
	port(Clk, Reset, input, enable : in std_logic;
			output : buffer std_logic
		 );
end entity;

architecture arch of D_FlipFlop is
	begin
		proc : process(clk, reset, enable, output)
			begin
				if(reset = '1') then
					output <= '0';
				elsif ((rising_edge(Clk)) and enable = '1') then
					output <= input;
				else
					output <= output;
				end if;
		end process proc;
end arch;