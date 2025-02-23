library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity decimal_shift_reg is
    generic (WIDTH: integer := 4);
    port (
        clock: in std_logic;
        reset: in std_logic;
        digit: in std_logic_vector(3 downto 0);
        trigger: in std_logic;
        max: in std_logic_vector(WIDTH - 1 downto 0);
        Q: buffer std_logic_vector(WIDTH - 1 downto 0)
    );
end decimal_shift_reg;

architecture behav of decimal_shift_reg is
    signal D: std_logic_vector(WIDTH - 1 downto 0);
begin
    reg: entity work.reg(behav)
    generic map (
        WIDTH => WIDTH
    )
    port map (
        D => D,
        Q => Q,
        enable => trigger,
        clock => clock,
        reset => reset
    );

    D <= std_logic_vector(resize((unsigned(Q) * 10 + unsigned(digit)) mod (unsigned(max) + 1), WIDTH));

end architecture;