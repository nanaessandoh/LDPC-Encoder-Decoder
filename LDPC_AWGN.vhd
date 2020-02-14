LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY AWGN IS

GENERIC(
	-- Define Generics
	 N :natural := 10 -- Length of Codeword Bits
);

PORT(
	-- Clock and Reset
	clk 		: IN std_logic;
	rstb 		: IN std_logic;
	-- Input Interface I/O
	isop 		: IN std_logic;
	code_data 	: IN std_logic_vector(N-1 downto 0);
	-- Output Interface I/O
	edone 		: OUT std_logic;
	error_data 	: OUT std_logic_vector (N-1 downto 0)
);
END AWGN ;


ARCHITECTURE behav OF AWGN IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE,GEN_ERROR,ADD_ERROR, VERIFY,ERROR,EOP);
-- Define States
SIGNAL current_state, next_state : state_type;
-- Define Signals
SIGNAL error1, error2, error3 : integer;
SIGNAL code_data_i, code_data_s : std_logic_vector (N-1 downto 0);
SIGNAL count1, count2, count3 : std_logic_vector (3 downto 0);
SIGNAL count : std_logic_vector (2 downto 0);
SIGNAL verify_code, gen_done: std_logic;


BEGIN

	sequential:
	PROCESS(clk,rstb)
	BEGIN

	CASE current_state IS
	
	WHEN ONRESET =>
	next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
	next_state <= GEN_ERROR;
	ELSE
	next_state <= IDLE;
	END IF;

	WHEN GEN_ERROR =>
	IF (gen_done = '1') THEN
	next_state <= ADD_ERROR;
	ELSE
	next_state <= GEN_ERROR;
	END IF;

	WHEN ADD_ERROR =>
	next_state <= VERIFY;

	WHEN VERIFY =>
	IF(verify_code = '0') THEN
	next_state <= ERROR;
	ELSIF (verify_code = '1') THEN
	next_state <= EOP;
	ELSE
	next_state <= VERIFY;
	END IF;

	WHEN EOP =>
	next_state <= ONRESET;

	WHEN ERROR =>
	next_state <= ONRESET;

	WHEN OTHERS =>
	next_state <= ONRESET;

	END CASE;

	END PROCESS sequential;


	clock_state_machine:
	PROCESS(clk,rstb)

	BEGIN
	IF (rstb /= '1') THEN
	current_state <= ONRESET;
	ELSIF (clk'EVENT and clk = '1') THEN
	current_state <= next_state;
	END IF;

	END PROCESS clock_state_machine;



	combinational:
	PROCESS(clk, rstb)	
	BEGIN

	IF ( clk'EVENT and clk = '0') THEN

	IF ( current_state = ONRESET) THEN
 		error_data <= (OTHERS => 'U');
		edone <= 'U';
		verify_code<= 'U'; 
		gen_done <= 'U'; 

	END IF;

	IF (current_state = IDLE) THEN
		count <= "111";
		count1 <= (OTHERS => '0');
		count2 <= (OTHERS => '0');
		count3 <= (OTHERS => '0');
		error1 <= 8;
		error2 <= 5;
		error3 <= 2;
	
	END IF;

	IF (current_state = GEN_ERROR) THEN
 		code_data_i <= code_data;
		code_data_s <= code_data;
		count1 <= code_data_i (N-1 downto 6);
		count2 <= code_data_i (N-5 downto 2);
		count3 <= code_data_i (N-7 downto 0);
         
	IF (count /= "000") THEN
		error1 <= (((to_integer(unsigned(count1)))*error1)+1) mod 10;	
		error2 <= (((to_integer(unsigned(count2)))*error2)+6) mod 10;
		error3 <= (((to_integer(unsigned(count3)))*error3)+9) mod 10;
		count <= count - 1;
		gen_done <= '0';

	ELSIF (count = "000") THEN
		gen_done <= '1'; -- Error Generation Done

	ELSE 
		count <= count;
	END IF;
	END IF;

	IF ( current_state = ADD_ERROR) THEN	
	-- Adding Errors
	IF(code_data_s(error1) = '0') THEN
		code_data_i(error1) <= '1';
	ELSE
		code_data_i(error1) <= '0';
	END IF;
	IF(code_data_s(error2) = '0') THEN
		code_data_i(error2) <= '1';
	ELSE
		code_data_i(error2) <= '0';
	END IF;
	IF(code_data_s(error3) = '0') THEN
		code_data_i(error3) <= '1';
	ELSE
		code_data_i(error3) <= '0';
	END IF;
	END IF;


	IF (current_state = VERIFY) THEN

	IF (code_data_i = code_data_s) THEN   --1
		verify_code <= '0'; --false
	ELSE
		verify_code <= '1'; --true
	END IF;
	END IF;


	IF (current_state = EOP) THEN
		edone <= '1';
		error_data <= code_data_i;
	ELSE 
		edone <= '0';
		error_data <= (OTHERS => 'U');
	END IF;
	END IF;

	END PROCESS combinational;


END behav;