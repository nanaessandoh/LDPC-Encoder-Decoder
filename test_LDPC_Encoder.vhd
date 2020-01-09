LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY test_encoder IS
GENERIC(
	-- Define Generics
	 N :natural := 5; -- Length of Message Bits
	 C : natural := 10 -- Length of Codewords
);

END test_encoder;

ARCHITECTURE behav OF test_encoder IS

-- Define Components
COMPONENT encoder IS
PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;
	-- Input Interface I/O
	isop : IN std_logic;
	ivalid: IN std_logic;
	idata : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	odata : OUT std_logic_vector (C-1 downto 0)

);
END COMPONENT;

 
	signal CycleNumber : integer;

	signal clk_i 	: std_logic;
	signal rstb_i 	: std_logic;
	signal isop_i 	:  std_logic;
	signal ivalid_i	:  std_logic;
	signal idata_i 	:  std_logic_vector(N-1 downto 0);
	signal edone_i 	:  std_logic;
	signal odata_i 	:  std_logic_vector (C-1 downto 0);


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
	test: encoder PORT MAP( 	clk => clk_i,
				       	rstb => rstb_i,
					isop => isop_i,
					ivalid => ivalid_i,
					idata => idata_i,
					edone => edone_i,
					odata => odata_i
				        );


	-- Perform Test
	Do_Test:
	PROCESS
	BEGIN

	WAIT FOR 5 ns;

	isop_i	<= '0';
	ivalid_i<= '0';
	idata_i	<= (OTHERS => 'X');


	WAIT FOR 10 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	idata_i	<= (OTHERS => '0');
	WAIT FOR 15 ns;
	isop_i	<= '0';


	WAIT FOR 100 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	idata_i	<= (OTHERS => '1');
        WAIT FOR 15 ns;
	isop_i	<= '0';



	WAIT FOR 100 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	idata_i	<= ("00001");
	WAIT FOR 15 ns;
	isop_i	<= '0';



	WAIT FOR 100 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	idata_i	<= ("00010");
        WAIT FOR 15 ns;
	isop_i	<= '0';


	WAIT FOR 100 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	idata_i	<= ("00011");
        WAIT FOR 15 ns;
	isop_i	<= '0';


	WAIT FOR 100 ns;
	isop_i	<= '1';
	ivalid_i<= '1';
	idata_i	<= ("00100");
        WAIT FOR 15 ns;
	isop_i	<= '0';

	

	END PROCESS Do_test;




    END behav;
