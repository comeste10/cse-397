-- Lab 2
-- Sequence Counter
-- Steve Comer
-- Stuart Larsen
-- Team A-Shred
-- Updated 18 Sept 2012
-- 	This entity outputs a sequence of states, based on the previous state. The next state is changed on clock 
-- 	high. The sequence can be reset back to its initial state with the synchronous reset pin.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY counter IS 
PORT(Reset  	: IN  STD_LOGIC;
	  Clock		: IN 	STD_LOGIC;
	  Q			: OUT STD_LOGIC_VECTOR(0 TO 3) := "0011"; -- set initial value to 3
	  clockLED	: OUT STD_LOGIC;
	  resetLED	: OUT STD_LOGIC);
	  
TYPE State IS (S0, S1, S2, S3, S4, S5, S6, S7);
SIGNAL cs : State := S3; -- initial state set to 3

END counter;

ARCHITECTURE Behavioral OF counter IS
	BEGIN
		clockLED <= NOT Clock;
		resetLED <= NOT Reset;
		
		counter : PROCESS(Clock)
			BEGIN
				IF (Clock'EVENT and Clock = '0' and Reset = '0') THEN			-- CLK pressed / Reset pressed
					Q <= "0011";
					cs <= S3;
				ELSIF (Clock'EVENT and Clock = '0' and Reset = '1') THEN		-- CLK pressed / Reset not pressed
					CASE cs IS
						WHEN S3 => 															-- if 3 -> 1
							cs <= S1;
							Q <= "0001";
						WHEN S1 =>															-- if 1 -> 6
							cs <= S6;	
							Q <= "0110";
						WHEN S6 =>															-- if 6 -> 4
							cs <= S4;
							Q <= "0100";
						WHEN S4 =>															-- if 4 -> 2
							cs <= S2;
							Q <= "0010";
						WHEN S2 =>															-- if 2 -> 0
							cs <= S0;
							Q <= "0000";
						WHEN S0 =>															-- if 0 -> 7
							cs <= S7;
							Q <= "0111";
						WHEN S7 =>															-- if 7 -> 5
							cs <= S5;
							Q <= "0101";
						WHEN S5 =>															-- if 5 -> 3
							cs <= S3;
							Q <= "0011";
						WHEN OTHERS =>														-- if other -> 3
							cs <= S3;
							Q <= "0011";
					END CASE;
				END IF;
			END PROCESS counter;
	END Behavioral;
