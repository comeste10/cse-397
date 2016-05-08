----------------------------------------------------------------------------------------------
-- Lab 3																												  --
-- reg1																												  --
-- Steve Comer																										  --
-- Derek Tsui																										  --
-- Kevin Vece 																										  --
-- Updated 14 Oct 2012																							  --
-- 	Implements a one bit synchronous register with a load bit and a clear input.			  --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------------------

-- Create and Entity which acts as a one bit register.
ENTITY bitreg IS 

PORT(A  			: IN  STD_LOGIC;				-- The input value for the register
	  clk			: IN  STD_LOGIC;				-- Clock input used for synchrnous load
	  clear		: IN  STD_LOGIC;				-- Clears the value in the register whenever this
														--		value changes
	  B			: OUT STD_LOGIC := '0'		-- The output value of the register
);
END bitreg;

----------------------------------------------------------------------------------------------


ARCHITECTURE Behavioral OF bitreg IS

	-- Declare a signal used to store what value that the clear input is.
	SIGNAL reset : STD_LOGIC := '0';
	
BEGIN
	
	-- This process activates whenever the clock or clear changes
	PROCESS (clk, clear)
	BEGIN
		
		IF clear = not reset THEN		-- If the value of clear changed
			B <= '0';						-- 	then set the output to zero
			reset <= clear;				--		and update the new value of clear
		ELSIF (clk = '1') THEN			-- Otherwise, if the clock is high
			B <= A;							--		update the value of the register to A
		END IF;
		
	END PROCESS;		
		
END Behavioral;
