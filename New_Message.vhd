LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY New_Message IS

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

END New_Message;



ARCHITECTURE behav OF New_Message IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE,CHECK1, CHECK2, CHECK3, CHECK4, DONE);

-- Define States
SIGNAL current_state, next_state : state_type;

-- Define Signals
-- Define Signals
SIGNAL pcheck1 : integer; --Counts the number of Error in each P Check Eqn 1
SIGNAL pcheck2 : integer; -- Eqn 2
SIGNAL pcheck3 : integer; -- Eqn 3
SIGNAL pcheck4 : integer; -- Eqn 4
SIGNAL pcheck5 : integer; -- Eqn 5
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
	next_state <= CHECK1;
	ELSE
	next_state <= IDLE;
	END IF;


	WHEN CHECK1 =>
	next_state <= CHECK2;

	WHEN CHECK2 =>
	next_state <= CHECK3;

	WHEN CHECK3 =>
	next_state <= CHECK4;

	WHEN CHECK4 =>
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

	CASE current_state IS

	WHEN ONRESET =>
		odata <= (others=>'U');
		msg_pass_done <= 'U';
		verify_code <='U';

	WHEN IDLE =>
		idata <= error_data;
		pcheck1 <= 0;
		pcheck2 <= 0;
		pcheck3 <= 0;
		pcheck4 <= 0;
		pcheck5 <= 0;
		verify_code<= '0';


	WHEN CHECK1 =>
		pcheck1 <= pcheck1 + 1;

	WHEN CHECK2 =>
		pcheck2 <= pcheck1 + 1;

	WHEN CHECK3 =>
		pcheck3 <= pcheck2 + 1;

	WHEN CHECK4 =>
		pcheck4 <=  pcheck4 + 1;	

	WHEN DONE =>

	END CASE;
	END PROCESS combinational;



END behav;
