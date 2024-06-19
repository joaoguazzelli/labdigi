library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MathProblemGenerator is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        generate_signal : in STD_LOGIC;
        user_input : in INTEGER;
        correct_output : out STD_LOGIC;
        operand_a : out INTEGER range 0 to 255;
        operand_b : out INTEGER range 0 to 255
    );
end MathProblemGenerator;

architecture Behavioral of MathProblemGenerator is
    signal a, b, result : INTEGER := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            a <= 0;
            b <= 0;
            correct_output <= '0';
        elsif rising_edge(clk) then
            if generate_signal = '1' then
                -- Simple random number generation for demonstration
                a <= a + 1;
                b <= b + 2;
                if a > 9 then
                    a <= 0;
                end if;
                if b > 9 then
                    b <= 0;
                end if;
            end if;
            result <= a + b;
            if user_input = result then
                correct_output <= '1';
            else
                correct_output <= '0';
            end if;
        end if;
    end process;

    operand_a <= a;
    operand_b <= b;
end Behavioral;
