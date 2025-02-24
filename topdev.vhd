library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.all;
use globals.all;

entity topdev is
    port(
        clock: in std_logic;
        reset_N: in std_logic;
        ps2_clk: in std_logic;
        ps2_data: in std_logic;
        seg0: out std_logic_vector (6 downto 0);
        seg1: out std_logic_vector (6 downto 0);
        seg2: out std_logic_vector (6 downto 0);
        seg3: out std_logic_vector (6 downto 0);
        seg4: out std_logic_vector (6 downto 0);
        seg5: out std_logic_vector (6 downto 0);
        seg6: out std_logic_vector (6 downto 0);
        seg7: out std_logic_vector (6 downto 0)
    );
end topdev;

architecture topdevarch of topdev is
    signal reset, ready, pulse: std_logic;
    signal char_code: std_logic_vector(7 downto 0);
    signal digit: std_logic_vector(3 downto 0);
    signal keyevent: key_event_type;
begin
    keyboard: entity work.keyboard
        port map(
            sys_clk => clock,
            ps2_clk => ps2_clk,
            ps2_data => ps2_data,
            reset => reset,
            char_code => char_code,
            char_ready => ready
        );

    decoder: entity work.scancode_decoder
        port map(
            sys_clk => clock,
            reset => reset,
            char_code => char_code,
            char_ready => ready,
            keydigit => digit,
            keyevent => keyevent,
            keytrigger => pulse
        );

    central_logic: entity work.calculator
        port map (
            sys_clk => clock,
            reset => reset,
            digit => digit,
            keyevent => keyevent,
            keytrigger => pulse,
            seg0 => seg0,
            seg1 => seg1,
            seg2 => seg2,
            seg3 => seg3,
            seg4 => seg4,
            seg5 => seg5,
            seg6 => seg6,
            seg7 => seg7
        );

    reset <= not reset_N;

end architecture topdevarch;