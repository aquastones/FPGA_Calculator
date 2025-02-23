library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity keyboard is
    port(
        sys_clk: in std_logic;
        ps2_clk: in std_logic;
        ps2_data: in std_logic;
        reset: in std_logic;
        char_code: out std_logic_vector(7 downto 0);
        char_ready: out std_logic
    );
end keyboard;

architecture behav of keyboard is
    type state_type is (IDLE, DATA, PARITY, STOP);
    signal next_state: state_type;
    signal counter: integer := 0;
    signal odd: std_logic := '0';
begin
    process(reset, ps2_clk)
    begin
        if reset = '1' then
            next_state <= IDLE;
            char_code <= (others => '0');
            char_ready <= '0';
            counter <= 0;
        elsif rising_edge(ps2_clk) then
            case next_state is
                when IDLE =>
                    if ps2_data = '0' then
                        char_ready <= '0';
                        odd <= '0';
                        next_state <= DATA;
                    end if;

                when DATA =>
                    char_code(counter) <= ps2_data;
                    odd <= odd xor ps2_data;
                    counter <= counter + 1;
                    if counter = 7 then
                        next_state <= PARITY;
                        counter <= 0;
                    end if;

                when PARITY =>
                    if odd = ps2_data then
                        next_state <= IDLE;
                    else
                        next_state <= STOP;
                    end if;

                when STOP =>
                    next_state <= IDLE;
                    if ps2_data = '1' then
                        char_ready <= '1';
                    end if;
            end case;
        end if;
    end process;
end architecture;