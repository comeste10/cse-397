----------------------------------------------------------------------------------------------
-- Lab 4																												  --
-- ram_driver																										  --
-- Steve Comer																										  --
-- Updated 27 Oct 2012																							  --
-- 	Driver for ram																	                       --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------------------

ENTITY ram_driver IS 

-- Input and output for the RAM_driver
-- Note: *_d shows that a value is an instance in the driver, not the component itself
PORT(
	clk_d              : IN STD_LOGIC;
	readEnable_d       : IN STD_LOGIC;
	writeEnable_d      : IN STD_LOGIC;
	address_d          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	dataIn_d		       : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	sevenSegmentOut_d  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	clkOut_d           : OUT STD_LOGIC
);

END ram_driver;

----------------------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF ram_driver IS
	
	-- See ram.vhd
	COMPONENT ram
		PORT(
			clk          : IN STD_LOGIC;
			readEnable   : IN STD_LOGIC;
			writeEnable  : IN STD_LOGIC;
			address      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			dataIn		 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			dataOut      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;
	
	-- See display_driver.vhd
	COMPONENT HexDriver
		PORT(
			numberToDisplay  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			sevenSegmentOut  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;
	
	-- Ensures that values updated in ram are displayed correctly in HexDriver
   SIGNAL dataOut_signal : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL clkNeg_signal  : STD_LOGIC;
	
BEGIN
		
	Negate_Clock_Process : PROCESS(clk_d)
	BEGIN
		clkNeg_signal <= NOT clk_d;		-- store the reversed value in the clkNeg wire
		clkOut_d <= NOT clk_d;		      -- use this value for the clock output check
	END PROCESS Negate_Clock_Process;
	
	ram_d : ram PORT MAP(clkNeg_signal,readEnable_d,writeEnable_d,address_d,dataIn_d,dataOut_signal);
	hexDriver_d : HexDriver PORT MAP(dataOut_signal,sevenSegmentOut_d);
		
END Behavioral;
