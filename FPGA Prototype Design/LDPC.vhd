-- The Top Level of the LDPC Encoder, Bit Erasure Channel and Message Passing Decoder
-- On the FPGA Board X and U cannot be simulated on the board so each 5 bit is encoded to a 20 Bit codeword
-- 00 for a 0, 11 for a 1, 10 for a U, and 01 for an X
  
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY LDPC IS

PORT(
	-- Clock and Reset
	CLOCK_50 : IN std_logic;

	-- Input Interface I/O
	KEY : IN std_logic_vector(3 downto 0); -- Push Buttons
 	SW : IN std_logic_vector(9 downto 0); -- Switches

	-- Output Interface I/O
	HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : OUT std_logic_vector(6 downto 0); -- HEX Displays
	LEDR : OUT std_logic_vector (9 downto 0) -- LED Lights
);

END LDPC;


ARCHITECTURE behav OF LDPC IS
-- Component in the Design
COMPONENT Seven_Segment IS

PORT(
	SW : IN std_logic_vector(3 downto 0);
	HEX0 : OUT std_logic_vector(6 downto 0)
);

END COMPONENT;


COMPONENT Hex_Controller IS
  PORT( CLOCK_50 : IN std_logic;
	MODE : IN std_logic_vector(3 downto 0); 
        SW: IN  std_logic_vector(9 downto 0); 
	CODE_INPUT : IN  std_logic_vector(19 downto 0); -- Codeword Bits
	MSG_OUT: OUT  std_logic_vector(4 downto 0); -- Message Bit
	DIGIT5,DIGIT4,DIGIT3,DIGIT2,DIGIT1,DIGIT0: OUT std_logic_vector(3 downto 0)
);
END COMPONENT;


COMPONENT Counter5bit IS
  port( CLOCK_50, EN: IN std_logic;
	UB : IN std_logic_vector(4 downto 0); -- Upper bound of counter
        COUNT: OUT  std_logic_vector(4 downto 0) -- Output of Counter
	);
END COMPONENT;

COMPONENT COUNT1S IS
  port( CLOCK_50: IN std_logic;
        CNT50M: OUT std_logic);
END COMPONENT;


COMPONENT LED_Controller IS
PORT(
	SW : IN std_logic_vector(19 downto 0);
	LEDR : OUT std_logic_vector(9 downto 0)
);
END COMPONENT;



FUNCTION Conv_To_20 (input1 :std_logic_vector(4 downto 0)) RETURN std_logic_vector IS
BEGIN 
  CASE input1 IS
                  WHEN "00000" => RETURN "00000000000000000000";
                  WHEN "00001" => RETURN "00000000110000111111";
                  WHEN "00010" => RETURN "00000011001100001100";
                  WHEN "00011" => RETURN "00000011111100110011";
                  WHEN "00100" => RETURN "00001100001111111100";
                  WHEN "00101" => RETURN "00001100111111000011";
                  WHEN "00110" => RETURN "00001111000011110000";
                  WHEN "00111" => RETURN "00001111110011001111";
                  WHEN "01000" => RETURN "00110000001100000011";
                  WHEN "01001" => RETURN "00110000111100111100";
                  WHEN "01010" => RETURN "00110011000000001111";
                  WHEN "01011" => RETURN "00110011110000110000";
                  WHEN "01100" => RETURN "00111100000011111111";
                  WHEN "01101" => RETURN "00111100110011000000";
                  WHEN "01110" => RETURN "00111111001111110011";
                  WHEN "01111" => RETURN "00111111111111001100";
                  WHEN "10000" => RETURN "11000000000011110011";
                  WHEN "10001" => RETURN "11000000110011001100";
                  WHEN "10010" => RETURN "11000011001111111111";
                  WHEN "10011" => RETURN "11000011111111000000";
                  WHEN "10100" => RETURN "11001100001100001111";
                  WHEN "10101" => RETURN "11001100111100110000";
                  WHEN "10110" => RETURN "11001111000000000011";
                  WHEN "10111" => RETURN "11001111110000111100";
                  WHEN "11000" => RETURN "11110000001111110000";
                  WHEN "11001" => RETURN "11110000111111001111";
                  WHEN "11010" => RETURN "11110011000011111100";
                  WHEN "11011" => RETURN "11110011110011000011";
                  WHEN "11100" => RETURN "11111100000000001100";
                  WHEN "11101" => RETURN "11111100110000110011";
                  WHEN "11110" => RETURN "11111111001100000000";
                  WHEN "11111" => RETURN "11111111111111111111";
		  WHEN OTHERS => RETURN "00000000000000000000";     
