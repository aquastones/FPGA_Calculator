library ieee;
use ieee.std_logic_1164.all;
use work.all;
use globals.all;
use IEEE.NUMERIC_STD.ALL;

entity calculator is
    port(
        sys_clk: in std_logic;
        reset: in std_logic;
        digit: in std_logic_vector(3 downto 0);
        keyevent: in key_event_type;
        keytrigger: in std_logic;
        seg0: out std_logic_vector(6 downto 0);
        seg1: out std_logic_vector(6 downto 0);
        seg2: out std_logic_vector(6 downto 0);
        seg3: out std_logic_vector(6 downto 0);
        seg4: out std_logic_vector(6 downto 0);
        seg5: out std_logic_vector(6 downto 0);
        seg6: out std_logic_vector(6 downto 0);
        seg7: out std_logic_vector(6 downto 0)
    );
end calculator;

architecture behav of calculator is
    function to_7seg(input : integer) return std_logic_vector is
    begin
        case input is
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when others => return "1111111";
        end case;
    end function;

    signal operand1, operand2: std_logic_vector(7 downto 0);
    signal trig1: std_logic := '1';
    signal trig2: std_logic := '0';
    signal result, result_in: std_logic_vector(15 downto 0);
    signal result_trig, trigger: std_logic;
    signal rst, k_rst: std_logic := '0';
    signal operator: key_event_type;
    signal num: std_logic;

begin
    rst <= k_rst or reset;
    trig2 <= not trig1;

    process(keyevent)
    begin
        if keyevent = KEY_NUM then
            num <= '1';
        else
            num <= '0';
        end if;
    end process;

    sync_trig: entity work.oneshot
        port map (
            trigger_i => keytrigger,
            pulse_o => trigger,
            clock => sys_clk,
            reset => rst
        );

    reg1: entity work.decimal_shift_reg(behav)
        generic map (
            WIDTH => 8
        )
        port map (
            digit => digit,
            Q => operand1,
            trigger => trig1 and trigger and num,
            clock => sys_clk,
            reset => rst,
            max => "01100011"
        );

    reg2: entity work.decimal_shift_reg(behav)
        generic map (
            WIDTH => 8
        )
        port map (
            digit => digit,
            Q => operand2,
            trigger => trig2 and trigger and num,
            clock => sys_clk,
            reset => rst,
            max => "01100011"
        );

    result_reg: entity work.reg(behav)
        generic map (
            WIDTH => 16
        )
        port map (
            D => result_in,
            Q => result,
            enable => result_trig,
            clock => sys_clk,
            reset => rst
        );

    process(rst, sys_clk)
    begin
        if rst = '1' then
            k_rst <= '0';
            trig1 <= '1';
            result_trig <= '0';
        elsif rising_edge(sys_clk) then
            k_rst <= '0';
            result_trig <= '0';
            if trigger = '1' then
                case keyevent is
                    when KEY_RESET =>
                        k_rst <= '1';
                    when KEY_ENTER =>
                        result_trig <= '1';
                        trig1 <= '1';
                    when KEY_ADD | KEY_SUB | KEY_DIV | KEY_MUL =>
                        trig1 <= '0';
                        operator <= keyevent;
                    when others =>
                end case;
            end if;
        end if;
    end process;

    process(operator)
    begin
        case operator is
            when KEY_ADD =>
                result_in <= std_logic_vector(resize((unsigned(operand1) + unsigned(operand2)), 16));
            when KEY_SUB =>
                result_in <= std_logic_vector(resize((unsigned(operand1) - unsigned(operand2)), 16));
            when KEY_DIV =>
                result_in <= std_logic_vector(resize((unsigned(operand1) / unsigned(operand2)), 16));
            when KEY_MUL =>
                result_in <= std_logic_vector(resize((unsigned(operand1) * unsigned(operand2)), 16));
            when others =>
        end case;
    end process;

    seg7 <= to_7seg((to_integer(unsigned(operand1)) / 10) mod 10);
    seg6 <= to_7seg(to_integer(unsigned(operand1)) mod 10);
    seg5 <= to_7seg((to_integer(unsigned(operand2)) / 10) mod 10);
    seg4 <= to_7seg(to_integer(unsigned(operand2)) mod 10);
    seg3 <= to_7seg((to_integer(unsigned(result)) / 1000) mod 10);
    seg2 <= to_7seg((to_integer(unsigned(result)) / 100) mod 10);
    seg1 <= to_7seg((to_integer(unsigned(result)) / 10) mod 10);
    seg0 <= to_7seg(to_integer(unsigned(result)) mod 10);
end architecture;