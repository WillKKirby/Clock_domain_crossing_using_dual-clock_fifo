library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.DigEng.all;

entity OUTPUT_CTRL is
    Generic (disp_delay : natural := 62500000);
    Port ( CLK : in  STD_LOGIC;
           USER_PB : in  STD_LOGIC_VECTOR (3 downto 0);
           SWITCH_ENC : in  UNSIGNED (7 downto 0);
           FROM_SOURCE : in  STD_LOGIC;
           TO_SOURCE : out  STD_LOGIC;
           DATA_FROM_FIFO : in  STD_LOGIC_VECTOR (3 downto 0);
           LEDS : out  STD_LOGIC_VECTOR (3 downto 0);
           FIFO_RD_EN : out  STD_LOGIC;
           FIFO_EMPTY : in  STD_LOGIC);
end OUTPUT_CTRL;

architecture Behavioral of OUTPUT_CTRL is

-- FSM states 
type fsm_states is (idle, wait_state);
signal state, next_state : fsm_states;

-- Control Signals
signal RST : std_logic;

-- Counter signals 
signal disp_counter : unsigned(log2(disp_delay)-1 downto 0);
signal disp_counter_en, disp_counter_rst : std_logic;

begin

---------
-- FSM --
---------

-- Next state process
next_state_process : process(clk) is
begin
    if rising_edge(clk) then
        if RST = '1' then
            state <= idle;
        else 
            state <= next_state;
        end if;
    end if;
end process next_state_process;

-- The state changed for this FSM is that if the empty signal isn't high, 
--    then it will keep running to the wait_state, letting the LEDs.
-- Once the empty signal is high, it will just wait in the idle state, 
--    until more data is ready to be output from the FIFO.

-- State Transitions
State_transition : process (state, FIFO_EMPTY, disp_counter)
begin
    case state is
        when idle => 
            if FIFO_EMPTY /= '1' then 
                next_state <= wait_state;
            else
                next_state <= state;
            end if;
        when wait_state =>
            if disp_counter = disp_delay-1 then
                next_state <= idle;
            else 
                next_state <= state;
            end if;
    end case;
end process State_transition;

-------------------------
-- Combinational Logic --
------------------------- 

-- Reset Signal
RST <= USER_PB(0);
-- Only allows the display counter to count when the state is in work
disp_counter_en <= '1' when state = wait_state else '0';
-- Reset for param counter
disp_counter_rst <= not disp_counter_en;
-- When the state is idle, and it is still running (determined by the FIFO empty term) 
--    the LEDs will output and the read_enable is active. 
-- Otherwise the LEDs will only output 0s
FIFO_RD_EN <= '1' when state = idle and FIFO_EMPTY /= '1' else '0';
LEDS <= DATA_FROM_FIFO when state = idle and FIFO_EMPTY /= '1' else
        (others => '0') when state = idle and FIFO_EMPTY = '1';
-- Sends a logic high when the fifo isn't empty.
-- This indicates it is still working and to not accept any enable signals.
TO_SOURCE <= '1' when FIFO_EMPTY /= '1' or state /= idle else '0';

---------------------
-- Display Counter --
---------------------

-- Assignment for counters -- 
display_time_counter : entity work.Param_Counter
Generic Map (LIMIT => disp_delay)
Port Map ( clk => CLK,
           rst => disp_counter_rst,
           en => disp_counter_en,
           count_out => disp_counter );

end Behavioral;

