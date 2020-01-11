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
TYPE state_type IS (ONRESET,IDLE,PARITY_CHK1,PARITY_CHK2,PARITY_CHK3,PARITY_CHK4,FIX_1,FIX_2,FIX_3,FIX_4,FIX_5, CODE_CHECK, VERIFY, ERROR, DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL pcheck1 : real; --Counts the number of Error in each P Check Eqn 1
SIGNAL pcheck2 : real; -- Eqn 2
SIGNAL pcheck3 : real; -- Eqn 3
SIGNAL pcheck4 : real; -- Eqn 4
SIGNAL pcheck5 : real; -- Eqn 5
SIGNAL verify_code: std_logic; -- Signals if any of the bits is not 0 or 1
SIGNAL idata : std_logic_vector (N-1 downto 0);


BEGIN


	clock_state_machine:
	PROCESS(clk,rstb)
	BEGIN
	IF (rstb /= '1') THEN
	current_state <= ONRESET;
	ELSIF (clk'EVENT and clk = '1') THEN
	current_state <= next_state;
	END IF;
	END PROCESS clock_state_machine;



	sequential:
	PROCESS(clk,rstb)
	BEGIN

	CASE current_state IS
	
	WHEN ONRESET =>
		next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
		next_state <= PARITY_CHK1;
	ELSE
		next_state <= IDLE;
	END IF;

	
	WHEN PARITY_CHK1 =>
		next_state <= PARITY_CHK2;

	WHEN PARITY_CHK2 =>
		next_state <= PARITY_CHK3;

	WHEN PARITY_CHK3 =>
		next_state <= PARITY_CHK4;

	WHEN PARITY_CHK4 =>
	IF (pcheck1= 1.0) THEN
		next_state <= FIX_1;
	ELSIF (pcheck2 = 1.0) THEN
		next_state <= FIX_2;
	ELSIF (pcheck3 = 1.0) THEN
		next_state <= FIX_3;
	ELSIF (pcheck4 = 1.0) THEN
		next_state <= FIX_4;
	ELSIF (pcheck5 = 1.0) THEN
		next_state <= FIX_5;
	ELSIF (pcheck1= 0.0) and (pcheck2= 0.0) and (pcheck3= 0.0) and (pcheck4= 0.0) and (pcheck5= 0.0) THEN
		next_state <= DONE;
	ELSE
		next_state <= ERROR;
	END IF;

--------------------------------------------------------
	WHEN FIX_1 =>
	IF(pcheck2 = 1.0) THEN
		next_state <= FIX_2;
	ELSIF(pcheck3 = 1.0) THEN
		next_state <= FIX_3;
	ELSIF(pcheck4 = 1.0) THEN
		next_state <= FIX_4;
	ELSIF(pcheck5 = 1.0) THEN
		next_state <= FIX_5;
	ELSE
		next_state <= CODE_CHECK;
	END IF;
----------------------------------------------------------


	WHEN FIX_2 =>
	IF(pcheck3 = 1.0) THEN
		next_state <= FIX_3;
	ELSIF(pcheck4 = 1.0) THEN
		next_state <= FIX_4;
	ELSIF(pcheck5 = 1.0) THEN
		next_state <= FIX_5;
	ELSE
		next_state <= CODE_CHECK;
	END IF;
-----------------------------------------------------------


	WHEN FIX_3 =>
	IF(pcheck4 = 1.0) THEN
		next_state <= FIX_4;
	ELSIF(pcheck5 = 1.0) THEN
		next_state <= FIX_5;
	ELSE
		next_state <= CODE_CHECK;
	END IF;
	
------------------------------------------------------------

	WHEN FIX_4 =>
	IF(pcheck5 = 1.0) THEN
		next_state <= FIX_5;
	ELSE
		next_state <= CODE_CHECK;
	END IF;

-----------------------------------------------------------
	WHEN FIX_5 =>
		next_state <= CODE_CHECK;
----------------------------------------------------------

	WHEN CODE_CHECK =>
		next_state <= VERIFY;
-----------------------------------------------------------

	WHEN VERIFY =>
	IF(verify_code = '1') THEN
		next_state <= DONE;
	ELSE
		next_state <= PARITY_CHK1;
	END IF;
------------------------------------------------------------
	WHEN ERROR =>
		next_state <= ONRESET;


	WHEN DONE =>
		next_state <= ONRESET;


	WHEN OTHERS =>
		next_state <= ONRESET;


	END CASE;

	END PROCESS sequential;

------------------------------------------------------------

	combinational:
	PROCESS(clk, rstb)	
	BEGIN

	IF ( current_state = ONRESET) THEN
 		odata <= "UUUUUUUUUU" ;
		msg_pass_done <= 'U';
		verify_code<= '0'; 
		
	END IF;

	IF (current_state = IDLE) THEN
		idata <= error_data;
		pcheck1 <= 0.0;
		pcheck2 <= 0.0;
		pcheck3 <= 0.0;
		pcheck4 <= 0.0;
		pcheck5 <= 0.0;
		verify_code<= '0';
		
	
	END IF;

-------------------------------------------------------------(9) and (6)
	IF (current_state = PARITY_CHK1) THEN
	


	IF (idata(N-1) = 'X') or (idata(N-1) = 'U')  THEN
		pcheck2 <= pcheck2 + 0.5;
		pcheck3 <= pcheck3 + 0.5;
		pcheck5 <= pcheck5 + 0.5;
	ELSE
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck5 <= pcheck5;
	END IF;

	IF (idata(N-4) = 'X') or (idata(N-4) = 'U')  THEN
		pcheck1 <= pcheck1 + 0.5;
		pcheck4 <= pcheck4 + 0.5;
	ELSE
		pcheck1 <= pcheck1;
		pcheck4 <= pcheck4;
	END IF;


	END IF;
---------------------------------------------------------------(8) (3) (2) and (1)
	IF (current_state = PARITY_CHK2) THEN
	
	IF (idata(N-2) = 'X') or (idata(N-2) = 'U')  THEN
		pcheck1 <= pcheck1 + 0.5;
		pcheck5 <= pcheck5 + 0.5;
	ELSE
		pcheck1 <= pcheck1;
		pcheck5 <= pcheck5;
	END IF;

	IF (idata(N-7) = 'X') or (idata(N-7) = 'U') THEN
		pcheck2 <= pcheck2 + 0.5;
	ELSE
		pcheck2 <= pcheck2;
	END IF;

	IF (idata(N-8) = 'X') or (idata(N-8) = 'U') THEN
		pcheck3 <= pcheck3 + 0.5;
	ELSE
		pcheck3 <= pcheck3;
	END IF;

	IF (idata(N-9) = 'X') or (idata(N-9) = 'U') THEN
		pcheck4 <= pcheck4 + 0.5;
	ELSE
		pcheck4 <= pcheck4;
	END IF;


	END IF;
---------------------------------------------------------------(7)

	IF (current_state = PARITY_CHK3) THEN
	
	IF (idata(N-3) = 'X') or (idata(N-3) = 'U')  THEN
		pcheck1 <= pcheck1 + 0.5;
		pcheck2 <= pcheck2 + 0.5;
	    	pcheck3 <= pcheck3 + 0.5;
		pcheck4 <= pcheck4 + 0.5;
	ELSE
		pcheck1 <= pcheck1;
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
	END IF;

	IF (idata(N-10) = 'X') or (idata(N-5) = 'U') THEN
		pcheck5 <= pcheck5 + 0.5;
	ELSE
		pcheck5 <= pcheck5;
	END IF;

	END IF;

---------------------------------------------------------------(6)

	IF (current_state = PARITY_CHK4) THEN
	
	IF (idata(N-5) = 'X') or (idata(N-5) = 'U') THEN
	    	pcheck3 <= pcheck3 + 0.5;
		pcheck4 <= pcheck4 + 0.5;
		pcheck5 <= pcheck5 + 0.5;
	ELSE
	    	pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
		pcheck5 <= pcheck5;
	END IF;

	IF (idata(N-6) = 'X') or (idata(N-6) = 'U') THEN
		pcheck1 <= pcheck1 + 0.5;
	ELSE
		pcheck1 <= pcheck1;
	END IF;

	END IF;

-----------------------------------------------------------------------------


	IF ( current_state = FIX_1) THEN	

	IF( idata(N-2) /= '0') and (idata(N-2) /= '1') THEN 		--(8)
	idata(N-2) <=  idata(N-3) xor idata(N-4) xor idata(N-6);
	ELSIF( idata(N-3) = '0') and (idata(N-3) /= '1') THEN		--(7)
	idata(N-3) <=  idata(N-2) xor idata(N-4) xor idata(N-6);
	ELSIF( idata(N-4) /= '0') and (idata(N-4) /= '1') THEN		--(6)
	idata(N-4) <=  idata(N-2) xor idata(N-3) xor idata(N-6);
	ELSIF( idata(N-6) /= '0') and (idata(N-6) /= '1') THEN		--(4)
	idata(N-6) <=  idata(N-2) xor idata(N-3) xor idata(N-4);
	END IF;

	END IF;


	IF ( current_state = FIX_2) THEN	

	IF( idata(N-1) /= '0') and (idata(N-1) /= '1') THEN 		--(9)
	idata(N-1) <=  idata(N-3) xor idata(N-7);
	ELSIF( idata(N-3) /= '0') and (idata(N-3) /= '1') THEN		--(7)
	idata(N-3) <=  idata(N-1) xor idata(N-7);
	ELSIF( idata(N-7) /= '0') and (idata(N-7) /= '1') THEN		--(3)
	idata(N-7) <=  idata(N-1) xor idata(N-3);
	END IF;

	END IF;


	IF (current_state = FIX_3) THEN	

	IF( idata(N-1) /= '0') and (idata(N-1) /= '1') THEN 			--(9)
	idata(N-1) <=  idata(N-3) xor idata(N-5) xor idata(N-8);
	ELSIF( idata(N-3) /= '0') and (idata(N-3) /= '1') THEN			--(7)
	idata(N-3) <=  idata(N-1) xor idata(N-5) xor idata(N-8);
	ELSIF( idata(N-5) /= '0') and (idata(N-5) /= '1') THEN			--(5)
	idata(N-5) <=  idata(N-1) xor idata(N-3) xor idata(N-8);
	ELSIF( idata(N-8) /= '0') and (idata(N-8) /= '1') THEN			--(2)
	idata(N-8) <=  idata(N-1) xor idata(N-3) xor idata(N-5);
	END IF;

	END IF;


	IF ( current_state = FIX_4) THEN	

	IF( idata(N-3) /= '0') and (idata(N-3) /= '1') THEN 		--(7)
	idata(N-3) <=  idata(N-4) xor idata(N-5) xor idata(N-9);
	ELSIF( idata(N-4) /= '0') and (idata(N-4) /= '1') THEN		--(6)
	idata(N-4) <=  idata(N-3) xor idata(N-5) xor idata(N-9);
	ELSIF( idata(N-5) /= '0') and (idata(N-5) /= '1') THEN		--(5)
	idata(N-5) <=  idata(N-3) xor idata(N-4) xor idata(N-9);
	ELSIF( idata(N-9) /= '0') and (idata(N-9) /= '1') THEN		--(1)
	idata(N-9) <=  idata(N-3) xor idata(N-4) xor idata(N-5);
	END IF;

	END IF;



	IF ( current_state = FIX_5) THEN	

	IF( idata(N-1) /= '0') and (idata(N-1) /= '1') THEN 		--(9)
	idata(N-1) <=  idata(N-2) xor idata(N-5) xor idata(N-10);
	ELSIF( idata(N-2) /= '0') and (idata(N-2) /= '1') THEN		--(8)
	idata(N-2) <=  idata(N-1) xor idata(N-5) xor idata(N-10);
	ELSIF( idata(N-5) /= '0') and (idata(N-5) /= '1') THEN		--(5)
	idata(N-5) <=  idata(N-1) xor idata(N-2) xor idata(N-10);
	ELSIF( idata(N-10) /= '0') and (idata(N-10) /= '1') THEN	--(0)
	idata(N-10) <=  idata(N-1) xor idata(N-2) xor idata(N-5);
	END IF;

	END IF;


	IF ( current_state = CODE_CHECK) THEN
	IF ((idata(N-1) = '0') or (idata(N-1) = '1')) and
	   ((idata(N-2) = '0') or (idata(N-2) = '1')) and
           ((idata(N-3) = '0') or (idata(N-3) = '1')) and
           ((idata(N-4) = '0') or (idata(N-4) = '1')) and
           ((idata(N-5) = '0') or (idata(N-5) = '1')) and
           ((idata(N-6) = '0') or (idata(N-6) = '1')) and
           ((idata(N-7) = '0') or (idata(N-7) = '1')) and
           ((idata(N-8) = '0') or (idata(N-8) = '1')) and
           ((idata(N-9) = '0') or (idata(N-9) = '1')) and
           ((idata(N-10) = '0') or (idata(N-10) = '1')) THEN
	   verify_code <= '1';
	   ELSE
	   verify_code <= '0';
	   pcheck1 <= 0.0;
	   pcheck2 <= 0.0;
	   pcheck3 <= 0.0;
	   pcheck4 <= 0.0;
	   pcheck5 <= 0.0;
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


END behav;
