----------------------------------------------------------------------------------
-- Engineer: Oscar Björkgren
-- 
-- Create Date: 08.10.2019 18:54:54
-- Design Name: Exercise 2
-- Module Name: tally_test - Behavioral
-- Project Name: HDL based design
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
    type int_type is array(natural range <>) of integer;
    
    -- Look up table used for input to DUT
    constant lut1: lut_type:=(
    "000",
    "001",
    "010",
    "011",
    "100",
    "101",
    "110",
    "111"
    );
    
    -- Look up table used for verification
    constant lut2: int_type:=(
        0,
        1,
        1,
        2,
        1,
        2,
        2,
        3
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
    
    -- Verification function, compares the outputted winner against calculated value
    function result (A: integer; B: integer; W: std_logic_vector) return boolean
        is
        begin
            if(W="00" AND B = 0 AND A = 0) then return true;
            elsif(W="01" AND A > B) then return true;
            elsif(W="10" AND A < B) then return true;
            elsif(W="11" AND A = B) then return true; 
            else return false;
            end if;        
    end result;
    

     
begin

    DUT: tally port map (scoresA => scoresA_test, scoresB => scoresB_test, winner => winner_test);
    
    process
        variable v1: std_logic_vector(2 downto 0);
        variable v2: std_logic_vector(2 downto 0);
    begin
        -- Loop trough look up tables and use values for DUT
        for i in 0 to 7 loop
        
            v1:= lut1(i);
            scoresA_test <= v1;
            
            for j in 0 to 7 loop
            
                v2:=lut1(j);          
                scoresB_test <= v2;
                
                wait for 10ns;
                
                assert result(lut2(i),lut2(j), winner_test)
                    report "result was " & to_hstring(winner_test)
                    severity error;
                             
            end loop;
        end loop;
        
    end process;

end Behavioral;
