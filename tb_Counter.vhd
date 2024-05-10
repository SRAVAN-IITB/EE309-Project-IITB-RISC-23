library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Counter is
end entity tb_Counter;

architecture TB_ARCH of tb_Counter is
    -- Constants
    constant CLOCK_PERIOD : time := 10 ns;

    -- Signals
    signal clk, reset : std_logic := '0';
    signal Values : std_logic_vector(2 downto 0);

    -- Component instantiation
component Test is
port (clk, reset:in std_logic;
Values :out std_logic_vector(2 downto 0));
end component Test;

begin
    -- Instantiate the Register File
    DUT: Test port map (clk => clk, reset => reset, Values => Values);
	 
	 reset <= '1', '0' after 1ns;
    -- Clock process
    clk_process: process
    begin
        while now < 500 ns loop  -- Simulate for 500 ns
            clk <= '1';
            wait for CLOCK_PERIOD / 2;
            clk <= '0';
            wait for CLOCK_PERIOD / 2;
        end loop;
        wait;
    end process;

end TB_ARCH;
