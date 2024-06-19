from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
import time
import threading
import random

app = Flask(__name__)
CORS(app)  # Allow all CORS requests

received_data = None
target_time = None
data_ready = threading.Event()
current_problem = None

def generate_math_problem():
    a = random.randint(1, 10)
    b = random.randint(1, 10)
    return f"{a} + {b}", a + b

def calculate_wait_time(target_time_str):
    now = datetime.now()
    target_time = datetime.strptime(target_time_str, "%H:%M").replace(year=now.year, month=now.month, day=now.day)
    if target_time < now:
        target_time += timedelta(days=1)
    wait_time = (target_time - now).total_seconds()
    return wait_time

@app.route('/set_time', methods=['POST'])
def set_time():
    global target_time, data_ready
    data = request.json
    target_time = data['time']
    received_data = data['data']
    wait_time_seconds = calculate_wait_time(target_time)
    data_ready.clear()
    threading.Thread(target=wait_and_process, args=(wait_time_seconds,)).start()
    return jsonify({"status": "Timer started", "wait_time_seconds": wait_time_seconds})

def wait_and_process(wait_time):
    global current_problem
    time.sleep(wait_time)
    problem, solution = generate_math_problem()
    current_problem = (problem, solution)
    # Send bit to FPGA to control buzzer (implement this based on your FPGA communication setup)
    data_ready.set()

@app.route('/get_problem', methods=['GET'])
def get_problem():
    data_ready.wait()
    return jsonify({"problem": current_problem[0]})

@app.route('/check_answer', methods=['POST'])
def check_answer():
    global current_problem
    data = request.json
    answer = int(data['answer'])
    if answer == current_problem[1]:
        # Stop FPGA buzzer (implement this based on your FPGA communication setup)
        return jsonify({"correct": True})
    else:
        problem, solution = generate_math_problem()
        current_problem = (problem, solution)
        return jsonify({"correct": False, "new_problem": current_problem[0]})

if __name__ == '__main__':
    app.run(debug=True)
