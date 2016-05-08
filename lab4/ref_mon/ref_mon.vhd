----------------------------------------------------------------------------------------------
-- Lab_4_RM																											  --
-- ref_mon																								           --
-- Steve Comer																										  --
-- Updated 28 Oct 2012																							  --
--		Process																										  --
--		 0		Read: 0-7	Write: 4-7	                                                        --																					  
--		 1		Read:	4-7	Write: 0-3                                                          --																						  
--		 2		Read:	0-15	Write: 0-14	                                                        --
--		 3		Read:	none  Write: 0-15                                                         --
----------------------------------------------------------------------------------------------

-- Import the necessary libraries.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------------------

ENTITY ref_mon IS 

-- Input and output for ref_mon
PORT(
	clk_rm              : IN STD_LOGIC;
	readEnable_rm       : IN STD_LOGIC;
	writeEnable_rm      : IN STD_LOGIC;
	address_rm          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	dataIn_rm		     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	dataOut_rm          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	proc_rm				  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	type_issue_LED		  : OUT STD_LOGIC;
	addr_issue_LED	     : OUT STD_LOGIC
);

END ref_mon;

----------------------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF ref_mon IS
	
	-- See ram.vhd
	COMPONENT ram
		PORT(
			clk          : IN STD_LOGIC;
			readEnable   : IN STD_LOGIC;
			writeEnable  : IN STD_LOGIC;
			address      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			dataIn		 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			dataOut      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			clear        : IN STD_LOGIC
		);
	END COMPONENT;
	
	-- Reference Monitor <==> RAM
	SIGNAL clear_flag  : STD_LOGIC;
	SIGNAL type_issue  : STD_LOGIC;
	SIGNAL addr_issue  : STD_LOGIC;
	
BEGIN

	Reference_Monitor_Process : PROCESS(clk_rm)
	
		-- local variables
		VARIABLE addr_int   : INTEGER;
		VARIABLE clear_var  : STD_LOGIC;
		VARIABLE type_var   : STD_LOGIC;	-- access type error
		VARIABLE addr_var   : STD_LOGIC; -- access address error
	
	BEGIN
		IF rising_edge(clk_rm) THEN
		
			-- if readEnable NAND writeEnable
			IF (NOT(readEnable_rm = '1' AND writeEnable_rm = '1')) THEN
				
				-- reset flags
				clear_var  := '0';
				addr_var   := '0';
				type_var   := '0';
				
				addr_int := conv_integer(address_rm);
				
				CASE proc_rm IS
					WHEN "00" =>
						-- valid address
						IF (addr_int >= 0 AND addr_int <= 7) THEN
							-- illegal read cases
								-- none
							-- illegal write cases
							IF (writeEnable_rm = '1' AND addr_int <= 3) THEN
								type_var := '1';
							END IF;
						-- invalid address
						ELSE                                          
							addr_var := '1';
						END IF;
						
					WHEN "01" =>
						-- valid address
						IF (addr_int >= 0 AND addr_int <= 7) THEN
							-- illegal read cases
							IF (readEnable_rm = '1' AND addr_int <= 3) THEN
								type_var := '1';
							-- illegal write cases
							ELSIF (writeEnable_rm = '1' AND addr_int >= 4) THEN
								type_var := '1';
							END IF;
						-- invalid address
						ELSE                                          
							addr_var := '1';
						END IF;
						
					WHEN "10" =>
						-- valid address
						IF (addr_int >= 0 AND addr_int <= 15) THEN
							-- illegal read cases
								-- none
							-- illegal write cases
							IF (writeEnable_rm = '1' AND addr_int = 15) THEN
								type_var := '1';
							END IF;
						-- invalid address
						ELSE                                          
							addr_var := '1';
						END IF;
					WHEN "11" =>
						-- valid address
						IF (addr_int >= 0 AND addr_int <= 15) THEN
							-- illegal read cases
							IF (readEnable_rm = '1') THEN
								type_var := '1';
							-- illegal write cases
								-- none
							END IF;
						-- invalid address
						ELSE                                          
							addr_var := '1';
						END IF;
					WHEN OTHERS =>
						-- Security Condition
						type_var := '1';
						addr_var := '1';
				END CASE;		
			END IF;
			
			-- clear conditions
			clear_var := type_var OR addr_var;
			
			-- update signals	
			clear_flag <= clear_var;
			type_issue_LED <= type_var;
			addr_issue_LED <= addr_var;
			
		END IF;
		
	END PROCESS Reference_Monitor_Process;

	ram_instance : ram PORT MAP(clk_rm,readEnable_rm,writeEnable_rm,address_rm,dataIn_rm,dataOut_rm,clear_flag);
	
END Behavioral;
