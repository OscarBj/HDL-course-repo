----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.10.2019 18:54:54
-- Design Name: 
-- Module Name: tally_test - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tally_test is
--  Port ( );
end tally_test;

architecture Behavioral of tally_test is
    type lut_type is array(natural range <>) of std_logic_vector(2 downto 0);
    
    constant lut1: lut_type:=(
    "000",
    "001",
    "010",
    "100",
    "011",
    "101",
    "110",
    "111"
    );
    constant lut2: lut_type:=(
    "000", -- change to 0
    "001", -- change to 1
    "010", -- change to 1
    "100",
    "011",
    "101",
    "110",
    "111"
    );
    
    component tally
        port(
        scoresA : in std_logic_vector;
        scoresB : in std_logic_vector;
        winner : out std_logic_vector
        );
    end component;
    
    signal scoresA_test: std_logic_vector(2 downto 0);
    signal scoresB_test: std_logic_vector(2 downto 0);
    signal winner_test: std_logic_vector(1 downto 0);
        
    function countOnes (X: std_logic_vector) return integer
        is
        variable tmp:integer;
        begin
        tmp:=0;
        for i in 0 to X'Length-1 loop
            if (X(i) = '1') then tmp:= tmp+1;
            end if;
        end loop;
        return tmp;
    end countOnes;
    
    function result (A: std_logic_vector; B: std_logic_vector; W: std_logic_vector) return std_logic
        is
        begin
            if(W="00" AND B = "000" AND A = "000") then return '1';
            elsif(W="01" AND countOnes(A) > countOnes(B)) then return '1';
			-- SHOULD BE elsif(W="01" AND A > B then return '1';, compare integers, not vectors -> different method than in tally
            elsif(W="10" AND countOnes(A) < countOnes(B)) then return '1';
            elsif(W="11" AND countOnes(A) = countOnes(B)) then return '1'; 
            else return '0';
            end if;        
    end result;
    

     
begin

    DUT: tally port map (scoresA => scoresA_test, scoresB => scoresB_test, winner => winner_test);
    
    process
        variable v1: std_logic_vector(2 downto 0);
        variable v2: std_logic_vector(2 downto 0);
    begin
        wait for 10ns;

        for i in 0 to 7 loop
            v1:= lut1(i);
            scoresA_test <= v1;
            for j in 0 to 7 loop
                v2:=lut2(j);
                

                scoresB_test <= v2;
                
                wait for 10ns;
                assert result(v1,v2, winner_test) = '1'
                    report "result was " & to_hstring(winner_test)
                    severity error;
                
            end loop;
        end loop;
        
    end process;

end Behavioral;
