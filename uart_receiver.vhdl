library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Receiver_Transmitter is
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
end UART_Receiver_Transmitter;

architecture Behavioral of UART_Receiver_Transmitter is
    constant BAUD_RATE : integer := 9600;
    constant CLOCK_FREQ : integer := 50000000; -- Assuming a 50 MHz clock
    constant TICKS_PER_BIT : integer := CLOCK_FREQ / BAUD_RATE;

    -- UART Receiver signals
    type rx_state_type is (RX_IDLE, RX_START_BIT, RX_DATA_BITS, RX_STOP_BIT);
    signal rx_state : rx_state_type := RX_IDLE;
    signal rx_bit_count : integer := 0;
    signal rx_tick_count : integer := 0;
    signal rx_shift_reg : STD_LOGIC_VECTOR (7 downto 0);
    signal rx_data_out_internal : STD_LOGIC_VECTOR (7 downto 0);
    signal rx_data_ready_internal : STD_LOGIC := '0';

    -- UART Transmitter signals
    type tx_state_type is (TX_IDLE, TX_START_BIT, TX_DATA_BITS, TX_STOP_BIT);
    signal tx_state : tx_state_type := TX_IDLE;
    signal tx_bit_count : integer := 0;
    signal tx_tick_count : integer := 0;
    signal tx_shift_reg : STD_LOGIC_VECTOR (7 downto 0);
    signal tx_reg : STD_LOGIC := '1';
    signal tx_busy_internal : STD_LOGIC := '0';

begin
    -- UART Receiving Process
    process(clk, reset)
    begin
        if reset = '1' then
            rx_state <= RX_IDLE;
            rx_bit_count <= 0;
            rx_tick_count <= 0;
            rx_shift_reg <= (others => '0');
            rx_data_out_internal <= (others => '0');
            rx_data_ready_internal <= '0';
        elsif rising_edge(clk) then
            case rx_state is
                when RX_IDLE =>
                    rx_data_ready_internal <= '0';
                    if rx = '0' then -- Start bit detected
                        rx_state <= RX_START_BIT;
                        rx_tick_count <= 0;
                    end if;
                
                when RX_START_BIT =>
                    if rx_tick_count = TICKS_PER_BIT / 2 then
                        if rx = '0' then
                            rx_state <= RX_DATA_BITS;
                            rx_bit_count <= 0;
                            rx_tick_count <= 0;
                        else
                            rx_state <= RX_IDLE; -- False start bit, go back to idle
                        end if;
                    else
                        rx_tick_count <= rx_tick_count + 1;
                    end if;
                
                when RX_DATA_BITS =>
                    if rx_tick_count = TICKS_PER_BIT then
                        rx_tick_count <= 0;
                        rx_shift_reg(rx_bit_count) <= rx;
                        if rx_bit_count = 7 then
                            rx_state <= RX_STOP_BIT;
                        else
                            rx_bit_count <= rx_bit_count + 1;
                        end if;
                    else
                        rx_tick_count <= rx_tick_count + 1;
                    end if;
                
                when RX_STOP_BIT =>
                    if rx_tick_count = TICKS_PER_BIT then
                        if rx = '1' then
                            rx_data_out_internal <= rx_shift_reg;
                            rx_data_ready_internal <= '1';
                        end if;
                        rx_state <= RX_IDLE;
                    else
                        rx_tick_count <= rx_tick_count + 1;
                    end if;
            end case;
        end if;
    end process;

    -- UART Transmitting Process
    process(clk, reset)
    begin
        if reset = '1' then
            tx_state <= TX_IDLE;
            tx_bit_count <= 0;
            tx_tick_count <= 0;
            tx_shift_reg <= (others => '0');
            tx_reg <= '1';
            tx_busy_internal <= '0';
        elsif rising_edge(clk) then
            case tx_state is
                when TX_IDLE =>
                    tx_busy_internal <= '0';
                    if tx_start = '1' then
                        tx_shift_reg <= tx_data_in;
                        tx_state <= TX_START_BIT;
                        tx_tick_count <= 0;
                        tx_reg <= '0'; -- Start bit
                        tx_busy_internal <= '1';
                    end if;

                when TX_START_BIT =>
                    if tx_tick_count = TICKS_PER_BIT then
                        tx_state <= TX_DATA_BITS;
                        tx_bit_count <= 0;
                        tx_tick_count <= 0;
                        tx_reg <= tx_shift_reg(tx_bit_count);
                    else
                        tx_tick_count <= tx_tick_count + 1;
                    end if;

                when TX_DATA_BITS =>
                    if tx_tick_count = TICKS_PER_BIT then
                        tx_tick_count <= 0;
                        if tx_bit_count = 7 then
                            tx_state <= TX_STOP_BIT;
                        else
                            tx_bit_count <= tx_bit_count + 1;
                            tx_reg <= tx_shift_reg(tx_bit_count + 1);
                        end if;
                    else
                        tx_tick_count <= tx_tick_count + 1;
                    end if;

                when TX_STOP_BIT =>
                    if tx_tick_count = TICKS_PER_BIT then
                        tx_state <= TX_IDLE;
                        tx_reg <= '1'; -- Stop bit
                    else
                        tx_tick_count <= tx_tick_count + 1;
                    end if;
            end case;
        end if;
    end process;

    -- Output assignments
    rx_data_out <= rx_data_out_internal;
    rx_data_ready <= rx_data_ready_internal;
    tx <= tx_reg;
    tx_busy <= tx_busy_internal;
end Behavioral;
