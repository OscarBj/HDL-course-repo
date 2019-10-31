library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Each input -> separate process
-- 1 process for main state machine
-- Can use multiple state machines but with communication in between
-- To make longer simulations, not changing clock freq, but state freq
-- User defined frequency is the frequency vivado gets, no virtual hw available

entity driver_module is
  generic(
    clk_divider: time:=1250 ms/2; -- > period = 10ns, should be able to be 1ns
    timer_vector: std_logic_vector(3 downto 0):= "1111"
  );
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
type rgb_sequence_type is array (natural range<>) of rgb_value;
type state_type is array(4 downto 0) of std_logic;

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
    
    -- Define states, one rgb sequence or value corresponds to one state
    
    constant continious_state: state_type:=('1','0','0','0','0');
    constant continious_rgb_sequence: rgb_sequence_type:=(
    rgb_values(0),
    rgb_values(5),
    rgb_values(1),
    rgb_values(2),
    rgb_values(6)
    );
    
    constant backwards_state: state_type:=('0','1','0','0','0');
    constant backwards_rgb_sequence: rgb_sequence_type:=(
    rgb_values(0),
    rgb_values(5),
    rgb_values(6),
    rgb_values(2),
    rgb_values(1)
    );
    
    constant alarm_state: state_type:=('0','0','1','0','0');
    constant alarm_sequence: rgb_sequence_type:=(
    rgb_values(3),
    rgb_values(4)
    );
    
    constant standby_state: state_type:=('0','0','0','1','0');
    constant standby: rgb_value:=rgb_values(3); 

    
    constant off_state: state_type:=('0','0','0','0','1');
    constant off: rgb_value:=rgb_values(4);  
    
    
-- State signals: TODO check these
signal current_state: state_type:= off_state;
--signal mode: rgb_sequence_type:= off;
signal r,g,b: std_ulogic_vector(7 downto 0);
signal curr_speed: integer:=0;

-- TIMER 1
signal rst_clk1: std_logic:='1';
signal timer1_update: std_logic:= '0';
signal timer1_in: std_ulogic_vector(timer_vector'length-1 downto 0):= "0001";
signal timer1_alarm: std_logic:='0';
-- TIMER 2
signal rst_clk2: std_logic:='1';
signal timer2_update: std_logic:= '0';
signal timer2_in: std_ulogic_vector(timer_vector'length-1 downto 0):= "0001";
signal timer2_alarm: std_logic:='0';

component timer_module
generic(
    clk_div: time; -- > period = 10ns, should be able to be 1ns
    clk_limit: std_logic_vector
);
port(
    rst: in std_logic;
    alrm: in std_logic;
    timer_in: in std_ulogic_vector;
    timer_out: out std_logic
    );
end component;

begin
    -- Create 2 timers
    timer1: timer_module generic map(clk_div => clk_divider, clk_limit => timer_vector) port map(rst => rst_clk1, alrm=>timer1_alarm, timer_in => timer1_in, timer_out => timer1_update);
    timer2: timer_module generic map(clk_div => clk_divider, clk_limit => timer_vector) port map(rst => rst_clk2, alrm=>timer2_alarm, timer_in => timer2_in, timer_out => timer2_update);
    
    -- Process for controlling states
    process(rst,alarm, loopmd, timer2_update)
    begin
        -- Go to alarm state
        if(rising_edge(alarm) AND rst='0') then
            rst_clk2<='0';
            timer2_in<="0111"; -- Alarm mode lasts 7 seconds
            timer1_alarm<='1';
            current_state<=alarm_state;
            
        -- Go from alarm state to standby
        elsif(current_state=alarm_state AND falling_edge(timer2_update)) then
            timer1_alarm<='0';
            timer2_in<="0100"; -- Standby mode lasts 4 seconds  
            current_state<=standby_state;
            
        elsif(rst='0') then
            
            -- Go from reset to standby
            if(falling_edge(rst)) then
                rst_clk2<='0';
                
                timer2_in<="0100"; -- Standby mode lasts 4 seconds  
                current_state<=standby_state;
                
            -- Go to continious loop or backwards loop state
            elsif(falling_edge(timer2_update)) then 
			    rst_clk1<='0';
			    rst_clk2<='1';
                if(loopmd='1') then
                    current_state<=continious_state;
                elsif(loopmd='0') then
                    current_state<=backwards_state;
                end if;
            end if;
        
        -- Reset timers
        elsif(rst='1') then      
            rst_clk2<='1';  
            rst_clk1<='1'; 
        end if;
    end process;     

    -- Process for assigning output
    process(current_state,timer1_update,rst)
    variable state: state_type:=off_state;
    variable curr_value: rgb_value;
    variable sequence_index: integer:=0;

    begin
        if(rst='1') then
            sequence_index:=0;
            
        -- Assign output based on current state
        elsif(falling_edge(timer1_update) OR current_state/=state) then
            -- State changed
            if(current_state/=state) then     
                state:=current_state;
                sequence_index:=0;
            end if;
            
            -- Get RGB values corresponding to current state
            if(current_state=off_state) then
                curr_value:=off;
            elsif(current_state=standby_state) then
                curr_value:=standby;
            elsif(current_state=alarm_state) then
                curr_value:=alarm_sequence(sequence_index mod 2);
                sequence_index:=sequence_index+1;
            else
                if(loopmd='1') then
                    curr_value:=continious_rgb_sequence(sequence_index);
                elsif(loopmd='0') then
                    curr_value:=backwards_rgb_sequence(sequence_index);
                end if;
                sequence_index:=sequence_index+1;
                if(sequence_index>continious_rgb_sequence'length-1) then
                    sequence_index:=0;
                end if;
            end if;
            
            -- Assign RGB values
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
            timer1_in<="0011";
        elsif(speedmd="11") then
            timer1_in<="0101";
        end if;
    end process;   

    -- Write output
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
