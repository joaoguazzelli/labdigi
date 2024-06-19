library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL; -- For reporting
use STD.TEXTIO.ALL; -- For reporting

entity TopLevel_tb is
end TopLevel_tb;

architecture Behavioral of TopLevel_tb is
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal rx : STD_LOGIC := '1';  -- UART RX signal
    signal gpio_pin : STD_LOGIC;

    constant CLOCK_PERIOD : time := 20 ns;

    component TopLevel
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            rx : in STD_LOGIC;
            gpio_pin : out STD_LOGIC
        );
    end component;

    procedure uart_transmit(signal tx_line : out STD_LOGIC; data : in STD_LOGIC) is
        constant baud_period : time := 104.167 us;  -- For 9600 baud
    begin
        report "Transmitting start bit";
        -- Start bit
        tx_line <= '0';
        wait for baud_period;
        report "Transmitting data bit: " & std_logic'image(data);
        -- Data bit
        tx_line <= data;
        wait for baud_period;
        report "Transmitting stop bit";
        -- Stop bit
        tx_line <= '1';
        wait for baud_period;
    end procedure;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: TopLevel
        Port map (
            clk => clk,
            reset => reset,
            rx => rx,
            gpio_pin => gpio_pin
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        report "Applying reset";
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        report "Reset released";

        -- Transmit '1' via UART
        report "Starting transmission of bit '1'";
        uart_transmit(rx, '1');
        wait for 2 ms;  -- Wait for processing
        report "Finished transmission of bit '1'";
        report "GPIO pin state after receiving '1': " & std_logic'image(gpio_pin);

        -- Transmit '0' via UART
        report "Starting transmission of bit '0'";
        uart_transmit(rx, '0');
        wait for 2 ms;  -- Wait for processing
        report "Finished transmission of bit '0'";
        report "GPIO pin state after receiving '0': " & std_logic'image(gpio_pin);

        -- Stop the simulation
        report "Stopping simulation";
        wait for 10 ms; -- Wait a bit longer to ensure all processes are completed
        assert false report "End of simulation" severity failure;
    end process;

end Behavioral;
