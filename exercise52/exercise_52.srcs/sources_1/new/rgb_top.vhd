----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2019 03:11:28 PM
-- Design Name: 
-- Module Name: rgb_top - Behavioral
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

entity rgb_top is
    Port ( sw : in STD_LOGIC_VECTOR(3 downto 0);
           led5_r : out STD_LOGIC;
           led5_g : out STD_LOGIC;
           led5_b : out STD_LOGIC);
end rgb_top;

architecture Behavioral of rgb_top is

    component rgb is
        Port(
            a: in std_logic;
            b: in std_logic;
            c: in std_logic;
            d: in std_logic;
            rr: out std_logic;
            gg: out std_logic;
            bb: out std_logic
            );
        end component;
            
begin

led: rgb port map(a=>sw(0), b=>sw(1), c=>sw(2), d=>sw(3), rr=>led5_r, gg=>led5_g, bb=>led5_b);

end Behavioral;
