library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ALU3 is
	port(A,B: in STD_LOGIC_VECTOR(15 downto 0);
	     C:   in STD_LOGIC;
		  Z,R: out STD_LOGIC;
		  D: 	out STD_LOGIC_VECTOR(15 downto 0));
end entity ALU3;

architecture BHV of ALU3 is
	signal DATA1_temp, T: STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
	signal R1,R2: STD_LOGIC;

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
	
	function AddCarry(A, B: in STD_LOGIC_VECTOR(15 downto 0))
		return STD_LOGIC is
		-- declaring and initializing variables using aggregates
		variable carry : STD_LOGIC := '0';
		variable sum : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			begin
				for i in 0 to 15 LOOP
					sum(i) := (A(i) xor B(i)) xor carry;
					carry := ((A(i) and B(i)) or ((A(i) xor B(i)) and carry));
				end LOOP;
		return carry;
	end AddCarry;

	begin
	
	T <= Add(A,B);
	R1 <= AddCarry(A,B);
	
	Decide_Carry: process(DATA1_temp, T, A, B, C, R1)
	begin
		 case C is
			  when '1' => 
					DATA1_temp <= Add(T, "0000000000000001");
					R2 <= R1 OR Addcarry(T, "0000000000000001");
			  when '0' => 
					DATA1_temp <= T;
			      R2 <= R1;		
			  when others => 
					-- Adding a default assignment to avoid latches
					DATA1_temp <= (others => '0');
		 end case;
	end process Decide_Carry;
	D <= DATA1_temp;
	R <= R2;
	
	Z <= NOT(data1_temp(0) OR data1_temp(1) OR data1_temp(2) OR data1_temp(3) 
			OR data1_temp(4) OR data1_temp(5) OR data1_temp(6) OR data1_temp(7) 
			OR data1_temp(8) OR data1_temp(9) OR data1_temp(10) OR data1_temp(11) 
			OR data1_temp(12) OR data1_temp(13) OR data1_temp(14) OR data1_temp(15));

end architecture BHV;