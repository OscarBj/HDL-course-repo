library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_module is
  generic(
    timer_limit: std_logic_vector:= "1111"
  );  
  Port ( 
    clock: in std_logic;
    rst: in std_logic;
    alrm: in std_logic;
    timer_in: in std_ulogic_vector(timer_limit'Length-1 downto 0);
    timer_out: out std_logic
    );
end timer_module;

architecture Behavioral of timer_module is
--signal update_t: integer:=0;
begin
--    process(alrm, timer_in)
--    variable t_in: std_ulogic_vector(timer_limit'Length-1 downto 0):=timer_limit;
--    begin
--        if(timer_in/=t_in) then
--            update_t<=to_integer(unsigned(timer_in))*10;
--            t_in:=timer_in;
--        end if;
--    end process;
    -- Generate timer clock signal
	process(timer_in, clock, rst, alrm)
	variable update_time: integer:=0;
	variable next_update: integer:=0;
	variable alrm_var: std_logic:='0';
	variable prev_rst: std_logic:='1';
	begin
	
	   -- Alarm state -> timer clock is 10 times faster
--        if(rising_edge(alrm)) then
--            update_time:=update_time/10;
--            next_update:=0;
--            timer_out<='0';
--        -- Normal state
--        elsif(falling_edge(alrm)) then
--            update_time:=update_time*10;
--            next_update:=0;
        if(alrm_var/=alrm) then
            if(alrm='1') then
                update_time:=update_time/10;
                next_update:=0;
                timer_out<='0';
                alrm_var:=alrm;
            else
                update_time:=update_time*10;
                next_update:=0;
                alrm_var:=alrm;
            end if;
             
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
		    prev_rst:=rst;
			update_time:=0;
			next_update:=0; 
		    timer_out<='0';
		else
		    -- After reset
            if(rst='0' AND prev_rst='1') then
                prev_rst:=rst;
                timer_out<='0'; -- set low by default
                update_time:=1; -- default is 1 (10 ns)
                next_update:=0;
            -- Timer clock 
            elsif(rising_edge(clock)) then
                next_update:= next_update+1;
                if(next_update=update_time) then
                    timer_out<= not timer_out;
                    next_update:=0;
                end if; 
            end if;
           
		end if;
	end process;
	
end Behavioral;
