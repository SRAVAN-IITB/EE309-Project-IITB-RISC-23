library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library work;
use work.Gates.all;

entity DataMemory is
	port(Address:in std_logic_vector(15 downto 0);
		  data_write: in std_logic_vector(15 downto 0);
		  data_out: out std_logic_vector(15 downto 0);
		  clock,MeM_W,MeM_R: in std_logic);
end entity DataMemory;

architecture struct of DataMemory is

type array_of_vectors is array (63 downto 0) of std_logic_vector(7 downto 0);
signal memory_storage: array_of_vectors := (0 => "00000000", 
                                            1 => "00000101", 
														  2 => "00000000", 
														  3 => "00000000", 
														  4 => "00000000", 
														  5 => "00000000", 
														  others => "00000000");

begin
memory_write: process(clock, MeM_W, data_write, Address)
    begin
        if(clock' event and clock = '1') then
            if (MeM_W = '1') then
                memory_storage(to_integer(unsigned(Address))) <= data_write(15 downto 8);
					 memory_storage(to_integer(unsigned(Address)) + 1) <= data_write(7 downto 0);
            else 
                null;
            end if;
        else
            null;
        end if;
    end process;

memory_read: process(Address, memory_storage,MeM_R)
    begin
	 if (Mem_R = '1') then
		 if unsigned(Address) < 63 then
            data_out(15 downto 8) <= memory_storage(to_integer(unsigned(Address)));
				data_out(7 downto 0) <= memory_storage(to_integer(unsigned(Address)) + 1);
		 else
            data_out <= (others => '0');
       end if;
	 end if;
end process;

end architecture struct;	