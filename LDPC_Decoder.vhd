LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;


-- Input and Output Definition
ENTITY Decoder IS

GENERIC(
	-- Define Generics
	 N : integer := 5; -- Length of Message Bits
	 C : integer := 10 -- Length of Codewords
);

PORT(
	-- Clock and Reset
	clk : IN std_logic;
	rstb : IN std_logic;


	-- Input Interface I/O
	isop : IN std_logic;
	idata : IN std_logic_vector(C-1 downto 0);

	-- Output Interface I/O
	edone : OUT std_logic;
	odata : OUT std_logic_vector (N-1 downto 0)

);

END Decoder;


--Hardware Description of Block

ARCHITECTURE behav OF Decoder IS

-- Define State of the State Machine
TYPE state_type IS (ONRESET, IDLE,VERIFY,ERROR,DECODE);


-- Define Signals 

SIGNAL current_state, next_state : state_type;
SIGNAL idata_i : std_logic_vector (C-1 downto 0);
SIGNAL verify_code : std_logic;

BEGIN


	sequential:
	PROCESS(clk,rstb, current_state,isop,verify_code)
	BEGIN

	CASE current_state IS
	

	WHEN ONRESET =>
	next_state <= IDLE;

	WHEN IDLE =>
	IF( isop = '1') THEN
	next_state <= VERIFY;
	ELSE
	next_state <= IDLE;
	END IF;

	WHEN VERIFY =>
	IF(verify_code = '1') THEN
	next_state <= DECODE;
	ELSIF (verify_code = '0') THEN
	next_state <= ERROR;
	ELSE
	next_state <= VERIFY;
	END IF;
	
	WHEN DECODE =>
	next_state <= ONRESET;

	WHEN ERROR =>
	next_state <= ONRESET;

	WHEN OTHERS =>
	next_state <= ONRESET;


	END CASE;
	END PROCESS sequential;


	clock_state_machine:
	PROCESS(clk,rstb)
	BEGIN
	IF (rstb /= '1') THEN
	current_state <= ONRESET;
	ELSIF (clk'EVENT and clk = '1') THEN
	current_state <= next_state;
	END IF;
	END PROCESS clock_state_machine;


	combinational:
	PROCESS(clk, rstb)
	BEGIN

	IF ( clk'EVENT and clk = '0') THEN

	IF (current_state = ONRESET) THEN
	edone <= '0';
	verify_code<= 'U'; 
	
	END IF;



	IF (current_state = VERIFY) THEN
	IF (idata = "0000000000") THEN   --1
	verify_code <= '1';
	ELSIF (idata = "0000100111") THEN --2
	verify_code <= '1';
	ELSIF (idata = "0001010010") THEN --3
	verify_code <= '1';
	ELSIF (idata = "0001110101") THEN --4
	verify_code <= '1';
	ELSIF (idata = "0010011110") THEN --5
	verify_code <= '1';
	ELSIF (idata = "0010111001") THEN --6
	verify_code <= '1';
	ELSIF (idata = "0011001100") THEN --7
	verify_code <= '1';
	ELSIF (idata = "0011101011") THEN --8
	verify_code <= '1';
	ELSIF (idata = "0100010001") THEN --9
	verify_code <= '1';
	ELSIF (idata = "0100110110") THEN --10
	verify_code <= '1';
	ELSIF (idata = "0101000011") THEN --11
	verify_code <= '1';
	ELSIF (idata = "0101100100") THEN --12
	verify_code <= '1';
	ELSIF (idata = "0110001111") THEN --13
	verify_code <= '1';
	ELSIF (idata = "0110101000") THEN --14
	verify_code <= '1';
	ELSIF (idata = "0111011101") THEN --15
	verify_code <= '1';
	ELSIF (idata = "0111111010") THEN --16
	verify_code <= '1';
	ELSIF (idata = "1000001101") THEN --17
	verify_code <= '1';
	ELSIF (idata = "1000101010") THEN --18
	verify_code <= '1';
	ELSIF (idata = "1001011111") THEN --19
	verify_code <= '1';
	ELSIF (idata = "1001111000") THEN --20
	verify_code <= '1';
	ELSIF (idata = "1010010011") THEN --21
	verify_code <= '1';
	ELSIF (idata = "1010110100") THEN --22
	verify_code <= '1';
	ELSIF (idata = "1011000001") THEN --23
	verify_code <= '1';
	ELSIF (idata = "1011100110") THEN --24
	verify_code <= '1';
	ELSIF (idata = "1100011100") THEN --25
	verify_code <= '1';
	ELSIF (idata = "1100111011") THEN --26
	verify_code <= '1';
	ELSIF (idata = "1101001110") THEN --27
	verify_code <= '1';
	ELSIF (idata = "1101101001") THEN --28
	verify_code <= '1';
	ELSIF (idata = "1110000010") THEN --29
	verify_code <= '1';
	ELSIF (idata = "1110100101") THEN --30
	verify_code <= '1';
	ELSIF (idata = "1111010000") THEN --31
	verify_code <= '1';
	ELSIF (idata = "1111110111") THEN --32
	verify_code <= '1';
	ELSE
	verify_code <= '0';
	END IF;
	END IF;


	IF (current_state = DECODE) THEN
	edone <= '1';
	odata <= idata(C-1 downto C-5);
	ELSE 
	edone <= '0';
	odata <= (OTHERS => 'U');
	END IF;
	END IF;

	END PROCESS combinational;

END behav;

