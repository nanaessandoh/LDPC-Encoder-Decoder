-------------------------------------- 
-- Viterbi Decoder
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std;

entity ViterbiDecoder is
    port (input: in std_logic_vector (1 downto 0);
          clk: in std_logic;
          output: out bit); --the ouput will be delayed for 3 clock, because Traceback Depth is 3
end ViterbiDecoder;

architecture ViterbiDecoder_behav of ViterbiDecoder is
type word_2 is array (1 downto 0) of std_logic_vector (1 downto 0);
type word_4_NextState is array (3 downto 0) of std_logic_vector (1 downto 0);
type word_3 is array (2 downto 0) of std_logic_vector (1 downto 0); 
type word_3_bit is array (2 downto 0) of bit; 
type word_4 is array (3 downto 0) of integer;
type word_4_bit is array (3 downto 0) of bit;
type memory_4 is array (3 downto 0) of word_2;
type memory_4_bit is array (3 downto 0) of word_4_bit;
type memory_4_NextState is array (3 downto 0) of word_4_NextState;
type memory_8 is array (7 downto 0) of integer;
type memory_traceback_row is array (7 downto 0) of word_3;
type memory_traceback_table is array (3 downto 0) of memory_traceback_row;

--To ease up the implementation i considered the traceback depth is 3 and hardcoded all the possible paths,
--which are 32 path in this case of traceback depth 3.
--The following are the definition of 4 tables each contain 8 possible paths depending on the initial state
constant traceback_table: memory_traceback_table:=((("00","00","00"),("11","10","11"),("00","11","10"),("11","01","01"),("00","00","11"),("11","10","00"),("00","11","01"),("11","01","10")),
                                                          (("11","00","00"),("00","10","11"),("11","11","10"),("00","01","01"),("11","00","11"),("00","10","00"),("11","11","01"),("00","01","10")),
                                                          (("10","11","00"),("01","01","11"),("10","00","10"),("01","10","01"),("10","11","11"),("01","01","00"),("10","00","01"),("01","10","10")),
                                                          (("01","11","00"),("10","01","11"),("01","00","10"),("10","10","01"),("01","11","11"),("10","01","00"),("01","00","01"),("10","10","10")));

--The next table maps the state transitions to the inputs that caused them(Current State Vs. output)
-- -1 means invalid operation
--constant outputTable:memory_4_bit:=((0,-1,-1,1),(1,-1,-1,0),(-1,1,0,-1),(-1,0,1,-1));
constant outputTable:memory_4_bit:=(('0','0','0','1'),('1','0','0','0'),('0','1','0','0'),('0','0','1','0'));

--The next table gets the next state providing the current state and the state transition
constant nextStateTable:memory_4_NextState:=(("00","00","00","10"),("10","00","00","00"),("00","11","01","00"),("00","01","11","00"));


constant TraceBackDepth: positive:=3;


function hammingDistance(a:std_logic_vector (1 downto 0)) return integer is
begin
  
  case a is
                  when "00" =>
                      return 0;
                  when "01" =>
                      return 1;
                  when "10" =>
                      return 1;
                  when "11" =>
                      return 2;
                  when others => 
                     return -1; --invalid operation
 end case; 
end hammingDistance; 

function conv_int(a:std_logic_vector (1 downto 0)) return integer is
begin
  
  case a is
                  when "00" =>
                      return 0;
                  when "01" =>
                      return 1;
                  when "10" =>
                      return 2;
                  when "11" =>
                      return 3;
                  when others => 
                     return -1; --invalid operation
 end case; 
end conv_int; 


begin  

  process(clk) 
   variable InitialState:std_logic_vector (1 downto 0):="00";
   variable TracebackResult:memory_8:=(0,0,0,0,0,0,0,0);
   variable InputLevel:integer:=0;
   variable i:integer:=0;
   variable chosenPathIndex:integer;
   variable lowestPathMetricError:integer:=6; --Initialized to the maximum possible error
   variable currentState:std_logic_vector (1 downto 0);
   variable outputVector:word_3_bit;
   
   variable temp_output:std_logic_vector (1 downto 0);
   begin
            if (Clk'event) and (Clk='1') and (input/= "UU")  then -- Positive Edge
               i:=0;
               
               -- Branch Metric Calculations
               while i <8 loop
                         TracebackResult(i):=TracebackResult(i)+ hammingDistance(traceback_table(3-conv_int(InitialState))(7-i)(2-InputLevel) xor input );
                          i:=i+1;
               end loop;    
                         
               
               --Output the decoded data, from the previous path metric calculations
               --Output will be delayed for 3 clock cycles
               output<=outputVector(InputLevel);
               
               InputLevel:=InputLevel+1;
               if(InputLevel =TraceBackDepth)then                   
                   --Select the correct path which have the lowest path metric error
                    i:=0;
                    while i<8 loop
                        if(lowestPathMetricError>TracebackResult(i)) then
                          lowestPathMetricError:=TracebackResult(i);
                          chosenPathIndex:=i;
                        end if;
                          i:=i+1;
                    end loop;  
                   
                   --Convert the selected path to corresponding output
                   currentState:=InitialState;
                    i:=0;
                    while i<TraceBackDepth loop
                     temp_output:=traceback_table(3-conv_int(InitialState))(7-chosenPathIndex)(2-i);
                     outputVector(i):=outputTable(3-conv_int(currentState))(3-conv_int(temp_output));
                     currentState:=nextStateTable(3-conv_int(currentState))(3-conv_int(temp_output));
                     i:=i+1;
                    end loop;  
                   
                   --Set the initial state of the next stage
                   InitialState:=currentState;
                   
                   --Reset variables
                   InputLevel:=0;
                   TracebackResult:=(0,0,0,0,0,0,0,0);
                   lowestPathMetricError:=6;
                   
               end if;
               
            end if;
   end process;   
   
   end ViterbiDecoder_behav;



        