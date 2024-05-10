library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity IITB_CPU_Pipeline is
	port(Clk, Reset : in std_logic);
end entity;

Architecture arc of IITB_CPU_Pipeline is

component ALU1 is
	port(A,B: in STD_LOGIC_VECTOR(15 downto 0);
	     Oper:in STD_LOGIC_VECTOR(3 downto 0);
		  Z: 	out STD_LOGIC;
		  C: 	out STD_LOGIC_VECTOR(15 downto 0));
end component ALU1;

component ALU2 is
	port(A,B: in STD_LOGIC_VECTOR(15 downto 0);
		  C: 	out STD_LOGIC_VECTOR(15 downto 0));
end component ALU2;

component ALU3 is
	port(A,B: in STD_LOGIC_VECTOR(15 downto 0);
	     C:   in STD_LOGIC;
		  Z,R: out STD_LOGIC;
		  D: 	out STD_LOGIC_VECTOR(15 downto 0));
end component ALU3;

component Register128bit is
	port(Clk, Reset : in std_logic;
			data_in : in std_logic_vector(127 downto 0);
			Stallbar: in std_logic;
			data_out : out std_logic_vector(127 downto 0);
			valid_bit : out std_logic
		 );
end component;

component Reg_File is
	port(Address_Read1, Address_Read2, Address_Write: in std_logic_vector(2 downto 0);
			data_Write 							  				: in std_logic_vector(15 downto 0);
			PC_data_input							  			: in std_logic_vector(15 downto 0);
			PC_data_output 							  		: out std_logic_vector(15 downto 0);
			Clk, Reset 							  				: in std_logic;
			RF_Write                                  : in std_logic;
			PC_Write                                  : in std_logic;
			data_Read1, data_Read2		               : out std_logic_vector(15 downto 0)
		 );
end component;

component three_bit_sync_up is
port (clk, reset:in std_logic;
Count:out std_logic_vector(2 downto 0);
CountBar:out std_logic_vector(2 downto 0);
enable: in std_logic);
end component three_bit_sync_up;

component InstructionMemory is
	port(Address:in std_logic_vector(15 downto 0);
		  data_out: out std_logic_vector(15 downto 0));
end component InstructionMemory;

component DataMemory is
	port(Address:in std_logic_vector(15 downto 0);
		  data_write: in std_logic_vector(15 downto 0);
		  data_out: out std_logic_vector(15 downto 0);
		  clock,MeM_W,MeM_R: in std_logic);
end component DataMemory;

component D_FlipFlop is
	port(Clk, Reset, input, enable : in std_logic;
			output : out std_logic
		 );
end component;


component Reg_16BIT is
	port (reset, clk	: 	in std_logic;
			data_in			:	in std_logic_vector(15 downto 0);
			data_out			: out std_logic_vector(15 downto 0)
			);
end component Reg_16BIT;


signal MUX1, current_PC, ALU2_D, Instruction_Word, current_PC_PRO1, Instruction_Word_PRO1, current_PC_PRO2, RA_RF_data, RB_RF_data: std_logic_vector(15 downto 0):= (others => '0');
signal MUX2, Destination_PRO3, Destination_PRO4, Destination_PRO5, Counter_Output, Counter_Complement_Output, MUX16:std_logic_vector(2 downto 0):= (others => '0');
signal Operation_Code, MUX10:std_logic_vector(3 downto 0):= (others => '0');
signal Instruction_Word_PRO2, MUX3, MUX4, MUX5, Immediate_PRO3, Current_PC_PRO3, RA_PRO3, RB_PRO3, MUX6, MUX7:std_logic_vector(15 downto 0):= (others => '0');
signal ALU3_D, MUX9, ALU1_D, MUX13, MUX14, Current_PC_PRO4, Register_Content_PRO4, Executed_Result_ALU_D_PRO4:std_logic_vector(15 downto 0):= (others => '0');
signal Mem_ALU_D, Executed_Result_ALU_D_PRO5, MUX15, Mem_ALU_D_PRO5, MUX17, Temporary_Address, MUX18, MUX11:std_logic_vector(15 downto 0):= (others => '0');
signal CZ:std_logic_vector(1 downto 0):= (others => '0');

signal ResetLogic1, valid_bit_PRO1, ResetLogic2, valid_bit_PRO2,  ResetLogic3, valid_bit_PRO3: std_logic:= '0';
signal CS_IsDestination, CS_IsDestination_PRO2, CS_IsDestination_PRO3, MUX8, ALU3_Z, ALU1_Z, ALU3_R, MUX12, CCR_R, CCR_Z: std_logic:= '0';
signal ResetLogic4, valid_bit_PRO4, CS_IsDestination_PRO4, ResetLogic5, valid_bit_PRO5, CS_IsDestination_PRO5:std_logic:= '0';
signal CS_MeM_R, CS_MeM_W, CS_MeM_R_PRO2, CS_MeM_W_PRO2, CS_MeM_R_PRO3, CS_MeM_W_PRO3, CS_MeM_R_PRO4, CS_MeM_W_PRO4: std_logic:= '0';
signal CS_RF_Write, CS_RF_Write_PRO2, CS_RF_Write_PRO3, CS_RF_Write_PRO4, CS_RF_Write_PRO5: std_logic:='0';
signal Stall_Logic1,Stall_Logic2,Stall_Logic3,Stall_Logic4,Stall_Logic5: std_logic:= '1';
signal CS_Load_Forwarded,CS_Load_Forwarded_PRO2,CS_Load_Forwarded_PRO3,CS_Load_Forwarded_PRO4,CS_Load_Forwarded_PRO5: std_logic:= '0';
signal Complement, MUX19, Counter_Enabling_Logic: std_logic:= '0';

