LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Bit_Flipping IS
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
	input_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	msg_decode_done : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto N-5)
);

END Bit_Flipping;



ARCHITECTURE behav OF Bit_Flipping IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE, PARITY_CHECK, BIT_CHECK, HOLD_1, HOLD_2, DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL B1_2,B1_3,B1_4,B1_6 : std_logic; --Represent Each Bit Protection Equation
SIGNAL B2_1,B2_3,B2_7  : std_logic;
SIGNAL B3_1,B3_3,B3_5,B3_8 : std_logic;
SIGNAL B4_3,B4_4,B4_5,B4_9 : std_logic;
SIGNAL B5_1,B5_2,B5_5,B5_10 : std_logic;

SIGNAL C1_0,C2,C3,C4,C5,C6,C7,C8,C9,C10 : std_logic;

SIGNAL idata: std_logic_vector (N-1 downto 0);


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
	PROCESS(clk, rstb)
	BEGIN

	CASE current_state IS
	
	WHEN ONRESET =>
	next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
	next_state <= PARITY_CHECK;
	ELSE
	next_state <= IDLE;
	END IF;

	WHEN PARITY_CHECK =>
	next_state <= HOLD_1;


	WHEN HOLD_1 =>
	next_state <= BIT_CHECK;



	WHEN BIT_CHECK =>
	next_state <= HOLD_2;


	
	WHEN HOLD_2 =>
	next_state <= DONE;


	WHEN DONE =>
	next_state <= IDLE;


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
		msg_decode_done <= 'U';
	END IF;

	IF (current_state = IDLE) THEN
		idata <= input_data;
				
	END IF;

-------------------------------------------------------------
	IF (current_state = PARITY_CHECK) THEN
	
	B1_2 <= idata(N-3) xor idata(N-4) xor idata(N-6);
	B1_3 <= idata(N-2) xor idata(N-4) xor idata(N-6);
	B1_4 <= idata(N-2) xor idata(N-3) xor idata(N-6);
	B1_6 <= idata(N-2) xor idata(N-3) xor idata(N-4);
------------------------------------------------------------
	B2_1 <= idata(N-3) xor idata(N-7);
	B2_3 <= idata(N-1) xor idata(N-7);
	B2_7 <= idata(N-1) xor idata(N-3);
------------------------------------------------------------
	B3_1 <= idata(N-3) xor idata(N-5) xor idata(N-8);
	B3_3 <= idata(N-1) xor idata(N-5) xor idata(N-8);
	B3_5 <= idata(N-1) xor idata(N-3) xor idata(N-8);
	B3_8 <= idata(N-1) xor idata(N-3) xor idata(N-5);
------------------------------------------------------------
	B4_3 <= idata(N-4) xor idata(N-5) xor idata(N-9);
	B4_4 <= idata(N-3) xor idata(N-5) xor idata(N-9);
	B4_5 <= idata(N-3) xor idata(N-4) xor idata(N-9);
	B4_9 <= idata(N-3) xor idata(N-4) xor idata(N-5);
-------------------------------------------------------------
	B5_1 <= idata(N-2) xor idata(N-5) xor idata(N-10);
	B5_2 <= idata(N-1) xor idata(N-5) xor idata(N-10);
	B5_5 <= idata(N-1) xor idata(N-2) xor idata(N-10);
	B5_10 <= idata(N-1) xor idata(N-2) xor idata(N-5);

	END IF;
-----------------------------------------------------------------------------


	IF (current_state = HOLD_1) THEN
	
	C1 <= B2_1 xor B3_1 xor B5_1;
	C2 <= B1_2 xor B5_2;
	C3 <= B1_3 xor B2_3 xor B3_3 xor B4_3;
	C4 <= B1_4 xor B4_4;
	C5 <= B3_5 xor B4_5 xor B5_5;
 





	END IF;
-----------------------------------------------------------------------------

	IF (current_state = BIT_CHECK) THEN
	
-------------------------------------------------------------------------- Bit 1
	IF (B2_1 = '0') and (B3_1 = '0') and (B5_1 = '0') THEN
	idata(N-1) <= '0';
	ELSIF (B2_1 = '1') and (B3_1 = '1') and (B5_1 = '1') THEN
	idata(N-1) <='1';
	ELSIF (C1 = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <=' 0';
 -------------------------------------------------------------------------- Bit 2

	IF (B1_2 = '0') and (B5_2 = '0') THEN
	idata(N-2) <= '0';
	ELSIF (B1_2 = '1') and (B5_2 = '1') THEN
	idata(N-2) <='1';
	ELSIF (C2 = '0') THEN
	idata(N-2) <= '1';
	ELSE
	idata(N-2) <=' 0';

--------------------------------------------------------------------------- Bit 3

	IF (B1_3 = '0') and (B2_3 = '0') and (B3_3 = '0') and (B4_3 = '0') THEN
	idata(N-3) <= '0';
	ELSIF (B1_3 = '1') and (B2_3 = '1') and (B3_3 = '1') THEN
	idata(N-3) <='1';
	ELSIF (B1_3 = '1') and (B2_3 = '1') and (B4_3 = '1') THEN
	idata(N-3) <='1';
	ELSIF (B1_3 = '1') and (B3_3 = '1') and (B4_3 = '1') THEN
	idata(N-3) <='1';
	ELSIF (B2_3 = '1') and (B3_3 = '1') and (B4_3 = '1') THEN
	idata(N-3) <='1';
	ELSIF (B1_3 = '1') and (B2_3 = '1') and (B3_3 = '1') and (B4_3 = '1') THEN
	idata(N-3) <='1';
	ELSIF (C3 = '0') THEN
	idata(N-3) <= '1';
	ELSE
	idata(N-3) <=' 0';

 ------------------------------------------------------------------------- Bit 4

	IF (B1_4 = '0') and (B4_4 = '0') THEN
	idata(N-4) <= '0';
	ELSIF (B1_4 = '1') and (B4_4 = '1') THEN
	idata(N-4) <='1';
	ELSIF (C4 = '0') THEN
	idata(N-4) <= '1';
	ELSE
	idata(N-4) <=' 0';

-------------------------------------------------------------------------- Bit 5

	IF (B3_5 = '0') and (B4_5 = '0') and (B5_5 = '0') THEN
	idata(N-5) <= '0';
	ELSIF (B3_5 = '1') and (B4_5 = '1') and (B5_5 = '1')  THEN
	idata(N-5) <='1';
	ELSIF (C5 = '0') THEN
	idata(N-5) <= '1';
	ELSE
	idata(N-5) <=' 0';



	END IF;



	IF ( current_state = DONE) THEN
		msg_decode_done <= '1';
		odata <= idata(N-1 downto N-5) ;
	ELSE 
		msg_decode_done <= '0';
		odata <= (OTHERS => 'U');
	END IF;
	END IF;

	END PROCESS combinational;


END behav;
