----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2019 03:11:28 PM
-- Design Name: 
-- Module Name: rgb - Behavioral
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

entity rgb is
    Port (
           clk: in std_logic;
           a : in STD_LOGIC;
           b : in STD_LOGIC;
           c : in STD_LOGIC;
           d : in STD_LOGIC;
           rr : out STD_LOGIC;
           gg : out STD_LOGIC;
           bb : out STD_LOGIC);
end rgb;

architecture Behavioral of rgb is

begin
    process(clk)
    begin
        if(clk='1') then
            rr<=a and b;
            gg<=b and c;
            bb<=c and d;
        else 
            rr<='0';
            gg<='0';
            bb<='0';
        end if;
    end process;


end Behavioral;
