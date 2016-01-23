library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Do not modify the port map of this structure
entity comments_fsm is
port (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
end comments_fsm;

architecture behavioral of comments_fsm is

-- The ASCII value for the '/', '*' and end-of-line characters
constant SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
constant STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
constant NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

constant IN_COMMENT : std_logic := '1';
constant NO_COMMENT : std_logic := '0';

type comment_state is (in_code, comment_start, block_comment, line_comment);
type comment_block is (star, other);

signal state : comment_state := in_code;
signal block_state : comment_block := other;


begin

-- Insert your processes here
process (clk, reset)
begin
    if reset = '1' then
        state <= in_code;
        block_state <= other;
	output <= NO_COMMENT;
    elsif rising_edge(clk) then
        case state is 
            when in_code =>
                if input = SLASH_CHARACTER then
                    state <= comment_start;
                end if;
                output <= NO_COMMENT;
            when comment_start =>
		if input = SLASH_CHARACTER then
                        state <= line_comment;
                elsif input = STAR_CHARACTER then
                        state <= block_comment;
                else
                        state <= in_code;
                end if;
                output <= NO_COMMENT;
            when block_comment =>
                case block_state is
                    when other =>
                        if input = STAR_CHARACTER then
                            block_state <= star;
                        end if;
                    when star =>
                        if input = SLASH_CHARACTER then
                            state <= in_code;
                        end if;
			block_state <= other;
                end case;
                output <= IN_COMMENT;
            when line_comment =>
                if input = NEW_LINE_CHARACTER then
                    state <= in_code;
                end if;
                output <= IN_COMMENT;
        end case;
    end if;
end process;

end behavioral;