signal Clean_Up_Signal: std_logic_vector(397 downto 0):= (others => '0');

begin 

RF: Reg_File port map (Clk => Clk,
                       Reset => Reset,
                       PC_data_input => MUX1,
                       PC_data_output => current_PC,
							  Address_Read1 => Instruction_Word_PRO2(11 downto 9),
							  Address_Read2 => MUX16,
							  Address_Write => Destination_PRO5,
							  data_Write => MUX15,
							  RF_Write => CS_RF_Write_PRO5,
							  PC_Write => '1',
							  data_Read1 => RA_RF_data,
							  data_Read2 => RB_RF_data);
							  
PCALU: ALU2 port map (A => current_PC,
                      B => "0000000000000010",
							 C => ALU2_D);
							 
I_MEM: InstructionMemory port map (Address => current_PC,
                                   data_out => Instruction_Word);
											 
PRO1: Register128bit port map (Clk => Clk,
                               Reset => ResetLogic1,
										 Stallbar => Stall_Logic1,
										 data_in(15 downto 0) => Instruction_Word,
										 data_in(31 downto 16) => Current_PC,
										 data_in(127 downto 32) => (others => '0'),
										 data_out(15 downto 0) => Instruction_Word_PRO1,
										 data_out(31 downto 16) => Current_PC_PRO1,
										 data_out(127 downto 32) => Clean_Up_Signal(95 downto 0),
										 valid_bit => valid_bit_PRO1);
										 
PRO2: Register128bit port map (Clk => Clk,
                               Reset => ResetLogic2,
										 Stallbar => Stall_Logic2,
										 data_in(15 downto 0) => Instruction_Word_PRO1,
										 data_in(31 downto 16) => Current_PC_PRO1,
										 data_in(32) => CS_MeM_R,
										 data_in(33) => CS_MeM_W,
										 data_in(34) => CS_RF_Write,
										 data_in(35) => CS_Load_Forwarded,
										 data_in(36) => CS_IsDestination,
										 data_in(127 downto 37) =>  (others => '0'),
										 data_out(15 downto 0) => Instruction_Word_PRO2,
										 data_out(31 downto 16) => Current_PC_PRO2,
										 data_out(32) => CS_MeM_R_PRO2,
										 data_out(33) => CS_MeM_W_PRO2,
										 data_out(34) => CS_RF_Write_PRO2,
										 data_out(35) => CS_Load_Forwarded_PRO2,
										 data_out(36) => CS_IsDestination_PRO2,
										 data_out(127 downto 37) =>Clean_Up_Signal(186 downto 96),
										 valid_bit => valid_bit_PRO2);

PRO3: Register128bit port map (Clk => Clk,
                               Reset => ResetLogic3,
										 Stallbar => Stall_Logic3,
										 data_in(15 downto 0) => MUX5,
										 data_in(31 downto 16) => Current_PC_PRO2,
										 data_in(35 downto 32) => Instruction_Word_PRO2(15 downto 12),
										 data_in(38 downto 36) => MUX2,
										 data_in(39) => CS_IsDestination_PRO2,
										 data_in(55 downto 40) => MUX3,
										 data_in(71 downto 56) => MUX4,
										 data_in(72) => CS_MeM_R_PRO2,
										 data_in(73) => CS_MeM_W_PRO2,
										 data_in(74) => CS_RF_Write_PRO2,
										 data_in(75) => CS_Load_Forwarded_PRO2,
										 data_in(76) => Instruction_Word_PRO2(2),
										 data_in(78 downto 77) => Instruction_Word_PRO2(1 downto 0),
										 data_in(127 downto 79) => (others => '0'),
										 data_out(15 downto 0) => Immediate_PRO3,
										 data_out(31 downto 16) => Current_PC_PRO3,
										 data_out(35 downto 32) => Operation_Code,
										 data_out(38 downto 36) => Destination_PRO3,
										 data_out(39) => CS_IsDestination_PRO3,
										 data_out(55 downto 40) => RA_PRO3,
										 data_out(71 downto 56) => RB_PRO3,
										 data_out(72) => CS_MeM_R_PRO3,
										 data_out(73) => CS_MeM_W_PRO3,
										 data_out(74) => CS_RF_Write_PRO3,
										 data_out(75) => CS_Load_Forwarded_PRO3,
										 data_out(76) => Complement,
										 data_out(78 downto 77) => CZ,
										 data_out(127 downto 79) =>  Clean_Up_Signal(235 downto 187),
										 valid_bit => valid_bit_PRO3);
										 
three_input_ALU : ALU3 port map (A => MUX6,
                                 B => MUX7,
											C => MUX8,
											Z => ALU3_Z,
											R => ALU3_R,
											D => ALU3_D);
											
two_input_ALU : ALU1 port map  (A => MUX18,
                                B => MUX9,
										  Oper => Operation_Code,
										  Z => ALU1_Z,
										  C => ALU1_D);

