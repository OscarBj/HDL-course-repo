----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2019 11:57:13
-- Design Name: 
-- Module Name: or_gate - Behavioral
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

entity or_gate is
    Port ( x : in STD_LOGIC;
           y : in STD_LOGIC;
           z : out STD_LOGIC);
end or_gate;

architecture Behavioral of or_gate is

begin
    process(x,y)
    begin
        z <= x or y;
    end process;

end Behavioral;
