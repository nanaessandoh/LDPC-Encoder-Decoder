LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


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
	msg_input : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	msg_output : OUT std_logic_vector (N-1 downto 0)
);

END LDPC;



ARCHITECTURE behav OF Top_Level IS


COMPONENT Encoder IS
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
	idata : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	odata : OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;

COMPONENT Bit_Erasure IS

GENERIC(
	-- Define Generics
	 C : integer := 10 -- Length of Codewords
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	code_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	error_data : OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;

COMPONENT Message_Passing IS

GENERIC(
	-- Define Generics
	 C : integer := 10 -- Length of Codewords
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;

	-- Input Interface I/O
	isop : IN std_logic;
	error_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	msg_pass_done : OUT std_logic;
	odata : OUT std_logic_vector (C-1 downto 0)
);

END COMPONENT;

COMPONENT Decoder IS

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
	idata : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto 0)

);

END COMPONENT;


--Signal Declaration
SIGNAL encode_done_i: std_logic;
SIGNAL erasure_done_i: std_logic;
SIGNAL msg_pass_done_i: std_logic;
SIGNAL code_encoder_i: std_logic_vector(C-1 downto 0);
SIGNAL code_bit_erasure_i: std_logic_vector(C-1 downto 0);
SIGNAL code_msg_pass_i: std_logic_vector(C-1 downto 0);

BEGIN

CE1: Encoder PORT MAP(		clk => clk,
				rstb => rstb,
				isop => isop,
				ivalid => '1',
				idata => msg_input,
				edone => encode_done_i,
				odata => code_encoder_i
			); 

CE2: Bit_Erasure PORT MAP(	clk => clk,
				rstb => rstb, 
				isop => erasure_done_i, 
				code_data => code_encoder_i,
				edone => erasure_done_i,
				error_data => code_bit_erasure_i
			);

CE3: Message_Passing PORT MAP(	clk => clk,
				rstb => rstb, 
				isop => erasure_done_i,
				error_data => code_bit_erasure_i, 
				msg_pass_done => msg_pass_done_i,
				odata => code_msg_pass_i
			);

CE4: Decoder PORT MAP(	clk => clk,
			rstb => rstb,
			isop => msg_pass_done_i,
			idata => code_msg_pass_i,  
			edone => edone,
			odata => msg_output

			);


END behav;