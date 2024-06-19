library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        rx : in STD_LOGIC;
        tx : out STD_LOGIC
    );
end TopLevel;

architecture Behavioral of TopLevel is
    signal rx_data_out : STD_LOGIC_VECTOR (7 downto 0);
    signal rx_data_ready : STD_LOGIC;
    signal tx_start : STD_LOGIC := '0';
    signal tx_data_in : STD_LOGIC_VECTOR (7 downto 0);
    signal tx_busy : STD_LOGIC;
    signal wait_timer : INTEGER := 0;
    signal process_data : STD_LOGIC := '0';
    signal received_time : INTEGER := 0;

    component UART_Receiver_Transmitter
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            rx : in STD_LOGIC;
            tx_start : in STD_LOGIC;
            tx_data_in : in STD_LOGIC_VECTOR (7 downto 0);
            rx_data_out : out STD_LOGIC_VECTOR (7 downto 0);
            rx_data_ready : out STD_LOGIC;
            tx : out STD_LOGIC;
            tx_busy : out STD_LOGIC
        );
    end component;

begin
    -- Instantiate UART Receiver/Transmitter
    U1: UART_Receiver_Transmitter
        Port map (
            clk => clk,
            reset => reset,
            rx => rx,
            tx_start => tx_start,
            tx_data_in => tx_data_in,
            rx_data_out => rx_data_out,
            rx_data_ready => rx_data_ready,
            tx => tx,
            tx_busy => tx_busy
        );

    -- Process to handle the wait timer
    process(clk, reset)
    begin
        if reset = '1' then
            wait_timer <= 0;
            process_data <= '0';
            received_time <= 0;
        elsif rising_edge(clk) then
            if rx_data_ready = '1' then
                received_time <= to_integer(unsigned(rx_data_out));
                -- Start the wait timer with the received time (assuming received time is in seconds)
                wait_timer <= received_time * 50_000_000;  -- Convert to clock cycles (50 MHz clock)
                process_data <= '0';
                report "Wait timer initialized with received time: " & integer'image(received_time) & " seconds";
            elsif wait_timer > 0 then
                wait_timer <= wait_timer - 1;
                if wait_timer = 1 then
                    process_data <= '1';
                    report "Wait timer completed";
                end if;
            end if;
        end if;
    end process;

    -- Process to print received data after the wait timer
    process(clk, reset)
    begin
        if reset = '1' then
            -- Do nothing on reset
        elsif rising_edge(clk) then
            if process_data = '1' then
                report "Received data after wait: " & integer'image(received_time);
                process_data <= '0';  -- Reset the process_data signal after processing
            end if;
        end if;
    end process;

end Behavioral;
