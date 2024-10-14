library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ALU2 is
	port(A,B: in STD_LOGIC_VECTOR(15 downto 0);
		  C: 	out STD_LOGIC_VECTOR(15 downto 0));
end entity ALU2;

architecture BHV of ALU2 is

	function Add(A, B: in STD_LOGIC_VECTOR(15 downto 0))
		return STD_LOGIC_VECTOR is
		-- declaring and initializing variables using aggregates
		variable carry : STD_LOGIC := '0';
		variable sum : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			begin
				for i in 0 to 15 LOOP
					sum(i) := (A(i) xor B(i)) xor carry;
					carry := ((A(i) and B(i)) or ((A(i) xor B(i)) and carry));
				end LOOP;
		return sum;
	end Add;

	begin
	C <= Add(A,B);

end architecture BHV;