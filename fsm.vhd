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

type comment_state is (in_code, block_comment, line_comment);
type comment_start is (backslash, other);
type comment_block is (star, other);

signal state : comment_state := in_code;
signal begin_comment : comment_start := other;
signal block_state : comment_block := other;


begin

-- Insert your processes here
process (clk, reset)
begin
    if reset = '1' then
        state <= in_code;
        begin_comment <= other;
    elsif rising_edge(clk) then
        case state is 
            when in_code =>
                case begin_comment is
                    when other =>
                        if input = SLASH_CHARACTER then
                            begin_comment <= backslash;
                        end if;
                    when backslash =>
                        if input = SLASH_CHARACTER then
                            state <= line_comment;
                        elsif input = STAR_CHARACTER then
                            state <= block_comment;
                        end if;
                        begin_comment <= other;
                end case; 
                output <= NO_COMMENT;
            when block_comment =>
                case block_state is
                    when other =>
                        if input = STAR_CHARACTER then
                            block_state <= star;
                        end if;
                    when star =>
                        block_state <= other;
                        if input = SLASH_CHARACTER then
                            state <= in_code;
                        end if;
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
