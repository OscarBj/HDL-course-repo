----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2019 14:11:53
-- Design Name: 
-- Module Name: bargraph_decoder - Behavioral
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

entity bargraph_decoder is
    Port ( bcd : in std_logic_vector (3 downto 0);
           bar_graph : out std_logic_vector (8 downto 0)
          );
end bargraph_decoder;

architecture behavioral_case of bargraph_decoder is

begin
    process(bcd)
    begin
        case bcd is
            when "0000" => bar_graph <= "000000000";
            when "0001" => bar_graph <= "000000001";
            when "0010" => bar_graph <= "000000011";
            when "0011" => bar_graph <= "000000111";
            when "0100" => bar_graph <= "000001111";
            when "0101" => bar_graph <= "000011111";
            when "0111" => bar_graph <= "000111111";
            when "1000" => bar_graph <= "001111111";
            when "1001" => bar_graph <= "011111111";
            when others => bar_graph <= "111111111";
        end case;
    end process;

end behavioral_case;


architecture behavioral_condition of bargraph_decoder is

begin
process(bcd)
    begin
    
    end process;


end behavioral_condition;

