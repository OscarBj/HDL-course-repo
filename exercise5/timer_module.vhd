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
    timer_update: in std_ulogic_vector(clk_limit'Length-1 downto 0);
    count: out std_ulogic_vector(clk_limit'Length-1 downto 0);
    timer_clk: out std_logic
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
    
    process(timer_update, count, rst)
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
            timer_clk<='0'; -- requires a reset before functioning 
        elsif(update_int/=to_integer(unsigned(timer_update)) AND timer_update<=clk_limit) then
            update_int:=to_integer(unsigned(timer_update));
            update_high:=update_int/2;
            update_low:=update_int-update_high;
            next_update:=update_high;
            active:=true;
        elsif(prev_count/=count AND active) then
            next_update:=next_update-1;
            prev_count:=count;
        end if;
        if(active AND next_update>=0) then
            timer_clk<=not timer_clk;
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
