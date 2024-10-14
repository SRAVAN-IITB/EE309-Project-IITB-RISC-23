library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ALU1 is
	port(A,B: in STD_LOGIC_VECTOR(15 downto 0);
	     Oper:in STD_LOGIC_VECTOR(3 downto 0);
		  Z: 	out STD_LOGIC;
		  R: out STD_LOGIC;
		  C: 	out STD_LOGIC_VECTOR(15 downto 0));
end entity ALU1;

architecture BHV of ALU1 is
	signal DATA1_temp: STD_LOGIC_VECTOR(15 downto 0);
	Signal R1: STD_LOGIC;

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

	function sub(A, B: in STD_LOGIC_VECTOR(15 downto 0))
		return STD_LOGIC_VECTOR is
		-- declaring and initializing variables using aggregates
		variable borrow : STD_LOGIC := '0';
		variable diff : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			begin
				for i in 0 to 15 LOOP
					diff(i) := (A(i) xor B(i)) xor borrow;
					borrow := ((not A(i)) and B(i)) or (((not A(i)) or B(i)) and borrow);
				end LOOP;
		return diff;
	end sub;

	function bit_NAND(A, B: in STD_LOGIC_VECTOR(15 downto 0))
		return STD_LOGIC_VECTOR is
		-- declaring and initializing variables using aggregates
		variable bit_NAND1 : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	begin
		for i in 0 to 15 LOOP
			bit_NAND1(i) := not (A(i) and B(i));
		end LOOP;
		return bit_NAND1;
	end bit_NAND;
	
  function subCARRY(A, B: in STD_LOGIC_VECTOR(15 downto 0))
		return STD_LOGIC is
		-- declaring and initializing variables using aggregates
		variable borrow : STD_LOGIC := '0';
		variable diff : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			begin
				for i in 0 to 15 LOOP
					diff(i) := (A(i) xor B(i)) xor borrow;
					borrow := ((not A(i)) and B(i)) or (((not A(i)) or B(i)) and borrow);
				end LOOP;
		return borrow;
	end subCARRY;

	begin
	Decide_Oper: process(Oper, DATA1_temp, A, B)
begin
    case Oper is
        when "1100" =>
            DATA1_temp <= Add(A, B);
				R1 <= '0';
        when "1101" => 
            DATA1_temp <= Add(A, B);
				R1 <= '0';
        when "1000" => 
            DATA1_temp <= sub(A, B);
				R1 <= subCARRY(A,B);
        when "1001" => 
            DATA1_temp <= sub(A, B);
				R1 <= subCARRY(A,B);
        when "1010" => 
            DATA1_temp <= sub(A, B);
				R1 <= subCARRY(A,B);
        when "0010" => 
            DATA1_temp <= bit_NAND(A, B);
				R1 <= '0';
        when others => 
            -- Adding a default assignment to avoid latches
            DATA1_temp <= (others => '0');
				R1 <= '0';
    end case;
end process Decide_Oper;
	Z <= NOT(data1_temp(0) OR data1_temp(1) OR data1_temp(2) OR data1_temp(3) 
			OR data1_temp(4) OR data1_temp(5) OR data1_temp(6) OR data1_temp(7) 
			OR data1_temp(8) OR data1_temp(9) OR data1_temp(10) OR data1_temp(11) 
			OR data1_temp(12) OR data1_temp(13) OR data1_temp(14) OR data1_temp(15));
	c <= DATA1_temp;
	R <= R1;

end architecture BHV;