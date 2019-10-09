
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity counter_test is
end counter_test;

architecture Behavioral of counter_test is
    component counter
        port ( enable : in STD_LOGIC;
           reset : in STD_LOGIC;
           downup : in STD_LOGIC;
           load : in STD_LOGIC;
           data : in std_logic_vector(4 downto 0);
           count : out std_logic_vector(4 downto 0);
           over : out STD_LOGIC);
    end component;
    
    signal enable_test : STD_LOGIC;
    signal reset_test : STD_LOGIC;
    signal downup_test : STD_LOGIC;
    signal load_test : STD_LOGIC;
    signal data_test : std_logic_vector(4 downto 0);
    signal count_test : std_logic_vector(4 downto 0);
    signal over_test : STD_LOGIC;

begin
    DUT: counter port map (enable => enable_test, reset => reset_test, downup => downup_test, load => load_test, data => data_test, count => count_test, over => over_test);
    
    process
    begin
    end process;

end Behavioral;
