----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2019 03:11:28 PM
-- Design Name: 
-- Module Name: rgb_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rgb_top is
    -- swtich vector maps to RESET, SPEED, MODE, ALARM
--    generic(
--        timer_vector: std_ulogic_vector(31 downto 0):= "00000111011100110101100101000000";  --"00000011111110010100000010101010"; -- 1 sec "00000111011100110101100101000000"
--        sec4: std_ulogic_vector(31 downto 0):= "00011101110011010110010100000000";          --"00001111111001010000001010101010"; -- 4 sec "00011101110011010110010100000000"
--        sec7: std_ulogic_vector(31 downto 0):= "00110100001001110111000011000000"          --"00011011110100001100010010101010"  -- 7 sec "00110100001001110111000011000000"
--    );
    Port ( 
           sysclk: in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR(3 downto 0);
           led5_r : out STD_LOGIC;
           led5_g : out STD_LOGIC;
           led5_b : out STD_LOGIC);
end rgb_top;

architecture Behavioral of rgb_top is

    component driver_module is
        Port ( 
            clk: in std_logic;
            rst: in std_logic;
            speedmd: in std_logic;--(1 downto 0);
            loopmd: in std_logic;
            alarm: in std_logic;
            red: out std_logic_vector;--(7 downto 0);
            blue: out std_logic_vector;--(7 downto 0);
            green: out std_logic_vector--(7 downto 0)
            );    
    end component;       
    
--    component rgb is 
--    Port(
--           clk: in std_logic;
--           a : in STD_LOGIC;
--           b : in STD_LOGIC;
--           c : in STD_LOGIC;
--           d : in STD_LOGIC;
--           rr : out STD_LOGIC;
--           gg : out STD_LOGIC;
--           bb : out STD_LOGIC
--    );
--    end component;     
    
    -- These values cannot be directly mapped to I/O    
    signal speed_mode: std_logic_vector(1 downto 0):="01";
    signal r: std_ulogic_vector(7 downto 0);
    signal g :std_ulogic_vector(7 downto 0);
    signal b: std_ulogic_vector(7 downto 0);
    
    signal sw_rst: std_logic:='1';
    signal sw_speedmd: std_logic:='0';
    signal sw_loopmd: std_logic:='0';
    signal sw_alarm: std_logic:='0';
    
    -- Testing
    --signal clock: std_logic:='0';
--    signal clk2: std_logic;
--    signal rst_clk2: std_logic:='0';
--    signal timer2_update: std_logic:= '0';
--    signal timer2_in: std_ulogic_vector(31 downto 0):= "00000000101111101011110000100000";--"00000111011100110101100101000000";11110100001001000
--    signal timer2_alarm: std_logic:='0';
    
--    component timer_module
--    generic(
--        timer_limit: std_logic_vector
--    );
--    port(
--        clock: in std_logic;
--        rst: in std_logic;
--        alrm: in std_logic;
--        timer_in: in std_ulogic_vector;
--        timer_out: out std_logic
--        );
--    end component;
begin

--process(sysclk)
--variable n: integer:=0;
--begin
--    if(falling_edge(sysclk)) then
--        n := n+1;
--        if(n=6e7) then
--            clock<= not clock;
--            n:=0;
--        end if;
--    end if;
--end process;

--process(clock)
--variable n: std_logic:='0';
--variable count: integer:=0;
--begin
--    if(rising_edge(clock)) then
--        count:=count+1;
--        if(count>2) then
--            count:=0;
--        end if;
--        if(count=0) then
--            led5_r<= '1';
--            led5_g<= '0';
--            led5_b<= '0';
--        elsif(count=1) then
--            led5_r<= '0';
--            led5_g<= '1';
--            led5_b<= '0';
--        else
--            led5_r<= '0';
--            led5_g<= '0';
--            led5_b<= '1';
--        end if;

        
--    end if;
--end process;
sw_rst<=sw(0);
sw_speedmd<=sw(1);
sw_loopmd<=sw(2);
sw_alarm<=sw(3);
--timer2: timer_module generic map(timer_limit => timer_vector) port map(clock=>sysclk, rst => rst_clk2, alrm=>timer2_alarm, timer_in => timer2_in, timer_out => timer2_update);

driver: driver_module port map(clk=>sysclk, rst=>sw_rst, speedmd=>sw_speedmd, loopmd=>sw_loopmd, alarm=>sw_alarm, red=>r, blue=>b, green=>g);
--driver: rgb port map(timer2_update, sw(0),sw(1),sw(2),sw(3), led5_r,led5_g,led5_b);
--clock<=sysclk;

-- Change speed
--process(sw(1))
--variable prev_speed:std_logic:='0';
--variable curr_speed:integer:=1;
--begin

--    curr_speed:=curr_speed+1;
--    if(curr_speed>3) then
--        curr_speed:=1;
--    end if;
--    speed_mode<=std_ulogic_vector(TO_UNSIGNED(curr_speed,2));

--end process;

-- PWM processes for the RGB values outputted from driver
process(r,sysclk)
variable rr: std_logic:='0';
begin
    if(r="11111111") then
        led5_r<='1';
    elsif(r="00000000") then
        led5_r<='0';
    else
        rr:= not rr;
        led5_r<= rr;
    end if;
end process;

process(g,sysclk)
begin
    if(g="11111111") then
        led5_g<='1';
    elsif(g="00000000") then
        led5_g<='0';
    end if;
end process;

process(b,sysclk)
variable bb: std_logic:='0';
begin
    if(b="11111111") then
        led5_b<='1';
    elsif(b="00000000") then
        led5_b<='0';
    else
        bb:= not bb;
        led5_b<= bb;
    end if;
end process;

end Behavioral;
