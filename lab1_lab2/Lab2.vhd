-- Lab 2
-- Master File (Uses Counter & Hex Driver)
-- Steve Comer
-- Stuart Larsen
-- Team A-Shred
-- Updated 18 Sept 2012
-- 	Combines both counter and HexDriver to create the ultimate sequence generator.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Lab2 IS 

PORT(Reset  			: IN  STD_LOGIC;
	  Clock				: IN 	STD_LOGIC;
	  sevenSegmentOut	: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	  clockLED			: OUT STD_LOGIC;
	  resetLED			: OUT STD_LOGIC);
	  
END Lab2;

ARCHITECTURE Behavioral OF Lab2 IS

COMPONENT counter
	PORT(Reset  : IN  STD_LOGIC;
		  Clock	: IN 	STD_LOGIC;
		  Q		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		  clockLED			: OUT STD_LOGIC;
		  resetLED			: OUT STD_LOGIC);
END COMPONENT;

COMPONENT HexDriver
	PORT(numberToDisplay  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
	     sevenSegmentOut	 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END COMPONENT;

SIGNAL binaryNumberOut : STD_LOGIC_VECTOR(3 DOWNTO 0);
	BEGIN
	
		counter1 : counter PORT MAP(Reset, Clock, binaryNumberOut, clockLED, resetLED);
		hexDriver1 : HexDriver PORT MAP(binaryNumberOut, sevenSegmentOut);
			
	END Behavioral;