END CASE; 
END Conv_To_20; 




-- Define State of the State Machine
TYPE state_type IS (ONRESET, STEP1, MSG_IN,ENCODE,STEP2,DISPLAY_CODE1,STEP3,ADD_ERROR,DISPLAY_CODE2,STEP4,PK1,PK2,PK3,PK4,HOLD,FIX1,FIX2,FIX3,FIX4,FIX5,CODE_CHECK,VERIFY,STEP5,DISPLAY_CODE3,ERROR,DONE);

-- Define the types for my hex screen
type hex_display is array (9 downto 0) of std_logic_vector (6 downto 0);


--Signal Declaration
SIGNAL current_state, next_state : state_type;
SIGNAL verify_msg_pass: std_logic := '0';
SIGNAL hex_mode : std_logic_vector(3 downto 0) := "0000"; 
SIGNAL msg_word : std_logic_vector(4 downto 0) := "00000";
SIGNAL code_word, code_word_i : std_logic_vector(19 downto 0) := "00000000000000000000";
SIGNAL pcheck1, pcheck2, pcheck3, pcheck4, pcheck5 : integer := 0; --Counts the number of Error in each P Check Eqn
SIGNAL Input0, Input1, Input2, Input3, Input4, Input5 : std_logic_vector(3 downto 0) := "0000";
SIGNAL Upper_B: std_logic_vector(4 downto 0) := "00001";
SIGNAL	Count_S: std_logic_vector(4 downto 0) := "00001";
signal start_counter: std_logic := '0'; 




