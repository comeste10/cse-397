-- Lab 6 												--
-- AddressDecoder 									--
-- Steve Comer 										--
-- Updated 14 Nov 2012 								--
-- Allows the external devices to Read/Write --

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY AddressDecoder IS
PORT(
	add        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	rd, wt     : IN STD_LOGIC;
	clk        : IN STD_LOGIC;
	enableROM  : OUT STD_LOGIC;
	enablePORT : OUT STD_LOGIC;
	enableALU  : OUT STD_LOGIC;
	enableRAM  : OUT STD_LOGIC
);
END AddressDecoder;

ARCHITECTURE Behavioral OF AddressDecoder IS

BEGIN

PROCESS(clk)
--Controls the Tri-State Buffers

VARIABLE enALU_var  : STD_LOGIC;
VARIABLE enPORT_var : STD_LOGIC;
VARIABLE enROM_var  : STD_LOGIC;
VARIABLE enRAM_var  : STD_LOGIC;
VARIABLE intAddr    : INTEGER;

BEGIN

IF(rising_edge (clk))THEN
	enALU_var  := '0';
	enPORT_var := '0';
	enROM_var  := '0';
	enRAM_var  := '0';
	
	intAddr := conv_integer(add);
	
		IF(wt = '0' AND rd = '0')THEN
			enALU_var  := '1';
		ELSIF(wt = '0' AND rd = '1')THEN
			IF(intAddr <= 31)THEN
				enROM_var  := '1';
			ELSIF(intAddr >= 128 AND intAddr <= 255) THEN
			   enRAM_var  := '1';
			END IF;
		ELSIF(wt = '1' AND rd = '0')THEN
			IF(intAddr = 96)THEN
				enPORT_var := '1';
			END IF;
		END IF;

	enableALU  <= enALU_var;
	enablePORT <= enPORT_var;
	enableROM  <= enROM_var;
	enableRAM  <= enRAM_var;
END IF;

END PROCESS;

END Behavioral;