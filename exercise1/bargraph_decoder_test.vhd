library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bargraph_decoder_test is

end bargraph_decoder_test;

architecture Behavioral of bargraph_decoder_test is

    -- Create custom type for look up table
    type lut_type is array(natural range <>) of std_logic_vector(8 downto 0);
    
    -- Decalre look up table
    constant lut: lut_type:=(
    "000000000",
    "000000001",
    "000000011",
    "000000111",
    "000001111",
    "000011111",
    "000111111",
    "001111111",
    "011111111",
    "111111111"
    );
    
    component bargraph_decoder
        port(bcd:in std_logic_vector;
            bar_graph:out std_logic_vector);
    end component;
    
    -- Test signals
    signal bcd_test: std_logic_vector(3 downto 0);
    signal bar_graph_test: std_logic_vector(8 downto 0);
    
begin
    DUT: bargraph_decoder port map (bcd => bcd_test, bar_graph => bar_graph_test);
    
    process

    begin

        for i in 0 to 9 loop
        
            -- Generate input signal for device
            bcd_test <= std_logic_vector(TO_UNSIGNED(i,4));
            
            wait for 10ns;
            
            -- Verify that output signal to matches the look up table
            assert bar_graph_test = (lut(i))
                report "ERROR, comparing output: " & to_hstring(bar_graph_test) & " to LUT" & to_hstring(lut(i))
                severity error;
        
        end loop;
    end process;

end Behavioral;