BEGIN

	-- Clock the State Machine
	clock_state_machine:
	PROCESS(CLOCK_50, KEY(3))
	BEGIN
	IF (KEY(3) = '0') THEN
	current_state <= ONRESET;
	ELSIF (CLOCK_50'EVENT and CLOCK_50 = '1') THEN
	current_state <= next_state;
	END IF;
	END PROCESS clock_state_machine;


--------------------------------------------------------------
----------------- SEQUENTIAL LOGIC
--------------------------------------------------------------

	sequential:
	PROCESS(CLOCK_50, KEY(3),current_state,Count_S,pcheck1,pcheck2,pcheck3,pcheck4,pcheck5,verify_msg_pass)
	BEGIN

	CASE current_state IS
	
-----------------------------------------------------------------
	WHEN ONRESET =>
	hex_mode <= "0000";
	next_state <= STEP1;
	Upper_B <= "00011";
-----------------------------------------------------------------
	WHEN STEP1 => -- 3 seconds
	IF(Count_S = "00000") THEN
	next_state <= MSG_IN;
	Upper_B <= "00110"; 
	ELSE
	next_state <= STEP1;
	hex_mode <= "0001";
	END IF;
-----------------------------------------------------------------
	WHEN MSG_IN => -- 6 seconds
	IF(Count_S = "00000") THEN
	next_state <= ENCODE;
	Upper_B <= "00101"; 
	ELSE
	next_state <= MSG_IN;
	hex_mode <= "0110";
	END IF;
-----------------------------------------------------------------
	WHEN ENCODE =>
	next_state <= STEP2;
	Upper_B <= "00011";
-----------------------------------------------------------------
	WHEN STEP2 => -- 3 seconds
	IF(Count_S = "00000") THEN
	next_state <= DISPLAY_CODE1;
	Upper_B <= "01110"; 
	ELSE
	next_state <= STEP2;
	hex_mode <= "0010";
	END IF;
------------------------------------------------------------------
	WHEN DISPLAY_CODE1 => -- 15 seconds
	IF(Count_S = "00000") THEN
	next_state <= STEP3;
	Upper_B <= "00011";  
	ELSE
	next_state <= DISPLAY_CODE1;
	hex_mode <= "0111";
	END IF;

------------------------------------------------------------------
	WHEN STEP3 => -- 3 seconds
	IF(Count_S = "00000") THEN
	next_state <= ADD_ERROR;
	Upper_B <= "01000"; 
	ELSE
	next_state <= STEP3;
	hex_mode <= "0011";
	END IF;
-------------------------------------------------------------------
	WHEN ADD_ERROR => -- 8 seconds
	IF(Count_S = "00000") THEN
	next_state <= DISPLAY_CODE2;
	Upper_B <= "01110"; 
	ELSE
	next_state <= ADD_ERROR;
	hex_mode <= "1001";
	END IF;
-------------------------------------------------------------------
	WHEN DISPLAY_CODE2 => -- 15 seconds
	IF(Count_S = "00000") THEN
	next_state <= STEP4;
	Upper_B <= "00011";  
	ELSE
	next_state <= DISPLAY_CODE2;
	hex_mode <= "0111";
	END IF;
--------------------------------------------------------------------
	WHEN STEP4 => -- 3 seconds
	IF(Count_S = "00000") THEN
	next_state <= PK1;
	Upper_B <= "00011"; 
	ELSE
	next_state <= STEP4;
	hex_mode <= "0100";
	END IF;
--------------------------------------------------------------------
	WHEN PK1 => next_state <= PK2;	
	WHEN PK2 => next_state <= PK3;	
	WHEN PK3 => next_state <= PK4;
	WHEN PK4 => next_state <= HOLD;
--------------------------------------------------------------
-- At Hold we have determined the number of errors based on the
-- parity check equations so we can process to fix the error
--------------------------------------------------------------
	WHEN HOLD => 
	IF (pcheck1= 1) THEN
	next_state <= FIX1;
	ELSIF (pcheck2 = 1) THEN
	next_state <= FIX2;
	ELSIF (pcheck3 = 1) THEN
	next_state <= FIX3;
	ELSIF (pcheck4 = 1) THEN
	next_state <= FIX4;
	ELSIF (pcheck5 = 1) THEN
	next_state <= FIX5;
	ELSIF (pcheck1 = 0) and (pcheck2 = 0) and (pcheck3 = 0) and (pcheck4 = 0) and (pcheck5 = 0) THEN
	next_state <= STEP5;
	Upper_B <= "00011";
	ELSE
	next_state <= ERROR;
	Upper_B <= "00100";
	END IF;

--------------------------------------------------------
	WHEN FIX1 =>
	IF(pcheck2 = 1) THEN
	next_state <= FIX2;
	ELSIF(pcheck3 = 1) THEN
	next_state <= FIX3;
	ELSIF(pcheck4 = 1) THEN
	next_state <= FIX4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
----------------------------------------------------------

	WHEN FIX2 =>
	IF(pcheck3 = 1) THEN
	next_state <= FIX3;
	ELSIF(pcheck4 = 1) THEN
	next_state <= FIX4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
-----------------------------------------------------------

	WHEN FIX3 =>
	IF(pcheck4 = 1) THEN
	next_state <= FIX4;
	ELSIF(pcheck5 = 1) THEN
	next_state <= FIX5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;
	
------------------------------------------------------------

	WHEN FIX4 =>
	IF(pcheck5 = 1) THEN
	next_state <= FIX5;
	ELSE
	next_state <= CODE_CHECK;
	END IF;

-----------------------------------------------------------
	WHEN FIX5 => next_state <= CODE_CHECK;
----------------------------------------------------------

	WHEN CODE_CHECK =>
	next_state <= VERIFY;
-----------------------------------------------------------

	WHEN VERIFY =>
	IF(verify_msg_pass = '1') THEN
	next_state <= STEP5;
	Upper_B <= "00011";
	ELSE
	next_state <= STEP4;
	END IF;

----------------------------------------------------------------------
	WHEN STEP5 => -- 3 seconds
	IF(Count_S = "00000") THEN
	next_state <= DISPLAY_CODE3;
	Upper_B <= "00110"; 
	ELSE
	next_state <= STEP5;
	hex_mode <= "0101";
	END IF;
---------------------------------------------------------------------
	WHEN DISPLAY_CODE3 => -- 6 seconds
	IF(Count_S = "00000") THEN
	next_state <= DONE;
	Upper_B <= "00011";  
	ELSE
	next_state <= DISPLAY_CODE3;
	hex_mode <= "1000";
	END IF;
--------------------------------------------------------------------
	WHEN ERROR => -- 4 seconds
	IF(Count_S = "00000") THEN
	next_state <= ONRESET; 
	ELSE
	next_state <= ERROR;
	hex_mode <= "1111";
	END IF;
--------------------------------------------------------------------
	WHEN DONE => -- 3 seconds
	IF(Count_S = "00000") THEN
	next_state <= ONRESET; 
	ELSE
	next_state <= DONE;
	hex_mode <= "1110";
	END IF;
---------------------------------------------------------------------
	WHEN OTHERS =>
	next_state <= ONRESET;

	END CASE;
	END PROCESS sequential;


--------------------------------------------------------------
----------------- COMBINATIONAL LOGIC
--------------------------------------------------------------

	combinational:
	PROCESS(CLOCK_50,KEY,SW,current_state)	
	BEGIN


	IF ( CLOCK_50'EVENT and CLOCK_50 = '1') THEN
----------------------------------------------------------------

	IF ( current_state = ONRESET) THEN
	code_word <="00000000000000000000";
	code_word_i <="00000000000000000000";
	END IF;

-----------------------------------------------------------------
	IF (current_state = ENCODE) THEN
	code_word <= Conv_To_20(msg_word);
	code_word_i <= Conv_To_20(msg_word);
	END IF; 

-----------------------------------------------------------------
	IF (current_state = ADD_ERROR) THEN
	IF ( SW(9) = '1') THEN code_word(19 downto 18) <= "01"; ELSE code_word(19 downto 18) <= code_word_i(19 downto 18); END IF;
	IF ( SW(8) = '1') THEN code_word(17 downto 16) <= "01"; ELSE code_word(17 downto 16) <= code_word_i(17 downto 16); END IF;
	IF ( SW(7) = '1') THEN code_word(15 downto 14) <= "01"; ELSE code_word(15 downto 14) <= code_word_i(15 downto 14); END IF;
	IF ( SW(6) = '1') THEN code_word(13 downto 12) <= "01"; ELSE code_word(13 downto 12) <= code_word_i(13 downto 12); END IF;
	IF ( SW(5) = '1') THEN code_word(11 downto 10) <= "01"; ELSE code_word(11 downto 10) <= code_word_i(11 downto 10); END IF;
	IF ( SW(4) = '1') THEN code_word(9 downto 8) <= "01"; ELSE code_word(9 downto 8) <= code_word_i(9 downto 8); END IF;
	IF ( SW(3) = '1') THEN code_word(7 downto 6) <= "01"; ELSE code_word(7 downto 6) <= code_word_i(7 downto 6); END IF;
	IF ( SW(2) = '1') THEN code_word(5 downto 4) <= "01"; ELSE code_word(5 downto 4) <= code_word_i(5 downto 4); END IF;
	IF ( SW(1) = '1') THEN code_word(3 downto 2) <= "01"; ELSE code_word(3 downto 2) <= code_word_i(3 downto 2); END IF;
	IF ( SW(0) = '1') THEN code_word(1 downto 0) <= "01"; ELSE code_word(1 downto 0) <= code_word_i(1 downto 0); END IF;

	END IF; 
-----------------------------------------------------------------
	IF (current_state = STEP4) THEN
	pcheck1 <= 0;
	pcheck2 <= 0;
	pcheck3 <= 0;
	pcheck4 <= 0;
	pcheck5 <= 0;
	verify_msg_pass <= '0';
	END IF; 
--------------------------------------------------------------------
	IF (current_state = PK1) THEN -- 9 and 6 
	
	IF  (code_word(19 downto 18) /= "00") and (code_word(19 downto 18) /= "11")  THEN
		pcheck2 <= pcheck2 + 1;
		pcheck3 <= pcheck3 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck2 <= pcheck2;
		pcheck3 <= pcheck3;
		pcheck5 <= pcheck5;
	END IF;

	IF  (code_word(13 downto 12) /= "00") and (code_word(13 downto 12) /= "11")  THEN
		pcheck1 <= pcheck1 + 1;
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck4 <= pcheck4;
	END IF;
	END IF;
-----------------------------------------------------------------
	IF (current_state = PK2) THEN -- 8,3,2 and 1
	
	IF  (code_word(17 downto 16) /= "00") and (code_word(17 downto 16) /= "11")  THEN
		pcheck1 <= pcheck1 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck1 <= pcheck1;
		pcheck5 <= pcheck5;
	END IF;

	IF  (code_word(7 downto 6) /= "00") and (code_word(7 downto 6) /= "11") THEN
		pcheck2 <= pcheck2 + 1;
	ELSE
		pcheck2 <= pcheck2;
	END IF;

	IF  (code_word(5 downto 4) /= "00") and (code_word(5 downto 4) /= "11") THEN
		pcheck3 <= pcheck3 + 1;
	ELSE
		pcheck3 <= pcheck3;
	END IF;

	IF  (code_word(3 downto 2) /= "00") and (code_word(3 downto 2) /= "11") THEN
		pcheck4 <= pcheck4 + 1;
	ELSE
		pcheck4 <= pcheck4;
	END IF;

	END IF;

-----------------------------------------------------------------
	IF (current_state = PK3) THEN -- 7 and 0
	
	IF  (code_word(15 downto 14) /= "00") and (code_word(15 downto 14) /= "11") THEN
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

	IF  (code_word(1 downto 0) /= "00") and (code_word(1 downto 0) /= "11") THEN
		pcheck5 <= pcheck5 + 1;
	ELSE
		pcheck5 <= pcheck5;
	END IF;

	END IF;

-----------------------------------------------------------------
	IF (current_state = PK4) THEN   -- 5 and 4
	
	IF  (code_word(11 downto 10) /= "00") and (code_word(11 downto 10) /= "11") THEN
	    	pcheck3 <= pcheck3 + 1;
		pcheck4 <= pcheck4 + 1;
		pcheck5 <= pcheck5 + 1;
	ELSE
	    	pcheck3 <= pcheck3;
		pcheck4 <= pcheck4;
		pcheck5 <= pcheck5;
	END IF;

	IF  (code_word(9 downto 8) /= "00") and (code_word(9 downto 8) /= "11") THEN
		pcheck1 <= pcheck1 + 1;
	ELSE
		pcheck1 <= pcheck1;
	END IF;

	END IF;
-----------------------------------------------------------------------------------
	IF (current_state = FIX1) THEN	

	IF (code_word(17 downto 16) /= "00") and (code_word(17 downto 16) /= "11") THEN 	--(8) 17/16
	code_word(17) <=  code_word(15) xor code_word(13) xor code_word(9);
	code_word(16) <=  code_word(14) xor code_word(12) xor code_word(8);
	ELSIF( code_word(15 downto 14) = "00") and (code_word(15 downto 14) /= "11") THEN	--(7) 15/14
	code_word(15) <=  code_word(17) xor code_word(13) xor code_word(9);
	code_word(14) <=  code_word(16) xor code_word(12) xor code_word(8);
	ELSIF( code_word(13 downto 12) /= "00") and (code_word(13 downto 12) /= "11") THEN	--(6) 13/12
	code_word(13) <=  code_word(17) xor code_word(15) xor code_word(9);
	code_word(12) <=  code_word(16) xor code_word(14) xor code_word(8);
	ELSIF( code_word(9 downto 8) /= "00") and (code_word(9 downto 8) /= "11") THEN		--(4) 9/8
	code_word(9) <=  code_word(17) xor code_word(15) xor code_word(13);
	code_word(8) <=  code_word(16) xor code_word(14) xor code_word(12);
	END IF;

	END IF;
-------------------------------------------------------------------
	IF ( current_state = FIX2) THEN	

	IF( code_word(19 downto 18) /= "00") and (code_word(19 downto 18) /= "11") THEN 	--(9) 19/18
	code_word(19) <=  code_word(15) xor code_word(7);
	code_word(18) <=  code_word(14) xor code_word(6);
	ELSIF( code_word(15 downto 14) /= "00") and (code_word(15 downto 14) /= "11") THEN	--(7) 15/14
	code_word(15) <=  code_word(19) xor code_word(7);
	code_word(14) <=  code_word(18) xor code_word(6);
	ELSIF( code_word(7 downto 6) /= "00") and (code_word(7 downto 6) /= "11") THEN		--(3) 7/6
	code_word(7) <=  code_word(19) xor code_word(15);
	code_word(6) <=  code_word(18) xor code_word(14);
	END IF;

	END IF;

-------------------------------------------------------------------

	IF (current_state = FIX3) THEN	

	IF( code_word(19 downto 18) /= "00") and (code_word(19 downto 18) /= "11") THEN 	--(9) 19/18
	code_word(19) <=  code_word(15) xor code_word(11) xor code_word(5);
	code_word(18) <=  code_word(14) xor code_word(10) xor code_word(4);
	ELSIF( code_word(15 downto 14) /= "00") and (code_word(15 downto 14) /= "11") THEN	--(7) 15/14
	code_word(15) <=  code_word(19) xor code_word(11) xor code_word(5);
	code_word(14) <=  code_word(18) xor code_word(10) xor code_word(4);
	ELSIF( code_word(11 downto 10) /= "00") and (code_word(11 downto 10) /= "11") THEN	--(5) 11/10
	code_word(11) <=  code_word(19) xor code_word(15) xor code_word(5);
	code_word(10) <=  code_word(18) xor code_word(14) xor code_word(4);
	ELSIF( code_word(5 downto 4) /= "00") and (code_word(5 downto 4) /= "11") THEN		--(2) 5/4
	code_word(5) <=  code_word(19) xor code_word(15) xor code_word(11);
	code_word(4) <=  code_word(18) xor code_word(14) xor code_word(10);
	END IF;

	END IF;
---------------------------------------------------------------------

	IF ( current_state = FIX4) THEN	

	IF( code_word(15 downto 14) /= "00") and (code_word(15 downto 14) /= "11") THEN 	--(7) 15/14
	code_word(15) <=  code_word(13) xor code_word(11) xor code_word(3);
	code_word(14) <=  code_word(12) xor code_word(10) xor code_word(2);
	ELSIF( code_word(13 downto 12) /= "00") and (code_word(13 downto 12) /= "11") THEN	--(6) 13/12
	code_word(13) <=  code_word(15) xor code_word(11) xor code_word(3);
	code_word(12) <=  code_word(14) xor code_word(10) xor code_word(2);
	ELSIF( code_word(11 downto 10) /= "00") and (code_word(11 downto 10) /= "11") THEN	--(5) 11/10
	code_word(11) <=  code_word(15) xor code_word(13) xor code_word(3);
	code_word(10) <=  code_word(14) xor code_word(12) xor code_word(2);
	ELSIF( code_word(3 downto 2) /= "00") and (code_word(3 downto 2) /= "11") THEN		--(1) 3/2
	code_word(3) <=  code_word(15) xor code_word(13) xor code_word(11);
	code_word(2) <=  code_word(14) xor code_word(12) xor code_word(10);
	END IF;

	END IF;

----------------------------------------------------------------------

	IF ( current_state = FIX5) THEN	

	IF( code_word(19 downto 18) /= "00") and (code_word(19 downto 18) /= "11") THEN 	--(9) 19/18
	code_word(19) <=  code_word(17) xor code_word(11) xor code_word(1);
	code_word(18) <=  code_word(16) xor code_word(10) xor code_word(0);
	ELSIF( code_word(17 downto 16) /= "00") and (code_word(17 downto 16) /= "11") THEN	--(8) 17/16
	code_word(17) <=  code_word(19) xor code_word(11) xor code_word(1);
	code_word(16) <=  code_word(18) xor code_word(10) xor code_word(0);
	ELSIF( code_word(11 downto 10) /= "00") and (code_word(11 downto 10) /= "11") THEN	--(5) 11/10
	code_word(11) <=  code_word(19) xor code_word(17) xor code_word(1);
	code_word(10) <=  code_word(18) xor code_word(16) xor code_word(0);
	ELSIF( code_word(1 downto 0) /= "00") and (code_word(1 downto 0) /= "11") THEN		--(0) 1/0
	code_word(1) <=  code_word(19) xor code_word(17) xor code_word(11);
	code_word(0) <=  code_word(18) xor code_word(16) xor code_word(10);
	END IF;

	END IF;
---------------------------------------------------------------------

	IF ( current_state = CODE_CHECK) THEN
	IF ((code_word(19 downto 18) = "00") or (code_word(19 downto 18) = "11")) and
	   ((code_word(17 downto 16) = "00") or (code_word(17 downto 16) = "11")) and
           ((code_word(15 downto 14) = "00") or (code_word(15 downto 14) = "11")) and
           ((code_word(13 downto 12) = "00") or (code_word(13 downto 12) = "11")) and
           ((code_word(11 downto 10) = "00") or (code_word(11 downto 10) = "11")) and
           ((code_word(9 downto 8) = "00") or (code_word(9 downto 8) = "11")) and
           ((code_word(7 downto 6) = "00") or (code_word(7 downto 6) = "11")) and
           ((code_word(5 downto 4) = "00") or (code_word(5 downto 4) = "11")) and
           ((code_word(3 downto 2) = "00") or (code_word(3 downto 2) = "11")) and
           ((code_word(1 downto 0) = "00") or (code_word(1 downto 0) = "11")) THEN
	   verify_msg_pass <= '1';
	   ELSE
	   verify_msg_pass <= '0';
	   END IF;
	   END IF;
-----------------------------------------------------------------------
	END IF;
	END PROCESS combinational;

	-- Port Maps
	SecH_0 : Seven_Segment port map (Input0, HEX0);
	SecH_1 : Seven_Segment port map (Input1, HEX1);
	SecH_2 : Seven_Segment port map (Input2, HEX2);
	SecH_3 : Seven_Segment port map (Input3, HEX3);
	SecH_4 : Seven_Segment port map (Input4, HEX4);
	SecH_5 : Seven_Segment port map (Input5, HEX5);
	Hex_6 : Hex_Controller port map (CLOCK_50, hex_mode, SW, code_word, msg_word, Input5, Input4, Input3, Input2, Input1, Input0);
	Seconds: COUNT1S port map(CLOCK_50, start_counter);
	C0 : Counter5bit port map (CLOCK_50, start_counter, Upper_B, Count_S);
	Lights: LED_Controller port map (code_word, LEDR);

END behav;
