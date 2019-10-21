library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hex_counter_test is
generic(
    d_length: integer:=4
);
end hex_counter_test;

architecture Behavioral of hex_counter_test is

    component hex_counter
        generic(
           digit_length: integer
        );
        port(
           clk : in STD_ULOGIC;
           rst : in STD_LOGIC;
           enable : in STD_LOGIC;
           downup : in STD_LOGIC;
           load : in STD_LOGIC;
           data : in std_logic_vector;
           digit1 : out std_logic_vector;
           digit2 : out std_logic_vector;
           over: out std_logic
           );
    end component;
    
    -- Test inputs
    signal clock_test : STD_ULOGIC:='0';
    signal enable_test : STD_LOGIC:='1';
    signal reset_test : STD_LOGIC:='1';
    signal downup_test : STD_LOGIC:='1';
    signal load_test : STD_LOGIC:='0';
    signal data_test : std_logic_vector(d_length*2-1 downto 0);
    -- Outputs
    signal digit1_test : std_logic_vector(d_length-1 downto 0);
    signal digit2_test : std_logic_vector(d_length-1 downto 0);
    signal over_test : std_logic;
    
begin
    DUT: hex_counter
    generic map(digit_length => d_length)
    port map(clk => clock_test, enable => enable_test, rst => reset_test, downup => downup_test, load => load_test, data => data_test, digit1 => digit1_test, digit2 => digit2_test, over => over_test);
    
    -- Clear reset    
    reset_test<='0' after 10ns;

    -- Generate clock signal
    clock_test <= not clock_test after 10ns;
    
    -- Loadable data
    data_test<="00011011";
    
    process
    begin
        wait for 2000ns;
        load_test<='1';
        wait for 20ns;
        load_test<='0';
        wait for 1000ns;
        downup_test<='0';
        wait for 1000ns;
        enable_test<='0';
        wait for 100ns;
        enable_test<='1';
    end process;

end Behavioral;
