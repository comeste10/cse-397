----------------------------------------------------------------------------------------------
-- Lab_4_RM																											  --
-- ram																												  --
-- Steve Comer																										  --
-- Updated 28 Oct 2012																							  --
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
	dataOut      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	clear        : IN STD_LOGIC
);

END ram;

----------------------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF ram IS
	
	TYPE tRam IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL sRam : tRam;
			
BEGIN

	-- Writes to RAM or Reads from RAM
	Read_Write_Process : PROCESS(clk,clear)
	
	VARIABLE dataOut_var : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	BEGIN
		-- asynchronous clear
		IF clear = '1' THEN
			dataOut_var := "00";
		-- synchronous remainder
		ELSIF rising_edge(clk) THEN
			IF (readEnable = '1' AND writeEnable = '1') OR
				(readEnable = '0' AND writeEnable = '0') THEN
				dataOut_var := "00";
			ELSIF writeEnable = '1' THEN
				sRam(conv_integer(address)) <= dataIn;
				dataOut_var := "00";
			ELSIF readEnable = '1' THEN
				dataOut_var := sRam(conv_integer(address));
			ELSE
				dataOut_var := "00";
			END IF;
		END IF;
	
		dataOut <= dataOut_var;
	 
	END PROCESS Read_Write_Process;
	
END Behavioral;
