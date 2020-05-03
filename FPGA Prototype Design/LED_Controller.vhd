-- LED lights up to represent the particular bit with a bit erasure 
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY LED_Controller IS

PORT(
		SW : IN std_logic_vector(19 downto 0);
		LEDR : OUT std_logic_vector(9 downto 0)
);

END LED_Controller;


ARCHITECTURE behav OF LED_Controller IS
BEGIN
  PROCESS(SW)
 BEGIN	
	IF (SW(19 downto 18)="00" or SW(19 downto 18)="11") THEN LEDR(9) <= '0'; ELSE LEDR(9) <= '1'; END IF;
	IF (SW(17 downto 16)="00" or SW(17 downto 16)="11") THEN LEDR(8) <= '0'; ELSE LEDR(8) <= '1'; END IF;
	IF (SW(15 downto 14)="00" or SW(15 downto 14)="11") THEN LEDR(7) <= '0'; ELSE LEDR(7) <= '1'; END IF;
	IF (SW(13 downto 12)="00" or SW(13 downto 12)="11") THEN LEDR(6) <= '0'; ELSE LEDR(6) <= '1'; END IF;
	IF (SW(11 downto 10)="00" or SW(11 downto 10)="11") THEN LEDR(5) <= '0'; ELSE LEDR(5) <= '1'; END IF;
	IF (SW(9 downto 8)="00" or SW(9 downto 8)="11") THEN LEDR(4) <= '0'; ELSE LEDR(4) <= '1'; END IF;
	IF (SW(7 downto 6)="00" or SW(7 downto 6)="11") THEN LEDR(3) <= '0'; ELSE LEDR(3) <= '1'; END IF;
	IF (SW(5 downto 4)="00" or SW(5 downto 4)="11") THEN LEDR(2) <= '0'; ELSE LEDR(2) <= '1'; END IF;
	IF (SW(3 downto 2)="00" or SW(3 downto 2)="11") THEN LEDR(1) <= '0'; ELSE LEDR(1) <= '1'; END IF;
	IF (SW(1 downto 0)="00" or SW(1 downto 0)="11") THEN LEDR(0) <= '0'; ELSE LEDR(0) <= '1'; END IF;	
END PROCESS;
END behav;
