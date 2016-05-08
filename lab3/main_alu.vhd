----------------------------------------------------------------------------------------------
-- Lab 3																												  --
-- Master File (Uses ALU & Hex Driver)																		  --
-- Steve Comer																										  --
-- Derek Tsui																										  --
-- Kevin Vece 																										  --
-- Updated 24 Sept 2012																							  --
-- 	Combines both counter and HexDriver to create the ultimate sequence generator.		  --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------------------


-- Create an Entity that connects the ALU to the HexDriver for a user interface
ENTITY main_alu IS 

-- Input and output for the entire ALU
PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);				-- connected to switches 17 thru 14
	  B			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);				-- connected to switches 13 thru 10
	  loadA		: IN  STD_LOGIC;										-- connected to switch 9
	  loadB		: IN  STD_LOGIC;										-- connected to switch 8
	  loadZ		: IN  STD_LOGIC;										-- connected to switch 7
	  fSelect	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);				-- connected to switches 2 thru 0
	  clk			: IN  STD_LOGIC;										-- connected to key 3
	  zOut		: OUT STD_LOGIC;										-- connected to LED R12
	  clkOut 			 : OUT STD_LOGIC;								-- connected to LED G6
	  loadA_out			 : OUT STD_LOGIC;								-- connected to LED R9
	  loadB_out			 : OUT STD_LOGIC;								-- connected to LED R8
	  loadZ_out			 : OUT STD_LOGIC;								-- connected to LED R7
	  sevenSegmentOut0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- connected to HEX 7
	  sevenSegmentOut1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- connected to HEX 5
	  sevenSegmentOut2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)		-- connected to HEX 3
);
	    
END main_alu;

----------------------------------------------------------------------------------------------


ARCHITECTURE Behavioral OF main_alu IS

	-- The display driver for the seven segment displays
	COMPONENT HexDriver
		PORT(numberToDisplay  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);	-- hexadecimal number to display
			  sevenSegmentOut	 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)		-- conversion of the number into
		);																				--   a seven element vector for
																						--   the seven segment display
	END COMPONENT;

	-- The actual logic unit
	COMPONENT alu IS 
		PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- input A, or the accumulator
			  B			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- input B
			  loadA		: IN  STD_LOGIC;								-- tells ALU to load the A register
			  loadB		: IN  STD_LOGIC;								-- tells ALU to load the B register
			  loadZ		: IN  STD_LOGIC;								-- tells ALU to load the Z register
																				--		if the output is zero
			  fSelect	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);		-- tells ALU which function to perform
			  clk			: IN  STD_LOGIC;								-- used to synchronize loads
			  zOut		: OUT STD_LOGIC;								-- shows the value of the Z register
			  output		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- the result the ALU is giving
		);
	END COMPONENT;

	-- Create wires to connect units
	SIGNAL output : STD_LOGIC_VECTOR(3 DOWNTO 0);	-- connects the ALU result to a HexDriver
	SIGNAL clkNeg : STD_LOGIC;								-- the reversed input from the clock button,
																	--		because pressed is logic '0' and we
																	--		want pressed to be logic '1'

----------------------------------------------------------------------------------------------																
																
BEGIN
			
			-- Create the components, one ALU, a HexDrivers to display the ALU output as well as
			--		the A and B inputs
			alu0 : alu PORT MAP(A, B, loadA, loadB, loadZ, fSelect, clkNeg, zOut, output);
			hexDriver0 : HexDriver PORT MAP(output, sevenSegmentOut0);
			hexDriver1 : HexDriver PORT MAP(A, sevenSegmentOut1);
			hexDriver2 : HexDriver PORT MAP(B, sevenSegmentOut2);
			
			-- Reverse the clock input from the button so pressed becomes logic '1'
			PROCESS(clk)
			BEGIN
				clkNeg <= NOT clk;		-- store the reversed value in the clkNeg wire to be used
												--		in the ALU
				clkOut <= NOT clk;		-- use this value for the clock output check
			END PROCESS;
			
----------------------------------------------------------------------------------------------			

			-- The rest just updates LED's on the board to help with user input
			
			PROCESS(loadA)
			BEGIN
				loadA_out <= loadA;		-- show if loadA is on
			END PROCESS;
			
			PROCESS(loadB)
			BEGIN
				loadB_out <= loadB;		-- show if loadB is on
			END PROCESS;
			
			PROCESS(loadZ)
			BEGIN
				loadZ_out <= loadZ;		-- show if loadZ is on
			END PROCESS;
				
END Behavioral;
