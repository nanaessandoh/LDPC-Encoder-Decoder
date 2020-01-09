LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Message_Passing IS

GENERIC(
	-- Define Generics
	 N :natural := 10 -- Length of Codeword Bits
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	error_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	msg_pass_done : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto 0)
);

END Message_Passing;



ARCHITECTURE behav OF Message_Passing IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET,IDLE,PARITY_COUNT,PARITY_ONE,PARITY_TWO,PARITY_THREE,PARITY_FOUR,PARITY_FIVE, CODE_CHECK, DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL pcheck1 : integer; --Counts the number of Error in each Parity Check Eqn 1
SIGNAL pcheck2 : integer; -- Eqn 2
SIGNAL pcheck3 : integer; -- Eqn 3
SIGNAL pcheck4 : integer; -- Eqn 4
SIGNAL pcheck5 : integer; -- Eqn 5
SIGNAL fix_count : integer; -- Hold the count of 0 and 1 in the code
SIGNAL verify_code: std_logic; -- Signals if any of the bits is not 0 or 1
SIGNAL idata : std_logic_vector (N-1 downto 0);


BEGIN
	sequential:
	PROCESS(clk,rstb)
	BEGIN

	CASE current_state IS
	

	WHEN ONRESET =>
		next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
		next_state <= PARITY_COUNT;
	ELSE
		next_state <= IDLE;
	END IF;

	WHEN PARITY_COUNT =>
	IF (pcheck1 = 3) THEN
		next_state <= PARITY_ONE;
	ELSE
		next_state <= PARITY_TWO;
	END IF;


	WHEN PARITY_ONE =>
	IF (pcheck2 = 2) THEN
		next_state <= PARITY_TWO;
	ELSE
		next_state <= PARITY_THREE;
	END IF;


	WHEN PARITY_TWO =>
	IF (pcheck3 = 4) THEN
		next_state <= PARITY_THREE;
	ELSE
		next_state <= PARITY_FOUR;
	END IF;


	WHEN PARITY_THREE =>
	IF (pcheck4 = 2) THEN
		next_state <= PARITY_FOUR;
	ELSE
		next_state <= PARITY_FIVE;
	END IF;
	

	WHEN PARITY_FOUR =>
	IF (pcheck5 = 3) THEN
		next_state <= PARITY_FIVE;
	ELSE
		next_state <= CODE_CHECK;
	END IF;


	WHEN CODE_CHECK =>
	IF(verify_code = '1') THEN
		next_state <= DONE;
	ELSE
		next_state <= PARITY_COUNT;
	END IF;


	WHEN OTHERS =>
		next_state <= ONRESET;


	END CASE;

	END PROCESS sequential;


	combinational:
	PROCESS(clk, rstb)	
	BEGIN

	IF ( current_state = ONRESET) THEN
 		odata <= "UUUUUUUUUU" ;
		msg_pass_done <= 'U';
		verify_code<= 'U'; 
		
	END IF;

	IF (current_state = IDLE) THEN
		idata <= error_data;
		pcheck1 <= 0;
		pcheck2 <= 0;
		pcheck3 <= 0;
		pcheck4 <= 0;
		pcheck5 <= 0;
	
	END IF;

	IF (current_state = PARITY_COUNT) THEN
	
	IF (idata(N-1) = '0') or (idata(N-1) = '1' ) THEN --(9)
		pcheck1 <= pcheck1 + 1;
	ELSE
		pcheck1 <= pcheck1;
	END IF;

	IF (idata(N-2) = '0') or (idata(N-2) = '1' ) THEN --(8)
		pcheck2 <= pcheck2 + 1;
	ELSE
		pcheck2 <= pcheck2;
	END IF;

	IF (idata(N-3) = '0') or (idata(N-3) = '1' ) THEN --(7)
		pcheck3 <= pcheck3 + 1;
	ELSE
		pcheck3 <= pcheck3;
	END IF;

	IF (idata(N-4) = '0') or (idata(N-4) = '1' ) THEN --(6)
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck4 <= pcheck4;
	END IF;

	IF (idata(N-5) = '0') or (idata(N-5) = '1' ) THEN --(5)
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck5 <= pcheck5;
	END IF;

	IF (idata(N-6) = '0') or (idata(N-6) = '1' ) THEN --(4)
		pcheck2 <= pcheck2 + 1;
		pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
	END IF;

	IF (idata(N-7) = '0') or (idata(N-7) = '1' ) THEN --(3)
		pcheck1 <= pcheck1 + 1;
		pcheck3 <= pcheck3 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck3 <= pcheck3;
	END IF;

	IF (idata(N-8) = '0') or (idata(N-8) = '1' ) THEN --(2)
		pcheck1 <= pcheck1 + 1;
		pcheck3 <= pcheck3 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck3 <= pcheck3;
		pcheck5 <= pcheck5;

	END IF;
	IF (idata(N-9) = '0') or (idata(N-9) = '1' ) THEN --(1)
		pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE	
		pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
		pcheck5 <= pcheck5;

	END IF;
	IF (idata(N-10) = '0') or (idata(N-10) = '1' ) THEN --(0)
		pcheck1 <= pcheck1 + 1;
		pcheck2 <= pcheck2 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck2 <= pcheck2;
		pcheck5 <= pcheck5;
	END IF;

	END IF;



	IF ( current_state = PARITY_ONE) THEN	

	IF( idata(N-1) /= '0' or idata(N-1) /= '1') THEN 		--(9)
	idata(N-1) <=  idata(N-7) xor idata(N-8) xor idata(N-10);
	ELSIF( idata(N-7) /= '0' or idata(N-7) /= '1') THEN		--(3)
	idata(N-7) <=  idata(N-1) xor idata(N-8) xor idata(N-10);
	ELSIF( idata(N-8) /= '0' or idata(N-8) /= '1') THEN		--(2)
	idata(N-8) <=  idata(N-1) xor idata(N-7) xor idata(N-10);
	ELSIF( idata(N-10) /= '0' xor idata(N-10) /= '1') THEN		--(0)
	idata(N-10) <=  idata(N-1) xor idata(N-7) xor idata(N-8);
	END IF;

	END IF;


	IF ( current_state = PARITY_TWO) THEN	

	IF( idata(N-2) /= '0' or idata(N-2) /= '1') THEN 		--(8)
	idata(N-2) <=  idata(N-6) xor idata(N-10);
	ELSIF( idata(N-6) /= '0' or idata(N-6) /= '1') THEN		--(4)
	idata(N-6) <=  idata(N-2) xor idata(N-10);
	ELSIF( idata(N-10) /= '0' or idata(N-10) /= '1') THEN		--(0)
	idata(N-10) <=  idata(N-2) xor idata(N-6);
	END IF;

	END IF;


	IF ( current_state = PARITY_THREE) THEN	

	IF( idata(N-3) /= '0' or idata(N-3) /= '1') THEN 			--(7)
	idata(N-3) <=  idata(N-6) xor idata(N-7) xor idata(N-8) xor idata(N-9);
	ELSIF( idata(N-6) /= '0' or idata(N-6) /= '1') THEN			--(4)
	idata(N-6) <=  idata(N-3) xor idata(N-7) xor idata(N-8) xor idata(N-9);
	ELSIF( idata(N-7) /= '0' or idata(N-7) /= '1') THEN			--(3)
	idata(N-7) <=  idata(N-3) xor idata(N-6) xor idata(N-8) xor idata(N-9);
	ELSIF( idata(N-8) /= '0' or idata(N-8) /= '1') THEN			--(2)
	idata(N-8) <=  idata(N-3) xor idata(N-6) xor idata(N-7) xor idata(N-9);
	ELSIF( idata(N-9) /= '0' or idata(N-9) /= '1') THEN			--(1)
	idata(N-9) <=  idata(N-3) xor idata(N-6) xor idata(N-7) xor idata(N-8);
	END IF;

	END IF;


	IF ( current_state = PARITY_FOUR) THEN	

	IF( idata(N-4) /= '0' or idata(N-4) /= '1') THEN 		--(6)
	idata(N-4) <=  idata(N-6) xor idata(N-9);
	ELSIF( idata(N-6) /= '0' or idata(N-6) /= '1') THEN		--(4)
	idata(N-6) <=  idata(N-4) xor idata(N-9);
	ELSIF( idata(N-9) /= '0' or idata(N-9) /= '1') THEN		--(1)
	idata(N-9) <=  idata(N-4) xor idata(N-6);
	END IF;

	END IF;



	IF ( current_state = PARITY_FIVE) THEN	

	IF( idata(N-5) /= '0' or idata(N-5) /= '1') THEN 		--(5)
	idata(N-5) <=  idata(N-8) xor idata(N-9) xor idata(N-10);
	ELSIF( idata(N-8) /= '0' or idata(N-8) /= '1') THEN		--(2)
	idata(N-8) <=  idata(N-5) xor idata(N-9) xor idata(N-10);
	ELSIF( idata(N-9) /= '0' or idata(N-9) /= '1') THEN		--(1)
	idata(N-9) <=  idata(N-5) xor idata(N-8) xor idata(N-10);
	ELSIF( idata(N-10) /= '0' or idata(N-10) /= '1') THEN		--(0)
	idata(N-10) <=  idata(N-5) xor idata(N-8) xor idata(N-9);
	END IF;

	END IF;


	IF ( current_state = CODE_CHECK) THEN
	--- Use a loop here
	FOR I IN 1 TO 10 LOOP
	IF (idata(N-I) = '0' or idata(N-I) = '1') THEN
	fix_count <= fix_count + 1;
	END IF;
	END LOOP;

	IF (fix_count = 10) THEN  
		verify_code <= '1'; -- All the bit are 0 or 1
	ELSE
		verify_code <= '0';
		pcheck1 <= 0;
		pcheck2 <= 0;
		pcheck3 <= 0;
		pcheck4 <= 0;
		pcheck5 <= 0;
	END IF;
	END IF;


	IF ( current_state = DONE) THEN
		msg_pass_done <= '1';
		odata <= idata;
	ELSE 
		msg_pass_done <= '0';
		odata <= "UUUUUUUUUU";
	END IF;

	END PROCESS combinational;




	clock_state_machine:
	PROCESS(clk,rstb)

	BEGIN
	IF (rstb /= '1') THEN
	current_state <= ONRESET;
	ELSIF (clk'EVENT and clk = '1') THEN
	current_state <= next_state;
	END IF;

	END PROCESS clock_state_machine;



END behav;
