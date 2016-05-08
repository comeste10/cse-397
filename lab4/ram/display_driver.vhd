-- Lab 4
-- Hex Display Driver
-- Steve Comer
-- Updated 27 Oct 2012
-- 	HexDriver takes a 2-bit number and displays it

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY HexDriver IS

PORT(numberToDisplay  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
	  sevenSegmentOut	 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END HexDriver;

ARCHITECTURE Behavioral OF HexDriver IS
	BEGIN
	
		HexDriver : PROCESS(numberToDisplay)
			BEGIN
				CASE numberToDisplay IS                            -- Disp
					WHEN "00" => sevenSegmentOut <= "1000000";		-- 0
					WHEN "01" => sevenSegmentOut <= "1111001";		-- 1
					WHEN "10" => sevenSegmentOut <= "0100100";		-- 2
					WHEN "11" => sevenSegmentOut <= "0110000";		-- 3
				
--					WHEN "0000" => sevenSegmentOut <= "1000000";    --	0			
--					WHEN "0001" => sevenSegmentOut <= "1111001";    --	1	
--					WHEN "0010" => sevenSegmentOut <= "0100100";    -- 2	
--					WHEN "0011" => sevenSegmentOut <= "0110000";    -- 3	
--					WHEN "0100" => sevenSegmentOut <= "0011001";    -- 4  
--					WHEN "0101" => sevenSegmentOut <= "0010010";    -- 5	
--					WHEN "0110" => sevenSegmentOut <= "0000010";		-- 6	
--					WHEN "0111" => sevenSegmentOut <= "1111000";		-- 7
--					WHEN "1000" => sevenSegmentOut <= "0000000";		--	8
--					WHEN "1001" => sevenSegmentOut <= "0010000";		-- 9
--					WHEN "1010" => sevenSegmentOut <= "0001000";		-- A
--					WHEN "1011" => sevenSegmentOut <= "0000011";		-- b
--					WHEN "1100" => sevenSegmentOut <= "1000110";		-- C
--					WHEN "1101" => sevenSegmentOut <= "0100001";		--	d
--					WHEN "1110" => sevenSegmentOut <= "0000110";		-- E
--					WHEN "1111" => sevenSegmentOut <= "0001110";		-- F
--					WHEN OTHERS => sevenSegmentOut <= "1111111";		--	null
				END CASE;	
					
			END PROCESS HexDriver;
			
	END Behavioral;
