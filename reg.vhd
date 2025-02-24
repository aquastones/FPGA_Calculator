library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity reg is
    generic(WIDTH: integer := 4);
    port(
        D: in std_logic_vector(WIDTH - 1 downto 0);
        Q: out std_logic_vector(WIDTH - 1 downto 0);
        clock: in std_logic;
        enable: in std_logic;
        reset: in std_logic
    );
end reg;

architecture behav of reg is
begin
    process (reset, clock, enable)
    begin
        if reset = '1' then
            Q <= (others => '0');
        elsif rising_edge(clock) and enable = '1' then
            Q <= D;
        end if;
    end process;
end behav;