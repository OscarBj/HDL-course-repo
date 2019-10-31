library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    generic(vector_size: integer:=5);
    Port ( 
           clock : in std_ulogic;
           enable : in STD_LOGIC;
           reset : in STD_LOGIC;
           downup : in STD_LOGIC;
           load : in STD_LOGIC;
           data : in std_logic_vector(vector_size-1 downto 0);
           count : out std_logic_vector(vector_size-1 downto 0);
           over : out STD_LOGIC);
end counter;

-- Counter Architecture 1 - Asynchronous
architecture counter_model1 of counter is
begin
    -- All inputs are in sensitivity list -> async
    process(clock,enable,reset,downup,load,data)
    
    variable count_int:integer:=0;
    variable over_count:std_logic:='0';
    
    begin
        -- Reset async
        if(reset = '1') then
            count_int:=0;
            count<=std_logic_vector(TO_UNSIGNED(count_int,vector_size));
            over_count:='0';
            over<=over_count;  
        end if;
        -- Load intermediate output values according to input
        if(load='1') then
            count_int:=to_integer(signed(data));
            over_count:='0'; 
        elsif(downup = '1' AND rising_edge(clock) AND enable = '1') then
            count_int:=count_int+1;
            if(count_int>15) then 
                count_int:=0;
                over_count:='1';
            end if;
        elsif(downup = '0'  AND rising_edge(clock) AND enable = '1') then
            count_int:=count_int-1;
            if(count_int<0) then 
                count_int:=15;
                over_count:='1';
            end if;
        end if;
        -- Assign output at rising edge of the clock
        if(rising_edge(clock) AND enable = '1') then
            count<=std_logic_vector(TO_UNSIGNED(count_int,vector_size));
            over<=over_count;
        end if;
    end process;
    
end counter_model1;

-- Counter Architecture 2 - Synchronous
architecture counter_model2 of counter is
begin
    -- React only to clock and reset
    process (clock, reset) 
    
    variable count_int:integer:=0;
    variable over_count:std_logic:='0';
    
    begin
        -- Reset async
        if(reset = '1') then
            count_int:=0;
            count<=std_logic_vector(TO_UNSIGNED(count_int,vector_size));
            over_count:='0';
            over<=over_count;  
        end if;
        -- Assign intermediate output values on rising edge
        if(rising_edge(clock) AND enable = '1') then
            if(load='1') then
                count_int:=to_integer(signed(data));
                over_count:='0';    
            else 
                if(downup = '1') then
                    count_int:=count_int+1;
                elsif(downup = '0') then
                    count_int:=count_int-1;
                end if;
                if(count_int>15) then 
                    count_int:=0;
                    over_count:='1';
                elsif(count_int<0) then 
                    count_int:=15;
                    over_count:='1';
                end if;
            end if;
            -- Assign output     
            count<=std_logic_vector(TO_UNSIGNED(count_int,vector_size));
            over<=over_count;  
        end if;

    
    end process;
    
end counter_model2;
