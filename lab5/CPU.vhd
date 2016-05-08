----------------------------------------------------------------------------------------------
-- Lab 5																												  --
-- State																												  --
-- Steve Comer																										  --
-- Edward Hazeldine																								  --
-- Michael Stikkel 																								  --
-- Updated 29 Oct 2012																							  --
-- SU 397 CPU																								  		  --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;

--Create top-level CPU entity.
ENTITY CPU IS
PORT(
	CpuClk,CpuReset                     : IN STD_LOGIC; -- CPU inputs (clock and reset)
	DispClk,DispReset,Porton            : OUT STD_LOGIC; -- CPU 1-bit outputs (clock, reset, port change)
	DispData,DispAdd1,DispAdd2,DispPort : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- CPU segment displays
	DispStep,DispIns,DispALU 				: OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- CPU segment displays (more)
);
END CPU;

ARCHITECTURE BEHAVIORAL OF CPU IS

-- CPU's state component
COMPONENT State IS
PORT(
	instruction : IN STD_LOGIC_VECTOR(3 DOWNTO 0);  -- The 4-bit instruction Opcode
	clk 			: IN STD_LOGIC;							-- The Clock for timing
	CPU_reset	: IN STD_LOGIC;							-- Reset the CPU
	Ostep 		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	IR_load     : OUT STD_LOGIC;							-- Load flag for the Instruction Register
	PC_clearPC  : OUT STD_LOGIC;							-- Clear input for counter
	PC_incPC	   : OUT STD_LOGIC;							-- Increment input for counter
	PC_loadPC   : OUT STD_LOGIC;							-- Load input for counter
	PC_clearX	: OUT STD_LOGIC;							-- Clear input for x
	PC_incX		: OUT STD_LOGIC;							-- Increment input for x
	PC_outSel	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);	-- Output select value
	ORL_load		: OUT STD_LOGIC;							-- Operand Register low
	ORH_load		: OUT STD_LOGIC;							-- Operand Register high
	ALU_loadA	: OUT STD_LOGIC;							-- Load flag for the ALU A register
	ALU_loadB	: OUT STD_LOGIC;							-- Load flag for the ALU B register
	ALU_loadZ	: OUT STD_LOGIC;							-- Load flag for the ALU Z flag
	ALU_fSelect	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- ALU function selector
	AD_wt			: OUT STD_LOGIC;							-- Address write
	AD_rd			: OUT STD_LOGIC							-- Address read						
);
END COMPONENT;

COMPONENT reg IS 
PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- The input value for the register
	  clk			: IN  STD_LOGIC;								-- A clock input used for a synchronous load
	  load		: IN  STD_LOGIC;								-- Load bit, the register will only load
																		--    the value in A if this bit is set
	  B			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- The output, the value of the register
);
END COMPONENT;

COMPONENT pc IS 
PORT(input  	: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);		-- input value
	  clearPC	: IN  STD_LOGIC;								-- clear input for counter
	  incPC		: IN  STD_LOGIC;								-- increment input for counter
	  loadPC		: IN  STD_LOGIC;								-- load input for counter
	  clearX		: IN  STD_LOGIC;								-- clear input for x
	  incX		: IN  STD_LOGIC;								-- increment input for x
	  outSel		: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);		-- output select value
	  clk			: IN STD_LOGIC;								-- clock input for synchronous load
	  output		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));	-- output value of the PC
END COMPONENT;

COMPONENT alu IS 
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
END COMPONENT;

COMPONENT SegDriver IS
PORT(
	switches   : IN STD_LOGIC_VECTOR(3 downto 0); 		-- 4-bit binary input
	segdispout : OUT STD_LOGIC_VECTOR(0 to 6) 			-- 7-bit output to seg-display
);
END COMPONENT;

COMPONENT ROM IS
PORT(
	clk     : IN STD_LOGIC;										-- clock input
	address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);			-- 8-bit address select
	dataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)			-- 4-bit data out
);
END COMPONENT;

COMPONENT PORTLED IS
PORT(
	  enable 	  : IN  STD_LOGIC;								-- from address decoder	
	  input  	  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- The input value for the register
	  output	  	  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- The output, for display	
);
END COMPONENT;

