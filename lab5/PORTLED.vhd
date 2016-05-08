----------------------------------------------------------------------------------------------
-- Lab 5																												  --
-- PORTLED																											  --
-- Steve Comer																										  --
-- Edward Hazeldine																								  --
-- Michial Stikkel 																								  --
-- Updated 29 Oct 2012																							  --																				  --
----------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY PORTLED IS

PORT(
	  enable 	  : IN  STD_LOGIC;								-- from address decoder	
	  input  	  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- The input value for the register
	  output	  	  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- The output, for display
);

END PORTLED;

ARCHITECTURE BEHAVIORAL OF PORTLED IS
BEGIN

-- This is the synchronous load command. When the clock is high, then the value
--		of the register is updated
PROCESS (enable)
BEGIN
	IF (enable = '1') THEN		-- If the clock is on its rising edge
		output <= input;			--		then store the value of A into B
	END IF;
END PROCESS;

END BEHAVIORAL;