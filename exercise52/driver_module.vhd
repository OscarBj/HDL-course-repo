library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Each input -> separate process
-- 1 process for main state machine
-- Can use multiple state machines but with communication in between
-- To make longer simulations, not changing clock freq, but state freq
-- User defined frequency is the frequency vivado gets, no virtual hw available

entity driver_module is                              
  generic(                                        -- 0000000010011000100101101000- 0.1s
    timer_vector: std_ulogic_vector(27 downto 0):=  "0000010111110101111000010000";  --"00000011111110010100000010101010"; -- 1 sec "00000111011100110101100101000000"
    sec4: std_ulogic_vector(27 downto 0):=          "0001011111010111100001000000";          --"00001111111001010000001010101010"; -- 4 sec "00011101110011010110010100000000"
    sec7: std_ulogic_vector(27 downto 0):=          "0010100110111001001001110000"          --"00011011110100001100010010101010"  -- 7 sec "00110100001001110111000011000000"
  );
  Port ( 
    clk: in std_logic;
    rst: in std_logic;
    speedmd: in std_logic;
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
    
    constant continious_state: std_logic_vector(4 downto 0):="10000";
    constant continious_rgb_sequence: rgb_sequence_type:=(
    rgb_values(0),
    rgb_values(5),
    rgb_values(1),
    rgb_values(2),
    rgb_values(6)
    );
    
    constant backwards_state: std_logic_vector(4 downto 0):="01000";
    constant backwards_rgb_sequence: rgb_sequence_type:=(
    rgb_values(0),
    rgb_values(5),
    rgb_values(6),
    rgb_values(2),
    rgb_values(1)
    );
    
    constant alarm_state: std_logic_vector(4 downto 0):="00100";
    constant alarm_sequence: rgb_sequence_type:=(
    rgb_values(3),
    rgb_values(4)
    );
    
    constant standby_state: std_logic_vector(4 downto 0):="00010";
    constant standby: rgb_value:=rgb_values(3); 

    
    constant off_state: std_logic_vector(4 downto 0):="00001";
    constant off: rgb_value:=rgb_values(4);  
    
-- System state representation
signal current_state: std_logic_vector(4 downto 0):= off_state;
-- Used for outputs
signal r,g,b: std_ulogic_vector(7 downto 0);

component timer_module
generic(
    timer_limit: std_logic_vector
);
port(
    clock: in std_logic;
    rst: in std_logic;
    alrm: in std_logic;
    timer_in: in std_ulogic_vector;
    timer_out: out std_logic
    );
end component;

-- TIMER 1
signal rst_clk1: std_logic:='1';
signal timer1_update: std_logic:= '0';
signal timer1_in: std_ulogic_vector(27 downto 0):= timer_vector;
signal timer1_alarm: std_logic:='0';

-- TIMER 2
signal rst_clk2: std_logic:='1';
signal timer2_update: std_logic:= '0';
signal timer2_in: std_ulogic_vector(27 downto 0):= timer_vector;
signal timer2_alarm: std_logic:='0';

begin

    -- Create 2 timers
    timer1: timer_module generic map(timer_limit => timer_vector) port map(clock=>clk, rst => rst_clk1, alrm=>timer1_alarm, timer_in => timer1_in, timer_out => timer1_update);
    timer2: timer_module generic map(timer_limit => timer_vector) port map(clock=>clk, rst => rst_clk2, alrm=>timer2_alarm, timer_in => timer2_in, timer_out => timer2_update);

    -- TEST
process(rst,alarm,timer2_update)
    variable state: std_logic_vector(4 downto 0):= off_state;
    variable prev_update: std_logic:='0';
    variable prev_rst: std_logic:='0';
    variable prev_alrm: std_logic:='0';
    begin
        if(rst='1' and prev_rst='0') then
            prev_rst:='1';
            prev_alrm:='0';
            state:=standby_state;
            rst_clk2<='0';
            timer2_in<=sec4;
            
            rst_clk1<='0';
            timer1_alarm<='0';
        elsif(alarm='1' and prev_alrm='0') then
            prev_rst:='0';
            prev_alrm:='1';
            state:=alarm_state;
            timer2_in<=sec7;
            rst_clk2<='0';           

            rst_clk1<='0';
            timer1_alarm<='1';
        elsif(falling_edge(timer2_update)) then
            prev_alrm:='0';
            prev_rst:='0';
            
            if(loopmd='1') then
                state:=backwards_state;
            else
                state:=continious_state;
            end if;
            
            rst_clk2<='1';
            
            rst_clk1<='0';
            timer1_alarm<='0';
        end if;
        current_state<=state;
--        if(rst='1') then
        
----            if(current_state/=standby_state) then
--                current_state<=standby_state;
----                timer2_in<=sec4;
----                if(rst_clk2='1') then
----                    rst_clk2<='0';
----                end if;

----            end if;

--        elsif(alarm='1') then -- rst is now also 0

----            if(current_state/=alarm_state) then
--                current_state<=alarm_state; 
----                timer2_in<=sec7;
----                if(rst_clk2='1') then
----                    rst_clk2<='0';
----                end if;
                
----            end if;
        
--        end if;
--        if(falling_edge(timer2_update) AND alarm='0' and rst='0') then

----            if(current_state=standby_state) then
--                current_state<=continious_state;
            
----            elsif(current_state=alarm_state OR current_state=off_state) then
----                timer2_in<=sec4;
----                current_state<=standby_state;
----            end if;
            
--        end if;
    end process;
    
    process(current_state, timer1_update)
    variable rgb_index: integer:=0;
    variable rgb: rgb_value:=(0,0,0);
    begin
        if(current_state=off_state) then
            r<="00000000";
            g<="00000000";
            b<="00000000";
        elsif(current_state=standby_state) then
            r<="11111111";
            g<="11111111";
            b<="11111111";
        elsif(current_state=alarm_state) then
--            if(falling_edge(timer1_update)) then
--                if(rgb_index>=alarm_sequence'length) then
--                    rgb_index:=0;
--                    rgb:=alarm_sequence(rgb_index);
--                    r<=std_ulogic_vector(TO_UNSIGNED(rgb(0),8)); 
--                    g<=std_ulogic_vector(TO_UNSIGNED(rgb(1),8));
--                    b<=std_ulogic_vector(TO_UNSIGNED(rgb(2),8));
--                    rgb_index:=rgb_index+1;
--                else
--                    rgb:=alarm_sequence(rgb_index);
--                    r<=std_ulogic_vector(TO_UNSIGNED(rgb(0),8)); 
--                    g<=std_ulogic_vector(TO_UNSIGNED(rgb(1),8));
--                    b<=std_ulogic_vector(TO_UNSIGNED(rgb(2),8));
--                    rgb_index:=rgb_index+1;
--                end if;
--          end if;
            if(timer1_update='1') then
                r<="11111111";
                g<="11111111";
                b<="11111111";
            else
                r<="00000000";
                g<="00000000";
                b<="00000000";
            end if;
        elsif(falling_edge(timer1_update)) then
            if(current_state=alarm_state) then
                if(rgb_index>=alarm_sequence'length) then
                    rgb_index:=0;
                    rgb:=alarm_sequence(rgb_index);
                    r<=std_ulogic_vector(TO_UNSIGNED(rgb(0),8)); 
                    g<=std_ulogic_vector(TO_UNSIGNED(rgb(1),8));
                    b<=std_ulogic_vector(TO_UNSIGNED(rgb(2),8));
                    rgb_index:=rgb_index+1;
                else
                    rgb:=alarm_sequence(rgb_index);
                    r<=std_ulogic_vector(TO_UNSIGNED(rgb(0),8)); 
                    g<=std_ulogic_vector(TO_UNSIGNED(rgb(1),8));
                    b<=std_ulogic_vector(TO_UNSIGNED(rgb(2),8));
                    rgb_index:=rgb_index+1;
                end if;
            elsif(current_state=continious_state OR current_state=backwards_state) then    
                if(rgb_index>=continious_state'length) then
                    rgb_index:=0;
                    rgb:=continious_rgb_sequence(rgb_index);
                    r<=std_ulogic_vector(TO_UNSIGNED(rgb(0),8)); 
                    g<=std_ulogic_vector(TO_UNSIGNED(rgb(1),8));
                    b<=std_ulogic_vector(TO_UNSIGNED(rgb(2),8));   
                    rgb_index:=rgb_index+1;
                elsif(loopmd='0') then
                    rgb:=continious_rgb_sequence(rgb_index);
                    r<=std_ulogic_vector(TO_UNSIGNED(rgb(0),8)); 
                    g<=std_ulogic_vector(TO_UNSIGNED(rgb(1),8));
                    b<=std_ulogic_vector(TO_UNSIGNED(rgb(2),8));   
                    rgb_index:=rgb_index+1;     
                elsif(loopmd='1') then
                    rgb:=backwards_rgb_sequence(rgb_index);
                    r<=std_ulogic_vector(TO_UNSIGNED(rgb(0),8)); 
                    g<=std_ulogic_vector(TO_UNSIGNED(rgb(1),8));
                    b<=std_ulogic_vector(TO_UNSIGNED(rgb(2),8));   
                    rgb_index:=rgb_index+1; 
                end if;
            end if;
        end if;
    end process;

    -- Change Loop Speed
    process(speedmd, rst)
    variable speed:std_logic:='0';
    begin

--        if((speed='0' and speedmd='1') OR rst='1') then
--            speed:=speedmd;
--            timer1_in<= timer_vector; -- 1 sec 
--        elsif(speed='1' and speedmd='0') then
--            timer1_in<= "0001000111100001101000110000";--"00001011111010111100001000000000"; -- 3 sec 00010110010110100000101111000000
--        elsif(speed='1' and speedmd='1') then
--            speed:='0';
--            timer1_in<= "0001110111001101011001010000";--"00010011110111100100001101010101"; -- 5 sec 00100101010000001011111001000000
--        end if;

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
