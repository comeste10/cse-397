--SegDriver
--Hazeldine

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SegDriver IS

PORT(
	switches   : IN STD_LOGIC_VECTOR(3 downto 0);
	segdispout : OUT STD_LOGIC_VECTOR(0 to 6)
);

END SegDriver;

ARCHITECTURE BEHAVIORAL OF SegDriver IS
BEGIN
	PROCESS(switches)
	-- 7-SEG DRIVER
	BEGIN
		CASE switches IS
			WHEN "0000" => segdispout <= "0000001";
								
			WHEN "0001" => segdispout <= "1001111";
			
			WHEN "0010" => segdispout <= "0010010";
			
			WHEN "0011" => segdispout <= "0000110";
			
			WHEN "0100" => segdispout <= "1001100";
		
			WHEN "0101" => segdispout <= "0100100";
			
			WHEN "0110" => segdispout <= "0100000";
		
			WHEN "0111" => segdispout <= "0001111";
		
			WHEN "1000" => segdispout <= "0000000";
			
			WHEN "1001" => segdispout <= "0000100";
			
			WHEN "1010" => segdispout <= "0001000";
			
			WHEN "1011" => segdispout <= "1100000";
			
			WHEN "1100" => segdispout <= "0110001";
		
			WHEN "1101" => segdispout <= "1000010";
			
			WHEN "1110" => segdispout <= "0110000";
			
			WHEN "1111" => segdispout <= "0111000";
			
			WHEN OTHERS => segdispout <= "0111111";
		END CASE;
	END PROCESS;
END BEHAVIORAL;