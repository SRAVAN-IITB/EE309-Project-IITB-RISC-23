library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg_16BIT is
	port (reset, clk	: 	in std_logic;
			data_in			:	in std_logic_vector(15 downto 0);
			data_out			: out std_logic_vector(15 downto 0)
			);
end entity Reg_16BIT;

architecture bhv of Reg_16BIT is
	signal reg_store: std_logic_vector(15 downto 0):="0000000000000000";
	begin
		data_out(15 downto 0) <= reg_store(15 downto 0);
		
		clkProc: process(clk, reset, reg_store)
		begin
			if(reset = '1') then
				reg_store(15 downto 0) <= "0000000000000000";
			else
				if(clk='1' and clk'event) then
					reg_store(15 downto 0) <= data_in(15 downto 0);
				else
					reg_store(15 downto 0) <= reg_store(15 downto 0);
				end if;
			end if;
		end process;
		
end architecture bhv;