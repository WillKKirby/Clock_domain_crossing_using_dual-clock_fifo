
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.DigEng.all;

entity DATA_SOURCE is
    Generic (data_size : natural := 16;
	          num_samples : natural := 64);
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (data_size*2-1 downto 0));
end DATA_SOURCE;

architecture Behavioral of DATA_SOURCE is
 
signal A, B, C, D : UNSIGNED (data_size-1 downto 0);
signal INTA, INTB, INTC, INTD : UNSIGNED (data_size-1 downto 0);
signal INTO : UNSIGNED (data_size*2-1 downto 0);
signal INT1 : UNSIGNED (data_size*2-1 downto 0);
signal INT2 : UNSIGNED (data_size*2-1 downto 0);
signal INT3 : UNSIGNED (data_size*2-1 downto 0);
signal INT4 : UNSIGNED (data_size*2-1 downto 0);
signal INT5 : UNSIGNED (data_size*2-1 downto 0);
signal mem_addr : UNSIGNED (log2(num_samples)-1 downto 0);

--attribute keep : string;
--attribute keep of A : signal is "true";
--attribute keep of B : signal is "true";
--attribute keep of C : signal is "true";
--attribute keep of D : signal is "true";
--attribute keep of INTA : signal is "true";
--attribute keep of INTB : signal is "true";
--attribute keep of INTC : signal is "true";
--attribute keep of INTD : signal is "true";
--attribute keep of INTO : signal is "true";

begin

INTA <= unsigned(A);
INTB <= unsigned(B);
INTC <= unsigned(C);
INTD <= unsigned(D);
			
INT1 <= INTA*3;
INT2 <= INTB*INTC;
INT3 <= INT1 + INT2;
INT4 <= INT3 / INTD;
INT5 <= INT4 + INTC;
INTO <= INT5 + 5;

outputreg: process (CLK) is
	begin
	if rising_edge(CLK) then
		if RST = '1' then 
			DATA_OUT <= (others => '0');
		elsif (EN = '1') then 
			DATA_OUT <= std_logic_vector(INTO);
		end if;
	end if;
end process outputreg;

Address_Counter: entity work.Param_Counter 
GENERIC MAP (LIMIT => num_samples)
PORT MAP(
	clk => CLK,
	rst => RST,
	en => EN,
	count_out => mem_addr 
);

DATA_SOURCE_A : entity work.MEM_A
PORT MAP (
	a => mem_addr,
	unsigned(spo) => A
);

DATA_SOURCE_B : entity work.MEM_B
PORT MAP (
	a => mem_addr,
	unsigned(spo) => B
);

DATA_SOURCE_C : entity work.MEM_C
PORT MAP (
	a => mem_addr,
	unsigned(spo) => C
);

DATA_SOURCE_D : entity work.MEM_D
PORT MAP (
	a => mem_addr,
	unsigned(spo) => D
);


end Behavioral;


