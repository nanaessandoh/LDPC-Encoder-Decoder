LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY Seven_Segment IS

PORT(
		SW : IN std_logic_vector(3 downto 0);
		HEX0 : OUT std_logic_vector(6 downto 0)
);

END Seven_Segment;


ARCHITECTURE BEHAV OF Seven_Segment IS
	BEGIN
	
	--HEX0(6) <= (SW(3) and SW(2) and SW(1)) or (not SW(3) and not SW(2) and not SW(1)) or (not SW(2) and not SW(1) and SW(0)) or (SW(2) and SW(1) and SW(0));  
	--HEX0(5) <= (SW(3) and SW(2)) or (not SW(3) and not SW(2) and SW(0)) or (not SW(3) and not SW(2) and SW(1)) or (not SW(3) and SW(1) and SW(0));
	--HEX0(4) <= (not SW(3) and SW(0)) or (SW(2) and SW(0)) or (not SW(3) and SW(2) and not SW(1)) or (SW(3) and SW(2) and SW(1));
	--HEX0(3) <= (not SW(2) and not SW(1) and SW(0)) or (SW(3) and not SW(1) and SW(0)) or (SW(3) and SW(1) and not SW(0)) or (SW(2) and SW(1) and SW(0)) or (not SW(3) and SW(2) and not SW(1) and not SW(0));
	--HEX0(2) <= (SW(3) and SW(1)) or (not SW(2) and SW(1) and not SW(0)) or (SW(3) and not SW(2) and not SW(0)) or (SW(3) and SW(2) and SW(0));  
	--HEX0(1) <= (SW(2) and not SW(1) and SW(0)) or ( SW(3) and SW(1) and SW(0)) or (SW(2) and SW(1) and not SW(0)) or (SW(3) and not SW(2) and not SW(1) and not SW(0));  
	--HEX0(0) <= (SW(3) and SW(2)) or (SW(2) and not SW(1) and not SW(0)) or (SW(3) and not SW(1) and not SW(0)) or (not SW(3) and not SW(2) and not SW(1) and SW(0)); 
	
	HEX0(6) <= (not SW(3) and not SW(2) and not SW(1)) or (not SW(2) and not SW(1) and SW(0)) or (SW(3) and SW(2) and SW(1) and not SW(0));
	HEX0(5) <= (SW(3) and SW(2)) or (not SW(3) and not SW(2) and SW(0)) or ( not SW(3) and not SW(2) and SW(1));
	HEX0(4) <= (not SW(3) and not SW(2) and SW(0)) or (not SW(3) and SW(2) and not SW(1)) or (SW(2) and not SW(1) and SW(0)) or (SW(3) and SW(2) and SW(1) and not SW(0));
	HEX0(3) <= (not SW(2) and not SW(1) and SW(0)) or (SW(2) and SW(1) and SW(0)) or (SW(3) and not SW(1) and SW(0)) or (SW(3) and SW(1) and not SW(0)) or (not SW(3) and SW(2) and not SW(1) and not SW(0));
	HEX0(2) <= (SW(3) and SW(1)) or (not SW(2) and SW(1) and not SW(0)) or (SW(3) and not SW(2) and not SW(0)) or (SW(3) and SW(2) and SW(0));
	HEX0(1) <= (SW(2) and not SW(1) and SW(0)) or (SW(2) and SW(1) and not SW(0)) or (SW(3) and SW(1) and SW(0)) or (SW(3) and not SW(2) and not SW(1) and not SW(0));
	HEX0(0) <= (SW(3) and SW(2)) or (SW(2) and not SW(1) and not SW(0)) or (SW(3) and not SW(1) and not SW(0)) or (not SW(3) and not SW(2) and not SW(1) and SW(0));


END BEHAV;