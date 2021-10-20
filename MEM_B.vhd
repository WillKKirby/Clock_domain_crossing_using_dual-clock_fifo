library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 64x16 asynchronous read ROM
entity MEM_B is
    Port ( a : in  UNSIGNED (5 downto 0); -- Address
           spo : out  STD_LOGIC_VECTOR (15 downto 0)); -- Data out
end MEM_B;

architecture Behavioral of MEM_B is

type ROM_Array is array (0 to 63) of std_logic_vector(15 downto 0);

constant Content: ROM_Array := (
x"C000",x"8407",x"C7FF",x"2000",x"0000",x"0800",x"C400",x"A800",x"0800",x"0C00",x"C3FF",x"8400",x"3400",x"8800",x"8C00",x"3BFF",x"8000",x"3000",x"3000",x"C400",x"0000",x"4401",x"4001",x"0C00",x"C7FF",x"A400",x"4809",x"4C03",x"1C00",x"1800",x"0400",x"2400",x"C400",x"C400",x"2000",x"C400",x"1400",x"AC00",x"1000",x"C400",x"C3FF",x"8400",x"3400",x"8800",x"8C00",x"3BFF",x"8000",x"3000",x"3000",x"C400",x"0000",x"4401",x"4001",x"0C00",x"C7FF",x"A400",x"4809",x"4C03",x"1C00",x"1800",x"C000",x"C000",x"A407",x"C000");

begin

spo <= Content(to_integer(a));

end Behavioral;

