-------------------------------------- 
-- Rising Edge Flip Flop
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity DFlipFlop is
   port( D, Clk: in std_logic;
         Q : OUT std_logic:='0');
end DFlipFlop;

architecture dff_behav of DFlipFlop is
   begin
      process(Clk) --We only care about Clk
         begin
            if (Clk'event) and (Clk='1') then -- Positive Edge
               Q <= D;
            end if;
      end process;
      
end dff_behav;

-------------------------------------- 
-- Convolutional Encoder
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity CEncoder is
    port(input : in std_logic;
         clk : in std_logic;
         output :out std_logic_vector (1 downto 0)
         );
end CEncoder;       

architecture CEncoder_behav of CEncoder is 
   signal DF1_out: std_logic;
   signal DF2_out: std_logic;
   
   component DFlipFlop
           port( D, Clk: in std_logic;
                 Q : OUT std_logic);  
   end component;
begin
    
    DF1:DFlipFlop
        port map (input,clk,DF1_out); 
    DF2:DFlipFlop
        port map (DF1_out,clk,DF2_out);
            
output(1)<= input xor DF1_out xor DF2_out;
output(0)<= input xor DF2_out;

end CEncoder_behav;


         
    