CCR_R_store: D_FlipFlop port map (Clk => Clk,
                                  Reset => Reset,
	                               input => ALU3_R,
	                               enable => Stall_Logic4,
	                               output => CCR_R);
	
CCR_Z_store: D_FlipFlop port map (Clk => Clk,
                                  Reset => Reset,
	                               input => MUX12,
	                               enable => Stall_Logic4,
	                               output => CCR_Z);	
											 
PRO4: Register128bit port map (Clk => Clk,
                               Reset => ResetLogic4,
										 Stallbar => Stall_Logic4,
										 data_in(15 downto 0) => MUX13,
										 data_in(31 downto 16) => Current_PC_PRO3,
										 data_in(34 downto 32) => Destination_PRO3,
										 data_in(35) => CS_IsDestination_PRO3,
										 data_in(51 downto 36) => MUX14,
										 data_in(52) => CS_MeM_R_PRO3,
										 data_in(53) => CS_MeM_W_PRO3,
										 data_in(54) => CS_RF_Write_PRO3,
										 data_in(55) => CS_Load_Forwarded_PRO3,
										 data_in(127 downto 56) =>  (others => '0'),
										 data_out(15 downto 0) => Executed_Result_ALU_D_PRO4,
										 data_out(31 downto 16) => Current_PC_PRO4,
										 data_out(34 downto 32) => Destination_PRO4,
										 data_out(35) => CS_IsDestination_PRO4,
										 data_out(51 downto 36) => Register_Content_PRO4,
										 data_out(52) => CS_MeM_R_PRO4,
										 data_out(53) => CS_MeM_W_PRO4,
										 data_out(54) => CS_RF_Write_PRO4,
										 data_out(55) => CS_Load_Forwarded_PRO4,
										 data_out(127 downto 56) => Clean_Up_Signal(307 downto 236),
										 valid_bit => valid_bit_PRO4);
										 
D_MEM: DataMemory port map (clock => Clk,
                            Address => Executed_Result_ALU_D_PRO4,
									 data_Write => Register_Content_PRO4,
                            data_out => Mem_ALU_D,
									 MEM_R => CS_MeM_R_PRO4,
									 MEM_W => CS_MeM_W_PRO4);
									 
PRO5: Register128bit port map (Clk => Clk,
                               Reset => ResetLogic5,
										 Stallbar => Stall_Logic5,
										 data_in(15 downto 0) => Executed_Result_ALU_D_PRO4,
										 data_in(31 downto 16) => Mem_ALU_D,
										 data_in(34 downto 32) => Destination_PRO4,
										 data_in(35) => CS_IsDestination_PRO4,
										 data_in(36) => CS_RF_Write_PRO4,
										 data_in(37) => CS_Load_Forwarded_PRO4,
										 data_in(127 downto 38) => (others => '0'),
										 data_out(15 downto 0) => Executed_Result_ALU_D_PRO5,
										 data_out(31 downto 16) => Mem_ALU_D_PRO5,
										 data_out(34 downto 32) => Destination_PRO5,
										 data_out(35) => CS_IsDestination_PRO5,
										 data_out(36) => CS_RF_Write_PRO5,
										 data_out(37) => CS_Load_Forwarded_PRO5,
										 data_out(127 downto 38) =>  Clean_Up_Signal(397 downto 308),
										 valid_bit => valid_bit_PRO5);
										 
Three_bit_UP_COUNTER: three_bit_sync_up port map (ClK => ClK,
																  Reset => Reset,
																  enable => Counter_Enabling_Logic,
																  Count => Counter_Output,
																  CountBar => Counter_Complement_Output);
																	 
Temporary_Address_Register: Reg_16BIT port map (clk => Clk,
                                                Reset => Reset,
												            data_in => MUX17,
												            data_out => Temporary_Address);
											 
Choose_PC: process (Operation_Code, CS_IsDestination_PRO3, Destination_PRO3, ALU3_R, MUX12, ALU2_D, ALU3_D, Current_PC_PRO2, 
                    CS_Load_Forwarded_PRO3, Destination_PRO4, CS_IsDestination_PRO4, CS_Load_Forwarded_PRO4)
    begin
	 if ((Destination_PRO3 = "000" AND CS_IsDestination_PRO3 = '1' AND CS_Load_Forwarded_PRO3 = '0') OR (Operation_Code = "1000" AND MUX12 = '1') 
	      OR (Operation_Code = "1001" AND ALU3_R = '1') OR (Operation_Code = "1010" AND  (ALU3_R OR MUX12) = '1') OR
			Operation_Code = "1100" OR Operation_Code = "1101" OR Operation_Code = "1111") then
				
				MUX1 <= ALU3_D;

	 elsif ((Destination_PRO4 = "000" AND CS_IsDestination_PRO4 = '1' AND CS_Load_Forwarded_PRO4 = '1')) then
	 
	         MUX1 <= Mem_ALU_D;
				
	 else
	         MUX1 <= ALU2_D;
	 end if;
    end process Choose_PC;

-- 

