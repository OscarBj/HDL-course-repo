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
    count: out std_ulogic_vector(clk_limit'Length-1 downto 0)
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
    
    process(clk,rst)
    variable count_int: integer:=0;
    begin
        if(rst='1') then
            count_int:=0;
            count<=std_ulogic_vector(TO_UNSIGNED(count_int,clk_len)); -- update timer count
        end if;
        if(rising_edge(clk)) then
            count_int:= count_int+1;
            
            -- Make sure to not cause an overflow on the count vector by reseting count int
            if(count_int>to_integer(unsigned(clk_limit))) then 
                count_int:=0;
            end if;
            count<=std_ulogic_vector(TO_UNSIGNED(count_int,clk_len)); -- update timer count
        end if;
    end process;
end Behavioral;
