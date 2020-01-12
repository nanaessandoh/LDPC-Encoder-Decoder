LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Test IS

GENERIC(
	-- Define Generics
	 N :natural := 10 -- Length of Codeword Bits
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic

);

END Test;



ARCHITECTURE behav OF Test IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE, ONE, TWO, DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
SIGNAL check1 : integer; 
SIGNAL check2 : integer; 


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
	PROCESS(clk,rstb,isop)
	BEGIN

	
	IF (current_state = ONRESET) THEN
		check1 <= 0;
		check2 <= 0;
		next_state <= IDLE;


	ELSIF (clk'EVENT and clk = '1') THEN

	IF (current_state = IDLE) THEN
	IF( isop = '1') THEN
	next_state <= ONE;
	ELSE
	next_state <= IDLE;
	END IF;
	

	ELSIF(current_state = ONE) THEN
	check1 <= check1 + 1;
	next_state <= TWO;

	ELSIF(current_state = TWO) THEN
	check2 <= check2 + 1;
	next_state <= DONE;

	ELSIF(current_state = DONE) THEN
	next_state <= ONRESET;

	ELSE
	next_state <= ONRESET;

	END IF;
	END IF;
	END PROCESS sequential;



END behav;
