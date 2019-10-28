library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_module is
  generic(
    clk_div: time:=1.25 sec;
    clk_limit: std_logic_vector:= "1111"
  );  
  Port ( 
    rst: in std_logic;
    timer_in: in std_ulogic_vector(clk_limit'Length-1 downto 0);
    count: out std_ulogic_vector(clk_limit'Length-1 downto 0);
    timer_out: out std_logic
    );
end timer_module;

architecture Behavioral of timer_module is
signal clk: std_logic;
constant clk_freq: real:= 125.000E6;
constant clk_period: time:=clk_div/clk_freq; -- time interval for one clock period
constant clk_high: time:= clk_period/2;
constant clk_low: time:= clk_period-clk_high;
constant clk_len: integer:=clk_limit'length;
begin
    process
    begin
        clk<='1';
        wait for clk_high;
        clk<='0';
        wait for clk_low;
    end process;
    
	-- TODO: skip the count stuff, this forces handling and reseting the count vector
	-- Instead, only use timer; Remove continuous clock (global clock) and only use two timers when needed (alarm state)
	-- Timer could be defined in ms, but the input can be seconds to be able to minimize input vector size and still be able to 
	-- divide timer into clock cycle without loosing precision
	
	process(timer_in, clk, rst)
	variable update_time: integer:=0;
	variable next_update: integer:=0;
	
	begin
		if(rst='1') then
			t:=0;
			update_time:=0;
			next_update:=-1; -- To prevent triggering update for timer_out
		
		elsif(next_update=0) then
			timer_out<= not timer_out;
			next_update:=update_time/2; -- NOTE: this makes the timer signal continious, could also be reset here
		
		elsif(rising_edge(clk)) then
			next_update:=next_update-1;
		
		elsif(update_time/=to_integer(unsigned(timer_in))) then
			update_time:=to_integer(unsigned(timer_in))*10; -- sec to 1/10 sec
			next_update:=update_time/2; -- no precision lost bc conversion ^^ NOTE: ADJUST THE CLOCK SPEED ACCORDINGLY
			
		end if;
	end process;
	
    process(timer_in, count, rst)
    variable prev_count: std_ulogic_vector(clk_limit'Length-1 downto 0);
    variable update_int: integer:=0;
    variable update_high: integer:=0;
    variable update_low: integer:=0;
    variable next_update: integer:= 0;
    variable active: boolean:=false;
    begin

        if(rst='1') then
            active:=false;
            update_int:=0;
            update_high:=0;
            update_low:=0;
            next_update:=0;
            timer_out<='0'; -- requires a reset before functioning 
        elsif(update_int/=to_integer(unsigned(timer_in)) AND timer_in<=clk_limit) then
            update_int:=to_integer(unsigned(timer_in));
            update_high:=update_int/2;
            update_low:=update_int-update_high;
            next_update:=update_high;
            active:=true;
        elsif(prev_count/=count AND active) then
            next_update:=next_update-1;
            prev_count:=count;
        end if;
        if(active AND next_update>=0) then
            timer_out<=not timer_out;
            if(next_update=update_high) then
                next_update:=update_low;
            elsif(next_update=update_low) then
                next_update:=update_high;
            end if;    
        end if;
    end process;
    
    process(clk,rst)
    variable count_int: integer:=0;
    begin
        if(rst='1') then
            count_int:=0;
            count<=std_ulogic_vector(TO_UNSIGNED(count_int,clk_len)); -- update timer count
        
        elsif(rising_edge(clk)) then
            count_int:= count_int+1;
            
            -- Make sure to not cause an overflow on the count vector by reseting count int
            if(count_int>to_integer(unsigned(clk_limit))) then 
                count_int:=0;
            end if;
            count<=std_ulogic_vector(TO_UNSIGNED(count_int,clk_len)); -- update timer count
        end if;
    end process;
end Behavioral;