COMPONENT AddressDecoder IS
PORT(
	add        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);			-- 8-bit address input
	rd, wt     : IN STD_LOGIC;										-- read / write inputs
	clk        : IN STD_LOGIC;										-- clock input
	enableROM  : OUT STD_LOGIC;									-- control signal to ROM TSB
	enablePORT : OUT STD_LOGIC;									-- control signal to PORT TSB
	enableALU  : OUT STD_LOGIC										-- control signal to ALU TSB
);
END COMPONENT;

COMPONENT TSB IS
PORT(
	TSBenable  : IN STD_LOGIC;										-- TSB enable signal
	TSBDataIn  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);			-- TSB data in  (4 bit)
	TSBDataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)			-- TSB data out (4 bit)
);
END COMPONENT;

SIGNAL Update 								    	: STD_LOGIC;	-- Update Signal (flips on rising edge)
SIGNAL CStep										: STD_LOGIC_VECTOR(3 DOWNTO 0); -- current step output
SIGNAL dataBus,AdataBus,RdataBus 	  	 	: STD_LOGIC_VECTOR(3 DOWNTO 0); -- data bus sized signals
SIGNAL addressBus                     	 	: STD_LOGIC_VECTOR(7 DOWNTO 0); -- address bus
SIGNAL SIR_load, SORH_load, SORL_load 	 	: STD_LOGIC; -- IR ORH and ORL load signals
SIGNAL SEPort, SEAlu, SERom             	: STD_LOGIC; -- Enable Signals for Port ALU and ROM
SIGNAL SAlu_Z 								    	: STD_LOGIC; -- Enable Z for ALU
SIGNAL SPC_clearPC, SPC_incPC			 	 	: STD_LOGIC; -- PC ClearPC and incPC signals
SIGNAL SPC_loadPC, SPC_incX, SPC_clearX 	: STD_LOGIC; -- PC LoadPC, incX, and clearX signal
SIGNAL SALU_loadA, SALU_loadB, SALU_loadZ : STD_LOGIC; -- ALU loadA, loadB, and loadZ signals
SIGNAL SAD_wt, SAD_rd 							: STD_LOGIC; -- Address Decoder read and write signals
SIGNAL SPC_outSel 								: STD_LOGIC_VECTOR(1 DOWNTO 0); -- PC output select
SIGNAL SALU_fSelect 								: STD_LOGIC_VECTOR(2 DOWNTO 0); -- ALU function select
SIGNAL Sinst, SAluOut, SRomOut	 			: STD_LOGIC_VECTOR(3 DOWNTO 0); -- Inst. Reg <-> State machine and ALU and ROM outputs
SIGNAL SPCinput 									: STD_LOGIC_VECTOR(7 DOWNTO 0); -- PC inputs (from ORH and ORL)
SIGNAL portLED_data 								: STD_LOGIC_VECTOR(3 DOWNTO 0); -- port LED input

SIGNAL TIR_load, TORH_load, TORL_load 	 	: STD_LOGIC; -- next state values for corresponding signals 
SIGNAL TPC_clearPC, TPC_incPC			 	 	: STD_LOGIC; -- next state values for corresponding signals 
SIGNAL TPC_loadPC, TPC_incX, TPC_clearX 	: STD_LOGIC; -- next state values for corresponding signals 
SIGNAL TALU_loadA, TALU_loadB, TALU_loadZ : STD_LOGIC; -- next state values for corresponding signals 
SIGNAL TAD_wt, TAD_rd 							: STD_LOGIC; -- next state values for corresponding signals 
SIGNAL TPC_outSel 								: STD_LOGIC_VECTOR(1 DOWNTO 0); -- next state values for corresponding signals 
SIGNAL TALU_fSelect 								: STD_LOGIC_VECTOR(2 DOWNTO 0); -- next state values for corresponding signals 

BEGIN

-- clock light process
PROCESS (CpuClk)
BEGIN
	DispClk <= not CpuClk;
END PROCESS;

-- reset light process
PROCESS(CpuReset)
BEGIN
	DispReset <= CpuReset;
END PROCESS;

-- port led output process
PROCESS(SEPort)
BEGIN
	Porton <= SEPort;
