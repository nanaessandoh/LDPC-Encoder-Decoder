LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.all;


ENTITY Top_Level IS

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
	code_data : IN std_logic_vector(N-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	error_data : OUT std_logic_vector (N-1 downto 0)
);

END Top_Level;



ARCHITECTURE behav OF Top_Level IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE,GEN_ERROR,ADD_ERROR, VERIFY,ERROR,EOP);
-- Define States
SIGNAL current_state, next_state : state_type;

BEGIN
	sequential:
	PROCESS
	BEGIN

	END PROCESS sequential;


END behav;