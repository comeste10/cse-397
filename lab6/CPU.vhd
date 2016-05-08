----------------------------------------------------------------------------------------------
-- Lab 6 																								       	  --
--	CPU 																									           --
-- Steve Comer																										  --																								  --
-- Updated 14 Nov 2012																							  --
-- SU 397 CPU																								  		  --
----------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CPU IS
PORT(
	CpuClk,CpuReset                     : IN STD_LOGIC;
	DispClk,DispReset,Porton,DispZ      : OUT STD_LOGIC;
	DispStep										: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	DispData,DispAdd1,DispAdd2,DispPort : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	DispIns,DispORH,DispORL,DispALU 		: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
END CPU;

ARCHITECTURE BEHAVIORAL OF CPU IS

COMPONENT State IS
PORT(
	instruction : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	clk 			: IN STD_LOGIC;					
	CPU_reset	: IN STD_LOGIC;
	PC_zflag    : IN STD_LOGIC;
	Ostep 		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);	
	IR_load     : OUT STD_LOGIC;							
	PC_clearPC  : OUT STD_LOGIC;							
	PC_incPC	   : OUT STD_LOGIC;							
	PC_loadPC   : OUT STD_LOGIC;							
	PC_clearX	: OUT STD_LOGIC;						
	PC_incX		: OUT STD_LOGIC;							
	PC_outSel	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);	
	ORL_load		: OUT STD_LOGIC;					
	ORH_load		: OUT STD_LOGIC;							
	ALU_loadA	: OUT STD_LOGIC;							
	ALU_loadB	: OUT STD_LOGIC;							
	ALU_loadZ	: OUT STD_LOGIC;							
	ALU_fSelect	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0); 
	AD_wt			: OUT STD_LOGIC;							
	AD_rd			: OUT STD_LOGIC							
);
END COMPONENT;

COMPONENT reg IS 
PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
	  clk			: IN  STD_LOGIC;							
	  load		: IN  STD_LOGIC;																							
	  B			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)	
);
END COMPONENT;

COMPONENT pc IS 
PORT(input  	: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);		
	  clearPC	: IN  STD_LOGIC;							
	  incPC		: IN  STD_LOGIC;								
	  loadPC		: IN  STD_LOGIC;								
	  clearX		: IN  STD_LOGIC;								
	  incX		: IN  STD_LOGIC;								
	  outSel		: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);		
	  clk			: IN STD_LOGIC;								
	  output		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));	
END COMPONENT;

COMPONENT alu IS 
PORT(A  			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		
	  B			: IN  STD_LOGIC_VECTOR(3 DOWNTO 0); 	
	  loadA		: IN  STD_LOGIC;																
	  loadB		: IN  STD_LOGIC;																							
	  loadZ		: IN  STD_LOGIC;																								
	  fSelect	: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);																		
	  clk			: IN  STD_LOGIC;																								
	  zOut		: OUT STD_LOGIC := '0';						
	  output		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)																			
);
END COMPONENT;

COMPONENT SegDriver IS
PORT(
	switches   : IN STD_LOGIC_VECTOR(3 downto 0);
	segdispout : OUT STD_LOGIC_VECTOR(0 to 6)
);
END COMPONENT;

