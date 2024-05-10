library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Reg_File is
	port(Address_Read1, Address_Read2, Address_Write: in std_logic_vector(2 downto 0);
			data_Write 							  				: in std_logic_vector(15 downto 0);
			PC_data_input							  			: in std_logic_vector(15 downto 0);
			PC_data_output 							  		: out std_logic_vector(15 downto 0);
			Clk, Reset 							  				: in std_logic;
			RF_Write                                  : in std_logic;
			PC_Write                                  : in std_logic;
			data_Read1, data_Read2		               : out std_logic_vector(15 downto 0)
		 );
end entity;

architecture BHV of Reg_File is
	signal R0, R3, R4, R5, R6, R7 : std_logic_vector(15 downto 0) := "0000000000000000";
	signal R1, R2 : std_logic_vector(15 downto 0) := "0000000000000000";
	signal data_Read1_temp, data_Read2_temp : std_logic_vector(15 downto 0) := "1111111111111111";

	begin
	--writing to register
    write_proc: PROCESS(data_Write, Address_Write, Reset, R0, R1, R2, R3, R4, R5, R6, R7, clk)
    begin
	   if(Reset = '1') then 
            R0 <= "0000000000000000";
            R1 <= "1000000000000010";
            R2 <= "1000000000000010";
            R3 <= "0000000000000000";
            R4 <= "0000000000000000";
            R5 <= "0000000000000000";
            R6 <= "0000000000000000";
            R7 <= "0000000000000000";
       else
			if(clk' event and clk = '1') then
			
			   if(PC_Write = '1') then
			      R0 <= PC_data_input;
			   end if;
				
				if(RF_Write = '1') then
				case(Address_Write) is
				  when "001" => -- Feed Register_1
					R1 <= data_Write;
				  when "010" => -- Feed Register_2
					R2 <= data_Write;
				  when "011" => -- Feed Register_3
					R3 <= data_Write;
				  when "100" => -- Feed Register_4
					R4 <= data_Write;
				  when "101" => -- Feed Register_5
					R5 <= data_Write;
				  when "110" => -- Feed Register_6
					R6 <= data_Write;
				  when "111" => -- Feed Register_7
					R7 <= data_Write;
				  when others =>
					NULL; -- Do nothing
				end case;
				end if;
			end if;
		end if;
	end PROCESS write_proc;
	
		  PC_data_output <= R0;
	 
	--reading from the registers
	READ_Address_Read1 : PROCESS(Address_Read1, data_Read1_temp, R0, R1, R2, R3, R4, R5, R6, R7)
	 begin
	  case(Address_Read1) is
	  	when "000" => -- Retrieve from Register_0
			data_Read1_temp <= R0;
		when "001" => -- Retrieve from Register_1
			data_Read1_temp <= R1;
		when "010" => -- Retrieve from Register_2
			data_Read1_temp <= R2;
		when "011" => -- Retrieve from Register_3
			data_Read1_temp <= R3;
		when "100" => -- Retrieve from Register_4
			data_Read1_temp <= R4;
		when "101" => -- Retrieve from Register_5
			data_Read1_temp <= R5;
		when "110" => -- Retrieve from Register_6
			data_Read1_temp <= R6;
		when "111" => -- Retrieve from Register_7
			data_Read1_temp <= R7;
		when others =>
			NULL; -- Do nothing
	  end case;
	 end PROCESS;
	data_Read1 <= data_Read1_temp; -- data_Read1 out
	 
	READ_Address_Read2 : PROCESS(Address_Read2, data_Read2_temp, R0, R1, R2, R3, R4, R5, R6, R7)
	 begin
	  case(Address_Read2) is
		when "000" => -- Retrieve from Register_0
			data_Read2_temp <= R0;
		when "001" => -- Retrieve from Register_1
			data_Read2_temp <= R1;
		when "010" => -- Retrieve from Register_2
			data_Read2_temp <= R2;
		when "011" => -- Retrieve from Register_3
			data_Read2_temp <= R3;
		when "100" => -- Retrieve from Register_4
			data_Read2_temp <= R4;
		when "101" => -- Retrieve from Register_5
			data_Read2_temp <= R5;
		when "110" => -- Retrieve from Register_6
			data_Read2_temp <= R6;
		when "111" => -- Retrieve from Register_7
			data_Read2_temp <= R7;
		when others =>
			NULL; -- Do nothing
	  end case;
	 end PROCESS;
	data_Read2 <= data_Read2_temp; -- data_Read2 out
		 
end BHV;