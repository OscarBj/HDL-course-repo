library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity driver_module is
  Port ( 
    rst: in std_logic;
    speedmd: in std_logic_vector(1 downto 0);
    loopmd: in std_logic;
    alarm: in std_logic;
    red: out std_logic_vector(7 downto 0);
    blue: out std_logic_vector(7 downto 0);
    green: out std_logic_vector(7 downto 0)
    );
end driver_module;

architecture Behavioral of driver_module is

-- Type for containing rgb values
type rgb_value is array(0 to 2) of integer;
type rgb_values_type is array(0 to 6) of rgb_value;
type rgb_sequence_type is array(0 to 4) of rgb_value;

 -- Look up table containing RGB values
    constant rgb_values: rgb_values_type:=(
    (255,   0,      0),     -- Red
    (0,     255,    0),     -- Green
    (0,     0,      255),   -- Blue 
    (255,   255,    255),   -- White
    (0,     0,      0),     -- Black
    (255,   255,    0),     -- Yellow
    (128,   0,      128)    -- Purple    
    );   
    constant continious_rgb_sequence: rgb_sequence_type:=(
    rgb_values(0),
    rgb_values(5),
    rgb_values(1),
    rgb_values(2),
    rgb_values(6)
    );
    constant backwards_rgb_sequence: rgb_sequence_type:=(
    rgb_values(0),
    rgb_values(5),
    rgb_values(6),
    rgb_values(2),
    rgb_values(1)
    );
    constant alarm_sequence: rgb_sequence_type:=(
    rgb_values(3),
    rgb_values(4),
    rgb_values(3),
    rgb_values(4),
    rgb_values(3)
    );
    constant standby: rgb_sequence_type:=(
    rgb_values(3),
    rgb_values(3),
    rgb_values(3),
    rgb_values(3),
    rgb_values(3)    
    );

signal mode: rgb_sequence_type:= standby;
signal rst_clk1,rst_clk2: std_logic:='1';
signal count_clk1,count_clk2: std_logic_vector(3 downto 0) :="1111";
signal r,g,b: std_ulogic_vector(7 downto 0);
signal curr_speed: integer:=0;
begin
    global_time: entity work.timer_module port map(rst_clk1,count_clk1);
    state_time: entity work.timer_module port map(rst_clk2,count_clk2);

    process(count_clk1,rst,alarm)
    begin
        if(alarm='1') then
            mode<=alarm_sequence;
        elsif(rst='0') then
            if(rising_edge(rst)) then
                rst_clk1<='0';  
                --rst_clk2<='0'; 
            end if;         
            
            if(7>to_integer(unsigned(count_clk1))) then
                mode<=standby;
            elsif(loopmd='1') then
                mode<=continious_rgb_sequence;
            elsif(loopmd='0') then
                mode<=backwards_rgb_sequence;
            end if;
            
            
        else       
            rst_clk1<='1';  
            --rst_clk2<='1';              
        end if;
    end process;     
    
    -- Loop rgb values
    process
    variable curr_value: rgb_value;
    begin
        for i in 0 to mode'length loop
            curr_value:=mode(i);
            r<=std_ulogic_vector(TO_UNSIGNED(curr_value(0),8));
            g<=std_ulogic_vector(TO_UNSIGNED(curr_value(1),8));
            b<=std_ulogic_vector(TO_UNSIGNED(curr_value(2),8));
            
            rst_clk2<='0';
            wait until curr_speed = to_integer(unsigned(count_clk2));
            rst_clk2<='1';
        end loop;    
    end process;
    
    -- Change Loop Speed
    process(speedmd)
    begin
        if(speedmd="01") then
            curr_speed<=1;
        elsif(speedmd="10") then
            curr_speed<=3;
        elsif(speedmd="11") then
            curr_speed<=5;
        end if;
    end process;   

    red_led : process(r)
    begin
        red<=r;
    end process red_led;
    
    green_led : process(g)
    begin
        green<=g;
    end process green_led;
    
    blue_led : process(b)
    begin
        blue<=b;
    end process blue_led;
    
end Behavioral;
