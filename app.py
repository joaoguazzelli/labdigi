from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
import time
import threading
import serial

app = Flask(__name__)
CORS(app)  # Allow all CORS requests

received_data = None
target_time = None
data_ready = threading.Event()

# Configure the serial port (update port and baudrate as necessary)
ser = serial.Serial(
    port='/dev/ttyV0',  # Update with your virtual serial port name
    baudrate=9600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=1
)

def send_integer_as_bytes(value):
    if not (0 <= value < 256):
        raise ValueError("Value must be between 0 and 255")
    ser.write(value.to_bytes(1, byteorder='big'))

def calculate_wait_time(target_time_str):
    now = datetime.now()
    target_time = datetime.strptime(target_time_str, "%H:%M").replace(year=now.year, month=now.month, day=now.day)
    if target_time < now:
        target_time += timedelta(days=1)
    wait_time = (target_time - now).total_seconds()
    return int(wait_time)

@app.route('/set_time', methods=['POST'])
def set_time():
    global target_time, data_ready
    data = request.json
    target_time = data['time']
    wait_time_seconds = calculate_wait_time(target_time)
    data_ready.clear()
    threading.Thread(target=wait_and_process, args=(wait_time_seconds,)).start()
    return jsonify({"status": "Timer started", "wait_time_seconds": wait_time_seconds})

def wait_and_process(wait_time):
    time.sleep(wait_time)
    send_integer_as_bytes(1)  # Signal to FPGA that time is up
    data_ready.set()

@app.route('/get_timer_status', methods=['GET'])
def get_timer_status():
    data_ready.wait()
    return jsonify({"status": "Time is up"})

@app.route('/reset_timer', methods=['POST'])
def reset_timer():
    send_integer_as_bytes(0)  # Signal to FPGA to reset the timer
    return jsonify({"status": "Timer reset"})

if __name__ == '__main__':
    app.run(debug=True)