Instruction_Word_Selector: process(Counter_Output, Instruction_Word_PRO1, MUX19, Current_PC)
	begin
	
	if(Counter_Output = "000") then
		MUX19 <= Instruction_Word_PRO1(7);
		
	elsif(Counter_Output = "001") then 
	MUX19 <= Instruction_Word_PRO1(6);
		
	elsif(Counter_Output = "010") then 
	MUX19 <= Instruction_Word_PRO1(5);
	
		elsif(Counter_Output = "011") then 
	MUX19 <= Instruction_Word_PRO1(4);
	
		elsif(Counter_Output = "100") then 
	MUX19 <= Instruction_Word_PRO1(3);
	
		elsif(Counter_Output = "101") then 
	MUX19 <= Instruction_Word_PRO1(2);
	
		elsif(Counter_Output = "110") then 
	MUX19 <= Instruction_Word_PRO1(1);
	
		else 
	MUX19 <= Instruction_Word_PRO1(0);
	
	end if;
	end process Instruction_Word_Selector;
	 
Control_Signals_Generator: process(Instruction_Word_PRO1, MUX19, Current_PC)
    begin
	 
	 CS_RF_Write <= '0';
	 CS_MeM_R <= '0';
	 CS_MeM_W <= '0';	 
	 CS_Load_Forwarded <= '0';
	 CS_IsDestination <= '0';

	 if ((Instruction_Word_PRO1(15 downto 12) = "0000") or
		  (Instruction_Word_PRO1(15 downto 12) = "0001") or
		  (Instruction_Word_PRO1(15 downto 12) = "0010") or 
		  (Instruction_Word_PRO1(15 downto 12) = "0011") or
		  (Instruction_Word_PRO1(15 downto 12) = "1100") or
		  (Instruction_Word_PRO1(15 downto 12) = "1101")) then
		  
		  CS_RF_Write <= '1';
		  CS_IsDestination <= '1';
		  
	 elsif ((Instruction_Word_PRO1(15 downto 12) = "0100")) then
	 
				 CS_RF_Write <= '1';
				 CS_MeM_R <= '1';
				 CS_MeM_W <= '0';	 
				 CS_Load_Forwarded <= '1';
				 CS_IsDestination <= '1';
		
	 elsif ((Instruction_Word_PRO1(15 downto 12) = "0110")) then
	 
				CS_RF_Write <= MUX19;
				CS_MeM_R <= '1';
				CS_MeM_W <= '0';	 
				CS_Load_Forwarded <= '1';
				CS_IsDestination <= MUX19;
				
		
	elsif ((Instruction_Word_PRO1(15 downto 12) = "0101")) then
				 CS_RF_Write <='0';
				 CS_MeM_R <= '0';
				 CS_MeM_W <= '1';	 
				 CS_Load_Forwarded <= '0';
				 CS_IsDestination <= '0'; 

	elsif ((Instruction_Word_PRO1(15 downto 12) = "0111")) then
				 CS_RF_Write <='0';
				 CS_MeM_R <= '0';
				 CS_MeM_W <= MUX19;	 
				 CS_Load_Forwarded <= '0';
			    CS_IsDestination <= '0';	 
	
	else
				 CS_RF_Write <='0';
				 CS_MeM_R <= '0';
				 CS_MeM_W <= '0';	 
				 CS_Load_Forwarded <= '0';
				 CS_IsDestination <= '0'; 
	
	 end if;
	 end process Control_Signals_Generator;

Decide_Destination: process(Destination_PRO3, Instruction_Word_PRO2, Current_PC_PRO2, Counter_Complement_Output)
    begin
	 if ((Instruction_Word_PRO2(15 downto 12) = "0001") OR 
	     (Instruction_Word_PRO2(15 downto 12) = "0010")) then
		  
		MUX2 <= Instruction_Word_PRO2(5 downto 3);
		
	 elsif ((Instruction_Word_PRO2(15 downto 12) = "0000")) then
	
		MUX2 <= Instruction_Word_PRO2(8 downto 6);	
		
	 elsif ((Instruction_Word_PRO2(15 downto 12) = "0011") OR
	        (Instruction_Word_PRO2(15 downto 12) = "0100") OR
			  (Instruction_Word_PRO2(15 downto 12) = "1100") OR
			  (Instruction_Word_PRO2(15 downto 12) = "1101")) then
	
		MUX2 <= Instruction_Word_PRO2(11 downto 9);
		
	 elsif (Instruction_Word_PRO2(15 downto 12) = "0110") then
			  
		MUX2 <= Counter_Complement_Output;
		
	else
	
	   MUX2 <= "000";
		
	end if;
	end process Decide_Destination;

RA_Forwarding: process(Instruction_Word_PRO2, Destination_PRO3, Destination_PRO4, Destination_PRO5, MUX13, RA_RF_Data, Mem_ALU_D_PRO5, 
                       Executed_Result_ALU_D_PRO5, CS_IsDestination_PRO3, CS_IsDestination_PRO4, CS_IsDestination_PRO5, Executed_Result_ALU_D_PRO4,
							  Mem_ALU_D, CS_Load_Forwarded_PRO3, CS_Load_Forwarded_PRO4, CS_Load_Forwarded_PRO5, Current_PC_PRO2)
    begin
	 If ((Instruction_Word_PRO2(11 downto 9) = Destination_PRO3) AND (CS_IsDestination_PRO3 = '1')) then
	    if (CS_Load_Forwarded_PRO3 = '0') then
		      MUX3 <= MUX13;
		  end if;
		
		elsif ((Instruction_Word_PRO2(11 downto 9) = Destination_PRO4) AND (CS_IsDestination_PRO4 = '1')) then
	     If (CS_Load_Forwarded_PRO4 = '0') then
		      MUX3 <= Executed_Result_ALU_D_PRO4;
		  else
		      MUX3 <= Mem_ALU_D;
		  end if;
		  
		  
	 elsif ((Instruction_Word_PRO2(11 downto 9) = Destination_PRO5) AND (CS_IsDestination_PRO5 = '1')) then
	     If (CS_Load_Forwarded_PRO5 = '0') then
		      MUX3 <= Executed_Result_ALU_D_PRO5;
		  else
		      MUX3 <= Mem_ALU_D_PRO5;
		  end if;
	 elsif (Instruction_Word_PRO2(11 downto 9) = "000") then
          
		     MUX3 <= Current_PC_PRO2;	 
		  
	 else 
	     MUX3 <= RA_RF_Data;
	 end if;
	 end process RA_Forwarding;
	