COMPONENT ram IS
PORT(
	clk          : IN STD_LOGIC;
	readEnable   : IN STD_LOGIC;
	writeEnable  : IN STD_LOGIC;
	address      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	dataIn		 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	dataOut      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END COMPONENT;

COMPONENT ROM IS
PORT(
	clk        : IN STD_LOGIC;
	address    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	dataOut    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END COMPONENT;

COMPONENT PORTLED IS
PORT(
	enable 	  : IN  STD_LOGIC;								-- from address decoder	
	input  	  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);		-- The input value for the register
	output	  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		-- The output, for display	
);
END COMPONENT;

COMPONENT AddressDecoder IS
PORT(
	add        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	rd, wt     : IN STD_LOGIC;
	clk        : IN STD_LOGIC;
	enableROM  : OUT STD_LOGIC;
	enablePORT : OUT STD_LOGIC;
	enableALU  : OUT STD_LOGIC;
	enableRAM  : OUT STD_LOGIC
);
END COMPONENT;

COMPONENT TSB IS
PORT(
	TSBenable  : IN STD_LOGIC;
	TSBDataIn  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	TSBDataOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END COMPONENT;

SIGNAL Update 								    	: STD_LOGIC;
SIGNAL CStep										: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL dataBus,AdataBus,RdataBus 	  	 	: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL addressBus                     	 	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL SIR_load, SORH_load, SORL_load 	 	: STD_LOGIC;
SIGNAL SEPort, SEAlu, SERom, SERam       	: STD_LOGIC;
SIGNAL SAlu_Z 								    	: STD_LOGIC;
SIGNAL S_DWR										: STD_LOGIC;
SIGNAL SPC_clearPC, SPC_incPC			 	 	: STD_LOGIC;
SIGNAL SPC_loadPC, SPC_incX, SPC_clearX 	: STD_LOGIC;
SIGNAL SALU_loadA, SALU_loadB, SALU_loadZ : STD_LOGIC;
SIGNAL SAD_wt, SAD_rd 							: STD_LOGIC;
SIGNAL SPC_outSel 								: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL SALU_fSelect 								: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Sinst, SAluOut, SRomOut, SRamOut	: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL SPCinput 									: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL portLED_data 								: STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL TIR_load, TORH_load, TORL_load 	 	: STD_LOGIC;
SIGNAL TPC_clearPC, TPC_incPC			 	 	: STD_LOGIC;
SIGNAL TPC_loadPC, TPC_incX, TPC_clearX 	: STD_LOGIC;
SIGNAL TALU_loadA, TALU_loadB, TALU_loadZ : STD_LOGIC;
SIGNAL TAD_wt, TAD_rd 							: STD_LOGIC;
SIGNAL TPC_outSel 								: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL TALU_fSelect 								: STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

PROCESS (CpuClk)
BEGIN
	DispClk <= not CpuClk;
END PROCESS;

PROCESS(CpuReset)
BEGIN
	DispReset <= CpuReset;
END PROCESS;

PROCESS(SEPort)
BEGIN
	Porton <= SEPort;
END PROCESS;

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
	DispStep     <= CStep;
	DispZ			 <= SAlu_Z;
	
	IF(SEPort = '1') THEN
		dataBus <= SAluOut;
	ELSIF(SEAlu = '1') THEN
		dataBus <= AdataBus;
	ELSIF(SERam = '1' OR SERom = '1') THEN
		dataBus <= RdataBus;
	ELSE -- nonMutex attempt
		dataBus	 <= "ZZZZ";
	END IF;
END PROCESS;

IR 					: reg PORT MAP(dataBus,CpuClk,SIR_load,Sinst);
ORH 					: reg PORT MAP(dataBus,CpuClk,SORH_load,SPCinput(7 DOWNTO 4));
ORL 					: reg PORT MAP(dataBus,CpuClk,SORL_load,SPCinput(3 DOWNTO 0));

AluTsb 				: TSB PORT MAP(SEAlu,SAluOut,AdataBus);
RomTsb 				: TSB PORT MAP(SERom,SRomOut,RdataBus);
RamTsb				: TSB PORT MAP(SERam,SRamOut,RdataBus);

StateMach 			: State PORT MAP(Sinst,CpuClk,CpuReset,SAlu_Z,CStep,TIR_load,TPC_clearPC,TPC_incPC,TPC_loadPC,
						  TPC_clearX,TPC_incX,TPC_outSel,TORL_load,TORH_load,TALU_loadA,TALU_loadB,
						  TALU_loadZ,TALU_fSelect,TAD_wt,TAD_rd);
PCMod					: pc PORT MAP(SPCinput,SPC_clearPC,SPC_incPC,SPC_loadPC,SPC_clearX,SPC_incX,
                    SPC_outSel,CpuClk,addressBus);
ALUComp				: alu PORT MAP(dataBus,dataBus,SALU_loadA,SALU_loadB,SALU_loadZ,SALU_fSelect,
                    CpuClk,SAlu_Z,SAluOut);

RAMComp           : ram PORT MAP(CpuClk,SAD_rd,SAD_wt,addressBus,SAluOut,SRamOut);
ROMComp				: ROM PORT MAP(CpuClk,addressBus,SRomOut);
PORTLEDComp			: PORTLED PORT MAP(SEPort,dataBus,portLED_data);
AddrDecoder			: AddressDecoder PORT MAP(addressBus,SAD_rd,SAD_wt,CpuClk,SERom,SEPort,SEAlu,SERam);
 
PORTSEG				: SegDriver PORT MAP(portLED_data,DispPort);
AddSEG1				: SegDriver PORT MAP(addressBus(3 DOWNTO 0),DispAdd1);
AddSEG2				: SegDriver PORT MAP(addressBus(7 DOWNTO 4),DispAdd2);
DataSEG				: SegDriver PORT MAP(dataBus,DispData);
InsSEG				: SegDriver	PORT MAP(Sinst,DispIns);
orhSEG				: SegDriver PORT MAP(SPCinput(7 DOWNTO 4),DispORH);
orlSEG            : SegDriver PORT MAP(SPCinput(3 DOWNTO 0),DispORL);
ALUSEG				: SegDriver	PORT MAP(SAluOut,DispALU);

END BEHAVIORAL;