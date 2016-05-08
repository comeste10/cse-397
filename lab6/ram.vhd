----------------------------------------------------------------------------------------------
-- Lab 6																												  --
-- RAM																												  --
-- Steve Comer																										  --
-- Updated 14 Nov 2012																							  --
-- 	128x4 RAM (128 addresses, 4-bit data)																	  --
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
	address      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	dataIn		 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	dataOut      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	--writeFlag    : OUT STD_LOGIC
);

END ram;

----------------------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF ram IS

	TYPE tRam IS ARRAY (128 TO 255) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL sRam : tRam;
	--
	--SIGNAL writeFlag_temp : STD_LOGIC;
	--
			
BEGIN

	Read_Write_Process : PROCESS(clk)
	--Read_Write_Process : PROCESS(address,dataIn,readEnable,writeEnable)
	
	BEGIN
		
		--
		--writeFlag <= '0';
		--
		
		IF rising_edge(clk) THEN
			IF writeEnable = '1' THEN
				IF readEnable = '0' THEN
					--
					--writeFlag <= '1';
					--
					sRam(conv_integer(address)) <= dataIn;
					dataOut <= "0000";
				END IF;
			ELSIF readEnable = '1' THEN
				IF writeEnable = '0' THEN
					--
					--writeFlag <= '0';
					--
					dataOut <= sRam(conv_integer(address));
				END IF;
			--
			--ELSE
			--	writeFlag <= '0';
			--
			END IF;
		END IF;
	
	END PROCESS Read_Write_Process;
	
		
END Behavioral;
