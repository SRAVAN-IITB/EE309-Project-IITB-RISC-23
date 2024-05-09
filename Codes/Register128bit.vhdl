library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity Register128bit is
	port(Clk, Reset : in std_logic;
			data_in : in std_logic_vector(127 downto 0);
			Stallbar: in std_logic;
			data_out : out std_logic_vector(127 downto 0);
			valid_bit : out std_logic
		 );
end entity;

architecture STRUCT of Register128bit is
	component D_FlipFlop is
		port(Clk, Reset, input, enable : in std_logic;
				output : out std_logic
			 );
	end component;

	begin

		loop1 : for i in 0 to 127 generate
					fx : D_FlipFlop port map(Clk => Clk, 
											Reset => Reset, 
											input => data_in(i), 
											enable => Stallbar, 
											output => data_out(i)
											);
	   end generate;
		
		
		valid_bit <= data_in(0) or data_in(1) or data_in(2) or data_in(3) or data_in(4) or data_in(5) or data_in(6) or data_in(7) or data_in(8) or
              data_in(9) or data_in(10) or data_in(11) or data_in(12) or data_in(13) or data_in(14) or data_in(15) or data_in(16) or data_in(17) or
              data_in(18) or data_in(19) or data_in(20) or data_in(21) or data_in(22) or data_in(23) or data_in(24) or data_in(25) or data_in(26) or
              data_in(27) or data_in(28) or data_in(29) or data_in(30) or data_in(31) or data_in(32) or data_in(33) or data_in(34) or data_in(35) or
              data_in(36) or data_in(37) or data_in(38) or data_in(39) or data_in(40) or data_in(41) or data_in(42) or data_in(43) or data_in(44) or
              data_in(45) or data_in(46) or data_in(47) or data_in(48) or data_in(49) or data_in(50) or data_in(51) or data_in(52) or data_in(53) or
              data_in(54) or data_in(55) or data_in(56) or data_in(57) or data_in(58) or data_in(59) or data_in(60) or data_in(61) or data_in(62) or
              data_in(63) or data_in(64) or data_in(65) or data_in(66) or data_in(67) or data_in(68) or data_in(69) or data_in(70) or data_in(71) or
              data_in(72) or data_in(73) or data_in(74) or data_in(75) or data_in(76) or data_in(77) or data_in(78) or data_in(79) or data_in(80) or
              data_in(81) or data_in(82) or data_in(83) or data_in(84) or data_in(85) or data_in(86) or data_in(87) or data_in(88) or data_in(89) or
              data_in(90) or data_in(91) or data_in(92) or data_in(93) or data_in(94) or data_in(95) or data_in(96) or data_in(97) or data_in(98) or
              data_in(99) or data_in(100) or data_in(101) or data_in(102) or data_in(103) or data_in(104) or data_in(105) or data_in(106) or data_in(107) or
              data_in(108) or data_in(109) or data_in(110) or data_in(111) or data_in(112) or data_in(113) or data_in(114) or data_in(115) or data_in(116) or
              data_in(117) or data_in(118) or data_in(119) or data_in(120) or data_in(121) or data_in(122) or data_in(123) or data_in(124) or data_in(125) or
              data_in(126) or data_in(127);

		
end STRUCT;