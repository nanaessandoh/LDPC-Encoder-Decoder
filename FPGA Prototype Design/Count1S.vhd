LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY COUNT1S IS
  PORT( CLOCK_50: IN std_logic;
        CNT50M: OUT std_logic
);
END COUNT1S;

ARCHITECTURE behav OF COUNT1S IS

SIGNAL CNT: std_logic_vector(25 downto 0) := "00000000000000000000000000";

BEGIN

  -- Clock the counter
  PROCESS (CLOCK_50)
  BEGIN
    IF (CLOCK_50'event) and (CLOCK_50 = '1') THEN
       IF (CNT = "10111110101111000010000000") THEN   
	  CNT50M <= '1';
          CNT <= "00000000000000000000000000";
       ELSE
          CNT50M <= '0';
          CNT <= CNT + '1';
	  END IF;
      END IF;
  END PROCESS;
  
END behav;

