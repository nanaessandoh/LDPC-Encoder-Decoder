LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY Shift_Reg IS

  PORT( -- Clock and Reset
	CLOCK_50 : IN std_logic;
	RSTB : IN std_logic;
	-- Input Interface I/O
	IN_VAL : IN std_logic_vector(19 downto 0);
	-- Output Interface I/O
	OUT_VAL_0: OUT std_logic_vector(1 downto 0);
        OUT_VAL_1: OUT std_logic_vector(1 downto 0);
	OUT_VAL_2: OUT std_logic_vector(1 downto 0);
	OUT_VAL_3: OUT std_logic_vector(1 downto 0);
	OUT_VAL_4: OUT std_logic_vector(1 downto 0);
	OUT_VAL_5: OUT std_logic_vector(1 downto 0)
);

END Shift_Reg;


ARCHITECTURE behav OF Shift_Reg IS
	
COMPONENT COUNT1S is
  port( CLOCK_50: in std_logic;
        CNT50M: out std_logic);
END COMPONENT;


SIGNAL CNT_EN: std_logic := '0';
SIGNAL IN_VAL_I: std_logic_vector(19 downto 0):= IN_VAL;
SIGNAL IN_CNT: std_logic_vector(3 downto 0) := "1010";
SIGNAL OUT_VAL_0I,OUT_VAL_1I,OUT_VAL_2I,OUT_VAL_3I,OUT_VAL_4I,OUT_VAL_5I: std_logic_vector(1 downto 0) := "10";


BEGIN
	PROCESS(CLOCK_50, IN_VAL, OUT_VAL_5I, OUT_VAL_4I, OUT_VAL_3I, OUT_VAL_2I, OUT_VAL_1I, OUT_VAL_0I)
	BEGIN

		IF ( RSTB = '1') THEN
					IN_CNT <= "1100";
					OUT_VAL_5I <= "10";
					OUT_VAL_4I <= "10";
					OUT_VAL_3I <= "10";
					OUT_VAL_2I <= "10";
					OUT_VAL_1I <= "10";
					OUT_VAL_0I <= "10";

		ELSIF (CLOCK_50'event and CLOCK_50 = '1') THEN
			IF (CNT_EN = '1') THEN
				IF (IN_CNT = "1100") THEN
					IN_VAL_I <= IN_VAL;
					IN_CNT <= "0000";
					OUT_VAL_5I <= "10";
					OUT_VAL_4I <= "10";
					OUT_VAL_3I <= "10";
					OUT_VAL_2I <= "10";
					OUT_VAL_1I <= "10";
					OUT_VAL_0I <= "10";
				ELSE
					OUT_VAL_5I <= OUT_VAL_4I;
					OUT_VAL_4I <= OUT_VAL_3I;
					OUT_VAL_3I <= OUT_VAL_2I;
					OUT_VAL_2I <= OUT_VAL_1I;
					OUT_VAL_1I <= OUT_VAL_0I;
					OUT_VAL_0I <= IN_VAL_I(19 downto 18);
---------------------------------------------------------------------
					IN_VAL_I(19) <= IN_VAL_I(17) ;
					IN_VAL_I(18) <= IN_VAL_I(16) ;
					IN_VAL_I(17) <= IN_VAL_I(15) ;
					IN_VAL_I(16) <= IN_VAL_I(14) ;
					IN_VAL_I(15) <= IN_VAL_I(13) ;
					IN_VAL_I(14) <= IN_VAL_I(12) ;
					IN_VAL_I(13) <= IN_VAL_I(11) ;
					IN_VAL_I(12) <= IN_VAL_I(10) ;    
					IN_VAL_I(11) <= IN_VAL_I(9) ;
					IN_VAL_I(10) <= IN_VAL_I(8) ;
					IN_VAL_I(9) <= IN_VAL_I(7) ;
					IN_VAL_I(8) <= IN_VAL_I(6) ;
					IN_VAL_I(7) <= IN_VAL_I(5) ;
					IN_VAL_I(6) <= IN_VAL_I(4) ;
					IN_VAL_I(5) <= IN_VAL_I(3) ;
					IN_VAL_I(4) <= IN_VAL_I(2) ;
					IN_VAL_I(3) <= IN_VAL_I(1) ;
					IN_VAL_I(2) <= IN_VAL_I(0) ;
					IN_VAL_I(1) <= '1' ;
					IN_VAL_I(0) <= '0';
					IN_CNT <= IN_CNT + '1';
				END IF;
			END IF;              
    	END IF;

	OUT_VAL_5 <= OUT_VAL_5I;
	OUT_VAL_4 <= OUT_VAL_4I;
	OUT_VAL_3 <= OUT_VAL_3I;
	OUT_VAL_2 <= OUT_VAL_2I;
	OUT_VAL_1 <= OUT_VAL_1I;
	OUT_VAL_0 <= OUT_VAL_0I;

END PROCESS;

SecH_0 : COUNT1S PORT MAP (CLOCK_50,CNT_EN);
END BEHAV;	
