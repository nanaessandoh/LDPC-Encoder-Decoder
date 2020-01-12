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
	PROCESS(clk,rstb)
	BEGIN

	CASE current_state IS
	

	WHEN ONRESET =>
	next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
	next_state <= ONE;
	ELSE
	next_state <= IDLE;
	END IF;


	WHEN ONE =>
	next_state <= TWO;

	WHEN TWO =>
	next_state <= DONE;


	WHEN DONE =>
	next_state <= ONRESET;

	WHEN OTHERS =>
	next_state <= ONRESET;


	END CASE;
	END PROCESS sequential;



	combinational:
	PROCESS(clk,rstb)
	BEGIN

	IF (current_state = IDLE ) THEN
		check1 <= 0;
		check2 <= 0;
	END IF;
	
	IF (current_state = ONE  ) THEN
		check1 <= check1 + 1;
	END IF;

	IF (current_state = TWO ) THEN
		check2 <= check2 + 2;
	END IF;

	END PROCESS combinational;

END behav;
