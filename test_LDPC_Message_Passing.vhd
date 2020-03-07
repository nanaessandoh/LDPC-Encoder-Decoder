LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY test_Message_Passing IS
GENERIC(
--	 Define Generics
	 C : integer := 10 -- Length of Codeword Bits
);

END test_Message_Passing;



ARCHITECTURE behav OF test_Message_Passing IS

COMPONENT Message_Passing IS

PORT(
	-- Clock and Reset
	clk 		: IN std_logic;
	rstb 		: IN std_logic;


	-- Input Interface I/O
	isop 		: IN std_logic;
	error_data 	: IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	msg_pass_done 	: OUT std_logic;
	odata 		: OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;

-- Define Signals

	signal CycleNumber : integer;

	signal clk_i 		: std_logic;
	signal rstb_i 		: std_logic;
	signal isop_i 		:  std_logic;
	signal error_data_i 	:  std_logic_vector(C-1 downto 0);
	signal msg_pass_done_i 	:  std_logic;
	signal odata_i 		:  std_logic_vector (C-1 downto 0);

BEGIN

	-- Generate Clock
	GenerateCLK:
	PROCESS
	VARIABLE TimeHigh : time := 5 ns;
	VARIABLE TimeLow : time := 5 ns;
	VARIABLE CycleCount: integer := 0;
 
	BEGIN
	clk_i <= '1';
	WAIT FOR TimeHigh;
	clk_i <= '0';
	WAIT FOR TimeLow;

	--Handle Reset
	CycleCount := CycleCount + 1;
	CycleNumber <= CycleCount AFTER 1 ns;

	END PROCESS GenerateCLK;


	-- Generate Global Reset
	GenerateRSTB:
	PROCESS(CycleNumber)
	VARIABLE ResetTime : INTEGER := 2000;
	
	BEGIN
	IF (CycleNumber <= ResetTime) THEN
		rstb_i <= '1' AFTER 1 ns;
	ELSE
		rstb_i <= '0' AFTER 1 ns;
	END IF; 
	END PROCESS GenerateRSTB;


    


	-- Port Map Declaration
	test: Message_passing 	PORT MAP( 	clk => clk_i,
				       		rstb => rstb_i,
						isop => isop_i,
						error_data => error_data_i,
						msg_pass_done => msg_pass_done_i,
						odata => odata_i
				        );


	-- Perform Test
	Do_Test:
	PROCESS
	BEGIN

	
	WAIT FOR 10 ns;

	isop_i	<= '1';
	error_data_i	<= ("00X010X1X1"); -- Original Codeword 0000100111	
        WAIT FOR 15 ns;
	isop_i	<= '0';
	
	WAIT FOR 250 ns;


	isop_i	<= '1';
	error_data_i	<= ("X0X0111X01"); -- Original Codeword 0010111001
        WAIT FOR 15 ns;
	isop_i	<= '0';

	WAIT FOR 250 ns;

	isop_i	<= '1';
	error_data_i	<= ("0101X000XX"); --  Original Codeword 0101000011
        WAIT FOR 15 ns;
	isop_i	<= '0';

	WAIT FOR 250 ns;

	END PROCESS Do_Test;


END behav;
