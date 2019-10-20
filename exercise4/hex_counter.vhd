library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
           over: out STD_LOGIC
           );
end hex_counter;

architecture Behavioral of hex_counter is

signal count_lock: boolean:=True;   
signal count_hex: integer:=0;
signal over_count: std_logic:='0';
begin

--    -- Combinatorial (logic) process
    process(clk)

    begin
        if(load='1') then
            count_hex<=to_integer(unsigned(data));
        end if;
        
        if(rising_edge(clk) AND load='0' and NOT count_lock) then
            if(downup='0') then
               count_hex<=count_hex-1;
            elsif(downup='1') then
               count_hex<=count_hex+1;
            end if;
                
            if(count_hex>16#FF#) then
               count_hex<=16#00#;
            elsif(count_hex<16#00#) then
               count_hex<=16#FF#;
            end if;           
        end if;
    end process;

    -- Register (clock) process
    process(clk, rst)
    begin
        
        if(rst = '1') then
            digit1<= std_logic_vector(TO_UNSIGNED(16#0#,digit_length)); -- reset to 0
            digit2<= std_logic_vector(TO_UNSIGNED(16#0#,digit_length)); -- reset to 0
            over_count<='0';
            over<=over_count;  
        end if;
        
        if(rising_edge(clk)) then
            count_lock<=True;
            
            digit1<= std_logic_vector(TO_UNSIGNED(count_hex mod 16#F#,digit_length));
            digit2<= std_logic_vector(TO_UNSIGNED(count_hex rem 16#F#,digit_length));   
            over<=over_count;
             
            if(over_count='1') then
               over_count<='0';
            end if;
                          
            count_lock<=False;       
        end if;
    end process;
    
    
    
    
--    process (clk, rst) 
--    variable data_int:integer:=0;
--    variable d1:integer:=0;
--    variable d2:integer:=0;
--    variable bias:integer:=1;
--    variable over_count:std_logic:='0';
    
--    begin
--        -- Reset async
--        if(rst = '1') then
--            digit1<= std_logic_vector(TO_UNSIGNED(16#0#,digit_length)); -- reset to 0
--            digit2<= std_logic_vector(TO_UNSIGNED(16#0#,digit_length)); -- reset to 0
--            over_count:='0';
--            over<=over_count;  
--        end if;
--        -- Assign intermediate output values on rising edge
--        if(rising_edge(clk) AND enable = '1') then
--            if(load='1') then
--                data_int:=to_integer(unsigned(data));
--                if(data_int>16#F#) then
--                    d2:=data_int-16#F#;                    
--                    d1:=16#F#;
--                else 
--                    d1:=data_int;
--                    d2:=16#0#;
--                end if;
--                over_count:='0';    
--            else 
--                -- Count up
--                if(downup = '1') then
--                    bias:=1;
--                    -- Count on D2 when D1 is F
--                    if(d1=16#F#) then
--                        d1:=16#F#;
--                        d2:=d2+bias;
--                    end if;      
--                    -- Count on D1 when D2 is 0
--                    if(d2=16#0#) then
--                        d1:=d1+bias;
--                        d2:=16#0#;
--                    end if;
                    
--                -- Count down                                     
--                elsif(downup = '0') then
--                    bias:=-1;
--                    -- Count on D1 when D2 is 0
--                    if(d2=16#0#) then
--                        d1:=d1+bias;
--                        d2:=16#0#;
--                    end if;                       
--                    -- Count on D2 when D1 is F
--                    if(d1=16#F#) then
--                        d1:=16#F#;
--                        d2:=d2+bias;
--                    end if;
--                end if;
                
--                -- Check overflow
--                -- When D2 is over F reset values, aka when count is > 30 -> 0
--                if(d2>16#F#) then 
--                    d1:=16#0#;
--                    d2:=16#0#;
--                    over_count:='1';
--                end if;
--                -- When D1 is less than 0 reset values, aka when count is < 0 -> 30
--                if(d1<16#0#) then 
--                    d2:=16#F#;
--                    d1:=16#F#;
--                    over_count:='1'; 
--                end if;
                
--            end if;
          
--            digit1<=std_logic_vector(TO_UNSIGNED(d1,digit_length));
--            digit2<=std_logic_vector(TO_UNSIGNED(d2,digit_length));
--            over<=over_count; 
             
--            if(over_count='1') then
--                over_count:='0';
--            end if;
            
--        end if;
--    end process;
    
end Behavioral;
