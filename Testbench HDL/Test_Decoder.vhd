LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Test_Decoder IS
GENERIC(
	-- Define Generics
	 N : integer := 5; -- Length of Message Bits
	 C : integer := 10 -- Length of Codewords
);

END Test_Decoder;

ARCHITECTURE behav OF Test_Decoder IS

-- Define Components
COMPONENT Decoder IS

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;

	-- Input Interface I/O
	error_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	dec_done : OUT std_logic;
	output_data : OUT std_logic_vector (N-1 downto 0)
);

END COMPONENT;

 
	signal CycleNumber : integer;

	signal clk_i		:  std_logic;
	signal rstb_i	 	:  std_logic;
	signal error_data_i	:  std_logic_vector(C-1 downto 0);
	signal dec_done_i 	:  std_logic;
	signal output_data_i 	:  std_logic_vector(N-1 downto 0);




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
	test: Decoder PORT MAP( 	clk => clk_i,
				       	rstb => rstb_i,
					error_data => error_data_i,
					dec_done => dec_done_i,
					output_data => output_data_i
				        );

	-- Perform Test
	Do_Test:
	PROCESS
	BEGIN
	
	WAIT FOR 20 ns;

	error_data_i <= ("00X010X1X1"); -- Original Codeword 0000100111	
        WAIT FOR 15 ns;
	error_data_i	<= (OTHERS => 'U');
	
	WAIT FOR 300 ns;



	error_data_i <= ("X0X0111X01"); -- Original Codeword 0010111001    
        WAIT FOR 15 ns;
	error_data_i	<= (OTHERS => 'U');

	WAIT FOR 300 ns;

	
	error_data_i <= ("0101X000XX"); --  Original Codeword 0101000011
        WAIT FOR 15 ns;
	error_data_i	<= (OTHERS => 'U');

	WAIT FOR 300 ns;

	END PROCESS Do_test;




    END behav;

