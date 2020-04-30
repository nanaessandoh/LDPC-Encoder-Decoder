LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;



-- Input and Output Definition
ENTITY LDPC IS

GENERIC(
	-- Define Generics
	 N : integer := 5; -- Length of Message Bits
	 C : integer := 10 -- Length of Codewords
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;

	-- Input Interface I/O
	isop : IN std_logic;
	ivalid: IN std_logic;
	input_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	dec_done : OUT std_logic;
	output_data : OUT std_logic_vector (N-1 downto 0)

);

END LDPC;


ARCHITECTURE behav OF LDPC IS

-- Define Components
COMPONENT Encoder
PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;

	-- Input Interface I/O
	isop : IN std_logic;
	ivalid: IN std_logic;
	input_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	code_data : OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;


COMPONENT Bit_Erasure

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	code_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	error_data : OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;


COMPONENT Decoder

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



-- Define Signals 
SIGNAL code_data_i : std_logic_vector (C-1 downto 0);
SIGNAL error_data_i : std_logic_vector (C-1 downto 0);
SIGNAL edone_i : std_logic;
SIGNAL edone_ii : std_logic;




BEGIN


	-- Port Map Declaration
	A1: Encoder PORT MAP( 		clk => clk,
				       	rstb => rstb,
					isop => isop,
					ivalid => ivalid,
					input_data => input_data,
					edone => edone_i,
					code_data => code_data_i
				        );

	A2: Bit_Erasure PORT MAP( 	clk => clk,
				       	rstb => rstb,
					code_data => code_data_i,
					edone => edone_ii,
					error_data => error_data_i
				        );

	A3: Decoder PORT MAP( 		clk => clk,
				       	rstb => rstb,
					error_data => error_data_i,
					dec_done => dec_done,
					output_data => output_data
				        );



	

	
	


END behav;

