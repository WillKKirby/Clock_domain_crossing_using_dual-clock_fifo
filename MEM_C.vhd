library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 64x16 asynchronous read ROM
entity MEM_C is
    Port ( a : in  UNSIGNED (5 downto 0); -- Address
           spo : out  STD_LOGIC_VECTOR (15 downto 0)); -- Data out
end MEM_C;

architecture Behavioral of MEM_C is

type ROM_Array is array (0 to 63) of std_logic_vector(15 downto 0);

constant Content: ROM_Array := (
x"C000",x"840F",x"3086",x"C406",x"0067",x"4484",x"4063",x"0CA5",x"C725",x"A407",x"48E7",x"4CE7",x"1CE8",x"18A8",x"0409",x"242A",x"C48A",x"C4CA",x"204B",x"C4AB",x"14EC",x"AC0C",x"C70F",
x"201F",x"0001",x"0821",x"C47F",x"A8E1",x"0821",x"0CFF",x"C300",x"8402",x"341E",x"88C3",x"8CC4",x"3B1D",x"8007",x"3045",x"3086",x"C406",x"0067",x"4484",x"4063",x"0CA5",x"C725",x"A407",x"48E7",x"4CE7",x"1CE8",x"18A8",x"0409",x"242A",x"C48A",x"C4CA",x"204B",x"C4AB",x"14EC",x"AC0C",x"108C",x"C44C",x"C000",x"C000",x"A407",x"C000");

begin

spo <= Content(to_integer(a));

end Behavioral;

