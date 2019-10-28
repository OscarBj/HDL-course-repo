library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_module is
  generic(
    clk_div: time:=1250 ms/2; -- > period = 10ns
    clk_limit: std_logic_vector:= "1111"
  );  
  Port ( 
    rst: in std_logic;
    timer_in: in std_ulogic_vector(clk_limit'Length-1 downto 0);
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
    
	process(timer_in, clk, rst)
	variable update_time: integer:=0;
	variable next_update: integer:=0;
	
	begin
        if(update_time/=to_integer(unsigned(timer_in))) then
            update_time:=to_integer(unsigned(timer_in));
            next_update:=update_time-1; -- set to high on this cycle
            if(update_time<1) then
                update_time:=1;
            end if;   
        end if;
		if(rst='1') then
			update_time:=0;
			next_update:=0; 
		    timer_out<='0';
		else
            if(falling_edge(rst)) then
                timer_out<='1'; -- default is 1 (10 ns)
                update_time:=1;
                next_update:=0;
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
