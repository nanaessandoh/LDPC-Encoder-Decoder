LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Decoder IS

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
	error_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	dec_done : OUT std_logic;
	output_data : OUT std_logic_vector (N-1 downto 0)
);

END Decoder;




ARCHITECTURE behav OF Decoder IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE,PARITY_CHK1,PARITY_CHK2,PARITY_CHK3,PARITY_CHK4,HOLD,FIX_1,FIX_2,FIX_3,FIX_4,FIX_5,CODE_CHECK,MP_VERIFY,DEC_VERIFY,DECODE,ERROR,DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL pCheck1, pCheck2, pCheck3, pCheck4, pCheck5 : integer; --Counts the number of Error in each P Check Eqn 1
SIGNAL dec_Code,mp_Code: std_logic; -- Signals if any of the bits is not 0 or 1
SIGNAL iData : std_logic_vector (C-1 downto 0);



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
	PROCESS(clk, rstb,current_state,dec_Code,mp_Code,pCheck1, pCheck2, pCheck3, pCheck4, pCheck5)
	BEGIN

	CASE current_state IS
	
	WHEN ONRESET =>
	next_state <= IDLE;

	WHEN IDLE =>
	IF(	error_data(9) /= 'U' or 
		error_data(8) /= 'U' or
		error_data(7) /= 'U' or
		error_data(6) /= 'U' or
		error_data(5) /= 'U' or
		error_data(4) /= 'U' or
		error_data(3) /= 'U' or
		error_data(2) /= 'U' or
		error_data(1) /= 'U' or
		error_data(0) /= 'U') THEN
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
	next_state <= HOLD;
