----------------------------------------------------------------------------------------------
-- Lab 5																												  --
-- ROM																												  --
-- Steve Comer																										  --
-- Edward Hazeldine																								  --
-- Michial Stikkel 																								  --
-- Updated 29 Oct 2012																							  --
-- 	Saves the Values in ROM																					  --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------------------

ENTITY ROM IS

PORT(
	clk     : IN STD_LOGIC;
	address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	dataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END ROM;

ARCHITECTURE Behavioral OF ROM IS
	--setting up the values of the ROM
	TYPE tROM IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	CONSTANT cRom : tROM := (
		0  => "0000",
		1  => "1100",
		2  => "0011",
		3  => "0110",
		4  => "0000",
		5  => "0001",
		6  => "0001",
		7  => "1111",
		8  => "0011",
		9  => "0110",
		10 => "0000",
		11 => "1110",
		12 => "1111",
		13 => "0010",
		14 => "0001",
		15 => "1100",
		16 => "0011",
		17 => "0110",
		18 => "0000",
		19 => "1111",
		20 => "0010",
		21 => "0001",
		22 => "1100",
		23 => "0011",
		24 => "0110",
		25 => "0000",
		26 => "0011",
		27 => "0110",
		28 => "0000",
		29 => "0110",
		30 => "0011",
		31 => "1001");
	 
BEGIN

	Read_Process : PROCESS(clk)
	--Returning the value requested 
	VARIABLE trunc_addr : STD_LOGIC_VECTOR(4 DOWNTO 0);
	BEGIN
		IF rising_edge(clk) THEN
			trunc_addr := address(4 DOWNTO 0);
			dataOut <= cROM(conv_integer(trunc_addr));
		END IF;
	END PROCESS Read_Process;
	
		
END Behavioral;