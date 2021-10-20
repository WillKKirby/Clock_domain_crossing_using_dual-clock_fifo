library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Single_bit_synchroniser is
    Port ( CLK : in  STD_LOGIC;
           S_IN : in  STD_LOGIC;
           S_OUT : out  STD_LOGIC);
end Single_bit_synchroniser;

architecture Behavioral of Single_bit_synchroniser is

signal Q : STD_LOGIC;

begin

Sync: process (CLK) is
begin
	if (rising_edge(CLK)) then
		Q <= S_IN;
		S_OUT <= Q;
	end if;
end process;

end Behavioral;

