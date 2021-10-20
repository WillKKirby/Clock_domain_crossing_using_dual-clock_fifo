library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 64x16 asynchronous read ROM
entity MEM_D is
    Port ( a : in  UNSIGNED (5 downto 0); -- Address
           spo : out  STD_LOGIC_VECTOR (15 downto 0)); -- Data out
end MEM_D;

architecture Behavioral of MEM_D is

type ROM_Array is array (0 to 63) of std_logic_vector(15 downto 0);

constant Content: ROM_Array := (
x"0002",x"F80F",x"FC0F",
x"0007",x"43A5",x"0486",x"0806",x"1C67",x"0484",x"0463",x"A0A5",x"E825",x"0007",x"24E7",x"14E7",x"00E8",x"23A8",x"1D09",x"052A",x"248A",x"20CA",x"094B",x"18AB",x"7C1F",x"0001",x"0021",x"147F",x"03E1",x"0021",x"03FF",x"F000",x"4002",x"101E",x"03C3",x"0FC4",x"FC1D",x"0007",x"43A5",x"0486",x"0806",x"1C67",x"0484",x"0463",x"A0A5",x"E825",x"0007",x"24E7",x"14E7",x"00E8",x"23A8",x"1D09",x"052A",x"248A",x"20CA",x"094B",x"18AB",x"2CEC",x"040C",x"2D8C",x"0C4C",x"A000",x"C000",x"FC07",x"F000");

begin

spo <= Content(to_integer(a));

end Behavioral;

