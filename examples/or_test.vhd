----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2019 12:03:10
-- Design Name: 
-- Module Name: or_test - Behavioral
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

entity or_test is
--  Port ( );
end or_test;

architecture Behavioral of or_test is
    
    component or_gate
        port(
            x,y : in std_logic;
            z : out std_logic
        );
    end component;
    
    signal test_x, test_y, test_z : std_logic;
    
begin
    DUT: or_gate port map (x => test_x, y => test_y, z => test_z);
    process
    begin
        for i in std_logic range '0' to '1' loop
            for j in std_logic range '0' to '1' loop
                test_x <= i;
                test_y <= j;
                wait for 10ns;
                assert test_z = (i or j)
                    report "ERROR"
                    severity error;
            end loop;
        end loop;    
    end process;

end Behavioral;
