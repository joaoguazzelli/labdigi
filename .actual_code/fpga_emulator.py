import serial

# Configure the receiver end of the virtual serial port pair
ser = serial.Serial(
    port='/dev/ttyV1',  # Update with your virtual serial port name
    baudrate=9600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=1
)

def receive_bit():
    while True:
        # Read start bit
        start_bit = ser.read(1)
        if start_bit == b'\x00':
            # Read data bit
            data_bit = ser.read(1)
            if data_bit:
                bit = int.from_bytes(data_bit, byteorder='big')
                print(f"Received bit: {bit}")
                # Read stop bit
                stop_bit = ser.read(1)
                if stop_bit == b'\x01':
                    print("Received stop bit")
                else:
                    print("Error: Stop bit not received")
            else:
                print("Error: Data bit not received")
        else:
            print("Error: Start bit not received")

if __name__ == "__main__":
    print("FPGA Simulator is running...")
    receive_bit()
