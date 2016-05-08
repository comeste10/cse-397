----------------------------------------------------------------------------------------------
-- Lab 5																												  --
-- State																												  --
-- Steve Comer																										  --
-- Edward Hazeldine																								  --
-- Michael Stikkel 																								  --
-- Updated 29 Oct 2012																							  --
-- State Machine																									  --
----------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;


ENTITY State IS
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
-- Fetch, Decode, Execute, Memory
BEGIN
	--Fetch
	IF(step = "0000")THEN		
		IR_load     <= '1';
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
		ALU_fSelect <= "111";
		AD_wt       <= '0';
		AD_rd       <= '1';
		tstep 	   <= "0001";
	--Decode
	ELSIF(step = "0001")THEN
		IR_load     <= '0';
		PC_incPC    <= '1';
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
		AD_rd       <= '1';
		tstep 	   <= "0010";
	--Excute 1
	ELSIF(step = "0010")THEN
		IR_load     <= '0';
		PC_incPC    <= '0';
		PC_loadPC   <= '0';
		PC_outSel   <= "00";
		ORL_load    <= '0';
		ORH_load    <= '0';
		ALU_loadA   <= '0';
		ALU_loadB   <= '0';
		ALU_loadZ   <= '0';
		CASE instruction IS
			--INCX
			WHEN "1111" =>
				PC_incX     <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0000";
			--CLEARX
			WHEN "1110" =>
				PC_incX     <= '0';
				PC_clearPC  <= '0';
				PC_clearX   <= '1';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0000";
			-- LDA #
			WHEN "0000" =>
				PC_incX     <= '0';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0011";
			-- LDA mem
			WHEN "0001" =>
				PC_incX     <= '0';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0011";
			-- LDA mem,x
			WHEN "0010" =>
				PC_incX     <= '0';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0011";
			-- STA mem
			WHEN "0011" =>
				PC_incX     <= '0';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0011";
			--Error
			WHEN OTHERS =>
				PC_incX     <= '0';
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
		END CASE;
	--Excute 2
	ELSIF(step = "0011")THEN
		IR_load     <= '0';
		PC_incX     <= '0';
		PC_loadPC   <= '0';
		PC_outSel   <= "00";
		ORL_load    <= '0';
		ALU_loadB   <= '0';
		CASE instruction IS
			-- LDA #
			WHEN "0000" =>
				PC_incPC    <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				ORH_load    <= '0';
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				AD_wt       <= '0';
				AD_rd       <= '0';
				ALU_fSelect <= "101";
				tstep 	   <= "0100";
			-- LDA mem
			WHEN "0001" =>
				PC_incPC    <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				ORH_load    <= '1';
				ALU_loadA   <= '0';
				ALU_loadZ   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0100";
			-- LDA mem,x
			WHEN "0010" =>
				PC_incPC    <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				ORH_load    <= '1';
				ALU_loadA   <= '0';
				ALU_loadZ   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0100";
			-- STA mem
			WHEN "0011" =>
				PC_incPC    <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				ORH_load    <= '1';
				ALU_loadA   <= '0';
				ALU_loadZ   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0100";
			--Error
			WHEN OTHERS =>
				PC_incPC    <= '0';
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				ORH_load    <= '0';
				ALU_loadA   <= '0';
				ALU_loadZ   <= '0';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
		END CASE;
	--Excute 3
	ELSIF(step = "0100")THEN
		IR_load     <= '0';
		PC_incPC    <= '0';
		PC_incX     <= '0';
		PC_loadPC   <= '0';
		PC_outSel   <= "00";
		ORH_load    <= '0';
		ORL_load    <= '0';
		ALU_loadA   <= '0';
		ALU_loadB   <= '0';
		ALU_loadZ   <= '0';
		CASE instruction IS
			-- LDA #
			WHEN "0000" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0000";
			-- LDA mem
			WHEN "0001" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0101";
			-- LDA mem,x
			WHEN "0010" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0101";
				-- STA mem
			WHEN "0011" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0101";
			--Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
		END CASE;
	--Excute 4
	ELSIF(step = "0101")THEN
		IR_load     <= '0';
		PC_incPC    <= '0';
		PC_incX     <= '0';
		PC_loadPC   <= '0';
		PC_outSel   <= "00";
		ORH_load    <= '0';
		ALU_loadA   <= '0';
		ALU_loadB   <= '0';
		ALU_loadZ   <= '0';
		CASE instruction IS
			-- LDA mem
			WHEN "0001" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				ORL_load    <= '1';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0110";
			-- LDA mem,x
			WHEN "0010" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				ORL_load    <= '1';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0110";
				-- STA mem
			WHEN "0011" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				ORL_load    <= '1';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0110";
			--Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				ORL_load    <= '0';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
		END CASE;
	--Excute 5
	ELSIF(step = "0110")THEN
		IR_load     <= '0';
		PC_incPC    <= '0';
		PC_incX     <= '0';
		PC_loadPC   <= '0';
		PC_outSel   <= "00";
		ORH_load    <= '0';
		ORL_load    <= '0';
		ALU_loadA   <= '0';
		ALU_loadB   <= '0';
		ALU_loadZ   <= '0';
		CASE instruction IS
			-- LDA mem
			WHEN "0001" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0111";
			-- LDA mem,x
			WHEN ("0010") =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0111";
			-- STA mem
			WHEN "0011" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0111";
			--Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
		END CASE;
	--Excute 6
	ELSIF(step = "0111")THEN
		IR_load     <= '0';
		PC_incPC    <= '0';
		PC_incX     <= '0';
		PC_loadPC   <= '0';
		ORH_load    <= '0';
		ORL_load    <= '0';
		ALU_loadA   <= '0';
		ALU_loadB   <= '0';
		ALU_loadZ   <= '0';
		CASE instruction IS
			-- LDA mem
			WHEN ("0001") =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				PC_outSel   <= "10";
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "1000";
			-- LDA mem,x
			WHEN ("0010") =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				PC_outSel   <= "01";
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "1000";
			-- STA mem
			WHEN "0011" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				PC_outSel   <= "10";
				AD_wt       <= '1';
				AD_rd       <= '0';
				ALU_fSelect <= "101";
				tstep 	   <= "1000";
			--Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				PC_outSel   <= "00";
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
		END CASE;
	-- Memory
	ELSIF(step = "1000")THEN
		IR_load     <= '0';
		PC_incX     <= '0';
		PC_loadPC   <= '0';
		ORH_load    <= '0';
		ORL_load    <= '0';
		ALU_loadB   <= '0';
		CASE instruction IS
			-- LDA mem
			WHEN "0001" =>
				PC_incPC    <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				PC_outSel   <= "10";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "1001";
			-- LDA mem,x
			WHEN "0010" =>
				PC_incPC    <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				PC_outSel   <= "01";
				ALU_loadA   <= '1';
				ALU_loadZ   <= '1';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "1001";
			-- STA mem
			WHEN "0011" =>
				PC_incPC    <= '1';
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				PC_outSel   <= "10";
				ALU_loadA   <= '0';
				ALU_loadZ   <= '0';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "1001";
			--Error
			WHEN OTHERS =>
				PC_incPC    <= '0';
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				PC_outSel   <= "00";
				ALU_loadA   <= '0';
				ALU_loadZ   <= '0';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
			END CASE;
	-- End
	ELSIF(step = "1001")THEN
		IR_load     <= '0';
		PC_incPC    <= '0';
		PC_incX     <= '0';
		PC_loadPC   <= '0';
		PC_outSel   <= "00";
		ORH_load    <= '0';
		ORL_load    <= '0';
		ALU_loadA   <= '0';
		ALU_loadB   <= '0';
		ALU_loadZ   <= '0';
		CASE instruction IS
			-- LDA mem
			WHEN "0001" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0000";
			-- LDA mem,x
			WHEN "0010" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0000";
			-- STA mem
			WHEN "0011" =>
				PC_clearPC  <= '0';
				PC_clearX   <= '0';
				AD_wt       <= '0';
				AD_rd       <= '1';
				ALU_fSelect <= "101";
				tstep 	   <= "0000";
			--Error
			WHEN OTHERS =>
				PC_clearPC  <= '1';
				PC_clearX   <= '1';
				AD_wt       <= '1';
				AD_rd       <= '1';
				ALU_fSelect <= "111";
				tstep 	   <= "0000";
		END CASE;
	-- ERRORS
	ELSE
		IR_load     <= '0';
		PC_incPC    <= '0';
		PC_clearPC  <= '1';
		PC_loadPC   <= '0';
		PC_clearX   <= '1';
		PC_incX     <= '0';
		PC_outSel   <= "00";
		ORL_load    <= '0';
		ORH_load    <= '0';
		ALU_loadA   <= '0';
		ALU_loadB   <= '0';
		ALU_loadZ   <= '0';
		ALU_fSelect <= "111";
		AD_wt       <= '1';
		AD_rd       <= '1';
		tstep 	   <= "0000";
	END IF;
END PROCESS;

END BEHAVIORAL;

