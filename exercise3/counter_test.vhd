library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity counter_test is
end counter_test;

architecture Behavioral of counter_test is

    -- Common Inputs
    signal clock_test : std_ulogic:='0';
    signal enable_test : STD_LOGIC;
    signal reset_test : STD_LOGIC:='1';
    signal downup_test : STD_LOGIC;
    signal load_test : STD_LOGIC;
    signal data_test : std_logic_vector(4 downto 0);
    
    -- Separate Outputs
    signal count_test_m1 : std_logic_vector(4 downto 0);
    signal over_test_m1 : STD_LOGIC;
    signal count_test_m2 : std_logic_vector(4 downto 0);
    signal over_test_m2 : STD_LOGIC;

begin
    -- Instantiate entities for the two architectures, map ports
    -- work. compares to this. in Java
    M1: entity work.counter(counter_model1)
    port map (clock => clock_test, enable => enable_test, reset => reset_test, downup => downup_test, load => load_test, data => data_test, count => count_test_m1, over => over_test_m1);
    M2: entity work.counter(counter_model2)
    port map (clock => clock_test, enable => enable_test, reset => reset_test, downup => downup_test, load => load_test, data => data_test, count => count_test_m2, over => over_test_m2);
    
    -- Generate clock signal
    clock_test<= not clock_test after 10ns;
    
    -- Loadable data
    data_test<="00011";

    -- Process containing main functionality of the counter
    process
    begin
        downup_test<='1';
        wait for 20ns;
        reset_test<='0';
        wait for 50ns;
        enable_test<='1';
        wait for 200ns;
        load_test<='1';
        wait for 20ns;
        load_test<='0';
        wait for 200ns;
        downup_test<='0';
        wait for 400ns;
        reset_test<='1';
        wait for 20ns;
        reset_test<='0'; 
    end process;


end Behavioral;
