library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hex_counter is
    generic(
        digit_length: integer:=4
    );
    Port ( 
           clk : in STD_ULOGIC;
           rst : in STD_LOGIC;
           enable : in STD_LOGIC;
           downup : in STD_LOGIC;
           load : in STD_LOGIC;
           data : in std_logic_vector((digit_length*2)-1 downto 0);
           digit1 : out std_logic_vector(digit_length-1 downto 0);
           digit2 : out std_logic_vector(digit_length-1 downto 0);
           over: out std_logic
           );
end hex_counter;

architecture Behavioral of hex_counter is

signal count_next: integer:=16#00#;
signal count_curr: integer:=16#00#;
signal over_count: std_logic:='0';

begin

    -- Combinatorial (logic) process
    process(enable,load,data,downup,count_curr)
    variable bias: integer:=1;
    begin
        if(enable='1') then
        
            -- Determine count direction
            if(downup='0') then
               bias:=-1;
            elsif(downup='1') then
               bias:=1;
            end if;
                        
            -- Load data 
            if(load='1') then
               count_next<=to_integer(unsigned(data));
               over_count<='0';
               
            -- Add/subtract when current count is updated with next count
            elsif(count_curr=count_next) then
                
                count_next<=count_next+bias;
                -- Handle overflow
                if(count_next+bias>16#FF#) then
                    over_count<='1';
                    count_next<=16#00#;
                -- Handle underflow    
                elsif(count_next+bias<16#00#) then
                    over_count<='1';
                    count_next<=16#FF#;
                else
                    over_count<='0';
                end if;
     
            end if;
        end if;            
    end process;

    -- Register (clock) process
    process(clk, rst)
    variable count_vector: std_logic_vector(7 downto 0);
    begin
    
        -- Async reset
        if(rst = '1') then
            digit1<= std_logic_vector(TO_UNSIGNED(16#0#,digit_length)); -- reset to 0
            digit2<= std_logic_vector(TO_UNSIGNED(16#0#,digit_length)); -- reset to 0
            over<='0';    
            
        -- Catch rising edge and assign output       
        elsif(rising_edge(clk)) then
            count_vector:=std_logic_vector(TO_UNSIGNED(count_next,digit_length*2));
            
            digit1<= count_vector(7 downto 4);
            digit2<= count_vector(3 downto 0);
               
            over<=over_count;
            
            -- Update current count with next -> allow logic process to add/subtract 
            count_curr<=count_next;
        end if;
    end process;
    
end Behavioral;