RB_Forwarding: process(Instruction_Word_PRO2, Destination_PRO3, Destination_PRO4, Destination_PRO5, MUX13, RB_RF_Data, Mem_ALU_D_PRO5, 
                       Executed_Result_ALU_D_PRO5, CS_IsDestination_PRO3, CS_IsDestination_PRO4, CS_IsDestination_PRO5, Executed_Result_ALU_D_PRO4,
							  Mem_ALU_D, CS_Load_Forwarded_PRO3, CS_Load_Forwarded_PRO4, CS_Load_Forwarded_PRO5, Current_PC_PRO2)
    begin
	 If ((Instruction_Word_PRO2(8 downto 6) = Destination_PRO3) AND (CS_IsDestination_PRO3 = '1')) then
	     If (CS_Load_Forwarded_PRO3 = '0') then
		      MUX4 <= MUX13;
		  end if;
	 elsif ((Instruction_Word_PRO2(8 downto 6) = Destination_PRO4) AND (CS_IsDestination_PRO4 = '1')) then
	     If (CS_Load_Forwarded_PRO4 = '0') then
		      MUX4 <= Executed_Result_ALU_D_PRO4;
		  else
		      MUX4 <= Mem_ALU_D;
		  end if;
		  
		  
	 elsif ((Instruction_Word_PRO2(8 downto 6) = Destination_PRO5) AND (CS_IsDestination_PRO5 = '1')) then
	     If (CS_Load_Forwarded_PRO5 = '0') then
		      MUX4 <= Executed_Result_ALU_D_PRO5;
		  else
		      MUX4 <= Mem_ALU_D_PRO5;
		  end if;
	 
	 elsif (Instruction_Word_PRO2(8 downto 6) = "000") then
          
		     MUX4 <= Current_PC_PRO2; 
	  
	 else 
	     MUX4 <= RB_RF_Data;
	 end if;
	 end process RB_Forwarding;

Choice_of_Immediate: process(Instruction_Word_PRO2, Current_PC_PRO2)
    begin
	 
	 If ((Instruction_Word_PRO2(15 downto 12) = "0000") OR 
	     (Instruction_Word_PRO2(15 downto 12) = "0100") OR
		  (Instruction_Word_PRO2(15 downto 12) = "0101")) then
		  
		  If Instruction_Word_PRO2(5) = '0' then
            MUX5 <= "0000000000" & Instruction_Word_PRO2(5 downto 0);
        else
            MUX5 <= "1111111111" & Instruction_Word_PRO2(5 downto 0);
        end if;

		  
	 elsif ((Instruction_Word_PRO2(15 downto 12) = "1000") OR 
	     (Instruction_Word_PRO2(15 downto 12) = "1001") OR
		  (Instruction_Word_PRO2(15 downto 12) = "1010")) then
		  	  
		 	If Instruction_Word_PRO2(5) = '0' then
            MUX5 <= "000000000" & Instruction_Word_PRO2(5 downto 0) & '0';
        else
            MUX5 <= "111111111" & Instruction_Word_PRO2(5 downto 0) & '0';
        end if;
	
	elsif ((Instruction_Word_PRO2(15 downto 12) = "1100") OR 
		(Instruction_Word_PRO2(15 downto 12) = "1101")) then
		 
		 If Instruction_Word_PRO2(5) = '0' then
		   MUX5 <= "000000" & Instruction_Word_PRO2(8 downto 0) & '0';
	   else
		   MUX5 <= "111111" & Instruction_Word_PRO2(8 downto 0) & '0';
	   end if;	

	elsif ((Instruction_Word_PRO2(15 downto 12) = "0011")) then
		  
		 MUX5 <= "0000000" & Instruction_Word_PRO2(8 downto 0);
	else
	    MUX5 <= "0000000000000000";
	end if;
	 end process Choice_of_Immediate;

ALU3_A_inputDecide: process(Operation_Code, Current_PC_PRO3, RA_PRO3, Immediate_PRO3, Temporary_Address)
    begin
	 
	If  ((Operation_Code = "0001") OR 
        (Operation_Code= "0000") OR
		  (Operation_Code= "0010")) then
		  
		  MUX6 <= RA_PRO3;
		  
	elsif((Operation_Code = "0100") OR 
		  (Operation_Code = "0011") OR
        (Operation_Code = "0101") OR
   	  (Operation_Code = "1000") OR
		  (Operation_Code = "1001") OR 
        (Operation_Code = "1010") OR
		  (Operation_Code = "1100") OR 
        (Operation_Code = "1111")) then
		 
		MUX6 <= Immediate_PRO3;

   elsif ((Operation_Code = "0110") OR 
          (Operation_Code = "0111")) then
		
	   MUX6 <= Temporary_Address;	
	
	else 
		MUX6 <= "0000000000000000";
   end if;
	end process ALU3_A_inputDecide;

