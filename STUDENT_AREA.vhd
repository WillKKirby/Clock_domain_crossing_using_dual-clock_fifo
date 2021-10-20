library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library xpm;
use xpm.vcomponents.all;

use work.DigEng.all;

-- This is where your work goes. Of course, you will have to put
--   your own comments in, to describe your work.

entity STUDENT_AREA is
    Generic (disp_delay : natural := 62500000);
    Port ( CLK_125MHZ : in  STD_LOGIC;
           CLK_7MHZ : in  STD_LOGIC;
           -- 7MHZ Debounced button inputs
           USER_PB_7MHZ : in  STD_LOGIC_VECTOR (3 downto 0);
           -- 100MHZ Debounced button inputs
           USER_PB_125MHZ : in  STD_LOGIC_VECTOR (3 downto 0);
           -- Board switches (not debounced)
           SWITCHES : in  STD_LOGIC_VECTOR (1 downto 0);
           -- Board LEDs
           LED_DISPLAY : out  STD_LOGIC_VECTOR (3 downto 0);
           -- Control signals for the data source
           RST_SOURCE : out  STD_LOGIC;
           EN_SOURCE : out  STD_LOGIC;
           SOURCE_DATA : in  STD_LOGIC_VECTOR (31 downto 0)
         );
end STUDENT_AREA;

architecture Behavioral of STUDENT_AREA is

signal FIFO_data_out : STD_LOGIC_VECTOR (3 downto 0);
signal FIFO_wr_en, FIFO_rd_en, FIFO_full, FIFO_empty : STD_LOGIC;

signal source_to_output, output_to_source : STD_LOGIC;
signal source_to_output_sync, output_to_source_sync : STD_LOGIC;

-- The number of samples to be displayed depending on the switches
--   Switches = 00 -> Samples = 0
--   Switches = 01 -> Samples = 3
--   Switches = 10 -> Samples = 15
--   Switches = 11 -> Samples = 225
signal SWITCH_ENC : UNSIGNED (7 downto 0);

begin

-- Number of samples to be displayed
with SWITCHES select 
    SWITCH_ENC <= to_unsigned(0,8)   when "00",
                  to_unsigned(3,8)   when "01",
                  to_unsigned(15,8)  when "10",
                  to_unsigned(255,8) when "11",
                  (others => 'U')    when others;

-- Dual-clock FIFO for clock domain crossing
--   depth = 32 32-bit words.
--   32-bit write port (connected to the 7MHZ clock)
--   4-bit read port (connected to the 125MHZ clock)
--   First-Word-Fall-Through
Synchronization_FIFO : entity work.DUAL_CLOCK_FIFO
PORT MAP (
   rst => USER_PB_7MHZ(1),
   wr_clk => CLK_7MHZ,
   rd_clk => CLK_125MHZ,
   din => SOURCE_DATA,
   wr_en => FIFO_wr_en,
   rd_en => FIFO_rd_en,
   dout => FIFO_data_out,
   full => FIFO_full,
   empty => FIFO_empty
);

-- 2-DFF Clock Domain Crossing Single-bit Synchronizer
-- Note: The input data must be sampled two or more times by the 
--  destination clock
Sync_output_FSM_state: entity work.Single_bit_synchroniser 
PORT MAP(
	CLK => CLK_7MHZ,
	S_IN => source_to_output,
	S_OUT => source_to_output_sync
);

-- xpm_cdc_single: Clock Domain Crossing Single-bit Synchronizer
-- Xilinx Parameterized Macro, Version 2016.4
-- Note: The input data must be sampled two or more times by the 
--  destination clock
Sync_source_FSM_state: xpm_cdc_single
GENERIC MAP (
  DEST_SYNC_FF => 2,   -- integer; range: 2-10
  SIM_ASSERT_CHK => 0, -- integer; 0=disable simulation messages, 
                       --          1=enable simulation messages
  SRC_INPUT_REG => 0   -- integer; 0=do not register input, 
                       --          1=register input
)
PORT MAP (
  src_clk => CLK_7MHZ,    -- used only when SRC_INPUT_REG = 1
  src_in => output_to_source, 
  dest_clk => CLK_125MHZ,
  dest_out => output_to_source_sync
);


SOURCE_CONTROL_LOGIC: entity work.SOURCE_CTRL 
PORT MAP(
	CLK => CLK_7MHZ,
	USER_PB => USER_PB_7MHZ,
	SWITCH_ENC => SWITCH_ENC,
	FIFO_FULL => FIFO_full,
	FIFO_WR_EN => FIFO_wr_en,
	TO_OUTPUT => source_to_output,
	FROM_OUTPUT => output_to_source_sync,
	RST_SOURCE => RST_SOURCE,
	EN_SOURCE => EN_SOURCE
);


OUTPUT_CONTROL_LOGIC: entity work.OUTPUT_CTRL
GENERIC MAP (disp_delay => disp_delay)
PORT MAP(
	CLK => CLK_125MHZ,
	USER_PB => USER_PB_125MHZ,
	SWITCH_ENC => SWITCH_ENC,
	FROM_SOURCE => source_to_output_sync,
	TO_SOURCE => output_to_source,
	DATA_FROM_FIFO => FIFO_data_out,
	LEDS => LED_DISPLAY,
	FIFO_RD_EN => FIFO_rd_en,
	FIFO_EMPTY => FIFO_empty
);

end Behavioral;

