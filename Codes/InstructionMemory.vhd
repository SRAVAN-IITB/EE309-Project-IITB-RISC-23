library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library work;
use work.Gates.all;

entity InstructionMemory is
	port(Address:in std_logic_vector(15 downto 0);
		  data_out: out std_logic_vector(15 downto 0));
end entity InstructionMemory;

architecture struct of InstructionMemory is

type array_of_vectors is array (255 downto 0) of std_logic_vector(7 downto 0);
signal memory_storage: array_of_vectors := (0 => "11100000",
														  2 => "00010010", 
                                            3 => "10001000", 
														  4 => "00100010",	 
														  5 => "10001110", 
														  6 => "00110110", 
														  7 => "00000111", 
														  8 => "01000111",
														  9 => "11000000",
														  others => "00000000");

begin

memory_read: process(Address, memory_storage)
    begin
		if unsigned(Address) < 256 then
            data_out(15 downto 8) <= memory_storage(to_integer(unsigned(Address)));
				data_out(7 downto 0) <= memory_storage(to_integer(unsigned(Address)) + 1);
		 else
            data_out <= (others => '0');
       end if;
end process;

end architecture struct;	