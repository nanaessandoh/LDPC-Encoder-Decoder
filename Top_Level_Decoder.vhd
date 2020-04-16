LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Top_Decoder IS

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
	error_data : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	dec_done : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto 0)
);

END Top_Decoder;




ARCHITECTURE behav OF Top_Decoder IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE, PARITY_CHK1, PARITY_CHK2, PARITY_CHK3, PARITY_CHK4, HOLD, FIX_1, FIX_2, FIX_3, FIX_4, FIX_5, CODE_CHECK, MP_VERIFY, DEC_VERIFY, DECODE, ERROR, DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL pcheck1, pcheck2, pcheck3, pcheck4, pcheck5 : integer; --Counts the number of Error in each P Check Eqn 1
SIGNAL dec_code,mp_code: std_logic; -- Signals if any of the bits is not 0 or 1
SIGNAL idata : std_logic_vector (C-1 downto 0);


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
	PROCESS(clk, rstb,current_state,isop,dec_code,mp_code,pcheck1, pcheck2, pcheck3, pcheck4, pcheck5)
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
	next_state <= HOLD;
--------------------------------------------------------------
-- At Hold we have determined the number of errors based on the
-- parity check equations so we can process to fix the error
--------------------------------------------------------------
	WHEN HOLD => 
	IF (pcheck1= 1) THEN
	next_state <= FIX_1;
	ELSIF (pcheck2 = 1) THEN
	next_state <= FIX_2;
	ELSIF (pcheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF (pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF (pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSIF (pcheck1 = 0) and (pcheck2 = 0) and (pcheck3 = 0) and (pcheck4 = 0) and (pcheck5 = 0) THEN
	next_state <= DONE;
	ELSE
	next_state <= ERROR;
	END IF;

--------------------------------------------------------
	WHEN FIX_1 =>
	IF(pcheck2 = 1) THEN
	next_state <= FIX_2;
	ELSIF(pcheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF(pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
----------------------------------------------------------

	WHEN FIX_2 =>
	IF(pcheck3 = 1) THEN
	next_state <= FIX_3;
	ELSIF(pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
-----------------------------------------------------------


	WHEN FIX_3 =>
	IF(pcheck4 = 1) THEN
	next_state <= FIX_4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX_5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
	
------------------------------------------------------------

	WHEN FIX_4 =>
	IF(pcheck5 = 1) THEN
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
	IF(mp_code = '1') THEN
	next_state <= DEC_VERIFY;
	ELSE
	next_state <= PARITY_CHK1;
	END IF;
------------------------------------------------------------
	WHEN DEC_VERIFY =>
	IF(dec_code = '1') THEN
	next_state <= DECODE;
	ELSIF (dec_code = '0') THEN
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
 		odata <= (OTHERS => 'U') ;
		dec_code<= 'U'; 
		
	END IF;

	IF (current_state = IDLE) THEN
		idata <= error_data;
		pcheck1 <= 0;
		pcheck2 <= 0;
		pcheck3 <= 0;
		pcheck4 <= 0;
		pcheck5 <= 0;
		dec_code<= '0';
	END IF;

-------------------------------------------------------------(9) and (6)
	IF (current_state = PARITY_CHK1) THEN
	


	IF  (idata(C-1) /= '0') and (idata(C-1) /= '1')  THEN
		pcheck2 <= pcheck2 + 1;
		pcheck3 <= pcheck3 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck5 <= pcheck5;
	END IF;

	IF  (idata(C-4) /= '0') and (idata(C-4) /= '1')  THEN
		pcheck1 <= pcheck1 + 1;
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck4 <= pcheck4;
	END IF;


	END IF;
---------------------------------------------------------------(8) (3) (2) and (1)
	IF (current_state = PARITY_CHK2) THEN
	
	IF  (idata(C-2) /= '0') and (idata(C-2) /= '1')  THEN
		pcheck1 <= pcheck1 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck5 <= pcheck5;
	END IF;

	IF  (idata(C-7) /= '0') and (idata(C-7) /= '1') THEN
		pcheck2 <= pcheck2 + 1;
	ELSE
		pcheck2 <= pcheck2;
	END IF;

	IF  (idata(C-8) /= '0') and (idata(C-8) /= '1') THEN
		pcheck3 <= pcheck3 + 1;
	ELSE
		pcheck3 <= pcheck3;
	END IF;

	IF  (idata(C-9) /= '0') and (idata(C-9) /= '1') THEN
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck4 <= pcheck4;
	END IF;


	END IF;
---------------------------------------------------------------(7) (0)

	IF (current_state = PARITY_CHK3) THEN
	
	IF  (idata(C-3) /= '0') and (idata(C-3) /= '1') THEN
		pcheck1 <= pcheck1 + 1;
		pcheck2 <= pcheck2 + 1;
	    	pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
	END IF;

	IF  (idata(C-10) /= '0') and (idata(C-10) /= '1') THEN
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck5 <= pcheck5;
	END IF;

	END IF;

---------------------------------------------------------------(5) and (4)

	IF (current_state = PARITY_CHK4) THEN
	
	IF  (idata(C-5) /= '0') and (idata(C-5) /= '1') THEN
	    	pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
	    	pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
		pcheck5 <= pcheck5;
	END IF;

	IF  (idata(C-6) /= '0') and (idata(C-6) /= '1') THEN
		pcheck1 <= pcheck1 + 1;
	ELSE
		pcheck1 <= pcheck1;
	END IF;

	END IF;

-----------------------------------------------------------------------------


	IF (current_state = FIX_1) THEN	

	IF (idata(C-2) /= '0') and (idata(C-2) /= '1') THEN 		--(8)
	idata(C-2) <=  idata(C-3) xor idata(C-4) xor idata(C-6);
	ELSIF( idata(C-3) = '0') and (idata(C-3) /= '1') THEN		--(7)
	idata(C-3) <=  idata(C-2) xor idata(C-4) xor idata(C-6);
	ELSIF( idata(C-4) /= '0') and (idata(C-4) /= '1') THEN		--(6)
	idata(C-4) <=  idata(C-2) xor idata(C-3) xor idata(C-6);
	ELSIF( idata(C-6) /= '0') and (idata(C-6) /= '1') THEN		--(4)
	idata(C-6) <=  idata(C-2) xor idata(C-3) xor idata(C-4);
	END IF;

	END IF;


	IF ( current_state = FIX_2) THEN	

	IF( idata(C-1) /= '0') and (idata(C-1) /= '1') THEN 		--(9)
	idata(C-1) <=  idata(C-3) xor idata(C-7);
	ELSIF( idata(C-3) /= '0') and (idata(C-3) /= '1') THEN		--(7)
	idata(C-3) <=  idata(C-1) xor idata(C-7);
	ELSIF( idata(C-7) /= '0') and (idata(C-7) /= '1') THEN		--(3)
	idata(C-7) <=  idata(C-1) xor idata(C-3);
	END IF;

	END IF;


	IF (current_state = FIX_3) THEN	

	IF( idata(C-1) /= '0') and (idata(C-1) /= '1') THEN 			--(9)
	idata(C-1) <=  idata(C-3) xor idata(C-5) xor idata(C-8);
	ELSIF( idata(C-3) /= '0') and (idata(C-3) /= '1') THEN			--(7)
	idata(C-3) <=  idata(C-1) xor idata(C-5) xor idata(C-8);
	ELSIF( idata(C-5) /= '0') and (idata(C-5) /= '1') THEN			--(5)
	idata(C-5) <=  idata(C-1) xor idata(C-3) xor idata(C-8);
	ELSIF( idata(C-8) /= '0') and (idata(C-8) /= '1') THEN			--(2)
	idata(C-8) <=  idata(C-1) xor idata(C-3) xor idata(C-5);
	END IF;

	END IF;


	IF ( current_state = FIX_4) THEN	

	IF( idata(C-3) /= '0') and (idata(C-3) /= '1') THEN 		--(7)
	idata(C-3) <=  idata(C-4) xor idata(C-5) xor idata(C-9);
	ELSIF( idata(C-4) /= '0') and (idata(C-4) /= '1') THEN		--(6)
	idata(C-4) <=  idata(C-3) xor idata(C-5) xor idata(C-9);
	ELSIF( idata(C-5) /= '0') and (idata(C-5) /= '1') THEN		--(5)
	idata(C-5) <=  idata(C-3) xor idata(C-4) xor idata(C-9);
	ELSIF( idata(C-9) /= '0') and (idata(C-9) /= '1') THEN		--(1)
	idata(C-9) <=  idata(C-3) xor idata(C-4) xor idata(C-5);
	END IF;

	END IF;



	IF ( current_state = FIX_5) THEN	

	IF( idata(C-1) /= '0') and (idata(C-1) /= '1') THEN 		--(9)
	idata(C-1) <=  idata(C-2) xor idata(C-5) xor idata(C-10);
	ELSIF( idata(C-2) /= '0') and (idata(C-2) /= '1') THEN		--(8)
	idata(C-2) <=  idata(C-1) xor idata(C-5) xor idata(C-10);
	ELSIF( idata(C-5) /= '0') and (idata(C-5) /= '1') THEN		--(5)
	idata(C-5) <=  idata(C-1) xor idata(C-2) xor idata(C-10);
	ELSIF( idata(C-10) /= '0') and (idata(C-10) /= '1') THEN	--(0)
	idata(C-10) <=  idata(C-1) xor idata(C-2) xor idata(C-5);
	END IF;

	END IF;


	IF ( current_state = CODE_CHECK) THEN
	IF ((idata(C-1) = '0') or (idata(C-1) = '1')) and
	   ((idata(C-2) = '0') or (idata(C-2) = '1')) and
           ((idata(C-3) = '0') or (idata(C-3) = '1')) and
           ((idata(C-4) = '0') or (idata(C-4) = '1')) and
           ((idata(C-5) = '0') or (idata(C-5) = '1')) and
           ((idata(C-6) = '0') or (idata(C-6) = '1')) and
           ((idata(C-7) = '0') or (idata(C-7) = '1')) and
           ((idata(C-8) = '0') or (idata(C-8) = '1')) and
           ((idata(C-9) = '0') or (idata(C-9) = '1')) and
           ((idata(C-10) = '0') or (idata(C-10) = '1')) THEN
	   mp_code <= '1';
	   ELSE
	   mp_code <= '0';
	   pcheck1 <= 0;
	   pcheck2 <= 0;
	   pcheck3 <= 0;
	   pcheck4 <= 0;
	   pcheck5 <= 0;
	   END IF;
	   END IF;


	IF (current_state = DEC_VERIFY) THEN
	IF (idata = "0000000000") THEN   --1
	dec_code <= '1';
	ELSIF (idata = "0000100111") THEN --2
	dec_code <= '1';
	ELSIF (idata = "0001010010") THEN --3
	dec_code <= '1';
	ELSIF (idata = "0001110101") THEN --4
	dec_code <= '1';
	ELSIF (idata = "0010011110") THEN --5
	dec_code <= '1';
	ELSIF (idata = "0010111001") THEN --6
	dec_code <= '1';
	ELSIF (idata = "0011001100") THEN --7
	dec_code <= '1';
	ELSIF (idata = "0011101011") THEN --8
	dec_code <= '1';
	ELSIF (idata = "0100010001") THEN --9
	dec_code <= '1';
	ELSIF (idata = "0100110110") THEN --10
	dec_code <= '1';
	ELSIF (idata = "0101000011") THEN --11
	dec_code <= '1';
	ELSIF (idata = "0101100100") THEN --12
	dec_code <= '1';
	ELSIF (idata = "0110001111") THEN --13
	dec_code <= '1';
	ELSIF (idata = "0110101000") THEN --14
	dec_code <= '1';
	ELSIF (idata = "0111011101") THEN --15
	dec_code <= '1';
	ELSIF (idata = "0111111010") THEN --16
	dec_code <= '1';
	ELSIF (idata = "1000001101") THEN --17
	dec_code <= '1';
	ELSIF (idata = "1000101010") THEN --18
	dec_code <= '1';
	ELSIF (idata = "1001011111") THEN --19
	dec_code <= '1';
	ELSIF (idata = "1001111000") THEN --20
	dec_code <= '1';
	ELSIF (idata = "1010010011") THEN --21
	dec_code <= '1';
	ELSIF (idata = "1010110100") THEN --22
	dec_code <= '1';
	ELSIF (idata = "1011000001") THEN --23
	dec_code <= '1';
	ELSIF (idata = "1011100110") THEN --24
	dec_code <= '1';
	ELSIF (idata = "1100011100") THEN --25
	dec_code <= '1';
	ELSIF (idata = "1100111011") THEN --26
	dec_code <= '1';
	ELSIF (idata = "1101001110") THEN --27
	dec_code <= '1';
	ELSIF (idata = "1101101001") THEN --28
	dec_code <= '1';
	ELSIF (idata = "1110000010") THEN --29
	dec_code <= '1';
	ELSIF (idata = "1110100101") THEN --30
	dec_code <= '1';
	ELSIF (idata = "1111010000") THEN --31
	dec_code <= '1';
	ELSIF (idata = "1111110111") THEN --32
	dec_code <= '1';
	ELSE
	dec_code <= '0';
	END IF;
	END IF;


	IF (current_state = DECODE) THEN
	dec_done <= '1';
	odata <= idata(C-1 downto C-5);
	ELSE 
	dec_done <= '0';
	odata <= (OTHERS => 'U');
	END IF;


	IF ( current_state = DONE) THEN
	dec_done <= '1';
	odata <= idata(C-1 downto C-5);
	ELSE 
	dec_done <= '0';
	odata <= (OTHERS => 'U');
	END IF;


	END IF;

	END PROCESS combinational;


END behav;
