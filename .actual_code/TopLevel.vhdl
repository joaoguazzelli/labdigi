library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TopLevel is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        rx : in STD_LOGIC;
        gpio_pin : out STD_LOGIC
    );
end TopLevel;

architecture Behavioral of TopLevel is

    -- UART Receiver Implementation
    constant baud_rate : integer := 9600;
    constant clock_frequency : integer := 50000000;
    constant baud_rate_divisor : integer := clock_frequency / baud_rate;

    signal baud_count : integer range 0 to baud_rate_divisor - 1 := 0;
    signal receiving : STD_LOGIC := '0';
    signal received_bit : STD_LOGIC := '0';
    signal gpio_pin_internal : STD_LOGIC := '0';

begin

    -- Combined Process for UART Reception and GPIO Control
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                baud_count <= 0;
                receiving <= '0';
                gpio_pin_internal <= '0';
                gpio_pin <= '0';
                report "GPIO pin reset to 0";
            else
                if receiving = '0' then
                    if rx = '0' then -- Start bit detected
                        receiving <= '1';
                        baud_count <= baud_rate_divisor / 2;
                        report "Start bit detected";
                    end if;
                else
                    if baud_count = baud_rate_divisor - 1 then
                        baud_count <= 0;
                        received_bit <= rx; -- Read data bit
                        gpio_pin_internal <= rx; -- Set internal GPIO pin based on received bit
                        receiving <= '0';
                        report "Data bit received: " & std_logic'image(received_bit);
                        report "GPIO pin internal set to: " & std_logic'image(gpio_pin_internal);
                    else
                        baud_count <= baud_count + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Assign the internal GPIO pin to the output pin
    gpio_pin <= gpio_pin_internal;

end Behavioral;
