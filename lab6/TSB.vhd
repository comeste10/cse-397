-- Lab 5 --
-- TSB --
-- Steve Comer --
-- Edward Hazeldine --
-- Michael Stikkel --
-- Updated 29 Oct 2012 --
-- Protects the BUS from unexpected writes.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;


ENTITY TSB IS
PORT(
	TSBenable: 	IN STD_LOGIC;
	TSBDataIn:	IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	TSBDataOut:	OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END TSB;

ARCHITECTURE Behavioral OF TSB IS

BEGIN

PROCESS(TSBDataIn, TSBenable)
--display input switches
BEGIN
	IF TSBenable = '1' THEN
		TSBDataOut <= TSBDataIn;
	ELSE
		TSBDataOut <= "ZZZZ";
	END IF;
END PROCESS;

END Behavioral;