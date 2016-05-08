-- Lab 3
-- ALU
-- Steve Comer
-- Derek Tsui
-- Kevin Vece
-- Updated 14 Oct 2012

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pc IS 

PORT(input  	: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);		-- input value
	  clearPC	: IN  STD_LOGIC;								-- clear input for counter
	  incPC		: IN  STD_LOGIC;								-- increment input for counter
	  loadPC		: IN  STD_LOGIC;								-- load input for counter
	  clearX		: IN  STD_LOGIC;								-- clear input for x
	  incX		: IN  STD_LOGIC;								-- increment input for x
	  outSel		: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);		-- output select value
	  clk			: IN STD_LOGIC;								-- clock input for synchronous load
	  output		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));	-- output value of the PC
	  
END pc;

ARCHITECTURE Behavioral OF pc IS
	
	-- Create two registers for both the PC and X
	SIGNAL pcREG : STD_LOGIC_VECTOR(7 DOWNTO 0) REGISTER;
	SIGNAL xREG : STD_LOGIC_VECTOR(7 DOWNTO 0) REGISTER;
	
BEGIN

	-- Change values on a high clock edge
	PROCESS(clk)
	BEGIN
		
		IF (RISING_EDGE(clk)) THEN			-- check fro rising edge of clock
		
			IF clearPC = '1' THEN			-- update the PC, priority is:
				pcREG <= "00000000";			-- 	clear, load, incrememnt
			ELSIF loadPC = '1' THEN
				pcREG <= input;
			ELSIF incPC = '1' THEN
				pcREG <= pcREG + '1';
			END IF;
			
			IF clearX = '1' THEN				-- update the X register, priority is:
				xREG <= "00000000";			-- 	clear, increment
			ELSIF incX = '1' THEN
				xREG <= xREG + '1';
			END IF;
			
		END IF;
		
	END PROCESS;

	-- Update the output
	PROCESS(outSel)
	BEGIN
		CASE (outSel) IS
			WHEN "00" =>							-- 00: PC
				output <= pcREG;
			WHEN "01" =>							-- 01: X + input
				output <= xREG + input;
			WHEN "10" =>							-- 10: input
				output <= input;
			WHEN "11" =>							-- 11: X
				output <= xREG;
			WHEN OTHERS => NULL;					-- safe case, do nothing
		END CASE;
	END PROCESS;
	
END Behavioral;
