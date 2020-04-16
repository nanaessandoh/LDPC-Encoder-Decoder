LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY test_Top_Level IS
GENERIC(
	-- Define Generics
	 N : integer := 5; -- Length of Message Bits
	 C : integer := 10 -- Length of Codewords
);

END test_Top_Level;

ARCHITECTURE behav OF test_Top_Level IS

-- Define Components
COMPONENT Top_Level_LDPC IS

PORT(
	clk : IN std_logic;
	rstb : IN std_logic;
	isop : IN std_logic;
	ivalid: IN std_logic;
	in_data : IN std_logic_vector(N-1 downto 0);
	dec_done : OUT std_logic;
	out_data : OUT std_logic_vector (N-1 downto 0)

);

END COMPONENT;

 
	signal CycleNumber : integer;

	signal clk_i 	: std_logic;
	signal rstb_i 	: std_logic;
	signal isop_i 	:  std_logic;
	signal ivalid_i	:  std_logic;
	signal in_data_i 	:  std_logic_vector(N-1 downto 0);
	signal dec_done_i :  std_logic;
	signal out_data_i 	:  std_logic_vector (N-1 downto 0);


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
	test: Top_Level_LDPC PORT MAP(	clk => clk_i,
					rstb => rstb_i, 
					isop => isop_i,
					ivalid => ivalid_i,
					in_data => in_data_i,
					dec_done => dec_done_i,
					out_data => out_data_i
					);


	-- Perform Test
	Do_Test:
	PROCESS
	BEGIN

	WAIT FOR 10 ns;

	isop_i	<= '1';
	ivalid_i<= '1';
	in_data_i <= ("10100");
	WAIT FOR 15 ns;
	isop_i	<= '0';
	ivalid_i<= '0';

	WAIT FOR 400 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	in_data_i <= ("00001");
        WAIT FOR 15 ns;
	isop_i	<= '0';
	ivalid_i<= '0';

	WAIT FOR 400 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	in_data_i <= ("00101");
	WAIT FOR 15 ns;
	isop_i	<= '0';
	ivalid_i<= '0';


	END PROCESS Do_test;


    END behav;