END PROCESS;

-- update signal flip process
PROCESS (CpuClk)
BEGIN
	IF (rising_edge(CpuClk) and CpuClk = '1')THEN
		IF(Update = '0')THEN
			Update <= '1';
		ELSE
			Update <= '0';
		END IF;
	END IF;
END PROCESS;

-- update process (updates all signal values on update)
PROCESS(Update)
BEGIN
	SAD_wt		 <= TAD_wt;
	SAD_rd		 <= TAD_rd;
	SIR_load 	 <= TIR_load;
	SORH_load	 <= TORH_load;
	SORL_load	 <= TORL_load;
	SPC_clearPC	 <= TPC_clearPC;
	SPC_incPC	 <= TPC_incPC;
	SPC_loadPC	 <= TPC_loadPC;
	SPC_incX		 <= TPC_incX;
	SPC_clearX	 <= TPC_clearX;
	SALU_loadA 	 <= TALU_loadA;
	SALU_loadB	 <= TALU_loadB;
	SALU_loadZ	 <= TALU_loadZ;
	SPC_outSel   <= TPC_outSel;
	SALU_fSelect <= TALU_fSelect;
	IF(SEAlu = '1' AND SERom = '0' AND SEPort = '0')THEN
		dataBus   <= AdataBus;
	ELSIF(SEAlu = '0' AND SERom = '1' AND SEPort = '0')THEN
		dataBus	 <= RdataBus;
	ELSIF(SEAlu = '0' AND SERom = '1' AND SEPort = '1')THEN
		dataBus   <= SAluOut;
	ELSIF(SEAlu = '1' AND SERom = '0' AND SEPort = '1')THEN
		dataBus   <= SAluOut;
	ELSE
		dataBus	 <= "ZZZZ";
	END IF;
END PROCESS;

-- Components (appropriately named)
IR 					: reg PORT MAP(dataBus,CpuClk,SIR_load,Sinst);
ORH 					: reg PORT MAP(dataBus,CpuClk,SORH_load,SPCinput(7 DOWNTO 4));
ORL 					: reg PORT MAP(dataBus,CpuClk,SORL_load,SPCinput(3 DOWNTO 0));

AluTsb 				: TSB PORT MAP(SEAlu,SAluOut,AdataBus);
RomTsb 				: TSB PORT MAP(SERom,SRomOut,RdataBus);

StateMech 			: State PORT MAP(Sinst,CpuClk,CpuReset,CStep,TIR_load,TPC_clearPC,TPC_incPC,TPC_loadPC,
						  TPC_clearX,TPC_incX,TPC_outSel,TORL_load,TORH_load,TALU_loadA,TALU_loadB,
						  TALU_loadZ,TALU_fSelect,TAD_wt,TAD_rd);
PCMod					: pc PORT MAP(SPCinput,SPC_clearPC,SPC_incPC,SPC_loadPC,SPC_clearX,SPC_incX,
                    SPC_outSel,CpuClk,addressBus);
ALUComp				: alu PORT MAP(dataBus,dataBus,SALU_loadA,SALU_loadB,SALU_loadZ,SALU_fSelect,
                    CpuClk,SAlu_Z,SAluOut);

ROMComp				: ROM PORT MAP(CpuClk,addressBus,SRomOut);
PORTLEDComp			: PORTLED PORT MAP(SEPort,dataBus,portLED_data);
AddrDecoder			: AddressDecoder PORT MAP(addressBus,SAD_rd,SAD_wt,CpuClk,SERom,SEPort,SEAlu);
 
PORTSEG				: SegDriver PORT MAP(portLED_data,DispPort);
AddSEG1				: SegDriver PORT MAP(addressBus(3 DOWNTO 0),DispAdd1);
AddSEG2				: SegDriver PORT MAP(addressBus(7 DOWNTO 4),DispAdd2);
DataSEG				: SegDriver PORT MAP(dataBus,DispData);
StepSEG				: SegDriver PORT MAP(CStep, DispStep);
InsSEG				: SegDriver	PORT MAP(Sinst,DispIns);
ALUSEG				: SegDriver	PORT MAP(SAluOut,DispALU);

END BEHAVIORAL;