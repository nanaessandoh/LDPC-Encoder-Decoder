LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY Hex_Controller IS
  PORT( CLOCK_50 : IN std_logic;
	MODE : IN std_logic_vector(3 downto 0); 
        SW: IN  std_logic_vector(9 downto 0); 
	CODE_INPUT : IN  std_logic_vector(19 downto 0); -- Codeword Bits
	MSG_OUT: OUT  std_logic_vector(4 downto 0); -- Message Bit
	DIGIT5,DIGIT4,DIGIT3,DIGIT2,DIGIT1,DIGIT0: OUT std_logic_vector(3 downto 0)
);
END Hex_Controller;

ARCHITECTURE behav OF Hex_Controller IS



FUNCTION Conv_To_Hex_1 (input :std_logic) RETURN std_logic_vector IS
BEGIN 
  CASE input IS
                  WHEN '0' => RETURN "0000"; -- 0
                  WHEN '1' => RETURN "0001"; -- 1
                  WHEN OTHERS => RETURN "1101"; -- Invalid Operation (Blank)
 END CASE; 
END Conv_To_Hex_1; 



FUNCTION Conv_To_Hex_2 (input1 :std_logic_vector(1 downto 0)) RETURN std_logic_vector IS
BEGIN 
  CASE input1 IS
                  WHEN "00" => RETURN "0000"; -- 0
                  WHEN "11" => RETURN "0001"; -- 1
		  WHEN "01" => RETURN "1101"; -- dash
		  WHEN "10" => RETURN "1110"; -- blank
                  WHEN OTHERS => RETURN "1110"; -- Invalid Operation (Blank)
 END CASE; 
END Conv_To_Hex_2; 
 


COMPONENT Shift_Reg IS

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
END COMPONENT;



-- Signal Declaration
SIGNAL Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : std_logic_vector(1 downto 0) := "10";
SIGNAL Reset : std_logic := '0';
 
BEGIN

  PROCESS (MODE, SW, CODE_INPUT, Hex0, Hex1, Hex2, Hex3, Hex4, Hex5)
  BEGIN
    case MODE is


	WHEN "0000" =>  -- Reset State 
	MSG_OUT <= "00000";

        WHEN "0001" => -- Display Step 1 (STEP1)
	DIGIT5 <= "0101"; 
	DIGIT4 <= "1000";
	DIGIT3 <= "1011"; 
	DIGIT2 <= "1010";
	DIGIT1 <= "1110"; 
	DIGIT0 <= "0001";
        
	
        WHEN "0010" => -- Display Step 2 (STEP2) 
	DIGIT5 <= "0101"; 
	DIGIT4 <= "1000";
	DIGIT3 <= "1011"; 
	DIGIT2 <= "1010";
	DIGIT1 <= "1110"; 
	DIGIT0 <= "0010";

	WHEN "0011" => -- Display Step 3 (STEP3)
	DIGIT5 <= "0101"; 
	DIGIT4 <= "1000";
	DIGIT3 <= "1011"; 
	DIGIT2 <= "1010";
	DIGIT1 <= "1110"; 
	DIGIT0 <= "0011";
	Reset <= '1';
 
        WHEN "0100" =>  -- Display Step 4 (STEP4)
	DIGIT5 <= "0101"; 
	DIGIT4 <= "1000";
	DIGIT3 <= "1011"; 
	DIGIT2 <= "1010";
	DIGIT1 <= "1110"; 
	DIGIT0 <= "0100";

        WHEN "0101" =>  -- Display Step 5 (STEP5)
	DIGIT5 <= "0101"; 
	DIGIT4 <= "1000";
	DIGIT3 <= "1011"; 
	DIGIT2 <= "1010";
	DIGIT1 <= "1110"; 
	DIGIT0 <= "0101";


	WHEN "0110" => -- Enter the Message Bits (MSG_IN)
	DIGIT5 <= "1110"; -- HEX 5 is off since it is not needed
	MSG_OUT <= SW(4 downto 0); -- Message Bits to be set to top level (LDPC)
	DIGIT4 <= Conv_To_Hex_1(SW(4));
	DIGIT3 <= Conv_To_Hex_1(SW(3));
	DIGIT2 <= Conv_To_Hex_1(SW(2));
	DIGIT1 <= Conv_To_Hex_1(SW(1));
	DIGIT0 <= Conv_To_Hex_1(SW(0));
	

	WHEN "0111" => -- Display Codeword
	Reset <= '0';
	DIGIT5 <= Conv_To_Hex_2(Hex5);
	DIGIT4 <= Conv_To_Hex_2(Hex4);
	DIGIT3 <= Conv_To_Hex_2(Hex3); 
	DIGIT2 <= Conv_To_Hex_2(Hex2);
	DIGIT1 <= Conv_To_Hex_2(Hex1); 
	DIGIT0 <= Conv_To_Hex_2(Hex0); 


	WHEN "1001" => -- Display ADD ERROR
	Reset <= '1';
	DIGIT5 <= "0111"; --A
	DIGIT4 <= "1100"; --d
	DIGIT3 <= "1100"; --d 
	DIGIT2 <= "1110"; -- Blank
	DIGIT1 <= "1011"; -- E
	DIGIT0 <= "1111"; -- r  

	WHEN "1000" => -- Display Decoded Message Bit 
	DIGIT5 <= Conv_To_Hex_2("10"); --- Make HEX-6 blank
	DIGIT4 <= Conv_To_Hex_2(CODE_INPUT(19 downto 18));
	DIGIT3 <= Conv_To_Hex_2(CODE_INPUT(17 downto 16)); 
	DIGIT2 <= Conv_To_Hex_2(CODE_INPUT(15 downto 14));
	DIGIT1 <= Conv_To_Hex_2(CODE_INPUT(13 downto 12)); 
	DIGIT0 <= Conv_To_Hex_2(CODE_INPUT(11 downto 10));
        

	WHEN "1110" => -- Display Done 
	DIGIT5 <= "1110"; 
	DIGIT4 <= "1100";
	DIGIT3 <= "0000"; 
	DIGIT2 <= "1001";
	DIGIT1 <= "1011"; 
	DIGIT0 <= "1110";

	WHEN "1111" => -- Error
	DIGIT5 <= "1110"; -- Blank 
	DIGIT4 <= "1011"; -- E
	DIGIT3 <= "1111"; -- r 
	DIGIT2 <= "1111"; -- r
	DIGIT1 <= "0000"; -- 0 
	DIGIT0 <= "1111"; -- r

	WHEN OTHERS => -- Error
	DIGIT5 <= "1110"; 
	DIGIT4 <= "1011";
	DIGIT3 <= "1111"; 
	DIGIT2 <= "1111";
	DIGIT1 <= "0000"; 
	DIGIT0 <= "1111";
    end case;   

  end process;

SHIFT_0 : Shift_Reg PORT MAP (CLOCK_50,Reset,CODE_INPUT,Hex0,Hex1,Hex2,Hex3,Hex4,Hex5);
end behav;




