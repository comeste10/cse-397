----------------------------------------------------------------------------------------------
-- Lab 3																												  --
-- reg																												  --
-- Steve Comer																										  --
-- Derek Tsui																										  --
-- Kevin Vece 																										  --
-- Updated 14 Oct 2012																							  --
-- 	Implements a four bit synchronous register with a load bit.									  --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------------------

-- Create an Entity that acts as a four bit register.
ENTITY reg IS 

-- Input and output for the Register
PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- The input value for the register
	  clk			: IN  STD_LOGIC;								-- A clock input used for a synchronous load
	  load		: IN  STD_LOGIC;								-- Load bit, the register will only load
																		--    the value in A if this bit is set
	  B			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- The output, the value of the register
);

END reg;

----------------------------------------------------------------------------------------------


ARCHITECTURE Behavioral OF reg IS
	
BEGIN
	
	-- This is the synchronous load command. When the clock is high and load is set, then the value
	--		of the register is updated
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk) and load = '1') THEN		-- If the clock is on its rising edge and load is set,
			B <= A;												--		then store the value of A into B
		END IF;
	END PROCESS;
		
END Behavioral;
