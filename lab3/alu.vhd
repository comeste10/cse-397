----------------------------------------------------------------------------------------------
-- Lab 3																												  --
-- ALU																												  --
-- Steve Comer																										  --
-- Derek Tsui																										  --
-- Kevin Vece																										  --
-- Updated 14 Oct 2012																							  --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------------------

-- Create the ALU entity which loads values and does calculations based on those values
ENTITY alu IS 

PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- The A input, or accumulator
	  B			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0); 	-- The B input
	  loadA		: IN  STD_LOGIC;								-- If a clock signal is given and loadA
																		--		is set then the ALU with load the
																		--		input value from A into registerA
	  loadB		: IN  STD_LOGIC;								-- If a clock signal is given and loadB
																		--		is set then the ALU with load the
																		--		input value from B into registerB
	  loadZ		: IN  STD_LOGIC;								-- If a clock signal is given and loadZ
																		--		is set then the ALU with load the
																		--		Z flag is the output is zero
	  fSelect	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);		-- The function select input is defined
																		--		as follows:
																		--		0: ADD (registerA + registerB)
																		--		1: SUBTRACT (registerA - registerB)
																		--		2: AND (registerA & registerB)
																		--		3: OR (registerA | registerB)
																		--		4: NOT A (~registerA)
																		--		5: A (registerA)
																		--		6: NOT B (~registerB)
																		--		7: B (registerB)
	  clk			: IN  STD_LOGIC;								-- The clock input used to synchronize
																		--		loads and operations
	  zOut		: OUT STD_LOGIC := '0';						-- The Z flag, shows if output is zero
	  output		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- The 4 bit result from the desired
																		--		operation
);

END alu;

----------------------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF alu IS
	
	-- This is a simple four bit register which updates is value if a clock input is given
	--		while load = '1'
	COMPONENT reg
		PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- the register's input
			  clk			: IN  STD_LOGIC;								-- an input clock signal
			  load		: IN  STD_LOGIC;								-- the load check
			  B			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- the value of the register
		);
	END COMPONENT;
	
	-- This is a one bit register with a clock and clear signal. If a clock input is given 
	--		the register will load the input. If the clear signal changes then the register
	--		will reset the register back to '0'
	COMPONENT bitreg IS 
		PORT(A  			: IN  STD_LOGIC;					-- the register's input
			  clk			: IN  STD_LOGIC;					-- an input clock signal
			  clear		: IN  STD_LOGIC;					-- the input reset signal
			  B			: OUT STD_LOGIC					-- the value of the register
		);
	END COMPONENT;

	-- Create wires for processes to communicate with other
	SIGNAL regA    : STD_LOGIC_VECTOR(3 DOWNTO 0);	-- holds the value of registerA
	SIGNAL regB    : STD_LOGIC_VECTOR(3 DOWNTO 0);	-- holds the value of registerB
	SIGNAL regZ 	: STD_LOGIC;							-- holds the value of registerZ
	SIGNAL outFlag : STD_LOGIC_VECTOR(3 DOWNTO 0);	-- holds the result of the ALU operation
	SIGNAL clear	: STD_LOGIC := '0';					-- used to clear registerZ

----------------------------------------------------------------------------------------------	
	
BEGIN

		-- Create the three registers to store A, B, and Z
		registerA : reg PORT MAP(A, clk, loadA, regA);
		registerB : reg PORT MAP(B, clk, loadB, regB);
		registerZ : bitreg PORT MAP(loadZ, clk, clear, regZ);
		
		-- This process calculates the desired ALU operation using the stored values in
		--		registerA and registerB
		PROCESS(fSelect, regA, regB)
		BEGIN
			CASE fSelect IS					
				WHEN "000" => 							-- ADD (registerA + registerB)																					
					outFlag <= regA + regB;
				WHEN "001" =>							-- SUBTRACT (registerA - registerB)														
					outFlag <= regA - regB;				
				WHEN "010" =>							-- AND (registerA & registerB)										
					outFlag <= regA and regB;
				WHEN "011" =>							-- OR (registerA | registerB)										
					outFlag <= regA or regB;
				WHEN "100" =>							-- NOT A (~registerA)										
					outFlag <= not regA;
				WHEN "101" =>							-- A (registerA)										
					outFlag <= regA;
				WHEN "110" =>							-- NOT B (~registerB)			
					outFlag <= not regB;
				WHEN "111" =>							-- B (registerB)						
					outFlag <= regB;
				WHEN OTHERS =>							-- safe value, just set output as zero				
					outFlag <= "0000";
			END CASE;
		END PROCESS;
	
		-- This process updates the calculated result to the output
		PROCESS (outFlag) 
		BEGIN
			output <= outFlag;						-- set the output to the ALU's result
			IF (regZ = '1') THEN						-- check if registerZ is set
				IF outFlag = "0000" THEN			--		if it is and the output is zero then
					zout <= '1';						--			set the z flag on
				ELSE										--		if output is nonzero then
					zout <= '0';						--			set the z flag off
				END IF;									--	if registerZ is not set then ignore the z flag
			END IF;
		END PROCESS;

		-- Whenever an operation is performed then the z flag does not need to be updated anymore
		PROCESS (fSelect)
		BEGIN
			IF regZ = '1' THEN			-- If registerZ was set when a function was performed then
				clear <= not clear;		--		clear the value of registerZ after the function
			END IF;							-- otherwise disregard registerZ
		END PROCESS;
		
			
END Behavioral;