ALU3_B_input_Decide: process(Operation_Code, Current_PC_PRO3, RB_PRO3, Complement, Immediate_PRO3, RA_PRO3)
    begin
	
	If  ((Operation_Code= "0010") OR
		  (Operation_Code= "0100") OR
   	  (Operation_Code = "0101") OR
		  (Operation_Code = "1101")) then
		  
		  MUX7 <= RB_PRO3;
		  
	elsif ((Operation_Code = "0001")) then
	
			if(Complement = '1') then
			MUX7 <= NOT (RB_PRO3);
			
			else
			MUX7 <= RB_PRO3;
			end if;
		
		  
	elsif  (Operation_Code = "0000") then
		
		MUX7 <= Immediate_PRO3;
		
	elsif  ((Operation_Code = "0011")) then
		  
		MUX7 <= "0000000000000000";
		
	elsif ((Operation_Code= "0110") OR
		    (Operation_Code= "0111")) then
			
		MUX7 <= "0000000000000010";	
		
	elsif  ((Operation_Code = "1000") OR 
        (Operation_Code= "1001") OR
		  (Operation_Code= "1010") OR
		  (Operation_Code = "1100")) then
		
		MUX7 <= Current_PC_PRO3;
		
	else 
		MUX7 <= RA_PRO3;
	end if;
	end process ALU3_B_input_Decide;

ALU3_C_input_Decide: process(Operation_Code, Current_PC_PRO3, CZ, CCR_R)
    begin
	 
		if(Operation_Code = "0001" and CZ = "11") then
		 MUX8 <= CCR_R;
		
		else
		MUX8 <= '0';
		
		end if;
		end process ALU3_C_input_Decide;
		
ALU1_A_input_Decide: process(Operation_Code, Current_PC_PRO3, RA_PRO3)
    begin
	 If ((Operation_Code = "1100") OR
	     (Operation_Code = "1101")) then
		  
		MUX18 <= Current_PC_PRO3;
	 else
		MUX18 <= RA_PRO3;
	 end if;
	 end process ALU1_A_input_Decide;

ALU1_B_input_Decide: process(Operation_Code, Complement, RB_PRO3, Current_PC_PRO3)
    begin
	 
	If(Operation_Code = "0010") then
	 
		If(Complement = '1') then
			MUX9 <= not RB_PRO3;
	   else
			MUX9 <= RB_PRO3;
	   end If;
	
	elsif ((Operation_Code = "1100") or
			 (Operation_Code = "1101")) then
			  
		MUX9 <= "0000000000000010";
		else
		MUX9 <= RB_PRO3;
	end if;
	end process ALU1_B_input_Decide;	
	 
Choose_Zero: process(Operation_Code, MUX12, ALU1_Z, ALU3_Z,  Current_PC_PRO3)
	 begin
	 
	 if((Operation_Code = "0001") or
			 (Operation_Code = "0000") or
			 (Operation_Code = "0100")) then
		MUX12 <= ALU3_Z;
		
	elsif((Operation_Code = "0010")) then
		MUX12 <= ALU1_Z;
		
	else
	MUX12 <= MUX12;
	 
	 end if;
	 end process Choose_Zero;
	 
Execute_Result_Decide: process(ALU2_D, ALU3_D, Temporary_Address, Operation_Code, Current_PC_PRO3, ALU1_D)
	 begin
	 If ((Operation_Code = "0111") OR
	     (Operation_Code = "0110")) then
	    MUX13 <= Temporary_Address;
		 
	 elsif ((Operation_Code = "0010") or
			  (Operation_Code = "1100") or
			  (Operation_Code = "1101"))then
		MUX13 <= ALU1_D;
		
	else
		MUX13 <= ALU3_D;
				
	end if;			
	 end process Execute_Result_Decide;
	 
Choose_Register_Content: process(RA_PRO3,RB_PRO3,Temporary_Address,Operation_Code, CS_IsDestination_PRO4,Destination_PRO4, Counter_Output,
                                 CS_Load_Forwarded_PRO4, CS_Load_Forwarded_PRO5, CS_IsDestination_PRO5, Current_PC_PRO4, Executed_Result_ALU_D_PRO4,
											Mem_ALU_D, Destination_PRO5, Executed_Result_ALU_D_PRO5, Mem_ALU_D_PRO5, RB_RF_Data)
	 begin
	 If (Operation_Code = "0111" AND Destination_PRO4 = "111" AND Counter_Output = "000" AND CS_IsDestination_PRO4 = '1') then
	     If (CS_Load_Forwarded_PRO4 = '0') then
		      MUX14 <= Executed_Result_ALU_D_PRO4;
		  else
		      MUX14 <= Mem_ALU_D;
		  end if;
	 elsif (Operation_Code = "0111" AND Destination_PRO5 = "111" AND Counter_Output = "000" AND CS_IsDestination_PRO5 = '1') then
	      If (CS_Load_Forwarded_PRO5 = '0') then
		      MUX14 <= Executed_Result_ALU_D_PRO5;
		  else
		      MUX14 <= Mem_ALU_D_PRO5;
		  end if;
	 elsif (Operation_Code = "0111" AND Destination_PRO5 = "110" AND Counter_Output = "001" AND CS_IsDestination_PRO5 = '1') then
	     If (CS_Load_Forwarded_PRO5 = '0') then
		      MUX14 <= Executed_Result_ALU_D_PRO5;
		  else
		      MUX14 <= Mem_ALU_D_PRO5;
		  end if;
	
		--   So if OpCode is 0111 and no forwarding is to be done
	 elsif (Operation_Code = "0111") then
	     MUX14 <= RB_RF_Data;
   elsif (Operation_Code = "0101") then
	     MUX14 <= RA_PRO3;
	else
			MUX14 <= MUX14;
	
	end if;
	 end process Choose_Register_Content;

	--  All for SW
	--  I need to take from REG (Reg_7, Reg_6 and so on) and put in MEM at some address that is computed (R_A, R_A+2, R_A+4 and so on). 

