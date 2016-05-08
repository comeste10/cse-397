----------------------------------------------------------------------------------------------
-- Lab 4																												  --
-- ram																												  --
-- Steve Comer																										  --
-- Updated 27 Oct 2012																							  --
-- 	16x4 RAM (16 address, 2-bit data)																	  --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------------------

ENTITY ram IS 

-- Input and output for the RAM
PORT(
	clk          : IN STD_LOGIC;
	readEnable   : IN STD_LOGIC;
	writeEnable  : IN STD_LOGIC;
	address      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	dataIn		 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	dataOut      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
);

END ram;

----------------------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF ram IS

	TYPE tRam IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL sRam : tRam;
			
BEGIN

	-- Performs write operation first
	Read_Write_Process : PROCESS(clk)		
	BEGIN
		IF rising_edge(clk) THEN
			IF writeEnable = '1' THEN
				IF readEnable = '0' THEN
					sRam(conv_integer(address)) <= dataIn;
					dataOut <= "00";
				END IF;
			ELSIF readEnable = '1' THEN
				IF writeEnable = '0' THEN
					dataOut <= sRam(conv_integer(address));
				END IF;
			END IF;
		END IF;	
	END PROCESS Read_Write_Process;
	
		
END Behavioral;
