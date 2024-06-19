library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel_tb is
end TopLevel_tb;

architecture Behavioral of TopLevel_tb is
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal rx_signal : STD_LOGIC := '1';  -- Signal to simulate UART RX
    signal tx : STD_LOGIC;

    constant BAUD_RATE : integer := 9600;
    constant CLOCK_PERIOD : time := 20 ns;
    constant BIT_PERIOD : time := 1 sec / BAUD_RATE;

    component TopLevel
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            rx : in STD_LOGIC;
            tx : out STD_LOGIC
        );
    end component;

    procedure uart_transmit(signal tx_line : out STD_LOGIC; data : in STD_LOGIC_VECTOR(7 downto 0)) is
    begin
        -- Start bit
        tx_line <= '0';
        wait for BIT_PERIOD;
        -- Data bits
        for i in 0 to 7 loop
            tx_line <= data(i);
            wait for BIT_PERIOD;
        end loop;
        -- Stop bit
        tx_line <= '1';
        wait for BIT_PERIOD;
    end procedure;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: TopLevel
        Port map (
            clk => clk,
            reset => reset,
            rx => rx_signal,
            tx => tx
        );

    -- Clock process definitions
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
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- Send data via UART (example: 5 seconds -> 00000101)
        uart_transmit(rx_signal, "00000101");

        -- Wait for some time to observe the behavior
        wait for 5 sec;

        -- Stop the simulation
        wait;
    end process;

end Behavioral;
