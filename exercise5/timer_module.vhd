library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_module is
  generic(
    clk_div: time:=1250 ms/2; 
    clk_limit: std_logic_vector:= "1111"
  );  
  Port ( 
    rst: in std_logic;
    alrm: in std_logic;
    timer_in: in std_ulogic_vector(clk_limit'Length-1 downto 0);
    timer_out: out std_logic
    );
end timer_module;

architecture Behavioral of timer_module is
signal clk: std_logic;
constant clk_freq: real:= 125.000E6;
constant clk_period: time:=(clk_div/clk_freq)/10; -- time interval for one clock period

signal clk_high: time:= clk_period/2;
signal clk_low: time:= clk_period-clk_high;

begin
    
    -- Clock signal
    process
    begin
        clk<='1';
        wait for clk_high;
        clk<='0';
        wait for clk_low;
    end process;
    
    -- Generate timer clock signal
	process(timer_in, clk, rst, alrm)
	variable update_time: integer:=0;
	variable next_update: integer:=0;
	begin
	   -- Alarm state -> timer clk is 10 times faster
        if(rising_edge(alrm)) then
            update_time:=update_time/10;
            next_update:=0;
            timer_out<='0';
        -- Normal state
        elsif(falling_edge(alrm)) then
            update_time:=update_time*10;
            next_update:=0;
        -- Timer input changed
        elsif(update_time/=to_integer(unsigned(timer_in))*10 AND alrm='0') then
            update_time:=to_integer(unsigned(timer_in));
            update_time:=update_time*10;
            next_update:=0;
            timer_out<='0'; -- set to low on this cycle
            if(update_time<1) then
                update_time:=1;
            end if;   
        end if;
		if(rst='1') then
			update_time:=0;
			next_update:=0; 
		    timer_out<='0';
		else
		    -- After reset
            if(falling_edge(rst)) then
                timer_out<='0'; -- set low by default
                update_time:=1; -- default is 1 (10 ns)
                next_update:=0;
            -- Timer clk 
            elsif(rising_edge(clk)) then
                next_update:= next_update+1;
                if(next_update=update_time) then
                    timer_out<= not timer_out;
                    next_update:=0;
                end if; 
            end if;
           
		end if;
	end process;
	
end Behavioral;
