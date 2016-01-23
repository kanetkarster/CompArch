LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY fsm_tb IS
END fsm_tb;

ARCHITECTURE behaviour OF fsm_tb IS

COMPONENT comments_fsm IS
PORT (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
END COMPONENT;

--Types for char and string
subtype char is std_logic_vector(7 downto 0);
type str is array (8 downto 0) of char;

--The input signals with their initial values
SIGNAL clk, s_reset, s_output: STD_LOGIC := '0';
SIGNAL s_input: std_logic_vector(7 downto 0) := (others => '0');

CONSTANT clk_period : time := 1 ns;

CONSTANT SLASH_CHARACTER : char := "00101111";
CONSTANT STAR_CHARACTER : char := "00101010";
CONSTANT NEW_LINE_CHARACTER : char := "00001010";
CONSTANT CHAR_A : char := "01000001";
CONSTANT CHAR_B : char := "01000010";



signal ALL_CODE : str := (CHAR_A, CHAR_B, CHAR_A, CHAR_A, CHAR_B, CHAR_A, CHAR_B, CHAR_A, CHAR_A);

signal ALL_LN_COMMENT : str := (SLASH_CHARACTER, SLASH_CHARACTER, STAR_CHARACTER, CHAR_A, CHAR_B, CHAR_A, CHAR_B, NEW_LINE_CHARACTER, CHAR_B);
signal PART_LN_COMMENT: str := (CHAR_A, SLASH_CHARACTER, SLASH_CHARACTER, STAR_CHARACTER, CHAR_B, CHAR_A, NEW_LINE_CHARACTER, CHAR_B, SLASH_CHARACTER);

signal ALL_BLK_COMMENT: str := (SLASH_CHARACTER, STAR_CHARACTER, CHAR_A, CHAR_B, CHAR_A, NEW_LINE_CHARACTER, CHAR_B, STAR_CHARACTER, SLASH_CHARACTER);
signal PART_BLK_COMMENT: str := (CHAR_A, CHAR_B, SLASH_CHARACTER, STAR_CHARACTER, SLASH_CHARACTER, SLASH_CHARACTER, STAR_CHARACTER, SLASH_CHARACTER, CHAR_B);

BEGIN
dut: comments_fsm
PORT MAP(clk, s_reset, s_input, s_output);

 --clock process
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;
 
--TODO: Thoroughly test your FSM
stim_process: PROCESS
BEGIN    
	-- Making the entire string part of a comment
	REPORT "Tests ALL_LN_COMMENT: `//*ABAB\nB`";
	FOR i IN 8 DOWNTO 7 loop
		s_input <= ALL_LN_COMMENT(i);
                WAIT FOR 1 * clk_period;
		ASSERT (s_output = '0') REPORT "Before Comment, should be 0" SEVERITY ERROR;	
	END LOOP; --i
	FOR i IN 6 DOWNTO 1 loop
		s_input <= ALL_LN_COMMENT(i);
                WAIT FOR 1 * clk_period;
		ASSERT (s_output = '1') REPORT "In Comment, should be 1" SEVERITY ERROR;
	END LOOP; --i
	s_input <= ALL_LN_COMMENT(0);
	WAIT FOR 1 * clk_period;
        ASSERT (s_output = '0') REPORT "After Comment, should be 0" SEVERITY ERROR;
	REPORT "_______________________";

	s_reset <= '1';
	WAIT FOR 1 * clk_period;
	s_reset <= '0';
	ASSERT (s_output = '0') REPORT "Couldn't Reset, should be '0'" SEVERITY ERROR;
	
	-- Simple tests, to make sure normal Code behaviour works
	REPORT "Tests ALL_CODE, should stay '0'";
	FOR i IN 8 DOWNTO 0 loop
		s_input <= ALL_CODE(i);
		WAIT FOR 1 * clk_period;
		ASSERT (s_output = '0') REPORT "When there are no comments, the output should be '0'" SEVERITY ERROR;
	END LOOP; --i
	REPORT "_______________________";

	s_reset <= '1';
	WAIT FOR 1 * clk_period;
	s_reset <= '0';
	ASSERT (s_output = '0') REPORT "Couldn't Reset, should be '0'" SEVERITY ERROR;

	-- Ensures new line ends line comment
	REPORT "Tests PART_LN_COMMENT. `A//ABAB\n/`";
	FOR i IN 8 DOWNTO 6 loop
		s_input <= PART_LN_COMMENT(i);
		WAIT FOR 1 * clk_period;
		ASSERT (s_output = '0') REPORT "Before Comment Starts, should be '0'" SEVERITY ERROR;
	END LOOP; --i
	FOR i IN 5 DOWNTO 2 loop
		s_input <= PART_LN_COMMENT(i);
		WAIT FOR 1 * clk_period;
                ASSERT (s_output = '1') REPORT "In Comment, should be 1" SEVERITY ERROR;
	END LOOP; --i
	FOR i IN 1 DOWNTO 0 loop
		s_input <= PART_LN_COMMENT(i);
		WAIT FOR 1 * clk_period;
                ASSERT (s_output = '0') REPORT "After Comment, should be 0" SEVERITY ERROR;
	END LOOP; --i
	REPORT "_______________________";

	s_reset <= '1';
	WAIT FOR 1 * clk_period;
	s_reset <= '0';
	ASSERT (s_output = '0') REPORT "Couldn't Reset, should be '0'" SEVERITY ERROR;

	-- Makes sure block comments work with normal comment headers inside
	REPORT "Tests ALL_BLK_COMMENT `/*ABA\nB*/`";
	FOR i IN 8 DOWNTO 7 loop
		s_input <= ALL_BLK_COMMENT(i);
                WAIT FOR 1 * clk_period;
		ASSERT (s_output = '0') REPORT "Before Comment, should be 0" SEVERITY ERROR;	
	END LOOP; --i
	FOR i IN 6 DOWNTO 0 loop
		s_input <= ALL_BLK_COMMENT(i);
                WAIT FOR 1 * clk_period;
		ASSERT (s_output = '1') REPORT "In Comment, should be 1" SEVERITY ERROR;
	END LOOP; --i
	REPORT "_______________________";

	s_reset <= '1';
	WAIT FOR 1 * clk_period;
	s_reset <= '0';
	ASSERT (s_output = '0') REPORT "Couldn't Reset, should be '0'" SEVERITY ERROR;

	REPORT "Tests PART_BLK_COMMENT, `AB/*//*/B`";
	FOR i IN 8 DOWNTO 5 loop
		s_input <= PART_BLK_COMMENT(i);
		WAIT FOR 1 * clk_period;
		ASSERT (s_output = '0') REPORT "Before Comment Starts, should be '0'" SEVERITY ERROR;
	END LOOP; --i
	FOR i IN 4 DOWNTO 1 loop
		s_input <= PART_BLK_COMMENT(i);
		WAIT FOR 1 * clk_period;
                ASSERT (s_output = '1') REPORT "In Comment, should be 1" SEVERITY ERROR;
	END LOOP; --i

	s_input <= PART_BLK_COMMENT(0);
	WAIT FOR 1 * clk_period;
        ASSERT (s_output = '0') REPORT "After Comment, should be 0" SEVERITY ERROR;

	REPORT "_______________________";
	WAIT;
END PROCESS stim_process;
END;
