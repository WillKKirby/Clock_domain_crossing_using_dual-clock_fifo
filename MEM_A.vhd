library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 64x16 asynchronous read ROM
entity MEM_A is
    Port ( a : in  UNSIGNED (5 downto 0); -- Address
           spo : out  STD_LOGIC_VECTOR (15 downto 0)); -- Data out
end MEM_A;

architecture Behavioral of MEM_A is

type ROM_Array is array (0 to 63) of std_logic_vector(15 downto 0);

constant Content: ROM_Array := (
x"0004",x"7F80",x"FFFC",x"007C",x"0000",x"0000",x"0014",x"0003",x"0000",x"0003",x"FFF0",x"A040",x"0010",x"0003",x"000F",x"FFFC",x"0000",x"0043",x"0004",x"0008",x"001C",x"0104",x"0104",x"0000",x"FFE8",x"0000",x"0924",x"0314",x"0000",x"0023",x"001D",x"0005",x"0024",x"0020",x"0009",x"0018",x"002C",x"FFFC",x"007C",x"0000",x"0000",x"0014",x"0003",x"0000",x"0003",x"FFF0",x"A040",x"0010",x"0003",x"000F",x"FFFC",x"0000",x"0043",x"0004",x"0008",x"001C",x"0104",x"0004",x"002D",x"000C",x"0000",x"0000",x"07FC",x"0000");

begin

spo <= Content(to_integer(a));

end Behavioral;

