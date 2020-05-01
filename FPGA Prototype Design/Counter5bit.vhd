LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY Counter5bit IS
  PORT( CLOCK_50, EN: IN std_logic;
	UB : IN std_logic_vector(4 downto 0); -- Upper bound of counter
        COUNT: OUT  std_logic_vector(4 downto 0) -- Output of Counter
	);
END Counter5bit;

ARCHITECTURE behav OF Counter5bit IS
-- Declare Signals  
SIGNAL CNT: std_logic_vector(4 downto 0) := UB;


BEGIN
  -- Clock the counter
  PROCESS (CLOCK_50)
  BEGIN

    IF (CLOCK_50'event) and (CLOCK_50 = '1') THEN
	IF (EN = '1') THEN
	CNT <= CNT - '1';
	ELSIF (CNT = "00000") THEN
	CNT <= UB;
	END IF;
        END IF;
  END PROCESS;
	COUNT <=CNT;
  
END behav;