Choose_WriteBack_Data: process(CS_Load_Forwarded_PRO5, CS_IsDestination_PRO5, MUX15, Executed_Result_ALU_D_PRO5, Mem_ALU_D_PRO5, Current_PC_PRO2)
	 begin
	 
	 	if ((CS_Load_Forwarded_PRO5 = '0') and (CS_IsDestination_PRO5 = '1'))then
		  
	 MUX15 <= Executed_Result_ALU_D_PRO5;
		  
	 elsif ((CS_Load_Forwarded_PRO5 = '1') and (CS_IsDestination_PRO5 = '1')) then
	 MUX15 <= Mem_ALU_D_PRO5;
	 
	 else
	 MUX15 <= Executed_Result_ALU_D_PRO5;
	 
	 end if;
	 end process Choose_WriteBack_Data;
	 
RF_Address_2_MUX: Process(Instruction_Word_PRO2, Counter_Complement_Output, Current_PC_PRO2)
	 begin
	 If (Instruction_Word_PRO2(15 downto 12) = "0111") then
	    MUX16 <= Counter_Complement_Output;
	 else
	    MUX16 <= Instruction_Word_PRO2(8 downto 6);
		 

		 
	END IF;
	 end process RF_Address_2_MUX;
	 
Temporary_Address_Decide: process(ALU3_D, RA_RF_Data, Operation_Code, Current_PC_PRO2)
    begin
	 If ((Operation_Code = "0110") OR (Operation_Code = "0111")) then
	    MUX17 <= ALU3_D;
	 else
	    MUX17 <= RA_RF_Data;
		 
	end if;
	 end process Temporary_Address_Decide;
	 
Resetter: process(Reset, Clk, Destination_PRO3, CS_IsDestination_PRO3, CS_Load_Forwarded_PRO3, Operation_Code, MUX12, ALU3_R, Destination_PRO4,
                  CS_IsDestination_PRO4, CS_Load_Forwarded_PRO4, valid_bit_PRO2, valid_bit_PRO3, Instruction_Word_PRO2, 
						valid_bit_PRO4, valid_bit_PRO5, Current_PC_PRO2)
    begin
	 
	 If(Reset = '1') then
		ResetLogic1 <= '1';
		ResetLogic2 <= '1';
		ResetLogic3 <= '1';
		ResetLogic4 <= '1';		
		ResetLogic5 <= '1';
	else
		ResetLogic1 <= '0';
		ResetLogic2 <= '0';
		ResetLogic3 <= '0';
		ResetLogic4 <= '0';		
		ResetLogic5 <= '0';
		
	end if;
	
		
