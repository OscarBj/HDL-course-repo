library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
            when "0110" => bar_graph <= "000111111";
            when "0111" => bar_graph <= "001111111";
            when "1000" => bar_graph <= "011111111";
            when "1001" => bar_graph <= "111111111";
            when others => bar_graph <= "111111111";
        end case;
    end process;

end behavioral_case;


architecture behavioral_condition of bargraph_decoder is

begin

        bar_graph <= "000000000" when bcd = "0000" else
                        "000000001" when bcd = "0001" else
                        "000000011" when bcd = "0010" else
                        "000000111" when bcd = "0011" else
                        "000001111" when bcd = "0100" else
                        "000011111" when bcd = "0101" else
                        "000111111" when bcd = "0111" else
                        "001111111" when bcd = "1000" else
                        "011111111" when bcd = "1001" else
                        "111111111";


end behavioral_condition;

