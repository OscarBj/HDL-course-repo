----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.10.2019 18:54:54
-- Design Name: 
-- Module Name: tally - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tally is
 port (
 scoresA : in std_logic_vector(2 downto 0);
 scoresB : in std_logic_vector(2 downto 0);
 winner : out std_logic_vector(1 downto 0)
 );
end entity;

architecture loopy of tally is

begin
    process(scoresA,scoresB)
    
    -- Intermediate results are stored in these variables
    variable comparableA: integer:=0;
    variable comparableB: integer:=0;
    
    begin
    comparableA:=0;
    comparableB:=0;
        -- Loop trough the input vectors, assign points accordingly
        for i in 0 to 2 loop
            if (scoresA(i) = '1') then comparableA:= comparableA+1;
            end if;
            if (scoresB(i) = '1') then comparableB:= comparableB+1;
            end if;
        end loop;
        
        -- Interpret the intermediate values and assign the winner/result
        if(comparableA>comparableB) then winner<="01";
        elsif(comparableB>comparableA) then winner<="10";
        elsif(comparableB = comparableA) then 
            if(comparableB >0 AND comparableA>0) then winner<="11";
            elsif(comparableB =0 AND comparableA =0) then winner<="00";
            end if;
        end if;
        
    end process;

end loopy;
