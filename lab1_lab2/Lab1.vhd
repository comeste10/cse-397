-- HexDriver
-- Stuart Larsen
-- Steve Comer
-- Team A-Shred

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HexDriver is 

Port(numberToDisplay  : IN  STD_LOGIC_VECTOR(3 downto 0);
	  sevenSegmentOut	 : OUT STD_LOGIC_VECTOR(6 downto 0));
	  
END HexDriver;

architecture Behavioral OF HexDriver is
	BEGIN
	
		HexDriver : PROCESS(numberToDisplay)
			BEGIN
				CASE numberToDisplay IS
					WHEN "0000" => sevenSegmentOut <= "1000000";
					WHEN "0001" => sevenSegmentOut <= "1111001";
					WHEN "0010" => sevenSegmentOut <= "0100100";
					WHEN "0011" => sevenSegmentOut <= "0110000";
					WHEN "0100" => sevenSegmentOut <= "0011001";
					WHEN "0101" => sevenSegmentOut <= "0010010";
					WHEN "0110" => sevenSegmentOut <= "0000010";
					WHEN "0111" => sevenSegmentOut <= "1111000";
					WHEN "1000" => sevenSegmentOut <= "0000000";
					WHEN "1001" => sevenSegmentOut <= "0010000";
					WHEN "1010" => sevenSegmentOut <= "0001000";
					WHEN "1011" => sevenSegmentOut <= "0000011";
					WHEN "1100" => sevenSegmentOut <= "1000110";
					WHEN "1101" => sevenSegmentOut <= "0100001";
					WHEN "1110" => sevenSegmentOut <= "0000110";
					WHEN "1111" => sevenSegmentOut <= "0001110";
					WHEN OTHERS => sevenSegmentOut <= "1111111";
				END CASE;	
					
			END PROCESS HexDriver;
			
	END Behavioral;
