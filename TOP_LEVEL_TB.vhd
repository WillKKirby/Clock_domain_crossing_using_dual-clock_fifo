library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TOP_LEVEL_TB is
end TOP_LEVEL_TB;

-- My testing stratgy is to enter all switch combinations sequentally, 
-- Then review the timeing simulation to check the circuit is working as exspected.
-- I will after also test it by sending an enable signle while it is running, 
--    to check is doesn't effect the circuit. 
-- I will first reivew the source control, 
--    to check the correct amount of data is being written to the FIFO.
-- I will then check the output control to make sure it is all outputted, 
--    and displayed for the correct amount of time. 

architecture Behavioral of TOP_LEVEL_TB is

-- This clocks allows the clock to run at 125MHz.
constant clk_period : time := 8ns;

-- I/O signals 
signal GCLK : std_logic;
signal BTN : std_logic_vector(3 downto 0);
signal SW : std_logic_vector (1 downto 0);
signal LED : std_logic_vector(3 downto 0);

-- Switch signal array.
type value_Array is array (natural range<>) of std_logic_vector(1 downto 0);
constant switch_values : value_Array := ("00","01","10","11") ;
-- Reset time array - To time when the circuit needs resetitng after running.
type wait_times is array (natural range<>) of integer;
constant reset_gaps : wait_times := (1000,16000,80000,1500000);

begin

-- UUT
UUT : entity work.TOP_LEVEL
-- For the UUT I choose 500 since it is much larger than the ratio between clocks.
GENERIC MAP (disp_delay => 500)
PORT MAP ( GCLK => GCLK,
           BTN => BTN,
           SW => SW,
           LED => LED );

-- Clk process
clk_process : process is
begin
    GCLK <= '1';
    wait for clk_period/2;
    GCLK <= '0';
    wait for clk_period/2;
end process clk_process;

-- Test process
Test_input_phase : process is
begin
    -- Inital wait 
    wait for 2000ns;
    wait until falling_edge(GCLK);
    
    -- INTIAL RESET to reset and clear all the counters 
    
    SW <= "00";
    BTN <= "0001";
    wait for clk_period*25;
    BTN <= "0000";
    wait for clk_period*40;

    BTN <= "0001";
    wait for clk_period*25;
    BTN <= "0000";
    
    -- The wait time after each reset 
    wait for clk_period*200;
    
    for i in 0 to 3 loop
        -- Tests
        -- The switches is fed inputs from the array
        SW <= switch_values(i);
        BTN <= "0100";
        -- Enough time to trigger the debouncers 
        wait for clk_period * 42;
        BTN <= "0000";
        -- The wait time is then also retrieved from an array, 
        -- This is in the case of the last 2 tests a very long time. 
        wait for clk_period * reset_gaps(i);
        
        -- Reset after each input has fully ran
        BTN <= "0001";
        wait for clk_period*40;
        BTN <= "0000";
        
        -- Wait after a reset 
        wait for clk_period*200;
    
    end loop;
    
    -- This is to check that the circuit responds correclty to a button press while it's working.
    -- Sending longest input signal.
    SW <= "11";
    BTN <= "0100";
    wait for clk_period*42;
    BTN <= "0000";
    -- Witing for it to run for a short while.
    wait for clk_period*2000;
    -- Sending a different EN signal.
    SW <= "00";
    BTN <= "0100";
    wait for clk_period*42;
    BTN <= "0000";
    
    
    wait;
end process Test_input_phase;

end Behavioral;
