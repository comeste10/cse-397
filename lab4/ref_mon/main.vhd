----------------------------------------------------------------------------------------------
-- Lab_4_RM																											  --
-- main																												  --
-- Steve Comer																										  --
-- Updated 28 Oct 2012																							  --
-- 	main program for ram	with reference monitor														  --
--		passes input to reference monitor                                                     --
--    receives output from reference monitor                                                --
--    passes output from reference monitor to displays/LEDs                                 --
-- problems:                                                                                --
-- 	two clock cycles required for transition from error state ==> legal state             --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------------------

ENTITY main IS 

-- Input and output for main
PORT(
	clk                  : IN STD_LOGIC;
	readEnable           : IN STD_LOGIC;
	writeEnable          : IN STD_LOGIC;
	address              : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	proc                 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	dataIn	            : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	sevenSegmentOut_data : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	sevenSegmentOut_p    : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	sevenSegmentOut_a    : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	type_issue_LED       : OUT STD_LOGIC;
	addr_issue_LED       : OUT STD_LOGIC;
	clkOut               : OUT STD_LOGIC
);

END main;

----------------------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF main IS
	
	-- See ref_mon.vhd
	COMPONENT ref_mon
		PORT(
			clk_rm            : IN STD_LOGIC;
			readEnable_rm     : IN STD_LOGIC;
			writeEnable_rm    : IN STD_LOGIC;
			address_rm        : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			dataIn_rm		   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			dataOut_rm        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			proc_rm			   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			type_issue_LED		: OUT STD_LOGIC;
			addr_issue_LED	   : OUT STD_LOGIC
		);
	END COMPONENT;
	
	-- See display_driver_2.vhd
	COMPONENT HexDriver_2
		PORT(
			numberToDisplay  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			sevenSegmentOut  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;
	
	-- See display_driver_4.vhd
	COMPONENT HexDriver_4
		PORT(
			numberToDisplay  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			sevenSegmentOut  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;
	
	-- Reference Monitor <==> Hex Driver
   SIGNAL dataOut_signal     : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL clkNeg_signal      : STD_LOGIC;
	
BEGIN
		
	Negate_Clock_Process : PROCESS(clk)
	BEGIN
		clkNeg_signal <= NOT clk;		
		clkOut <= NOT clk;
	END PROCESS Negate_Clock_Process;
	
	ref_mon_instance : ref_mon PORT MAP(clkNeg_signal,readEnable,writeEnable,address,
                      dataIn,dataOut_signal,proc,type_issue_LED,addr_issue_LED);
	hexDriver_data   : HexDriver_2 PORT MAP(dataOut_signal,sevenSegmentOut_data);
	hexDriver_proc   : HexDriver_2 PORT MAP(proc,sevenSegmentOut_p);
	hexDriver_addr   : HexDriver_4 PORT MAP(address,sevenSegmentOut_a);
		
END Behavioral;