library ieee;
use ieee.std_logic_1164.all;
use work.all;
use globals.all;

entity scancode_decoder is
    port(
        sys_clk: in std_logic;
        reset: in std_logic;
        char_code: in std_logic_vector(7 downto 0);
        char_ready: in std_logic;
        keydigit: out std_logic_vector(3 downto 0);
        keyevent: buffer key_event_type;
        keytrigger: buffer std_logic
    );
end scancode_decoder;

architecture behav of scancode_decoder is
    type state_type is (ONE, TWO, RELEASE);
    signal next_state: state_type := ONE;
    signal next_event: key_event_type := KEY_OTHER;
    signal next_digit: std_logic_vector(3 downto 0);
    signal next_trigger, sync_ready: std_logic;
begin
    oneshot: entity work.oneshot(behav)
        port map (
            trigger_i => char_ready,
            pulse_o => sync_ready,
            clock => sys_clk,
            reset => reset
        );

    process(reset, sys_clk)
    begin
        if reset = '1' then
            keytrigger <= '0';
            keydigit <= "0000";
            keyevent <= KEY_OTHER;
        elsif rising_edge(sys_clk) then
            if keytrigger = '1' then
                keytrigger <= '0';
            end if;
            if sync_ready = '1' and next_trigger = '1' and next_event /= KEY_OTHER then
                keyevent <= next_event;
                keydigit <= next_digit;
                keytrigger <= '1';
            end if;
        end if;
    end process;

    process(reset, char_ready)
    begin
        if reset = '1' then
            next_state <= ONE;
        elsif rising_edge(char_ready) then
            next_trigger <= '0';
            case next_state is
                when ONE =>
                    case char_code is
                        when x"E0" =>
                            next_state <= TWO;
                        when x"F0" =>
                            next_state <= TWO;
                            next_event <= KEY_OTHER;
                        when x"70" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0000";
                            next_trigger <= '1';
                        when x"69" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0001";
                            next_trigger <= '1';
                        when x"72" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0010";
                            next_trigger <= '1';
                        when x"7A" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0011";
                            next_trigger <= '1';
                        when x"6B" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0100";
                            next_trigger <= '1';
                        when x"73" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0101";
                            next_trigger <= '1';
                        when x"74" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0110";
                            next_trigger <= '1';
                        when x"6C" =>
                            next_event <= KEY_NUM;
                            next_digit <= "0111";
                            next_trigger <= '1';
                        when x"75" =>
                            next_event <= KEY_NUM;
                            next_digit <= "1000";
                            next_trigger <= '1';
                        when x"7D" =>
                            next_event <= KEY_NUM;
                            next_digit <= "1001";
                            next_trigger <= '1';
                        when x"7C" =>
                            next_event <= KEY_MUL;
                            next_trigger <= '1';
                        when x"7B" =>
                            next_event <= KEY_SUB;
                            next_trigger <= '1';
                        when x"79" =>
                            next_event <= KEY_ADD;
                            next_trigger <= '1';
                        when x"76" =>
                            next_event <= KEY_RESET;
                            next_trigger <= '1';
                        when others =>
                            next_event <= KEY_OTHER;
                    end case;
                when TWO =>
                    case char_code is
                        when x"F0" =>
                            next_state <= RELEASE;
                        when x"4A" =>
                            next_event <= KEY_DIV;
                            next_state <= ONE;
                            next_trigger <= '1';
                        when x"5A" =>
                            next_event <= KEY_ENTER;
                            next_state <= ONE;
                            next_trigger <= '1';
                        when others =>
                            next_state <= ONE;
                            next_event <= KEY_OTHER;
                    end case;
                when RELEASE =>
                    next_state <= ONE;
            end case;
        end if;
    end process;
end architecture;