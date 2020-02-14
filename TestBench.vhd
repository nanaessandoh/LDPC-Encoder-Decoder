-------------------------------------- 
-- Testbench
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity TestBench is
    port(input : in std_logic;
         clk : in std_logic;
         output :out std_logic
         );
end TestBench;   

architecture TestBench_behav of TestBench is 

signal CE1_Out:std_logic_vector(1 downto 0);
signal VD1_Out:bit;

component CEncoder
    port(input : in std_logic;
         clk : in std_logic;
         output :out std_logic_vector (1 downto 0)
         );
end component;


component ViterbiDecoder
        port (input: in std_logic_vector (1 downto 0);
          clk: in std_logic;
          output: out bit); 
end component;

begin
    
    CE1:CEncoder
    port map(input,clk,CE1_Out);
        
    CE2:ViterbiDecoder
    port map(CE1_Out,clk,VD1_Out);
    
end TestBench_behav;
