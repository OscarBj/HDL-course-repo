library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Each input -> separate process
-- 1 process for main state machine
-- Can use multiple state machines but with communication in between
-- To make longer simulations, not changing clock freq, but state freq
-- User defined frequency is the frequency vivado gets, no virtual hw available

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
    constant off: rgb_sequence_type:=(
    rgb_values(4),
    rgb_values(4),
    rgb_values(4),
    rgb_values(4),
    rgb_values(4)    
    );
    
-- State signals: TODO check these
signal mode: rgb_sequence_type:= off;
signal r,g,b: std_ulogic_vector(7 downto 0);
signal curr_speed: integer:=0;

-- Timer signals: TODO make vector lengths generic, verify default values
-- State time
signal rst_clk2: std_logic:='1';
signal timer2_update: std_logic:= '0';
signal timer2_in: std_logic_vector(3 downto 0):= "0001";
-- Global time -> change to timer 1 and timer 2, no global time only different timers (no counter)
signal rst_clk1: std_logic:='1';
signal timer1_update: std_logic:= '0';
signal timer1_in: std_logic_vector(3 downto 0):= "0001";

component timer_module
port(
    rst: in std_logic;
    timer_in: in std_ulogic_vector;
    timer_out: out std_logic
    );
end component;

begin
    timer1: timer_module port map(rst => rst_clk2, timer_in => timer1_in, timer_out => timer1_update);
    timer2: timer_module port map(rst => rst_clk1, timer_in => timer2_in, timer_out => timer2_update);
    
	-- Modify this to work with new timer thingy
    process(rst,alarm, loopmd)
    begin
        -- TODO: Alarm have to be overriden by reset
        if(alarm='1' AND rst='0') then
            mode<=alarm_sequence;
        elsif(rst='0') then
            if(falling_edge(rst) OR falling_edge(alarm)) then
                rst_clk2<='0';
                timer2_in<="0111";  
                mode<=standby;
            elsif(rising_edge(timer2_update)) then -- catch timer to be able to switch modes, atm we get stuck on standby bc there is not timer on it
			     -- Move to separate process
                if(loopmd='1') then
                    mode<=continious_rgb_sequence;
                elsif(loopmd='0') then
                    mode<=backwards_rgb_sequence;
                end if;
            end if;

        else       
            rst_clk2<='1';  
             
        end if;
    end process;     
    
    
    -- Loop rgb values
--    process
--    variable curr_value: rgb_value;
--    begin
--        for i in 0 to mode'length-1 loop
--            curr_value:=mode(i);
--            r<=std_ulogic_vector(TO_UNSIGNED(curr_value(0),8));
--            g<=std_ulogic_vector(TO_UNSIGNED(curr_value(1),8));
--            b<=std_ulogic_vector(TO_UNSIGNED(curr_value(2),8));
            
--            rst_clk1<='0';
--            wait until curr_speed = to_integer(unsigned(count_clk2));
--            rst_clk1<='1';
--        end loop;    
--    end process;
    
	-- Modify this to work with new timer thingy
    process(mode,timer2_update,rst)
    variable mode_var: rgb_sequence_type:= off;
    variable curr_value: rgb_value;
    variable sequence_index: integer:=0;
    begin
        if(rst='1') then
            sequence_index:=0;
            curr_value:=off(0);
            rst_clk1<='1';
        elsif(falling_edge(rst) OR mode/=mode_var) then
            mode_var:=mode;
            rst_clk1<='0';
        elsif(rising_edge(timer2_update) OR mode/=mode_var) then       
            sequence_index:= sequence_index +1;
            if(sequence_index>mode_var'length-1) then
                sequence_index:=0;
            end if;
            curr_value:=mode_var(sequence_index);
            r<=std_ulogic_vector(TO_UNSIGNED(curr_value(0),8));
            g<=std_ulogic_vector(TO_UNSIGNED(curr_value(1),8));
            b<=std_ulogic_vector(TO_UNSIGNED(curr_value(2),8));
        end if; 
    end process;
    
    -- Change Loop Speed
    process(speedmd)
    begin
        if(speedmd="01") then
            timer1_in<="0001";
        elsif(speedmd="10") then
            timer1_in<="0010";
        elsif(speedmd="11") then
            timer1_in<="0101";
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
