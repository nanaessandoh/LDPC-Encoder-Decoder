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
	odata : OUT std_logic_vector (N-1 downto 0)
);

END Bit_Flipping;



ARCHITECTURE behav OF Bit_Flipping IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE, PARITY_CHECK, BIT_ADD1, BIT_ADD2, BIT_ADD3, BIT_ADD4, BIT_ADD5, HOLD_1, HOLD_2, BIT_FLIP, BIT_DECODE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL Bit1 : real; --Represent Each Bit Protection Equation
SIGNAL Bit2 : real; -- Eqn 2
SIGNAL Bit3 : real; -- Eqn 3
SIGNAL Bit4 : real; -- Eqn 4
SIGNAL Bit5 : real; -- Eqn 5
SIGNAL Bit6 : real; -- Eqn 6
SIGNAL Bit7 : real; -- Eqn 7
SIGNAL Bit8 : real; -- Eqn 8
SIGNAL Bit9 : real; -- Eqn 9
SIGNAL Bit10 : real; -- Eqn 10



SIGNAL Parity1,Parity2,Parity3,Parity4,Parity5 : std_logic;

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
	IF (Parity1 = '0') and (Parity2 = '0') and (Parity3 = '0') and (Parity4 = '0') and (Parity5 = '0') THEN 	
	next_state <= BIT_DECODE
        ELSIF (Parity1 = '1') THEN
	next_state <= BIT_ADD1;
        ELSIF (Parity2 = '1') THEN
	next_state <= BIT_ADD2;
        ELSIF (Parity3 = '1') THEN
	next_state <= BIT_ADD3;
        ELSIF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;



	WHEN BIT_ADD1 =>
        IF ((Parity2 = '1') THEN
	next_state <= BIT_ADD2;
        ELSIF (Parity3 = '1') THEN
	next_state <= BIT_ADD3;
        ELSIF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	ELSE
	next_state<= BIT_FLIP;

	
	WHEN BIT_ADD2 =>
        IF (Parity3 = '1') THEN
	next_state <= BIT_ADD3;
        ELSIF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	ELSE
	next_state<= BIT_FLIP;

	WHEN BIT_ADD3 =>
	IF (Parity4 = '1') THEN
	next_state <= BIT_ADD4;
        ELSIF (Parity5 = '1') THEN
	next_state <= BIT_ADD5;
	ELSE
	next_state<= HOLD_2;

	WHEN BIT_COUNT4 =>
	IF (Parity5 = '1') THEN
	next_state <= BIT_COUNT5;
	ELSE
	next_state<= HOLD_2;

	WHEN BIT_COUNT5 =>
	next_state<= HOLD_2;

	WHEN HOLD_2 =>
	next_state <= BIT_FLIP;
----------------------------------------------------------

	WHEN WHEN BIT_FLIP =>
	next_state <= PARITY_CHECK;
-----------------------------------------------------------



	WHEN BIT_DECODE =>
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
 		odata <= (OTHERS => 'U') ;
		msg_pass_done <= 'U';
		verify_code<= 'U'; 
		
	END IF;

	IF (current_state = IDLE) THEN
		idata <= input_data;
		Bit1 <= 0.0;
		Bit2 <= 0.0;
		Bit3 <= 0.0;
		Bit4 <= 0.0;
		Bit5 <= 0.0;
		Bit6 <= 0.0;
		Bit7 <= 0.0;
		Bit8 <= 0.0;
		Bit9 <= 0.0;
		Bit10 <= 0.0;
				
	END IF;

-------------------------------------------------------------
	IF (current_state = PARITY_CHECK) THEN
	
	Parity1 <= idata(N-2) xor idata(N-3) xor idata(N-4) xor idata(N-6);
	Parity2 <= idata(N-1) xor idata(N-3) xor idata(N-7);
	Parity3 <= idata(N-1) xor idata(N-3) xor idata(N-5) xor idata(N-8);
	Parity4 <= idata(N-3) xor idata(N-4) xor idata(N-5) xor idata(N-9);
	Parity5 <= idata(N-1) xor idata(N-2) xor idata(N-5) xor idata(N-10);

	END IF;
-----------------------------------------------------------------------------


	IF (current_state = BIT_ADD1) THEN	

	Bit2 <= Bit2 + 0.5;
	Bit3 <= Bit3 + 0.5;
	Bit4 <= Bit4 + 0.5;
	Bit6 <= Bit6 + 0.5;

	END IF;

	IF (current_state = BIT_ADD2) THEN	

	Bit1 <= Bit1 + 0.5;
	Bit3 <= Bit3 + 0.5;
	Bit7 <= Bit7 + 0.5;

	END IF;

	IF (current_state = BIT_ADD3) THEN	

	Bit1 <= Bit1 + 0.5;
	Bit3 <= Bit3 + 0.5;
	Bit5 <= Bit5 + 0.5;
	Bit8 <= Bit8 + 0.5;

	END IF;


	IF (current_state = BIT_ADD4) THEN	

	Bit3 <= Bit3 + 0.5;
	Bit4 <= Bit4 + 0.5;
	Bit5 <= Bit5 + 0.5;
	Bit9 <= Bit9 + 0.5;

	END IF;


	IF (current_state = BIT_ADD5) THEN	

	Bit1 <= Bit1 + 0.5;
	Bit2 <= Bit2 + 0.5;
	Bit5 <= Bit5 + 0.5;
	Bit10 <= Bit10 + 0.5;

	END IF;




	IF ( current_state = BIT_FLIP) THEN
	
	--9
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <= '0';
	END IF;
	
	--8
	IF ((Bit2>Bit1)and(Bit2>Bit3)and(Bit2>Bit4)and(Bit2>Bit5)and(Bit2>Bit6)and(Bit2>Bit7)and(Bit2>Bit8)and(Bit2>Bit9)and(Bit2>Bit10)) THEN 
	IF(idata(N-2) = '0') THEN
	idata(N-2) <= '1';
	ELSE
	idata(N-2) <= '0';
	END IF;
	
	--7
	IF ((Bit3>Bit1)and(Bit3>Bit2)and(Bit3>Bit4)and(Bit3>Bit5)and(Bit3>Bit6)and(Bit3>Bit7)and(Bit3>Bit8)and(Bit3>Bit9)and(Bit3>Bit10)) THEN 
	IF(idata(N-3) = '0') THEN
	idata(N-3) <= '1';
	ELSE
	idata(N-3) <= '0';
	END IF;

	--6
	IF ((Bit4>Bit1)and(Bit4>Bit2)and(Bit4>Bit3)and(Bit4>Bit5)and(Bit4>Bit6)and(Bit4>Bit7)and(Bit4>Bit8)and(Bit4>Bit9)and(Bit4>Bit10)) THEN 
	IF(idata(N-4) = '0') THEN
	idata(N-4) <= '1';
	ELSE
	idata(N-4) <= '0';
	END IF;

	--5
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <= '0';
	END IF;

	--4
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <= '0';
	END IF;

	--3
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <= '0';
	END IF;

	--2
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <= '0';
	END IF;

	--1
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <= '0';
	END IF;

	--0
	IF ((Bit1>Bit2)and(Bit1>Bit3)and(Bit1>Bit4)and(Bit1>Bit5)and(Bit1>Bit6)and(Bit1>Bit7)and(Bit1>Bit8)and(Bit1>Bit9)and(Bit1>Bit10)) THEN 
	IF(idata(N-1) = '0') THEN
	idata(N-1) <= '1';
	ELSE
	idata(N-1) <= '0';
	END IF;



	END IF;


	IF ( current_state = BIT_DECODE) THEN
		msg_decode_done <= '1';
		odata <= idata;
	ELSE 
		msg_decode_done <= '0';
		odata <= (OTHERS => 'U');
	END IF;

	END PROCESS combinational;


END behav;
