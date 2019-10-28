library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity driver_tb is 
end driver_tb;

architecture tb of driver_tb is

signal rst: std_logic:= '1';
signal speed: std_logic_vector(1 downto 0):="10"; -- ish works for 01, continue from here, verify that this works as 1 button 
signal loopmode: std_logic:='1';
signal alarm: std_logic:='0';
signal r: std_logic_vector(7 downto 0);
signal b: std_logic_vector(7 downto 0);
signal g: std_logic_vector(7 downto 0); 

begin
    DUT: entity work.driver_module port map(rst, speed, loopmode, alarm, r, b, g);
    
    rst<='0' after 100ns;
    
end tb;