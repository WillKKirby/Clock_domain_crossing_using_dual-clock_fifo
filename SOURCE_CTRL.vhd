library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SOURCE_CTRL is
    Port ( CLK : in  STD_LOGIC;
           USER_PB : in  STD_LOGIC_VECTOR (3 downto 0);
           SWITCH_ENC : in  UNSIGNED (7 downto 0);
           FIFO_FULL : in  STD_LOGIC;
           FIFO_WR_EN : out  STD_LOGIC;
           TO_OUTPUT : out  STD_LOGIC;
           FROM_OUTPUT : in  STD_LOGIC;
           RST_SOURCE : out  STD_LOGIC;
           EN_SOURCE : out  STD_LOGIC);
end SOURCE_CTRL;

architecture Behavioral of SOURCE_CTRL is

-- Setting en and rst signals from buttons
signal EN, RST : std_logic;

-- FSM signals
type fsm_types is (idle, wait_state, work);
signal state, next_state : fsm_types;

-- Counter signals to know when the amount of data being read is done.
signal counter_val : unsigned(7 downto 0);
signal counter_en, counter_rst : std_logic;

begin

---------
-- FSM --
---------
 
-- FSM processes and logic 
next_state_process : process (clk) is
begin
    if rising_edge(clk) then
        if RST = '1' then
            state <= idle;
        else
            state <= next_state;
        end if;
    end if;
end process next_state_process;

-- Moving state process -- 
-- The logic process for my FSM is to wait in idle until there is an enable button press,
-- It will move to work and stay there either until it has sent all the data, then move back to idle.
-- Or, until the FIFO is full, it will them move to the wait_state until the FIFO is no longer full, 
--    to resume its working. 
fsm : process (state, EN, FIFO_FULL, counter_val) is
begin
    case state is
        when idle => 
            if (EN = '1') then
                next_state <= work;
            else
                next_state <= state;
            end if;
        when work =>
            if (FIFO_FULL = '1') then 
                next_state <= wait_state;
            elsif (counter_val = SWITCH_ENC) then
                next_state <= idle;
            else
                next_state <= state;
            end if;
        when wait_state =>
            if (FIFO_FULL = '0') then
                next_state <= work;
            else 
                next_state <= state;
            end if;
    end case;
end process fsm;

--------------------------
-- Combainational Logic -- 
--------------------------

-- Control Logic,
-- The condition for the EN signal is that when it is pressed, 
--    the output source can't be working at the same time. 
EN <= USER_PB(2) when FROM_OUTPUT = '0' else '0';
RST <= USER_PB(0);
-- Setting signals to ports 
EN_SOURCE <= '1' when state = work and FIFO_FULL /= '1' else '0';
-- Add methods of resetting after the enable signal 
RST_SOURCE <= RST; 
-- Logic for the Write enable 
FIFO_WR_EN <= '1' when state = work and counter_val > 0 and FIFO_FULL /= '1' else '0';
-- Counter logic 
counter_en <= '1' when state = work and FIFO_FULL /= '1' else '0';
counter_rst <= '1' when state = idle or RST = '1' else '0';

---------------------------
-- Data Retrival Counter --  
---------------------------

-- Counter for knowing how long to let the data_source run.
-- This counter counts with the data_source until it reaches SWITCH_ENC

counter : process (clk) is
begin
    if rising_edge(clk) then
        if counter_rst = '1' then
            counter_val <= (others => '0');
        elsif counter_en = '1' then
--            if (counter_val = SWITCH_ENC) then
--                counter_val <= (others => '0');
--            else
                counter_val <= (counter_val + 1);
--            end if;
        end if;
    end if;
end process counter;

end Behavioral;

