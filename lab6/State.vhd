----------------------------------------------------------------------------------------------
-- Lab 6																												  --
-- State																												  --
-- Steve Comer																										  --																						  --
-- Updated 8 Dec 2012																							  --
-- State Machine																									  --
----------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY State IS
PORT(
	instruction : IN STD_LOGIC_VECTOR(3 DOWNTO 0);  -- The 4-bit instruction Opcode
	clk 			: IN STD_LOGIC;							-- The Clock for timing
	CPU_reset	: IN STD_LOGIC;							-- Reset the CPU
	PC_zflag		: IN STD_LOGIC;
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
END State;

ARCHITECTURE BEHAVIORAL OF State IS

SIGNAL step  : STD_LOGIC_VECTOR(3 DOWNTO 0); -- Holds the step for the operation
SIGNAL tstep : STD_LOGIC_VECTOR(3 DOWNTO 0); -- Holds the temp step for the operation

BEGIN

PROCESS(clk)
-- 
BEGIN
	IF(rising_edge(clk))THEN
		IF (CPU_reset = '1')THEN
			step <= "1111";
			Ostep <= "1111";
		ELSE
			step <= tstep;
			Ostep <= tstep;
		END IF;
	END IF;
END PROCESS;

PROCESS(step)
-- int vars
VARIABLE intInstr : INTEGER;
 
-- Fetch, Decode, Execute, Memory
BEGIN
	-- set int vars
	intInstr := conv_integer(instruction);
	
	-- reset all signals
	IR_load     <= '0';
	PC_incPC    <= '0';
	PC_clearPC  <= '0';
	PC_loadPC   <= '0';
	PC_clearX   <= '0';
	PC_incX     <= '0';
	PC_outSel   <= "00";
	ORL_load    <= '0';
	ORH_load    <= '0';
	ALU_loadA   <= '0';
	ALU_loadB   <= '0';
	ALU_loadZ   <= '0';
	ALU_fSelect <= "101";
	AD_wt       <= '0';
	AD_rd       <= '0';
	
	-- Put ROM onto data bus
	IF(step = "0000")THEN
		AD_rd       <= '1';
		tstep       <= "0001";
		
	--Fetch
	ELSIF(step = "0001")THEN		
		IR_load     <= '1';
		AD_rd       <= '1';
		tstep 	   <= "0010";
		
	--Decode
	ELSIF(step = "0010")THEN
		PC_incPC    <= '1';
		AD_rd       <= '1';
		tstep 	   <= "0011";
		
	--Execute 1
	ELSIF(step = "0011")THEN
		CASE intInstr IS
			-- LDA #, LDA mem, LDA mem+x, STA mem, STA mem+x
			-- put regval 2 from ROM onto data bus
			WHEN 0 | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 9 | 10 | 11 | 12 | 13 =>
				AD_rd       <= '1';
				tstep 	   <= "0100";
			-- COMA
			WHEN 7 =>
				ALU_loadZ   <= '1';
				ALU_fSelect <= "100";
				tstep			<= "0100";
			-- CLEARX
			-- perform clear x operation
			-- put next instr on data bus from ROM
			WHEN 14 =>
				PC_clearX   <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0001";
			-- INCX
			-- perform inc x operation
			-- put next instr on data bus from ROM
			WHEN 15 =>
				PC_incX     <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0001";
			-- Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
		END CASE;
		
	--Execute 2
	ELSIF(step = "0100")THEN
		CASE intInstr IS
			-- LDA #
			-- load regval 2 from data bus into A
			-- enable Z flag
			WHEN 0 =>
				PC_incPC    <= '1';
				ALU_loadA   <= '1';
				--ALU_loadZ   <= '1';
				tstep 	   <= "0000";
			-- LDA mem, LDA mem+x, STA mem, STA mem+x
			-- BRA, BEQ, BNE
			-- load regval 2 into ORH
			WHEN 1 | 2 | 3| 4 | 11 | 12 | 13 =>
				PC_incPC    <= '1';
				ORH_load    <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0101";
			-- COMA
			-- put ~A onto data bus and load A
			-- inc PC
			WHEN 7 =>
				ALU_fSelect <= "100";
				ALU_loadZ   <= '1';
				ALU_loadA   <= '1';
				tstep			<= "0000";
			-- ANDA
			-- load B, output A AND B, check Z
			WHEN 5 =>
				ALU_fSelect <= "010";
				ALU_loadB   <= '1';
				ALU_loadZ   <= '1';
				tstep			<= "0101";
			-- ORA
			-- load B, output A OR B, check Z
			WHEN 6 =>
				ALU_fSelect <= "011";
				ALU_loadB   <= '1';
				ALU_loadZ   <= '1';
				tstep			<= "0101";
			-- ADDA
			-- load B, output A + B, check Z
			WHEN 8 =>
				ALU_fSelect <= "000";
				ALU_loadB   <= '1';
				ALU_loadZ   <= '1';
				tstep			<= "0101";
			-- SUBA, CMPA
			-- load B, output A - B, check Z
			-- might be a problem if CMPA writes to data bus?
			-- does it anyway
			WHEN 9 | 10 =>
				ALU_fSelect <= "001";
				ALU_loadB   <= '1';
				ALU_loadZ   <= '1';
				tstep			<= "0101";
			-- Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
		END CASE;
		
	--Execute 3
	ELSIF(step = "0101")THEN
		CASE intInstr IS
			-- LDA mem, LDA mem+x, STA mem, STA mem,x
			-- BRA, BEQ, BNE
			-- ORH is now "in"
			-- put regval 3 onto data bus
			WHEN 1 | 2 | 3 | 4 | 11 | 12 | 13 =>
				AD_rd       <= '1';
				tstep 	   <= "0110";
			-- ANDA
			-- put A AND B on data bus and load A
			-- inc PC
			WHEN 5 =>
				ALU_fSelect <= "010";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				PC_incPC		<= '1';
				tstep			<= "0000";
			-- ORA
			-- put A OR B on data bus and load A
			-- inc PC
			WHEN 6 =>
				ALU_fSelect <= "011";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				PC_incPC		<= '1';
				tstep			<= "0000";
			-- ADDA
			-- put A + B on data bus and load A
			-- inc PC
			WHEN 8 =>
				ALU_fSelect <= "000";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				PC_incPC		<= '1';
				tstep			<= "0000";
			-- SUBA
			-- put A - B on data bus and load A
			-- inc PC
			WHEN 9 =>
				ALU_fSelect <= "001";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				PC_incPC		<= '1';
				tstep			<= "0000";
			-- CMPA
			-- keep outputting A-B, might be a problem?
			-- inc PC
			WHEN 10 =>
				ALU_fSelect <= "001";
				ALU_loadZ   <= '1';
				PC_incPC    <= '1';
				tstep			<= "0000";
			-- Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
		END CASE;
		
	--Execute 4
	ELSIF(step = "0110")THEN
		CASE intInstr IS
			-- LDA mem, LDA mem+x, STA mem, STA mem+x
			-- BRA, BEQ, BNE
			-- load regval 3 from data bus into ORL
			WHEN 1 | 2 | 3 | 4 | 11 | 12 | 13 =>
				ORL_load    <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0111";
			-- Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
		END CASE;
		
	--Execute 5
	ELSIF(step = "0111")THEN
		CASE intInstr IS
			-- LDA mem, LDA mem+x, STA mem, STA mem+x
			-- BRA, BEQ, BNE
			-- ORL is now "in"
			WHEN 1 | 2 | 3 | 4 | 11 | 12 | 13 =>
				AD_rd       <= '1';
				tstep 	   <= "1000";
			--Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
		END CASE;
		
	--Execute 6
	ELSIF(step = "1000")THEN
		CASE intInstr IS
			-- LDA mem
			WHEN 1 =>
				PC_outSel   <= "10";
				AD_rd       <= '1';
				tstep 	   <= "1001";
			-- LDA mem,x
			WHEN 2 =>
				PC_outSel   <= "01";
				AD_rd       <= '1';
				tstep 	   <= "1001";
			-- STA mem
			WHEN 3 =>
				PC_outSel   <= "10";
				AD_wt       <= '1';
				tstep 	   <= "1001";
			-- STA mem,x
			WHEN 4 =>
				PC_outSel   <= "01";
				AD_wt       <= '1';
				tstep 	   <= "1001";
			-- BRA
			WHEN 11 =>
				PC_loadPC 	<= '1';
				tstep 		<= "0000";
			-- BEQ
			WHEN 12 =>
				IF (PC_zflag = '1') THEN
					PC_loadPC <= '1';
				ELSE
					PC_incPC <= '1';
				END IF;
				tstep			<= "0000";
			-- BNE
			WHEN 13 =>
				IF (PC_zflag = '0') THEN
					PC_loadPC <= '1';
				ELSE
					PC_incPC <= '1';
				END IF;
				tstep			<= "0000";
			-- Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
		END CASE;
		
	-- Memory
	ELSIF(step = "1001")THEN
		CASE intInstr IS
			-- LDA mem
			WHEN 1 =>
				PC_incPC    <= '1';
				PC_outSel   <= "10";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
			-- LDA mem,x
			WHEN 2 =>
				PC_incPC    <= '1';
				PC_outSel   <= "01";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
			-- STA mem, STA mem+x
			WHEN 3 | 4 =>
				PC_incPC    <= '1';
				PC_outSel   <= "10";
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
			-- Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				tstep 	   <= "0000";
			END CASE;
			
	-- ERRORS
	ELSE
		PC_clearPC  <= '1';
		PC_clearX   <= '1';
		AD_wt       <= '1';
		AD_rd       <= '1';
		tstep 	   <= "0000";
	END IF;
END PROCESS;

END BEHAVIORAL;

