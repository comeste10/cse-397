-- Lab 3
-- Master File (Uses PC & Display Driver)
-- Steve Comer
-- Derek Tsui
-- Kevin Vece
-- Updated 14 Oct 2012
-- 	Combines both PC and Display Driver to create a Program Counter

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY main_pc IS 

PORT(input  	: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);					-- input value on the PC
	  clearPC	: IN  STD_LOGIC;											-- clear PC register
	  incPC		: IN  STD_LOGIC;											-- increment PC register
	  loadPC		: IN  STD_LOGIC;											-- load PC register
	  clearX		: IN  STD_LOGIC;											-- clear X register
	  incX		: IN  STD_LOGIC;											-- increment X register
	  outSel		: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);					-- select which output to display
	  clk			: IN  STD_LOGIC;											-- clock input
	  clkOut		: OUT STD_LOGIC;											-- clock output, used for testing
																					-- SEVEN SEGMENT DISPLAYS:
	  sevenSegmentOut0		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- first digit on input
	  sevenSegmentOut1		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- second digit on input
	  sevenSegmentOut2		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- first digit on output
	  sevenSegmentOut3		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)	-- second digit on input
);
	  
END main_pc;


ARCHITECTURE Behavioral OF main_pc IS

	-- Declare the Hex driver component to convert hex values into a format for the 
	--		seven segment displays on the board.
	COMPONENT HexDriver
		PORT(numberToDisplay  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			  sevenSegmentOut	 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;

	-- Declare the Program Counter component to do the grunt of the work.
	COMPONENT pc IS 
		PORT(input  	: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			  clearPC	: IN  STD_LOGIC;
			  incPC		: IN  STD_LOGIC;
			  loadPC		: IN  STD_LOGIC;
			  clearX		: IN  STD_LOGIC;
			  incX		: IN  STD_LOGIC;
			  outSel		: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			  clk			: IN  STD_LOGIC;
			  output		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));	  
	END COMPONENT;

	-- Create wires
	SIGNAL output : STD_LOGIC_VECTOR(7 DOWNTO 0);	-- wire used to show output on the PC
	SIGNAL clkNeg : STD_LOGIC;								-- Reverse of the clock input
	
BEGIN
			
	-- Create the program counter and link it to the seven segment displays.
	pc0 : pc PORT MAP(input, clearPC, incPC, loadPC, clearX, incX, outSel, clkNeg, output);
	hexDriver0 : HexDriver PORT MAP(input(7 DOWNTO 4), sevenSegmentOut0);
	hexDriver1 : HexDriver PORT MAP(input(3 DOWNTO 0), sevenSegmentOut1);
	hexDriver2 : HexDriver PORT MAP(output(7 DOWNTO 4), sevenSegmentOut2);
	hexDriver3 : HexDriver PORT MAP(output(3 DOWNTO 0), sevenSegmentOut3);
	
	-- Reverse the clock input so that button pressed = clock high
	PROCESS(clk)
	BEGIN
		clkNeg <= NOT clk;
		clkOut <= NOT clk;
	END PROCESS;
				
END Behavioral;