--	 If (Reset = '1') then
--	   ResetLogic1 <= '1';	
--		
----	 elsif (valid_bit_PRO1 = '0' AND (Clk = '0')) then
----	    ResetLogic1 <= '0';
----	 elsif ((Destination_PRO3 = "000" AND CS_IsDestination_PRO3 = '1' AND CS_Load_Forwarded_PRO3 = '0') OR (Operation_Code = "1000" AND MUX12 = '1') 
----	      OR (Operation_Code = "1001" AND ALU3_R = '1') OR (Operation_Code = "1010" AND  (ALU3_R OR MUX12) = '1') OR
----			Operation_Code = "1100" OR Operation_Code = "1101" OR Operation_Code = "1111") then
----		If ((Clk = '1')) then	
----		 ResetLogic1 <= '1';
----		else
----		 ResetLogic1 <= '0';
----		end if;
----	 elsif ((Destination_PRO4 = "000" AND CS_IsDestination_PRO4 = '1' AND CS_Load_Forwarded_PRO4 = '1')) then
----	   If ((Clk = '1')) then	
----		 ResetLogic1 <= '1';
----	 else
----	    ResetLogic1 <= '0';
----	 end if;
----	 else
----		 ResetLogic1 <= '0';
--	 end if;
--	 
--    If (Reset = '1') then
--	   ResetLogic2 <= '1';
----	 elsif (valid_bit_PRO1 = '0' AND (Clk = '1')) then
----	   ResetLogic2 <= '1';
----	 elsif (valid_bit_PRO2 = '0' AND (Clk = '0')) then
----	    ResetLogic2 <= '0';
----	 elsif ((Destination_PRO3 = "000" AND CS_IsDestination_PRO3 = '1' AND CS_Load_Forwarded_PRO3 = '0') OR (Operation_Code = "1000" AND MUX12 = '1') 
----	      OR (Operation_Code = "1001" AND ALU3_R = '1') OR (Operation_Code = "1010" AND  (ALU3_R OR MUX12) = '1') OR
----			Operation_Code = "1100" OR Operation_Code = "1101" OR Operation_Code = "1111") then
----		If ((Clk = '1')) then	
----		 ResetLogic2 <= '1';
----		 else
----		 ResetLogic2 <= '0';
----		end if;
----	 elsif ((Destination_PRO4 = "000" AND CS_IsDestination_PRO4 = '1' AND CS_Load_Forwarded_PRO4 = '1')) then
----	   If ((Clk = '1')) then	
----		 ResetLogic2 <= '1';
----		else
----		 ResetLogic2 <= '0';
----		end if;
----		else
----	    ResetLogic2 <= '0';
--	 end if;
--	 
--    If (Reset = '1') then
--	   ResetLogic3 <= '1';
----	 elsif (valid_bit_PRO2 = '0' AND (Clk = '1')) then
----	   ResetLogic3 <= '1';
----	 elsif (valid_bit_PRO3 = '0' AND (Clk = '0')) then
----	    ResetLogic3 <= '0';
----	 elsif ((Destination_PRO3 = "000" AND CS_IsDestination_PRO3 = '1' AND CS_Load_Forwarded_PRO3 = '0') OR (Operation_Code = "1000" AND MUX12 = '1') 
----	      OR (Operation_Code = "1001" AND ALU3_R = '1') OR (Operation_Code = "1010" AND  (ALU3_R OR MUX12) = '1') OR
----			Operation_Code = "1100" OR Operation_Code = "1101" OR Operation_Code = "1111") then
----		If ((Clk = '1')) then	
----		 ResetLogic3 <= '1';
----		else
----		 ResetLogic3 <= '0';
----		end if;
----	 elsif ((Destination_PRO4 = "000" AND CS_IsDestination_PRO4 = '1' AND CS_Load_Forwarded_PRO4 = '1')) then
----	   If ((Clk = '1')) then	
----		 ResetLogic3 <= '1';
----		else
----		 ResetLogic3 <= '0';
----		end if;
----	 elsif ((Instruction_Word_PRO2(8 downto 6) = Destination_PRO3) AND (CS_IsDestination_PRO3 = '1') AND (CS_Load_Forwarded_PRO3 = '1')) then
----	   If ((Clk = '1')) then	
----		 ResetLogic3 <= '1';
----		else
----		 ResetLogic3 <= '0';
----		end if;
----		else
----	    ResetLogic3 <= '0';
--	 end if;
--	 
--    If (Reset = '1') then
--	   ResetLogic4 <= '1';
----	 elsif (valid_bit_PRO3 = '0' AND Clk = '1') then
----	   ResetLogic4 <= '1';
----	 elsif (valid_bit_PRO4 = '0' AND (Clk = '0')) then
----	    ResetLogic4 <= '0';
----	 elsif ((Destination_PRO4 = "000" AND CS_IsDestination_PRO4 = '1' AND CS_Load_Forwarded_PRO4 = '1')) then
----	   If ((Clk = '1')) then	
----		 ResetLogic4 <= '1';
----		else 
----		 ResetLogic4 <= '0';
----		end if;
----		else
----	    ResetLogic4 <= '0';
--	 end if;
--	 
--    If (Reset = '1') then
--      ResetLogic5 <= '1';
----	 elsif (valid_bit_PRO4 = '0' AND Clk = '1') then
----	   ResetLogic5 <= '1';
----	 elsif (valid_bit_PRO5 = '0' AND (Clk = '0')) then
----	    ResetLogic5 <= '0';
----	 else
----	    ResetLogic5 <= '0';
--	 end if;
	 
end process Resetter;

Counter_Enabler: process(Current_PC_PRO2, Operation_Code)
begin
	If (Operation_Code = "0110" OR Operation_Code = "0111") then
		Counter_Enabling_Logic  <= '1';
	else
		Counter_Enabling_Logic  <= '0';
	end if;
end process Counter_Enabler;

When_to_Stall: process(Operation_Code, Counter_Output, Instruction_Word_PRO2, Destination_PRO3, CS_IsDestination_PRO3, CS_Load_Forwarded_PRO3)
begin
	Stall_Logic1 <= '1';
	Stall_Logic2 <= '1';
	Stall_Logic3 <= '1';
	Stall_Logic4 <= '1';
	Stall_Logic5 <= '1';
	
	If (((Operation_Code = "0110") OR (Operation_Code = "0111")) AND (Counter_Output /= "111")) then
	
		Stall_Logic1 <= '0';
		Stall_Logic2 <= '0';
		Stall_Logic3 <= '0';
	
	elsif ((Instruction_Word_PRO2(8 downto 6) = Destination_PRO3) AND (CS_IsDestination_PRO3 = '1') AND (CS_Load_Forwarded_PRO3 = '1')) then
	
		Stall_Logic1 <= '0';
		Stall_Logic2 <= '0';
	
	else
		Stall_Logic1 <= '1';
		Stall_Logic2 <= '1';
		Stall_Logic3 <= '1';
		Stall_Logic4 <= '1';
		Stall_Logic5 <= '1';
	end If;
end process When_to_Stall;

end arc;