--------------------------------------------------------------
-- At Hold we have determined the number of errors based on the
-- parity check equations so we can process to fix the error
--------------------------------------------------------------
	WHEN HOLD => 
	IF (pCheck1= 1) THEN
	next_state <= FIX_1;
	ELSIF (pCheck2 = 1) THEN
	next_state <= FIX_2;
	ELSIF (pCheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF (pCheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF (pCheck5 = 1) THEN
	next_state <= FIX_5;
	ELSIF (pCheck1 = 0) and (pCheck2 = 0) and (pCheck3 = 0) and (pCheck4 = 0) and (pCheck5 = 0) THEN
	next_state <= CODE_CHECK;
	ELSE
	next_state <= ERROR;
	END IF;

--------------------------------------------------------
	WHEN FIX_1 =>
	IF(pCheck2 = 1) THEN
	next_state <= FIX_2;
	ELSIF(pCheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF(pCheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pCheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
----------------------------------------------------------

	WHEN FIX_2 =>
	IF(pCheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF(pCheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pCheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
-----------------------------------------------------------


	WHEN FIX_3 =>
	IF(pCheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pCheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
	
------------------------------------------------------------

	WHEN FIX_4 =>
	IF(pCheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;

-----------------------------------------------------------
	WHEN FIX_5 =>
	next_state <= CODE_CHECK;
----------------------------------------------------------

	WHEN CODE_CHECK =>
	next_state <= MP_VERIFY;
-----------------------------------------------------------

	WHEN MP_VERIFY =>
	IF(mp_Code = '1') THEN
	next_state <= DEC_VERIFY;
	ELSE
	next_state <= PARITY_CHK1;
	END IF;
------------------------------------------------------------
	WHEN DEC_VERIFY =>
	IF(dec_Code = '1') THEN
	next_state <= DECODE;
	ELSIF (dec_Code = '0') THEN
	next_state <= ERROR;
	ELSE
	next_state <= DEC_VERIFY;
	END IF;
---------------------------------------
	WHEN DECODE =>
	next_state <= DONE;
-----------------------------------------------------------
	WHEN ERROR =>
	next_state <= IDLE;

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

	IF ( clk'EVENT and clk = '0') THEN

	IF ( current_state = ONRESET) THEN
 		output_data <= (OTHERS => 'U');
		dec_Code <= 'U';
		mp_Code <= 'U'; 
		iData <= (OTHERS => 'U');
		
	END IF;

	IF (current_state = IDLE) THEN
		dec_done <= '0';
		output_data <= (OTHERS => 'U');
		pCheck1 <= 0;
		pCheck2 <= 0;
		pCheck3 <= 0;
		pCheck4 <= 0;
		pCheck5 <= 0;
	IF(	error_data(9) /= 'U' or 
		error_data(8) /= 'U' or
		error_data(7) /= 'U' or
		error_data(6) /= 'U' or
		error_data(5) /= 'U' or
		error_data(4) /= 'U' or
		error_data(3) /= 'U' or
		error_data(2) /= 'U' or
		error_data(1) /= 'U' or
		error_data(0) /= 'U') THEN
		iData <= error_data;
		END IF;
		END IF;

-------------------------------------------------------------(9) and (6)
	IF (current_state = PARITY_CHK1) THEN
	
	IF  (iData(C-1) /= '0') and (iData(C-1) /= '1')  THEN
		pCheck2 <= pCheck2 + 1;
		pCheck3 <= pCheck3 + 1;
		pCheck5 <= pCheck5 + 1;
	ELSE
		pCheck2 <= pCheck2;
		pCheck3 <= pCheck3;
		pCheck5 <= pCheck5;
	END IF;

	IF  (iData(C-4) /= '0') and (iData(C-4) /= '1')  THEN
		pCheck1 <= pCheck1 + 1;
		pCheck4 <= pCheck4 + 1;
	ELSE
		pCheck1 <= pCheck1;
		pCheck4 <= pCheck4;
	END IF;


	END IF;
---------------------------------------------------------------(8) (3) (2) and (1)
	IF (current_state = PARITY_CHK2) THEN
	
	IF  (iData(C-2) /= '0') and (iData(C-2) /= '1')  THEN
		pCheck1 <= pCheck1 + 1;
		pCheck5 <= pCheck5 + 1;
	ELSE
		pCheck1 <= pCheck1;
		pCheck5 <= pCheck5;
	END IF;

	IF  (iData(C-7) /= '0') and (iData(C-7) /= '1') THEN
		pCheck2 <= pCheck2 + 1;
	ELSE
		pCheck2 <= pCheck2;
	END IF;

	IF  (iData(C-8) /= '0') and (iData(C-8) /= '1') THEN
		pCheck3 <= pCheck3 + 1;
	ELSE
		pCheck3 <= pCheck3;
	END IF;

	IF  (iData(C-9) /= '0') and (iData(C-9) /= '1') THEN
		pCheck4 <= pCheck4 + 1;
	ELSE
		pCheck4 <= pCheck4;
	END IF;


	END IF;
---------------------------------------------------------------(7) (0)

	IF (current_state = PARITY_CHK3) THEN
	
	IF  (iData(C-3) /= '0') and (iData(C-3) /= '1') THEN
		pCheck1 <= pCheck1 + 1;
		pCheck2 <= pCheck2 + 1;
	    	pCheck3 <= pCheck3 + 1;
		pCheck4 <= pCheck4 + 1;
	ELSE
		pCheck1 <= pCheck1;
		pCheck2 <= pCheck2;
		pCheck3 <= pCheck3;
		pCheck4 <= pCheck4;
	END IF;

	IF  (iData(C-10) /= '0') and (iData(C-10) /= '1') THEN
		pCheck5 <= pCheck5 + 1;
	ELSE
		pCheck5 <= pCheck5;
	END IF;

	END IF;

---------------------------------------------------------------(5) and (4)

	IF (current_state = PARITY_CHK4) THEN
	
	IF  (iData(C-5) /= '0') and (iData(C-5) /= '1') THEN
	    	pCheck3 <= pCheck3 + 1;
		pCheck4 <= pCheck4 + 1;
		pCheck5 <= pCheck5 + 1;
	ELSE
	    	pCheck3 <= pCheck3;
		pCheck4 <= pCheck4;
		pCheck5 <= pCheck5;
	END IF;

	IF  (iData(C-6) /= '0') and (iData(C-6) /= '1') THEN
		pCheck1 <= pCheck1 + 1;
	ELSE
		pCheck1 <= pCheck1;
	END IF;

	END IF;

-----------------------------------------------------------------------------


	IF (current_state = FIX_1) THEN	

	IF (iData(C-2) /= '0') and (iData(C-2) /= '1') THEN 		--(8)
	iData(C-2) <=  iData(C-3) xor iData(C-4) xor iData(C-6);
	ELSIF( iData(C-3) = '0') and (iData(C-3) /= '1') THEN		--(7)
	iData(C-3) <=  iData(C-2) xor iData(C-4) xor iData(C-6);
	ELSIF( iData(C-4) /= '0') and (iData(C-4) /= '1') THEN		--(6)
	iData(C-4) <=  iData(C-2) xor iData(C-3) xor iData(C-6);
	ELSIF( iData(C-6) /= '0') and (iData(C-6) /= '1') THEN		--(4)
	iData(C-6) <=  iData(C-2) xor iData(C-3) xor iData(C-4);
	END IF;

	END IF;


	IF ( current_state = FIX_2) THEN	

	IF( iData(C-1) /= '0') and (iData(C-1) /= '1') THEN 		--(9)
	iData(C-1) <=  iData(C-3) xor iData(C-7);
	ELSIF( iData(C-3) /= '0') and (iData(C-3) /= '1') THEN		--(7)
	iData(C-3) <=  iData(C-1) xor iData(C-7);
	ELSIF( iData(C-7) /= '0') and (iData(C-7) /= '1') THEN		--(3)
	iData(C-7) <=  iData(C-1) xor iData(C-3);
	END IF;

	END IF;


	IF (current_state = FIX_3) THEN	

	IF( iData(C-1) /= '0') and (iData(C-1) /= '1') THEN 			--(9)
	iData(C-1) <=  iData(C-3) xor iData(C-5) xor iData(C-8);
	ELSIF( iData(C-3) /= '0') and (iData(C-3) /= '1') THEN			--(7)
	iData(C-3) <=  iData(C-1) xor iData(C-5) xor iData(C-8);
	ELSIF( iData(C-5) /= '0') and (iData(C-5) /= '1') THEN			--(5)
	iData(C-5) <=  iData(C-1) xor iData(C-3) xor iData(C-8);
	ELSIF( iData(C-8) /= '0') and (iData(C-8) /= '1') THEN			--(2)
	iData(C-8) <=  iData(C-1) xor iData(C-3) xor iData(C-5);
	END IF;

	END IF;


	IF ( current_state = FIX_4) THEN	

	IF( iData(C-3) /= '0') and (iData(C-3) /= '1') THEN 		--(7)
	iData(C-3) <=  iData(C-4) xor iData(C-5) xor iData(C-9);
	ELSIF( iData(C-4) /= '0') and (iData(C-4) /= '1') THEN		--(6)
	iData(C-4) <=  iData(C-3) xor iData(C-5) xor iData(C-9);
	ELSIF( iData(C-5) /= '0') and (iData(C-5) /= '1') THEN		--(5)
	iData(C-5) <=  iData(C-3) xor iData(C-4) xor iData(C-9);
	ELSIF( iData(C-9) /= '0') and (iData(C-9) /= '1') THEN		--(1)
	iData(C-9) <=  iData(C-3) xor iData(C-4) xor iData(C-5);
	END IF;

	END IF;



	IF ( current_state = FIX_5) THEN	

	IF( iData(C-1) /= '0') and (iData(C-1) /= '1') THEN 		--(9)
	iData(C-1) <=  iData(C-2) xor iData(C-5) xor iData(C-10);
	ELSIF( iData(C-2) /= '0') and (iData(C-2) /= '1') THEN		--(8)
	iData(C-2) <=  iData(C-1) xor iData(C-5) xor iData(C-10);
	ELSIF( iData(C-5) /= '0') and (iData(C-5) /= '1') THEN		--(5)
	iData(C-5) <=  iData(C-1) xor iData(C-2) xor iData(C-10);
	ELSIF( iData(C-10) /= '0') and (iData(C-10) /= '1') THEN	--(0)
	iData(C-10) <=  iData(C-1) xor iData(C-2) xor iData(C-5);
	END IF;

	END IF;


	IF ( current_state = CODE_CHECK) THEN
	IF ((iData(C-1) = '0') or (iData(C-1) = '1')) and
	   ((iData(C-2) = '0') or (iData(C-2) = '1')) and
           ((iData(C-3) = '0') or (iData(C-3) = '1')) and
           ((iData(C-4) = '0') or (iData(C-4) = '1')) and
           ((iData(C-5) = '0') or (iData(C-5) = '1')) and
           ((iData(C-6) = '0') or (iData(C-6) = '1')) and
           ((iData(C-7) = '0') or (iData(C-7) = '1')) and
           ((iData(C-8) = '0') or (iData(C-8) = '1')) and
           ((iData(C-9) = '0') or (iData(C-9) = '1')) and
           ((iData(C-10) = '0') or (iData(C-10) = '1')) THEN
	   mp_Code <= '1';
	   ELSE
	   mp_Code <= '0';
	   pCheck1 <= 0;
	   pCheck2 <= 0;
	   pCheck3 <= 0;
	   pCheck4 <= 0;
	   pCheck5 <= 0;
	   END IF;
	   END IF;


	IF (current_state = DEC_VERIFY) THEN
	IF (iData = "0000000000") THEN   --1
	dec_Code <= '1';
	ELSIF (iData = "0000100111") THEN --2
	dec_Code <= '1';
	ELSIF (iData = "0001010010") THEN --3
	dec_Code <= '1';
	ELSIF (iData = "0001110101") THEN --4
	dec_Code <= '1';
	ELSIF (iData = "0010011110") THEN --5
	dec_Code <= '1';
	ELSIF (iData = "0010111001") THEN --6
	dec_Code <= '1';
	ELSIF (iData = "0011001100") THEN --7
	dec_Code <= '1';
	ELSIF (iData = "0011101011") THEN --8
	dec_Code <= '1';
	ELSIF (iData = "0100010001") THEN --9
	dec_Code <= '1';
	ELSIF (iData = "0100110110") THEN --10
	dec_Code <= '1';
	ELSIF (iData = "0101000011") THEN --11
	dec_Code <= '1';
	ELSIF (iData = "0101100100") THEN --12
	dec_Code <= '1';
	ELSIF (iData = "0110001111") THEN --13
	dec_Code <= '1';
	ELSIF (iData = "0110101000") THEN --14
	dec_Code <= '1';
	ELSIF (iData = "0111011101") THEN --15
	dec_Code <= '1';
	ELSIF (iData = "0111111010") THEN --16
	dec_Code <= '1';
	ELSIF (iData = "1000001101") THEN --17
	dec_Code <= '1';
	ELSIF (iData = "1000101010") THEN --18
	dec_Code <= '1';
	ELSIF (iData = "1001011111") THEN --19
	dec_Code <= '1';
	ELSIF (iData = "1001111000") THEN --20
	dec_Code <= '1';
	ELSIF (iData = "1010010011") THEN --21
	dec_Code <= '1';
	ELSIF (iData = "1010110100") THEN --22
	dec_Code <= '1';
	ELSIF (iData = "1011000001") THEN --23
	dec_Code <= '1';
	ELSIF (iData = "1011100110") THEN --24
	dec_Code <= '1';
	ELSIF (iData = "1100011100") THEN --25
	dec_Code <= '1';
	ELSIF (iData = "1100111011") THEN --26
	dec_Code <= '1';
	ELSIF (iData = "1101001110") THEN --27
	dec_Code <= '1';
	ELSIF (iData = "1101101001") THEN --28
	dec_Code <= '1';
	ELSIF (iData = "1110000010") THEN --29
	dec_Code <= '1';
	ELSIF (iData = "1110100101") THEN --30
	dec_Code <= '1';
	ELSIF (iData = "1111010000") THEN --31
	dec_Code <= '1';
	ELSIF (iData = "1111110111") THEN --32
	dec_Code <= '1';
	ELSE
	dec_Code <= '0';
	END IF;
	END IF;


	IF (current_state = DECODE) THEN
	dec_done <= '1';
	output_data <= iData(C-1 downto C-5);
	ELSE 
	dec_done <= '0';
	output_data <= (OTHERS => 'U');
	END IF;



	END IF;

	END PROCESS combinational;


END behav;
